;;; sources.el --- Bounded font-lock implementation audit -*- lexical-binding: t; -*-
(require 'org)
(require 'org-src)
(require 'font-lock)
(require 'jit-lock)
(require 'find-func)
(defvar fl-output (getenv "PROBE_OUTPUT"))
(let ((coding-system-for-write 'utf-8-unix))
  (with-temp-file (expand-file-name "versions.sexp" fl-output)
    (prin1 (list :emacs emacs-version :org (org-version)) (current-buffer))))
(dolist (symbol '(org-src-font-lock-fontify-block org-fontify-meta-lines-and-blocks
                  org-set-font-lock-defaults org-extend-font-lock-region
                  font-lock-fontify-region font-lock-default-unfontify-region
                  font-lock-unfontify-region jit-lock-after-change jit-lock-refontify
                  font-lock-extend-region-wholelines org-fontify-meta-lines-and-blocks-1
                  org-unfontify-region org-font-lock-hook font-lock-extend-region-multiline
                  font-lock-flush font-lock-ensure font-lock-mode))
  (condition-case err
      (let* ((location (find-function-noselect symbol))
             (text (with-current-buffer (car location)
                     (save-excursion (goto-char (cdr location))
                                     (buffer-substring-no-properties (point) (progn (forward-sexp) (point)))))))
        (with-temp-file (expand-file-name (concat (symbol-name symbol) ".el") fl-output)
          (insert text "\n")))
    (error
     (with-temp-file (expand-file-name (concat (symbol-name symbol) ".unavailable") fl-output)
       (prin1 err (current-buffer))))))
(with-temp-buffer
  (org-mode)
  (font-lock-set-defaults)
  (let ((state
         (mapcar (lambda (symbol) (list symbol (and (boundp symbol) (symbol-value symbol))))
                 '(font-lock-defaults font-lock-keywords font-lock-extra-managed-props
                   font-lock-fontify-region-function font-lock-unfontify-region-function
                   font-lock-extend-region-functions jit-lock-after-change-extend-region-functions
                   before-change-functions after-change-functions org-src-fontify-natively
                   org-fontify-whole-block-delimiter-line org-src-lang-modes))))
    (with-temp-file (expand-file-name "org-state.sexp" fl-output)
      (dolist (entry state) (prin1 entry (current-buffer)) (insert "
")))))
(message "Bounded source audit complete")
