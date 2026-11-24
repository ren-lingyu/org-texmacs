;;; org-texmacs-syntax.el --- Owned Org syntax snapshots -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-
;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Commentary:
;; Capture resolved native syntax without a worker or full model construction.
;;; Code:
(require 'org)
(require 'org-texmacs-model)
(defconst org-texmacs--parse-syntax-variables
  '(org-todo-regexp
    org-todo-keywords
    org-todo-keywords-1
    org-done-keywords
    org-odd-levels-only
    org-priority-regexp
    org-priority-highest
    org-priority-lowest
    org-priority-default
    org-footnote-section
    org-emph-re
    org-verbatim-re
    org-match-substring-regexp
    org-match-substring-with-braces-regexp
    org-entities-user
    org-list-allow-alphabetical
    org-plain-list-ordered-item-terminator
    org-element-affiliated-keywords
    org-element-dual-keywords
    org-element-parsed-keywords
    org-element-multiple-keywords
    org-element-secondary-value-alist
    org-element-keyword-translation-alist
    org-target-link-regexp
    org-target-link-regexps)
  "Effective native syntax retained independently of export configuration.
Only bound variables are captured.  Link types and abbreviations are handled
separately; link follow/export handlers are not syntax and are not captured.")

(defun org-texmacs--syntax-heading-settings ()
  "Copy effective Org heading parser settings for transfer and comparison.
Keep TODO regexp, DONE keywords, odd-level policy and priority regexp.
Copy strings as well as lists so in-place edits invalidate the snapshot.
Capture `org-footnote-section' so special footnote headings use source policy.
Do not rebuild effective values from TODO declarations or file keywords."
  (unless (and (or (null org-todo-regexp) (stringp org-todo-regexp))
               (proper-list-p org-done-keywords)
               (cl-every #'stringp org-done-keywords)
               (stringp org-priority-regexp)
               (or (null org-footnote-section)
                   (stringp org-footnote-section)))
    (signal 'org-texmacs-document-error
            '("Invalid Org heading settings")))
  (list
   (and org-todo-regexp (substring-no-properties org-todo-regexp))
   (mapcar #'substring-no-properties org-done-keywords)
   (and org-odd-levels-only t)
   (substring-no-properties org-priority-regexp)
   (and org-footnote-section
        (substring-no-properties org-footnote-section))))

(defun org-texmacs--syntax-use-heading-settings (settings)
  "Install copied heading SETTINGS in the private Org parser buffer.
Call after `org-mode' initialization and before parsing any source.  Keep
buffer-local copies separate from the caller's snapshot and source buffer."
  (setq-local org-todo-regexp
              (and (nth 0 settings)
                   (substring-no-properties (nth 0 settings))))
  (setq-local org-done-keywords
              (mapcar #'substring-no-properties (nth 1 settings)))
  (setq-local org-odd-levels-only (nth 2 settings))
  (setq-local org-priority-regexp
              (substring-no-properties (nth 3 settings)))
  (setq-local org-footnote-section
              (and (nth 4 settings)
                   (substring-no-properties (nth 4 settings)))))

(defun org-texmacs--syntax-copy (value)
  "Return independently owned resolved syntax VALUE."
  (org-texmacs--model-copy-data
   (org-texmacs--model-owner-create) value))

(defun org-texmacs--parse-settings ()
  "Capture effective native Org syntax as explicit variable/value pairs."
  (mapcar
   (lambda (symbol)
     (cons symbol (org-texmacs--syntax-copy (symbol-value symbol))))
   (cl-remove-if-not #'boundp org-texmacs--parse-syntax-variables)))

(defun org-texmacs--parse-links ()
  "Capture link names and abbreviations without retaining handler functions."
  (unless (and (proper-list-p org-link-parameters)
               (cl-every
                (lambda (entry)
                  (and (consp entry) (stringp (car entry))))
                org-link-parameters))
    (signal 'org-texmacs-model-error '("Invalid Org link registry")))
  (org-texmacs--syntax-copy
   (list
    :types (mapcar #'car org-link-parameters)
    :global org-link-abbrev-alist
    :local org-link-abbrev-alist-local)))

(defun org-texmacs--syntax-capture ()
  "Capture native syntax for the temporary Org recognition tree's root."
  (list
   :heading-settings (org-texmacs--parse-settings)
   :link-settings (org-texmacs--parse-links)))

(provide 'org-texmacs-syntax)
;;; org-texmacs-syntax.el ends here
