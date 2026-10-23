;;; special-blocks.el --- core special-blocks regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-issue13-stage4-org-native-api ()
  (should (equal (org-version) "9.8.10"))
  (with-temp-buffer
    (org-mode)
    (insert "* Alpha title\n#+NAME: Named--Object\n| A |\n\n"
            "<<dedicated spot>>\n[[Named--Object]] [[*alpha   title]] [[dedicated   spot]]\n")
    (let* ((ast (org-element-parse-buffer))
           (info (list :parse-tree ast :internal-references nil :crossrefs nil))
           (links (org-element-map ast 'link #'identity))
           (table (org-element-map ast 'table #'identity nil t))
           (headline (org-element-map ast 'headline #'identity nil t))
           (target (org-element-map ast 'target #'identity nil t))
           (a (org-export-get-reference table info))
           (b (org-export-get-reference headline info)))
      (should (eq table (org-export-resolve-fuzzy-link (nth 0 links) info)))
      (should (eq headline (org-export-resolve-fuzzy-link (nth 1 links) info)))
      (should (eq target (org-export-resolve-fuzzy-link (nth 2 links) info)))
      (should (equal a (org-export-get-reference table info)))
      (should-not (equal a b))
      (should (string-match-p "\\`org[0-9a-f]+\\'" a))
      (message "Stage4 Org API origin: %s" (symbol-file 'org-export-get-reference 'defun)))))

