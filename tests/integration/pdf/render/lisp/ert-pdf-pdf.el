;;; ert-pdf-pdf.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'org-texmacs-parse)
(require 'ox)
(require 'ox-texmacs)
(require 'dom)

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

(ert-deftest org-texmacs-pdf-preformatted-lines-and-indent ()
  :tags
  '(issue4-closure)
  (org-texmacs-test--with-worker
   (let ((actual (expand-file-name "code.pdf" test-directory))
         (reference
          (expand-file-name "code-reference.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\nCodeBefore\n\n"
        "#+begin_example -i\n  ExampleOne\n    ExampleTwo\n\n  ExampleThree\n#+end_example\n\n"
        ": FixedOne\n:   FixedTwo\n\n"
        "#+begin_src text -i\n  SourceOne\n\n    SourceTwo\n#+end_src\n\nCodeAfter\n")
       (org-texmacs-export-to-pdf-file (current-buffer) actual))
     (org-texmacs-document-save-pdf
      (org-texmacs--document-create
       :body
       '(document
         (concat "CodeBefore ")
         (code
          (document
           "  ExampleOne" "    ExampleTwo" "" "  ExampleThree"))
         (code (document "FixedOne" "  FixedTwo"))
         (code (document "  SourceOne" "" "    SourceTwo"))
         (concat "CodeAfter ")))
      reference)
     (let ((words (org-texmacs-test--pdf-words actual))
           (expected (org-texmacs-test--pdf-words reference)))
       (dolist (token
                '("CodeBefore"
                  "ExampleOne"
                  "ExampleTwo"
                  "ExampleThree"
                  "FixedOne"
                  "FixedTwo"
                  "SourceOne"
                  "SourceTwo"
                  "CodeAfter"))
         (cl-mapc
          (lambda (a b) (should (<= (abs (- a b)) 1.0)))
          (org-texmacs-test--pdf-word words token)
          (org-texmacs-test--pdf-word expected token)))
       (let ((one (org-texmacs-test--pdf-word words "ExampleOne"))
             (two (org-texmacs-test--pdf-word words "ExampleTwo"))
             (three
              (org-texmacs-test--pdf-word words "ExampleThree")))
         (should (> (car two) (+ (car one) 1.0)))
         (should (<= (abs (- (car one) (car three))) 1.0))
         (should
          (<= (abs
               (- (- (cadr three) (cadr two))
                  (* 2 (- (cadr two) (cadr one)))))
              1.0)))
       (should
        (> (car (org-texmacs-test--pdf-word words "FixedTwo"))
           (+ 1.0
              (car
               (org-texmacs-test--pdf-word words "FixedOne")))))))))

(ert-deftest org-texmacs-pdf-list-multiparagraph-native-layout ()
  :tags
  '(issue4-closure)
  (org-texmacs-test--with-worker
   (let ((actual (expand-file-name "lists.pdf" test-directory))
         (reference
          (expand-file-name "lists-reference.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
        "- OuterOne\n\n  OuterMore\n\n  1. InnerOne\n  2. InnerTwo\n- OuterTwo\n\n"
        "Separator\n\n- TermOne :: BodyOne\n\n  BodyMore\n- TermTwo :: BodyTwo\n")
       (org-texmacs-export-to-pdf-file (current-buffer) actual))
     (org-texmacs-document-save-pdf
      (org-texmacs--document-create
       :body
       '(document
         (itemize
          (document
           (concat (item) "OuterOne ") (concat "OuterMore ")
           (enumerate
            (document
             (concat (item) "InnerOne ") (concat (item) "InnerTwo ")))
           (concat (item) "OuterTwo ")))
         (concat "Separator ")
         (description
          (document
           (concat (item* "TermOne") "BodyOne ")
           (concat "BodyMore ")
           (concat (item* "TermTwo") "BodyTwo ")))))
      reference)
     (let ((words (org-texmacs-test--pdf-words actual))
           (expected (org-texmacs-test--pdf-words reference)))
       (dolist (token
                '("OuterOne"
                  "OuterMore"
                  "InnerOne"
                  "InnerTwo"
                  "OuterTwo"
                  "TermOne."
                  "BodyOne"
                  "BodyMore"
                  "TermTwo."
                  "BodyTwo"))
         (cl-mapc
          (lambda (a b) (should (<= (abs (- a b)) 1.0)))
          (org-texmacs-test--pdf-word words token)
          (org-texmacs-test--pdf-word expected token)))
       (let ((outer
              (car (org-texmacs-test--pdf-word words "OuterOne"))))
         (dolist (token '("OuterMore" "OuterTwo"))
           (should
            (<= (abs
                 (- outer
                    (car (org-texmacs-test--pdf-word words token))))
                1.0)))
         (should
          (> (car (org-texmacs-test--pdf-word words "InnerOne"))
             (+ outer 1.0)))))
     (should
      (string-match-p
       "1\\. InnerOne 2\\. InnerTwo"
       (org-texmacs-test--pdf-text actual))))))

(ert-deftest org-texmacs-pdf-caption-number-and-reference-semantics ()
  :tags
  '(issue4-closure)
  (org-texmacs-test--with-worker
   (let ((actual (expand-file-name "captions.pdf" test-directory))
         (reference
          (expand-file-name "captions-reference.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\nBeforeTable [[one]] [[two]]\n\n"
        "#+name: one\n#+caption[ShortOne]: LongCaptionOne\n| LeftOne | RightOne |\n\n"
        "#+name: two\n#+caption: LongCaptionTwo\n| LeftTwo | RightTwo |\n\n"
        "AfterTable [[one][FirstTable]] [[two]]\n")
       (org-texmacs-export-to-pdf-file (current-buffer) actual))
     (org-texmacs-document-save-pdf
      (org-texmacs--document-create
       :body
       '(document
         (concat
          "BeforeTable "
          (reference "native-one")
          " "
          (reference "native-two")
          " ")
         (big-table
          (tabular
           (tformat (table (row (cell "LeftOne") (cell "RightOne")))))
          (surround
           (label "native-one")
           ""
           (caption-detailed "LongCaptionOne" "ShortOne")))
         (big-table
          (tabular
           (tformat (table (row (cell "LeftTwo") (cell "RightTwo")))))
          (surround (label "native-two") "" "LongCaptionTwo"))
         (concat
          "AfterTable "
          (hlink "FirstTable" "#native-one")
          " "
          (reference "native-two")
          " ")))
      reference)
     (let ((words (org-texmacs-test--pdf-words actual))
           (expected (org-texmacs-test--pdf-words reference)))
       (dolist (token
                '("BeforeTable"
                  "LeftOne"
                  "RightOne"
                  "LongCaptionOne"
                  "LeftTwo"
                  "RightTwo"
                  "LongCaptionTwo"
                  "AfterTable"
                  "FirstTable"))
         (cl-mapc
          (lambda (a b) (should (<= (abs (- a b)) 1.0)))
          (org-texmacs-test--pdf-word words token)
          (org-texmacs-test--pdf-word expected token))))
     (let ((text (org-texmacs-test--pdf-text actual)))
       (dolist (pattern
                '("BeforeTable 1 2"
                  "Table 1\\. LongCaptionOne"
                  "Table 2\\. LongCaptionTwo"
                  "AfterTable FirstTable 2"))
         (should (string-match-p pattern text)))
       (should-not (string-match-p "ShortOne" text))))))

