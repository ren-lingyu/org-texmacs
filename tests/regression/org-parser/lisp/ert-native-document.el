;;; ert-native-document.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-caption-inline-footnote-stock-parser ()
  (should-not
   (memq
    'footnote-reference
    (cdr (assq 'keyword org-element-object-restrictions))))
  (dolist (kind '("plain" "figure" "figure*" "table" "table*"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
       "#+CAPTION[Short[fn::ShortNote]]: Long[fn::LongNote] (math \"literal\")\n")
      (unless (equal kind "plain")
        (insert "#+begin_" kind "\n"))
      (insert
       (if (string-prefix-p "figure" kind)
           "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"
         "| A |\n"))
      (unless (equal kind "plain")
        (insert "#+end_" kind "\n"))
      (insert "\nBody[fn::BodyNote].\n")
      (let ((source (buffer-string))
            requests)
        (let ((reader (symbol-function 'org-texmacs--stm-read)))
          (cl-letf (((symbol-function 'org-texmacs--stm-read)
                     (lambda (raw &rest _)
                       (push raw requests)
                       (funcall reader raw))))
            (let* ((input
                    (org-texmacs-prepare-buffer (current-buffer)))
                   (document (org-texmacs-document input))
                   (body (org-texmacs-document-body document)))
              (should
               (= 1
                  (length
                   (org-texmacs-test--caption-inline-footnote-nodes
                    body 'footnote))))
              (should
               (string-match-p
                "\\[fn::LongNote\\]" (prin1-to-string body)))
              (should
               (string-match-p
                "\\[fn::ShortNote\\]" (prin1-to-string body)))
              (should
               (= (length requests)
                  (if (string-prefix-p "figure" kind)
                      1
                    0)))
              (should
               (equal document (org-texmacs-document input))))))
        (should (equal source (buffer-string)))))))

;;; ert-native-document.el ends here
