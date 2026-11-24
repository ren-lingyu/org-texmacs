;;; ert-native-document.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'org-texmacs)
(require 'org-texmacs-parse)
(require 'ox)
(require 'subr-x)

(defun org-texmacs-test--example-document ()
  "Exercise the fixed document fixture."
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\n"
     "* 中\n"
     "Text *bold* <alpha> $(math \"α <alpha>\")$ end.\n\n"
     "#+begin_texmacs\n"
     "(with \"mode\" \"math\" (frac \"中\" \"2\"))\n"
     "#+end_texmacs\n")
    (org-texmacs-document-from-buffer (current-buffer))))

(defun org-texmacs-test--reference-map (body)
  "Map BODY's random labels to structural fixture names, preserving static IDs."
  (let* ((labels (org-texmacs--document-output-labels body))
         (reserved
          (cl-remove-if-not
           (lambda (id)
             (string-match-p "\\`org-texmacs-ref-[0-9]+\\'" id))
           labels))
         (next 0)
         result)
    (dolist (id labels)
      (when (string-match-p "\\`org-texmacs-.*org[0-9a-f]+\\'" id)
        (let (canonical)
          (while (progn
                   (setq canonical
                         (format "org-texmacs-ref-%d" (cl-incf next)))
                   (member canonical reserved)))
          (push (cons id canonical) result))))
    (nreverse result)))

(defun org-texmacs-test--rewrite-references (tree mapping)
  "Copy TREE, replacing complete label/reference strings using MAPPING."
  (cond
   ((stringp tree)
    (or (cdr (assoc tree mapping))
        (and (string-prefix-p "#" tree)
             (when-let* ((id
                          (cdr (assoc (substring tree 1) mapping))))
               (concat "#" id)))
        tree))
   ((consp tree)
    (mapcar
     (lambda (child)
       (org-texmacs-test--rewrite-references child mapping))
     tree))
   (t
    tree)))

(defun org-texmacs-test--stable-reference-body (document)
  "Return DOCUMENT body with random references renamed for structural comparison."
  (let ((body (org-texmacs-document-body document)))
    (org-texmacs-test--rewrite-references
     body (org-texmacs-test--reference-map body))))

(defun org-texmacs-test--expand-references (tree document)
  "Expand TREE's fixture labels to DOCUMENT's actual IDs before native encoding."
  (org-texmacs-test--rewrite-references
   tree
   (mapcar
    (lambda (entry) (cons (cdr entry) (car entry)))
    (org-texmacs-test--reference-map
     (org-texmacs-document-body document)))))

(ert-deftest org-texmacs-document-metadata-native-encoding ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+TITLE: 中 <alpha>\n"
      "#+AUTHOR: /Author/\n#+OPTIONS: author:t\n"
      "#+DATE: <2026-09-15>\n"
      "Body\n")
     (let ((document
            (org-texmacs-document-from-buffer (current-buffer)))
           (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                '(document
                  (doc-data
                   (doc-title "<#4E2D> <less>alpha<gtr>")
                   (doc-author
                    (author-data (author-name (em "Author"))))
                   (doc-date "<less>2026-09-15<gtr>"))
                  (concat "Body "))))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-nested-markup-source-and-native ()
  (org-texmacs-test--with-worker
   (let ((session (org-texmacs-session-open)))
     (unwind-protect
         (dolist (case
                  '(("*a /i/ z*\n" strong em "i")
                    ("/a *b* z/\n" em strong "b")
                    ("_a *b* z_\n" underline strong "b")
                    ("+a *b* z+\n" strike-through strong "b")))
           (with-temp-buffer
             (org-mode)
             (setq-local org-export-with-author nil)
             (insert (car case))
             (let* ((source (buffer-string))
                    (expected
                     (list
                      'document
                      (list
                       'concat
                       (list
                        (nth 1 case)
                        (list
                         'concat
                         "a "
                         (list (nth 2 case) (nth 3 case))
                         " "
                         "z"))
                       " ")))
                    (document
                     (org-texmacs-document-from-buffer
                      (current-buffer))))
               (should
                (equal (org-texmacs-document-body document) expected))
               (org-texmacs-session-set-document session document)
               (should
                (equal
                 (org-texmacs--session-read session)
                 (org-texmacs-test--native-hex expected)))
               (should (equal source (buffer-string))))))
       (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-document-inline-native-whitespace ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert "A\t¯˙\n/i/ _u_ +s+ ~x\t y~\n")
     (let* ((source (buffer-string))
            (document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal
               (org-texmacs-document-body document)
               '(document
                 (concat
                  "A ¯˙ "
                  (em "i")
                  " "
                  (underline "u")
                  " "
                  (strike-through "s")
                  " "
                  (verbatim "x y")
                  " "))))
             (org-texmacs-session-set-document session document)
             ;; Native 09/0a here represent actual glyphs, not source whitespace.
             (should
              (equal
               (org-texmacs--session-read session)
               '(document
                 (concat
                  "4120090a20"
                  (em "69")
                  "20"
                  (underline "75")
                  "20"
                  (strike-through "73")
                  "20"
                  (verbatim "782079")
                  "20"))))
             (should (equal source (buffer-string))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-reference-native-readback ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+OPTIONS: toc:nil\n* Alpha\n:PROPERTIES:\n:ID: local-id\n:END:\n"
      "[[id:local-id]]\n")
     (let ((document
            (org-texmacs-document-from-buffer (current-buffer)))
           (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                (org-texmacs-test--expand-references
                 '(document
                   (section "Alpha")
                   (label "org-texmacs-ref-1")
                   (concat (reference "org-texmacs-ref-1") " "))
                 document)))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-uri-native-islands ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "[[https://example.org/中%20文?q=a&b=%26][中文 <alpha>]] $(math \"<alpha>\")$\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal
               (org-texmacs-document-stm-paths document) '((0 2))))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                '(document
                  (concat
                   (hlink
                    "<#4E2D><#6587> <less>alpha<gtr>"
                    "https://example.org/<#4E2D>%20<#6587>?q=a&b=%26")
                   " " (math "<alpha>") " "))))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-named-footnote-native ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "A[fn:n] again[fn:n] anonymous[fn::Literal <alpha>].\n\n[fn:n] 中 *Body*.\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                '(document
                  (concat
                   "A"
                   (footnote
                    (surround
                     (label "org-texmacs-fn-1") ""
                     (document
                      (concat "<#4E2D> " (strong "Body") ". "))))
                   " " "again"
                   (rsup
                    (with
                     "font-shape"
                     "right"
                     (reference "org-texmacs-fn-1")))
                   " " "anonymous"
                   (footnote
                    (document (concat "Literal <less>alpha<gtr>")))
                   ". "))))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-footnote-rich-native ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "A[fn::中 *bold* ~code~ [[https://example.org][Link]] <alpha>]\n")
     (let* ((source (buffer-string))
            (document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open))
            (expected
             '(document
               (concat
                "A"
                (footnote
                 (document
                  (concat
                   "中 "
                   (strong "bold")
                   " "
                   (verbatim "code")
                   " "
                   (hlink "Link" "https://example.org")
                   " "
                   "<alpha>")))
                " "))))
       (unwind-protect
           (progn
             (should
              (equal (org-texmacs-document-body document) expected))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                '(document
                  (concat
                   "A"
                   (footnote
                    (document
                     (concat
                      "<#4E2D> "
                      (strong "bold")
                      " "
                      (verbatim "code")
                      " "
                      (hlink "Link" "https://example.org")
                      " "
                      "<less>alpha<gtr>")))
                   " ")))))
             (should (equal source (buffer-string))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-toc-static-label-conflict-native ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+OPTIONS: toc:1 todo:nil\n"
      "#+begin_texmacs\n"
      "(label \"org-texmacs-toc-1\")\n"
      "#+end_texmacs\n"
      "* 中 <alpha>\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
            (expected
             '(document
               (table-of-contents
                "org-texmacs-toc"
                (document
                 (toc-1
                  (hlink
                   (concat "1 " "中 <alpha>") "#org-texmacs-toc-2")
                  (pageref "org-texmacs-toc-2"))))
               (label "org-texmacs-toc-1")
               (section "中 <alpha>")
               (label "org-texmacs-toc-2")))
            (expected-native
             '(document
               (table-of-contents
                "org-texmacs-toc"
                (document
                 (toc-1
                  (hlink
                   (concat "1 " "<#4E2D> <less>alpha<gtr>")
                   "#org-texmacs-toc-2")
                  (pageref "org-texmacs-toc-2"))))
               (label "org-texmacs-toc-1")
               (section "<#4E2D> <less>alpha<gtr>")
               (label "org-texmacs-toc-2")))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal (org-texmacs-document-body document) expected))
             (should
              (equal
               (org-texmacs-document-stm-paths document) '((1))))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected-native))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-list-containers-native ()
  (org-texmacs-test--with-worker
   (let ((session (org-texmacs-session-open)))
     (unwind-protect
         (dolist (case
                  '(("- Bullet\n" (document
                      (itemize (document (concat (item) "Bullet ")))))
                    ("1. Number\n" (document
                      (enumerate
                       (document (concat (item) "Number ")))))
                    ("- Term :: Definition\n" (document
                      (description
                       (document
                        (concat (item* "Term") "Definition ")))))
                    ("#+begin_quote\nQuoted.\n#+end_quote\n" (document
                      (quotation (document (concat "Quoted. ")))))
                    ("#+begin_center\nCentered.\n#+end_center\n"
                     (document
                      (center (document (concat "Centered. ")))))))
           (with-temp-buffer
             (org-mode)
             (setq-local org-export-with-author nil)
             (insert (car case))
             (let ((document
                    (org-texmacs-document-from-buffer
                     (current-buffer))))
               (should
                (equal
                 (org-texmacs-document-body document) (cadr case)))
               (org-texmacs-session-set-document session document)
               (should
                (equal
                 (org-texmacs--session-read session)
                 (org-texmacs-test--native-hex (cadr case)))))))
       (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-document-preformatted-native-and-provenance
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (setq-local tab-width 4)
     (insert
      "$(math \"x\")$\n\n"
      "#+begin_src text\n"
      "中¯˙\t<alpha>\n"
      "#+end_src\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
            (expected
             '(document
               (math "x") (code (document "中¯˙    <alpha>"))))
            (expected-native
             '(document
               (math "x")
               (code (document "<#4E2D>\t\n    <less>alpha<gtr>"))))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal (org-texmacs-document-body document) expected))
             (should
              (equal
               (org-texmacs-document-stm-paths document) '((0))))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected-native))))
         (org-texmacs-session-close session))))))

