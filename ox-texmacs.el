;;; ox-texmacs.el --- Bounded Org export dispatcher for TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Register TeXmacs in Org's export dispatcher.  Menu actions consume the
;; original explicit source through org-texmacs's owned structured pipeline.
;; This frontend supports synchronous whole-buffer, subtree and active-region
;; exports.
;; Org's generic string-transcoder/preprocessing APIs are explicitly rejected
;; for this backend before includes, macros or Babel processing.

;;; Code:

(require 'ox)
(require 'org-texmacs)

(defun org-texmacs--export-check-options (async subtreep visible-only body-only ext-plist)
  "Validate the bounded frontend's Org export arguments.
Reject ASYNC, VISIBLE-ONLY and BODY-ONLY before conversion.
Validate and copy restricted EXT-PLIST before prompts or workers.
Return (SUBTREE-POSITION REGION EXT-PLIST), captured before conversion.
An active region selects the body; SUBTREEP still selects its configuration."
  (when (or async visible-only body-only)
    (user-error "TeXmacs export supports synchronous buffer/subtree/region export"))
  (org-texmacs--export-interactive-source)
  (setq ext-plist
        (condition-case err (org-texmacs--context-external-options ext-plist)
          (org-texmacs-document-error (user-error "%s" (error-message-string err)))))
  (let ((region (and (org-region-active-p)
                     (cons (region-beginning) (region-end)))))
    (list (when subtreep
            (if (buffer-narrowed-p)
                (let ((position (point)))
                  (org-texmacs--export-source-copy
                   (current-buffer)
                   (lambda ()
                     (goto-char position)
                     (condition-case nil (org-back-to-heading t)
                       (error (user-error "No subtree at point")))))
                  position)
              (save-excursion
                (condition-case nil (org-back-to-heading t)
                  (error (user-error "No subtree at point")))
                (point))))
          region ext-plist)))

;;;###autoload
(defun org-texmacs-export-as-texmacs
    (&optional async subtreep visible-only body-only ext-plist)
  "Export the current Org buffer to a fresh readonly native .tm byte buffer.
Reject non-nil ASYNC, VISIBLE-ONLY or BODY-ONLY.
Existing narrowing bounds the exported body.
EXT-PLIST accepts only the documented restricted configuration keys
and is captured before preparation.  An active region selects the body.
Reuse the owned pipeline; do not run generic preprocessing or read bibliography.
Non-nil SUBTREEP supplies subtree configuration and, without a region, its body.
Return the new buffer.  Display it when
`org-export-show-temporary-export-buffer' is non-nil."
  (interactive)
  (let* ((selection (org-texmacs--export-check-options
                    async subtreep visible-only body-only ext-plist))
         (output (org-texmacs-export-to-buffer (current-buffer) nil
                                              (car selection) (cadr selection)
                                              (nth 2 selection))) complete)
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
  "Export the current Org buffer to Org's local .tm output path.
Reject non-nil ASYNC, VISIBLE-ONLY or BODY-ONLY.
Existing narrowing bounds the exported body.
EXT-PLIST accepts only the documented restricted configuration keys
and is captured before output naming.  An active region selects the body.
Use `org-export-output-file-name'
and overwrite an existing writable regular output after source checking.
Non-nil SUBTREEP uses the containing subtree's configuration and output name.
Return the absolute destination.  No bibliography files are read."
  (interactive)
  (let ((selection (org-texmacs--export-check-options
                   async subtreep visible-only body-only ext-plist)))
    (org-texmacs--export-named-file ".tm" #'org-texmacs-export-from-buffer
                                     (car selection) (cadr selection) (nth 2 selection))))

;;;###autoload
(defun org-texmacs-export-to-texmacs-pdf
    (&optional async subtreep visible-only body-only ext-plist)
  "Export the current Org buffer to Org's local PDF output path.
Reject non-nil ASYNC, VISIBLE-ONLY or BODY-ONLY.
Existing narrowing bounds the exported body.
EXT-PLIST accepts only the documented restricted configuration keys
and is captured before output naming.  An active region selects the body.
Use `org-export-output-file-name'
and overwrite an existing writable regular output after source checking.
Non-nil SUBTREEP uses the containing subtree's configuration and output name.
Return the absolute destination.  No PDF viewer or bibliography reader runs."
  (interactive)
  (let ((selection (org-texmacs--export-check-options
                   async subtreep visible-only body-only ext-plist)))
    (org-texmacs--export-named-file ".pdf" #'org-texmacs-export-pdf-from-buffer
                                     (car selection) (cadr selection) (nth 2 selection))))

(defun org-texmacs--export-writable-target (file source-file)
  "Validate and own local output FILE without handlers.
Require a writable regular or absent target in an existing directory.
Reject symlinks and an alias of SOURCE-FILE.  This is not a concurrency lock."
  (let ((file-name-handler-alist nil))
    (unless (and (org-texmacs--document-local-file-path-p file)
                 (file-name-absolute-p file) (not (string-match-p "\0" file))
                 (> (length (file-name-nondirectory file)) 0))
      (user-error "TeXmacs export requires a local output file"))
    (when (or (file-symlink-p file)
              (and (file-exists-p file) (not (file-regular-p file))))
      (signal 'file-error (list "Output is not a regular file" file)))
    (when (and source-file
               (or (equal file source-file) (file-equal-p file source-file)))
      (user-error "TeXmacs output must not replace the Org source"))
    (unless (file-directory-p (file-name-directory file))
      (signal 'file-missing (list "Output directory does not exist" file)))
    (unless (file-writable-p file)
      (signal 'file-error (list "Output file not writable" file)))
    (substring-no-properties file)))

(defun org-texmacs--export-named-file (extension consumer &optional subtree-position region ext-plist)
  "Export the current source with byte CONSUMER to Org's EXTENSION output.
Capture source/directory/destination before conversion; permit replacement.
Do not add a newline or re-encode bytes.  File errors propagate; partial
output may remain after write failure.  No backup or atomic replacement is used.
Optional SUBTREE-POSITION freezes the selected source heading before prompts.
REGION is the captured body range; naming still follows SUBTREE-POSITION.
EXT-PLIST is owned by frontend validation; it cannot override output paths."
  (let* ((source (current-buffer))
         (bounds (cons (point-min) (point-max)))
         (directory (org-texmacs--source-capture-path default-directory))
         (source-file (buffer-file-name (buffer-base-buffer))))
    (unless (and (org-texmacs--document-local-file-path-p directory)
                 (or (null source-file)
                     (org-texmacs--document-local-file-path-p source-file)))
      (user-error "TeXmacs export requires a local source context"))
    (setq source-file (and source-file (substring-no-properties source-file)))
    (let* ((name (save-excursion
                   (if (buffer-narrowed-p)
                       (let ((choice
                              (org-texmacs--export-source-copy
                               source
                               (lambda ()
                                 (let ((file-name-handler-alist nil))
                                   (when subtree-position (goto-char subtree-position))
                                   (catch 'output-prompt
                                     (cl-letf (((symbol-function 'read-file-name)
                                                (lambda (&rest arguments)
                                                  (throw 'output-prompt arguments))))
                                       (org-export-output-file-name
                                        extension (and subtree-position t)))))))))
                         ;; Prompt in the original source context, outside the
                         ;; private copy's property bindings and restriction.
                         (if (stringp choice) choice
                           (concat (file-name-sans-extension
                                    (apply #'read-file-name choice)) extension)))
                     (let ((file-name-handler-alist nil)
                           (org-entry-property-inherited-from (make-marker)))
                       (when subtree-position (goto-char subtree-position))
                       (org-export-output-file-name extension (and subtree-position t))))))
           (target (expand-file-name name directory)))
      (unless (with-current-buffer source
                (equal bounds (cons (point-min) (point-max))))
        (user-error "Source restriction changed during output naming"))
      ;; Org's helper protects existing source files.  Also protect an unsaved
      ;; visiting source with an output suffix, where file-equal-p is nil.
      (when (equal target source-file) (setq target (concat target extension)))
      (setq target (org-texmacs--export-writable-target target source-file))
      (let ((bytes (funcall consumer source nil subtree-position region ext-plist)))
        (org-texmacs--export-writable-target target source-file)
        (org-texmacs--native-save-bytes bytes target t)))))

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
        (?t "As .tm file" org-texmacs-export-to-texmacs)
        (?p "As PDF file" org-texmacs-export-to-texmacs-pdf))))

;; Abort unsupported generic export before Org reads includes or executes Babel.
;; This hook is inert for unrelated backends; menu consumers do not run it.
(add-hook 'org-export-before-processing-functions
          #'org-texmacs--export-reject-generic-preprocessing -100)

(provide 'ox-texmacs)
;;; ox-texmacs.el ends here
