;;; ert-pdf-pdf.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'org)
(require 'org-texmacs)

(ert-deftest org-texmacs-pdf-issue10-inline-and-separate ()
  :tags
  '(issue10)
  (org-texmacs-test--with-worker
   (dolist (kind '(anonymous named forward bare))
     (let* ((directory
             (make-temp-file (expand-file-name "note-" test-directory)
                             t))
            (tm (expand-file-name "inline.tm" directory))
            (pdf (expand-file-name "inline.pdf" directory))
            (reference (expand-file-name "separate.pdf" directory))
            (reload (expand-file-name "reload.pdf" directory))
            (payload
             (if (eq kind 'bare)
                 "$(equation* \"x=1\")$"
               "Before $(math (frac \"1\" \"2\"))$ after"))
            (inline
             (pcase kind
               ('anonymous (concat "A[fn::" payload "].\n"))
               ('forward (concat "A[fn:n] then[fn:n:" payload "].\n"))
               (_ (concat "A[fn:n:" payload "].\n"))))
            (separate
             (concat
              (if (eq kind 'forward)
                  "A[fn:n] then[fn:n].\n"
                "A[fn:n].\n")
              "\n[fn:n] " payload "\n")))
       (dolist (source (list inline separate))
         (with-temp-buffer
           (org-mode)
           (insert
            "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
            source)
           (let ((document
                  (org-texmacs-document-from-buffer
                   (current-buffer))))
             (should
              (= (length (org-texmacs-document-stm-paths document))
                 1))
             (if (eq source inline)
                 (progn
                   (org-texmacs-document-save document tm)
                   (org-texmacs-document-save-pdf document pdf))
               (org-texmacs-document-save-pdf document reference)))))
       (org-texmacs-test--pdf-compare-text-and-geometry pdf reference)
       (should-not
        (string-match-p
         "math\\|frac\\|equation" (org-texmacs-test--pdf-text pdf)))
       (org-texmacs-test--pdf-render-from-saved-tm
        tm reload directory)
       (org-texmacs-test--pdf-compare-text-and-geometry
        pdf reload)))))

;;; ert-pdf-pdf.el ends here
