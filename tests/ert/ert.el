;;; ert.el --- Tests for org-texmacs -*- lexical-binding: t; -*-

;;; Commentary:

;; ERT tests for org-texmacs.

;;; Code:

(require 'ert)
(require 'org-texmacs)

(ert-deftest org-texmacs-test-package-loads ()
  (should (featurep 'org-texmacs)))

(ert-deftest org-texmacs-test-setup-check-passes ()
  (let ((result (org-texmacs-check-setup)))
    (should (car result))
    (should (stringp (cdr result)))))

(ert-deftest org-texmacs-test-capability-types ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (command)
               (and (string= command "texmacs")
                    "/test/bin/texmacs"))))
    (let ((result
           (org-texmacs--check-capabilities
            '((org-element-create . function)
              (features . variable)
              (texmacs . executable)))))
      (should (car result)))))

(ert-deftest org-texmacs-test-capability-check-reports-all-failures ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (_command)
               nil)))
    (let ((result
           (org-texmacs--check-capabilities
            '((org-texmacs-test--missing-function . function)
              (org-texmacs-test--missing-variable . variable)
              (org-texmacs-test--missing-executable . executable)
              (org-element-create . unsupported)))))
      (should-not (car result))
      (dolist (name '(org-texmacs-test--missing-function
                      org-texmacs-test--missing-variable
                      org-texmacs-test--missing-executable
                      org-element-create))
        (should (string-match-p (regexp-quote (symbol-name name))
                                (cdr result)))))))

(ert-deftest org-texmacs-test-capability-check-rejects-malformed-input ()
  (let ((result (org-texmacs--check-capabilities
                 '(org-element-create . function))))
    (should-not (car result))
    (should (string-match-p "malformed"
                            (cdr result)))))

(ert-deftest org-texmacs-test-ensure-setup-signals-error ()
  (let ((org-texmacs--capability-alist
         '((org-texmacs-test--missing-function . function))))
    (should-error (org-texmacs--ensure-setup)
                  :type 'org-texmacs-error)))

;;; ert.el ends here
