;;; package-lint.el --- Check supplied package sources -*- lexical-binding: t; -*-

;;; Commentary:

;; Keep the existing package-lint batch diagnostics and main-file handling.

;;; Code:

(require 'package-lint)

(let* ((source (or (getenv "ORG_TEXMACS_TEST_SOURCE")
                   (error "ORG_TEXMACS_TEST_SOURCE is not set")))
       (default-directory (file-name-as-directory source))
       (load-path (cons source load-path))
       (command-line-args-left
        (sort (directory-files-recursively source "\\.el\\'") #'string<))
       (package-lint-emacs-head-version '(32)))
  (unless command-line-args-left
    (error "No Emacs Lisp files found in %s" source))
  (package-lint-batch-and-exit))

;;; package-lint.el ends here