(ert-deftest
    org-texmacs-document-table-alignment-caption-reference-and-files
    ()
  :tags
  '(issue4)
  (org-texmacs-test--with-worker
   (let (documents)
     (dolist (format '(nil "| <l> | <r> |\n"))
       (with-temp-buffer
         (org-mode)
         (setq-local org-export-with-author nil)
         (insert
          "#+OPTIONS: toc:nil title:nil author:nil date:nil\n[[t]]\n\n"
          "#+name: t\n#+caption: Caption [[./caption.org][CaptionFile]]\n"
          (or format "")
          "| [[./asset.org][AssetFile]] | =<r>= <alpha> |\n"
          "\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
         (push (org-texmacs-document
                (org-texmacs-test--input-from-model
                 (org-texmacs-parse-buffer (current-buffer))))
               documents)))
     (let* ((aligned (car documents))
            (plain (cadr documents))
            (body
             (copy-tree
              (org-texmacs-test--stable-reference-body aligned))))
       (cl-labels
        ((strip
          (node)
          (when (consp node)
            (when (eq (car node) 'tformat)
              (setcdr
               node
               (cl-remove-if
                (lambda (child)
                  (and (consp child)
                       (eq (car child) 'cwith)
                       (equal (nth 5 child) "cell-halign")))
                (cdr node))))
            (mapc #'strip (cdr node)))))
        (strip body))
       (should
        (equal body (org-texmacs-test--stable-reference-body plain)))
       (should
        (equal
         (org-texmacs-document-stm-paths aligned)
         (org-texmacs-document-stm-paths plain)))
       (should
        (= (length (org-texmacs-document-file-paths aligned)) 2))
       (dolist (path (org-texmacs-document-file-paths aligned))
         (let ((leaf
                (org-texmacs-test--stable-reference-body aligned)))
           (dolist (index path)
             (setq leaf (nth (1+ index) leaf)))
           (should (member leaf '("./caption.org" "./asset.org")))))
       (should
        (consp (org-texmacs--native-encode-document aligned)))))))

(ert-deftest org-texmacs-document-named-table-native-and-provenance ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (setq default-directory "/tmp/")
     (insert
      "[[t]]\n\n#+name: t\n#+caption[Short]: 中 <alpha> [[./caption.org][File]]\n| x |\n"
      "\n#+begin_texmacs\n(label \"org-texmacs-ref-1\")\n#+end_texmacs\n")
     (let* ((document
             (org-texmacs-document
              (org-texmacs-test--input-from-model
               (org-texmacs-parse-buffer (current-buffer)))))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal
               (org-texmacs-document-file-paths document)
               '((1 1 2 0 1 1))))
             (should
              (equal
               (org-texmacs-document-stm-paths document) '((2))))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                (org-texmacs-test--expand-references
                 '(document
                   (concat (reference "org-texmacs-ref-2") " ")
                   (big-table
                    (tabular (tformat (table (row (cell "x")))))
                    (surround
                     (label "org-texmacs-ref-2") ""
                     (caption-detailed
                      (concat
                       "<#4E2D> <less>alpha<gtr> "
                       (hlink "File" "/tmp/caption.pdf"))
                      "Short")))
                   (label "org-texmacs-ref-1"))
                 document)))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-table-native-and-provenance ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "| 中 <alpha> | *B* |\n"
      "|------------+-----|\n"
      "| x          |     |\n")
     (let* ((document
             (org-texmacs-document
              (org-texmacs-test--input-from-model
               (org-texmacs-parse-buffer (current-buffer)))))
            (expected
             '(document
               (tabular
                (tformat
                 (cwith "1" "1" "1" "-1" "cell-bborder" "1ln")
                 (table
                  (row (cell "中 <alpha>") (cell (strong "B")))
                  (row (cell "x") (cell "")))))))
            (expected-native
             '(document
               (tabular
                (tformat
                 (cwith "1" "1" "1" "-1" "cell-bborder" "1ln")
                 (table
                  (row
                   (cell "<#4E2D> <less>alpha<gtr>")
                   (cell (strong "B")))
                  (row (cell "x") (cell "")))))))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal (org-texmacs-document-body document) expected))
             (should-not (org-texmacs-document-stm-paths document))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected-native))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-mixed-inline-session ()
  (org-texmacs-test--with-worker
   (should-not (org-texmacs--worker-live-p))
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "中 /i/ [fn::*n*] [[https://example.org][L]] $(math \"<alpha>\")$$(math \"x\")$\n\n"
      "#+begin_texmacs\n(equation* \"y\")\n#+end_texmacs\n")
     (let* ((source (buffer-string))
            (tick (buffer-chars-modified-tick))
            (position (point))
            (document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open))
            (process org-texmacs--worker-process)
            (expected
             '(document
               (concat
                "<#4E2D> "
                (em "i")
                " "
                (footnote (document (concat (strong "n"))))
                " "
                (hlink "L" "https://example.org")
                " "
                (math "<alpha>")
                (math "x")
                " ")
               (equation* "y"))))
       (unwind-protect
           (progn
             (should
              (equal
               (org-texmacs-document-stm-paths document)
               '((0 7) (0 8) (1))))
             (dotimes (_ 2)
               (org-texmacs-session-set-document session document)
               (should
                (equal
                 (org-texmacs--session-read session)
                 (org-texmacs-test--native-hex expected))))
             (org-texmacs-session-close session)
             (should-error
              (org-texmacs-session-set-document session document)
              :type 'org-texmacs-session-error)
             (setq session (org-texmacs-session-open))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected)))
             (should (eq process org-texmacs--worker-process))
             (should (equal source (buffer-string)))
             (should (= tick (buffer-chars-modified-tick)))
             (should (= position (point))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-real-chinese-end-to-end ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "#+OPTIONS: toc:nil\n* 中文标题\n\n普通的中文 *加粗* $(math (frac \"一\" \"2\"))$.\n\n"
      "#+begin_texmacs\n(equation* (frac \"3\" \"4\"))\n#+end_texmacs\n\n"
      "** Second\n\nFinal paragraph.\n")
     (goto-char (point-min))
     (search-forward "#+begin_texmacs")
     (let* ((block (org-element-at-point))
            (source (buffer-string))
            (tick (buffer-chars-modified-tick))
            (position (point))
            (document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal
               (org-texmacs-document-body document)
               '(document
                 (section "中文标题")
                 (concat
                  "普通的中文 "
                  (strong "加粗")
                  " "
                  (math (frac "一" "2"))
                  ". ")
                 (equation* (frac "3" "4"))
                 (subsection "Second")
                 (concat "Final paragraph. "))))
             (should
              (equal
               (org-texmacs-document-stm-paths document)
               '((1 3) (2))))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                '(document
                  (section "<#4E2D><#6587><#6807><#9898>")
                  (concat
                   "<#666E><#901A><#7684><#4E2D><#6587> "
                   (strong "<#52A0><#7C97>")
                   " "
                   (math (frac "<#4E00>" "2"))
                   ". ")
                  (equation* (frac "3" "4"))
                  (subsection "Second")
                  (concat "Final paragraph. ")))))
             (should (equal source (buffer-string)))
             (should (= tick (buffer-chars-modified-tick)))
             (should (= position (point)))
             (should (eq (org-element-type block) 'special-block))
             (should
              (eq
               (org-element-type (org-element-at-point))
               'special-block)))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-real-failure-repair-and-update ()
  (org-texmacs-test--with-worker
   (let ((session (org-texmacs-session-open))
         (process org-texmacs--worker-process))
     (unwind-protect
         (with-temp-buffer
           (org-mode)
           (setq-local org-export-with-author nil)
           (insert "Original\n")
           (org-texmacs-session-set-document
            session
            (org-texmacs-document-from-buffer (current-buffer)))
           (let ((old (org-texmacs--session-read session)))
             (dolist (case
                      '(("#+attr_html: :class test\nParagraph\n"
                         .
                         org-texmacs-document-error)
                        ("$(math 1)$\n" . org-texmacs-parse-error)))
               (erase-buffer)
               (insert (car case))
               (should-error
                (org-texmacs-session-set-document
                 session
                 (org-texmacs-document-from-buffer (current-buffer)))
                :type (cdr case))
               (should
                (equal old (org-texmacs--session-read session)))
               (should (eq process org-texmacs--worker-process))))
           (erase-buffer)
           (insert "$(math \"<less>alpha<gtr> α\")$\n")
           (let ((document
                  (org-texmacs-document-from-buffer
                   (current-buffer))))
             ;; Reusing the text result must not double-encode its leaves.
             (dotimes (_ 2)
               (org-texmacs-session-set-document session document)
               (should
                (equal
                 (org-texmacs--session-read session)
                 (org-texmacs-test--native-hex
                  '(document (math "<less>alpha<gtr> <alpha>")))))))
           (should (eq process org-texmacs--worker-process)))
       (org-texmacs-session-close session))
     (should
      (equal
       (org-texmacs--worker-request "(frac \"1\" \"2\")")
       '(frac "1" "2"))))))

(ert-deftest org-texmacs-document-real-custom-heading-settings ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
       (org-mode)
       (setq-local org-export-with-author nil))
     (setq-local org-odd-levels-only t)
     (insert
      "#+TODO: WAIT | FINISHED\n#+OPTIONS: toc:nil\n*** TODO Task\n$(math \"α\")$\n")
     (let* ((settings (org-texmacs--syntax-heading-settings))
            (source (buffer-string))
            (document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal
               (org-texmacs-document-body document)
               '(document (section "TODO Task") (math "α"))))
             (should
              (equal
               (org-texmacs-document-stm-paths document) '((1))))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                '(document (section "TODO Task") (math "<alpha>")))))
             (should (equal source (buffer-string)))
             (should
              (equal
               settings (org-texmacs--syntax-heading-settings))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-document-native-example ()
  (org-texmacs-test--with-worker
   (let* ((document (org-texmacs-test--example-document))
          (session (org-texmacs-session-open)))
     (unwind-protect
         (progn
           (should
            (equal
             (org-texmacs-document-body document)
             '(document
               (section "中")
               (concat
                "Text "
                (strong "bold")
                " "
                "<alpha> "
                (math "α <alpha>")
                " "
                "end. ")
               (with "mode" "math" (frac "中" "2")))))
           (should
            (equal
             (org-texmacs-document-stm-paths document) '((1 4) (2))))
           (org-texmacs-session-set-document session document)
           (should
            (equal
             (org-texmacs--session-read session)
             (org-texmacs-test--native-hex
              '(document
                (section "<#4E2D>")
                (concat
                 "Text "
                 (strong "bold")
                 " "
                 "<less>alpha<gtr> "
                 (math "<alpha> <alpha>")
                 " "
                 "end. ")
                (with "mode" "math" (frac "<#4E2D>" "2")))))))
       (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-headline-native-metadata-literal ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (let ((org-todo-keywords '((sequence "<alpha>" "|" "FINISHED"))))
       (org-mode)
       (setq-local org-export-with-author nil))
     (insert
      "#+TODO: <alpha> | FINISHED\n#+OPTIONS: toc:nil\n* <alpha> [#12] 中 :tag:\n$(math \"<alpha>\")$\n")
     (let* ((org-export-with-todo-keywords t)
            (org-export-with-priority t)
            (org-export-with-tags t)
            (document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should
              (equal
               (org-texmacs-document-stm-paths document) '((1))))
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex
                '(document
                  (section
                   (concat
                    (strong "<less>alpha<gtr>")
                    " "
                    "[#12]"
                    " "
                    "<#4E2D>"
                    " "
                    ":tag:"))
                  (math "<alpha>"))))))
         (org-texmacs-session-close session))))))

;;; ert-native-document.el ends here
