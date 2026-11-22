;;; ert-core-special-blocks.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-issue13-stage3-real-parser-contract ()
  (dolist (type '("figure" "figure*" "TABLE" "TABLE*"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+CAPTION[Short]: Long *bold*\n#+begin_"
       type
       "\n\n"
       "#+begin_texmacs\n\"body\"\n#+end_texmacs\n\n#+end_"
       type
       "\n")
      (let* ((ast (org-element-parse-buffer))
             (wrapper
              (org-element-map ast 'special-block #'identity nil t))
             (children (org-element-contents wrapper)))
        (should
         (equal
          (downcase (org-element-property :type wrapper))
          (downcase type)))
        (should-not (org-element-property :parameters wrapper))
        (should
         (integerp (org-element-property :contents-begin wrapper)))
        (should
         (< (org-element-property :begin wrapper)
            (org-element-property :post-affiliated wrapper)))
        ;; Pinned Org represents a leading blank line as a paragraph containing
        ;; exactly a newline; the trailing blank is the inner block's post-blank.
        (should (= (length children) 2))
        (should (eq (org-element-type (car children)) 'paragraph))
        (should
         (equal
          (mapcar
           #'substring-no-properties
           (org-element-contents (car children)))
          '("\n")))
        (setq children (cdr children))
        (should (org-texmacs--block-p (car children)))
        (should (eq (org-element-parent (car children)) wrapper))
        (should
         (equal
          (cdr
           (car (org-element-property :caption wrapper)))
          '("Short")))))))

(ert-deftest org-texmacs-issue13-stage3-org-footnote-boundary-limit ()
  (with-temp-buffer
    (org-mode)
    (insert
     "Text[fn:n].\n\n[fn:n]\n#+begin_figure\n#+begin_texmacs\n"
     "(concat \"\n#+INCLUDE: missing.org\n#+BIBLIOGRAPHY: missing.bib\n[fn:missing]\n\")\n"
     "#+end_texmacs\n#+end_figure\n")
    ;; Org's footnote parser terminates n at the next column-zero definition,
    ;; even inside a would-be raw block.  Never reconstruct lost Org elements.
    (should-not
     (org-texmacs--native-body-blocks (org-element-parse-buffer)))
    (should-not
     (org-element-map
      (org-element-parse-buffer)
      'special-block
      #'org-texmacs--figure-table-kind))))

;;; ert-core-special-blocks.el ends here
