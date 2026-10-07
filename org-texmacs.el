;;; org-texmacs.el --- TeXmacs trees and document sessions for Org -*- lexical-binding: t; -*-

;; Copyright (C) 2026 aRenCoco

;; Author: aRenCoco
;; Maintainer: aRenCoco
;; Version: 0.3.1
;; Package-Requires: ((emacs "31.1") (org "9.8"))
;; Keywords: outlines, tex
;; URL: https://github.com/ren-lingyu/org-texmacs
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Use `org-texmacs-tree' to derive an Org-compatible TeXmacs tree from a
;; native TeXmacs special block, with lazy parsing and Org-managed caching.
;; Discover paragraph source spans with `org-texmacs-fragment-at-point' or
;; `org-texmacs-fragment-map', using `org-texmacs-fragment-tags' as entry names.
;; Use `org-texmacs-fragment-tree' to parse a fragment source span on demand,
;; without caching or changing Org's native object parser.
;; Use `org-texmacs-document' to lower an explicit prepared input, or
;; `org-texmacs-document-from-buffer' for whole-buffer structural conversion
;; to a text TeXmacs document result with body, style, initial environment and
;; STM provenance, before native encoding.
;; Use `org-texmacs-session-open', `org-texmacs-session-set-document' and
;; `org-texmacs-session-close' to manage explicit native document state.
;; Source stays in Org; no external .tm file is required.  This package does
;; not provide preview, export, rendered numbering or a combined Org/TeXmacs
;; document AST.
;; Use `org-texmacs-check-setup' to inspect the capabilities required by the
;; package without starting TeXmacs.

;;; Code:

