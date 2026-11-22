;;; ert-pdf-document.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest
    org-texmacs-document-issue11-file-provenance-and-source-errors
    ()
  :tags
  '(issue11)
  (let* ((leaf (org-element-create 'stm-fragment nil))
         (link
          (org-element-create
           'link '(:type "file" :path "asset.pdf")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create
            'quote-block
            nil
            (org-element-create 'paragraph nil leaf "\n")
            (org-element-create 'paragraph nil link))))
         (input
          (org-texmacs-input-create
           ast
           nil
           :resource-base "/base/"
           :islands
           (list (cons leaf '(math "<alpha>")))))
         (result (org-texmacs-document input)))
    (should
     (equal (org-texmacs-document-stm-paths result) '((0 0 0))))
    (should
     (equal (org-texmacs-document-file-paths result) '((0 0 1 0 1))))
    (should
     (string-match-p
      (regexp-quote "/base/asset.pdf")
      (org-texmacs--native-document-wire result)))
    (should
     (equal
      (cadr (org-texmacs-document-body result))
      '(quotation
        (document
         (math "<alpha>")
         (concat (hlink "asset.pdf" "asset.pdf")))))))
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (insert "Before $(equation \"x\")$ after.\n")
     (let ((before
            (org-texmacs-test--document-buffer-state
             (current-buffer)))
           (file
            (expand-file-name "should-not-exist.pdf" test-directory)))
       (cl-letf (((symbol-function 'org-texmacs-document-pdf)
                  (lambda (&rest _)
                    (ert-fail "Rejected paragraph rendered PDF"))))
         (should-error
          (org-texmacs-export-to-pdf-file (current-buffer) file)
          :type 'org-texmacs-document-error))
       (should-not (file-exists-p file))
       (should
        (equal
         before
         (org-texmacs-test--document-buffer-state
          (current-buffer))))))))

;;; ert-pdf-document.el ends here
