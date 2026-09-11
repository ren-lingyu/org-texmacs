;;; org-texmacs-fragment.el --- Fragment sources for TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Discover fragment STM source spans without extending Org's object parser.
;; Spans describe one source snapshot, not live Org objects or cached trees.

;;; Code:

(require 'org-texmacs-core)
(require 'org)

(cl-defstruct (org-texmacs-fragment-span
               (:constructor org-texmacs--fragment-span-create)
               (:copier nil))
  "Read-only fragment source snapshot; obtain another after editing.

BUFFER and TICK identify the source buffer and its character modification
count.  BEGIN and END delimit the half-open source range.  SOURCE is an
unpropertized string; callers must not modify it."
  (buffer nil :read-only t)
  (tick nil :read-only t)
  (begin nil :read-only t)
  (end nil :read-only t)
  (source nil :read-only t))

(defconst org-texmacs--fragment-syntax-table
  (let ((table (make-syntax-table)))
    (dolist (character '(?\[ ?\] ?\{ ?\} ?\; ?# ?\' ?` ?, ?|))
      (modify-syntax-entry character "." table))
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)
    table)
  "Syntax table for fragment STM boundaries, not a Scheme reader.")

(defun org-texmacs--fragment-next ()
  "Move past the next fragment prefix and return its start, or nil.

Search case-sensitively in the accessible buffer.  After `(math', require
whitespace or a parenthesis, not a longer tag or an adjacent string quote."
  (let ((case-fold-search nil)
        (start nil))
    (while (and (not start) (search-forward "(math" nil t))
      (when (memq (char-after) '(?\s ?\t ?\r ?\n ?\( ?\)))
        (setq start (- (point) 5))))
    start))

(defun org-texmacs--fragment-end (start)
  "Return the balanced fragment end at START, or nil.

The caller must narrow to the containing paragraph.  Use dedicated string
and escape syntax, ignoring Org syntax properties.  Reject unsupported
reader punctuation outside strings instead of returning a truncated span.
This only discovers boundaries; the worker validates STM data."
  (save-excursion
    (with-syntax-table org-texmacs--fragment-syntax-table
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

(defun org-texmacs--fragment-check-region (begin end)
  "Check that BEGIN and END delimit an accessible region in an Org buffer."
  (unless (and (derived-mode-p 'org-mode)
               (integerp begin) (integerp end)
               (<= (point-min) begin end (point-max)))
    (signal 'org-texmacs-error
            '("Expected an accessible integer range in an Org buffer"))))

(defun org-texmacs--fragment-check-source (buffer tick)
  "Signal an error unless BUFFER is current and its source still has TICK."
  (unless (and (buffer-live-p buffer)
               (eq (current-buffer) buffer)
               (derived-mode-p 'org-mode)
               (integerp tick)
               (= tick (buffer-chars-modified-tick)))
    (signal 'org-texmacs-error '("Fragment source buffer changed or is no longer current"))))

(defun org-texmacs--fragment-source (span)
  "Return current raw source for fragment SPAN, rejecting stale snapshots.

SPAN must come from the current Org buffer and remain fully accessible.
Reject character edits, even outside the span, and a modified source string.
Text property changes alone do not invalidate a snapshot.  Do not widen,
rescan Org context, or change point.  Signal `org-texmacs-error' on failure."
  (unless (org-texmacs-fragment-span-p span)
    (signal 'org-texmacs-error '("Expected a fragment TeXmacs source span")))
  (org-texmacs--fragment-check-source (org-texmacs-fragment-span-buffer span)
                                   (org-texmacs-fragment-span-tick span))
  (let ((begin (org-texmacs-fragment-span-begin span))
        (end (org-texmacs-fragment-span-end span)))
    (org-texmacs--fragment-check-region begin end)
    (let ((source (buffer-substring-no-properties begin end)))
      (unless (and (< begin end)
                   (equal source (org-texmacs-fragment-span-source span)))
        (signal 'org-texmacs-error '("Fragment span source no longer matches the buffer")))
      source)))

(defun org-texmacs--fragment-texmacs-ancestor-p (paragraph)
  "Return non-nil if PARAGRAPH is inside a TeXmacs special block."
  (cl-some (lambda (ancestor)
             (and (eq (org-element-type ancestor) 'special-block)
                  (equal (org-element-property :type ancestor) "texmacs")))
           (org-element-lineage paragraph)))

(defun org-texmacs--fragment-mask (source)
  "Return an inert, equal-length replacement for complete fragment SOURCE.

Keep the outer parentheses and internal whitespace.  Replace other interior
characters with ordinary letters, removing foreign markup without changing
adjacent Org delimiter boundaries or creating blank lines."
  (concat "("
          (replace-regexp-in-string "[^ \t\r\n]" "x" (substring source 1 -1))
          ")"))

(defun org-texmacs--fragment-scan-paragraph (paragraph buffer tick offset)
  "Collect spans in shadow PARAGRAPH for source BUFFER at TICK.

OFFSET translates shadow positions to source positions.  Mask accepted spans
in the shadow buffer so their Org markup cannot hide later candidates."
  (unless (org-texmacs--fragment-texmacs-ancestor-p paragraph)
    (save-restriction
      (narrow-to-region (org-element-property :contents-begin paragraph)
                        (org-element-property :contents-end paragraph))
      (goto-char (point-min))
      (let ((spans nil)
            (start nil)
            (stop nil))
        (while (and (not stop) (setq start (org-texmacs--fragment-next)))
          (when (save-excursion
                  (goto-char start)
                  (eq (org-element-type (org-element-context)) 'paragraph))
            (let ((end (org-texmacs--fragment-end start)))
              (if (not end)
                  (setq stop t)
                (let ((source (buffer-substring-no-properties start end)))
                  (push (org-texmacs--fragment-span-create
                         :buffer buffer :tick tick
                         :begin (+ offset start) :end (+ offset end)
                         :source source)
                        spans)
                  (goto-char start)
                  (delete-region start end)
                  (insert (org-texmacs--fragment-mask source)))
                (goto-char end)))))
        (nreverse spans)))))

(defun org-texmacs--fragment-collect ()
  "Collect fragment spans in a private copy of the accessible Org source.

Do not widen the source buffer, run its mode hooks, or start a worker.
Scan the entire copy before region filtering to preserve left-to-right
precedence.  An unsupported or unclosed candidate stops its paragraph."
  (let ((buffer (current-buffer))
        (tick (buffer-chars-modified-tick))
        (offset (1- (point-min)))
        (source (buffer-substring-no-properties (point-min) (point-max)))
        (spans nil))
    (save-match-data
      (with-temp-buffer
        (let ((org-element-use-cache nil)
              (org-inhibit-startup t))
          (delay-mode-hooks (org-mode))
          (insert source)
          (let ((paragraphs (org-element-map (org-element-parse-buffer 'element)
                               'paragraph #'identity)))
            (dolist (paragraph paragraphs)
              (setq spans
                    (nconc spans (org-texmacs--fragment-scan-paragraph
                                  paragraph buffer tick offset))))))))
    (org-texmacs--fragment-check-source buffer tick)
    spans))

;;;###autoload
(defun org-texmacs-fragment-at-point (&optional position)
  "Return the fragment source span covering POSITION, or nil.

POSITION defaults to point and must be an accessible integer position in an
Org buffer.  Span bounds are half-open: BEGIN is included and END is not.
See `org-texmacs-fragment-map' for the source recognition and lifetime contract.
Leave source text, point and narrowing unchanged; do not start TeXmacs."
  (let ((position (or position (point))))
    (org-texmacs--fragment-check-region position position)
    (cl-find-if (lambda (span)
                  (<= (org-texmacs-fragment-span-begin span) position
                      (1- (org-texmacs-fragment-span-end span))))
                (org-texmacs--fragment-collect))))

;;;###autoload
(defun org-texmacs-fragment-map (begin end function)
  "Call FUNCTION on fragment spans wholly within BEGIN and END.

BEGIN and END must be ordered accessible integer positions in an Org buffer.
Return callback results in source order, including nil results.  Scan the
accessible buffer before filtering; region edges never truncate a formula.
Current narrowing acts as the document boundary; do not implicitly widen.

Recognize lowercase `(math ...)' only in paragraph text, including list item
paragraphs.  Exclude native objects such as emphasis, links and code, as well
as headlines, table cells, source blocks and TeXmacs special-block bodies.
Support nested lists, strings, escapes and newlines within a paragraph.
Unsupported reader punctuation outside strings, including Scheme comments,
or an unclosed candidate stops recognition for the rest of that paragraph.
Balanced input is not necessarily valid STM; this API does not parse it.

Spans are read-only snapshots, not Org nodes.  Obtain fresh spans after any
source edit.  No worker or cache is used, and native Org parsing is unchanged:
Org can still see markup inside formulas.  A private copy is used for Org
context checks without running mode hooks or copying source text properties.

Call FUNCTION in the source buffer, restoring point and narrowing after each
call.  FUNCTION must not edit the text, kill the buffer or change the current
buffer or major mode.  Signal `org-texmacs-error' on invalid bounds or source
changes; completed callback effects are not rolled back."
  (org-texmacs--fragment-check-region begin end)
  (unless (functionp function)
    (signal 'org-texmacs-error '("Expected a fragment span callback")))
  (let ((buffer (current-buffer))
        (tick (buffer-chars-modified-tick))
        (spans (org-texmacs--fragment-collect)))
    (mapcar (lambda (span)
              (org-texmacs--fragment-check-source buffer tick)
              (save-excursion
                (save-restriction
                  (prog1 (funcall function span)
                    (org-texmacs--fragment-check-source buffer tick)))))
            (cl-remove-if-not
             (lambda (span)
               (<= begin (org-texmacs-fragment-span-begin span)
                   (org-texmacs-fragment-span-end span) end))
             spans))))

(provide 'org-texmacs-fragment)

;;; org-texmacs-fragment.el ends here
