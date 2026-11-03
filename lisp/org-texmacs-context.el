;;; org-texmacs-context.el --- Owned export context schema -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Supported context fields and pure structural/naming helpers.  Org owns
;; preparation, selection and option precedence; no parallel export lifecycle.

;;; Code:

(require 'org-texmacs-core)
(require 'org-texmacs-source)

(defconst org-texmacs--context-rich-metadata
  '(:title :subtitle :author :date)
  "Fields owned as parsed Org secondary strings.")

(defconst org-texmacs--context-plain-metadata
  '(:email :language :keywords :description :creator)
  "Fields owned as literal text, without STM or inline discovery.")

(defun org-texmacs--context-metadata-keys ()
  "Return all supported metadata keys."
  (append
   org-texmacs--context-rich-metadata
   org-texmacs--context-plain-metadata))

(defun org-texmacs--context-metadata-name (key)
  "Return the source keyword for metadata KEY."
  (upcase (substring (symbol-name key) 1)))

(defconst org-texmacs--context-export-options
  '(:title
    :subtitle
    :email
    :language
    :keywords
    :description
    :creator
    :date
    :author
    :select-tags
    :exclude-tags
    :headline-levels
    :section-numbers
    :with-archived-trees
    :with-author
    :with-date
    :with-email
    :with-creator
    :with-entities
    :with-priority
    :with-toc
    :with-tags
    :with-tasks
    :with-title
    :with-todo-keywords)
  "Supported fields projected from final Org Export INFO, without merging.")

(defconst org-texmacs--context-source-keywords
  '("OPTIONS"
    "TODO"
    "SEQ_TODO"
    "TYP_TODO"
    "PRIORITIES"
    "FILETAGS"
    "TITLE"
    "SUBTITLE"
    "EMAIL"
    "LANGUAGE"
    "DESCRIPTION"
    "CREATOR"
    "DATE"
    "AUTHOR"
    "SELECT_TAGS"
    "EXCLUDE_TAGS"
    "EXPORT_FILE_NAME")
  "Org keywords consumed by the standard preparation context.
KEYWORDS stays in the AST for independent positional presentation.")

(defun org-texmacs--context-subtree-settings ()
  "Own the source's property lookup settings used by subtree export."
  (org-texmacs--context-copy
   (list
    org-use-property-inheritance
    org-property-separators
    org-global-properties
    org-global-properties-fixed)))

(defun org-texmacs--context-copy (value)
  "Copy configuration VALUE without retaining mutable strings or conses."
  (cond
   ((stringp value)
    (substring-no-properties value))
   ((consp value)
    (cons
     (org-texmacs--context-copy (car value))
     (org-texmacs--context-copy (cdr value))))
   ((vectorp value)
    (apply #'vector (mapcar #'org-texmacs--context-copy value)))
   (t
    value)))

(defun org-texmacs--context-footnote-definitions (ast islands)
  "Collect named definition nodes from AST without entering ISLANDS.
Keep parsed nodes, including inline definitions, rather than source spans."
  (let (definitions)
    (cl-labels
     ((walk
       (node ancestors)
       (when (and (consp node)
                  (not (assq node islands))
                  (not (org-texmacs--native-body-kind node)))
         (when (memq node ancestors)
           (signal 'org-texmacs-document-error
                   '("Cyclic footnote definition tree")))
         (when (and (or (eq
                         (org-element-type node) 'footnote-definition)
                        (and (eq
                              (org-element-type node)
                              'footnote-reference)
                             (eq
                              (org-element-property :type node)
                              'inline)))
                    (org-element-property :label node))
           (push node definitions))
         (let ((ancestors (cons node ancestors)))
           (when (eq (org-element-type node) 'headline)
             (mapc
              (lambda (child) (walk child ancestors))
              (org-element-property :title node)))
           (mapc
            (lambda (child) (walk child ancestors))
            (org-element-contents node))))))
     (walk ast nil))
    (nreverse definitions)))

(provide 'org-texmacs-context)
;;; org-texmacs-context.el ends here
