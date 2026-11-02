;;; org-texmacs-inspect.el --- Readable mathematical-document inspection -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Project native Org structure and authoritative STM islands for inspection.
;; This view is neither Org source nor a persistent mathematical-document AST.

;;; Code:

(require 'org-texmacs-model)
(require 'pp)

(defconst org-texmacs--inspect-hidden-properties
  '(:parent
    :buffer
    :secondary
    :deferred
    :cached
    :mode
    :begin
    :end
    :contents-begin
    :contents-end
    :post-affiliated
    :robust-begin
    :robust-end
    :granularity)
  "Ownership, source-coordinate and parser bookkeeping omitted from the view.
Other properties, including post-blank and semantic whitespace, stay visible.")

(defconst org-texmacs--inspect-empty-standard-properties
  '(:post-blank :structure :true-level)
  "Native standard slots omitted only when unset.
Ordinary supplied nil-valued properties remain visible in the projection.")

(defun org-texmacs--inspect-fail (message path)
  "Report structural MESSAGE at native AST PATH without source coordinates."
  (signal 'org-texmacs-model-error
          (list (format "%s at AST path %S" message path))))

(defun org-texmacs--inspect-snapshot (model)
  "Validate MODEL and return detached (AST ISLANDS PATHS) for projection.
Reuse model ownership and island validation.  Also check existing parents rather
than silently repairing a damaged snapshot.  PATHS indexes all structural nodes,
including secondary strings, captions and suppressed island body residue."
  (unless (and (org-texmacs-model-p model)
               (consp (org-texmacs-model-ast model))
               (eq (car (org-texmacs-model-ast model)) 'org-data))
    (org-texmacs--inspect-fail
     "Expected a mathematical-document model" nil))
  (let* ((owner (org-texmacs--model-owner-create))
         (paths (make-hash-table :test #'eq))
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
                 #'org-texmacs--model-copy-stree))
          (org-texmacs--model-check-islands ast islands))
      (org-texmacs-model-error
       (org-texmacs--inspect-fail (error-message-string err) nil)))
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
           (org-texmacs--inspect-fail
            "Inconsistent Org parent" (gethash new paths)))))
     (org-texmacs--model-owner-nodes owner))
    (list ast islands paths)))

;;;###autoload
(defun org-texmacs-model-inspect (model)
  "Return an independent readable S-expression projection of MODEL.
Represent Org nodes as (TYPE PROPERTIES CONTENTS...), retaining document order.
Sort visible property keys by name.  Plain text stays text; islands appear
as (stm TREE).  An Org node island retains its wrapper properties; replace
its old contents and body-valued properties with the authoritative STM tree.
Affiliated captions remain outside that mathematical body.

Parsed secondary properties contain projected Org objects.  Caption lines use
(:long OBJECTS :short OBJECTS).  Other property references to structural nodes
appear as (org-ref PATH), where PATH uses zero-based contents/property indices.
Omit parents, source coordinates and internal parser bookkeeping.  Preserve
other properties and text whitespace without text properties.
Use parsed titles in preference to their redundant raw-value strings.

Do not parse source, invoke a worker/lowering or modify MODEL.
Invalid structure, parents or islands signal `org-texmacs-model-error'
with an AST path.  Whole-snapshot validation errors use the root path.
This view is not a persistence format, semantic-equivalence oracle or
third canonical AST."
  (let* ((snapshot (org-texmacs--inspect-snapshot model))
         (ast (nth 0 snapshot))
         (paths (nth 2 snapshot))
         (islands (make-hash-table :test #'eq)))
    (dolist (entry (nth 1 snapshot))
      (puthash (car entry) entry islands))
    (cl-labels
     ((data
       (value)
       (let ((path (gethash value paths :not-a-node)))
         (cond
          ((not (eq path :not-a-node))
           (list 'org-ref (copy-sequence path)))
          ((stringp value)
           (substring-no-properties value))
          ((consp value)
           (cons (data (car value)) (data (cdr value))))
          ((vectorp value)
           (apply #'vector (mapcar #'data value)))
          (t
           value))))
      (properties
       (node)
       (let (pairs)
         (org-element-properties-mapc
          (lambda (key value _node)
            (unless
                (or
                 (memq key org-texmacs--inspect-hidden-properties)
                 (and
                  (null value)
                  (memq
                   key
                   org-texmacs--inspect-empty-standard-properties))
                 (and (gethash node islands)
                      (or (memq key '(:value :raw-value))
                          (and (not (eq key :caption))
                               (memq
                                key
                                (org-element-property-raw
                                 :secondary node)))))
                 (and (eq key :raw-value)
                      (memq
                       :title
                       (org-element-property-raw :secondary node))
                      (org-element-property-raw :title node))
                 (string-prefix-p ":org-element--" (symbol-name key)))
              (push (cons
                     key
                     (cond
                      ((eq key :caption)
                       (mapcar
                        (lambda (line)
                          (list
                           :long (mapcar #'walk (car line))
                           :short (mapcar #'walk (cdr line))))
                        value))
                      ((memq
                        key
                        (org-element-property-raw :secondary node))
                       (mapcar #'walk value))
                      (t
                       (data value))))
                    pairs)))
          node)
         (cl-loop
          for (key . value) in
          (sort pairs
                (lambda (a b)
                  (string-lessp
                   (symbol-name (car a)) (symbol-name (car b)))))
          append (list key value))))
      (walk
       (node)
       (let ((entry (gethash node islands)))
         (cond
          ((stringp node)
           (if entry
               (list 'stm (cdr entry))
             (substring-no-properties node)))
          (t
           (append
            (list (org-element-type node) (properties node))
            (if entry
                (list (list 'stm (cdr entry)))
              (mapcar #'walk (org-element-contents node)))))))))
     (walk ast))))

;;;###autoload
(defun org-texmacs-model-display (model &optional name)
  "Display MODEL's inspection projection in a new read-only buffer.
Return the buffer.  Optional NAME defaults to `*org-texmacs-model*'; generate
a unique buffer even if that name already exists.  Validate before creating
the buffer, and clean it up if printing or display fails.  Do not change MODEL
or its source.  This is an explicit-model Lisp entry, not a source parsing
command."
  (unless (or (null name) (stringp name))
    (signal 'org-texmacs-model-error
            '("Expected an inspection buffer name")))
  (let* ((projection (org-texmacs-model-inspect model))
         (buffer
          (generate-new-buffer (or name "*org-texmacs-model*")))
         complete)
    (unwind-protect
        (progn
          (with-current-buffer buffer
            (let ((print-length nil)
                  (print-level nil)
                  (print-circle nil)
                  (print-escape-newlines t))
              (pp projection (current-buffer)))
            (goto-char (point-min))
            (let ((change-major-mode-hook nil)
                  (after-change-major-mode-hook nil))
              (delay-mode-hooks
                (special-mode)))
            (set-buffer-modified-p nil))
          (display-buffer buffer)
          (setq complete t)
          buffer)
      (unless (or complete (not (buffer-live-p buffer)))
        (kill-buffer buffer)))))

(provide 'org-texmacs-inspect)
;;; org-texmacs-inspect.el ends here
