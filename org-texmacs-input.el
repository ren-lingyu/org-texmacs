;;; org-texmacs-input.el --- Prepared inputs for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Owned snapshots for structural lowering, independent of source buffers.

;;; Code:

(require 'org-texmacs-document)

(cl-defstruct (org-texmacs-input
               (:constructor org-texmacs--input-create)
               (:copier nil))
  "Prepared structural input.  Treat all slots and nested data as read-only.
AST and its identity-keyed ISLANDS and POST-BLANKS belong to this snapshot.
INFO contains fixed context and prepared views, not a request to collect source configuration.
STYLE and INITIAL are copied TeXmacs document settings.
SOURCE-FILE is optional source identity; RESOURCE-BASE is the optional
fixed base for source-relative resources.  Neither is inferred from the other.
BIBLIOGRAPHY owns parsed BibTeX dependency trees keyed by source identity;
these native source-semantic trees are separate from the Org AST and islands."
  (ast nil :read-only t)
  (info nil :read-only t)
  (islands nil :read-only t)
  (post-blanks nil :read-only t)
  (style nil :read-only t)
  (initial nil :read-only t)
  (source-file nil :read-only t)
  (resource-base nil :read-only t)
  (bibliography nil :read-only t))

(defun org-texmacs--bibliography-copy (bibliography)
  "Validate and own prepared BIBLIOGRAPHY without parsing or file access.
Each entry maps an explicit absolute source path to a parsed BibTeX document
stree.  Reject duplicate paths and citation keys across the complete snapshot."
  (unless (proper-list-p bibliography)
    (signal 'org-texmacs-document-error '("Expected a bibliography alist")))
  (let (paths keys result)
    (dolist (source bibliography)
      (unless (and (consp source) (stringp (car source)))
        (signal 'org-texmacs-document-error '("Invalid bibliography source")))
      (let ((path (org-texmacs--source-copy-path (car source)))
            (tree (org-texmacs--document-copy-stree (cdr source))))
        (when (member path paths)
          (signal 'org-texmacs-document-error '("Duplicate bibliography path")))
        (push path paths)
        (unless (and (consp tree) (eq (car tree) 'document))
          (signal 'org-texmacs-document-error '("Expected a parsed bibliography document")))
        (dolist (entry (cdr tree))
          (unless (and (consp entry) (eq (car entry) 'bib-entry) (= (length entry) 4)
                       (stringp (nth 1 entry)) (> (length (nth 1 entry)) 0)
                       (stringp (nth 2 entry)) (> (length (nth 2 entry)) 0)
                       (consp (nth 3 entry)) (eq (car (nth 3 entry)) 'document))
            (signal 'org-texmacs-document-error '("Invalid parsed bibliography entry")))
          (when (member (nth 2 entry) keys)
            (signal 'org-texmacs-document-error '("Duplicate bibliography key")))
          (push (nth 2 entry) keys)
          (let (fields)
            (dolist (field (cdr (nth 3 entry)))
              (unless (and (consp field) (eq (car field) 'bib-field) (= (length field) 3)
                           (stringp (nth 1 field)) (> (length (nth 1 field)) 0)
                           (not (member-ignore-case (nth 1 field) fields)))
                (signal 'org-texmacs-document-error '("Invalid or duplicate bibliography field")))
              (push (nth 1 field) fields))))
        (push (cons path tree) result)))
    (nreverse result)))

;;;###autoload
(cl-defun org-texmacs-input-create
    (ast info &key islands post-blanks (style '("generic")) initial
         source-file resource-base bibliography)
  "Copy AST, INFO, mappings and explicit document context into an owned input.
AST must be a fully parsed `org-data' tree, not Org's live cache.  Do not
resolve deferred properties, read buffers, discover STM or run a formatter.
ISLANDS maps AST node identities to already parsed text strees; POST-BLANKS
maps inline node identities to trailing spaces/tabs.  See the preparation
contract of `org-texmacs--document-lower'.  Unsupported lowering is diagnosed
by `org-texmacs-document', not by invoking it during this copy.

STYLE is a nonempty list of TeXmacs style identifier strings and defaults to
`(\"generic\")'.  INITIAL is an alist of unique nonempty environment identifier
strings to source-semantic text strees and defaults to nil.  Neither setting
is inferred from INFO or ambient Custom values.

SOURCE-FILE and RESOURCE-BASE are optional explicit absolute path strings,
copied without filesystem access or path expansion.  RESOURCE-BASE fixes
the source-relative resource base; SOURCE-FILE does not override it.  Omitted
values remain nil and are never inferred from the current buffer.

BIBLIOGRAPHY is an alist from explicit absolute source paths to already parsed
BibTeX document strees.  Copy its text trees and reject duplicate source paths,
keys or fields.  Never read those paths or parse source text here.  This slot
establishes prepared data ownership.  Citation lowering also requires fixed
INFO declaration identities and a prepared output view for bibliography print.
The view binds prefix, key order, selected entry trees and source-semantic body;
pure lowering verifies that it matches the current resolution plan.

Copy strings, lists and vectors, rebuild parent links, and remap references
to AST nodes in INFO and the mappings.  Copy parsed title, author and date
secondary strings as separately owned Org objects.  Reject cyclic or multiply
owned AST nodes, detached/duplicate mapping keys, deferred values and opaque
objects.
Discard Org's source buffer and parent bookkeeping.  INFO must be a plist
with unique keyword keys; nil selects fixed lowering defaults.  A supplied
headline formatter is resolved now and retained as an opaque function;
mutable state captured by a user closure is not frozen.  Never mutate the
returned input, its accessors' values, or arguments from a formatter."
  (unless (and (consp ast) (eq (car ast) 'org-data))
    (signal 'org-texmacs-document-error '("Expected a prepared Org document AST")))
  (unless (and (proper-list-p info) (zerop (% (length info) 2)))
    (signal 'org-texmacs-document-error '("Expected an options plist")))
  (let ((nodes (make-hash-table :test #'eq)) pending)
    (cl-labels
        ((fail (message)
           (signal 'org-texmacs-document-error (list message)))
         (data (value &optional ancestors)
           (cond
            ((gethash value nodes))
            ((stringp value) (substring-no-properties value))
            ((or (null value) (symbolp value) (numberp value)) value)
            ((memq value ancestors) (fail "Cyclic snapshot data"))
            ((consp value)
             (cons (data (car value) (cons value ancestors))
                   (data (cdr value) (cons value ancestors))))
            ((vectorp value)
             (apply #'vector
                    (mapcar (lambda (item) (data item (cons value ancestors))) value)))
            (t (fail "Opaque or deferred snapshot value"))))
         (node (old parent)
           (when (gethash old nodes) (fail "Cyclic or multiply owned AST node"))
           (cond
            ((stringp old)
             (let ((new (substring-no-properties old)))
               (puthash old new nodes)
               (org-element-put-property new :parent parent)
               new))
            ((and (consp old) (car old) (symbolp (car old))
                  (proper-list-p old) (cdr old)
                  (proper-list-p (cadr old))
                  (zerop (% (length (cadr old)) 2)))
             (when (org-element-property-raw :deferred old)
               (fail "Expected fully resolved Org properties"))
             (let* ((new (org-element-create (car old) nil))
                    (secondary (org-element-property-raw :secondary old))
                    (keys (cdr (assq (car old) org-element-secondary-value-alist))))
               (unless (and (proper-list-p secondary)
                            (cl-every #'keywordp secondary))
                 (fail "Invalid secondary property list"))
               (setq keys (delete-dups (append secondary keys nil)))
               (puthash old new nodes)
               (org-element-put-property new :parent parent)
               (org-element-properties-mapc
                (lambda (key value _owner)
                  (cond
                   ((memq key '(:parent :buffer :deferred :secondary)))
                   ((memq key keys)
                    (unless (proper-list-p value)
                      (fail "Expected parsed secondary objects"))
                    (org-element-put-property
                     new key (mapcar (lambda (child) (node child new)) value)))
                   (t (push (list new key value) pending))))
                old)
               (when keys (org-element-put-property new :secondary keys))
               (apply #'org-element-set-contents
                      new (mapcar (lambda (child) (node child new)) (cddr old)))
               new))
            (t (fail "Invalid Org AST node"))))
         (mapping (entries copy-value)
           (unless (proper-list-p entries) (fail "Expected an identity-keyed alist"))
           (let (seen)
             (mapcar
              (lambda (entry)
                (unless (and (consp entry) (gethash (car entry) nodes)
                             (not (memq (car entry) seen)))
                  (fail "Detached or duplicate mapping key"))
                (push (car entry) seen)
                (cons (gethash (car entry) nodes) (funcall copy-value (cdr entry))))
              entries)))
         (secondary (value)
           (unless (proper-list-p value)
             (fail "Expected parsed metadata objects"))
           (let ((copy (mapcar (lambda (child) (node child nil)) value)))
             (dolist (child copy)
               (org-element-put-property child :parent copy))
             copy)))
      (let ((new-ast (node ast nil)) new-info seen)
        (setq info (or info '(:with-todo-keywords t :with-priority nil :with-tags t
                             :texmacs-format-headline-function
                             org-texmacs-format-headline-default-function)))
        (while info
          (let ((key (pop info)) (value (pop info)))
            (unless (and (keywordp key) (not (memq key seen)))
              (fail "Invalid or duplicate options key"))
            (push key seen)
            (when (eq key :texmacs-format-headline-function)
              (setq value (indirect-function value))
              (unless (functionp value) (fail "Invalid headline formatter")))
            (setq new-info
                  (append new-info
                          (list key
                                (cond
                                 ((eq key :texmacs-format-headline-function) value)
                                 ((memq key '(:title :author :date)) (secondary value))
                                 (t (data value))))))))
        ;; INFO secondary strings create their nodes after the AST copy.  Apply
        ;; pending properties only after both ownership domains are complete.
        (dolist (entry pending)
          (org-element-put-property (nth 0 entry) (nth 1 entry) (data (nth 2 entry))))
        (org-texmacs--input-create
         :ast new-ast :info new-info
         :islands (mapping islands #'org-texmacs--document-copy-stree)
         :style (org-texmacs--document-copy-style style)
         :initial (org-texmacs--document-copy-initial initial)
         :source-file (org-texmacs--source-copy-path source-file)
         :resource-base (org-texmacs--source-copy-path resource-base)
         :bibliography (org-texmacs--bibliography-copy bibliography)
         :post-blanks
         (mapping post-blanks
                  (lambda (value)
                    (unless (and (stringp value)
                                 (string-match-p "\\`[ \t]*\\'" value))
                      (fail "Expected trailing spaces or tabs"))
                    (substring-no-properties value))))))))

(provide 'org-texmacs-input)
;;; org-texmacs-input.el ends here
