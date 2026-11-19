;;; metadata.el --- Native document information -*- lexical-binding: t; -*-

;;; Code:

(ert-deftest
    org-texmacs-metadata-native-information-and-literal-initial
    ()
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (with-temp-buffer
       (org-mode)
       (insert org-texmacs-test--metadata-source)
       (let* ((org-texmacs-document-style (list style))
              (document
               (org-texmacs-document-from-buffer (current-buffer)))
              (session (org-texmacs-session-open))
              (expected
               '(document
                 (doc-data
                  (doc-title "TitleSentinel")
                  (doc-subtitle (em "SubtitleSentinel"))
                  (doc-author
                   (author-data
                    (author-name "AuthorSentinel")
                    (author-email "email@example.test")))
                  (doc-date "DateSentinel")
                  (doc-note "Created by: GeneratorSentinel"))
                 (abstract-data
                  (abstract (document (concat "FirstSummary "))))
                 (abstract-keywords "FirstKeywords")
                 (concat "MiddleSentinel ")
                 (abstract-data
                  (abstract (document (concat "SecondSummary "))))
                 (abstract-keywords "SecondKeywords")
                 (section* "BodyHeading")
                 (concat "BodySentinel "))))
         (unwind-protect
             (progn
               (org-texmacs-session-set-document session document)
               (should
                (equal
                 (org-texmacs--session-read session)
                 (org-texmacs-test--native-hex expected)))
               (let* ((state
                       (org-texmacs--session-read-document session))
                      (initial (cdr (assq 'initial (cdr state)))))
                 (should
                  (member
                   (list
                    'associate "global-subject"
                    (org-texmacs-test--ascii-hex
                     "HiddenSubject <less>alpha<gtr> & \"quoted\""))
                   initial))
                 (should
                  (member
                   (list
                    'associate
                    "language"
                    (org-texmacs-test--ascii-hex "english"))
                   initial)))
               ;; Malformed provenance cannot alter an existing native document.
               (should-error
                (org-texmacs-session-set-document
                 session
                 (org-texmacs--document-create
                  :body
                  '(document "Wrong")
                  :initial-literal-keys '("missing")))
                :type 'org-texmacs-encoding-error)
               (should
                (equal
                 (org-texmacs--session-read session)
                 (org-texmacs-test--native-hex expected)))
               (let ((bytes
                      (org-texmacs-document-serialize document)))
                 (should (string-match-p "global-subject" bytes))
                 (should
                  (string-match-p
                   (regexp-quote "\\<less\\>alpha\\<gtr\\>") bytes))))
           (org-texmacs-session-close session)))))))

(ert-deftest org-texmacs-metadata-native-email-only-and-empty-abstract
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+EMAIL: only@example.test\n#+OPTIONS: author:nil email:t toc:nil date:nil\n"
      "#+begin_abstract\n#+end_abstract\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open))
            (expected
             '(document
               (doc-data
                (doc-author
                 (author-data (author-email "only@example.test"))))
               (abstract-data (abstract (document ""))))))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-metadata-native-language-registry ()
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "language-registry.scm" test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(define original-initial org-texmacs-native-initial)\n"
        "(set! org-texmacs-native-initial (lambda (wire)\n"
        " (let ((entries (original-initial wire)))\n"
        "  (for-each (lambda (entry)\n"
        "   (if (and (equal? (car entry) \"language\")\n"
        "            (not (member (tree->stree (cdr entry)) supported-languages)))\n"
        "       (error \"Language absent from native registry\"))) entries)\n"
        "  entries)))\n"))
     (let ((org-texmacs--worker-scheme-file script))
       (dolist (code
                '("en"
                  "en-US"
                  "en-GB"
                  "zh"
                  "zh-CN"
                  "zh-TW"
                  "bg"
                  "hr"
                  "cs"
                  "da"
                  "nl"
                  "eo"
                  "fi"
                  "fr"
                  "de"
                  "el"
                  "hu"
                  "it"
                  "ja"
                  "ko"
                  "pl"
                  "pt"
                  "ro"
                  "ru"
                  "sk"
                  "sl"
                  "es"
                  "sv"
                  "uk"))
         (with-temp-buffer
           (org-mode)
           (insert "#+LANGUAGE: " code "\nBody\n")
           (should
            (org-texmacs--native-encode-document
             (org-texmacs-document-from-buffer
              (current-buffer))))))))))

;;; metadata.el ends here
