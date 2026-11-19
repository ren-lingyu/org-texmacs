;;; support.el --- CSL fixture support -*- lexical-binding: t; -*-

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
