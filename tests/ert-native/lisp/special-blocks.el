;;; special-blocks.el --- native special-blocks regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-issue13-stage4-names-and-frozen-ownership ()
  (dolist (kind
           (append
            '("equation"
              "equation*"
              "texmacs"
              "figure"
              "figure*"
              "table"
              "table*")
            (cl-mapcan
             (lambda (tag)
               (let ((name (symbol-name tag)))
                 (append
                  (list
                   (concat "statement " name)
                   (concat "statement_" name))
                  (unless (eq tag 'example)
                    (list name)))))
             org-texmacs--document-statement-tags)))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
       "[[Object--A]] [[Object--A][Describe]].\n"
       (org-texmacs-test--stage4-block kind "Object--A"))
      (let ((source (buffer-string))
            input)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (raw &rest _) (read raw))))
          (setq input (org-texmacs-prepare-buffer (current-buffer))))
        (should (equal source (buffer-string)))
        (let* ((resolution (org-texmacs-input-resolution input))
               (id (cdar (org-texmacs-resolution-labels resolution)))
               (document (org-texmacs-document input))
               (body (org-texmacs-document-body document)))
          (should
           (string-match-p
            "\\`org-texmacs-object__a-org[0-9a-f]+\\'" id))
          (should
           (= 1
              (cl-count
               id
               (org-texmacs--document-output-labels body)
               :test #'equal)))
          (should
           (equal
            (mapcar
             #'cdr (org-texmacs-resolution-links resolution))
            (list id id)))
          (should
           (string-match-p
            (regexp-quote (concat "#" id)) (prin1-to-string body)))
          (cl-letf (((symbol-function 'org-export-get-reference)
                     (lambda (&rest _) (ert-fail "Lower allocated")))
                    ((symbol-function 'org-export-resolve-fuzzy-link)
                     (lambda (&rest _) (ert-fail "Lower resolved")))
                    ((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _) (ert-fail "Lower parsed")))
                    ((symbol-function 'buffer-substring-no-properties)
                     (lambda (&rest _)
                       (ert-fail "Lower read source"))))
            (should (equal document (org-texmacs-document input))))
          (should
           (= (length (org-texmacs-document-stm-paths document))
              (if (or (member
                       kind '("equation" "equation*" "texmacs"))
                      (string-prefix-p "figure" kind))
                  1
                0))))))))

(ert-deftest
    org-texmacs-issue13-stage4-unused-duplicates-and-ambiguity
    ()
  (dolist (link '("" "[[Same]]" "[[Same][Describe]]"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil\n"
       link
       "\n"
       (org-texmacs-test--stage4-block "theorem" "Same")
       (org-texmacs-test--stage4-block "lemma" "Same"))
      (if (equal link "")
          (let ((ids
                 (org-texmacs--document-output-labels
                  (org-texmacs-document-body
                   (org-texmacs-document-from-buffer
                    (current-buffer))))))
            (should (= 2 (length ids)))
            (should-not (equal (car ids) (cadr ids))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error))))
  (with-temp-buffer
    (org-mode)
    (insert
     (org-texmacs-test--stage4-block "theorem" "Spot")
     "<<Spot>> [[Spot]]\n")
    (should-error
     (org-texmacs-document-from-buffer (current-buffer))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-issue13-stage4-slug-and-allocation-collision
    ()
  (dolist (case-fold-search '(nil t))
    (dolist (pair
             '(("Thm--Main" . "thm__main")
               ("A+B=C" . "a_b_c")
               ("_X_" . "_x_")
               ("张量范畴" . "____")
               ("Kİ１２" . "____")))
      (should
       (equal (org-texmacs--reference-slug (car pair)) (cdr pair)))))
  (let* ((block
          (org-element-create
           'special-block (list :type "theorem" :name "A")))
         (island
          (org-element-create 'special-block (list :type "texmacs")))
         (ast (org-element-create 'org-data nil block island))
         (calls 0)
         input)
    (cl-letf (((symbol-function 'org-export-new-reference)
               (lambda (_cache) (cl-incf calls))))
      (setq input
            (org-texmacs-input-create
             ast nil
             :islands
             (list
              (cons island '(label "org-texmacs-a-org0000001"))))))
    (should (= calls 2))
    (should
     (equal
      (cdar
       (org-texmacs-resolution-labels
        (org-texmacs-input-resolution input)))
      "org-texmacs-a-org0000002"))
    (should (org-texmacs-document input)))
  ;; A custom handler can introduce a conflicting static label only at final lower.
  (with-temp-buffer
    (org-mode)
    (insert
     (org-texmacs-test--stage4-block "theorem" "A")
     "#+begin_custom\nText\n#+end_custom\n")
    (let (id)
      (let* ((org-texmacs--document-special-block-handlers
              (list
               (cons
                "custom"
                (lambda
                  (_node body _info)
                  (list 'custom (list 'label id) body)))))
             (input (org-texmacs-prepare-buffer (current-buffer))))
        (setq id
              (cdar
               (org-texmacs-resolution-labels
                (org-texmacs-input-resolution input))))
        (should-error
         (org-texmacs-document input)
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-issue13-stage4-scope-opacity-and-name-evidence
    ()
  (dolist (kind '("theorem" "equation" "texmacs" "figure" "table"))
    (with-temp-buffer
      (org-mode)
      (insert
       "* Kept\n"
       (org-texmacs-test--stage4-block kind "Kept")
       "[[Kept][Self]]\n* Hidden :noexport:\n#+NAME: X\n"
       (org-texmacs-test--stage4-block kind "Bad"))
      (goto-char (point-min))
      (let ((end
             (save-excursion
               (outline-next-heading)
               (point))))
        (dolist (scope '(full subtree region narrow))
          (save-restriction
            (when (eq scope 'narrow)
              (narrow-to-region 1 end))
            (cl-letf (((symbol-function 'org-texmacs--worker-request)
                       (lambda (raw &rest _) (read raw))))
              (should
               (org-texmacs-document-from-buffer
                (current-buffer)
                nil
                (and (eq scope 'subtree) 1)
                (and (eq scope 'region) (cons 1 end)))))))))
    (dolist (prefix
             '("#+NAME: First\n" "#+ATTR_TEXMACS: unsupported\n"))
      (with-temp-buffer
        (org-mode)
        (insert prefix (org-texmacs-test--stage4-block kind "Second"))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Invalid NAME requested STM"))))
          (should-error
           (org-texmacs-document-from-buffer (current-buffer))
           :type 'org-texmacs-document-error))))
    (with-temp-buffer
      (org-mode)
      (insert (org-texmacs-test--stage4-block kind "Cut"))
      (goto-char (point-min))
      (forward-line 1)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Truncated NAME requested STM"))))
        (should-error
         (org-texmacs-document-from-buffer
          (current-buffer) nil nil (cons (point) (point-max)))
         :type 'org-texmacs-document-error))))
  (with-temp-buffer
    (org-mode)
    (insert
     "#+NAME: Raw\n#+begin_texmacs\n(document \"<<Fake>>\")\n#+end_texmacs\n[[Fake]]\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Fake target escaped opacity"))))
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error)))
  (with-temp-buffer
    (org-mode)
    (insert
     (org-texmacs-test--stage4-block "theorem" "Spot")
     "[[Spot]]\n\n[fn:unused] <<Spot>>\n")
    (should (org-texmacs-document-from-buffer (current-buffer)))))

(ert-deftest
    org-texmacs-issue13-stage4-synthetic-identity-and-nested-provenance
    ()
  (let* ((name (copy-sequence "Same"))
         (a
          (org-element-create
           'special-block (list :type "theorem" :name name)))
         (b
          (org-element-create
           'special-block (list :type "theorem" :name "Same")))
         (link
          (org-element-create
           'link (list :type "fuzzy" :path "Same")))
         (ast
          (org-element-create
           'org-data
           nil
           a
           b
           (org-element-create 'paragraph nil link)))
         (input (org-texmacs-input-create ast nil)))
    ;; Structurally equal, distinct targets must remain ambiguous.
    (should-error
     (org-texmacs-document input)
     :type 'org-texmacs-document-error)
    (org-element-set-contents
     ast a
     (org-element-create 'paragraph nil link))
    (setq input (org-texmacs-input-create ast nil))
    (should-not
     (eq
      a
      (caar
       (org-texmacs-resolution-labels
        (org-texmacs-input-resolution input)))))
    (aset name 0 ?X)
    (should (org-texmacs-document input)))
  (with-temp-buffer
    (org-mode)
    (insert
     "#+NAME: Outer\n#+begin_theorem\nSee [[Inner]].\n\n"
     "#+NAME: Inner\n#+begin_lemma\n[[file:note.pdf][File]] (math \"x\")\n"
     "#+end_lemma\n#+end_theorem\n[[Outer][Back]]\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (raw &rest _) (read raw))))
      (let* ((document
              (org-texmacs-document-from-buffer (current-buffer)))
             (root (org-texmacs-document-body document)))
        (should
         (= 2 (length (org-texmacs--document-output-labels root))))
        (should
         (= 1 (length (org-texmacs-document-file-paths document))))
        (dolist (path (org-texmacs-document-stm-paths document))
          (let ((node root))
            (dolist (index path)
              (setq node (nth (1+ index) node)))
            (should (equal node '(math "x")))))))))

(ert-deftest
    org-texmacs-issue13-stage4-excluded-truncated-native-owner
    ()
  (dolist (kind '("equation" "equation*" "texmacs"))
    (with-temp-buffer
      (org-mode)
      (insert
       "* Kept\nVisible.\n* Hidden :noexport:\n#+NAME: First\n"
       (org-texmacs-test--stage4-block kind "Duplicate"))
      (goto-char (point-min))
      (search-forward "frac")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Excluded native owner requested body"))))
        (let ((document
               (org-texmacs-document-from-buffer
                (current-buffer) nil nil (cons 1 (point)))))
          (should-not
           (string-match-p
            "Duplicate\\|Hidden" (prin1-to-string document))))))))

(ert-deftest
    org-texmacs-issue13-stage4-allocation-after-filter-and-body
    ()
  (dolist (filtered '(nil t))
    (with-temp-buffer
      (org-mode)
      (insert
       (org-texmacs-test--stage4-block "equation" "A")
       "[[A]] [[A][Again]]\n")
      (let* ((org-export-filter-parse-tree-functions
              (and filtered (list (lambda (&rest _) nil))))
             (allocate (symbol-function 'org-export-get-reference))
             parsed
             (calls 0)
             input)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (raw &rest _)
                     (setq parsed t)
                     (read raw)))
                  ((symbol-function 'org-export-get-reference)
                   (lambda (&rest args)
                     (should parsed)
                     (cl-incf calls)
                     (apply allocate args))))
          (setq input (org-texmacs-prepare-buffer (current-buffer))))
        (should (= 1 calls))
        (should
         (equal
          (org-texmacs-document input)
          (org-texmacs-document input)))))))

(ert-deftest
    org-texmacs-issue13-stage4-original-name-matching-and-slug-collisions
    ()
  (dolist (name '("eq:main" "Thm--Main" "A+B=C" "张量范畴" "_X_" "a b"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil\n"
       (org-texmacs-test--stage4-block "theorem" name)
       "[["
       name
       "][Describe]]\n")
      (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
             (mapping (org-texmacs-input-resolution input))
             (id (cdar (org-texmacs-resolution-labels mapping))))
        (should
         (string-prefix-p
          (concat
           "org-texmacs-" (org-texmacs--reference-slug name) "-org")
          id))
        (should
         (equal
          (mapcar
           #'cdr (org-texmacs-resolution-links mapping))
          (list id)))
        (should (org-texmacs-document input)))))
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n* A+B\n"
     (org-texmacs-test--stage4-block "theorem" "A+B")
     (org-texmacs-test--stage4-block "lemma" "A-B")
     "[[A+B]] [[A-B]]\n")
    (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
           (mapping (org-texmacs-input-resolution input))
           (ids
            (mapcar #'cdr (org-texmacs-resolution-labels mapping))))
      (should (= 2 (length ids)))
      (should-not (equal (car ids) (cadr ids)))
      (dolist (id ids)
        (should (string-prefix-p "org-texmacs-a_b-org" id)))
      (should
       (equal
        ids (mapcar #'cdr (org-texmacs-resolution-links mapping)))))))

(ert-deftest org-texmacs-issue13-stage4-rejects-custom-handler-name ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+NAME: Custom\n#+begin_custom\n(math \"x\")\n#+end_custom\n")
    (let ((org-texmacs--document-special-block-handlers
           (list
            (cons
             "custom"
             (lambda
               (&rest _)
               (ert-fail "Named custom handler ran"))))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Named custom block requested STM"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-issue13-handler-provenance-and-ownership ()
  (let* ((input
          (org-texmacs-test--issue13-input
           (lambda (_block body _info)
             (list 'custom "title" body))
           '(math "<alpha>")))
         (document (org-texmacs-document input)))
    (should
     (equal
      (org-texmacs-document-body document)
      '(document (custom "title" (document (math "<alpha>"))))))
    (should
     (equal (org-texmacs-document-stm-paths document) '((0 1 0))))
    (should (equal (org-texmacs-document input) document)))
  (with-temp-buffer
    (org-mode)
    (insert
     "#+begin_custom\n[[file:relative.pdf][File]]\n#+end_custom\n")
    (let* ((org-texmacs--document-special-block-handlers
            (list
             (cons
              "custom"
              (lambda (_block body _info) (list 'custom body)))))
           (document
            (org-texmacs-document-from-buffer (current-buffer))))
      (should
       (equal
        (org-texmacs-document-file-paths document) '((0 0 0 0 1)))))))

(ert-deftest org-texmacs-issue13-rejects-file-leaf-sharing ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+begin_custom\n[[file:relative.pdf][File]]\n#+end_custom\n")
    (let ((org-texmacs--document-special-block-handlers
           (list
            (cons
             "custom"
             (lambda
               (_b c _i)
               (list 'custom c (nth 2 (cadr (cadr c)))))))))
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-issue13-source-handler-snapshot-through-filter-and-wait
    ()
  (dolist (filtered '(nil t))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_custom\n(math \"x\")\n#+end_custom\n")
      (let* ((org-export-filter-parse-tree-functions
              (and filtered (list (lambda (&rest _) nil))))
             (registry
              (list
               (cons "custom" (lambda (_b c _i) (list 'initial c)))))
             (org-texmacs--document-special-block-handlers registry))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (setcdr
                      (car registry)
                      (lambda (_b c _i) (list 'next c)))
                     '(math "x"))))
          (should
           (eq
            (car
             (cadr
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))))
            'initial)))))))

(ert-deftest org-texmacs-issue13-prepared-input-without-stm ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_custom\nOnly prose.\n#+end_custom\n")
    (let ((calls 0)
          (org-texmacs--document-special-block-handlers nil))
      (setq org-texmacs--document-special-block-handlers
            (list
             (cons
              "custom"
              (lambda (_b c _i)
                (setq calls (1+ calls))
                (list 'custom c)))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Prose-only block started a worker"))))
        (let ((input (org-texmacs-prepare-buffer (current-buffer))))
          (should (= calls 0))
          (should-not
           (plist-member
            (org-texmacs-input-info input)
            :texmacs-special-block-preflight))
          (should
           (equal
            (org-texmacs-document-body (org-texmacs-document input))
            '(document (custom (document (concat "Only prose. "))))))
          (should (= calls 1)))))))

(ert-deftest
    org-texmacs-issue13-native-final-handler-error-and-recovery
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+begin_custom\n#+begin_texmacs\n(math \"α\")\n#+end_texmacs\n#+end_custom\n")
     (let ((org-texmacs--document-special-block-handlers
            (list
             (cons
              "custom"
              (lambda (_b c _i)
                (should (equal (cadr c) '(math "α")))
                (list 'custom c (cadr c)))))))
       (should-error
        (org-texmacs-document-from-buffer (current-buffer))
        :type 'org-texmacs-document-error)
       (should (org-texmacs--worker-live-p))
       (let ((process org-texmacs--worker-process))
         (setq org-texmacs--document-special-block-handlers
               (list
                (cons "custom" (lambda (_b c _i) (list 'custom c)))))
         (should
          (equal
           (org-texmacs-document-stm-paths
            (org-texmacs-document-from-buffer (current-buffer)))
           '((0 0 0))))
         (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-issue13-scoped-islands-and-footnotes ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Kept\n#+begin_theorem\nFirst (math \"one\")[fn:n].\n\n"
     "#+begin_texmacs\n(math \"two\")\n#+end_texmacs\n#+end_theorem\n"
     "* Omitted\n#+begin_theorem\n(math \"omitted\")\n#+end_theorem\n"
     "[fn:n] #+begin_statement remark\nNote (math \"note\").\n#+end_statement\n")
    ;; A separate note may contain an ordinary recursive block, but the block
    ;; marker must start its own line rather than follow [fn:n] as text.
    (goto-char (point-min))
    (search-forward "[fn:n] #+")
    (replace-match "[fn:n]\n#+" t t)
    (dolist (scope '(subtree region narrow))
      (save-restriction
        (goto-char (point-min))
        (let ((start (point))
              (end
               (save-excursion
                 (outline-next-heading)
                 (point)))
              requests)
          (when (eq scope 'narrow)
            (narrow-to-region start end))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (source &rest _)
                       (push source requests)
                       (read source))))
            (let ((document
                   (org-texmacs-document-from-buffer
                    (current-buffer)
                    nil
                    (and (eq scope 'subtree) start)
                    (and (eq scope 'region) (cons start end)))))
              (should document)
              (should
               (= (length (org-texmacs-document-stm-paths document))
                  3))
              (should (= (length requests) 3))
              (should-not
               (cl-some
                (lambda (request)
                  (string-match-p "omitted" request))
                requests)))))))))

(ert-deftest org-texmacs-issue13-source-change-during-wait ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_theorem\n(math \"x\")\n#+end_theorem\n")
    (let ((source (current-buffer)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (with-current-buffer source
                     (goto-char (point-max))
                     (insert "changed"))
                   '(math "x"))))
        (should-error
         (org-texmacs-document-from-buffer source)
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-statement-caption-tags-syntax-and-frozen-links
    ()
  (dolist (tag org-texmacs--document-statement-tags)
    (dolist (syntax
             (append
              (list
               (concat "statement " (symbol-name tag))
               (concat "statement_" (symbol-name tag)))
              (unless (eq tag 'example)
                (list (upcase (symbol-name tag))))))
      (with-temp-buffer
        (org-mode)
        (insert
         "#+NAME: Object\n#+CAPTION: Title *bold* [[Object]] [[Object][Self]]\n"
         "#+CAPTION: More [[file:caption.pdf][File]] (math \"literal\")\n"
         "#+begin_"
         syntax
         "\nBody.\n#+end_"
         (car (split-string syntax))
         "\n")
        (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
               (document (org-texmacs-document input))
               (body (org-texmacs-document-body document))
               (statement
                (car
                 (org-texmacs-test--caption-inline-footnote-nodes
                  body tag)))
               (first (cadadr statement))
               (id
                (cdar
                 (org-texmacs-resolution-labels
                  (org-texmacs-input-resolution input)))))
          (should (eq (car first) 'surround))
          (should (equal (cadr (cadr first)) (list 'label id)))
          (should
           (= 1
              (length
               (org-texmacs-test--caption-inline-footnote-nodes
                body 'dueto))))
          (should
           (member
            (list 'reference id)
            (org-texmacs-test--caption-inline-footnote-nodes
             body 'reference)))
          (should
           (member
            (list 'hlink "Self" (concat "#" id))
            (org-texmacs-test--caption-inline-footnote-nodes
             body 'hlink)))
          (should-not
           (org-texmacs-test--caption-inline-footnote-nodes
            body 'math))
          (should (org-texmacs-document-file-paths document))
          (cl-letf (((symbol-function 'org-export-get-reference)
                     (lambda (&rest _) (ert-fail "Reallocated")))
                    ((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _) (ert-fail "Pure worker")))
                    ((symbol-function 'buffer-substring-no-properties)
                     (lambda (&rest _)
                       (ert-fail "Pure source read"))))
            (should
             (equal document (org-texmacs-document input)))))))))

(ert-deftest
    org-texmacs-statement-caption-source-rejections-before-worker
    ()
  (dolist (metadata
           '("#+CAPTION[Short]: Long\n"
             "#+CAPTION[]: Long\n"
             "#+CAPTION: \n"
             "#+CAPTION: \t\n"
             "#+CAPTION[[[Missing]]]: Long\n"
             "#+CAPTION: Good\n#+CAPTION[]: Other\n"
             "#+NAME: A\n#+NAME: B\n#+CAPTION: Long\n"
             "#+ATTR_TEXMACS: x\n#+CAPTION: Long\n"))
    (with-temp-buffer
      (org-mode)
      (insert
       metadata
       "#+begin_theorem\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n#+end_theorem\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Invalid statement submitted body request"))))
        (let ((err
               (should-error
                (org-texmacs-document-from-buffer (current-buffer))
                :type 'org-texmacs-document-error)))
          (when (string-match-p "CAPTION\\[" metadata)
            (should
             (string-match-p
              "short caption" (error-message-string err)))))))))

(ert-deftest org-texmacs-statement-caption-shapes-and-provenance ()
  (dolist
      (native
       '("(concat \"Original\" (math \"x\") (image \"body.png\" \"\" \"\" \"\" \"\"))"
         "(with \"color\" \"red\" \"Original\")"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+NAME: A\n#+CAPTION: [[file:caption.pdf][File]]\n#+begin_theorem\n"
       "#+begin_texmacs\n"
       native
       "\n#+end_texmacs\n\nSecond paragraph.\n#+end_theorem\n")
      (let (input)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (raw &rest _) (read raw))))
          (setq input (org-texmacs-prepare-buffer (current-buffer))))
        (let* ((before
                (let ((print-circle t))
                  (prin1-to-string input)))
               (document (org-texmacs-document input))
               (body (org-texmacs-document-body document))
               (path (car (org-texmacs-document-stm-paths document)))
               (node body))
          (dolist (index path)
            (setq node (nth (1+ index) node)))
          (should (equal node (read native)))
          (should
           (equal
            path
            (if (string-prefix-p "(concat" native)
                '(0 0 0 2)
              '(0 0 1))))
          (should
           (equal
            before
            (let ((print-circle t))
              (prin1-to-string input))))
          (should (equal document (org-texmacs-document input)))
          (dolist (file-path
                   (org-texmacs-document-file-paths document))
            (let ((leaf body))
              (dolist (index file-path)
                (setq leaf (nth (1+ index) leaf)))
              (should (equal leaf "caption.pdf"))))))))
  (dolist (body '("" "#+begin_quote\nQuote\n#+end_quote\n" "Plain\n"))
    (dolist (metadata
             '(""
               "#+NAME: A\n"
               "#+CAPTION: Title\n"
               "#+NAME: A\n#+CAPTION: Title\n"))
      (with-temp-buffer
        (org-mode)
        (insert metadata "#+begin_theorem\n" body "#+end_theorem\n")
        (let* ((document
                (org-texmacs-document-from-buffer (current-buffer)))
               (tree (org-texmacs-document-body document)))
          (should
           (= (length
               (org-texmacs-test--caption-inline-footnote-nodes
                tree 'dueto))
              (if (string-match-p "CAPTION" metadata)
                  1
                0)))
          (should
           (= (length (org-texmacs--document-output-labels tree))
              (if (string-match-p "NAME" metadata)
                  1
                0))))))))

(ert-deftest
    org-texmacs-statement-caption-selection-and-region-integrity
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Bad :noexport:\n#+CAPTION[]: Bad\n#+begin_theorem\nBad\n#+end_theorem\n"
     "* Good\n#+CAPTION: Good\n#+begin_theorem\nBody\n#+end_theorem\n")
    (should (org-texmacs-document-from-buffer (current-buffer)))
    (goto-char (point-min))
    (search-forward "* Good")
    (beginning-of-line)
    (let ((subtree (point)))
      (should
       (org-texmacs-document-from-buffer
        (current-buffer) nil subtree)))
    (search-forward "#+CAPTION: Good")
    (beginning-of-line)
    (let ((begin (point))
          (end (point-max)))
      (should
       (org-texmacs-document-from-buffer
        (current-buffer) nil nil (cons begin end)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Truncated request"))))
        (should-error
         (org-texmacs-document-from-buffer
          (current-buffer) nil nil (cons (1+ begin) end))
         :type 'org-texmacs-document-error)
        (should-error
         (org-texmacs-document-from-buffer
          (current-buffer) nil nil (cons begin (- end 5)))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-statement-caption-errors-and-worker-boundary
    ()
  (dolist (caption '("[[Missing]]" "[cite:@missing]" "<<Target>>"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+BIBLIOGRAPHY: refs.bib\n#+CAPTION: "
       caption
       "\n"
       "#+begin_theorem\n#+begin_texmacs\n(math \"body\")\n#+end_texmacs\n#+end_theorem\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_raw &optional operation)
                   (unless (eq operation 'bibliography)
                     (ert-fail "Caption error submitted body STM"))
                   '(document))))
        (should-error
         (org-texmacs-document-from-buffer
          (current-buffer) '(("refs.bib" . "")))
         :type 'org-texmacs-document-error))))
  (with-temp-buffer
    (org-mode)
    (insert "#+CAPTION: Title\n#+begin_custom\nBody\n#+end_custom\n")
    (let ((org-texmacs--document-special-block-handlers
           (list
            (cons
             "custom"
             (lambda
               (&rest _)
               (ert-fail "Invalid metadata reached handler"))))))
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-statement-caption-stock-parser-and-forward-links
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+CAPTION: Title[fn::literal] [[Later][Forward]]\n#+begin_theorem\nBody\n#+end_theorem\n"
     "#+NAME: Later\n#+begin_lemma\nDestination\n#+end_lemma\n")
    (let* ((document
            (org-texmacs-document-from-buffer (current-buffer)))
           (body (org-texmacs-document-body document))
           (labels (org-texmacs--document-output-labels body)))
      (should-not
       (org-texmacs-test--caption-inline-footnote-nodes
        body 'footnote))
      (should
       (string-match-p
        (regexp-quote "[fn::literal]") (prin1-to-string body)))
      (should
       (member
        (list 'hlink "Forward" (concat "#" (car labels)))
        (org-texmacs-test--caption-inline-footnote-nodes
         body 'hlink))))))

(ert-deftest org-texmacs-issue13-source-syntax-and-recursion ()
  (dolist (syntax
           '("statement theorem"
             "statement_theorem"
             "theorem"
             "STATEMENT THEOREM"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_"
       syntax
       "\nFirst *bold*.\n\n"
       "#+begin_quote\nQuote.\n#+end_quote\n\n"
       "- Item\n\n| A | B |\n\n"
       "#+begin_example\nLiteral\n#+end_example\n\n"
       "#+begin_center\nCenter.\n#+end_center\n\nLast.\n#+end_"
       (car (split-string syntax))
       "\n")
      (let* ((state
              (org-texmacs-test--document-buffer-state
               (current-buffer)))
             (document
              (org-texmacs-document-from-buffer (current-buffer)))
             (statement (cadr (org-texmacs-document-body document))))
        (should (eq (car statement) 'theorem))
        (should (eq (caadr statement) 'document))
        (should (= (length (cdadr statement)) 7))
        (should
         (equal
          state
          (org-texmacs-test--document-buffer-state
           (current-buffer)))))))
  (dolist (syntax '("statement example" "statement_example"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_"
       syntax
       "\nExample.\n#+end_"
       (car (split-string syntax))
       "\n")
      (should
       (eq
        (car
         (cadr
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))))
        'example)))))

(ert-deftest org-texmacs-issue13-source-errors-before-body-worker ()
  (dolist (syntax
           '("statement"
             "statement unknown"
             "statement theorem extra"
             "statement_unknown"
             "statement_theorem extra"
             "theorem extra"
             "unknown"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_"
       syntax
       "\n(math \"x\")\n#+end_"
       (car (split-string syntax))
       "\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Invalid block submitted native request"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error))))
  (dolist (metadata
           '("#+CAPTION[short]: caption\n" "#+ATTR_TEXMACS: x\n"))
    (with-temp-buffer
      (org-mode)
      (insert metadata "#+begin_theorem\nBody.\n#+end_theorem\n")
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-issue13-preflight-bibliography-boundary ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+BIBLIOGRAPHY: refs.bib\n#+begin_unknown\n(math \"body\")\n#+end_unknown\n")
    (let (requests)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_source &optional operation)
                   (push operation requests)
                   (unless (eq operation 'bibliography)
                     (ert-fail "Body request escaped preflight"))
                   '(document))))
        (should-error
         (org-texmacs-document-from-buffer
          (current-buffer) '(("refs.bib" . "")))
         :type 'org-texmacs-document-error)
        (should (equal requests '(bibliography)))))))

(ert-deftest
    org-texmacs-issue13-preflight-skips-handler-and-final-errors
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+begin_custom\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n#+end_custom\n")
    (let ((calls 0)
          (parsed nil)
          (org-texmacs--document-special-block-handlers nil))
      (setq org-texmacs--document-special-block-handlers
            (list
             (cons
              "custom"
              (lambda (_b c info)
                (should parsed)
                (should-not
                 (plist-get info :texmacs-special-block-preflight))
                (setq calls (1+ calls))
                (list 'custom c)))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (setq parsed t)
                   '(math "x"))))
        (should (org-texmacs-document-from-buffer (current-buffer)))
        (should (= calls 1))))))

(ert-deftest org-texmacs-issue13-stage2-source-capture-and-nesting ()
  (dolist (type '("equation" "EQUATION*"))
    (dolist (wrapper '(nil "statement theorem" "quote" "center"))
      (with-temp-buffer
        (org-mode)
        (insert "#+OPTIONS: toc:nil title:nil author:nil date:nil\n")
        (when wrapper
          (insert "#+begin_" wrapper "\n"))
        (insert
         "#+begin_"
         type
         "\n  (concat \"α=\" (frac \"1\" \"2\"))  \n#+end_"
         type
         "\n")
        (when wrapper
          (insert "#+end_" (car (split-string wrapper)) "\n"))
        (let ((source (buffer-string))
              requests)
          (should
           (= (length
               (org-texmacs--native-body-blocks
                (org-element-parse-buffer)))
              1))
          (should-not
           (org-texmacs--fragment-collect org-texmacs-fragment-tags))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (raw &rest _)
                       (push raw requests)
                       '(concat "α=" (frac "1" "2")))))
            (let ((document
                   (org-texmacs-document-from-buffer
                    (current-buffer))))
              (should
               (= (length (org-texmacs-document-stm-paths document))
                  1))))
          (should
           (equal
            requests '("  (concat \"α=\" (frac \"1\" \"2\"))  \n")))
          (should (equal source (buffer-string))))))))

(ert-deftest org-texmacs-issue13-stage2-preflight-source-errors ()
  (dolist (type '("equation" "equation*"))
    (dolist
        (fixture
         '("#+begin_%s bad\n\"x\"\n#+end_%s\n"
           "#+begin_%s\n \t\n#+end_%s\n"
           "#+NAME: first\n#+NAME: named\n#+begin_%s\n\"x\"\n#+end_%s\n"
           "#+CAPTION: caption\n#+begin_%s\n\"x\"\n#+end_%s\n"
           "#+ATTR_TEXMACS: bad\n#+begin_%s\n\"x\"\n#+end_%s\n"))
      (with-temp-buffer
        (org-mode)
        (insert (format fixture type type))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Invalid equation reached worker"))))
          (should-error
           (org-texmacs-document-from-buffer (current-buffer))
           :type 'org-texmacs-document-error)))))
  (with-temp-buffer
    (org-mode)
    (insert
     "#+BIBLIOGRAPHY: refs.bib\n#+NAME: first\n#+NAME: named\n#+begin_equation\n\"x\"\n#+end_equation\n")
    (let (requests)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_raw &optional operation)
                   (push operation requests)
                   (should (eq operation 'bibliography))
                   '(document))))
        (should-error
         (org-texmacs-document-from-buffer
          (current-buffer) '(("refs.bib" . "")))
         :type 'org-texmacs-document-error)
        (should (equal requests '(bibliography)))))))

(ert-deftest
    org-texmacs-issue13-stage2-opaque-preprocessing-and-dependencies
    ()
  (dolist (type '("equation" "equation*"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
       "Before (math \"before\").\n\n#+begin_"
       type
       "\n"
       "(concat \"raw\"\n; raw STM comment\n"
       "; (math \"inside\")\n"
       "\"\n#+INCLUDE: \"missing-file.org\"\n"
       "#+BIBLIOGRAPHY: missing.bib\n#+TITLE: Hidden\n"
       "[cite:@hidden] [fn:missing]\n[fn:hidden] Ghost\n\")\n"
       "#+end_"
       type
       "\n\nAfter (math \"after\").\n")
      (let (requests)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (raw &optional operation)
                     (should-not operation)
                     (push raw requests)
                     (if (string-prefix-p "(math" raw)
                         (read raw)
                       "opaque"))))
          (dolist (convert
                   '(org-texmacs-document-from-buffer
                     org-texmacs-document-from-buffer-preprocessed))
            (setq requests nil)
            (let ((document (funcall convert (current-buffer))))
              (should
               (= (length (org-texmacs-document-stm-paths document))
                  3))
              (should (= (length requests) 3))
              (should
               (cl-find-if
                (lambda (raw)
                  (string-match-p "INCLUDE" raw))
                requests)))))))))

(ert-deftest org-texmacs-issue13-stage2-scoped-selection-and-clipping
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Kept\n#+begin_equation*\n\"kept\"\n#+end_equation*\n"
     "* Omitted\n#+begin_equation bad\n\n#+end_equation\n")
    (dolist (scope '(subtree region narrow))
      (save-restriction
        (goto-char (point-min))
        (let ((start (point))
              (end
               (save-excursion
                 (outline-next-heading)
                 (point)))
              requests)
          (when (eq scope 'narrow)
            (narrow-to-region start end))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (raw &rest _)
                       (push raw requests)
                       "kept")))
            (should
             (org-texmacs-document-from-buffer
              (current-buffer)
              nil
              (and (eq scope 'subtree) start)
              (and (eq scope 'region) (cons start end))))
            (should (equal requests '("\"kept\"\n")))))))
    (goto-char (point-min))
    (search-forward "\"kept")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Clipped equation reached worker"))))
      (should-error
       (org-texmacs-document-from-buffer
        (current-buffer) nil nil (cons (point-min) (point)))
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-issue13-stage2-parser-boundaries-and-outermost
    ()
  (dolist (end '("" "#+end_equation*\n"))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_equation\n\"x\"\n" end)
      ;; Unclosed/mismatched wrappers are ordinary Org source, not native blocks.
      (should-not
       (org-texmacs--native-body-blocks (org-element-parse-buffer)))))
  (with-temp-buffer
    (org-mode)
    (insert
     "#+begin_equation\n(concat \"\n#+begin_equation*\n"
     "(math \"inner\")\n#+end_equation*\n\")\n#+end_equation\n")
    (should
     (= (length
         (org-texmacs--native-body-blocks (org-element-parse-buffer)))
        1))
    (should-not
     (org-texmacs--fragment-collect org-texmacs-fragment-tags))
    (let (requests)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (raw &rest _)
                   (push raw requests)
                   "outer")))
        (should (org-texmacs-document-from-buffer (current-buffer)))
        (should (= (length requests) 1)))))
  (with-temp-buffer
    (org-mode)
    (insert
     "- Item\n\n  #+begin_equation*\n  \"list\"\n  #+end_equation*\n")
    (let (requests)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (raw &rest _)
                   (push raw requests)
                   "list")))
        (let ((document
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (= (length (org-texmacs-document-stm-paths document)) 1))
          (should (= (length requests) 1)))))))

(ert-deftest
    org-texmacs-issue13-stage2-restored-notes-and-excluded-errors
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Kept\nText[fn:n].\n* Hidden :noexport:\n"
     "#+begin_equation bad\n\n#+end_equation\n"
     "[fn:n]\n#+begin_equation*\n\"note\"\n#+end_equation*\n")
    (goto-char (point-min))
    (let (requests)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (raw &rest _)
                   (push raw requests)
                   "note")))
        (let ((document
               (org-texmacs-document-from-buffer
                (current-buffer) nil (point))))
          (should
           (= (length (org-texmacs-document-stm-paths document)) 1))
          (should (equal requests '("\"note\"\n"))))))))

(ert-deftest
    org-texmacs-issue13-stage2-filter-cannot-edit-raw-citation
    ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_equation\n\"[cite:@raw]\"\n#+end_equation\n")
    (let ((org-export-filter-parse-tree-functions
           (list
            (lambda (ast _backend _info)
              (org-element-map
               ast 'citation-reference
               (lambda (node)
                 (org-element-put-property node :key "changed")))
              ast))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Mutated raw AST reached worker"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-issue13-stage2-wait-source-guard ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_equation\n\"x\"\n#+end_equation\n")
    (let ((source (current-buffer)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (with-current-buffer source
                     (goto-char (point-max))
                     (insert "changed"))
                   "x")))
        (should-error
         (org-texmacs-document-from-buffer source)
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-issue13-stage2-native-string-reader-and-recovery
    ()
  (org-texmacs-test--with-worker
   (dolist (raw '("\"\"" "\"a\\\"b\\\\c\"" "(sqrt \"x\")"))
     (with-temp-buffer
       (org-mode)
       (insert "#+begin_equation*\n" raw "\n#+end_equation*\n")
       (let ((document
              (org-texmacs-document-from-buffer (current-buffer))))
         (should
          (eq
           (car (cadr (org-texmacs-document-body document)))
           'equation*)))))
   (with-temp-buffer
     (org-mode)
     (insert "#+begin_equation\n\"a\" \"b\"\n#+end_equation\n")
     (should-error
      (org-texmacs-document-from-buffer (current-buffer))
      :type 'org-texmacs-parse-error)
     (erase-buffer)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil\n#+begin_equation\n\"recovered\"\n#+end_equation\n")
     (should
      (equal
       (org-texmacs-document-body
        (org-texmacs-document-from-buffer (current-buffer)))
       '(document (equation "recovered")))))))

(ert-deftest org-texmacs-issue13-stage3-source-bodies-and-caption ()
  (dolist (kind '("figure" "figure*" "table" "table*"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
       "#+CAPTION[Short]: Long *bold* [[file:caption.pdf][File]] (math \"literal\")\n"
       "#+begin_"
       kind
       "\n\n#+begin_texmacs\n"
       (if (string-prefix-p "table" kind)
           "(table (row (cell \"A\")))"
         "(math \"x\")")
       "\n#+end_texmacs\n\n#+end_"
       kind
       "\n")
      (let (requests)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (source &rest _)
                     (push source requests)
                     (read source))))
          (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
                 (before (org-texmacs-document input))
                 (body (org-texmacs-document-body before)))
            (should
             (eq (car (cadr body)) (intern (concat "big-" kind))))
            (should (= (length requests) 1))
            (should
             (equal
              (org-texmacs-document-stm-paths before)
              (if (string-prefix-p "table" kind)
                  '((0 0 0 0))
                '((0 0)))))
            (should (org-texmacs-document-file-paths before))
            (should (equal before (org-texmacs-document input)))))))))

(ert-deftest
    org-texmacs-issue13-stage3-original-body-errors-before-worker
    ()
  (dolist (extra
           '("# Comment\n"
             "#+TITLE: Hidden\n"
             "[fn:n] Unused\n"
             "Prose\n"
             "| Extra |\n"))
    (dolist (scope '(full region))
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_table\n| A |\n\n" extra "#+end_table\n")
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail
                      "Invalid source body reached worker"))))
          (should-error
           (org-texmacs-document-from-buffer
            (current-buffer)
            nil
            nil
            (and (eq scope 'region) (cons (point-min) (point-max))))
           :type 'org-texmacs-document-error)))))
  (dolist (extra
           '("# Comment\n" "#+TITLE: Hidden\n" "[fn:n] Unused\n"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_figure\n#+begin_texmacs\n\"x\"\n#+end_texmacs\n\n"
       extra
       "#+end_figure\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Invalid original wrapper submitted body STM"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error))))
  (dolist
      (source
       '("#+begin_figure\n#+end_figure\n"
         "#+begin_figure\n| A |\n#+end_figure\n"
         "#+begin_table bad\n| A |\n#+end_table\n"
         "#+NAME: first\n#+NAME: outer\n#+begin_table\n| A |\n#+end_table\n"
         "#+CAPTION:\n#+begin_table\n| A |\n#+end_table\n"
         "#+begin_table\n#+CAPTION: inner\n| A |\n#+end_table\n"
         "#+begin_table\n#+NAME: inner\n| A |\n#+end_table\n"
         "#+begin_figure\n#+begin_texmacs bad\n\"x\"\n#+end_texmacs\n#+end_figure\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid metadata reached worker"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-issue13-stage3-scope-and-complete-wrapper ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Kept\n#+CAPTION: Caption\n#+begin_table\n| A |\n#+end_table\n"
     "* Omitted\n#+begin_figure\nIllegal\n#+end_figure\n")
    (dolist (scope '(subtree region narrow))
      (save-restriction
        (goto-char (point-min))
        (let ((start (point))
              (end
               (save-excursion
                 (outline-next-heading)
                 (point))))
          (when (eq scope 'narrow)
            (narrow-to-region start end))
          (should
           (org-texmacs-document-from-buffer
            (current-buffer)
            nil
            (and (eq scope 'subtree) start)
            (and (eq scope 'region) (cons start end)))))))
    (dolist (clip '(caption body end))
      (goto-char (point-min))
      (let* ((start
              (if (eq clip 'caption)
                  (progn
                    (search-forward "Caption")
                    (point))
                (point-min)))
             (end
              (progn
                (search-forward
                 (if (eq clip 'end)
                     "end_table"
                   "| A |"))
                (point))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Incomplete wrapper reached worker"))))
          (should-error
           (org-texmacs-document-from-buffer
            (current-buffer) nil nil (cons start end))
           :type 'org-texmacs-document-error))))))

(ert-deftest org-texmacs-issue13-stage3-excluded-partial-wrapper ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Visible\nKept.\n* Hidden :noexport:\n#+CAPTION: Hidden\n"
     "#+begin_table\n| A |\n\n# extra\n#+end_table\n")
    (goto-char (point-min))
    (search-forward "| A |")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Excluded wrapper reached worker"))))
      (should
       (org-texmacs-document-from-buffer
        (current-buffer) nil nil (cons (point-min) (point)))))))

(ert-deftest
    org-texmacs-issue13-stage3-region-restored-wrapper-completeness
    ()
  (dolist (section '("" "* Footnotes\n"))
    (dolist (reference '(nil t))
      (with-temp-buffer
        (org-mode)
        (insert
         (if reference
             "Text[fn:n].\n\n"
           "Text.\n\n")
         section "[fn:n]\n#+begin_table\n| A |\n#+end_table\n")
        (goto-char (point-min))
        (search-forward "| A |")
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail
                      "Incomplete dependency reached worker"))))
          (if reference
              (should-error
               (org-texmacs-document-from-buffer
                (current-buffer) nil nil (cons (point-min) (point)))
               :type 'org-texmacs-document-error)
            (should
             (org-texmacs-document-from-buffer
              (current-buffer)
              nil
              nil
              (cons (point-min) (point))))))))))

(ert-deftest org-texmacs-issue13-stage3-caption-subset-and-registry ()
  ;; Named notes, citations and targets remain unsupported caption objects.
  ;; Anonymous inline notes have separate long/short AST compatibility coverage.
  (dolist (object
           (list
            (org-element-create
             'footnote-reference '(:type standard :label "n"))
            (org-element-create 'citation '(:style nil))
            (org-element-create 'target '(:value "target"))))
    (let* ((table
            (org-element-create
             'table '(:type org)
             (org-element-create
              'table-row
              '(:type standard)
              (org-element-create 'table-cell nil "A"))))
           (wrapper
            (org-element-create
             'special-block
             (list
              :type "table"
              :caption
              (list (cons (list object) nil)))
             table))
           (ast (org-element-create 'org-data nil wrapper)))
      (should-error
       (org-texmacs-document (org-texmacs-input-create ast nil))
       :type 'org-texmacs-document-error)))
  (with-temp-buffer
    (org-mode)
    (insert
     "#+CAPTION: [cite:@k]\n#+begin_table\n| A |\n#+end_table\n")
    (should-error
     (org-texmacs-document-from-buffer (current-buffer))
     :type 'org-texmacs-document-error))
  (dolist (key '("figure" "FIGURE*" "table" "TABLE*"))
    (should-error
     (org-texmacs--document-copy-handlers (list (cons key #'ignore)))
     :type 'org-texmacs-document-error)))

(ert-deftest
    org-texmacs-issue13-stage3-preflight-bibliography-and-native-recovery
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+BIBLIOGRAPHY: refs.bib\n#+begin_figure\nIllegal\n#+end_figure\n")
    (let (operations)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_source &optional operation)
                   (push operation operations)
                   (should (eq operation 'bibliography))
                   '(document))))
        (should-error
         (org-texmacs-document-from-buffer
          (current-buffer) '(("refs.bib" . "")))
         :type 'org-texmacs-document-error)
        (should (equal operations '(bibliography))))))
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+begin_table\n#+begin_texmacs\n(math \"bad-root\")\n#+end_texmacs\n#+end_table\n")
     (should-error
      (org-texmacs-document-from-buffer (current-buffer))
      :type 'org-texmacs-document-error)
     (erase-buffer)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
      "#+begin_table\n#+begin_texmacs\n(table (row (cell \"ok\")))\n#+end_texmacs\n#+end_table\n")
     (should
      (equal
       (org-texmacs-document-body
        (org-texmacs-document-from-buffer (current-buffer)))
       '(document
         (big-table
          (tabular (tformat (table (row (cell "ok"))))) "")))))))

(ert-deftest
    org-texmacs-issue13-stage3-include-restored-notes-and-opaque-body
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region
     "#+begin_table*\n| Included |\n#+end_table*\n" nil "part.org"
     nil 'silent)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+INCLUDE: \"part.org\"\n"
     "#+begin_figure\n#+begin_texmacs\n"
     "(concat \"\n#+INCLUDE: missing.org\n#+BIBLIOGRAPHY: missing.bib\n[fn:missing]\n\")\n"
     "#+end_texmacs\n#+end_figure\n"
     "Text[fn:n].\n\n[fn:n]\n#+begin_figure\n#+begin_texmacs\n"
     "\"Restored\"\n#+end_texmacs\n#+end_figure\n")
    (let* ((source (buffer-string))
           (document
            (org-texmacs-document-from-buffer-preprocessed
             (current-buffer))))
      (should
       (string-match-p
        "big-table\\*"
        (prin1-to-string (org-texmacs-document-body document))))
      (should
       (= (length (org-texmacs-document-stm-paths document)) 2))
      (should (equal source (buffer-string)))))))

(ert-deftest
    org-texmacs-issue13-stage3-filter-cannot-replace-source-evidence
    ()
  (dolist (mutation '(proof child duplicate))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_figure\n#+begin_texmacs\n\"x\"\n#+end_texmacs\n#+end_figure\n")
      (let ((org-export-filter-parse-tree-functions
             (list
              (lambda (ast _backend _info)
                (let* ((wrapper
                        (org-element-map
                         ast 'special-block #'identity nil t))
                       (child (car (org-element-contents wrapper))))
                  (pcase mutation
                    ('proof
                     (org-element-put-property
                      wrapper
                      :texmacs-figure-table-source nil))
                    ('child (org-element-extract child))
                    ('duplicate
                     (org-element-set-contents wrapper child child))))
                ast))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Mutated wrapper reached worker"))))
          (should-error
           (org-texmacs-document-from-buffer (current-buffer))
           :type 'org-texmacs-document-error))))))

(ert-deftest
    org-texmacs-issue13-stage3-owned-proof-pure-and-excluded-wrapper
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+CAPTION: (math \"text\") [[https://example.org][Link]]\n"
     "#+begin_table\n| A |\n#+end_table\n"
     "* Hidden :noexport:\n#+begin_figure\nWrong\n#+end_figure\n")
    (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
           (wrapper
            (org-element-map
             (org-texmacs-input-ast input)
             'special-block
             #'identity
             nil
             t))
           (proof
            (copy-tree
             (org-element-property
              :texmacs-figure-table-source wrapper))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Pure lower started worker")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _)
                   (ert-fail "Pure lower read source"))))
        (let ((first (org-texmacs-document input)))
          (should (equal first (org-texmacs-document input)))
          (should-not (org-texmacs-document-stm-paths first))))
      (should
       (equal
        proof
        (org-element-property
         :texmacs-figure-table-source wrapper))))))

;;; special-blocks.el ends here
