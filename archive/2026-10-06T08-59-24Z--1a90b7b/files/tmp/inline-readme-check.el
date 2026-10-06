;;; inline-readme-check.el --- Read-only documentation checks -*- lexical-binding: t; -*-

(require 'ert)
(require 'org-texmacs)

(defconst org-texmacs-doc-probe-root (expand-file-name default-directory))
(defvar org-texmacs-doc-probe-package-directory nil)
(load (expand-file-name "tests/ert/ert.el" org-texmacs-doc-probe-root) nil t)

(ert-deftest org-texmacs-doc-probe-examples ()
  (org-texmacs-test--with-worker
    (dolist (example '(("example-tree" ((with concat frac) t))
                       ("example-inline-tree"
                        ("(math (frac \"1\" \"2\"))" (math frac) nil))
                       ("example-inline-map"
                        ("(math \"x\")" "(math (sqrt \"y\"))"))))
      (let ((body
             (with-temp-buffer
               (org-mode)
               (insert-file-contents
                (expand-file-name "README.org" org-texmacs-doc-probe-root))
               (org-element-map (org-element-parse-buffer) 'src-block
                 (lambda (block)
                   (when (equal (org-element-property :name block) (car example))
                     (org-element-property :value block))) nil t))))
        (ert-info ((car example))
          (should (stringp body))
          ;; Evaluate only the three named examples, never Babel execution or
          ;; source-block result insertion into the README buffer.
          (should (equal (eval (read body) t) (cadr example))))))))

(ert-deftest org-texmacs-doc-probe-installed-files ()
  (should org-texmacs-doc-probe-package-directory)
  (dolist (entry '(org-texmacs-inline-at-point org-texmacs-inline-map
                   org-texmacs-inline-tree))
    (should (fboundp entry))
    (should (file-in-directory-p (symbol-file entry 'defun)
                                org-texmacs-doc-probe-package-directory)))
  (should (file-readable-p org-texmacs--worker-scheme-file))
  (should (file-in-directory-p org-texmacs--worker-scheme-file
                              org-texmacs-doc-probe-package-directory))
  (should (file-name-absolute-p org-texmacs-program))
  (should (file-executable-p org-texmacs-program)))
