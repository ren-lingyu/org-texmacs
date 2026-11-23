;;; ert-native-serialization.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-texmacs-parse)
(require 'ox)
(require 'ox-texmacs)

(ert-deftest
    org-texmacs-serialization-native-roundtrip-and-session-independence
    ()
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "serialization-roundtrip.scm"
                            test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(define org-texmacs-test-serializer serialize-texmacs)\n"
        "(set! serialize-texmacs (lambda (file)\n"
        "  (let* ((bytes (org-texmacs-test-serializer file))\n"
        "         (readback (parse-texmacs bytes)))\n"
        "    (if (not (equal? (tree->stree file) (tree->stree readback)))\n"
        "        (error \"Native file roundtrip mismatch\")) bytes)))\n"))
     (let* ((org-texmacs--worker-scheme-file script)
            (document
             (org-texmacs--document-create
              :style
              '("article" "number-europe" "number-europe")
              :initial
              '(("par-first" . "2fn") ("custom" tuple "中" "<alpha>"))
              :resource-base "/tmp/org-serialization-source/"
              :body
              '(document
                "Café 中 <alpha>"
                (math "<alpha>")
                (hlink "File" "./file.org"))
              :stm-paths '((1))
              :file-paths '((2 1))))
            (before (copy-tree (org-texmacs-document-body document)))
            (bytes (org-texmacs-document-serialize document))
            (process org-texmacs--worker-process)
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should-not (multibyte-string-p bytes))
             (should (string-prefix-p "<TeXmacs|" bytes))
             (should
              (string-match-p
               (regexp-quote "/tmp/org-serialization-source/file.pdf")
               bytes))
             (should
              (string-match-p (regexp-quote "<\\initial>") bytes))
             (should
              (equal before (org-texmacs-document-body document)))
             (org-texmacs-session-set-document
              session
              (org-texmacs--document-create
               :body '(document "Session state")))
             (let ((state
                    (org-texmacs--session-read-document session)))
               (with-temp-buffer
                 (setq default-directory
                       "/tmp/different-save-destination/")
                 (should
                  (equal
                   bytes (org-texmacs-document-serialize document))))
               (should (eq process org-texmacs--worker-process))
               (should
                (equal
                 state (org-texmacs--session-read-document session))))
             (should (org-texmacs--session-live-p session)))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-serialization-owned-org-document ()
  (org-texmacs-test--with-worker
   (let
       ((document
         (with-temp-buffer
           (org-mode)
           (setq default-directory "/tmp/")
           (insert
            "#+OPTIONS: toc:nil\nSee [[t]] and [cite:@key]. Note[fn:n].\n\n"
            "#+NAME: t\n#+CAPTION: Caption 中\n| a | b |\n\n"
            "#+bibliography: refs.bib\n#+print_bibliography:\n\n"
            "[fn:n] *Body* [[./file.org][File]].\n")
           (org-texmacs-test--native-bib-document
            (org-texmacs-parse-buffer (current-buffer))
            "@book{key,title={Café},author={Ada Example},year=2026,publisher={Example}}"))))
     (let ((body (copy-tree (org-texmacs-document-body document)))
           (stm (copy-tree (org-texmacs-document-stm-paths document)))
           (files
            (copy-tree (org-texmacs-document-file-paths document)))
           (bytes (org-texmacs-document-serialize document)))
       (dolist (tag '("big-table" "footnote" "with-bib" "bib-list"))
         (should
          (or (string-match-p (regexp-quote (concat "<" tag)) bytes)
              (string-match-p
               (regexp-quote (concat "<\\" tag)) bytes))))
       (dolist (marker
                (list
                 (format
                  "<reference|%s>"
                  (cadar
                   (org-texmacs-test--caption-inline-footnote-nodes
                    (org-texmacs-document-body document) 'reference)))
                 "/tmp/file.pdf"))
         (should (string-match-p (regexp-quote marker) bytes)))
       (should (equal body (org-texmacs-document-body document)))
       (should (equal stm (org-texmacs-document-stm-paths document)))
       (should
        (equal files (org-texmacs-document-file-paths document)))))))

(ert-deftest org-texmacs-serialization-native-errors-preserve-worker
    ()
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "serialization-failure.scm"
                            test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(define org-texmacs-test-serializer serialize-texmacs)\n"
        "(define org-texmacs-test-first #t)\n"
        "(set! serialize-texmacs (lambda (file)\n"
        "  (if org-texmacs-test-first\n"
        "      (begin (set! org-texmacs-test-first #f) (error \"Injected serializer error\"))\n"
        "      (org-texmacs-test-serializer file))))\n"))
     (let* ((org-texmacs--worker-scheme-file script)
            (document
             (org-texmacs--document-create :body '(document "Text"))))
       (should-error
        (org-texmacs-document-serialize document)
        :type 'org-texmacs-serialization-error)
       (let ((process org-texmacs--worker-process))
         (should (org-texmacs--worker-live-p))
         (should-error
          (org-texmacs--native-call
           (lambda (id)
             (format
              "(serialize %d (\"generic\") () (\"document\" \"Text\") ((9)))\n"
              id))
           'serialize)
          :type 'org-texmacs-encoding-error)
         (should
          (string-prefix-p
           "<TeXmacs|" (org-texmacs-document-serialize document)))
         (let ((empty
                (org-texmacs-document-serialize
                 (org-texmacs--document-create :body '(document)))))
           (should (string-prefix-p "<TeXmacs|" empty))
           (should-not
            (string-match-p (regexp-quote "<\\initial>") empty)))
         (should (eq process org-texmacs--worker-process)))))))

(ert-deftest
    org-texmacs-serialization-save-native-bytes-and-caller-isolation
    ()
  (org-texmacs-test--with-worker
   (let* ((file (expand-file-name "中 file <alpha>.tm" test-directory))
          (document
           (org-texmacs--document-create
            :body
            '(document "Café 中 <alpha>" (hlink "File" "./file.org"))
            :resource-base "/tmp/org-save-source/"
            :file-paths '((1 1))))
          (bytes (org-texmacs-document-serialize document))
          (process org-texmacs--worker-process))
     (with-temp-buffer
       (insert "Unrelated caller")
       (goto-char 4)
       (set-mark 6)
       (narrow-to-region 2 9)
       (setq buffer-file-name
             (expand-file-name "caller.org" test-directory))
       (let ((state
              (list
               (buffer-string)
               (point)
               (mark)
               (point-min)
               (point-max)
               (buffer-modified-p)
               buffer-file-name))
             (coding-system-for-write 'utf-16)
             (buffer-file-format '(hostile-format))
             (write-region-annotate-functions
              (list
               (lambda (&rest _)
                 (ert-fail "Save used caller annotations"))))
             (write-region-post-annotation-function
              (lambda (&rest _)
                (ert-fail "Save used annotation callback")))
             (file-name-handler-alist
              (list
               (cons
                (regexp-quote file)
                (lambda (&rest _)
                  (ert-fail "Save used file handler"))))))
         (should
          (equal file (org-texmacs-document-save document file)))
         (should
          (equal
           state
           (list
            (buffer-string)
            (point)
            (mark)
            (point-min)
            (point-max)
            (buffer-modified-p)
            buffer-file-name)))))
     (with-temp-buffer
       (set-buffer-multibyte nil)
       (insert-file-contents-literally file)
       (should (equal bytes (buffer-string)))
       (should
        (string-match-p
         (regexp-quote
          "/tmp/org-save-source/file.pdf")
         (buffer-string))))
     (should-not (find-buffer-visiting file))
     (should (eq process org-texmacs--worker-process)))))

(ert-deftest org-texmacs-serialization-export-native-source-and-file
    ()
  (org-texmacs-test--with-worker
   (let ((destination (expand-file-name "destination" test-directory))
         (serialize (symbol-function 'org-texmacs-document-serialize))
         (calls 0)
         (prepared 0)
         (parsed 0)
         (export (symbol-function 'org-export-as)))
     (make-directory destination)
     (with-temp-buffer
       (org-mode)
       (setq default-directory
             (file-name-as-directory test-directory))
       (insert
        "#+OPTIONS: toc:nil\n#+TITLE: Export\nCafé 中 <alpha> [[./file.org][File]].\n"
        "$(math \"<alpha>\")$\n")
       (goto-char 4)
       (set-mark 6)
       (let ((state
              (list
               (buffer-string)
               (point)
               (mark)
               (buffer-modified-p)
               default-directory
               buffer-file-name))
             (org-export-before-processing-functions
              (list (lambda (&rest _) (cl-incf prepared))))
             (org-export-before-parsing-functions
              (list (lambda (&rest _) (cl-incf parsed)))))
         (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                    (lambda (document)
                      (cl-incf calls)
                      (funcall serialize document)))
                   ((symbol-function 'org-export-as)
                    (lambda (&rest args)
                      (should (eq (car args) 'texmacs))
                      (apply export args))))
           (let* ((source (current-buffer))
                  (bytes
                   (org-texmacs-export-texmacs-from-buffer source))
                  (file (expand-file-name "export.tm" destination)))
             (should-not (multibyte-string-p bytes))
             (should (= calls 1))
             (with-temp-buffer
               ;; Caller location cannot replace the explicit source's base.
               (setq default-directory
                     (file-name-as-directory destination))
               (should
                (equal
                 file
                 (org-texmacs-export-to-texmacs-file source file))))
             (should (= calls 2))
             (should (= prepared 2))
             (should (= parsed 2))
             (with-temp-buffer
               (set-buffer-multibyte nil)
               (insert-file-contents-literally file)
               (should (equal bytes (buffer-string)))
               (should
                (string-match-p
                 (regexp-quote
                  (expand-file-name "file.pdf" test-directory))
                 (buffer-string))))
             (should
              (equal
               state
               (list
                (buffer-string)
                (point)
                (mark)
                (buffer-modified-p)
                default-directory
                buffer-file-name))))))))))

(ert-deftest org-texmacs-serialization-export-buffer-native-and-owned
    ()
  (org-texmacs-test--with-worker
   (let ((occupied (generate-new-buffer "*Org TeXmacs Export*"))
         outputs)
     (unwind-protect
         (progn
           (with-current-buffer occupied
             (insert "Existing user view"))
           (with-temp-buffer
             (org-mode)
             (insert "Café 中 <alpha>.\n")
             (goto-char 4)
             (set-mark 6)
             (let ((source (current-buffer))
                   (state
                    (list
                     (buffer-string)
                     (point)
                     (mark)
                     (buffer-modified-p)))
                   (bytes
                    (org-texmacs-export-texmacs-from-buffer
                     (current-buffer)))
                   (special-mode-hook
                    (list
                     (lambda ()
                       (ert-fail "Export view ran mode hook"))))
                   (change-major-mode-hook
                    (list
                     (lambda ()
                       (ert-fail
                        "Export view ran mode-change hook"))))
                   (after-change-major-mode-hook
                    (list
                     (lambda ()
                       (ert-fail
                        "Export view ran mode-change callback")))))
               (cl-letf (((symbol-function 'display-buffer)
                          (lambda (&rest _)
                            (ert-fail
                             "Lisp export displayed a view"))))
                 (dotimes (_ 2)
                   (let ((output
                          (org-texmacs-export-to-buffer source)))
                     (push output outputs)
                     (should-not (eq output occupied))
                     (with-current-buffer output
                       (should (eq major-mode 'special-mode))
                       (should buffer-read-only)
                       (should-not (buffer-modified-p))
                       (should-not enable-multibyte-characters)
                       (should
                        (eq buffer-file-coding-system 'no-conversion))
                       (should-not buffer-file-name)
                       (should (equal bytes (buffer-string)))
                       (should-error
                        (insert "Changed")
                        :type 'buffer-read-only)))))
               (should-not (eq (car outputs) (cadr outputs)))
               (should
                (equal
                 state
                 (list
                  (buffer-string)
                  (point)
                  (mark)
                  (buffer-modified-p))))))
           (with-current-buffer occupied
             (should (equal (buffer-string) "Existing user view"))))
       (dolist (buffer (cons occupied outputs))
         (when (buffer-live-p buffer)
           (kill-buffer buffer)))))))

(ert-deftest org-texmacs-serialization-export-explicit-file-source ()
  (org-texmacs-test--with-worker
   (let ((source (generate-new-buffer " *Explicit source*"))
         (file (expand-file-name "chosen.tm" test-directory)))
     (unwind-protect
         (progn
           (with-current-buffer source
             (org-mode)
             (insert "Original source.\n"))
           (cl-letf (((symbol-function 'read-file-name)
                      (lambda (&rest _)
                        (ert-fail "Explicit file API prompted"))))
             (with-temp-buffer
               (setq default-directory "/different-caller-context/")
               (should
                (equal
                 (org-texmacs-export-to-texmacs-file
                  source file)
                 file))))
           (should (file-exists-p file))
           (with-current-buffer source
             (should (equal (buffer-string) "Original source.\n"))))
       (kill-buffer source)))))

(ert-deftest org-texmacs-file-link-policy-native-consumers ()
  (org-texmacs-test--with-worker
   (dolist (pdf '(nil t))
     (let* ((document
             (org-texmacs--document-create
              :body
              '(document
                (concat
                 (hlink "Article" "./article.org")
                 " "
                 (hlink "Native" "native.org")))
              :file-paths '((0 0 1))
              :stm-paths '((0 2))
              :resource-base "/captured/source/"
              :link-org-files-as-pdf pdf))
            (before (copy-tree (org-texmacs-document-body document)))
            (target
             (if pdf
                 "/captured/source/article.pdf"
               "/captured/source/article.org"))
            (org-texmacs-link-org-files-as-pdf (not pdf))
            (bytes (org-texmacs-document-serialize document))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should (string-match-p (regexp-quote target) bytes))
             (should
              (string-match-p "<hlink|Native|native.org>" bytes))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                (list
                 'document
                 (list
                  'concat
                  (list 'hlink "Article" target)
                  " "
                  '(hlink "Native" "native.org"))))))
             (should
              (equal before (org-texmacs-document-body document))))
         (org-texmacs-session-close session))))))

;;; ert-native-serialization.el ends here
