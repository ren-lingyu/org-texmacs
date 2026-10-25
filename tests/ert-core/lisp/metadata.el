;;; metadata.el --- Document information regressions -*- lexical-binding: t; -*-

;;; Code:

(defun org-texmacs-test--metadata-input (source &optional external subtree region)
  "Prepare SOURCE with explicit EXTERNAL, SUBTREE and REGION selections."
  (with-temp-buffer
    (org-mode)
    (let ((org-export-with-author nil) (org-export-with-date nil)
          (org-export-with-toc nil) (org-export-with-creator nil)
          (org-export-with-email nil))
      (insert source)
      (org-texmacs-prepare-buffer (current-buffer) nil subtree region external))))

(defun org-texmacs-test--metadata-nodes (tree tag)
  "Return TREE's nodes with TAG in depth-first order."
  (when (consp tree)
    (append (and (eq (car tree) tag) (list tree))
            (mapcan (lambda (child) (org-texmacs-test--metadata-nodes child tag))
                    (cdr tree)))))

(ert-deftest org-texmacs-metadata-repeat-and-plain-semantics ()
  (let* ((input (org-texmacs-test--metadata-input
                 (concat "#+TITLE: First\n#+TITLE: *Second*\n"
                         "#+SUBTITLE: /Sub/\n#+SUBTITLE: Tail\n"
                         "#+AUTHOR: One\n#+AUTHOR: Two\n"
                         "#+EMAIL: first@example.test\n#+EMAIL: last@example.test\n"
                         "#+LANGUAGE: en\n#+LANGUAGE: fr\n"
                         "#+DESCRIPTION: <alpha> & \"quoted\"\n#+DESCRIPTION: Second\n"
                         "#+CREATOR: FirstCreator\n#+CREATOR: SecondCreator\n"
                         "#+KEYWORDS: alpha, beta\n#+KEYWORDS: beta, gamma\nBody\n")))
         (info (org-texmacs-input-info input))
         (document (org-texmacs-document input)))
    (should (equal (plist-get info :email) "last@example.test"))
    (should (equal (plist-get info :creator) "FirstCreator"))
    (should (equal (plist-get info :keywords) "alpha, beta beta, gamma"))
    (should (equal (plist-get info :description) "<alpha> & \"quoted\"\nSecond"))
    (should (equal (cdr (assoc "language" (org-texmacs-document-initial document))) "french"))
    (should (equal (org-texmacs-test--metadata-nodes
                    (org-texmacs-document-body document) 'abstract-keywords)
                   '((abstract-keywords "alpha, beta") (abstract-keywords "beta, gamma"))))
    (should (org-texmacs-test--metadata-nodes
             (org-texmacs-document-body document) 'doc-subtitle))))

(ert-deftest org-texmacs-metadata-initial-precedence-and-clear ()
  (let ((org-texmacs-document-initial
         '(("language" . "german") ("global-subject" . "Default") ("par-first" . "2fn"))))
    (dolist (case '(("Body\n" nil "german" "Default")
                    ("#+LANGUAGE: fr\n#+DESCRIPTION: File\nBody\n"
                     (:language "en" :description "External") "french" "File")
                    ("Body\n" (:language nil :description nil) nil nil)))
      (let* ((input (org-texmacs-test--metadata-input (nth 0 case) (nth 1 case)))
             (document (org-texmacs-document input))
             (initial (org-texmacs-document-initial document)))
        (should (equal (cdr (assoc "language" initial)) (nth 2 case)))
        (should (equal (cdr (assoc "global-subject" initial)) (nth 3 case)))
        (should (equal (cdr (assoc "par-first" initial)) "2fn"))))))

(ert-deftest org-texmacs-metadata-owned-and-pure ()
  (let* ((source "#+SUBTITLE: *Owned*\n#+DESCRIPTION: <alpha>\nBody\n")
         (input (org-texmacs-test--metadata-input source))
         (before (prin1-to-string input)) first)
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) (ert-fail "Pure metadata conversion invoked worker")))
              ((symbol-function 'buffer-substring-no-properties)
               (lambda (&rest _) (ert-fail "Pure metadata conversion read source"))))
      (setq first (org-texmacs-document input))
      (should (equal first (org-texmacs-document input))))
    (should (equal before (prin1-to-string input)))
    (should (equal (cdr (assoc "global-subject" (org-texmacs-document-initial first)))
                   "<alpha>"))
    (should (member "global-subject" (org-texmacs-document-initial-literal-keys first)))
    (aset source 0 ?X)
    (should (equal first (org-texmacs-document input)))))

(ert-deftest org-texmacs-metadata-keywords-subtree-and-region ()
  (let* ((preamble "#+KEYWORDS: first, second\n#+KEYWORDS: second, third\n")
         (prefix (concat preamble "* Selected\n"))
         (begin (1+ (length preamble))))
    (dolist (override '(nil "Replacement" ""))
      (let* ((source (concat prefix
                             (when override (concat ":PROPERTIES:\n:EXPORT_KEYWORDS: " override
                                                    "\n:EXPORT_DESCRIPTION: Subtree\n:END:\n"))
                             "Body\n* Other\nOther\n"))
             (input (org-texmacs-test--metadata-input source nil begin))
             (document (org-texmacs-document input)))
        (should (equal (org-texmacs-test--metadata-nodes
                        (org-texmacs-document-body document) 'abstract-keywords)
                       (cond ((null override) '((abstract-keywords "first, second second, third")))
                             ((equal override "") nil)
                             (t '((abstract-keywords "Replacement"))))))
        (when override
          (should (equal (cdr (assoc "global-subject" (org-texmacs-document-initial document)))
                         "Subtree")))))
    (let* ((source (concat prefix "RegionBody\n"))
           (region (cons (1+ (length prefix)) (1+ (length source))))
           (document (org-texmacs-document
                      (org-texmacs-test--metadata-input source nil nil region))))
      (should (equal (org-texmacs-test--metadata-nodes
                      (org-texmacs-document-body document) 'abstract-keywords)
                     '((abstract-keywords "first, second second, third")))))))

(ert-deftest org-texmacs-metadata-external-validation-and-fallback ()
  (dolist (options '((:email 42) (:description ("bad")) (:keywords "one" :keywords "two")
                    (:with-email comment) (:with-creator comment)))
    (should-error (org-texmacs-test--metadata-input "Body\n" options)
                  :type 'org-texmacs-document-error))
  (let ((body (org-texmacs-document-body
               (org-texmacs-document
                (org-texmacs-test--metadata-input "Body\n" '(:keywords "External <alpha>"))))))
    (should (equal (car (org-texmacs-test--metadata-nodes body 'abstract-keywords))
                   '(abstract-keywords "External <alpha>")))))

(ert-deftest org-texmacs-metadata-language-table-and-errors ()
  ;; Independent expected identifiers: no acceptance based solely on persistence.
  (dolist (case '(("en-US" . "english") (" EN-gB " . "british")
                  ("zh-CN" . "chinese") ("zh-TW" . "taiwanese")
                  ("fr" . "french") ("sl" . "slovene") ("uk" . "ukrainian")))
    (let ((document (org-texmacs-document
                     (org-texmacs-test--metadata-input
                      (concat "#+LANGUAGE: " (car case) "\nBody\n")))))
      (should (equal (cdr (assoc "language" (org-texmacs-document-initial document)))
                     (cdr case)))))
  (dolist (language '("unknown" "american" "fr-UNKNOWN"))
    (should-error (org-texmacs-test--metadata-input
                   (concat "#+LANGUAGE: " language "\nBody\n"))
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-metadata-visibility-and-email-only ()
  (dolist (options '((:with-author nil :with-email t :with-creator t :with-title nil)
                    (:with-author nil :with-email nil :with-creator nil)))
    (let* ((body (org-texmacs-document-body
                  (org-texmacs-document
                   (org-texmacs-test--metadata-input
                    "#+SUBTITLE: Sub\n#+EMAIL: only@example.test\n#+CREATOR: Generator\nBody\n"
                    options)))))
      (should-not (org-texmacs-test--metadata-nodes body 'author-name))
      (should (eq (not (null (org-texmacs-test--metadata-nodes body 'author-email)))
                  (plist-get options :with-email)))
      (should (eq (not (null (org-texmacs-test--metadata-nodes body 'doc-note)))
                  (plist-get options :with-creator)))))
  (let ((body (org-texmacs-document-body
               (org-texmacs-document
                (org-texmacs-test--metadata-input "#+DESCRIPTION: Hidden\nBody\n")))))
    (should-not (org-texmacs-test--metadata-nodes body 'doc-data))))

(ert-deftest org-texmacs-metadata-ordered-abstracts ()
  (let* ((input (org-texmacs-test--metadata-input
                 (concat "#+begin_abstract\nFirst *summary*.\n#+end_abstract\n"
                         "#+KEYWORDS: FirstKeywords\nMiddle.\n"
                         "#+begin_abstract\nSecond summary.\n#+end_abstract\n"
                         "#+KEYWORDS: SecondKeywords\n#+begin_abstract\n#+end_abstract\n")))
         (body (org-texmacs-document-body (org-texmacs-document input))))
    (should (equal (mapcar #'car (cdr body))
                   '(abstract-data abstract-keywords concat abstract-data abstract-keywords abstract-data)))
    (should (= 3 (length (org-texmacs-test--metadata-nodes body 'abstract))))
    (should (org-texmacs-test--metadata-nodes body 'strong))))

(ert-deftest org-texmacs-metadata-abstract-error-boundaries ()
  (dolist (source '("#+begin_abstract parameter\nBody\n#+end_abstract\n"
                    "#+NAME: summary\n#+begin_abstract\nBody\n#+end_abstract\n"
                    "#+CAPTION: Caption\n#+begin_abstract\nBody\n#+end_abstract\n"))
    (should-error (org-texmacs-test--metadata-input source)
                  :type 'org-texmacs-document-error))
  (let ((org-texmacs--document-special-block-handlers
         '(("abstract" . ignore))))
    (should-error (org-texmacs-test--metadata-input "Body\n")
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-metadata-initial-provenance-preflight ()
  (dolist (keys '(("missing") ("subject" "subject") (42)))
    (should-error
     (org-texmacs--native-document-wire
      (org-texmacs--document-create :body '(document "Body")
                                    :initial '(("subject" . "Text"))
                                    :initial-literal-keys keys))
     :type 'org-texmacs-encoding-error)))

(ert-deftest org-texmacs-metadata-all-fields-priority ()
  (let* ((keys '(:title :subtitle :author :email :date :language
                 :keywords :description :creator))
         external lines properties)
    (dolist (key keys)
      (let* ((name (substring (symbol-name key) 1))
             (file (if (eq key :language) "fr" (concat "File" name)))
             (subtree (if (eq key :language) "de" (concat "Subtree" name))))
        (setq external (append external (list key (if (eq key :language) "en"
                                                   (concat "External" name)))))
        (push (format "#+%s: %s\n" (upcase name) file) lines)
        (push (format ":EXPORT_%s: %s\n" (upcase name) subtree) properties)))
    (let* ((preamble (apply #'concat (nreverse lines)))
           (source (concat preamble "* Selected\n:PROPERTIES:\n"
                           (apply #'concat (nreverse properties)) ":END:\nBody\n")))
      (dolist (selection '(file subtree))
        (let* ((input (org-texmacs-test--metadata-input
                       source external (and (eq selection 'subtree) (1+ (length preamble)))))
               (info (org-texmacs-input-info input)))
          (dolist (key keys)
            (let ((value (plist-get info key))
                  (expected (if (eq key :language)
                                (if (eq selection 'file) "fr" "de")
                              (concat (if (eq selection 'file) "File" "Subtree")
                                      (substring (symbol-name key) 1)))))
              (when (memq key '(:title :subtitle :author :date))
                (setq value (org-element-interpret-data value)))
              (should (equal value expected)))))))))

(ert-deftest org-texmacs-metadata-keywords-selection-fallback ()
  (let* ((input (org-texmacs-test--metadata-input
                 (concat "#+KEYWORDS: First\n#+KEYWORDS: Second\n#+SELECT_TAGS: keep\n"
                         "* Selected :keep:\nBody\n* Excluded\nOther\n")))
         (document (org-texmacs-document input)))
    (should (equal (org-texmacs-test--metadata-nodes
                    (org-texmacs-document-body document) 'abstract-keywords)
                   '((abstract-keywords "First Second"))))))

(ert-deftest org-texmacs-metadata-external-strings-owned ()
  (let* ((subtitle (copy-sequence "*Original*"))
         (description (copy-sequence "Original description"))
         (input (org-texmacs-test--metadata-input
                 "Body\n" (list :subtitle subtitle :description description)))
         (before (org-texmacs-document input)))
    (aset subtitle 1 ?X)
    (aset description 0 ?X)
    (should (equal before (org-texmacs-document input)))))

(ert-deftest org-texmacs-metadata-empty-last-and-global-language ()
  (let ((org-texmacs-document-initial '(("language" . "german"))))
    (let* ((input (org-texmacs-test--metadata-input
                   "#+LANGUAGE: en\n#+LANGUAGE:\n#+EMAIL: first@example.test\n#+EMAIL:\nBody\n"))
           (document (org-texmacs-document input)))
      (should (equal (plist-get (org-texmacs-input-info input) :email) ""))
      (should-not (assoc "language" (org-texmacs-document-initial document)))))
  (let ((org-texmacs-document-initial nil) (org-export-default-language "fr"))
    (should (equal (cdr (assoc "language" (org-texmacs-document-initial
                                           (org-texmacs-document
                                            (org-texmacs-test--metadata-input "Body\n")))))
                   "french"))))

(ert-deftest org-texmacs-metadata-plain-result-does-not-share-input ()
  (let* ((input (org-texmacs-test--metadata-input
                 "#+EMAIL: email@example.test\n#+KEYWORDS: Keyword\nBody\n"
                 '(:with-email t)))
         (before (org-texmacs-document input))
         (snapshot (org-texmacs-document input)))
    (aset (cadar (org-texmacs-test--metadata-nodes
                  (org-texmacs-document-body before) 'author-email)) 0 ?X)
    (aset (cadar (org-texmacs-test--metadata-nodes
                  (org-texmacs-document-body before) 'abstract-keywords)) 0 ?X)
    (aset (car (car (org-texmacs-document-initial before))) 0 ?X)
    (should (equal snapshot (org-texmacs-document input)))))

(ert-deftest org-texmacs-metadata-pure-info-keywords ()
  (let* ((input (org-texmacs-input-create
                 (org-element-create 'org-data nil
                   (org-element-create 'paragraph nil "Body"))
                 '(:keywords "Effective <alpha>")))
         (body (org-texmacs-document-body (org-texmacs-document input))))
    (should (equal (cadr body) '(abstract-keywords "Effective <alpha>")))))

;;; metadata.el ends here
