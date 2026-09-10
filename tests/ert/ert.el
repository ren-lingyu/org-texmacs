;;; ert.el --- Tests for org-texmacs -*- lexical-binding: t; -*-

;;; Commentary:

;; ERT tests for org-texmacs.

;;; Code:

(require 'ert)
(require 'org-texmacs)

(ert-deftest org-texmacs-test-package-loads ()
  (should (featurep 'org-texmacs)))

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

;;; ert.el ends here
