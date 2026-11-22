;;; ert-native-special-blocks.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-document-typed-reference-named-blocks ()
  (org-texmacs-test--with-worker
   (dolist (case
            '(("theorem" . theorem-ref)
              ("statement proposition" . proposition-ref)
              ("statement_lemma" . lemma-ref)
              ("corollary" . cor-ref)
              ("axiom" . axiom-ref)
              ("definition" . definition-ref)
              ("notation" . notation-ref)
              ("conjecture" . conjecture-ref)
              ("remark" . remark-ref)
              ("statement example" . example-ref)
              ("note" . note-ref)
              ("warning" . warning-ref)
              ("convention" . convention-ref)
              ("exercise" . exercise-ref)
              ("problem" . problem-ref)
              ("equation" . eq-ref)
              ("figure" . figure-ref)
              ("table" . table-ref)
              ("proof" . reference)
              ("equation*" . reference)
              ("figure*" . reference)
              ("table*" . reference)
              ("texmacs" . reference)))
     (ert-info
      ((car case))
      (with-temp-buffer
        (org-mode)
        (insert
         "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
         "[[eq:object]] [[eq:object][Describe]].\n\n"
         (org-texmacs-test--stage4-block (car case) "eq:object"))
        (let* ((org-texmacs-document-style '("generic" "smart-ref"))
               (org-texmacs-typed-references t)
               (input (org-texmacs-prepare-buffer (current-buffer)))
               (document (org-texmacs-document input))
               (body (org-texmacs-document-body document))
               (id
                (cdar
                 (org-texmacs-resolution-labels
                  (org-texmacs-input-resolution input))))
               (tag (cdr case))
               (session (org-texmacs-session-open)))
          (should
           (equal
            (org-texmacs-test--caption-inline-footnote-nodes body tag)
            (list (list tag id))))
          (should
           (member
            (list 'hlink "Describe" (concat "#" id))
            (org-texmacs-test--caption-inline-footnote-nodes
             body 'hlink)))
          (should (equal document (org-texmacs-document input)))
          (unwind-protect
              (progn
                (org-texmacs-session-set-document session document)
                (should
                 (equal
                  (org-texmacs--session-read session)
                  (org-texmacs-test--native-hex body))))
            (org-texmacs-session-close session))))))))

;;; ert-native-special-blocks.el ends here
