;;; doc-01-bibliography-probe.el --- Snapshot bibliography probe -*- lexical-binding: t; -*-
(load "/home/lingyu/Projects/org-texmacs/tests/ert/ert.el" nil t)
(let ((org-texmacs--worker-scheme-file
       "/home/lingyu/Projects/org-texmacs/tmp/doc-01-bibliography-probe.scm"))
  (org-texmacs-test--with-worker
    (let (results)
      (dolist (entry '((valid . "@book{knuth, author={Donald E. Knuth}, title={The TeXbook}, year={1984}, publisher={Addison-Wesley}}")
                       (unicode . "@book{unicode, author={Ada Example}, title={中 <alpha>}, year={2026}, publisher={Example}}")
                       (malformed . "@book{broken, title={Missing")))
        (push (cons (car entry)
                    (condition-case err (org-texmacs--worker-request (cdr entry))
                      (error (list 'probe-error (error-message-string err)))))
              results))
      (with-temp-file "/home/lingyu/Projects/org-texmacs/tmp/doc-01-bibliography-probe.txt"
        (let ((print-length nil) (print-level nil))
          (prin1 (nreverse results) (current-buffer)) (terpri (current-buffer)))))))
