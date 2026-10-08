;;; fragment-tags-probe.el --- Probe default fragment roots -*- lexical-binding: t; -*-
(load (expand-file-name "tests/ert/ert.el") nil t)
(princ (format "Executable: %s\n" (file-truename (executable-find "texmacs"))))
(ert-deftest org-texmacs-probe-tags ()
 (org-texmacs-test--with-worker
  (let ((decode (symbol-function 'org-texmacs--worker-decode)))
   (cl-letf (((symbol-function 'org-texmacs--worker-decode)
              (lambda (response id)
                (princ (format "Raw response: %S\n" response))
                (funcall decode response id))))
  (dolist (tag '(math equation equation* eqnarray eqnarray* align align*
                     gather gather* eqsplit eqsplit*))
    (let* ((body
            (cond
             ((memq tag '(math equation equation*)) '(frac "1" (sqrt "x")))
             ((memq tag '(gather gather*))
              '(tformat (table (row (cell "x=1")) (row (cell "y=2")))))
             ((memq tag '(align align*))
              '(tformat (table (row (cell "x") (cell "=1"))
                               (row (cell "y") (cell "=2")))))
             (t '(tformat (table (row (cell "x") (cell "=") (cell "1"))
                                 (row (cell "y") (cell "=") (cell "2")))))))
           (stree (list tag body))
           (result (org-texmacs--worker-request (prin1-to-string stree))))
      (unless (equal result stree) (error "Unexpected tree for %S: %S" tag result))
      (princ (format "%S: %S\n" tag result))))))))