(ert-deftest org-texmacs-issue13-stage4-invalid-name-and-bounded-allocation ()
  (dolist (name '("" "   " 42))
    (let* ((block (org-element-create 'special-block (list :type "theorem" :name name)))
           (input (org-texmacs-input-create (org-element-create 'org-data nil block) nil)))
      (should-error (org-texmacs-document input) :type 'org-texmacs-document-error)))
  (let* ((block (org-element-create 'special-block (list :type "theorem" :name "A")))
         (island (org-element-create 'special-block (list :type "texmacs")))
         (ast (org-element-create 'org-data nil block island))
         (calls 0) input)
    (cl-letf (((symbol-function 'org-export-new-reference)
               (lambda (_cache) (cl-incf calls) 1)))
      (setq input (org-texmacs-input-create
                   ast nil :islands (list (cons island '(label "org-texmacs-a-org0000001"))))))
    (should (= calls 64))
    (should-error (org-texmacs-document input) :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-issue13-handler-rejects-invalid-output ()
  (dolist (handler
           (list (lambda (_b _c _i) '(custom "dropped"))
                 (lambda (_b c _i) (list 'custom c c))
                 (lambda (_b c _i) (list 'custom c (cadr c)))
                 (lambda (_b c _i) (list 'custom c (cadr (cadr c))))
                 (lambda (_b c _i) (cons 'custom (cdr c)))
                 (lambda (_b c _i) (setcar c 'changed) (list 'custom c))
                 (lambda (_b c _i) (aset (cadr (cadr c)) 0 ?X) (list 'custom c))
                 (lambda (_b c _i) (setcdr c c) (list 'custom c))
                 (lambda (_b c _i) (list 'custom c 42))
                 (lambda (_b c _i)
                   (let ((cycle (list 'custom c)))
                     (setcdr (cdr cycle) (list cycle)) cycle))))
    (should-error
     (org-texmacs-document (org-texmacs-test--issue13-input handler))
     :type 'org-texmacs-document-error))
  ;; An equal, independently allocated wrapper string is not borrowed content.
  (should (org-texmacs-document
           (org-texmacs-test--issue13-input
            (lambda (_b c _i) (list 'custom (copy-sequence "Text") c))))))

(ert-deftest org-texmacs-issue13-handler-registry-validation ()
  (dolist (registry (list 'invalid '(("" . ignore)) '(("a b" . ignore))
                         '(("A" . ignore) ("a" . ignore))
                         '(("theorem" . ignore)) '(("statement_unknown" . ignore))
                         '(("texmacs" . ignore)) '(("custom" . no-such-handler))))
    (should-error (org-texmacs--document-copy-handlers registry)
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-issue13-deep-island-sharing-and-equal-replacement ()
  (dolist (handler
           (list (lambda (_b c _i) (list 'custom c (cadr (cadr (cadr c)))))
                 (lambda (_b c _i)
                   (setcar (cdr c) (copy-tree (cadr c))) (list 'custom c))))
    (should-error
     (org-texmacs-document
      (org-texmacs-test--issue13-input handler '(math (frac "1" "2"))))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-issue13-pure-interface-and-manual-statements ()
  (dolist (type '("theorem" "statement_theorem" "statement"))
    (let* ((block (org-element-create
                   'special-block (list :type type :parameters
                                        (and (equal type "statement") "theorem"))
                   (org-element-create 'paragraph nil "Manual")))
           (ast (org-element-create 'org-data nil block))
           (input (org-texmacs-input-create ast nil)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Pure lowering requested native work")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _) (ert-fail "Pure lowering read a source buffer")))
                ((symbol-function 'org-texmacs--document-options)
                 (lambda () (ert-fail "Pure lowering captured dynamic options"))))
        (should (equal (org-texmacs-document-body (org-texmacs-document input))
                       '(document (theorem (document (concat "Manual"))))))
        (should (equal (org-element-property :type block) type))))))

(ert-deftest org-texmacs-issue13-handler-snapshot-and-pure-defaults ()
  (cl-letf (((symbol-function 'org-texmacs-test--issue13-handler)
             (lambda (_b c _i) (list 'initial c))))
    (let* ((key (copy-sequence "CUSTOM"))
           (registry (list (cons key 'org-texmacs-test--issue13-handler)))
           (org-texmacs--document-special-block-handlers registry)
           (info (org-texmacs--document-options))
           (ast (org-element-create
                 'org-data nil (org-element-create 'special-block '(:type "custom")
                                                   (org-element-create 'paragraph nil "Text")))))
      (aset key 0 ?X)
      (setcdr (car registry) #'ignore)
      (cl-letf (((symbol-function 'org-texmacs-test--issue13-handler)
                 (lambda (_b c _i) (list 'next c))))
        (let ((input (org-texmacs-input-create ast info)))
          (should (member '(initial (document (concat "Text")))
                          (cdr (org-texmacs-document-body (org-texmacs-document input)))))
          (should-error (org-texmacs-test--lower ast)
                        :type 'org-texmacs-document-error))))))

(ert-deftest org-texmacs-statement-caption-original-concat-indivisible ()
  (let* ((root (list 'concat "Original" (list 'math "x")))
         (contents (org-texmacs--document-create :body (list 'document root '(concat "Next"))
                                                :stm-paths '((0))))
         (prefix (org-texmacs--document-create :body '(concat (label "ID") (dueto "Title"))))
         (result (org-texmacs--document-statement-prefix contents prefix)))
    (should (eq root (nth 3 (cadr (org-texmacs-document-body result)))))
    (should (equal (org-texmacs-document-body contents)
                   '(document (concat "Original" (math "x")) (concat "Next"))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 2))))))

(ert-deftest org-texmacs-statement-caption-anonymous-owned-ast ()
  (let* ((note (org-element-create 'footnote-reference '(:type inline)
                                    "Note " (org-element-create 'bold nil "Body")))
         (statement (org-element-create 'special-block '(:type "theorem")
                                         (org-element-create 'paragraph nil "Body")))
         (ast (org-element-create 'org-data nil statement)))
    (org-element-put-property statement :caption (list (cons (list "Title" note) nil)))
    (let* ((before (let ((print-circle t)) (prin1-to-string ast)))
           (input (org-texmacs-input-create ast nil))
           (document (org-texmacs-document input)))
      (should (equal (org-texmacs-test--caption-inline-footnote-nodes
                       (org-texmacs-document-body document) 'footnote)
                     '((footnote (document (concat "Note " (strong "Body")))))))
      (should (equal document (org-texmacs-document input)))
      (should (equal before (let ((print-circle t)) (prin1-to-string ast)))))
    (org-element-put-property statement :caption (list (cons '("Long") '("Short"))))
    (should-error (org-texmacs-document (org-texmacs-input-create ast nil))
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-issue13-stage2-pure-wrappers-and-provenance ()
  (dolist (type '("equation" "EQUATION*"))
    (dolist (body '("" "x" (frac "1" "2") (document "x")
                   (hlink "file" "relative.pdf")))
      (let* ((block (org-element-create 'special-block (list :type type)))
             (ast (org-element-create 'org-data nil block))
             (input (org-texmacs-input-create ast nil :islands (list (cons block body))))
             (before (copy-tree (org-texmacs-input-islands input)))
             (expected `(document (,(intern (downcase type)) ,body))))
        (cl-letf (((symbol-function 'buffer-substring-no-properties)
                   (lambda (&rest _) (ert-fail "Pure lowering read source")))
                  ((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) (ert-fail "Pure lowering started worker"))))
          (dotimes (_ 2)
            (let ((document (org-texmacs-document input)))
              (should (equal (org-texmacs-document-body document) expected))
              (should (equal (org-texmacs-document-stm-paths document) '((0 0))))
              (should-not (org-texmacs-document-file-paths document)))))
        (should (equal before (org-texmacs-input-islands input)))))))

(ert-deftest org-texmacs-issue13-stage2-pure-errors-and-reserved-names ()
  (dolist (type '("equation" "equation*"))
    (let* ((block (org-element-create 'special-block (list :type type)))
           (ast (org-element-create 'org-data nil block)))
      (should-error (org-texmacs-document (org-texmacs-input-create ast nil))
                    :type 'org-texmacs-document-error)
      (should-error
       (org-texmacs-document
        (org-texmacs-input-create ast nil :islands (list (cons block "x") (cons block "y"))))
       :type 'org-texmacs-document-error)
      (org-element-put-property block :parameters "bad")
      (should-error
       (org-texmacs-document
        (org-texmacs-input-create ast nil :islands (list (cons block "x"))))
       :type 'org-texmacs-document-error))
    (dolist (key (list type (upcase type)))
      (should-error (org-texmacs--document-copy-handlers (list (cons key #'ignore)))
                    :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-issue13-stage3-real-parser-contract ()
  (dolist (type '("figure" "figure*" "TABLE" "TABLE*"))
    (with-temp-buffer
      (org-mode)
      (insert "#+CAPTION[Short]: Long *bold*\n#+begin_" type "\n\n"
              "#+begin_texmacs\n\"body\"\n#+end_texmacs\n\n#+end_" type "\n")
      (let* ((ast (org-element-parse-buffer))
             (wrapper (org-element-map ast 'special-block #'identity nil t))
             (children (org-element-contents wrapper)))
        (should (equal (downcase (org-element-property :type wrapper)) (downcase type)))
        (should-not (org-element-property :parameters wrapper))
        (should (integerp (org-element-property :contents-begin wrapper)))
        (should (< (org-element-property :begin wrapper)
                   (org-element-property :post-affiliated wrapper)))
        ;; Pinned Org represents a leading blank line as a paragraph containing
        ;; exactly a newline; the trailing blank is the inner block's post-blank.
        (should (= (length children) 2))
        (should (eq (org-element-type (car children)) 'paragraph))
        (should (equal (mapcar #'substring-no-properties
                               (org-element-contents (car children))) '("\n")))
        (setq children (cdr children))
        (should (org-texmacs--block-p (car children)))
        (should (eq (org-element-parent (car children)) wrapper))
        (should (equal (cdr (car (org-element-property :caption wrapper))) '("Short")))))))

(ert-deftest org-texmacs-issue13-stage3-native-table-grammar-and-provenance ()
  (let* ((table '(table (row (cell (frac "1" "2")))
                        (row (cell (hlink "Native" "relative.pdf")))))
         (format `(tformat (twith "arbitrary-variable" "arbitrary-value")
                           (cwith "1" "-1" "1" "-1" "cell-halign" "c") ,table)))
    (cl-mapc
     (lambda (raw path)
       (let* ((block (org-element-create 'special-block '(:type "texmacs")))
              (wrapper (org-element-create 'special-block '(:type "table") block))
              (ast (org-element-create 'org-data nil wrapper))
              (input (org-texmacs-input-create ast nil :islands (list (cons block raw))))
              (document (org-texmacs-document input)))
         (should (equal (org-texmacs-document-stm-paths document) (list path)))
         (let ((root (org-texmacs-document-body document)))
           (dolist (index path) (setq root (nth (1+ index) root)))
           (should (equal root raw)))
         (should-not (org-texmacs-document-file-paths document))
         (should (equal document (org-texmacs-document input)))))
     (list table format `(tabular ,format)) '((0 0 0 0) (0 0 0) (0 0))))
  (dolist (raw '("not-table" (table) (table (row)) (table (row (cell)))
                 (table (row (cell "a" "b"))) (table (cell "a"))
                 (table (row (cell "a")) (row (cell "a") (cell "b")))
                 (tformat) (tformat (table (row (cell "a"))) (twith "x" "y"))
                 (tformat (twith "x") (table (row (cell "a"))))
                 (tformat (cwith "1" "2") (table (row (cell "a"))))
                 (tabular (table (row (cell "a"))))
                 (tabular (tformat (table (row (cell "a")))) "extra")
                 (tformat (unknown "x") (table (row (cell "a"))))))
    (should-error (org-texmacs--document-normalize-table
                   (org-texmacs--document-create :body raw :stm-paths '(nil)))
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-issue13-stage3-org-footnote-boundary-limit ()
  (with-temp-buffer
    (org-mode)
    (insert "Text[fn:n].\n\n[fn:n]\n#+begin_figure\n#+begin_texmacs\n"
            "(concat \"\n#+INCLUDE: missing.org\n#+BIBLIOGRAPHY: missing.bib\n[fn:missing]\n\")\n"
            "#+end_texmacs\n#+end_figure\n")
    ;; Org's footnote parser terminates n at the next column-zero definition,
    ;; even inside a would-be raw block.  Never reconstruct lost Org elements.
    (should-not (org-texmacs--native-body-blocks (org-element-parse-buffer)))
    (should-not (org-element-map (org-element-parse-buffer) 'special-block
                  #'org-texmacs--figure-table-kind))))

;;; special-blocks.el ends here
