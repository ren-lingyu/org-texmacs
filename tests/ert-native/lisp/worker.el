;;; worker.el --- native worker regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

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
             (result (org-texmacs--native-encode-document input)))
        (should (equal result
                       (list 'document (org-texmacs-test--ascii-hex (nth 1 case))
                             (list 'math (org-texmacs-test--ascii-hex (nth 2 case))))))
        (should (equal (org-texmacs-document-body input)
                       (list 'document source (list 'math source))))))
    ;; This character has a single Cork byte: do not return its UTF-8 bytes.
    (let ((result (org-texmacs--native-encode-document
                   (org-texmacs--document-create :body '(document "é")))))
      (should (equal result '(document "e9"))))
    (should (org-texmacs--worker-live-p))))

(ert-deftest org-texmacs-encoding-real-errors-preserve-parser ()
  (org-texmacs-test--with-worker
    (org-texmacs--worker-request "(math \"α\")")
    (let ((process org-texmacs--worker-process))
      ;; Bypass local preflight to exercise the Scheme validation boundary.
      (dolist (payload '("(\"generic\") () (\"document\" \"x\") ((2))"
                         "(\"generic\") () (\"document\" (\"math\" \"x\")) ((0) (0 0))"
                         "(\"generic\") () (\"document\" (\"raw-data\" \"x\")) ()"
                         "() () (\"document\" \"x\") ()"
                         "(\"generic\") ((\"x\" (\"raw-data\" \"x\"))) (\"document\" \"x\") ()"))
        (should-error
         (org-texmacs--native-call
          (lambda (id) (format "(encode %d %s)\n" id payload)) 'encode)
         :type 'org-texmacs-encoding-error))
      (should (equal (org-texmacs--worker-request "(math \"α <alpha>\")")
                     '(math "α <alpha>")))
      (should (eq process org-texmacs--worker-process)))))

(ert-deftest org-texmacs-test-prepare-buffer-independent-result ()
  (let (input expected)
    (with-temp-buffer
      (org-mode)
      (insert "* Heading\nText (math \"x\")\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_source) '(math "x"))))
        (setq input (org-texmacs-prepare-buffer (current-buffer))
              expected (org-texmacs-document-from-buffer (current-buffer)))))
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) (ert-fail "Prepared input must not parse again"))))
      (should (equal (org-texmacs-document input) expected)))))

(ert-deftest org-texmacs-test-setup-checks-configured-program ()
  (let ((org-texmacs-program "/org-texmacs-test/nonexistent"))
    (should-not (car (org-texmacs-check-setup)))))

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

(ert-deftest org-texmacs-test-worker-request-builder-error-preserves-process ()
  (org-texmacs-test--with-worker
    (let ((process (org-texmacs--worker-start)))
      (should-error
       (org-texmacs--worker-call
        (lambda (_id)
          (signal 'org-texmacs-session-error '("Stale session"))))
       :type 'org-texmacs-session-error)
      (should (eq process org-texmacs--worker-process))
      (should (org-texmacs--worker-live-p)))))

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

;;; worker.el ends here
