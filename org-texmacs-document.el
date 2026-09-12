;;; org-texmacs-document.el --- Document lowering for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Pure structural lowering of prepared Org trees and TeXmacs islands.
;; Source discovery and native encoding are separate operations.  These trees
;; contain text, not native TeXmacs bytes; STM paths preserve source semantics.

;;; Code:

(require 'org-texmacs-core)
(require 'org-texmacs-source)

(define-error 'org-texmacs-document-error
              "Org TeXmacs document conversion failed" 'org-texmacs-error)

(cl-defstruct (org-texmacs-document
               (:constructor org-texmacs--document-create)
               (:copier nil))
  "Read-only structural result, before native encoding.
BODY is a text stree; STM-PATHS locate its STM island roots.  Each path
contains zero-based child indices, excluding tags.  Callers must not mutate
either slot or its nested lists and strings.  No source buffer is retained."
  (body nil :read-only t)
  (stm-paths nil :read-only t))

(defun org-texmacs--document-fail (node message)
  "Signal a conversion error for NODE with MESSAGE and source context."
  (signal 'org-texmacs-document-error
          (list message
                (if (stringp node) 'plain-text (org-element-type node))
                (unless (stringp node) (org-element-property :begin node)))))

(defun org-texmacs--document-copy-stree (node &optional ancestors)
  "Validate and copy text stree NODE without sharing strings or conses.
ANCESTORS detects cycles; repeated, non-cyclic subtrees are copied separately."
  (cond
   ((stringp node) (substring-no-properties node))
   ((and (consp node) (car node) (symbolp (car node))
         (proper-list-p node) (not (memq node ancestors)))
    (cons (car node)
          (mapcar (lambda (child)
                    (org-texmacs--document-copy-stree child (cons node ancestors)))
                  (cdr node))))
   (t (signal 'org-texmacs-document-error '("Invalid island stree")))))

(defun org-texmacs--document-pack (tag parts)
  "Wrap lowered PARTS in TAG, prefixing their STM paths by child index."
  (let ((index 0) (children nil) (paths nil))
    (dolist (part parts)
      (push (org-texmacs-document-body part) children)
      (dolist (path (org-texmacs-document-stm-paths part))
        (push (cons index path) paths))
      (setq index (1+ index)))
    (org-texmacs--document-create
     :body (cons tag (nreverse children)) :stm-paths (nreverse paths))))

(defun org-texmacs--document-lower (ast &optional islands post-blanks)
  "Lower prepared Org AST and ISLANDS to a structural document result.

AST must be an `org-data' snapshot.  ISLANDS is an identity-keyed alist
of (NODE . STREE): NODE is a complete TeXmacs special block or a standalone
plain-text child of a paragraph.  A preparation layer must split text at
fragment boundaries and mask foreign markup before constructing this input.
This function never discovers or parses fragments.  Every mapping must be
consumed exactly once; each mapped root contributes one output child.

POST-BLANKS optionally maps inline Org object identities to their exact
trailing spaces/tabs.  Without an entry, a nonnegative `:post-blank' count
becomes that many spaces.  This is not byte-exact source reconstruction:
callers needing tab preservation must supply the original whitespace.

Support paragraphs, plain text, bold, transparent Org sections and level
1--3 headlines with nonempty titles.  Reject other nodes and unsupported
headline semantics rather than discarding them.  Preserve paragraph text
and newlines; do not merge adjacent strings or flatten island strees.

Return a fresh result with STM root paths, retaining no Org properties or
source objects.  Do not read or modify buffers, encode text, start a worker,
or change AST/ISLANDS.  The caller must prepare all inputs from one snapshot."
  (unless (and (consp ast) (eq (org-element-type ast) 'org-data))
    (signal 'org-texmacs-document-error '("Expected an Org document AST")))
  (dolist (mapping (list islands post-blanks))
    (unless (proper-list-p mapping)
      (signal 'org-texmacs-document-error '("Expected a proper mapping alist")))
    (let ((keys nil))
      (dolist (entry mapping)
        (unless (and (consp entry) (or (stringp (car entry)) (consp (car entry)))
                     (not (memq (car entry) keys)))
          (signal 'org-texmacs-document-error '("Invalid or duplicate mapping key")))
        (push (car entry) keys))))
  (let ((used-islands nil) (used-blanks nil))
    (cl-labels
        ((text (string)
           (org-texmacs--document-create :body (substring-no-properties string)))
         (island (node entry)
           (when (memq entry used-islands)
             (org-texmacs--document-fail node "Island occurs more than once"))
           (push entry used-islands)
           (org-texmacs--document-create
            :body (org-texmacs--document-copy-stree (cdr entry))
            :stm-paths (list nil)))
         (blank (node)
           (let ((entry (assq node post-blanks))
                 (count (or (org-element-property :post-blank node) 0)))
             (unless (and (integerp count) (>= count 0))
               (org-texmacs--document-fail node "Invalid inline post-blank"))
             (let ((value (if entry (cdr entry) (make-string count ?\s))))
               (unless (and (stringp value) (string-match-p "\\`[ \t]*\\'" value))
                 (org-texmacs--document-fail node "Expected trailing spaces or tabs"))
               (when entry
                 (when (memq entry used-blanks)
                   (org-texmacs--document-fail node "Whitespace mapping reused"))
                 (push entry used-blanks))
               (unless (equal value "") (list (text value))))))
         (inline (node context ancestors)
           (let ((entry (assq node islands)))
             (cond
              (entry
               (unless (and (stringp node) (eq context 'paragraph))
                 (org-texmacs--document-fail node "Island outside paragraph text"))
               (list (island node entry)))
              ((stringp node) (list (text node)))
              ((and (consp node) (eq (org-element-type node) 'bold))
               (when (memq node ancestors)
                 (org-texmacs--document-fail node "Cyclic Org AST"))
               (let ((ancestors (cons node ancestors)))
                 (cons (org-texmacs--document-pack
                        'strong (inlines (org-element-contents node) 'bold ancestors))
                       (blank node))))
              (t (org-texmacs--document-fail node "Unsupported inline node")))))
         (inlines (nodes context ancestors)
           (unless (proper-list-p nodes)
             (signal 'org-texmacs-document-error '("Invalid inline contents")))
           (apply #'append (mapcar (lambda (node) (inline node context ancestors)) nodes)))
         (blocks (nodes context ancestors)
           (unless (proper-list-p nodes)
             (signal 'org-texmacs-document-error '("Invalid block contents")))
           (apply #'append (mapcar (lambda (node) (block node context ancestors)) nodes)))
         (block (node context ancestors)
           (unless (and (consp node) (not (memq node ancestors)))
             (org-texmacs--document-fail node "Invalid or cyclic block node"))
           (let ((ancestors (cons node ancestors))
                 (type (org-element-type node))
                 (entry (assq node islands)))
             (let ((begin (org-element-property :begin node))
                   (post (org-element-property :post-affiliated node)))
               (when (and (integerp begin) (integerp post) (> post begin))
                 (org-texmacs--document-fail node "Unsupported affiliated metadata")))
             (dolist (property '(:name :caption :attr_texmacs))
               (when (org-element-property property node)
                 (org-texmacs--document-fail node "Unsupported affiliated metadata")))
             (cond
              (entry
               (unless (org-texmacs--block-p node)
                 (org-texmacs--document-fail node "Island key is not a TeXmacs block"))
               (list (island node entry)))
              ((eq type 'section)
               (unless (memq context '(org-data headline))
                 (org-texmacs--document-fail node "Unexpected Org section"))
               (blocks (org-element-contents node) 'section ancestors))
              ((eq type 'paragraph)
               (list (org-texmacs--document-pack
                      'concat (inlines (org-element-contents node) 'paragraph ancestors))))
              ((eq type 'headline)
               (unless (memq context '(org-data headline))
                 (org-texmacs--document-fail node "Unexpected headline"))
               (let ((level (org-element-property :level node))
                     (raw (org-element-property :raw-value node)))
                 (unless (and (integerp level) (<= 1 level 3))
                   (org-texmacs--document-fail node "Unsupported headline level"))
                 (unless (and (stringp raw) (string-match-p "[^ \t\r\n]" raw))
                   (org-texmacs--document-fail node "Empty headline title"))
                 (dolist (property '(:todo-keyword :priority :tags :commentedp :archivedp))
                   (when (org-element-property property node)
                     (org-texmacs--document-fail node "Unsupported headline metadata")))
                 (let* ((parts (inlines (org-element-property :title node) 'title ancestors))
                        (title (if (= (length parts) 1) (car parts)
                                 (org-texmacs--document-pack 'concat parts))))
                   (unless parts
                     (org-texmacs--document-fail node "Empty headline title"))
                   (cons (org-texmacs--document-pack
                          (nth (1- level) '(section subsection subsubsection))
                          (list title))
                         (blocks (org-element-contents node) 'headline ancestors)))))
              (t (org-texmacs--document-fail node "Unsupported or unprepared block"))))))
      (let ((result (org-texmacs--document-pack
                     'document (blocks (org-element-contents ast) 'org-data (list ast)))))
        (unless (and (= (length used-islands) (length islands))
                     (= (length used-blanks) (length post-blanks)))
          (signal 'org-texmacs-document-error '("Unused preparation mappings")))
        result))))

(provide 'org-texmacs-document)

;;; org-texmacs-document.el ends here
