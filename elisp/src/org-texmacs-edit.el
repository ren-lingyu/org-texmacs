;;; org-texmacs-edit.el --- Scheme editing for embedded STM -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Reuse Org source-edit buffers for STM carriers and native TeXmacs blocks.
;; Provide Scheme indentation within native TeXmacs block bodies.

;;; Code:

(require 'cl-lib)
(require 'org-texmacs-fragment-object)
(require 'org-texmacs-source)
(require 'org-src)

(defvar-local org-texmacs--edit-base 0
  "Minimum indentation of a native STM block in its Org container.")

(defvar-local org-texmacs--edit-indent-function nil
  "Native Scheme line indentation function in the current edit buffer.")

(defvar-local org-texmacs--edit-ready nil
  "Non-nil when a TeXmacs edit buffer has been initialized successfully.")

(defvar-local org-texmacs--edit-fragment-source nil
  "Last known source payload of the STM fragment being edited.")

(defvar-local org-texmacs--edit-block-end-regexp nil
  "Closing line of the native STM block being edited.")

(defun org-texmacs--edit-check-mode ()
  "Return the Scheme mode resolved by Org Src, or signal a user error."
  (let ((mode (org-src-get-lang-mode "scheme")))
    (unless (fboundp mode)
      (user-error
       "TeXmacs editing needs the configured Scheme mode %S"
       mode))
    mode))

(defun org-texmacs--edit-block-end-pattern (kind)
  "Return a regexp matching the native STM block KIND's closing line."
  (concat
   "^[ \t]*#\\+end_" (regexp-quote (symbol-name kind)) "[ \t]*$"))

(defun org-texmacs--edit-context ()
  "Return (BLOCK BODY-BEGIN BODY-END INDENT) for the current native STM block.
Return nil outside a complete, accessible native special block.  Delimiters
are located only after Org has identified the block; no STM is parsed."
  (when (derived-mode-p 'org-mode)
    (let* ((node
            (org-element-lineage
             (org-element-at-point) '(special-block) t))
           (begin (and node (org-element-post-affiliated node)))
           (end (and node (org-element-property :end node)))
           (kind (org-texmacs--native-body-kind node)))
      (when (and kind
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
                   (concat
                    "[ \t]*#\\+begin_"
                    (regexp-quote (symbol-name kind))
                    "\\(?:[ \t].*\\)?$"))
              (forward-line)
              (setq body-begin (point))
              (goto-char end)
              (skip-chars-backward " \t\r\n" body-begin)
              (beginning-of-line)
              (when (and (>= (point) body-begin)
                         (looking-at
                          (org-texmacs--edit-block-end-pattern kind)))
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

(defun org-texmacs--edit-fragment-at-point ()
  "Return the recognized STM carrier at point, including its source bounds."
  (when (derived-mode-p 'org-mode)
    (save-match-data
      (org-with-wide-buffer
       (org-texmacs--call-with-ast-context
        (lambda ()
          (let ((element (org-element-at-point)))
            ;; The local context parser can descend into raw native block
            ;; bodies, which are opaque to the STM carrier recognizer.
            (unless (cl-some
                     (lambda (ancestor)
                       (and (org-texmacs--native-body-kind ancestor)
                            (>= (point)
                                (org-element-post-affiliated
                                 ancestor))))
                     (org-element-lineage element nil t))
              (let ((node (org-element-context element)))
                (when (and (eq (org-element-type node) 'stm-fragment)
                           (<= (org-element-begin node) (point))
                           (< (point)
                              (- (org-element-end node)
                                 (org-element-property
                                  :post-blank node))))
                  node)))))
        t)))))

(defun org-texmacs--edit-fragment (node)
  "Open an Org Src editor for the exact STM payload of NODE."
  (barf-if-buffer-read-only)
  (let* ((start (org-element-begin node))
         (source (org-element-property :stm-source node))
         (offset
          (if (eq (char-after start) ?$)
              1
            2))
         (begin (+ start offset))
         (end (+ begin (length source))))
    (unless (and (<= (point-min) start)
                 (<= (+ end offset) (point-max)))
      (user-error
       "STM carrier extends outside the accessible source"))
    (let ((mode (org-texmacs--edit-check-mode))
          (datum
           (org-element-create
            'stm-fragment
            (list
             :begin start
             :contents-begin begin
             :contents-end end))))
      (org-src--edit-element
       datum (format "*Org STM: %s*" (buffer-name))
       (lambda ()
         ;; Restore the literal payload after Org's initial dedenting.
         (erase-buffer)
         (insert source)
         (funcall mode)
         (setq-local org-texmacs--edit-fragment-source source)
         (set-buffer-modified-p nil))
       t)
      (unless org-texmacs--edit-fragment-source
        (org-edit-src-abort)
        (user-error "Could not initialize STM fragment editing"))
      (setq-local org-src--preserve-indentation t))))

(defun org-texmacs--edit-write-back (original &rest arguments)
  "Check STM edits before calling ORIGINAL with ARGUMENTS."
  (when (and org-src--allow-write-back
             org-texmacs--edit-block-end-regexp)
    ;; Check before Org changes the modified flag or allocates its write buffer.
    (save-match-data
      (org-with-wide-buffer
       (goto-char (point-min))
       (let ((case-fold-search t))
         (when (re-search-forward org-texmacs--edit-block-end-regexp
                                  nil
                                  t)
           (user-error
            "STM body contains its Org block closing line"))))))
  (if (not
       (and org-texmacs--edit-fragment-source
            org-src--allow-write-back))
      (apply original arguments)
    (let ((editor (current-buffer))
          (payload
           (org-with-wide-buffer
            (buffer-substring-no-properties (point-min) (point-max))))
          (expected org-texmacs--edit-fragment-source)
          (begin org-src--beg-marker)
          (end org-src--end-marker))
      (with-temp-buffer
        ;; Use the same lexical rules as recognition, with synthetic delimiters.
        (insert "$" payload "$")
        (unless (condition-case nil
                    (= (car
                        (org-texmacs--fragment-object-scan
                         (point-min) (point-max)))
                       (point-max))
                  (org-texmacs-parse-error
                   nil))
          (user-error "Expected one complete compound STM datum")))
      (with-current-buffer (org-src-source-buffer)
        (barf-if-buffer-read-only)
        (unless (<= (point-min) begin end (point-max))
          (user-error
           "STM payload extends outside the accessible source"))
        (unless (equal
                 expected (buffer-substring-no-properties begin end))
          (user-error "STM payload changed in the source buffer")))
      (prog1 (apply original arguments)
        (when (buffer-live-p editor)
          (with-current-buffer editor
            (setq org-texmacs--edit-fragment-source payload)))))))

(defun org-texmacs--edit-special (original &rest arguments)
  "Edit embedded STM, or apply ORIGINAL to ARGUMENTS normally."
  (let ((context (org-texmacs--edit-context)))
    (if (not context)
        (let ((fragment (org-texmacs--edit-fragment-at-point)))
          (if fragment
              (org-texmacs--edit-fragment fragment)
            (apply original arguments)))
      (barf-if-buffer-read-only)
      (let* ((mode (org-texmacs--edit-check-mode))
             (datum (org-element-copy (car context)))
             (begin (nth 1 context))
             (end (nth 2 context))
             (base (nth 3 context))
             (end-regexp
              (org-texmacs--edit-block-end-pattern
               (org-texmacs--native-body-kind datum)))
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
           (setq-local org-texmacs--edit-block-end-regexp end-regexp)
           (set-buffer-modified-p nil))
         t)
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
  "Handle Org TAB inside a native STM special-block body."
  (let ((context (org-texmacs--edit-context)))
    (when (and context
               (<= (nth 1 context) (point))
               (< (point) (nth 2 context)))
      (org-texmacs--edit-indent context (point) (point))
      t)))

(advice-add 'org-edit-special :around #'org-texmacs--edit-special)
(advice-add 'org-edit-src-save :around #'org-texmacs--edit-write-back)
(advice-add 'org-edit-src-exit :around #'org-texmacs--edit-write-back)
(advice-add
 'org-indent-line
 :around #'org-texmacs--edit-org-indent-line)
(advice-add
 'org-indent-region
 :around #'org-texmacs--edit-org-indent-region)
(add-hook 'org-tab-first-hook #'org-texmacs--edit-tab)

(provide 'org-texmacs-edit)

;;; org-texmacs-edit.el ends here