(ert-deftest org-texmacs-pdf-five-level-headline-counter-and-toc ()
  :tags
  '(issue4-closure)
  (org-texmacs-test--with-worker
   (let ((file (expand-file-name "headings.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:5 H:5 title:nil author:nil date:nil\n"
        "* FirstHeading\nBodyFirst [[*SecondHeading]]\n"
        "** ChildHeading\nBodyChild\n*** ThirdHeading\nBodyThird\n"
        "**** FourthHeading\nBodyFourth\n***** FifthHeading\nBodyFifth\n"
        "****** LowHeading\nBodyLow\n"
        "* SecondHeading\nBodySecond [[*FirstHeading]] [[*FourthHeading]] [[*FifthHeading]]\n"
        "* UnnumberedHeading\n:PROPERTIES:\n:UNNUMBERED: t\n:END:\nBodyUnnumbered\n")
       (org-texmacs-export-to-pdf-file (current-buffer) file))
     (let ((text (org-texmacs-test--pdf-text file)))
       (dolist (pattern
                '("1 FirstHeading"
                  "1\\.1 ChildHeading"
                  "1\\.1\\.1 ThirdHeading"
                  "1\\.1\\.1\\.1 FourthHeading"
                  "1\\.1\\.1\\.1\\.1 FifthHeading"
                  "BodyFirst 2"
                  "BodySecond 1 1\\.1\\.1\\.1 1\\.1\\.1\\.1\\.1"
                  "LowHeading BodyLow"
                  "UnnumberedHeading BodyUnnumbered"))
         (should (string-match-p pattern text)))
       (should
        (= 2
           (cl-count
            "FirstHeading"
            (split-string text "[^[:alnum:]]+" t)
            :test #'equal)))))))

(ert-deftest org-texmacs-pdf-date-literal-layout ()
  :tags
  '(issue4-closure)
  (org-texmacs-test--with-worker
   (let ((raw "<2026-10-14 Wed 15:30 +0800>")
         (actual (expand-file-name "date.pdf" test-directory))
         (reference
          (expand-file-name "date-reference.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil\n#+TITLE: DateTitle\n#+AUTHOR: DateAuthor\n"
        "#+DATE: "
        raw
        "\nDateBody\n")
       (let ((state
              (org-texmacs-test--document-buffer-state
               (current-buffer)))
             (document
              (org-texmacs-document-from-buffer (current-buffer))))
         (should
          (equal
           (org-texmacs--native-encode-document document)
           (org-texmacs-test--native-hex
            '(document
              (doc-data
               (doc-title "DateTitle")
               (doc-author (author-data (author-name "DateAuthor")))
               (doc-date "<less>2026-10-14 Wed 15:30 +0800<gtr>"))
              (concat "DateBody ")))))
         (org-texmacs-export-to-pdf-file (current-buffer) actual)
         (org-texmacs-document-save-pdf
          (org-texmacs--document-create
           :body
           `(document
             (doc-data
              (doc-title "DateTitle")
              (doc-author (author-data (author-name "DateAuthor")))
              (doc-date ,raw))
             (concat "DateBody ")))
          reference)
         (should
          (string-match-p
           (regexp-quote raw) (org-texmacs-test--pdf-text actual)))
         (let ((words (org-texmacs-test--pdf-words actual))
               (expected (org-texmacs-test--pdf-words reference)))
           (dolist (token
                    '("DateTitle" "DateAuthor" "DateBody" "+0800>"))
             (cl-mapc
              (lambda (a b) (should (<= (abs (- a b)) 1.0)))
              (org-texmacs-test--pdf-word words token)
              (org-texmacs-test--pdf-word expected token))))
         (should
          (equal
           state
           (org-texmacs-test--document-buffer-state
            (current-buffer)))))))))

(ert-deftest org-texmacs-pdf-block-quotation-and-center-layout ()
  :tags
  '(issue4)
  (org-texmacs-test--with-worker
   (let ((actual (expand-file-name "blocks.pdf" test-directory))
         (reference
          (expand-file-name "blocks-reference.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\nAnchorBefore\n\n"
        "#+begin_quote\nQuoteFirst\n\nQuoteSecond\n#+end_quote\n\n"
        "#+begin_center\nCenterShort\n\nCenterLongerContent\n#+end_center\n\n"
        "AnchorAfter\n")
       (org-texmacs-export-to-pdf-file (current-buffer) actual))
     (org-texmacs-document-save-pdf
      (org-texmacs--document-create
       :style '("generic")
       :body
       '(document
         (concat "AnchorBefore ")
         (quotation
          (document (concat "QuoteFirst ") (concat "QuoteSecond ")))
         (center
          (document
           (concat "CenterShort ") (concat "CenterLongerContent ")))
         (concat "AnchorAfter ")))
      reference)
     (let ((words (org-texmacs-test--pdf-words actual))
           (expected (org-texmacs-test--pdf-words reference)))
       (dolist (token
                '("AnchorBefore"
                  "QuoteFirst"
                  "QuoteSecond"
                  "CenterShort"
                  "CenterLongerContent"
                  "AnchorAfter"))
         (cl-mapc
          (lambda (a b) (should (<= (abs (- a b)) 1.0)))
          (org-texmacs-test--pdf-word words token)
          (org-texmacs-test--pdf-word expected token)))
       (let ((anchor
              (car
               (org-texmacs-test--pdf-word words "AnchorBefore"))))
         (dolist (token '("QuoteFirst" "QuoteSecond"))
           (should
            (> (car (org-texmacs-test--pdf-word words token))
               (+ anchor 1.0)))))
       (let ((short (org-texmacs-test--pdf-word words "CenterShort"))
             (long
              (org-texmacs-test--pdf-word
               words "CenterLongerContent")))
         (should
          (<= (abs
               (- (/ (+ (nth 0 short) (nth 2 short)) 2.0)
                  (/ (+ (nth 0 long) (nth 2 long)) 2.0)))
              1.0))))
     (let ((text (org-texmacs-test--pdf-text actual)))
       (should-not (string-match-p "\\bquote\\b" text))))))

(ert-deftest
    org-texmacs-pdf-table-alignment-frontend-and-native-layout
    ()
  :tags
  '(issue4)
  (org-texmacs-test--with-worker
   (let ((actual (expand-file-name "table.pdf" test-directory))
         (reference
          (expand-file-name "table-reference.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name
             (expand-file-name "table.org" test-directory))
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
        "#+begin_quote\nQuoteTableContext\n#+end_quote\n\n"
        "| LeftLongest | MiddleLongest | RightLongest |\n"
        "| <l> | <c> | <r> |\n| L | C | R |\n")
       (set-buffer-modified-p nil)
       (let ((before (buffer-string)))
         (let ((file (org-texmacs-export-to-texmacs)))
           (with-temp-buffer
             (insert-file-contents-literally file nil 0 32)
             (should (string-prefix-p "<TeXmacs|" (buffer-string)))))
         (should (equal actual (org-texmacs-export-to-pdf)))
         (should (equal before (buffer-string)))
         (should-not (buffer-modified-p))))
     (org-texmacs-document-save-pdf
      (org-texmacs--document-create
       :body
       '(document
         (quotation (document (concat "QuoteTableContext ")))
         (tabular
          (tformat
           (cwith "1" "-1" "1" "1" "cell-halign" "l")
           (cwith "1" "-1" "2" "2" "cell-halign" "c")
           (cwith "1" "-1" "3" "3" "cell-halign" "r")
           (table
            (row
             (cell "LeftLongest")
             (cell "MiddleLongest")
             (cell "RightLongest"))
            (row (cell "L") (cell "C") (cell "R")))))))
      reference)
     (let ((words (org-texmacs-test--pdf-words actual))
           (expected (org-texmacs-test--pdf-words reference)))
       (dolist (token
                '("QuoteTableContext"
                  "LeftLongest"
                  "MiddleLongest"
                  "RightLongest"
                  "L"
                  "C"
                  "R"))
         (cl-mapc
          (lambda (a b) (should (<= (abs (- a b)) 1.0)))
          (org-texmacs-test--pdf-word words token)
          (org-texmacs-test--pdf-word expected token)))
       (dolist (column
                '(("LeftLongest" "L" left)
                  ("MiddleLongest" "C" center)
                  ("RightLongest" "R" right)))
         (let* ((a (org-texmacs-test--pdf-word words (nth 0 column)))
                (b (org-texmacs-test--pdf-word words (nth 1 column)))
                (position
                 (lambda (bounds)
                   (pcase (nth 2 column)
                     ('left (nth 0 bounds))
                     ('right (nth 2 bounds))
                     (_ (/ (+ (nth 0 bounds) (nth 2 bounds)) 2.0))))))
           (should
            (<= (abs (- (funcall position a) (funcall position b)))
                1.0))))))))

(ert-deftest org-texmacs-pdf-footnote-text-and-repeated-markers ()
  (org-texmacs-test--with-worker
   (let ((file (expand-file-name "footnotes.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil\nFirst[fn:n] Repeat[fn:n] Anonymous[fn::AnonymousBodySentinel].\n\n"
        "[fn:n] NamedBodySentinel.\n")
       (org-texmacs-export-to-pdf-file (current-buffer) file))
     (let ((text (org-texmacs-test--pdf-text file)))
       (dolist (marker
                '("First *1\\b" "Repeat *1\\b" "Anonymous *2\\b"))
         (should (string-match-p marker text)))
       (dolist (body '("NamedBodySentinel" "AnonymousBodySentinel"))
         (should
          (= 1
             (cl-count
              body
              (split-string text "[^[:alnum:]]+" t)
              :test #'equal))))))))

(ert-deftest org-texmacs-pdf-citation-text-and-owned-bibliography ()
  (org-texmacs-test--with-worker
   (let ((file (expand-file-name "citations.pdf" test-directory)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+bibliography: refs.bib\n"
        "Group [cite:@a; @b]. Repeat [cite:@a]. Detail [cite:@a, chapter 1].\n\n#+print_bibliography:\n")
       (org-texmacs-document-save-pdf
        (org-texmacs-test--native-bib-document
         (org-texmacs-parse-buffer (current-buffer))
         "@book{a, author={Ada Alpha}, title={FirstTitleSentinel}, year=2024, publisher={Example}}\n@book{b, author={Bob Beta}, title={SecondTitleSentinel}, year=2025, publisher={Example}}\n@book{unused, title={UnusedTitleSentinel}}")
        file))
     (let ((text (org-texmacs-test--pdf-text file)))
       (should (string-match-p "Group *\\[1, *2\\]" text))
       (should (string-match-p "Repeat *\\[1\\]" text))
       (should (string-match-p "Detail *\\[1, *chapter 1\\]" text))
       (dolist (title '("FirstTitleSentinel" "SecondTitleSentinel"))
         (should
          (= 1
             (cl-count
              title
              (split-string text "[^[:alnum:]]+" t)
              :test #'equal))))
       (should-not (string-match-p "UnusedTitleSentinel" text))))))

(ert-deftest org-texmacs-pdf-native-citation-detail-and-reload ()
  (org-texmacs-test--with-worker
   (let ((bib (expand-file-name "detail.bib" test-directory))
         (org-texmacs-document-style '("generic"))
         (org-export-use-babel nil))
     (with-temp-file bib
       (insert
        "@book{key,author={Ada Alpha},title={ReferencePayload},year={2024},publisher={Example}}\n"))
     (dolist (style '("plain" "alpha" "abbrv"))
       (let* ((directory
               (make-temp-file (expand-file-name "detail-"
                                                 test-directory)
                               t))
              (pdf (expand-file-name "direct.pdf" directory))
              (tm (expand-file-name "saved.tm" directory))
              (reload (expand-file-name "reload.pdf" directory)))
         (with-temp-buffer
           (org-mode)
           (insert
            "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
            "#+bibliography: "
            bib
            "\n#+cite_export: texmacs-native "
            style
            "\nBare [cite:@key]. Detailed [cite:@key, chapter 1].\n"
            "\n#+begin_texmacs\n(new-page)\n#+end_texmacs\n\n#+print_bibliography:\n")
           (let ((document
                  (org-texmacs-document-from-buffer
                   (current-buffer))))
             (org-texmacs-document-save document tm)
             (org-texmacs-document-save-pdf document pdf)))
         (org-texmacs-test--pdf-render-from-saved-tm
          tm reload directory)
         (should
          (equal
           (org-texmacs-test--pdf-text pdf)
           (org-texmacs-test--pdf-text reload)))
         (dolist (file (list pdf reload))
           (let* ((text (org-texmacs-test--pdf-text file))
                  (inspection
                   (org-texmacs-test--pdf-note-inspect file))
                  (reference
                   (org-texmacs-test--pdf-note-text
                    inspection "ReferencePayload"))
                  (page (alist-get 'page reference))
                  (citations
                   (cl-remove-if-not
                    (lambda (link)
                      (let ((target (alist-get 'target link)))
                        (and target
                             (= (alist-get 'page target) page)
                             (< (alist-get 'page link) page))))
                    (alist-get 'links inspection))))
             (should (string-match "Bare *\\[\\([^],]+\\)\\]" text))
             (let ((label (match-string 1 text)))
               (should
                (string-match-p
                 (concat
                  "Detailed *\\["
                  (regexp-quote label)
                  ", *chapter 1\\]")
                 text)))
             (should-not (string-match-p "[?]\\|\\[cite:" text))
             (should (> page 1))
             (should (>= (length citations) 2)))))))))

(ert-deftest org-texmacs-pdf-native-basic ()
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "pdf-diagnostics.scm" test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(define test-render org-texmacs-render-native-pdf)\n"
        "(set! org-texmacs-render-native-pdf (lambda (native)\n"
        "  (catch #t (lambda () (test-render native))\n"
        "    (lambda args (display \"PDF-DIAGNOSTIC: \") (write args)\n"
        "      (newline) (force-output) (apply throw args)))))\n"))
     (let ((org-texmacs--worker-scheme-file script))
       (condition-case err
           (let ((bytes
                  (org-texmacs-document-pdf
                   (org-texmacs--document-create
                    :body '(document "Hello native PDF")))))
             (should-not (multibyte-string-p bytes))
             (should (string-prefix-p "%PDF-" bytes))
             (should (> (length bytes) 1000)))
         (error
          (when (buffer-live-p org-texmacs--worker-buffer)
            (princ
             (with-current-buffer org-texmacs--worker-buffer
               (buffer-string))))
          (signal (car err) (cdr err))))))))

(ert-deftest org-texmacs-pdf-native-session-and-inspection ()
  (org-texmacs-test--with-worker
   (let ((session (org-texmacs-session-open))
         (file (expand-file-name "native.pdf" test-directory)))
     (unwind-protect
         (progn
           (org-texmacs-session-set-document
            session
            (org-texmacs--document-create
             :body '(document "Existing session")))
           (let
               ((state (org-texmacs--session-read-document session))
                (process org-texmacs--worker-process)
                (document
                 (with-temp-buffer
                   (org-mode)
                   (insert
                    "#+OPTIONS: toc:nil\n* Heading\n"
                    "Section [[*Heading]]. Literal <alpha>. Café.\n\n"
                    "#+name: t\n#+caption: Table caption\n| a | b |\n\nTable [[t]].\n")
                   (org-texmacs-document-from-buffer
                    (current-buffer)))))
             (should
              (equal
               file (org-texmacs-document-save-pdf document file)))
             (should-not
              (directory-files org-texmacs--worker-directory
                               nil "\\`render-.*\\.pdf\\'"))
             (should (eq process org-texmacs--worker-process))
             (should
              (equal
               state (org-texmacs--session-read-document session)))
             (should-error
              (org-texmacs-document-save-pdf document file)
              :type 'file-already-exists)
             (let ((info (executable-find "pdfinfo"))
                   (text (executable-find "pdftotext")))
               (should info)
               (should text)
               (when info
                 (with-temp-buffer
                   (should (= 0 (call-process info nil t nil file)))
                   (should
                    (re-search-backward "Pages: +[1-9][0-9]*"
                                        nil
                                        t))))
               (when text
                 (with-temp-buffer
                   (let ((coding-system-for-read 'utf-8-unix))
                     (should
                      (= 0 (call-process text nil t nil file "-"))))
                   (dolist (value
                            '("Heading"
                              "Literal <alpha>"
                              "Café"
                              "Table caption"
                              "Section 1"
                              "Table 1"))
                     (should
                      (string-match-p
                       (regexp-quote value) (buffer-string)))))))))
       (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-pdf-hyperlink-annotations ()
  :tags
  '(pdf-links)
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (let* ((stem (expand-file-name style test-directory))
            (tm (concat stem ".tm"))
            (pdf (concat stem ".pdf"))
            (again (concat stem "-again.pdf"))
            (reload (concat stem "-reload.pdf"))
            (uri (concat "https://example.org/" style))
            document)
       (with-temp-buffer
         (org-mode)
         (insert
          "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
          "[["
          uri
          "][ExternalLink]]\n\nSee [[*Target][InternalLink]].\n\n"
          "#+begin_texmacs\n(new-page)\n#+end_texmacs\n\n"
          "* Target\nTargetBody\n")
         (let ((org-texmacs-document-style (list style))
               (before
                (org-texmacs-test--document-buffer-state
                 (current-buffer))))
           (setq document
                 (org-texmacs-document-from-buffer (current-buffer)))
           (should
            (equal
             before
             (org-texmacs-test--document-buffer-state
              (current-buffer))))))
       ;; Consume owned input after its source buffer has been destroyed.
       (org-texmacs-document-save document tm)
       (org-texmacs-document-save-pdf document pdf)
       (org-texmacs-document-save-pdf document again)
       (dolist (file (list pdf again))
         (let ((links (org-texmacs-test--pdf-links file)))
           (should (equal uri (cdr (assoc "ExternalLink" links))))
           (should
            (string-suffix-p
             ".html#2" (cdr (assoc "InternalLink" links))))
           (should-not (assoc "TargetBody" links))))
       (org-texmacs-test--pdf-render-from-saved-tm
        tm reload test-directory)
       (let ((links (org-texmacs-test--pdf-links reload)))
         (should (equal uri (cdr (assoc "ExternalLink" links))))
         (should
          (string-suffix-p
           ".html#2" (cdr (assoc "InternalLink" links)))))
       (should-not
        (directory-files org-texmacs--worker-directory
                         nil
                         "\\`render-.*\\.pdf\\'"))))))

(ert-deftest org-texmacs-pdf-file-link-policies ()
  :tags
  '(pdf-links)
  (org-texmacs-test--with-worker
   (dolist (absolute '(nil t))
     (dolist (pdf '(nil t))
       (let*
           ((document
             (org-texmacs--document-create
              :body
              '(document
                (concat (hlink "Org" "./article.ORG") " ")
                (concat (hlink "Parent" "../peer.org") " ")
                (concat (hlink "Space" "space name.org") " ")
                (concat (hlink "Unicode" "子/é.org") " ")
                (concat
                 (hlink "Absolute" "/absolute/article.org") " ")
                (concat
                 (hlink "URI" "https://example.org/file.org") " ")
                (concat (hlink "Native" "native.org") " "))
              :resource-base "/captured/source/"
              :file-paths '((0 0 1) (1 0 1) (2 0 1) (3 0 1) (4 0 1))
              :stm-paths '((6 0))
              :pdf-file-links-as-absolute absolute
              :link-org-files-as-pdf pdf))
            (before (copy-tree (org-texmacs-document-body document)))
            (file
             (expand-file-name (format "links-%s-%s.pdf" absolute pdf)
                               test-directory))
            (relative
             (if pdf
                 '("./article.pdf"
                   "../peer.pdf"
                   "space name.pdf"
                   "子/é.pdf"
                   "/absolute/article.pdf")
               '("./article.ORG"
                 "../peer.org"
                 "space name.org"
                 "子/é.org"
                 "/absolute/article.org")))
            (expected
             (append
              (if absolute
                  (mapcar
                   (lambda (path)
                     (expand-file-name path "/captured/source/"))
                   relative)
                relative)
              '("https://example.org/file.org" "native.org")))
            ;; Completed document policies, not consumer-time globals, decide.
            (org-texmacs-pdf-file-links-as-absolute (not absolute))
            (org-texmacs-link-org-files-as-pdf (not pdf)))
         (org-texmacs-document-save-pdf document file)
         (should
          (equal
           expected
           (mapcar
            (lambda (link) (alist-get 'uri link))
            (alist-get
             'links (org-texmacs-test--pdf-note-inspect file t)))))
         (should (equal before (org-texmacs-document-body document)))
         ;; A serialized native document intentionally retains absolute targets.
         (when (and (not absolute) pdf)
           (let ((tm
                  (expand-file-name "links-native.tm" test-directory))
                 (reload
                  (expand-file-name "links-native-reload.pdf"
                                    test-directory)))
             (org-texmacs-document-save document tm)
             (org-texmacs-test--pdf-render-from-saved-tm
              tm reload test-directory)
             (should
              (equal
               (append
                (mapcar
                 (lambda (path)
                   (expand-file-name path "/captured/source/"))
                 relative)
                '("https://example.org/file.org" "native.org"))
               (mapcar
                (lambda (link) (alist-get 'uri link))
                (alist-get
                 'links
                 (org-texmacs-test--pdf-note-inspect
                  reload t))))))))))))

(ert-deftest org-texmacs-pdf-derived-link-targets ()
  :tags
  '(pdf-adjacent)
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (dolist (long '(nil t))
       (let ((file
              (expand-file-name (format "%s-%s.pdf" style long)
                                test-directory)))
         (with-temp-buffer
           (org-mode)
           (insert (org-texmacs-test--adjacent-source long))
           (let ((org-texmacs-document-style (list style))
                 (state
                  (org-texmacs-test--document-buffer-state
                   (current-buffer))))
             (org-texmacs-document-save-pdf
              (org-texmacs-test--native-bib-document
               (org-texmacs-parse-buffer (current-buffer))
               org-texmacs-test--adjacent-bib
               t
               (list style))
              file)
             (should
              (equal
               state
               (org-texmacs-test--document-buffer-state
                (current-buffer))))))
         (org-texmacs-test--adjacent-pdf-targets file))))))

(ert-deftest org-texmacs-pdf-footnote-forward-backward-and-repeats ()
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (dolist
         (fixture
          '(("anonymous"
             "FirstAnon[fn::AnonBodyA] SecondAnon[fn::AnonBodyB]\n"
             (("FirstAnon" . "AnonBodyA")
              ("SecondAnon" . "AnonBodyB")
              ("AnonBodyA" . "FirstAnon")
              ("AnonBodyB" . "SecondAnon")))
            ("named-cross-page"
             "FirstNamed[fn:a].\n\n#+begin_texmacs\n(new-page)\n#+end_texmacs\n\nAgainNamed[fn:a].\n\nSecondPage[fn::CrossBody].\n\n[fn:a] NamedBody.\n"
             (("FirstNamed" . "NamedBody")
              ("AgainNamed" . "NamedBody")
              ("NamedBody" . "FirstNamed")
              ("SecondPage" . "CrossBody")
              ("CrossBody" . "SecondPage")))
            ("markup"
             "MarkupFirst[fn::MarkupBody *BoldNote* and /ItalicNote/].\n"
             (("MarkupFirst" . "MarkupBody")
              ("MarkupBody" . "MarkupFirst")))))
       (with-temp-buffer
         (org-mode)
         (insert
          "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
          (nth 1 fixture))
         (let* ((org-texmacs-document-style (list style))
                (state
                 (org-texmacs-test--document-buffer-state
                  (current-buffer)))
                (input (org-texmacs-prepare-buffer (current-buffer)))
                (document (org-texmacs-document input))
                (before (org-texmacs-document-serialize document))
                inspections)
           (dotimes (repeat 3)
             (let ((file
                    (expand-file-name (format "%s-%s-%d.pdf"
                                              style
                                              (car fixture)
                                              repeat)
                                      test-directory)))
               (cond
                ((= repeat 1)
                 (org-texmacs-export-to-pdf-file
                  (current-buffer) file))
                ((and (= repeat 2) (equal (car fixture) "anonymous"))
                 (let ((buffer-file-name
                        (concat
                         (file-name-sans-extension file) ".org")))
                   (org-texmacs-export-to-pdf)))
                (t
                 (org-texmacs-document-save-pdf document file)))
               (let ((inspection
                      (org-texmacs-test--pdf-note-inspect file)))
                 (should
                  (= (length (nth 2 fixture))
                     (length (alist-get 'links inspection))))
                 (dolist (edge (nth 2 fixture))
                   (org-texmacs-test--pdf-note-edge
                    inspection (car edge) (cdr edge)))
                 (when (equal (car fixture) "named-cross-page")
                   (should
                    (< (alist-get
                        'page
                        (org-texmacs-test--pdf-note-text
                         inspection "NamedBody"))
                       (alist-get
                        'page
                        (org-texmacs-test--pdf-note-text
                         inspection "AgainNamed")))))
                 (push inspection inspections)))
             (should
              (equal
               state
               (org-texmacs-test--document-buffer-state
                (current-buffer))))
             (should
              (equal
               before (org-texmacs-document-serialize document)))
             (should (equal document (org-texmacs-document input)))
             (should-not
              (directory-files org-texmacs--worker-directory
                               nil "\\`render-.*\\.pdf\\'")))
           (should
            (cl-every
             (lambda (item)
               (equal item (car inspections)))
             inspections))))))))

(ert-deftest org-texmacs-pdf-footnote-private-state-and-error-cleanup
    ()
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "footnote-isolation.scm" test-directory))
         (closed (expand-file-name "closed" test-directory))
         (guard-pdf (expand-file-name "guard.pdf" test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(define original-install org-texmacs-pdf-install-footnote-anchors)\n"
        "(define installs 0)\n"
        "(set! org-texmacs-pdf-install-footnote-anchors (lambda (native)\n"
        " (set! installs (+ installs 1))\n"
        " (if (= installs 3) #f\n"
        "  (let ((changed (original-install native)))\n"
        "   (if (not changed) (error \"Expected private macro override\"))\n"
        "   (if (= installs 1) (error \"Injected after macro override\")) changed))))\n"
        "(define original-close buffer-close)\n(define closed-count 0)\n"
        "(set! buffer-close (lambda (b) (original-close b)\n"
        " (set! closed-count (+ closed-count 1))\n"
        (format
         " (string-save (number->string closed-count) (system->url %s))))\n"
         (org-texmacs--scheme-string closed))
        "(define (guard-state)\n (org-texmacs-with-session-buffer (lambda ()\n"
        " (do ((i 0 (+ i 1))) ((= i 3)) (update-current-buffer)) (update-forced)\n"
        (format " (print-to-file (system->url %s))\n"
                (org-texmacs--scheme-string guard-pdf))
        " (list (org-texmacs-native-readback) (tree->stree (get-env-tree \"render-footnote*\"))))))\n"
        "(define original-render org-texmacs-render-native-pdf)\n"
        "(set! org-texmacs-render-native-pdf (lambda (native)\n"
        " (let ((before (guard-state)) (result #f) (failure #f))\n"
        "  (catch #t (lambda () (set! result (original-render native)))\n"
        "   (lambda args (set! failure args)))\n"
        "  (if (not (equal? before (guard-state))) (error \"Session/macro leak\"))\n"
        "  (if failure (apply throw failure)) result)))\n"))
     (let* ((org-texmacs--worker-scheme-file script)
            (guard
             (org-texmacs--document-create
              :body '(document "GuardSentinel")
              :style '("article")
              :initial
              '(("render-footnote*" .
                 (macro "sym" "nr" "body" "GuardMacro")))))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session guard)
             (let ((state (org-texmacs--session-read session))
                   (process org-texmacs--worker-process)
                   (failed
                    (expand-file-name "failed.pdf" test-directory))
                   document)
               (with-temp-buffer
                 (org-mode)
                 (insert
                  "#+OPTIONS: toc:nil title:nil author:nil date:nil\nFirstSafe[fn::SafeBody].\n")
                 (setq document
                       (org-texmacs-document-from-buffer
                        (current-buffer))))
               (should-error
                (org-texmacs-document-save-pdf document failed)
                :type 'org-texmacs-rendering-error)
               (should-not (file-exists-p failed))
               (should
                (equal state (org-texmacs--session-read session)))
               (should-not
                (directory-files org-texmacs--worker-directory
                                 nil "\\`render-.*\\.pdf\\'"))
               (let ((file
                      (expand-file-name "recovered.pdf"
                                        test-directory)))
                 (org-texmacs-document-save-pdf document file)
                 (let ((inspection
                        (org-texmacs-test--pdf-note-inspect file)))
                   (org-texmacs-test--pdf-note-edge
                    inspection "FirstSafe" "SafeBody")
                   (org-texmacs-test--pdf-note-edge
                    inspection "SafeBody" "FirstSafe")))
               ;; The third request bypasses the installer in this test process.
               ;; Missing targets again prove that no global macro was modified.
               (let ((file
                      (expand-file-name "unpatched.pdf"
                                        test-directory)))
                 (org-texmacs-document-save-pdf document file)
                 (should
                  (cl-some
                   (lambda (link) (null (alist-get 'target link)))
                   (alist-get
                    'links
                    (org-texmacs-test--pdf-note-inspect file)))))
               (should
                (equal state (org-texmacs--session-read session)))
               (should (eq process org-texmacs--worker-process))
               (should-not
                (directory-files org-texmacs--worker-directory
                                 nil "\\`render-.*\\.pdf\\'"))
               (should
                (equal
                 (with-temp-buffer
                   (insert-file-contents closed)
                   (buffer-string))
                 "3"))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-pdf-footnote-explicit-macro-preserved ()
  (org-texmacs-test--with-worker
   (dolist (entry
            '(("footnote" .
               (macro "body" (concat "OverrideBody " (arg "body"))))
              ("render-footnote" .
               (macro
                "nr" "body" (concat "OverrideBody " (arg "body"))))
              ("render-footnote*" .
               (macro
                "sym"
                "nr"
                "body"
                (concat "OverrideBody " (arg "body"))))))
     (with-temp-buffer
       (org-mode)
       (insert "CustomFirst[fn::CustomNote].\n")
       (let* ((org-texmacs-document-initial (list entry))
              (document
               (org-texmacs-document-from-buffer (current-buffer)))
              (before (org-texmacs-document-serialize document))
              (file
               (expand-file-name (concat (car entry) ".pdf")
                                 test-directory)))
         (org-texmacs-document-save-pdf document file)
         (should
          (string-match-p
           "OverrideBody" (org-texmacs-test--pdf-text file)))
         (should
          (equal
           before (org-texmacs-document-serialize document))))))))

(ert-deftest org-texmacs-pdf-typeset-error-recovery ()
  :tags
  '(pdf-links)
  (dolist (failed-update '(1 2))
    (org-texmacs-test--with-worker
     (let ((script
            (expand-file-name "typeset-failure.scm" test-directory)))
       (with-temp-file script
         (insert
          (format "(load %s)\n"
                  (org-texmacs--scheme-string
                   org-texmacs--worker-scheme-file))
          "(define original-update update-forced)\n"
          "(define update-count 0)\n"
          "(set! update-forced (lambda ()\n"
          "  (set! update-count (+ update-count 1))\n"
          (format
           "  (if (= update-count %d) (error \"Injected layout failure\")\n"
           failed-update)
          "      (original-update))))\n"))
       (let* ((org-texmacs--worker-scheme-file script)
              (document
               (org-texmacs--document-create
                :body '(document "Text")))
              (session (org-texmacs-session-open)))
         (unwind-protect
             (progn
               (org-texmacs-session-set-document session document)
               (let ((state
                      (org-texmacs--session-read-document session))
                     (process org-texmacs--worker-process))
                 (should-error
                  (org-texmacs-document-pdf document)
                  :type 'org-texmacs-rendering-error)
                 (should (org-texmacs--worker-live-p))
                 (should-not
                  (directory-files org-texmacs--worker-directory
                                   nil "\\`render-.*\\.pdf\\'"))
                 (should
                  (equal
                   state
                   (org-texmacs--session-read-document session)))
                 (should
                  (string-prefix-p
                   "%PDF-" (org-texmacs-document-pdf document)))
                 (should (eq process org-texmacs--worker-process))))
           (org-texmacs-session-close session)))))))

(ert-deftest org-texmacs-pdf-render-error-recovery ()
  (dolist (failed-print '(1 2))
    (org-texmacs-test--with-worker
     (let ((script
            (expand-file-name "pdf-failure.scm" test-directory)))
       (with-temp-file script
         (insert
          (format "(load %s)\n"
                  (org-texmacs--scheme-string
                   org-texmacs--worker-scheme-file))
          "(define original-printer print-to-file)\n"
          "(define print-count 0)\n"
          "(set! print-to-file (lambda (file)\n"
          "  (set! print-count (+ print-count 1))\n"
          (format
           "  (if (= print-count %d) (error \"Injected printer failure\")\n"
           failed-print)
          "      (original-printer file))))\n"))
       (let* ((org-texmacs--worker-scheme-file script)
              (document
               (org-texmacs--document-create
                :body '(document "Text")))
              (session (org-texmacs-session-open)))
         (unwind-protect
             (progn
               (org-texmacs-session-set-document session document)
               (let ((state
                      (org-texmacs--session-read-document session))
                     (process org-texmacs--worker-process))
                 (should-error
                  (org-texmacs-document-pdf document)
                  :type 'org-texmacs-rendering-error)
                 (should (org-texmacs--worker-live-p))
                 (should-not
                  (directory-files org-texmacs--worker-directory
                                   nil "\\`render-.*\\.pdf\\'"))
                 (should
                  (equal
                   state
                   (org-texmacs--session-read-document session)))
                 (should
                  (string-prefix-p
                   "%PDF-" (org-texmacs-document-pdf document)))
                 (should (eq process org-texmacs--worker-process))))
           (org-texmacs-session-close session)))))))

(ert-deftest org-texmacs-pdf-explicit-source-export ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "PDF from explicit source.\n")
     (let ((source (current-buffer))
           (file (expand-file-name "interactive.pdf" test-directory)))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (ert-fail "Explicit PDF API prompted"))))
         (should
          (equal file (org-texmacs-export-to-pdf-file source file))))
       (should (eq source (current-buffer)))
       (with-temp-buffer
         (set-buffer-multibyte nil)
         (insert-file-contents-literally file)
         (should (string-prefix-p "%PDF-" (buffer-string))))))))

(ert-deftest org-texmacs-pdf-citation-contexts-and-reload ()
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (dolist (toc '(nil t))
       (let* ((directory
               (make-temp-file (expand-file-name "citations-"
                                                 test-directory)
                               t))
              (org-texmacs-document-style (list style))
              (pdf (expand-file-name "direct.pdf" directory))
              (tm (expand-file-name "saved.tm" directory))
              (reload (expand-file-name "reload.pdf" directory)))
         (with-temp-buffer
           (org-mode)
           (insert
            (format
             "#+OPTIONS: toc:%s title:nil author:nil date:nil\n"
             (if toc
                 "t"
               "nil"))
            "#+bibliography: refs.bib\n"
            "* HeadingProbe [cite:@key]\n:PROPERTIES:\n:ALT_TITLE: AlternateProbe [cite:@key]\n:END:\n"
            "*BoldProbe [cite:@key] text*. /ItalicProbe [cite:@key] text/.\n"
            "_UnderlineProbe [cite:@key] text_. +StrikeProbe [cite:@key] text+.\n\n"
            "#+CAPTION: CaptionProbe [cite:@key]\n| CellProbe [cite:@key] | other |\n\n"
            "#+begin_texmacs\n(new-page)\n#+end_texmacs\n\n#+print_bibliography:\n")
           (let
               ((document
                 (org-texmacs-test--native-bib-document
                  (org-texmacs-parse-buffer (current-buffer))
                  "@book{key,author={Ada Alpha},title={ReferencePayload},year=2024,publisher={Example}}"
                  toc
                  (list style)
                  (org-element-parse-secondary-string
                   "AlternateProbe [cite:@key]"
                   (org-element-restriction 'headline)))))
             (org-texmacs-document-save document tm)
             (org-texmacs-document-save-pdf document pdf)))
         (org-texmacs-test--pdf-render-from-saved-tm
          tm reload directory)
         (should
          (equal
           (org-texmacs-test--pdf-text pdf)
           (org-texmacs-test--pdf-text reload)))
         (dolist (file (list pdf reload))
           (let* ((text (org-texmacs-test--pdf-text file))
                  (inspection
                   (org-texmacs-test--pdf-note-inspect file))
                  (reference
                   (org-texmacs-test--pdf-note-text
                    inspection "ReferencePayload"))
                  (page (alist-get 'page reference))
                  (links (alist-get 'links inspection))
                  (citations
                   (cl-remove-if-not
                    (lambda (link)
                      (let ((target (alist-get 'target link)))
                        (and target
                             (= (alist-get 'page target) page)
                             (< (alist-get 'page link) page))))
                    links)))
             (should (> page 1))
             (should-not (string-match-p "[?]\\|\\[cite:" text))
             (dolist (word
                      '("HeadingProbe"
                        "BoldProbe"
                        "ItalicProbe"
                        "UnderlineProbe"
                        "StrikeProbe"
                        "CaptionProbe"
                        "CellProbe"))
               (should (string-match-p word text)))
             (should
              (eq (and (string-match-p "AlternateProbe" text) t) toc))
             ;; Heading and TOC navigation must coexist with citation links to
             ;; the bibliography on a different page, including after reload.
             (should
              (>= (length citations)
                  (if toc
                      8
                    7)))
             (should
              (cl-every
               (lambda (link) (alist-get 'target link)) links)))))))))

(ert-deftest org-texmacs-pdf-external-id-link-policies ()
  :tags
  '(pdf-links)
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-id-files
    (concat
     "#+TITLE: Source\n#+OPTIONS: toc:nil title:nil author:nil date:nil\n\n"
     "External [[id:target-file-id][File target]].\n"
     "Headline [[id:target-headline-id][Headline target]].\n")
    (with-temp-buffer
      (org-mode)
      (insert source-text)
      (setq
       buffer-file-name source
       default-directory (file-name-directory source))
      ;; Default file-link policies: .org -> .pdf, PDF targets stay relative.
      (let ((org-texmacs-link-org-files-as-pdf t)
            (org-texmacs-pdf-file-links-as-absolute nil))
        (let*
            ((document
              (org-texmacs-document-from-buffer (current-buffer)))
             (before (copy-tree (org-texmacs-document-body document)))
             ;; The output PDF sits next to the source Org file, so the
             ;; relative target is consistent with the output location.
             (file
              (expand-file-name "external-id.pdf"
                                (file-name-directory source))))
          ;; The target PDF is not built or checked for existence.
          (should-not
           (file-exists-p
            (expand-file-name "target.pdf"
                              (file-name-directory target))))
          ;; The structural document retains the source .org target.
          (should
           (member
            "../target/target.org"
            (flatten-tree (org-texmacs-document-body document))))
          (org-texmacs-document-save-pdf document file)
          (should (file-exists-p file))
          (let ((links
                 (alist-get
                  'links
                  (org-texmacs-test--pdf-note-inspect file t))))
            ;; Described hlinks render one annotation per text run.
            (should (>= (length links) 2))
            (dolist (link links)
              (should
               (equal "../target/target.pdf" (alist-get 'uri link)))))
          (should
           (equal before (org-texmacs-document-body document)))))))))

;;; ert-pdf-pdf.el ends here
