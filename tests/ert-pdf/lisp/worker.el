;;; worker.el --- pdf worker regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-test-package-loads ()
  (should-not org-texmacs-test--worker-loaded-document)
  (should
   (equal
    (file-name-base
     (symbol-file 'org-texmacs--native-document-wire 'defun))
    "org-texmacs-session"))
  (let ((directory
         (file-name-directory (locate-library "org-texmacs"))))
    (dolist (feature
             '(org-texmacs
               org-texmacs-core
               org-texmacs-ast
               org-texmacs-source
               org-texmacs-fragment
               org-texmacs-font-lock
               org-texmacs-edit
               org-texmacs-document
               org-texmacs-input
               org-texmacs-context
               org-texmacs-worker
               org-texmacs-session))
      (should (featurep feature))
      (let ((library (locate-library (symbol-name feature))))
        (should library)
        (should (equal directory (file-name-directory library)))))
    (should
     (equal
      org-texmacs--worker-scheme-file
      (expand-file-name "org-texmacs-worker.scm" directory)))
    (should (file-readable-p org-texmacs--worker-scheme-file)))
  (dolist (function
           '(org-texmacs-fragment-at-point
             org-texmacs-fragment-map
             org-texmacs-fragment-tree
             org-texmacs-fragment-span-p
             org-texmacs-document
             org-texmacs-document-current-buffer
             org-texmacs-document-from-buffer
             org-texmacs-prepare-buffer
             org-texmacs-input-create
             org-texmacs-input-p
             org-texmacs-input-ast
             org-texmacs-input-info
             org-texmacs-input-islands
             org-texmacs-input-post-blanks
             org-texmacs-input-style
             org-texmacs-input-initial
             org-texmacs-input-source-file
             org-texmacs-input-resource-base
             org-texmacs-input-bibliography
             org-texmacs-document-body
             org-texmacs-document-style
             org-texmacs-document-initial
             org-texmacs-document-stm-paths
             org-texmacs-document-source-file
             org-texmacs-document-resource-base
             org-texmacs-document-file-paths
             org-texmacs-document-serialize
             org-texmacs-document-save
             org-texmacs-export-texmacs-from-buffer
             org-texmacs-export-to-texmacs-file
             org-texmacs-export-to-buffer
             org-texmacs-document-pdf
             org-texmacs-document-save-pdf
             org-texmacs-export-pdf-from-buffer
             org-texmacs-export-to-pdf-file
             org-texmacs-session-open
             org-texmacs-session-set-document
             org-texmacs-session-close))
    (should (fboundp function))
    (should
     (equal
      (file-name-directory (symbol-file function 'defun))
      (file-name-directory (locate-library "org-texmacs"))))))

;;; worker.el ends here
