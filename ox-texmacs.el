;;; ox-texmacs.el --- Bounded Org export dispatcher for TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Register TeXmacs in Org's export dispatcher.  Menu actions consume the
;; original explicit source through org-texmacs's owned structured pipeline.
;; This first frontend supports synchronous whole-buffer exports only.
;; Org's generic string-transcoder/preprocessing APIs are explicitly rejected
;; for this backend before includes, macros or Babel processing.

;;; Code:

(require 'ox)
(require 'org-texmacs)

(defun org-texmacs--export-check-options (async subtreep visible-only body-only ext-plist)
  "Validate the bounded frontend's Org export arguments.
Reject ASYNC, SUBTREEP, VISIBLE-ONLY, BODY-ONLY and EXT-PLIST before conversion."
  (when (or async subtreep visible-only body-only ext-plist)
    (user-error "TeXmacs export supports synchronous whole-buffer export without overrides"))
  (org-texmacs--export-interactive-source)
  (when (org-region-active-p)
    (user-error "TeXmacs export does not support an active region")))

;;;###autoload
(defun org-texmacs-export-as-texmacs
    (&optional async subtreep visible-only body-only ext-plist)
  "Export the current Org buffer to a fresh readonly native .tm byte buffer.
Reject non-nil ASYNC, SUBTREEP, VISIBLE-ONLY, BODY-ONLY or EXT-PLIST, narrowing
and an active region before preparation.  Reuse the owned source pipeline;
do not run generic Org preprocessing or read bibliography files.
Return the new buffer.  Display it when
`org-export-show-temporary-export-buffer' is non-nil."
  (interactive)
  (org-texmacs--export-check-options async subtreep visible-only body-only ext-plist)
  (let ((output (org-texmacs-export-to-buffer (current-buffer))) complete)
    (unwind-protect
        (progn
          (when org-export-show-temporary-export-buffer (display-buffer output))
          (setq complete t)
          output)
      (unless complete
        (let ((kill-buffer-query-functions nil))
          (when (buffer-live-p output) (kill-buffer output)))))))

;;;###autoload
(defun org-texmacs-export-to-texmacs
    (&optional async subtreep visible-only body-only ext-plist)
  "Export the current Org buffer to a prompted new local .tm file.
Reject non-nil ASYNC, SUBTREEP, VISIBLE-ONLY, BODY-ONLY or EXT-PLIST, narrowing
and an active region before prompting.  Capture the source before the prompt
and reuse `org-texmacs-export-to-file' with its exclusive creation policy.
Return the absolute destination.  No bibliography files are read."
  (interactive)
  (org-texmacs--export-check-options async subtreep visible-only body-only ext-plist)
  (apply #'org-texmacs-export-to-file (org-texmacs--export-file-arguments "tm")))

;;;###autoload
(defun org-texmacs-export-to-texmacs-pdf
    (&optional async subtreep visible-only body-only ext-plist)
  "Export the current Org buffer to a prompted new local PDF file.
Reject non-nil ASYNC, SUBTREEP, VISIBLE-ONLY, BODY-ONLY or EXT-PLIST, narrowing
and an active region before prompting.  Capture the source before the prompt
and reuse `org-texmacs-export-to-pdf' with its exclusive creation policy.
Return the absolute destination.  No PDF viewer or bibliography reader runs."
  (interactive)
  (org-texmacs--export-check-options async subtreep visible-only body-only ext-plist)
  (apply #'org-texmacs-export-to-pdf (org-texmacs--export-file-arguments "pdf")))

(defun org-texmacs--export-reject-string-transcoding (&rest _arguments)
  "Reject Org's generic string transcoding for the TeXmacs backend."
  (user-error "Use the TeXmacs dispatcher actions or explicit org-texmacs source APIs"))

(defun org-texmacs--export-reject-generic-preprocessing (backend)
  "Reject generic preprocessing for TeXmacs BACKEND and its derivatives."
  (when (org-export-derived-backend-p backend 'texmacs)
    (org-texmacs--export-reject-string-transcoding)))

(org-export-define-backend 'texmacs
  '((org-data . org-texmacs--export-reject-string-transcoding)
    (plain-text . org-texmacs--export-reject-string-transcoding))
  :menu-entry
  '(?T "Export to TeXmacs"
       ((?T "As TeXmacs buffer" org-texmacs-export-as-texmacs)
        (?t "As new .tm file" org-texmacs-export-to-texmacs)
        (?p "As new PDF file" org-texmacs-export-to-texmacs-pdf))))

;; Abort unsupported generic export before Org reads includes or executes Babel.
;; This hook is inert for unrelated backends; menu consumers do not run it.
(add-hook 'org-export-before-processing-functions
          #'org-texmacs--export-reject-generic-preprocessing -100)

(provide 'ox-texmacs)
;;; ox-texmacs.el ends here
