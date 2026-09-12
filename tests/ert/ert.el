;;; ert.el --- Tests for org-texmacs -*- lexical-binding: t; -*-

;;; Commentary:

;; ERT tests for org-texmacs.

;;; Code:

(require 'ert)
(require 'org-texmacs)

(defconst org-texmacs-test--readme
  (or (getenv "ORG_TEXMACS_TEST_README")
      (expand-file-name "../../README.org"
                        (file-name-directory (or load-file-name buffer-file-name))))
  "README under test, explicitly supplied by the Nix test driver.")

(ert-deftest org-texmacs-test-package-loads ()
  (let ((directory (file-name-directory (locate-library "org-texmacs"))))
    (dolist (feature '(org-texmacs org-texmacs-core org-texmacs-ast
                       org-texmacs-source org-texmacs-fragment
                       org-texmacs-document org-texmacs-worker org-texmacs-session))
      (should (featurep feature))
      (let ((library (locate-library (symbol-name feature))))
        (should library)
        (should (equal directory (file-name-directory library)))))
    (should (equal org-texmacs--worker-scheme-file
                   (expand-file-name "org-texmacs-worker.scm" directory)))
    (should (file-readable-p org-texmacs--worker-scheme-file)))
  (dolist (function '(org-texmacs-fragment-at-point org-texmacs-fragment-map
                      org-texmacs-fragment-tree org-texmacs-fragment-span-p
                      org-texmacs-document org-texmacs-document-body
                      org-texmacs-document-stm-paths org-texmacs-session-open
                      org-texmacs-session-set-document org-texmacs-session-close))
    (should (fboundp function))))

(ert-deftest org-texmacs-test-setup-check-passes ()
  (let ((result (org-texmacs-check-setup)))
    (should (car result))
    (should (stringp (cdr result)))))

(ert-deftest org-texmacs-test-capability-types ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (command)
               (and (string= command "texmacs")
                    "/test/bin/texmacs"))))
    (let ((result
           (org-texmacs--check-capabilities
            '((org-element-create . function)
              (features . variable)
              (texmacs . executable)))))
      (should (car result)))))

(ert-deftest org-texmacs-test-capability-check-reports-all-failures ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (_command)
               nil)))
    (let ((result
           (org-texmacs--check-capabilities
            '((org-texmacs-test--missing-function . function)
              (org-texmacs-test--missing-variable . variable)
              (org-texmacs-test--missing-executable . executable)
              (org-element-create . unsupported)))))
      (should-not (car result))
      (dolist (name '(org-texmacs-test--missing-function
                      org-texmacs-test--missing-variable
                      org-texmacs-test--missing-executable
                      org-element-create))
        (should (string-match-p (regexp-quote (symbol-name name))
                                (cdr result)))))))

