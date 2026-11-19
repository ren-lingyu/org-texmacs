;;; native.el --- native regression support -*- lexical-binding: t; -*-

;;; Commentary:

;; Test-owned support and fixtures.

;;; Code:

(defmacro org-texmacs-test--with-worker (&rest body)
  "Run BODY with isolated worker state and TeXmacs configuration."
  (declare (indent 0) (debug t))
  `(let ((org-texmacs--worker-process nil)
         (org-texmacs--worker-directory nil)
         (org-texmacs--worker-socket nil)
         (org-texmacs--worker-buffer nil)
         (org-texmacs--worker-request-id 0)
         (org-texmacs--worker-busy nil)
         (kill-emacs-hook (copy-sequence kill-emacs-hook))
         (process-environment (copy-sequence process-environment))
         (test-directory (make-temp-file "org-texmacs-ert-" t)))
     (unwind-protect
         (let ((default-directory
                (file-name-as-directory test-directory)))
           (setenv "HOME" test-directory)
           (setenv "TEXMACS_HOME_PATH"
                   (expand-file-name "config" test-directory))
           ,@body)
       (org-texmacs--worker-stop)
       (delete-directory test-directory t))))

(defun org-texmacs-test--ascii-hex (text)
  "Represent expected ASCII native TEXT as lowercase hexadecimal bytes."
  (mapconcat (lambda (character) (format "%02x" character)) text ""))

(defun org-texmacs-test--native-hex (tree)
  "Represent independently specified native TREE with hex leaves.
Only serialize expected bytes; do not call the production encoder."
  (if (stringp tree)
      (org-texmacs-test--ascii-hex tree)
    (cons
     (car tree) (mapcar #'org-texmacs-test--native-hex (cdr tree)))))

;;; native.el ends here
