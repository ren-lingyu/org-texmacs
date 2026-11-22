;;; ert-pdf-pdf.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-pdf-issue11-bare-block-and-reload-consistency
    ()
  :tags
  '(issue11)
  (org-texmacs-test--with-worker
   ;; All default roots use their existing valid multirow/native fixtures.
   ;; Context expansion focuses on environments with explicit display semantics.
   (dolist (context '(body quote center footnote list))
     (dolist (tree
              (if (eq context 'body)
                  org-texmacs-test--fragment-strees
                (cl-remove-if-not
                 (lambda (tree)
                   (memq (car tree) '(equation equation* align)))
                 org-texmacs-test--fragment-strees)))
       (ert-info
        ((format "%s in %s" (car tree) context))
        (let* ((directory
                (make-temp-file (expand-file-name "native-"
                                                  test-directory)
                                t))
               (tm (expand-file-name "bare.tm" directory))
               (pdf (expand-file-name "bare.pdf" directory))
               (block-pdf (expand-file-name "block.pdf" directory))
               (reload (expand-file-name "reload.pdf" directory))
               (text (prin1-to-string tree)))
          (dolist (block '(nil t))
            (with-temp-buffer
              (org-mode)
              (insert
               (org-texmacs-test--issue11-source
                context
                (if block
                    (concat
                     "#+begin_texmacs\n" text "\n#+end_texmacs\n")
                  (concat "$" text "$ \t\n"))))
              (let ((document
                     (org-texmacs-document-from-buffer
                      (current-buffer))))
                (unless block
                  (org-texmacs-document-save document tm))
                (org-texmacs-document-save-pdf
                 document
                 (if block
                     block-pdf
                   pdf)))))
          (org-texmacs-test--pdf-compare-text-and-geometry
           pdf block-pdf)
          (org-texmacs-test--pdf-render-from-saved-tm
           tm reload directory)
          (org-texmacs-test--pdf-compare-text-and-geometry
           pdf reload)))))))

(ert-deftest org-texmacs-pdf-issue11-original-equation-layout ()
  :tags
  '(issue11)
  (org-texmacs-test--with-worker
   (let* ((tree
           '(equation
             (concat
              "0<longrightarrow>"
              (math-up "ker")
              (around* "(" "<alpha>" ")")
              "<longrightarrow>"
              (math-up "ker")
              (around* "(" "<beta>" ")")
              "<longrightarrow>"
              (math-up "ker")
              (around* "(" "<gamma>" ")")
              (above "<longrightarrow>" "<delta>")
              (math-up "coker")
              (around* "(" "<alpha>" ")")
              "<longrightarrow>"
              (math-up "coker")
              (around* "(" "<beta>" ")")
              "<longrightarrow>"
              (math-up "coker")
              (around* "(" "<gamma>" ")")
              "<longrightarrow>0")))
          (text (prin1-to-string tree))
          (tm (expand-file-name "original.tm" test-directory))
          (pdf (expand-file-name "original.pdf" test-directory))
          (reload
           (expand-file-name "original-reload.pdf" test-directory))
          (org-texmacs-document-style '("article"))
          (org-texmacs-document-initial
           '(("page-type" . "a4")
             ("page-odd" . "12.7mm")
             ("page-even" . "12.7mm")
             ("page-right" . "12.7mm")
             ("page-top" . "12.7mm")
             ("page-bot" . "12.7mm"))))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\n#+begin_texmacs\n"
        text
        "\n#+end_texmacs\n\n$"
        text
        "$\n")
       (let ((document
              (org-texmacs-document-from-buffer (current-buffer))))
         (org-texmacs-document-save document tm)
         (org-texmacs-document-save-pdf document pdf)))
     (let* ((words (org-texmacs-test--pdf-words-tolerant pdf))
            (zeros
             (cl-remove-if-not
              (lambda (w) (equal (car w) "0")) words))
            (one (cl-find "(1)" words :key #'car :test #'equal))
            (two (cl-find "(2)" words :key #'car :test #'equal)))
       (should (= (length zeros) 4))
       (should one)
       (should two)
       (should
        (<= (abs (- (cadr (nth 0 zeros)) (cadr (nth 2 zeros)))) 1.0))
       (should (<= (abs (- (cadr one) (cadr two))) 1.0))
       (should (> (cadr one) (+ (cadr (nth 1 zeros)) 50))))
     (org-texmacs-test--pdf-render-from-saved-tm
      tm reload test-directory)
     (org-texmacs-test--pdf-compare-text-and-geometry pdf reload))))

;;; ert-pdf-pdf.el ends here
