;;; org-texmacs.el --- Mathematical-document ASTs for Org -*- lexical-binding: t; -*-

;; Copyright (C) 2026 aRenCoco

;; Author: aRenCoco
;; Maintainer: aRenCoco
;; Version: 0.7.0
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

;; Independent mathematical-document models combine native Org structure with
;; parsed TeXmacs STM islands.  Construct, inspect, transform and serialize them
;; as normalized Org; TeXmacs document export is a separate bounded consumer.
;; Core model validity is independent of lowering and serialization support.
;;
;; Package-Requires declares minimum versions.  Recorded regressions used
;; Emacs 31.1 and Org 9.8.10; Nix selects dependencies from flake.lock.
;; Org 9.8 passed API/signature and strict compilation checks for an earlier version;
;; full ERT/native behavior regression on that minimum version is unverified.
;; Org-roam and its extensions are optional integration-test dependencies.
;; CSL citations use the optional citeproc package through standard Org Cite.
;; TeXmacs is an external runtime dependency, checked by the setup command.
;;
;; Use `org-texmacs-tree' to derive an Org-compatible TeXmacs tree from a
;; native TeXmacs special block, with lazy parsing and Org-managed caching.
;; Discover paragraph source spans with `org-texmacs-fragment-at-point' or
;; `org-texmacs-fragment-map', using `org-texmacs-fragment-tags' as entry names.
;; Use `org-texmacs-fragment-tree' to parse a fragment source span on demand,
;; without caching or changing Org's native object parser.
;; Loading enables Scheme fontification of embedded STM in Org buffers.
;; Use Org's source-edit workflow for TeXmacs blocks; `org-texmacs-edit-mode'
;; selects the editing/indentation major mode, defaulting to `scheme-mode'.
;; Use `org-texmacs-model-create' to own a native Org AST and already parsed
;; STM islands independently of document lowering.  The model module can be
;; loaded alone without export preparation or a native worker.
;; Use `org-texmacs-parse-buffer' for complete-source model construction with
;; native STM parsing, without export filtering or document lowering.
;; Use `org-texmacs-model-inspect' for a readable structural projection, or
;; `org-texmacs-model-display' to show it in a new read-only buffer.
;; Use `org-texmacs-model-serialize' for normalized Org text, or
;; `org-texmacs-model-to-buffer' for a new editable Org buffer.
;; Use `org-texmacs-model-copy' for an independent snapshot,
;; `org-texmacs-model-island' for read-only access by snapshot-local node,
;; and `org-texmacs-model-replace-stm' for structural STM subtree replacement.
;; Use `org-texmacs-document' to lower an explicit prepared input, or
;; `org-texmacs-document-from-buffer' for source-buffer structural conversion
;; to a text TeXmacs document result with body, style, initial environment and
;; STM provenance, before native encoding.
;; Use `org-texmacs-session-open', `org-texmacs-session-set-document' and
;; `org-texmacs-session-close' to manage explicit native document state.
;; Source stays in Org; completed documents can be serialized, saved or rendered
;; as native PDF.  Load optional `ox-texmacs' for bounded export commands;
;; configure its menu keys before loading to enable Org dispatcher entries.
;; No GUI preview or combined live Org/TeXmacs document AST is provided.
;; Use `org-texmacs-check-setup' to inspect the capabilities required by the
;; package without starting TeXmacs.

;;; Code:

(require 'org-texmacs-core)
(require 'org-texmacs-ast)
(require 'org-texmacs-source)
(require 'org-texmacs-fragment)
(require 'org-texmacs-font-lock)
(require 'org-texmacs-edit)
(require 'org-texmacs-worker)
(require 'org-texmacs-context)
(require 'org-texmacs-document)
(require 'org-texmacs-input)
(require 'org-texmacs-session)

(autoload 'org-texmacs--standard-source-consume "org-texmacs-export")

(autoload
  'org-texmacs-document-from-buffer-discover-bibliography
  "org-texmacs-bibliography")
(autoload
  'org-texmacs-export-from-buffer-discover-bibliography
  "org-texmacs-bibliography")

(autoload
  'org-texmacs-prepare-buffer-preprocessed "org-texmacs-preprocess")
(autoload
  'org-texmacs-document-from-buffer-preprocessed
  "org-texmacs-preprocess")
(autoload
  'org-texmacs-export-from-buffer-preprocessed
  "org-texmacs-preprocess")

(defconst org-texmacs--cache-miss
  (make-symbol "org-texmacs-cache-miss")
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
  (let ((cached
         (org-element-cache-get-key
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
          (signal 'org-texmacs-error
                  '("Org source changed during TeXmacs parsing")))
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
    (unless (and (consp stree)
                 (symbolp (car stree))
                 (equal
                  (symbol-name (car stree))
                  (org-texmacs-fragment-span-tag span)))
      (signal 'org-texmacs-parse-error
              '("TeXmacs root differs from fragment tag")))
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
    (signal 'org-texmacs-document-error
            '("Expected an org-texmacs-input")))
  (org-texmacs--document-lower
   (org-texmacs-input-ast input)
   (org-texmacs-input-islands input)
   (org-texmacs-input-post-blanks input)
   (org-texmacs-input-info input)
   (org-texmacs-input-style input)
   (org-texmacs-input-initial input)
   (org-texmacs-input-source-file input)
   (org-texmacs-input-resource-base input)
   (org-texmacs-input-bibliography input)
   (org-texmacs-input-resolution input)))

(defun org-texmacs--bibliography-format (plan)
  "Format explicit native bibliography PLAN at the worker boundary.
This supports constructor-supplied native data; standard Org Cite does not
call this formatter or acquire bibliography through it."
  (let* ((prefix (plist-get plan :prefix))
         (keys (plist-get plan :keys))
         (entries (plist-get plan :entries))
         body)
    (cl-labels
     ((wire
       (node)
       (if (stringp node)
           (org-texmacs--scheme-string node)
         (concat
          "(" (org-texmacs--scheme-string (symbol-name (car node)))
          (mapconcat
           (lambda (child) (concat " " (wire child))) (cdr node)
           "")
          ")"))))
     (let ((response
            (org-texmacs--worker-call
             (lambda (id)
               (format "(format-bibliography %d %s %s)\n"
                       id
                       (org-texmacs--scheme-string prefix)
                       (wire entries))))))
       (when (and (eq (car response) 'error)
                  (stringp (nth 2 response)))
         (signal 'org-texmacs-document-error (list (nth 2 response))))
       (condition-case err
           (progn
             (unless (eq (car response) 'ok)
               (signal 'org-texmacs-worker-error
                       '("Invalid bibliography response status")))
             (setq body
                   (org-texmacs--document-copy-stree
                    (nth 2 response)))
             (unless (and (consp body)
                          (eq (car body) 'bib-list)
                          (= (length body) 3)
                          (equal
                           (sort
                            (org-texmacs--bibliography-labels body)
                            #'string-lessp)
                           (sort (mapcar
                                  (lambda (key)
                                    (concat prefix "-" key))
                                  keys)
                                 #'string-lessp)))
               (signal 'org-texmacs-worker-error
                       '("Invalid formatted bibliography payload"))))
         (org-texmacs-error
          (org-texmacs--worker-stop)
          (signal 'org-texmacs-worker-error (cdr err))))))
    (org-texmacs--bibliography-check-references body prefix)
    (list prefix keys entries body)))

;;;###autoload
(defun org-texmacs-prepare-buffer
    (source-buffer
     &optional bibliography-sources subtree-position region ext-plist)
  "Return standard input from explicit SOURCE-BUFFER once.
BIBLIOGRAPHY-SOURCES must be nil.  Other arguments use standard source rules."
  (org-texmacs--standard-source-consume
   'input
   source-buffer
   bibliography-sources
   subtree-position
   region
   ext-plist))

;;;###autoload
(defun org-texmacs-document-from-buffer
    (source-buffer
     &optional bibliography-sources subtree-position region ext-plist)
  "Return standard document from explicit SOURCE-BUFFER once.
BIBLIOGRAPHY-SOURCES must be nil.  Other arguments use standard source rules."
  (org-texmacs--standard-source-consume
   'document
   source-buffer
   bibliography-sources
   subtree-position
   region
   ext-plist))

;;;###autoload
(defun org-texmacs-export-texmacs-from-buffer
    (source-buffer
     &optional bibliography-sources subtree-position region ext-plist)
  "Export explicit Org SOURCE-BUFFER to final native .tm bytes.
Run one standard Org export transaction on a live Org buffer object.
BIBLIOGRAPHY-SOURCES must be nil. Configure standard Org Cite instead.

SUBTREE-POSITION selects its accessible containing heading.
REGION is a nonempty integer (BEGIN . END) body range.
When both are given, the heading at BEGIN must match the subtree heading;
otherwise fail before preparation. Nil REGION ignores an active region.
Preserve source point, mark and restriction independently of the caller.

Own EXT-PLIST before hooks. Org manages options, selection, AST filters
and Cite. Final text filters feed reversible Latin-1 transport.
Lossy conversion fails. Return unibyte data after source/native checks.
No file is written. Load the backend only at export use."
  (org-texmacs--standard-source-consume
   'tm
   source-buffer
   bibliography-sources
   subtree-position
   region
   ext-plist))

;;;###autoload
(defun org-texmacs-export-pdf-from-buffer
    (source-buffer
     &optional bibliography-sources subtree-position region ext-plist)
  "Render explicit Org SOURCE-BUFFER to native PDF bytes.
Run one standard export transaction. Arguments and selection follow
`org-texmacs-export-texmacs-from-buffer'; supplied BibTeX texts fail.
Consume the completed native document without a .tm text round trip.
Reject incompatible text filters/finalizers before their tail effects.
Return unibyte PDF data after source/native-setting checks.
No output file or viewer is created."
  (org-texmacs--standard-source-consume
   'pdf
   source-buffer
   bibliography-sources
   subtree-position
   region
   ext-plist))

