;;; org-texmacs.el --- TeXmacs AST integration for Org -*- lexical-binding: t; -*-

;; Copyright (C) 2026 aRenCoco

;; Author: aRenCoco
;; Maintainer: aRenCoco
;; Version: 0.1.0
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
;; Use `org-texmacs-document' for a limited whole-buffer structural conversion
;; to a text TeXmacs body with STM provenance, before native encoding.
;; Source stays in Org; no external .tm file is required.  This package does
;; not provide preview, export, numbering or a combined Org/TeXmacs document AST.
;; Use `org-texmacs-check-setup' to inspect the capabilities required by the
;; package without starting TeXmacs.

;;; Code:

(require 'org-texmacs-core)
(require 'org-texmacs-ast)
(require 'org-texmacs-source)
(require 'org-texmacs-fragment)
(require 'org-texmacs-worker)
(require 'org-texmacs-document)

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
(defun org-texmacs-document ()
  "Convert the complete current Org buffer to a text document result.

Return an `org-texmacs-document' structure with BODY and STM-PATHS accessors.
This is a new derived result, not an Org live AST replacement or a native
encoded tree.  Treat it and its nested contents as read-only.

Support paragraphs, plain text, bold and level 1--3 headings, plus complete
TeXmacs special blocks and discovered paragraph fragments.  Use the current
`org-texmacs-fragment-tags'.  Other Org nodes and semantic metadata signal
`org-texmacs-document-error'.  Reject narrowing; do not widen implicitly,
expand INCLUDE, execute Babel, run export hooks or read external files.
Reject effective TODO or headline-level settings that differ from the
private Org parser; do not silently reinterpret customized headings.

Prepare a private snapshot without mode hooks, validate supported structure,
then synchronously parse each island with the shared worker.  Do not cache
the result or modify source/live Org nodes.  Reject source, mode, narrowing
or tag changes while waiting.  Parser and worker errors propagate unchanged.
The result preserves source-dependent text semantics for later encoding;
it does not provide export, native buffer updates or rendering."
  (unless (and (derived-mode-p 'org-mode) (not (buffer-narrowed-p)))
    (signal 'org-texmacs-document-error '("Expected an unnarrowed Org buffer")))
  (let* ((buffer (current-buffer))
         (tick (buffer-chars-modified-tick))
         (tags (org-texmacs--fragment-tags))
         (heading-settings (org-texmacs--document-heading-settings))
         (source (buffer-substring-no-properties (point-min) (point-max)))
         (spans (org-texmacs--fragment-collect tags))
         (prepared (org-texmacs--document-prepare source spans heading-settings)))
    (cl-labels ((check ()
                 (org-texmacs--fragment-check-source buffer tick)
                 (org-texmacs--fragment-check-tags tags)
                 (unless (equal heading-settings (org-texmacs--document-heading-settings))
                   (signal 'org-texmacs-document-error
                           '("Org heading settings changed during conversion")))
                 (when (buffer-narrowed-p)
                   (signal 'org-texmacs-document-error '("Source became narrowed")))))
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
      (org-texmacs--document-lower (nth 0 prepared) (nth 1 prepared)
                                 (nth 3 prepared)))))

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
