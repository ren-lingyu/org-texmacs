;;; org-texmacs-model.el --- Mathematical-document snapshots -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Own native Org trees and parsed STM islands without source buffers,
;; document lowering, export configuration or native worker operations.
;; Nested objects are read-only by convention, not protected from mutation.

;;; Code:

(require 'org-texmacs-core)
(require 'org-texmacs-stm)
(require 'org-texmacs-source)

(autoload 'org-texmacs-parse-buffer "org-texmacs-parse")
(autoload 'org-texmacs-model-inspect "org-texmacs-inspect")
(autoload 'org-texmacs-model-display "org-texmacs-inspect")
(autoload 'org-texmacs-model-serialize "org-texmacs-serialize")
(autoload 'org-texmacs-model-to-buffer "org-texmacs-serialize")

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
  '(:heading-settings :link-settings :source-file :resource-base)
  "Explicit syntax/source context keys, excluding export configuration.
The buffer adapter will capture effective syntax settings.  This module only
owns supplied resolved data; it does not infer settings or interpret options.")

(cl-defstruct
 (org-texmacs--model-owner
  (:constructor org-texmacs--model-owner-create) (:copier nil))
 "Private copying transaction shared with export input ownership."
 (nodes (make-hash-table :test #'eq))
 pending
 (strip-fragment-source nil)
 (error-type 'org-texmacs-model-error)
 excluded-nodes
 (secondary-normalizer #'identity)
 (caption-reader #'org-texmacs--model-caption-lines))

(defun org-texmacs--model-fail (owner message)
  "Signal OWNER's error condition with MESSAGE."
  (signal (org-texmacs--model-owner-error-type owner) (list message)))

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
            ((and (org-texmacs--model-owner-strip-fragment-source
                   owner)
                  (or (and (eq (car old) 'stm-fragment)
                           (memq key '(:stm-source :value)))
                      (and (not parent)
                           (eq key :org-texmacs-syntax)))))
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
                   (cl-remove-if
                    (lambda (child)
                      (memq
                       child
                       (org-texmacs--model-owner-excluded-nodes
                        owner)))
                    (car line)))
                  (mapcar
                   (lambda
                     (child)
                     (org-texmacs--model-copy-node owner child new))
                   (cl-remove-if
                    (lambda (child)
                      (memq
                       child
                       (org-texmacs--model-owner-excluded-nodes
                        owner)))
                    (cdr line)))))
               (funcall
                (org-texmacs--model-owner-caption-reader owner)
                old))))
            ((memq key keys)
             (setq value
                   (funcall
                    (org-texmacs--model-owner-secondary-normalizer
                     owner)
                    value))
             (unless (proper-list-p value)
               (org-texmacs--model-fail
                owner "Expected parsed secondary objects"))
             (org-element-put-property
              new key
              (mapcar
               (lambda (child)
                 (org-texmacs--model-copy-node owner child new))
               (cl-remove-if
                (lambda (child)
                  (memq
                   child
                   (org-texmacs--model-owner-excluded-nodes owner)))
                value))))
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
                (cl-remove-if
                 (lambda (child)
                   (memq
                    child
                    (org-texmacs--model-owner-excluded-nodes owner)))
                 (cddr old))))
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
  "Validate island associations in owned AST and ISLANDS.
Require typed object keys and complete fragment mappings.
Inspect contents, captions and secondary properties without reading source."
  (let ((keys (make-hash-table :test #'eq)))
    (dolist (entry islands)
      (let ((node (car entry)))
        (unless (or (eq (org-element-type node) 'stm-fragment)
                    (org-texmacs--native-body-kind node))
          (signal
           (or error-type 'org-texmacs-model-error)
           '("Expected a fragment or native block island key")))
        (puthash node t keys)))
    (cl-labels
     ((walk
       (node enclosing)
       (let ((island (gethash node keys)))
         (when (eq (org-element-type node) 'stm-fragment)
           (unless (and island
                        (null (org-element-contents node))
                        (let ((blank
                               (org-element-property-raw
                                :post-blank node)))
                          (or (null blank) (wholenump blank))))
             (signal
              (or error-type 'org-texmacs-model-error)
              '("Expected a mapped nonrecursive STM fragment"))))
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

(defun org-texmacs--model-copy-context (owner context keys)
  "Validate and copy CONTEXT for OWNER, permitting unique KEYS."
  (unless (and (proper-list-p context) (zerop (% (length context) 2)))
    (org-texmacs--model-fail owner "Expected a syntax context plist"))
  (let (seen)
    (cl-loop
     for (key _value) on context by #'cddr do
     (unless (and (memq key keys) (not (memq key seen)))
       (org-texmacs--model-fail
        owner "Invalid or duplicate syntax context key"))
     (push key seen)))
  (org-texmacs--model-copy-data owner context))

(defun org-texmacs--model-own-context (owner ast context)
  "Merge already owned CONTEXT with the validated syntax snapshot on AST."
  (let ((syntax
         (org-texmacs--model-copy-context
          owner
          (org-element-property-raw :org-texmacs-syntax ast)
          '(:heading-settings :link-settings)))
        (result context))
    (cl-loop
     for (key value) on syntax by #'cddr do
     (if (plist-member result key)
         (unless (equal (plist-get result key) value)
           (org-texmacs--model-fail
            owner (format "Conflicting captured syntax: %s" key)))
       (setq result (plist-put result key value))))
    result))

(defun org-texmacs--model-own (ast islands context)
  "Own AST, ISLANDS and CONTEXT in one pure transaction."
  (unless (and (consp ast) (eq (car ast) 'org-data))
    (signal 'org-texmacs-model-error
            '("Expected an Org org-data AST")))
  (let* ((owner
          (org-texmacs--model-owner-create :strip-fragment-source t))
         (copy (org-texmacs--model-copy-node owner ast nil))
         (mapping
          (org-texmacs--model-copy-mapping
           owner islands #'org-texmacs--stm-copy))
         (owned-context
          (org-texmacs--model-copy-context
           owner context org-texmacs--model-context-keys)))
    (org-texmacs--model-finish-owner owner)
    (org-texmacs--model-check-islands copy mapping)
    (org-texmacs--model-create
     :ast copy
     :islands mapping
     :context
     (org-texmacs--model-own-context owner ast owned-context))))

;;;###autoload
(cl-defun
 org-texmacs-model-create (ast &key islands context)
 "Own native Org AST, parsed STM ISLANDS and explicit CONTEXT.
AST must be a fully resolved org-data tree, not Org's live cache.  ISLANDS
maps distinct stm-fragment or native block identities to parsed STM trees.
Trees are authoritative for the mathematical content;
Org nodes retain the structural wrapper and affiliation.  Nested island
contents cannot overlap.  Secondary strings and captions belong to the AST.

CONTEXT is a unique-keyword plist of resolved syntax/source data with keys
:heading-settings, :link-settings, :source-file or :resource-base.
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
 (org-texmacs--model-own ast islands context))

(defun org-texmacs--model-path-error (message path)
  "Report structural MESSAGE at native AST PATH without source coordinates."
  (signal 'org-texmacs-model-error
          (list (format "%s at AST path %S" message path))))

(defun org-texmacs--model-node-paths (ast)
  "Index structural nodes of AST by identity, including secondary values."
  (let ((paths (make-hash-table :test #'eq)))
    (cl-labels
     ((sequence
       (children path)
       (cl-loop
        for
        child
        in
        children
        for
        index
        from
        0
        do
        (walk child (append path (list index)))))
      (walk
       (node path) (puthash node path paths)
       (when (consp node)
         (sequence
          (org-element-contents node) (append path '(contents)))
         (dolist (key (org-element-property-raw :secondary node))
           (unless (eq key :caption)
             (sequence
              (org-element-property-raw key node)
              (append path (list key)))))
         (cl-loop
          for
          line
          in
          (org-element-property-raw :caption node)
          for
          index
          from
          0
          do
          (sequence
           (car line) (append path (list :caption index :long)))
          (sequence
           (cdr line) (append path (list :caption index :short)))))))
     (walk ast nil))
    paths))

(defun org-texmacs--model-snapshot (model &optional context)
  "Validate MODEL and return detached (AST ISLANDS PATHS) for projection.
Reuse model ownership and island validation.  Also check existing parents rather
than silently repairing a damaged snapshot.  PATHS indexes all structural nodes,
including secondary strings, captions and native island body residue.
With CONTEXT non-nil, append owned syntax context as a fourth result."
  (unless (and (org-texmacs-model-p model)
               (consp (org-texmacs-model-ast model))
               (eq (car (org-texmacs-model-ast model)) 'org-data))
    (org-texmacs--model-path-error
     "Expected a mathematical-document model" nil))
  (let* ((owner (org-texmacs--model-owner-create))
         paths
         ast
         islands)
    (condition-case err
        (progn
          (setq ast
                (org-texmacs--model-copy-node
                 owner (org-texmacs-model-ast model) nil))
          (org-texmacs--model-finish-owner owner)
          (setq islands
                (org-texmacs--model-copy-mapping
                 owner
                 (org-texmacs-model-islands model)
                 #'org-texmacs--stm-copy))
          (org-texmacs--model-check-islands ast islands))
      (org-texmacs-model-error
       (org-texmacs--model-path-error
        (error-message-string err) nil)))
    (setq paths (org-texmacs--model-node-paths ast))
    (maphash
     (lambda (old new)
       (let ((actual (org-element-property-raw :parent old))
             (expected (org-element-property-raw :parent new)))
         (unless (if expected
                     (eq
                      (gethash
                       actual (org-texmacs--model-owner-nodes owner))
                      expected)
                   (null actual))
           (org-texmacs--model-path-error
            "Inconsistent Org parent" (gethash new paths)))))
     (org-texmacs--model-owner-nodes owner))
    (append
     (list ast islands paths)
     (when context
       (let ((value (org-texmacs-model-context model))
             seen)
         (unless (and (proper-list-p value)
                      (zerop (% (length value) 2)))
           (org-texmacs--model-path-error
            "Invalid syntax context" nil))
         (cl-loop
          for (key _value) on value by #'cddr do
          (unless (and (memq key org-texmacs--model-context-keys)
                       (not (memq key seen)))
            (org-texmacs--model-path-error
             "Invalid or duplicate syntax context key" nil))
          (push key seen))
         (list
          (org-texmacs--model-own-context
           owner ast (org-texmacs--model-copy-data owner value))))))))

;;;###autoload
(defun org-texmacs-model-copy (model)
  "Return an independent, structurally equivalent snapshot of MODEL.
Copy all mutable Org, STM and context data, rebuild parents and remap island
identities and structural references.  No parser, worker or lowering runs.
Accessors on the result return read-only references, as on MODEL.
Signal `org-texmacs-model-error' for invalid input; leave MODEL untouched."
  (let ((snapshot (org-texmacs--model-snapshot model t)))
    (org-texmacs--model-create
     :ast (nth 0 snapshot)
     :islands (nth 1 snapshot)
     :context (nth 3 snapshot))))

;;;###autoload
(defun org-texmacs-model-island (model node)
  "Return the read-only STM tree associated with MODEL's island NODE.
NODE must be the actual island key from MODEL, not an equal copy or a node
from another snapshot.  Obtain keys from `org-texmacs-model-islands' or native
Org traversal.  Do not modify the returned tree or any of its nested data.
Signal `org-texmacs-model-error' if NODE is not an island in MODEL."
  (unless (org-texmacs-model-p model)
    (org-texmacs--model-path-error
     "Expected a mathematical-document model" nil))
  (let ((entry (assq node (org-texmacs-model-islands model))))
    (unless entry
      (org-texmacs--model-path-error
       "Node is not an island in this snapshot" nil))
    (cdr entry)))

;;;###autoload
(defun org-texmacs-model-replace-stm (model node path replacement)
  "Return a new snapshot replacing MODEL island NODE's PATH with REPLACEMENT.
NODE is a snapshot-local island key.  PATH is a proper list of zero-based
STM child indices, excluding each tag; nil replaces the whole island tree.
REPLACEMENT is a structured STM tree.
Own every mutable input, rebuild Org parents and island identities, and leave
MODEL and its locators untouched on success or failure.  Old nodes cannot
locate islands in the result.  No source coordinates, text round trips,
parser, worker or document lowering are used.

Root replacement uses ordinary structural validation.  Atomic STM string
roots are outside the supported replacement contract.  Serialization may
reject a structurally valid result.  Source text and
coordinates retained on Org nodes describe the original source, not the new
STM content.  Use island identities and AST paths, never those coordinates,
to address the result.  Signal `org-texmacs-model-error' for invalid arguments."
  (let* ((snapshot (org-texmacs--model-snapshot model t))
         (islands (nth 1 snapshot))
         (position
          (cl-position
           node
           (org-texmacs-model-islands model)
           :key #'car
           :test #'eq))
         (entry (and position (nth position islands)))
         (location
          (and entry (gethash (car entry) (nth 2 snapshot)))))
    (unless entry
      (org-texmacs--model-path-error
       "Node is not an island in this snapshot" nil))
    (unless (and (proper-list-p path) (cl-every #'natnump path))
      (org-texmacs--model-path-error
       "Expected STM child indices" location))
    (let ((tree (cdr entry))
          (steps path)
          (visited (append location '(stm)))
          parent
          slot)
      (while steps
        (let ((index (pop steps)))
          (unless (and (consp tree) (< index (length (cdr tree))))
            (org-texmacs--model-path-error
             "STM child index out of range"
             (append visited (list index))))
          (setq
           parent tree
           slot index
           tree (nth (1+ index) tree)
           visited (append visited (list index)))))
      (let ((owned
             (condition-case err
                 (org-texmacs--stm-copy replacement)
               (org-texmacs-model-error
                (org-texmacs--model-path-error
                 (error-message-string err) visited)))))
        (if parent
            (setcar (nthcdr (1+ slot) parent) owned)
          (setcdr entry owned))))
    (org-texmacs--model-create
     :ast (nth 0 snapshot)
     :islands islands
     :context (nth 3 snapshot))))

(provide 'org-texmacs-model)
;;; org-texmacs-model.el ends here
