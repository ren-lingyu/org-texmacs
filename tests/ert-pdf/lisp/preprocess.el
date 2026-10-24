;;; preprocess.el --- pdf preprocess regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-preprocess-cross-directory-stm-final-context
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (make-directory "parts")
    (write-region
     "#+begin_texmacs\n(image \"asset.png\")\n#+end_texmacs\n"
     nil
     "parts/a.org"
     nil
     'silent)
    (insert "#+INCLUDE: \"parts/a.org\"\n")
    (let* ((input
            (org-texmacs-prepare-buffer-preprocessed
             (current-buffer)))
           (document (org-texmacs-document input)))
      (should
       (equal
        (plist-get
         (org-texmacs-input-info input)
         :texmacs-preprocessed-source)
        "#+begin_texmacs\n(image \"asset.png\")\n#+end_texmacs\n"))
      (should
       (equal
        (org-texmacs-input-resource-base input) default-directory))
      (should
       (string-match-p
        "asset.png"
        (prin1-to-string (org-texmacs-document-body document))))
      (should-not
       (plist-member
        (org-texmacs-input-info input)
        :texmacs-island-origins))
      (should-error
       (org-texmacs-document-pdf document)
       :type 'org-texmacs-error)))))

;;; preprocess.el ends here