;;;###autoload
(defun org-texmacs-export-to-pdf-file
    (source-buffer file &optional bibliography-sources)
  "Render explicit Org SOURCE-BUFFER to a new local PDF at absolute FILE.
Capture the destination before one standard export transaction.
BIBLIOGRAPHY-SOURCES must be nil. Pass the actual path in INFO
without aliasing the write target. Check source before writing.
Use exclusive creation and native saving's partial-write error boundary.
This API is noninteractive and opens no viewer."
  (let ((target (org-texmacs--native-save-target file)))
    (org-texmacs--native-save-bytes
     (org-texmacs-export-pdf-from-buffer
      source-buffer
      bibliography-sources
      nil
      nil
      (list :output-file (substring-no-properties target)))
     target)
    target))

(defun org-texmacs--export-interactive-source ()
  "Return the current Org source for an interactive export command."
  (unless (derived-mode-p 'org-mode)
    (user-error "Export requires an Org source buffer"))
  (current-buffer))

(defun org-texmacs--source-buffer-text ()
  "Copy the complete current source text, restoring its restriction immediately.
Do not parse, invoke callbacks or wait while widened for this read."
  (save-restriction
    (widen)
    (buffer-substring-no-properties (point-min) (point-max))))

(defun org-texmacs--export-source-copy (source function)
  "Call FUNCTION in a private full copy of SOURCE for heading/output metadata.
Retain file/directory and heading/property context without live source widening
during Org parsing or prompts.  Do not run mode hooks or export preprocessing."
  (let (text
        file
        directory
        headings
        settings)
    (with-current-buffer source
      (setq
       text (org-texmacs--source-buffer-text)
       file (buffer-file-name (buffer-base-buffer))
       directory default-directory
       headings (org-texmacs--document-heading-settings)
       settings (org-texmacs--context-subtree-settings)))
    (with-temp-buffer
      (let ((org-element-use-cache nil)
            (org-inhibit-startup t)
            (org-use-property-inheritance (nth 0 settings))
            (org-property-separators (nth 1 settings))
            (org-global-properties (nth 2 settings))
            (org-global-properties-fixed (nth 3 settings))
            (org-entry-property-inherited-from (make-marker)))
        (delay-mode-hooks
          (org-mode))
        (org-texmacs--document-use-heading-settings headings)
        (setq-local default-directory directory)
        (insert text)
        ;; Provide filename metadata only during lookup, without making the
        ;; private buffer a visiting source when it is disposed.
        (let ((buffer-file-name file))
          (funcall function))))))

;;;###autoload
(defun org-texmacs-export-to-buffer
    (source-buffer
     &optional bibliography-sources subtree-position region ext-plist)
  "Export explicit Org SOURCE-BUFFER to a fresh readonly native byte buffer.
Arguments follow `org-texmacs-export-texmacs-from-buffer'.
BIBLIOGRAPHY-SOURCES must be nil; use standard Org Cite instead.
Return a new unibyte `special-mode' buffer without display.
Use no-conversion coding, no visiting file and no mode hooks.
Create it only after successful conversion and source checks.
Existing result buffers are never reused or changed.
The caller owns the result's lifetime."
  (org-texmacs--export-byte-buffer
   (org-texmacs-export-texmacs-from-buffer
    source-buffer
    bibliography-sources subtree-position region ext-plist)))

(defun org-texmacs--export-byte-buffer (bytes &optional name)
  "Create a fresh readonly native view of checked unibyte BYTES.
Optional NAME overrides the explicit-source result name prefix."
  (let* ((output
          (generate-new-buffer
           (or name "*Org TeXmacs Source Export*")))
         complete)
    (unwind-protect
        (progn
          (with-current-buffer output
            (let ((change-major-mode-hook nil)
                  (after-change-major-mode-hook nil))
              (delay-mode-hooks
                (special-mode)))
            (set-buffer-multibyte nil)
            (let ((inhibit-read-only t)
                  (inhibit-modification-hooks t))
              (insert bytes))
            (setq-local buffer-file-coding-system 'no-conversion)
            (setq-local buffer-file-format nil)
            (setq-local buffer-offer-save nil)
            (setq buffer-undo-list t)
            (set-buffer-modified-p nil)
            (goto-char (point-min)))
          (setq complete t)
          output)
      (unless complete
        (let ((kill-buffer-query-functions nil))
          (when (buffer-live-p output)
            (kill-buffer output)))))))

;;;###autoload
(defun org-texmacs-export-to-texmacs-file
    (source-buffer file &optional bibliography-sources)
  "Export explicit Org SOURCE-BUFFER to a new native file at absolute FILE.
Copy the destination before one standard export transaction.
BIBLIOGRAPHY-SOURCES must be nil; configure standard Org Cite instead.
Pass the actual path in INFO without aliasing the write target.
Write checked native bytes once without conversion or an extra newline.
Source-relative resources retain their captured base.
Existing files and symlinks are never overwritten.
Use exclusive creation and the native partial-write file-error boundary.
No output buffer or viewer is opened."
  (let ((target (org-texmacs--native-save-target file)))
    (org-texmacs--native-save-bytes
     (org-texmacs-export-texmacs-from-buffer
      source-buffer
      bibliography-sources
      nil
      nil
      (list :output-file (substring-no-properties target)))
     target)
    target))

;;;###autoload
(defun org-texmacs-document-current-buffer
    (&optional bibliography-sources)
  "Convert the current Org buffer using `org-texmacs-document-from-buffer'.
BIBLIOGRAPHY-SOURCES must be nil; configure standard Org Cite instead."
  (org-texmacs-document-from-buffer (current-buffer)
                                    bibliography-sources))

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
