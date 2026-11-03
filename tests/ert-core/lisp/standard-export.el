;;; standard-export.el --- Standard export ownership regressions -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-standard-export-caption-note-boundary ()
  ;; Stock Org spelling stays literal, in both caption parts.
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+CAPTION[Short[fn::ShortNote]]: Long[fn::LongNote]\n| A |\n")
    (let ((body
           (org-texmacs-document-body
            (org-texmacs-document-from-buffer (current-buffer)))))
      (should-not (memq 'footnote (flatten-tree body)))
      (should (string-search "[fn::LongNote]" (prin1-to-string body)))
      (should
       (string-search "[fn::ShortNote]" (prin1-to-string body)))))
  ;; Positionless filter-created notes fail before native parsing or numbering.
  ;; Deleted/ignored owners and unused definitions must not be resurrected.
  (dolist (part '(long short))
    (dolist (selection '(keep delete ignore unused-definition))
      (with-temp-buffer
        (org-mode)
        (insert "| A |\n")
        (let ((org-export-use-babel nil)
              (org-export-filter-parse-tree-functions
               (list
                (lambda (tree _backend info)
                  (let* ((table
                          (org-element-map
                           tree 'table #'identity nil t))
                         (note
                          (org-element-create
                           'footnote-reference
                           '(:type inline)
                           "Note")))
                    (org-element-put-property
                     table
                     :caption
                     (list
                      (if (eq part 'long)
                          (cons (list "Long" note) nil)
                        (cons (list "Long") (list "Short" note)))))
                    (pcase selection
                      ('delete (org-element-extract-element table))
                      ('ignore
                       (plist-put info :ignore-list (list table)))
                      ('unused-definition
                       (org-element-extract-element table)
                       (org-element-set-contents
                        tree
                        (org-element-create
                         'footnote-definition
                         '(:label "unused")
                         table))))
                    tree)))))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (ert-fail
                        "Caption validation started native parsing")))
                    ((symbol-function 'org-export-get-footnote-number)
                     (lambda (&rest _)
                       (ert-fail
                        "Caption validation queried numbering"))))
            (if (eq selection 'keep)
                (let ((failure
                       (should-error
                        (org-texmacs-prepare-buffer (current-buffer))
                        :type 'org-texmacs-document-error)))
                  (should
                   (equal
                    (cadr failure)
                    "Caption footnotes are unsupported in standard source export")))
              (should
               (org-texmacs-input-p
                (org-texmacs-prepare-buffer (current-buffer)))))))))))

(ert-deftest org-texmacs-standard-export-native-body-raw-is-not-source
    ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-map
               tree 'special-block
               (lambda (node)
                 (org-element-set-contents
                  node
                  "(math \""
                  (org-export-raw-string "TARGET")
                  "\")")))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_source)
                   (ert-fail "Target raw reached native parser"))))
        (should-error
         (org-texmacs--standard-consume 'input)
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-standard-export-freezes-context-before-native-wait
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* Heading\n(math \"x\")\n")
    (let* ((formatter (make-symbol "standard-test-headline"))
           (original (lambda (&rest _arguments) "owned-heading"))
           (org-texmacs-format-headline-function formatter)
           (org-export-use-babel nil))
      (fset formatter original)
      (unwind-protect
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (_text)
                       (fset formatter
                             (lambda (&rest _arguments)
                               "changed-heading"))
                       '(math "x"))))
            (let ((input (org-texmacs--standard-consume 'input)))
              (should
               (eq
                (plist-get
                 (org-texmacs-input-info input)
                 :texmacs-format-headline-function)
                original))
              (should
               (string-match-p
                "owned-heading"
                (prin1-to-string
                 (org-texmacs-document-body
                  (org-texmacs-document input)))))))
        (fmakunbound formatter)))))

(ert-deftest
    org-texmacs-standard-export-adjacent-synthetic-text-is-one-input
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Replace.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-set-element
               (car (org-element-map tree 'paragraph #'identity))
               (org-element-create
                'paragraph nil "(ma" "th \"joined\")"))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (should (equal source "(math \"joined\")"))
                   '(math "joined"))))
        (should
         (equal
          (cdar
           (org-texmacs-input-islands
            (org-texmacs--standard-consume 'input)))
          '(math "joined")))))))

(ert-deftest
    org-texmacs-standard-export-resolves-code-without-overwriting-filter
    ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"~original~\")\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-map
               tree 'code
               (lambda (node)
                 (org-element-put-property node :value "filtered")))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (should (equal source "(math \"~filtered~\")"))
                   '(math "~filtered~"))))
        (should
         (equal
          (cdar
           (org-texmacs-input-islands
            (org-texmacs--standard-consume 'input)))
          '(math "~filtered~")))))))

(ert-deftest
    org-texmacs-standard-export-positionless-unsupported-affiliation-fails
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Text.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-set-element
               (car (org-element-map tree 'paragraph #'identity))
               (org-element-create
                'paragraph '(:attr_texmacs ("unsupported")) "Text."))
              tree))))
      (should-error
       (org-texmacs--standard-consume 'document)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-standard-export-positionless-island-ownership
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Replace this.\n")
    (let (final-node
          final-tree
          (calls 0)
          (org-export-use-babel nil))
      (let ((org-export-filter-parse-tree-functions
             (list
              (lambda (tree _backend _info)
                (setq final-node
                      (org-element-create
                       'paragraph nil "Left (math \"new\") right."))
                (org-element-set-element
                 (car
                  (org-element-map tree 'paragraph #'identity))
                 final-node)
                (setq final-tree tree)
                tree))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (text)
                     (cl-incf calls)
                     (should (equal text "(math \"new\")"))
                     '(math "new"))))
          (let* ((input (org-texmacs--standard-consume 'input))
                 (island (car (org-texmacs-input-islands input)))
                 (model (org-texmacs-input-model input)))
            (should (= calls 1))
            (should-not (org-element-property :begin final-node))
            (should
             (eq
              (org-texmacs-input-ast input)
              (org-texmacs-model-ast model)))
            (should
             (eq
              (org-texmacs-input-islands input)
              (org-texmacs-model-islands model)))
            (should-not
             (eq
              (org-element-property :parent (car island)) final-node))
            (should
             (memq
              (car island)
              (org-element-contents
               (org-element-property :parent (car island)))))
            (should (= (length (org-element-contents final-node)) 1))
            (org-element-set-contents final-node "External mutation")
            (should (equal (cdr island) '(math "new")))
            (should-not (eq (org-texmacs-input-ast input) final-tree))
            (should (org-texmacs-document input))))))))

(ert-deftest
    org-texmacs-standard-export-logical-exclusion-before-parsing
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Keep.\n\n(math incomplete\n")
    (let ((org-export-use-babel nil)
          captured
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend info)
              (plist-put
               info
               :ignore-list
               (last (org-element-map tree 'paragraph #'identity)))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_text) (ert-fail "Ignored STM parsed"))))
        (setq captured (org-texmacs--standard-consume 'input)))
      (should-not (org-texmacs-input-islands captured))
      (should
       (= (length
           (org-element-map
            (org-texmacs-input-ast captured) 'paragraph #'identity))
          1)))))

(ert-deftest
    org-texmacs-standard-export-native-source-property-and-movement
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* One\nOld.\n* Two\nNext.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (let* ((headings
                      (org-element-map tree 'headline #'identity))
                     (old
                      (car
                       (org-element-map tree 'paragraph #'identity)))
                     (block
                      (org-element-create
                       'special-block
                       '(:type
                         "equation*"
                         :texmacs-source "(sqrt \"new\")"))))
                (org-element-extract-element old)
                (org-element-adopt (cadr headings) block))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (text)
                   (should (equal text "(sqrt \"new\")"))
                   '(sqrt "new"))))
        (let* ((input (org-texmacs--standard-consume 'input))
               (island (car (org-texmacs-input-islands input))))
          (should (equal (cdr island) '(sqrt "new")))
          (should
           (equal
            (org-element-property
             :raw-value (org-element-property :parent (car island)))
            "Two"))
          (should-not (org-element-property :begin (car island))))))))

(ert-deftest
    org-texmacs-standard-export-boundary-errors-before-native-effects
    ()
  (dolist (text
           '("(math *x*)\n"
             "(math \"unterminated)\n"
             "(math (sqrt *x*))\n"))
    (with-temp-buffer
      (org-mode)
      (insert text)
      (let ((org-export-use-babel nil))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_source)
                     (ert-fail "Invalid boundary started worker"))))
          (should-error
           (org-texmacs--standard-consume 'input)
           :type 'org-texmacs-document-error))))))

(ert-deftest
    org-texmacs-standard-export-stm-parse-error-and-source-preservation
    ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")\n")
    (let ((source (buffer-string))
          (org-export-use-babel nil))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_source)
                   (signal 'org-texmacs-parse-error
                           '("Invalid native data")))))
        (should-error
         (org-texmacs--standard-consume 'document)
         :type 'org-texmacs-parse-error))
      (should (equal source (buffer-string)))
      (should-not org-texmacs--standard-transaction)
      (should-not org-texmacs--standard-request))))

(ert-deftest
    org-texmacs-standard-export-fragment-settings-change-across-wait
    ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")\n")
    (let ((source (current-buffer))
          (org-texmacs-fragment-tags '("math"))
          (org-export-use-babel nil))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_text)
                   (with-current-buffer source
                     (setq org-texmacs-fragment-tags '("other")))
                   '(math "x"))))
        (should-error
         (org-texmacs--standard-consume 'input)
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-standard-export-real-preparation-and-structured-result
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Plain document.\n")
    (let ((calls 0)
          (before 0)
          (trees 0)
          (org-export-use-babel nil))
      (let ((org-export-before-processing-functions
             (list
              (lambda (backend)
                (should (eq backend 'texmacs))
                (cl-incf before))))
            (org-export-filter-parse-tree-functions
             (list
              (lambda (tree _backend _info)
                (cl-incf trees)
                (org-element-adopt
                 tree
                 (org-element-create
                  'section
                  nil
                  (org-element-create 'paragraph nil "Inserted")))
                tree))))
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (_document)
                     (cl-incf calls)
                     "<TeXmacs|probe>")))
          (let ((document (org-texmacs--standard-consume 'document)))
            (should (org-texmacs-document-p document))
            (should
             (string-match-p
              "Inserted"
              (prin1-to-string (org-texmacs-document-body document))))
            (should (= calls 0))
            (should (= before 1))
            (should (= trees 1)))
          (should (equal (org-export-as 'texmacs) "<TeXmacs|probe>"))
          (should (= calls 1)))))))

(ert-deftest
    org-texmacs-standard-export-node-filters-fail-before-effects
    ()
  (dolist (stage '(initial options ast))
    (with-temp-buffer
      (org-mode)
      (insert "Plain document.\n")
      (let* ((calls 0)
             (filter
              (lambda (text _backend _info)
                (cl-incf calls)
                text))
             (org-export-use-babel nil)
             (org-export-filter-paragraph-functions
              (when (eq stage 'initial)
                (list filter)))
             (org-export-filter-options-functions
              (when (eq stage 'options)
                (list
                 (lambda (info _backend)
                   (plist-put
                    info
                    :filter-paragraph (list filter))))))
             (org-export-filter-parse-tree-functions
              (when (eq stage 'ast)
                (list
                 (lambda (tree _backend info)
                   (plist-put info :filter-paragraph (list filter))
                   tree)))))
        (should-error
         (org-export-as 'texmacs)
         :type 'org-texmacs-document-error)
        (should (= calls 0))))))

(ert-deftest org-texmacs-standard-export-final-filters-see-final-text
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Plain document.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-body-functions
           (list
            (lambda (text _backend _info) (concat text " BODY"))))
          (org-export-filter-final-output-functions
           (list
            (lambda (text _backend _info) (concat text " FINAL")))))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document) "NATIVE")))
        (should
         (equal (org-export-as 'texmacs) "NATIVE BODY FINAL"))))))

(ert-deftest
    org-texmacs-standard-export-nested-normal-return-and-errors
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Outer document.\n")
    (let* ((nested nil)
           (returns 0)
           (advice
            (lambda (function &rest args)
              (prog1 (apply function args)
                (cl-incf returns))))
           (org-export-use-babel nil)
           (org-export-filter-parse-tree-functions
            (list
             (lambda (tree _backend _info)
               (unless nested
                 (setq nested t)
                 (unwind-protect
                     (with-temp-buffer
                       (org-mode)
                       (insert "Inner document.\n")
                       (should
                        (org-texmacs-model-p
                         (org-texmacs--standard-consume 'model))))
                   (setq nested nil)))
               tree))))
      (advice-add 'org-export-as :around advice)
      (unwind-protect
          (progn
            (let ((document
                   (org-texmacs--standard-consume 'document)))
              (should
               (string-match-p
                "Outer"
                (prin1-to-string
                 (org-texmacs-document-body document)))))
            (should (= returns 2))
            (let ((org-export-filter-final-output-functions
                   (list (lambda (text _backend _info) text))))
              (should-error
               (org-texmacs--standard-consume 'document)
               :type 'org-texmacs-document-error))
            (should-not org-texmacs--standard-request)
            (should-not org-texmacs--standard-transaction)
            (should
             (org-texmacs-document-p
              (org-texmacs--standard-consume 'document))))
        (advice-remove 'org-export-as advice)))))

(ert-deftest
    org-texmacs-standard-export-target-raw-is-not-literal-text
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Plain document.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-map
               tree 'paragraph
               (lambda (node)
                 (org-element-set-contents
                  node (org-export-raw-string "TARGET-CODE"))))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document)
                   (ert-fail "Unsupported raw serialized"))))
        (should-error
         (org-export-as 'texmacs)
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-standard-export-source-location-alias-change
    ()
  (dolist (kind '(file directory))
    (with-temp-buffer
      (org-mode)
      (insert "Plain document.\n")
      (let* ((location (copy-sequence "/tmp/source.org"))
             (directory (copy-sequence "/tmp/"))
             (org-export-use-babel nil))
        (setq
         buffer-file-name location
         default-directory directory)
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (_document)
                     (if (eq kind 'file)
                         (aset location 5 ?X)
                       (aset directory 1 ?X))
                     "<TeXmacs|probe>")))
          (should-error
           (org-export-as 'texmacs)
           :type 'org-texmacs-document-error))
        ;; External callback edits are detected, not reverted.
        (should
         (eq
          (if (eq kind 'file)
              (aref buffer-file-name 5)
            (aref default-directory 1))
          ?X))
        (setq buffer-file-name nil)))))

(ert-deftest
    org-texmacs-standard-export-native-consumer-nested-request
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Outer document.\n")
    (let ((org-export-use-babel nil))
      (cl-letf
          (((symbol-function 'org-texmacs-document-serialize)
            (lambda (_document) "NESTED-TEXT"))
           ((symbol-function 'org-texmacs-document-pdf)
            (lambda (_document)
              ;; Native waits can dispatch timers which start new exports.
              (should-not org-texmacs--standard-request)
              (with-temp-buffer
                (org-mode)
                (insert "Inner document.\n")
                (should
                 (equal (org-export-as 'texmacs) "NESTED-TEXT")))
              "%PDF-probe")))
        (should
         (equal
          (org-texmacs--standard-consume 'pdf) "%PDF-probe"))))))

(ert-deftest org-texmacs-standard-export-request-token-is-single-use
    ()
  (dolist (phase '(before after))
    (with-temp-buffer
      (org-mode)
      (insert "Outer document.\n")
      (let* ((active nil)
             (nested 0)
             (org-export-use-babel nil)
             (org-export-filter-options-functions
              (list
               (lambda (info _backend)
                 (should-not
                  (plist-member info :texmacs--result-token))
                 info)))
             (run-nested
              (lambda ()
                (setq active t)
                (unwind-protect
                    (with-temp-buffer
                      (org-mode)
                      (insert "Inner document.\n")
                      (should
                       (equal (org-export-as 'texmacs) "NESTED-TEXT"))
                      (cl-incf nested))
                  (setq active nil))))
             (advice
              (lambda (function &rest args)
                (when (and (not active) (eq phase 'before))
                  (funcall run-nested))
                (prog1 (apply function args)
                  (when (and (not active) (eq phase 'after))
                    (funcall run-nested))))))
        (advice-add 'org-export-as :around advice '((depth . -100)))
        (unwind-protect
            (cl-letf (((symbol-function
                        'org-texmacs-document-serialize)
                       (lambda (_document) "NESTED-TEXT")))
              (should
               (org-texmacs-document-p
                (org-texmacs--standard-consume 'document)))
              (should (= nested 1)))
          (advice-remove 'org-export-as advice))))))

(ert-deftest org-texmacs-standard-export-guards-ignore-other-backends
    ()
  (require 'ox-ascii)
  (with-temp-buffer
    (org-mode)
    (insert "Unrelated source.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-paragraph-functions
           (list
            (lambda (text _backend _info) (concat text "SENTINEL")))))
      (should (string-match-p "SENTINEL" (org-export-as 'ascii))))))

(ert-deftest org-texmacs-standard-export-body-only-before-processing
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Plain document.\n")
    (let ((org-export-before-processing-functions
           (list
            (lambda
              (_backend)
              (ert-fail "Body-only started preparation")))))
      (should-error
       (org-export-as 'texmacs nil nil t)
       :type 'user-error))))

(ert-deftest org-texmacs-standard-export-incomplete-stm-is-not-literal
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Math (math \"x\".\n")
    (let ((org-export-use-babel nil))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document)
                   (ert-fail "Incomplete STM serialized as text"))))
        (should-error
         (org-export-as 'texmacs)
         :type 'org-texmacs-document-error)))))
