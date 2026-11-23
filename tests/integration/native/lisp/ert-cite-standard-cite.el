;;; ert-cite-standard-cite.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'ox)
(require 'ox-texmacs)

(require 'oc-csl)

(ert-deftest org-texmacs-standard-csl-text-filters-and-native-refusal
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-csl
    (with-temp-buffer
      (org-mode)
      (insert csl-header "[cite:@key]\n#+print_bibliography:\n")
      (let ((org-export-use-babel nil)
            (body-calls 0)
            (final-calls 0))
        (let ((org-export-filter-body-functions
               (list
                (lambda (text _backend _info)
                  (cl-incf body-calls)
                  (concat text " BODY"))))
              (org-export-filter-final-output-functions
               (list
                (lambda (text _backend _info)
                  (cl-incf final-calls)
                  (concat text " FINAL")))))
          (should
           (string-suffix-p " BODY FINAL" (org-export-as 'texmacs)))
          (should (= body-calls 1))
          (should (= final-calls 1))
          (should-error
           (org-texmacs--standard-consume 'pdf)
           :type 'org-texmacs-document-error)
          (should (= body-calls 1))
          (should (= final-calls 1))))))))

;;; ert-cite-standard-cite.el ends here
