;;; org-texmacs-export.el --- Standard export handoff -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Consume prepared structures inside the real Org exporter.  Org owns all
;; preparation.  A scoped request can retain the owned input/document while the
;; standard call returns normally; native consumers never reconstruct that data
;; from serialized text.  The prepared adapter recognizes STM from the final
;; tree.  Unsupported structures fail explicitly at the consumer boundary.

;;; Code:

(require 'ox)
(require 'oc)
(require 'oc-csl)
(require 'org-texmacs-cite-native)

(defun org-texmacs--standard-unadvised-definition (name)
  "Return function NAME's definition only when it has no advice."
  (let (advised)
    (advice-mapc
     (lambda (_function _properties) (setq advised t)) name)
    (unless advised
      (symbol-function name))))

(defconst org-texmacs--standard-csl-finalizer
  (org-texmacs--standard-unadvised-definition 'org-cite-csl-finalizer)
  "Known unadvised CSL finalizer captured when this module loads.")
(defconst org-texmacs--standard-csl-format
  (org-texmacs--standard-unadvised-definition
   'org-cite-csl--output-format)
  "Known unadvised CSL format dispatch captured when this module loads.")

(require 'org-texmacs-input)
(require 'org-texmacs-session)
(require 'org-texmacs-fragment)
(require 'org-texmacs-prepared)
(require 'org-texmacs-query)

(defvar org-texmacs--standard-request nil
  "Private, single-invocation structured result request.")
(defvar org-texmacs--standard-transaction nil
  "Current standard TeXmacs export transaction, isolated across nested calls.")

(defun org-texmacs--standard-backend-p (backend)
  "Whether BACKEND is the TeXmacs backend or one of its derivatives."
  (org-export-derived-backend-p backend 'texmacs))

(defun org-texmacs--standard-node-filters (info)
  "Reject unsupported effective node-string filters in TeXmacs INFO.
Options and parse-tree filters operate normally.  Body/final-output filters
operate on the final serialized text.  Do not run node filters and then discard
their string result when consuming the prepared AST."
  (when (org-texmacs--standard-backend-p (plist-get info :back-end))
    (dolist (entry org-export-filters-alist)
      (let ((key (car entry)))
        (when (and (not
                    (memq
                     key
                     '(:filter-options
                       :filter-parse-tree
                       :filter-body
                       :filter-final-output)))
                   (plist-get info key))
          (signal 'org-texmacs-document-error
                  (list
                   "Unsupported TeXmacs node-string filter" key)))))))

(defun org-texmacs--standard-options (info _backend)
  "Check initial effective filters in INFO before later export stages."
  (org-texmacs--standard-node-filters info)
  info)

(defun org-texmacs--standard-tree (tree _backend info)
  "Check filters installed by options filters, returning standard TREE."
  (org-texmacs--standard-node-filters info)
  tree)

(defun org-texmacs--standard-capture-id-base (info)
  "Capture the directory for Org's collected ID filenames in INFO once.
Call at the first standard dispatch after tree-property collection, before
Cite callbacks or, with Cite disabled, before root-tree transcoding.  The
root identity binds the capture to this transaction's prepared tree."
  (let ((tree (plist-get info :parse-tree)))
    (when (and org-texmacs--standard-transaction
               (org-texmacs--standard-backend-p
                (plist-get info :back-end))
               (eq (org-element-type tree) 'org-data)
               (plist-member info :id-alist)
               (not
                (plist-get
                 org-texmacs--standard-transaction
                 :id-resolution-tree)))
      (setf
       (plist-get
        org-texmacs--standard-transaction
        :id-resolution-tree)
       tree
       (plist-get
        org-texmacs--standard-transaction
        :id-resolution-base)
       (when (plist-get info :id-alist)
         (org-texmacs--source-capture-path default-directory))))))

(defun org-texmacs--standard-data (function data info)
  "Call Org transcoder FUNCTION for DATA/INFO after checking effective filters.
This catches reentrant transcoding and later INFO updates.  Other backends pass
through unchanged.  No Org preparation or transcoder implementation is copied."
  (org-texmacs--standard-node-filters info)
  ;; Without Cite, Org immediately transcodes the collected root tree.  Do
  ;; not use a later transcoding call to infer a missing Cite-time capture.
  (when (and (not (plist-get info :with-cite-processors))
             (eq data (plist-get info :parse-tree)))
    (org-texmacs--standard-capture-id-base info))
  (funcall function data info))

(defun org-texmacs--standard-cite (info)
  "Check INFO and capture ID filename context before Cite callbacks execute."
  (org-texmacs--standard-node-filters info)
  (org-texmacs--standard-capture-id-base info))

(defun org-texmacs--standard-copy-options (value)
  "Own mutable VALUE data, preserving functions and opaque object identities.
A memoized graph copy also preserves parent links in parsed Org metadata."
  (unless (and (proper-list-p value)
               (cl-evenp (length value))
               (cl-loop
                for
                (key _value)
                on
                value
                by
                #'cddr
                always
                (keywordp key)))
    (signal 'org-texmacs-document-error
            '("Expected an Org export option plist")))
  (let ((copies (make-hash-table :test #'eq)))
    (cl-labels
     ((copy
       (item)
       (cond
        ((functionp item)
         item)
        ((gethash item copies))
        ((stringp item)
         (let ((new (substring-no-properties item)))
           (puthash item new copies)
           new))
        ((consp item)
         (let ((new (cons nil nil)))
           (puthash item new copies)
           (setcar new (copy (car item)))
           (setcdr new (copy (cdr item)))
           new))
        ((recordp item)
         item)
        ((vectorp item)
         (let ((new (copy-sequence item)))
           (puthash item new copies)
           (dotimes (index (length item))
             (aset new index (copy (aref item index))))
           new))
        (t
         item))))
     (copy value))))

(defun org-texmacs--standard-source-state ()
  "Capture source identity and native presentation settings without preparation."
  (list
   (current-buffer)
   (buffer-chars-modified-tick)
   major-mode
   (point-min)
   (point-max)
   (when-let* ((file (buffer-file-name (buffer-base-buffer))))
     (substring-no-properties file))
   (substring-no-properties default-directory)
   (org-texmacs--document-copy-style org-texmacs-document-style)
   (org-texmacs--document-copy-initial org-texmacs-document-initial)
   (org-texmacs--fragment-tags)
   (org-texmacs--standard-copy-options
    (list
     :texmacs-tab-width tab-width
     :texmacs-format-headline-function org-texmacs-format-headline-function
     :texmacs-special-block-handlers org-texmacs--document-special-block-handlers
     :texmacs-pdf-file-links-as-absolute org-texmacs-pdf-file-links-as-absolute
     :texmacs-link-org-files-as-pdf org-texmacs-link-org-files-as-pdf))))

(defun org-texmacs--standard-check-source (state &optional selecting)
  "Reject source changes across native waits using captured STATE.
Do not roll back changes made by arbitrary callbacks."
  (let ((source (car state)))
    (unless
        (and
         (buffer-live-p source)
         (with-current-buffer source
           (let ((current (org-texmacs--standard-source-state)))
             (when selecting
               ;; Org temporarily narrows its source for selection.
               (setf
                (nth 3 current) (nth 3 state)
                (nth 4 current) (nth 4 state)))
             ;; Presentation data in the last field has already been consumed.
             ;; Keep source/style/initial/fragment guards without receipt replay.
             (equal
              (cl-subseq state 0 10) (cl-subseq current 0 10)))))
      (signal
       'org-texmacs-document-error
       '("Standard export source or native settings changed")))))

(defun org-texmacs--standard-call
    (function backend
              &optional
              subtreep
              visible-only
              body-only
              ext-plist)
  "Run real exporter FUNCTION for BACKEND in one owned transaction.
Forward standard arguments.  Structured requests use a scoped result container,
not an early exit across normal export advice or a second preparation pass."
  (if (not (org-texmacs--standard-backend-p backend))
      (funcall function
               backend
               subtreep
               visible-only
               body-only
               ext-plist)
    (when body-only
      (user-error
       "TeXmacs body-only output has no supported fragment contract"))
    (let* ((request
            (and org-texmacs--standard-request
                 (not
                  (plist-get org-texmacs--standard-request :claimed))
                 (eq
                  (plist-get ext-plist :texmacs--result-token)
                  (plist-get org-texmacs--standard-request :token))
                 org-texmacs--standard-request))
           (ext-plist
            (cl-loop
             for
             (key value)
             on
             ext-plist
             by
             #'cddr
             unless
             (eq key :texmacs--result-token)
             append
             (list key value)))
           (org-texmacs--standard-request nil)
           (org-entry-property-inherited-from (make-marker))
           (state (org-texmacs--standard-source-state))
           (org-texmacs--standard-transaction
            (list
             :consumer
             (or (plist-get request :consumer) 'text)
             :source state
             :request request
             :id-resolution-tree nil
             :id-resolution-base nil)))
      (when request
        (setf (plist-get request :claimed) t))
      (prog1 (funcall function
                      backend
                      subtreep
                      visible-only
                      nil
                      ext-plist)
        (org-texmacs--standard-check-source state)
        (when-let* ((input
                     (plist-get
                      org-texmacs--standard-transaction
                      :input)))
          (org-texmacs--prepared-cite-check input))))))

(defun org-texmacs--standard-plain (text _info)
  "Return provisional plain TEXT for Org's standard traversal.
The prepared AST remains authoritative; this is not STM text construction."
  text)

(defun org-texmacs--standard-contents (_node contents _info)
  "Return provisional CONTENTS during Org's standard traversal."
  contents)

(defun org-texmacs--standard-transcoders ()
  "Return the initial standard traversal and final handoff callbacks."
  (append
   '((plain-text . org-texmacs--standard-plain)
     (inner-template . org-texmacs--standard-inner))
   (mapcar
    (lambda (type) (cons type #'org-texmacs--standard-contents))
    (delete-dups
     (append org-element-all-elements org-element-all-objects nil)))))

(defun org-texmacs--standard-input (info state)
  "Own the prepared tree from standard INFO and source STATE.
Project supported options without repeating preparation or retaining full INFO."
  (let ((tree (plist-get info :parse-tree))
        (identities (make-hash-table :test #'eq))
        ignored
        (keys org-texmacs--context-export-options)
        (native (eq (org-cite-processor info) 'texmacs-native))
        (original (plist-get info :parse-tree))
        projected)
    ;; Resolve through public access while live, never reparse working text.
    (org-texmacs--prepared-resolve tree)
    (setq ignored
          (append
           (plist-get info :ignore-list)
           (org-texmacs--query-excluded-definitions tree info)))
    (setq tree (org-texmacs--prepared-copy tree ignored identities))
    (when native
      (setq projected
            (list
             :texmacs-cite-requests
             (org-texmacs--prepared-cite-requests
              original
              (plist-get info :texmacs-cite-requests)
              ignored
              identities))))
    (org-texmacs--prepared-footnote-bodies tree)
    (org-texmacs--prepared-check-caption-notes tree)
    (org-texmacs--prepared-control-keywords tree)
    (dolist (key keys)
      (when (plist-member info key)
        (when (memq key org-texmacs--context-rich-metadata)
          (org-texmacs--prepared-resolve (plist-get info key))
          (org-texmacs--prepared-reject-raw (plist-get info key)))
        (let ((value (plist-get info key)))
          (setq projected
                (plist-put
                 projected key
                 (if (and (memq
                           key org-texmacs--context-rich-metadata)
                          (stringp value))
                     (list value)
                   value))))))
    (setq projected
          (append
           projected
           (org-texmacs--standard-copy-options (nth 10 state))))
    (let*
        ((source-file
          (org-texmacs--source-capture-path (nth 5 state)))
         (resource-base
          (org-texmacs--source-capture-path (nth 6 state)))
         (id-resolution-base
          (when (eq
                 (plist-get info :parse-tree)
                 (plist-get
                  org-texmacs--standard-transaction
                  :id-resolution-tree))
            (plist-get
             org-texmacs--standard-transaction
             :id-resolution-base)))
         (requests
          (org-texmacs--prepared-discover tree (nth 9 state) t))
         (query
          (prog1 (org-texmacs--query-snapshot
                  tree
                  info
                  identities
                  source-file
                  resource-base
                  id-resolution-base
                  (lambda (definition)
                    (setq requests
                          (append
                           requests
                           (org-texmacs--prepared-discover
                            definition (nth 9 state))))))
            (org-texmacs--prepared-affiliation tree)))
         ;; As in the independent parser, placeholders exist only inside an
         ;; unpublished ownership transaction.  Freeze context before waits;
         ;; allocate labels only after all actual native trees are available.
         (input
          (org-texmacs--input-own
           tree (plist-put projected :texmacs-org-query query)
           :islands
           (mapcar
            (lambda (request)
              (cons (car request) '(concat "")))
            requests)
           :style (nth 7 state)
           :initial (nth 8 state)
           :source-file source-file
           :resource-base resource-base)))
      (when native
        (setq input (org-texmacs--prepared-cite-snapshot input)))
      (org-texmacs--prepared-parse
       requests (org-texmacs-input-islands input))
      (setq input (org-texmacs--input-finalize input))
      (if native
          (org-texmacs--prepared-cite-fulfill input)
        input))))

(defun org-texmacs--standard-compatible-finalizer-p (finalizer info)
  "Whether FINALIZER is a known identity operation in native INFO.
The standard CSL processor returns Org structures for this backend.  Its
unmodified finalizer only changes LaTeX output.  Do not call arbitrary functions
to predict their effects, or accept advice/redefinitions by their name alone."
  (and (eq finalizer 'org-cite-csl-finalizer)
       org-texmacs--standard-csl-finalizer
       org-texmacs--standard-csl-format
       (eq
        (org-texmacs--standard-unadvised-definition finalizer)
        org-texmacs--standard-csl-finalizer)
       (eq
        (org-texmacs--standard-unadvised-definition
         'org-cite-csl--output-format)
        org-texmacs--standard-csl-format)
       (not
        (org-export-derived-backend-p
         (plist-get info :back-end) 'latex 'html))))

(defun org-texmacs--standard-structured-tail (info)
  "Reject unproven string-tail effects for a structured consumer of INFO.
Use the selected backend's effective callbacks, not global variable presence.
Arbitrary functions are not replayed or predicted to be no-ops."
  (dolist (key '(:filter-body :filter-final-output))
    (when (plist-get info key)
      (signal
       'org-texmacs-document-error
       (list
        "Unsupported string filter for native structured output"
        key))))
  (when (plist-get info :with-cite-processors)
    (when-let* ((processor
                 (org-cite-get-processor (org-cite-processor info))))
      (when-let* ((finalizer
                   (org-cite-processor-export-finalizer processor)))
        (unless (org-texmacs--standard-compatible-finalizer-p
                 finalizer info)
          (signal
           'org-texmacs-document-error
           '("Unsupported Cite finalizer for native structured output")))))))

(defun org-texmacs--standard-inner (_provisional info)
  "Build the native document from final standard INFO in its live transaction."
  (unless org-texmacs--standard-transaction
    (signal 'org-texmacs-document-error
            '("Expected a live standard Org Export transaction")))
  (org-texmacs--standard-node-filters info)
  (let* ((transaction org-texmacs--standard-transaction)
         (state (plist-get transaction :source))
         (consumer (plist-get transaction :consumer)))
    (unless (eq consumer 'text)
      (org-texmacs--standard-structured-tail info))
    (org-texmacs--standard-check-source state t)
    (let* ((prepared-state
            (with-current-buffer (car state)
              (org-texmacs--standard-source-state)))
           (input (org-texmacs--standard-input info state))
           (document
            (unless (memq consumer '(input model))
              (org-texmacs-document input)))
           (request (plist-get transaction :request)))
      (plist-put transaction :input input)
      (when request
        (setf
         (plist-get request :input) input
         (plist-get request :document) document
         (plist-get request :source) state))
      (prog1
          (if (eq consumer 'text)
              ;; Native source uses Cork octets, not arbitrary UTF-8.  The standard
              ;; string is a reversible Latin-1 transport; file callers must use its
              ;; matching coding system.  Native byte consumers retain exact bytes.
              (decode-coding-string
               (org-texmacs-document-serialize
                document)
               'iso-latin-1-unix)
            "")
        (org-texmacs--standard-check-source prepared-state)
        (org-texmacs--prepared-cite-check input)))))

(defun org-texmacs--standard-text-bytes (text)
  "Convert final standard TEXT to native bytes without lossy substitution."
  (unless (stringp text)
    (signal 'org-texmacs-document-error
            '("Expected standard TeXmacs text output")))
  (let ((bytes (encode-coding-string text 'iso-latin-1-unix)))
    (unless (equal
             text (decode-coding-string bytes 'iso-latin-1-unix))
      (signal
       'org-texmacs-document-error
       '("Text filter output is not reversible native Latin-1 transport")))
    bytes))

(defun org-texmacs--standard-source-consume
    (consumer
     source-buffer
     bibliography-sources
     subtree-position
     region
     ext-plist)
  "Consume explicit SOURCE-BUFFER once through standard CONSUMER export.
BIBLIOGRAPHY-SOURCES must be nil; configure normal Org Cite instead.
SUBTREE-POSITION and REGION are integer selections within accessible source.
When both are given, their containing heading at REGION start must match.
Nil REGION ignores any ambient active region.  Own EXT-PLIST before hooks."
  (unless (and (bufferp source-buffer) (buffer-live-p source-buffer))
    (signal 'org-texmacs-document-error
            '("Expected a live Org buffer object")))
  (unless (memq consumer '(tm input model document pdf))
    (signal 'org-texmacs-document-error
            '("Invalid standard source consumer")))
  (when bibliography-sources
    (signal
     'org-texmacs-document-error
     '("Supplied BibTeX texts are unsupported; configure standard Org Cite")))
  (setq ext-plist (org-texmacs--standard-copy-options ext-plist))
  (with-current-buffer source-buffer
    (unless (derived-mode-p 'org-mode)
      (signal 'org-texmacs-document-error
              '("Expected an Org buffer")))
    (when (and subtree-position
               (not
                (and (integerp subtree-position)
                     (<= (point-min) subtree-position (point-max)))))
      (signal 'org-texmacs-document-error
              '("Invalid subtree source position")))
    (when (and region
               (not
                (and (consp region)
                     (integerp (car region))
                     (integerp (cdr region))
                     (<= (point-min) (car region))
                     (< (car region) (cdr region))
                     (<= (cdr region) (point-max)))))
      (signal 'org-texmacs-document-error '("Invalid source region")))
    (setq region (and region (cons (car region) (cdr region))))
    (let ((state (org-texmacs--standard-source-state)))
      (save-mark-and-excursion
        (cl-labels
         ((heading
           ()
           (condition-case nil
               (progn
                 (org-back-to-heading t)
                 (point))
             (error
              (signal 'org-texmacs-document-error
                      '("No accessible subtree at position"))))))
         (let ((selected-heading
                (and subtree-position
                     (save-excursion
                       (goto-char subtree-position)
                       (heading))))
               (mark-active (and region t))
               (transient-mark-mode
                (if region
                    t
                  transient-mark-mode)))
           (cond
            (region
             (goto-char (car region))
             (when (and selected-heading
                        (/=
                         selected-heading (save-excursion (heading))))
               (signal
                'org-texmacs-document-error
                '("Region start must belong to requested subtree")))
             (set-marker (mark-marker) (cdr region)))
            (subtree-position
             (goto-char subtree-position)))
           ;; Register only at actual export use; independent core stays separate.
           (require 'ox-texmacs)
           (prog1 (if (eq consumer 'tm)
                      (org-texmacs--standard-text-bytes
                       (org-export-as
                        'texmacs
                        (and subtree-position t)
                        nil
                        nil
                        ext-plist))
                    (org-texmacs--standard-consume consumer
                                                   (and
                                                    subtree-position
                                                    t)
                                                   nil ext-plist))
             (org-texmacs--standard-check-source state))))))))

(defun org-texmacs--standard-consume
    (consumer &optional subtreep visible-only ext-plist)
  "Return a structured CONSUMER result from the current source once.
CONSUMER is input, model, document or pdf.  Forward standard SUBTREEP,
VISIBLE-ONLY and EXT-PLIST without selecting or merging configuration here.
Public source APIs and interactive commands share this bridge."
  (unless (memq consumer '(input model document pdf))
    (signal 'org-texmacs-document-error
            '("Invalid structured export consumer")))
  (let ((request
         (list
          :consumer consumer
          :token (make-symbol "org-texmacs-result")
          :claimed nil
          :input nil
          :document nil
          :source nil)))
    (let ((org-texmacs--standard-request request))
      (org-export-as
       'texmacs subtreep visible-only nil
       (append
        (list :texmacs--result-token (plist-get request :token))
        ext-plist)))
    (unless (and (plist-get request :input)
                 (or (memq consumer '(input model))
                     (plist-get request :document)))
      (signal 'org-texmacs-document-error
              '("Missing standard export result")))
    (prog1 (pcase consumer
             ('input (plist-get request :input))
             ('model
              (org-texmacs-input-model (plist-get request :input)))
             ('document (plist-get request :document))
             ('pdf
              (org-texmacs-document-pdf
               (plist-get request :document))))
      (org-texmacs--standard-check-source (plist-get request :source))
      (org-texmacs--prepared-cite-check (plist-get request :input)))))

;; The normal backend callbacks cannot see filters installed by later user
;; callbacks.  Narrow guards at public dispatch boundaries prevent execution
;; before Cite/transcoding without copying/advising private Org preparation.
(advice-add 'org-export-as :around #'org-texmacs--standard-call)
(advice-add 'org-export-data :around #'org-texmacs--standard-data)
(advice-add
 'org-cite-process-citations
 :before #'org-texmacs--standard-cite)

(provide 'org-texmacs-export)
;;; org-texmacs-export.el ends here
