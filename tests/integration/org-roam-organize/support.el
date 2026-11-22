;;; support.el --- Suite-local fixtures -*- lexical-binding: t; -*-

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

;;; support.el ends here
