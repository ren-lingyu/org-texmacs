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
(require 'org-texmacs-input)
(require 'org-texmacs-session)
(require 'org-texmacs-fragment)
(require 'org-texmacs-prepared)

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

(defun org-texmacs--standard-data (function data info)
  "Call Org transcoder FUNCTION for DATA/INFO after checking effective filters.
This catches reentrant transcoding and later INFO updates.  Other backends pass
through unchanged.  No Org preparation or transcoder implementation is copied."
  (org-texmacs--standard-node-filters info)
  (funcall function data info))

(defun org-texmacs--standard-cite (info)
  "Check INFO after AST filters and before Cite callbacks execute."
  (org-texmacs--standard-node-filters info))

(defun org-texmacs--standard-source-state ()
  "Capture source identity and native presentation settings without preparation."
  (list
   (current-buffer)
   (buffer-chars-modified-tick)
   major-mode
   (point-min)
   (point-max)
   (and buffer-file-name (substring-no-properties buffer-file-name))
   (substring-no-properties default-directory)
   (org-texmacs--document-copy-style org-texmacs-document-style)
   (org-texmacs--document-copy-initial org-texmacs-document-initial)
   (org-texmacs--fragment-tags)))

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
             (equal state current))))
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
           (state (org-texmacs--standard-source-state))
           (org-texmacs--standard-transaction
            (list
             :consumer
             (or (plist-get request :consumer) 'text)
             :source state
             :request request)))
      (when request
        (setf (plist-get request :claimed) t))
      (prog1 (funcall function
                      backend
                      subtreep
                      visible-only
                      nil
                      ext-plist)
        (org-texmacs--standard-check-source state)))))

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
        (keys (mapcar #'car org-texmacs--context-option-alist))
        projected)
    ;; Org's public map resolves deferred properties while its buffer is live,
    ;; including affiliated/secondary data.  Never reparse the working buffer.
    (org-element-map
     tree t
     (lambda (node)
       (when (consp node)
         ;; Resolve without FORCE: explicit AST-filter property replacements
         ;; remain authoritative over deferred source-derived values.
         (org-element-properties-resolve node)))
     nil nil nil t)
    (setq tree
          (org-texmacs--prepared-copy
           tree (plist-get info :ignore-list)))
    (org-texmacs--prepared-control-keywords tree)
    (org-texmacs--prepared-affiliation tree)
    (dolist (key keys)
      (when (plist-member info key)
        (when (memq key org-texmacs--context-rich-metadata)
          (org-element-map
           (plist-get info key) t
           (lambda (node)
             (when (consp node)
               (org-element-properties-resolve node)))
           nil nil nil t))
        (setq projected
              (plist-put projected key (plist-get info key)))))
    (setq projected
          (plist-put projected :texmacs-tab-width tab-width))
    (setq
     projected
     (plist-put
      projected
      :texmacs-format-headline-function org-texmacs-format-headline-function))
    (setq
     projected
     (plist-put
      projected
      :texmacs-special-block-handlers org-texmacs--document-special-block-handlers))
    (setq
     projected
     (plist-put
      projected
      :texmacs-pdf-file-links-as-absolute org-texmacs-pdf-file-links-as-absolute))
    (setq
     projected
     (plist-put
      projected
      :texmacs-link-org-files-as-pdf org-texmacs-link-org-files-as-pdf))
    (let*
        ((requests
          (org-texmacs--prepared-discover
           tree (org-texmacs--fragment-tags)))
         ;; As in the independent parser, placeholders exist only inside an
         ;; unpublished ownership transaction.  Freeze context before waits;
         ;; allocate labels only after all actual native trees are available.
         (input
          (org-texmacs--input-own
           tree projected
           :islands
           (mapcar
            (lambda (request)
              (cons (car request) '(concat "")))
            requests)
           :style (nth 7 state)
           :initial (nth 8 state)
           :source-file (nth 5 state)
           :resource-base (nth 6 state))))
      (org-texmacs--prepared-parse
       requests (org-texmacs-input-islands input))
      (org-texmacs--input-finalize input))))

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
      (when (org-cite-processor-export-finalizer processor)
        (signal
         'org-texmacs-document-error
         '("Unsupported Cite finalizer for native structured output"))))))

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
           (document (org-texmacs-document input))
           (request (plist-get transaction :request)))
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
        (org-texmacs--standard-check-source prepared-state)))))

(defun org-texmacs--standard-consume (consumer)
  "Return a structured CONSUMER result from the current source once.
CONSUMER is input, model, document or pdf.  Do not reinterpret serialized text.
This private bridge does not migrate the legacy source APIs or frontend yet."
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
       'texmacs
       nil
       nil
       nil
       (list :texmacs--result-token (plist-get request :token))))
    (unless (plist-get request :document)
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
      (org-texmacs--standard-check-source
       (plist-get request :source)))))

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
