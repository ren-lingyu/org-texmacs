;;; session.el --- native session regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

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
  (should (equal (org-texmacs--native-decode
                  "(ok 1 (session \"2\"))" 1 'session-open)
                 "2"))
  (dolist (response '("(ok 1 (session \"0\"))" "(ok 1 (closed \"1\"))"
                      "(ok 1 (session 1))" "(ok 1 (session \"1\" \"2\"))"))
    (should-error (org-texmacs--native-decode response 1 'session-open)
                  :type 'org-texmacs-worker-error))
  (should-error (org-texmacs--native-decode
                 "(session-error 1 \"invalid\")" 1 'session-set)
                :type 'org-texmacs-session-error)
  (should-error (org-texmacs--native-decode
                 "(session-fatal 1 \"cleanup\")" 1 'session-close)
                :type 'org-texmacs-worker-error)
  (let ((response
         '(native-document
           (style "generic")
           (initial (associate "par-first" "32666e"))
           (body (document "00")))))
    (should
     (equal
      (org-texmacs--native-decode
       "(ok 1 (native-document (style \"generic\") (initial (associate \"par-first\" \"32666e\")) (body (document \"00\"))))"
       1 'session-read)
      response)))
  (dolist (response
           '("(ok 1 (native-body (document \"00\")))"
             "(ok 1 (native-document (style) (initial) (body (document \"00\"))))"
             "(ok 1 (native-document (style \"generic\") (initial (associate \"x\" \"0g\")) (body (document \"00\"))))"
             "(ok 1 (native-document (style \"generic\") (initial (associate \"x\" \"00\") (associate \"x\" \"00\")) (body (document \"00\"))))"))
    (should-error (org-texmacs--native-decode response 1 'session-read)
                  :type 'org-texmacs-worker-error)))

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
              (let* ((document (org-texmacs-document-from-buffer (current-buffer)))
                     (expected (org-texmacs--native-encode-document document)))
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

(ert-deftest org-texmacs-session-real-complete-document-state ()
  (org-texmacs-test--with-worker
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (progn
            (org-texmacs-session-set-document
             session
             (org-texmacs--document-create
              :style '("article" "number-europe" "number-europe")
              :initial '(("par-first" . "2fn")
                         ("custom" tuple "中" "<alpha>"))
              :body '(document "中 <alpha>")))
            (let* ((readback (org-texmacs--session-read-document session))
                   (style (cdr (assq 'style (cdr readback))))
                   (initial (cdr (assq 'initial (cdr readback)))))
              ;; TeXmacs normalizes duplicate and included style packages.
              (should (equal style '("article" "number-europe")))
              (should (= (length initial) 2))
              (should
               (equal (caddr (cl-find "par-first" initial
                                      :key #'cadr :test #'equal))
                      (org-texmacs-test--ascii-hex "2fn")))
              (should
               (equal (caddr (cl-find "custom" initial
                                      :key #'cadr :test #'equal))
                      (org-texmacs-test--native-hex
                       '(tuple "<#4E2D>" "<alpha>"))))
              (should
               (equal (org-texmacs--session-read session)
                      (org-texmacs-test--native-hex
                       '(document "<#4E2D> <less>alpha<gtr>")))))
            (org-texmacs-session-set-document
             session
             (org-texmacs--document-create
              :style '("generic") :initial '(("new" . "中"))
              :body '(document "second")))
            (let* ((readback (org-texmacs--session-read-document session))
                   (style (cdr (assq 'style (cdr readback))))
                   (initial (cdr (assq 'initial (cdr readback)))))
              (should (equal style '("generic")))
              (should (= (length initial) 1))
              (should-not (cl-find "par-first" initial :key #'cadr :test #'equal))
              (should-not (cl-find "custom" initial :key #'cadr :test #'equal))
              (should
               (equal (caddr (cl-find "new" initial :key #'cadr :test #'equal))
                      (org-texmacs-test--ascii-hex "<#4E2D>"))))
            (org-texmacs-session-set-document
             session (org-texmacs--document-create :body '(document "empty")))
            (let ((readback (org-texmacs--session-read-document session)))
              (should (equal (cdr (assq 'style (cdr readback))) '("generic")))
              (should-not (cdr (assq 'initial (cdr readback))))))
        (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-session-real-encoding-error-preserves-body ()
  (org-texmacs-test--with-worker
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (progn
            (org-texmacs-session-set-document
             session (org-texmacs--document-create :body '(document "original")))
            (let ((old (org-texmacs--session-read session)))
              (should-error
               (org-texmacs-session-set-document
                session
                (org-texmacs--document-create
                 :style nil :body '(document "invalid style")))
               :type 'org-texmacs-encoding-error)
              (should-error
               (org-texmacs-session-set-document
                session
                (org-texmacs--document-create
                 :initial '(("bad" raw-data "x"))
                 :body '(document "invalid initial")))
               :type 'org-texmacs-encoding-error)
              (should-error (org-texmacs-session-set-document
                             session (org-texmacs--document-create :body '(document (raw-data "x"))))
                            :type 'org-texmacs-encoding-error)
              ;; Bypass Elisp validation to cover the worker's pre-mutation path.
              (should-error (org-texmacs--session-command
                             session 'session-set
                             "(\"generic\") () (\"document\" \"x\") ((9))")
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

(ert-deftest org-texmacs-session-example ()
  (org-texmacs-test--with-worker
    (should (eq t (org-texmacs-test--example-session)))
    (should (org-texmacs--worker-live-p))
    ;; The example must close its buffer, allowing another session to open.
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (should (equal (org-texmacs--session-read session) '(document "")))
        (org-texmacs-session-close session)))))

;;; session.el ends here
