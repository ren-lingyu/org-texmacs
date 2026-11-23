;;; ert-native-frontend.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'oc)
(require 'org)
(require 'ox)
(require 'ox-texmacs)

(ert-deftest org-texmacs-export-backend-keyword-naming-and-reexport ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (setq buffer-file-name
           (expand-file-name "source.org" test-directory))
     (insert "#+EXPORT_FILE_NAME: chosen.other\nOldBodySentinel.\n")
     (let ((file (expand-file-name "chosen.tm" test-directory)))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (ert-fail "Named output unexpectedly prompted"))))
         (should (equal file (org-texmacs-export-to-texmacs)))
         (erase-buffer)
         (insert
          "#+EXPORT_FILE_NAME: chosen.other\nNewBodySentinel.\n")
         (should (equal file (org-texmacs-export-to-texmacs))))
       (with-temp-buffer
         (insert-file-contents-literally file)
         (should (string-match-p "NewBodySentinel" (buffer-string)))
         (should-not
          (string-match-p
           "OldBodySentinel\\|EXPORT_FILE_NAME" (buffer-string))))))))

(ert-deftest
    org-texmacs-export-backend-standard-levels-and-source-size
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (insert "* Heading\nText\n") (setq-local org-odd-levels-only t)
    (let ((org-export-use-babel nil)
          (org-export-show-temporary-export-buffer nil))
      (kill-buffer (org-texmacs-export-as-texmacs))
      (setq-local org-odd-levels-only nil)
      (erase-buffer)
      (insert (make-string 262145 ?a))
      (let ((output (org-texmacs-export-as-texmacs)))
        (unwind-protect
            (should
             (> (with-current-buffer output
                  (buffer-size))
                262145))
          (kill-buffer output)))))))

(ert-deftest org-texmacs-export-backend-local-standard-preparation ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region "Included subtree sentinel\n" nil "part.org"
                  nil
                  'silent)
    (insert
     "* Heading\n:PROPERTIES:\n:CUSTOM_DATA: ignored\n:END:\n#+INCLUDE: part.org\n")
    (goto-char (point-min))
    (let ((org-export-use-babel nil)
          (org-export-show-temporary-export-buffer nil)
          (calls 0))
      (let ((org-export-before-processing-functions
             (list (lambda (_) (cl-incf calls)))))
        (let ((output (org-texmacs-export-as-texmacs nil t)))
          (unwind-protect
              (should
               (string-search
                "Included subtree sentinel"
                (with-current-buffer output
                  (buffer-string))))
            (kill-buffer output))))
      (should (= calls 1))))))

