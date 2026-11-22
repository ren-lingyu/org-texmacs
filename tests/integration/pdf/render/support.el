;;; support.el --- Suite-local fixtures -*- lexical-binding: t; -*-

(defconst org-texmacs-test--adjacent-bib
  "@book{alpha, author={Ada Alpha}, title={FirstTitleSentinel}, year=2024, publisher={Example}}\n@book{beta, author={Bob Beta}, title={SecondTitleSentinel}, year=2025, publisher={Example}}"
  "Small bibliography for derived PDF link inspections.")

(defun org-texmacs-test--adjacent-source (long)
  "Return a combined link fixture, adding flowing paragraphs when LONG."
  (concat
   "#+BIBLIOGRAPHY: refs.bib\n"
   "[[https://example.org][ExternalLink]] and [[*OmegaDestination][ForwardToOmega]].\n\n"
   "#+begin_texmacs\n(new-page)\n#+end_texmacs\n\n"
   "* AlphaDestination\nAlphaBodySentinel. Group [cite:@alpha; @beta].\n\n"
   "First[fn:n].\n\n"
   (when long
     (apply
      #'concat
      (make-list
       40
       (concat
        (apply
         #'concat
         (make-list
          8
          "This flowing paragraph checks stable page references and link destinations. "))
        "\n\n"))))
   "#+begin_texmacs\n(new-page)\n#+end_texmacs\n\n"
   "* OmegaDestination\nOmegaBodySentinel. [[*AlphaDestination][BackToAlpha]].\n\n"
   "AlphaNumber [[*AlphaDestination]]. Again[fn:n]. Repeat [cite:@alpha].\n\n"
   "#+begin_texmacs\n(new-page)\n#+end_texmacs\n\n"
   "* ReferencesDestination\nBibSectionSentinel.\n\n#+print_bibliography:\n\n"
   "[fn:n] NamedFootnoteBodySentinel.\n"))

(defun org-texmacs-test--pdf-word (words text)
  "Find exactly one word TEXT in WORDS and return its coordinate list."
  (let ((matches
         (cl-remove-if-not
          (lambda (word) (equal (car word) text)) words)))
    (should (= (length matches) 1))
    (cdar matches)))

(defun org-texmacs-test--adjacent-pdf-targets (file)
  "Check FILE's derived link destinations and TOC values against actual pages."
  (let* ((tree (org-texmacs-test--pdf-link-tree file))
         (pages (dom-by-tag tree 'page))
         (page-texts
          (mapcar
           (lambda (page)
             (cons
              (string-to-number (dom-attr page 'number))
              (mapconcat #'dom-texts (dom-by-tag page 'text) " ")))
           pages))
         links)
    (dolist (page pages)
      (dolist (link (dom-by-tag page 'a))
        (push (list
               (string-to-number (dom-attr page 'number))
               (dom-texts link)
               (dom-attr link 'href))
              links)))
    (cl-labels
     ((page-of
       (marker)
       (let ((matches
              (cl-remove-if-not
               (lambda (entry)
                 (string-match-p marker (cdr entry)))
               page-texts)))
         (should (= 1 (length matches)))
         (caar matches)))
      (jumps
       (text target &optional from)
       (cl-remove-if-not
        (lambda (link)
          (and (or (null from) (= from (car link)))
               (equal text (nth 1 link))
               (string-suffix-p
                (format ".html#%d" target) (nth 2 link))))
        links)))
     (let ((alpha (page-of "AlphaBodySentinel"))
           (omega (page-of "OmegaBodySentinel"))
           (note (page-of "NamedFootnoteBodySentinel"))
           (first (page-of "FirstTitleSentinel"))
           (second (page-of "SecondTitleSentinel")))
       (should (jumps "1 AlphaDestination" alpha 1))
       (should (jumps "2 OmegaDestination" omega 1))
       (should (jumps "ForwardToOmega" omega))
       (should (jumps "BackToAlpha" alpha))
       (should (jumps "1" first alpha))
       (should (jumps "2" second alpha))
       (should (jumps "1" first omega))
       ;; Numeric headline reference and repeated footnote must both link.
       (should (jumps "1" alpha omega))
       (should (jumps "1" note omega))
       (when (= alpha note)
         (should (>= (length (jumps "1" note omega)) 2)))
       (dolist (entry
                `(("AlphaDestination" . ,alpha)
                  ("OmegaDestination" . ,omega)))
         (should
          (string-match-p
           (format "%s[[:space:].]*%d\\b"
                   (car entry)
                   (cdr entry))
           (cdar page-texts))))))))

;;; support.el ends here
