;;; org-texmacs-prepared.el --- Prepared AST islands -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Adapt the final Org export tree without source coordinates or preparation.
;; Native parsing happens once at this input boundary, before model ownership.

;;; Code:

(require 'org-texmacs-input)
(require 'org-texmacs-fragment)
(require 'org-texmacs-worker)

(defun org-texmacs--prepared-fail (message)
  "Reject incomplete or ambiguous prepared input with MESSAGE."
  (signal 'org-texmacs-document-error (list message)))

(defun org-texmacs--prepared-copy (tree ignored)
  "Own final TREE and apply Org's identity-keyed IGNORED list.
This realizes exclusion decisions already made by Org; it does not select or
prune export trees independently.  Detached ignore entries have no effect."
  (let* ((owner (org-texmacs--model-owner-create
                 :error-type 'org-texmacs-document-error
                 :caption-reader #'org-texmacs--document-caption-lines))
         (copy (org-texmacs--model-copy-node owner tree nil)))
    (org-texmacs--model-finish-owner owner)
    (dolist (node ignored)
      (when-let* ((owned (gethash node (org-texmacs--model-owner-nodes owner))))
        (if (eq owned copy)
            (org-element-set-contents copy)
          (org-element-extract-element owned))))
    copy))

(defun org-texmacs--prepared-inline (node tags)
  "Split STM in direct contents of NODE using TAGS.
Return (KEY SOURCE TAG) requests keyed by new text identities.  Org objects
may contribute their interpreted syntax only inside a complete STM string;
ordinary Org objects outside islands remain structured and untouched."
  (let (parts ranges (offset 0) requests)
    (dolist (child (org-element-contents node))
      (let ((text (if (stringp child) child (org-element-interpret-data child))))
        (push text parts)
        (push (list offset (+ offset (length text)) child) ranges)
        (setq offset (+ offset (length text)))))
    (setq ranges (nreverse ranges))
    (with-temp-buffer
      (insert (apply #'concat (nreverse parts)))
      (goto-char (point-min))
      (let ((regexp (concat "(" (regexp-opt tags t))) spans)
        (while-let ((start (org-texmacs--fragment-next regexp)))
          (let* ((tag (buffer-substring-no-properties (1+ start) (point)))
                 (range (cl-find-if (lambda (r) (<= (1+ (nth 0 r)) start (nth 1 r))) ranges)))
            (when (and range (stringp (nth 2 range)))
              (let ((end (org-texmacs--fragment-end start)))
                (unless end
                  (org-texmacs--prepared-fail "Incomplete prepared STM fragment"))
                (dolist (r ranges)
                  (unless (or (stringp (nth 2 r))
                              (<= (1+ (nth 1 r)) start)
                              (>= (1+ (nth 0 r)) end))
                    (unless
                        (and (<= start (1+ (nth 0 r)) (1+ (nth 1 r)) end)
                             (with-syntax-table org-texmacs--fragment-syntax-table
                               (and (nth 3 (parse-partial-sexp start (1+ (nth 0 r))))
                                    (nth 3 (parse-partial-sexp start (1+ (nth 1 r)))))))
                      (org-texmacs--prepared-fail "STM crosses an Org object boundary"))))
                (push (list (1- start) (1- end)
                            (buffer-substring-no-properties start end) tag) spans)
                (goto-char end)))))
        (let ((cursor 0) children)
          (cl-labels ((ordinary
                       (begin end)
                       (dolist (r ranges)
                         (let ((lo (max begin (nth 0 r)))
                               (hi (min end (nth 1 r)))
                               (child (nth 2 r)))
                           (when (< lo hi)
                             (push (if (stringp child)
                                       (buffer-substring-no-properties (1+ lo) (1+ hi))
                                     child)
                                   children))))))
            (dolist (span (nreverse spans))
              (ordinary cursor (nth 0 span))
              (let ((leaf (copy-sequence (nth 2 span))))
                (push leaf children)
                (push (list leaf leaf (nth 3 span)) requests))
              (setq cursor (nth 1 span)))
            (ordinary cursor offset))
          (apply #'org-element-set-contents node (nreverse children)))))
    (nreverse requests)))

(defun org-texmacs--prepared-islands (tree tags)
  "Recognize and parse final TREE STM under TAGS, returning an island alist.
Native blocks can supply complete :texmacs-source text explicitly.  Otherwise
their final structured contents are interpreted as input syntax, never reread
from potentially stale source positions.  No Org reparsing or export is done."
  (let (requests islands)
    (cl-labels ((walk
                 (node)
                 (when (consp node)
                   (cond
                    ((org-texmacs--native-body-kind node)
                     (org-texmacs--native-body-check node)
                     (let ((raw (if (org-element-property :texmacs-source node)
                                    (org-element-property :texmacs-source node)
                                  (org-element-interpret-data (org-element-contents node)))))
                       (unless (and (stringp raw) (> (length raw) 0))
                         (org-texmacs--prepared-fail "Native STM block requires complete input"))
                       (push (list node (substring-no-properties raw) nil) requests)
                       (org-element-set-contents node)))
                    ((or (eq (org-element-type node) 'paragraph)
                         (and (eq (org-element-type node) 'footnote-reference)
                              (eq (org-element-property :type node) 'inline)))
                     (when tags
                       (setq requests (append (reverse (org-texmacs--prepared-inline node tags)) requests)))
                     (mapc #'walk (org-element-contents node)))
                    (t (mapc #'walk (org-element-contents node)))))))
      (walk tree))
    ;; Finish discovery before starting a worker; invalid boundaries never
    ;; trigger partial native processing.  The existing parser validates STM.
    (dolist (request (nreverse requests))
      (let ((parsed (org-texmacs--worker-request (copy-sequence (nth 1 request))))
            (tag (nth 2 request)))
        (when (and tag (not (and (consp parsed) (symbolp (car parsed))
                                (equal tag (symbol-name (car parsed))))))
          (signal 'org-texmacs-parse-error '("TeXmacs root differs from fragment tag")))
        (push (cons (car request) (org-texmacs--document-copy-stree parsed)) islands)))
    (nreverse islands)))

(provide 'org-texmacs-prepared)
;;; org-texmacs-prepared.el ends here
