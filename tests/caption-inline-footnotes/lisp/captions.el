;;; captions.el --- Caption tests with patched Org -*- lexical-binding: t; -*-

;;; Commentary:

;; The neighboring Nix check provides the test-only parser patch.

;;; Code:

(ert-deftest org-texmacs-caption-patched-loaded-libraries ()
  (should (equal (org-version) "9.8.10"))
  (let ((org (getenv "ORG_TEXMACS_TEST_PATCHED_ORG"))
        (package (getenv "ORG_TEXMACS_TEST_PATCHED_PACKAGE")))
    (should org)
    (should package)
    (dolist (function
             '(org-mode org-element-parse-buffer org-export-as))
      (should
       (string-prefix-p
        (file-name-as-directory org)
        (file-truename (symbol-file function 'defun)))))
    (should
     (string-prefix-p
      (file-name-as-directory package)
      (file-truename (locate-library "org-texmacs-document")))))
  (should
   (memq
    'footnote-reference
    (cdr (assq 'keyword org-element-object-restrictions)))))

(ert-deftest org-texmacs-caption-patched-statement-private-snapshot ()
  (dolist (syntax '("theorem" "statement example" "statement_proof"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+CAPTION: Title[fn::Note *bold*] [[file:note.pdf][File]]\n"
       "#+begin_"
       syntax
       "\nBody[fn::BodyNote]\n#+end_"
       (car (split-string syntax))
       "\n")
      (let ((source-buffer (current-buffer))
            (parser (symbol-function 'org-element-parse-buffer))
            private)
        (cl-letf (((symbol-function 'org-element-parse-buffer)
                   (lambda (&rest args)
                     (unless (eq (current-buffer) source-buffer)
                       (setq private t))
                     (apply parser args))))
          (let* ((input (org-texmacs-prepare-buffer source-buffer))
                 (document (org-texmacs-document input))
                 (body (org-texmacs-document-body document)))
            (should private)
            (should
             (= 2
                (length
                 (org-texmacs-test--caption-inline-footnote-nodes
                  body 'footnote))))
            (should
             (= 1
                (length
                 (org-texmacs-test--caption-inline-footnote-nodes
                  body 'dueto))))
            (should (string-match-p "Note" (prin1-to-string body)))
            (should (org-texmacs-document-file-paths document))
            (should
             (equal document (org-texmacs-document input)))))))))

(ert-deftest org-texmacs-caption-patched-parser ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+CAPTION: test[fn::test]\n| 1 | 1 | 1 |\n| 1 | 1 | 1 |\n")
    (let* ((ast (org-element-parse-buffer))
           (table (org-element-map ast 'table #'identity nil t))
           (caption (caar (org-element-property :caption table)))
           (note (cadr caption)))
      (should (equal (car caption) "test"))
      (should (eq (org-element-type note) 'footnote-reference))
      (should (eq (org-element-property :type note) 'inline))
      (should-not (org-element-property :label note))
      (should (equal (org-element-contents note) '("test")))
      (should (= (length (org-element-contents table)) 2))
      (should-not
       (org-element-map ast 'footnote-definition #'identity)))))

(ert-deftest org-texmacs-caption-patched-private-snapshot-export ()
  (org-texmacs-test--with-worker
   (dolist (kind '("plain" "figure" "figure*" "table" "table*"))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
        "#+CAPTION[Short[fn::ShortBody]]: Long[fn::LongBody *bold* (math \"literal\") [[file:caption.pdf][File]]]\n"
        "#+CAPTION: More[fn::MoreBody]\n")
       (unless (equal kind "plain")
         (insert "#+begin_" kind "\n"))
       (insert
        (if (string-prefix-p "figure" kind)
            "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"
          "| A |\n"))
       (unless (equal kind "plain")
         (insert "#+end_" kind "\n"))
       (insert
        "\nBody[fn::BodyNote] Named[fn:n] Again[fn:n].\n\n[fn:n] NamedBody.\n")
       (let ((source (buffer-string))
             (source-buffer (current-buffer))
             (parser (symbol-function 'org-element-parse-buffer))
             (worker (symbol-function 'org-texmacs--worker-request))
             private
             requests
             document
             input)
         (cl-letf (((symbol-function 'org-element-parse-buffer)
                    (lambda (&rest args)
                      (unless (eq (current-buffer) source-buffer)
                        (setq private t))
                      (apply parser args)))
                   ((symbol-function 'org-texmacs--worker-request)
                    (lambda (raw &rest args)
                      (push raw requests)
                      (apply worker raw args))))
           (setq
            input (org-texmacs-prepare-buffer (current-buffer))
            document (org-texmacs-document-from-buffer (current-buffer))))
         (should private)
         (should (equal source (buffer-string)))
         ;; Both formal source entry points use the private snapshot pipeline.
         (should (equal document (org-texmacs-document input)))
         (should (equal document (org-texmacs-document input)))
         (should
          (= (length requests)
             (if (string-prefix-p "figure" kind)
                 2
               0)))
         (let ((body (org-texmacs-document-body document)))
           (should
            (= 5
               (length
                (org-texmacs-test--caption-inline-footnote-nodes
                 body 'footnote))))
           (should
            (= (length
                (org-texmacs-test--caption-inline-footnote-nodes
                 body 'math))
               (if (string-prefix-p "figure" kind)
                   1
                 0)))
           (should-not
            (org-texmacs-test--caption-inline-footnote-nodes
             body 'note-ref))
           (should-not
            (org-texmacs-test--caption-inline-footnote-nodes
             body 'note-footnote))
           (dolist (token
                    '("LongBody"
                      "ShortBody"
                      "MoreBody"
                      "BodyNote"
                      "NamedBody"
                      "literal"))
             (should (string-match-p token (prin1-to-string body))))
           (should (org-texmacs-document-file-paths document))
           (let ((session (org-texmacs-session-open)))
             (unwind-protect
                 (progn
                   (org-texmacs-session-set-document session document)
                   (let*
                       ((expected (copy-tree body))
                        (file
                         (car
                          (org-texmacs-test--caption-inline-footnote-nodes
                           expected 'hlink))))
                     (should (equal (caddr file) "caption.pdf"))
                     (setcar
                      (cddr file)
                      (expand-file-name "caption.pdf" test-directory))
                     (should
                      (equal
                       (org-texmacs--session-read session)
                       (org-texmacs-test--native-hex expected)))))
               (org-texmacs-session-close session)))))))))

(ert-deftest org-texmacs-caption-patched-scoped-export ()
  (dolist (scope '(full subtree region narrow))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
       "* Kept\n#+CAPTION[Short[fn::Short]]: Long[fn::Long]\n"
       "#+begin_table\n| A |\n#+end_table\n"
       "* Hidden :noexport:\n#+CAPTION: Bad[fn::outer[fn::inner]]\n"
       "#+begin_table\n| Hidden |\n#+end_table\n")
      (goto-char (point-min))
      (search-forward "* Kept")
      (beginning-of-line)
      (let ((start (point))
            (end
             (save-excursion
               (outline-next-heading)
               (point))))
        (save-restriction
          (when (eq scope 'narrow)
            (narrow-to-region start end))
          (let ((document
                 (org-texmacs-document-from-buffer
                  (current-buffer)
                  nil
                  (and (eq scope 'subtree) start)
                  (and (eq scope 'region) (cons start end)))))
            (should
             (= 2
                (length
                 (org-texmacs-test--caption-inline-footnote-nodes
                  (org-texmacs-document-body document)
                  'footnote))))))))))

(ert-deftest org-texmacs-caption-patched-unsupported-notes ()
  (dolist (caption
           '("Long[fn:n]"
             "Long[fn:n:Named]"
             "Long[fn::outer[fn::inner]]"
             "Long[fn::Note [cite:@k]]"
             "[Short[fn::Note [cite:@k]]]: Long"
             "[Short[fn:n]]: Long"
             "[Short[fn:n:Named]]: Long"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+CAPTION"
       (if (string-prefix-p "[" caption)
           ""
         ": ")
       caption "\n| A |\n\n[fn:n] Definition.\n")
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

;;; captions.el ends here
