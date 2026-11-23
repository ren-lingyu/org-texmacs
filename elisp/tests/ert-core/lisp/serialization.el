;;; serialization.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-texmacs)

(defun org-texmacs-test--ascii-hex (text)
  "Represent expected ASCII native TEXT as lowercase hexadecimal bytes."
  (mapconcat (lambda (character) (format "%02x" character)) text ""))

(ert-deftest org-texmacs-serialization-preflight-and-protocol ()
  (let ((valid
         (org-texmacs--document-create :body '(document "Text"))))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (&rest _)
                 (ert-fail "Invalid serialization started worker"))))
      (dolist (document
               (list
                nil
                (org-texmacs--document-create :body '(concat "Text"))
                (org-texmacs--document-create
                 :body '(document (raw-data "bytes")))
                (org-texmacs--document-create
                 :body
                 '(document "Text")
                 :stm-paths '((9)))
                (org-texmacs--document-create
                 :body '(document (hlink "File" "./file"))
                 :file-paths '((0 1)))))
        (should-error
         (org-texmacs-document-serialize document)
         :type 'org-texmacs-encoding-error)))
    (let* ((bytes
            (concat
             (encode-coding-string
              "<TeXmacs|2.1.5>\n" 'us-ascii)
             (unibyte-string 233 0)))
           (hex (org-texmacs-test--ascii-hex bytes)))
      (should
       (equal
        bytes
        (org-texmacs--native-decode
         (prin1-to-string
          (list 'ok 1 (list 'serialized-document "2.1.5" hex)))
         1 'serialize)))
      (should-not
       (multibyte-string-p
        (org-texmacs--native-decode-datum
         (list 'ok 1 (list 'serialized-document "2.1.5" hex))
         'serialize))))
    (dolist (payload
             '((serialized-document "" "00")
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
          (should-error
           (org-texmacs-document-serialize valid)
           :type 'org-texmacs-worker-error)
          (should (= stops 1)))))
    (dolist (failure
             '((encoding-error . org-texmacs-encoding-error)
               (serialization-error
                . org-texmacs-serialization-error)))
      (cl-letf (((symbol-function 'org-texmacs--worker-call)
                 (lambda (_request)
                   (list (car failure) 1 "Rejected")))
                ((symbol-function 'org-texmacs--worker-stop)
                 (lambda ()
                   (ert-fail "Domain error stopped worker"))))
        (should-error
         (org-texmacs-document-serialize valid)
         :type (cdr failure))))))

(ert-deftest org-texmacs-serialization-save-preflight ()
  (org-texmacs-test--with-environment
   (let* ((existing (expand-file-name "existing.tm" test-directory))
          (symlink (expand-file-name "dangling.tm" test-directory))
          (document
           (org-texmacs--document-create :body '(document "Text"))))
     (with-temp-file existing
       (insert "Original"))
     (make-symbolic-link
      (expand-file-name "missing.tm" test-directory) symlink)
     (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                (lambda (&rest _)
                  (ert-fail
                   "Invalid destination reached serializer"))))
       (dolist (path
                (list
                 nil
                 "relative.tm"
                 "~/output.tm"
                 "/ssh:host:/tmp/output.tm"
                 (concat test-directory "/bad\0.tm")
                 (file-name-as-directory test-directory)))
         (should-error
          (org-texmacs-document-save document path)
          :type 'org-texmacs-error))
       (dolist (path (list existing symlink test-directory))
         (should-error
          (org-texmacs-document-save document path)
          :type 'file-already-exists))
       (should-error
        (org-texmacs-document-save
         document
         (expand-file-name "missing/output.tm" test-directory))
        :type 'file-missing))
     (with-temp-buffer
       (insert-file-contents-literally existing)
       (should (equal (buffer-string) "Original")))
     (should (file-symlink-p symlink)))))

(ert-deftest org-texmacs-serialization-save-copied-path-and-races ()
  (org-texmacs-test--with-environment
   (let* ((path (expand-file-name "copied.tm" test-directory))
          (expected (copy-sequence path))
          (bytes (encode-coding-string "<TeXmacs|2.1.5>\n" 'us-ascii))
          (document
           (org-texmacs--document-create :body '(document "Text"))))
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
       (let ((raced
              (expand-file-name (format "race-%s.tm" kind)
                                test-directory)))
         (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                    (lambda (_document)
                      (pcase kind
                        ('file
                         (with-temp-file raced
                           (insert "Competitor")))
                        ('directory (make-directory raced))
                        ('symlink
                         (make-symbolic-link expected raced)))
                      bytes)))
           (should-error
            (org-texmacs-document-save document raced)
            :type 'file-error))
         (pcase kind
           ('file
            (with-temp-buffer
              (insert-file-contents-literally raced)
              (should (equal (buffer-string) "Competitor"))))
           ('directory
            (should-not
             (directory-files
              raced
              nil directory-files-no-dot-files-regexp)))
           ('symlink
            (should (equal (file-symlink-p raced) expected)))))))))

(ert-deftest org-texmacs-serialization-save-error-boundaries ()
  (org-texmacs-test--with-environment
   (let ((file (expand-file-name "failed.tm" test-directory))
         (document
          (org-texmacs--document-create :body '(document "Text"))))
     (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                (lambda (_document)
                  (signal 'org-texmacs-serialization-error
                          '("Rejected")))))
       (should-error
        (org-texmacs-document-save document file)
        :type 'org-texmacs-serialization-error))
     (should-not (file-exists-p file))
     (should-error
      (org-texmacs-document-save nil file)
      :type 'org-texmacs-encoding-error)
     (should-not (file-exists-p file))
     (let ((write (symbol-function 'write-region)))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (_document)
                    (encode-coding-string
                     "Complete bytes" 'us-ascii)))
                 ((symbol-function 'write-region)
                  (lambda (_start
                           _end name append visit lockname mustbenew)
                    (funcall write
                             "Partial"
                             nil
                             name
                             append
                             visit
                             lockname
                             mustbenew)
                    (signal 'file-error
                            '("Injected write failure")))))
         (should-error
          (org-texmacs-document-save document file)
          :type 'file-error)))
     ;; Failed filesystem writes are not deleted speculatively by the caller.
     (with-temp-buffer
       (insert-file-contents-literally file)
       (should (equal (buffer-string) "Partial"))))))

(ert-deftest
    org-texmacs-serialization-export-source-waits-before-output
    ()
  (org-texmacs-test--with-environment
   (dolist (change
            '(text location heading links narrowing mode killed))
     (with-temp-buffer
       (org-mode)
       (insert "Text.\n")
       (let ((source (current-buffer))
             (save-bytes
              (symbol-function 'org-texmacs--native-save-bytes))
             (file
              (expand-file-name (format "%s.tm" change)
                                test-directory)))
         (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                    (lambda (document)
                      (should
                       (string-search
                        "Text."
                        (prin1-to-string
                         (org-texmacs-document-body document))))
                      (with-current-buffer source
                        (pcase change
                          ('text
                           (goto-char (point-max))
                           (insert "Changed"))
                          ('location
                           (setq default-directory
                                 "/different-source/"))
                          ('heading
                           (setq-local org-priority-regexp "Changed"))
                          ('links
                           (setq-local
                            org-link-abbrev-alist
                            '(("x" . "https://example.org"))))
                          ('narrowing (narrow-to-region 1 3))
                          ('mode (setq major-mode 'fundamental-mode))
                          ('killed (kill-buffer source))))
                      (encode-coding-string
                       "<TeXmacs|2.1.5>\n" 'us-ascii)))
                   ((symbol-function 'org-texmacs--native-save-bytes)
                    (lambda (&rest args)
                      (if (memq change '(heading links))
                          (apply save-bytes args)
                        (ert-fail
                         "Export wrote before source check")))))
           (if (memq change '(heading links))
               (should
                (equal
                 file
                 (org-texmacs-export-to-texmacs-file source file)))
             (should-error
              (org-texmacs-export-to-texmacs-file source file)
              :type 'org-texmacs-document-error)))
         (should
          (eq
           (and (file-exists-p file) t)
           (and (memq change '(heading links)) t))))))))

(ert-deftest
    org-texmacs-serialization-export-bibliography-migration-before-effects
    ()
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (insert
      "[cite:@key]\n#+bibliography: refs.bib\n#+print_bibliography:\n")
     (let
         ((sources
           (list
            (cons
             "refs.bib"
             (copy-sequence
              "@book{key,title={Title},author={Ada Example},year=2026,publisher={Example}}"))))
          (file (expand-file-name "bibliography.tm" test-directory)))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (_document)
                    (aset (cdar sources) 0 ?X)
                    (encode-coding-string
                     "<TeXmacs|2.1.5>\n" 'us-ascii)))
                 ((symbol-function 'org-texmacs--native-save-bytes)
                  (lambda (&rest _)
                    (ert-fail
                     "Export wrote stale dependency output"))))
         (should-error
          (org-texmacs-export-to-texmacs-file
           (current-buffer) file sources)
          :type 'org-texmacs-document-error))
       (should-not (file-exists-p file))
       (should-not (org-texmacs--worker-live-p))
       (should (string-prefix-p "@book" (cdar sources)))))))

(ert-deftest
    org-texmacs-serialization-export-destination-and-preflight
    ()
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (insert "Text.\n")
     (let* ((file
             (expand-file-name "copied-export.tm" test-directory))
            (expected (copy-sequence file))
            (calls 0))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (_document)
                    (cl-incf calls)
                    (aset file (1- (length file)) ?X)
                    (encode-coding-string
                     "<TeXmacs|2.1.5>\n" 'us-ascii))))
         (should
          (equal
           expected
           (org-texmacs-export-to-texmacs-file
            (current-buffer) file)))
         (should (= calls 1)))
       (should (file-exists-p expected))
       (should-not (file-exists-p file))
       (cl-letf (((symbol-function
                   'org-texmacs--document-prepare-source)
                  (lambda (&rest _)
                    (ert-fail
                     "Existing output reached preparation"))))
         (should-error
          (org-texmacs-export-to-texmacs-file
           (current-buffer) expected)
          :type 'file-already-exists))))
   (dolist (directive '("#+INCLUDE: missing.org\n"))
     (with-temp-buffer
       (org-mode)
       (insert directive "$(math \"x\")$\n")
       (let ((file
              (expand-file-name "unsupported.tm" test-directory)))
         (cl-letf (((symbol-function 'org-texmacs--worker-request)
                    (lambda (&rest _)
                      (ert-fail
                       "Unsupported export requested worker")))
                   ((symbol-function 'org-texmacs--native-save-bytes)
                    (lambda (&rest _)
                      (ert-fail "Unsupported export wrote output"))))
           (should-error
            (org-texmacs-export-to-texmacs-file (current-buffer) file)
            :type 'error))
         (should-not (file-exists-p file)))))))

(ert-deftest
    org-texmacs-serialization-export-buffer-initialization-and-failure
    ()
  (with-temp-buffer
    (org-mode)
    (let ((source (current-buffer))
          created
          (make-buffer (symbol-function 'generate-new-buffer)))
      (cl-letf (((symbol-function
                  'org-texmacs-export-texmacs-from-buffer)
                 (lambda (&rest _)
                   (signal 'org-texmacs-document-error
                           '("Source changed"))))
                ((symbol-function 'generate-new-buffer)
                 (lambda (&rest _)
                   (ert-fail "Failed source export created a view"))))
        (should-error
         (org-texmacs-export-to-buffer source)
         :type 'org-texmacs-document-error))
      (cl-letf (((symbol-function
                  'org-texmacs-export-texmacs-from-buffer)
                 (lambda (&rest _) (unibyte-string ?A)))
                ((symbol-function 'generate-new-buffer)
                 (lambda (name &rest args)
                   (setq created (apply make-buffer name args))))
                ((symbol-function 'set-buffer-multibyte)
                 (lambda (&rest _) (error "Initialization failure"))))
        (should-error (org-texmacs-export-to-buffer source))
        (should-not (buffer-live-p created))))))

(ert-deftest
    org-texmacs-serialization-export-explicit-command-boundary
    ()
  (dolist (function
           '(org-texmacs-export-to-buffer
             org-texmacs-export-to-texmacs-file
             org-texmacs-export-to-pdf-file
             org-texmacs-export-texmacs-from-buffer
             org-texmacs-export-pdf-from-buffer))
    (should-not (commandp function))
    (should-error (call-interactively function)))
  (with-temp-buffer
    (should-error
     (org-texmacs-export-to-buffer (current-buffer))
     :type 'org-texmacs-document-error)))

;;; serialization.el ends here
