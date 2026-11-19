;;; ox-texmacs.el --- Bounded Org export dispatcher for TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Register the TeXmacs backend and export commands without a menu by default.
;; Configure `org-texmacs-export-menu-keys' before the first require to add a
;; native dispatcher menu; later option changes do not refresh it.
;; Commands share one standard Org export transaction and the AST-first handoff.
;; Org owns preparation, options, selection, filters and Cite.  Native PDF
;; consumes the completed document directly; text filters run at the boundary.
;; Synchronous whole-buffer, subtree, active-region and visible-only export
;; are supported.  Body-only fragments and asynchronous export are rejected.

;;; Code:

(require 'ox)
(require 'org-texmacs)
(require 'org-texmacs-export)

(defcustom org-texmacs-export-discover-bibliography nil
  "Obsolete discovery flag; leave nil and configure standard Org Cite instead.
Non-nil values are rejected by the standard frontend with migration advice."
  :type 'boolean
  :safe #'booleanp
  :group 'org-texmacs)
(make-variable-buffer-local 'org-texmacs-export-discover-bibliography)

(defun org-texmacs--export-check-options
    (async subtreep visible-only body-only ext-plist)
  "Capture standard frontend arguments before prompts and workers.
Reject ASYNC/BODY-ONLY and obsolete discovery settings.  Preserve SUBTREEP,
VISIBLE-ONLY and EXT-PLIST semantics under the real Org export transaction."
  (when (or async body-only)
    (user-error
     "TeXmacs export supports synchronous whole-document output"))
  (org-texmacs--export-interactive-source)
  (when org-texmacs-export-discover-bibliography
    (user-error
     "Remove org-texmacs-export-discover-bibliography; configure standard Org Cite"))
  (let ((position (point))
        (region
         (and (org-region-active-p)
              (cons (region-beginning) (region-end))))
        (options
         (condition-case err
             (org-texmacs--standard-copy-options ext-plist)
           (org-texmacs-document-error
            (user-error "%s" (error-message-string err))))))
    (list
     (when subtreep
       (org-texmacs--export-source-copy
        (current-buffer)
        (lambda ()
          (goto-char position)
          (condition-case nil
              (org-back-to-heading t)
            (error
             (user-error "No subtree at point")))
          (point))))
     region
     options
     visible-only
     position
     (org-texmacs--standard-source-state))))

(defun org-texmacs--export-byte-consumer (format selection)
  "Return a standard byte consumer for FORMAT and captured SELECTION.
Text uses the final Org string; PDF consumes the completed native document."
  (unless (memq format '(tm pdf))
    (user-error "Unknown TeXmacs output format"))
  (lambda (source _sources subtree region options)
    (with-current-buffer source
      (cl-labels
       ((check
         () (org-texmacs--standard-check-source (nth 5 selection))
         (when (buffer-local-value
                'org-texmacs-export-discover-bibliography source)
           (signal
            'org-texmacs-document-error
            '("Remove obsolete discovery flag; configure standard Org Cite")))))
       (check)
       (save-mark-and-excursion
         (goto-char (nth 4 selection))
         (let ((mark-active (and region t))
               (transient-mark-mode
                (if region
                    t
                  transient-mark-mode)))
           (when region
             (set-marker
              (mark-marker)
              (if (= (point) (car region))
                  (cdr region)
                (car region))))
           (prog1 (if (eq format 'pdf)
                      (org-texmacs--standard-consume
                       'pdf (and subtree t) (nth 3 selection) options)
                    (org-texmacs--standard-text-bytes
                     (org-export-as
                      'texmacs
                      (and subtree t)
                      (nth 3 selection)
                      nil
                      options)))
             (check))))))))

(defvar org-texmacs--export-managed-buffer nil
  "Frontend result record: buffer, original name and last modification tick.
A result relinquished by its user is never automatically reclaimed.")

(defvar-local org-texmacs--export-buffer-owner nil
  "Identity of the frontend record owning this result buffer.")

(defun org-texmacs--export-managed-buffer-p (record)
  "Return non-nil when RECORD still owns an untouched native result."
  (and record
       (buffer-live-p (car record))
       (with-current-buffer (car record)
         (and (eq org-texmacs--export-buffer-owner record)
              (equal (buffer-name) (nth 1 record))
              (= (buffer-modified-tick) (nth 2 record))
              (eq major-mode 'special-mode)
              buffer-read-only
              (not (buffer-modified-p))
              (not enable-multibyte-characters)
              (not buffer-file-name)
              (not (buffer-narrowed-p))
              (eq buffer-file-coding-system 'no-conversion)
              (null buffer-file-format)
              (null buffer-offer-save)
              (eq buffer-undo-list t)))))

(defun org-texmacs--export-update-buffer (record bytes)
  "Commit checked BYTES to RECORD, preserving its old content on failure."
  (with-current-buffer (car record)
    (let ((inhibit-read-only t)
          (inhibit-modification-hooks t)
          (position (point))
          complete)
      (unwind-protect
          (progn
            (atomic-change-group
              (erase-buffer)
              (insert bytes)
              (goto-char (point-min))
              (set-buffer-modified-p nil))
            (setq complete t))
        (unless complete
          (goto-char position)
          (set-buffer-modified-p nil))
        (setq buffer-undo-list t)
        ;; A cancelled change group also advances the modification tick.
        (setf (nth 2 record) (buffer-modified-tick))))
    (current-buffer)))

;;;###autoload
(defun org-texmacs-export-as-texmacs
    (&optional async subtreep visible-only body-only ext-plist)
  "Export the current Org source to a managed readonly native .tm byte buffer.
Use one standard Org export transaction.  SUBTREEP, VISIBLE-ONLY, active region,
narrowing and EXT-PLIST follow Org semantics.  Capture selection and mutable
option data before conversion; functions and opaque objects retain identity.
Reject non-nil ASYNC or BODY-ONLY and obsolete discovery settings.
Final text filters run before reversible Latin-1 transport conversion; output
that cannot preserve native bytes fails explicitly.
Reuse the frontend's untouched result, or create a uniquely named new result.
User edits, renaming or takeover end automatic reuse.  Explicit-source results
are independent.  Conversion or content commit failure preserves the old result.
Display when `org-export-show-temporary-export-buffer' is non-nil.  Display
failure retains a reused result's new content, but removes a newly created view.
Return the result buffer; its lifetime is independent of the Org source."
  (interactive nil org-mode)
  (let* ((selection
          (org-texmacs--export-check-options
           async subtreep visible-only body-only ext-plist))
         (bytes
          (funcall (org-texmacs--export-byte-consumer 'tm selection)
                   (current-buffer)
                   nil
                   (car selection)
                   (cadr selection)
                   (nth 2 selection)))
         (record org-texmacs--export-managed-buffer)
         (reuse (org-texmacs--export-managed-buffer-p record))
         (output
          (if reuse
              (org-texmacs--export-update-buffer record bytes)
            (org-texmacs--export-byte-buffer
             bytes "*Org TeXmacs Export*")))
         complete)
    (unless reuse
      (setq
       record
       (list
        output (buffer-name output)
        (with-current-buffer output
          (buffer-modified-tick)))
       org-texmacs--export-managed-buffer record)
      (with-current-buffer output
        (setq org-texmacs--export-buffer-owner record)))
    (unwind-protect
        (progn
          (when org-export-show-temporary-export-buffer
            (display-buffer output))
          (setq complete t)
          output)
      (unless (or complete reuse)
        (when (eq org-texmacs--export-managed-buffer record)
          (setq org-texmacs--export-managed-buffer nil))
        (let ((kill-buffer-query-functions nil))
          (when (buffer-live-p output)
            (kill-buffer output)))))))