(require 'org-texmacs-core)
(require 'org-texmacs-ast)
(require 'org-texmacs-source)
(require 'org-texmacs-fragment)
(require 'org-texmacs-worker)
(require 'org-texmacs-context)
(require 'org-texmacs-document)
(require 'org-texmacs-input)
(require 'org-texmacs-session)

(defconst org-texmacs--cache-miss (make-symbol "org-texmacs-cache-miss")
  "Sentinel distinguishing an absent cached tree from a stored value.")

;;;###autoload
(defun org-texmacs-tree (block)
  "Return the Org-compatible TeXmacs tree derived from special BLOCK.

BLOCK must be an up-to-date TeXmacs special block in the current Org buffer,
with its contents accessible under the current narrowing.  Obtain it again
after editing, for example with `org-element-at-point' at the block opening.
The caller is responsible for supplying an element from the correct buffer.

On a cache miss, synchronously parse the raw STM source with the shared
TeXmacs worker and convert the stree to an Org pseudo tree.  Cache the result
through Org's custom element cache with default invalidation.  Unrelated
edits may also invalidate this best-effort cache.  No edit hooks are installed.

Treat the returned tree as read-only: cache hits return the same object.
Its root is detached from BLOCK; its children have Org parent links.  An
atomic TeXmacs string yields an unpropertized string.  BLOCK remains a native
Org special block, and the source text is not modified.

Signal `org-texmacs-error' for invalid input or text changed during parsing,
`org-texmacs-parse-error' for invalid STM, and `org-texmacs-worker-error' for
worker failures.  Failed parses are never cached."
  (unless (org-texmacs--block-p block)
    (signal 'org-texmacs-error '("Expected a TeXmacs special block")))
  (let ((cached (org-element-cache-get-key
                 block 'org-texmacs-tree org-texmacs--cache-miss)))
    (if (not (eq cached org-texmacs--cache-miss))
        cached
      (let* ((buffer (current-buffer))
             (tick (buffer-chars-modified-tick))
             (source (org-texmacs--block-source block))
             (stree (org-texmacs--worker-request source)))
        ;; Waiting for process output may run timers that edit or kill buffer.
        ;; This guards one synchronous call, without tracking block identities.
        (unless (and (buffer-live-p buffer)
                     (eq (current-buffer) buffer)
                     (= tick (buffer-chars-modified-tick)))
          (signal 'org-texmacs-error '("Org source changed during TeXmacs parsing")))
        (let ((tree (org-texmacs--stree-to-org stree)))
          (org-element-cache-store-key block 'org-texmacs-tree tree)
          tree)))))

;;;###autoload
(defun org-texmacs-fragment-tree (span)
  "Return the Org-compatible TeXmacs tree derived from fragment SPAN.

Obtain SPAN with `org-texmacs-fragment-at-point' or `org-texmacs-fragment-map'.
It must belong to the current Org buffer and be fully accessible under the
current narrowing.  Obtain another span after any character edit, including
edits outside its range, or changes to `org-texmacs-fragment-tags'.
Text property changes alone do not invalidate it.

Synchronously parse the current raw source using the same persistent worker
as `org-texmacs-tree', then convert its stree with the shared AST adapter.
Every call requests a new parse; no fragment cache or edit hooks are used.
Recheck the span after waiting, rejecting changed source or configuration.

Return a fresh pseudo tree with the source root tag and Org parent links
inside the tree.  Do not attach it to SPAN or an Org paragraph.  Strings are
copied by the adapter; neither source nor native Org AST is modified.  Parser
success does not imply valid tag arities, mathematical meaning or rendering.

Signal `org-texmacs-error' for invalid or stale spans, inaccessible bounds or
source changes during parsing, `org-texmacs-parse-error' for invalid STM or a
root tag mismatch, and `org-texmacs-worker-error' for worker failures."
  (let* ((source (org-texmacs--fragment-source span))
         (stree (org-texmacs--worker-request source)))
    ;; Waiting may run timers that edit/kill the buffer or change narrowing.
    (org-texmacs--fragment-source span)
    (unless (and (consp stree) (symbolp (car stree))
                 (equal (symbol-name (car stree)) (org-texmacs-fragment-span-tag span)))
      (signal 'org-texmacs-parse-error '("TeXmacs root differs from fragment tag")))
    (org-texmacs--stree-to-org stree)))

;;;###autoload
(defun org-texmacs-document (input)
  "Lower prepared INPUT into a fresh structural TeXmacs document result.
INPUT must be an `org-texmacs-input' made by `org-texmacs-input-create' or
`org-texmacs-prepare-buffer'.  Consume only its fixed AST, INFO, mappings,
STYLE, INITIAL and source location strings;
do not read source buffers, collect configuration, parse STM or start a worker.
Treat INPUT and the returned result, including nested data, as read-only.
Unsupported structures signal `org-texmacs-document-error'.  For source
preparation and conversion together, use `org-texmacs-document-from-buffer'."
  (unless (org-texmacs-input-p input)
    (signal 'org-texmacs-document-error '("Expected an org-texmacs-input")))
  (org-texmacs--document-lower
   (org-texmacs-input-ast input) (org-texmacs-input-islands input)
   (org-texmacs-input-post-blanks input) (org-texmacs-input-info input)
   (org-texmacs-input-style input) (org-texmacs-input-initial input)
   (org-texmacs-input-source-file input) (org-texmacs-input-resource-base input)
   (org-texmacs-input-bibliography input)))

(defun org-texmacs--bibliography-format (plan)
  "Prepare native plain bibliography output for fixed PLAN using the worker."
  (let* ((prefix (plist-get plan :prefix)) (keys (plist-get plan :keys))
         (entries (plist-get plan :entries)) body)
    (cl-labels ((wire (node)
                  (if (stringp node) (org-texmacs--scheme-string node)
                    (concat "(" (org-texmacs--scheme-string (symbol-name (car node)))
                            (mapconcat (lambda (child) (concat " " (wire child))) (cdr node) "") ")"))))
      (let ((response (org-texmacs--worker-call
                       (lambda (id)
                         (format "(format-bibliography %d %s %s)\n" id
                                 (org-texmacs--scheme-string prefix) (wire entries))))))
        (when (and (eq (car response) 'error) (stringp (nth 2 response)))
          (signal 'org-texmacs-document-error (list (nth 2 response))))
        (condition-case err
            (progn
              (unless (eq (car response) 'ok)
                (signal 'org-texmacs-worker-error '("Invalid bibliography response status")))
              (setq body (org-texmacs--document-copy-stree (nth 2 response)))
              (unless (and (consp body) (eq (car body) 'bib-list) (= (length body) 3)
                           (equal (sort (org-texmacs--document-static-labels (list (cons 'body body)))
                                        #'string-lessp)
                                  (sort (mapcar (lambda (key) (concat prefix "-" key)) keys)
                                        #'string-lessp)))
                (signal 'org-texmacs-worker-error '("Invalid formatted bibliography payload"))))
          (org-texmacs-error
           (org-texmacs--worker-stop)
           (signal 'org-texmacs-worker-error (cdr err))))))
    (list prefix keys entries body)))

;;;###autoload
(defun org-texmacs-prepare-buffer (source-buffer &optional bibliography-sources)
  "Prepare a buffer-independent structural input from SOURCE-BUFFER.
Apply the source and supported-subset contract of
`org-texmacs-document-from-buffer', including preflight and STM parsing.
Return an `org-texmacs-input', without opening a native session.
BIBLIOGRAPHY-SOURCES explicitly maps source paths to BibTeX text strings.
Capture paths relative to the Org source resource base, validate text before
worker requests, and own native parsed entries in the input's BIBLIOGRAPHY.
Never open these paths or query a bibliography database.  Resolve document
bibliography declarations, bare default citations and one bibliography print,
then prepare native plain output in the fixed INFO context."
  (org-texmacs--prepare-buffer source-buffer #'identity bibliography-sources))

;;;###autoload
(defun org-texmacs-document-from-buffer (source-buffer &optional bibliography-sources)
  "Convert the complete Org SOURCE-BUFFER to a text document result.

SOURCE-BUFFER must be a live, unnarrowed Org buffer object, not a name
or file path.  Capture source text and supported configuration from it,
independently of the caller's current buffer.  For a convenience wrapper,
use `org-texmacs-document-current-buffer'.
BIBLIOGRAPHY-SOURCES is the explicit text snapshot alist accepted by
`org-texmacs-prepare-buffer'.  Bibliography declarations must match those source
identities.  Bare default citations require exactly one bibliography print.

Return an `org-texmacs-document' structure with BODY, STYLE, INITIAL and
STM-PATHS, SOURCE-FILE, RESOURCE-BASE and FILE-PATHS accessors.
This is a new derived result, not an Org live AST replacement or a native
encoded tree.  Treat it and its nested contents as read-only.

Support paragraphs, plain text, bold/italic/underline/strike-through,
inline code/verbatim, explicit paragraph line breaks, five sectioning levels
and lower-level headline lists, the three Org list types, and quote/center
containers, static example/fixed-width/source blocks, and basic rectangular
Org tables with rule rows,
plus http/https/mailto/ftp/ftps URI links with optional inline descriptions,
same-document headline/ID and dedicated-target links,
plain local body file links with raw paths and target provenance,
anonymous inline footnotes directly in paragraphs,
plus complete TeXmacs special blocks and discovered paragraph fragments.
Normalize ordinary spaces, tabs and soft newlines in Org inline text,
including literal inline code; do not normalize STM subtree contents.
Use SOURCE-BUFFER's `org-texmacs-fragment-tags'.  Other Org nodes and metadata
outside the documented subset signal `org-texmacs-document-error'.  Reject
narrowing; do not widen implicitly,
expand INCLUDE, execute Babel, run export hooks or read external files.
Copy effective TODO, DONE, priority regexp and headline-level settings into
the private Org parser; do not silently reinterpret customized headings.
Levels are Org's parsed levels, including its odd-level policy.  Other
parser customization is not supported.  TODO, priority and explicit tags use
standard `org-export-with-todo-keywords', `org-export-with-priority' and
`org-export-with-tags' settings with `org-texmacs-format-headline-function'.
Lower supported rich title/author/date metadata into body `doc-data'.  Apply
headline depth and numbering options, including UNNUMBERED.  Build a static
table of contents from the filtered headline set when `org-export-with-toc'
is non-nil; use parsed ALT_TITLE for TOC text and generated labels with
`hlink' and `pageref' for structural navigation.  Resolve same-document
headline, CUSTOM_ID, ID and dedicated-target links from the owned AST, without
cross-file or global ID lookup.  This does not resolve page numbers.
Capture the base buffer's file name as source identity and SOURCE-BUFFER's
effective `default-directory' as the resource base, keeping them distinct.
Expand any home-directory abbreviation once during preparation.
Do not expand resource paths or read linked files.  Reject either location
changing during conversion, including changes that leave source text intact.
Snapshot the supported Org document context once; later changes affect only
the next conversion.  Merge the documented #+OPTIONS and metadata keyword
subset, then apply Org's task/archive/select/exclude/comment filtering before
worker requests.  Reject unsupported options and preprocessing directives.
Capture SOURCE-BUFFER's `tab-width' for preformatted text.  Do not execute
source blocks, process coderefs/noweb, or apply syntax highlighting.
Reject table formulas, layout/control rows and columns, and non-rectangular
tables.  Table cells use the existing inline subset without STM discovery.

Prepare a private snapshot without mode hooks or export preprocessing,
validate supported structure,
then synchronously parse each island with the shared worker.  Do not cache
the result.  Invoke headline formatters outside private parser bindings,
both during structural preflight and final lowering.  Do not modify
source/live Org nodes.  Reject source, mode, narrowing
or tag/heading/link-setting changes while waiting.  Parser and worker errors
propagate unchanged.
The result preserves source-dependent text semantics for later encoding;
it does not provide export, native buffer updates or rendering."
  (org-texmacs--prepare-buffer source-buffer #'org-texmacs-document bibliography-sources))

(defun org-texmacs--prepare-buffer (source-buffer consumer &optional bibliography-sources)
  "Prepare SOURCE-BUFFER and call CONSUMER before the final source check."
  (unless (and (bufferp source-buffer) (buffer-live-p source-buffer))
    (signal 'org-texmacs-document-error '("Expected a live Org buffer object")))
  (with-current-buffer source-buffer
    (unless (and (derived-mode-p 'org-mode) (not (buffer-narrowed-p)))
      (signal 'org-texmacs-document-error '("Expected an unnarrowed Org buffer")))
    (let* ((buffer source-buffer)
           (mode major-mode)
           (tick (buffer-chars-modified-tick))
           (source-file-value
            (when-let* ((file (buffer-file-name (buffer-base-buffer))))
              (substring-no-properties file)))
           (source-directory-value
            (and default-directory (substring-no-properties default-directory)))
           (source-file (org-texmacs--source-capture-path source-file-value))
           (resource-base (org-texmacs--source-capture-path source-directory-value))
           (bibliography-source-snapshot
            (org-texmacs--bibliography-source-snapshot bibliography-sources resource-base))
           (bibliography-original-snapshot
            (mapcar (lambda (entry)
                      (cons (substring-no-properties (car entry))
                            (substring-no-properties (cdr entry))))
                    bibliography-sources))
           (bibliography-signatures
            (mapcar (lambda (entry)
                      (org-texmacs--bibliography-validate-source (cdr entry)))
                    bibliography-source-snapshot))
           (bibliography nil)
           (tags (org-texmacs--fragment-tags))
           (heading-settings (org-texmacs--document-heading-settings))
           (link-settings (org-texmacs--document-link-settings))
           (base-info (plist-put (org-texmacs--document-options) :texmacs-resource-base resource-base))
           (style (org-texmacs--document-copy-style org-texmacs-document-style))
           (initial (org-texmacs--document-copy-initial org-texmacs-document-initial))
           (source (buffer-substring-no-properties (point-min) (point-max)))
           (prepared (org-texmacs--document-prepare-source
                      source tags heading-settings link-settings base-info))
           (info (nth 4 prepared)))
      (cl-labels ((check ()
                   (unless (buffer-live-p buffer)
                     (signal 'org-texmacs-document-error '("Source buffer was killed")))
                   (with-current-buffer buffer
                     (unless (and (eq major-mode mode) (derived-mode-p 'org-mode)
                                  (= tick (buffer-chars-modified-tick)))
                       (signal 'org-texmacs-document-error '("Source buffer changed")))
                     (org-texmacs--fragment-check-tags tags)
                     (unless (equal bibliography-original-snapshot bibliography-sources)
                       (signal 'org-texmacs-document-error
                               '("Bibliography source texts changed during preparation")))
                     (unless (and (equal source-file-value
                                         (buffer-file-name (buffer-base-buffer)))
                                  (equal source-directory-value default-directory))
                       (signal 'org-texmacs-document-error
                               '("Source location changed during conversion")))
                     (unless (equal heading-settings (org-texmacs--document-heading-settings))
                       (signal 'org-texmacs-document-error
                               '("Org heading settings changed during conversion")))
                     (unless (equal link-settings (org-texmacs--document-link-settings))
                       (signal 'org-texmacs-document-error
                               '("Org link settings changed during conversion")))
                     (when (buffer-narrowed-p)
                       (signal 'org-texmacs-document-error '("Source became narrowed"))))))
        (check)
        (let (keys)
          (dolist (signatures bibliography-signatures)
            (dolist (signature signatures)
              (when (member (nth 1 signature) keys)
                (signal 'org-texmacs-document-error '("Duplicate bibliography key")))
              (push (nth 1 signature) keys))))
        ;; Run user formatters only after private parser bindings have unwound.
        ;; Reject unsupported structure before starting any island request.
        (let* ((placeholder
                (cl-mapcar
                 (lambda (entry signatures)
                   (cons (car entry)
                         (cons 'document
                               (mapcar (lambda (signature)
                                         (list 'bib-entry (nth 0 signature) (nth 1 signature)
                                               (cons 'document
                                                     (mapcar (lambda (field) (list 'bib-field field ""))
                                                             (nth 2 signature))))) signatures))))
                 bibliography-source-snapshot bibliography-signatures))
               (plan (org-texmacs--bibliography-plan
                      (nth 0 prepared) (nth 1 prepared) info placeholder
                      (org-texmacs--document-resolve (nth 0 prepared) (nth 1 prepared) nil resource-base) nil)))
          (setq bibliography placeholder)
          (setq info (plist-put info :texmacs-bibliography-output
                                (list (plist-get plan :prefix) (plist-get plan :keys)
                                      (plist-get plan :entries)
                                      (list 'bib-list (number-to-string (length (plist-get plan :keys)))
                                            (cons 'document
                                                  (mapcar (lambda (key)
                                                            (list 'concat '(bibitem* "0")
                                                                  (list 'label (concat (plist-get plan :prefix) "-" key))))
                                                          (plist-get plan :keys))))))))
        (org-texmacs--document-lower (nth 0 prepared) (nth 1 prepared)
                                     (nth 3 prepared) info style initial
                                     source-file resource-base
                                     bibliography)
        (check)
        (dolist (request (nth 2 prepared))
          (check)
          (let ((stree (org-texmacs--worker-request (nth 1 request)))
                (tag (nth 2 request)))
            (check)
            (when (and tag (not (and (consp stree) (symbolp (car stree))
                                    (equal tag (symbol-name (car stree))))))
              (signal 'org-texmacs-parse-error '("TeXmacs root differs from fragment tag")))
            (setcdr (car request) stree)))
        (setq bibliography nil)
        (cl-mapc
         (lambda (entry expected)
           (check)
           (let ((tree (org-texmacs--worker-request (cdr entry) 'bibliography)))
             (check)
             (condition-case err
                 (let* ((owned (org-texmacs--bibliography-copy (list (cons (car entry) tree))))
                        (parsed (cdar owned))
                        (actual
                         (mapcar (lambda (item)
                                   (list (nth 1 item) (nth 2 item)
                                         (mapcar (lambda (field) (nth 1 field))
                                                 (cdr (nth 3 item)))))
                                 (cdr parsed))))
                   (unless (equal expected actual)
                     (signal 'org-texmacs-document-error '("Native bibliography changed entry structure")))
                   (push (car owned) bibliography))
               (org-texmacs-document-error
                (org-texmacs--worker-stop)
                (signal 'org-texmacs-worker-error (cdr err))))))
         bibliography-source-snapshot bibliography-signatures)
        (setq bibliography (nreverse bibliography))
        (let* ((static (org-texmacs--document-static-labels (nth 1 prepared)))
               (resolution (org-texmacs--document-resolve (nth 0 prepared) (nth 1 prepared) static resource-base))
               (plan (org-texmacs--bibliography-plan
                      (nth 0 prepared) (nth 1 prepared) info bibliography resolution static)))
          (when (plist-get plan :prints)
            (check)
            (setq info (plist-put info :texmacs-bibliography-output
                                  (org-texmacs--bibliography-format plan)))
            (check)))
        (let ((result (funcall consumer
                               (org-texmacs-input-create
                                (nth 0 prepared) info
                                :islands (nth 1 prepared)
                                :post-blanks (nth 3 prepared)
                                :style style :initial initial
                                :source-file source-file
                                :resource-base resource-base
                                :bibliography bibliography))))
          ;; The constructor owns a separate copy of parsed dependency data.
          (check)
          result)))))

;;;###autoload
(defun org-texmacs-export-from-buffer (source-buffer &optional bibliography-sources)
  "Export explicit Org SOURCE-BUFFER to a complete native .tm byte string.
Use the same restricted preparation, configuration snapshot and explicit
BIBLIOGRAPHY-SOURCES text snapshots as `org-texmacs-document-from-buffer'.
Lower and serialize inside preparation's final source consistency check, so
source, parser or dependency changes during native waits reject the export.
Preserve SOURCE-BUFFER and return an unibyte string.  No output file, live
session, export hook or generic Org export backend is created or invoked.
Unsupported directives retain the existing explicit preparation errors."
  (org-texmacs--prepare-buffer
   source-buffer
   (lambda (input) (org-texmacs-document-serialize (org-texmacs-document input)))
   bibliography-sources))

;;;###autoload
(defun org-texmacs-export-to-file (source-buffer file &optional bibliography-sources)
  "Export explicit Org SOURCE-BUFFER to a new local native file at FILE.
Validate and copy the absolute destination before preparation.  Export with
`org-texmacs-export-from-buffer' and BIBLIOGRAPHY-SOURCES, checking source and
dependency consistency through native serialization before opening the file.
Write the already serialized bytes once and return the copied path.
The destination does not redefine source-relative links.  Existing files or
symlinks are never overwritten; use the same exclusive creation and file-error
boundary as `org-texmacs-document-save'.  No source/output buffer is visited or
changed, and no generic Org export preprocessing or session update runs."
  (let ((target (org-texmacs--native-save-target file)))
    (org-texmacs--native-save-bytes
     (org-texmacs-export-from-buffer source-buffer bibliography-sources) target)))

;;;###autoload
(defun org-texmacs-document-current-buffer (&optional bibliography-sources)
  "Convert the current Org buffer using `org-texmacs-document-from-buffer'.
Pass explicit BIBLIOGRAPHY-SOURCES text snapshots to its preparation adapter."
  (org-texmacs-document-from-buffer (current-buffer) bibliography-sources))

;;;###autoload
(defun org-texmacs-check-setup ()
  "Check whether Org TeXmacs capabilities are available.

Return a cons cell whose car is the boolean result and whose cdr is a
human-readable report.  When called interactively, also display that report."
  (interactive)
  (let ((result (org-texmacs--setup-check)))
    (when (called-interactively-p 'interactive)
      (message "%s"
               (concat
                (if (car result)
                    "Org TeXmacs setup checks passed.\n"
                  "Org TeXmacs setup checks failed.\n")
                (cdr result))))
    result))

(provide 'org-texmacs)

;;; org-texmacs.el ends here
