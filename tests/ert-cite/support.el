;;; support.el --- CSL fixture support -*- lexical-binding: t; -*-

(defconst org-texmacs-test--csl-style
  "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Org TeXmacs test</title><id>https://example.org/org-texmacs-test</id><updated>2026-01-01T00:00:00+00:00</updated></info><citation><layout prefix=\"[\" suffix=\"]\"><text variable=\"title\" font-style=\"italic\"/></layout></citation><bibliography><layout><text variable=\"title\" font-style=\"italic\"/></layout></bibliography></style>"
  "Local minimal CSL style exercising linked citations and rich bibliography.")

(defmacro org-texmacs-test--with-csl (&rest body)
  "Run BODY with native isolation and local CSL-BIBLIOGRAPHY/STYLE/HEADER."
  (declare (indent 0))
  `(org-texmacs-test--with-worker
    (let* ((csl-bibliography
            (expand-file-name "refs.bib" default-directory))
           (csl-style
            (expand-file-name "fixture.csl" default-directory))
           (csl-header
            (format "#+bibliography: %s\n#+cite_export: csl %s\n"
                    csl-bibliography csl-style)))
      (with-temp-file csl-bibliography
        (insert
         "@book{key, author={Doe, Jane}, title={Reference Alpha}, year={2026}}\n@book{other, author={Smith, John}, title={Reference Beta}, year={2025}}\n"))
      (with-temp-file csl-style
        (insert org-texmacs-test--csl-style))
      ,@body)))
