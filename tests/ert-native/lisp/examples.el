;;; examples.el --- Fixed native example fixtures -*- lexical-binding: t; -*-

;;; Commentary:

;; Test-owned support and fixtures.

;;; Code:

(defun org-texmacs-test--example-document ()
  "Exercise the fixed document fixture."
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n"
     "* 中\n"
     "Text *bold* <alpha> (math \"α <alpha>\") end.\n\n"
     "#+begin_texmacs\n"
     "(with \"mode\" \"math\" (frac \"中\" \"2\"))\n"
     "#+end_texmacs\n")
    (org-texmacs-document-from-buffer (current-buffer))))

(defun org-texmacs-test--example-session ()
  "Exercise the fixed session fixture."
  (let ((document
         (with-temp-buffer
           (org-mode)
           (insert "Text (math \"α\")\n")
           (org-texmacs-document-from-buffer (current-buffer)))))
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (progn
            (org-texmacs-session-set-document session document)
            t)
        (org-texmacs-session-close session)))))

;;; examples.el ends here
