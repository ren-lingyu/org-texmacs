;;; org-texmacs-font-lock.el --- Embedded STM presentation -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Present recognized STM as embedded Scheme without changing Org source or
;; export discovery.  All entry points and the default-on override are internal.

;;; Code:

(require 'org-texmacs-fragment)
(require 'org-src)

(defvar font-lock-beg)
(defvar font-lock-end)

(defvar-local org-texmacs--font-lock-enabled t
  "Non-nil means present STM regions using Scheme fontification.
This is an internal override, not a user option.  Set the default binding
before loading to suppress automatic presentation globally, or set a local
binding to nil in an Org buffer.  Changes schedule normal refontification.
This does not enable Font Lock itself or change accepted export syntax.")

(defvar-local org-texmacs--font-lock-original nil
  "Org fontification function wrapped in the current buffer.")

(defvar-local org-texmacs--font-lock-dirty nil
  "Markers delimiting an old owned context affected by a character edit.")

(defun org-texmacs--font-lock-contexts (begin end)
  "Return paragraph and TeXmacs block contexts intersecting BEGIN through END.
Each entry is (TYPE BEGIN END CONTENTS-BEGIN CONTENTS-END).  Use Org's
local element lookup, not a full-source copy or export discovery request."
  (save-excursion
    (goto-char begin)
    (let (contexts)
      (while (< (point) end)
        (let* ((position (point))
               (node (org-element-at-point))
               (block (org-element-lineage node '(special-block) t))
               (type (org-element-type node))
               (target
                (cond
                 ((and block (org-texmacs--block-p block))
                  block)
                 ((eq type 'paragraph)
                  node)
                 ((memq type '(plain-list item footnote-definition))
                  (save-excursion
                    (end-of-line)
                    (org-element-lineage
                     (org-element-context) '(paragraph) t)))))
               (next (and node (org-element-property :end node))))
          (cond
           (target
            (let ((b (org-element-property :begin target))
                  (e (org-element-property :end target))
                  (cb (org-element-property :contents-begin target))
                  (ce (org-element-property :contents-end target)))
              (when (and b
                         e cb ce (< b end) (< begin e)
                         (< (max (point-min) cb)
                            (min (point-max) ce)))
                (push (list
                       (if (eq target block)
                           'block
                         'paragraph)
                       (max (point-min) b)
                       (min (point-max) e)
                       (max (point-min) cb)
                       (min (point-max) ce))
                      contexts))
              (goto-char
               (min (point-max)
                    (max (1+ position) (or e position))))))
           ((memq
             type
             '(src-block
               example-block
               export-block
               fixed-width
               table
               keyword
               comment
               comment-block))
            (goto-char
             (min (point-max)
                  (max (1+ position) (or next position)))))
           (t
            (forward-line 1)))
          (when (= position (point))
            (goto-char end))))
      (nreverse contexts))))

(defun org-texmacs--font-lock-owned-bounds (begin end)
  "Return bounds of old owned contexts touching BEGIN or END, or nil."
  (let (bounds)
    (dolist (position (list begin (max begin (1- end))))
      (when (and (< position (point-max))
                 (get-text-property
                  position 'org-texmacs--font-lock-owner))
        (let ((b
               (or (previous-single-property-change
                    (1+ position) 'org-texmacs--font-lock-owner
                    nil (point-min))
                   (point-min)))
              (e
               (or (next-single-property-change
                    position 'org-texmacs--font-lock-owner
                    nil (point-max))
                   (point-max))))
          (setq bounds
                (if bounds
                    (cons (min b (car bounds)) (max e (cdr bounds)))
                  (cons b e))))))
    bounds))

(defun org-texmacs--font-lock-extend ()
  "Extend fontification to complete current and previously owned contexts."
  (let ((begin font-lock-beg)
        (end font-lock-end)
        (old
         (org-texmacs--font-lock-owned-bounds
          font-lock-beg font-lock-end)))
    (when old
      (setq
       font-lock-beg (min font-lock-beg (car old))
       font-lock-end (max font-lock-end (cdr old))))
    (when (and org-texmacs--font-lock-enabled
               org-src-fontify-natively)
      (dolist (context
               (org-texmacs--font-lock-contexts
                font-lock-beg font-lock-end))
        (setq
         font-lock-beg (min font-lock-beg (nth 1 context))
         font-lock-end (max font-lock-end (nth 2 context)))))
    (or (/= begin font-lock-beg) (/= end font-lock-end))))

(defun org-texmacs--font-lock-paragraph-spans (begin end tags)
  "Discover presentation spans within one paragraph BEGIN to END using TAGS.
Use the existing masking and boundary scanner in a private local Org view.
Incomplete input is an editing state, not an export error."
  (when tags
    (let ((source (buffer-substring-no-properties begin end))
          (buffer (current-buffer))
          (tick (buffer-chars-modified-tick)))
      (with-temp-buffer
        (let ((org-element-use-cache nil)
              (org-inhibit-startup t))
          (delay-mode-hooks
            (org-mode))
          ;; Preserve paragraph context even if list/footnote prefixes were
          ;; outside CONTENTS-BEGIN and the first characters look structural.
          (insert "x " source)
          (condition-case nil
              (mapcar
               (lambda (span)
                 (cons
                  (org-texmacs-fragment-span-begin span)
                  (org-texmacs-fragment-span-end span)))
               (org-texmacs--fragment-scan-paragraph
                (org-element-create
                 'paragraph
                 (list :contents-begin 3 :contents-end (point-max)))
                buffer
                tick
                (- begin 3)
                tags
                (concat "(" (regexp-opt tags))))
            (org-texmacs-error
             nil)))))))

(defun org-texmacs--font-lock-scheme (begin end)
  "Apply native Scheme presentation to BEGIN through END via a private view.
The Org helper assumes a preceding character for indentation.  A staging
newline handles islands at accessible buffer start without touching source."
  (let ((source (buffer-substring-no-properties begin end))
        result)
    (with-temp-buffer
      (delay-mode-hooks
        (org-mode))
      (insert "\n" source)
      (org-src-font-lock-fontify-block "scheme" 2 (point-max))
      (setq result (buffer-substring 2 (point-max))))
    (let ((position 0)
          next)
      (while (< position (length result))
        (setq next
              (next-property-change position result (length result)))
        (add-text-properties
         (+ begin position)
         (+ begin next)
         (text-properties-at position result))
        (setq position next)))))

(defun org-texmacs--font-lock-region (begin end &optional loudly)
  "Fontify BEGIN through END with Org, then opaque embedded Scheme spans.
LOUDLY is passed to the original Org fontifier.  Never parse STM natively."
  (save-excursion
    (save-match-data
      (let ((font-lock-beg begin)
            (font-lock-end end))
        (while (org-texmacs--font-lock-extend))
        (setq
         begin font-lock-beg
         end font-lock-end))
      (let ((contexts
             (and org-texmacs--font-lock-enabled
                  org-src-fontify-natively
                  (org-texmacs--font-lock-contexts begin end)))
            (tags
             (condition-case nil
                 (org-texmacs--fragment-tags)
               (org-texmacs-error
                nil))))
        (funcall org-texmacs--font-lock-original begin end loudly)
        (dolist (context contexts)
          (let* ((cb (nth 3 context))
                 (ce (nth 4 context))
                 (spans
                  (if (eq (car context) 'block)
                      (list (cons cb ce))
                    (org-texmacs--font-lock-paragraph-spans
                     cb ce tags))))
            (when spans
              (with-silent-modifications
                (dolist (span spans)
                  ;; Remove Org's activation/hiding, not just its faces, before
                  ;; allowing the Scheme fontifier to own these characters.
                  (org-unfontify-region (car span) (cdr span))
                  (org-texmacs--font-lock-scheme
                   (car span) (cdr span)))
                ;; Include block delimiters so their deletion invalidates the
                ;; formerly owned body, even though delimiters keep Org faces.
                (put-text-property
                 (nth 1 context)
                 (nth 2 context)
                 'org-texmacs--font-lock-owner
                 (list t))
                (put-text-property
                 (nth 1 context)
                 (nth 2 context)
                 'font-lock-multiline
                 t)))))))))

(defun org-texmacs--font-lock-before-change (begin end)
  "Remember owned context bounds before an edit between BEGIN and END."
  (let ((bounds
         (org-texmacs--font-lock-owned-bounds
          (max (point-min) (1- begin)) (min (point-max) (1+ end)))))
    (when bounds
      (setq org-texmacs--font-lock-dirty
            (cons
             (copy-marker (car bounds))
             (copy-marker (cdr bounds) t))))))

(defun org-texmacs--font-lock-after-change (begin end _old-length)
  "Invalidate old owned context and newly changed text between BEGIN and END."
  (when org-texmacs--font-lock-dirty
    (let ((b (car org-texmacs--font-lock-dirty))
          (e (cdr org-texmacs--font-lock-dirty)))
      (setq org-texmacs--font-lock-dirty nil)
      (when font-lock-mode
        (font-lock-flush
         (max (point-min) (min begin (marker-position b)))
         (min (point-max) (max end (marker-position e)))))
      (set-marker b nil)
      (set-marker e nil))))

(defun org-texmacs--font-lock-teardown ()
  "Remove presentation ownership when leaving Org mode."
  (when org-texmacs--font-lock-original
    (when (eq
           font-lock-fontify-region-function
           #'org-texmacs--font-lock-region)
      (setq font-lock-fontify-region-function
            org-texmacs--font-lock-original))
    (save-restriction
      (widen)
      (with-silent-modifications
        (org-unfontify-region (point-min) (point-max))
        (remove-text-properties
         (point-min)
         (point-max)
         '(org-texmacs--font-lock-owner nil))))
    (when org-texmacs--font-lock-dirty
      (set-marker (car org-texmacs--font-lock-dirty) nil)
      (set-marker (cdr org-texmacs--font-lock-dirty) nil))
    (setq
     org-texmacs--font-lock-dirty nil
     org-texmacs--font-lock-original nil)))

(defun org-texmacs--font-lock-setup ()
  "Install local STM presentation around this Org buffer's fontifier."
  (when (and (derived-mode-p 'org-mode)
             (not org-texmacs--font-lock-original))
    (font-lock-set-defaults)
    (setq-local org-texmacs--font-lock-original
                font-lock-fontify-region-function)
    (setq-local font-lock-fontify-region-function
                #'org-texmacs--font-lock-region)
    (setq-local font-lock-extra-managed-props
                (cons
                 'org-texmacs--font-lock-owner
                 font-lock-extra-managed-props))
    (add-hook 'font-lock-extend-region-functions
              #'org-texmacs--font-lock-extend
              t
              t)
    (add-hook
     'before-change-functions #'org-texmacs--font-lock-before-change
     t t)
    (add-hook
     'after-change-functions #'org-texmacs--font-lock-after-change
     t t)
    (add-hook
     'change-major-mode-hook #'org-texmacs--font-lock-teardown
     nil t)
    (when font-lock-mode
      (font-lock-flush))))

(defun org-texmacs--font-lock-variable-changed
    (_symbol _value operation where)
  "Schedule refresh after an override/configuration change.
OPERATION is the variable watcher operation and WHERE is its buffer or nil.
Only invalidate here: watchers run before the new binding becomes visible."
  (when (memq operation '(set let unlet makunbound))
    (dolist (buffer
             (if (bufferp where)
                 (list where)
               (buffer-list)))
      (with-current-buffer buffer
        (when (and org-texmacs--font-lock-original font-lock-mode)
          (save-restriction
            (widen)
            (font-lock-flush)))))))

(add-hook 'org-mode-hook #'org-texmacs--font-lock-setup)
(add-variable-watcher
 'org-texmacs--font-lock-enabled
 #'org-texmacs--font-lock-variable-changed)
(add-variable-watcher
 'org-texmacs-fragment-tags #'org-texmacs--font-lock-variable-changed)

;; Loading the package also covers existing Org buffers.  Private parsing
;; views created with delayed mode hooks never install presentation machinery.
(dolist (buffer (buffer-list))
  (with-current-buffer buffer
    (when (derived-mode-p 'org-mode)
      (org-texmacs--font-lock-setup))))

(provide 'org-texmacs-font-lock)

;;; org-texmacs-font-lock.el ends here
