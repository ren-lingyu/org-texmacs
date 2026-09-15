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
INFO contains fixed options, not a request to collect source configuration."
  (ast nil :read-only t)
  (info nil :read-only t)
  (islands nil :read-only t)
  (post-blanks nil :read-only t))

;;;###autoload
(cl-defun org-texmacs-input-create (ast info &key islands post-blanks)
  "Copy prepared AST, INFO, ISLANDS and POST-BLANKS into an owned input.
AST must be a fully parsed `org-data' tree, not Org's live cache.  Do not
resolve deferred properties, read buffers, discover STM or run a formatter.
ISLANDS maps AST node identities to already parsed text strees; POST-BLANKS
maps inline node identities to trailing spaces/tabs.  See the preparation
contract of `org-texmacs--document-lower'.  Unsupported lowering is diagnosed
by `org-texmacs-document', not by invoking it during this copy.

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
        (dolist (entry pending)
          (org-element-put-property (nth 0 entry) (nth 1 entry) (data (nth 2 entry))))
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
        (org-texmacs--input-create
         :ast new-ast :info new-info
         :islands (mapping islands #'org-texmacs--document-copy-stree)
         :post-blanks
         (mapping post-blanks
                  (lambda (value)
                    (unless (and (stringp value)
                                 (string-match-p "\\`[ \t]*\\'" value))
                      (fail "Expected trailing spaces or tabs"))
                    (substring-no-properties value))))))))

(provide 'org-texmacs-input)
;;; org-texmacs-input.el ends here
