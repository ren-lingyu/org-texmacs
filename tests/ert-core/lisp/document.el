;;; document.el --- core document regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-caption-inline-footnote-owned-ast ()
  (dolist (kind '("plain" "figure" "figure*" "table" "table*"))
    (let* ((link (org-element-create 'link (list :type "file" :path "/tmp/caption-note.pdf") "File"))
           (note (org-element-create 'footnote-reference (list :type 'inline)
                                     "Explanation" (org-element-create 'bold nil "bold") link))
           (caption (list (cons (list (copy-sequence "Long") note)
                               (list "Short" (org-texmacs-test--caption-inline-footnote "ShortNote")))
                          (cons (list "Second" (org-element-create 'bold nil "Caption")) nil)))
           (body (org-element-create
                  'paragraph nil "Body" (org-texmacs-test--caption-inline-footnote "BodyNote")
                  (org-element-create 'footnote-reference (list :type 'standard :label "n"))))
           (definition (org-element-create 'footnote-definition (list :label "n")
                                           (org-element-create 'paragraph nil "NamedNote")))
           (args (org-texmacs-test--caption-inline-footnote-input-args kind caption body definition))
           (source (let ((print-circle t)) (prin1-to-string (car args))))
           (input (apply #'org-texmacs-input-create args))
           document)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Pure caption lower invoked worker")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _) (ert-fail "Pure caption lower read source"))))
        (setq document (org-texmacs-document input))
        (should (equal document (org-texmacs-document input))))
      (should (equal source (let ((print-circle t)) (prin1-to-string (car args)))))
      (should (equal
               (caddr (cadr (org-texmacs-document-body document)))
               '(caption-detailed
                 (concat (concat "Long" (footnote (document
                                                  (concat "Explanation" (strong "bold")
                                                          (hlink "File" "/tmp/caption-note.pdf")))))
                         " " (concat "Second" (strong "Caption")))
                 (concat "Short" (footnote (document (concat "ShortNote")))))))
      (should (= 4 (length (org-texmacs-test--caption-inline-footnote-nodes
                            (org-texmacs-document-body document) 'footnote))))
      (should (org-texmacs-document-file-paths document))
      (should (equal (org-texmacs-document-stm-paths document)
                     (and (string-prefix-p "figure" kind) '((0 0)))))
      ;; Prepared input owns all caption descendants independently of its source.
      (org-element-put-property note :type 'standard)
      (aset (car (car (car caption))) 0 ?X)
      (should (equal document (org-texmacs-document input))))))

(ert-deftest org-texmacs-caption-inline-footnote-invalid-ast ()
  (dolist (short '(nil t))
    (dolist (note (list
                   (org-element-create 'footnote-reference (list :type 'standard :label "n"))
                   (org-element-create 'footnote-reference (list :type 'inline :label "n") "Named")
                   (org-element-create 'footnote-reference (list :type 'invalid) "Wrong")
                   (org-element-create
                    'footnote-reference (list :type 'inline)
                    (org-element-create 'citation nil
                                        (org-element-create 'citation-reference (list :key "k"))))
                   (org-element-create 'footnote-reference (list :type 'inline)
                                       (org-texmacs-test--caption-inline-footnote "Nested"))))
      (let* ((caption (list (if short (cons '("Long") (list note)) (cons (list note) nil))))
             (definition (org-element-create 'footnote-definition (list :label "n")
                                             (org-element-create 'paragraph nil "Definition")))
             (input (apply #'org-texmacs-input-create
                           (org-texmacs-test--caption-inline-footnote-input-args
                            "table" caption definition))))
        (should-error (org-texmacs-document input) :type 'org-texmacs-document-error))))
  (let* ((note (org-texmacs-test--caption-inline-footnote "WrongContext"))
         (paragraph (org-element-create 'paragraph nil (org-element-create 'bold nil note)))
         (input (org-texmacs-input-create (org-element-create 'org-data nil paragraph) nil)))
    (should-error (org-texmacs-document input) :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-issue11-bare-identity-and-purity ()
  :tags '(issue11)
  (dolist (tree (append org-texmacs-test--fragment-strees
                       '((with "mode" "math" "<alpha>") (concat "a" "b")
                         "literal" " " "")))
    (dolist (blank '("" " \t\r\n"))
      (let* ((leaf (copy-sequence "island"))
             (ast (org-element-create 'org-data nil
                                      (apply #'org-element-create 'paragraph nil
                                             (append (list (copy-sequence blank) leaf)
                                                     (and (> (length blank) 0)
                                                          (list (copy-sequence blank)))))))
             (input (org-texmacs-input-create ast nil :islands (list (cons leaf tree))))
             (before (let ((print-circle t)) (prin1-to-string (org-texmacs-input-ast input))))
             first second)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) (ert-fail "Pure lowering requested worker")))
                  ((symbol-function 'buffer-substring-no-properties)
                   (lambda (&rest _) (ert-fail "Pure lowering read buffer"))))
          (setq first (org-texmacs-document input) second (org-texmacs-document input)))
        (should (equal (org-texmacs-document-body first) (list 'document tree)))
        (should (equal (org-texmacs-document-stm-paths first) '((0))))
        (should-not (org-texmacs-document-file-paths first))
        (unless (equal tree "")
          (should-not (eq (cadr (org-texmacs-document-body first))
                          (cadr (org-texmacs-document-body second)))))
        (should (equal before (let ((print-circle t))
                                (prin1-to-string (org-texmacs-input-ast input))))))))
  ;; A mapped whitespace leaf is still an island, not ignorable Org whitespace.
  (let* ((leaf (copy-sequence " "))
         (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil leaf))))
    (should (equal (org-texmacs-document-body
                    (org-texmacs-test--lower ast (list (cons leaf '(math "x")))))
                   '(document (math "x"))))))

(ert-deftest org-texmacs-document-issue11-nonbare-boundaries ()
  :tags '(issue11)
  (dolist (other (list "Text" "\u00a0" (org-element-create 'bold nil "")
                      (org-element-create 'line-break nil)))
    (let* ((leaf (copy-sequence "island"))
           (ast (org-element-create 'org-data nil
                                    (org-element-create 'paragraph nil other leaf)))
           (result (org-texmacs-test--lower ast (list (cons leaf '(math "x"))))))
      (should (eq (caadr (org-texmacs-document-body result)) 'concat))
      (should (equal (org-texmacs-document-stm-paths result) '((0 1))))))
  (let* ((one (copy-sequence "one")) (two (copy-sequence "two"))
         (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil one " " two)))
         (result (org-texmacs-test--lower
                  ast (list (cons one '(math "x")) (cons two '(math "y"))))))
    (should (equal (org-texmacs-document-body result)
                   '(document (concat (math "x") " " (math "y")))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 0) (0 2)))))
  ;; An unused target can disappear from output, but still makes the source
  ;; paragraph non-bare.  Do not decide eligibility from lowered parts alone.
  (let* ((leaf (copy-sequence "island"))
         (target (org-element-create 'target '(:value "unused")))
         (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil target leaf)))
         (result (org-texmacs-test--lower ast (list (cons leaf '(math "x"))))))
    (should (equal (org-texmacs-document-body result) '(document (concat "" (math "x")))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 1)))))
  (let* ((leaf (copy-sequence "one"))
         (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil leaf leaf))))
    (should-error (org-texmacs-test--lower ast (list (cons leaf '(math "x"))))
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-issue11-display-mixtures-reject ()
  :tags '(issue11)
  (dolist (tag '(equation equation* eqnarray eqnarray* align align* gather gather* eqsplit eqsplit*))
    (dolist (other (list "Before " "\u00a0" (org-element-create 'bold nil "")
                        (org-element-create 'target '(:value "unused"))))
      (let* ((leaf (copy-sequence "island"))
             (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil other leaf))))
        (should-error (org-texmacs-test--lower ast (list (cons leaf (list tag "x"))))
                      :type 'org-texmacs-document-error))))
  (let* ((one (copy-sequence "one")) (two (copy-sequence "two"))
         (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil one " " two))))
    (should-error (org-texmacs-test--lower
                   ast (list (cons one '(math "x")) (cons two '(equation "y"))))
                  :type 'org-texmacs-document-error))
  ;; A wrapper is authored STM, not an invitation to inspect or rewrite inside it.
  (let* ((leaf (copy-sequence "island"))
         (tree '(with "mode" "math" (equation "x")))
         (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil "Before " leaf))))
    (should (equal (org-texmacs-document-body (org-texmacs-test--lower ast (list (cons leaf tree))))
                   `(document (concat "Before " ,tree))))))

(ert-deftest org-texmacs-document-empty ()
  (let ((result (org-texmacs-test--lower
                 (org-element-create 'org-data nil))))
    (should (org-texmacs-document-p result))
    (should (equal (org-texmacs-document-body result) '(document)))
    (should-not (org-texmacs-document-stm-paths result))
    (should (equal (org-texmacs-document-style result) '("generic")))
    (should-not (org-texmacs-document-initial result))))

(ert-deftest org-texmacs-document-paragraphs-and-bold ()
  (let* ((bold (org-element-create 'bold '(:post-blank 2) "bold"))
         (ast (org-element-create
               'org-data nil
               (org-element-create
                'section nil
                (org-element-create 'paragraph nil "Before " bold "after.\n")
                (org-element-create 'paragraph nil "Next.\n"))))
         (result (org-texmacs-test--lower ast)))
    (should (equal (org-texmacs-document-body result)
                   '(document (concat "Before " (strong "bold") " " "after. ")
                              (concat "Next. "))))
    (should-not (org-texmacs-document-stm-paths result))
    (should (equal (org-texmacs-document-body
                    (org-texmacs-test--lower ast nil (list (cons bold "\t "))))
                   '(document (concat "Before " (strong "bold") " " "after. ")
                              (concat "Next. "))))))

(ert-deftest org-texmacs-document-inline-whitespace-stream ()
  (let* ((value (copy-sequence " \nb\t"))
         (bold (org-element-create 'bold '(:post-blank 2) value))
         (ast (org-element-create
               'org-data nil
               (org-element-create 'paragraph nil " \ta  " bold "\n c\r\n")
               (org-element-create 'paragraph nil "\tsecond\n")))
         (before (substring-no-properties value))
         (result (org-texmacs-test--lower ast)))
    ;; State crosses Org object boundaries, but not paragraph boundaries.
    ;; Empty text slots remain rather than shifting island child indices.
    (should (equal (org-texmacs-document-body result)
                   '(document (concat "a " (strong "b ") "" "c ")
                              (concat "second "))))
    (should (equal before (substring-no-properties value)))
    (should (equal (org-element-property :post-blank bold) 2))))

(ert-deftest org-texmacs-document-nested-inline-and-cycles ()
  (let* ((italic (org-element-create 'italic nil "i"))
         (bold (org-element-create 'bold nil "b " italic))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil bold))))
    (should (equal (org-texmacs-document-body (org-texmacs-test--lower ast))
                   '(document (concat (strong (concat "b " (em "i")))))))
    (org-element-set-contents italic bold)
    (should-error (org-texmacs-test--lower ast) :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-markup-single-body ()
  (dolist (mapping '((bold . strong) (italic . em) (underline . underline)
                     (strike-through . strike-through)))
    (dolist (parts '(nil ("one") ("one" " two")))
      (let* ((node (apply #'org-element-create (car mapping) nil parts))
             (ast (org-element-create 'org-data nil
                                      (org-element-create 'paragraph nil node)))
             (body (org-texmacs-document-body (org-texmacs-test--lower ast)))
             (markup (cadr (cadr body))))
        (should (= (length markup) 2))
        (should (equal markup
                       (list (cdr mapping)
                             (cond ((null parts) "")
                                   ((null (cdr parts)) "one")
                                   (t '(concat "one" " two"))))))))))

(ert-deftest org-texmacs-document-literal-inline-semantics ()
  (dolist (type '(code verbatim))
    (let* ((value (copy-sequence "*not bold*\t (math \"x\")\n<alpha> ¯˙"))
           (node (org-element-create type (list :value value)))
           (ast (org-element-create 'org-data nil
                                    (org-element-create 'paragraph nil node)))
           (result (org-texmacs-test--lower ast)))
      (should (equal (org-texmacs-document-body result)
                     '(document (concat (verbatim "*not bold* (math \"x\") <alpha> ¯˙")))))
      (should-not (org-texmacs-document-stm-paths result))
      (should (equal value "*not bold*\t (math \"x\")\n<alpha> ¯˙"))
      (org-element-set-contents node "unexpected")
      (should-error (org-texmacs-test--lower ast) :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-whitespace-island-boundary ()
  (let* ((foreign (copy-sequence "island"))
         (native '(concat " \tSTM\n" (em "  untouched  ")))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil
                                                      "A\t " foreign "\n B C\n")))
         (result (org-texmacs-test--lower ast (list (cons foreign native)))))
    ;; NBSP is not ordinary prose whitespace; STM content is never inspected.
    (should (equal (org-texmacs-document-body result)
                   '(document (concat "A " (concat " \tSTM\n" (em "  untouched  ")) " B C "))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 1))))
    (should (equal native '(concat " \tSTM\n" (em "  untouched  "))))))

(ert-deftest org-texmacs-document-reference-label-skips-stm-label ()
  (let* ((island (org-element-create 'special-block '(:type "texmacs")))
         (link (org-element-create 'link '(:type "custom-id" :path "local")))
         (headline (org-element-create
                    'headline
                    '(:level 1 :raw-value "Alpha" :title ("Alpha")
                             :CUSTOM_ID "local")
                    (org-element-create 'section nil
                                        (org-element-create 'paragraph nil link))))
         (ast (org-element-create 'org-data nil island headline))
         (body (org-texmacs-test--stable-reference-body
                (org-texmacs-test--lower
                 ast (list (cons island '(label "org-texmacs-ref-1")))))))
    (should (equal (nth 2 body) '(section "Alpha")))
    (should (equal (nth 3 body) '(label "org-texmacs-ref-2")))
    (should (equal (nth 4 body)
                   '(concat (reference "org-texmacs-ref-2"))))))

(ert-deftest org-texmacs-document-uri-type-and-target-contract ()
  (let* ((path (copy-sequence "//example.org/<alpha>\t%20"))
         (link (org-element-create 'link
                                   (list :type "HTTPS" :path path :raw-link "file:wrong")))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil link)))
         (body (org-texmacs-document-body (org-texmacs-test--lower ast))))
    (should (equal body '(document (concat (hlink "HTTPS://example.org/<alpha>\t%20"
                                                "HTTPS://example.org/<alpha>\t%20")))))
    (should-not (eq path (nth 2 (nth 1 (nth 1 body)))))
    (should (equal path "//example.org/<alpha>\t%20")))
  (dolist (type '("file" "fuzzy" "id" "custom-id" "news" nil))
    (let ((ast (org-element-create
                'org-data nil
                (org-element-create 'paragraph nil
                                    (org-element-create 'link
                                                        (list :type type :path "x"
                                                              :raw-link "https://example.org"))))))
      (should-error (org-texmacs-test--lower ast) :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-footnote-whitespace-and-empty ()
  (let* ((note (org-element-create 'footnote-reference '(:type inline :post-blank 2)
                                   " \tnote\n " (org-element-create 'line-break nil) " \tend "))
         (empty (org-element-create 'footnote-reference '(:type inline)))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil "a " note " b " empty)))
         (before (substring-no-properties (car (org-element-contents note))))
         (result (org-texmacs-test--lower ast)))
    (should (equal (org-texmacs-document-body result)
                   '(document (concat "a " (footnote (document (concat "note " (next-line) "end ")))
                                      " " "b " (footnote (document (concat "")))))))
    (should-not (org-texmacs-document-stm-paths result))
    (should (equal before (substring-no-properties (car (org-element-contents note)))))))

(ert-deftest org-texmacs-document-named-footnote-label-collision-and-empty ()
  (let* ((island (copy-sequence "island"))
         (reference (org-element-create 'footnote-reference '(:type standard :label "n")))
         (definition (org-element-create 'footnote-definition '(:label "n")))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil reference island)
                                  definition))
         (input (org-texmacs-input-create ast nil
                                         :islands (list (cons island '(label "org-texmacs-fn-1"))))))
    (should (equal (org-texmacs-document-body (org-texmacs-document input))
                   '(document (concat (footnote
                                       (surround (label "org-texmacs-fn-2") "" (document)))
                                      (label "org-texmacs-fn-1")))))))

(ert-deftest org-texmacs-document-issue10-pure-bare ()
  :tags '(issue10)
  (dolist (tree (append org-texmacs-test--fragment-strees
                       '((with "mode" "math" "x") "atomic" " " "")))
    (let* ((leaf (copy-sequence "island"))
           (note (org-element-create 'footnote-reference '(:type inline)
                                     " \t" leaf "\r\n"))
           (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil "A" note)))
           (input (org-texmacs-input-create ast nil :islands (list (cons leaf tree)))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Pure lowering started worker")))
                ((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _) (ert-fail "Pure lowering read buffer"))))
        (let ((document (org-texmacs-document input)))
          (should (equal (org-texmacs-document-body document)
                         `(document (concat "A" (footnote (document ,tree))))))
          (should (equal (org-texmacs-document-stm-paths document) '((0 1 0 0)))))))))

(ert-deftest org-texmacs-document-issue10-display-mixtures ()
  :tags '(issue10)
  (dolist (tag org-texmacs--document-display-math-tags)
    (dolist (label '(nil "n"))
      (let* ((leaf (copy-sequence "island"))
             (note (org-element-create 'footnote-reference (list :type 'inline :label label)
                                       "Before " leaf))
             (ast (org-element-create 'org-data nil (org-element-create 'paragraph nil note))))
        (should-error (org-texmacs-test--lower ast (list (cons leaf (list tag "x"))))
                      :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-document-headline-levels ()
  (with-temp-buffer
    (org-mode)
    (insert "* First\nBody.\n*** Third\n")
    (should (equal (org-texmacs-document-body
                    (org-texmacs-test--lower (org-element-parse-buffer)))
                   '(document (section "First") (concat "Body. ")
                              (subsubsection "Third"))))))

(ert-deftest org-texmacs-document-island-paths-and-copies ()
  (let* ((ordinary (copy-sequence "<alpha>"))
         (foreign (copy-sequence "<alpha>"))
         (paragraph (org-element-create 'paragraph nil ordinary foreign "\n"))
         (block (org-element-create 'special-block '(:type "texmacs")))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'section nil paragraph block)))
         (stree (list 'document (copy-sequence "中")))
         (result (org-texmacs-test--lower
                  ast (list (cons foreign '(math "<alpha>")) (cons block stree))))
         (body (org-texmacs-document-body result)))
    (should (equal body '(document (concat "<alpha>" (math "<alpha>") " ")
                                  (document "中"))))
    (should (equal (org-texmacs-document-stm-paths result) '((0 1) (1))))
    (should-not (eq ordinary (nth 1 (nth 1 body))))
    (should-not (text-properties-at 0 (nth 1 (nth 1 body))))
    (should-not (eq stree (nth 2 body)))
    (should-not (eq (cadr stree) (cadr (nth 2 body))))))

(ert-deftest org-texmacs-document-rich-title-without-worker ()
  (cl-letf (((symbol-function 'org-texmacs--worker-start)
             (lambda (&rest _) (ert-fail "Pure lowering started a worker")))
            ((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _) (ert-fail "Pure lowering requested parsing"))))
    (with-temp-buffer
      (org-mode)
      (insert "** A *bold* title\n")
      (let ((source (buffer-string)))
        (should (equal (org-texmacs-document-body
                        (org-texmacs-test--lower (org-element-parse-buffer)))
                       '(document (section
                                   (concat "A " (strong "bold") " " "title")))))
        (should (equal source (buffer-string)))))))

(ert-deftest org-texmacs-document-rejects-invalid-whitespace ()
  (let* ((bold (org-element-create 'bold nil "bold"))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil bold))))
    (dolist (value '("\n" "text" 1))
      (should-error (org-texmacs-test--lower ast nil (list (cons bold value)))
                    :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-atomic-island ()
  (let* ((block (org-element-create 'special-block '(:type "texmacs")))
         (ast (org-element-create 'org-data nil block))
         (result (org-texmacs-test--lower ast (list (cons block "literal")))))
    (should (equal (org-texmacs-document-body result) '(document "literal")))
    (should (equal (org-texmacs-document-stm-paths result) '((0))))))

(ert-deftest org-texmacs-document-named-table-caption-ownership ()
  (let (input expected)
    (with-temp-buffer
      (org-mode)
      (insert "#+caption[Short]: Long *B* [[https://example.org][URI]]\n| x |\n")
      (let* ((prepared (org-texmacs--document-prepare-source
                        (buffer-string) nil
                        (org-texmacs--document-heading-settings)
                        (org-texmacs--document-link-settings)
                        (org-texmacs--document-options)))
             (ast (car prepared))
             (table (org-element-map ast 'table #'identity nil t))
             (bold (cadr (caar (org-element-property :caption table)))))
        (setq input (org-texmacs-input-create
                     ast (nth 4 prepared) :post-blanks (nth 3 prepared))
              expected (org-texmacs-document-body (org-texmacs-document input)))
        (org-element-set-contents bold "Changed")
        (org-element-put-property table :caption nil)
        (should (equal expected (org-texmacs-document-body (org-texmacs-document input))))))
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) (ert-fail "Owned caption requested a worker"))))
      (should (equal expected (org-texmacs-document-body (org-texmacs-document input)))))
    (let* ((table (org-element-map (org-texmacs-input-ast input) 'table #'identity nil t))
           (bold (cadr (caar (org-element-property :caption table)))))
      (should (eq (org-element-parent bold) table))
      (should (assq bold (org-texmacs-input-post-blanks input)))))
  (dolist (caption '(("unparsed") ((("Long") . "unparsed"))))
    (let* ((table (org-element-create 'table (list :caption caption)))
           (ast (org-element-create 'org-data nil table)))
      (should-error (org-texmacs-input-create ast nil)
                    :type 'org-texmacs-document-error)))
  (let* ((bold (org-element-create 'bold nil "Shared"))
         (table (org-element-create 'table (list :caption (list (cons (list bold) (list bold))))))
         (ast (org-element-create 'org-data nil table)))
    (should-error (org-texmacs-input-create ast nil) :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-rejects-unsupported-source ()
  (dolist (source '("[[file:notes.org][link]]\n"
                    "[[./notes.org]]\n" "[[file:/ssh:host:/tmp/notes.org]]\n"
                    "[[file:notes.org::heading]]\n" "[[file+emacs:notes.org]]\n"
                    "[[#target]]\n" "[[id:missing]]\n"
                    "A[fn:named]\n" "# comment\n"
                    "#+title: Title\n" "* COMMENT Task\n"
                    "* \n" "#+name: named\nParagraph\n"
                    "#+attr_html: :class test\nParagraph\n"
                    "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (should-error (org-texmacs-test--lower (org-element-parse-buffer))
                    :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-document-rejects-invalid-mappings ()
  (let* ((leaf (copy-sequence "x"))
         (ast (org-element-create
               'org-data nil (org-element-create 'paragraph nil leaf))))
    (dolist (mapping (list (list (cons leaf '(math "x")) (cons leaf "x"))
                          (list (cons (copy-sequence "missing") "x"))
                          (list (cons leaf '(math 1)))
                          (list (cons leaf '(nil "x")))))
      (should-error (org-texmacs-test--lower ast mapping)
                    :type 'org-texmacs-document-error))
    (should-error (org-texmacs-test--lower ast nil (list (cons leaf " ")))
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-rejects-cycles ()
  (let* ((bold (org-element-create 'bold nil))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'paragraph nil bold))))
    (org-element-set-contents bold bold)
    (should-error (org-texmacs-test--lower ast)
                  :type 'org-texmacs-document-error))
  (let ((stree (list 'math "x")))
    (setcar (cdr stree) stree)
    (should-error (org-texmacs--document-copy-stree stree)
                  :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-document-lowering-needs-no-source ()
  (let ((ast (org-element-create 'org-data nil
                                 (org-element-create 'paragraph nil "Text"))))
    (with-temp-buffer
      (cl-letf (((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _) (ert-fail "Lowering read source")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Lowering requested worker")))
                ((symbol-function 'org-texmacs--document-options)
                 (lambda (&rest _) (ert-fail "Lowering captured editor options"))))
        (should (equal (org-texmacs-document-body (org-texmacs-test--lower ast))
                       '(document (concat "Text"))))))))

(ert-deftest org-texmacs-document-heading-settings-parser-parity ()
  (with-temp-buffer
    (let ((org-todo-keywords '((sequence "WAIT" "|" "FINISHED"))))
      (org-mode))
    (setq-local org-odd-levels-only t)
    (insert "* WAIT [#A] A *bold* title :tag:\n*** FINISHED Done\n")
    (cl-labels ((properties ()
                 (org-element-map (org-element-parse-buffer) 'headline
                   (lambda (node)
                     (mapcar (lambda (key) (org-element-property key node))
                             '(:level :todo-keyword :todo-type :priority :raw-value :tags))))))
      (let ((expected (properties))
            (settings (org-texmacs--document-heading-settings))
            (source (buffer-string)))
        (should (equal expected
                       '((1 "WAIT" todo 65 "A *bold* title" ("tag"))
                         (2 "FINISHED" done nil "Done" nil))))
        (with-temp-buffer
          (org-mode)
          (org-texmacs--document-use-heading-settings settings)
          (insert source)
          (should (equal (properties) expected)))))))

(ert-deftest org-texmacs-document-heading-settings-copy-isolation ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-todo-regexp (copy-sequence "\\(WAIT\\)"))
    (setq-local org-done-keywords (list (copy-sequence "FINISHED")))
    (setq-local org-priority-regexp (copy-sequence org-priority-regexp))
    (let* ((settings (org-texmacs--document-heading-settings))
           (expected (org-texmacs--document-heading-settings)))
      (aset org-todo-regexp 0 ?x)
      (aset (car org-done-keywords) 0 ?x)
      (aset org-priority-regexp 0 ?x)
      (should (equal settings expected))
      (with-temp-buffer
        (org-mode)
        (org-texmacs--document-use-heading-settings settings)
        (aset org-todo-regexp 0 ?y)
        (aset (car org-done-keywords) 0 ?y)
        (aset org-priority-regexp 0 ?y)
        (should (equal settings expected))))))

(ert-deftest org-texmacs-headline-formatter-copies-and-preserves-parts ()
  (let* ((todo (copy-sequence "WAIT"))
         (plain (copy-sequence "Title"))
         (parts (list plain '(strong "bold") "\t " "end"))
         (tags (list (copy-sequence "one")))
         (result (org-texmacs-format-headline-default-function todo 'todo 12 parts tags nil)))
    (should (equal result '(concat (strong "WAIT") " " "[#12]" " "
                                   "Title" (strong "bold") "\t " "end" " " ":one:")))
    (should (equal result
                   (org-texmacs-format-headline-default-function todo 'done 12 parts tags nil)))
    (should (equal parts '("Title" (strong "bold") "\t " "end")))
    (aset todo 0 ?X)
    (aset plain 0 ?X)
    (aset (car tags) 0 ?X)
    (should (equal (cadr (cadr result)) "WAIT"))
    (should (equal (nth 5 result) "Title")))
  (let* ((text (copy-sequence "Title"))
         (result (org-texmacs-format-headline-default-function nil nil nil (list text) nil nil)))
    (should (equal result text))
    (should-not (eq result text))))

;;; document.el ends here
