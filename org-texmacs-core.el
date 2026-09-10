;;; org-texmacs-core.el --- Shared core for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Define shared errors and runtime capability checks for Org TeXmacs.

;;; Code:

(require 'cl-lib)
(require 'org-element)

(define-error 'org-texmacs-error
              "Org TeXmacs error")

(defconst org-texmacs--capability-alist
  '((org-element-cache-store-key . function)
    (org-element-cache-get-key . function)
    (org-element-create . function)
    (org-element-contents . function)
    (org-element-type . function)
    (org-element-property . function))
  "Runtime capabilities required by Org TeXmacs.

Each entry has the form (NAME . TYPE).  TYPE is one of `function',
`variable', or `executable'.  Executable names are symbols resolved through
`executable-find'.

Rationale: Checking the interfaces used by the implementation is more precise
than inferring runtime compatibility from package version numbers alone.")

(defun org-texmacs--capability-present-p (name type)
  "Return non-nil when capability NAME exists with TYPE.

TYPE may be `function', `variable', or `executable'.  Return nil for malformed
or unsupported capability entries."
  (and (symbolp name)
       (pcase type
         ('function
          (fboundp name))
         ('variable
          (boundp name))
         ('executable
          (and (executable-find (symbol-name name))
               t))
         (_
          nil))))

(defun org-texmacs--check-capabilities (alist)
  "Check Org TeXmacs runtime capabilities in ALIST.

ALIST maps capability symbols to `function', `variable', or `executable'.
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
               "Org TeXmacs runtime capabilities:\n"
               (mapconcat #'identity (nreverse lines) "\n")
               "\n")))
    (cons nil
          "Org TeXmacs capability specification is malformed.\n")))

(defun org-texmacs--setup-check ()
  "Check whether Org TeXmacs runtime capabilities are available.

Return a cons cell whose car is the boolean result and whose cdr is a
human-readable report."
  (org-texmacs--check-capabilities org-texmacs--capability-alist))

(defun org-texmacs--ensure-setup ()
  "Signal `org-texmacs-error' unless runtime setup checks pass."
  (let ((result (org-texmacs--setup-check)))
    (unless (car result)
      (signal 'org-texmacs-error
              (list (cdr result))))))

(provide 'org-texmacs-core)

;;; org-texmacs-core.el ends here
