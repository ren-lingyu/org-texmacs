;;; ert-pdf-pdf.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-pdf-issue12-native-bibliography-and-reload ()
  :tags
  '(issue12)
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
      "#+bibliography: refs.bib\nBody[cite:@child; @parent; @online].\n#+print_bibliography:\n")
     (let*
         ((sources
           '(("refs.bib"
              .
              "@string{word={Native}}\n@preamble{\"PreambleSentinel\"}\n@book{child,title={ChildTitle},crossref={parent}}\n@book{parent,title={ParentTitle}}\n@online{online,title=word # {Title},year=2026}")))
          (document
           (org-texmacs-test--native-bib-document
            (org-texmacs-parse-buffer (current-buffer))
            (cdar sources)))
          (pdf (expand-file-name "native.pdf" test-directory))
          (tm (expand-file-name "native.tm" test-directory))
          (reload (expand-file-name "reload.pdf" test-directory)))
       (org-texmacs-document-save document tm)
       (org-texmacs-document-save-pdf document pdf)
       (org-texmacs-test--issue11-reload-pdf tm reload test-directory)
       (let ((text (org-texmacs-test--pdf-text pdf))
             (loaded (org-texmacs-test--pdf-text reload)))
         (dolist (token '("ChildTitle" "ParentTitle" "NativeTitle"))
           (should (string-match-p token text))
           (should (string-match-p token loaded)))
         (should-not (string-match-p "PreambleSentinel\\|[?]" text))
         (should-not (string-match-p "PreambleSentinel\\|[?]" loaded))
         (should (string-match-p "in *\\[[123]\\]" text))
         (should (equal text loaded)))))))

;;; ert-pdf-pdf.el ends here
