;;; org-texmacs-model.el --- Mathematical-document snapshots -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Own native Org trees and parsed STM islands without source buffers,
;; document lowering, export configuration or native worker operations.
;; Nested objects are read-only by convention, not protected from mutation.

;;; Code:

(require 'org-texmacs-core)

(cl-defstruct
 (org-texmacs-model
  (:constructor org-texmacs--model-create) (:copier nil))
 "Owned mathematical-document snapshot; all nested data is read-only.
AST is a native Org org-data tree.  ISLANDS associates nodes in that tree
with authoritative parsed STM trees.  CONTEXT contains explicit syntax/source
context, not export INFO, document settings or derived output state.
Accessors return internal read-only references.  A read-only slot does not
prevent mutation of nested strings, conses or vectors."
 (ast nil :read-only t)
 (islands nil :read-only t)
 (context nil :read-only t))

(defconst org-texmacs--model-context-keys
  '(:fragment-tags
    :heading-settings
    :link-settings
    :source-file
    :resource-base)
  "Explicit syntax/source context keys, excluding export configuration.
The buffer adapter will capture effective syntax settings.  This module only
owns supplied resolved data; it does not infer settings or interpret options.")

(cl-defstruct
 (org-texmacs--model-owner
  (:constructor org-texmacs--model-owner-create) (:copier nil))
 "Private copying transaction shared with export input ownership."
 (nodes (make-hash-table :test #'eq))
 pending
 (error-type 'org-texmacs-model-error)
 (caption-reader #'org-texmacs--model-caption-lines))

(defun org-texmacs--model-fail (owner message)
  "Signal OWNER's error condition with MESSAGE."
  (signal (org-texmacs--model-owner-error-type owner) (list message)))

(defun org-texmacs--model-copy-stree
    (tree &optional error-type ancestors)
  "Validate and copy STM TREE without native parsing.
ERROR-TYPE defaults to `org-texmacs-model-error'.  ANCESTORS detects cycles;
noncyclic repeated subtrees are copied independently."
  (cond
   ((stringp tree)
    (substring-no-properties tree))
   ((and (consp tree)
         (car tree)
         (symbolp (car tree))
         (proper-list-p tree)
         (not (memq tree ancestors)))
    (cons
     (car tree)
     (mapcar
      (lambda (child)
        (org-texmacs--model-copy-stree child
                                       error-type
                                       (cons tree ancestors)))
      (cdr tree))))
   (t
    (signal (or error-type 'org-texmacs-model-error)
            '("Invalid island stree")))))

(defun org-texmacs--model-copy-data (owner value &optional ancestors)
  "Copy resolved VALUE, remapping known Org identities through OWNER.
Reject cycles and opaque runtime objects.  Strip text properties from data
strings; structural text nodes get their rebuilt parent from the node copier."
  (cond
   ((gethash value (org-texmacs--model-owner-nodes owner)))
   ((stringp value)
    (substring-no-properties value))
   ((or (null value) (symbolp value) (numberp value))
    value)
   ((memq value ancestors)
    (org-texmacs--model-fail owner "Cyclic snapshot data"))
   ((consp value)
    (cons
     (org-texmacs--model-copy-data owner (car value)
                                   (cons value ancestors))
     (org-texmacs--model-copy-data owner (cdr value)
                                   (cons value ancestors))))
   ((vectorp value)
    (apply #'vector
           (mapcar
            (lambda (item)
              (org-texmacs--model-copy-data owner item
                                            (cons value ancestors)))
            value)))
   (t
    (org-texmacs--model-fail
     owner "Opaque or deferred snapshot value"))))

(defun org-texmacs--model-caption-lines (node)
  "Return structurally valid parsed caption pairs from NODE.
Empty secondary strings are valid here; consumer-specific caption policies
belong to consumers.  Never consult a source buffer."
  (let ((caption (org-element-property-raw :caption node)))
    (unless (and (proper-list-p caption)
                 (cl-every
                  (lambda (line)
                    (and (consp line)
                         (proper-list-p (car line))
                         (proper-list-p (cdr line))))
                  caption))
      (signal 'org-texmacs-model-error '("Invalid parsed caption")))
    caption))

(defun org-texmacs--model-copy-node (owner old parent)
  "Copy Org node OLD into OWNER, rebuilding its PARENT association.
Secondary strings and captions are owned structural nodes too.  Copy other
properties after all structural identities have been registered."
  (let ((nodes (org-texmacs--model-owner-nodes owner)))
    (when (gethash old nodes)
      (org-texmacs--model-fail
       owner "Cyclic or multiply owned AST node"))
    (cond
     ((stringp old)
      (let ((new (substring-no-properties old)))
        (puthash old new nodes)
        (org-element-put-property new :parent parent)
        new))
     ((and (consp old)
           (car old)
           (symbolp (car old))
           (proper-list-p old)
           (cdr old)
           (proper-list-p (cadr old))
           (zerop (% (length (cadr old)) 2)))
      (let (seen)
        (cl-loop
         for (key _value) on (cadr old) by #'cddr do
         (unless (and (keywordp key) (not (memq key seen)))
           (org-texmacs--model-fail
            owner "Invalid or duplicate Org property key"))
         (push key seen)))
      (when (org-element-property-raw :deferred old)
        (org-texmacs--model-fail
         owner "Expected fully resolved Org properties"))
      (let* ((new (org-element-create (car old) nil))
             (secondary (org-element-property-raw :secondary old))
             (keys
              (cdr
               (assq (car old) org-element-secondary-value-alist))))
        (unless (and (proper-list-p secondary)
                     (cl-every #'keywordp secondary))
          (org-texmacs--model-fail
           owner "Invalid secondary property list"))
        (setq keys (delete-dups (append secondary keys nil)))
        (puthash old new nodes)
        (org-element-put-property new :parent parent)
        (org-element-properties-mapc
         (lambda (key value _owner)
           (cond
            ((memq key '(:parent :buffer :deferred :secondary)))
            ((eq key :caption)
             (org-element-put-property
              new key
              (mapcar
               (lambda (line)
                 (cons
                  (mapcar
                   (lambda
                     (child)
                     (org-texmacs--model-copy-node owner child new))
                   (car line))
                  (mapcar
                   (lambda
                     (child)
                     (org-texmacs--model-copy-node owner child new))
                   (cdr line))))
               (funcall
                (org-texmacs--model-owner-caption-reader owner)
                old))))
            ((memq key keys)
             (unless (proper-list-p value)
               (org-texmacs--model-fail
                owner "Expected parsed secondary objects"))
             (org-element-put-property
              new key
              (mapcar
               (lambda (child)
                 (org-texmacs--model-copy-node owner child new))
               value)))
            (t
             (push (list new key value)
                   (org-texmacs--model-owner-pending owner)))))
         old)
        (when keys
          (org-element-put-property new :secondary keys))
        (apply #'org-element-set-contents
               new
               (mapcar
                (lambda (child)
                  (org-texmacs--model-copy-node owner child new))
                (cddr old)))
        new))
     (t
      (org-texmacs--model-fail owner "Invalid Org AST node")))))

(defun org-texmacs--model-copy-secondary (owner value)
  "Own separate parsed secondary string VALUE through OWNER."
  (unless (proper-list-p value)
    (org-texmacs--model-fail
     owner "Expected parsed metadata objects"))
  (let ((copy
         (mapcar
          (lambda (child)
            (org-texmacs--model-copy-node owner child nil))
          value)))
    (dolist (child copy)
      (org-element-put-property child :parent copy))
    copy))

(defun org-texmacs--model-finish-owner (owner)
  "Copy OWNER's pending properties after all Org nodes are registered."
  (dolist (entry (org-texmacs--model-owner-pending owner))
    (org-element-put-property
     (nth 0 entry)
     (nth 1 entry)
     (org-texmacs--model-copy-data owner (nth 2 entry))))
  (setf (org-texmacs--model-owner-pending owner) nil))

(defun org-texmacs--model-copy-mapping (owner entries copy-value)
  "Own identity-keyed ENTRIES with OWNER and COPY-VALUE.
All keys must be distinct registered nodes.  Return keys in the copied tree."
  (unless (proper-list-p entries)
    (org-texmacs--model-fail
     owner "Expected an identity-keyed alist"))
  (let ((seen (make-hash-table :test #'eq)))
    (mapcar
     (lambda (entry)
       (unless (and (consp entry)
                    (gethash
                     (car entry)
                     (org-texmacs--model-owner-nodes owner))
                    (not (gethash (car entry) seen)))
         (org-texmacs--model-fail
          owner "Detached or duplicate mapping key"))
       (puthash (car entry) t seen)
       (cons
        (gethash
         (car entry) (org-texmacs--model-owner-nodes owner))
        (funcall copy-value (cdr entry))))
     entries)))

(defun org-texmacs--model-check-islands
    (ast islands &optional error-type)
  "Reject overlapping island associations in owned AST and ISLANDS.
Inspect contents, captions and secondary properties without reading source."
  (let ((keys (make-hash-table :test #'eq)))
    (dolist (entry islands)
      (puthash (car entry) t keys))
    (cl-labels
     ((walk
       (node enclosing)
       (let ((island (gethash node keys)))
         (when (and island enclosing)
           (signal (or error-type 'org-texmacs-model-error)
                   '("Overlapping STM islands")))
         (when (consp node)
           (let ((inside (or island enclosing)))
             (dolist (child (org-element-contents node))
               (walk child inside))
             (dolist (key (org-element-property-raw :secondary node))
               (unless (eq key :caption)
                 (dolist (child (org-element-property-raw key node))
                   (walk child inside)))))
           ;; Affiliated captions belong outside a block's raw body.
           (dolist (line (org-element-property-raw :caption node))
             (dolist (child (car line))
               (walk child enclosing))
             (dolist (child (cdr line))
               (walk child enclosing)))))))
     (walk ast nil))))

;;;###autoload
(cl-defun
 org-texmacs-model-create (ast &key islands context)
 "Own native Org AST, parsed STM ISLANDS and explicit CONTEXT.
AST must be a fully resolved org-data tree, not Org's live cache.  ISLANDS
maps distinct AST node identities to parsed STM trees (strings or proper
symbol-tagged trees).  Trees are authoritative for the mathematical content;
Org nodes retain the structural wrapper and affiliation.  Nested island
contents cannot overlap.  Secondary strings and captions belong to the AST.

CONTEXT is a unique-keyword plist of resolved syntax/source data with keys
:fragment-tags, :heading-settings, :link-settings, :source-file or
:resource-base.
Do not supply export INFO, style, initial, formatted bibliography or output
references.  No context is inferred from the current buffer.
Copy strings, lists and vectors, rebuild parents and
remap structural identities.  Reject cycles, multiply owned nodes, detached or
duplicate mappings, deferred values and opaque runtime objects.

This is structural validation, not a source scan, recognition-completeness
check, serialization promise or target-format check.  A valid island may be
inexpressible under current Org recognition syntax.  No parser, source buffer,
worker, document lowering, reference allocation or formatter is consulted.
Return a read-only snapshot: callers must not modify accessor results or
nested data.  Signal `org-texmacs-model-error' for invalid inputs."
 (unless (and (consp ast) (eq (car ast) 'org-data))
   (signal 'org-texmacs-model-error
           '("Expected an Org org-data AST")))
 (unless (and (proper-list-p context) (zerop (% (length context) 2)))
   (signal 'org-texmacs-model-error
           '("Expected a syntax context plist")))
 (let* ((owner (org-texmacs--model-owner-create))
        (copy (org-texmacs--model-copy-node owner ast nil))
        (mapping
         (org-texmacs--model-copy-mapping
          owner islands #'org-texmacs--model-copy-stree))
        seen)
   (let ((options context))
     (while options
       (let ((key (pop options)))
         (pop options)
         (unless (and (memq key org-texmacs--model-context-keys)
                      (not (memq key seen)))
           (signal 'org-texmacs-model-error
                   '("Invalid or duplicate syntax context key")))
         (push key seen))))
   (org-texmacs--model-finish-owner owner)
   (org-texmacs--model-check-islands copy mapping)
   (org-texmacs--model-create
    :ast copy
    :islands mapping
    :context
    (org-texmacs--model-copy-data owner context))))

(provide 'org-texmacs-model)
;;; org-texmacs-model.el ends here
