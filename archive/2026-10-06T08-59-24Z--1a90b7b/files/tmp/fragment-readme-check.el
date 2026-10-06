;;; fragment-readme-check.el --- Targeted README checks -*- lexical-binding: t; -*-

(require 'ert)
(require 'org-texmacs)
(defconst org-texmacs-doc-root (expand-file-name default-directory))
(defvar org-texmacs-doc-package-directory nil)
(load (expand-file-name "tests/ert/ert.el" org-texmacs-doc-root) nil t)

(ert-deftest org-texmacs-doc-examples ()
  (org-texmacs-test--with-worker
    (dolist (example '(("example-tree" ((with concat frac) t))
                       ("example-fragment-tree"
                        ("(math (frac \"1\" \"2\"))" (math frac) nil))
                       ("example-fragment-map"
                        ("(math \"x\")" "(math (sqrt \"y\"))"))
                       ("example-fragment-config"
                        (("equation*") ("math") nil ("equation*")))
                       ("example-fragment-block" ((math equation* align*) with))))
      (let ((body
             (with-temp-buffer
               (org-mode)
               (insert-file-contents (expand-file-name "README.org" org-texmacs-doc-root))
               (org-element-map (org-element-parse-buffer) 'src-block
                 (lambda (block)
                   (when (equal (org-element-property :name block) (car example))
                     (org-element-property :value block))) nil t))))
        (ert-info ((car example))
          (should (stringp body))
          ;; Only these reviewed named examples; no Babel or README writes.
          (if (member (car example) '("example-fragment-map" "example-fragment-config"))
              (cl-letf (((symbol-function 'org-texmacs--worker-request)
                         (lambda (_) (ert-fail "Discovery must not parse"))))
                (should (equal (eval (read body) t) (cadr example))))
            (should (equal (eval (read body) t) (cadr example)))))))))

(ert-deftest org-texmacs-doc-loaded-files ()
  (let ((directory (or org-texmacs-doc-package-directory org-texmacs-doc-root)))
    (dolist (entry '(org-texmacs-tree org-texmacs-fragment-at-point
                     org-texmacs-fragment-map org-texmacs-fragment-tree))
      (should (file-in-directory-p (symbol-file entry 'defun) directory)))
    (should (file-in-directory-p org-texmacs--worker-scheme-file directory))
    (should (file-readable-p org-texmacs--worker-scheme-file)))
  (when org-texmacs-doc-package-directory
    (should (file-name-absolute-p org-texmacs-program))
    (should (file-executable-p org-texmacs-program))))

;;; fragment-readme-check.el ends here
