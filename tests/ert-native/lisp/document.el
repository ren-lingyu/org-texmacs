;;; document.el --- native document regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-caption-inline-footnote-stock-parser ()
  (should-not
   (memq
    'footnote-reference
    (cdr (assq 'keyword org-element-object-restrictions))))
  (dolist (kind '("plain" "figure" "figure*" "table" "table*"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
       "#+CAPTION[Short[fn::ShortNote]]: Long[fn::LongNote] (math \"literal\")\n")
      (unless (equal kind "plain")
        (insert "#+begin_" kind "\n"))
      (insert
       (if (string-prefix-p "figure" kind)
           "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"
         "| A |\n"))
      (unless (equal kind "plain")
        (insert "#+end_" kind "\n"))
      (insert "\nBody[fn::BodyNote].\n")
      (let ((source (buffer-string))
            requests)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (raw &rest _)
                     (push raw requests)
                     (read raw))))
          (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
                 (document (org-texmacs-document input))
                 (body (org-texmacs-document-body document)))
            (should
             (= 1
                (length
                 (org-texmacs-test--caption-inline-footnote-nodes
                  body 'footnote))))
            (should
             (string-match-p
              "\\[fn::LongNote\\]" (prin1-to-string body)))
            (should
             (string-match-p
              "\\[fn::ShortNote\\]" (prin1-to-string body)))
            (should
             (= (length requests)
                (if (string-prefix-p "figure" kind)
                    1
                  0)))
            (should (equal document (org-texmacs-document input)))))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-citations-preflight-boundaries ()
  (dolist
      (source
       '("#+bibliography: refs.bib\n[cite/author:@key]\n#+print_bibliography:\n"
         "#+bibliography: refs.bib\n[cite:see @key]\n#+print_bibliography:\n"
         "#+bibliography: refs.bib\n[cite:@key]\n"
         "#+bibliography: refs.bib\n[cite:@key]\n#+print_bibliography:\n#+print_bibliography:\n"
         "#+bibliography: refs.bib\n* Title[cite/author:@key]\n#+print_bibliography:\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid citation started worker"))))
        (should-error
         (org-texmacs-prepare-buffer
          (current-buffer) '(("refs.bib" . "@book{key}")))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-citations-footnote-order-and-stale-output ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+bibliography: refs.bib\nA[fn:n] [cite:@second] [fn:n].\n"
     "#+print_bibliography:\n\n[fn:n] [cite:@first]\n")
    (let (seen
          input)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   '(document
                     (bib-entry "book" "first" (document))
                     (bib-entry "book" "second" (document)))))
                ((symbol-function 'org-texmacs--bibliography-format)
                 (lambda (plan)
                   (setq seen (plist-get plan :keys))
                   (list
                    (plist-get plan :prefix)
                    seen
                    (plist-get plan :entries)
                    '(bib-list
                      "2"
                      (document
                       (concat
                        (label "org-texmacs-bib-1-first") "Prepared")
                       (concat
                        (label "org-texmacs-bib-1-second")
                        "Prepared")))))))
        (setq input
              (org-texmacs-prepare-buffer
               (current-buffer)
               '(("refs.bib" . "@book{first}\n@book{second}")))))
      (should (equal seen '("first" "second")))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Pure lowering started worker"))))
        (let ((doc (org-texmacs-document input)))
          (should
           (equal (org-texmacs-document-stm-paths doc) '((1 1))))))
      (let* ((bad-info (copy-tree (org-texmacs-input-info input)))
             (bad-input nil))
        (setcar
         (cadr
          (plist-get bad-info :texmacs-bibliography-output))
         "stale")
        (setq bad-input
              (org-texmacs-input-create
               (org-texmacs-input-ast input) bad-info
               :bibliography (org-texmacs-input-bibliography input)))
        (should-error
         (org-texmacs-document bad-input)
         :type 'org-texmacs-document-error))
      (let ((changed
             (copy-tree (org-texmacs-input-bibliography input))))
        (setcar (cdr (cadr (cdar changed))) "misc")
        (should-error
         (org-texmacs-document
          (org-texmacs-input-create
           (org-texmacs-input-ast input)
           (org-texmacs-input-info input)
           :bibliography changed))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-citations-formatting-wait-and-payload-errors
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+bibliography: refs.bib\n[cite:@key]\n#+print_bibliography:\n")
    (let* ((text (copy-sequence "@book{key}"))
           (sources (list (cons "refs.bib" text))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   '(document (bib-entry "book" "key" (document)))))
                ((symbol-function 'org-texmacs--bibliography-format)
                 (lambda (_plan)
                   (aset text 0 ?X)
                   nil)))
        (should-error
         (org-texmacs-prepare-buffer (current-buffer) sources)
         :type 'org-texmacs-document-error)))
    (let (stopped)
      (cl-letf (((symbol-function 'org-texmacs--worker-call)
                 (lambda (_request)
                   '(ok 1 (bib-list "1" (document (label "wrong"))))))
                ((symbol-function 'org-texmacs--worker-stop)
                 (lambda () (setq stopped t))))
        (should-error
         (org-texmacs--bibliography-format
          '(:prefix "p" :keys ("key") :entries (document)))
         :type 'org-texmacs-worker-error)
        (should stopped)))
    (let (stopped)
      (cl-letf (((symbol-function 'org-texmacs--worker-call)
                 (lambda (_request)
                   '(error 1 "Unsupported formatter data")))
                ((symbol-function 'org-texmacs--worker-stop)
                 (lambda () (setq stopped t))))
        (should-error
         (org-texmacs--bibliography-format
          '(:prefix "p" :keys nil :entries (document)))
         :type 'org-texmacs-document-error)
        (should-not stopped)))))

(ert-deftest org-texmacs-citations-native-output-and-ownership ()
  (org-texmacs-test--with-worker
   (let (input)
     (with-temp-buffer
       (org-mode)
       (insert
        "#+bibliography: refs.bib\nA[cite:@key].\n#+print_bibliography:\n")
       (setq
        input
        (org-texmacs-prepare-buffer
         (current-buffer)
         '(("refs.bib"
            .
            "@book{key, title={Café 中 <alpha>}, author={Ada Example}, year=2026, publisher={Example}}")))))
     (let* ((doc (org-texmacs-document input))
            (expected
             '(document
               (concat
                "A"
                (with-bib "org-texmacs-bib-1" (cite "key")) ". ")
               (with-bib
                "org-texmacs-bib-1"
                (bib-list
                 "1"
                 (document
                  (concat
                   (bibitem* "1")
                   (label "org-texmacs-bib-1-key")
                   "Ada Example. "
                   (newblock)
                   (with
                    "font-shape"
                    "italic"
                    "Café <#4E2D> <less>alpha<gtr>")
                   ". "
                   (newblock)
                   "Example, 2026."
                   (newblock)))))))
            (session (org-texmacs-session-open)))
       (unwind-protect
           (progn
             (should (equal (org-texmacs-document-body doc) expected))
             (should
              (equal (org-texmacs-document-stm-paths doc) '((1 1))))
             (org-texmacs-session-set-document session doc)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected)))
             (should
              (equal
               (org-texmacs--worker-request
                "(math \"x\")")
               '(math "x"))))
         (org-texmacs-session-close session)))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+bibliography: refs.bib\nA[cite:@a; @b]\n"
        "#+begin_texmacs\n(label \"org-texmacs-bib-1-a\")\n#+end_texmacs\n"
        "#+print_bibliography:\n")
       (let* ((doc
               (org-texmacs-document-from-buffer
                (current-buffer)
                '(("refs.bib"
                   .
                   "@book{a, title={A}}\n@book{b, title={B}}"))))
              (body (org-texmacs-document-body doc)))
         (should
          (equal
           (nth 2 (cadr body))
           '(with-bib "org-texmacs-bib-2" (cite "a" "b"))))
         (should
          (equal
           (org-texmacs-document-stm-paths doc) '((1) (2 1)))))))))

(ert-deftest org-texmacs-document-settings-buffer-snapshot ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")\n")
    (let ((org-export-default-language "en")
          (org-texmacs-document-style '("article"))
          (org-texmacs-document-initial '(("par-first" . "2fn"))))
      (cl-letf
          (((symbol-function 'org-texmacs--worker-request)
            (lambda (_source)
              (setq
               org-export-default-language "fr"
               org-texmacs-document-style '("generic")
               org-texmacs-document-initial '(("par-first" tuple "中" "<alpha>")))
              '(math "x"))))
        (let ((first
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal (org-texmacs-document-style first) '("article")))
          (should
           (equal
            (org-texmacs-document-initial first)
            '(("language" . "english") ("par-first" . "2fn"))))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_source) '(math "x"))))
        (let ((second
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal (org-texmacs-document-style second) '("generic")))
          (should
           (equal
            (org-texmacs-document-initial second)
            '(("language" . "french")
              ("par-first" tuple "中" "<alpha>")))))))))

(ert-deftest org-texmacs-document-metadata-native-encoding ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+TITLE: 中 <alpha>\n"
      "#+AUTHOR: /Author/\n"
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

(ert-deftest org-texmacs-document-date-timestamp-raw-text ()
  :tags
  '(issue4-closure)
  (dolist (raw
           '("<2026-10-14>"
             "[2026-10-14 Wed]"
             "<2026-10-14 Wed 15:30 +0800>"
             "<2026-10-14  15:30  +0800>"
             "<2026-10-14 Wed 15:30-16:00>"
             "<2026-10-14 Wed>--<2026-10-15 Thu>"
             "[2026-10-14 Wed]--[2026-10-15 Thu]"
             "<2026-10-14 Wed +1w>"
             "<2026-10-14 Wed .+1m/2m>"
             "<2026-10-14 Wed -3d>"
             "<%%(diary-anniversary 10 14 2000)>"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "#+DATE: " raw "\nBody\n")
      (let* ((state
              (org-texmacs-test--document-buffer-state
               (current-buffer)))
             (input (org-texmacs-prepare-buffer (current-buffer)))
             (date
              (car (plist-get (org-texmacs-input-info input) :date))))
        (should (eq (org-element-type date) 'timestamp))
        (should (equal (org-element-property :raw-value date) raw))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Pure date lowering started worker"))))
          (should
           (equal
            (org-texmacs-document-body (org-texmacs-document input))
            `(document (doc-data (doc-date ,raw)) (concat "Body ")))))
        (should
         (equal
          state
          (org-texmacs-test--document-buffer-state
           (current-buffer))))))))

(ert-deftest org-texmacs-document-date-precedence-and-suppression ()
  :tags
  '(issue4-closure)
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "Body\n")
    (let ((raw "<2026-10-14 Wed 15:30 +0800>"))
      (should
       (equal
        (cadr
         (org-texmacs-document-body
          (org-texmacs-document-from-buffer
           (current-buffer) nil nil nil (list :date raw))))
        `(doc-data (doc-date ,raw))))
      (insert "#+DATE: *Release* " raw " =literal=\n")
      (let ((body
             (org-texmacs-document-body
              (org-texmacs-document-from-buffer
               (current-buffer) nil nil nil '(:date "External")))))
        (should
         (equal
          (cadr body)
          `(doc-data
            (doc-date
             (concat
              (strong "Release")
              " "
              ,raw
              " "
              (verbatim "literal")))))))
      (dolist (options '((:with-date nil) (:date nil :with-date nil)))
        (should-not
         (memq
          'doc-data
          (flatten-tree
           (org-texmacs-document-body
            (org-texmacs-document-from-buffer
             (current-buffer) nil nil nil options))))))
      (insert
       "* Chosen\n:PROPERTIES:\n:EXPORT_DATE: [2026-10-15 Thu]\n:END:\n")
      (search-backward "* Chosen")
      (should
       (equal
        (cadr
         (org-texmacs-document-body
          (org-texmacs-document-from-buffer
           (current-buffer) nil (point) nil '(:date "External"))))
        '(doc-data
          (doc-title "Chosen") (doc-date "[2026-10-15 Thu]"))))))
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "Body\n")
    (should-not
     (memq
      'doc-data
      (flatten-tree
       (org-texmacs-document-body
        (org-texmacs-document-from-buffer (current-buffer))))))))

(ert-deftest org-texmacs-document-date-malformed-and-context ()
  :tags
  '(issue4-closure)
  (dolist (value '(nil "" 42))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "#+DATE: <2026-10-14>\n")
      (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
             (date
              (car (plist-get (org-texmacs-input-info input) :date))))
        (org-element-put-property date :raw-value value)
        (should-error
         (org-texmacs-document input)
         :type 'org-texmacs-document-error))))
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "#+DATE: <2026-10-14>\n")
    (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
           (date
            (car (plist-get (org-texmacs-input-info input) :date))))
      (org-element-set-contents date "unexpected")
      (should-error
       (org-texmacs-document input)
       :type 'org-texmacs-document-error)))
  (dolist (source '("<2026-10-14>\n" "#+TITLE: <2026-10-14>\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-date-advice-snapshot-and-ownership
    ()
  :tags
  '(issue4-closure)
  (let ((raw "<2026-10-14 Wed 15:30 +0800>")
        result
        input)
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "#+DATE: " raw "\n")
      (let ((advice
             (lambda (text)
               (aset text 0 ?X)
               (setq result text))))
        (unwind-protect
            (progn
              (advice-add
               'org-texmacs--document-date-timestamp-text
               :override advice)
              (setq input
                    (org-texmacs-prepare-buffer (current-buffer))))
          (advice-remove
           'org-texmacs--document-date-timestamp-text advice)))
      (let* ((date
              (car (plist-get (org-texmacs-input-info input) :date)))
             (document (org-texmacs-document input)))
        (should (equal (org-element-property :raw-value date) raw))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (doc-data (doc-date "X2026-10-14 Wed 15:30 +0800>")))))
        (aset result 1 ?Y)
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (doc-data (doc-date "X2026-10-14 Wed 15:30 +0800>")))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          `(document (doc-data (doc-date ,raw)))))))
    ;; Pure construction also fixes the function, without buffer preparation.
    (let ((advice (lambda (_text) "PureDate")))
      (unwind-protect
          (progn
            (advice-add
             'org-texmacs--document-date-timestamp-text
             :override advice)
            (setq input
                  (org-texmacs-input-create
                   (org-element-create 'org-data nil)
                   (list
                    :date
                    (list
                     (org-element-create
                      'timestamp (list :raw-value raw)))))))
        (advice-remove
         'org-texmacs--document-date-timestamp-text advice))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document input))
        '(document (doc-data (doc-date "PureDate"))))))))

(ert-deftest org-texmacs-document-date-advice-result-and-error ()
  :tags
  '(issue4-closure)
  (dolist (value '(42 nil (strong "bad")))
    (let ((advice (lambda (_raw) value)))
      (unwind-protect
          (progn
            (advice-add
             'org-texmacs--document-date-timestamp-text
             :override advice)
            (with-temp-buffer
              (org-mode)
              (setq-local org-export-with-author nil)
              (insert "#+DATE: <2026-10-14>\n")
              (should-error
               (org-texmacs-document-from-buffer (current-buffer))
               :type 'org-texmacs-document-error)))
        (advice-remove
         'org-texmacs--document-date-timestamp-text advice))))
  (let ((advice (lambda (_raw) "")))
    (unwind-protect
        (progn
          (advice-add
           'org-texmacs--document-date-timestamp-text
           :override advice)
          (with-temp-buffer
            (org-mode)
            (setq-local org-export-with-author nil)
            (insert "#+DATE: <2026-10-14>\n")
            (should
             (equal
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              '(document (doc-data (doc-date "")))))))
      (advice-remove
       'org-texmacs--document-date-timestamp-text advice)))
  (let ((advice (lambda (_raw) (error "DateAdviceFailure"))))
    (unwind-protect
        (progn
          (advice-add
           'org-texmacs--document-date-timestamp-text
           :override advice)
          (with-temp-buffer
            (org-mode)
            (setq-local org-export-with-author nil)
            (insert "#+DATE: <2026-10-14>\n")
            (let ((state
                   (org-texmacs-test--document-buffer-state
                    (current-buffer))))
              (should-error
               (org-texmacs-document-from-buffer (current-buffer)))
              (should
               (equal
                state
                (org-texmacs-test--document-buffer-state
                 (current-buffer)))))))
      (advice-remove
       'org-texmacs--document-date-timestamp-text advice))))

(ert-deftest org-texmacs-document-date-worker-wait-snapshot ()
  :tags
  '(issue4-closure)
  (let ((advice (lambda (_raw) "ChangedDate")))
    (unwind-protect
        (with-temp-buffer
          (org-mode)
          (setq-local org-export-with-author nil)
          (insert "#+DATE: <2026-10-14>\n(math \"x\")\n")
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (advice-add
                        'org-texmacs--document-date-timestamp-text
                        :override advice)
                       '(math "x"))))
            (should
             (equal
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              '(document
                (doc-data (doc-date "<2026-10-14>")) (math "x"))))
            (should
             (equal
              (cadr
               (org-texmacs-document-body
                (org-texmacs-document-from-buffer (current-buffer))))
              '(doc-data (doc-date "ChangedDate"))))))
      (advice-remove
       'org-texmacs--document-date-timestamp-text advice))))

(ert-deftest
    org-texmacs-document-issue11-container-structure-and-paths
    ()
  :tags
  '(issue11)
  (org-texmacs-test--with-worker
   (dolist (context '(body quote center footnote list))
     (dolist (tree org-texmacs-test--fragment-strees)
       (let ((text (prin1-to-string tree))
             documents)
         (dolist (payload
                  (list
                   (concat text " \t\n")
                   (concat
                    "#+begin_texmacs\n" text "\n#+end_texmacs\n")))
           (with-temp-buffer
             (org-mode)
             (insert
              (org-texmacs-test--issue11-source context payload))
             (let ((before
                    (org-texmacs-test--document-buffer-state
                     (current-buffer))))
               (push (org-texmacs-document-from-buffer
                      (current-buffer))
                     documents)
               (should
                (equal
                 before
                 (org-texmacs-test--document-buffer-state
                  (current-buffer)))))))
         (should
          (equal
           (org-texmacs-document-body (car documents))
           (org-texmacs-document-body (cadr documents))))
         (should
          (equal
           (org-texmacs-document-stm-paths (car documents))
           (org-texmacs-document-stm-paths (cadr documents)))))))
   (dolist (prefix '("- " "1. " "- Term :: "))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert prefix "(math \"x\")\n")
       (let ((body
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))))
         (should (memq 'concat (flatten-tree body)))
         (should
          (memq
           (if (string-match-p "Term" prefix)
               'item*
             'item)
           (flatten-tree body)))))
     (with-temp-buffer
       (org-mode)
       (insert prefix "(equation \"x\")\n")
       (should-error
        (org-texmacs-document-from-buffer (current-buffer))
        :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-basic-inline-source ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n* /Title/\nA /i/ _u_ +s+ ~code~ =literal=.\n")
    (let ((source (buffer-string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Ordinary inline started a worker"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section (em "Title"))
            (concat
             "A "
             (em "i")
             " "
             (underline "u")
             " "
             (strike-through "s")
             " "
             (verbatim "code")
             " "
             (verbatim "literal")
             ". ")))))
      (should (equal source (buffer-string))))))

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

(ert-deftest org-texmacs-document-line-break-contexts ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: toc:nil\n* Title\nA\\\\\nB\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section "Title") (concat "A" (next-line) "B ")))))
  (let* ((break (org-element-create 'line-break nil))
         (italic (org-element-create 'italic nil "title" break))
         (headline
          (org-element-create
           'headline
           (list :level 1 :raw-value "title" :title (list italic))))
         (ast (org-element-create 'org-data nil headline)))
    (should-error
     (org-texmacs-test--lower ast)
     :type 'org-texmacs-document-error))
  (let* ((break (org-element-create 'line-break nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil "a " break " \tb"))))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-test--lower ast))
      '(document (concat "a " (next-line) "b"))))))

(ert-deftest org-texmacs-document-inline-native-whitespace ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
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

(ert-deftest org-texmacs-document-uri-source-forms ()
  (dolist (type '("http" "https" "mailto" "ftp" "ftps"))
    (let ((uri
           (concat
            type ":"
            (if (equal type "mailto")
                "user@example.org"
              "//example.org/a%20b?q=x%26y&n=2"))))
      (dolist (source
               (list
                (concat "[[" uri "]]\n")
                (concat "<" uri ">\n")
                (concat uri "\n")
                (concat "[[" uri "][Label]]\n")))
        (with-temp-buffer
          (org-mode)
          (insert source)
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (ert-fail "URI parsing started worker"))))
            (should
             (equal
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              (list
               'document
               (list
                'concat
                (list
                 'hlink
                 (if (equal source (concat "[[" uri "][Label]]\n"))
                     "Label"
                   uri)
                 uri)
                " ")))))
          (should (equal source (buffer-string))))))))

(ert-deftest org-texmacs-document-uri-rich-description ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n* [[https://example.org][Title]]\n"
     "A [[ftps://example.org/中%20文?q=x%26y&z=2][*bold* /em/]]\t end\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (section (hlink "Title" "https://example.org"))
        (concat
         "A "
         (hlink
          (concat (strong "bold") " " (em "em"))
          "ftps://example.org/中%20文?q=x%26y&z=2")
         " " "end "))))))

(ert-deftest org-texmacs-document-resolves-local-headline-links ()
  (let (prepared)
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil\n* Alpha\n:PROPERTIES:\n:CUSTOM_ID: local\n:ID: local-id\n:END:\n"
       "See [[#local][custom]], [[id:local-id][id]], [[*Alpha][heading]], "
       "[[Alpha][fuzzy]], and [[#local]].\n")
      (let ((source (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Local links started a worker"))))
          (setq prepared
                (org-texmacs-prepare-buffer (current-buffer))))
        (should (equal source (buffer-string)))))
    (should
     (equal
      (org-texmacs-test--stable-reference-body
       (org-texmacs-document prepared))
      '(document
        (section "Alpha") (label "org-texmacs-ref-1")
        (concat
         "See "
         (hlink "custom" "#org-texmacs-ref-1")
         ", "
         (hlink "id" "#org-texmacs-ref-1")
         ", "
         (hlink "heading" "#org-texmacs-ref-1")
         ", "
         (hlink "fuzzy" "#org-texmacs-ref-1")
         ", and "
         (reference "org-texmacs-ref-1")
         ". "))))))

(ert-deftest org-texmacs-document-resolves-dedicated-target ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\nSee [[spot][there]].\nHere <<spot>> later.\n")
    (let* ((body
            (org-texmacs-test--stable-reference-body
             (org-texmacs-document-from-buffer (current-buffer))))
           (paragraph (cadr body))
           (link '(hlink "there" "#org-texmacs-ref-1"))
           (target '(label "org-texmacs-ref-1")))
      (should (= (length body) 2))
      (should (eq (car paragraph) 'concat))
      (should (member link paragraph))
      (should (member target paragraph))
      (should
       (< (cl-position link paragraph :test #'equal)
          (cl-position target paragraph :test #'equal))))))

(ert-deftest
    org-texmacs-document-rejects-ambiguous-and-external-id-links
    ()
  (dolist
      (source
       '("#+OPTIONS: toc:nil\n* Alpha\n* Alpha\n[[*Alpha]]\n"
         "#+OPTIONS: toc:nil\n[[id:external-id]]\n"
         "#+OPTIONS: toc:nil\n#+EXCLUDE_TAGS: hidden\n* Hidden :hidden:\n:PROPERTIES:\n:CUSTOM_ID: gone\n:END:\n* Visible\n[[#gone]]\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (let ((before (buffer-string)))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)
        (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-document-reference-native-readback ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
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

(ert-deftest
    org-texmacs-document-reference-preflight-before-island-request
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "[[id:external-id][missing]]\n"
     "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Broken link requested an island"))))
      (let ((failure
             (should-error
              (org-texmacs-document-from-buffer (current-buffer))
              :type 'org-texmacs-document-error)))
        (should (equal (cadr failure) "Unresolved internal link"))))))

(ert-deftest
    org-texmacs-document-reference-low-headline-and-target-priority
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: H:1 toc:nil\n* Top\n** spot\n"
     "[[spot][there]] <<spot>>\n[[*spot][heading]]\n")
    (let* ((body
            (org-texmacs-test--stable-reference-body
             (org-texmacs-document-from-buffer (current-buffer))))
           (items (cadr (nth 2 body)))
           (paragraph (nth 3 items)))
      (should (equal (nth 1 items) '(concat (item) "spot")))
      (should (equal (nth 2 items) '(label "org-texmacs-ref-1")))
      (should
       (member '(hlink "there" "#org-texmacs-ref-2") paragraph))
      (should (member '(label "org-texmacs-ref-2") paragraph))
      (should
       (member '(hlink "heading" "#org-texmacs-ref-1") paragraph)))))

(ert-deftest org-texmacs-document-uri-private-syntax-restoration ()
  (dolist (suffix '("" "\n[[file:unsupported.org::#target][link]]\n"))
    (with-temp-buffer
      (org-mode)
      (insert "[[ftps://example.org][(math \"hidden\")]]" suffix)
      (let* ((variables
              '(org-link-parameters
                org-link-types-re
                org-link-angle-re
                org-link-plain-re
                org-link-bracket-re
                org-link-any-re
                org-element--object-regexp
                org-element-paragraph-separate))
             (before
              (mapcar
               (lambda (var)
                 (org-texmacs--document-copy-link-setting
                  (symbol-value var)))
               variables))
             (source (buffer-string))
             (reset (symbol-function 'org-element-cache-reset)))
        (cl-letf (((symbol-function 'org-element-cache-reset)
                   (lambda (&rest args)
                     (when (eq (car args) 'all)
                       (ert-fail "Global cache reset"))
                     (apply reset args)))
                  ((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Link description scanned as STM"))))
          (if (equal suffix "")
              (should
               (equal
                (org-texmacs-document-body
                 (org-texmacs-document-from-buffer (current-buffer)))
                '(document
                  (concat
                   (hlink
                    "(math \"hidden\")" "ftps://example.org")))))
            (should-error
             (org-texmacs-document-from-buffer (current-buffer))
             :type 'org-texmacs-document-error)))
        (should (equal before (mapcar #'symbol-value variables)))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-document-uri-abbreviation-and-stale-settings
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-link-abbrev-alist-local
                '(("short" . "https://example.org/%s")))
    (insert "[[short:page][Page]]\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (concat (hlink "Page" "https://example.org/page") " "))))
    (insert "(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (setq-local org-link-abbrev-alist-local nil)
                 '(math "x"))))
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-uri-native-islands ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "[[https://example.org/中%20文?q=a&b=%26][中文 <alpha>]] (math \"<alpha>\")\n")
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

(ert-deftest org-texmacs-document-footnote-source ()
  (with-temp-buffer
    (org-mode)
    (insert "A[fn::one][fn::two] end\n")
    (let ((source (buffer-string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Ordinary footnote started worker"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (concat
             "A"
             (footnote (document (concat "one")))
             (footnote (document (concat "two"))) " " "end ")))))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-footnote-rejects-contexts ()
  (dolist (context '(title bold link footnote))
    (let* ((note
            (org-element-create
             'footnote-reference '(:type inline) "note"))
           (container
            (pcase context
              ('title
               (org-element-create
                'headline
                (list
                 :level 1
                 :raw-value "title"
                 :title (list note))))
              ('bold
               (org-element-create
                'paragraph nil (org-element-create 'bold nil note)))
              ('link
               (org-element-create
                'paragraph nil
                (org-element-create
                 'link '(:type "https" :path "//example.org") note)))
              ('footnote
               (org-element-create
                'paragraph nil
                (org-element-create
                 'footnote-reference '(:type inline) note)))))
           (ast (org-element-create 'org-data nil container)))
      (should-error
       (org-texmacs-test--lower ast)
       :type 'org-texmacs-document-error)))
  (dolist (source
           '("A[fn:name]\n"
             "A[fn:name:outer [fn::inner]]\n"
             "* Title[fn::note]\n"
             "[fn::outer [fn::inner]]\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-named-footnote-first-and-repeated ()
  (dolist (source
           '("A[fn:n] again[fn:n].\n\n[fn:n] *Body*.\n"
             "A[fn:n:*Body*.] again[fn:n].\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Ordinary named footnote started worker"))))
        (let ((body
               (org-texmacs-document-body
                (org-texmacs-document-from-buffer (current-buffer)))))
          (should
           (equal
            (nth 2 (cadr body))
            `(footnote
              (surround
               (label "org-texmacs-fn-1") ""
               (document
                (concat
                 (strong "Body")
                 ,(if (string-prefix-p "A[fn:n]" source)
                      ". "
                    ".")))))))
          (should
           (equal
            (nth 5 (cadr body))
            '(rsup
              (with
               "font-shape" "right"
               (reference "org-texmacs-fn-1")))))))
      (should (equal source (buffer-string))))))

(ert-deftest
    org-texmacs-document-named-footnote-forward-inline-definition
    ()
  (with-temp-buffer
    (org-mode)
    (insert "A[fn:n] then[fn:n:Body].\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (concat
         "A"
         (footnote
          (surround
           (label "org-texmacs-fn-1") "" (document (concat "Body"))))
         " " "then"
         (rsup
          (with "font-shape" "right" (reference "org-texmacs-fn-1")))
         ". "))))))

(ert-deftest org-texmacs-document-named-footnote-pruned-definitions ()
  (dolist (definition
           '("[fn:n] Preserved body.\n"
             "Hidden[fn:n:Preserved body. ]\n"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil tags:nil\n#+SELECT_TAGS: keep\n* Hidden\n"
       definition
       "* Visible :keep:\nA[fn:n].\n")
      (cl-letf (((symbol-function 'org-footnote-get-definition)
                 (lambda (&rest _)
                   (ert-fail "Footnote read source buffer")))
                ((symbol-function 'org-export--missing-definitions)
                 (lambda (&rest _)
                   (ert-fail "Footnote used buffer fallback"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section "Visible")
            (concat
             "A"
             (footnote
              (surround
               (label "org-texmacs-fn-1")
               ""
               (document (concat "Preserved body. "))))
             ". "))))))))

(ert-deftest org-texmacs-document-named-footnote-section-setting ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-footnote-section "Notes")
    (insert "A[fn:n].\n* Notes\n[fn:n] Note.\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (concat
         "A"
         (footnote
          (surround
           (label "org-texmacs-fn-1")
           ""
           (document (concat "Note. "))))
         ". "))))
    (erase-buffer)
    (insert "A[fn:n].\n\n[fn:n] (math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (setq-local org-footnote-section "Changed")
                 '(math "x"))))
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-named-footnote-unused-and-invalid ()
  (with-temp-buffer
    (org-mode)
    (insert
     "Visible.\n\n[fn:unused] (math \"unused\") [[unknown:bad]]\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Unused definition started worker"))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document (concat "Visible. "))))))
  (dolist (source
           '("A[fn:missing]. (math \"x\")\n"
             "A[fn:n].\n\n[fn:n] One.\n\n[fn:n] Two.\n"
             "A[fn:n].\n\n[fn:n] Nested[fn:m].\n\n[fn:m] Body.\n"
             "A[fn:n:One] B[fn:n:Two]\n"
             "A[fn:n].\n\n[fn:n] Recursive[fn:n].\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid footnote started worker"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-document-named-footnote-owned-body-and-provenance
    ()
  (let (input
        requests)
    (with-temp-buffer
      (org-mode)
      (insert
       "A[fn:n] repeat[fn:n].\n\n[fn:n] [[file:note.txt][File]] (math \"x\")\n\nSecond.\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (push source requests)
                   '(math "x"))))
        (setq input (org-texmacs-prepare-buffer (current-buffer)))))
    (should (equal requests '("(math \"x\")")))
    (cl-letf (((symbol-function 'org-footnote-get-definition)
               (lambda (&rest _)
                 (ert-fail "Owned input read buffer")))
              ((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Owned input started worker"))))
      (let* ((result (org-texmacs-document input))
             (body (org-texmacs-document-body result)))
        (should
         (equal
          (org-texmacs-document-stm-paths result) '((0 1 0 2 0 2))))
        (should
         (equal
          (org-texmacs-document-file-paths result)
          '((0 1 0 2 0 0 1))))
        (should
         (equal
          (nth 2 (cadr body))
          '(footnote
            (surround
             (label "org-texmacs-fn-1") ""
             (document
              (concat (hlink "File" "note.txt") " " (math "x") " ")
              (concat "Second. "))))))))))

(ert-deftest org-texmacs-document-named-footnote-native ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
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

(ert-deftest
    org-texmacs-document-named-footnote-blocks-and-local-targets
    ()
  (dolist (entry
           '(("#+begin_quote\nQuote.\n#+end_quote\n" . quotation)
             ("#+begin_center\nCenter.\n#+end_center\n" . center)
             ("- Item.\n" . itemize)
             ("#+begin_example\nCode.\n#+end_example\n" . code)
             ("| A | B |\n" . tabular)))
    (with-temp-buffer
      (org-mode)
      (insert "A[fn:n].\n\n[fn:n] Body.\n\n" (car entry))
      (let* ((body
              (org-texmacs-test--stable-reference-body
               (org-texmacs-document-from-buffer (current-buffer))))
             (definition (nth 3 (cadr (nth 2 (cadr body))))))
        (should (eq (car (nth 2 definition)) (cdr entry))))))
  (with-temp-buffer
    (org-mode)
    (insert "A[fn:n] [[inside][Link]].\n\n[fn:n] <<inside>> Body.\n")
    (let ((body
           (org-texmacs-test--stable-reference-body
            (org-texmacs-document-from-buffer (current-buffer)))))
      (should
       (equal
        (nth 4 (cadr body)) '(hlink "Link" "#org-texmacs-ref-1")))
      (should
       (equal
        (cadr (cadr (nth 3 (cadr (nth 2 (cadr body))))))
        '(label "org-texmacs-ref-1"))))))

(ert-deftest org-texmacs-document-issue10-owned-forward-and-scoped ()
  :tags
  '(issue10)
  (dolist (scope '(full selected subtree region narrowed))
    (let (input
          requests)
      (with-temp-buffer
        (org-mode)
        (insert
         "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
         "* Hidden\nHidden[fn:n:Before (math \"x\") [[file:note.txt][File]] (math \"y\")].\n"
         "Unused[fn:u:(math \"unused\")].\n"
         "* Visible :keep:\nA[fn:n] repeat[fn:n].\n")
        (setq-local default-directory "/base/")
        (when (eq scope 'selected)
          (goto-char 1)
          (insert "#+SELECT_TAGS: keep\n"))
        (goto-char (point-min))
        (search-forward "* Visible")
        (beginning-of-line)
        (let ((begin (point))
              (end (point-max)))
          (when (eq scope 'narrowed)
            (narrow-to-region begin end))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (raw)
                       (push raw requests)
                       (cond
                        ((string-match-p "unused" raw)
                         '(math "unused"))
                        ((string-match-p "x" raw)
                         '(math "x"))
                        (t
                         '(math "y")))))
                    ((symbol-function 'org-footnote-get-definition)
                     (lambda (&rest _)
                       (ert-fail "Definition source fallback"))))
            (let ((before
                   (org-texmacs-test--document-buffer-state
                    (current-buffer))))
              (setq input
                    (org-texmacs-prepare-buffer
                     (current-buffer)
                     nil
                     (and (eq scope 'subtree) begin)
                     (and (eq scope 'region) (cons begin end))))
              (should
               (equal
                before
                (org-texmacs-test--document-buffer-state
                 (current-buffer))))))))
      (should
       (equal
        (reverse requests)
        (append
         '("(math \"x\")" "(math \"y\")")
         (and (eq scope 'full) '("(math \"unused\")")))))
      (unless (eq scope 'full)
        (should-not (member "(math \"unused\")" requests)))
      ;; The source buffer is already dead; both pure conversions must succeed.
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Owned lowering requested worker")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _)
                   (ert-fail "Owned lowering read buffer"))))
        (let* ((first (org-texmacs-document input))
               (second (org-texmacs-document input))
               (body (org-texmacs-document-body first)))
          (should (equal body (org-texmacs-document-body second)))
          (should
           (= (length (org-texmacs-document-stm-paths first))
              (if (eq scope 'full)
                  3
                2)))
          (should
           (= (length (org-texmacs-document-file-paths first)) 1))
          (should
           (= (cl-count 'footnote (flatten-tree body))
              (if (eq scope 'full)
                  2
                1)))
          (should (memq 'reference (flatten-tree body)))
          (should
           (string-match-p
            "/base/note.txt"
            (org-texmacs--native-document-wire first))))))))

(ert-deftest org-texmacs-document-footnote-stm-support ()
  (with-temp-buffer
    (org-mode)
    (insert "A[fn::(math \"hidden\")] (math \"visible\")\n")
    (let (requests)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (push source requests)
                   (if (string-match-p "hidden" source)
                       '(math "hidden")
                     '(math "visible")))))
        (let ((result
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal
            (reverse requests)
            '("(math \"hidden\")" "(math \"visible\")")))
          (should
           (equal
            (org-texmacs-document-body result)
            '(document
              (concat
               "A"
               (footnote (document (math "hidden")))
               " "
               (math "visible")
               " "))))
          (should
           (equal
            (org-texmacs-document-stm-paths result)
            '((0 1 0 0) (0 3)))))))))

(ert-deftest org-texmacs-document-footnote-rich-native ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
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

(ert-deftest
    org-texmacs-document-relative-headlines-and-low-level-lists
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: H:2 num:1 toc:nil\n"
     "** Top\n"
     "*** Child\n"
     "**** Deep A\n"
     "**** Deep B\n"
     "***** Nested\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (section "Top") (subsection* "Child")
        (itemize
         (document
          (concat (item) "Deep A")
          (concat (item) "Deep B")
          (itemize (document (concat (item) "Nested"))))))))
    (erase-buffer)
    (insert "#+OPTIONS: H:0 toc:nil\n* First\n* Second\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (itemize
         (document
          (concat (item) "First") (concat (item) "Second"))))))))

(ert-deftest
    org-texmacs-document-five-section-levels-and-unnumbered-property
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: H:5 num:nil toc:nil\n"
     "* One\n** Two\n*** Three\n**** Four\n***** Five\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (section* "One")
        (subsection* "Two")
        (subsubsection* "Three")
        (paragraph* "Four")
        (subparagraph* "Five"))))
    (erase-buffer)
    (insert
     "* Visible title\n"
     ":PROPERTIES:\n"
     ":UNNUMBERED: notoc\n"
     ":ALT_TITLE: Short *title*\n"
     ":END:\n"
     "Body\n")
    (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
           (headline
            (car
             (org-element-contents (org-texmacs-input-ast input)))))
      (should
       (equal
        (org-texmacs-document-body (org-texmacs-document input))
        '(document (section* "Visible title") (concat "Body "))))
      (let ((alt (org-element-property :ALT_TITLE headline)))
        (should
         (equal (mapcar #'org-element-type alt) '(plain-text bold)))
        (dolist (object alt)
          (should
           (eq (org-element-property :parent object) headline)))))))

(ert-deftest org-texmacs-document-toc-structure-and-headline-policies
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: H:3 toc:2 num:1 tags:not-in-toc todo:nil\n"
     "* Visible :tag:\n"
     ":PROPERTIES:\n:ALT_TITLE: Short *title*\n:END:\n"
     "** Child\n"
     "*** Deep\n"
     "* Plain\n"
     ":PROPERTIES:\n:UNNUMBERED: t\n:END:\n"
     "* Hidden\n"
     ":PROPERTIES:\n:UNNUMBERED: notoc\n:END:\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (table-of-contents
         "org-texmacs-toc"
         (document
          (toc-1
           (hlink
            (concat "1 " (concat "Short " (strong "title")))
            "#org-texmacs-toc-1")
           (pageref "org-texmacs-toc-1"))
          (toc-2
           (hlink "Child" "#org-texmacs-toc-2")
           (pageref "org-texmacs-toc-2"))
          (toc-1
           (hlink "Plain" "#org-texmacs-toc-3")
           (pageref "org-texmacs-toc-3"))))
        (section (concat "Visible" " " ":tag:"))
        (label "org-texmacs-toc-1")
        (subsection* "Child")
        (label "org-texmacs-toc-2")
        (subsubsection* "Deep")
        (section* "Plain")
        (label "org-texmacs-toc-3")
        (section* "Hidden"))))))

(ert-deftest org-texmacs-document-toc-uses-filtered-context ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: tasks:done toc:2 todo:nil\n"
     "* TODO Dropped\n"
     "** Dropped child\n"
     "* DONE Kept\n"
     "** Child\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (table-of-contents
         "org-texmacs-toc"
         (document
          (toc-1
           (hlink (concat "1 " "Kept") "#org-texmacs-toc-1")
           (pageref "org-texmacs-toc-1"))
          (toc-2
           (hlink (concat "1.1 " "Child") "#org-texmacs-toc-2")
           (pageref "org-texmacs-toc-2"))))
        (section "Kept")
        (label "org-texmacs-toc-1")
        (subsection "Child")
        (label "org-texmacs-toc-2"))))))

(ert-deftest org-texmacs-document-toc-static-label-conflict-native ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
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

(ert-deftest org-texmacs-document-rejects-headline-depth-over-five ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: H:6\n* Heading\n")
    (should-error
     (org-texmacs-prepare-buffer (current-buffer))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-list-source-forms ()
  (dolist (case
           '(("- One\n- Two\n" (document
               (itemize
                (document
                 (concat (item) "One ") (concat (item) "Two ")))))
             ("1. First\n2. Second\n" (document
               (enumerate
                (document
                 (concat (item) "First ")
                 (concat (item) "Second ")))))
             ("- (math \"term\") :: Definition\n- Untagged\n"
              (document
               (description
                (document
                 (concat (item* "(math \"term\")") "Definition ")
                 (concat (item) "Untagged ")))))))
    (with-temp-buffer
      (org-mode)
      (insert (car case))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Description term reached worker"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          (cadr case)))))))

(ert-deftest org-texmacs-document-nested-list-island ()
  (with-temp-buffer
    (org-mode)
    (insert "- Outer\n  1. Inner (math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (source)
                 (should (equal source "(math \"x\")"))
                 '(math "x"))))
      (let ((document
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (itemize
             (document
              (concat (item) "Outer ")
              (enumerate
               (document
                (concat (item) "Inner " (math "x") " "))))))))
        (should
         (equal
          (org-texmacs-document-stm-paths document)
          '((0 0 1 0 0 2))))))))

(ert-deftest org-texmacs-document-quote-and-center-containers ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+begin_quote\nFirst (math \"q\").\n\nSecond.\n#+end_quote\n"
     "#+begin_center\n- Centered item\n#+end_center\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (source)
                 (should (equal source "(math \"q\")"))
                 '(math "q"))))
      (let ((document
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (quotation
             (document
              (concat "First " (math "q") ". ") (concat "Second. ")))
            (center
             (document
              (itemize
               (document (concat (item) "Centered item "))))))))
        (should
         (equal
          (org-texmacs-document-stm-paths document) '((0 0 0 1))))))))

(ert-deftest org-texmacs-document-quote-uniform-quotation ()
  :tags
  '(issue4)
  (dolist (contents
           '("Single.\n"
             "First.\n\nSecond.\n"
             "- Nested item\n"
             "#+begin_center\nNested.\n#+end_center\n"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil title:nil author:nil date:nil\n#+begin_quote\n"
       contents
       "#+end_quote\n")
      (let* ((before (buffer-string))
             (document
              (org-texmacs-document-from-buffer (current-buffer)))
             (container (cadr (org-texmacs-document-body document))))
        (should (eq (car container) 'quotation))
        (should (eq (caadr container) 'document))
        (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-document-rejects-list-checkbox-and-counter ()
  (dolist (source '("- [ ] Task\n" "1. [@3] Counted\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid list reached worker"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

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

(ert-deftest org-texmacs-document-preformatted-source-forms ()
  (with-temp-buffer
    (org-mode)
    (setq-local tab-width 4)
    (insert
     "#+begin_example\n"
     "    a\tb\n"
     "      c  d\n"
     "\n"
     "    中¯˙ <alpha> (math \"hidden\")\n"
     "#+end_example\n\n"
     ": x\ty\n"
     ":  z  q\n\n"
     "#+begin_src emacs-lisp\n"
     "  ,* protected\n"
     "    (+ 1 2)\n"
     "\n"
     "  中文\t<alpha> (math \"hidden\")\n"
     "#+end_src\n\n"
     "#+begin_example\n#+end_example\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Preformatted text reached worker")))
              ((symbol-function 'org-export-unravel-code)
               (lambda (&rest _)
                 (ert-fail
                  "Preformatted text invoked coderef processing")))
              ((symbol-function 'org-babel-execute-src-block)
               (lambda (&rest _) (ert-fail "Source block executed"))))
      (let ((document
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (code
             (document
              "a   b" "  c  d" "" "中¯˙ <alpha> (math \"hidden\")"))
            (code (document "x   y" " z  q"))
            (code
             (document
              "* protected"
              "  (+ 1 2)"
              ""
              "中文    <alpha> (math \"hidden\")"))
            (code (document "")))))
        (should-not (org-texmacs-document-stm-paths document))))))

(ert-deftest
    org-texmacs-document-preformatted-tab-snapshot-and-preserve-indent
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local tab-width 4)
    (insert "#+begin_example -i\n  a\tb\n#+end_example\n")
    (let ((input (org-texmacs-prepare-buffer (current-buffer))))
      (should
       (= (plist-get
           (org-texmacs-input-info input)
           :texmacs-tab-width)
          4))
      (setq-local tab-width 8)
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document input))
        '(document (code (document "  a b")))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document (code (document "  a     b"))))))))

(ert-deftest org-texmacs-document-rejects-dynamic-code-semantics ()
  (dolist (source
           '("#+begin_src emacs-lisp -n\nx\n#+end_src\n"
             "#+begin_src emacs-lisp -r\nx (ref:line)\n#+end_src\n"
             "#+begin_src emacs-lisp :noweb yes\nx\n#+end_src\n"
             "#+begin_example -n\nx\n#+end_example\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid code reached worker")))
                ((symbol-function 'org-babel-execute-src-block)
                 (lambda (&rest _)
                   (ert-fail "Invalid source block executed"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-preformatted-native-and-provenance
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local tab-width 4)
     (insert
      "(math \"x\")\n\n"
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

(ert-deftest org-texmacs-document-table-source-and-inline-subset ()
  (with-temp-buffer
    (org-mode)
    (insert
     "| Name | Value |\n"
     "| 中 <alpha> (math \"literal\") | *bold* [[https://example.org][site]] |\n"
     "| empty | |\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Table text reached worker"))))
      (let ((document
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (tabular
             (tformat
              (table
               (row (cell "Name") (cell "Value"))
               (row
                (cell "中 <alpha> (math \"literal\")")
                (cell
                 (concat
                  (strong "bold")
                  " "
                  (hlink "site" "https://example.org"))))
               (row (cell "empty") (cell ""))))))))
        (should-not (org-texmacs-document-stm-paths document))))))

(ert-deftest org-texmacs-document-table-rule-positions ()
  (with-temp-buffer
    (org-mode)
    (insert
     "|----+----|\n"
     "| h1 | h2 |\n"
     "| h3 | h4 |\n"
     "|----+----|\n"
     "| a  | b  |\n"
     "|----+----|\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (tabular
         (tformat
          (cwith "1" "1" "1" "-1" "cell-tborder" "1ln")
          (cwith "2" "2" "1" "-1" "cell-bborder" "1ln")
          (cwith "3" "3" "1" "-1" "cell-bborder" "1ln")
          (table
           (row (cell "h1") (cell "h2"))
           (row (cell "h3") (cell "h4"))
           (row (cell "a") (cell "b"))))))))))

(ert-deftest
    org-texmacs-document-table-alignment-row-positions-and-ownership
    ()
  :tags
  '(issue4)
  (dolist (position '(0 1 2))
    (with-temp-buffer
      (org-mode)
      (let ((lines
             '("| LeftLongest | MiddleLongest | RightLongest |\n"
               "| L | C | R |\n")))
        (dotimes (index 3)
          (when (= index position)
            (insert "| <l> | <c> | <r> |\n"))
          (when (< index 2)
            (insert (nth index lines)))))
      (let* ((source (buffer-string))
             (input (org-texmacs-prepare-buffer (current-buffer)))
             (print-circle t)
             (before (prin1-to-string (org-texmacs-input-ast input)))
             (document (org-texmacs-document input)))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
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
               (row (cell "L") (cell "C") (cell "R"))))))))
        (should
         (equal
          before (prin1-to-string (org-texmacs-input-ast input))))
        (should (equal source (buffer-string)))))))

(ert-deftest
    org-texmacs-document-table-alignment-column-counts-and-rules
    ()
  :tags
  '(issue4)
  (dolist (count '(1 2 4))
    (with-temp-buffer
      (org-mode)
      (let ((fields (make-list count "<c>"))
            (data (make-list count "x")))
        (insert
         "| "
         (mapconcat #'identity fields " | ")
         " |\n"
         "| "
         (mapconcat #'identity data " | ")
         " |\n"))
      (let* ((body
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer))))
             (format (cadadr body)))
        (should (eq (car format) 'tformat))
        (should (= (length (cdr format)) (1+ count)))
        (should
         (= (length (cdr (cadr (car (last format))))) count)))))
  (with-temp-buffer
    (org-mode)
    (insert
     "|---+---|\n| <r> | <l> |\n| Head | Col |\n"
     "|---+---|\n| 1 | 2 |\n|---+---|\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (tabular
         (tformat
          (cwith "1" "-1" "1" "1" "cell-halign" "r")
          (cwith "1" "-1" "2" "2" "cell-halign" "l")
          (cwith "1" "1" "1" "-1" "cell-tborder" "1ln")
          (cwith "1" "1" "1" "-1" "cell-bborder" "1ln")
          (cwith "2" "2" "1" "-1" "cell-bborder" "1ln")
          (table
           (row (cell "Head") (cell "Col"))
           (row (cell "1") (cell "2"))))))))))

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
         (insert
          "#+OPTIONS: toc:nil title:nil author:nil date:nil\n[[t]]\n\n"
          "#+name: t\n#+caption: Caption [[./caption.org][CaptionFile]]\n"
          (or format "")
          "| [[./asset.org][AssetFile]] | =<r>= <alpha> |\n"
          "\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
         (push (org-texmacs-document-from-buffer (current-buffer))
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

(ert-deftest org-texmacs-document-table-alignment-rejections ()
  :tags
  '(issue4)
  (dolist (source
           '("| <l> | <r> |\n| <l> | <r> |\n| a | b |\n"
             "| <l> | <r> |\n| a | b |\n| <r> | <l> |\n"
             "| <l> | |\n| a | b |\n"
             "| <l> | data |\n| a | b |\n"
             "| <r10> | data |\n| a | b |\n"
             "| <10> |\n| a |\n"
             "| <l> | <r> |\n"
             "|---+---|\n| <l> | <r> |\n|---+---|\n"
             "| <l> | <r> |\n| a | b | c |\n"
             "| a | b |\n| <l> | <r> | <c> |\n"
             "|---+---|\n| <l> | <r> |\n|---+---|\n| a | b |\n"
             "| <l> | <r> |\n| / | < |\n| # | data |\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error)
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-rejects-advanced-table-semantics ()
  (dolist (source
           '("| a | b | c |\n| d |\n"
             "| <l> | <10> |\n| a | b |\n"
             "| / | < | > |\n| # | a | b |\n|   | c | d |\n"
             "| a | b |\n| 1 | 2 |\n#+TBLFM: $2=$1+1\n"
             "|---+---|\n|---+---|\n| a | b |\n"
             "| [fn::note] |\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid table reached worker"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error))))
  (let* ((cell (org-element-create 'table-cell nil "x"))
         (row (org-element-create 'table-row '(:type standard) cell))
         (table (org-element-create 'table '(:type table.el) row))
         (ast (org-element-create 'org-data nil table)))
    (should-error
     (org-texmacs-test--lower ast)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-named-table-captions-and-links ()
  (with-temp-buffer
    (org-mode)
    (insert
     "[[t]] [[t][Table]].\n\n"
     "#+name: t\n#+caption[Short *S*]: Long [[t][self]]\n"
     "#+caption: Second <alpha>\n| a | b |\n")
    (let ((body
           (org-texmacs-test--stable-reference-body
            (org-texmacs-document-from-buffer (current-buffer)))))
      (should
       (equal
        body
        '(document
          (concat
           (reference "org-texmacs-ref-1") " "
           (hlink "Table" "#org-texmacs-ref-1") ". ")
          (big-table
           (tabular (tformat (table (row (cell "a") (cell "b")))))
           (surround
            (label "org-texmacs-ref-1") ""
            (caption-detailed
             (concat
              (concat "Long " (hlink "self" "#org-texmacs-ref-1"))
              " "
              "Second <alpha>")
             (concat "Short " (strong "S")))))))))))

(ert-deftest org-texmacs-document-named-table-uncaptioned-and-priority
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n[[same][Table]]\n\n"
     "#+name: same\n| x |\n\n* same\n")
    (let ((body
           (org-texmacs-test--stable-reference-body
            (org-texmacs-document-from-buffer (current-buffer)))))
      (should
       (equal
        (cadr body)
        '(concat (hlink "Table" "#org-texmacs-ref-1") " ")))
      (should
       (equal
        (nth 2 body)
        '(surround
          (label "org-texmacs-ref-1")
          ""
          (tabular (tformat (table (row (cell "x"))))))))))
  (with-temp-buffer
    (org-mode)
    (insert "#+name: unused\n| x |\n")
    (should
     (equal
      (org-texmacs-test--stable-reference-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (tabular (tformat (table (row (cell "x"))))))))))

(ert-deftest org-texmacs-document-named-table-rejects-before-worker ()
  (dolist
      (source
       '("[[t]]\n\n#+name: t\n| x |\n"
         "[[t][T]]\n\n#+name: t\n| x |\n\n#+name: t\n| y |\n"
         "[[t][T]]\n\n<<t>>\n\n#+name: t\n| x |\n"
         "#+EXCLUDE_TAGS: hidden\n[[t][T]]\n* Hidden :hidden:\n#+name: t\n| x |\n"
         "#+name: t\n#+name: again\n| x |\n"
         "#+name: t\n#+attr_html: :class hidden\n| x |\n"
         "#+caption: C\n#+attr_texmacs: float\n| x |\n"
         "#+caption: C\n#+results: data\n| x |\n"
         "#+caption:\n| x |\n"
         "#+caption: [[missing]]\n| x |\n"
         "#+caption: [cite:@k]\n| x |\n"))
    (with-temp-buffer
      (org-mode)
      (insert
       source "\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
      (let ((before (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail
                      "Invalid named table reached worker"))))
          (ert-info
           ((format "Named-table source: %s" source))
           (should-error
            (org-texmacs-document-from-buffer (current-buffer))
            :type 'org-texmacs-document-error)))
        (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-document-named-table-native-and-provenance ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq default-directory "/tmp/")
     (insert
      "[[t]]\n\n#+name: t\n#+caption[Short]: 中 <alpha> [[./caption.org][File]]\n| x |\n"
      "\n#+begin_texmacs\n(label \"org-texmacs-ref-1\")\n#+end_texmacs\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
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
     (insert
      "| 中 <alpha> | *B* |\n"
      "|------------+-----|\n"
      "| x          |     |\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
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

(ert-deftest org-texmacs-document-source-without-islands ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n* A *bold*\t title\nText *strong*\t  tail.\n")
    (goto-char 4)
    (let ((source (buffer-string))
          (position (point))
          (tick (buffer-chars-modified-tick)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Unexpected worker request"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section (concat "A " (strong "bold") " " "title"))
            (concat "Text " (strong "strong") " " "tail. ")))))
      (should (= position (point)))
      (should (= tick (buffer-chars-modified-tick)))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-document-source-adjacent-islands ()
  (with-temp-buffer
    (org-mode)
    (insert "Before (math \"*fake* [[link]]\")(math \"α\") after.\n")
    (let ((requests nil))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (push (substring-no-properties source) requests)
                   (list
                    'math
                    (if (= (length requests) 1)
                        "*fake* [[link]]"
                      "α")))))
        (let ((result
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (equal
            (org-texmacs-document-body result)
            '(document
              (concat
               "Before "
               (math "*fake* [[link]]")
               (math "α")
               " after. "))))
          (should
           (equal
            (org-texmacs-document-stm-paths result) '((0 1) (0 2))))
          (should
           (equal
            (nreverse requests)
            '("(math \"*fake* [[link]]\")" "(math \"α\")"))))))))

(ert-deftest org-texmacs-document-source-preflight ()
  (dolist
      (source
       '("(math \"x\")\n\n[[file:unsupported.org::#target][link]]\n"
         "#+include: missing.org\n"
         "#+begin_src emacs-lisp -n\n(error \"never execute\")\n#+end_src\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Preflight started parsing"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-source-rejects-context ()
  (with-temp-buffer
    (should-error
     (org-texmacs-document-from-buffer (current-buffer))
     :type 'org-texmacs-document-error)
    (org-mode)
    (insert "First\nSecond\n")
    (narrow-to-region 2 (point-max))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (concat "irst Second "))))
    (should (= (point-min) 2))))

(ert-deftest org-texmacs-document-explicit-source-and-wrapper ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: toc:nil\n*** Heading\n")
    (setq-local org-odd-levels-only t)
    (let* ((source (current-buffer))
           (expected (org-texmacs-document-from-buffer source)))
      (should (equal expected (org-texmacs-document-current-buffer)))
      (with-temp-buffer
        (org-mode)
        (insert "Unrelated\n")
        (setq-local org-odd-levels-only nil)
        (narrow-to-region 2 (point-max))
        (let ((caller (current-buffer))
              (position (point)))
          (should
           (equal expected (org-texmacs-document-from-buffer source)))
          (should (eq caller (current-buffer)))
          (should (= position (point)))
          (should (= 2 (point-min)))))
      (should
       (equal
        (org-texmacs-document-body expected)
        '(document (section "Heading")))))))

(ert-deftest
    org-texmacs-document-explicit-source-rejects-invalid-input
    ()
  (with-temp-buffer
    (org-mode)
    (dolist (source (list nil t 1 (buffer-name)))
      (should-error
       (org-texmacs-document-from-buffer source)
       :type 'org-texmacs-document-error))
    (should-error
     (org-texmacs-document-from-buffer)
     :type 'wrong-number-of-arguments)
    (let ((dead
           (with-temp-buffer
             (current-buffer))))
      (should-error
       (org-texmacs-document-from-buffer dead)
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-document-explicit-source-survives-buffer-switch
    ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\") (math \"x\")\n")
    (let ((source (current-buffer)))
      (with-temp-buffer
        (let ((caller (current-buffer))
              (calls 0))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (_source)
                       (setq calls (1+ calls))
                       (set-buffer caller)
                       '(math "x"))))
            (let ((result (org-texmacs-document-from-buffer source)))
              (should
               (equal
                (org-texmacs-document-stm-paths result)
                '((0 0) (0 2)))))
            (should (= calls 2))
            (should (eq caller (current-buffer)))))))))

(ert-deftest
    org-texmacs-document-explicit-source-checks-after-lowering
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Text\n")
    (let ((source (current-buffer))
          (lower (symbol-function 'org-texmacs--document-lower))
          (calls 0))
      (cl-letf (((symbol-function 'org-texmacs--document-lower)
                 (lambda (&rest args)
                   (setq calls (1+ calls))
                   (prog1 (apply lower args)
                     (when (= calls 2)
                       (with-current-buffer source
                         (insert "changed")))))))
        (should-error
         (org-texmacs-document-from-buffer source)
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-formatter-parser-isolation ()
  ;; Exclude FTPS even if another package has registered it in this Emacs.
  (let ((org-link-parameters
         (cl-remove
          "ftps"
          org-link-parameters
          :key #'car
          :test #'equal))
        (org-link-types-re org-link-types-re)
        (org-link-angle-re org-link-angle-re)
        (org-link-plain-re org-link-plain-re)
        (org-link-bracket-re org-link-bracket-re)
        (org-link-any-re org-link-any-re)
        (org-element--object-regexp org-element--object-regexp)
        (org-element-paragraph-separate
         org-element-paragraph-separate))
    (org-link-make-regexps)
    (org-element--set-regexps)
    (with-temp-buffer
      (org-mode)
      (insert "[[ftps://example.org][Other]]\n")
      (let* ((other (current-buffer))
             (types
              (lambda ()
                (with-current-buffer other
                  (org-element-map
                   (org-element-parse-buffer) 'link
                   (lambda (link)
                     (org-element-property :type link))))))
             (baseline (funcall types))
             (settings (org-texmacs--document-link-settings))
             (calls 0))
        (with-temp-buffer
          (org-mode)
          (insert
           "#+OPTIONS: toc:nil\n* Title\n[[ftps://example.org][Own]]\n")
          (let ((org-texmacs-format-headline-function
                 (lambda (&rest _)
                   (setq calls (1+ calls))
                   (should
                    (equal
                     settings (org-texmacs--document-link-settings)))
                   (should (equal baseline (funcall types)))
                   "Title")))
            (cl-letf (((symbol-function 'org-texmacs--worker-request)
                       (lambda (&rest _)
                         (ert-fail "Plain content started worker"))))
              (should
               (equal
                (org-texmacs-document-body
                 (org-texmacs-document-from-buffer (current-buffer)))
                '(document
                  (section "Title")
                  (concat (hlink "Own" "ftps://example.org") " "))))))
          ;; Both the structural preflight and the final lowering were observed.
          (should (= calls 2)))
        (should (equal baseline (funcall types)))))))

(ert-deftest org-texmacs-document-preserves-buffer-state-on-exit ()
  (dolist (outcome '(success unsupported parse-error worker-error))
    (dolist (modified '(nil t))
      (with-temp-buffer
        (org-mode)
        (insert "Text (math \"x\")\n")
        (when (eq outcome 'unsupported)
          (insert "\n[[file:unsupported.org::#target][link]]\n"))
        (put-text-property 1 3 'org-texmacs-test-property "retained")
        (goto-char 3)
        (set-mark 2)
        (setq mark-active t)
        (set-buffer-modified-p modified)
        (let* ((source (current-buffer))
               (before
                (org-texmacs-test--document-buffer-state source)))
          (with-temp-buffer
            (org-mode)
            (insert "Unrelated buffer\n")
            (narrow-to-region 2 (point-max))
            (let* ((caller (current-buffer))
                   (caller-before
                    (org-texmacs-test--document-buffer-state caller)))
              (cl-letf (((symbol-function
                          'org-texmacs--worker-request)
                         (lambda (&rest _)
                           (set-buffer caller)
                           (pcase outcome
                             ('unsupported
                              (ert-fail
                               "Unsupported input started worker"))
                             ('parse-error
                              (signal 'org-texmacs-parse-error
                                      '("fixture")))
                             ('worker-error
                              (signal 'org-texmacs-worker-error
                                      '("fixture")))
                             (_ '(math "x"))))))
                (if (eq outcome 'success)
                    (should
                     (org-texmacs-document-p
                      (org-texmacs-document-from-buffer source)))
                  (should-error
                   (org-texmacs-document-from-buffer source)
                   :type
                   (pcase outcome
                     ('unsupported 'org-texmacs-document-error)
                     ('parse-error 'org-texmacs-parse-error)
                     (_ 'org-texmacs-worker-error))))
                (should (eq caller (current-buffer)))
                (should
                 (equal-including-properties
                  caller-before
                  (org-texmacs-test--document-buffer-state
                   caller))))))
          (should
           (equal-including-properties
            before
            (org-texmacs-test--document-buffer-state source))))))))

(ert-deftest
    org-texmacs-document-rechecks-explicit-source-after-switch
    ()
  (dolist (change '(text tags heading link narrowing mode killed))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\") (math \"y\")\n")
      (let ((source (current-buffer)))
        (with-temp-buffer
          (let ((caller (current-buffer))
                (calls 0))
            (cl-letf (((symbol-function 'org-texmacs--worker-request)
                       (lambda (&rest _)
                         (setq calls (1+ calls))
                         (with-current-buffer source
                           (pcase change
                             ('text (insert "changed"))
                             ('tags
                              (setq-local
                               org-texmacs-fragment-tags nil))
                             ('heading
                              (setq-local org-odd-levels-only
                                          (not org-odd-levels-only)))
                             ('link
                              (setq-local
                               org-link-abbrev-alist-local
                               '(("changed"
                                  .
                                  "https://example.org/%s"))))
                             ('narrowing
                              (narrow-to-region 2 (point-max)))
                             ('mode (fundamental-mode))
                             ('killed
                              (set-buffer-modified-p nil)
                              (kill-buffer source))))
                         (set-buffer caller)
                         '(math "x"))))
              (should-error
               (org-texmacs-document-from-buffer source)
               :type 'org-texmacs-error)
              (should (eq caller (current-buffer)))
              (should (= calls 1))
              (when (eq change 'text)
                (with-current-buffer source
                  (should
                   (string-suffix-p
                    "changed" (buffer-string))))))))))))

(ert-deftest org-texmacs-document-explicit-info-snapshot ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: toc:nil\n* Title\n(math \"x\")\n")
    (setq-local org-texmacs-format-headline-function
                (lambda (&rest _) "Initial"))
    (let ((source (current-buffer)))
      (with-temp-buffer
        (let ((caller (current-buffer)))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (with-current-buffer source
                         (setq-local
                          org-texmacs-format-headline-function
                          (lambda (&rest _) "Next")))
                       (set-buffer caller)
                       '(math "x"))))
            (should
             (equal
              (cadr
               (org-texmacs-document-body
                (org-texmacs-document-from-buffer source)))
              '(section "Initial")))
            (should
             (equal
              (cadr
               (org-texmacs-document-body
                (org-texmacs-document-from-buffer source)))
              '(section "Next")))))))))

(ert-deftest org-texmacs-document-source-cache-remains-observable ()
  (with-temp-buffer
    (org-mode)
    (insert "Text\n")
    (goto-char 1)
    (let ((node (org-element-at-point)))
      (org-element-cache-store-key
       node 'org-texmacs-test-preserved 'present)
      (should
       (eq
        (org-element-cache-get-key
         node 'org-texmacs-test-preserved)
        'present))
      (org-texmacs-document-from-buffer (current-buffer))
      (should
       (eq
        (org-element-cache-get-key
         (org-element-at-point) 'org-texmacs-test-preserved)
        'present)))))

(ert-deftest org-texmacs-document-source-rechecks-snapshot ()
  (dolist (change '(text tags narrowing mode))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\") (math \"y\")\n")
      (let ((calls 0))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_source)
                     (setq calls (1+ calls))
                     (pcase change
                       ('text (insert "changed"))
                       ('tags
                        (setq-local org-texmacs-fragment-tags nil))
                       ('narrowing (narrow-to-region 2 (point-max)))
                       ('mode (fundamental-mode)))
                     '(math "x"))))
          (should-error
           (org-texmacs-document-from-buffer (current-buffer))
           :type 'org-texmacs-error)
          (should (= calls 1)))))))

(ert-deftest org-texmacs-document-source-root-mismatch ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (_source) '(concat "x"))))
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-parse-error))))

(ert-deftest org-texmacs-document-source-disabled-fragments ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-texmacs-fragment-tags nil)
    (insert "(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Disabled fragment parsed"))))
      (let ((result
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal
          (org-texmacs-document-body result)
          '(document (concat "(math \"x\") "))))
        (should-not (org-texmacs-document-stm-paths result))))))

(ert-deftest org-texmacs-document-source-real-islands ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil\n* Title\nText (math (frac \"α\" \"2\")) end.\n\n"
      "#+begin_texmacs\n(document (math \"中\"))\n#+end_texmacs\n")
     (let ((source (buffer-string))
           (result
            (org-texmacs-document-from-buffer (current-buffer))))
       (should
        (equal
         (org-texmacs-document-body result)
         '(document
           (section "Title")
           (concat
            "Text " (math (frac "α" "2")) " end. ")
           (document (math "中")))))
       (should
        (equal (org-texmacs-document-stm-paths result) '((1 1) (2))))
       (should (= org-texmacs--worker-request-id 2))
       (should (equal source (buffer-string)))
       (should (org-texmacs--worker-live-p))))))

(ert-deftest org-texmacs-document-source-real-error-and-repair ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "(math 1)\n")
     (should-error
      (org-texmacs-document-from-buffer (current-buffer))
      :type 'org-texmacs-parse-error)
     (let ((process org-texmacs--worker-process))
       (erase-buffer)
       (insert "#+begin_texmacs\n\"atomic\"\n#+end_texmacs\n")
       (let ((result
              (org-texmacs-document-from-buffer (current-buffer))))
         (should
          (equal
           (org-texmacs-document-body result) '(document "atomic")))
         (should
          (equal (org-texmacs-document-stm-paths result) '((0)))))
       (should (eq process org-texmacs--worker-process))))))

(ert-deftest org-texmacs-document-source-custom-todo-settings ()
  (dolist (keyword '("WAIT" "FINISHED"))
    (with-temp-buffer
      (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
        (org-mode))
      (insert "#+OPTIONS: toc:nil\n* " keyword " Task\n")
      ;; Establish that the fixture really has non-default TODO semantics.
      (should
       (equal
        (org-element-map
         (org-element-parse-buffer)
         'headline
         (lambda (node) (org-element-property :todo-keyword node)))
        (list keyword)))
      (let ((source (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Plain headline started parsing"))))
          (let ((org-export-with-todo-keywords t))
            (should
             (equal
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              (list
               'document
               (list
                'section
                (list 'concat (list 'strong keyword) " " "Task")))))))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-document-source-custom-level-settings ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-odd-levels-only t)
    (insert "#+OPTIONS: toc:nil\n*** Heading\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section "Heading"))))
    (erase-buffer)
    (insert "#+OPTIONS: toc:nil\n******* Deep\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section "Deep"))))))

(ert-deftest org-texmacs-document-source-custom-todo-plain-title ()
  (with-temp-buffer
    (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
      (org-mode))
    (insert "#+OPTIONS: toc:nil\n* TODO A *bold* title\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (section (concat "TODO A " (strong "bold") " " "title")))))))

(ert-deftest org-texmacs-document-source-custom-priority-settings ()
  (with-temp-buffer
    (org-mode)
    ;; A numeric-only effective regexp leaves [#A] in the title itself.
    (setq-local org-priority-regexp "\\(\\[#\\([0-9]+\\)\\] ?\\)")
    (insert "#+OPTIONS: toc:nil\n* [#A] Task\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section "[#A] Task"))))
    (erase-buffer)
    (insert "#+OPTIONS: toc:nil\n* [#12] Task\n")
    (let ((org-export-with-priority t))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document (section (concat "[#12]" " " "Task"))))))))

(ert-deftest
    org-texmacs-document-heading-settings-reject-malformed-values
    ()
  (dolist (setting
           '((org-todo-regexp . 1)
             (org-done-keywords . "DONE")
             (org-done-keywords . (1))
             (org-done-keywords . ("DONE" . "rest"))
             (org-priority-regexp . nil)))
    (with-temp-buffer
      (org-mode)
      (set (make-local-variable (car setting)) (cdr setting))
      (insert "Text\n")
      (should-error
       (org-texmacs-document-from-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-source-rechecks-heading-settings ()
  (dolist (change '(regexp done done-in-place level priority))
    (with-temp-buffer
      (org-mode)
      (setq-local org-done-keywords (list (copy-sequence "DONE")))
      (insert "(math \"x\") (math \"y\")\n")
      (let ((calls 0))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_source)
                     (setq calls (1+ calls))
                     (pcase change
                       ('regexp
                        (setq-local org-todo-regexp
                                    (copy-sequence org-todo-regexp))
                        (aset org-todo-regexp 0 ?x))
                       ('done
                        (setq-local org-done-keywords '("FINISHED")))
                       ('done-in-place
                        (aset (car org-done-keywords) 0 ?x))
                       ('priority
                        (setq-local org-priority-regexp
                                    (copy-sequence
                                     org-priority-regexp))
                        (aset org-priority-regexp 0 ?x))
                       ('level
                        (setq-local org-odd-levels-only
                                    (not org-odd-levels-only))))
                     '(math "x"))))
          (let ((failure
                 (should-error
                  (org-texmacs-document-from-buffer (current-buffer))
                  :type 'org-texmacs-document-error)))
            (should
             (equal
              (cadr failure)
              "Org heading settings changed during conversion")))
          (should (= calls 1)))))))

(ert-deftest org-texmacs-document-mixed-inline-session ()
  (org-texmacs-test--with-worker
   (should-not (org-texmacs--worker-live-p))
   (with-temp-buffer
     (org-mode)
     (insert
      "中 /i/ [fn::*n*] [[https://example.org][L]] (math \"<alpha>\")(math \"x\")\n\n"
      "#+begin_texmacs\n(equation* \"y\")\n#+end_texmacs\n")
     (let* ((source (buffer-string))
            (tick (buffer-chars-modified-tick))
            (position (point))
            (document
             (org-texmacs-document-from-buffer (current-buffer)))
            (process org-texmacs--worker-process)
            (session (org-texmacs-session-open))
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
     (insert
      "#+OPTIONS: toc:nil\n* 中文标题\n\n普通的中文 *加粗* (math (frac \"一\" \"2\")).\n\n"
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
           (insert "Original\n")
           (org-texmacs-session-set-document
            session
            (org-texmacs-document-from-buffer (current-buffer)))
           (let ((old (org-texmacs--session-read session)))
             (dolist (case
                      '(("[[file:unsupported.org::#target][link]]\n"
                         .
                         org-texmacs-document-error)
                        ("(math 1)\n" . org-texmacs-parse-error)))
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
           (insert "(math \"<less>alpha<gtr> α\")\n")
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
       (org-mode))
     (setq-local org-odd-levels-only t)
     (insert "#+OPTIONS: toc:nil\n*** TODO Task\n(math \"α\")\n")
     (let* ((settings (org-texmacs--document-heading-settings))
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
               settings (org-texmacs--document-heading-settings))))
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
                " end. ")
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
                 " end. ")
                (with "mode" "math" (frac "<#4E2D>" "2")))))))
       (org-texmacs-session-close session)))))

(ert-deftest org-texmacs-headline-policy-combinations ()
  (dolist (todo '(nil t))
    (dolist (priority '(nil t))
      (dolist (tags '(nil t not-in-toc))
        (with-temp-buffer
          (org-mode)
          (insert
           "#+OPTIONS: toc:nil\n* TODO [#A] A *bold* title :one:two:\nBody\n")
          (let* ((org-export-with-todo-keywords todo)
                 (org-export-with-priority priority)
                 (org-export-with-tags tags)
                 (source (buffer-string))
                 (result
                  (org-texmacs-document-from-buffer (current-buffer)))
                 (parts
                  (append
                   (and todo '((strong "TODO") " "))
                   (and priority '("[#A]" " "))
                   '("A " (strong "bold") " " "title")
                   (and tags '(" " ":one:two:")))))
            (should
             (equal
              (org-texmacs-document-body result)
              (list
               'document
               (list 'section (cons 'concat parts))
               '(concat "Body "))))
            (should-not (org-texmacs-document-stm-paths result))
            (should (equal source (buffer-string)))))))))

(ert-deftest org-texmacs-headline-custom-formatter-policy-and-result
    ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: toc:nil\n*** TODO [#A] Title :tag:\n")
    (let* ((output (list 'strong (copy-sequence "custom")))
           (calls 0)
           (org-export-with-todo-keywords nil)
           (org-export-with-priority nil)
           (org-export-with-tags nil)
           (org-texmacs-format-headline-function
            (lambda (todo type priority parts tags info)
              (cl-incf calls)
              (should-not todo)
              (should-not type)
              (should-not priority)
              (should-not tags)
              (should (equal parts '("Title")))
              (should-not (plist-get info :with-tags))
              output))
           (result
            (org-texmacs-document-from-buffer (current-buffer))))
      (should (> calls 0))
      (should
       (equal
        (org-texmacs-document-body result)
        '(document (section (strong "custom")))))
      (aset (cadr output) 0 ?X)
      (should
       (equal
        (org-texmacs-document-body result)
        '(document (section (strong "custom"))))))))

(ert-deftest org-texmacs-headline-invalid-formatter-result ()
  (with-temp-buffer
    (org-mode)
    (insert "* Title\n")
    (dolist (value '(42 (strong 42) (nil "x") (strong . "x")))
      (let ((org-texmacs-format-headline-function
             (lambda (&rest _) value)))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-headline-output-settings-snapshot ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n* TODO [#A] Title :tag:\n(math \"x\")\n")
    (let ((org-export-with-todo-keywords t)
          (org-export-with-priority t)
          (org-export-with-tags t)
          (org-texmacs-format-headline-function
           #'org-texmacs-format-headline-default-function))
      (cl-letf
          (((symbol-function 'org-texmacs--worker-request)
            (lambda (_)
              (setq
               org-export-with-todo-keywords nil
               org-export-with-priority nil
               org-export-with-tags nil
               org-texmacs-format-headline-function (lambda (&rest _) "changed"))
              '(math "x"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section
             (concat
              (strong "TODO") " " "[#A]" " " "Title" " " ":tag:"))
            (math "x"))))
        (should
         (equal
          (cadr
           (org-texmacs-document-body
            (org-texmacs-document-from-buffer (current-buffer))))
          '(section "changed")))))))

(ert-deftest org-texmacs-headline-explicit-tags-only ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n* Parent :parent:\n** Child :child:\n")
    (let ((org-export-with-tags t))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document
          (section (concat "Parent" " " ":parent:"))
          (subsection (concat "Child" " " ":child:"))))))))

(ert-deftest
    org-texmacs-headline-file-options-without-export-environment
    ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: todo:nil toc:nil\n* TODO Title\n")
    (cl-letf (((symbol-function 'org-export-get-environment)
               (lambda (&rest _)
                 (ert-fail "Collected export environment"))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document (section "Title")))))))

(ert-deftest org-texmacs-headline-native-metadata-literal ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (let ((org-todo-keywords '((sequence "<alpha>" "|" "FINISHED"))))
       (org-mode))
     (insert
      "#+OPTIONS: toc:nil\n* <alpha> [#12] 中 :tag:\n(math \"<alpha>\")\n")
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

;;; document.el ends here
