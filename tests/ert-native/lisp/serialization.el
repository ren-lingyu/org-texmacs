;;; serialization.el --- native serialization regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-serialization-preflight-and-protocol ()
  (let ((valid (org-texmacs--document-create :body '(document "Text"))))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (&rest _) (ert-fail "Invalid serialization started worker"))))
      (dolist (document
               (list nil (org-texmacs--document-create :body '(concat "Text"))
                     (org-texmacs--document-create :body '(document (raw-data "bytes")))
                     (org-texmacs--document-create :body '(document "Text") :stm-paths '((9)))
                     (org-texmacs--document-create :body '(document (hlink "File" "./file"))
                                                  :file-paths '((0 1)))))
        (should-error (org-texmacs-document-serialize document)
                      :type 'org-texmacs-encoding-error)))
    (let* ((bytes (concat (encode-coding-string "<TeXmacs|2.1.5>\n" 'us-ascii)
                          (unibyte-string 233 0)))
           (hex (org-texmacs-test--ascii-hex bytes)))
      (should (equal bytes
                     (org-texmacs--native-decode
                      (prin1-to-string (list 'ok 1 (list 'serialized-document "2.1.5" hex)))
                      1 'serialize)))
      (should-not (multibyte-string-p
                   (org-texmacs--native-decode-datum
                    (list 'ok 1 (list 'serialized-document "2.1.5" hex)) 'serialize))))
    (dolist (payload '((serialized-document "" "00")
                       (serialized-document "2.1.5" "0")
                       (serialized-document "2.1.5" "gg")
                       (serialized-document "2.1.5" "00")
                       (serialized-document "2.1.5" "")
                       (other "2.1.5" "00")))
      (let ((stops 0))
        (cl-letf (((symbol-function 'org-texmacs--worker-call)
                   (lambda (_request) (list 'ok 1 payload)))
                  ((symbol-function 'org-texmacs--worker-stop)
                   (lambda () (cl-incf stops))))
          (should-error (org-texmacs-document-serialize valid) :type 'org-texmacs-worker-error)
          (should (= stops 1)))))
    (dolist (failure '((encoding-error . org-texmacs-encoding-error)
                       (serialization-error . org-texmacs-serialization-error)))
      (cl-letf (((symbol-function 'org-texmacs--worker-call)
                 (lambda (_request) (list (car failure) 1 "Rejected")))
                ((symbol-function 'org-texmacs--worker-stop)
                 (lambda () (ert-fail "Domain error stopped worker"))))
        (should-error (org-texmacs-document-serialize valid) :type (cdr failure))))))

(ert-deftest org-texmacs-serialization-native-roundtrip-and-session-independence ()
  (org-texmacs-test--with-worker
    (let ((script (expand-file-name "serialization-roundtrip.scm" test-directory)))
      (with-temp-file script
        (insert (format "(load %s)\n" (org-texmacs--scheme-string org-texmacs--worker-scheme-file))
                "(define org-texmacs-test-serializer serialize-texmacs)\n"
                "(set! serialize-texmacs (lambda (file)\n"
                "  (let* ((bytes (org-texmacs-test-serializer file))\n"
                "         (readback (parse-texmacs bytes)))\n"
                "    (if (not (equal? (tree->stree file) (tree->stree readback)))\n"
                "        (error \"Native file roundtrip mismatch\")) bytes)))\n"))
      (let* ((org-texmacs--worker-scheme-file script)
             (document (org-texmacs--document-create
                        :style '("article" "number-europe" "number-europe")
                        :initial '(("par-first" . "2fn") ("custom" tuple "中" "<alpha>"))
                        :resource-base "/tmp/org-serialization-source/"
                        :body '(document "Café 中 <alpha>" (math "<alpha>")
                                         (hlink "File" "./file.org"))
                        :stm-paths '((1)) :file-paths '((2 1))))
             (before (copy-tree (org-texmacs-document-body document)))
             (bytes (org-texmacs-document-serialize document))
             (process org-texmacs--worker-process)
             (session (org-texmacs-session-open)))
        (unwind-protect
            (progn
              (should-not (multibyte-string-p bytes))
              (should (string-prefix-p "<TeXmacs|" bytes))
              (should (string-match-p (regexp-quote "/tmp/org-serialization-source/file.org") bytes))
              (should (string-match-p (regexp-quote "<\\initial>") bytes))
              (should (equal before (org-texmacs-document-body document)))
              (org-texmacs-session-set-document
               session (org-texmacs--document-create :body '(document "Session state")))
              (let ((state (org-texmacs--session-read-document session)))
                (with-temp-buffer
                  (setq default-directory "/tmp/different-save-destination/")
                  (should (equal bytes (org-texmacs-document-serialize document))))
                (should (eq process org-texmacs--worker-process))
                (should (equal state (org-texmacs--session-read-document session))))
              (should (org-texmacs--session-live-p session)))
          (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-serialization-owned-org-document ()
  (org-texmacs-test--with-worker
    (let ((document
           (with-temp-buffer
             (org-mode)
             (setq default-directory "/tmp/")
             (insert "#+OPTIONS: toc:nil\nSee [[t]] and [cite:@key]. Note[fn:n].\n\n"
                     "#+NAME: t\n#+CAPTION: Caption 中\n| a | b |\n\n"
                     "#+bibliography: refs.bib\n#+print_bibliography:\n\n"
                     "[fn:n] *Body* [[./file.org][File]].\n")
             (org-texmacs-document-from-buffer
              (current-buffer)
              '(("refs.bib" . "@book{key,title={Café},author={Ada Example},year=2026,publisher={Example}}"))))))
      (let ((body (copy-tree (org-texmacs-document-body document)))
            (stm (copy-tree (org-texmacs-document-stm-paths document)))
            (files (copy-tree (org-texmacs-document-file-paths document)))
            (bytes (org-texmacs-document-serialize document)))
        (dolist (tag '("big-table" "footnote" "with-bib" "bib-list"))
          (should (or (string-match-p (regexp-quote (concat "<" tag)) bytes)
                      (string-match-p (regexp-quote (concat "<\\" tag)) bytes))))
        (dolist (marker (list (format "<reference|%s>"
                                      (cadar (org-texmacs-test--caption-inline-footnote-nodes
                                              (org-texmacs-document-body document) 'reference))) "/tmp/file.org"))
          (should (string-match-p (regexp-quote marker) bytes)))
        (should (equal body (org-texmacs-document-body document)))
        (should (equal stm (org-texmacs-document-stm-paths document)))
        (should (equal files (org-texmacs-document-file-paths document)))))))

(ert-deftest org-texmacs-serialization-native-errors-preserve-worker ()
  (org-texmacs-test--with-worker
    (let ((script (expand-file-name "serialization-failure.scm" test-directory)))
      (with-temp-file script
        (insert (format "(load %s)\n" (org-texmacs--scheme-string org-texmacs--worker-scheme-file))
                "(define org-texmacs-test-serializer serialize-texmacs)\n"
                "(define org-texmacs-test-first #t)\n"
                "(set! serialize-texmacs (lambda (file)\n"
                "  (if org-texmacs-test-first\n"
                "      (begin (set! org-texmacs-test-first #f) (error \"Injected serializer error\"))\n"
                "      (org-texmacs-test-serializer file))))\n"))
      (let* ((org-texmacs--worker-scheme-file script)
             (document (org-texmacs--document-create :body '(document "Text"))))
        (should-error (org-texmacs-document-serialize document) :type 'org-texmacs-serialization-error)
        (let ((process org-texmacs--worker-process))
          (should (org-texmacs--worker-live-p))
          (should-error
           (org-texmacs--native-call
            (lambda (id) (format "(serialize %d (\"generic\") () (\"document\" \"Text\") ((9)))\n" id))
            'serialize)
           :type 'org-texmacs-encoding-error)
          (should (string-prefix-p "<TeXmacs|" (org-texmacs-document-serialize document)))
          (let ((empty (org-texmacs-document-serialize
                        (org-texmacs--document-create :body '(document)))))
            (should (string-prefix-p "<TeXmacs|" empty))
            (should-not (string-match-p (regexp-quote "<\\initial>") empty)))
          (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-serialization-save-preflight ()
  (org-texmacs-test--with-worker
    (let* ((existing (expand-file-name "existing.tm" test-directory))
           (symlink (expand-file-name "dangling.tm" test-directory))
           (document (org-texmacs--document-create :body '(document "Text"))))
      (with-temp-file existing (insert "Original"))
      (make-symbolic-link (expand-file-name "missing.tm" test-directory) symlink)
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (&rest _) (ert-fail "Invalid destination reached serializer"))))
        (dolist (path (list nil "relative.tm" "~/output.tm" "/ssh:host:/tmp/output.tm"
                           (concat test-directory "/bad\0.tm")
                           (file-name-as-directory test-directory)))
          (should-error (org-texmacs-document-save document path) :type 'org-texmacs-error))
        (dolist (path (list existing symlink test-directory))
          (should-error (org-texmacs-document-save document path) :type 'file-already-exists))
        (should-error
         (org-texmacs-document-save document (expand-file-name "missing/output.tm" test-directory))
         :type 'file-missing))
      (with-temp-buffer
        (insert-file-contents-literally existing)
        (should (equal (buffer-string) "Original")))
      (should (file-symlink-p symlink)))))

(ert-deftest org-texmacs-serialization-save-native-bytes-and-caller-isolation ()
  (org-texmacs-test--with-worker
    (let* ((file (expand-file-name "中 file <alpha>.tm" test-directory))
           (document (org-texmacs--document-create
                      :body '(document "Café 中 <alpha>" (hlink "File" "./file.org"))
                      :resource-base "/tmp/org-save-source/" :file-paths '((1 1))))
           (bytes (org-texmacs-document-serialize document))
           (process org-texmacs--worker-process))
      (with-temp-buffer
        (insert "Unrelated caller")
        (goto-char 4)
        (set-mark 6)
        (narrow-to-region 2 9)
        (setq buffer-file-name (expand-file-name "caller.org" test-directory))
        (let ((state (list (buffer-string) (point) (mark) (point-min) (point-max)
                           (buffer-modified-p) buffer-file-name))
              (coding-system-for-write 'utf-16)
              (buffer-file-format '(hostile-format))
              (write-region-annotate-functions
               (list (lambda (&rest _) (ert-fail "Save used caller annotations"))))
              (write-region-post-annotation-function
               (lambda (&rest _) (ert-fail "Save used annotation callback")))
              (file-name-handler-alist
               (list (cons (regexp-quote file)
                           (lambda (&rest _) (ert-fail "Save used file handler"))))))
          (should (equal file (org-texmacs-document-save document file)))
          (should (equal state
                         (list (buffer-string) (point) (mark) (point-min) (point-max)
                               (buffer-modified-p) buffer-file-name)))))
      (with-temp-buffer
        (set-buffer-multibyte nil)
        (insert-file-contents-literally file)
        (should (equal bytes (buffer-string)))
        (should (string-match-p (regexp-quote "/tmp/org-save-source/file.org") (buffer-string))))
      (should-not (find-buffer-visiting file))
      (should (eq process org-texmacs--worker-process)))))

(ert-deftest org-texmacs-serialization-save-copied-path-and-races ()
  (org-texmacs-test--with-worker
    (let* ((path (expand-file-name "copied.tm" test-directory))
           (expected (copy-sequence path))
           (bytes (encode-coding-string "<TeXmacs|2.1.5>\n" 'us-ascii))
           (document (org-texmacs--document-create :body '(document "Text"))))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document)
                   (aset path (1- (length path)) ?X)
                   bytes)))
        (let ((saved (org-texmacs-document-save document path)))
          (should (equal saved expected))
          (should-not (eq saved path))
          (should (file-exists-p saved))
          (should-not (file-exists-p path))))
      (dolist (kind '(file directory symlink))
        (let ((raced (expand-file-name (format "race-%s.tm" kind) test-directory)))
          (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                     (lambda (_document)
                       (pcase kind
                         ('file (with-temp-file raced (insert "Competitor")))
                         ('directory (make-directory raced))
                         ('symlink (make-symbolic-link expected raced)))
                       bytes)))
            (should-error (org-texmacs-document-save document raced) :type 'file-error))
          (pcase kind
            ('file (with-temp-buffer
                     (insert-file-contents-literally raced)
                     (should (equal (buffer-string) "Competitor"))))
            ('directory (should-not (directory-files raced nil directory-files-no-dot-files-regexp)))
            ('symlink (should (equal (file-symlink-p raced) expected)))))))))

(ert-deftest org-texmacs-serialization-save-error-boundaries ()
  (org-texmacs-test--with-worker
    (let ((file (expand-file-name "failed.tm" test-directory))
          (document (org-texmacs--document-create :body '(document "Text"))))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document) (signal 'org-texmacs-serialization-error '("Rejected")))))
        (should-error (org-texmacs-document-save document file)
                      :type 'org-texmacs-serialization-error))
      (should-not (file-exists-p file))
      (should-error (org-texmacs-document-save nil file) :type 'org-texmacs-encoding-error)
      (should-not (file-exists-p file))
      (let ((write (symbol-function 'write-region)))
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (_document) (encode-coding-string "Complete bytes" 'us-ascii)))
                  ((symbol-function 'write-region)
                   (lambda (_start _end name append visit lockname mustbenew)
                     (funcall write "Partial" nil name append visit lockname mustbenew)
                     (signal 'file-error '("Injected write failure")))))
          (should-error (org-texmacs-document-save document file) :type 'file-error)))
      ;; Failed filesystem writes are not deleted speculatively by the caller.
      (with-temp-buffer
        (insert-file-contents-literally file)
        (should (equal (buffer-string) "Partial"))))))

(ert-deftest org-texmacs-serialization-export-native-source-and-file ()
  (org-texmacs-test--with-worker
    (let ((destination (expand-file-name "destination" test-directory))
          (serialize (symbol-function 'org-texmacs-document-serialize))
          (calls 0))
      (make-directory destination)
      (with-temp-buffer
        (org-mode)
        (setq default-directory (file-name-as-directory test-directory))
        (insert "#+OPTIONS: toc:nil\n#+TITLE: Export\nCafé 中 <alpha> [[./file.org][File]].\n"
                "(math \"<alpha>\")\n")
        (goto-char 4)
        (set-mark 6)
        (let ((state (list (buffer-string) (point) (mark) (buffer-modified-p)
                           default-directory buffer-file-name))
              (org-export-before-processing-hook
               (list (lambda (&rest _) (ert-fail "Export ran generic processing hook"))))
              (org-export-before-parsing-hook
               (list (lambda (&rest _) (ert-fail "Export ran generic parsing hook")))))
          (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                     (lambda (document) (cl-incf calls) (funcall serialize document)))
                    ((symbol-function 'org-export-as)
                     (lambda (&rest _) (ert-fail "Export entered generic backend pipeline"))))
            (let* ((source (current-buffer))
                   (bytes (org-texmacs-export-texmacs-from-buffer source))
                   (file (expand-file-name "export.tm" destination)))
              (should-not (multibyte-string-p bytes))
              (should (= calls 1))
              (with-temp-buffer
                ;; Caller location cannot replace the explicit source's base.
                (setq default-directory (file-name-as-directory destination))
                (should (equal file (org-texmacs-export-to-texmacs-file source file))))
              (should (= calls 2))
              (with-temp-buffer
                (set-buffer-multibyte nil)
                (insert-file-contents-literally file)
                (should (equal bytes (buffer-string)))
                (should (string-match-p (regexp-quote (expand-file-name "file.org" test-directory))
                                        (buffer-string))))
              (should (equal state (list (buffer-string) (point) (mark) (buffer-modified-p)
                                         default-directory buffer-file-name))))))))))

(ert-deftest org-texmacs-serialization-export-source-waits-before-output ()
  (org-texmacs-test--with-worker
    (dolist (change '(text location heading links narrowing mode killed))
      (with-temp-buffer
        (org-mode)
        (insert "Text.\n")
        (let ((source (current-buffer))
              (file (expand-file-name (format "%s.tm" change) test-directory)))
          (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                     (lambda (_document)
                       (with-current-buffer source
                         (pcase change
                           ('text (goto-char (point-max)) (insert "Changed"))
                           ('location (setq default-directory "/different-source/"))
                           ('heading (setq-local org-priority-regexp "Changed"))
                           ('links (setq-local org-link-abbrev-alist-local '(("x" . "https://example.org"))))
                           ('narrowing (narrow-to-region 1 3))
                           ('mode (setq major-mode 'fundamental-mode))
                           ('killed (kill-buffer source))))
                       (encode-coding-string "<TeXmacs|2.1.5>\n" 'us-ascii)))
                    ((symbol-function 'org-texmacs--native-save-bytes)
                     (lambda (&rest _) (ert-fail "Export wrote before source check"))))
            (should-error (org-texmacs-export-to-texmacs-file source file) :type 'org-texmacs-document-error))
          (should-not (file-exists-p file)))))))

(ert-deftest org-texmacs-serialization-export-bibliography-wait ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "[cite:@key]\n#+bibliography: refs.bib\n#+print_bibliography:\n")
      (let ((sources (list (cons "refs.bib"
                                (copy-sequence "@book{key,title={Title},author={Ada Example},year=2026,publisher={Example}}"))))
            (file (expand-file-name "bibliography.tm" test-directory)))
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (_document)
                     (aset (cdar sources) 0 ?X)
                     (encode-coding-string "<TeXmacs|2.1.5>\n" 'us-ascii)))
                  ((symbol-function 'org-texmacs--native-save-bytes)
                   (lambda (&rest _) (ert-fail "Export wrote stale dependency output"))))
          (should-error (org-texmacs-export-to-texmacs-file (current-buffer) file sources)
                        :type 'org-texmacs-document-error))
        (should-not (file-exists-p file))
        (should (org-texmacs--worker-live-p))))))

(ert-deftest org-texmacs-serialization-export-destination-and-preflight ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "Text.\n")
      (let* ((file (expand-file-name "copied-export.tm" test-directory))
             (expected (copy-sequence file))
             (calls 0))
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (_document)
                     (cl-incf calls)
                     (aset file (1- (length file)) ?X)
                     (encode-coding-string "<TeXmacs|2.1.5>\n" 'us-ascii))))
          (should (equal expected (org-texmacs-export-to-texmacs-file (current-buffer) file)))
          (should (= calls 1)))
        (should (file-exists-p expected))
        (should-not (file-exists-p file))
        (cl-letf (((symbol-function 'org-texmacs--document-prepare-source)
                   (lambda (&rest _) (ert-fail "Existing output reached preparation"))))
          (should-error (org-texmacs-export-to-texmacs-file (current-buffer) expected)
                        :type 'file-already-exists))))
    (dolist (directive '("#+INCLUDE: missing.org\n" "#+SETUPFILE: missing.org\n"))
      (with-temp-buffer
        (org-mode)
        (insert directive "(math \"x\")\n")
        (let ((file (expand-file-name "unsupported.tm" test-directory)))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _) (ert-fail "Unsupported export requested worker")))
                    ((symbol-function 'org-texmacs--native-save-bytes)
                     (lambda (&rest _) (ert-fail "Unsupported export wrote output"))))
            (should-error (org-texmacs-export-to-texmacs-file (current-buffer) file)
                          :type 'org-texmacs-document-error))
          (should-not (file-exists-p file)))))))

(ert-deftest org-texmacs-serialization-export-buffer-native-and-owned ()
  (org-texmacs-test--with-worker
    (let ((occupied (generate-new-buffer "*Org TeXmacs Export*")) outputs)
      (unwind-protect
          (progn
            (with-current-buffer occupied (insert "Existing user view"))
            (with-temp-buffer
              (org-mode)
              (insert "Café 中 <alpha>.\n")
              (goto-char 4)
              (set-mark 6)
              (let ((source (current-buffer))
                    (state (list (buffer-string) (point) (mark) (buffer-modified-p)))
                    (bytes (org-texmacs-export-texmacs-from-buffer (current-buffer)))
                    (special-mode-hook (list (lambda () (ert-fail "Export view ran mode hook"))))
                    (change-major-mode-hook (list (lambda () (ert-fail "Export view ran mode-change hook"))))
                    (after-change-major-mode-hook (list (lambda () (ert-fail "Export view ran mode-change callback")))))
                (cl-letf (((symbol-function 'display-buffer)
                           (lambda (&rest _) (ert-fail "Lisp export displayed a view"))))
                  (dotimes (_ 2)
                    (let ((output (org-texmacs-export-to-buffer source)))
                      (push output outputs)
                      (should-not (eq output occupied))
                      (with-current-buffer output
                        (should (eq major-mode 'special-mode))
                        (should buffer-read-only)
                        (should-not (buffer-modified-p))
                        (should-not enable-multibyte-characters)
                        (should (eq buffer-file-coding-system 'no-conversion))
                        (should-not buffer-file-name)
                        (should (equal bytes (buffer-string)))
                        (should-error (insert "Changed") :type 'buffer-read-only)))))
                (should-not (eq (car outputs) (cadr outputs)))
                (should (equal state (list (buffer-string) (point) (mark) (buffer-modified-p))))))
            (with-current-buffer occupied (should (equal (buffer-string) "Existing user view"))))
        (dolist (buffer (cons occupied outputs))
          (when (buffer-live-p buffer) (kill-buffer buffer)))))))

(ert-deftest org-texmacs-serialization-export-buffer-initialization-and-failure ()
  (with-temp-buffer
    (org-mode)
    (let ((source (current-buffer)) created
          (make-buffer (symbol-function 'generate-new-buffer)))
      (cl-letf (((symbol-function 'org-texmacs-export-texmacs-from-buffer)
                 (lambda (&rest _) (signal 'org-texmacs-document-error '("Source changed"))))
                ((symbol-function 'generate-new-buffer)
                 (lambda (&rest _) (ert-fail "Failed source export created a view"))))
        (should-error (org-texmacs-export-to-buffer source) :type 'org-texmacs-document-error))
      (cl-letf (((symbol-function 'org-texmacs-export-texmacs-from-buffer)
                 (lambda (&rest _) (unibyte-string ?A)))
                ((symbol-function 'generate-new-buffer)
                 (lambda (name &rest args)
                   (setq created (apply make-buffer name args))))
                ((symbol-function 'set-buffer-multibyte)
                 (lambda (&rest _) (error "Initialization failure"))))
        (should-error (org-texmacs-export-to-buffer source))
        (should-not (buffer-live-p created))))))

(ert-deftest org-texmacs-serialization-export-explicit-file-source ()
  (org-texmacs-test--with-worker
    (let ((source (generate-new-buffer " *Explicit source*"))
          (file (expand-file-name "chosen.tm" test-directory)))
      (unwind-protect
          (progn
            (with-current-buffer source (org-mode) (insert "Original source.\n"))
            (cl-letf (((symbol-function 'read-file-name)
                       (lambda (&rest _) (ert-fail "Explicit file API prompted"))))
              (with-temp-buffer
                (setq default-directory "/different-caller-context/")
                (should (equal (org-texmacs-export-to-texmacs-file source file) file))))
            (should (file-exists-p file))
            (with-current-buffer source
              (should (equal (buffer-string) "Original source.\n"))))
        (kill-buffer source)))))

;;; serialization.el ends here