;;;###autoload
(defun org-texmacs-export-to-texmacs
    (&optional async subtreep visible-only body-only ext-plist)
  "Export the current Org source to Org's local .tm output path.
Use standard preparation with SUBTREEP, VISIBLE-ONLY, region/narrowing and
EXT-PLIST.
Reject non-nil ASYNC or BODY-ONLY and obsolete discovery settings.
Capture selection/options before output naming.  Org chooses the filename;
overwrite writable regular outputs after source and destination checks.
Pass the actual destination in INFO without aliasing the protected write path.
Write reversible native bytes from final text output, without adding a newline.
Return the destination."
  (interactive nil org-mode)
  (let ((selection
         (org-texmacs--export-check-options
          async subtreep visible-only body-only ext-plist)))
    (org-texmacs--export-named-file
     ".tm" (org-texmacs--export-byte-consumer 'tm selection)
     (car selection) (cadr selection) (nth 2 selection))))

;;;###autoload
(defun org-texmacs-export-to-pdf
    (&optional async subtreep visible-only body-only ext-plist)
  "Export the current Org source directly to Org's local PDF output path.
Use standard preparation with SUBTREEP, VISIBLE-ONLY, region/narrowing and
EXT-PLIST.
Reject non-nil ASYNC or BODY-ONLY and obsolete discovery settings.
Capture selection/options before output naming.  Org chooses the filename;
overwrite writable regular outputs after source and destination checks.
Render the completed native document without a .tm text round trip.  Unsupported
text filters/finalizers fail before their string-tail effects.  No viewer runs.
Return the destination."
  (interactive nil org-mode)
  (let ((selection
         (org-texmacs--export-check-options
          async subtreep visible-only body-only ext-plist)))
    (org-texmacs--export-named-file
     ".pdf" (org-texmacs--export-byte-consumer 'pdf selection)
     (car selection) (cadr selection) (nth 2 selection))))

(defun org-texmacs--export-writable-target (file source-file)
  "Validate and own local output FILE without handlers.
Require a writable regular or absent target in an existing directory.
Reject symlinks and an alias of SOURCE-FILE.  This is not a concurrency lock."
  (let ((file-name-handler-alist nil))
    (unless (and (org-texmacs--document-local-file-path-p file)
                 (file-name-absolute-p file)
                 (not (string-match-p "\0" file))
                 (> (length (file-name-nondirectory file)) 0))
      (user-error "TeXmacs export requires a local output file"))
    (when (or (file-symlink-p file)
              (and (file-exists-p file) (not (file-regular-p file))))
      (signal 'file-error (list "Output is not a regular file" file)))
    (when (and source-file
               (or (equal file source-file)
                   (file-equal-p file source-file)))
      (user-error "TeXmacs output must not replace the Org source"))
    (unless (file-directory-p (file-name-directory file))
      (signal 'file-missing
              (list "Output directory does not exist" file)))
    (unless (file-writable-p file)
      (signal 'file-error (list "Output file not writable" file)))
    (substring-no-properties file)))

(defun org-texmacs--export-named-file
    (extension consumer &optional subtree-position region ext-plist)
  "Export the current source with byte CONSUMER to Org's EXTENSION output.
Capture source/directory/destination before conversion; permit replacement.
Do not add a newline or re-encode bytes.  File errors propagate; partial
output may remain after write failure.  No backup or atomic replacement is used.
Optional SUBTREE-POSITION freezes the selected source heading before prompts.
REGION is the captured body range; naming still follows SUBTREE-POSITION.
EXT-PLIST is owned before prompts.  Org's plist merger supplies the actual
output path in INFO; metadata mutations cannot redirect the final write."
  (let* ((source (current-buffer))
         (bounds (cons (point-min) (point-max)))
         (directory
          (org-texmacs--source-capture-path default-directory))
         (source-file (buffer-file-name (buffer-base-buffer))))
    (unless (and (org-texmacs--document-local-file-path-p directory)
                 (or (null source-file)
                     (org-texmacs--document-local-file-path-p
                      source-file)))
      (user-error "TeXmacs export requires a local source context"))
    (setq source-file
          (and source-file (substring-no-properties source-file)))
    (let*
        ((name
          (save-excursion
            (if (buffer-narrowed-p)
                (let ((choice
                       (org-texmacs--export-source-copy
                        source
                        (lambda ()
                          (let ((file-name-handler-alist nil))
                            (when subtree-position
                              (goto-char subtree-position))
                            (catch 'output-prompt
                              (cl-letf (((symbol-function
                                          'read-file-name)
                                         (lambda (&rest arguments)
                                           (throw 'output-prompt
                                                  arguments))))
                                (org-export-output-file-name
                                 extension
                                 (and subtree-position t)))))))))
                  ;; Prompt in the original source context, outside the
                  ;; private copy's property bindings and restriction.
                  (if (stringp choice)
                      choice
                    (concat
                     (file-name-sans-extension
                      (apply #'read-file-name choice))
                     extension)))
              (let ((file-name-handler-alist nil)
                    (org-entry-property-inherited-from (make-marker)))
                (when subtree-position
                  (goto-char subtree-position))
                (org-export-output-file-name
                 extension (and subtree-position t))))))
         (target (expand-file-name name directory)))
      (unless (with-current-buffer source
                (equal bounds (cons (point-min) (point-max))))
        (user-error
         "Source restriction changed during output naming"))
      ;; Org's helper protects existing source files.  Also protect an unsaved
      ;; visiting source with an output suffix, where file-equal-p is nil.
      (when (equal target source-file)
        (setq target (concat target extension)))
      (setq target
            (org-texmacs--export-writable-target target source-file))
      (let ((bytes
             (funcall consumer
                      source nil subtree-position region
                      (org-combine-plists
                       ext-plist
                       (list
                        :output-file
                        (substring-no-properties target))))))
        (org-texmacs--export-writable-target target source-file)
        (org-texmacs--native-save-bytes bytes target t)))))

(defcustom org-texmacs-export-menu-keys nil
  "Explicit dispatcher menu keys, configured before loading ox-texmacs.
Nil registers the backend without a menu.  Otherwise supply a complete plist
with :prefix, :buffer, :file and :pdf character values.  Action keys must be
distinct; reserved control/help/publishing keys and existing action conflicts
are rejected.  Graphic Unicode characters are supported.
This is a load-time setting.  Changing it after the first require, including
via Custom, does not refresh the registered menu; use a new Emacs session.
No default keys or automatic conflict reassignment are provided."
  :type
  '(choice
    (const :tag "No dispatcher menu" nil)
    (sexp :tag "Complete explicit key plist"))
  :group 'org-texmacs)

(defun org-texmacs--export-menu-entry (configuration)
  "Validate CONFIGURATION and build an independent native Org menu or nil.
Honor shared prefixes with disjoint actions in currently registered backends.
Do not change existing backends, hooks, or the user's configuration."
  (when configuration
    (unless (and (proper-list-p configuration)
                 (= (length configuration) 8))
      (user-error
       "TeXmacs menu requires a complete four-field key plist"))
    (let ((fields '(:prefix :buffer :file :pdf))
          seen)
      (cl-loop
       for (field value) on configuration by #'cddr do
       (unless (and (memq field fields) (not (memq field seen)))
         (user-error "Unknown or duplicate TeXmacs menu field: %S"
                     field))
       (push field seen)
       (unless (and (characterp value)
                    (<= value #x10ffff) (not (<= #xd800 value #xdfff))
                    (string-match-p
                     "\\`[[:graph:]]\\'" (char-to-string value))
                    (not (memq value '(?q ?? ?# ?&))))
         (user-error "Unsupported or reserved TeXmacs menu key: %S"
                     value)))
      (let* ((prefix (plist-get configuration :prefix))
             (keys
              (mapcar
               (lambda (field)
                 (plist-get configuration field))
               '(:buffer :file :pdf))))
        (when (or (= prefix ?P)
                  (/= (length (delete-dups (copy-sequence keys))) 3))
          (user-error
           "Reserved prefix or duplicate TeXmacs action keys"))
        (dolist (backend org-export-registered-backends)
          (let ((menu (org-export-backend-menu backend)))
            (when (and menu
                       (not
                        (eq
                         (org-export-backend-name backend) 'texmacs))
                       (eq (car menu) prefix))
              (let ((actions (nth 2 menu)))
                (unless (and (not (functionp actions))
                             (proper-list-p actions))
                  (user-error
                   "TeXmacs prefix conflicts with backend %S"
                   (org-export-backend-name backend)))
                (when (cl-some
                       (lambda (action)
                         (memq (car action) keys))
                       actions)
                  (user-error
                   "TeXmacs action key conflicts with backend %S"
                   (org-export-backend-name backend)))))))
        (list
         prefix "Export to TeXmacs"
         (cl-mapcar
          #'list keys
          '("As TeXmacs buffer" "As .tm file" "As PDF file")
          '(org-texmacs-export-as-texmacs
            org-texmacs-export-to-texmacs
            org-texmacs-export-to-pdf)))))))

;; Validate the menu before replacing the registered backend.
(let ((menu
       (org-texmacs--export-menu-entry org-texmacs-export-menu-keys)))
  (org-export-define-backend
   'texmacs (org-texmacs--standard-transcoders)
   :options-alist
   '((:cite-export
      "CITE_EXPORT" nil (org-texmacs--cite-default-processors))
     (:subtitle "SUBTITLE" nil nil parse)
     (:keywords "KEYWORDS" nil nil space)
     (:description "DESCRIPTION" nil nil newline))
   :filters-alist
   '((:filter-options . org-texmacs--standard-options)
     (:filter-parse-tree . org-texmacs--standard-tree))
   :menu-entry menu))

;; A previous load may have installed the old rejection hook.
(remove-hook
 'org-export-before-processing-functions
 'org-texmacs--export-reject-generic-preprocessing)

(provide 'ox-texmacs)
;;; ox-texmacs.el ends here
