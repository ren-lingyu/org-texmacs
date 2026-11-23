;;; support.el --- Package contract fixtures -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'oc)
(require 'org)
(require 'org-element)
(require 'ox)
(require 'ox-texmacs)

(defvar org-texmacs-test--native-cite-fulfiller #'identity)

(defun org-texmacs-test--native-cite-fill (input)
  "Complete INPUT with fixed native data, without reading bibliography files."
  (let* ((plan
          (plist-get
           (org-texmacs-input-info input)
           :texmacs-cite-plan))
         (sources
          (mapcar
           (lambda (file)
             (cons
              file
              '(document
                (bib-entry
                 "book" "one" (document (bib-field "title" "One")))
                (bib-entry
                 "book" "two" (document (bib-field "title" "Two"))))))
           (plist-get plan :files)))
         (prepared (org-texmacs--input-cite-result input sources nil))
         (view
          (plist-get
           (org-texmacs-input-info prepared)
           :texmacs-cite-plan))
         (prefix (plist-get view :prefix))
         (keys (plist-get view :keys))
         (body
          (list
           'bib-list (number-to-string (length keys))
           (cons
            'document
            (cl-loop
             for key in keys for n from 1 collect
             (list
              'concat (list 'bibitem* (number-to-string n))
              (list
               'label (concat prefix "-" key))
              (concat "Mock " key)))))))
    (org-texmacs--input-cite-result
     prepared sources
     (list prefix keys (plist-get view :entries) body))))

(defun org-texmacs-test--native-cite-prepare (text &optional scope)
  "Prepare TEXT in a genuine export, optionally using subtree or visible SCOPE."
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+bibliography: /fixtures/references.bib\n"
     "#+cite_export: texmacs-native plain\n"
     text)
    (when (eq scope 'subtree)
      (goto-char (point-min))
      (re-search-forward "^\\* Keep")
      (beginning-of-line))
    (when (eq scope 'visible)
      (goto-char (point-min))
      (re-search-forward "^\\* Hidden")
      (beginning-of-line)
      (org-fold-hide-subtree))
    (let ((org-export-use-babel nil)
          (source (buffer-string))
          input
          region)
      (when (eq scope 'region)
        (goto-char (point-min))
        (search-forward "Keep region")
        (beginning-of-line)
        (let ((begin (point)))
          (search-forward "Outside tail")
          (beginning-of-line)
          (setq region (cons begin (point)))))
      (cl-letf (((symbol-function
                  'org-texmacs--prepared-cite-snapshot)
                 #'identity)
                ((symbol-function 'org-texmacs--prepared-cite-fulfill)
                 org-texmacs-test--native-cite-fulfiller)
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Mock native preparation started worker"))))
        (setq input
              (if region
                  (org-texmacs-prepare-buffer
                   (current-buffer) nil nil region)
                (org-texmacs--standard-consume
                 'input (eq scope 'subtree) (eq scope 'visible)))))
      (should (equal source (buffer-string)))
      input)))

(defun org-texmacs-test--native-cite-lower (input)
  "Lower INPUT while forbidding native work and source citation collection."
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _)
               (ert-fail "Pure citation lowering started worker")))
            ((symbol-function 'org-texmacs--worker-call)
             (lambda (&rest _)
               (ert-fail "Pure citation lowering called worker")))
            ((symbol-function 'insert-file-contents)
             (lambda (&rest _)
               (ert-fail "Pure citation lowering read file")))
            ((symbol-function 'org-texmacs--bibliography-collect)
             (lambda (&rest _)
               (ert-fail
                "Prepared native citations were recollected"))))
    (org-texmacs-document-body (org-texmacs-document input))))

(defvar org-texmacs-test--cite-result 'element)

(defvar org-texmacs-test--cite-calls nil)

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

(defun org-texmacs-test--caption-inline-footnote-nodes (tree tag)
  "Collect native TAG nodes from TREE."
  (when (consp tree)
    (append
     (and (eq (car tree) tag) (list tree))
     (cl-mapcan
      (lambda (child)
        (org-texmacs-test--caption-inline-footnote-nodes child tag))
      (cdr tree)))))

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
     (org-texmacs--document-heading-settings)
     (org-texmacs--document-link-settings)
     (org-texmacs-test--document-settings))))

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

(defmacro org-texmacs-test--with-environment (&rest body)
  "Run BODY in an isolated temporary directory and HOME."
  (declare (indent 0) (debug t))
  `(let* ((test-directory (make-temp-file "org-texmacs-ert-" t))
          (default-directory (file-name-as-directory test-directory))
          (process-environment (copy-sequence process-environment)))
     (unwind-protect
         (progn
           (setenv "HOME" test-directory)
           ,@body)
       (delete-directory test-directory t))))

;;; support.el ends here