(ert-deftest org-texmacs-test-capability-check-rejects-malformed-input ()
  (let ((result (org-texmacs--check-capabilities
                 '(org-element-create . function))))
    (should-not (car result))
    (should (string-match-p "malformed"
                            (cdr result)))))

(ert-deftest org-texmacs-test-ensure-setup-signals-error ()
  (let ((org-texmacs--capability-alist
         '((org-texmacs-test--missing-function . function))))
    (should-error (org-texmacs--ensure-setup)
                  :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-stree-org-round-trip ()
  (let* ((mode (copy-sequence "mode"))
         (math (copy-sequence "math"))
         (sum (copy-sequence "x+"))
         (numerator (copy-sequence "1"))
         (denominator (copy-sequence "2"))
         (stree
          (list 'with
                mode
                math
                (list 'concat
                      sum
                      (list 'frac numerator denominator))))
         (tree (org-texmacs--stree-to-org stree))
         (round-trip (org-texmacs--org-to-stree tree)))
    (should (equal round-trip stree))
    (dolist (string (list mode math sum numerator denominator))
      (should-not (text-properties-at 0 string)))
    (dolist (string
             (list (nth 1 round-trip)
                   (nth 2 round-trip)
                   (nth 1 (nth 3 round-trip))
                   (nth 1 (nth 2 (nth 3 round-trip)))
                   (nth 2 (nth 2 (nth 3 round-trip)))))
      (should-not (text-properties-at 0 string)))))

(ert-deftest org-texmacs-test-stree-to-org-copies-strings ()
  (let* ((source (copy-sequence "1"))
         (tree (org-texmacs--stree-to-org (list 'frac source "2")))
         (converted (car (org-element-contents tree))))
    (should (equal converted source))
    (should-not (eq converted source))
    (should-not (text-properties-at 0 source))))

(ert-deftest org-texmacs-test-stree-to-org-builds-parent-links ()
  (let* ((tree
          (org-texmacs--stree-to-org
           '(with "mode" "math"
                  (concat "x+" (frac "1" "2")))))
         (root-contents (org-element-contents tree))
         (mode (nth 0 root-contents))
         (math (nth 1 root-contents))
         (concat-node (nth 2 root-contents))
         (concat-contents (org-element-contents concat-node))
         (sum (nth 0 concat-contents))
         (frac-node (nth 1 concat-contents))
         (frac-contents (org-element-contents frac-node)))
    (should (eq (org-element-property :parent mode) tree))
    (should (eq (org-element-property :parent math) tree))
    (should (eq (org-element-property :parent concat-node) tree))
    (should (eq (org-element-property :parent sum) concat-node))
    (should (eq (org-element-property :parent frac-node) concat-node))
    (dolist (string frac-contents)
      (should (eq (org-element-property :parent string)
                  frac-node)))))

(ert-deftest org-texmacs-test-block-p ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
    (goto-char (point-min))
    (should (org-texmacs--block-p (org-element-at-point))))
  (dolist (node (list nil "text"
                     (org-element-create 'paragraph nil)
                     (org-element-create 'special-block '(:type "example"))
                     (org-element-create 'src-block '(:language "texmacs"))))
    (should-not (org-texmacs--block-p node))))

(ert-deftest org-texmacs-test-block-source-exact ()
  (dolist (body '("(frac \"1\" \"2\")\n"
                  "\n\t(with \"mode\" \"math\"\n  (concat \"α *bold* [[link]]\" (sqrt \"x\")))\n\n"
                  ""
                  "\n\n"))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_texmacs\n" body "#+end_texmacs\n")
      (goto-char (point-min))
      (let* ((block (org-element-at-point))
             (before (buffer-string))
             (position (point))
             (tick (buffer-modified-tick)))
        (should (equal (org-texmacs--block-source block) body))
        (should (equal (buffer-string) before))
        (should (= (point) position))
        (should (= (buffer-modified-tick) tick))))))

(ert-deftest org-texmacs-test-block-source-strips-properties ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
    (goto-char (point-min))
    (let* ((block (org-element-at-point))
           (begin (org-element-property :contents-begin block))
           (end (org-element-property :contents-end block)))
      (put-text-property begin end 'org-texmacs-test-property t)
      (let ((source (org-texmacs--block-source block)))
        (should (equal source "(sqrt \"x\")\n"))
        (dotimes (index (length source))
          (should-not (text-properties-at index source)))))))

(ert-deftest org-texmacs-test-block-source-rejects-other-nodes ()
  (dolist (node (list nil
                     (org-element-create 'paragraph nil)
                     (org-element-create 'special-block '(:type "example"))))
    (should-error (org-texmacs--block-source node)
                  :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-block-source-rejects-invalid-bounds ()
  (with-temp-buffer
    (insert "text")
    (dolist (bounds '((nil 3) (2 nil) (3 2) (0 2) (1 100) ("1" 2)))
      (let ((block (org-element-create
                    'special-block
                    (list :type "texmacs"
                          :contents-begin (car bounds)
                          :contents-end (cadr bounds)))))
        (should-error (org-texmacs--block-source block)
                      :type 'org-texmacs-error)))))

(ert-deftest org-texmacs-test-texmacs-headless-parse ()
  "Check the actual TeXmacs executable supplied by the test environment."
  (let ((executable (executable-find "texmacs")))
    ;; A missing executable must fail the check instead of skipping coverage.
    (should executable)
    (let ((directory (make-temp-file "org-texmacs-test-" t))
          (process-environment (copy-sequence process-environment))
          (process nil))
      (unwind-protect
          (with-temp-buffer
            ;; Isolate initialization even when this test runs outside Nix.
            (setenv "HOME" directory)
            (setenv "TEXMACS_HOME_PATH"
                    (expand-file-name "texmacs" directory))
            (let ((default-directory (file-name-as-directory directory))
                  (deadline (+ (float-time) 60)))
              (setq process
                    (make-process
                     :name "org-texmacs-test-headless"
                     :buffer (current-buffer)
                     :command
                     (list executable "-H" "-s" "-x"
                           (concat
                            "(begin "
                            "(display \"ORG-TEXMACS-SMOKE:\") "
                            "(write (tree->stree "
                            "(stm-snippet->texmacs \"(frac \\\"1\\\" \\\"2\\\")\"))) "
                            "(newline) (force-output) (quit-TeXmacs))"))
                     :connection-type 'pipe
                     :coding 'utf-8-unix
                     :noquery t
                     :sentinel #'ignore))
              (while (and (process-live-p process)
                          (< (float-time) deadline))
                (accept-process-output process 0.1))
              (ert-info ((buffer-string))
                (should-not (process-live-p process))
                (should (eq (process-status process) 'exit))
                (should (= (process-exit-status process) 0))
                (goto-char (point-min))
                (should (search-forward "ORG-TEXMACS-SMOKE:" nil t))
                (should (equal (read (current-buffer))
                               '(frac "1" "2"))))))
        (when (and process (process-live-p process))
          (delete-process process))
        (delete-directory directory t)))))

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
         (let ((default-directory (file-name-as-directory test-directory)))
           (setenv "HOME" test-directory)
           (setenv "TEXMACS_HOME_PATH" (expand-file-name "config" test-directory))
           ,@body)
       (org-texmacs--worker-stop)
       (delete-directory test-directory t))))

(ert-deftest org-texmacs-test-worker-reuses-process ()
  (org-texmacs-test--with-worker
    (should-not (org-texmacs--worker-live-p))
    (when-let* ((expected (getenv "ORG_TEXMACS_TEST_PROGRAM")))
      ;; In a Nix build the installed package must work without TeXmacs on
      ;; Emacs's executable search path, not only inside the devShell.
      (should (equal org-texmacs-program expected))
      (let ((exec-path nil))
        (should (equal (org-texmacs--worker-request "(frac \"1\" \"2\")")
                       '(frac "1" "2")))))
    (let ((process (org-texmacs--worker-start))
          (directory org-texmacs--worker-directory))
      (dolist (tree '((frac "1" "2")
                      (sqrt "α")
                      (with "mode" "math" (concat "x+" (frac "1" "2")))
                      (concat "quote: \"" "slash: \\")
                      (concat "line\nnext" "tab\tend" "control\001end")))
        (with-temp-buffer
          (should (equal (org-texmacs--worker-request (prin1-to-string tree)) tree)))
        (should (eq process org-texmacs--worker-process)))
      (should (org-texmacs--worker-live-p))
      (org-texmacs--worker-stop)
      (org-texmacs--worker-stop)
      (should-not (process-live-p process))
      (should-not (file-exists-p directory))
      (should-not org-texmacs--worker-socket)
      (should-not org-texmacs--worker-buffer))))

(ert-deftest org-texmacs-test-worker-recovers-from-source-errors ()
  (org-texmacs-test--with-worker
    (let ((process (org-texmacs--worker-start)))
      (dolist (source '("" " ; comment only\n" "(frac \"1\" \"2\""
                        "(frac \"1\" \"2)" "(sqrt \"x\") (sqrt \"y\")" "42"))
        (should-error (org-texmacs--worker-request source)
                      :type 'org-texmacs-parse-error)
        (should (eq process org-texmacs--worker-process))
        (should (equal (org-texmacs--worker-request "(sqrt \"x\") ; trailing comment\n")
                       '(sqrt "x")))))))

(ert-deftest org-texmacs-test-worker-restarts-after-exit ()
  (org-texmacs-test--with-worker
    (let ((process (org-texmacs--worker-start))
          (directory org-texmacs--worker-directory))
      (delete-process process)
      (should (equal (org-texmacs--worker-request "(sqrt \"x\")") '(sqrt "x")))
      (should-not (eq process org-texmacs--worker-process))
      (should-not (file-exists-p directory)))))

(ert-deftest org-texmacs-test-worker-request-timeout-cleans-up ()
  (org-texmacs-test--with-worker
    (let ((process (org-texmacs--worker-start))
          (directory org-texmacs--worker-directory)
          (org-texmacs-worker-request-timeout 0.1))
      ;; Leave the real server waiting for input to exercise transport expiry.
      (cl-letf (((symbol-function 'process-send-string) (lambda (&rest _) nil)))
        (should-error (org-texmacs--worker-request "(sqrt \"x\")")
                      :type 'org-texmacs-worker-error))
      (should-not (process-live-p process))
      (should-not (file-exists-p directory))
      (should-not (org-texmacs--worker-live-p)))))

(ert-deftest org-texmacs-test-worker-rejects-reentrant-request ()
  (let ((org-texmacs--worker-busy t))
    (cl-letf (((symbol-function 'org-texmacs--worker-start)
               (lambda () (ert-fail "A nested request must not touch the worker"))))
      (should-error (org-texmacs--worker-request "(sqrt \"x\")")
                    :type 'org-texmacs-worker-error))))

(ert-deftest org-texmacs-test-worker-start-timeout-cleans-up ()
  (org-texmacs-test--with-worker
    (let ((org-texmacs-worker-start-timeout 0.1)
          (make-process-function (symbol-function 'make-process))
          (make-directory-function (symbol-function 'make-temp-file))
          (started-process nil)
          (socket-directory nil))
      (cl-letf (((symbol-function 'make-process)
                 (lambda (&rest arguments)
                   ;; A real headless process which never announces readiness.
                   (setq started-process
                         (apply make-process-function
                                (plist-put arguments :command
                                           (list (executable-find org-texmacs-program)
                                                 "-H" "-s" "-x" "(sleep 30)"))))))
                ((symbol-function 'make-temp-file)
                 (lambda (&rest arguments)
                   (setq socket-directory
                         (apply make-directory-function arguments)))))
        (should-error (org-texmacs--worker-start)
                      :type 'org-texmacs-worker-error))
      (should-not (process-live-p started-process))
      (should-not (file-exists-p socket-directory))
      (should-not org-texmacs--worker-process)
      (should-not org-texmacs--worker-buffer))))

(ert-deftest org-texmacs-test-worker-rejects-invalid-responses ()
  (dolist (response '("(ok 2 (sqrt \"x\"))"
                      "(ok 1 (sqrt \"x\")) extra"
                      "(ok 1 (sqrt 42))"
                      "(unknown 1 \"x\")"
                      "(error 1 42)"))
    (should-error (org-texmacs--worker-decode response 1)
                  :type 'org-texmacs-worker-error)))

(ert-deftest org-texmacs-test-worker-decode-scopes-reader-settings ()
  (dolist (setting '(t nil))
    (let ((read-circle setting)
          (reader (symbol-function 'read-from-string))
          (predicate (symbol-function 'org-texmacs--stree-p))
          (response "(ok 1 (math \"x\"))")
          (reader-settings nil)
          (validation-settings nil))
      (cl-letf (((symbol-function 'read-from-string)
                 (lambda (string &rest args)
                   (when (equal string response)
                     (push read-circle reader-settings))
                   (apply reader string args)))
                ((symbol-function 'org-texmacs--stree-p)
                 (lambda (node)
                   (push read-circle validation-settings)
                   (funcall predicate node))))
        (should (equal (org-texmacs--worker-decode response 1) '(math "x"))))
      (should (equal reader-settings '(nil)))
      (should validation-settings)
      (should (cl-every (lambda (value) (eq value setting)) validation-settings))
      (should (eq read-circle setting)))))

(ert-deftest org-texmacs-test-worker-decode-rejects-reader-references ()
  (let ((read-circle t))
    (dolist (response '("(ok 1 #1=(math . #1#))"
                        "(ok 1 (concat #1=\"x\" #1#))"))
      (should-error (org-texmacs--worker-decode response 1)
                    :type 'invalid-read-syntax)
      (should read-circle)
      (should (equal (org-texmacs--worker-decode "(ok 1 (sqrt \"x\"))" 1)
                     '(sqrt "x"))))))

(ert-deftest org-texmacs-test-worker-decode-escaped-response-and-errors ()
  (should (equal (org-texmacs--worker-decode
                  "(\\o\\k 1 (\\m\\a\\t\\h \"中文\"))\n" 1)
                 '(math "中文")))
  (should-error (org-texmacs--worker-decode "(error 1 \"Invalid STM source\")" 1)
                :type 'org-texmacs-parse-error)
  (should (equal (org-texmacs--worker-decode "(ok 1 (math \"x\"))" 1)
                 '(math "x"))))

(ert-deftest org-texmacs-test-setup-checks-configured-program ()
  (let ((org-texmacs-program "/org-texmacs-test/nonexistent"))
    (should-not (car (org-texmacs-check-setup)))))

(defun org-texmacs-test--first-block ()
  "Return a fresh Org element at the first TeXmacs block opening."
  (save-excursion
    (goto-char (point-min))
    (search-forward "#+begin_texmacs")
    (beginning-of-line)
    (org-element-at-point)))

(ert-deftest org-texmacs-test-tree-real-parser-and-cache ()
  (org-texmacs-test--with-worker
    (let ((org-element-use-cache t))
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_texmacs\n"
                "(with \"mode\" \"math\" (concat \"x+\" (frac \"1\" \"2\")))\n"
                "#+end_texmacs\n")
        (let* ((block (org-texmacs-test--first-block))
               (text (buffer-string))
               (position (point))
               (tick (buffer-chars-modified-tick))
               (tree (org-texmacs-tree block))
               (request-id org-texmacs--worker-request-id)
               (concat-node (nth 2 (org-element-contents tree)))
               (frac-node (nth 1 (org-element-contents concat-node))))
          (should (= request-id 1))
          (should (equal (org-texmacs--org-to-stree tree)
                         '(with "mode" "math" (concat "x+" (frac "1" "2")))))
          (should (eq (org-element-property :parent concat-node) tree))
          (should (eq (org-element-property :parent frac-node) concat-node))
          (dolist (leaf (org-element-contents frac-node))
            (should (eq (org-element-property :parent leaf) frac-node)))
          (should-not (org-element-property :parent tree))
          (should (equal (org-element-map tree '(with concat frac)
                          #'org-element-type)
                         '(with concat frac)))
          (should (eq (org-element-type block) 'special-block))
          (should (equal (buffer-string) text))
          (should (= (point) position))
          (should (= (buffer-chars-modified-tick) tick))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (_source) (ert-fail "Cache hit must not parse again"))))
            (should (eq tree (org-texmacs-tree (org-texmacs-test--first-block)))))
          (should (= request-id org-texmacs--worker-request-id)))))))

(ert-deftest org-texmacs-test-tree-edit-and-error-recovery ()
  (org-texmacs-test--with-worker
    (let ((org-element-use-cache t))
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
        (org-texmacs-tree (org-texmacs-test--first-block))
        (let ((process org-texmacs--worker-process))
          (goto-char (point-min))
          (search-forward "\"2\"")
          (replace-match "\"3\"" t t)
          (let ((block (org-texmacs-test--first-block)))
            (should (eq (org-element-cache-get-key block 'org-texmacs-tree
                                                  org-texmacs--cache-miss)
                        org-texmacs--cache-miss))
            (should (equal (org-texmacs--org-to-stree (org-texmacs-tree block))
                           '(frac "1" "3")))
            (should (= org-texmacs--worker-request-id 2)))
          ;; Remove the closing parenthesis.  Org still has a special block,
          ;; but the strict reader must reject its STM body.
          (goto-char (point-min))
          (search-forward ")")
          (delete-char -1)
          (let ((block (org-texmacs-test--first-block)))
            (dotimes (_ 2)
              (should-error (org-texmacs-tree block) :type 'org-texmacs-parse-error)
              (should (eq (org-element-cache-get-key block 'org-texmacs-tree
                                                    org-texmacs--cache-miss)
                          org-texmacs--cache-miss)))
            (should (= org-texmacs--worker-request-id 4)))
          (insert ")")
          (should (equal (org-texmacs--org-to-stree
                          (org-texmacs-tree (org-texmacs-test--first-block)))
                         '(frac "1" "3")))
          (should (= org-texmacs--worker-request-id 5))
          (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-test-tree-blocks-share-worker ()
  (org-texmacs-test--with-worker
    (let ((org-element-use-cache t))
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n\n"
                "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
        (let* ((first (org-texmacs-tree (org-texmacs-test--first-block)))
               (process org-texmacs--worker-process))
          (goto-char (point-max))
          (search-backward "#+begin_texmacs")
          (should (equal (org-texmacs--org-to-stree (org-texmacs-tree (org-element-at-point)))
                         '(sqrt "x")))
          (should (eq first (org-texmacs-tree (org-texmacs-test--first-block))))
          (should (= org-texmacs--worker-request-id 2))
          (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-test-tree-prefix-edit-remains-correct ()
  (let ((org-element-use-cache t)
        (calls 0))
    (with-temp-buffer
      (org-mode)
      (insert "Before\n\n#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (should (equal source "(sqrt \"x\")\n"))
                   (cl-incf calls)
                   '(sqrt "x"))))
        (org-texmacs-tree (org-texmacs-test--first-block))
        (goto-char (point-min))
        (insert "New prefix\n")
        (let ((block (org-texmacs-test--first-block)))
          (should (equal (org-texmacs--org-to-stree (org-texmacs-tree block))
                         '(sqrt "x")))
          ;; Correctness does not depend on retaining the entry across a shift.
          (should (<= 1 calls 2)))))))

(ert-deftest org-texmacs-test-tree-rejects-wrong-block ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_source) (ert-fail "Invalid block must not start parsing"))))
    (dolist (node (list nil (org-element-create 'special-block '(:type "example"))))
      (should-error (org-texmacs-tree node) :type 'org-texmacs-error))))

(ert-deftest org-texmacs-test-tree-rejects-text-changed-during-parse ()
  (let ((org-element-use-cache t))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
      (let ((block (org-texmacs-test--first-block)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_source)
                     ;; Simulate an edit from a timer during process waiting.
                     (goto-char (point-min))
                     (search-forward "\"x\"")
                     (replace-match "\"y\"" t t)
                     '(sqrt "x"))))
          (should-error (org-texmacs-tree block) :type 'org-texmacs-error))
        (should (eq (org-element-cache-get-key (org-texmacs-test--first-block)
                                              'org-texmacs-tree org-texmacs--cache-miss)
                    org-texmacs--cache-miss))))))

(ert-deftest org-texmacs-test-fragment-prefix ()
  (with-temp-buffer
    (insert "(mathjax \"x\") (foo bar) (math\"x\") (math \"y\") (math) (math(frac))")
    (goto-char (point-min))
    (dotimes (_ 3)
      (let ((start (org-texmacs--fragment-next "(math")))
        (should start)
        (should (equal (buffer-substring start (point)) "(math"))))
    (should-not (org-texmacs--fragment-next "(math"))))

(ert-deftest org-texmacs-test-fragment-prefix-is-case-sensitive ()
  (dolist (fold '(t nil))
    (with-temp-buffer
      (insert "(MATH \"x\") (Math \"y\") (math \"z\") (mAth \"w\")")
      (goto-char (point-min))
      (let* ((case-fold-search fold)
             (start (org-texmacs--fragment-next "(math")))
        (should start)
        (should (equal (buffer-substring-no-properties start (point))
                       "(math"))
        (should-not (org-texmacs--fragment-next "(math"))
        (should (eq case-fold-search fold))))))

(ert-deftest org-texmacs-test-fragment-structural-boundaries ()
  (dolist (source '("(math \"x\")" "(math)" "(math(frac \"1\" \"2\"))"
                    "(math\n (frac \"1\" (sqrt \"x\")))"
                    "(math (concat \"a)\\\"b\" \"c\\\\d\"))"
                    "(math \"; #; #| |# ' ` , \\\\ \\\"\")"))
    (ert-info (source)
      (with-temp-buffer
        (org-mode)
        (insert source " tail")
        ;; Source text properties must not override the dedicated table.
        (put-text-property (point-min) (point-max) 'syntax-table '(1))
        (let ((position (point)))
          (should (= (org-texmacs--fragment-end (point-min))
                     (1+ (length source))))
          (should (= (point) position)))))))

(ert-deftest org-texmacs-test-fragment-rejects-reader-extensions ()
  (dolist (source '("(math ; ) comment\n \"x\")"
                    "(math #; (sqrt \"x\") \"y\")"
                    "(math #| ) comment |# \"x\")"
                    "(math #\\))" "(math '(sqrt \"x\"))"
                    "(math `(sqrt ,x))" "(math (|escaped tag| \"x\"))"
                    "(math (escaped\\)tag \"x\"))"
                    "(math \"unclosed)" "(math (frac \"1\" \"2\")"))
    (ert-info (source)
      (with-temp-buffer
        (insert source)
        (should-not (org-texmacs--fragment-end (point-min)))))))

(ert-deftest org-texmacs-test-fragment-structural-scan-stays-in-paragraph ()
  (with-temp-buffer
    (insert "(math \"x\"\n\nNext )\n")
    (narrow-to-region (point-min) 11)
    (should-not (org-texmacs--fragment-end (point-min)))))

(defun org-texmacs-test--fragment-sources (&optional begin end)
  "Return fragment sources in the accessible buffer or between BEGIN and END."
  (org-texmacs-fragment-map (or begin (point-min)) (or end (point-max))
                         #'org-texmacs-fragment-span-source))

(ert-deftest org-texmacs-test-fragment-source-cases ()
  (dolist (case
           '(("A (math \"x\") B\n" "(math \"x\")")
             ("A (math (frac \"1\" (sqrt \"x\"))) B\n" "(math (frac \"1\" (sqrt \"x\")))")
             ("A (math (concat \"a)\\\"b\" \"c\\\\d\")) B\n" "(math (concat \"a)\\\"b\" \"c\\\\d\"))")
             ("A (math\n (frac \"1\" \"2\")) B\n" "(math\n (frac \"1\" \"2\"))")
             ("A (math \"x\") B (math \"y\") C\n" "(math \"x\")" "(math \"y\")")
             ("A (math(frac \"1\" \"2\")) B\n" "(math(frac \"1\" \"2\"))")
             ("A (mathjax \"x\") B (foo bar) C (math\"x\")\n")
             ("A (MATH \"x\") B (Math \"y\") C\n")
             ("A (math (frac \"1\" \"2\") B\n\nNext ) paragraph.\n")
             ("A (math \"unclosed) B\n")
             ("A ~(math \"x\")~ B =(math \"y\")= C\n")
             ("A [[file:x][(math \"x\")]] B *(math \"y\")* C\n")
             ("A /(math \"x\")/ B _(math \"y\")_ C +(math \"z\")+ D\n")
             ("A (math (concat \"*bold*\" \"[[file:x]]\" \"~code~\")) B\n"
              "(math (concat \"*bold*\" \"[[file:x]]\" \"~code~\"))")
             ("* Heading (math \"x\")\n")
             ("| cell (math \"x\") |\n")
             ("#+begin_src scheme\n(math \"x\")\n#+end_src\n")
             ("#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
             ("#+begin_texmacs\n#+begin_quote\n(math \"x\")\n#+end_quote\n#+end_texmacs\n")
             ("#+begin_quote\nText (math \"x\")\n#+end_quote\n" "(math \"x\")")
             ("- Item (math \"x\")\n" "(math \"x\")")
             ("A (math (unknown ...)) B\n" "(math (unknown ...))")
             ("A (math \"literal ; #; #| |#\") B\n" "(math \"literal ; #; #| |#\")")
             ("A (math ;; ) comment\n \"x\") B\n")
             ("A (math #; (sqrt \"x\") \"y\") B\n")
             ("A (math #| ) comment |# \"x\") B\n")
             ("A (math ; comment (math \"not-a-formula\")\n \"x\") B (math \"y\")\n")
             ("A (math (frac \"1\" \"2\") B (math \"y\") C\n")
             ("(math \"x\")(math \"y\")" "(math \"x\")" "(math \"y\")")
             ("A (math (concat \"(math)\" (math \"x\"))) B\n"
              "(math (concat \"(math)\" (math \"x\")))")))
    (ert-info ((car case))
      (with-temp-buffer
        (org-mode)
        (insert (car case))
        (let ((text (buffer-string))
              (position (point))
              (tick (buffer-chars-modified-tick)))
          (should (equal (org-texmacs-test--fragment-sources) (cdr case)))
          (should (equal (buffer-string) text))
          (should (= (point) position))
          (should (= (buffer-chars-modified-tick) tick)))))))

(ert-deftest org-texmacs-test-fragment-scan-is-isolated ()
  (with-temp-buffer
    (org-mode)
    (insert "Text (math \"*bold* [[file:x]]\") end\n")
    (put-text-property (point-min) (point-max) 'org-texmacs-test t)
    (let ((buffer (current-buffer))
          (text (buffer-string))
          (position (point))
          (tick (buffer-modified-tick))
          (buffer-read-only t)
          (org-mode-hook (list (lambda () (ert-fail "Mode hooks must not run")))))
      (cl-letf (((symbol-function 'org-texmacs--worker-start)
                 (lambda () (ert-fail "Scanning must not start a worker")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (_) (ert-fail "Scanning must not request a tree"))))
        (let* ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity))
               (span (car spans))
               (source (org-texmacs-fragment-span-source span)))
          (should (= (length spans) 1))
          (should (org-texmacs-fragment-span-p span))
          (should (eq (org-texmacs-fragment-span-buffer span) buffer))
          (should (= (org-texmacs-fragment-span-tick span) (buffer-chars-modified-tick)))
          (should (equal source (buffer-substring-no-properties
                                (org-texmacs-fragment-span-begin span)
                                (org-texmacs-fragment-span-end span))))
          (dotimes (index (length source))
            (should-not (text-properties-at index source)))))
      (should (equal-including-properties (buffer-string) text))
      (should (= (buffer-modified-tick) tick))
      (should (= (point) position))
      (should (equal (org-element-map (org-element-parse-buffer) '(bold link)
                      #'org-element-type) '(bold link))))))

(ert-deftest org-texmacs-test-fragment-at-point-boundaries ()
  (with-temp-buffer
    (org-mode)
    (insert "前文 (math \"α\") 后文\n")
    (let* ((span (car (org-texmacs-fragment-map (point-min) (point-max) #'identity)))
           (begin (org-texmacs-fragment-span-begin span))
           (end (org-texmacs-fragment-span-end span)))
      (dotimes (offset (- end begin))
        (goto-char (+ begin offset))
        (should (equal (org-texmacs-fragment-at-point) span)))
      (should (equal (org-texmacs-fragment-at-point begin) span))
      (should-not (org-texmacs-fragment-at-point (1- begin)))
      (should-not (org-texmacs-fragment-at-point end))
      (should-not (org-texmacs-fragment-at-point (point-max))))))

(ert-deftest org-texmacs-test-fragment-region-filtering-preserves-precedence ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math (concat \"~foo\" \"bar\")) after (math \"y\") end~ Z\n")
    (let* ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity))
           (first (car spans))
           (second (cadr spans))
           (begin (org-texmacs-fragment-span-begin first))
           (end (org-texmacs-fragment-span-end first)))
      (should (equal (mapcar #'org-texmacs-fragment-span-source spans)
                     '("(math (concat \"~foo\" \"bar\"))" "(math \"y\")")))
      (should (equal (org-texmacs-test--fragment-sources begin end)
                     (list (org-texmacs-fragment-span-source first))))
      (should-not (org-texmacs-test--fragment-sources (1+ begin) end))
      (should-not (org-texmacs-test--fragment-sources begin (1- end)))
      (should-not (org-texmacs-test--fragment-sources begin begin))
      ;; Even with the first formula outside the region, mask it before
      ;; checking the second one's native Org context.
      (should (equal (org-texmacs-test--fragment-sources (1+ begin) (point-max))
                     (list (org-texmacs-fragment-span-source second)))))))

(ert-deftest org-texmacs-test-fragment-mask-preserves-shape ()
  (dolist (source '("(math)" "(math \"*bold* [[file:x]] ~code~\")"
                    "(math\n (concat \"α\"\r\n\t\"β\"))"))
    (let ((copy (copy-sequence source))
          (mask (org-texmacs--fragment-mask source)))
      (should (equal source copy))
      (should (= (length source) (length mask)))
      (should (= (aref mask 0) ?\())
      (should (= (aref mask (1- (length mask))) ?\)))
      (cl-loop for index from 1 below (1- (length source))
               for character = (aref source index)
               do (should (= (aref mask index)
                             (if (memq character '(?\s ?\t ?\r ?\n))
                                 character ?x)))))))

(ert-deftest org-texmacs-test-fragment-masking-preserves-adjacent-markup ()
  (dolist (delimiter '("*" "~" "=" "/" "+"))
    (ert-info (delimiter)
      (with-temp-buffer
        (org-mode)
        (insert "A (math \"x\")" delimiter "(math \"y\")" delimiter " B\n")
        ;; The closing parenthesis does not open native emphasis/code.
        ;; Masking must not replace it with an enabling space.
        (should-not (org-element-map (org-element-parse-buffer)
                        '(bold code verbatim italic strike-through) #'identity))
        (let* ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity))
               (second (cadr spans)))
          (should (equal (mapcar #'org-texmacs-fragment-span-source spans)
                         '("(math \"x\")" "(math \"y\")")))
          (should (equal (org-texmacs-fragment-at-point
                          (org-texmacs-fragment-span-begin second)) second))
          (should (equal (org-texmacs-test--fragment-sources
                          (org-texmacs-fragment-span-begin second)
                          (org-texmacs-fragment-span-end second))
                         '("(math \"y\")"))))))))

(ert-deftest org-texmacs-test-fragment-masking-keeps-native-object-exclusions ()
  (dolist (delimiter '("*" "~" "=" "/" "+"))
    (ert-info (delimiter)
      (with-temp-buffer
        (org-mode)
        ;; An actual source space, unlike a masking artifact, enables markup.
        (insert "A (math \"x\") " delimiter "(math \"y\")" delimiter " B\n")
        (should (= (length (org-element-map (org-element-parse-buffer)
                              '(bold code verbatim italic strike-through) #'identity)) 1))
        (should (equal (org-texmacs-test--fragment-sources) '("(math \"x\")")))
        (goto-char (point-min))
        (search-forward "(math \"y\")")
        (should-not (org-texmacs-fragment-at-point (1- (point))))))))

(ert-deftest org-texmacs-test-fragment-scan-resumes-next-paragraph ()
  (dolist (bad '("(math \"unclosed) (math \"hidden\")"
                 "(math ; ) comment (math \"hidden\")"
                 "(math #\\)) (math \"hidden\")"))
    (with-temp-buffer
      (org-mode)
      (insert "A (math \"before\") B " bad "\n\nNext (math \"after\")\n")
      (should (equal (org-texmacs-test--fragment-sources)
                     '("(math \"before\")" "(math \"after\")"))))))

(ert-deftest org-texmacs-test-fragment-narrowing ()
  (with-temp-buffer
    (org-mode)
    (insert "Outside (math \"outside\")\n\n正文 (math \"α\") 尾部\n\nEnd\n")
    (goto-char (point-min))
    (search-forward "正文")
    (let ((begin (line-beginning-position))
          (end (line-beginning-position 2)))
      (narrow-to-region begin end)
      (let ((position (point)))
        (let ((span (car (org-texmacs-fragment-map begin end #'identity))))
          (should (equal (org-texmacs-fragment-span-source span) "(math \"α\")"))
          (should (equal (buffer-substring-no-properties
                          (org-texmacs-fragment-span-begin span)
                          (org-texmacs-fragment-span-end span)) "(math \"α\")")))
        (should (= (point) position)))
      (should (= (point-min) begin))
      (should (= (point-max) end)))))

(ert-deftest org-texmacs-test-fragment-rejects-invalid-arguments ()
  (with-temp-buffer
    (insert "(math \"x\")")
    (should-error (org-texmacs-fragment-at-point) :type 'org-texmacs-error)
    (should-error (org-texmacs-test--fragment-sources) :type 'org-texmacs-error)
    (org-mode)
    (dolist (position (list 0 (1+ (point-max)) "1" 1.5))
      (should-error (org-texmacs-fragment-at-point position) :type 'org-texmacs-error))
    (dolist (bounds (list '(0 2) '(3 2) '("1" 2) (list 1 (1+ (point-max)))))
      (should-error (org-texmacs-fragment-map (car bounds) (cadr bounds) #'identity)
                    :type 'org-texmacs-error))
    (should-error (org-texmacs-fragment-map (point-min) (point-max) 'not-a-function)
                  :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-fragment-map-callback-context ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math \"x\") B (math \"y\") C\n")
    (let ((buffer (current-buffer))
          (position (point))
          (begin (point-min))
          (end (point-max)))
      (should (equal (org-texmacs-fragment-map
                      begin end
                      (lambda (_span)
                        (should (eq (current-buffer) buffer))
                        (should (= (point) position))
                        (should (= (point-min) begin))
                        (should (= (point-max) end))
                        (goto-char begin)
                        (narrow-to-region begin (1+ begin))
                        nil))
                     '(nil nil)))
      (should (= (point) position))
      (should (= (point-min) begin))
      (should (= (point-max) end)))))

(ert-deftest org-texmacs-test-fragment-map-rejects-callback-source-changes ()
  (dolist (action '(edit kill change-buffer change-mode))
    (with-temp-buffer
      (org-mode)
      (insert "A (math \"x\") B (math \"y\") C\n")
      (let ((calls 0)
            (other (generate-new-buffer " *org-texmacs-test-other*")))
        (unwind-protect
            (progn
              (should-error
               (org-texmacs-fragment-map
                (point-min) (point-max)
                (lambda (_span)
                  (cl-incf calls)
                  (pcase action
                    ('edit (insert "changed"))
                    ('kill (kill-buffer (current-buffer)))
                    ('change-buffer (set-buffer other))
                    ('change-mode (fundamental-mode)))))
               :type 'org-texmacs-error)
              (should (= calls 1)))
          (kill-buffer other))))))

(defun org-texmacs-test--first-fragment ()
  "Return the first fragment span in the accessible Org buffer."
  (car (org-texmacs-fragment-map (point-min) (point-max) #'identity)))

(ert-deftest org-texmacs-test-fragment-tree-real-parser ()
  (org-texmacs-test--with-worker
    (dolist (stree '((math (concat "α+" (frac "1" (sqrt "x")) "a\"b\\c"))
                     (math) (math (frac "1"))))
      (with-temp-buffer
        (org-mode)
        (insert "Before " (prin1-to-string stree) " after\n")
        (let* ((span (org-texmacs-test--first-fragment))
               (text (buffer-string))
               (position (point))
               (tick (buffer-modified-tick))
               (tree (org-texmacs-fragment-tree span)))
          (should (eq (org-element-type tree) 'math))
          (should-not (org-element-property :parent tree))
          (should (equal (org-texmacs--org-to-stree tree) stree))
          (org-element-map tree t
            (lambda (node)
              (unless (eq node tree)
                (let ((parent (org-element-property :parent node)))
                  (should parent)
                  (should (memq node (org-element-contents parent)))
                  (should (memq tree (org-element-lineage node)))))))
          (should (equal-including-properties (buffer-string) text))
          (should (= (point) position))
          (should (= (buffer-modified-tick) tick)))))))

(ert-deftest org-texmacs-test-fragment-tree-shares-worker-with-blocks ()
  (org-texmacs-test--with-worker
    (let ((org-element-use-cache t)
          (process nil))
      (with-temp-buffer
        (org-mode)
        (insert "Fragment (math \"x\")\n\n#+begin_texmacs\n(sqrt \"y\")\n#+end_texmacs\n")
        (let* ((span (org-texmacs-test--first-fragment))
               (first (org-texmacs-fragment-tree span)))
          (setq process org-texmacs--worker-process)
          (should (= org-texmacs--worker-request-id 1))
          (let ((second (org-texmacs-fragment-tree span)))
            (should-not (eq first second))
            (should (equal (org-texmacs--org-to-stree first)
                           (org-texmacs--org-to-stree second))))
          (should (= org-texmacs--worker-request-id 2)))
        (let* ((block (org-texmacs-test--first-block))
               (tree (org-texmacs-tree block)))
          (should (equal (org-texmacs--org-to-stree tree) '(sqrt "y")))
          (should (eq tree (org-texmacs-tree block)))
          (should (= org-texmacs--worker-request-id 3))
          (should (eq process org-texmacs--worker-process))))
      (with-temp-buffer
        (org-mode)
        (insert "Other buffer (math (frac \"1\" \"2\"))\n")
        (should (equal (mapcar #'org-texmacs--org-to-stree
                              (org-texmacs-fragment-map (point-min) (point-max)
                                                      #'org-texmacs-fragment-tree))
                       '((math (frac "1" "2")))))
        (should (= org-texmacs--worker-request-id 4))
        (should (eq process org-texmacs--worker-process))))))

(ert-deftest org-texmacs-test-fragment-tree-real-error-and-repair ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      ;; Balanced source reaches the worker, whose stree-shape check rejects
      ;; the numeric child.  This is not a tag-arity validation test.
      (insert "A (math 1) B\n")
      (let ((span (org-texmacs-test--first-fragment)))
        (dotimes (_ 2)
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-parse-error)
          (should (org-texmacs--worker-live-p)))
        (let ((process org-texmacs--worker-process))
          (should (= org-texmacs--worker-request-id 2))
          (goto-char (point-min))
          (search-forward "1")
          (replace-match "\"1\"" t t)
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)
          (should (= org-texmacs--worker-request-id 2))
          (should (equal (org-texmacs--org-to-stree
                          (org-texmacs-fragment-tree (org-texmacs-test--first-fragment)))
                         '(math "1")))
          (should (= org-texmacs--worker-request-id 3))
          (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-test-fragment-tree-rejects-invalid-spans ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_) (ert-fail "Invalid spans must not request parsing"))))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\")")
      (dolist (span (list nil "(math \"x\")" '(math nil "x")
                          (org-texmacs--fragment-span-create)
                          (org-texmacs--fragment-span-create :buffer (current-buffer))))
        (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))
      (dolist (bounds (list '(0 2) '(1 nil) '(nil 2) '(3 2) '(1 1) '("1" 2)
                            (list 1 (1+ (point-max)))))
        (let ((span (org-texmacs--fragment-span-create
                     :buffer (current-buffer) :tick (buffer-chars-modified-tick)
                     :begin (car bounds) :end (cadr bounds) :source "(math \"x\")"
                     :tag "math" :tags (org-texmacs--fragment-tags))))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))
      (let ((span (org-texmacs-test--first-fragment)))
        (aset (org-texmacs-fragment-span-source span) 7 ?y)
        (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))))

(ert-deftest org-texmacs-test-fragment-tree-rejects-stale-source ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_) (ert-fail "Stale spans must not request parsing"))))
    (dolist (action '(body prefix restored-text major-mode))
      (with-temp-buffer
        (org-mode)
        (insert "A (math \"x\") B\n")
        (let ((span (org-texmacs-test--first-fragment)))
          (pcase action
            ('body
             (goto-char (point-min))
             (search-forward "\"x\"")
             (replace-match "\"y\"" t t))
            ('prefix (goto-char (point-min)) (insert "Prefix "))
            ('restored-text (insert " ") (delete-char -1))
            ('major-mode (fundamental-mode)))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))))))

(ert-deftest org-texmacs-test-fragment-tree-rejects-other-or-dead-buffer ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_) (ert-fail "Wrong-buffer spans must not request parsing"))))
    (let ((span nil))
      (with-temp-buffer
        (org-mode)
        (insert "A (math \"x\") B\n")
        (setq span (org-texmacs-test--first-fragment))
        (with-temp-buffer
          (org-mode)
          (insert "A (math \"x\") B\n")
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))
      (should-not (buffer-live-p (org-texmacs-fragment-span-buffer span)))
      (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))))

(ert-deftest org-texmacs-test-fragment-tree-narrowing-and-text-properties ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math \"x\") B\n")
    (let* ((span (org-texmacs-test--first-fragment))
           (begin (org-texmacs-fragment-span-begin span))
           (end (org-texmacs-fragment-span-end span))
           (calls 0))
      (put-text-property begin end 'org-texmacs-test t)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (cl-incf calls)
                   (should (equal source "(math \"x\")"))
                   (should-not (text-properties-at 0 source))
                   '(math "x"))))
        (save-restriction
          (narrow-to-region begin end)
          (should (equal (org-texmacs--org-to-stree (org-texmacs-fragment-tree span))
                         '(math "x")))
          (should (= (point-min) begin))
          (should (= (point-max) end)))
        (dolist (bounds (list (list (1+ begin) end) (list begin (1- end))))
          (save-restriction
            (narrow-to-region (car bounds) (cadr bounds))
            (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))
        (should (= calls 1))))))

(ert-deftest org-texmacs-test-fragment-tree-rechecks-after-worker-wait ()
  (dolist (action '(edit kill change-buffer narrow span-string))
    (with-temp-buffer
      (org-mode)
      (insert "A (math \"x\") B\n")
      (let ((span (org-texmacs-test--first-fragment))
            (other (generate-new-buffer " *org-texmacs-test-other*")))
        (unwind-protect
            (cl-letf (((symbol-function 'org-texmacs--worker-request)
                       (lambda (_)
                         ;; Model actions that can happen while waiting for
                         ;; process output, without depending on timer timing.
                         (pcase action
                           ('edit (insert "changed"))
                           ('kill (kill-buffer (current-buffer)))
                           ('change-buffer (set-buffer other))
                           ('narrow (narrow-to-region (point-min) (1+ (point-min))))
                           ('span-string (aset (org-texmacs-fragment-span-source span) 9 ?x)))
                         '(math "x")))
                      ((symbol-function 'org-texmacs--stree-to-org)
                       (lambda (_) (ert-fail "Stale results must not reach the adapter"))))
              (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))
          (kill-buffer other))))))

(ert-deftest org-texmacs-test-fragment-tree-root-and-error-contract ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math \"x\") B\n")
    (let ((span (org-texmacs-test--first-fragment)))
      (dolist (stree '("x" (frac "1" "2") (MATH "x") (equation "x")
                       nil (1 "x")))
        (cl-letf (((symbol-function 'org-texmacs--worker-request) (lambda (_) stree)))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-parse-error)))
      (dolist (condition '(org-texmacs-parse-error org-texmacs-worker-error))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_) (signal condition '("test error")))))
          (should (equal (should-error (org-texmacs-fragment-tree span) :type condition)
                         (list condition "test error"))))))))

(ert-deftest org-texmacs-test-fragment-tree-copies-stree-strings ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math \"x\") B\n")
    (let* ((span (org-texmacs-test--first-fragment))
           (string (copy-sequence "x"))
           (stree (list 'math string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request) (lambda (_) stree)))
        (let* ((tree (org-texmacs-fragment-tree span))
               (child (car (org-element-contents tree))))
          (should (equal child string))
          (should-not (eq child string))
          (should (eq (org-element-property :parent child) tree))
          (should-not (text-properties-at 0 string))
          (should-not (text-properties-at 0 (org-texmacs-fragment-span-source span)))
          (should (equal (org-texmacs--org-to-stree tree) stree)))))))

(defconst org-texmacs-test--fragment-strees
  '((math (frac "1" (sqrt "x")))
    (equation (frac "1" (sqrt "x")))
    (equation* (frac "1" (sqrt "x")))
    (eqnarray (tformat (table (row (cell "x") (cell "=") (cell "1"))
                             (row (cell "y") (cell "=") (cell "2")))))
    (eqnarray* (tformat (table (row (cell "x") (cell "=") (cell "1"))
                              (row (cell "y") (cell "=") (cell "2")))))
    (align (tformat (table (row (cell "x") (cell "=1"))
                          (row (cell "y") (cell "=2")))))
    (align* (tformat (table (row (cell "x") (cell "=1"))
                           (row (cell "y") (cell "=2")))))
    (gather (tformat (table (row (cell "x=1")) (row (cell "y=2")))))
    (gather* (tformat (table (row (cell "x=1")) (row (cell "y=2")))))
    (eqsplit (tformat (table (row (cell "x") (cell "=") (cell "1+2"))
                            (row (cell "") (cell "=") (cell "3")))))
    (eqsplit* (tformat (table (row (cell "x") (cell "=") (cell "1+2"))
                             (row (cell "") (cell "=") (cell "3"))))))
  "Representative default roots, including actual multi-row formula tables.
These fixtures test AST preservation, not numbering or rendering semantics.")

(ert-deftest org-texmacs-test-fragment-default-tags ()
  (should (equal org-texmacs-fragment-tags
                 '("math" "equation" "equation*" "eqnarray" "eqnarray*"
                   "align" "align*" "gather" "gather*" "eqsplit" "eqsplit*")))
  (should (equal org-texmacs-fragment-tags
                 (mapcar (lambda (stree) (symbol-name (car stree)))
                         org-texmacs-test--fragment-strees))))

(ert-deftest org-texmacs-test-fragment-default-sources ()
  (dolist (stree org-texmacs-test--fragment-strees)
    (let ((single (prin1-to-string stree)))
      (dolist (source (list single (replace-regexp-in-string " (" "\n (" single t t)))
        (ert-info ((format "%S: %s" (car stree) source))
          (with-temp-buffer
            (org-mode)
            (insert "A " source " Z\n")
            (let* ((text (buffer-string))
                   (position (point))
                   (tick (buffer-chars-modified-tick))
                   (spans (org-texmacs-fragment-map (point-min) (point-max) #'identity))
                   (span (car spans))
                   (end (+ 3 (length source))))
              (should (= (length spans) 1))
              (should (= (org-texmacs-fragment-span-begin span) 3))
              (should (= (org-texmacs-fragment-span-end span) end))
              (should (equal (org-texmacs-fragment-span-source span) source))
              (should (equal (org-texmacs-fragment-span-tag span)
                             (symbol-name (car stree))))
              (should (equal (org-texmacs-fragment-at-point 3) span))
              (should (equal (org-texmacs-fragment-at-point (1- end)) span))
              (should-not (org-texmacs-fragment-at-point end))
              (should (equal (org-texmacs-test--fragment-sources 3 end) (list source)))
              (should-not (org-texmacs-test--fragment-sources 4 end))
              (should-not (org-texmacs-test--fragment-sources 3 (1- end)))
              (should (equal (buffer-string) text))
              (should (= (point) position))
              (should (= (buffer-chars-modified-tick) tick)))))))))

(ert-deftest org-texmacs-test-fragment-default-real-trees ()
  (org-texmacs-test--with-worker
    (let ((process nil)
          (calls 0))
      (dolist (stree org-texmacs-test--fragment-strees)
        (let ((single (prin1-to-string stree)))
          (dolist (source (list single (replace-regexp-in-string " (" "\n (" single t t)))
            (ert-info ((format "%S: %s" (car stree) source))
              (with-temp-buffer
                (org-mode)
                (insert "A " source " Z\n")
                (let* ((span (org-texmacs-test--first-fragment))
                       (text (buffer-string))
                       (tree (org-texmacs-fragment-tree span))
                       (again (org-texmacs-fragment-tree span)))
                  (cl-incf calls 2)
                  (unless process (setq process org-texmacs--worker-process))
                  (should (eq process org-texmacs--worker-process))
                  (should (= calls org-texmacs--worker-request-id))
                  (should (eq (org-element-type tree) (car stree)))
                  (should-not (org-element-property :parent tree))
                  (should-not (eq tree again))
                  (should (equal (org-texmacs--org-to-stree tree) stree))
                  (should (equal (org-texmacs--org-to-stree again) stree))
                  (org-element-map tree t
                    (lambda (node)
                      ;; Empty cell strings carry no text properties.
                      (unless (or (eq node tree) (equal node ""))
                        (let ((parent (org-element-property :parent node)))
                          (should parent)
                          (should (memq node (org-element-contents parent)))
                          (should (memq tree (org-element-lineage node)))))))
                  (let ((leaves (org-element-map tree 'plain-text #'identity))
                        (copies (org-element-map again 'plain-text #'identity)))
                    (cl-mapc (lambda (a b)
                               (unless (equal a "") (should-not (eq a b))))
                             leaves copies))
                  (should-not (text-properties-at 0 (org-texmacs-fragment-span-source span)))
                  (should (equal (buffer-string) text)))))))))))

(ert-deftest org-texmacs-test-fragment-default-native-exclusions ()
  (dolist (stree org-texmacs-test--fragment-strees)
    (let ((source (prin1-to-string stree)))
      (dolist (wrapper '("A ~%s~ B\n" "A =%s= B\n" "A *%s* B\n"
                         "A [[file:x][%s]] B\n" "* Heading %s\n" "| %s |\n"
                         "#+begin_src scheme\n%s\n#+end_src\n"
                         "#+begin_texmacs\n%s\n#+end_texmacs\n"
                         "#+begin_texmacs\n#+begin_quote\n%s\n#+end_quote\n#+end_texmacs\n"))
        (ert-info ((format "%S: %s" (car stree) wrapper))
          (with-temp-buffer
            (org-mode)
            (insert (format wrapper source))
            (should-not (org-texmacs-test--fragment-sources))
            (goto-char (point-min))
            (search-forward (concat "(" (symbol-name (car stree))))
            (should-not (org-texmacs-fragment-at-point))))))))

(ert-deftest org-texmacs-test-fragment-tag-prefixes ()
  (dolist (tag org-texmacs-fragment-tags)
    (ert-info (tag)
      (with-temp-buffer
        (org-mode)
        (insert (format "(%sx \"no\") (%s\"no\") (%s \"no\") (%s) (%s(frac))\n"
                        tag tag (upcase tag) tag tag))
        (should (equal (org-texmacs-test--fragment-sources)
                       (list (format "(%s)" tag) (format "(%s(frac))" tag)))))))
  (with-temp-buffer
    (org-mode)
    (let ((sources (mapcar #'prin1-to-string org-texmacs-test--fragment-strees)))
      (insert (mapconcat #'identity sources " ") "\n")
      (should (equal (org-texmacs-test--fragment-sources) sources))
      (let ((org-texmacs-fragment-tags (reverse org-texmacs-fragment-tags)))
        (should (equal (org-texmacs-test--fragment-sources) sources))))))

(ert-deftest org-texmacs-test-fragment-custom-tags ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\") (custom.tag* (sqrt \"y\")) (customXtag \"no\")\n")
    (let ((org-texmacs-fragment-tags '("custom.tag*" "custom.tag*")))
      (should (equal (org-texmacs-test--fragment-sources)
                     '("(custom.tag* (sqrt \"y\"))"))))
    (let ((org-texmacs-fragment-tags nil))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_) (ert-fail "Disabled scanning must not parse"))))
        (should-not (org-texmacs-test--fragment-sources))
        (should-not (org-texmacs-fragment-at-point (point-min))))))
  (with-temp-buffer
    (org-mode)
    (insert "(equation (math \"x\"))\n")
    (should (equal (org-texmacs-test--fragment-sources) '("(equation (math \"x\"))")))
    (let ((org-texmacs-fragment-tags '("math")))
      (should (equal (org-texmacs-test--fragment-sources) '("(math \"x\")")))))
  (dolist (tag '("A0-_.+*?!:/<>=" "TeXmacs"))
    (with-temp-buffer
      (org-mode)
      (let ((org-texmacs-fragment-tags (list tag))
            (source (format "(%s \"x\")" tag)))
        (insert "A " source " B\n")
        (should (equal (org-texmacs-test--fragment-sources) (list source)))))))

(ert-deftest org-texmacs-test-fragment-invalid-tags ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")")
    (let ((span (org-texmacs-test--first-fragment))
          (cycle (list "math")))
      (setcdr cycle cycle)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_) (ert-fail "Invalid configuration must not parse"))))
        (dolist (value (append (list cycle) '(t "math" ["math"] (math) (nil)
                                             ("math" . "equation") ("") ("1x")
                                             ("math ") ("é") ("math\n") ("(math")
                                             ("math)") ("x\"y") ("x\\y") ("x#")
                                             ("x;") ("x'") ("x`") ("x,") ("x|")
                                             ("x[") ("x{") ("x\t"))))
          (let ((org-texmacs-fragment-tags value))
            (should-error (org-texmacs-fragment-at-point 1) :type 'org-texmacs-error)
            (should-error (org-texmacs-test--fragment-sources) :type 'org-texmacs-error)
            (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)))))))

(ert-deftest org-texmacs-test-fragment-tag-snapshots ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\") (math \"y\")")
    (let* ((org-texmacs-fragment-tags (list (copy-sequence "math")))
           (span (org-texmacs-test--first-fragment))
           (snapshot (org-texmacs-fragment-span-tags span)))
      (should (equal snapshot org-texmacs-fragment-tags))
      (should-not (eq snapshot org-texmacs-fragment-tags))
      (should-not (eq (car snapshot) (car org-texmacs-fragment-tags)))
      (should-not (eq (car snapshot) (org-texmacs-fragment-span-tag span)))
      (aset (car org-texmacs-fragment-tags) 0 ?M)
      (should (equal snapshot '("math")))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_) (ert-fail "Changed tags must not parse"))))
        (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)
        (setcar org-texmacs-fragment-tags "equation")
        (should (equal snapshot '("math")))
        (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))
      ;; Equal restored values are accepted; no configuration history tracking.
      (setq org-texmacs-fragment-tags (list (copy-sequence "math")))
      (cl-letf (((symbol-function 'org-texmacs--worker-request) (lambda (_) '(math "x"))))
        (should (equal (org-texmacs--org-to-stree (org-texmacs-fragment-tree span))
                       '(math "x"))))
      (setq org-texmacs-fragment-tags '("math" "equation"))
      (setq span (org-texmacs-test--first-fragment))
      (setq org-texmacs-fragment-tags '("equation" "math"))
      (should-error (org-texmacs--fragment-source span) :type 'org-texmacs-error))))

(ert-deftest org-texmacs-test-fragment-buffer-local-tags ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-texmacs-fragment-tags '("equation*"))
    (insert "(math \"x\") (equation* \"y\")")
    (let ((span (org-texmacs-test--first-fragment)))
      (should (equal (org-texmacs-fragment-span-tag span) "equation*"))
      (with-temp-buffer
        (org-mode)
        (setq-local org-texmacs-fragment-tags '("math"))
        (insert "(math \"x\") (equation* \"y\")")
        (should (equal (org-texmacs-test--fragment-sources) '("(math \"x\")"))))
      (should (equal (org-texmacs-test--fragment-sources) '("(equation* \"y\")")))
      (should (equal (org-texmacs--fragment-source span) "(equation* \"y\")")))))

(ert-deftest org-texmacs-test-fragment-map-checks-tags ()
  (dolist (mutation '(replace list string))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\") (math \"y\")")
      (let ((org-texmacs-fragment-tags (list (copy-sequence "math")))
            (calls 0))
        (should-error
         (org-texmacs-fragment-map
          (point-min) (point-max)
          (lambda (_)
            (cl-incf calls)
            (pcase mutation
              ('replace (setq org-texmacs-fragment-tags nil))
              ('list (setcar org-texmacs-fragment-tags "equation"))
              ('string (aset (car org-texmacs-fragment-tags) 0 ?M)))))
         :type 'org-texmacs-error)
        (should (= calls 1))))))

(ert-deftest org-texmacs-test-fragment-tree-rechecks-tags ()
  (dolist (mutation '(replace list string tag))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\")")
      (let* ((org-texmacs-fragment-tags (list (copy-sequence "math")))
             (span (org-texmacs-test--first-fragment)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_)
                     (pcase mutation
                       ('replace (setq org-texmacs-fragment-tags nil))
                       ('list (setcar org-texmacs-fragment-tags "equation"))
                       ('string (aset (car org-texmacs-fragment-tags) 0 ?M))
                       ('tag (aset (org-texmacs-fragment-span-tag span) 0 ?M)))
                     '(math "x")))
                  ((symbol-function 'org-texmacs--stree-to-org)
                   (lambda (_) (ert-fail "Changed configuration must not reach adapter"))))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error))))))

(ert-deftest org-texmacs-test-fragment-mixed-boundaries ()
  (dolist (tag org-texmacs-fragment-tags)
    (let ((source (format "(%s \"x\")" tag)))
      (dolist (marker '("*" "~" "=" "/" "+"))
        (with-temp-buffer
          (org-mode)
          (insert "A " source marker "(math \"y\")" marker " B\n")
          (should (equal (org-texmacs-test--fragment-sources)
                         (list source "(math \"y\")")))))
      (with-temp-buffer
        (org-mode)
        (insert "A " source " B\n")
        (narrow-to-region 3 (+ 3 (length source)))
        (should (equal (org-texmacs-test--fragment-sources) (list source))))
      (dolist (bad (list (format "(%s \"x\"\n\nNext )" tag)
                        (format "(%s ; comment\n \"x\") (math \"hidden\")" tag)))
        (with-temp-buffer
          (org-mode)
          (insert bad "\n\nNext (equation* \"ok\")\n")
          (should (equal (org-texmacs-test--fragment-sources)
                         '("(equation* \"ok\")"))))))))

(ert-deftest org-texmacs-test-fragment-tags-do-not-restrict-blocks ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (let ((org-element-use-cache t)
            (stree '(with "mode" "math" (concat (math "x") (equation* "y")))))
        (insert "Before (math \"a\")\n\n#+begin_texmacs\n"
                (prin1-to-string stree) "\n#+end_texmacs\n\nAfter (align* \"b\")\n")
        (let* ((block (org-texmacs-test--first-block))
               (org-texmacs-fragment-tags nil)
               (tree (org-texmacs-tree block))
               (process org-texmacs--worker-process))
          (should-not (org-texmacs-test--fragment-sources))
          (should (equal (org-texmacs--org-to-stree tree) stree))
          (dolist (tags '(nil ("math") ("with" "math" "equation*" "align*") invalid))
            (let ((org-texmacs-fragment-tags tags))
              (should (eq tree (org-texmacs-tree block)))))
          (should (= org-texmacs--worker-request-id 1))
          (let ((org-texmacs-fragment-tags '("math" "align*")))
            (should (equal (org-texmacs-test--fragment-sources)
                           '("(math \"a\")" "(align* \"b\")")))
            (org-texmacs-fragment-map (point-min) (point-max) #'org-texmacs-fragment-tree))
          (should (eq process org-texmacs--worker-process))
          (should (= org-texmacs--worker-request-id 3))
          (should (eq tree (org-texmacs-tree block))))))))

(ert-deftest org-texmacs-test-fragment-custom-real-error-and-repair ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (let ((org-texmacs-fragment-tags '("custom.tag*")))
        (insert "Before (custom.tag* 1) after\n")
        (let ((span (org-texmacs-test--first-fragment)))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-parse-error)
          (should (org-texmacs--worker-live-p))
          (let ((process org-texmacs--worker-process))
            (goto-char (point-min))
            (search-forward "1")
            (replace-match "\"1\"" t t)
            (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)
            (should (= org-texmacs--worker-request-id 1))
            ;; Unknown tags can round-trip as AST, without proving semantics.
            (should (equal (org-texmacs--org-to-stree
                            (org-texmacs-fragment-tree (org-texmacs-test--first-fragment)))
                           '(custom.tag* "1")))
            (should (eq process org-texmacs--worker-process))
            (should (= org-texmacs--worker-request-id 2))))))))

(ert-deftest org-texmacs-document-empty ()
  (let ((result (org-texmacs--document-lower
                 (org-element-create 'org-data nil))))
    (should (org-texmacs-document-p result))
    (should (equal (org-texmacs-document-body result) '(document)))
    (should-not (org-texmacs-document-stm-paths result))))

(ert-deftest org-texmacs-document-paragraphs-and-bold ()
  (let* ((bold (org-element-create 'bold '(:post-blank 2) "bold"))
         (ast (org-element-create
               'org-data nil
               (org-element-create
                'section nil
                (org-element-create 'paragraph nil "Before " bold "after.\n")
                (org-element-create 'paragraph nil "Next.\n"))))
         (result (org-texmacs--document-lower ast)))
    (should (equal (org-texmacs-document-body result)
                   '(document (concat "Before " (strong "bold") " " "after. ")
                              (concat "Next. "))))
    (should-not (org-texmacs-document-stm-paths result))
    (should (equal (org-texmacs-document-body
                    (org-texmacs--document-lower ast nil (list (cons bold "\t "))))
                   '(document (concat "Before " (strong "bold") " " "after. ")
                              (concat "Next. "))))))

(ert-deftest org-texmacs-document-inline-whitespace-stream ()
  (let* ((value (copy-sequence " \nb\t"))
         (bold (org-element-create 'bold '(:post-blank 2) value))
         (ast (org-element-create
               'org-data nil
               (org-element-create 'paragraph nil " \ta  " bold "\n c\r\n")
               (org-element-create 'paragraph nil "\tsecond\n")))
         (before (substring-no-properties value))
         (result (org-texmacs--document-lower ast)))
    ;; State crosses Org object boundaries, but not paragraph boundaries.
    ;; Empty text slots remain rather than shifting island child indices.
    (should (equal (org-texmacs-document-body result)
                   '(document (concat "a " (strong "b ") "" "c ")
                              (concat "second "))))
    (should (equal before (substring-no-properties value)))
    (should (equal (org-element-property :post-blank bold) 2))))

(ert-deftest org-texmacs-document-basic-inline-source ()
  (with-temp-buffer
    (org-mode)
    (insert "* /Title/\nA /i/ _u_ +s+ ~code~ =literal=.\n")
    (let ((source (buffer-string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Ordinary inline started a worker"))))
        (should (equal (org-texmacs-document-body (org-texmacs-document))
                       '(document (section (em "Title"))
                                  (concat "A " (em "i") " " (underline "u") " "
                                          (strike-through "s") " "
                                          (verbatim "code") " " (verbatim "literal") ". ")))))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-nested-inline-and-cycles ()
  (let* ((italic (org-element-create 'italic nil "i"))
         (bold (org-element-create 'bold nil "b " italic))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil bold))))
    (should (equal (org-texmacs-document-body (org-texmacs--document-lower ast))
                   '(document (concat (strong (concat "b " (em "i")))))))
    (org-element-set-contents italic bold)
    (should-error (org-texmacs--document-lower ast) :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-markup-single-body ()
  (dolist (mapping '((bold . strong) (italic . em) (underline . underline)
                     (strike-through . strike-through)))
    (dolist (parts '(nil ("one") ("one" " two")))
      (let* ((node (apply #'org-element-create (car mapping) nil parts))
             (ast (org-element-create 'org-data nil
                                      (org-element-create 'paragraph nil node)))
             (body (org-texmacs-document-body (org-texmacs--document-lower ast)))
             (markup (cadr (cadr body))))
        (should (= (length markup) 2))
        (should (equal markup
                       (list (cdr mapping)
                             (cond ((null parts) "")
                                   ((null (cdr parts)) "one")
                                   (t '(concat "one" " two"))))))))))

(ert-deftest org-texmacs-document-nested-markup-source-and-native ()
  (org-texmacs-test--with-worker
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (dolist (case '(("*a /i/ z*\n" strong em "i")
                          ("/a *b* z/\n" em strong "b")
                          ("_a *b* z_\n" underline strong "b")
                          ("+a *b* z+\n" strike-through strong "b")))
            (with-temp-buffer
              (org-mode)
              (insert (car case))
              (let* ((source (buffer-string))
                     (expected
                      (list 'document
                            (list 'concat
                                  (list (nth 1 case)
                                        (list 'concat "a "
                                              (list (nth 2 case) (nth 3 case)) " " "z"))
                                  " ")))
                     (document (org-texmacs-document)))
                (should (equal (org-texmacs-document-body document) expected))
                (org-texmacs-session-set-document session document)
                (should (equal (org-texmacs--session-read session)
                               (org-texmacs-test--native-hex expected)))
                (should (equal source (buffer-string))))))
        (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-document-literal-inline-semantics ()
  (dolist (type '(code verbatim))
    (let* ((value (copy-sequence "*not bold*\t (math \"x\")\n<alpha> ¯˙"))
           (node (org-element-create type (list :value value)))
           (ast (org-element-create 'org-data nil
                                    (org-element-create 'paragraph nil node)))
           (result (org-texmacs--document-lower ast)))
      (should (equal (org-texmacs-document-body result)
                     '(document (concat (verbatim "*not bold* (math \"x\") <alpha> ¯˙")))))
      (should-not (org-texmacs-document-stm-paths result))
      (should (equal value "*not bold*\t (math \"x\")\n<alpha> ¯˙"))
      (org-element-set-contents node "unexpected")
      (should-error (org-texmacs--document-lower ast) :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-line-break-contexts ()
  (with-temp-buffer
    (org-mode)
    (insert "* Title\nA\\\\\nB\n")
    (should (equal (org-texmacs-document-body (org-texmacs-document))
                   '(document (section "Title") (concat "A" (next-line) "B ")))))
  (let* ((break (org-element-create 'line-break nil))
         (italic (org-element-create 'italic nil "title" break))
         (headline (org-element-create 'headline
                                       (list :level 1 :raw-value "title" :title (list italic))))
         (ast (org-element-create 'org-data nil headline)))
    (should-error (org-texmacs--document-lower ast) :type 'org-texmacs-document-error))
  (let* ((break (org-element-create 'line-break nil))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil "a " break " \tb"))))
    (should (equal (org-texmacs-document-body (org-texmacs--document-lower ast))
                   '(document (concat "a " (next-line) "b"))))))

(ert-deftest org-texmacs-document-whitespace-island-boundary ()
  (let* ((foreign (copy-sequence "island"))
         (native '(concat " \tSTM\n" (em "  untouched  ")))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil
                                                      "A\t " foreign "\n B C\n")))
         (result (org-texmacs--document-lower ast (list (cons foreign native)))))
    ;; NBSP is not ordinary prose whitespace; STM content is never inspected.
    (should (equal (org-texmacs-document-body result)
                   '(document (concat "A " (concat " \tSTM\n" (em "  untouched  ")) " B C "))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 1))))
    (should (equal native '(concat " \tSTM\n" (em "  untouched  "))))))

(ert-deftest org-texmacs-document-inline-native-whitespace ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "A\t¯˙\n/i/ _u_ +s+ ~x\t y~\n")
      (let* ((source (buffer-string))
             (document (org-texmacs-document))
             (session (org-texmacs-session-open)))
        (unwind-protect
            (progn
              (should (equal (org-texmacs-document-body document)
                             '(document (concat "A ¯˙ " (em "i") " " (underline "u") " "
                                                (strike-through "s") " " (verbatim "x y") " "))))
              (org-texmacs-session-set-document session document)
              ;; Native 09/0a here represent actual glyphs, not source whitespace.
              (should (equal (org-texmacs--session-read session)
                             '(document (concat "4120090a20" (em "69") "20" (underline "75") "20"
                                                (strike-through "73") "20" (verbatim "782079") "20"))))
              (should (equal source (buffer-string))))
          (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-uri-source-forms ()
  (dolist (type '("http" "https" "mailto" "ftp" "ftps"))
    (let ((uri (concat type ":" (if (equal type "mailto")
                                    "user@example.org" "//example.org/a%20b?q=x%26y&n=2"))))
      (dolist (source (list (concat "[[" uri "]]\n")
                            (concat "<" uri ">\n") (concat uri "\n")
                            (concat "[[" uri "][Label]]\n")))
        (with-temp-buffer
          (org-mode)
          (insert source)
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _) (ert-fail "URI parsing started worker"))))
            (should (equal (org-texmacs-document-body (org-texmacs-document))
                           (list 'document
                                 (list 'concat
                                       (list 'hlink
                                             (if (equal source (concat "[[" uri "][Label]]\n"))
                                                 "Label" uri)
                                             uri)
                                       " ")))))
          (should (equal source (buffer-string))))))))

(ert-deftest org-texmacs-document-uri-rich-description ()
  (with-temp-buffer
    (org-mode)
    (insert "* [[https://example.org][Title]]\n"
            "A [[ftps://example.org/中%20文?q=x%26y&z=2][*bold* /em/]]\t end\n")
    (should
     (equal (org-texmacs-document-body (org-texmacs-document))
            '(document (section (hlink "Title" "https://example.org"))
                       (concat "A " (hlink (concat (strong "bold") " " (em "em"))
                                          "ftps://example.org/中%20文?q=x%26y&z=2")
                               " " "end "))))))

(ert-deftest org-texmacs-document-uri-type-and-target-contract ()
  (let* ((path (copy-sequence "//example.org/<alpha>\t%20"))
         (link (org-element-create 'link
                                   (list :type "HTTPS" :path path :raw-link "file:wrong")))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil link)))
         (body (org-texmacs-document-body (org-texmacs--document-lower ast))))
    (should (equal body '(document (concat (hlink "HTTPS://example.org/<alpha>\t%20"
                                                "HTTPS://example.org/<alpha>\t%20")))))
    (should-not (eq path (nth 2 (nth 1 (nth 1 body)))))
    (should (equal path "//example.org/<alpha>\t%20")))
  (dolist (type '("file" "fuzzy" "id" "custom-id" "news" nil))
    (let ((ast (org-element-create
                'org-data nil
                (org-element-create 'paragraph nil
                                    (org-element-create 'link
                                                        (list :type type :path "x"
                                                              :raw-link "https://example.org"))))))
      (should-error (org-texmacs--document-lower ast) :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-uri-private-syntax-restoration ()
  (dolist (suffix '("" "\n- unsupported\n"))
    (with-temp-buffer
      (org-mode)
      (insert "[[ftps://example.org][(math \"hidden\")]]" suffix)
      (let* ((variables '(org-link-parameters org-link-types-re org-link-angle-re
                         org-link-plain-re org-link-bracket-re org-link-any-re
                         org-element--object-regexp org-element-paragraph-separate))
             (before (mapcar (lambda (var)
                               (org-texmacs--document-copy-link-setting (symbol-value var)))
                             variables))
             (source (buffer-string))
             (reset (symbol-function 'org-element-cache-reset)))
        (cl-letf (((symbol-function 'org-element-cache-reset)
                   (lambda (&rest args)
                     (when (eq (car args) 'all) (ert-fail "Global cache reset"))
                     (apply reset args)))
                  ((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) (ert-fail "Link description scanned as STM"))))
          (if (equal suffix "")
              (should (equal (org-texmacs-document-body (org-texmacs-document))
                             '(document (concat (hlink "(math \"hidden\")"
                                                      "ftps://example.org")))))
            (should-error (org-texmacs-document) :type 'org-texmacs-document-error)))
        (should (equal before (mapcar #'symbol-value variables)))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-document-uri-abbreviation-and-stale-settings ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-link-abbrev-alist-local '(("short" . "https://example.org/%s")))
    (insert "[[short:page][Page]]\n")
    (should (equal (org-texmacs-document-body (org-texmacs-document))
                   '(document (concat (hlink "Page" "https://example.org/page") " "))))
    (insert "(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (setq-local org-link-abbrev-alist-local nil)
                 '(math "x"))))
      (should-error (org-texmacs-document) :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-uri-native-islands ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "[[https://example.org/中%20文?q=a&b=%26][中文 <alpha>]] (math \"<alpha>\")\n")
      (let* ((document (org-texmacs-document))
             (session (org-texmacs-session-open)))
        (unwind-protect
            (progn
              (should (equal (org-texmacs-document-stm-paths document) '((0 2))))
              (org-texmacs-session-set-document session document)
              (should (equal
                       (org-texmacs--session-read session)
                       (org-texmacs-test--native-hex
                        '(document
                          (concat (hlink "<#4E2D><#6587> <less>alpha<gtr>"
                                         "https://example.org/<#4E2D>%20<#6587>?q=a&b=%26")
                                  " " (math "<alpha>") " "))))))
          (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-headline-levels ()
  (with-temp-buffer
    (org-mode)
    (insert "* First\nBody.\n*** Third\n")
    (should (equal (org-texmacs-document-body
                    (org-texmacs--document-lower (org-element-parse-buffer)))
                   '(document (section "First") (concat "Body. ")
                              (subsubsection "Third"))))))

(ert-deftest org-texmacs-document-island-paths-and-copies ()
  (let* ((ordinary (copy-sequence "<alpha>"))
         (foreign (copy-sequence "<alpha>"))
         (paragraph (org-element-create 'paragraph nil ordinary foreign "\n"))
         (block (org-element-create 'special-block '(:type "texmacs")))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'section nil paragraph block)))
         (stree (list 'document (copy-sequence "中")))
         (result (org-texmacs--document-lower
                  ast (list (cons foreign '(math "<alpha>")) (cons block stree))))
         (body (org-texmacs-document-body result)))
    (should (equal body '(document (concat "<alpha>" (math "<alpha>") " ")
                                  (document "中"))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 1) (1))))
    (should-not (eq ordinary (nth 1 (nth 1 body))))
    (should-not (text-properties-at 0 (nth 1 (nth 1 body))))
    (should-not (eq stree (nth 2 body)))
    (should-not (eq (cadr stree) (cadr (nth 2 body))))))

(ert-deftest org-texmacs-document-rich-title-without-worker ()
  (cl-letf (((symbol-function 'org-texmacs--worker-start)
             (lambda (&rest _) (ert-fail "Pure lowering started a worker")))
            ((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _) (ert-fail "Pure lowering requested parsing"))))
    (with-temp-buffer
      (org-mode)
      (insert "** A *bold* title\n")
      (let ((source (buffer-string)))
        (should (equal (org-texmacs-document-body
                        (org-texmacs--document-lower (org-element-parse-buffer)))
                       '(document (subsection
                                   (concat "A " (strong "bold") " " "title")))))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-document-rejects-invalid-whitespace ()
  (let* ((bold (org-element-create 'bold nil "bold"))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil bold))))
    (dolist (value '("\n" "text" 1))
      (should-error (org-texmacs--document-lower ast nil (list (cons bold value)))
                    :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-atomic-island ()
  (let* ((block (org-element-create 'special-block '(:type "texmacs")))
         (ast (org-element-create 'org-data nil block))
         (result (org-texmacs--document-lower ast (list (cons block "literal")))))
    (should (equal (org-texmacs-document-body result) '(document "literal")))
    (should (equal (org-texmacs-document-stm-paths result) '((0))))))

(ert-deftest org-texmacs-document-rejects-unsupported-source ()
  (dolist (source '("- item\n" "[[file:notes.org][link]]\n"
                    "[[./notes.org]]\n" "[[/tmp/notes.org]]\n"
                    "[[file:notes.org::heading]]\n" "[[file+emacs:notes.org]]\n"
                    "[[#target]]\n" "[[id:missing]]\n"
                    "[fn::note]\n" "| table |\n" "# comment\n"
                    "#+title: Title\n" "* COMMENT Task\n" "* Tagged :ARCHIVE:\n"
                    "**** Deep\n" "* \n" "#+name: named\nParagraph\n"
                    "#+attr_html: :class test\nParagraph\n"
                    "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (should-error (org-texmacs--document-lower (org-element-parse-buffer))
                    :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-rejects-invalid-mappings ()
  (let* ((leaf (copy-sequence "x"))
         (ast (org-element-create
               'org-data nil (org-element-create 'paragraph nil leaf))))
    (dolist (mapping (list (list (cons leaf '(math "x")) (cons leaf "x"))
                          (list (cons (copy-sequence "missing") "x"))
                          (list (cons leaf '(math 1)))
                          (list (cons leaf '(nil "x")))))
      (should-error (org-texmacs--document-lower ast mapping)
                    :type 'org-texmacs-document-error))
    (should-error (org-texmacs--document-lower ast nil (list (cons leaf " ")))
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-rejects-cycles ()
  (let* ((bold (org-element-create 'bold nil))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil bold))))
    (org-element-set-contents bold bold)
    (should-error (org-texmacs--document-lower ast)
                  :type 'org-texmacs-document-error))
  (let ((stree (list 'math "x")))
    (setcar (cdr stree) stree)
    (should-error (org-texmacs--document-copy-stree stree)
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-source-without-islands ()
  (with-temp-buffer
    (org-mode)
    (insert "* A *bold*\t title\nText *strong*\t  tail.\n")
    (goto-char 4)
    (let ((source (buffer-string)) (position (point))
          (tick (buffer-chars-modified-tick)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Unexpected worker request"))))
        (should (equal (org-texmacs-document-body (org-texmacs-document))
                       '(document
                         (section (concat "A " (strong "bold") " " "title"))
                         (concat "Text " (strong "strong") " " "tail. ")))))
      (should (= position (point)))
      (should (= tick (buffer-chars-modified-tick)))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-source-adjacent-islands ()
  (with-temp-buffer
    (org-mode)
    (insert "Before (math \"*fake* [[link]]\")(math \"α\") after.\n")
    (let ((requests nil))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (push (substring-no-properties source) requests)
                   (list 'math (if (= (length requests) 1) "*fake* [[link]]" "α")))))
        (let ((result (org-texmacs-document)))
          (should (equal (org-texmacs-document-body result)
                         '(document (concat "Before " (math "*fake* [[link]]")
                                            (math "α") " after. "))))
          (should (equal (org-texmacs-document-stm-paths result) '((0 1) (0 2))))
          (should (equal (nreverse requests)
                         '("(math \"*fake* [[link]]\")" "(math \"α\")"))))))))

(ert-deftest org-texmacs-document-source-preflight ()
  (dolist (source '("(math \"x\")\n\n- unsupported\n"
                    "#+include: missing.org\n"
                    "#+begin_src emacs-lisp\n(error \"never execute\")\n#+end_src\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Preflight started parsing"))))
        (should-error (org-texmacs-document) :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-source-rejects-context ()
  (with-temp-buffer
    (should-error (org-texmacs-document) :type 'org-texmacs-document-error)
    (org-mode)
    (insert "First\nSecond\n")
    (narrow-to-region 2 (point-max))
    (should-error (org-texmacs-document) :type 'org-texmacs-document-error)
    (should (= (point-min) 2))))

(ert-deftest org-texmacs-document-source-rechecks-snapshot ()
  (dolist (change '(text tags narrowing mode))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\") (math \"y\")\n")
      (let ((calls 0))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_source)
                     (setq calls (1+ calls))
                     (pcase change
                       ('text (insert "changed"))
                       ('tags (setq-local org-texmacs-fragment-tags nil))
                       ('narrowing (narrow-to-region 2 (point-max)))
                       ('mode (fundamental-mode)))
                     '(math "x"))))
          (should-error (org-texmacs-document) :type 'org-texmacs-error)
          (should (= calls 1)))))))

(ert-deftest org-texmacs-document-source-root-mismatch ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (_source) '(concat "x"))))
      (should-error (org-texmacs-document) :type 'org-texmacs-parse-error))))

(ert-deftest org-texmacs-document-source-disabled-fragments ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-texmacs-fragment-tags nil)
    (insert "(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) (ert-fail "Disabled fragment parsed"))))
      (let ((result (org-texmacs-document)))
        (should (equal (org-texmacs-document-body result)
                       '(document (concat "(math \"x\") "))))
        (should-not (org-texmacs-document-stm-paths result))))))

(ert-deftest org-texmacs-document-source-real-islands ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "* Title\nText (math (frac \"α\" \"2\")) end.\n\n"
              "#+begin_texmacs\n(document (math \"中\"))\n#+end_texmacs\n")
      (let ((source (buffer-string))
            (result (org-texmacs-document)))
        (should (equal (org-texmacs-document-body result)
                       '(document (section "Title")
                                  (concat "Text " (math (frac "α" "2")) " end. ")
                                  (document (math "中")))))
        (should (equal (org-texmacs-document-stm-paths result) '((1 1) (2))))
        (should (= org-texmacs--worker-request-id 2))
        (should (equal source (buffer-string)))
        (should (org-texmacs--worker-live-p))))))

(ert-deftest org-texmacs-document-source-real-error-and-repair ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "(math 1)\n")
      (should-error (org-texmacs-document) :type 'org-texmacs-parse-error)
      (let ((process org-texmacs--worker-process))
        (erase-buffer)
        (insert "#+begin_texmacs\n\"atomic\"\n#+end_texmacs\n")
        (let ((result (org-texmacs-document)))
          (should (equal (org-texmacs-document-body result) '(document "atomic")))
          (should (equal (org-texmacs-document-stm-paths result) '((0)))))
        (should (eq process org-texmacs--worker-process))))))

(ert-deftest org-texmacs-document-source-custom-todo-settings ()
  (dolist (keyword '("WAIT" "FINISHED"))
    (with-temp-buffer
      (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
        (org-mode))
      (insert "* " keyword " Task\n")
      ;; Establish that the fixture really has non-default TODO semantics.
      (should (equal (org-element-map (org-element-parse-buffer) 'headline
                       (lambda (node) (org-element-property :todo-keyword node)))
                     (list keyword)))
      (let ((source (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Plain headline started parsing"))))
          (let ((org-export-with-todo-keywords t))
            (should (equal (org-texmacs-document-body (org-texmacs-document))
                           (list 'document (list 'section
                                                (list 'concat (list 'strong keyword) " " "Task")))))))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-document-source-custom-level-settings ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-odd-levels-only t)
    (insert "*** Heading\n")
    (should (equal (org-texmacs-document-body (org-texmacs-document))
                   '(document (subsection "Heading"))))
    (erase-buffer)
    (insert "******* Deep\n")
    (should-error (org-texmacs-document) :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-source-custom-todo-plain-title ()
  (with-temp-buffer
    (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
      (org-mode))
    (insert "* TODO A *bold* title\n")
    (should (equal (org-texmacs-document-body (org-texmacs-document))
                   '(document (section (concat "TODO A " (strong "bold") " " "title")))))))

(ert-deftest org-texmacs-document-source-custom-priority-settings ()
  (with-temp-buffer
    (org-mode)
    ;; A numeric-only effective regexp leaves [#A] in the title itself.
    (setq-local org-priority-regexp "\\(\\[#\\([0-9]+\\)\\] ?\\)")
    (insert "* [#A] Task\n")
    (should (equal (org-texmacs-document-body (org-texmacs-document))
                   '(document (section "[#A] Task"))))
    (erase-buffer)
    (insert "* [#12] Task\n")
    (let ((org-export-with-priority t))
      (should (equal (org-texmacs-document-body (org-texmacs-document))
                     '(document (section (concat "[#12]" " " "Task"))))))))

(ert-deftest org-texmacs-document-heading-settings-parser-parity ()
  (with-temp-buffer
    (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
      (org-mode))
    (setq-local org-odd-levels-only t)
    (insert "* WAIT [#A] A *bold* title :tag:\n*** FINISHED Done\n")
    (cl-labels ((properties ()
                 (org-element-map (org-element-parse-buffer) 'headline
                   (lambda (node)
                     (mapcar (lambda (key) (org-element-property key node))
                             '(:level :todo-keyword :todo-type :priority :raw-value :tags))))))
      (let ((expected (properties))
            (settings (org-texmacs--document-heading-settings))
            (source (buffer-string)))
        (should (equal expected
                       '((1 "WAIT" todo 65 "A *bold* title" ("tag"))
                         (2 "FINISHED" done nil "Done" nil))))
        (with-temp-buffer
          (org-mode)
          (org-texmacs--document-use-heading-settings settings)
          (insert source)
          (should (equal (properties) expected)))))))

(ert-deftest org-texmacs-document-heading-settings-copy-isolation ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-todo-regexp (copy-sequence "\\(WAIT\\)"))
    (setq-local org-done-keywords (list (copy-sequence "FINISHED")))
    (setq-local org-priority-regexp (copy-sequence org-priority-regexp))
    (let* ((settings (org-texmacs--document-heading-settings))
           (expected (org-texmacs--document-heading-settings)))
      (aset org-todo-regexp 0 ?x)
      (aset (car org-done-keywords) 0 ?x)
      (aset org-priority-regexp 0 ?x)
      (should (equal settings expected))
      (with-temp-buffer
        (org-mode)
        (org-texmacs--document-use-heading-settings settings)
        (aset org-todo-regexp 0 ?y)
        (aset (car org-done-keywords) 0 ?y)
        (aset org-priority-regexp 0 ?y)
        (should (equal settings expected))))))

(ert-deftest org-texmacs-document-heading-settings-reject-malformed-values ()
  (dolist (setting '((org-todo-regexp . 1)
                     (org-done-keywords . "DONE")
                     (org-done-keywords . (1))
                     (org-done-keywords . ("DONE" . "rest"))
                     (org-priority-regexp . nil)))
    (with-temp-buffer
      (org-mode)
      (set (make-local-variable (car setting)) (cdr setting))
      (insert "Text\n")
      (should-error (org-texmacs-document) :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-source-rechecks-heading-settings ()
  (dolist (change '(regexp done done-in-place level priority))
    (with-temp-buffer
      (org-mode)
      (setq-local org-done-keywords (list (copy-sequence "DONE")))
      (insert "(math \"x\") (math \"y\")\n")
      (let ((calls 0))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_source)
                     (setq calls (1+ calls))
                     (pcase change
                       ('regexp
                        (setq-local org-todo-regexp (copy-sequence org-todo-regexp))
                        (aset org-todo-regexp 0 ?x))
                       ('done (setq-local org-done-keywords '("FINISHED")))
                       ('done-in-place
                        (aset (car org-done-keywords) 0 ?x))
                       ('priority
                        (setq-local org-priority-regexp (copy-sequence org-priority-regexp))
                        (aset org-priority-regexp 0 ?x))
                       ('level (setq-local org-odd-levels-only (not org-odd-levels-only))))
                     '(math "x"))))
          (let ((failure (should-error (org-texmacs-document)
                                       :type 'org-texmacs-document-error)))
            (should (equal (cadr failure) "Org heading settings changed during conversion")))
          (should (= calls 1)))))))

(ert-deftest org-texmacs-encoding-rejects-invalid-input-before-worker ()
  (cl-letf (((symbol-function 'org-texmacs--worker-start)
             (lambda () (ert-fail "Invalid input started worker"))))
    (should-error (org-texmacs--worker-encode-document nil)
                  :type 'org-texmacs-encoding-error)
    (dolist (paths '(((2)) ((-1)) ((0 0)) (("0")) ((0) (0)) (() (0))
                     ((0) (0 1)) ((0 . 1))))
      (should-error (org-texmacs--worker-encode-document
                     (org-texmacs--document-create :body '(document "x") :stm-paths paths))
                    :type 'org-texmacs-encoding-error))
    (should-error (org-texmacs--worker-encode-document
                   (org-texmacs--document-create :body '(document (raw-data "x"))))
                  :type 'org-texmacs-encoding-error)))

(ert-deftest org-texmacs-encoding-wire-is-data ()
  (cl-letf (((symbol-function 'org-texmacs--worker-call)
             (lambda (make-request operation)
               (should (eq operation 'encode))
               (should (equal (funcall make-request 7)
                              "(encode 7 (\"document\" (\"custom.tag*\" \"<alpha>\")) ((0)))\n"))
               'encoded)))
    (should (eq (org-texmacs--worker-encode-document
                 (org-texmacs--document-create
                  :body '(document (custom.tag* "<alpha>")) :stm-paths '((0))))
                'encoded))))

(ert-deftest org-texmacs-encoding-decode-contract ()
  (should (equal (org-texmacs--worker-decode
                  "(ok 1 (native-body (document \"e9\")))" 1 'encode)
                 '(document "e9")))
  (dolist (response '("(ok 2 (native-body (document \"00\")))"
                      "(ok 1 (document \"00\"))"
                      "(ok 1 (native-body (document \"f\")))"
                      "(ok 1 (native-body (document \"gg\")))"
                      "(ok 1 (native-body (document \"é\")))"
                      "(ok 1 (native-body (document \"00\"))) extra"))
    (should-error (org-texmacs--worker-decode response 1 'encode)
                  :type 'org-texmacs-worker-error))
  (should-error (org-texmacs--worker-decode "(encoding-error 1 \"invalid\")" 1 'encode)
                :type 'org-texmacs-encoding-error)
  (should-error (org-texmacs--worker-decode "(encoding-error 1 \"invalid\")" 1)
                :type 'org-texmacs-worker-error))

(defun org-texmacs-test--ascii-hex (text)
  "Represent expected ASCII native TEXT as lowercase hexadecimal bytes."
  (mapconcat (lambda (character) (format "%02x" character)) text ""))

(ert-deftest org-texmacs-encoding-real-source-semantics ()
  (org-texmacs-test--with-worker
    (dolist (case '(("<alpha>" "<less>alpha<gtr>" "<alpha>")
                    ("α" "<alpha>" "<alpha>")
                    ("<less>alpha<gtr>" "<less>less<gtr>alpha<less>gtr<gtr>"
                     "<less>alpha<gtr>")
                    ("中" "<#4E2D>" "<#4E2D>")
                    ("α <alpha>" "<alpha> <less>alpha<gtr>" "<alpha> <alpha>")
                    ("\"\\\n\t" "\"\\\n\t" "\"\\\n\t")))
      (let* ((source (car case))
             (input (org-texmacs--document-create
                     :body (list 'document source (list 'math source))
                     :stm-paths '((1))))
             (result (org-texmacs--worker-encode-document input)))
        (should (equal result
                       (list 'document (org-texmacs-test--ascii-hex (nth 1 case))
                             (list 'math (org-texmacs-test--ascii-hex (nth 2 case))))))
        (should (equal (org-texmacs-document-body input)
                       (list 'document source (list 'math source))))))
    ;; This character has a single Cork byte: do not return its UTF-8 bytes.
    (let ((result (org-texmacs--worker-encode-document
                   (org-texmacs--document-create :body '(document "é")))))
      (should (equal result '(document "e9"))))
    (should (org-texmacs--worker-live-p))))

(ert-deftest org-texmacs-encoding-real-errors-preserve-parser ()
  (org-texmacs-test--with-worker
    (org-texmacs--worker-request "(math \"α\")")
    (let ((process org-texmacs--worker-process))
      ;; Bypass local preflight to exercise the Scheme validation boundary.
      (dolist (payload '("(\"document\" \"x\") ((2))"
                         "(\"document\" (\"math\" \"x\")) ((0) (0 0))"
                         "(\"document\" (\"raw-data\" \"x\")) ()"))
        (should-error
         (org-texmacs--worker-call
          (lambda (id) (format "(encode %d %s)\n" id payload)) 'encode)
         :type 'org-texmacs-encoding-error))
      (should (equal (org-texmacs--worker-request "(math \"α <alpha>\")")
                     '(math "α <alpha>")))
      (should (eq process org-texmacs--worker-process)))))

(ert-deftest org-texmacs-session-invalid-and-stale-handles ()
  (let ((org-texmacs--worker-process nil)
        (stale (org-texmacs--session-create :key "1" :process 'old)))
    (cl-letf (((symbol-function 'org-texmacs--worker-start)
               (lambda () (ert-fail "Stale handle started worker"))))
      (should-error (org-texmacs-session-set-document stale nil)
                    :type 'org-texmacs-session-error)
      (should-error (org-texmacs-session-close nil) :type 'org-texmacs-session-error)
      (should-not (org-texmacs-session-close stale))
      (should-not (org-texmacs-session-close stale))
      (should (org-texmacs-session-closed stale)))))

(ert-deftest org-texmacs-session-response-contract ()
  (should (equal (org-texmacs--worker-decode "(ok 1 (session \"2\"))" 1 'session-open) "2"))
  (dolist (response '("(ok 1 (session \"0\"))" "(ok 1 (closed \"1\"))"
                      "(ok 1 (session 1))" "(ok 1 (session \"1\" \"2\"))"))
    (should-error (org-texmacs--worker-decode response 1 'session-open)
                  :type 'org-texmacs-worker-error))
  (should-error (org-texmacs--worker-decode "(session-error 1 \"invalid\")" 1 'session-set)
                :type 'org-texmacs-session-error)
  (should-error (org-texmacs--worker-decode "(session-fatal 1 \"cleanup\")" 1 'session-close)
                :type 'org-texmacs-worker-error))

(ert-deftest org-texmacs-session-real-lifecycle ()
  (org-texmacs-test--with-worker
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (progn
            (should (equal (org-texmacs--session-read session) '(document "")))
            (should-error (org-texmacs-session-open) :type 'org-texmacs-session-error)
            (should (org-texmacs--session-live-p session))
            (with-temp-buffer
              (org-mode)
              (insert "Text (math \"α <alpha>\")\n")
              (let* ((document (org-texmacs-document))
                     (expected (org-texmacs--worker-encode-document document)))
                (should (eq (org-texmacs-session-set-document session document) session))
                (should (equal (org-texmacs--session-read session) expected))))
            (org-texmacs-session-set-document
             session (org-texmacs--document-create :body '(document "second")))
            (should (equal (org-texmacs--session-read session)
                           (list 'document (org-texmacs-test--ascii-hex "second")))))
        (org-texmacs-session-close session))
      (let ((requests org-texmacs--worker-request-id))
        (should-not (org-texmacs-session-close session))
        (should (= requests org-texmacs--worker-request-id)))
      (should-error (org-texmacs--session-read session) :type 'org-texmacs-session-error)
      (should (equal (org-texmacs--worker-request "(math \"x\")") '(math "x")))
      (let ((next (org-texmacs-session-open)))
        (should-not (equal (org-texmacs-session-key session) (org-texmacs-session-key next)))
        (org-texmacs-session-close next)))))

(ert-deftest org-texmacs-session-real-encoding-error-preserves-body ()
  (org-texmacs-test--with-worker
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (progn
            (org-texmacs-session-set-document
             session (org-texmacs--document-create :body '(document "original")))
            (let ((old (org-texmacs--session-read session)))
              (should-error (org-texmacs-session-set-document
                             session (org-texmacs--document-create :body '(document (raw-data "x"))))
                            :type 'org-texmacs-encoding-error)
              ;; Bypass Elisp validation to cover the worker's pre-mutation path.
              (should-error (org-texmacs--session-command
                             session 'session-set "(\"document\" \"x\") ((9))")
                            :type 'org-texmacs-encoding-error)
              (should (org-texmacs--session-live-p session))
              (should (equal old (org-texmacs--session-read session)))))
        (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-session-real-restart-invalidates-handle ()
  (org-texmacs-test--with-worker
    (let ((old (org-texmacs-session-open)))
      (org-texmacs--worker-stop)
      (let ((new (org-texmacs-session-open)))
        (unwind-protect
            (progn
              ;; The server counter restarts; process identity must disambiguate.
              (should (equal (org-texmacs-session-key old) (org-texmacs-session-key new)))
              (should-error (org-texmacs-session-set-document
                             old (org-texmacs--document-create :body '(document "stale")))
                            :type 'org-texmacs-session-error)
              (org-texmacs-session-close old)
              (should (equal (org-texmacs--session-read new) '(document ""))))
          (org-texmacs-session-close new))))))

(ert-deftest org-texmacs-session-real-update-failure-discards-buffer ()
  (org-texmacs-test--with-worker
    (let ((script (expand-file-name "session-failure.scm" test-directory)))
      (with-temp-file script
        (insert (format "(load %s)\n" (org-texmacs--scheme-string org-texmacs--worker-scheme-file))
                "(define original-set-body buffer-set-body)\n"
                "(define set-count 0)\n"
                "(set! buffer-set-body (lambda (buf body)\n"
                "  (set! set-count (+ set-count 1))\n"
                "  (if (= set-count 2) (error \"Injected update failure\")\n"
                "      (original-set-body buf body))))\n"))
      (let* ((org-texmacs--worker-scheme-file script)
             (session (org-texmacs-session-open)))
        (should-error (org-texmacs-session-set-document
                       session (org-texmacs--document-create :body '(document "changed")))
                      :type 'org-texmacs-session-error)
        (should (org-texmacs-session-closed session))
        (should (org-texmacs--worker-live-p))
        (let ((next (org-texmacs-session-open)))
          (unwind-protect
              (progn
                (org-texmacs-session-set-document
                 next (org-texmacs--document-create :body '(document "recovered")))
                (should (equal (org-texmacs--session-read next)
                               (list 'document (org-texmacs-test--ascii-hex "recovered")))))
            (org-texmacs-session-close next)))))))

(ert-deftest org-texmacs-session-real-close-failure-stops-worker ()
  (org-texmacs-test--with-worker
    (let ((script (expand-file-name "session-close-failure.scm" test-directory)))
      (with-temp-file script
        (insert (format "(load %s)\n" (org-texmacs--scheme-string org-texmacs--worker-scheme-file))
                "(set! buffer-close (lambda (buf) (error \"Injected close failure\")))\n"))
      (let* ((org-texmacs--worker-scheme-file script)
             (session (org-texmacs-session-open)))
        (should-error (org-texmacs-session-close session) :type 'org-texmacs-worker-error)
        (should-not (org-texmacs--worker-live-p))
        (should-not (org-texmacs-session-close session))))))

(defun org-texmacs-test--native-hex (tree)
  "Represent independently specified native TREE with hex leaves.
Only serialize expected bytes; do not call the production encoder."
  (if (stringp tree)
      (org-texmacs-test--ascii-hex tree)
    (cons (car tree) (mapcar #'org-texmacs-test--native-hex (cdr tree)))))

(ert-deftest org-texmacs-document-real-chinese-end-to-end ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "* 中文标题\n\n普通的中文 *加粗* (math (frac \"一\" \"2\")).\n\n"
              "#+begin_texmacs\n(equation* (frac \"3\" \"4\"))\n#+end_texmacs\n\n"
              "** Second\n\nFinal paragraph.\n")
      (goto-char (point-min))
      (search-forward "#+begin_texmacs")
      (let* ((block (org-element-at-point))
             (source (buffer-string))
             (tick (buffer-chars-modified-tick))
             (position (point))
             (document (org-texmacs-document))
             (session (org-texmacs-session-open)))
        (unwind-protect
            (progn
              (should (equal (org-texmacs-document-body document)
                             '(document (section "中文标题")
                                        (concat "普通的中文 " (strong "加粗") " "
                                                (math (frac "一" "2")) ". ")
                                        (equation* (frac "3" "4"))
                                        (subsection "Second") (concat "Final paragraph. "))))
              (should (equal (org-texmacs-document-stm-paths document) '((1 3) (2))))
              (org-texmacs-session-set-document session document)
              (should (equal
                       (org-texmacs--session-read session)
                       (org-texmacs-test--native-hex
                        '(document (section "<#4E2D><#6587><#6807><#9898>")
                                   (concat "<#666E><#901A><#7684><#4E2D><#6587> "
                                           (strong "<#52A0><#7C97>") " "
                                           (math (frac "<#4E00>" "2")) ". ")
                                   (equation* (frac "3" "4"))
                                   (subsection "Second") (concat "Final paragraph. ")))))
              (should (equal source (buffer-string)))
              (should (= tick (buffer-chars-modified-tick)))
              (should (= position (point)))
              (should (eq (org-element-type block) 'special-block))
              (should (eq (org-element-type (org-element-at-point)) 'special-block)))
          (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-real-failure-repair-and-update ()
  (org-texmacs-test--with-worker
    (let ((session (org-texmacs-session-open))
          (process org-texmacs--worker-process))
      (unwind-protect
          (with-temp-buffer
            (org-mode)
            (insert "Original\n")
            (org-texmacs-session-set-document session (org-texmacs-document))
            (let ((old (org-texmacs--session-read session)))
              (dolist (case '(("* COMMENT Task\n" . org-texmacs-document-error)
                              ("(math 1)\n" . org-texmacs-parse-error)))
                (erase-buffer)
                (insert (car case))
                (should-error
                 (org-texmacs-session-set-document session (org-texmacs-document))
                 :type (cdr case))
                (should (equal old (org-texmacs--session-read session)))
                (should (eq process org-texmacs--worker-process))))
            (erase-buffer)
            (insert "(math \"<less>alpha<gtr> α\")\n")
            (let ((document (org-texmacs-document)))
              ;; Reusing the text result must not double-encode its leaves.
              (dotimes (_ 2)
                (org-texmacs-session-set-document session document)
                (should (equal (org-texmacs--session-read session)
                               (org-texmacs-test--native-hex
                                '(document (concat (math "<less>alpha<gtr> <alpha>") " ")))))))
            (should (eq process org-texmacs--worker-process)))
        (org-texmacs-session-close session))
      (should (equal (org-texmacs--worker-request "(frac \"1\" \"2\")") '(frac "1" "2"))))))

(defun org-texmacs-test--readme-example (name)
  "Evaluate the single named Emacs Lisp example NAME from the local README.
Only tests with explicit example names use this helper; do not run Babel."
  (let ((forms nil))
    (with-temp-buffer
      (insert-file-contents org-texmacs-test--readme)
      (org-mode)
      (org-element-map (org-element-parse-buffer) 'src-block
        (lambda (block)
          (when (equal (org-element-property :name block) name)
            (should (equal (org-element-property :language block) "emacs-lisp"))
            (let* ((source (org-element-property :value block))
                   (read-circle nil)
                   (form (read-from-string source)))
              (should (string-match-p "\\`[ \t\n]*\\'" (substring source (cdr form))))
              (push (car form) forms))))))
    (should (= (length forms) 1))
    (eval (car forms) t)))

(ert-deftest org-texmacs-document-readme-native-example ()
  (org-texmacs-test--with-worker
    (let* ((document (org-texmacs-test--readme-example "example-document"))
           (session (org-texmacs-session-open)))
      (unwind-protect
          (progn
            (should (equal (org-texmacs-document-body document)
                           '(document (section "中")
                                      (concat "Text " (strong "bold") " " "<alpha> "
                                              (math "α <alpha>") " end. ")
                                      (with "mode" "math" (frac "中" "2")))))
            (should (equal (org-texmacs-document-stm-paths document) '((1 4) (2))))
            (org-texmacs-session-set-document session document)
            (should (equal (org-texmacs--session-read session)
                           (org-texmacs-test--native-hex
                            '(document (section "<#4E2D>")
                                       (concat "Text " (strong "bold") " " "<less>alpha<gtr> "
                                               (math "<alpha> <alpha>") " end. ")
                                       (with "mode" "math" (frac "<#4E2D>" "2")))))))
        (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-session-readme-example ()
  (org-texmacs-test--with-worker
    (should (eq t (org-texmacs-test--readme-example "example-session")))
    (should (org-texmacs--worker-live-p))
    ;; The example must close its buffer, allowing another session to open.
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (should (equal (org-texmacs--session-read session) '(document "")))
        (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-document-real-custom-heading-settings ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
        (org-mode))
      (setq-local org-odd-levels-only t)
      (insert "*** TODO Task\n(math \"α\")\n")
      (let* ((settings (org-texmacs--document-heading-settings))
             (source (buffer-string))
             (document (org-texmacs-document))
             (session (org-texmacs-session-open)))
        (unwind-protect
            (progn
              (should (equal (org-texmacs-document-body document)
                             '(document (subsection "TODO Task") (concat (math "α") " "))))
              (should (equal (org-texmacs-document-stm-paths document) '((1 0))))
              (org-texmacs-session-set-document session document)
              (should (equal (org-texmacs--session-read session)
                             (org-texmacs-test--native-hex
                              '(document (subsection "TODO Task")
                                         (concat (math "<alpha>") " ")))))
              (should (equal source (buffer-string)))
              (should (equal settings (org-texmacs--document-heading-settings))))
          (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-headline-policy-combinations ()
  (dolist (todo '(nil t))
    (dolist (priority '(nil t))
      (dolist (tags '(nil t not-in-toc))
        (with-temp-buffer
          (org-mode)
          (insert "* TODO [#A] A *bold* title :one:two:\nBody\n")
          (let* ((org-export-with-todo-keywords todo)
                 (org-export-with-priority priority)
                 (org-export-with-tags tags)
                 (source (buffer-string))
                 (result (org-texmacs-document))
                 (parts (append (and todo '((strong "TODO") " "))
                                (and priority '("[#A]" " "))
                                '("A " (strong "bold") " " "title")
                                (and tags '(" " ":one:two:")))))
            (should (equal (org-texmacs-document-body result)
                           (list 'document (list 'section (cons 'concat parts))
                                 '(concat "Body "))))
            (should-not (org-texmacs-document-stm-paths result))
            (should (equal source (buffer-string)))))))))

(ert-deftest org-texmacs-headline-formatter-copies-and-preserves-parts ()
  (let* ((todo (copy-sequence "WAIT"))
         (plain (copy-sequence "Title"))
         (parts (list plain '(strong "bold") "\t " "end"))
         (tags (list (copy-sequence "one")))
         (result (org-texmacs-format-headline-default-function todo 'todo 12 parts tags nil)))
    (should (equal result '(concat (strong "WAIT") " " "[#12]" " "
                                   "Title" (strong "bold") "\t " "end" " " ":one:")))
    (should (equal result
                   (org-texmacs-format-headline-default-function todo 'done 12 parts tags nil)))
    (should (equal parts '("Title" (strong "bold") "\t " "end")))
    (aset todo 0 ?X)
    (aset plain 0 ?X)
    (aset (car tags) 0 ?X)
    (should (equal (cadr (cadr result)) "WAIT"))
    (should (equal (nth 5 result) "Title")))
  (let* ((text (copy-sequence "Title"))
         (result (org-texmacs-format-headline-default-function nil nil nil (list text) nil nil)))
    (should (equal result text))
    (should-not (eq result text))))

(ert-deftest org-texmacs-headline-custom-formatter-policy-and-result ()
  (with-temp-buffer
    (org-mode)
    (insert "*** TODO [#A] Title :tag:\n")
    (let* ((output (list 'strong (copy-sequence "custom")))
           (calls 0)
           (org-export-with-todo-keywords nil)
           (org-export-with-priority nil)
           (org-export-with-tags nil)
           (org-texmacs-format-headline-function
            (lambda (todo type priority parts tags info)
              (cl-incf calls)
              (should-not todo) (should-not type) (should-not priority) (should-not tags)
              (should (equal parts '("Title")))
              (should-not (plist-get info :with-tags))
              output))
           (result (org-texmacs-document)))
      (should (> calls 0))
      (should (equal (org-texmacs-document-body result)
                     '(document (subsubsection (strong "custom")))))
      (aset (cadr output) 0 ?X)
      (should (equal (org-texmacs-document-body result)
                     '(document (subsubsection (strong "custom"))))))))

(ert-deftest org-texmacs-headline-invalid-formatter-result ()
  (with-temp-buffer
    (org-mode)
    (insert "* Title\n")
    (dolist (value '(42 (strong 42) (nil "x") (strong . "x")))
      (let ((org-texmacs-format-headline-function (lambda (&rest _) value)))
        (should-error (org-texmacs-document) :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-headline-output-settings-snapshot ()
  (with-temp-buffer
    (org-mode)
    (insert "* TODO [#A] Title :tag:\n(math \"x\")\n")
    (let ((org-export-with-todo-keywords t)
          (org-export-with-priority t)
          (org-export-with-tags t)
          (org-texmacs-format-headline-function #'org-texmacs-format-headline-default-function))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_)
                   (setq org-export-with-todo-keywords nil
                         org-export-with-priority nil org-export-with-tags nil
                         org-texmacs-format-headline-function (lambda (&rest _) "changed"))
                   '(math "x"))))
        (should (equal (org-texmacs-document-body (org-texmacs-document))
                       '(document (section (concat (strong "TODO") " " "[#A]" " "
                                                    "Title" " " ":tag:"))
                                  (concat (math "x") " "))))
        (should (equal (cadr (org-texmacs-document-body (org-texmacs-document)))
                       '(section "changed")))))))

(ert-deftest org-texmacs-headline-explicit-tags-only ()
  (with-temp-buffer
    (org-mode)
    (insert "* Parent :parent:\n** Child :child:\n")
    (let ((org-export-with-tags t))
      (should (equal (org-texmacs-document-body (org-texmacs-document))
                     '(document (section (concat "Parent" " " ":parent:"))
                                (subsection (concat "Child" " " ":child:"))))))))

(ert-deftest org-texmacs-headline-no-file-export-options ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: todo:nil\n* TODO Title\n")
    (cl-letf (((symbol-function 'org-export-get-environment)
               (lambda (&rest _) (ert-fail "Collected export environment"))))
      (should-error (org-texmacs-document) :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-headline-native-metadata-literal ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (let ((org-todo-keywords '((sequence "<alpha>" "|" "FINISHED"))))
        (org-mode))
      (insert "* <alpha> [#12] 中 :tag:\n(math \"<alpha>\")\n")
      (let* ((org-export-with-todo-keywords t)
             (org-export-with-priority t)
             (org-export-with-tags t)
             (document (org-texmacs-document))
             (session (org-texmacs-session-open)))
        (unwind-protect
            (progn
              (should (equal (org-texmacs-document-stm-paths document) '((1 0))))
              (org-texmacs-session-set-document session document)
              (should (equal (org-texmacs--session-read session)
                             (org-texmacs-test--native-hex
                              '(document (section (concat (strong "<less>alpha<gtr>") " "
                                                           "[#12]" " " "<#4E2D>" " " ":tag:"))
                                         (concat (math "<alpha>") " "))))))
          (org-texmacs-session-close session))))))

;;; ert.el ends here