(ert-deftest
    org-texmacs-export-backend-standard-discovery-and-obsolete-flag
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (insert "Text\n")
    (let ((org-export-use-babel nil)
          (org-export-show-temporary-export-buffer nil)
          (calls 0)
          (collector
           (symbol-function 'org-cite-list-bibliography-files)))
      (cl-letf (((symbol-function 'org-cite-list-bibliography-files)
                 (lambda (&rest args)
                   (cl-incf calls)
                   (apply collector args)))
                ((symbol-function 'org-texmacs--bibliography-acquire)
                 (lambda (&rest _)
                   (ert-fail
                    "Standard frontend used independent discovery"))))
        (kill-buffer (org-texmacs-export-as-texmacs)))
      (should (> calls 0))
      (dolist (obsolete '(t invalid))
        (setq-local org-texmacs-export-discover-bibliography obsolete)
        (cl-letf (((symbol-function 'read-file-name)
                   (lambda (&rest _)
                     (ert-fail "Obsolete discovery prompted"))))
          (should-error
           (org-texmacs-export-to-texmacs)
           :type 'user-error)))))))

(ert-deftest
    org-texmacs-file-links-native-readback-and-preflight-preservation
    ()
  (org-texmacs-test--with-worker
   ;; Launch under the existing fixture directory, then exercise a source
   ;; resource base that need not exist or be read by conversion.
   (org-texmacs--worker-start)
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (setq default-directory "/tmp/org-resource/root/")
     (insert "[[file:子/é <alpha>%20.pdf][Resource]]\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open))
            (process org-texmacs--worker-process))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (let ((native (org-texmacs--session-read session)))
               (should
                (equal
                 native
                 (org-texmacs-test--native-hex
                  '(document
                    (concat
                     (hlink
                      "Resource"
                      "/tmp/org-resource/root/<#5B50>/é <less>alpha<gtr>%20.pdf")
                     " ")))))
               (erase-buffer)
               (insert "[[file:name#fragment.pdf][Rejected]]\n")
               (should-error
                (org-texmacs-session-set-document
                 session
                 (org-texmacs-document-from-buffer (current-buffer)))
                :type 'org-texmacs-encoding-error)
               (should (eq process org-texmacs--worker-process))
               (should
                (equal native (org-texmacs--session-read session)))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-narrowing-prompts-and-restriction-changes ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert "Prefix SelectedBodySentinel suffix.\n")
     (search-backward "SelectedBodySentinel")
     (let* ((begin (point))
            (end (+ (point) (length "SelectedBodySentinel")))
            (source (current-buffer)))
       (narrow-to-region begin end)
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (should (eq source (current-buffer)))
                    (should (= begin (point-min)))
                    (should (= end (point-max)))
                    "prompt.other")))
         (let ((file (org-texmacs-export-to-texmacs)))
           (should
            (equal
             file (expand-file-name "prompt.tm" test-directory)))
           (with-temp-buffer
             (set-buffer-multibyte nil)
             (insert-file-contents-literally file)
             (should
              (string-match-p "SelectedBodySentinel" (buffer-string)))
             (should-not
              (string-match-p "Prefix\\|suffix" (buffer-string))))))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (with-current-buffer source
                      (widen))
                    "changed.other"))
                 ((symbol-function 'org-texmacs--worker-request)
                  (lambda (&rest _)
                    (ert-fail "Restriction change started worker"))))
         (should-error
          (org-texmacs-export-to-texmacs)
          :type 'user-error)
         (should-not (buffer-narrowed-p))
         (should-not
          (file-exists-p
           (expand-file-name "changed.tm" test-directory))))
       (narrow-to-region begin end)
       (should-not (commandp 'org-texmacs-export-to-texmacs-file))))))

(ert-deftest
    org-texmacs-narrowing-native-waits-reject-changes-before-write
    ()
  (org-texmacs-test--with-worker
   (dolist (change '(widen shift hidden-text))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert "Prefix SelectedBodySentinel suffix.\n")
       (setq buffer-file-name
             (expand-file-name "source.org" test-directory))
       (search-backward "SelectedBodySentinel")
       (let* ((begin (point))
              (end (+ begin (length "SelectedBodySentinel")))
              (source (current-buffer))
              (file (expand-file-name "source.tm" test-directory))
              (serialize
               (symbol-function 'org-texmacs-document-serialize)))
         (write-region "PreviousOutput" nil file nil 'silent)
         (narrow-to-region begin end)
         (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                    (lambda (document)
                      (with-current-buffer source
                        (pcase change
                          ('widen (widen))
                          ('shift (narrow-to-region (1+ begin) end))
                          ('hidden-text
                           (save-restriction
                             (widen)
                             (goto-char 1)
                             (insert "X")))))
                      (funcall serialize document))))
           (should-error
            (org-texmacs-export-to-texmacs)
            :type 'org-texmacs-document-error))
         (with-temp-buffer
           (insert-file-contents-literally file)
           (should (equal "PreviousOutput" (buffer-string)))))))))

(ert-deftest
    org-texmacs-overrides-owned-across-prompt-and-native-waits
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert "BodySentinel.\n")
     (let* ((title (copy-sequence "ExternalTitleSentinel"))
            (tags (list (copy-sequence "skip")))
            (options
             (list :title title :exclude-tags tags :with-toc nil))
            (serialize
             (symbol-function 'org-texmacs-document-serialize)))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (aset title 0 ?X)
                    (aset (car tags) 0 ?X)
                    (plist-put options :with-title nil)
                    (funcall serialize document))))
         (let ((bytes
                (org-texmacs-export-texmacs-from-buffer
                 (current-buffer) nil nil nil options)))
           (should (string-match-p "ExternalTitleSentinel" bytes))))
       (setq options
             (list
              :title (copy-sequence "PromptTitleSentinel")
              :with-toc nil))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (aset (plist-get options :title) 0 ?X)
                    (expand-file-name "prompt.tm" test-directory))))
         (let ((file
                (org-texmacs-export-to-texmacs
                 nil nil nil nil options)))
           (with-temp-buffer
             (set-buffer-multibyte nil)
             (insert-file-contents-literally file)
             (should
              (string-match-p
               "PromptTitleSentinel" (buffer-string))))))))))

(ert-deftest org-texmacs-region-footnote-dependencies-and-islands ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+OPTIONS: toc:nil\n[fn:before] Note $(math \"x\")$.\n\n* Main\n"
      "Selected $(math \"y\")$ [fn:before] [fn:local] [fn:inline].\n\n"
      "[fn:local] LocalNoteSentinel.\n\n"
      "* Outside\nOutside[fn:inline:InlineNoteSentinel].\n"
      "#+begin_texmacs\n(math\n#+end_texmacs\n")
     (goto-char (point-min))
     (search-forward "Selected")
     (let ((begin (match-beginning 0))
           (request (symbol-function 'org-texmacs--stm-read))
           seen)
       (search-forward "* Outside")
       (let ((end (match-beginning 0)))
         (cl-letf (((symbol-function 'org-texmacs--stm-read)
                    (lambda (text &rest args)
                      (push text seen)
                      (apply request text args))))
           (let* ((document
                   (org-texmacs-document-from-buffer
                    (current-buffer) nil nil (cons begin end)))
                  (body (org-texmacs-document-body document)))
             (should
              (equal
               (nreverse seen) '("(math \"y\")" "(math \"x\")")))
             (should (= 3 (cl-count 'footnote (flatten-tree body))))
             (should
              (string-match-p
               "LocalNoteSentinel" (prin1-to-string body)))
             (should-not
              (string-match-p
               "InlineNoteSentinel" (prin1-to-string body)))
             (should-not
              (string-match-p "Outside" (prin1-to-string body)))
             (should
              (string-prefix-p
               "<TeXmacs|"
               (org-texmacs-document-serialize document))))))))))

(ert-deftest org-texmacs-region-frozen-selection-and-stale-source ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+OPTIONS: toc:nil\nPrefix SelectedBodySentinel suffix.\n")
     (search-backward "SelectedBodySentinel")
     (let* ((source (current-buffer))
            (region
             (cons
              (point) (+ (point) (length "SelectedBodySentinel"))))
            (serialize
             (symbol-function 'org-texmacs-document-serialize)))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (setcar region 1)
                    (with-current-buffer source
                      (goto-char (point-max))
                      (push-mark 1 t t))
                    (funcall serialize document))))
         (let ((bytes
                (org-texmacs-export-texmacs-from-buffer
                 source nil nil region)))
           (should (string-match-p "SelectedBodySentinel" bytes))
           (should-not (string-match-p "Prefix\\|suffix" bytes))))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (with-current-buffer source
                      (insert " changed"))
                    (funcall serialize document))))
         (should-error
          (org-texmacs-export-texmacs-from-buffer
           source nil nil (cons 1 (point-max)))
          :type 'org-texmacs-document-error))))))

(ert-deftest org-texmacs-subtree-external-footnotes-and-stm-order ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+OPTIONS: toc:nil\n[fn:before] Before $(math \"x\")$.\n\n"
      "* Chosen\nSelected $(math \"y\")$ [fn:before] [fn:inline].\n"
      "* Outside\nElse[fn:inline:Owned *inline* body.].\n"
      "#+begin_texmacs\n(math\n#+end_texmacs\n")
     (goto-char (point-min))
     (search-forward "* Chosen")
     (let ((request (symbol-function 'org-texmacs--stm-read))
           seen)
       (cl-letf (((symbol-function 'org-texmacs--stm-read)
                  (lambda (text &rest arguments)
                    (push text seen)
                    (apply request text arguments))))
         (let* ((document
                 (org-texmacs-document-from-buffer
                  (current-buffer) nil (point)))
                (body (org-texmacs-document-body document)))
           (should
            (equal (nreverse seen) '("(math \"y\")" "(math \"x\")")))
           (should (= 2 (cl-count 'footnote (flatten-tree body))))
           (should-not
            (string-match-p "Owned" (prin1-to-string body)))
           (should-not (string-match-p "Else" (prin1-to-string body)))
           (should
            (string-prefix-p
             "<TeXmacs|"
             (org-texmacs-document-serialize document)))))))))

(ert-deftest org-texmacs-subtree-selection-and-property-waits ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+OPTIONS: toc:nil\n* First\nFirstBodySentinel.\n* Second\nSecondBodySentinel.\n")
     (goto-char (point-min))
     (search-forward "FirstBodySentinel")
     (let ((source (current-buffer))
           (position (point))
           (serialize
            (symbol-function 'org-texmacs-document-serialize)))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (with-current-buffer source
                      (goto-char (point-max)))
                    (funcall serialize document))))
         (let ((bytes
                (org-texmacs-export-texmacs-from-buffer
                 source nil position)))
           (should (string-match-p "FirstBodySentinel" bytes))
           (should-not (string-match-p "SecondBodySentinel" bytes)))))
     (goto-char (point-min))
     (search-forward "FirstBodySentinel")
     (let ((org-use-property-inheritance
            (list (copy-sequence "EXPORT_AUTHOR"))))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (should
                     (string-search
                      "FirstBodySentinel"
                      (prin1-to-string
                       (org-texmacs-document-body document))))
                    (aset (car org-use-property-inheritance) 0 ?X)
                    (encode-coding-string
                     "<TeXmacs|2.1.5>" 'us-ascii))))
         (should
          (string-prefix-p
           "<TeXmacs|"
           (org-texmacs-export-texmacs-from-buffer
            (current-buffer) nil (point)))))))))

;;; ert-native-frontend.el ends here
