;;; special-blocks.el --- pdf special-blocks regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-issue13-stage4-native-label-placements ()
  ;; Independent native controls: no Org preparation or document lowering.
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (let* ((roots
             '("x"
               (frac "1" "2")
               (concat "x+" "y")
               (with "color" "red" "x")))
            (table
             '(tabular (tformat (table (row (cell "CellBody"))))))
            (index 0)
            targets
            links)
       (cl-labels
        ((add
          (builder)
          (let* ((id (format "stage4-native-%d" (cl-incf index)))
                 (text (format "Jump%d" index)))
            (push (funcall builder id) targets)
            (push `(hlink ,text ,(concat "#" id)) links)
            (push " " links)
            (push `(reference ,id) links)
            (push " " links))))
        (dolist (root roots)
          (dolist (tag '(equation equation*))
            (add (lambda (id) `(,tag (concat (label ,id) ,root))))))
        (dolist (tag org-texmacs--document-statement-tags)
          (add
           (lambda (id)
             `(,tag (document (label ,id) "StatementBody")))))
        (add
         (lambda (id)
           `(theorem
             (document
              (label ,id)
              (lemma
               (document (label "nested-lemma") "NestedBody"))))))
        (dolist (tag '(big-table big-table* big-figure big-figure*))
          (dolist (caption
                   '("" "CaptionBody"
                     (caption-detailed "LongCaption" "ShortCaption")))
            (add
             (lambda (id)
               `(,tag
                 ,(if (memq tag '(big-table big-table*))
                      table
                    org-texmacs-test--issue13-stage3-graphic)
                 (surround (label ,id) "" ,caption))))))
        (dolist (root
                 '("RawBody"
                   (math "x")
                   (document "RawDocument")
                   (with "color" "red" "RawWith")))
          (add (lambda (id) `(surround (label ,id) "" ,root)))))
       (let* ((body
               `(document
                 (concat ,@ (nreverse links))
                 (new-page)
                 ,@
                 (nreverse targets)))
              (document
               (org-texmacs--document-create
                :body body
                :style (list style)))
              (tm
               (expand-file-name (concat style "-stage4-native.tm")
                                 test-directory))
              (pdf
               (expand-file-name (concat style "-stage4-native.pdf")
                                 test-directory))
              (reload
               (expand-file-name (concat style "-stage4-reload.pdf")
                                 test-directory))
              (session (org-texmacs-session-open)))
         (unwind-protect
             (progn
               (org-texmacs-session-set-document session document)
               (should
                (equal
                 (org-texmacs--session-read session)
                 (org-texmacs-test--native-hex body))))
           (org-texmacs-session-close session))
         (org-texmacs-document-save document tm)
         (org-texmacs-document-save-pdf document pdf)
         (org-texmacs-test--issue11-reload-pdf
          tm reload test-directory)
         (dolist (file (list pdf reload))
           ;; Only the first, numbered equation has a required numeric value.
           (should
            (string-match-p
             "Jump1 1" (org-texmacs-test--pdf-text file))))
         (dolist (file (list pdf reload))
           (let* ((tree (org-texmacs-test--pdf-link-tree file))
                  (pages
                   (mapcar
                    (lambda (page)
                      (dom-attr page 'number))
                    (dom-by-tag tree 'page)))
                  (actual (org-texmacs-test--pdf-links file)))
             (dotimes (i index)
               (let* ((text (format "Jump%d" (1+ i)))
                      (destination
                       (cdr
                        (cl-find-if
                         (lambda (entry)
                           (string-match-p
                            (concat "\\b" text "\\b") (car entry)))
                         actual))))
                 (ert-info
                  ((format "%s %s: %S" style text actual))
                  (should destination)
                  (should
                   (string-match
                    "\\.html#\\([0-9]+\\)\\'" destination))
                  (should
                   (member (match-string 1 destination) pages)))))))
         (org-texmacs-test--issue11-compare-pdfs pdf reload))))))

(ert-deftest
    org-texmacs-issue13-stage4-exporter-native-links-and-provenance
    ()
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (let (input
           document)
       (with-temp-buffer
         (org-mode)
         (insert
          "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
          "[[Eq][JumpEquation]] [[Proof][JumpProof]] [[Figure][JumpFigure]] "
          "[[Table][JumpTable]] [[Raw][JumpRaw]]\n\n"
          "#+begin_texmacs\n(new-page)\n#+end_texmacs\n"
          (org-texmacs-test--stage4-block "equation" "Eq")
          (org-texmacs-test--stage4-block "proof" "Proof")
          (org-texmacs-test--stage4-block
           "figure" "Figure" "FigureCaption")
          (org-texmacs-test--stage4-block
           "table"
           "Table"
           "TableCaption [[Eq][CaptionLink]] [[file:asset.pdf][File]]")
          (org-texmacs-test--stage4-block "texmacs" "Raw")
          "Body[fn::Note [[Eq][NoteLink]]].\n")
         (let ((org-texmacs-document-style (list style))
               (source (buffer-string)))
           (setq
            input (org-texmacs-prepare-buffer (current-buffer))
            document (org-texmacs-document input))
           (should (equal source (buffer-string)))))
       (should (equal document (org-texmacs-document input)))
       (let* ((body (org-texmacs-document-body document))
              (tm
               (expand-file-name (concat style "-stage4-export.tm")
                                 test-directory))
              (pdf
               (expand-file-name (concat style "-stage4-export.pdf")
                                 test-directory))
              (reload
               (expand-file-name (concat
                                  style "-stage4-export-reload.pdf")
                                 test-directory))
              (session (org-texmacs-session-open)))
         (should
          (= 4 (length (org-texmacs-document-stm-paths document))))
         (should
          (= 1 (length (org-texmacs-document-file-paths document))))
         (unwind-protect
             (progn
               (org-texmacs-session-set-document session document)
               (let*
                   ((expected (copy-tree body))
                    (file
                     (cl-find-if
                      (lambda (link) (equal (cadr link) "File"))
                      (org-texmacs-test--caption-inline-footnote-nodes
                       expected 'hlink))))
                 (setcar
                  (cddr file)
                  (expand-file-name "asset.pdf" test-directory))
                 (should
                  (equal
                   (org-texmacs--session-read session)
                   (org-texmacs-test--native-hex expected)))))
           (org-texmacs-session-close session))
         (org-texmacs-document-save document tm)
         (org-texmacs-document-save-pdf document pdf)
         (org-texmacs-test--issue11-reload-pdf
          tm reload test-directory)
         (dolist (file (list pdf reload))
           (let ((links (org-texmacs-test--pdf-links file)))
             (dolist (token
                      '("JumpEquation"
                        "JumpProof"
                        "JumpFigure"
                        "JumpTable"
                        "JumpRaw"))
               (let ((entry
                      (cl-find-if
                       (lambda (link)
                         (string-match-p token (car link)))
                       links)))
                 (should entry)
                 (should
                  (string-match-p "\\.html#2\\'" (cdr entry)))))))
         (org-texmacs-test--issue11-compare-pdfs pdf reload))))))

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
          "\nFirst (math \"x+y\").\n\nSecond paragraph.\n#+end_"
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

(ert-deftest
    org-texmacs-issue13-source-real-islands-and-native-statements
    ()
  (require 'ucs-normalize)
  (org-texmacs-test--with-worker
   (should (executable-find "pdftotext"))
   (dolist (tag org-texmacs--document-statement-tags)
     (ert-info
      ((symbol-name tag))
      (with-temp-buffer
        (org-mode)
        (insert
         "#+OPTIONS: toc:nil title:nil author:nil date:nil\n#+begin_statement "
         (symbol-name tag)
         "\nStatementFirst.\n\n#+begin_texmacs\n"
         "(equation* (concat \"x=\" (frac \"1\" \"2\")))\n#+end_texmacs\n\n"
         "StatementLast.\n#+end_statement\n")
        (let* ((document
                (org-texmacs-document-from-buffer (current-buffer)))
               (expected
                `(document
                  (,tag
                   (document
                    (concat "StatementFirst. ")
                    (equation* (concat "x=" (frac "1" "2")))
                    (concat "StatementLast. ")))))
               (pdf
                (expand-file-name (concat (symbol-name tag) ".pdf")
                                  test-directory))
               (tm
                (expand-file-name (concat (symbol-name tag) ".tm")
                                  test-directory))
               (reference
                (expand-file-name (concat
                                   (symbol-name tag) "-reference.pdf")
                                  test-directory)))
          (should
           (equal (org-texmacs-document-body document) expected))
          (should
           (equal
            (org-texmacs-document-stm-paths document) '((0 0 1))))
          (org-texmacs-document-save document tm)
          (org-texmacs-document-save-pdf document pdf)
          (org-texmacs-document-save-pdf
           (org-texmacs--document-create
            :body expected
            :stm-paths
            '((0 0 1)))
           reference)
          (org-texmacs-test--issue11-compare-pdfs pdf reference)
          (let ((case-fold-search t))
            ;; PDF text may retain font ligatures (Deﬁnition).  Require the
            ;; native title/counter, not merely acceptance of an unknown tag.
            (should
             (string-match-p
              (concat
               "\\b" (symbol-name tag)
               (if (eq tag 'proof)
                   "\\."
                 " [0-9]+\\."))
              (ucs-normalize-NFKC-string
               (org-texmacs-test--pdf-text pdf)))))
          (when (memq tag '(theorem proof))
            (let ((reload
                   (expand-file-name (concat
                                      (symbol-name tag) "-reload.pdf")
                                     test-directory)))
              (org-texmacs-test--issue11-reload-pdf
               tm reload test-directory)
              (org-texmacs-test--issue11-compare-pdfs
               pdf reload)))))))))

(ert-deftest
    org-texmacs-issue13-stage2-native-layout-counter-and-reload
    ()
  (org-texmacs-test--with-worker
   (should (executable-find "pdftotext"))
   (dolist (style '("generic" "article"))
     (with-temp-buffer
       (org-mode)
       (setq-local org-texmacs-document-style (list style))
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
        "#+begin_equation\n(concat \"α=\" (frac \"1\" \"2\"))\n#+end_equation\n"
        "#+begin_equation*\n\"y\"\n#+end_equation*\n"
        "#+begin_equation\n\"z\"\n#+end_equation\n"
        "#+begin_theorem\n#+begin_equation*\n\"nested\"\n#+end_equation*\n#+end_theorem\n")
       (let* ((document
               (org-texmacs-document-from-buffer (current-buffer)))
              (expected
               '(document
                 (equation (concat "α=" (frac "1" "2")))
                 (equation* "y")
                 (equation "z")
                 (theorem (document (equation* "nested")))))
              (pdf
               (expand-file-name (concat style ".pdf")
                                 test-directory))
              (reference
               (expand-file-name (concat style "-expected.pdf")
                                 test-directory))
              (tm
               (expand-file-name (concat style ".tm") test-directory))
              (reload
               (expand-file-name (concat style "-reload.pdf")
                                 test-directory)))
         (should
          (equal (org-texmacs-document-body document) expected))
         (should
          (equal
           (org-texmacs-document-stm-paths document)
           '((0 0) (1 0) (2 0) (3 0 0 0))))
         (let ((session (org-texmacs-session-open)))
           (unwind-protect
               (progn
                 (org-texmacs-session-set-document session document)
                 (should
                  (equal
                   (org-texmacs--session-read session)
                   (org-texmacs-test--native-hex
                    '(document
                      (equation (concat "<alpha>=" (frac "1" "2")))
                      (equation* "y")
                      (equation "z")
                      (theorem (document (equation* "nested"))))))))
             (org-texmacs-session-close session)))
         (org-texmacs-document-save document tm)
         (org-texmacs-document-save-pdf document pdf)
         (org-texmacs-document-save-pdf
          (org-texmacs--document-create
           :body expected
           :style
           (list style)
           :stm-paths
           '((0 0) (1 0) (2 0) (3 0 0 0)))
          reference)
         (org-texmacs-test--issue11-compare-pdfs pdf reference)
         (let ((text (org-texmacs-test--pdf-text pdf)))
           (should (string-match-p "(1)" text))
           (should (string-match-p "(2)" text))
           (should-not (string-match-p "(3)" text)))
         (org-texmacs-test--issue11-reload-pdf
          tm reload test-directory)
         (org-texmacs-test--issue11-compare-pdfs pdf reload))))))

(ert-deftest org-texmacs-issue13-stage3-native-prevalidation ()
  (org-texmacs-test--with-worker
   (should (executable-find "pdftotext"))
   (dolist (style '("generic" "article"))
     (let* ((table
             '(tabular
               (tformat
                (table
                 (row (cell "A") (cell "B"))
                 (row (cell "1") (cell "2"))))))
            (body
             `(document
               (big-figure
                ,org-texmacs-test--issue13-stage3-graphic
                "FirstFigure")
               (big-table ,table "FirstTable")
               (big-figure*
                ,org-texmacs-test--issue13-stage3-graphic
                "StarFigure")
               (big-table* ,table "StarTable")
               (big-figure
                ,org-texmacs-test--issue13-stage3-graphic "")
               (big-table ,table "")
               (big-figure
                ,org-texmacs-test--issue13-stage3-graphic
                (caption-detailed
                 (concat "Long " (strong "Caption")) "Short"))
               (big-table
                ,table (caption-detailed "LongTable" "ShortTable"))))
            (document
             (org-texmacs--document-create
              :body body
              :style (list style)))
            (pdf
             (expand-file-name (concat style "-float.pdf")
                               test-directory))
            (tm
             (expand-file-name (concat style "-float.tm")
                               test-directory))
            (reload
             (expand-file-name (concat style "-float-reload.pdf")
                               test-directory))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex body))))
         (org-texmacs-session-close session))
       (org-texmacs-document-save document tm)
       (org-texmacs-document-save-pdf document pdf)
       (let ((text (org-texmacs-test--pdf-text pdf)))
         (dolist (pattern
                  '("Figure 1\\. FirstFigure"
                    "Table 1\\. FirstTable"
                    "Figure 2\\."
                    "Table 2\\."
                    "Figure 3\\."
                    "Table 3\\."
                    "StarFigure"
                    "StarTable"
                    "Diagram"
                    "Long Caption"
                    "LongTable"))
           (ert-info
            ((format "%s: %s: %s" style pattern text))
            (should (string-match-p pattern text))))
         (should-not
          (string-match-p "Figure 4\\.\\|Table 4\\." text)))
       (org-texmacs-test--issue11-reload-pdf tm reload test-directory)
       (org-texmacs-test--issue11-compare-pdfs pdf reload)
       (cl-mapc
        (lambda (a b) (should (<= (abs (- a b)) 1)))
        (org-texmacs-test--issue13-stage3-graphic-ink pdf)
        (org-texmacs-test--issue13-stage3-graphic-ink reload))))))

(ert-deftest org-texmacs-issue13-stage3-exporter-native-pdf-and-reload
    ()
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (with-temp-buffer
       (org-mode)
       (setq-local org-texmacs-document-style (list style))
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
        "#+CAPTION: FigureCaption\n#+begin_figure\n#+begin_texmacs\n"
        (prin1-to-string org-texmacs-test--issue13-stage3-graphic)
        "\n#+end_texmacs\n#+end_figure\n"
        "#+CAPTION[Short]: Long *Table*\n#+begin_table\n| A | B |\n| 1 | 2 |\n#+end_table\n"
        "#+begin_figure*\n#+begin_texmacs\n\"StarFigureBody\"\n#+end_texmacs\n#+end_figure*\n"
        "#+begin_table*\n#+begin_texmacs\n(tformat (twith \"table-halign\" \"c\")"
        " (table (row (cell \"Raw\"))))\n#+end_texmacs\n#+end_table*\n")
       (let* ((document
               (org-texmacs-document-from-buffer (current-buffer)))
              (expected
               `(document
                 (big-figure
                  ,org-texmacs-test--issue13-stage3-graphic
                  "FigureCaption")
                 (big-table
                  (tabular
                   (tformat
                    (table
                     (row (cell "A") (cell "B"))
                     (row (cell "1") (cell "2")))))
                  (caption-detailed
                   (concat "Long " (strong "Table")) "Short"))
                 (big-figure* "StarFigureBody" "")
                 (big-table*
                  (tabular
                   (tformat
                    (twith "table-halign" "c")
                    (table (row (cell "Raw")))))
                  "")))
              (paths '((0 0) (2 0) (3 0 0)))
              (pdf
               (expand-file-name (concat style "-export.pdf")
                                 test-directory))
              (reference
               (expand-file-name (concat style "-reference.pdf")
                                 test-directory))
              (tm
               (expand-file-name (concat style "-export.tm")
                                 test-directory))
              (reload
               (expand-file-name (concat style "-export-reload.pdf")
                                 test-directory)))
         (should
          (equal (org-texmacs-document-body document) expected))
         (should
          (equal (org-texmacs-document-stm-paths document) paths))
         (org-texmacs-document-save document tm)
         (org-texmacs-document-save-pdf document pdf)
         (org-texmacs-document-save-pdf
          (org-texmacs--document-create
           :body expected
           :stm-paths paths
           :style
           (list style))
          reference)
         (org-texmacs-test--issue11-compare-pdfs pdf reference)
         (org-texmacs-test--issue11-reload-pdf
          tm reload test-directory)
         (org-texmacs-test--issue11-compare-pdfs pdf reload)
         (should
          (equal
           (org-texmacs-test--issue13-stage3-graphic-ink pdf)
           (org-texmacs-test--issue13-stage3-graphic-ink
            reference))))))))

;;; special-blocks.el ends here
