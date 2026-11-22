;;; run.el --- Explicit ERT suite entry -*- lexical-binding: t; -*-

;;; Commentary:

;; All external paths are supplied by the calling Nix check.

;;; Code:

(require 'ert)
(require 'json)

(defun org-texmacs-test--required-env (name)
  "Return nonempty environment variable NAME, or fail."
  (let ((value (getenv name)))
    (unless (and value (not (equal value "")))
      (error "Missing test input: %s" name))
    value))

(defun org-texmacs-test--guard-executable (program)
  "Reject actual TeXmacs executable PROGRAM in a package contract test."
  (when (and (stringp program)
             (equal (file-name-nondirectory program) "texmacs"))
    (ert-fail "Package contract test attempted to execute TeXmacs")))

(defun org-texmacs-test--guard-pure-suite ()
  "Isolate package contract tests from TeXmacs."
  (when (executable-find "texmacs")
    (error "TeXmacs is present on the package test PATH"))
  (setq org-texmacs-program "/nonexistent/org-texmacs-test/texmacs")
  (advice-add
   'org-texmacs--worker-start
   :before
   (lambda ()
     (ert-fail "Package contract test attempted worker startup")))
  (advice-add
   'call-process
   :before
   (lambda (program &rest _)
     (org-texmacs-test--guard-executable program)))
  (advice-add
   'make-process
   :before
   (lambda (&rest options)
     (org-texmacs-test--guard-executable
      (car (plist-get options :command))))))

(let* ((bootstrap
        (org-texmacs-test--required-env "ORG_TEXMACS_TEST_BOOTSTRAP"))
       (helpers
        (json-parse-string (org-texmacs-test--required-env
                            "ORG_TEXMACS_TEST_HELPERS")
                           :array-type 'list))
       (files
        (json-parse-string (org-texmacs-test--required-env
                            "ORG_TEXMACS_TEST_FILES")
                           :array-type 'list)))
  (dolist (tool
           (json-parse-string (org-texmacs-test--required-env
                               "ORG_TEXMACS_TEST_TOOLS")
                              :array-type 'list))
    (unless (executable-find tool)
      (error "Missing required test tool: %s" tool)))
  ;; Observe worker-only loading before helpers load the package.
  (dolist (file (cons bootstrap helpers))
    (unless (and (file-name-absolute-p file) (file-readable-p file))
      (error "Unreadable support file: %S" file))
    (load file nil t))
  (when (equal (getenv "ORG_TEXMACS_TEST_PURE") "1")
    (org-texmacs-test--guard-pure-suite))
  (when (ert-select-tests t t)
    (error "Test support must not register ERT cases"))
  (unless files
    (error "No test files supplied"))
  (let ((set-test (symbol-function 'ert-set-test)))
    (cl-letf (((symbol-function 'ert-set-test)
               (lambda (name test)
                 (when (ert-test-boundp name)
                   (error "Duplicate ERT case: %s" name))
                 (funcall set-test name test))))
      (dolist (file files)
        (unless (and (file-name-absolute-p file)
                     (file-readable-p file))
          (error "Unreadable test file: %S" file))
        (load file nil t))))
  (let* ((cases (ert-select-tests t t))
         (names
          (sort (mapcar
                 (lambda (test)
                   (symbol-name (ert-test-name test)))
                 cases)
                #'string<)))
    (unless cases
      (error "ERT suite is empty"))
    (when-let* ((output (getenv "ORG_TEXMACS_TEST_NAMES_FILE")))
      (with-temp-file output
        (dolist (name names)
          (insert name "\n"))))))

(ert-run-tests-batch-and-exit t)

;;; run.el ends here
