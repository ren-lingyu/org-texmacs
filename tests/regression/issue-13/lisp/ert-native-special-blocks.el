;;; ert-native-special-blocks.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-texmacs)
(require 'ox)

(ert-deftest
    org-texmacs-issue13-native-final-handler-error-and-recovery
    ()
  (org-texmacs-test--with-worker
   (org-texmacs--worker-request "(math \"ready\")")
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+begin_custom\n#+begin_texmacs\n(math \"α\")\n#+end_texmacs\n#+end_custom\n")
     (let ((org-texmacs--document-special-block-handlers
            (list
             (cons
              "custom"
              (lambda (_b c _i)
                (should (equal (cadr c) '(math "α")))
                (list 'custom c (cadr c)))))))
       (should-error
        (org-texmacs-document-from-buffer (current-buffer))
        :type 'org-texmacs-document-error)
       (should (org-texmacs--worker-live-p))
       (let ((process org-texmacs--worker-process))
         (setq org-texmacs--document-special-block-handlers
               (list
                (cons "custom" (lambda (_b c _i) (list 'custom c)))))
         (should
          (equal
           (org-texmacs-document-stm-paths
            (org-texmacs-document-from-buffer (current-buffer)))
           '((0 0 0))))
         (should (eq process org-texmacs--worker-process)))))))

(ert-deftest
    org-texmacs-issue13-stage3-invalid-figure-and-table-recovery
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+BIBLIOGRAPHY: refs.bib\n#+begin_figure\nIllegal\n#+end_figure\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Invalid figure requested native work"))))
      (let ((failure
             (should-error
              (org-texmacs-document-from-buffer (current-buffer))
              :type 'org-texmacs-document-error)))
        (should
         (string-match-p
          "figure/table body" (error-message-string failure))))))
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+begin_table\n#+begin_texmacs\n(math \"bad-root\")\n#+end_texmacs\n#+end_table\n")
     (should-error
      (org-texmacs-document-from-buffer (current-buffer))
      :type 'org-texmacs-document-error)
     (erase-buffer)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
      "#+begin_table\n#+begin_texmacs\n(table (row (cell \"ok\")))\n#+end_texmacs\n#+end_table\n")
     (should
      (equal
       (org-texmacs-document-body
        (org-texmacs-document-from-buffer (current-buffer)))
       '(document
         (big-table
          (tabular (tformat (table (row (cell "ok"))))) "")))))))

;;; ert-native-special-blocks.el ends here
