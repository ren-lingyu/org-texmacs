;;; org-texmacs-edit.el --- Scheme editing for TeXmacs blocks -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Reuse Org source-edit buffers and Scheme indentation for native TeXmacs
;; special blocks.  This does not turn blocks into Babel source blocks.

;;; Code:

(require 'org-texmacs-fragment)
(require 'org-src)
(require 'scheme)

(declare-function scheme-ts-mode "scheme-ts-mode")

(defcustom org-texmacs-edit-mode 'scheme-mode
  "Major mode used to edit and indent TeXmacs special-block bodies.
The default `scheme-mode' is bundled with Emacs.  Selecting `scheme-ts-mode'
requires that mode and its Scheme Tree-sitter grammar to be installed by the
user.  Missing optional support signals an error; nothing is installed or
silently substituted.  Existing edit buffers retain their mode until closed.
This option does not change STM fontification, parsing or export support."
  :type
  '(choice
    (const :tag "Scheme" scheme-mode)
    (const :tag "Scheme (Tree-sitter)" scheme-ts-mode))
  :group 'org-texmacs)

(defvar-local org-texmacs--edit-base 0
  "Minimum indentation of a TeXmacs block in its Org container.")

(defvar-local org-texmacs--edit-indent-function nil
  "Native Scheme line indentation function in the current edit buffer.")

(defvar-local org-texmacs--edit-ready nil
  "Non-nil when a TeXmacs edit buffer has been initialized successfully.")

(defun org-texmacs--edit-check-mode ()
  "Return the selected editing mode, or explain unavailable support."
  (pcase org-texmacs-edit-mode
    ('scheme-mode #'scheme-mode)
    ('scheme-ts-mode
     (unless (and (or (fboundp 'scheme-ts-mode)
                      (require 'scheme-ts-mode nil t))
                  (fboundp 'scheme-ts-mode)
                  (fboundp 'treesit-ready-p)
                  (treesit-ready-p 'scheme t))
       (user-error
        "TeXmacs editing needs scheme-ts-mode and its Scheme grammar"))
     #'scheme-ts-mode)
    (_
     (user-error "Unsupported TeXmacs editing mode: %S"
                 org-texmacs-edit-mode))))

(defun org-texmacs--edit-context ()
  "Return (BLOCK BODY-BEGIN BODY-END INDENT) for the current TeXmacs block.
Return nil outside a complete, accessible native special block.  Delimiters
are located only after Org has identified the block; no STM is parsed."
  (when (derived-mode-p 'org-mode)
    (let* ((node
            (org-element-lineage
             (org-element-at-point) '(special-block) t))
           (begin (and node (org-element-post-affiliated node)))
           (end (and node (org-element-property :end node))))
      (when (and node
                 (org-texmacs--block-p node)
                 begin
                 end
                 (<= (point-min) begin)
                 (<= end (point-max)))
        (save-excursion
          (let ((case-fold-search t)
                body-begin
                body-end
                base)
            (goto-char begin)
            (setq base (current-indentation))
            (when (looking-at
                   "[ \t]*#\\+begin_texmacs\\(?:[ \t].*\\)?$")
              (forward-line)
              (setq body-begin (point))
              (goto-char end)
              (skip-chars-backward " \t\r\n" body-begin)
              (beginning-of-line)
              (when (and (>= (point) body-begin)
                         (looking-at "[ \t]*#\\+end_texmacs[ \t]*$"))
                (setq body-end (point))
                (list node body-begin body-end base)))))))))

(defun org-texmacs--edit-indent-line ()
  "Indent using the selected Scheme mode, respecting the Org container."
  (let ((string (nth 3 (syntax-ppss (line-beginning-position)))))
    (funcall org-texmacs--edit-indent-function)
    (unless string
      (when (< (current-indentation) org-texmacs--edit-base)
        (let ((offset (- (point) (line-beginning-position))))
          (indent-line-to org-texmacs--edit-base)
          (when (< offset org-texmacs--edit-base)
            (back-to-indentation)))))))

(defun org-texmacs--edit-initialize (mode base)
  "Initialize MODE with minimum indentation BASE in a private Scheme buffer."
  (funcall mode)
  (setq-local
   org-texmacs--edit-base base
   org-texmacs--edit-indent-function indent-line-function
   indent-line-function #'org-texmacs--edit-indent-line
   indent-region-function nil
   org-texmacs--edit-ready t))

(defun org-texmacs--edit-special (original &rest arguments)
  "Edit a TeXmacs block, or apply ORIGINAL to ARGUMENTS normally."
  (let ((context (org-texmacs--edit-context)))
    (if (not context)
        (apply original arguments)
      (barf-if-buffer-read-only)
      (let* ((mode (org-texmacs--edit-check-mode))
             (datum (org-element-copy (car context)))
             (begin (nth 1 context))
             (end (nth 2 context))
             (base (nth 3 context))
             (text (buffer-substring-no-properties begin end)))
        ;; Empty special blocks lack contents positions.  Keep their native
        ;; type while supplying the exact editing area to Org.
        (org-element-put-property datum :contents-begin begin)
        (org-element-put-property datum :contents-end end)
        (org-src--edit-element
         datum (format "*Org TeXmacs: %s*" (buffer-name))
         (lambda ()
           ;; Org normally dedents special blocks before INITIALIZE.  Restore
           ;; the literal body so multiline strings and no-change round trips
           ;; retain their whitespace, including inside indented containers.
           (erase-buffer)
           (insert text)
           (org-texmacs--edit-initialize mode base)
           (set-buffer-modified-p nil))
         (lambda ()
           (let ((case-fold-search t))
             (when (re-search-forward "^[ \t]*#\\+end_texmacs[ \t]*$"
                                      nil
                                      t)
               (user-error
                "TeXmacs body contains an Org block closing line")))))
        (unless org-texmacs--edit-ready
          (org-edit-src-abort)
          (user-error "Could not initialize TeXmacs Scheme editing"))
        ;; Org assigns this after INITIALIZE; prevent an additional indentation
        ;; pass during save/exit.  Existing edit buffers use the same contract.
        (setq-local org-src--preserve-indentation t)))))

(defun org-texmacs--edit-indent (context begin end)
  "Indent complete lines BEGIN through END in CONTEXT's block body.
Compute the result privately before changing the source."
  (barf-if-buffer-read-only)
  (let* ((mode (org-texmacs--edit-check-mode))
         (body-begin (nth 1 context))
         (body-end (nth 2 context))
         (base (nth 3 context))
         (start
          (save-excursion
            (goto-char begin)
            (line-beginning-position)))
         (stop
          (save-excursion
            (goto-char end)
            (if (and (> end begin) (bolp))
                (point)
              (min body-end (line-beginning-position 2)))))
         (text (buffer-substring-no-properties body-begin body-end))
         (offset
          (- (point)
             (save-excursion
               (back-to-indentation)
               (point))))
         (replacement
          (with-temp-buffer
            (insert text)
            (org-texmacs--edit-initialize mode base)
            (goto-char (+ (point-min) (- start body-begin)))
            (let ((limit
                   (copy-marker
                    (+ (point-min) (- stop body-begin)) t)))
              (while (< (point) limit)
                (indent-according-to-mode)
                (forward-line))
              (buffer-substring-no-properties
               (+ (point-min) (- start body-begin)) limit)))))
    (unless (equal
             replacement (buffer-substring-no-properties start stop))
      (atomic-change-group
        (save-excursion
          (goto-char start)
          (delete-region start stop)
          (insert replacement))))
    (goto-char start)
    (back-to-indentation)
    (when (> offset 0)
      (goto-char (min (+ (point) offset) (line-end-position))))))

(defun org-texmacs--edit-org-indent-line (original &rest arguments)
  "Indent a TeXmacs body line or apply ORIGINAL to ARGUMENTS."
  (let ((context (org-texmacs--edit-context)))
    (if (and context
             (<= (nth 1 context) (point))
             (< (point) (nth 2 context)))
        (org-texmacs--edit-indent context (point) (point))
      (apply original arguments))))

(defun org-texmacs--edit-org-indent-region
    (original begin end &rest arguments)
  "Indent a TeXmacs body region or apply ORIGINAL with BEGIN, END, ARGUMENTS."
  (let ((context
         (save-excursion
           (goto-char begin)
           (org-texmacs--edit-context))))
    (if (and context
             (<= (nth 1 context) begin)
             (<= end (nth 2 context))
             (< begin end))
        (save-excursion (org-texmacs--edit-indent context begin end))
      (apply original begin end arguments))))

(defun org-texmacs--edit-tab (&rest _arguments)
  "Handle Org TAB inside a TeXmacs special-block body."
  (let ((context (org-texmacs--edit-context)))
    (when (and context
               (<= (nth 1 context) (point))
               (< (point) (nth 2 context)))
      (org-texmacs--edit-indent context (point) (point))
      t)))

(advice-add 'org-edit-special :around #'org-texmacs--edit-special)
(advice-add
 'org-indent-line
 :around #'org-texmacs--edit-org-indent-line)
(advice-add
 'org-indent-region
 :around #'org-texmacs--edit-org-indent-region)
(add-hook 'org-tab-first-hook #'org-texmacs--edit-tab)

(provide 'org-texmacs-edit)

;;; org-texmacs-edit.el ends here
