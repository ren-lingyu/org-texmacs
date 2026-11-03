;;; org-texmacs-prepared.el --- Prepared AST islands -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Adapt the final Org export tree without source coordinates or preparation.
;; Native parsing happens once during the private input ownership transaction.

;;; Code:

(require 'org-texmacs-input)
(require 'org-texmacs-fragment)
(require 'org-texmacs-worker)

(defun org-texmacs--prepared-fail (message)
  "Reject incomplete or ambiguous prepared input with MESSAGE."
  (signal 'org-texmacs-document-error (list message)))

(defun org-texmacs--prepared-reject-raw (data)
  "Reject target-specific raw DATA before native input interpretation."
  ;; `raw' is a pseudo object.  A raw-only map misses paragraph contents.
  (when (org-element-map
         data t
         (lambda (node)
           (and (consp node) (eq (org-element-type node) 'raw)))
         nil t nil t)
    (org-texmacs--prepared-fail
     "Raw target output is unsupported; use a structured Org Cite processor")))

(defun org-texmacs--prepared-resolve (data)
  "Resolve DATA properties while live, preserving explicit filter values.
Some conditional deferred values survive the bulk resolver.  Public property
access materializes them without FORCE or replaying an overwritten value."
  (org-element-map
   data t
   (lambda (node)
     (when (consp node)
       (org-element-properties-resolve node)
       (org-element-properties-mapc
        (lambda (key _value _owner)
          (org-element-put-property
           node key (org-element-property key node)))
        node)))
   nil nil nil t))

(defun org-texmacs--prepared-copy (tree ignored &optional identities)
  "Own final TREE and apply Org's identity-keyed IGNORED list.
This realizes exclusion decisions already made by Org; it does not select or
prune export trees independently.  Detached ignore entries have no effect.
Optionally populate IDENTITIES with original-to-owned node associations."
  (let* ((owner
          (org-texmacs--model-owner-create
           :error-type 'org-texmacs-document-error
           :secondary-normalizer
           (lambda (value)
             (if (stringp value)
                 (list value)
               value))
           :caption-reader #'org-texmacs--document-caption-lines))
         (copy (org-texmacs--model-copy-node owner tree nil)))
    (org-texmacs--model-finish-owner owner)
    (dolist (node ignored)
      (when-let* ((owned
                   (gethash
                    node (org-texmacs--model-owner-nodes owner))))
        (if (eq owned copy)
            (org-element-set-contents copy)
          (org-element-extract-element owned))))
    (when identities
      (maphash
       (lambda (original owned)
         (puthash original owned identities))
       (org-texmacs--model-owner-nodes owner)))
    copy))

(defun org-texmacs--prepared-control-keywords (tree)
  "Remove consumed preparation/configuration directives from owned TREE.
Their effective values already belong to Org INFO.  Keep positional KEYWORDS
while bibliography acquisition remains with standard Org Cite."
  (org-element-map
   tree 'keyword
   (lambda (node)
     (when (member
            (org-element-property :key node)
            (append
             org-texmacs--context-source-keywords
             '("MACRO"
               "PROPERTY"
               "SETUPFILE"
               "INCLUDE"
               "BIND"
               "CITE_EXPORT"
               "BIBLIOGRAPHY")))
       (org-element-extract-element node))))
  tree)

(defun org-texmacs--prepared-affiliation (tree)
  "Project final TREE affiliation for the existing pure lowering contract.
Org has consumed RESULTS.  Derive other affiliations from actual properties,
including positionless nodes, instead of source-position evidence.  Unsupported
affiliations still reach the lowerer's explicit validation."
  (org-element-map
   tree t
   (lambda (node)
     (when (consp node)
       (let (keys)
         (org-element-put-property node :results nil)
         (org-element-properties-mapc
          (lambda (key value _owner)
            (let ((name (upcase (substring (symbol-name key) 1))))
              (when (and value
                         (not
                          (and (eq key :label)
                               (memq
                                (org-element-type node)
                                '(footnote-reference
                                  footnote-definition))))
                         (or (member
                              name org-element-affiliated-keywords)
                             (string-prefix-p "ATTR_" name)))
                (push name keys))))
          node)
         (org-element-put-property
          node
          :texmacs-affiliated-keywords (nreverse keys))
         (org-element-put-property
          node
          :post-affiliated (org-element-property :begin node)))))
   nil nil nil t)
  tree)

(defun org-texmacs--prepared-inline (node tags)
  "Split STM in direct contents of NODE using TAGS.
Return (KEY SOURCE TAG) requests keyed by new text identities.  Org objects
may contribute their interpreted syntax only inside a complete STM string;
ordinary Org objects outside islands remain structured and untouched."
  (when (string-match-p
         (concat "(" (regexp-opt tags t) "[ \t\r\n()]")
         (mapconcat (lambda (child)
                      (if (stringp child)
                          child
                        "\ufffc"))
                    (org-element-contents node)
                    ""))
    (let (parts
          ranges
          (offset 0)
          requests)
      (dolist (child (org-element-contents node))
        (let ((text
               (if (stringp child)
                   child
                 (if (eq (org-element-type child) 'raw)
                     "\ufffc"
                   (condition-case nil
                       (org-element-interpret-data child)
                     (error
                      "\ufffc"))))))
          (push text parts)
          (push (list
                 offset
                 (+ offset (length text))
                 child
                 (equal text "\ufffc"))
                ranges)
          (setq offset (+ offset (length text)))))
      (setq ranges (nreverse ranges))
      (with-temp-buffer
        (insert (apply #'concat (nreverse parts)))
        (goto-char (point-min))
        (let ((regexp (concat "(" (regexp-opt tags t)))
              spans)
          (while-let ((start (org-texmacs--fragment-next regexp)))
            (let* ((tag
                    (buffer-substring-no-properties
                     (1+ start) (point)))
                   (range
                    (cl-find-if
                     (lambda (r)
                       (<= (1+ (nth 0 r)) start (nth 1 r)))
                     ranges)))
              (when (and range (stringp (nth 2 range)))
                (let ((end (org-texmacs--fragment-end start)))
                  (unless end
                    (org-texmacs--prepared-fail
                     "Incomplete prepared STM fragment"))
                  (dolist (r ranges)
                    (unless (or (stringp (nth 2 r))
                                (<= (1+ (nth 1 r)) start)
                                (>= (1+ (nth 0 r)) end))
                      (unless (and
                               (not (nth 3 r))
                               (not
                                (eq
                                 (org-element-type (nth 2 r)) 'raw))
                               (<= start
                                   (1+ (nth 0 r))
                                   (1+ (nth 1 r))
                                   end)
                               (with-syntax-table
                                   org-texmacs--fragment-syntax-table
                                 (and (nth
                                       3
                                       (parse-partial-sexp
                                        start (1+ (nth 0 r))))
                                      (nth
                                       3
                                       (parse-partial-sexp
                                        start (1+ (nth 1 r)))))))
                        (org-texmacs--prepared-fail
                         "STM crosses an Org object boundary"))))
                  (push (list
                         (1- start) (1- end)
                         (buffer-substring-no-properties
                          start end)
                         tag)
                        spans)
                  (goto-char end)))))
          (let ((cursor 0)
                children)
            (cl-labels
             ((ordinary
               (begin end)
               (dolist (r ranges)
                 (let ((lo (max begin (nth 0 r)))
                       (hi (min end (nth 1 r)))
                       (child (nth 2 r)))
                   (when (< lo hi)
                     (push (if (stringp child)
                               (buffer-substring-no-properties
                                (1+ lo) (1+ hi))
                             child)
                           children))))))
             (dolist (span (nreverse spans))
               (ordinary cursor (nth 0 span))
               (let ((leaf (copy-sequence (nth 2 span))))
                 (push leaf children)
                 (push (list leaf leaf (nth 3 span)) requests))
               (setq cursor (nth 1 span)))
             (ordinary cursor offset))
            (apply #'org-element-set-contents
                   node
                   (nreverse children)))))
      (nreverse requests))))

(defun org-texmacs--prepared-discover
    (tree tags &optional defer-notes)
  "Recognize final TREE STM under TAGS, returning (KEY SOURCE TAG) requests.
Native blocks can supply complete :texmacs-source text explicitly.  Otherwise
their final structured contents are interpreted as input syntax, never reread
from potentially stale source positions.  No Org reparsing or export is done."
  (let (requests)
    (cl-labels
     ((walk
       (node)
       (when (consp node)
         (cond
          ((and defer-notes
                (or (eq (org-element-type node) 'footnote-definition)
                    (and (eq (org-element-type node) 'headline)
                         (org-element-property
                          :footnote-section-p node)))))
          ((eq (org-element-type node) 'raw)
           (org-texmacs--prepared-reject-raw node))
          ((org-texmacs--native-body-kind node)
           (org-texmacs--native-body-check node)
           (let ((raw
                  (if (org-element-property :texmacs-source node)
                      (org-element-property :texmacs-source node)
                    (progn
                      (org-texmacs--prepared-reject-raw
                       (org-element-contents node))
                      (org-element-interpret-data
                       (org-element-contents node))))))
             (unless (and (stringp raw) (> (length raw) 0))
               (org-texmacs--prepared-fail
                "Native STM block requires complete input"))
             (push
              (list node (substring-no-properties raw) nil) requests)
             (org-element-set-contents node)))
          ((or (eq (org-element-type node) 'paragraph)
               (and (eq (org-element-type node) 'footnote-reference)
                    (eq (org-element-property :type node) 'inline)))
           (when tags
             (setq requests
                   (append
                    (reverse
                     (org-texmacs--prepared-inline node tags))
                    requests)))
           (mapc #'walk (org-element-contents node)))
          (t
           (mapc #'walk (org-element-contents node))))
         (unless (and defer-notes
                      (or (eq
                           (org-element-type node)
                           'footnote-definition)
                          (org-element-property
                           :footnote-section-p node)))
           (dolist (key
                    (remq
                     :caption
                     (copy-sequence
                      (org-element-property :secondary node))))
             (org-texmacs--prepared-reject-raw
              (org-element-property key node)))
           (dolist (line (org-element-property :caption node))
             (org-texmacs--prepared-reject-raw (car line))
             (org-texmacs--prepared-reject-raw (cdr line)))))))
     (walk tree))
    (nreverse requests)))

(defun org-texmacs--prepared-parse (requests islands)
  "Fill private owned ISLANDS from already discovered REQUESTS.
The caller must own the complete input/context before the first native wait.
No intermediate input or placeholder island may be exposed to consumers."
  (cl-mapc
   (lambda (request island)
     (let ((parsed
            (org-texmacs--worker-request
             (copy-sequence (nth 1 request))))
           (tag (nth 2 request)))
       (when (and tag
                  (not
                   (and (consp parsed)
                        (symbolp (car parsed))
                        (equal tag (symbol-name (car parsed))))))
         (signal 'org-texmacs-parse-error
                 '("TeXmacs root differs from fragment tag")))
       (setcdr island (org-texmacs--document-copy-stree parsed))))
   requests islands))

(provide 'org-texmacs-prepared)
;;; org-texmacs-prepared.el ends here
