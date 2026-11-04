;;; standard-cite.el --- Org Cite protocol regressions -*- lexical-binding: t; -*-

(defvar org-texmacs-test--cite-result 'element)
(defvar org-texmacs-test--cite-calls nil)
(defvar org-texmacs-test--cite-info nil)
(defvar org-texmacs-test--cite-finalized 0)

(defun org-texmacs-test--cite-citation (citation _style backend info)
  (should (org-export-derived-backend-p backend 'texmacs))
  (should (equal '("key") (org-cite-get-references citation t)))
  (push 'citation org-texmacs-test--cite-calls)
  (setq org-texmacs-test--cite-info info)
  (pcase org-texmacs-test--cite-result
    ('scripts
     (list
      "x"
      (org-element-create 'subscript nil "i")
      (org-element-create 'superscript nil "2")
      " y"
      (org-element-create
       'superscript
       '(:use-brackets-p t)
       "a"
       (org-element-create 'subscript nil "b"))))
    ('entity
     (org-element-create
      'entity '(:name "alpha" :utf-8 "α" :latex-math-p t)))
    ('element (org-element-create 'bold nil "Structured"))
    ('secondary
     (list "Prefix " (org-element-create 'italic nil "Structured")))
    ('reentrant
     (org-export-data (org-element-create 'bold nil "Nested") info))
    (_ "Target output")))

(defun org-texmacs-test--cite-bibliography
    (keys files _style _props _backend info)
  (should (eq info org-texmacs-test--cite-info))
  (should (equal keys '("key")))
  (should (equal files (plist-get info :bibliography)))
  (push 'bibliography org-texmacs-test--cite-calls)
  (org-element-create 'paragraph nil "Bibliography"))

(defun org-texmacs-test--cite-finalizer (text &rest _)
  (cl-incf org-texmacs-test--cite-finalized)
  (concat text " finalized"))

(org-cite-register-processor
 'org-texmacs-test-structured
 :export-citation #'org-texmacs-test--cite-citation
 :export-bibliography #'org-texmacs-test--cite-bibliography
 :cite-styles '((("nil"))))
(org-cite-register-processor
 'org-texmacs-test-finalized
 :export-citation #'org-texmacs-test--cite-citation
 :export-finalizer #'org-texmacs-test--cite-finalizer
 :cite-styles '((("nil"))))

(ert-deftest org-texmacs-standard-cite-late-entity-options ()
  (dolist (enabled '(nil t))
    (with-temp-buffer
      (org-mode)
      (insert "[cite:@key]\n")
      (let* ((org-export-use-babel nil)
             (org-export-with-entities enabled)
             (org-texmacs-cite-export-processor nil)
             (org-cite-export-processors
              '((t org-texmacs-test-structured)))
             (org-texmacs-test--cite-result 'entity)
             (org-texmacs-test--cite-calls nil)
             (input (org-texmacs--standard-consume 'input))
             (body
              (org-texmacs-document-body
               (org-texmacs-document input))))
        (should (equal org-texmacs-test--cite-calls '(citation)))
        (should
         (org-element-map
          (org-texmacs-input-ast input) 'entity #'identity))
        (if enabled
            (should
             (member
              '(math "α")
              (org-texmacs-test--caption-inline-footnote-nodes
               body 'math)))
          (should-not
           (org-texmacs-test--caption-inline-footnote-nodes
            body 'math))
          (should
           (string-search "\\\\alpha" (prin1-to-string body))))))))

(ert-deftest org-texmacs-standard-cite-late-script-options ()
  (dolist (policy '(t {} nil))
    (with-temp-buffer
      (org-mode)
      (insert "[cite:@key]\n")
      (let* ((org-export-use-babel nil)
             (org-export-with-sub-superscripts policy)
             (org-texmacs-cite-export-processor nil)
             (org-cite-export-processors
              '((t org-texmacs-test-structured)))
             (org-texmacs-test--cite-result 'scripts)
             (org-texmacs-test--cite-calls nil)
             (input (org-texmacs--standard-consume 'input))
             (body
              (org-texmacs-document-body
               (org-texmacs-document input))))
        (should (equal org-texmacs-test--cite-calls '(citation)))
        (should
         (org-element-map
          (org-texmacs-input-ast input) 'subscript #'identity))
        (should
         (= (length
             (org-texmacs-test--caption-inline-footnote-nodes
              body 'rsub))
            (if (eq policy t)
                2
              0)))
        (should
         (= (length
             (org-texmacs-test--caption-inline-footnote-nodes
              body 'rsup))
            (pcase policy
              ('t 2)
              ('{} 1)
              (_ 0))))))))

(ert-deftest org-texmacs-standard-cite-structured-protocol-once ()
  (dolist (org-texmacs-test--cite-result '(element secondary))
    (with-temp-buffer
      (org-mode)
      (insert "[cite:@alias]\n#+print_bibliography:\n")
      (let ((org-export-use-babel nil)
            (org-texmacs-cite-export-processor nil)
            (org-cite-export-processors
             '((t org-texmacs-test-structured)))
            (org-texmacs-test--cite-calls nil)
            (org-texmacs-test--cite-info nil)
            (filtered 0)
            (prepared 0))
        (let ((org-export-before-processing-functions
               (list (lambda (_) (cl-incf prepared))))
              (org-export-filter-parse-tree-functions
               (list
                (lambda (tree _backend _info)
                  (cl-incf filtered)
                  (org-element-map
                   tree 'citation-reference
                   (lambda (reference)
                     (org-element-put-property reference :key "key")))
                  tree))))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (ert-fail "Unexpected native parser"))))
            (let ((input (org-texmacs--standard-consume 'input)))
              (should (org-texmacs-document input))
              (should
               (org-element-map
                (org-texmacs-input-ast input)
                (if (eq org-texmacs-test--cite-result 'element)
                    'bold
                  'italic)
                #'identity))))
          (should (= prepared 1))
          (should (= filtered 1))
          (should
           (equal
            '(bibliography citation)
            org-texmacs-test--cite-calls)))))))

(ert-deftest
    org-texmacs-standard-cite-raw-and-reentrant-are-explicit-errors
    ()
  (dolist (org-texmacs-test--cite-result '(string reentrant))
    (with-temp-buffer
      (org-mode)
      (insert "[cite:@key]\n")
      (let ((org-export-use-babel nil)
            (org-texmacs-cite-export-processor nil)
            (org-cite-export-processors
             '((t org-texmacs-test-structured)))
            (org-texmacs-test--cite-calls nil))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Unexpected native parser"))))
          (should
           (string-match-p
            "Raw target output"
            (cadr
             (should-error
              (org-texmacs--standard-consume 'document)
              :type 'org-texmacs-document-error)))))
        (should (equal '(citation) org-texmacs-test--cite-calls))))))

(ert-deftest
    org-texmacs-standard-cite-basic-raw-rejected-before-native-work
    ()
  (let ((bib (make-temp-file "org-texmacs-basic-" nil ".bib")))
    (unwind-protect
        (progn
          (with-temp-file bib
            (insert
             "@book{key, author={Doe, Jane}, title={Fixture}, year={2026}}\n"))
          (with-temp-buffer
            (org-mode)
            (insert
             (format
              "#+bibliography: %s\n#+cite_export: basic\n[cite:@key]\n#+print_bibliography:\n"
              bib))
            (let ((org-export-use-babel nil))
              (cl-letf (((symbol-function
                          'org-texmacs--worker-request)
                         (lambda (&rest _)
                           (ert-fail "Unexpected native parser"))))
                (should-error
                 (org-export-as 'texmacs)
                 :type 'org-texmacs-document-error)))))
      (delete-file bib))))

(ert-deftest
    org-texmacs-standard-cite-unknown-finalizer-native-refused-before-effects
    ()
  (with-temp-buffer
    (org-mode)
    (insert "[cite:@key]\n")
    (let ((org-export-use-babel nil)
          (org-texmacs-cite-export-processor nil)
          (org-cite-export-processors
           '((t org-texmacs-test-finalized)))
          (org-texmacs-test--cite-result 'element)
          (org-texmacs-test--cite-finalized 0))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Unexpected native parser"))))
        (should-error
         (org-texmacs--standard-consume 'document)
         :type 'org-texmacs-document-error))
      (should (= 0 org-texmacs-test--cite-finalized)))))

(ert-deftest org-texmacs-standard-cite-text-finalizer-runs-once ()
  (with-temp-buffer
    (org-mode)
    (insert "[cite:@key]\n")
    (let ((org-export-use-babel nil)
          (org-texmacs-cite-export-processor nil)
          (org-cite-export-processors
           '((t org-texmacs-test-finalized)))
          (org-texmacs-test--cite-result 'element)
          (org-texmacs-test--cite-finalized 0))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_) "native text")))
        (should
         (equal (org-export-as 'texmacs) "native text finalized")))
      (should (= 1 org-texmacs-test--cite-finalized)))))

(ert-deftest
    org-texmacs-standard-cite-late-node-filter-precedes-processor
    ()
  (with-temp-buffer
    (org-mode)
    (insert "[cite:@key]\n")
    (let ((org-export-use-babel nil)
          (org-texmacs-cite-export-processor nil)
          (org-cite-export-processors
           '((t org-texmacs-test-structured)))
          (org-texmacs-test--cite-calls nil)
          (filter-calls 0))
      (let ((org-export-filter-parse-tree-functions
             (list
              (lambda (tree _backend info)
                (plist-put
                 info
                 :filter-paragraph
                 (list
                  (lambda (text &rest _)
                    (cl-incf filter-calls)
                    text)))
                tree))))
        (should-error
         (org-export-as 'texmacs)
         :type 'org-texmacs-document-error)
        (should (= 0 filter-calls))
        (should-not org-texmacs-test--cite-calls)))))

(ert-deftest
    org-texmacs-standard-cite-compatible-finalizer-redefinition-refused
    ()
  (let ((info (list :back-end (org-export-get-backend 'texmacs)))
        (calls 0))
    (should
     (org-texmacs--standard-compatible-finalizer-p
      'org-cite-csl-finalizer info))
    (cl-letf (((symbol-function 'org-cite-csl-finalizer)
               (lambda (&rest _)
                 (cl-incf calls)
                 "modified")))
      (should-not
       (org-texmacs--standard-compatible-finalizer-p
        'org-cite-csl-finalizer info)))
    (cl-letf (((symbol-function 'org-cite-csl--output-format)
               (lambda (&rest _)
                 (cl-incf calls)
                 'org)))
      (should-not
       (org-texmacs--standard-compatible-finalizer-p
        'org-cite-csl-finalizer info)))
    (should (= calls 0))))

(ert-deftest
    org-texmacs-standard-cite-zero-width-text-keeps-model-unicode
    ()
  (with-temp-buffer
    (org-mode)
    (insert "a\u200bb\n")
    (let ((org-export-use-babel nil))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Unexpected native parser"))))
        (let* ((input (org-texmacs--standard-consume 'input))
               (paragraph
                (car
                 (org-element-map
                  (org-texmacs-input-ast input)
                  'paragraph
                  #'identity)))
               (text (car (org-element-contents paragraph)))
               (document (org-texmacs-document input)))
          (should (string-search "\u200b" text))
          (should
           (string-search
            "(space \"0em\")"
            (prin1-to-string (org-texmacs-document-body document))))
          (should (string-search "\u200b" text)))))))

(ert-deftest
    org-texmacs-standard-cite-secondary-raw-rejected-before-body-stm
    ()
  (dolist (location '(headline caption metadata))
    (with-temp-buffer
      (org-mode)
      (insert
       "* Heading\n#+caption: Caption\n| Cell |\n\n(math \"x\")\n")
      (let ((org-export-use-babel nil))
        (let ((org-export-filter-parse-tree-functions
               (list
                (lambda (tree _backend info)
                  (let ((raw (org-export-raw-string "TARGET")))
                    (pcase location
                      ('headline
                       (org-element-map
                        tree 'headline
                        (lambda (node)
                          (org-element-put-property
                           node
                           :title (list raw)))))
                      ('caption
                       (org-element-map
                        tree 'table
                        (lambda (node)
                          (org-element-put-property
                           node
                           :caption (list (cons (list raw) nil))))))
                      ('metadata (plist-put info :title (list raw)))))
                  tree))))
          (cl-letf
              (((symbol-function 'org-texmacs--worker-request)
                (lambda (&rest _)
                  (ert-fail
                   "Target raw was found after native parsing"))))
            (should-error
             (org-texmacs--standard-consume 'input)
             :type 'org-texmacs-document-error)))))))
