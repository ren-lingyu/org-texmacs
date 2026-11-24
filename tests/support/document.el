;;; document.el --- Repository ERT document fixtures -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'org-id)
(require 'org-texmacs)
(require 'org-texmacs-export)
(require 'ox)

(defun org-texmacs-test--caption-inline-footnote-nodes (tree tag)
  "Collect native TAG nodes from TREE."
  (when (consp tree)
    (append
     (and (eq (car tree) tag) (list tree))
     (cl-mapcan
      (lambda (child)
        (org-texmacs-test--caption-inline-footnote-nodes child tag))
      (cdr tree)))))

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
     (org-texmacs--syntax-heading-settings)
     (plist-get
      (org-texmacs--standard-copy-options
       (list
        :links
        (list
         org-link-parameters
         org-link-abbrev-alist
         org-link-abbrev-alist-local)))
      :links)
     (org-texmacs-test--document-settings))))

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

;;; document.el ends here
