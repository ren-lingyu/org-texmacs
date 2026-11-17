;;; versions.el --- verify minimum-version module origins -*- lexical-binding: t; -*-
(setq load-prefer-newer t)
(require 'org)
(require 'org-element)
(require 'ox)
(let ((root (file-truename (expand-file-name "tmp/stm-e7/org98/" default-directory))) rows)
  (dolist (sym '(org-mode org-element-parse-buffer org-element-map org-element-class
                org-element-create org-element-copy org-element-interpret-data org-export-as))
    (let ((file (symbol-file sym 'defun)))
      (unless (and file (file-in-directory-p file root)) (error "Mixed Org version: %s %s" sym file))
      (push (cons sym file) rows)))
  (with-temp-file "tmp/stm-e7/module-origins.sexp"
    (prin1 (list :emacs emacs-version :org (org-version) :modules rows) (current-buffer))))
