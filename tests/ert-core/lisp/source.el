;;; source.el --- core source regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-test-stree-org-round-trip ()
  (let* ((mode (copy-sequence "mode"))
         (math (copy-sequence "math"))
         (sum (copy-sequence "x+"))
         (numerator (copy-sequence "1"))
         (denominator (copy-sequence "2"))
         (stree
          (list 'with
                mode
                math
                (list 'concat
                      sum
                      (list 'frac numerator denominator))))
         (tree (org-texmacs--stree-to-org stree))
         (round-trip (org-texmacs--org-to-stree tree)))
    (should (equal round-trip stree))
    (dolist (string (list mode math sum numerator denominator))
      (should-not (text-properties-at 0 string)))
    (dolist (string
             (list (nth 1 round-trip)
                   (nth 2 round-trip)
                   (nth 1 (nth 3 round-trip))
                   (nth 1 (nth 2 (nth 3 round-trip)))
                   (nth 2 (nth 2 (nth 3 round-trip)))))
      (should-not (text-properties-at 0 string)))))

(ert-deftest org-texmacs-test-stree-to-org-copies-strings ()
  (let* ((source (copy-sequence "1"))
         (tree (org-texmacs--stree-to-org (list 'frac source "2")))
         (converted (car (org-element-contents tree))))
    (should (equal converted source))
    (should-not (eq converted source))
    (should-not (text-properties-at 0 source))))

(ert-deftest org-texmacs-test-stree-to-org-builds-parent-links ()
  (let* ((tree
          (org-texmacs--stree-to-org
           '(with "mode" "math"
                  (concat "x+" (frac "1" "2")))))
         (root-contents (org-element-contents tree))
         (mode (nth 0 root-contents))
         (math (nth 1 root-contents))
         (concat-node (nth 2 root-contents))
         (concat-contents (org-element-contents concat-node))
         (sum (nth 0 concat-contents))
         (frac-node (nth 1 concat-contents))
         (frac-contents (org-element-contents frac-node)))
    (should (eq (org-element-property :parent mode) tree))
    (should (eq (org-element-property :parent math) tree))
    (should (eq (org-element-property :parent concat-node) tree))
    (should (eq (org-element-property :parent sum) concat-node))
    (should (eq (org-element-property :parent frac-node) concat-node))
    (dolist (string frac-contents)
      (should (eq (org-element-property :parent string)
                  frac-node)))))

(ert-deftest org-texmacs-block-case-markers-and-raw-source ()
  (dolist (fold '(nil t))
    (dolist (begin '("begin" "BEGIN" "BeGiN"))
      (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
        (dolist (end '("end" "END" "EnD"))
          (dolist (end-type '("texmacs" "TEXMACS" "TeXmAcS"))
            (with-temp-buffer
              (org-mode)
              (let ((body "(math (concat \"MiXeD α\" \"<alpha>\"))\n")
                    (case-fold-search fold))
                (insert (format "#+%s_%s\n%s#+%s_%s\n" begin type body end end-type))
                (goto-char (point-min))
                (let ((block (org-element-at-point))
                      (text (buffer-string)) (tick (buffer-modified-tick)))
                  (should (org-texmacs--block-p block))
                  (should (equal (org-element-property :type block) type))
                  (should (equal (org-texmacs--block-source block) body))
                  (should (equal (org-element-property :type block) type))
                  (should (equal (buffer-string) text))
                  (should (= (point) (point-min)))
                  (should (= (buffer-modified-tick) tick))
                  (should (eq case-fold-search fold)))))))))))

(ert-deftest org-texmacs-block-case-fragment-exclusion ()
  (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
    (with-temp-buffer
      (org-mode)
      (insert "Before (math \"outside\").\n\n"
              (format "#+BEGIN_%s\n" type)
              "#+begin_quote\n(math \"inside\")\n#+end_quote\n"
              "#+END_TEXMACS\n\nAfter (MATH \"literal\").\n")
      (let ((text (buffer-string)) (tick (buffer-modified-tick)) (position (point)))
        (should (equal (org-texmacs-test--fragment-sources) '("(math \"outside\")")))
        (should (equal (buffer-string) text))
        (should (= (buffer-modified-tick) tick))
        (should (= (point) position))))))

(ert-deftest org-texmacs-block-case-preprocessing-shield ()
  (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
    (org-texmacs-test--with-bibliography-files
      (let ((payload (concat (format "#+BEGIN_%s\n" type)
                             "#+INCLUDE: \"absent.org\"\n#+SETUPFILE: absent.org\n"
                             "#+END_TEXMACS\n")))
        (write-region payload nil "included.org" nil 'silent)
        (insert payload "#+INCLUDE: \"included.org\"\n")
        (let* ((state (org-texmacs-test--document-buffer-state (current-buffer)))
               (result (org-texmacs-test--compose))
               (source (plist-get result :source))
               (first (string-match (regexp-quote payload) source)))
          (should first)
          (should (string-match (regexp-quote payload) source (+ first (length payload))))
          (should (= (length (plist-get result :sources)) 1))
          (should (equal state (org-texmacs-test--document-buffer-state (current-buffer)))))))))

(ert-deftest org-texmacs-block-case-bibliography-shield ()
  (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
    (org-texmacs-test--with-bibliography-files
      (insert "#+bibliography: refs.bib\n" (format "#+BEGIN_%s\n" type)
              "#+bibliography: absent.bib\n#+SETUPFILE: absent.org\n"
              "[cite:@GhostKey]\n#+END_TEXMACS\n")
      (let ((state (org-texmacs-test--document-buffer-state (current-buffer))))
        (cl-letf (((symbol-function 'org-file-contents)
                   (lambda (&rest _) (ert-fail "STM caused external keyword read"))))
          (let ((result (org-texmacs--bibliography-discover
                         (buffer-string) (org-texmacs--fragment-tags)
                         (org-texmacs--document-heading-settings)
                         (org-texmacs--document-link-settings)
                         (plist-put (org-texmacs--document-options)
                                    :texmacs-resource-base default-directory)
                         nil default-directory nil)))
            (should (equal (car result) '("refs.bib")))))
        (should (equal state (org-texmacs-test--document-buffer-state (current-buffer))))))))

(ert-deftest org-texmacs-fragment-issue10-discovery ()
  :tags '(issue10)
  (dolist (prefix '("[fn::" "[fn:n:"))
    (with-temp-buffer
      (org-mode)
      (insert "A" prefix "Before (math \"x\") after (math \"y\")].\n")
      (let ((before (org-texmacs-test--document-buffer-state (current-buffer))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) (ert-fail "Discovery started worker"))))
          (let ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity)))
            (should (equal (mapcar #'org-texmacs-fragment-span-source spans)
                           '("(math \"x\")" "(math \"y\")")))
            (dolist (span spans)
              (should (equal (org-texmacs-fragment-span-source
                              (org-texmacs-fragment-at-point (org-texmacs-fragment-span-begin span)))
                             (org-texmacs-fragment-span-source span))))))
        (should (equal before (org-texmacs-test--document-buffer-state (current-buffer))))))))

(ert-deftest org-texmacs-test-fragment-prefix ()
  (with-temp-buffer
    (insert "(mathjax \"x\") (foo bar) (math\"x\") (math \"y\") (math) (math(frac))")
    (goto-char (point-min))
    (dotimes (_ 3)
      (let ((start (org-texmacs--fragment-next "(math")))
        (should start)
        (should (equal (buffer-substring start (point)) "(math"))))
    (should-not (org-texmacs--fragment-next "(math"))))

(ert-deftest org-texmacs-test-fragment-prefix-is-case-sensitive ()
  (dolist (fold '(t nil))
    (with-temp-buffer
      (insert "(MATH \"x\") (Math \"y\") (math \"z\") (mAth \"w\")")
      (goto-char (point-min))
      (let* ((case-fold-search fold)
             (start (org-texmacs--fragment-next "(math")))
        (should start)
        (should (equal (buffer-substring-no-properties start (point))
                       "(math"))
        (should-not (org-texmacs--fragment-next "(math"))
        (should (eq case-fold-search fold))))))

(ert-deftest org-texmacs-test-fragment-structural-boundaries ()
  (dolist (source '("(math \"x\")" "(math)" "(math(frac \"1\" \"2\"))"
                    "(math\n (frac \"1\" (sqrt \"x\")))"
                    "(math (concat \"a)\\\"b\" \"c\\\\d\"))"
                    "(math \"; #; #| |# ' ` , \\\\ \\\"\")"))
    (ert-info (source)
      (with-temp-buffer
        (org-mode)
        (insert source " tail")
        ;; Source text properties must not override the dedicated table.
        (put-text-property (point-min) (point-max) 'syntax-table '(1))
        (let ((position (point)))
          (should (= (org-texmacs--fragment-end (point-min))
                     (1+ (length source))))
          (should (= (point) position)))))))

(ert-deftest org-texmacs-test-fragment-rejects-reader-extensions ()
  (dolist (source '("(math ; ) comment\n \"x\")"
                    "(math #; (sqrt \"x\") \"y\")"
                    "(math #| ) comment |# \"x\")"
                    "(math #\\))" "(math '(sqrt \"x\"))"
                    "(math `(sqrt ,x))" "(math (|escaped tag| \"x\"))"
                    "(math (escaped\\)tag \"x\"))"
                    "(math \"unclosed)" "(math (frac \"1\" \"2\")"))
    (ert-info (source)
      (with-temp-buffer
        (insert source)
        (should-not (org-texmacs--fragment-end (point-min)))))))

(ert-deftest org-texmacs-test-fragment-structural-scan-stays-in-paragraph ()
  (with-temp-buffer
    (insert "(math \"x\"\n\nNext )\n")
    (narrow-to-region (point-min) 11)
    (should-not (org-texmacs--fragment-end (point-min)))))

(ert-deftest org-texmacs-test-fragment-source-cases ()
  (dolist (case
           '(("A (math \"x\") B\n" "(math \"x\")")
             ("A (math (frac \"1\" (sqrt \"x\"))) B\n" "(math (frac \"1\" (sqrt \"x\")))")
             ("A (math (concat \"a)\\\"b\" \"c\\\\d\")) B\n" "(math (concat \"a)\\\"b\" \"c\\\\d\"))")
             ("A (math\n (frac \"1\" \"2\")) B\n" "(math\n (frac \"1\" \"2\"))")
             ("A (math \"x\") B (math \"y\") C\n" "(math \"x\")" "(math \"y\")")
             ("A (math(frac \"1\" \"2\")) B\n" "(math(frac \"1\" \"2\"))")
             ("A (mathjax \"x\") B (foo bar) C (math\"x\")\n")
             ("A (MATH \"x\") B (Math \"y\") C\n")
             ("A (math (frac \"1\" \"2\") B\n\nNext ) paragraph.\n")
             ("A (math \"unclosed) B\n")
             ("A ~(math \"x\")~ B =(math \"y\")= C\n")
             ("A [[file:x][(math \"x\")]] B *(math \"y\")* C\n")
             ("A /(math \"x\")/ B _(math \"y\")_ C +(math \"z\")+ D\n")
             ("A (math (concat \"*bold*\" \"[[file:x]]\" \"~code~\")) B\n"
              "(math (concat \"*bold*\" \"[[file:x]]\" \"~code~\"))")
             ("* Heading (math \"x\")\n")
             ("| cell (math \"x\") |\n")
             ("#+begin_src scheme\n(math \"x\")\n#+end_src\n")
             ("#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
             ("#+begin_texmacs\n#+begin_quote\n(math \"x\")\n#+end_quote\n#+end_texmacs\n")
             ("#+begin_quote\nText (math \"x\")\n#+end_quote\n" "(math \"x\")")
             ("- Item (math \"x\")\n" "(math \"x\")")
             ("A (math (unknown ...)) B\n" "(math (unknown ...))")
             ("A (math \"literal ; #; #| |#\") B\n" "(math \"literal ; #; #| |#\")")
             ("A (math ;; ) comment\n \"x\") B\n")
             ("A (math #; (sqrt \"x\") \"y\") B\n")
             ("A (math #| ) comment |# \"x\") B\n")
             ("A (math ; comment (math \"not-a-formula\")\n \"x\") B (math \"y\")\n")
             ("A (math (frac \"1\" \"2\") B (math \"y\") C\n")
             ("(math \"x\")(math \"y\")" "(math \"x\")" "(math \"y\")")
             ("A (math (concat \"(math)\" (math \"x\"))) B\n"
              "(math (concat \"(math)\" (math \"x\")))")))
    (ert-info ((car case))
      (with-temp-buffer
        (org-mode)
        (insert (car case))
        (let ((text (buffer-string))
              (position (point))
              (tick (buffer-chars-modified-tick)))
          (should (equal (org-texmacs-test--fragment-sources) (cdr case)))
          (should (equal (buffer-string) text))
          (should (= (point) position))
          (should (= (buffer-chars-modified-tick) tick)))))))

(ert-deftest org-texmacs-test-fragment-scan-is-isolated ()
  (with-temp-buffer
    (org-mode)
    (insert "Text (math \"*bold* [[file:x]]\") end\n")
    (put-text-property (point-min) (point-max) 'org-texmacs-test t)
    (let ((buffer (current-buffer))
          (text (buffer-string))
          (position (point))
          (tick (buffer-modified-tick))
          (buffer-read-only t)
          (org-mode-hook (list (lambda () (ert-fail "Mode hooks must not run")))))
      (cl-letf (((symbol-function 'org-texmacs--worker-start)
                 (lambda () (ert-fail "Scanning must not start a worker")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (_) (ert-fail "Scanning must not request a tree"))))
        (let* ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity))
               (span (car spans))
               (source (org-texmacs-fragment-span-source span)))
          (should (= (length spans) 1))
          (should (org-texmacs-fragment-span-p span))
          (should (eq (org-texmacs-fragment-span-buffer span) buffer))
          (should (= (org-texmacs-fragment-span-tick span) (buffer-chars-modified-tick)))
          (should (equal source (buffer-substring-no-properties
                                (org-texmacs-fragment-span-begin span)
                                (org-texmacs-fragment-span-end span))))
          (dotimes (index (length source))
            (should-not (text-properties-at index source)))))
      (should (equal-including-properties (buffer-string) text))
      (should (= (buffer-modified-tick) tick))
      (should (= (point) position))
      (should (equal (org-element-map (org-element-parse-buffer) '(bold link)
                      #'org-element-type) '(bold link))))))

(ert-deftest org-texmacs-test-fragment-at-point-boundaries ()
  (with-temp-buffer
    (org-mode)
    (insert "前文 (math \"α\") 后文\n")
    (let* ((span (car (org-texmacs-fragment-map (point-min) (point-max) #'identity)))
           (begin (org-texmacs-fragment-span-begin span))
           (end (org-texmacs-fragment-span-end span)))
      (dotimes (offset (- end begin))
        (goto-char (+ begin offset))
        (should (equal (org-texmacs-fragment-at-point) span)))
      (should (equal (org-texmacs-fragment-at-point begin) span))
      (should-not (org-texmacs-fragment-at-point (1- begin)))
      (should-not (org-texmacs-fragment-at-point end))
      (should-not (org-texmacs-fragment-at-point (point-max))))))

(ert-deftest org-texmacs-test-fragment-region-filtering-preserves-precedence ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math (concat \"~foo\" \"bar\")) after (math \"y\") end~ Z\n")
    (let* ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity))
           (first (car spans))
           (second (cadr spans))
           (begin (org-texmacs-fragment-span-begin first))
           (end (org-texmacs-fragment-span-end first)))
      (should (equal (mapcar #'org-texmacs-fragment-span-source spans)
                     '("(math (concat \"~foo\" \"bar\"))" "(math \"y\")")))
      (should (equal (org-texmacs-test--fragment-sources begin end)
                     (list (org-texmacs-fragment-span-source first))))
      (should-not (org-texmacs-test--fragment-sources (1+ begin) end))
      (should-not (org-texmacs-test--fragment-sources begin (1- end)))
      (should-not (org-texmacs-test--fragment-sources begin begin))
      ;; Even with the first formula outside the region, mask it before
      ;; checking the second one's native Org context.
      (should (equal (org-texmacs-test--fragment-sources (1+ begin) (point-max))
                     (list (org-texmacs-fragment-span-source second)))))))

(ert-deftest org-texmacs-test-fragment-mask-preserves-shape ()
  (dolist (source '("(math)" "(math \"*bold* [[file:x]] ~code~\")"
                    "(math\n (concat \"α\"\r\n\t\"β\"))"))
    (let ((copy (copy-sequence source))
          (mask (org-texmacs--fragment-mask source)))
      (should (equal source copy))
      (should (= (length source) (length mask)))
      (should (= (aref mask 0) ?\())
      (should (= (aref mask (1- (length mask))) ?\)))
      (cl-loop for index from 1 below (1- (length source))
               for character = (aref source index)
               do (should (= (aref mask index)
                             (if (memq character '(?\s ?\t ?\r ?\n))
                                 character ?x)))))))

(ert-deftest org-texmacs-test-fragment-masking-preserves-adjacent-markup ()
  (dolist (delimiter '("*" "~" "=" "/" "+"))
    (ert-info (delimiter)
      (with-temp-buffer
        (org-mode)
        (insert "A (math \"x\")" delimiter "(math \"y\")" delimiter " B\n")
        ;; The closing parenthesis does not open native emphasis/code.
        ;; Masking must not replace it with an enabling space.
        (should-not (org-element-map (org-element-parse-buffer)
                        '(bold code verbatim italic strike-through) #'identity))
        (let* ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity))
               (second (cadr spans)))
          (should (equal (mapcar #'org-texmacs-fragment-span-source spans)
                         '("(math \"x\")" "(math \"y\")")))
          (should (equal (org-texmacs-fragment-at-point
                          (org-texmacs-fragment-span-begin second)) second))
          (should (equal (org-texmacs-test--fragment-sources
                          (org-texmacs-fragment-span-begin second)
                          (org-texmacs-fragment-span-end second))
                         '("(math \"y\")"))))))))

(ert-deftest org-texmacs-test-fragment-masking-keeps-native-object-exclusions ()
  (dolist (delimiter '("*" "~" "=" "/" "+"))
    (ert-info (delimiter)
      (with-temp-buffer
        (org-mode)
        ;; An actual source space, unlike a masking artifact, enables markup.
        (insert "A (math \"x\") " delimiter "(math \"y\")" delimiter " B\n")
        (should (= (length (org-element-map (org-element-parse-buffer)
                              '(bold code verbatim italic strike-through) #'identity)) 1))
        (should (equal (org-texmacs-test--fragment-sources) '("(math \"x\")")))
        (goto-char (point-min))
        (search-forward "(math \"y\")")
        (should-not (org-texmacs-fragment-at-point (1- (point))))))))

(ert-deftest org-texmacs-test-fragment-scan-resumes-next-paragraph ()
  (dolist (bad '("(math \"unclosed) (math \"hidden\")"
                 "(math ; ) comment (math \"hidden\")"
                 "(math #\\)) (math \"hidden\")"))
    (with-temp-buffer
      (org-mode)
      (insert "A (math \"before\") B " bad "\n\nNext (math \"after\")\n")
      (should (equal (org-texmacs-test--fragment-sources)
                     '("(math \"before\")" "(math \"after\")"))))))

(ert-deftest org-texmacs-test-fragment-narrowing ()
  (with-temp-buffer
    (org-mode)
    (insert "Outside (math \"outside\")\n\n正文 (math \"α\") 尾部\n\nEnd\n")
    (goto-char (point-min))
    (search-forward "正文")
    (let ((begin (line-beginning-position))
          (end (line-beginning-position 2)))
      (narrow-to-region begin end)
      (let ((position (point)))
        (let ((span (car (org-texmacs-fragment-map begin end #'identity))))
          (should (equal (org-texmacs-fragment-span-source span) "(math \"α\")"))
          (should (equal (buffer-substring-no-properties
                          (org-texmacs-fragment-span-begin span)
                          (org-texmacs-fragment-span-end span)) "(math \"α\")")))
        (should (= (point) position)))
      (should (= (point-min) begin))
      (should (= (point-max) end)))))

(ert-deftest org-texmacs-test-fragment-rejects-invalid-arguments ()
  (with-temp-buffer
    (insert "(math \"x\")")
    (should-error (org-texmacs-fragment-at-point) :type 'org-texmacs-error)
    (should-error (org-texmacs-test--fragment-sources) :type 'org-texmacs-error)
    (org-mode)
    (dolist (position (list 0 (1+ (point-max)) "1" 1.5))
      (should-error (org-texmacs-fragment-at-point position) :type 'org-texmacs-error))
    (dolist (bounds (list '(0 2) '(3 2) '("1" 2) (list 1 (1+ (point-max)))))
      (should-error (org-texmacs-fragment-map (car bounds) (cadr bounds) #'identity)
                    :type 'org-texmacs-error))
    (should-error (org-texmacs-fragment-map (point-min) (point-max) 'not-a-function)
                  :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-fragment-map-callback-context ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math \"x\") B (math \"y\") C\n")
    (let ((buffer (current-buffer))
          (position (point))
          (begin (point-min))
          (end (point-max)))
      (should (equal (org-texmacs-fragment-map
                      begin end
                      (lambda (_span)
                        (should (eq (current-buffer) buffer))
                        (should (= (point) position))
                        (should (= (point-min) begin))
                        (should (= (point-max) end))
                        (goto-char begin)
                        (narrow-to-region begin (1+ begin))
                        nil))
                     '(nil nil)))
      (should (= (point) position))
      (should (= (point-min) begin))
      (should (= (point-max) end)))))

(ert-deftest org-texmacs-test-fragment-map-rejects-callback-source-changes ()
  (dolist (action '(edit kill change-buffer change-mode))
    (with-temp-buffer
      (org-mode)
      (insert "A (math \"x\") B (math \"y\") C\n")
      (let ((calls 0)
            (other (generate-new-buffer " *org-texmacs-test-other*")))
        (unwind-protect
            (progn
              (should-error
               (org-texmacs-fragment-map
                (point-min) (point-max)
                (lambda (_span)
                  (cl-incf calls)
                  (pcase action
                    ('edit (insert "changed"))
                    ('kill (kill-buffer (current-buffer)))
                    ('change-buffer (set-buffer other))
                    ('change-mode (fundamental-mode)))))
               :type 'org-texmacs-error)
              (should (= calls 1)))
          (kill-buffer other))))))

(ert-deftest org-texmacs-test-fragment-tree-rejects-invalid-spans ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_) (ert-fail "Invalid spans must not request parsing"))))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\")")
      (dolist (span (list nil "(math \"x\")" '(math nil "x")
                          (org-texmacs--fragment-span-create)
                          (org-texmacs--fragment-span-create :buffer (current-buffer))))
        (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))
      (dolist (bounds (list '(0 2) '(1 nil) '(nil 2) '(3 2) '(1 1) '("1" 2)
                            (list 1 (1+ (point-max)))))
        (let ((span (org-texmacs--fragment-span-create
                     :buffer (current-buffer) :tick (buffer-chars-modified-tick)
                     :begin (car bounds) :end (cadr bounds) :source "(math \"x\")"
                     :tag "math" :tags (org-texmacs--fragment-tags))))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))
      (let ((span (org-texmacs-test--first-fragment)))
        (aset (org-texmacs-fragment-span-source span) 7 ?y)
        (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))))

(ert-deftest org-texmacs-test-fragment-tree-rejects-stale-source ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_) (ert-fail "Stale spans must not request parsing"))))
    (dolist (action '(body prefix restored-text major-mode))
      (with-temp-buffer
        (org-mode)
        (insert "A (math \"x\") B\n")
        (let ((span (org-texmacs-test--first-fragment)))
          (pcase action
            ('body
             (goto-char (point-min))
             (search-forward "\"x\"")
             (replace-match "\"y\"" t t))
            ('prefix (goto-char (point-min)) (insert "Prefix "))
            ('restored-text (insert " ") (delete-char -1))
            ('major-mode (fundamental-mode)))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))))))

(ert-deftest org-texmacs-test-fragment-tree-rejects-other-or-dead-buffer ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_) (ert-fail "Wrong-buffer spans must not request parsing"))))
    (let ((span nil))
      (with-temp-buffer
        (org-mode)
        (insert "A (math \"x\") B\n")
        (setq span (org-texmacs-test--first-fragment))
        (with-temp-buffer
          (org-mode)
          (insert "A (math \"x\") B\n")
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))
      (should-not (buffer-live-p (org-texmacs-fragment-span-buffer span)))
      (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))))

(ert-deftest org-texmacs-test-fragment-tree-narrowing-and-text-properties ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math \"x\") B\n")
    (let* ((span (org-texmacs-test--first-fragment))
           (begin (org-texmacs-fragment-span-begin span))
           (end (org-texmacs-fragment-span-end span))
           (calls 0))
      (put-text-property begin end 'org-texmacs-test t)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (cl-incf calls)
                   (should (equal source "(math \"x\")"))
                   (should-not (text-properties-at 0 source))
                   '(math "x"))))
        (save-restriction
          (narrow-to-region begin end)
          (should (equal (org-texmacs--org-to-stree (org-texmacs-fragment-tree span))
                         '(math "x")))
          (should (= (point-min) begin))
          (should (= (point-max) end)))
        (dolist (bounds (list (list (1+ begin) end) (list begin (1- end))))
          (save-restriction
            (narrow-to-region (car bounds) (cadr bounds))
            (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))
        (should (= calls 1))))))

(ert-deftest org-texmacs-test-fragment-tree-rechecks-after-worker-wait ()
  (dolist (action '(edit kill change-buffer narrow span-string))
    (with-temp-buffer
      (org-mode)
      (insert "A (math \"x\") B\n")
      (let ((span (org-texmacs-test--first-fragment))
            (other (generate-new-buffer " *org-texmacs-test-other*")))
        (unwind-protect
            (cl-letf (((symbol-function 'org-texmacs--worker-request)
                       (lambda (_)
                         ;; Model actions that can happen while waiting for
                         ;; process output, without depending on timer timing.
                         (pcase action
                           ('edit (insert "changed"))
                           ('kill (kill-buffer (current-buffer)))
                           ('change-buffer (set-buffer other))
                           ('narrow (narrow-to-region (point-min) (1+ (point-min))))
                           ('span-string (aset (org-texmacs-fragment-span-source span) 9 ?x)))
                         '(math "x")))
                      ((symbol-function 'org-texmacs--stree-to-org)
                       (lambda (_) (ert-fail "Stale results must not reach the adapter"))))
              (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))
          (kill-buffer other))))))

(ert-deftest org-texmacs-test-fragment-tree-root-and-error-contract ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math \"x\") B\n")
    (let ((span (org-texmacs-test--first-fragment)))
      (dolist (stree '("x" (frac "1" "2") (MATH "x") (equation "x")
                       nil (1 "x")))
        (cl-letf (((symbol-function 'org-texmacs--worker-request) (lambda (_) stree)))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-parse-error)))
      (dolist (condition '(org-texmacs-parse-error org-texmacs-worker-error))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_) (signal condition '("test error")))))
          (should (equal (should-error (org-texmacs-fragment-tree span) :type condition)
                         (list condition "test error"))))))))

(ert-deftest org-texmacs-test-fragment-tree-copies-stree-strings ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math \"x\") B\n")
    (let* ((span (org-texmacs-test--first-fragment))
           (string (copy-sequence "x"))
           (stree (list 'math string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request) (lambda (_) stree)))
        (let* ((tree (org-texmacs-fragment-tree span))
               (child (car (org-element-contents tree))))
          (should (equal child string))
          (should-not (eq child string))
          (should (eq (org-element-property :parent child) tree))
          (should-not (text-properties-at 0 string))
          (should-not (text-properties-at 0 (org-texmacs-fragment-span-source span)))
          (should (equal (org-texmacs--org-to-stree tree) stree)))))))

(ert-deftest org-texmacs-test-fragment-default-tags ()
  (should (equal org-texmacs-fragment-tags
                 '("math" "equation" "equation*" "eqnarray" "eqnarray*"
                   "align" "align*" "gather" "gather*" "eqsplit" "eqsplit*")))
  (should (equal org-texmacs-fragment-tags
                 (mapcar (lambda (stree) (symbol-name (car stree)))
                         org-texmacs-test--fragment-strees))))

(ert-deftest org-texmacs-test-fragment-default-sources ()
  (dolist (stree org-texmacs-test--fragment-strees)
    (let ((single (prin1-to-string stree)))
      (dolist (source (list single (replace-regexp-in-string " (" "\n (" single t t)))
        (ert-info ((format "%S: %s" (car stree) source))
          (with-temp-buffer
            (org-mode)
            (insert "A " source " Z\n")
            (let* ((text (buffer-string))
                   (position (point))
                   (tick (buffer-chars-modified-tick))
                   (spans (org-texmacs-fragment-map (point-min) (point-max) #'identity))
                   (span (car spans))
                   (end (+ 3 (length source))))
              (should (= (length spans) 1))
              (should (= (org-texmacs-fragment-span-begin span) 3))
              (should (= (org-texmacs-fragment-span-end span) end))
              (should (equal (org-texmacs-fragment-span-source span) source))
              (should (equal (org-texmacs-fragment-span-tag span)
                             (symbol-name (car stree))))
              (should (equal (org-texmacs-fragment-at-point 3) span))
              (should (equal (org-texmacs-fragment-at-point (1- end)) span))
              (should-not (org-texmacs-fragment-at-point end))
              (should (equal (org-texmacs-test--fragment-sources 3 end) (list source)))
              (should-not (org-texmacs-test--fragment-sources 4 end))
              (should-not (org-texmacs-test--fragment-sources 3 (1- end)))
              (should (equal (buffer-string) text))
              (should (= (point) position))
              (should (= (buffer-chars-modified-tick) tick)))))))))

(ert-deftest org-texmacs-test-fragment-default-native-exclusions ()
  (dolist (stree org-texmacs-test--fragment-strees)
    (let ((source (prin1-to-string stree)))
      (dolist (wrapper '("A ~%s~ B\n" "A =%s= B\n" "A *%s* B\n"
                         "A [[file:x][%s]] B\n" "* Heading %s\n" "| %s |\n"
                         "#+begin_src scheme\n%s\n#+end_src\n"
                         "#+begin_texmacs\n%s\n#+end_texmacs\n"
                         "#+begin_texmacs\n#+begin_quote\n%s\n#+end_quote\n#+end_texmacs\n"))
        (ert-info ((format "%S: %s" (car stree) wrapper))
          (with-temp-buffer
            (org-mode)
            (insert (format wrapper source))
            (should-not (org-texmacs-test--fragment-sources))
            (goto-char (point-min))
            (search-forward (concat "(" (symbol-name (car stree))))
            (should-not (org-texmacs-fragment-at-point))))))))

(ert-deftest org-texmacs-test-fragment-tag-prefixes ()
  (dolist (tag org-texmacs-fragment-tags)
    (ert-info (tag)
      (with-temp-buffer
        (org-mode)
        (insert (format "(%sx \"no\") (%s\"no\") (%s \"no\") (%s) (%s(frac))\n"
                        tag tag (upcase tag) tag tag))
        (should (equal (org-texmacs-test--fragment-sources)
                       (list (format "(%s)" tag) (format "(%s(frac))" tag)))))))
  (with-temp-buffer
    (org-mode)
    (let ((sources (mapcar #'prin1-to-string org-texmacs-test--fragment-strees)))
      (insert (mapconcat #'identity sources " ") "\n")
      (should (equal (org-texmacs-test--fragment-sources) sources))
      (let ((org-texmacs-fragment-tags (reverse org-texmacs-fragment-tags)))
        (should (equal (org-texmacs-test--fragment-sources) sources))))))

(ert-deftest org-texmacs-test-fragment-custom-tags ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\") (custom.tag* (sqrt \"y\")) (customXtag \"no\")\n")
    (let ((org-texmacs-fragment-tags '("custom.tag*" "custom.tag*")))
      (should (equal (org-texmacs-test--fragment-sources)
                     '("(custom.tag* (sqrt \"y\"))"))))
    (let ((org-texmacs-fragment-tags nil))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_) (ert-fail "Disabled scanning must not parse"))))
        (should-not (org-texmacs-test--fragment-sources))
        (should-not (org-texmacs-fragment-at-point (point-min))))))
  (with-temp-buffer
    (org-mode)
    (insert "(equation (math \"x\"))\n")
    (should (equal (org-texmacs-test--fragment-sources) '("(equation (math \"x\"))")))
    (let ((org-texmacs-fragment-tags '("math")))
      (should (equal (org-texmacs-test--fragment-sources) '("(math \"x\")")))))
  (dolist (tag '("A0-_.+*?!:/<>=" "TeXmacs"))
    (with-temp-buffer
      (org-mode)
      (let ((org-texmacs-fragment-tags (list tag))
            (source (format "(%s \"x\")" tag)))
        (insert "A " source " B\n")
        (should (equal (org-texmacs-test--fragment-sources) (list source)))))))

(ert-deftest org-texmacs-test-fragment-invalid-tags ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")")
    (let ((span (org-texmacs-test--first-fragment))
          (cycle (list "math")))
      (setcdr cycle cycle)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_) (ert-fail "Invalid configuration must not parse"))))
        (dolist (value (append (list cycle) '(t "math" ["math"] (math) (nil)
                                             ("math" . "equation") ("") ("1x")
                                             ("math ") ("é") ("math\n") ("(math")
                                             ("math)") ("x\"y") ("x\\y") ("x#")
                                             ("x;") ("x'") ("x`") ("x,") ("x|")
                                             ("x[") ("x{") ("x\t"))))
          (let ((org-texmacs-fragment-tags value))
            (should-error (org-texmacs-fragment-at-point 1) :type 'org-texmacs-error)
            (should-error (org-texmacs-test--fragment-sources) :type 'org-texmacs-error)
            (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))))))

(ert-deftest org-texmacs-test-fragment-tag-snapshots ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\") (math \"y\")")
    (let* ((org-texmacs-fragment-tags (list (copy-sequence "math")))
           (span (org-texmacs-test--first-fragment))
           (snapshot (org-texmacs-fragment-span-tags span)))
      (should (equal snapshot org-texmacs-fragment-tags))
      (should-not (eq snapshot org-texmacs-fragment-tags))
      (should-not (eq (car snapshot) (car org-texmacs-fragment-tags)))
      (should-not (eq (car snapshot) (org-texmacs-fragment-span-tag span)))
      (aset (car org-texmacs-fragment-tags) 0 ?M)
      (should (equal snapshot '("math")))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_) (ert-fail "Changed tags must not parse"))))
        (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)
        (setcar org-texmacs-fragment-tags "equation")
        (should (equal snapshot '("math")))
        (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))
      ;; Equal restored values are accepted; no configuration history tracking.
      (setq org-texmacs-fragment-tags (list (copy-sequence "math")))
      (cl-letf (((symbol-function 'org-texmacs--worker-request) (lambda (_) '(math "x"))))
        (should (equal (org-texmacs--org-to-stree (org-texmacs-fragment-tree span))
                       '(math "x"))))
      (setq org-texmacs-fragment-tags '("math" "equation"))
      (setq span (org-texmacs-test--first-fragment))
      (setq org-texmacs-fragment-tags '("equation" "math"))
      (should-error (org-texmacs--fragment-source span) :type 'org-texmacs-error))))

(ert-deftest org-texmacs-test-fragment-buffer-local-tags ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-texmacs-fragment-tags '("equation*"))
    (insert "(math \"x\") (equation* \"y\")")
    (let ((span (org-texmacs-test--first-fragment)))
      (should (equal (org-texmacs-fragment-span-tag span) "equation*"))
      (with-temp-buffer
        (org-mode)
        (setq-local org-texmacs-fragment-tags '("math"))
        (insert "(math \"x\") (equation* \"y\")")
        (should (equal (org-texmacs-test--fragment-sources) '("(math \"x\")"))))
      (should (equal (org-texmacs-test--fragment-sources) '("(equation* \"y\")")))
      (should (equal (org-texmacs--fragment-source span) "(equation* \"y\")")))))

(ert-deftest org-texmacs-test-fragment-map-checks-tags ()
  (dolist (mutation '(replace list string))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\") (math \"y\")")
      (let ((org-texmacs-fragment-tags (list (copy-sequence "math")))
            (calls 0))
        (should-error
         (org-texmacs-fragment-map
          (point-min) (point-max)
          (lambda (_)
            (cl-incf calls)
            (pcase mutation
              ('replace (setq org-texmacs-fragment-tags nil))
              ('list (setcar org-texmacs-fragment-tags "equation"))
              ('string (aset (car org-texmacs-fragment-tags) 0 ?M)))))
         :type 'org-texmacs-error)
        (should (= calls 1))))))

(ert-deftest org-texmacs-test-fragment-tree-rechecks-tags ()
  (dolist (mutation '(replace list string tag))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\")")
      (let* ((org-texmacs-fragment-tags (list (copy-sequence "math")))
             (span (org-texmacs-test--first-fragment)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_)
                     (pcase mutation
                       ('replace (setq org-texmacs-fragment-tags nil))
                       ('list (setcar org-texmacs-fragment-tags "equation"))
                       ('string (aset (car org-texmacs-fragment-tags) 0 ?M))
                       ('tag (aset (org-texmacs-fragment-span-tag span) 0 ?M)))
                     '(math "x")))
                  ((symbol-function 'org-texmacs--stree-to-org)
                   (lambda (_) (ert-fail "Changed configuration must not reach adapter"))))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))))))

(ert-deftest org-texmacs-test-fragment-mixed-boundaries ()
  (dolist (tag org-texmacs-fragment-tags)
    (let ((source (format "(%s \"x\")" tag)))
      (dolist (marker '("*" "~" "=" "/" "+"))
        (with-temp-buffer
          (org-mode)
          (insert "A " source marker "(math \"y\")" marker " B\n")
          (should (equal (org-texmacs-test--fragment-sources)
                         (list source "(math \"y\")")))))
      (with-temp-buffer
        (org-mode)
        (insert "A " source " B\n")
        (narrow-to-region 3 (+ 3 (length source)))
        (should (equal (org-texmacs-test--fragment-sources) (list source))))
      (dolist (bad (list (format "(%s \"x\"\n\nNext )" tag)
                        (format "(%s ; comment\n \"x\") (math \"hidden\")" tag)))
        (with-temp-buffer
          (org-mode)
          (insert bad "\n\nNext (equation* \"ok\")\n")
          (should (equal (org-texmacs-test--fragment-sources)
                         '("(equation* \"ok\")"))))))))

(ert-deftest org-texmacs-source-location-owned-pure-input ()
  (let* ((file (propertize (copy-sequence "/source/notes.org") 'face 'bold))
         (directory (copy-sequence "/resources/link/../base/"))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil "Text")))
         (input (org-texmacs-input-create ast nil :source-file file
                                          :resource-base directory))
         first)
    (aset file 1 ?X)
    (aset directory 1 ?X)
    (let ((default-directory "/unrelated/"))
      (cl-letf (((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _) (ert-fail "Unexpected buffer read"))))
        ;; Install the sentinel after function rebinding: native compilation's
        ;; trampoline setup may itself consult file handlers.
        (let ((file-name-handler-alist
               '(("." . (lambda (&rest _) (ert-fail "Unexpected file handler"))))))
          (setq first (org-texmacs-document input)))))
    (should (equal (org-texmacs-document-source-file first) "/source/notes.org"))
    (should (equal (org-texmacs-document-resource-base first)
                   "/resources/link/../base/"))
    (should-not (text-properties-at 0 (org-texmacs-input-source-file input)))
    (should-not (eq (org-texmacs-input-resource-base input)
                    (org-texmacs-document-resource-base first)))
    (should-not (eq (org-texmacs-input-source-file input)
                    (org-texmacs-document-source-file first)))
    (aset (org-texmacs-document-resource-base first) 1 ?X)
    (aset (org-texmacs-document-source-file first) 1 ?X)
    (should (equal (org-texmacs-document-source-file (org-texmacs-document input))
                   "/source/notes.org"))
    (should (equal (org-texmacs-document-resource-base (org-texmacs-document input))
                   "/resources/link/../base/"))
    (let ((unspecified (org-texmacs-document (org-texmacs-input-create ast nil))))
      (should-not (org-texmacs-document-source-file unspecified))
      (should-not (org-texmacs-document-resource-base unspecified)))))

(ert-deftest org-texmacs-source-location-rejects-implicit-paths ()
  (let ((ast (org-element-create 'org-data nil)))
    (dolist (path '("" "relative/path" "~/notes.org" "/path\0suffix" t))
      (should-error (org-texmacs-input-create ast nil :source-file path)
                    :type 'org-texmacs-document-error)
      (should-error (org-texmacs-input-create ast nil :resource-base path)
                    :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-test-block-p ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
    (goto-char (point-min))
    (should (org-texmacs--block-p (org-element-at-point))))
  (dolist (node (list nil "text"
                     (org-element-create 'paragraph nil)
                     (org-element-create 'special-block nil)
                     (org-element-create 'special-block '(:type 42))
                     (org-element-create 'special-block '(:type "example"))
                     (org-element-create 'src-block '(:language "texmacs"))))
    (should-not (org-texmacs--block-p node))))

(ert-deftest org-texmacs-test-block-source-exact ()
  (dolist (body '("(frac \"1\" \"2\")\n"
                  "\n\t(with \"mode\" \"math\"\n  (concat \"α *bold* [[link]]\" (sqrt \"x\")))\n\n"
                  ""
                  "\n\n"))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_texmacs\n" body "#+end_texmacs\n")
      (goto-char (point-min))
      (let* ((block (org-element-at-point))
             (before (buffer-string))
             (position (point))
             (tick (buffer-modified-tick)))
        (should (equal (org-texmacs--block-source block) body))
        (should (equal (buffer-string) before))
        (should (= (point) position))
        (should (= (buffer-modified-tick) tick))))))

(ert-deftest org-texmacs-test-block-source-strips-properties ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
    (goto-char (point-min))
    (let* ((block (org-element-at-point))
           (begin (org-element-property :contents-begin block))
           (end (org-element-property :contents-end block)))
      (put-text-property begin end 'org-texmacs-test-property t)
      (let ((source (org-texmacs--block-source block)))
        (should (equal source "(sqrt \"x\")\n"))
        (dotimes (index (length source))
          (should-not (text-properties-at index source)))))))

(ert-deftest org-texmacs-test-block-source-rejects-other-nodes ()
  (dolist (node (list nil
                     (org-element-create 'paragraph nil)
                     (org-element-create 'special-block '(:type "example"))))
    (should-error (org-texmacs--block-source node)
                  :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-block-source-rejects-invalid-bounds ()
  (with-temp-buffer
    (insert "text")
    (dolist (bounds '((nil 3) (2 nil) (3 2) (0 2) (1 100) ("1" 2)))
      (let ((block (org-element-create
                    'special-block
                    (list :type "texmacs"
                          :contents-begin (car bounds)
                          :contents-end (cadr bounds)))))
        (should-error (org-texmacs--block-source block)
                      :type 'org-texmacs-error)))))

(ert-deftest org-texmacs-test-tree-prefix-edit-remains-correct ()
  (let ((org-element-use-cache t)
        (calls 0))
    (with-temp-buffer
      (org-mode)
      (insert "Before\n\n#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (should (equal source "(sqrt \"x\")\n"))
                   (cl-incf calls)
                   '(sqrt "x"))))
        (org-texmacs-tree (org-texmacs-test--first-block))
        (goto-char (point-min))
        (insert "New prefix\n")
        (let ((block (org-texmacs-test--first-block)))
          (should (equal (org-texmacs--org-to-stree (org-texmacs-tree block))
                         '(sqrt "x")))
          ;; Correctness does not depend on retaining the entry across a shift.
          (should (<= 1 calls 2)))))))

(ert-deftest org-texmacs-test-tree-rejects-wrong-block ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_source) (ert-fail "Invalid block must not start parsing"))))
    (dolist (node (list nil (org-element-create 'special-block '(:type "example"))))
      (should-error (org-texmacs-tree node) :type 'org-texmacs-error))))

(ert-deftest org-texmacs-test-tree-rejects-text-changed-during-parse ()
  (let ((org-element-use-cache t))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
      (let ((block (org-texmacs-test--first-block)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_source)
                     ;; Simulate an edit from a timer during process waiting.
                     (goto-char (point-min))
                     (search-forward "\"x\"")
                     (replace-match "\"y\"" t t)
                     '(sqrt "x"))))
          (should-error (org-texmacs-tree block) :type 'org-texmacs-error))
        (should (eq (org-element-cache-get-key (org-texmacs-test--first-block)
                                              'org-texmacs-tree org-texmacs--cache-miss)
                    org-texmacs--cache-miss))))))

;;; source.el ends here
