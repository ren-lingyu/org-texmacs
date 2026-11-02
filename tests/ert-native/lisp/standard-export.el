;;; standard-export.el --- Standard native output regressions -*- lexical-binding: t; -*-

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

(ert-deftest
    org-texmacs-standard-export-native-pdf-without-text-serialization
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Standard native PDF.\n")
     (let ((org-export-use-babel nil))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (_document)
                    (ert-fail "PDF serialized .tm"))))
         (let ((pdf (org-texmacs--standard-consume 'pdf)))
           (should (string-prefix-p "%PDF-" pdf))
           (should-not (multibyte-string-p pdf))))))))
