;;; common.el --- common regression support -*- lexical-binding: t; -*-

;;; Commentary:

;; Test-owned support and fixtures.

;;; Code:

(defun org-texmacs-test--lower
    (ast
     &optional
     islands
     blanks
     info
     style
     initial
     source-file
     resource-base
     bibliography)
  "Own AST and allocate references before exercising the pure lowering kernel."
  (org-texmacs-document
   (org-texmacs-input-create
    ast
    info
    :islands islands
    :post-blanks blanks
    :style
    (or style '("generic"))
    :initial initial
    :source-file source-file
    :resource-base resource-base
    :bibliography bibliography)))

(defun org-texmacs-test--input-from-model (model)
  "Construct target input from explicit MODEL with fixed defaults.
Options are not interpreted; no selection, hooks, Cite or source preparation."
  (let* ((copy
          (org-texmacs-model-create
           (org-texmacs-model-ast model)
           :islands (org-texmacs-model-islands model)
           :context (org-texmacs-model-context model)))
         (ast (org-texmacs-model-ast copy))
         (context (org-texmacs-model-context copy)))
    ;; These constructor fixtures supply fixed settings, not source OPTIONS.
    (org-element-map
     ast 'keyword
     (lambda (node)
       (when (equal (org-element-property :key node) "OPTIONS")
         (org-element-extract-element node))))
    (org-texmacs--prepared-affiliation ast)
    (org-texmacs-input-create
     ast
     nil
     :islands (org-texmacs-model-islands copy)
     :source-file (plist-get context :source-file)
     :resource-base (plist-get context :resource-base))))

(defun org-texmacs-test--with-registered-ftps (thunk)
  "Call THUNK with an Org-registered FTPS scheme and isolated parser regexps."
  (let ((org-link-parameters (cons '("ftps") org-link-parameters))
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
    (funcall thunk)))

(defun org-texmacs-test--parse-fixture-stm (raw &rest _)
  "Return the parsed tree for a small known fixture RAW."
  (condition-case nil
      (read raw)
    (end-of-file
     (signal 'org-texmacs-parse-error '("Incomplete fixture STM")))))

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

(defun org-texmacs-test--stage4-block (kind name &optional caption)
  "Return one named KIND block, with optional CAPTION."
  (let* ((syntax
          (if (string-prefix-p "statement " kind)
              "statement"
            kind))
         (body
          (cond
           ((member kind '("equation" "equation*" "texmacs"))
            "(frac \"1\" \"2\")\n")
           ((string-prefix-p "figure" kind)
            "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
           ((string-prefix-p "table" kind)
            "| A |\n")
           (t
            "Statement body.\n"))))
    (concat
     "#+NAME: "
     name
     "\n"
     (and caption (concat "#+CAPTION[Short]: " caption "\n"))
     "#+begin_"
     kind
     "\n"
     body
     "#+end_"
     syntax
     "\n")))

(defun org-texmacs-test--issue13-input (handler &optional islands)
  "Build an owned custom-block input using HANDLER and optional ISLANDS."
  (let* ((paragraph (org-element-create 'paragraph nil "Text"))
         (block
          (org-element-create
           'special-block '(:type "custom") paragraph))
         (ast (org-element-create 'org-data nil block)))
    (org-texmacs-input-create
     ast
     (list
      :texmacs-special-block-handlers (list (cons "custom" handler)))
     :islands
     (and islands
          (list
           (cons (car (org-element-contents paragraph)) islands))))))

(defconst org-texmacs-test--issue13-stage3-graphic
  '(with
    "gr-geometry"
    (tuple "geometry" "4cm" "2cm" "center")
    "gr-frame"
    (tuple "scale" "1cm" (tuple "2cm" "1cm"))
    (graphics
     ""
     (line
      (point "-1" "-0.5")
      (point "1" "-0.5")
      (point "1" "0.5")
      (point "-1" "0.5")
      (point "-1" "-0.5"))
     (text-at "Diagram" (point "-0.5" "0"))))
  "Independent fixed-size native graphical fixture for stage3.")

(defun org-texmacs-test--caption-inline-footnote (text)
  "Create an anonymous inline note with TEXT."
  (org-element-create 'footnote-reference (list :type 'inline) text))

(defun org-texmacs-test--caption-inline-footnote-input-args
    (kind caption &rest extra)
  "Build input constructor arguments for KIND, CAPTION and EXTRA blocks."
  (let* ((native (string-prefix-p "figure" kind))
         (body
          (if native
              (org-element-create
               'special-block (list :type "texmacs"))
            (org-element-create
             'table (list :type 'org)
             (org-element-create
              'table-row
              (list :type 'standard)
              (org-element-create 'table-cell nil "A")))))
         (node
          (if (equal kind "plain")
              body
            (org-element-create
             'special-block (list :type kind) body))))
    (org-element-put-property node :caption caption)
    (list
     (apply #'org-element-create 'org-data nil node extra)
     nil
     :islands (and native (list (cons body '(math "x")))))))

(defun org-texmacs-test--caption-inline-footnote-nodes (tree tag)
  "Collect native TAG nodes from TREE."
  (when (consp tree)
    (append
     (and (eq (car tree) tag) (list tree))
     (cl-mapcan
      (lambda (child)
        (org-texmacs-test--caption-inline-footnote-nodes child tag))
      (cdr tree)))))

(defun org-texmacs-test--first-block ()
  "Return a fresh Org element at the first TeXmacs block opening."
  (save-excursion
    (goto-char (point-min))
    (search-forward "#+begin_texmacs")
    (beginning-of-line)
    (org-element-at-point)))

(defun org-texmacs-test--fragment-sources (&optional begin end)
  "Return fragment sources in the accessible buffer or between BEGIN and END."
  (org-texmacs-fragment-map
   (or begin (point-min))
   (or end (point-max))
   #'org-texmacs-fragment-span-source))

(defun org-texmacs-test--first-fragment ()
  "Return the first fragment span in the accessible Org buffer."
  (car (org-texmacs-fragment-map (point-min) (point-max) #'identity)))

(defconst org-texmacs-test--fragment-strees
  '((math (frac "1" (sqrt "x")))
    (equation (frac "1" (sqrt "x")))
    (equation* (frac "1" (sqrt "x")))
    (eqnarray
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1"))
       (row (cell "y") (cell "=") (cell "2")))))
    (eqnarray*
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1"))
       (row (cell "y") (cell "=") (cell "2")))))
    (align
     (tformat
      (table
       (row (cell "x") (cell "=1")) (row (cell "y") (cell "=2")))))
    (align*
     (tformat
      (table
       (row (cell "x") (cell "=1")) (row (cell "y") (cell "=2")))))
    (gather (tformat (table (row (cell "x=1")) (row (cell "y=2")))))
    (gather* (tformat (table (row (cell "x=1")) (row (cell "y=2")))))
    (eqsplit
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1+2"))
       (row (cell "") (cell "=") (cell "3")))))
    (eqsplit*
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1+2"))
       (row (cell "") (cell "=") (cell "3"))))))
  "Representative default roots, including actual multi-row formula tables.
These fixtures test AST preservation, not numbering or rendering semantics.")

(defun org-texmacs-test--issue11-source (context payload)
  "Wrap PAYLOAD in a supported CONTEXT, suppressing document metadata."
  (concat
   "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
   (pcase context
     ('body payload)
     ('quote (concat "#+begin_quote\n" payload "#+end_quote\n"))
     ('center (concat "#+begin_center\n" payload "#+end_center\n"))
     ('footnote
      (concat
       "Text[fn:n]. Again[fn:n].\n\n[fn:n]\n"
       (replace-regexp-in-string "^" "  " payload)))
     ('list
      (concat
       "- Intro\n\n" (replace-regexp-in-string "^" "  " payload))))))

(defun org-texmacs-test--document-settings ()
  "Copy settings for state diagnostics; do not prepare export input."
  (org-texmacs--standard-copy-options
   (list
    :settings
    (mapcar
     (lambda (symbol) (cons symbol (symbol-value symbol)))
     '(org-export-headline-levels
       org-export-with-toc
       org-export-with-section-numbers
       org-export-with-author
       org-export-with-date
       org-export-with-title
       org-export-with-email
       org-export-with-creator
       org-export-with-priority
       org-export-with-tags
       org-export-with-tasks
       org-export-with-todo-keywords
       org-export-with-archived-trees
       org-export-select-tags
       org-export-exclude-tags
       org-tag-groups-alist
       org-tag-groups-alist-for-agenda
       org-texmacs-format-headline-function)))))

(defun org-texmacs-test--document-buffer-state (buffer)
  "Capture observable BUFFER state without moving point or touching caches."
  (with-current-buffer buffer
    (list
     (buffer-substring (point-min) (point-max))
     (buffer-modified-p)
     (point)
     (mark t)
     mark-active
     (point-min)
     (point-max)
     major-mode
     (org-texmacs--fragment-tags)
     (org-texmacs--document-heading-settings)
     (org-texmacs--document-link-settings)
     (org-texmacs-test--document-settings))))

(defun org-texmacs-test--native-bib-document
    (model text &optional toc style alternate-title)
  "Lower explicit fixture MODEL and native bibliography TEXT with fixed INFO.
This is a constructor fixture, not an Org exporter or option parser.  The
fixture already has its final AST/islands and supplies target settings here."
  (let*
      ((model
        (org-texmacs-model-create
         (org-texmacs-model-ast model)
         :islands (org-texmacs-model-islands model)
         :context (org-texmacs-model-context model)))
       (context (org-texmacs-model-context model))
       (bibliography (org-texmacs--worker-request text 'bibliography))
       (info
        (list
         :with-toc toc
         :with-title nil
         :with-author nil
         :with-date nil
         :section-numbers t
         :headline-levels 3
         :texmacs-format-headline-function org-texmacs-format-headline-function
         :texmacs-bibliography-declarations '(("refs.bib" . "/native-fixture/refs.bib"))))
       (_
        (org-texmacs--prepared-affiliation
         (org-texmacs-model-ast model)))
       (_
        (org-element-map
         (org-texmacs-model-ast model) 'keyword
         (lambda (node)
           (when (equal (org-element-property :key node) "OPTIONS")
             (org-element-extract-element node)))))
       (_
        (org-element-map
         (org-texmacs-model-ast model)
         'property-drawer
         #'org-element-extract-element))
       (_
        (when alternate-title
          (let ((heading
                 (org-element-map
                  (org-texmacs-model-ast model)
                  'headline
                  #'identity
                  nil
                  t)))
            (org-element-put-property
             heading
             :ALT_TITLE alternate-title)
            (org-element-put-property
             heading
             :secondary '(:title :ALT_TITLE)))))
       (input
        (org-texmacs-input-create
         (org-texmacs-model-ast model)
         info
         :islands
         (org-texmacs-model-islands model)
         :source-file
         (plist-get context :source-file)
         :resource-base
         (plist-get context :resource-base)
         :style (or style '("generic"))
         :bibliography
         (list (cons "/native-fixture/refs.bib" bibliography))))
       (static
        (org-texmacs--document-static-labels
         (org-texmacs-input-islands input)))
       (plan
        (org-texmacs--bibliography-plan
         (org-texmacs-input-ast input)
         (org-texmacs-input-islands input)
         (org-texmacs-input-info input)
         (org-texmacs-input-bibliography input)
         (org-texmacs-input-resolution input)
         static))
       (owned-info
        (plist-put
         (copy-sequence (org-texmacs-input-info input))
         :texmacs-bibliography-output
         (org-texmacs--bibliography-format plan))))
    (org-texmacs-document
     (org-texmacs--input-with-info input owned-info))))

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

(defun org-texmacs-test--ast-filter-remap (tree backend info)
  "Map the controlled UUID in TREE using the standard filter signature."
  (should (eq backend 'texmacs))
  (should (eq org-export-current-backend 'texmacs))
  (should
   (eq (plist-get info :back-end) (org-export-get-backend 'texmacs)))
  (should (derived-mode-p 'org-mode))
  (should-not buffer-file-name)
  (should-not (plist-member info :parse-tree))
  (should-not (plist-member info :input-buffer))
  (should-not (plist-get info :with-cite-processors))
  (org-element-map
   tree 'citation-reference
   (lambda (reference)
     (when (equal
            (org-element-property :key reference) "managed-uuid")
       (org-element-put-property reference :key "external-key"))))
  tree)

(defmacro org-texmacs-test--with-bibliography-files (&rest body)
  "Run BODY in a private directory with a real UTF-8 bibliography."
  (declare (indent 0) (debug t))
  `(let ((directory (make-temp-file "org-texmacs-bibliography-" t)))
     (unwind-protect
         (with-temp-buffer
           (org-mode)
           (setq-local default-directory
                       (file-name-as-directory directory))
           (let ((coding-system-for-write 'utf-8-unix))
             (write-region "@book{external-key, title={Café}}"
                           nil
                           (expand-file-name "refs.bib")
                           nil
                           'silent))
           ,@body)
       (delete-directory directory t))))

(defun org-texmacs-test--menu-fresh-process (form)
  "Evaluate FORM in a fresh locked Emacs with no previous frontend require."
  (let ((file (make-temp-file "org-texmacs-menu-" nil ".el")))
    (unwind-protect
        (progn
          (with-temp-file file
            (insert ";;; -*- lexical-binding: t; -*-\n")
            (prin1 `(progn
                      (require 'ert)
                      (require 'cl-lib)
                      (require 'ox)
                      ,form)
                   (current-buffer)))
          (with-temp-buffer
            (let ((status
                   (call-process (expand-file-name
                                  invocation-name
                                  invocation-directory)
                                 nil t nil "-Q" "--batch" "-L"
                                 (file-name-directory
                                  (locate-library "org"))
                                 "-L"
                                 (file-name-directory
                                  (locate-library "org-texmacs"))
                                 "--load" file)))
              (unless (equal status 0)
                (ert-fail
                 (format "Fresh menu process failed: %s\n%s"
                         status
                         (buffer-string)))))))
      (delete-file file))))

(defmacro org-texmacs-test--with-managed-export (&rest body)
  "Run BODY with checked byte exports and isolated managed results."
  (declare (indent 0) (debug t))
  `(let ((org-texmacs--export-managed-buffer nil)
         (org-export-show-temporary-export-buffer nil)
         (bytes (unibyte-string ?A))
         created
         (allocate (symbol-function 'generate-new-buffer)))
     (unwind-protect
         (cl-letf (((symbol-function 'generate-new-buffer)
                    (lambda (&rest args)
                      (let ((buffer (apply allocate args)))
                        (push buffer created)
                        buffer)))
                   ((symbol-function
                     'org-texmacs--export-byte-consumer)
                    (lambda (&rest _) (lambda (&rest _) bytes))))
           (with-temp-buffer
             (org-mode)
             (insert "Source.\n")
             ,@body))
       (dolist (buffer created)
         (when (buffer-live-p buffer)
           (with-current-buffer buffer
             (setq buffer-file-name nil))
           (let ((kill-buffer-query-functions nil))
             (kill-buffer buffer)))))))

(defun org-texmacs-test--observe-standard-cleanup
    (thunk &optional failure)
  "Call THUNK and check disposal of Org's working export buffers.
FAILURE injects an error in root, prepared or ast phase, after switching to a
separate user-owned buffer.  Return the observed phase names."
  (let ((source (current-buffer))
        (other (generate-new-buffer " *standard-user-owned*"))
        records)
    (unwind-protect
        (cl-labels
         ((observe
           (stage)
           (should-not (eq source (current-buffer)))
           (push (cons stage (current-buffer)) records)
           (when (eq stage failure)
             (goto-char (point-max))
             (insert "Injected copy change")
             (set-buffer other)
             (signal 'org-texmacs-document-error
                     '("Cleanup sentinel")))))
         (let ((org-export-before-processing-functions
                (append
                 org-export-before-processing-functions
                 (list (lambda (_) (observe 'root)))))
               (org-export-before-parsing-functions
                (append
                 org-export-before-parsing-functions
                 (list (lambda (_) (observe 'prepared)))))
               (org-export-filter-parse-tree-functions
                (append
                 org-export-filter-parse-tree-functions
                 (list
                  (lambda (tree _backend _info)
                    (observe 'ast)
                    tree)))))
           (funcall thunk))
         (should (buffer-live-p source))
         (should (buffer-live-p other))
         (dolist (record records)
           (should-not (buffer-live-p (cdr record))))
         (mapcar #'car (nreverse records)))
      (when (buffer-live-p other)
        (let ((kill-buffer-query-functions nil))
          (kill-buffer other))))))

(defmacro org-texmacs-test--with-cleanup-source (&rest body)
  "Run BODY in a real visiting Org buffer and a test-owned directory."
  (declare (indent 0) (debug t))
  `(org-texmacs-test--with-bibliography-files
     (write-region "Included cleanup sentinel\n" nil "part.org"
                   nil
                   'silent)
     (write-region "#+INCLUDE: \"part.org\"\n" nil "source.org"
                   nil
                   'silent)
     (let ((source
            (find-file-noselect (expand-file-name "source.org"))))
       (unwind-protect
           (with-current-buffer source
             (org-mode)
             ,@body)
         (when (buffer-live-p source)
           (with-current-buffer source
             (set-buffer-modified-p nil))
           (kill-buffer source))))))

(defmacro org-texmacs-test--with-font-lock (source &rest body)
  "Run BODY in an Org buffer containing SOURCE, with registered JIT hooks."
  (declare (indent 1))
  `(with-temp-buffer
     (rename-buffer
      (generate-new-buffer-name "org-texmacs-font-lock-test"))
     (org-mode)
     (insert ,source)
     (buffer-enable-undo)
     (setq buffer-undo-list nil)
     (set-buffer-modified-p nil)
     (let ((noninteractive nil))
       (font-lock-mode 1))
     (should font-lock-mode)
     (should jit-lock-mode)
     (font-lock-ensure)
     ,@body))

(defun org-texmacs-test--font-lock-position (text)
  "Return the first character position of literal case-sensitive TEXT."
  (let ((case-fold-search nil))
    (save-excursion
      (goto-char (point-min))
      (search-forward text)
      (- (point) (length text)))))

(defun org-texmacs-test--font-lock-string-p (text)
  "Return non-nil if TEXT has Scheme string face."
  (let ((face
         (get-text-property
          (org-texmacs-test--font-lock-position text) 'face)))
    (or (eq face 'font-lock-string-face)
        (and (listp face) (memq 'font-lock-string-face face)))))

(defmacro org-texmacs-test--with-edit-source (text &rest body)
  "Display a temporary Org source containing TEXT and run BODY."
  (declare (indent 1) (debug t))
  `(save-window-excursion
     (let ((source (generate-new-buffer " *org-texmacs-edit-test*"))
           editor
           (org-src-window-setup 'current-window))
       (unwind-protect
           (progn
             (switch-to-buffer source)
             (org-mode)
             (insert ,text)
             (goto-char (point-min))
             ,@body)
         (when (buffer-live-p editor)
           (with-current-buffer editor
             (set-buffer-modified-p nil))
           (kill-buffer editor))
         (when (buffer-live-p source)
           (with-current-buffer source
             (set-buffer-modified-p nil))
           (kill-buffer source))))))

(defconst org-texmacs-test--metadata-source
  (concat
   "#+TITLE: TitleSentinel\n#+SUBTITLE: /SubtitleSentinel/\n"
   "#+AUTHOR: AuthorSentinel\n#+EMAIL: email@example.test\n#+DATE: DateSentinel\n"
   "#+DESCRIPTION: HiddenSubject <alpha> & \"quoted\"\n"
   "#+CREATOR: GeneratorSentinel\n#+LANGUAGE: en-US\n"
   "#+OPTIONS: toc:nil num:nil author:t email:t date:t creator:t\n"
   "#+begin_abstract\nFirstSummary\n#+end_abstract\n"
   "#+KEYWORDS: FirstKeywords\nMiddleSentinel\n"
   "#+begin_abstract\nSecondSummary\n#+end_abstract\n"
   "#+KEYWORDS: SecondKeywords\n* BodyHeading\nBodySentinel\n")
  "Test-owned document covering metadata and interleaved summaries.")

(defun org-texmacs-test--model-meaning (model)
  "Return a test-owned semantic summary of MODEL for round-trip assertions.
Explicit native attributes and traversal differ from the production output
guard and inspection view.  Keep object spaces and literal/STM whitespace."
  (let ((islands (org-texmacs-model-islands model)))
    (cl-labels
     ((clone
       (value)
       (cond
        ((stringp value)
         (substring-no-properties value))
        ((consp value)
         (cons (clone (car value)) (clone (cdr value))))
        ((vectorp value)
         (apply #'vector (mapcar #'clone value)))
        (t
         value)))
      (objects (values) (mapcar #'walk values))
      (walk
       (node)
       (let ((entry (assq node islands)))
         (if (stringp node)
             (if entry
                 (list 'island (cdr entry))
               (substring-no-properties node))
           (let ((type (org-element-type node)))
             (list
              type
              (mapcar
               (lambda (key)
                 (list key (org-element-property key node)))
               '(:type
                 :level
                 :todo-keyword
                 :todo-type
                 :priority
                 :tags
                 :commentedp
                 :key
                 :language
                 :parameters
                 :label
                 :name
                 :path
                 :search-option
                 :checkbox
                 :bullet
                 :counter
                 :style
                 :tblfm
                 :application
                 :format))
              (when (eq
                     (org-element-class
                      node (org-element-parent node))
                     'object)
                (or (org-element-property :post-blank node) 0))
              (unless (or entry (eq type 'headline))
                (org-element-property :value node))
              (mapcar
               (lambda (key)
                 (list key (objects (org-element-property key node))))
               '(:title :tag :prefix :suffix))
              (mapcar
               (lambda (line)
                 (list (objects (car line)) (objects (cdr line))))
               (org-element-property :caption node))
              (if entry
                  (list 'island (cdr entry))
                (objects (org-element-contents node)))))))))
     (clone (walk (org-texmacs-model-ast model))))))

(defun org-texmacs-test--register-id-locations (alist)
  "Install isolated org-id-locations from ALIST of (FILE . IDS)."
  (setq org-id-locations
        (org-id-alist-to-hash
         (mapcar
          (lambda (entry)
            (cons
             (abbreviate-file-name (file-truename (car entry)))
             (copy-sequence (cdr entry))))
          alist)))
  (setq org-id-files
        (mapcar
         (lambda (entry)
           (abbreviate-file-name (file-truename (car entry))))
         alist)))

(defmacro org-texmacs-test--with-id-files (source-text &rest body)
  "Create isolated source/target Org files and register target IDs.
SOURCE-TEXT becomes notes/source/source.org; notes/target/target.org carries a
file-level ID and a headline ID.  BODY sees `source', `target', `directory' and
`source-text' bound.  org-id-locations/org-id-locations-file/org-id-files and
the related tracking/scan state are isolated for the dynamic extent, so
fixtures never touch a user knowledge base."
  (declare (indent 1) (debug t))
  `(let*
       ((directory (make-temp-file "org-texmacs-id-" t))
        (source
         (expand-file-name "notes/source/source.org" directory))
        (target
         (expand-file-name "notes/target/target.org" directory))
        (source-text ,source-text)
        (org-id-locations nil)
        (org-id-locations-file (expand-file-name "ids" directory))
        (org-id-files nil)
        ;; org-id-find's unresolved fallback may call
        ;; org-id-update-id-locations; allow that scan but keep every
        ;; input private (nil agenda/extra, isolated files and locations).
        (org-id-track-globally t)
        (org-id--locations-checksum nil)
        (org-id-extra-files nil)
        (org-agenda-files nil)
        (org-export-use-babel nil))
     (unwind-protect
         (progn
           (make-directory (file-name-directory source) t)
           (make-directory (file-name-directory target) t)
           (let ((coding-system-for-write 'utf-8-unix))
             (write-region
              ":PROPERTIES:\n:ID: target-file-id\n:END:\n#+TITLE: Target\n\n* Target headline\n:PROPERTIES:\n:ID: target-headline-id\n:END:\n"
              nil
              target
              nil
              'silent)
             (write-region source-text nil source nil 'silent))
           (org-texmacs-test--register-id-locations
            (list
             (cons target '("target-file-id" "target-headline-id"))))
           ,@body)
       (delete-directory directory t))))

;;; common.el ends here
