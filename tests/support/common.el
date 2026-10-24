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
     (org-texmacs--document-options))))

(defconst org-texmacs-test--adjacent-bib
  "@book{alpha, author={Ada Alpha}, title={FirstTitleSentinel}, year=2024, publisher={Example}}\n@book{beta, author={Bob Beta}, title={SecondTitleSentinel}, year=2025, publisher={Example}}"
  "Small bibliography for derived PDF link inspections.")

(defun org-texmacs-test--adjacent-source (long)
  "Return a combined link fixture, adding flowing paragraphs when LONG."
  (concat
   "#+OPTIONS: toc:t num:t title:nil author:nil date:nil\n#+BIBLIOGRAPHY: refs.bib\n"
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

(defun org-texmacs-test--compose ()
  "Exercise the private composition component with current captured source."
  (org-texmacs--preprocess-compose
   (buffer-string)
   (org-texmacs--fragment-tags)
   (org-texmacs--document-heading-settings)
   (org-texmacs--document-link-settings)
   (plist-put
    (org-texmacs--document-options)
    :texmacs-resource-base default-directory)
   buffer-file-name
   default-directory
   #'ignore
   (org-texmacs--preprocess-hooks)))

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

(defun org-texmacs-test--observe-cleanup (thunk &optional failure)
  "Call THUNK observing actual private buffer destruction.
FAILURE injects an error after modification in root, include or bibliography."
  (let ((context (symbol-function 'org-texmacs--preprocess-context))
        (collect (symbol-function 'org-texmacs--fragment-collect))
        (cite (symbol-function 'org-cite-list-bibliography-files))
        (kill (symbol-function 'kill-buffer))
        (other (generate-new-buffer " *cleanup-user-owned*"))
        records
        killed)
    (unwind-protect
        (progn
          (with-current-buffer other
            (insert "User-owned sentinel"))
          (cl-labels
           ((register
             (kind)
             (let ((record
                    (list
                     (current-buffer)
                     kind
                     buffer-file-name
                     default-directory)))
               (push record records)
               record))
            (fail
             (kind)
             (when (eq failure kind)
               (should (buffer-modified-p))
               ;; Cleanup must target the owned object after a callback switches.
               (set-buffer other)
               (signal 'org-texmacs-document-error
                       '("Cleanup sentinel")))))
           (cl-letf
               (((symbol-function 'org-texmacs--preprocess-context)
                 (lambda (&rest args)
                   (apply context args)
                   (should (equal buffer-file-name (nth 4 args)))
                   (should (equal default-directory (nth 5 args)))
                   (register
                    (if (and buffer-file-name
                             (equal
                              (file-name-nondirectory
                               buffer-file-name)
                              "part.org"))
                        'include
                      'root))))
                ((symbol-function 'org-texmacs--fragment-collect)
                 (lambda (&rest args)
                   (prog1 (apply collect args)
                     (when-let* ((record
                                  (assq (current-buffer) records)))
                       (fail (nth 1 record))))))
                ((symbol-function 'org-cite-list-bibliography-files)
                 (lambda (&rest args)
                   (register 'bibliography)
                   (prog1 (apply cite args)
                     (fail 'bibliography))))
                ((symbol-function 'kill-buffer)
                 (lambda (&optional buffer)
                   (let* ((target
                           (get-buffer (or buffer (current-buffer))))
                          (record (assq target records)))
                     (when record
                       (push (list
                              target
                              (buffer-local-value
                               'buffer-file-name target)
                              (buffer-modified-p target))
                             killed))
                     ;; Observe, never replace the actual destruction or throw here.
                     (funcall kill buffer)))))
             (funcall thunk)))
          (should records)
          (dolist (record records)
            (let ((event (assq (car record) killed)))
              (should event)
              (should-not (and (nth 1 event) (nth 2 event)))
              (should-not (buffer-live-p (car record)))))
          (should (buffer-live-p other))
          (with-current-buffer other
            (should (equal (buffer-string) "User-owned sentinel"))
            (should (buffer-modified-p))
            (should-not buffer-file-name))
          (mapcar #'cadr records))
      (dolist (record records)
        (when (buffer-live-p (car record))
          (with-current-buffer (car record)
            (setq buffer-file-name nil))
          (funcall kill (car record))))
      (funcall kill other))))

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

;;; common.el ends here
