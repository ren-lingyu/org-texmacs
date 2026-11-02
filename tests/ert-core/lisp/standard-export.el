;;; standard-export.el --- Standard export ownership regressions -*- lexical-binding: t; -*-

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

(ert-deftest org-texmacs-standard-export-unadapted-stm-is-not-literal
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Math (math \"x\").\n")
    (let ((org-export-use-babel nil))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document)
                   (ert-fail "Unadapted STM serialized as text"))))
        (should-error
         (org-export-as 'texmacs)
         :type 'org-texmacs-document-error)))))
