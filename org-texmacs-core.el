;;; org-texmacs-core.el --- Shared core for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Define shared errors and capability checks for Org TeXmacs.

;;; Code:

(require 'cl-lib)
(require 'org-element)

(defgroup org-texmacs nil
  "Use TeXmacs trees as structured data in Org."
  :group 'org)

(defcustom org-texmacs-program "texmacs"
  "TeXmacs executable name or absolute path.
Changing this option takes effect after the current worker is stopped."
  :type 'string
  :group 'org-texmacs)

(define-error 'org-texmacs-error
              "Org TeXmacs error")

(defconst org-texmacs--capability-alist
  '((org-element-cache-store-key . function)
    (org-element-cache-get-key . function)
    (org-element-create . function)
    (org-element-contents . function)
    (org-element-set-contents . function)
    (org-element-type . function)
    (org-element-property . function)
    (org-element-parse-buffer . function)
    (org-element-map . function)
    (org-element-context . function)
    (org-element-lineage . function)
    (org-mode . function)
    (derived-mode-p . function)
    (delay-mode-hooks . function)
    (org-element-use-cache . variable)
    (org-inhibit-startup . variable)
    (org-todo-regexp . variable)
    (org-done-keywords . variable)
    (org-odd-levels-only . variable)
    (org-priority-regexp . variable)
    (org-priority-to-string . function)
    (org-make-tag-string . function)
    (org-export-with-todo-keywords . variable)
    (org-export-with-priority . variable)
    (org-export-with-tags . variable)
    (indirect-function . function)
    (functionp . function)
    (scan-sexps . function)
    (parse-partial-sexp . function)
    (make-syntax-table . function)
    (modify-syntax-entry . function)
    (regexp-opt . function)
    (regexp-quote . function)
    (string-match-p . function)
    (proper-list-p . function)
    (cl-every . function)
    (make-process . function)
    (make-network-process . function)
    (process-live-p . function)
    (process-send-string . function)
    (accept-process-output . function)
    (delete-process . function))
  "Capabilities required by Org TeXmacs.

Each entry has the form (NAME . TYPE).  TYPE is one of `function',
`variable', or `executable'.  Executable names may be strings or symbols
resolved through `executable-find'; other names must be symbols.

Rationale: Checking the interfaces used by the implementation is more precise
than inferring compatibility from package version numbers alone.")

(defun org-texmacs--capability-present-p (name type)
  "Return non-nil when capability NAME exists with TYPE.

TYPE may be `function', `variable', or `executable'.  Return nil for malformed
or unsupported capability entries."
  (pcase type
    ('function
     (and (symbolp name) (fboundp name)))
    ('variable
     (and (symbolp name) (boundp name)))
    ('executable
     (and (or (stringp name) (symbolp name))
          (executable-find (if (symbolp name) (symbol-name name) name))
          t))
    (_
     nil)))

(defun org-texmacs--check-capabilities (alist)
  "Check Org TeXmacs capabilities in ALIST.

ALIST maps capability names to `function', `variable', or `executable'.
Return a cons cell whose car is non-nil when every capability exists and whose
cdr is a human-readable report.  Malformed input yields a failed result.

Every entry is checked so callers receive one complete report instead of only
the first failure."
  (if (proper-list-p alist)
      (let ((result t)
            (lines nil))
        (dolist (entry alist)
          (let* ((name (car-safe entry))
                 (type (cdr-safe entry))
                 (present
                  (and (consp entry)
                       (memq type '(function variable executable))
                       (org-texmacs--capability-present-p name type))))
            (unless present
              (setq result nil))
            (push (format "- %s (%s): %s"
                          name
                          type
                          (if present "available" "missing"))
                  lines)))
        (cons result
              (concat
               "Org TeXmacs capabilities:\n"
               (mapconcat #'identity (nreverse lines) "\n")
               "\n")))
    (cons nil
          "Org TeXmacs capability specification is malformed.\n")))

(defun org-texmacs--setup-check ()
  "Check whether Org TeXmacs capabilities are available.

Return a cons cell whose car is the boolean result and whose cdr is a
human-readable report."
  (org-texmacs--check-capabilities
   (append org-texmacs--capability-alist
           (list (cons org-texmacs-program 'executable)))))

(defun org-texmacs--ensure-setup ()
  "Signal `org-texmacs-error' unless setup checks pass."
  (let ((result (org-texmacs--setup-check)))
    (unless (car result)
      (signal 'org-texmacs-error
              (list (cdr result))))))

(provide 'org-texmacs-core)

;;; org-texmacs-core.el ends here
