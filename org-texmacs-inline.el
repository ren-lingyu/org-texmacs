;;; org-texmacs-inline.el --- Inline sources for TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Discover inline STM source spans without extending Org's object parser.
;; Spans describe one source snapshot, not live Org objects or cached trees.

;;; Code:

(require 'org-texmacs-core)

(cl-defstruct (org-texmacs-inline-span
               (:constructor org-texmacs--inline-span-create)
               (:copier nil))
  "Read-only inline source snapshot; obtain another after editing.

BUFFER and TICK identify the source buffer and its character modification
count.  BEGIN and END delimit the half-open source range.  SOURCE is an
unpropertized string; callers must not modify it."
  (buffer nil :read-only t)
  (tick nil :read-only t)
  (begin nil :read-only t)
  (end nil :read-only t)
  (source nil :read-only t))

(defconst org-texmacs--inline-syntax-table
  (let ((table (make-syntax-table)))
    (dolist (character '(?\[ ?\] ?\{ ?\} ?\; ?# ?\' ?` ?, ?|))
      (modify-syntax-entry character "." table))
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)
    table)
  "Syntax table for inline STM boundaries, not a Scheme reader.")

(defun org-texmacs--inline-next ()
  "Move past the next inline prefix and return its start, or nil.

Search case-sensitively in the accessible buffer.  After `(math', require
whitespace or a parenthesis, not a longer tag or an adjacent string quote."
  (let ((case-fold-search nil)
        (start nil))
    (while (and (not start) (search-forward "(math" nil t))
      (when (memq (char-after) '(?\s ?\t ?\r ?\n ?\( ?\)))
        (setq start (- (point) 5))))
    start))

(defun org-texmacs--inline-end (start)
  "Return the balanced inline end at START, or nil.

The caller must narrow to the containing paragraph.  Use dedicated string
and escape syntax, ignoring Org syntax properties.  Reject unsupported
reader punctuation outside strings instead of returning a truncated span.
This only discovers boundaries; the worker validates STM data."
  (save-excursion
    (with-syntax-table org-texmacs--inline-syntax-table
      (let* ((parse-sexp-lookup-properties nil)
             (parse-sexp-ignore-comments nil)
             (end (condition-case nil
                      (scan-sexps start 1)
                    (scan-error nil)))
             (unsupported nil))
        (goto-char start)
        (while (and end (not unsupported)
                    (re-search-forward "[;#'`,|\\\\]" end t))
          (unless (save-excursion
                    (nth 3 (parse-partial-sexp start (match-beginning 0))))
            (setq unsupported t)))
        (and (not unsupported) end)))))

(provide 'org-texmacs-inline)

;;; org-texmacs-inline.el ends here
