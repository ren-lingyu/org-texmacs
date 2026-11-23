;;; ert-pdf-preprocess.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-texmacs-bibliography)
(require 'org-texmacs-preprocess)
(require 'ox)

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

;;; ert-pdf-preprocess.el ends here
