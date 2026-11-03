;;; preprocess.el --- Structured standard consumers -*- lexical-binding: t; -*-

(ert-deftest
    org-texmacs-standard-structured-prepared-consumers-do-not-lower
    ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_unknown\nPreserved model data.\n#+end_unknown\n")
    (let ((calls 0)
          (org-export-use-babel nil))
      (let ((org-export-before-processing-functions
             (list (lambda (_) (cl-incf calls)))))
        (cl-letf (((symbol-function 'org-texmacs-document)
                   (lambda (&rest _)
                     (ert-fail
                      "Prepared consumer forced target lowering"))))
          (let ((input (org-texmacs-prepare-buffer (current-buffer)))
                (model
                 (org-texmacs--standard-source-consume
                  'model (current-buffer) nil nil nil nil)))
            (should (org-texmacs-input-p input))
            (should (org-texmacs-model-p model))
            (should
             (org-element-map
              (org-texmacs-model-ast model)
              'special-block
              #'identity)))))
      (should (= calls 2)))
    (should-error
     (org-texmacs-document-from-buffer (current-buffer))
     :type 'org-texmacs-document-error)))

(ert-deftest
    org-texmacs-standard-structured-output-consumers-lower-once
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil\nBody.\n")
     (let ((source (current-buffer))
           (lower (symbol-function 'org-texmacs-document)))
       (dolist (function
                '(org-texmacs-document-from-buffer
                  org-texmacs-export-texmacs-from-buffer
                  org-texmacs-export-pdf-from-buffer))
         (let ((calls 0)
               (prepared 0))
           (let ((org-export-before-processing-functions
                  (list (lambda (_) (cl-incf prepared)))))
             (cl-letf (((symbol-function 'org-texmacs-document)
                        (lambda (input)
                          (cl-incf calls)
                          (funcall lower input))))
               (with-temp-buffer
                 (funcall function source))))
           (should (= calls 1))
           (should (= prepared 1))))))))

(ert-deftest
    org-texmacs-standard-structured-legacy-wrappers-use-standard-only
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Body.\n")
     (let ((source (current-buffer)))
       (dolist
           (function
            '(org-texmacs-prepare-buffer-preprocessed
              org-texmacs-document-from-buffer-preprocessed
              org-texmacs-export-from-buffer-preprocessed
              org-texmacs-document-from-buffer-discover-bibliography
              org-texmacs-export-from-buffer-discover-bibliography))
         (let ((calls 0))
           (let ((org-export-before-processing-functions
                  (list (lambda (_) (cl-incf calls)))))
             (cl-letf (((symbol-function 'org-texmacs--prepare-buffer)
                        (lambda (&rest _)
                          (ert-fail "Parallel preparation")))
                       ((symbol-function
                         'org-texmacs--preprocess-convert)
                        (lambda (&rest _)
                          (ert-fail "Parallel composition")))
                       ((symbol-function
                         'org-texmacs--bibliography-convert)
                        (lambda (&rest _)
                          (ert-fail "Parallel bibliography"))))
               (with-temp-buffer
                 (funcall function source))))
           (should (= calls 1))))))))

(ert-deftest org-texmacs-standard-structured-errors-and-nested-input
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Outer.\n")
    (let ((calls 0)
          child)
      (let ((org-export-before-processing-functions
             (list
              (lambda (_)
                (cl-incf calls)
                (when (= calls 1)
                  (with-temp-buffer
                    (org-mode)
                    (insert "Inner.\n")
                    (setq child
                          (org-texmacs-prepare-buffer
                           (current-buffer)))))))))
        (let ((outer (org-texmacs-prepare-buffer (current-buffer))))
          (should
           (string-search
            "Outer."
            (prin1-to-string (org-texmacs-input-ast outer))))))
      (should (= calls 2))
      (should
       (string-search
        "Inner." (prin1-to-string (org-texmacs-input-ast child)))))
    (let ((org-export-before-processing-functions
           (list
            (lambda (_)
              (ert-fail "Unmappable arguments ran preparation")))))
      (should-error
       (org-texmacs-prepare-buffer-preprocessed
        (current-buffer) nil nil t)
       :type 'org-texmacs-document-error)
      (should-error
       (org-texmacs-document-from-buffer-discover-bibliography
        (current-buffer) '(("x" . "BibTeX")))
       :type 'org-texmacs-document-error))))
