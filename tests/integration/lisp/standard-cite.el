;;; standard-cite.el --- Real standard export integration -*- lexical-binding: t; -*-
(require 'org-roam)
(require 'org-roam-organize)
(require 'ox-html)
(require 'ucs-normalize)

(defmacro org-texmacs-integration--with-standard-organize (&rest body)
  "Run BODY with real Organize mode, isolated files and a real SQLite database."
  (declare (indent 0))
  `(org-texmacs-test--with-worker
    (let* ((notes (expand-file-name "notes/" default-directory))
           (org-roam-directory notes)
           (org-roam-organize-directory notes)
           (org-roam-db-location
            (expand-file-name "roam.db" default-directory))
           (org-roam-db--connection (make-hash-table :test #'equal))
           (org-id-locations nil)
           (org-id-locations-file
            (expand-file-name "ids" default-directory))
           (org-roam-db-update-on-save nil)
           (org-roam-organize-registry
            '((:name
               "navigation"
               :tag "map"
               :directory "navigation"
               :moc t
               :basic t)
              (:name
               "literature"
               :tag "ref"
               :directory "literature"
               :cite t
               :bibliography t)))
           (uuid "55555555-5555-4555-8555-555555555555")
           (mode org-roam-organize-mode)
           (bib (expand-file-name "literature/refs.bib" notes)))
      (unwind-protect
          (progn
            (make-directory (expand-file-name "literature" notes) t)
            (make-directory (expand-file-name "navigation" notes) t)
            (with-temp-file (expand-file-name "literature/ref.org"
                                              notes)
              (insert
               (format
                ":PROPERTIES:\n:ID: %s\n:ROAM_REFS: @real-key\n:BIBLIOGRAPHY: refs.bib\n:END:\n#+TITLE: Reference\n#+FILETAGS: :ref:\n"
                uuid)))
            (with-temp-file bib
              (insert
               "@book{real-key, author={Doe, Jane}, title={Actual fixture reference}, year={2026}}\n"))
            (with-temp-file (expand-file-name "literature/unused.org"
                                              notes)
              (insert
               ":PROPERTIES:\n:ID: 66666666-6666-4666-8666-666666666666\n:ROAM_REFS: @unused-key\n:BIBLIOGRAPHY: unused.bib\n:END:\n#+TITLE: Unused\n#+FILETAGS: :ref:\n"))
            (with-temp-file (expand-file-name "literature/unused.bib"
                                              notes)
              (insert
               "@book{unused-key, title={Unused reference}, year={2025}}\n"))
            (with-temp-file (expand-file-name "fixture.csl" notes)
              (insert org-texmacs-test--csl-style))
            (org-roam-db-sync)
            (org-roam-organize-mode 1)
            (should org-roam-organize-mode)
            ,@body)
        (org-roam-organize-mode
         (if mode
             1
           -1))
        (org-roam-db--close-all)))))

(ert-deftest org-texmacs-integration-standard-organize-csl-info-once
    ()
  (org-texmacs-integration--with-standard-organize
    (with-temp-buffer
      (org-mode)
      (setq
       default-directory notes
       buffer-file-name (expand-file-name "root.org" notes))
      (insert
       (format
        "#+cite_export: csl fixture.csl\n[cite:@%s]\n#+print_bibliography:\n"
        uuid))
      (let ((org-export-use-babel nil)
            (before (buffer-string))
            (globals (copy-tree org-cite-global-bibliography))
            (prepared 0)
            (citations 0)
            (bibliographies 0)
            live
            (cite (symbol-function 'org-cite-csl-render-citation))
            (bibliography
             (symbol-function 'org-cite-csl-render-bibliography)))
        (let ((org-export-before-processing-functions
               (list (lambda (_) (cl-incf prepared)))))
          (cl-letf (((symbol-function 'org-cite-csl-render-citation)
                     (lambda (citation style backend info)
                       (cl-incf citations)
                       (setq live info)
                       (should
                        (org-export-derived-backend-p
                         backend 'texmacs))
                       (should
                        org-roam-organize--cite-export-in-progress)
                       (should
                        (equal
                         '("real-key")
                         (org-cite-get-references citation t)))
                       (should
                        (equal
                         (list bib) (plist-get info :bibliography)))
                       (should
                        (equal
                         (list bib)
                         (org-cite-list-bibliography-files)))
                       (funcall cite citation style backend info)))
                    ((symbol-function
                      'org-cite-csl-render-bibliography)
                     (lambda (keys files style props backend info)
                       (cl-incf bibliographies)
                       (should (eq live info))
                       (should (equal '("real-key") keys))
                       (should (equal (list bib) files))
                       (funcall bibliography
                                keys
                                files
                                style
                                props
                                backend
                                info))))
            (let* ((input (org-texmacs--standard-consume 'input))
                   (document (org-texmacs-document input))
                   (printed
                    (prin1-to-string
                     (org-texmacs-document-body document))))
              (should
               (string-match-p "Actual fixture reference" printed))
              (should (string-match-p "hlink" printed))
              (should-not (string-match-p uuid printed))
              (should-not
               (string-match-p "Unused reference" printed)))))
        (should (= 1 prepared))
        (should (= 1 citations))
        (should (= 1 bibliographies))
        (should-not org-roam-organize--cite-export-in-progress)
        (should (equal before (buffer-string)))
        (should (equal globals org-cite-global-bibliography))))))

(ert-deftest
    org-texmacs-integration-standard-organize-csl-native-pdf-and-html
    ()
  (org-texmacs-integration--with-standard-organize
    (with-temp-buffer
      (org-mode)
      (setq
       default-directory notes
       buffer-file-name (expand-file-name "root.org" notes))
      (insert
       (format
        "#+cite_export: csl fixture.csl\n[cite:@%s] (math \"x\")\n#+print_bibliography:\n"
        uuid))
      (let ((org-export-use-babel nil)
            (before (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (&rest _)
                     (ert-fail "Unexpected PDF text serialization"))))
          (let ((bytes (org-texmacs--standard-consume 'pdf))
                (file (expand-file-name "actual.pdf" notes)))
            (should (string-prefix-p "%PDF-" bytes))
            (let ((coding-system-for-write 'no-conversion))
              (write-region bytes nil file nil 'silent))
            (let ((text
                   (ucs-normalize-NFKC-string
                    (org-texmacs-test--pdf-text file))))
              (should
               (string-match-p "Actual fixture reference" text))
              (should-not (string-search "<#200B>" text)))))
        (should
         (string-match-p
          "Actual fixture reference" (org-export-as 'html)))
        (should (string-match-p "TeXmacs" (org-export-as 'texmacs)))
        (should (equal before (buffer-string)))
        (should-not org-roam-organize--cite-export-in-progress)))))

(ert-deftest
    org-texmacs-integration-standard-organize-interactive-commands
    ()
  (org-texmacs-integration--with-standard-organize
    (with-temp-buffer
      (org-mode)
      (setq
       default-directory notes
       buffer-file-name (expand-file-name "root.org" notes))
      (insert
       (format
        "#+cite_export: csl fixture.csl
[cite:@%s]
#+print_bibliography:
"
        uuid))
      (let ((org-export-use-babel nil)
            (org-export-show-temporary-export-buffer nil)
            (cite (symbol-function 'org-cite-csl-render-citation)))
        (dolist (command
                 '(org-texmacs-export-as-texmacs
                   org-texmacs-export-to-texmacs
                   org-texmacs-export-to-pdf))
          (let ((prepared 0)
                (citations 0))
            (let ((org-export-before-processing-functions
                   (list (lambda (_) (cl-incf prepared)))))
              (cl-letf
                  (((symbol-function 'org-cite-csl-render-citation)
                    (lambda (citation style backend info)
                      (cl-incf citations)
                      (should
                       org-roam-organize--cite-export-in-progress)
                      (should
                       (equal
                        '("real-key")
                        (org-cite-get-references citation t)))
                      (should
                       (equal
                        (list bib) (plist-get info :bibliography)))
                      (funcall cite citation style backend info))))
                (let ((result (funcall command)))
                  (cond
                   ((bufferp result)
                    (unwind-protect
                        (should
                         (string-search
                          "Actual fixture reference"
                          (with-current-buffer result
                            (buffer-string))))
                      (kill-buffer result)))
                   ((eq command 'org-texmacs-export-to-pdf)
                    (should
                     (string-search
                      "Actual fixture reference"
                      (ucs-normalize-NFKC-string
                       (org-texmacs-test--pdf-text result)))))
                   (t
                    (with-temp-buffer
                      (insert-file-contents-literally result)
                      (should
                       (string-search
                        "Actual fixture reference"
                        (buffer-string)))))))))
            (should (= prepared 1))
            (should (= citations 1))))))))
