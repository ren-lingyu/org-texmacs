;;; doc-01-footnote-probe.el --- Native footnote environment probe -*- lexical-binding: t; -*-
(load "/home/lingyu/Projects/org-texmacs/tests/ert/ert.el" nil t)
(let ((org-texmacs--worker-scheme-file
       "/home/lingyu/Projects/org-texmacs/tmp/doc-01-footnote-probe.scm"))
  (org-texmacs-test--with-worker
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (let ((result (org-texmacs--worker-request "\"probe\"")))
            (with-temp-file "/home/lingyu/Projects/org-texmacs/tmp/doc-01-footnote-probe.txt"
              (let ((print-length nil) (print-level nil))
                (prin1 result (current-buffer)) (terpri (current-buffer))))
            (prin1 result) (terpri))
        (org-texmacs-session-close session)))))
