;;; ert-pdf-preprocess.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-texmacs)
(require 'ox)

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

;;; ert-pdf-preprocess.el ends here
