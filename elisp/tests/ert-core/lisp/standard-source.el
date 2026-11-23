;;; standard-source.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'org)
(require 'ox)

(require 'ox-texmacs)

(ert-deftest
    org-texmacs-standard-source-invalid-arguments-before-effects
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* One\nFirst.\n* Two\nSecond.\n")
    (goto-char (point-min))
    (search-forward "Second.")
    (let ((region (cons (- (point) 7) (point)))
          (org-export-before-processing-functions
           (list
            (lambda (_)
              (ert-fail "Invalid request ran preparation")))))
      (should-error
       (org-texmacs-export-texmacs-from-buffer
        (current-buffer) nil 1 region nil)
       :type 'org-texmacs-document-error)
      (should-error
       (org-texmacs-export-texmacs-from-buffer
        (current-buffer) '(("x" . "text")) nil nil nil)
       :type 'org-texmacs-document-error)
      (should-error
       (org-texmacs-export-texmacs-from-buffer "name" nil nil nil nil)
       :type 'org-texmacs-document-error))))

;;; standard-source.el ends here
