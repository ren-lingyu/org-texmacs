;;; document.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'org-id)
(require 'org-texmacs)
(require 'org-texmacs-parse)
(require 'ox)
(require 'subr-x)

(defun org-texmacs-test--with-registered-ftps (thunk)
  "Call THUNK with an Org-registered FTPS scheme and isolated parser regexps."
  (let ((org-link-parameters (cons '("ftps") org-link-parameters))
        (org-link-types-re org-link-types-re)
        (org-link-angle-re org-link-angle-re)
        (org-link-plain-re org-link-plain-re)
        (org-link-bracket-re org-link-bracket-re)
        (org-link-any-re org-link-any-re)
        (org-element--object-regexp org-element--object-regexp)
        (org-element-paragraph-separate
         org-element-paragraph-separate))
    (org-link-make-regexps)
    (org-element--set-regexps)
    (funcall thunk)))

(defun org-texmacs-test--reference-map (body)
  "Map BODY's random labels to structural fixture names, preserving static IDs."
  (let* ((labels (org-texmacs--document-output-labels body))
         (reserved
          (cl-remove-if-not
           (lambda (id)
             (string-match-p "\\`org-texmacs-ref-[0-9]+\\'" id))
           labels))
         (next 0)
         result)
    (dolist (id labels)
      (when (string-match-p "\\`org-texmacs-.*org[0-9a-f]+\\'" id)
        (let (canonical)
          (while (progn
                   (setq canonical
                         (format "org-texmacs-ref-%d" (cl-incf next)))
                   (member canonical reserved)))
          (push (cons id canonical) result))))
    (nreverse result)))

(defun org-texmacs-test--rewrite-references (tree mapping)
  "Copy TREE, replacing complete label/reference strings using MAPPING."
  (cond
   ((stringp tree)
    (or (cdr (assoc tree mapping))
        (and (string-prefix-p "#" tree)
             (when-let* ((id
                          (cdr (assoc (substring tree 1) mapping))))
               (concat "#" id)))
        tree))
   ((consp tree)
    (mapcar
     (lambda (child)
       (org-texmacs-test--rewrite-references child mapping))
     tree))
   (t
    tree)))

(defun org-texmacs-test--stable-reference-body (document)
  "Return DOCUMENT body with random references renamed for structural comparison."
  (let ((body (org-texmacs-document-body document)))
    (org-texmacs-test--rewrite-references
     body (org-texmacs-test--reference-map body))))

(defun org-texmacs-test--caption-inline-footnote (text)
  "Create an anonymous inline note with TEXT."
  (org-element-create 'footnote-reference (list :type 'inline) text))

(defun org-texmacs-test--caption-inline-footnote-input-args
    (kind caption &rest extra)
  "Build input constructor arguments for KIND, CAPTION and EXTRA blocks."
  (let* ((native (string-prefix-p "figure" kind))
         (body
          (if native
              (org-element-create
               'special-block (list :type "texmacs"))
            (org-element-create
             'table (list :type 'org)
             (org-element-create
              'table-row
              (list :type 'standard)
              (org-element-create 'table-cell nil "A")))))
         (node
          (if (equal kind "plain")
              body
            (org-element-create
             'special-block (list :type kind) body))))
    (org-element-put-property node :caption caption)
    (list
     (apply #'org-element-create 'org-data nil node extra)
     nil
     :islands (and native (list (cons body '(math "x")))))))

(defconst org-texmacs-test--fragment-strees
  '((math (frac "1" (sqrt "x")))
    (equation (frac "1" (sqrt "x")))
    (equation* (frac "1" (sqrt "x")))
    (eqnarray
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1"))
       (row (cell "y") (cell "=") (cell "2")))))
    (eqnarray*
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1"))
       (row (cell "y") (cell "=") (cell "2")))))
    (align
     (tformat
      (table
       (row (cell "x") (cell "=1")) (row (cell "y") (cell "=2")))))
    (align*
     (tformat
      (table
       (row (cell "x") (cell "=1")) (row (cell "y") (cell "=2")))))
    (gather (tformat (table (row (cell "x=1")) (row (cell "y=2")))))
    (gather* (tformat (table (row (cell "x=1")) (row (cell "y=2")))))
    (eqsplit
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1+2"))
       (row (cell "") (cell "=") (cell "3")))))
    (eqsplit*
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1+2"))
       (row (cell "") (cell "=") (cell "3"))))))
  "Representative default roots, including actual multi-row formula tables.
These fixtures test AST preservation, not numbering or rendering semantics.")

(defun org-texmacs-test--issue11-source (context payload)
  "Wrap PAYLOAD in a supported CONTEXT, suppressing document metadata."
  (concat
   "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
   (pcase context
     ('body payload)
     ('quote (concat "#+begin_quote\n" payload "#+end_quote\n"))
     ('center (concat "#+begin_center\n" payload "#+end_center\n"))
     ('footnote
      (concat
       "Text[fn:n]. Again[fn:n].\n\n[fn:n]\n"
       (replace-regexp-in-string "^" "  " payload)))
     ('list
      (concat
       "- Intro\n\n" (replace-regexp-in-string "^" "  " payload))))))

(ert-deftest org-texmacs-document-script-owned-nested-spacing ()
  (dolist (info '(nil (:with-sub-superscript t)))
    (let* ((sub (org-element-create 'subscript nil "i"))
           (leaf (org-element-create 'stm-fragment nil))
           (ast
            (org-element-create
             'org-data nil
             (org-element-create
              'paragraph
              nil
              "The "
              (org-element-create 'italic nil "first")
              " term is x"
              sub
              (org-element-create 'superscript nil "2")
              ". Nested x"
              (org-element-create
               'superscript
               '(:use-brackets-p t)
               "a"
               (org-element-create 'subscript nil "b"))
              ". "
              leaf
              (org-element-create
               'subscript
               (list :use-brackets-p t :post-blank 1)
               " q ")
              " after.")))
           (input
            (org-texmacs-input-create
             ast info
             :islands (list (cons leaf '(math (frac "a" "b"))))))
           (before
            (let ((print-circle t))
              (prin1-to-string input)))
           (org-export-with-sub-superscripts nil)
           result)
      (org-element-set-contents sub "changed")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Script invoked worker")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _) (ert-fail "Script read source")))
                ((symbol-function 'org-element-interpret-data)
                 (lambda (&rest _)
                   (ert-fail "Script serialized Org"))))
        (setq result (org-texmacs-document input))
        (should (equal result (org-texmacs-document input))))
      (should
       (equal
        (org-texmacs-document-body result)
        '(document
          (concat
           "The "
           (em "first")
           " term is x"
           (rsub "i")
           (rsup "2")
           ". Nested x"
           (rsup (concat "a" (rsub "b")))
           ". "
           (math (frac "a" "b"))
           (rsub " q ")
           " "
           "after."))))
      (should
       (equal (org-texmacs-document-stm-paths result) '((0 8))))
      (should
       (equal
        before
        (let ((print-circle t))
          (prin1-to-string input)))))))

(ert-deftest org-texmacs-document-script-disabled-structured-children
    ()
  (dolist (policy '(nil {}))
    (let* ((ast
            (org-element-create
             'org-data nil
             (org-element-create
              'paragraph
              nil
              "x"
              (org-element-create 'subscript nil "i")
              (org-element-create 'superscript nil "2")
              " y"
              (org-element-create
               'superscript
               '(:use-brackets-p t)
               (org-element-create 'bold nil "a")
               (org-element-create 'subscript nil "b")))))
           (input
            (org-texmacs-input-create
             ast (list :with-sub-superscript policy))))
      (should
       (equal
        (org-texmacs-document-body (org-texmacs-document input))
        (if policy
            '(document
              (concat
               "x"
               "_"
               "i"
               "^"
               "2"
               " y"
               (rsup (concat (strong "a") "_" "b"))))
          '(document
            (concat
             "x"
             "_"
             "i"
             "^"
             "2"
             " y"
             "^{"
             (strong "a")
             "_"
             "b"
             "}"))))))))

(ert-deftest org-texmacs-document-script-metadata-guards ()
  (dolist (child
           (list
            (org-element-create 'line-break nil)
            (org-element-create
             'link
             '(:type "file" :path "/tmp/script.pdf") "Link")))
    (let* ((ast
            (org-element-create
             'org-data nil
             (org-element-create
              'headline
              (list
               :level 1
               :title
               (list
                "Heading x"
                (org-element-create
                 'superscript '(:use-brackets-p t) child))))))
           (input (org-texmacs-input-create ast nil)))
      (should-error
       (org-texmacs-document input)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-entity-owned-pure-options ()
  (dolist (info '(nil (:with-entities t) (:with-entities nil)))
    (let* ((value (copy-sequence "α"))
           (entity
            (org-element-create
             'entity
             (list
              :name "alpha"
              :utf-8 value
              :latex-math-p t
              :use-brackets-p t
              :post-blank 1)))
           (leaf (org-element-create 'stm-fragment nil))
           (ast
            (org-element-create
             'org-data nil
             (org-element-create
              'paragraph
              nil
              "Before "
              entity
              "literal <alpha> "
              leaf)))
           (input
            (org-texmacs-input-create
             ast info
             :islands (list (cons leaf '(math "x")))))
           (before
            (let ((print-circle t))
              (prin1-to-string input)))
           (org-export-with-entities nil)
           (org-entities-user
            '(("alpha" "wrong" t "wrong" "wrong" "wrong" "wrong")))
           result)
      ;; The input owns entity values and STM trees before pure conversion.
      (should-not
       (eq
        value
        (org-element-property
         :utf-8
         (org-element-map
          (org-texmacs-input-ast input) 'entity #'identity nil t))))
      (org-element-put-property entity :utf-8 "changed")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Entity invoked worker")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _) (ert-fail "Entity read source")))
                ((symbol-function 'org-entity-get)
                 (lambda (&rest _)
                   (ert-fail "Entity read dynamic definitions"))))
        (setq result (org-texmacs-document input))
        (should (equal result (org-texmacs-document input))))
      (should
       (equal
        (org-texmacs-document-body result)
        `(document
          (concat
           "Before "
           ,(if (and info (null (plist-get info :with-entities)))
                "\\alpha{}"
              '(math "α"))
           " " "literal <alpha> " (math "x")))))
      (should
       (equal (org-texmacs-document-stm-paths result) '((0 4))))
      (should
       (equal
        before
        (let ((print-circle t))
          (prin1-to-string input)))))))

(ert-deftest org-texmacs-document-entity-invalid-representation ()
  (dolist (props
           '((:name "missing")
             (:name "empty" :utf-8 "")
             (:name "wrong" :utf-8 3)
             (:name "wrong" :utf-8 "x" :latex-math-p math)
             (:name "wrong" :utf-8 "x" :use-brackets-p brackets)
             (:name nil :utf-8 "x")))
    (should-error
     (org-texmacs-document
      (org-texmacs-input-create
       (org-element-create
        'org-data nil
        (org-element-create
         'paragraph nil (org-element-create 'entity props)))
       nil))
     :type 'org-texmacs-document-error))
  ;; Disabled interpretation needs source spelling, not a Unicode fallback.
  (should
   (equal
    (org-texmacs-document-body
     (org-texmacs-document
      (org-texmacs-input-create
       (org-element-create
        'org-data nil
        (org-element-create
         'paragraph
         nil
         (org-element-create 'entity '(:name "unknown"))))
       '(:with-entities nil))))
    '(document (concat "\\unknown")))))

(ert-deftest org-texmacs-document-entity-text-and-structured-contexts
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Heading \\alpha\n/Emphasis \\copy/ and note[fn::\\rightarrow].\n"
     "#+CAPTION: Caption \\cdot\n| Cell \\copy |\n")
    (let* ((ast (org-element-parse-buffer))
           (_affiliation
            (org-element-put-property
             (org-element-map ast 'table #'identity nil t)
             :texmacs-affiliated-keywords '("CAPTION")))
           (input (org-texmacs-input-create ast nil))
           (body
            (org-texmacs-document-body (org-texmacs-document input))))
      (should
       (equal
        (org-texmacs-test--caption-inline-footnote-nodes
         body 'math)
        '((math "α") (math "→") (math "⋅"))))
      (should (string-search "©" (prin1-to-string body)))
      (should-not
       (member
        '(math "©")
        (org-texmacs-test--caption-inline-footnote-nodes
         body 'math))))))

(ert-deftest org-texmacs-caption-inline-footnote-owned-ast ()
  (dolist (kind '("plain" "figure" "figure*" "table" "table*"))
    (let* ((link
            (org-element-create
             'link
             (list
              :type "file"
              :path "/tmp/caption-note.pdf")
             "File"))
           (note
            (org-element-create
             'footnote-reference
             (list :type 'inline)
             "Explanation"
             (org-element-create 'bold nil "bold")
             link))
           (caption
            (list
             (cons
              (list (copy-sequence "Long") note)
              (list
               "Short"
               (org-texmacs-test--caption-inline-footnote
                "ShortNote")))
             (cons
              (list
               "Second" (org-element-create 'bold nil "Caption"))
              nil)))
           (body
            (org-element-create
             'paragraph
             nil
             "Body"
             (org-texmacs-test--caption-inline-footnote "BodyNote")
             (org-element-create
              'footnote-reference (list :type 'standard :label "n"))))
           (definition
            (org-element-create
             'footnote-definition
             (list :label "n")
             (org-element-create 'paragraph nil "NamedNote")))
           (args
            (org-texmacs-test--caption-inline-footnote-input-args
             kind caption
             body definition))
           (source
            (let ((print-circle t))
              (prin1-to-string (car args))))
           (input (apply #'org-texmacs-input-create args))
           document)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Pure caption lower invoked worker")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _)
                   (ert-fail "Pure caption lower read source"))))
        (setq document (org-texmacs-document input))
        (should (equal document (org-texmacs-document input))))
      (should
       (equal
        source
        (let ((print-circle t))
          (prin1-to-string (car args)))))
      (should
       (equal
        (caddr (cadr (org-texmacs-document-body document)))
        '(caption-detailed
          (concat
           (concat
            "Long"
            (footnote
             (document
              (concat
               "Explanation"
               (strong "bold")
               (hlink "File" "/tmp/caption-note.pdf")))))
           " " (concat "Second" (strong "Caption")))
          (concat
           "Short" (footnote (document (concat "ShortNote")))))))
      (should
       (= 4
          (length
           (org-texmacs-test--caption-inline-footnote-nodes
            (org-texmacs-document-body document) 'footnote))))
      (should (org-texmacs-document-file-paths document))
      (should
       (equal
        (org-texmacs-document-stm-paths document)
        (and (string-prefix-p "figure" kind) '((0 0)))))
      ;; Prepared input owns all caption descendants independently of its source.
      (org-element-put-property note :type 'standard)
      (aset (car (car (car caption))) 0 ?X)
      (should (equal document (org-texmacs-document input))))))

(ert-deftest org-texmacs-caption-inline-footnote-invalid-ast ()
  (dolist (short '(nil t))
    (dolist (note
             (list
              (org-element-create
               'footnote-reference (list :type 'standard :label "n"))
              (org-element-create
               'footnote-reference
               (list :type 'inline :label "n") "Named")
              (org-element-create
               'footnote-reference (list :type 'invalid) "Wrong")
              (org-element-create
               'footnote-reference (list :type 'inline)
               (org-element-create
                'citation nil
                (org-element-create
                 'citation-reference (list :key "k"))))
              (org-element-create
               'footnote-reference
               (list :type 'inline)
               (org-texmacs-test--caption-inline-footnote "Nested"))))
      (let* ((caption
              (list
               (if short
                   (cons '("Long") (list note))
                 (cons (list note) nil))))
             (definition
              (org-element-create
               'footnote-definition
               (list :label "n")
               (org-element-create 'paragraph nil "Definition")))
             (input
              (apply
               #'org-texmacs-input-create
               (org-texmacs-test--caption-inline-footnote-input-args
                "table" caption
                definition))))
        (should-error
         (org-texmacs-document input)
         :type 'org-texmacs-document-error))))
  (let* ((note
          (org-texmacs-test--caption-inline-footnote "WrongContext"))
         (paragraph
          (org-element-create
           'paragraph nil (org-element-create 'bold nil note)))
         (input
          (org-texmacs-input-create
           (org-element-create 'org-data nil paragraph) nil)))
    (should-error
     (org-texmacs-document input)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-issue11-bare-identity-and-purity ()
  :tags
  '(issue11)
  (dolist (tree
           (append
            org-texmacs-test--fragment-strees
            '((with "mode" "math" "<alpha>")
              (concat "a" "b")
              "literal"
              " "
              "")))
    (dolist (blank '("" " \t\r\n"))
      (let* ((leaf (org-element-create 'stm-fragment nil))
             (ast
              (org-element-create
               'org-data nil
               (apply #'org-element-create
                      'paragraph nil
                      (append
                       (list (copy-sequence blank) leaf)
                       (and (> (length blank) 0)
                            (list (copy-sequence blank)))))))
             (input
              (org-texmacs-input-create
               ast nil
               :islands (list (cons leaf tree))))
             (before
              (let ((print-circle t))
                (prin1-to-string (org-texmacs-input-ast input))))
             first
             second)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Pure lowering requested worker")))
                  ((symbol-function 'buffer-substring-no-properties)
                   (lambda (&rest _)
                     (ert-fail "Pure lowering read buffer"))))
          (setq
           first (org-texmacs-document input)
           second (org-texmacs-document input)))
        (should
         (equal
          (org-texmacs-document-body first) (list 'document tree)))
        (should (equal (org-texmacs-document-stm-paths first) '((0))))
        (should-not (org-texmacs-document-file-paths first))
        (unless (equal tree "")
          (should-not
           (eq
            (cadr (org-texmacs-document-body first))
            (cadr (org-texmacs-document-body second)))))
        (should
         (equal
          before
          (let ((print-circle t))
            (prin1-to-string (org-texmacs-input-ast input))))))))
  ;; A mapped fragment is an island even when it has no source properties.
  (let* ((leaf (org-element-create 'stm-fragment nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil leaf))))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-test--lower ast (list (cons leaf '(math "x")))))
      '(document (math "x"))))))

(ert-deftest org-texmacs-document-issue11-nonbare-boundaries ()
  :tags
  '(issue11)
  (dolist (other
           (list
            "Text"
            "\u00a0"
            (org-element-create 'bold nil "")
            (org-element-create 'line-break nil)))
    (let* ((leaf (org-element-create 'stm-fragment nil))
           (ast
            (org-element-create
             'org-data nil
             (org-element-create 'paragraph nil other leaf)))
           (result
            (org-texmacs-test--lower
             ast (list (cons leaf '(math "x"))))))
      (should (eq (caadr (org-texmacs-document-body result)) 'concat))
      (should
       (equal (org-texmacs-document-stm-paths result) '((0 1))))))
  (let* ((one (org-element-create 'stm-fragment nil))
         (two (org-element-create 'stm-fragment nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil one " " two)))
         (result
          (org-texmacs-test--lower
           ast (list (cons one '(math "x")) (cons two '(math "y"))))))
    (should
     (equal
      (org-texmacs-document-body result)
      '(document (concat (math "x") " " (math "y")))))
    (should
     (equal (org-texmacs-document-stm-paths result) '((0 0) (0 2)))))
  ;; An unused target can disappear from output, but still makes the source
  ;; paragraph non-bare.  Do not decide eligibility from lowered parts alone.
  (let* ((leaf (org-element-create 'stm-fragment nil))
         (target (org-element-create 'target '(:value "unused")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil target leaf)))
         (result
          (org-texmacs-test--lower
           ast (list (cons leaf '(math "x"))))))
    (should
     (equal
      (org-texmacs-document-body result)
      '(document (concat "" (math "x")))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 1)))))
  (let* ((leaf (org-element-create 'stm-fragment nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil leaf leaf))))
    (should-error
     (org-texmacs-test--lower ast (list (cons leaf '(math "x"))))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-issue11-display-mixtures-reject ()
  :tags
  '(issue11)
  (dolist (tag
           '(equation
             equation*
             eqnarray
             eqnarray*
             align
             align*
             gather
             gather*
             eqsplit
             eqsplit*))
    (dolist (other
             (list
              "Before "
              "\u00a0"
              (org-element-create 'bold nil "")
              (org-element-create 'target '(:value "unused"))))
      (let* ((leaf (org-element-create 'stm-fragment nil))
             (ast
              (org-element-create
               'org-data
               nil
               (org-element-create 'paragraph nil other leaf))))
        (should-error
         (org-texmacs-test--lower
          ast (list (cons leaf (list tag "x"))))
         :type 'org-texmacs-document-error))))
  (let* ((one (org-element-create 'stm-fragment nil))
         (two (org-element-create 'stm-fragment nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil one " " two))))
    (should-error
     (org-texmacs-test--lower
      ast (list (cons one '(math "x")) (cons two '(equation "y"))))
     :type 'org-texmacs-document-error))
  ;; A wrapper is authored STM, not an invitation to inspect or rewrite inside it.
  (let* ((leaf (org-element-create 'stm-fragment nil))
         (tree '(with "mode" "math" (equation "x")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil "Before " leaf))))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-test--lower ast (list (cons leaf tree))))
      `(document (concat "Before " ,tree))))))

(ert-deftest org-texmacs-document-empty ()
  (let ((result
         (org-texmacs-test--lower
          (org-element-create 'org-data nil))))
    (should (org-texmacs-document-p result))
    (should (equal (org-texmacs-document-body result) '(document)))
    (should-not (org-texmacs-document-stm-paths result))
    (should (equal (org-texmacs-document-style result) '("generic")))
    (should-not (org-texmacs-document-initial result))))

(ert-deftest org-texmacs-document-paragraphs-and-bold ()
  (let* ((bold (org-element-create 'bold '(:post-blank 2) "bold"))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create
            'section nil
            (org-element-create
             'paragraph nil "Before " bold "after.\n")
            (org-element-create 'paragraph nil "Next.\n"))))
         (result (org-texmacs-test--lower ast)))
    (should
     (equal
      (org-texmacs-document-body result)
      '(document
        (concat
         "Before " (strong "bold") " " "after. ")
        (concat "Next. "))))
    (should-not (org-texmacs-document-stm-paths result))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-test--lower ast nil (list (cons bold "\t "))))
      '(document
        (concat
         "Before " (strong "bold") " " "after. ")
        (concat "Next. "))))))

(ert-deftest org-texmacs-document-inline-whitespace-stream ()
  (let* ((value (copy-sequence " \nb\t"))
         (bold (org-element-create 'bold '(:post-blank 2) value))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create
            'paragraph nil " \ta  " bold "\n c\r\n")
           (org-element-create 'paragraph nil "\tsecond\n")))
         (before (substring-no-properties value))
         (result (org-texmacs-test--lower ast)))
    ;; State crosses Org object boundaries, but not paragraph boundaries.
    ;; Empty text slots remain rather than shifting island child indices.
    (should
     (equal
      (org-texmacs-document-body result)
      '(document
        (concat "a " (strong "b ") "" "c ") (concat "second "))))
    (should (equal before (substring-no-properties value)))
    (should (equal (org-element-property :post-blank bold) 2))))

(ert-deftest org-texmacs-document-nested-inline-and-cycles ()
  (let* ((italic (org-element-create 'italic nil "i"))
         (bold (org-element-create 'bold nil "b " italic))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil bold))))
    (should
     (equal
      (org-texmacs-document-body (org-texmacs-test--lower ast))
      '(document (concat (strong (concat "b " (em "i")))))))
    (org-element-set-contents italic bold)
    (should-error
     (org-texmacs-test--lower ast)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-markup-single-body ()
  (dolist (mapping
           '((bold . strong)
             (italic . em)
             (underline . underline)
             (strike-through . strike-through)))
    (dolist (parts '(nil ("one") ("one" " two")))
      (let* ((node
              (apply #'org-element-create (car mapping) nil parts))
             (ast
              (org-element-create
               'org-data
               nil
               (org-element-create 'paragraph nil node)))
             (body
              (org-texmacs-document-body
               (org-texmacs-test--lower ast)))
             (markup (cadr (cadr body))))
        (should (= (length markup) 2))
        (should
         (equal
          markup
          (list
           (cdr mapping)
           (cond
            ((null parts)
             "")
            ((null (cdr parts))
             "one")
            (t
             '(concat "one" " two"))))))))))

(ert-deftest org-texmacs-document-literal-inline-semantics ()
  (dolist (type '(code verbatim))
    (let* ((value
            (copy-sequence "*not bold*\t (math \"x\")\n<alpha> ¯˙"))
           (node (org-element-create type (list :value value)))
           (ast
            (org-element-create
             'org-data nil
             (org-element-create 'paragraph nil node)))
           (result (org-texmacs-test--lower ast)))
      (should
       (equal
        (org-texmacs-document-body result)
        '(document
          (concat (verbatim "*not bold* (math \"x\") <alpha> ¯˙")))))
      (should-not (org-texmacs-document-stm-paths result))
      (should (equal value "*not bold*\t (math \"x\")\n<alpha> ¯˙"))
      (org-element-set-contents node "unexpected")
      (should-error
       (org-texmacs-test--lower ast)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-whitespace-island-boundary ()
  (let* ((foreign (org-element-create 'stm-fragment nil))
         (native '(concat " \tSTM\n" (em "  untouched  ")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create
            'paragraph nil "A\t " foreign "\n B C\n")))
         (result
          (org-texmacs-test--lower ast (list (cons foreign native)))))
    ;; NBSP is not ordinary prose whitespace; STM content is never inspected.
    (should
     (equal
      (org-texmacs-document-body result)
      '(document
        (concat
         "A "
         (concat " \tSTM\n" (em "  untouched  ")) " B C "))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 1))))
    (should
     (equal native '(concat " \tSTM\n" (em "  untouched  "))))))

(ert-deftest org-texmacs-document-reference-label-skips-stm-label ()
  (let* ((island
          (org-element-create 'special-block '(:type "texmacs")))
         (link
          (org-element-create
           'link '(:type "custom-id" :path "local")))
         (headline
          (org-element-create
           'headline
           '(:level
             1
             :raw-value "Alpha"
             :title ("Alpha")
             :CUSTOM_ID "local")
           (org-element-create
            'section nil (org-element-create 'paragraph nil link))))
         (ast (org-element-create 'org-data nil island headline))
         (body
          (org-texmacs-test--stable-reference-body
           (org-texmacs-test--lower
            ast (list (cons island '(label "org-texmacs-ref-1")))))))
    (should (equal (nth 2 body) '(section "Alpha")))
    (should (equal (nth 3 body) '(label "org-texmacs-ref-2")))
    (should
     (equal (nth 4 body) '(concat (reference "org-texmacs-ref-2"))))))

(ert-deftest org-texmacs-document-uri-type-and-target-contract ()
  (let* ((path (copy-sequence "//example.org/<alpha>\t%20"))
         (link
          (org-element-create
           'link
           (list :type "HTTPS" :path path :raw-link "file:wrong")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil link)))
         (body
          (org-texmacs-document-body (org-texmacs-test--lower ast))))
    (should
     (equal
      body
      '(document
        (concat
         (hlink
          "HTTPS://example.org/<alpha>\t%20"
          "HTTPS://example.org/<alpha>\t%20")))))
    (should-not (eq path (nth 2 (nth 1 (nth 1 body)))))
    (should (equal path "//example.org/<alpha>\t%20")))
  (dolist (type '(nil ""))
    (let ((ast
           (org-element-create
            'org-data nil
            (org-element-create
             'paragraph nil
             (org-element-create
              'link
              (list
               :type type
               :path "x"
               :raw-link "https://example.org"))))))
      (should-error
       (org-texmacs-test--lower ast)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-unsupported-link-visible-content ()
  (let* ((described
          (org-element-create
           'link
           '(:type "news" :path "ignored" :post-blank 1)
           (org-element-create 'bold nil "Important") " note"))
         (bare
          (org-element-create
           'link
           '(:type
             "news"
             :path "different"
             :raw-link "news:raw text"
             :post-blank 1)))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create
            'paragraph nil "Before " described bare "after.")))
         (plain
          (org-element-create
           'org-data nil
           (org-element-create
            'paragraph
            nil
            "Before "
            (org-element-create 'bold nil "Important")
            " note"
            (copy-sequence " ")
            "news:raw text"
            (copy-sequence " ")
            "after.")))
         (document (org-texmacs-test--lower ast)))
    (should
     (equal
      (org-texmacs-document-body document)
      (org-texmacs-document-body (org-texmacs-test--lower plain))))
    (should-not (org-texmacs-document-file-paths document))
    (should-not (org-texmacs-document-stm-paths document)))
  (dolist (raw '(nil "" 42))
    (let ((ast
           (org-element-create
            'org-data nil
            (org-element-create
             'paragraph nil
             (org-element-create
              'link (list :type "news" :path "x" :raw-link raw))))))
      (should-error
       (org-texmacs-test--lower ast)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-footnote-whitespace-and-empty ()
  (let* ((note
          (org-element-create
           'footnote-reference
           '(:type inline :post-blank 2)
           " \tnote\n "
           (org-element-create 'line-break nil)
           " \tend "))
         (empty
          (org-element-create 'footnote-reference '(:type inline)))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil "a " note " b " empty)))
         (before
          (substring-no-properties (car (org-element-contents note))))
         (result (org-texmacs-test--lower ast)))
    (should
     (equal
      (org-texmacs-document-body result)
      '(document
        (concat
         "a "
         (footnote (document (concat "note " (next-line) "end ")))
         " "
         "b "
         (footnote (document (concat "")))))))
    (should-not (org-texmacs-document-stm-paths result))
    (should
     (equal
      before
      (substring-no-properties (car (org-element-contents note)))))))

(ert-deftest
    org-texmacs-document-named-footnote-label-collision-and-empty
    ()
  (let* ((island (org-element-create 'stm-fragment nil))
         (reference
          (org-element-create
           'footnote-reference '(:type standard :label "n")))
         (definition
          (org-element-create 'footnote-definition '(:label "n")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create
            'paragraph nil reference island)
           definition))
         (input
          (org-texmacs-input-create
           ast nil
           :islands
           (list (cons island '(label "org-texmacs-fn-1"))))))
    (should
     (equal
      (org-texmacs-document-body (org-texmacs-document input))
      '(document
        (concat
         (footnote
          (surround (label "org-texmacs-fn-2") "" (document)))
         (label "org-texmacs-fn-1")))))))

(ert-deftest org-texmacs-document-issue10-pure-bare ()
  :tags
  '(issue10)
  (dolist (tree
           (append
            org-texmacs-test--fragment-strees
            '((with "mode" "math" "x") "atomic" " " "")))
    (let* ((leaf (org-element-create 'stm-fragment nil))
           (note
            (org-element-create
             'footnote-reference '(:type inline) " \t" leaf "\r\n"))
           (ast
            (org-element-create
             'org-data nil
             (org-element-create 'paragraph nil "A" note)))
           (input
            (org-texmacs-input-create
             ast
             nil
             :islands (list (cons leaf tree)))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Pure lowering started worker")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _)
                   (ert-fail "Pure lowering read buffer"))))
        (let ((document (org-texmacs-document input)))
          (should
           (equal
            (org-texmacs-document-body document)
            `(document (concat "A" (footnote (document ,tree))))))
          (should
           (equal
            (org-texmacs-document-stm-paths document)
            '((0 1 0 0)))))))))

(ert-deftest org-texmacs-document-issue10-display-mixtures ()
  :tags
  '(issue10)
  (dolist (tag org-texmacs--document-display-math-tags)
    (dolist (label '(nil "n"))
      (let* ((leaf (org-element-create 'stm-fragment nil))
             (note
              (org-element-create
               'footnote-reference
               (list :type 'inline :label label) "Before " leaf))
             (ast
              (org-element-create
               'org-data
               nil
               (org-element-create 'paragraph nil note))))
        (should-error
         (org-texmacs-test--lower
          ast (list (cons leaf (list tag "x"))))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-headline-levels ()
  (with-temp-buffer
    (org-mode)
    (insert "* First\nBody.\n*** Third\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-test--lower (org-element-parse-buffer)))
      '(document
        (section "First")
        (concat "Body. ")
        (subsubsection "Third"))))))

(ert-deftest org-texmacs-document-island-paths-and-copies ()
  (let* ((ordinary (copy-sequence "<alpha>"))
         (foreign (org-element-create 'stm-fragment nil))
         (paragraph
          (org-element-create 'paragraph nil ordinary foreign "\n"))
         (block
          (org-element-create 'special-block '(:type "texmacs")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'section nil paragraph block)))
         (stree (list 'document (copy-sequence "中")))
         (result
          (org-texmacs-test--lower
           ast
           (list
            (cons foreign '(math "<alpha>")) (cons block stree))))
         (body (org-texmacs-document-body result)))
    (should
     (equal
      body
      '(document
        (concat "<alpha>" (math "<alpha>") " ") (document "中"))))
    (should
     (equal (org-texmacs-document-stm-paths result) '((0 1) (1))))
    (should-not (eq ordinary (nth 1 (nth 1 body))))
    (should-not (text-properties-at 0 (nth 1 (nth 1 body))))
    (should-not (eq stree (nth 2 body)))
    (should-not (eq (cadr stree) (cadr (nth 2 body))))))

(ert-deftest org-texmacs-document-rich-title-without-worker ()
  (cl-letf (((symbol-function 'org-texmacs--worker-start)
             (lambda (&rest _)
               (ert-fail "Pure lowering started a worker")))
            ((symbol-function 'org-texmacs--stm-read)
             (lambda (&rest _)
               (ert-fail "Pure lowering requested parsing"))))
    (with-temp-buffer
      (org-mode)
      (insert "** A *bold* title\n")
      (let ((source (buffer-string)))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-test--lower (org-element-parse-buffer)))
          '(document
            (section (concat "A " (strong "bold") " " "title")))))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-document-rejects-invalid-whitespace ()
  (let* ((bold (org-element-create 'bold nil "bold"))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil bold))))
    (dolist (value '("\n" "text" 1))
      (should-error
       (org-texmacs-test--lower ast nil (list (cons bold value)))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-atomic-island ()
  (let* ((block
          (org-element-create 'special-block '(:type "texmacs")))
         (ast (org-element-create 'org-data nil block))
         (result
          (org-texmacs-test--lower
           ast (list (cons block "literal")))))
    (should
     (equal (org-texmacs-document-body result) '(document "literal")))
    (should (equal (org-texmacs-document-stm-paths result) '((0))))))

(ert-deftest org-texmacs-document-rejects-unsupported-source ()
  (dolist (source
           '("A[fn:named]\n"
             "# comment\n"
             "#+title: Title\n"
             "* COMMENT Task\n"
             "* \n"
             "#+name: named\nParagraph\n"
             "#+attr_html: :class test\nParagraph\n"
             "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (should-error
       (org-texmacs-test--lower (org-element-parse-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-unavailable-link-content ()
  (dolist (case
           '(("[[file:notes.org][link]]" . "link")
             ("[[./notes.org]]" . "./notes.org")
             ("[[file:/ssh:host:/tmp/notes.org]]"
              .
              "file:/ssh:host:/tmp/notes.org")
             ("[[file:notes.org::heading]]"
              .
              "file:notes.org::heading")
             ("[[file+emacs:notes.org]]" . "file+emacs:notes.org")
             ("[[#target]]" . "#target")
             ("[[id:missing]]" . "id:missing")
             ("[[unresolved]]" . "unresolved")))
    (with-temp-buffer
      (org-mode)
      (insert (car case) "\n")
      (let* ((document
              (org-texmacs-test--lower (org-element-parse-buffer)))
             (body (org-texmacs-document-body document)))
        (should-not (memq 'hlink (flatten-tree body)))
        (should-not (memq 'reference (flatten-tree body)))
        (should-not (org-texmacs-document-file-paths document))
        (should
         (equal
          (string-trim
           (apply #'concat
                  (cl-remove-if-not #'stringp (flatten-tree body))))
          (cdr case)))))))

(ert-deftest org-texmacs-document-rejects-invalid-mappings ()
  (let* ((leaf (org-element-create 'stm-fragment nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil leaf))))
    (dolist (mapping
             (list
              (list (cons leaf '(math "x")) (cons leaf "x"))
              (list (cons (copy-sequence "missing") "x"))
              (list (cons leaf '(math 1)))
              (list (cons leaf '(nil "x")))))
      (should-error
       (org-texmacs-test--lower ast mapping)
       :type 'org-texmacs-document-error))
    (should-error
     (org-texmacs-test--lower ast nil (list (cons leaf " ")))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-rejects-cycles ()
  (let* ((bold (org-element-create 'bold nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil bold))))
    (org-element-set-contents bold bold)
    (should-error
     (org-texmacs-test--lower ast)
     :type 'org-texmacs-document-error))
  (let ((stree (list 'math "x")))
    (setcar (cdr stree) stree)
    (should-error
     (org-texmacs--document-copy-stree stree)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-lowering-needs-no-source ()
  (let ((ast
         (org-element-create
          'org-data nil
          (org-element-create 'paragraph nil "Text"))))
    (with-temp-buffer
      (cl-letf (((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _) (ert-fail "Lowering read source")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Lowering requested worker")))
                ((symbol-function 'org-texmacs--document-options)
                 (lambda (&rest _)
                   (ert-fail "Lowering captured editor options"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-test--lower ast))
          '(document (concat "Text"))))))))

(ert-deftest org-texmacs-document-heading-settings-parser-parity ()
  (with-temp-buffer
    (insert
     "#+TODO: WAIT | FINISHED\n"
     "* WAIT [#A] A *bold* title :tag:\n*** FINISHED Done\n")
    (org-mode)
    (setq-local org-odd-levels-only t)
    (cl-labels
     ((properties
       ()
       (org-element-map
        (org-element-parse-buffer) 'headline
        (lambda (node)
          (mapcar
           (lambda (key) (org-element-property key node))
           '(:level
             :todo-keyword
             :todo-type
             :priority
             :raw-value
             :tags))))))
     (let ((expected (properties))
           (settings (org-texmacs--document-heading-settings))
           (source (buffer-string)))
       (should
        (equal
         expected
         '((1 "WAIT" todo 65 "A *bold* title" ("tag"))
           (2 "FINISHED" done nil "Done" nil))))
       (with-temp-buffer
         (org-mode)
         (org-texmacs--document-use-heading-settings settings)
         (insert source)
         (should (equal (properties) expected)))))))

(ert-deftest org-texmacs-document-file-link-settings-parser-parity ()
  (dolist (org-element-use-cache '(nil t))
    (with-temp-buffer
      (let ((org-link-abbrev-alist
             '(("demo" . "http://global.test/%s"))))
        (insert
         "#+LINK: demo https://example.test/%s\n\n[[demo:item]]\n")
        (org-mode)
        (goto-char (point-max))
        (forward-line -1)
        ;; Populate the element cache when enabled before reading the context.
        (org-element-at-point)
        (let* ((ast (org-texmacs--ast-parse-buffer (current-buffer)))
               (link (org-element-map ast 'link #'identity nil t))
               (syntax (org-element-property :org-texmacs-syntax ast))
               (links (plist-get syntax :link-settings))
               (expected '(("demo" . "https://example.test/%s"))))
          (should (equal (org-element-property :type link) "https"))
          (should
           (equal
            (org-element-property :path link) "//example.test/item"))
          (should (equal (plist-get links :local) expected))
          (should
           (equal
            (cdr (org-texmacs--document-link-settings))
            (list org-link-abbrev-alist expected))))))))

(ert-deftest org-texmacs-document-heading-settings-copy-isolation ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-todo-regexp (copy-sequence "\\(WAIT\\)"))
    (setq-local org-done-keywords (list (copy-sequence "FINISHED")))
    (setq-local org-priority-regexp
                (copy-sequence org-priority-regexp))
    (let* ((settings (org-texmacs--document-heading-settings))
           (expected (org-texmacs--document-heading-settings)))
      (aset org-todo-regexp 0 ?x)
      (aset (car org-done-keywords) 0 ?x)
      (aset org-priority-regexp 0 ?x)
      (should (equal settings expected))
      (with-temp-buffer
        (org-mode)
        (org-texmacs--document-use-heading-settings settings)
        (aset org-todo-regexp 0 ?y)
        (aset (car org-done-keywords) 0 ?y)
        (aset org-priority-regexp 0 ?y)
        (should (equal settings expected))))))

(ert-deftest org-texmacs-headline-formatter-copies-and-preserves-parts
    ()
  (let* ((todo (copy-sequence "WAIT"))
         (plain (copy-sequence "Title"))
         (parts (list plain '(strong "bold") "\t " "end"))
         (tags (list (copy-sequence "one")))
         (result
          (org-texmacs-format-headline-default-function
           todo 'todo 12 parts tags nil)))
    (should
     (equal
      result
      '(concat
        (strong "WAIT")
        " "
        "[#12]"
        " "
        "Title"
        (strong "bold")
        "\t "
        "end"
        " "
        ":one:")))
    (should
     (equal
      result
      (org-texmacs-format-headline-default-function
       todo 'done 12 parts tags nil)))
    (should (equal parts '("Title" (strong "bold") "\t " "end")))
    (aset todo 0 ?X)
    (aset plain 0 ?X)
    (aset (car tags) 0 ?X)
    (should (equal (cadr (cadr result)) "WAIT"))
    (should (equal (nth 5 result) "Title")))
  (let* ((text (copy-sequence "Title"))
         (result
          (org-texmacs-format-headline-default-function
           nil nil nil (list text) nil nil)))
    (should (equal result text))
    (should-not (eq result text))))

(ert-deftest org-texmacs-document-named-table-caption-ownership ()
  (let (input
        expected)
    (with-temp-buffer
      (org-mode)
      (insert
       "#+caption[Short]: Long *B* [[https://example.org][URI]]\n| x |\n")
      (let* ((ast (org-element-parse-buffer))
             (table (org-element-map ast 'table #'identity nil t))
             (bold
              (cadr (caar (org-element-property :caption table)))))
        (org-element-put-property
         table
         :texmacs-affiliated-keywords '("CAPTION"))
        (setq
         input
         (org-texmacs-input-create
          ast
          nil
          :post-blanks (list (cons bold " ")))
         expected (org-texmacs-document-body (org-texmacs-document input)))
        (org-element-set-contents bold "Changed")
        (org-element-put-property table :caption nil)
        (should
         (equal
          expected
          (org-texmacs-document-body (org-texmacs-document input))))))
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Owned caption requested a worker"))))
      (should
       (equal
        expected
        (org-texmacs-document-body (org-texmacs-document input)))))
    (let* ((table
            (org-element-map
             (org-texmacs-input-ast input) 'table #'identity nil t))
           (bold (cadr (caar (org-element-property :caption table)))))
      (should (eq (org-element-parent bold) table))
      (should (assq bold (org-texmacs-input-post-blanks input)))))
  (dolist (caption '(("unparsed") ((("Long") . "unparsed"))))
    (let* ((table (org-element-create 'table (list :caption caption)))
           (ast (org-element-create 'org-data nil table)))
      (should-error
       (org-texmacs-input-create ast nil)
       :type 'org-texmacs-document-error)))
  (let* ((bold (org-element-create 'bold nil "Shared"))
         (table
          (org-element-create
           'table
           (list :caption (list (cons (list bold) (list bold))))))
         (ast (org-element-create 'org-data nil table)))
    (should-error
     (org-texmacs-input-create ast nil)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-pure-input-ignores-id-database ()
  (let* ((directory (make-temp-file "org-texmacs-pure-id-" t))
         (file (expand-file-name "target.org" directory)))
    (with-temp-file file
      (insert
       ":PROPERTIES:\n:ID: ambient-id\n:END:\n#+TITLE: Target\n"))
    (unwind-protect
        (let ((org-id-locations
               (org-id-alist-to-hash
                (list
                 (list
                  (abbreviate-file-name (file-truename file))
                  "ambient-id"))))
              (org-id-locations-file
               (expand-file-name "ids" directory))
              (org-id-files (list file))
              (org-id-track-globally nil))
          (with-temp-buffer
            (org-mode)
            (insert
             "#+OPTIONS: toc:nil\n[[id:ambient-id][Ambient]].\n")
            ;; Even a registered ambient ID stays a text-only fallback in
            ;; independent input.  Neither preparation nor lowering may query
            ;; the live ID database.
            (cl-letf (((symbol-function 'org-id-find)
                       (lambda (&rest _)
                         (ert-fail
                          "Pure input queried the ID database")))
                      ((symbol-function 'org-id-find-id-file)
                       (lambda (&rest _)
                         (ert-fail
                          "Pure input queried the ID database")))
                      ((symbol-function 'org-export-resolve-id-link)
                       (lambda (&rest _)
                         (ert-fail
                          "Pure input queried Org ID resolution"))))
              (let* ((document
                      (org-texmacs-document
                       (org-texmacs-test--input-from-model
                        (org-texmacs-parse-buffer (current-buffer)))))
                     (body (org-texmacs-document-body document)))
                (should-not (memq 'hlink (flatten-tree body)))
                (should-not (memq 'reference (flatten-tree body)))
                (should-not
                 (org-texmacs-document-file-paths document))
                (should
                 (equal
                  (string-trim
                   (apply #'concat
                          (cl-remove-if-not
                           #'stringp (flatten-tree body))))
                  "Ambient."))))))
      (delete-directory directory t))))

(ert-deftest org-texmacs-document-validates-frozen-external-id-mapping
    ()
  (let* ((id
          (org-element-create
           'link '(:type "id" :path "external-id")))
         (uri
          (org-element-create
           'link '(:type "https" :path "//example.org")))
         (detached
          (org-element-create 'link '(:type "id" :path "detached")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil id " " uri)))
         (valid (cons id "target.org")))
    (cl-labels
     ((lower
       (entries &optional targets)
       (org-texmacs-document
        (org-texmacs-input-create
         ast
         (list
          :texmacs-org-query
          (list :external-files entries :targets targets))
         :resource-base "/tmp/"))))
     (should (org-texmacs-document-p (lower (list valid))))
     (dolist (entries
              (list
               (list valid valid)
               (list (cons id nil))
               (list (cons id ""))
               (list valid (cons uri "other.org"))
               (list valid (cons detached "other.org"))))
       (should-error
        (lower entries)
        :type 'org-texmacs-document-error))
     (should-error
      (lower (list valid) (list (cons id id)))
      :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-validates-frozen-unavailable-links
    ()
  (let* ((link
          (org-element-create
           'link
           '(:type "id" :path "missing" :raw-link "id:missing")))
         (uri
          (org-element-create
           'link '(:type "https" :path "//example.org")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil link " " uri))))
    (cl-labels
     ((lower
       (query)
       (org-texmacs-document
        (org-texmacs-input-create
         ast
         (list :texmacs-org-query query)
         :resource-base "/tmp/"))))
     (let ((document (lower (list :unavailable-links (list link)))))
       (should
        (member
         "id:missing"
         (flatten-tree (org-texmacs-document-body document))))
       (should-not (org-texmacs-document-file-paths document)))
     (dolist (query
              (list
               '(:targets nil)
               (list :unavailable-links (list link link))
               (list :unavailable-links (list uri))
               (list
                :unavailable-links (list link)
                :external-files (list (cons link "other.org")))
               (list
                :unavailable-links (list link)
                :targets (list (cons link ast)))
               (list :targets (list (cons link nil)))))
       (should-error
        (lower query)
        :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-typed-reference-independent-input ()
  (let* ((target
          (org-element-create
           'special-block
           '(:type "theorem" :name "definition:object")
           (org-element-create 'paragraph nil "Statement.")))
         (link
          (org-element-create
           'link '(:type "fuzzy" :path "definition:object")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil link) target))
         (org-texmacs-typed-references t)
         (plain (org-texmacs-input-create ast nil))
         (typed
          (org-texmacs-input-create
           ast '(:texmacs-typed-references t)))
         (advice (lambda (_type) 'custom-theorem-ref))
         advised)
    ;; Independent construction never reads ambient Custom policy.  The
    ;; deliberately misleading NAME must not determine the reference type.
    (should
     (memq
      'reference
      (flatten-tree
       (org-texmacs-document-body (org-texmacs-document plain)))))
    (unwind-protect
        (progn
          (advice-add
           'org-texmacs--document-reference-tag
           :override advice)
          (setq advised
                (org-texmacs-input-create
                 ast '(:texmacs-typed-references t)))
          (should
           (memq
            'theorem-ref
            (flatten-tree
             (org-texmacs-document-body
              (org-texmacs-document typed))))))
      (advice-remove 'org-texmacs--document-reference-tag advice))
    (let* ((org-texmacs-typed-references nil)
           (document (org-texmacs-document advised))
           (body (org-texmacs-document-body document))
           (id
            (cdar
             (org-texmacs-resolution-labels
              (org-texmacs-input-resolution advised)))))
      (should
       (equal
        (org-texmacs-test--caption-inline-footnote-nodes
         body 'custom-theorem-ref)
        (list (list 'custom-theorem-ref id))))
      (should (equal document (org-texmacs-document advised)))
      (should
       (equal (org-texmacs-document-style document) '("generic"))))
    (should-error
     (org-texmacs-input-create ast '(:texmacs-typed-references yes))
     :type 'org-texmacs-document-error)
    (dolist (bad '(nil t "theorem-ref" (theorem-ref) :theorem-ref))
      (should-error
       (org-texmacs-document
        (org-texmacs-input-create
         ast
         (list
          :texmacs-typed-references t
          :texmacs-reference-tag-function
          (lambda (_type) bad))))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-typed-reference-headline-policies ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: H:5 toc:nil num:2 title:nil author:nil date:nil\n"
     "[[#one]] [[#two]] [[#three]] [[#four]] [[#five]] [[#six]] [[#star]] [[spot]]\n\n"
     "<<spot>>\n\n")
    (cl-loop
     for
     name
     in
     '("one" "two" "three" "four" "five" "six")
     for
     level
     from
     1
     do
     (insert
      (make-string level ?*)
      " "
      name
      "\n:PROPERTIES:\n"
      ":CUSTOM_ID: "
      name
      "\n:END:\n"))
    (insert
     "* Unnumbered\n:PROPERTIES:\n:CUSTOM_ID: star\n:UNNUMBERED: t\n:END:\n")
    (let* ((org-texmacs-typed-references t)
           (input (org-texmacs-prepare-buffer (current-buffer)))
           (body
            (org-texmacs-document-body (org-texmacs-document input)))
           (links
            (org-texmacs-resolution-links
             (org-texmacs-input-resolution input))))
      (should (= (length links) 8))
      (dolist (entry links)
        (let* ((path (org-element-property :path (car entry)))
               (tag
                (if (member path '("one" "two"))
                    'section-ref
                  'reference)))
          (should
           (member
            (list tag (cdr entry))
            (org-texmacs-test--caption-inline-footnote-nodes
             body tag))))))
    ;; The same structures at the maximum numbered sectioning depth.
    (goto-char (point-min))
    (search-forward "num:2")
    (replace-match "num:t" t t)
    (let* ((org-texmacs-typed-references t)
           (input (org-texmacs-prepare-buffer (current-buffer)))
           (body
            (org-texmacs-document-body (org-texmacs-document input)))
           (links
            (org-texmacs-resolution-links
             (org-texmacs-input-resolution input))))
      (should (= (length links) 8))
      (dolist (entry links)
        (let* ((path (org-element-property :path (car entry)))
               (tag
                (if (member path '("one" "two" "three" "four" "five"))
                    'section-ref
                  'reference)))
          (should
           (member
            (list tag (cdr entry))
            (org-texmacs-test--caption-inline-footnote-nodes
             body tag))))))))

(ert-deftest org-texmacs-document-typed-reference-standard-snapshot ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "[[Object]] [[Object][Explicit]]\n\n"
     (org-texmacs-test--stage4-block "theorem" "Object"))
    (let* ((org-texmacs-typed-references t)
           (org-texmacs-document-style '("article"))
           (input (org-texmacs-prepare-buffer (current-buffer)))
           (document (org-texmacs-document input))
           (advice (lambda (_type) 'reference))
           advised)
      (unwind-protect
          (progn
            (advice-add
             'org-texmacs--document-reference-tag
             :override advice)
            (setq advised
                  (org-texmacs-prepare-buffer (current-buffer)))
            (should (equal document (org-texmacs-document input))))
        (advice-remove 'org-texmacs--document-reference-tag advice))
      (setq org-texmacs-typed-references nil)
      (should (equal document (org-texmacs-document input)))
      (should
       (equal (org-texmacs-document-style document) '("article")))
      (should
       (equal
        (org-texmacs-document-style
         (org-texmacs-document advised))
        '("article")))
      (dolist (candidate
               (list
                advised
                (org-texmacs-prepare-buffer (current-buffer))))
        (let ((body
               (org-texmacs-test--stable-reference-body
                (org-texmacs-document candidate))))
          (should (memq 'reference (flatten-tree body)))
          (should-not (memq 'theorem-ref (flatten-tree body)))
          (should (memq 'hlink (flatten-tree body)))))
      (should
       (memq
        'theorem-ref
        (flatten-tree (org-texmacs-document-body document)))))))

(ert-deftest org-texmacs-document-settings-buffer-snapshot ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "$(math \"x\")$\n")
    (let ((org-export-default-language "en")
          (org-texmacs-document-style '("article"))
          (org-texmacs-document-initial '(("par-first" . "2fn")))
          (reader (symbol-function 'org-texmacs--stm-read))
          (calls 0))
      (cl-letf
          (((symbol-function 'org-texmacs--stm-read)
            (lambda (source)
              (cl-incf calls)
              (setq-local
               org-export-default-language "fr"
               org-texmacs-document-style '("generic")
               org-texmacs-document-initial '(("par-first" tuple "中" "<alpha>")))
              (funcall reader source))))
        (let ((first
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal (org-texmacs-document-style first) '("article")))
          (should
           (equal
            (org-texmacs-document-initial first)
            '(("language" . "english") ("par-first" . "2fn"))))))
      (should (= calls 1))
      (setq
       org-export-default-language "fr"
       org-texmacs-document-style '("generic")
       org-texmacs-document-initial '(("par-first" tuple "中" "<alpha>")))
      (let ((second
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal (org-texmacs-document-style second) '("generic")))
        (should
         (equal
          (org-texmacs-document-initial second)
          '(("language" . "french")
            ("par-first" tuple "中" "<alpha>"))))))))

(ert-deftest org-texmacs-document-date-timestamp-raw-text ()
  :tags
  '(issue4-closure)
  (dolist (raw
           '("<2026-10-14>"
             "[2026-10-14 Wed]"
             "<2026-10-14 Wed 15:30 +0800>"
             "<2026-10-14  15:30  +0800>"
             "<2026-10-14 Wed 15:30-16:00>"
             "<2026-10-14 Wed>--<2026-10-15 Thu>"
             "[2026-10-14 Wed]--[2026-10-15 Thu]"
             "<2026-10-14 Wed +1w>"
             "<2026-10-14 Wed .+1m/2m>"
             "<2026-10-14 Wed -3d>"
             "<%%(diary-anniversary 10 14 2000)>"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "#+DATE: " raw "\nBody\n")
      (let* ((state
              (org-texmacs-test--document-buffer-state
               (current-buffer)))
             (input (org-texmacs-prepare-buffer (current-buffer)))
             (date
              (car (plist-get (org-texmacs-input-info input) :date))))
        (should (eq (org-element-type date) 'timestamp))
        (should (equal (org-element-property :raw-value date) raw))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Pure date lowering started worker"))))
          (should
           (equal
            (org-texmacs-document-body (org-texmacs-document input))
            `(document (doc-data (doc-date ,raw)) (concat "Body ")))))
        (should
         (equal
          state
          (org-texmacs-test--document-buffer-state
           (current-buffer))))))))

(ert-deftest org-texmacs-document-date-precedence-and-suppression ()
  :tags
  '(issue4-closure)
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "Body\n")
    (let ((raw "<2026-10-14 Wed 15:30 +0800>"))
      (should
       (equal
        (cadr
         (org-texmacs-document-body
          (org-texmacs-document-from-buffer
           (current-buffer) nil nil nil (list :date raw))))
        `(doc-data (doc-date ,raw))))
      (insert "#+DATE: *Release* " raw " =literal=\n")
      (let ((body
             (org-texmacs-document-body
              (org-texmacs-document-from-buffer
               (current-buffer) nil nil nil '(:date "External")))))
        (should
         (equal
          (cadr body)
          `(doc-data
            (doc-date
             (concat
              (strong "Release")
              " "
              ,raw
              " "
              (verbatim "literal")))))))
      (dolist (options '((:with-date nil) (:date nil :with-date nil)))
        (should-not
         (memq
          'doc-data
          (flatten-tree
           (org-texmacs-document-body
            (org-texmacs-document-from-buffer
             (current-buffer) nil nil nil options))))))
      (insert
       "* Chosen\n:PROPERTIES:\n:EXPORT_DATE: [2026-10-15 Thu]\n:END:\n")
      (search-backward "* Chosen")
      (should
       (equal
        (cadr
         (org-texmacs-document-body
          (org-texmacs-document-from-buffer
           (current-buffer) nil (point) nil '(:date "External"))))
        '(doc-data
          (doc-title "Chosen") (doc-date "[2026-10-15 Thu]"))))))
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "Body\n")
    (should-not
     (memq
      'doc-data
      (flatten-tree
       (org-texmacs-document-body
        (org-texmacs-document-from-buffer (current-buffer))))))))

(ert-deftest org-texmacs-document-date-malformed-and-context ()
  :tags
  '(issue4-closure)
  (dolist (value '(nil "" 42))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "#+DATE: <2026-10-14>\n")
      (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
             (date
              (car (plist-get (org-texmacs-input-info input) :date))))
        (org-element-put-property date :raw-value value)
        (should-error
         (org-texmacs-document input)
         :type 'org-texmacs-document-error))))
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "#+DATE: <2026-10-14>\n")
    (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
           (date
            (car (plist-get (org-texmacs-input-info input) :date))))
      (org-element-set-contents date "unexpected")
      (should-error
       (org-texmacs-document input)
       :type 'org-texmacs-document-error)))
  (dolist (source '("<2026-10-14>\n" "#+TITLE: <2026-10-14>\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-date-advice-snapshot-and-ownership
    ()
  :tags
  '(issue4-closure)
  (let ((raw "<2026-10-14 Wed 15:30 +0800>")
        result
        input)
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "#+DATE: " raw "\n")
      (let ((advice
             (lambda (text)
               (aset text 0 ?X)
               (setq result text))))
        (unwind-protect
            (progn
              (advice-add
               'org-texmacs--document-date-timestamp-text
               :override advice)
              (setq input
                    (org-texmacs-prepare-buffer (current-buffer))))
          (advice-remove
           'org-texmacs--document-date-timestamp-text advice)))
      (let* ((date
              (car (plist-get (org-texmacs-input-info input) :date)))
             (document (org-texmacs-document input)))
        (should (equal (org-element-property :raw-value date) raw))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (doc-data (doc-date "X2026-10-14 Wed 15:30 +0800>")))))
        (aset result 1 ?Y)
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (doc-data (doc-date "X2026-10-14 Wed 15:30 +0800>")))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          `(document (doc-data (doc-date ,raw)))))))
    ;; Pure construction also fixes the function, without buffer preparation.
    (let ((advice (lambda (_text) "PureDate")))
      (unwind-protect
          (progn
            (advice-add
             'org-texmacs--document-date-timestamp-text
             :override advice)
            (setq input
                  (org-texmacs-input-create
                   (org-element-create 'org-data nil)
                   (list
                    :date
                    (list
                     (org-element-create
                      'timestamp (list :raw-value raw)))))))
        (advice-remove
         'org-texmacs--document-date-timestamp-text advice))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document input))
        '(document (doc-data (doc-date "PureDate"))))))))

(ert-deftest org-texmacs-document-date-advice-result-and-error ()
  :tags
  '(issue4-closure)
  (dolist (value '(42 nil (strong "bad")))
    (let ((advice (lambda (_raw) value)))
      (unwind-protect
          (progn
            (advice-add
             'org-texmacs--document-date-timestamp-text
             :override advice)
            (with-temp-buffer
              (org-mode)
              (setq-local org-export-with-author nil)
              (insert "#+DATE: <2026-10-14>\n")
              (should-error
               (org-texmacs-document-from-buffer (current-buffer))
               :type 'org-texmacs-document-error)))
        (advice-remove
         'org-texmacs--document-date-timestamp-text advice))))
  (let ((advice (lambda (_raw) "")))
    (unwind-protect
        (progn
          (advice-add
           'org-texmacs--document-date-timestamp-text
           :override advice)
          (with-temp-buffer
            (org-mode)
            (setq-local org-export-with-author nil)
            (insert "#+DATE: <2026-10-14>\n")
            (should
             (equal
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              '(document (doc-data (doc-date "")))))))
      (advice-remove
       'org-texmacs--document-date-timestamp-text advice)))
  (let ((advice (lambda (_raw) (error "DateAdviceFailure"))))
    (unwind-protect
        (progn
          (advice-add
           'org-texmacs--document-date-timestamp-text
           :override advice)
          (with-temp-buffer
            (org-mode)
            (setq-local org-export-with-author nil)
            (insert "#+DATE: <2026-10-14>\n")
            (let ((state
                   (org-texmacs-test--document-buffer-state
                    (current-buffer))))
              (should-error
               (org-texmacs-document-from-buffer (current-buffer)))
              (should
               (equal
                state
                (org-texmacs-test--document-buffer-state
                 (current-buffer)))))))
      (advice-remove
       'org-texmacs--document-date-timestamp-text advice))))

(ert-deftest org-texmacs-document-date-stm-snapshot ()
  :tags
  '(issue4-closure)
  (let ((advice (lambda (_raw) "ChangedDate")))
    (unwind-protect
        (with-temp-buffer
          (org-mode)
          (setq-local org-export-with-author nil)
          (insert "#+DATE: <2026-10-14>\n$(math \"x\")$\n")
          (cl-letf (((symbol-function 'org-texmacs--stm-read)
                     (lambda (&rest _)
                       (advice-add
                        'org-texmacs--document-date-timestamp-text
                        :override advice)
                       '(math "x"))))
            (should
             (equal
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              '(document
                (doc-data (doc-date "<2026-10-14>")) (math "x"))))
            (should
             (equal
              (cadr
               (org-texmacs-document-body
                (org-texmacs-document-from-buffer (current-buffer))))
              '(doc-data (doc-date "ChangedDate"))))))
      (advice-remove
       'org-texmacs--document-date-timestamp-text advice))))

(ert-deftest
    org-texmacs-document-issue11-container-structure-and-paths
    ()
  :tags
  '(issue11)
  (org-texmacs-test--with-environment
   (dolist (context '(body quote center footnote list))
     (dolist (tree org-texmacs-test--fragment-strees)
       (let ((text (prin1-to-string tree))
             documents)
         (dolist (payload
                  (list
                   (concat "$" text "$ \t\n")
                   (concat
                    "#+begin_texmacs\n" text "\n#+end_texmacs\n")))
           (with-temp-buffer
             (org-mode)
             (setq-local org-export-with-author nil)
             (insert
              (org-texmacs-test--issue11-source context payload))
             (let ((before
                    (org-texmacs-test--document-buffer-state
                     (current-buffer))))
               (push (org-texmacs-document-from-buffer
                      (current-buffer))
                     documents)
               (should
                (equal
                 before
                 (org-texmacs-test--document-buffer-state
                  (current-buffer)))))))
         (should
          (equal
           (org-texmacs-document-body (car documents))
           (org-texmacs-document-body (cadr documents))))
         (should
          (equal
           (org-texmacs-document-stm-paths (car documents))
           (org-texmacs-document-stm-paths (cadr documents)))))))
   (dolist (prefix '("- " "1. " "- Term :: "))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert prefix "$(math \"x\")$\n")
       (let ((body
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))))
         (should (memq 'concat (flatten-tree body)))
         (should
          (memq
           (if (string-match-p "Term" prefix)
               'item*
             'item)
           (flatten-tree body)))))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert prefix "$(equation \"x\")$\n")
       (should-error
        (org-texmacs-document-from-buffer (current-buffer))
        :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-basic-inline-source ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\n* /Title/\nA /i/ _u_ +s+ ~code~ =literal=.\n")
    (let ((source (buffer-string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Ordinary inline started a worker"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section (em "Title"))
            (concat
             "A "
             (em "i")
             " "
             (underline "u")
             " "
             (strike-through "s")
             " "
             (verbatim "code")
             " "
             (verbatim "literal")
             ". ")))))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-line-break-contexts ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "#+OPTIONS: toc:nil\n* Title\nA\\\\\nB\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section "Title") (concat "A" (next-line) "B ")))))
  (let* ((break (org-element-create 'line-break nil))
         (italic (org-element-create 'italic nil "title" break))
         (headline
          (org-element-create
           'headline
           (list :level 1 :raw-value "title" :title (list italic))))
         (ast (org-element-create 'org-data nil headline)))
    (should-error
     (org-texmacs-test--lower ast)
     :type 'org-texmacs-document-error))
  (let* ((break (org-element-create 'line-break nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil "a " break " \tb"))))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-test--lower ast))
      '(document (concat "a " (next-line) "b"))))))

(ert-deftest org-texmacs-document-uri-source-forms ()
  (org-texmacs-test--with-registered-ftps
   (lambda ()
     (dolist (type '("http" "https" "mailto" "ftp" "ftps"))
       (let ((uri
              (concat
               type ":"
               (if (equal type "mailto")
                   "user@example.org"
                 "//example.org/a%20b?q=x%26y&n=2"))))
         (dolist (source
                  (list
                   (concat "[[" uri "]]\n")
                   (concat "<" uri ">\n")
                   (concat uri "\n")
                   (concat "[[" uri "][Label]]\n")))
           (with-temp-buffer
             (org-mode)
             (setq-local org-export-with-author nil)
             (insert source)
             (cl-letf (((symbol-function 'org-texmacs--worker-request)
                        (lambda (&rest _)
                          (ert-fail "URI parsing started worker"))))
               (should
                (equal
                 (org-texmacs-document-body
                  (org-texmacs-document-from-buffer (current-buffer)))
                 (list
                  'document
                  (list
                   'concat
                   (list
                    'hlink
                    (if (equal source (concat "[[" uri "][Label]]\n"))
                        "Label"
                      uri)
                    uri)
                   " ")))))
             (should (equal source (buffer-string))))))))))

(ert-deftest org-texmacs-document-uri-rich-description ()
  (org-texmacs-test--with-registered-ftps
   (lambda ()
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert
        "#+OPTIONS: toc:nil\n* [[https://example.org][Title]]\n"
        "A [[ftps://example.org/中%20文?q=x%26y&z=2][*bold* /em/]]\t end\n")
       (should
        (equal
         (org-texmacs-document-body
          (org-texmacs-document-from-buffer (current-buffer)))
         '(document
           (section (hlink "Title" "https://example.org"))
           (concat
            "A "
            (hlink
             (concat (strong "bold") " " (em "em"))
             "ftps://example.org/中%20文?q=x%26y&z=2")
            " " "end "))))))))

(ert-deftest org-texmacs-document-resolves-local-headline-links ()
  (let (prepared)
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert
       "#+OPTIONS: toc:nil\n* Alpha\n:PROPERTIES:\n:CUSTOM_ID: local\n:ID: local-id\n:END:\n"
       "See [[#local][custom]], [[id:local-id][id]], [[*Alpha][heading]], "
       "[[Alpha][fuzzy]], and [[#local]].\n")
      (let ((source (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Local links started a worker"))))
          (setq prepared
                (org-texmacs-prepare-buffer (current-buffer))))
        (should (equal source (buffer-string)))))
    (should
     (equal
      (org-texmacs-test--stable-reference-body
       (org-texmacs-document prepared))
      '(document
        (section "Alpha") (label "org-texmacs-ref-1")
        (concat
         "See "
         (hlink "custom" "#org-texmacs-ref-1")
         ", "
         (hlink "id" "#org-texmacs-ref-1")
         ", "
         (hlink "heading" "#org-texmacs-ref-1")
         ", "
         (hlink "fuzzy" "#org-texmacs-ref-1")
         ", and "
         (reference "org-texmacs-ref-1")
         ". "))))))

(ert-deftest org-texmacs-document-resolves-dedicated-target ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\nSee [[spot][there]].\nHere <<spot>> later.\n")
    (let* ((body
            (org-texmacs-test--stable-reference-body
             (org-texmacs-document-from-buffer (current-buffer))))
           (paragraph (cadr body))
           (link '(hlink "there" "#org-texmacs-ref-1"))
           (target '(label "org-texmacs-ref-1")))
      (should (= (length body) 2))
      (should (eq (car paragraph) 'concat))
      (should (member link paragraph))
      (should (member target paragraph))
      (should
       (< (cl-position link paragraph :test #'equal)
          (cl-position target paragraph :test #'equal))))))

(ert-deftest org-texmacs-document-ambiguous-and-unresolved-id-fallback
    ()
  (dolist (case
           '(("#+OPTIONS: toc:nil\n* Alpha\n* Alpha\n[[*Alpha]]\n"
              .
              "*Alpha")
             ("#+OPTIONS: toc:nil\n[[id:external-id]]\n"
              .
              "id:external-id")
             ("#+OPTIONS: toc:nil\n* Visible\n[[#gone]]\n"
              .
              "#gone")))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert (car case))
      (let* ((before (buffer-string))
             (document
              (org-texmacs-document
               (org-texmacs-test--input-from-model
                (org-texmacs-parse-buffer (current-buffer)))))
             (body (org-texmacs-document-body document)))
        (should (member (cdr case) (flatten-tree body)))
        (should-not (memq 'reference (flatten-tree body)))
        (should-not (memq 'hlink (flatten-tree body)))
        (should-not (org-texmacs-document-file-paths document))
        (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-document-excluded-custom-id-fallback ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+EXCLUDE_TAGS: hidden\n"
     "* Hidden :hidden:\n:PROPERTIES:\n:CUSTOM_ID: gone\n:END:\n"
     "* Visible\n[[#gone]]\n")
    (let* ((source (buffer-string))
           (document
            (org-texmacs-document-from-buffer (current-buffer)))
           (body (flatten-tree (org-texmacs-document-body document))))
      (should (member "Visible" body))
      (should-not (member "Hidden" body))
      (should (member "#gone" body))
      (should-not (memq 'reference body))
      (should-not (memq 'hlink body))
      (should-not (org-texmacs-document-file-paths document))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-unavailable-reference-with-island ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "[[missing-target][missing]]\n"
     "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
    (let* ((document
            (org-texmacs-document-from-buffer (current-buffer)))
           (body (org-texmacs-document-body document)))
      (should (member "missing" (flatten-tree body)))
      (should-not (memq 'hlink (flatten-tree body)))
      (should (org-texmacs-document-stm-paths document)))))

(ert-deftest
    org-texmacs-document-reference-low-headline-and-target-priority
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: H:1 toc:nil\n* Top\n** spot\n"
     "[[spot][there]] <<spot>>\n[[*spot][heading]]\n")
    (let* ((body
            (org-texmacs-test--stable-reference-body
             (org-texmacs-document-from-buffer (current-buffer))))
           (items (cadr (nth 2 body)))
           (paragraph (nth 3 items)))
      (should (equal (nth 1 items) '(concat (item) "spot")))
      (should (equal (nth 2 items) '(label "org-texmacs-ref-1")))
      (should
       (member '(hlink "there" "#org-texmacs-ref-2") paragraph))
      (should (member '(label "org-texmacs-ref-2") paragraph))
      (should
       (member '(hlink "heading" "#org-texmacs-ref-1") paragraph)))))

(ert-deftest org-texmacs-document-uri-private-syntax-restoration ()
  (org-texmacs-test--with-registered-ftps
   (lambda ()
     (dolist (suffix
              '("" "\n[[file:unsupported.org::#target][link]]\n"))
       (with-temp-buffer
         (org-mode)
         (setq-local org-export-with-author nil)
         (insert "[[ftps://example.org][(math \"hidden\")]]" suffix)
         (let* ((variables
                 '(org-link-parameters
                   org-link-types-re
                   org-link-angle-re
                   org-link-plain-re
                   org-link-bracket-re
                   org-link-any-re
                   org-element--object-regexp
                   org-element-paragraph-separate))
                (before
                 (mapcar
                  (lambda (var)
                    (org-texmacs--document-copy-link-setting
                     (symbol-value var)))
                  variables))
                (source (buffer-string))
                (reset (symbol-function 'org-element-cache-reset)))
           (cl-letf (((symbol-function 'org-element-cache-reset)
                      (lambda (&rest args)
                        (when (eq (car args) 'all)
                          (ert-fail "Global cache reset"))
                        (apply reset args)))
                     ((symbol-function 'org-texmacs--stm-read)
                      (lambda (&rest _)
                        (ert-fail
                         "Link description scanned as STM"))))
             (if (equal suffix "")
                 (should
                  (equal
                   (org-texmacs-document-body
                    (org-texmacs-document-from-buffer
                     (current-buffer)))
                   '(document
                     (concat
                      (hlink
                       "(math \"hidden\")" "ftps://example.org")))))
               (let ((body
                      (org-texmacs-document-body
                       (org-texmacs-document-from-buffer
                        (current-buffer)))))
                 (should (member "link" (flatten-tree body)))
                 (should
                  (member
                   "ftps://example.org" (flatten-tree body))))))
           (should (equal before (mapcar #'symbol-value variables)))
           (should (equal source (buffer-string)))))))))

(ert-deftest org-texmacs-document-uri-abbreviation-and-stale-settings
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq-local org-link-abbrev-alist
                '(("short" . "https://example.org/%s")))
    (insert "[[short:page][Page]]\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (concat (hlink "Page" "https://example.org/page") " "))))
    (insert "$(math \"x\")$\n")
    (let ((reader (symbol-function 'org-texmacs--stm-read))
          (calls 0))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (cl-incf calls)
                   (setq-local org-link-abbrev-alist nil)
                   (funcall reader source))))
        (should
         (member
          "https://example.org/page"
          (flatten-tree
           (org-texmacs-document-body
            (org-texmacs-document-from-buffer (current-buffer)))))))
      (should (= calls 1)))))

(ert-deftest org-texmacs-document-footnote-source ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "A[fn::one][fn::two] end\n")
    (let ((source (buffer-string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Ordinary footnote started worker"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (concat
             "A"
             (footnote (document (concat "one")))
             (footnote (document (concat "two"))) " " "end ")))))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-footnote-rejects-contexts ()
  (dolist (context '(title bold link footnote))
    (let* ((note
            (org-element-create
             'footnote-reference '(:type inline) "note"))
           (container
            (pcase context
              ('title
               (org-element-create
                'headline
                (list
                 :level 1
                 :raw-value "title"
                 :title (list note))))
              ('bold
               (org-element-create
                'paragraph nil (org-element-create 'bold nil note)))
              ('link
               (org-element-create
                'paragraph nil
                (org-element-create
                 'link '(:type "https" :path "//example.org") note)))
              ('footnote
               (org-element-create
                'paragraph nil
                (org-element-create
                 'footnote-reference '(:type inline) note)))))
           (ast (org-element-create 'org-data nil container)))
      (should-error
       (org-texmacs-test--lower ast)
       :type 'org-texmacs-document-error)))
  (dolist (source
           '("A[fn:name]\n"
             "A[fn:name:outer [fn::inner]]\n"
             "* Title[fn::note]\n"
             "[fn::outer [fn::inner]]\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type
       (if (equal source "A[fn:name]\n")
           'user-error
         'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-named-footnote-first-and-repeated ()
  (dolist (source
           '("A[fn:n] again[fn:n].\n\n[fn:n] *Body*.\n"
             "A[fn:n:*Body*.] again[fn:n].\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Ordinary named footnote started worker"))))
        (let ((body
               (org-texmacs-document-body
                (org-texmacs-document-from-buffer (current-buffer)))))
          (should
           (equal
            (nth 2 (cadr body))
            `(footnote
              (surround
               (label "org-texmacs-fn-1") ""
               (document
                (concat
                 (strong "Body")
                 ,(if (string-prefix-p "A[fn:n]" source)
                      ". "
                    ".")))))))
          (should
           (equal
            (nth 5 (cadr body))
            '(rsup
              (with
               "font-shape" "right"
               (reference "org-texmacs-fn-1")))))))
      (should (equal source (buffer-string))))))

(ert-deftest
    org-texmacs-document-named-footnote-forward-inline-definition
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "A[fn:n] then[fn:n:Body].\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (concat
         "A"
         (footnote
          (surround
           (label "org-texmacs-fn-1") "" (document (concat "Body"))))
         " " "then"
         (rsup
          (with "font-shape" "right" (reference "org-texmacs-fn-1")))
         ". "))))))

(ert-deftest org-texmacs-document-named-footnote-pruned-definitions ()
  (dolist (definition
           '("[fn:n] Preserved body.\n"
             "Hidden[fn:n:Preserved body. ]\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert
       "#+OPTIONS: toc:nil tags:nil\n#+SELECT_TAGS: keep\n* Hidden\n"
       definition
       "* Visible :keep:\nA[fn:n].\n")
      (progn
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section "Visible")
            (concat
             "A"
             (footnote
              (surround
               (label "org-texmacs-fn-1")
               ""
               (document (concat "Preserved body. "))))
             ". "))))))))

(ert-deftest org-texmacs-document-named-footnote-section-setting ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq-local org-footnote-section "Notes")
    (insert "A[fn:n].\n* Notes\n[fn:n] Note.\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (concat
         "A"
         (footnote
          (surround
           (label "org-texmacs-fn-1")
           ""
           (document (concat "Note. "))))
         ". "))))
    (erase-buffer)
    (insert "A[fn:n].\n\n[fn:n] $(math \"x\")$\n")
    (let ((reader (symbol-function 'org-texmacs--stm-read))
          (calls 0))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (cl-incf calls)
                   (setq-local org-footnote-section "Changed")
                   (funcall reader source))))
        (should
         (memq
          'footnote
          (flatten-tree
           (org-texmacs-document-body
            (org-texmacs-document-from-buffer (current-buffer)))))))
      (should (= calls 1)))))

(ert-deftest org-texmacs-document-named-footnote-unused-and-invalid ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "Visible.\n\n[fn:unused] $(math \"unused\")$ [[unknown:bad]]\n")
    (cl-letf (((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _)
                 (ert-fail
                  "Unused definition reached the STM reader"))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document (concat "Visible. "))))))
  (dolist (source
           '("A[fn:missing]. $(math \"x\")$\n"
             "A[fn:n].\n\n[fn:n] One.\n\n[fn:n] Two.\n"
             "A[fn:n].\n\n[fn:n] Nested[fn:m].\n\n[fn:m] Body.\n"
             "A[fn:n:One] B[fn:n:Two]\n"
             "A[fn:n].\n\n[fn:n] Recursive[fn:n].\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (should-error
       (org-texmacs-document
        (org-texmacs-test--input-from-model
         (org-texmacs-parse-buffer (current-buffer))))
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-document-named-footnote-owned-body-and-provenance
    ()
  (let (input
        requests)
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert
       "A[fn:n] repeat[fn:n].\n\n[fn:n] [[file:note.txt][File]] $(math \"x\")$\n\nSecond.\n")
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (push source requests)
                   '(math "x"))))
        (setq input (org-texmacs-prepare-buffer (current-buffer)))))
    (should (equal requests '("(math \"x\")")))
    (cl-letf (((symbol-function 'org-footnote-get-definition)
               (lambda (&rest _)
                 (ert-fail "Owned input read buffer")))
              ((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _) (ert-fail "Owned input reread STM")))
              ((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Owned input started worker"))))
      (let* ((result (org-texmacs-document input))
             (body (org-texmacs-document-body result)))
        (should
         (equal
          (org-texmacs-document-stm-paths result) '((0 1 0 2 0 2))))
        (should
         (equal
          (org-texmacs-document-file-paths result)
          '((0 1 0 2 0 0 1))))
        (should
         (equal
          (nth 2 (cadr body))
          '(footnote
            (surround
             (label "org-texmacs-fn-1") ""
             (document
              (concat (hlink "File" "note.txt") " " (math "x") " ")
              (concat "Second. "))))))))))

(ert-deftest
    org-texmacs-document-named-footnote-blocks-and-local-targets
    ()
  (dolist (entry
           '(("#+begin_quote\nQuote.\n#+end_quote\n" . quotation)
             ("#+begin_center\nCenter.\n#+end_center\n" . center)
             ("- Item.\n" . itemize)
             ("#+begin_example\nCode.\n#+end_example\n" . code)
             ("| A | B |\n" . tabular)))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "A[fn:n].\n\n[fn:n] Body.\n\n" (car entry))
      (let* ((body
              (org-texmacs-test--stable-reference-body
               (org-texmacs-document-from-buffer (current-buffer))))
             (definition (nth 3 (cadr (nth 2 (cadr body))))))
        (should (eq (car (nth 2 definition)) (cdr entry))))))
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "A[fn:n] [[inside][Link]].\n\n[fn:n] <<inside>> Body.\n")
    (let ((body
           (org-texmacs-test--stable-reference-body
            (org-texmacs-document-from-buffer (current-buffer)))))
      (should
       (equal
        (nth 4 (cadr body)) '(hlink "Link" "#org-texmacs-ref-1")))
      (should
       (equal
        (cadr (cadr (nth 3 (cadr (nth 2 (cadr body))))))
        '(label "org-texmacs-ref-1"))))))

(ert-deftest org-texmacs-document-issue10-owned-forward-and-scoped ()
  :tags
  '(issue10)
  (dolist (scope '(full selected subtree region narrowed))
    (let (input
          requests
          raw-definitions)
      (with-temp-buffer
        (org-mode)
        (insert
         "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
         "* Hidden\nHidden[fn:n:Before $(math \"x\")$ [[file:note.txt][File]] $(math \"y\")$].\n"
         "Unused[fn:u:$(math \"unused\")$].\n"
         "* Visible :keep:\nA[fn:n] repeat[fn:n].\n")
        (setq-local default-directory "/base/")
        (when (eq scope 'selected)
          (goto-char 1)
          (insert "#+SELECT_TAGS: keep\n"))
        (goto-char 1)
        (search-forward "* Visible")
        (beginning-of-line)
        (let ((begin (point))
              (end (point-max))
              (definition
               (symbol-function 'org-export-get-footnote-definition)))
          (when (eq scope 'narrowed)
            (narrow-to-region begin end))
          (let ((reader (symbol-function 'org-texmacs--stm-read)))
            (cl-letf (((symbol-function 'org-texmacs--stm-read)
                       (lambda (raw)
                         (push raw requests)
                         (funcall reader raw)))
                      ((symbol-function
                        'org-export-get-footnote-definition)
                       (lambda (reference info)
                         (let ((body
                                (funcall definition reference info)))
                           (push body raw-definitions)
                           body))))
              (let ((before
                     (org-texmacs-test--document-buffer-state
                      (current-buffer))))
                (setq input
                      (org-texmacs-prepare-buffer
                       (current-buffer)
                       nil
                       (and (eq scope 'subtree) begin)
                       (and (eq scope 'region) (cons begin end))))
                (should
                 (equal
                  before
                  (org-texmacs-test--document-buffer-state
                   (current-buffer)))))))))
      (let ((count
             (pcase scope
               ('full 3)
               ('selected 2)
               (_ 0))))
        (should (= (length requests) count))
        (should (= (length (org-texmacs-input-islands input)) count)))
      (if (memq scope '(subtree region narrowed))
          (should (member "" raw-definitions))
        (should-not (member "" raw-definitions)))
      ;; Source is dead.  Neither interpretation nor conversion may revisit it.
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (&rest _)
                   (ert-fail "Owned lowering reread STM")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Owned lowering requested worker")))
                ((symbol-function 'org-export-get-footnote-definition)
                 (lambda (&rest _)
                   (ert-fail "Owned lowering repeated Org query")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _)
                   (ert-fail "Owned lowering read source"))))
        (let* ((document (org-texmacs-document input))
               (body (org-texmacs-document-body document)))
          (should (equal document (org-texmacs-document input)))
          (should
           (= (cl-count 'footnote (flatten-tree body))
              (if (eq scope 'full)
                  2
                1)))
          (should (memq 'reference (flatten-tree body)))
          (should
           (= (length (org-texmacs-document-file-paths document))
              (if (memq scope '(full selected))
                  1
                0))))))))

(ert-deftest org-texmacs-document-footnote-stm-support ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "A[fn::$(math \"hidden\")$] $(math \"visible\")$\n")
    (let (requests)
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (push source requests)
                   (if (string-match-p "hidden" source)
                       '(math "hidden")
                     '(math "visible")))))
        (let ((result
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal
            (sort (copy-sequence requests) #'string<)
            '("(math \"hidden\")" "(math \"visible\")")))
          (should
           (equal
            (org-texmacs-document-body result)
            '(document
              (concat
               "A"
               (footnote (document (math "hidden")))
               " "
               (math "visible")
               " "))))
          (should
           (equal
            (org-texmacs-document-stm-paths result)
            '((0 1 0 0) (0 3)))))))))

(ert-deftest
    org-texmacs-document-relative-headlines-and-low-level-lists
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: H:2 num:1 toc:nil\n"
     "** Top\n"
     "*** Child\n"
     "**** Deep A\n"
     "**** Deep B\n"
     "***** Nested\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (section "Top") (subsection* "Child")
        (itemize
         (document
          (concat (item) "Deep A")
          (concat (item) "Deep B")
          (itemize (document (concat (item) "Nested"))))))))
    (erase-buffer)
    (insert "#+OPTIONS: H:0 toc:nil\n* First\n* Second\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (itemize
         (document
          (concat (item) "First") (concat (item) "Second"))))))))

(ert-deftest
    org-texmacs-document-five-section-levels-and-unnumbered-property
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: H:5 num:nil toc:nil\n"
     "* One\n** Two\n*** Three\n**** Four\n***** Five\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (section* "One")
        (subsection* "Two")
        (subsubsection* "Three")
        (paragraph* "Four")
        (subparagraph* "Five"))))
    (erase-buffer)
    (insert
     "* Visible title\n"
     ":PROPERTIES:\n"
     ":UNNUMBERED: notoc\n"
     ":ALT_TITLE: Short *title*\n"
     ":END:\n"
     "Body\n")
    (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
           (headline
            (car
             (org-element-contents (org-texmacs-input-ast input)))))
      (should
       (equal
        (org-texmacs-document-body (org-texmacs-document input))
        '(document (section* "Visible title") (concat "Body "))))
      (let ((alt (org-element-property :ALT_TITLE headline)))
        (should
         (equal (mapcar #'org-element-type alt) '(plain-text bold)))
        (dolist (object alt)
          (should
           (eq (org-element-property :parent object) headline)))))))

(ert-deftest org-texmacs-document-toc-structure-and-headline-policies
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: H:3 toc:2 num:1 tags:not-in-toc todo:nil\n"
     "* Visible :tag:\n"
     ":PROPERTIES:\n:ALT_TITLE: Short *title*\n:END:\n"
     "** Child\n"
     "*** Deep\n"
     "* Plain\n"
     ":PROPERTIES:\n:UNNUMBERED: t\n:END:\n"
     "* Hidden\n"
     ":PROPERTIES:\n:UNNUMBERED: notoc\n:END:\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (table-of-contents
         "org-texmacs-toc"
         (document
          (toc-1
           (hlink
            (concat "1 " (concat "Short " (strong "title")))
            "#org-texmacs-toc-1")
           (pageref "org-texmacs-toc-1"))
          (toc-2
           (hlink "Child" "#org-texmacs-toc-2")
           (pageref "org-texmacs-toc-2"))
          (toc-1
           (hlink "Plain" "#org-texmacs-toc-3")
           (pageref "org-texmacs-toc-3"))))
        (section (concat "Visible" " " ":tag:"))
        (label "org-texmacs-toc-1")
        (subsection* "Child")
        (label "org-texmacs-toc-2")
        (subsubsection* "Deep")
        (section* "Plain")
        (label "org-texmacs-toc-3")
        (section* "Hidden"))))))

(ert-deftest org-texmacs-document-toc-uses-filtered-context ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: tasks:done toc:2 todo:nil\n"
     "* TODO Dropped\n"
     "** Dropped child\n"
     "* DONE Kept\n"
     "** Child\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (table-of-contents
         "org-texmacs-toc"
         (document
          (toc-1
           (hlink (concat "1 " "Kept") "#org-texmacs-toc-1")
           (pageref "org-texmacs-toc-1"))
          (toc-2
           (hlink (concat "1.1 " "Child") "#org-texmacs-toc-2")
           (pageref "org-texmacs-toc-2"))))
        (section "Kept")
        (label "org-texmacs-toc-1")
        (subsection "Child")
        (label "org-texmacs-toc-2"))))))

(ert-deftest org-texmacs-document-rejects-headline-depth-over-five ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "#+OPTIONS: H:6\n* Heading\n")
    (should-error
     (org-texmacs-document-from-buffer (current-buffer))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-list-source-forms ()
  (dolist (case
           '(("- One\n- Two\n" (document
               (itemize
                (document
                 (concat (item) "One ") (concat (item) "Two ")))))
             ("1. First\n2. Second\n" (document
               (enumerate
                (document
                 (concat (item) "First ")
                 (concat (item) "Second ")))))
             ("- (math \"term\") :: Definition\n- Untagged\n"
              (document
               (description
                (document
                 (concat (item* "(math \"term\")") "Definition ")
                 (concat (item) "Untagged ")))))))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert (car case))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (&rest _)
                   (ert-fail
                    "Description term reached the STM reader"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          (cadr case)))))))

(ert-deftest org-texmacs-document-nested-list-island ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "- Outer\n  1. Inner $(math \"x\")$\n")
    (let ((reader (symbol-function 'org-texmacs--stm-read))
          sources)
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (push source sources)
                   (should (equal source "(math \"x\")"))
                   (funcall reader source))))
        (let ((document
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal
            (org-texmacs-document-body document)
            '(document
              (itemize
               (document
                (concat (item) "Outer ")
                (enumerate
                 (document
                  (concat (item) "Inner " (math "x") " "))))))))
          (should
           (equal
            (org-texmacs-document-stm-paths document)
            '((0 0 1 0 0 2))))))
      (should (= (length sources) 1)))))

(ert-deftest org-texmacs-document-quote-and-center-containers ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+begin_quote\nFirst $(math \"q\")$.\n\nSecond.\n#+end_quote\n"
     "#+begin_center\n- Centered item\n#+end_center\n")
    (let ((reader (symbol-function 'org-texmacs--stm-read))
          sources)
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (push source sources)
                   (should (equal source "(math \"q\")"))
                   (funcall reader source))))
        (let ((document
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal
            (org-texmacs-document-body document)
            '(document
              (quotation
               (document
                (concat "First " (math "q") ". ")
                (concat "Second. ")))
              (center
               (document
                (itemize
                 (document (concat (item) "Centered item "))))))))
          (should
           (equal
            (org-texmacs-document-stm-paths document) '((0 0 0 1))))))
      (should (= (length sources) 1)))))

(ert-deftest org-texmacs-document-quote-uniform-quotation ()
  :tags
  '(issue4)
  (dolist (contents
           '("Single.\n"
             "First.\n\nSecond.\n"
             "- Nested item\n"
             "#+begin_center\nNested.\n#+end_center\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n#+begin_quote\n"
       contents
       "#+end_quote\n")
      (let* ((before (buffer-string))
             (document
              (org-texmacs-document-from-buffer (current-buffer)))
             (container (cadr (org-texmacs-document-body document))))
        (should (eq (car container) 'quotation))
        (should (eq (caadr container) 'document))
        (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-document-rejects-list-checkbox-and-counter ()
  (dolist (source '("- [ ] Task\n" "1. [@3] Counted\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid list reached worker"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-preformatted-source-forms ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq-local tab-width 4)
    (insert
     "#+begin_example\n"
     "    a\tb\n"
     "      c  d\n"
     "\n"
     "    中¯˙ <alpha> (math \"hidden\")\n"
     "#+end_example\n\n"
     ": x\ty\n"
     ":  z  q\n\n"
     "#+begin_src emacs-lisp\n"
     "  ,* protected\n"
     "    (+ 1 2)\n"
     "\n"
     "  中文\t<alpha> (math \"hidden\")\n"
     "#+end_src\n\n"
     "#+begin_example\n#+end_example\n")
    (cl-letf (((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _)
                 (ert-fail
                  "Preformatted text reached the STM reader")))
              ((symbol-function 'org-export-unravel-code)
               (lambda (&rest _)
                 (ert-fail
                  "Preformatted text invoked coderef processing")))
              ((symbol-function 'org-babel-execute-src-block)
               (lambda (&rest _) (ert-fail "Source block executed"))))
      (let ((document
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (code
             (document
              "a   b" "  c  d" "" "中¯˙ <alpha> (math \"hidden\")"))
            (code (document "x   y" " z  q"))
            (code
             (document
              "* protected"
              "  (+ 1 2)"
              ""
              "中文    <alpha> (math \"hidden\")"))
            (code (document "")))))
        (should-not (org-texmacs-document-stm-paths document))))))

(ert-deftest
    org-texmacs-document-preformatted-tab-snapshot-and-preserve-indent
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq-local tab-width 4)
    (insert "#+begin_example -i\n  a\tb\n#+end_example\n")
    (let ((input (org-texmacs-prepare-buffer (current-buffer))))
      (should
       (= (plist-get
           (org-texmacs-input-info input)
           :texmacs-tab-width)
          4))
      (setq-local tab-width 8)
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document input))
        '(document (code (document "  a b")))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document (code (document "  a     b"))))))))

(ert-deftest org-texmacs-document-rejects-dynamic-code-semantics ()
  (dolist (source
           '("#+begin_src emacs-lisp -n\nx\n#+end_src\n"
             "#+begin_src emacs-lisp -r\nx (ref:line)\n#+end_src\n"
             "#+begin_src emacs-lisp :noweb yes\nx\n#+end_src\n"
             "#+begin_example -n\nx\n#+end_example\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid code reached worker")))
                ((symbol-function 'org-babel-execute-src-block)
                 (lambda (&rest _)
                   (ert-fail "Invalid source block executed"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-table-source-and-inline-subset ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "| Name | Value |\n"
     "| 中 <alpha> (math \"literal\") | *bold* [[https://example.org][site]] |\n"
     "| empty | |\n")
    (cl-letf (((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _)
                 (ert-fail "Table text reached the STM reader"))))
      (let ((document
             (org-texmacs-document
              (org-texmacs-test--input-from-model
               (org-texmacs-parse-buffer (current-buffer))))))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (tabular
             (tformat
              (table
               (row (cell "Name") (cell "Value"))
               (row
                (cell "中 <alpha> (math \"literal\")")
                (cell
                 (concat
                  (strong "bold")
                  " "
                  (hlink "site" "https://example.org"))))
               (row (cell "empty") (cell ""))))))))
        (should-not (org-texmacs-document-stm-paths document))))))

(ert-deftest org-texmacs-document-table-rule-positions ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "|----+----|\n"
     "| h1 | h2 |\n"
     "| h3 | h4 |\n"
     "|----+----|\n"
     "| a  | b  |\n"
     "|----+----|\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document
        (org-texmacs-test--input-from-model
         (org-texmacs-parse-buffer (current-buffer)))))
      '(document
        (tabular
         (tformat
          (cwith "1" "1" "1" "-1" "cell-tborder" "1ln")
          (cwith "2" "2" "1" "-1" "cell-bborder" "1ln")
          (cwith "3" "3" "1" "-1" "cell-bborder" "1ln")
          (table
           (row (cell "h1") (cell "h2"))
           (row (cell "h3") (cell "h4"))
           (row (cell "a") (cell "b"))))))))))

(ert-deftest
    org-texmacs-document-table-alignment-row-positions-and-ownership
    ()
  :tags
  '(issue4)
  (dolist (position '(0 1 2))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (let ((lines
             '("| LeftLongest | MiddleLongest | RightLongest |\n"
               "| L | C | R |\n")))
        (dotimes (index 3)
          (when (= index position)
            (insert "| <l> | <c> | <r> |\n"))
          (when (< index 2)
            (insert (nth index lines)))))
      (let* ((source (buffer-string))
             (input
              (org-texmacs-test--input-from-model
               (org-texmacs-parse-buffer (current-buffer))))
             (print-circle t)
             (before (prin1-to-string (org-texmacs-input-ast input)))
             (document (org-texmacs-document input)))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (tabular
             (tformat
              (cwith "1" "-1" "1" "1" "cell-halign" "l")
              (cwith "1" "-1" "2" "2" "cell-halign" "c")
              (cwith "1" "-1" "3" "3" "cell-halign" "r")
              (table
               (row
                (cell "LeftLongest")
                (cell "MiddleLongest")
                (cell "RightLongest"))
               (row (cell "L") (cell "C") (cell "R"))))))))
        (should
         (equal
          before (prin1-to-string (org-texmacs-input-ast input))))
        (should (equal source (buffer-string)))))))

(ert-deftest
    org-texmacs-document-table-alignment-column-counts-and-rules
    ()
  :tags
  '(issue4)
  (dolist (count '(1 2 4))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (let ((fields (make-list count "<c>"))
            (data (make-list count "x")))
        (insert
         "| "
         (mapconcat #'identity fields " | ")
         " |\n"
         "| "
         (mapconcat #'identity data " | ")
         " |\n"))
      (let* ((body
              (org-texmacs-document-body
               (org-texmacs-document
                (org-texmacs-test--input-from-model
                 (org-texmacs-parse-buffer (current-buffer))))))
             (format (cadadr body)))
        (should (eq (car format) 'tformat))
        (should (= (length (cdr format)) (1+ count)))
        (should
         (= (length (cdr (cadr (car (last format))))) count)))))
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "|---+---|\n| <r> | <l> |\n| Head | Col |\n"
     "|---+---|\n| 1 | 2 |\n|---+---|\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document
        (org-texmacs-test--input-from-model
         (org-texmacs-parse-buffer (current-buffer)))))
      '(document
        (tabular
         (tformat
          (cwith "1" "-1" "1" "1" "cell-halign" "r")
          (cwith "1" "-1" "2" "2" "cell-halign" "l")
          (cwith "1" "1" "1" "-1" "cell-tborder" "1ln")
          (cwith "1" "1" "1" "-1" "cell-bborder" "1ln")
          (cwith "2" "2" "1" "-1" "cell-bborder" "1ln")
          (table
           (row (cell "Head") (cell "Col"))
           (row (cell "1") (cell "2"))))))))))

(ert-deftest org-texmacs-document-table-alignment-rejections ()
  :tags
  '(issue4)
  (dolist (source
           '("| <l> | <r> |\n| <l> | <r> |\n| a | b |\n"
             "| <l> | <r> |\n| a | b |\n| <r> | <l> |\n"
             "| <l> | |\n| a | b |\n"
             "| <l> | data |\n| a | b |\n"
             "| <r10> | data |\n| a | b |\n"
             "| <10> |\n| a |\n"
             "| <l> | <r> |\n"
             "|---+---|\n| <l> | <r> |\n|---+---|\n"
             "| <l> | <r> |\n| a | b | c |\n"
             "| a | b |\n| <l> | <r> | <c> |\n"
             "|---+---|\n| <l> | <r> |\n|---+---|\n| a | b |\n"
             "| <l> | <r> |\n| / | < |\n| # | data |\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (should-error
       (org-texmacs-document
        (org-texmacs-test--input-from-model
         (org-texmacs-parse-buffer (current-buffer))))
       :type 'org-texmacs-document-error)
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-rejects-advanced-table-semantics ()
  (dolist (source
           '("| a | b | c |\n| d |\n"
             "| <l> | <10> |\n| a | b |\n"
             "| / | < | > |\n| # | a | b |\n|   | c | d |\n"
             "| a | b |\n| 1 | 2 |\n#+TBLFM: $2=$1+1\n"
             "|---+---|\n|---+---|\n| a | b |\n"
             "| [fn::note] |\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid table reached worker"))))
        (should-error
         (org-texmacs-document
          (org-texmacs-test--input-from-model
           (org-texmacs-parse-buffer (current-buffer))))
         :type 'org-texmacs-document-error))))
  (let* ((cell (org-element-create 'table-cell nil "x"))
         (row (org-element-create 'table-row '(:type standard) cell))
         (table (org-element-create 'table '(:type table.el) row))
         (ast (org-element-create 'org-data nil table)))
    (should-error
     (org-texmacs-test--lower ast)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-named-table-captions-and-links ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "[[t]] [[t][Table]].\n\n"
     "#+name: t\n#+caption[Short *S*]: Long [[t][self]]\n"
     "#+caption: Second <alpha>\n| a | b |\n")
    (let ((body
           (org-texmacs-test--stable-reference-body
            (org-texmacs-document
             (org-texmacs-test--input-from-model
              (org-texmacs-parse-buffer (current-buffer)))))))
      (should
       (equal
        body
        '(document
          (concat
           (reference "org-texmacs-ref-1") " "
           (hlink "Table" "#org-texmacs-ref-1") ". ")
          (big-table
           (tabular (tformat (table (row (cell "a") (cell "b")))))
           (surround
            (label "org-texmacs-ref-1") ""
            (caption-detailed
             (concat
              (concat "Long " (hlink "self" "#org-texmacs-ref-1"))
              " "
              "Second <alpha>")
             (concat "Short " (strong "S")))))))))))

(ert-deftest org-texmacs-document-named-table-uncaptioned-and-priority
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\n[[same][Table]]\n\n"
     "#+name: same\n| x |\n\n* same\n")
    (let ((body
           (org-texmacs-test--stable-reference-body
            (org-texmacs-document
             (org-texmacs-test--input-from-model
              (org-texmacs-parse-buffer (current-buffer)))))))
      (should
       (equal
        (cadr body)
        '(concat (hlink "Table" "#org-texmacs-ref-1") " ")))
      (should
       (equal
        (nth 2 body)
        '(surround
          (label "org-texmacs-ref-1")
          ""
          (tabular (tformat (table (row (cell "x"))))))))))
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "#+name: unused\n| x |\n")
    (should
     (equal
      (org-texmacs-test--stable-reference-body
       (org-texmacs-document
        (org-texmacs-test--input-from-model
         (org-texmacs-parse-buffer (current-buffer)))))
      '(document (tabular (tformat (table (row (cell "x"))))))))))

(ert-deftest org-texmacs-document-named-table-rejects-invalid-source
    ()
  (dolist (source
           '("#+name: t\n#+attr_html: :class hidden\n| x |\n"
             "#+caption: C\n#+attr_texmacs: float\n| x |\n"
             "#+caption:\n| x |\n"
             "#+caption: [cite:@k]\n| x |\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert
       source "\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
      (let ((before (buffer-string)))
        (ert-info
         ((format "Named-table source: %s" source))
         (should-error
          (org-texmacs-document-from-buffer (current-buffer))
          :type 'org-texmacs-document-error))
        (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-document-unavailable-table-reference-fallback
    ()
  (dolist
      (case
       '(("[[t]]\n\n#+name: t\n| x |\n" . "t")
         ("#+EXCLUDE_TAGS: hidden\n[[t][T]]\n* Hidden :hidden:\n#+name: t\n| x |\n"
          .
          "T")
         ("#+caption: [[missing]]\n| x |\n" . "missing")))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert (car case))
      (let* ((document
              (org-texmacs-document-from-buffer (current-buffer)))
             (body (org-texmacs-document-body document)))
        (should (member (cdr case) (flatten-tree body)))
        (should-not (memq 'reference (flatten-tree body)))
        (should-not (memq 'hlink (flatten-tree body)))))))

(ert-deftest org-texmacs-document-source-without-islands ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\n* A *bold*\t title\nText *strong*\t  tail.\n")
    (goto-char 4)
    (let ((source (buffer-string))
          (position (point))
          (tick (buffer-chars-modified-tick)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Unexpected worker request"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section (concat "A " (strong "bold") " " "title"))
            (concat "Text " (strong "strong") " " "tail. ")))))
      (should (= position (point)))
      (should (= tick (buffer-chars-modified-tick)))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-source-adjacent-islands ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "Before $(math \"*fake* [[link]]\")$$(math \"α\")$ after.\n")
    (let ((requests nil))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (push (substring-no-properties source) requests)
                   (list
                    'math
                    (if (= (length requests) 1)
                        "*fake* [[link]]"
                      "α")))))
        (let ((result
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal
            (org-texmacs-document-body result)
            '(document
              (concat
               "Before "
               (math "*fake* [[link]]")
               (math "α")
               " "
               "after. "))))
          (should
           (equal
            (org-texmacs-document-stm-paths result) '((0 1) (0 2))))
          (should
           (equal
            (nreverse requests)
            '("(math \"*fake* [[link]]\")" "(math \"α\")"))))))))

(ert-deftest org-texmacs-document-source-rejects-context ()
  (with-temp-buffer
    (should-error
     (org-texmacs-document-from-buffer (current-buffer))
     :type 'org-texmacs-document-error)
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "First\nSecond\n")
    (narrow-to-region 2 (point-max))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (concat "irst Second "))))
    (should (= (point-min) 2))))

(ert-deftest org-texmacs-document-explicit-source-and-wrapper ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "#+OPTIONS: toc:nil\n*** Heading\n")
    (setq-local org-odd-levels-only t)
    (let* ((source (current-buffer))
           (expected (org-texmacs-document-from-buffer source)))
      (should (equal expected (org-texmacs-document-current-buffer)))
      (with-temp-buffer
        (org-mode)
        (setq-local org-export-with-author nil)
        (insert "Unrelated\n")
        (setq-local org-odd-levels-only nil)
        (narrow-to-region 2 (point-max))
        (let ((caller (current-buffer))
              (position (point)))
          (should
           (equal expected (org-texmacs-document-from-buffer source)))
          (should (eq caller (current-buffer)))
          (should (= position (point)))
          (should (= 2 (point-min)))))
      (should
       (equal
        (org-texmacs-document-body expected)
        '(document (section "Heading")))))))

(ert-deftest
    org-texmacs-document-explicit-source-rejects-invalid-input
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (dolist (source (list nil t 1 (buffer-name)))
      (should-error
       (org-texmacs-document-from-buffer source)
       :type 'org-texmacs-document-error))
    (should-error
     (org-texmacs-document-from-buffer)
     :type 'wrong-number-of-arguments)
    (let ((dead
           (with-temp-buffer
             (current-buffer))))
      (should-error
       (org-texmacs-document-from-buffer dead)
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-document-explicit-source-survives-buffer-switch
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "$(math \"x\")$ $(math \"x\")$\n")
    (let ((source (current-buffer)))
      (with-temp-buffer
        (let ((caller (current-buffer))
              (calls 0))
          (cl-letf (((symbol-function 'org-texmacs--stm-read)
                     (lambda (_source)
                       (setq calls (1+ calls))
                       (set-buffer caller)
                       '(math "x"))))
            (let ((result (org-texmacs-document-from-buffer source)))
              (should
               (equal
                (org-texmacs-document-stm-paths result)
                '((0 0) (0 2)))))
            (should (= calls 2))
            (should (eq caller (current-buffer)))))))))

(ert-deftest
    org-texmacs-document-explicit-source-checks-after-lowering
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "Text\n")
    (let ((source (current-buffer))
          (lower (symbol-function 'org-texmacs--document-lower))
          (calls 0))
      (cl-letf (((symbol-function 'org-texmacs--document-lower)
                 (lambda (&rest args)
                   (setq calls (1+ calls))
                   (prog1 (apply lower args)
                     (when (= calls 1)
                       (with-current-buffer source
                         (insert "changed")))))))
        (should-error
         (org-texmacs-document-from-buffer source)
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-preserves-buffer-state-on-exit ()
  (dolist (outcome '(success unsupported parse-error))
    (dolist (modified '(nil t))
      (with-temp-buffer
        (org-mode)
        (setq-local org-export-with-author nil)
        (insert "Text $(math \"x\")$\n")
        (when (eq outcome 'unsupported)
          (insert "\n#+attr_html: :class test\nParagraph\n"))
        (put-text-property 1 3 'org-texmacs-test-property "retained")
        (goto-char 3)
        (set-mark 2)
        (setq mark-active t)
        (set-buffer-modified-p modified)
        (let* ((source (current-buffer))
               (before
                (org-texmacs-test--document-buffer-state source)))
          (with-temp-buffer
            (org-mode)
            (setq-local org-export-with-author nil)
            (insert "Unrelated buffer\n")
            (narrow-to-region 2 (point-max))
            (let* ((caller (current-buffer))
                   (caller-before
                    (org-texmacs-test--document-buffer-state caller)))
              (cl-letf (((symbol-function 'org-texmacs--stm-read)
                         (lambda (&rest _)
                           (set-buffer caller)
                           (pcase outcome
                             ('unsupported '(math "x"))
                             ('parse-error
                              (signal 'org-texmacs-parse-error
                                      '("fixture")))
                             (_ '(math "x"))))))
                (if (eq outcome 'success)
                    (should
                     (org-texmacs-document-p
                      (org-texmacs-document-from-buffer source)))
                  (should-error
                   (org-texmacs-document-from-buffer source)
                   :type
                   (pcase outcome
                     ('unsupported 'org-texmacs-document-error)
                     ('parse-error 'org-texmacs-parse-error))))
                (should (eq caller (current-buffer)))
                (should
                 (equal-including-properties
                  caller-before
                  (org-texmacs-test--document-buffer-state
                   caller))))))
          (should
           (equal-including-properties
            before
            (org-texmacs-test--document-buffer-state source))))))))

(ert-deftest
    org-texmacs-document-preserves-buffer-state-on-bibliography-worker-error
    ()
  (let ((bib-file
         (make-temp-file
          "org-texmacs-bibliography-"
          nil
          ".bib"
          "@book{one,title={One},author={Ada Alpha},year={2026}}\n")))
    (unwind-protect
        (with-temp-buffer
          (org-mode)
          (insert
           "#+cite_export: texmacs-native plain\n#+bibliography: "
           bib-file
           "\nText [cite:@one].\n#+print_bibliography:\n")
          (goto-char 3)
          (set-mark 2)
          (setq mark-active t)
          (set-buffer-modified-p nil)
          (let* ((source (current-buffer))
                 (source-state
                  (org-texmacs-test--document-buffer-state source)))
            (with-temp-buffer
              (org-mode)
              (insert "Unrelated caller\n")
              (set-mark (point-max))
              (narrow-to-region 2 (point-max))
              (goto-char 3)
              (let* ((caller (current-buffer))
                     (caller-state
                      (org-texmacs-test--document-buffer-state
                       caller))
                     (failure
                      '(org-texmacs-worker-error
                        "Injected bibliography worker failure")))
                (cl-letf (((symbol-function
                            'org-texmacs--worker-request)
                           (lambda (_source &optional operation)
                             (should (eq operation 'bibliography))
                             (set-buffer source)
                             (signal (car failure) (cdr failure)))))
                  (should
                   (equal
                    (should-error
                     (org-texmacs-document-from-buffer source)
                     :type 'org-texmacs-worker-error)
                    failure)))
                (should (eq (current-buffer) caller))
                (should
                 (equal-including-properties
                  caller-state
                  (org-texmacs-test--document-buffer-state caller)))
                (should
                 (equal-including-properties
                  source-state
                  (org-texmacs-test--document-buffer-state
                   source)))))))
      (delete-file bib-file))))

(ert-deftest
    org-texmacs-document-rechecks-explicit-source-after-switch
    ()
  (dolist (change '(text narrowing mode killed))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "$(math \"x\")$ $(math \"y\")$\n")
      (let ((source (current-buffer)))
        (with-temp-buffer
          (let ((caller (current-buffer))
                (calls 0))
            (cl-letf (((symbol-function 'org-texmacs--stm-read)
                       (lambda (&rest _)
                         (setq calls (1+ calls))
                         (with-current-buffer source
                           (pcase change
                             ('text (insert "changed"))
                             ('heading
                              (setq-local org-odd-levels-only
                                          (not org-odd-levels-only)))
                             ('link
                              (setq-local
                               org-link-abbrev-alist
                               '(("changed"
                                  .
                                  "https://example.org/%s"))))
                             ('narrowing
                              (narrow-to-region 2 (point-max)))
                             ('mode (fundamental-mode))
                             ('killed
                              (set-buffer-modified-p nil)
                              (kill-buffer source))))
                         (set-buffer caller)
                         '(math "x"))))
              (should-error
               (org-texmacs-document-from-buffer source)
               :type
               (if (eq change 'killed)
                   'error
                 'org-texmacs-error))
              (should (eq caller (current-buffer)))
              (should (= calls 2))
              (when (eq change 'text)
                (with-current-buffer source
                  (should
                   (string-suffix-p
                    "changed" (buffer-string))))))))))))

(ert-deftest org-texmacs-document-explicit-info-snapshot ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "#+OPTIONS: toc:nil\n* Title\n$(math \"x\")$\n")
    (setq-local org-texmacs-format-headline-function
                (lambda (&rest _) "Initial"))
    (let ((source (current-buffer)))
      (with-temp-buffer
        (let ((caller (current-buffer)))
          (cl-letf (((symbol-function 'org-texmacs--stm-read)
                     (lambda (&rest _)
                       (with-current-buffer source
                         (setq-local
                          org-texmacs-format-headline-function
                          (lambda (&rest _) "Next")))
                       (set-buffer caller)
                       '(math "x"))))
            (should
             (equal
              (cadr
               (org-texmacs-document-body
                (org-texmacs-document-from-buffer source)))
              '(section "Initial")))
            (should
             (equal
              (cadr
               (org-texmacs-document-body
                (org-texmacs-document-from-buffer source)))
              '(section "Next")))))))))

(ert-deftest org-texmacs-document-source-cache-remains-observable ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "Text\n")
    (goto-char 1)
    (let ((node (org-element-at-point)))
      (org-element-cache-store-key
       node 'org-texmacs-test-preserved 'present)
      (should
       (eq
        (org-element-cache-get-key
         node 'org-texmacs-test-preserved)
        'present))
      (org-texmacs-document-from-buffer (current-buffer))
      (should
       (eq
        (org-element-cache-get-key
         (org-element-at-point) 'org-texmacs-test-preserved)
        'present)))))

(ert-deftest org-texmacs-document-source-rechecks-snapshot ()
  (dolist (change '(text narrowing mode))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "$(math \"x\")$ $(math \"y\")$\n")
      (let ((calls 0))
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (_source)
                     (setq calls (1+ calls))
                     (pcase change
                       ('text (insert "changed"))
                       ('narrowing (narrow-to-region 2 (point-max)))
                       ('mode (fundamental-mode)))
                     '(math "x"))))
          (let ((source (current-buffer))
                (before (buffer-string)))
            (should
             (org-texmacs-document-p
              (org-texmacs-document-from-buffer source)))
            (should (equal before (buffer-string))))
          (should (= calls 2)))))))

(ert-deftest org-texmacs-document-source-accepts-unlisted-tags ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "$(custom-tag \"x\")$\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (custom-tag "x"))))))

(ert-deftest org-texmacs-document-source-bare-expressions-are-text ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _)
                 (ert-fail "Bare text reached the STM reader"))))
      (let ((result
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal
          (org-texmacs-document-body result)
          '(document (concat "(math \"x\") "))))
        (should-not (org-texmacs-document-stm-paths result))))))

(ert-deftest org-texmacs-document-source-real-islands ()
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+OPTIONS: toc:nil\n* Title\nText $(math (frac \"α\" \"2\"))$ end.\n\n"
      "#+begin_texmacs\n(document (math \"中\"))\n#+end_texmacs\n")
     (let ((source (buffer-string))
           (result
            (org-texmacs-document-from-buffer (current-buffer))))
       (should
        (equal
         (org-texmacs-document-body result)
         '(document
           (section "Title")
           (concat
            "Text " (math (frac "α" "2")) " " "end. ")
           (document (math "中")))))
       (should
        (equal (org-texmacs-document-stm-paths result) '((1 1) (2))))
       (should (= org-texmacs--worker-request-id 0))
       (should (equal source (buffer-string)))
       (should-not (org-texmacs--worker-live-p))))))

(ert-deftest org-texmacs-document-source-real-error-and-repair ()
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert "$(math 1)$\n")
     (should-error
      (org-texmacs-document-from-buffer (current-buffer))
      :type 'org-texmacs-parse-error)
     (should-not (org-texmacs--worker-live-p))
     (progn
       (erase-buffer)
       (insert "#+begin_texmacs\n\"atomic\"\n#+end_texmacs\n")
       (let ((result
              (org-texmacs-document-from-buffer (current-buffer))))
         (should
          (equal
           (org-texmacs-document-body result) '(document "atomic")))
         (should
          (equal (org-texmacs-document-stm-paths result) '((0)))))
       (should-not (org-texmacs--worker-live-p))))))

(ert-deftest org-texmacs-document-source-custom-todo-settings ()
  (dolist (keyword '("WAIT" "FINISHED"))
    (with-temp-buffer
      (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
        (org-mode)
        (setq-local org-export-with-author nil))
      (insert
       "#+TODO: WAIT | FINISHED\n#+OPTIONS: toc:nil\n* "
       keyword
       " Task\n")
      ;; Establish that the fixture really has non-default TODO semantics.
      (should
       (equal
        (org-element-map
         (org-element-parse-buffer)
         'headline
         (lambda (node) (org-element-property :todo-keyword node)))
        (list keyword)))
      (let ((source (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Plain headline started parsing"))))
          (let ((org-export-with-todo-keywords t))
            (should
             (equal
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              (list
               'document
               (list
                'section
                (list 'concat (list 'strong keyword) " " "Task")))))))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-document-source-custom-level-settings ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq-local org-odd-levels-only t)
    (insert "#+OPTIONS: toc:nil\n*** Heading\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section "Heading"))))
    (erase-buffer)
    (insert "#+OPTIONS: toc:nil\n******* Deep\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section "Deep"))))))

(ert-deftest org-texmacs-document-source-custom-todo-plain-title ()
  (with-temp-buffer
    (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
      (org-mode)
      (setq-local org-export-with-author nil))
    (insert
     "#+TODO: WAIT | FINISHED\n#+OPTIONS: toc:nil\n* TODO A *bold* title\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (section (concat "TODO A " (strong "bold") " " "title")))))))

(ert-deftest org-texmacs-document-source-custom-priority-settings ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    ;; A numeric-only effective regexp leaves [#A] in the title itself.
    (setq-local org-priority-regexp "\\(\\[#\\([0-9]+\\)\\] ?\\)")
    (insert "#+OPTIONS: toc:nil\n* [#A] Task\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section "[#A] Task"))))
    (erase-buffer)
    (insert "#+OPTIONS: toc:nil\n* [#12] Task\n")
    (let ((org-export-with-priority t))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document (section (concat "[#12]" " " "Task"))))))))

(ert-deftest org-texmacs-headline-policy-combinations ()
  (dolist (todo '(nil t))
    (dolist (priority '(nil t))
      (dolist (tags '(nil t not-in-toc))
        (with-temp-buffer
          (org-mode)
          (setq-local org-export-with-author nil)
          (insert
           "#+OPTIONS: toc:nil\n* TODO [#A] A *bold* title :one:two:\nBody\n")
          (let* ((org-export-with-todo-keywords todo)
                 (org-export-with-priority priority)
                 (org-export-with-tags tags)
                 (source (buffer-string))
                 (result
                  (org-texmacs-document-from-buffer (current-buffer)))
                 (parts
                  (append
                   (and todo '((strong "TODO") " "))
                   (and priority '("[#A]" " "))
                   '("A " (strong "bold") " " "title")
                   (and tags '(" " ":one:two:")))))
            (should
             (equal
              (org-texmacs-document-body result)
              (list
               'document
               (list 'section (cons 'concat parts))
               '(concat "Body "))))
            (should-not (org-texmacs-document-stm-paths result))
            (should (equal source (buffer-string)))))))))

(ert-deftest org-texmacs-headline-custom-formatter-policy-and-result
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "#+OPTIONS: toc:nil\n*** TODO [#A] Title :tag:\n")
    (let* ((output (list 'strong (copy-sequence "custom")))
           (calls 0)
           (org-export-with-todo-keywords nil)
           (org-export-with-priority nil)
           (org-export-with-tags nil)
           (org-texmacs-format-headline-function
            (lambda (todo type priority parts tags info)
              (cl-incf calls)
              (should-not todo)
              (should-not type)
              (should-not priority)
              (should-not tags)
              (should (equal parts '("Title")))
              (should-not (plist-get info :with-tags))
              output))
           (result
            (org-texmacs-document-from-buffer (current-buffer))))
      (should (> calls 0))
      (should
       (equal
        (org-texmacs-document-body result)
        '(document (section (strong "custom")))))
      (aset (cadr output) 0 ?X)
      (should
       (equal
        (org-texmacs-document-body result)
        '(document (section (strong "custom"))))))))

(ert-deftest org-texmacs-headline-invalid-formatter-result ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "* Title\n")
    (dolist (value '(42 (strong 42) (nil "x") (strong . "x")))
      (let ((org-texmacs-format-headline-function
             (lambda (&rest _) value)))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-headline-output-settings-snapshot ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\n* TODO [#A] Title :tag:\n$(math \"x\")$\n")
    (let ((org-export-with-todo-keywords t)
          (org-export-with-priority t)
          (org-export-with-tags t)
          (org-texmacs-format-headline-function
           #'org-texmacs-format-headline-default-function))
      (cl-letf
          (((symbol-function 'org-texmacs--stm-read)
            (lambda (_)
              (setq
               org-export-with-todo-keywords nil
               org-export-with-priority nil
               org-export-with-tags nil
               org-texmacs-format-headline-function (lambda (&rest _) "changed"))
              '(math "x"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section
             (concat
              (strong "TODO") " " "[#A]" " " "Title" " " ":tag:"))
            (math "x"))))
        (should
         (equal
          (cadr
           (org-texmacs-document-body
            (org-texmacs-document-from-buffer (current-buffer))))
          '(section "changed")))))))

(ert-deftest org-texmacs-headline-explicit-tags-only ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\n* Parent :parent:\n** Child :child:\n")
    (let ((org-export-with-tags t))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document
          (section (concat "Parent" " " ":parent:"))
          (subsection (concat "Child" " " ":child:"))))))))

;;; document.el ends here
