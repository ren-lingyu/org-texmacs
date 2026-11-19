;;; serialization.el --- pdf serialization regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest
    org-texmacs-serialization-export-explicit-command-boundary
    ()
  (dolist (function
           '(org-texmacs-export-to-buffer
             org-texmacs-export-to-texmacs-file
             org-texmacs-export-to-pdf-file
             org-texmacs-export-texmacs-from-buffer
             org-texmacs-export-pdf-from-buffer))
    (should-not (commandp function))
    (should-error (call-interactively function)))
  (with-temp-buffer
    (should-error
     (org-texmacs-export-to-buffer (current-buffer))
     :type 'org-texmacs-document-error)))

;;; serialization.el ends here
