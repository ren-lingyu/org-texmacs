;;; document-config-check.el --- Configuration probe -*- lexical-binding: t; -*-
(require 'org-texmacs)
(with-temp-buffer
  (let ((org-todo-keywords '((sequence "WAIT" "|" "DONE"))))
    (org-mode))
  (insert "* WAIT Task\n")
  (princ (format "native-todo=%S\n"
                 (org-element-map (org-element-parse-buffer) 'headline
                   (lambda (node) (org-element-property :todo-keyword node)))))
  (condition-case err
      (princ (format "document=%S\n"
                     (org-texmacs-document-body (org-texmacs-document))))
    (error (princ (format "document-error=%S\n" err)))))
(dolist (function '(org-element-headline-parser org-element-parse-buffer
                    org-set-regexps-and-options))
  (princ (format "%S: %s\n" function (symbol-file function 'defun))))
