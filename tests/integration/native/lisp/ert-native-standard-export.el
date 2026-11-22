;;; ert-native-standard-export.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-standard-export-native-script-tree-and-island
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil ^:t\n"
      "The /first/ term is x_i^2.\n\nNested x^{a_b}.\n\n"
      "$(math (frac \"a\" \"b\"))$_i^2.\n")
     (let* ((input (org-texmacs--standard-consume 'input))
            (original
             (copy-tree (cdar (org-texmacs-input-islands input))))
            (document (org-texmacs-document input))
            (expected
             '(document
               (concat
                "The "
                (em "first")
                " "
                "term is x"
                (rsub "i")
                (rsup "2")
                ". ")
               (concat "Nested x" (rsup (concat "a" (rsub "b"))) ". ")
               (concat
                (math (frac "a" "b")) (rsub "i") (rsup "2") ". ")))
            (session (org-texmacs-session-open)))
       (should (equal original '(math (frac "a" "b"))))
       (should
        (equal original (cdar (org-texmacs-input-islands input))))
       (should
        (equal (org-texmacs-document-stm-paths document) '((2 0))))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-standard-export-native-entity-encoding ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil e:t\n"
      "Before \\alpha{} \\cdot \\rightarrow \\copy literal <alpha> After.\n")
     (let* ((document (org-texmacs--standard-consume 'document))
            (session (org-texmacs-session-open))
            (expected
             '(document
               (concat
                "Before "
                (math "<alpha>")
                " "
                (math "<cdot>")
                " "
                (math "<rightarrow>")
                " "
                "<copyright>"
                " "
                "literal <less>alpha<gtr> After. "))))
       (should-not (org-texmacs-document-stm-paths document))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected))))
         (org-texmacs-session-close session))
       (should
        (string-search
         "<math|\\<alpha\\>>"
         (org-texmacs-document-serialize document)))))))

(ert-deftest org-texmacs-standard-export-native-text-file-and-source
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Café 中文 α and literal <alpha>.\n")
     (let* ((source (buffer-string))
            (org-export-use-babel nil)
            (org-export-coding-system 'iso-latin-1-unix)
            (text (org-export-as 'texmacs))
            (bytes (encode-coding-string text 'iso-latin-1-unix))
            (file (expand-file-name "standard.tm" test-directory)))
       (should (string-prefix-p "<TeXmacs|" text))
       (should-not (cl-some (lambda (c) (> c #x10ffff)) text))
       (org-export-to-file 'texmacs file)
       (with-temp-buffer
         (set-buffer-multibyte nil)
         (insert-file-contents-literally file)
         (should (equal (concat bytes "\n") (buffer-string))))
       (should (equal source (buffer-string)))))))

;;; ert-native-standard-export.el ends here
