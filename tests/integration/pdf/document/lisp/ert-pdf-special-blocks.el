;;; ert-pdf-special-blocks.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-statement-caption-native-export-and-reload ()
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (with-temp-buffer
       (org-mode)
       (insert "#+OPTIONS: toc:nil title:nil author:nil date:nil\n")
       (dolist (tag '("theorem" "remark" "exercise" "proof"))
         (insert
          "#+NAME: "
          tag
          "\n#+CAPTION: "
          tag
          "Title *Bold*\n#+begin_"
          tag
          "\nFirst $(math \"x+y\")$.\n\nSecond paragraph.\n#+end_"
          tag
          "\n"
          "[["
          tag
          "][Jump"
          tag
          "]]\n"))
       (let* ((org-texmacs-document-style (list style))
              (input (org-texmacs-prepare-buffer (current-buffer)))
              (document (org-texmacs-document input))
              (tm
               (expand-file-name (concat
                                  style "-statement-caption.tm")
                                 test-directory))
              (pdf
               (expand-file-name (concat
                                  style "-statement-caption.pdf")
                                 test-directory))
              (reload
               (expand-file-name
                (concat style "-statement-caption-reload.pdf")
                test-directory)))
         (should
          (= 4 (length (org-texmacs-document-stm-paths document))))
         (org-texmacs-document-save document tm)
         (org-texmacs-document-save-pdf document pdf)
         (org-texmacs-test--issue11-reload-pdf
          tm reload test-directory)
         (org-texmacs-test--issue11-compare-pdfs pdf reload)
         (dolist (file (list pdf reload))
           (let ((text (org-texmacs-test--pdf-text file))
                 (links (org-texmacs-test--pdf-links file)))
             (dolist (tag '("theorem" "remark" "exercise" "proof"))
               (should (string-match-p (concat tag "Title") text))
               (should
                (cl-find-if
                 (lambda (entry)
                   (string-match-p (concat "Jump" tag) (car entry)))
                 links)))
             (let ((inspection
                    (org-texmacs-test--pdf-note-inspect file)))
               (dolist (tag '("theorem" "remark" "exercise" "proof"))
                 (org-texmacs-test--pdf-note-edge
                  inspection
                  (concat "Jump" tag)
                  (concat tag "Title"))))))
         (should (equal document (org-texmacs-document input))))))))

(ert-deftest org-texmacs-typed-references-native-pdf-and-reload ()
  (require 'ucs-normalize)
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (let*
         ((cases
           '(("theorem" "Theorem")
             ("proposition" "Proposition")
             ("lemma" "Lemma")
             ("corollary" "Corollary")
             ("axiom" "Axiom")
             ("definition" "Definition")
             ("notation" "Notation")
             ("conjecture" "Conjecture")
             ("remark" "Remark")
             ("statement example" "Example")
             ("note" "Note")
             ("warning" "Warning")
             ("convention" "Convention")
             ("exercise" "Exercise")
             ("problem" "Problem")
             ("equation" "Equation")
             ("figure" "Figure")
             ("table" "Table")
             ("section" "Section")))
          (org-texmacs-typed-references t)
          (org-texmacs-document-style (list style "smart-ref"))
          (document
           (with-temp-buffer
             (org-mode)
             (insert
              "#+LANGUAGE: en\n"
              "#+OPTIONS: toc:nil num:t title:nil author:nil date:nil\n")
             ;; The bare and described links share a target.  Keep all
             ;; references before their targets to exercise forward binding.
             (dolist (case cases)
               (let* ((name (cadr case))
                      (target
                       (concat
                        (if (equal name "Section")
                            "#"
                          "")
                        "object-" (downcase name))))
                 (insert
                  "Ref"
                  name
                  " [["
                  target
                  "]] and [["
                  target
                  "][Jump"
                  name
                  "]].\n\n")))
             (insert "#+begin_texmacs\n(new-page)\n#+end_texmacs\n\n")
             (dolist (case cases)
               (let ((kind (car case))
                     (name (concat "object-" (downcase (cadr case)))))
                 (insert
                  (cond
                   ((equal kind "section")
                    (concat
                     "* Target section\n:PROPERTIES:\n:CUSTOM_ID: "
                     name
                     "\n:END:\n"))
                   ((equal kind "table")
                    (concat
                     "#+NAME: "
                     name
                     "\n#+CAPTION: TableBody\n| A |\n"))
                   (t
                    (org-texmacs-test--stage4-block
                     kind name
                     (when (equal kind "figure")
                       "FigureBody"))))
                  "\n")))
             (org-texmacs-document-from-buffer (current-buffer))))
          (tm
           (expand-file-name (concat style "-typed.tm")
                             test-directory))
          (pdf
           (expand-file-name (concat style "-typed.pdf")
                             test-directory))
          (reload
           (expand-file-name (concat style "-typed-reload.pdf")
                             test-directory)))
       (org-texmacs-document-save document tm)
       (org-texmacs-document-save-pdf document pdf)
       (org-texmacs-test--issue11-reload-pdf tm reload test-directory)
       (dolist (file (list pdf reload))
         ;; Poppler may extract a font ligature as a compatibility character,
         ;; for example U+FB01 in Definition.  Normalize only the test's text.
         (let ((text
                (ucs-normalize-NFKC-string
                 (org-texmacs-test--pdf-text file)))
               (links (org-texmacs-test--pdf-links file))
               (previous-index -1))
           (dolist (case cases)
             (let* ((name (cadr case))
                    (index
                     (cl-position-if
                      (lambda (entry)
                        (string-match-p
                         (concat "Jump" name "\\b")
                         (ucs-normalize-NFKC-string (car entry))))
                      links
                      :start (1+ previous-index))))
               (ert-info
                ((format "%s %s: %S" style name links))
                (should
                 (string-match-p
                  (concat
                   "Ref" name " "
                   (if (equal name "Equation")
                       "( *[0-9][0-9.]* *)"
                     (concat name " [0-9][0-9.]*")))
                  text))
                (should (and index (> index previous-index)))
                (let ((destination (cdr (nth index links))))
                  (should
                   (string-match-p "\\.html#[0-9]+\\'" destination))
                  ;; The native reference may occupy several annotations,
                  ;; notably the parentheses and number of an eq-ref.
                  ;; Search this pair's interval, not just the last link.
                  (should
                   (cl-loop
                    for
                    i
                    from
                    (1+ previous-index)
                    below
                    index
                    for
                    typed
                    =
                    (nth i links)
                    thereis
                    (and (string-match-p "[0-9]" (car typed))
                         (equal (cdr typed) destination)))))
                (setq previous-index index))))))))))

;;; ert-pdf-special-blocks.el ends here
