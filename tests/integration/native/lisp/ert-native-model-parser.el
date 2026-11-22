;;; ert-native-model-parser.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'org-texmacs-parse)

(ert-deftest org-texmacs-model-parse-native-errors-preserve-worker ()
  (org-texmacs-test--with-worker
   (org-texmacs--worker-request "(math \"ready\")")
   (dolist
       (text
        '("$(math 7)$\n"
          "* COMMENT Excluded\n#+begin_texmacs\n(math 7)\n#+end_texmacs\n"))
     (with-temp-buffer
       (org-mode)
       (insert text)
       (should-error
        (org-texmacs-parse-buffer (current-buffer))
        :type 'org-texmacs-parse-error)))
   (let ((worker org-texmacs--worker-process))
     (should (process-live-p worker))
     (with-temp-buffer
       (org-mode)
       (insert "$(math \"recovered\")$\n")
       (should
        (equal
         (cdar
          (org-texmacs-model-islands
           (org-texmacs-parse-buffer (current-buffer))))
         '(math "recovered"))))
     (should (eq worker org-texmacs--worker-process)))))

;;; ert-native-model-parser.el ends here
