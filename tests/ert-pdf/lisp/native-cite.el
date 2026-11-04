;;; native-cite.el --- Native source bibliography layout -*- lexical-binding: t; -*-
(require 'ox-texmacs)

(ert-deftest org-texmacs-native-cite-math-tm-pdf-and-reload ()
  (org-texmacs-test--with-worker
   (let ((file (expand-file-name "references.bib" test-directory))
         (out
          (file-name-directory
           (getenv "ORG_TEXMACS_TEST_NAMES_FILE"))))
     (with-temp-file file
       (insert
        "@book{one,author={Alpha, Ada},title={Properties of $\\alpha_i$},year={2026},publisher={Press}}\n"
        "@book{two,author={Zulu, Zoe},title={Ratio $\\frac{a}{b}$},year={2025},publisher={Press}}\n"))
     (dolist (style '("plain" "alpha"))
       (with-temp-buffer
         (org-mode)
         (insert
          "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
          "#+bibliography: "
          file
          "\n#+cite_export: texmacs-native "
          style
          "\n"
          "First [cite:@two]. Repeated [cite:@one]. Multiple [cite:@one; @two].\n"
          "#+print_bibliography:\n")
         (let* ((org-export-use-babel nil)
                (document
                 (org-texmacs-document-from-buffer (current-buffer)))
                (body (org-texmacs-document-body document))
                (pdf
                 (expand-file-name (concat
                                    "native-cite-" style ".pdf")
                                   out))
                (tm
                 (expand-file-name (concat "native-cite-" style ".tm")
                                   out))
                (reload
                 (expand-file-name (concat
                                    "native-cite-"
                                    style
                                    "-reload.pdf")
                                   out)))
           (should (memq 'rsub (flatten-tree body)))
           (should (memq 'frac (flatten-tree body)))
           (should
            (= 2 (length (org-texmacs--bibliography-labels body))))
           (org-texmacs-document-save document tm)
           (org-texmacs-document-save-pdf document pdf)
           (should
            (= 0
               (call-process "pdftoppm"
                             nil
                             nil
                             nil
                             "-f"
                             "1"
                             "-singlefile"
                             "-scale-to"
                             "1400"
                             "-png"
                             pdf
                             (file-name-sans-extension pdf))))
           (org-texmacs-test--issue11-reload-pdf
            tm reload test-directory)
           (org-texmacs-test--issue11-compare-pdfs pdf reload)
           (let ((text (org-texmacs-test--pdf-text pdf)))
             (dolist (word
                      '("First"
                        "Repeated"
                        "Multiple"
                        "Properties"
                        "Ratio"))
               (should (string-search word text)))
             (should-not (string-search "?" text))
             (if (equal style "plain")
                 (should
                  (string-match-p "First[[:space:]]*\\[2\\]" text))
               (should
                (string-match-p
                 "First[[:space:]]*\\[Zul25\\]" text))))))))))
