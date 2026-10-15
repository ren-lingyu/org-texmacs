;;; realworld-repro.el -*- lexical-binding: t; -*-
(ert-deftest org-texmacs-cleanup-realworld-repro ()
  (org-texmacs-test--with-worker
    (let ((directory (make-temp-file "realworld-cleanup-" t)))
      (unwind-protect
          (progn
            (dolist (name '("test.org" "test_include.org"))
              (copy-file (expand-file-name name (getenv "ISSUE6_REALWORLD"))
                         (expand-file-name name directory)))
            (dolist (name '("test.org" "test_include.org"))
              (let ((source (find-file-noselect (expand-file-name name directory))))
                (unwind-protect
                    (with-current-buffer source
                      (org-mode)
                      (setq-local org-export-with-toc nil)
                      (dolist (discover '(nil t))
                        (setq-local org-texmacs-export-discover-bibliography discover)
                        (let ((before (org-texmacs-test--document-buffer-state source))
                              (file buffer-file-name))
                          (dolist (command '(org-texmacs-export-to-texmacs org-texmacs-export-to-pdf))
                            (message "REALWORLD-NATIVE %s discover=%S command=%S" name discover command)
                            (let ((output (funcall command)))
                              (should (file-regular-p output))
                              (with-temp-buffer
                                (set-buffer-multibyte nil)
                                (insert-file-contents-literally output)
                                (should (string-prefix-p
                                         (if (eq command 'org-texmacs-export-to-pdf)
                                             "%PDF-" "<TeXmacs|") (buffer-string)))))
                            (should (equal before (org-texmacs-test--document-buffer-state source)))
                            (should (equal file buffer-file-name))))))
                  (kill-buffer source)))))
        (delete-directory directory t)))))
