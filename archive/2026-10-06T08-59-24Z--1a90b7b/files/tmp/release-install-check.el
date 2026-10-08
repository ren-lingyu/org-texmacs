;;; release-install-check.el --- Isolated installation checks -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'lisp-mnt)
(require 'org)
(require 'use-package)
(require 'url)

(defconst org-texmacs-install-test-root (expand-file-name default-directory))
(defconst org-texmacs-install-test-straight
  "/home/lingyu/.emacs.d/straight/repos/straight.el/straight.el")
(defconst org-texmacs-install-test-files
  '("org-texmacs.el" "org-texmacs-core.el" "org-texmacs-ast.el"
    "org-texmacs-source.el" "org-texmacs-fragment.el" "org-texmacs-worker.el"
    "org-texmacs-document.el" "org-texmacs-input.el" "org-texmacs-context.el"
    "org-texmacs-session.el"
    "org-texmacs-worker.scm" "README.org" "LICENSE"))

(defun org-texmacs-install-test-example (name)
  (with-temp-buffer
    (org-mode)
    (insert-file-contents (expand-file-name "README.org" org-texmacs-install-test-root))
    (let ((body
           (org-element-map (org-element-parse-buffer) 'src-block
             (lambda (block)
               (when (equal (org-element-property :name block) name)
                 (org-element-property :value block))) nil t)))
      (cl-assert body nil "Missing README example: %s" name)
      (read body))))

(defun org-texmacs-install-test-eval (form)
  ;; Even global ensure/defer preferences must not break the explicit example.
  (let ((use-package-always-ensure t)
        (use-package-always-defer t)
        (use-package-expand-minimally t))
    (eval form t)))

(defun org-texmacs-install-test-check-loaded (directory)
  (cl-assert (featurep 'org-texmacs))
  (with-temp-buffer
    (insert-file-contents (expand-file-name "org-texmacs.el" directory))
    (cl-assert (equal (lm-header "version") "0.3.0")))
  (dolist (function '(org-texmacs-tree org-texmacs-fragment-at-point
                      org-texmacs-fragment-map org-texmacs-fragment-tree
                      org-texmacs-document org-texmacs-document-current-buffer
                      org-texmacs-input-create org-texmacs-prepare-buffer
                      org-texmacs-document-from-buffer
                      org-texmacs-session-open
                      org-texmacs-session-set-document org-texmacs-session-close))
    ;; Compare the load path, not the symlink target in straight's source copy.
    (cl-assert (equal (file-name-as-directory directory)
                      (file-name-directory (symbol-file function 'defun)))
               nil "Wrong library for %s: %s" function (symbol-file function 'defun)))
  (dolist (name org-texmacs-install-test-files)
    (when (string-suffix-p ".el" name)
      (cl-assert (featurep (intern (file-name-base name))))
      (cl-assert (equal (file-name-as-directory directory)
                        (file-name-directory (locate-library (file-name-base name)))))))
  (cl-assert (equal (expand-file-name "org-texmacs-worker.scm" directory)
                    org-texmacs--worker-scheme-file))
  (cl-assert (file-readable-p org-texmacs--worker-scheme-file))
  (cl-assert (not org-texmacs--worker-process))
  (cl-assert (car (org-texmacs-check-setup)))
  (cl-assert (not org-texmacs--worker-process))
  (cl-assert (= (length org-texmacs-fragment-tags) 11))
  (princ "PASS: loaded files, Scheme file, setup and lazy worker\n"))

(defun org-texmacs-install-test-parse ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math (sqrt \"x\")) B (equation* \"y\")\n\n"
            "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
    (let ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity)))
      (cl-assert (= (length spans) 2))
      (cl-assert (not org-texmacs--worker-process))
      (cl-assert (equal (org-texmacs--org-to-stree
                        (org-texmacs-fragment-tree (car spans)))
                       '(math (sqrt "x"))))
      (let ((process org-texmacs--worker-process))
        (cl-assert (equal (org-texmacs--org-to-stree
                          (org-texmacs-fragment-tree (cadr spans)))
                         '(equation* "y")))
        (goto-char (point-min))
        (search-forward "#+begin_texmacs")
        (let* ((block (org-element-at-point))
               (tree (org-texmacs-tree block)))
          (cl-assert (equal (org-texmacs--org-to-stree tree) '(frac "1" "2")))
          (cl-assert (eq tree (org-texmacs-tree block))))
        (cl-assert (eq process org-texmacs--worker-process))
        (cl-assert (org-texmacs--worker-live-p)))))
  (princ "PASS: real fragment/block parsing, shared worker and cache\n"))

(defun org-texmacs-install-test-document ()
  "Exercise the installed v0.3 document/session bridge from a cold worker."
  (cl-assert (not org-texmacs--worker-process))
  (with-temp-buffer
    (org-mode)
    (insert "#+TITLE: Release check\n"
            "#+OPTIONS: toc:1 H:1 num:nil\n"
            "* Heading\n"
            "- /i/ [[ftps://example.org][L]] [fn::n] (math \"<alpha>\")\n\n"
            "| A | B |\n"
            "| 1 | 2 |\n\n"
            "#+begin_src text\n"
            "x\n"
            "#+end_src\n")
    (let ((org-texmacs-document-style '("article" "number-europe"))
          (org-texmacs-document-initial '(("par-first" . "2fn"))))
      (let* ((source (buffer-string))
             (tick (buffer-chars-modified-tick))
             (buffer (current-buffer))
             (input (org-texmacs-prepare-buffer buffer))
             (document (org-texmacs-document input))
             (session (org-texmacs-session-open))
             (process org-texmacs--worker-process))
        (unwind-protect
            (progn
              (cl-assert (org-texmacs-input-p input))
              (cl-assert (equal document
                                (org-texmacs-document-from-buffer buffer)))
              (cl-assert (equal document
                                (org-texmacs-document-current-buffer)))
              (cl-assert (equal (org-texmacs-document-style document)
                                '("article" "number-europe")))
              (cl-assert (equal (org-texmacs-document-initial document)
                                '(("par-first" . "2fn"))))
              (let ((printed (prin1-to-string (org-texmacs-document-body document))))
                (dolist (tag '(doc-data table-of-contents section* itemize
                               hlink footnote math tabular code))
                  (cl-assert (string-match-p
                              (concat "(" (regexp-quote (symbol-name tag)) "\\(?:[ )]\\)")
                              printed))))
              (dotimes (_ 2)
                (org-texmacs-session-set-document session document)
                (let* ((readback (org-texmacs--session-read-document session))
                       (style (cdr (assq 'style (cdr readback))))
                       (initial (cdr (assq 'initial (cdr readback))))
                       (body (cadr (assq 'body (cdr readback)))))
                  (cl-assert (equal style '("article" "number-europe")))
                  (cl-assert
                   (equal (caddr (cl-find "par-first" initial
                                          :key #'cadr :test #'equal))
                          "32666e"))
                  (cl-assert (eq (car body) 'document))))
              (cl-assert (eq process org-texmacs--worker-process))
              (cl-assert (equal source (buffer-string)))
              (cl-assert (= tick (buffer-chars-modified-tick))))
          (org-texmacs-session-close session)))))
  (org-texmacs--worker-stop)
  (princ "PASS: cold installed v0.3 document/session bridge and repeated native update\n"))

(defun org-texmacs-install-test-run (kind)
  (cl-assert (memq kind '(local straight)))
  (cl-assert (not (featurep 'org-texmacs)) nil "Package already loaded before test")
  (let* ((fixture (make-temp-file
                   (expand-file-name "tmp/install-check-" org-texmacs-install-test-root) t))
         (user-emacs-directory (expand-file-name "emacs/" fixture))
         (temporary-file-directory (file-name-as-directory fixture))
         (default-directory (file-name-as-directory fixture))
         (process-environment (copy-sequence process-environment))
         (kill-emacs-hook (copy-sequence kill-emacs-hook))
         (source (expand-file-name "source/" fixture)))
    ;; Do not let native compilation escape to the user's cache or outlive us.
    (set 'native-comp-jit-compilation nil)
    (set 'native-comp-deferred-compilation nil)
    (setenv "HOME" fixture)
    (setenv "TEXMACS_HOME_PATH" (expand-file-name "texmacs" fixture))
    (setenv "XDG_CACHE_HOME" (expand-file-name "cache" fixture))
    (unwind-protect
        (cl-letf (((symbol-function 'url-retrieve)
                   (lambda (&rest _) (error "Network forbidden in install test")))
                  ((symbol-function 'url-retrieve-synchronously)
                   (lambda (&rest _) (error "Network forbidden in install test")))
                  ((symbol-function 'package-install)
                   (lambda (&rest _) (error "package.el install forbidden"))))
          (make-directory source t)
          (make-directory user-emacs-directory t)
          (dolist (name org-texmacs-install-test-files)
            (copy-file (expand-file-name name org-texmacs-install-test-root)
                       (expand-file-name name source)))
          (princ (format "Environment: %s; Org %s; mode %s\n"
                         emacs-version (org-version) kind))
          (pcase kind
            ('local
             (let ((form (org-texmacs-install-test-example "example-use-package-local")))
               (setcdr (cdr form) (plist-put (cddr form) :load-path source))
               (org-texmacs-install-test-eval form))
             (org-texmacs-install-test-check-loaded source)
             (org-texmacs-install-test-eval
              (org-texmacs-install-test-example "example-use-package-installed"))
             (org-texmacs-install-test-document)
             (org-texmacs-install-test-parse)
             (let ((form (org-texmacs-install-test-example "example-use-package-installed")))
               (org-texmacs-install-test-eval
                (append form '(:custom (org-texmacs-fragment-tags '("math"))))))
             (cl-assert (equal org-texmacs-fragment-tags '("math")))
             (with-temp-buffer
               (org-mode)
               (insert "(math \"x\") (equation* \"y\")")
               (cl-assert (equal (org-texmacs-fragment-map
                                 (point-min) (point-max) #'org-texmacs-fragment-span-tag)
                                '("math")))))
            ('straight
             (dolist (setting `((straight-base-dir . ,user-emacs-directory)
                                (straight-recipe-repositories . nil)
                                (straight-check-for-modifications . nil)
                                (straight-enable-package-integration . nil)
                                (straight-disable-native-compile . t)))
               (set (car setting) (cdr setting)))
             ;; Read the installed source directly, never bootstrap or init.el.
             (load org-texmacs-install-test-straight nil t t)
             (straight-use-package-mode 1)
             (cl-letf (((symbol-function 'straight--clone-repository)
                        (lambda (&rest _) (error "Cloning forbidden in install test"))))
               ;; Org is supplied by emacs-twist; do not download a second Org.
               (straight-use-package '(org :type built-in))
               (let* ((form (org-texmacs-install-test-example "example-use-package-straight"))
                      (recipe (copy-tree (plist-get (cddr form) :straight))))
                 (cl-assert (equal (plist-get (cdr recipe) :files)
                                   '("org-texmacs*.el" "org-texmacs-worker.scm")))
                 ;; Only substitute fetching; retain the actual file/build recipe.
                 (setcdr recipe (plist-put (cdr recipe) :type nil))
                 (setcdr recipe (plist-put (cdr recipe) :local-repo source))
                 (setcdr (cdr form) (plist-put (cddr form) :straight recipe))
                 (org-texmacs-install-test-eval form))
               (let ((build (expand-file-name "straight/build/org-texmacs/"
                                              user-emacs-directory)))
                 (org-texmacs-install-test-check-loaded build)
                 (dolist (name org-texmacs-install-test-files)
                   (when (string-suffix-p ".el" name)
                     (cl-assert (file-exists-p (expand-file-name (concat name "c") build)))))
                 (cl-assert (file-readable-p
                             (expand-file-name "org-texmacs-autoloads.el" build)))
                 (with-temp-buffer
                   (insert-file-contents (expand-file-name "org-texmacs-autoloads.el" build))
                   (dolist (function '(org-texmacs-document
                                       org-texmacs-input-create
                                       org-texmacs-prepare-buffer
                                       org-texmacs-document-from-buffer
                                       org-texmacs-document-current-buffer))
                     (goto-char (point-min))
                     (cl-assert (re-search-forward
                                 (concat "(autoload '" (symbol-name function) "\\_>") nil t))))
                 (cl-assert (not (file-exists-p (expand-file-name "README.org" build))))
                 (princ "PASS: real straight byte compilation and autoload generation\n"))
               (org-texmacs-install-test-document)
               (org-texmacs-install-test-parse)
               ;; Also verify the documented opt-out under global straight defaults.
               (set 'straight-use-package-by-default t)
               (cl-letf (((symbol-function 'straight-use-package)
                          (lambda (&rest _) (error "Opt-out unexpectedly invoked straight"))))
                 (org-texmacs-install-test-eval
                  (append (org-texmacs-install-test-example "example-use-package-installed")
                          '(:straight nil)))))))
          (princ (format "PASS: %s installation checks complete\n" kind)))
      (when (fboundp 'org-texmacs--worker-stop) (org-texmacs--worker-stop))
      ;; Only the fresh fixture created by this invocation is removed.
      (delete-directory fixture t))))

;;; release-install-check.el ends here
