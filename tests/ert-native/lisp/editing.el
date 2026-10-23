;;; editing.el --- native editing regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-font-lock-existing-buffer-fresh-load ()
  (dolist (enabled '(t nil))
    (org-texmacs-test--menu-fresh-process
     `(progn
        (set-default 'org-texmacs--font-lock-enabled ,enabled)
        (with-temp-buffer
          (rename-buffer (generate-new-buffer-name "font-lock-existing"))
          (org-mode) (insert "(math \"x\")\n")
          (let ((noninteractive nil)) (font-lock-mode 1))
          (require 'org-texmacs)
          (should (eq font-lock-fontify-region-function #'org-texmacs--font-lock-region))
          (should (eq (default-value 'org-texmacs--font-lock-enabled) ,enabled))
          (font-lock-ensure)
          (let ((face (get-text-property 8 'face)))
            (should (eq (and (memq 'font-lock-string-face
                                    (if (listp face) face (list face))) t)
                        ,enabled))))))))

;;; editing.el ends here
