;;; bibliography.el --- Explicit native bibliography constructor fixtures -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-native-bibliography-parser-and-owned-input ()
  (org-texmacs-test--with-worker
   (let*
       ((tree
         (org-texmacs--worker-request
          "@book{key, title={Native title}, author={Ada Example}, year={2026}}"
          'bibliography))
        (ast
         (org-element-create
          'org-data nil
          (org-element-create 'paragraph nil "Text")))
        (input
         (org-texmacs-input-create
          ast nil
          :bibliography (list (cons "/fixture/refs.bib" tree)))))
     (should (eq (car tree) 'document))
     (should
      (string-search
       "key"
       (prin1-to-string (org-texmacs-input-bibliography input))))
     (should
      (equal
       (org-texmacs-document-body
        (org-texmacs-document input))
       '(document (concat "Text"))))
     (setcdr tree nil)
     (should
      (string-search
       "Native title"
       (prin1-to-string (org-texmacs-input-bibliography input)))))))

(ert-deftest
    org-texmacs-native-bibliography-constructor-format-and-lower
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+bibliography: refs.bib\nBefore [cite:@key]. Again [cite:@key].\n#+print_bibliography:\n")
     (let*
         ((model (org-texmacs-parse-buffer (current-buffer)))
          (document
           (org-texmacs-test--native-bib-document
            model
            "@book{key, title={Native title}, author={Ada Example}, year={2026}}"))
          (body (org-texmacs-document-body document)))
       (erase-buffer)
       (should (memq 'cite (flatten-tree body)))
       (should (memq 'bib-list (flatten-tree body)))
       (should (string-search "Native title" (prin1-to-string body)))
       (should
        (string-prefix-p
         "<TeXmacs|" (org-texmacs-document-serialize document)))))))
