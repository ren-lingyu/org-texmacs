;;; org-texmacs-serialize.el --- Normalized mathematical-document Org output -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Restore authoritative islands on an owned Org copy, interpret native syntax,
;; and check the output boundary without reparsing known STM trees as input.

;;; Code:

(require 'org-texmacs-parse)
(require 'subr-x)

(defconst org-texmacs--serialize-types
  '(org-data
    headline
    section
    paragraph
    plain-list
    item
    footnote-definition
    footnote-reference
    comment
    comment-block
    drawer
    property-drawer
    node-property
    keyword
    src-block
    example-block
    export-block
    quote-block
    center-block
    special-block
    verse-block
    table
    table-row
    table-cell
    horizontal-rule
    bold
    italic
    underline
    strike-through
    code
    verbatim
    link
    entity
    line-break
    latex-fragment
    latex-environment
    subscript
    superscript
    timestamp
    target
    radio-target
    statistics-cookie
    citation
    citation-reference
    planning
    fixed-width
    inline-src-block
    inline-babel-call
    babel-call
    macro
    export-snippet)
  "Native Org types in the initial serialization profile.
Passing this list is not enough: output must also preserve model structure.")

(defconst org-texmacs--serialize-transient-properties
  '(:parent
    :buffer
    :deferred
    :secondary
    :begin
    :end
    :contents-begin
    :contents-end
    :post-affiliated
    :robust-begin
    :robust-end
    :cached
    :mode
    :structure
    :true-level
    :granularity
    :post-blank
    :pre-blank)
  "Coordinates, derived parser state and element spacing excluded from equality.
Object post-blank spaces are compared separately; text whitespace is retained.")

(defun org-texmacs--serialize-fail (message &optional path)
  "Signal unsupported serialization MESSAGE at native AST PATH."
  (signal 'org-texmacs-model-serialization-error
          (list (format "%s at AST path %S" message path))))

(defun org-texmacs--serialize-context (model)
  "Own and validate MODEL's recorded syntax for this output profile.
Require explicit syntax captured by the buffer adapter, never ambient options."
  (unless (org-texmacs-model-p model)
    (signal 'org-texmacs-model-error
            '("Expected a mathematical-document model")))
  (let* ((context
          (org-texmacs--parse-copy (org-texmacs-model-context model)))
         (settings (plist-get context :heading-settings))
         (links (plist-get context :link-settings))
         seen)
    (unless (and (proper-list-p context)
                 (plist-member context :heading-settings)
                 (plist-member context :link-settings)
                 (plist-member context :fragment-tags)
                 (proper-list-p settings)
                 (proper-list-p links)
                 (zerop (% (length links) 2))
                 (cl-every
                  #'keywordp
                  (cl-loop
                   for (key _value) on links by #'cddr collect key))
                 (equal
                  (sort (copy-sequence
                         (cl-loop
                          for
                          (key _value)
                          on
                          links
                          by
                          #'cddr
                          collect
                          key))
                        (lambda (a b)
                          (string-lessp
                           (symbol-name a) (symbol-name b))))
                  '(:global :local :types))
                 (proper-list-p (plist-get links :types))
                 (cl-every #'stringp (plist-get links :types))
                 (proper-list-p (plist-get links :global))
                 (proper-list-p (plist-get links :local)))
      (org-texmacs--serialize-fail
       "Recorded Org syntax context is required"))
    (dolist (setting settings)
      (unless (and (consp setting)
                   (memq
                    (car setting) org-texmacs--parse-syntax-variables)
                   (not (memq (car setting) seen)))
        (org-texmacs--serialize-fail "Unsupported syntax setting"))
      (push (car setting) seen))
    (unless (equal
             (sort (copy-sequence seen)
                   (lambda (a b)
                     (string-lessp (symbol-name a) (symbol-name b))))
             (sort (copy-sequence
                    (cl-remove-if-not
                     #'boundp org-texmacs--parse-syntax-variables))
                   (lambda (a b)
                     (string-lessp (symbol-name a) (symbol-name b)))))
      (org-texmacs--serialize-fail "Incomplete recorded Org syntax"))
    (unless (or (null (plist-get context :resource-base))
                (and (stringp (plist-get context :resource-base))
                     (file-name-absolute-p
                      (plist-get context :resource-base))))
      (org-texmacs--serialize-fail "Invalid resource base"))
    (let ((org-texmacs-fragment-tags
           (plist-get context :fragment-tags)))
      (org-texmacs--fragment-tags))
    context))

(defun org-texmacs--serialize-preflight (ast islands paths tags)
  "Check AST, ISLANDS and TAGS against output syntax, using PATHS for errors."
  (dolist (entry islands)
    (let* ((key (car entry))
           (parent (org-element-parent key))
           (tree (cdr entry)))
      (unless (and (not
                    (cl-some
                     #'org-texmacs--native-body-kind
                     (org-element-lineage key)))
                   (if (stringp key)
                       (and (or (eq
                                 (org-element-type parent) 'paragraph)
                                (and (eq
                                      (org-element-type parent)
                                      'footnote-reference)
                                     (eq
                                      (org-element-property
                                       :type parent)
                                      'inline)))
                            (consp tree)
                            (member (symbol-name (car tree)) tags))
                     (and (org-texmacs--native-body-kind key)
                          (let ((parameters
                                 (org-element-property
                                  :parameters key)))
                            (or (null parameters)
                                (and (stringp parameters)
                                     (not
                                      (string-match-p
                                       "[\r\n]" parameters))))))))
        (org-texmacs--serialize-fail
         "Island is not expressible at this location"
         (gethash key paths)))))
  (cl-labels
   ((walk
     (node)
     (when (consp node)
       (let ((type (org-element-type node)))
         (unless (and (memq type org-texmacs--serialize-types)
                      (or (eq type 'org-data)
                          (fboundp
                           (intern
                            (format "org-element-%s-interpreter"
                                    type)))))
           (org-texmacs--serialize-fail (format
                                         "Unsupported Org type %S"
                                         type)
                                        (gethash node paths))))
       (unless (assq node islands)
         (mapc #'walk (org-element-contents node))
         (dolist (key (org-element-property-raw :secondary node))
           (unless (eq key :caption)
             (mapc #'walk (org-element-property-raw key node)))))
       (dolist (line (org-element-property-raw :caption node))
         (mapc #'walk (car line))
         (mapc #'walk (cdr line))))))
   (walk ast)))

(defun org-texmacs--serialize-initialize (context)
  "Install CONTEXT's syntax in an empty private or generated Org buffer.
Retain currently available link handlers, without storing them in the model."
  (let* ((links (plist-get context :link-settings))
         (registry org-link-parameters))
    (org-texmacs--parse-initialize
     (plist-get context :heading-settings)
     links
     (plist-get context :fragment-tags)
     (plist-get context :resource-base))
    (setq-local org-link-parameters
                (mapcar
                 (lambda (name)
                   (copy-tree (or (assoc name registry) (list name))))
                 (plist-get links :types)))))

(defun org-texmacs--serialize-signature (ast islands paths)
  "Compare important native AST and island semantics, excluding source details.
This private output guard is independent of the human inspection projection."
  (cl-labels
   ((data
     (value)
     (let ((path (gethash value paths :not-a-node)))
       (cond
        ((not (eq path :not-a-node))
         (list 'reference path))
        ((stringp value)
         (substring-no-properties value))
        ((and (consp value) (eq (car value) 'timestamp))
         (walk value))
        ((consp value)
         (cons (data (car value)) (data (cdr value))))
        ((vectorp value)
         (apply #'vector (mapcar #'data value)))
        (t
         value))))
    (children
     (nodes paragraph)
     (let (result)
       (cl-loop
        for node in nodes for last = (eq node (car (last nodes))) do
        (let ((value (walk node)))
          (when (and paragraph
                     last
                     (stringp value)
                     (string-suffix-p "\n" value))
            (setq value (substring value 0 -1)))
          (cond
           ((equal value ""))
           ((and (stringp value) (stringp (car result)))
            (setcar result (concat (car result) value)))
           (t
            (push value result)))))
       (nreverse result)))
    (walk
     (node)
     (let ((island (assq node islands)))
       (if (stringp node)
           (if island
               (list 'stm (cdr island))
             (substring-no-properties node))
         (let ((type (org-element-type node))
               properties)
           (org-element-properties-mapc
            (lambda (key value _node)
              (unless (or
                       (memq
                        key
                        org-texmacs--serialize-transient-properties)
                       (string-prefix-p
                        ":org-element--" (symbol-name key))
                       (and (eq type 'headline)
                            (eq key :raw-value)
                            (org-element-property-raw :title node))
                       (and (eq type 'link) (eq key :raw-link))
                       (and island
                            (or (memq key '(:value :raw-value))
                                (and (not (eq key :caption))
                                     (memq
                                      key
                                      (org-element-property-raw
                                       :secondary node))))))
                (push (cons
                       key
                       (cond
                        ((eq key :caption)
                         (mapcar
                          (lambda (line)
                            (cons
                             (children (car line) nil)
                             (children (cdr line) nil)))
                          value))
                        ((memq
                          key
                          (org-element-property-raw :secondary node))
                         (children value nil))
                        (t
                         (data value))))
                      properties)))
            node)
           (when (eq
                  (org-element-class
                   node (org-element-parent node))
                  'object)
             (push (cons
                    :post-blank
                    (or (org-element-property :post-blank node) 0))
                   properties))
           (list
            type
            (sort properties
                  (lambda (a b)
                    (string-lessp
                     (symbol-name (car a)) (symbol-name (car b)))))
            (if island
                (list (list 'stm (cdr island)))
              (children
               (org-element-contents node)
               (eq type 'paragraph)))))))))
   (walk ast)))

(defun org-texmacs--serialize-render (ast islands context)
  "Restore AST ISLANDS structurally and interpret Org using CONTEXT.
Return (TEXT SOURCES), where SOURCES maps native source to existing STM trees."
  (let ((blocks (make-hash-table :test #'eq))
        (sources (make-hash-table :test #'equal))
        (interpreter
         (symbol-function 'org-element-special-block-interpreter)))
    (dolist (entry islands)
      (let* ((key (car entry))
             (source (org-texmacs--worker-serialize-stm (cdr entry))))
        (puthash (string-trim source) (cdr entry) sources)
        (if (stringp key)
            (let* ((parent (org-element-parent key))
                   (replacement (copy-sequence source)))
              (org-element-put-property replacement :parent parent)
              (apply #'org-element-set-contents
                     parent
                     (mapcar
                      (lambda (child)
                        (if (eq child key)
                            replacement
                          child))
                      (org-element-contents parent))))
          (org-element-set-contents key)
          (puthash key source blocks))))
    (cl-letf (((symbol-function
                'org-element-special-block-interpreter)
               (lambda (node contents)
                 (let ((source (gethash node blocks)))
                   (if source
                       (let ((type (org-element-property :type node))
                             (parameters
                              (org-element-property
                               :parameters node)))
                         (format "#+begin_%s%s\n%s\n#+end_%s"
                                 type
                                 (if parameters
                                     (concat " " parameters)
                                   "")
                                 source type))
                     (funcall interpreter node contents))))))
      (with-temp-buffer
        (let ((org-element-use-cache nil)
              (org-inhibit-startup t)
              (change-major-mode-hook nil)
              (after-change-major-mode-hook nil))
          (delay-mode-hooks
            (org-mode))
          (org-texmacs--serialize-initialize context)
          (list (or (org-element-interpret-data ast) "") sources))))))

(defun org-texmacs--serialize-check-output
    (text sources context expected)
  "Check serialized TEXT under CONTEXT against EXPECTED structure.
Associate recognized SOURCES with known trees; do not invoke the STM parser."
  (let* ((prepared
          (org-texmacs--parse-prepare
           text
           (plist-get context :heading-settings)
           (plist-get context :link-settings)
           (plist-get context :fragment-tags)
           (plist-get context :resource-base) context))
         (model (car prepared)))
    (dolist (request (cadr prepared))
      (let ((tree
             (gethash (string-trim (nth 1 request)) sources
                      :missing)))
        (when (eq tree :missing)
          (org-texmacs--serialize-fail
           "Output introduces a new STM island"))
        (setcdr (car request) (org-texmacs--model-copy-stree tree))))
    (let ((snapshot (org-texmacs--model-snapshot model)))
      (unless (equal
               expected
               (apply #'org-texmacs--serialize-signature snapshot))
        (org-texmacs--serialize-fail
         "Org output would change model structure")))))

;;;###autoload
(defun org-texmacs-model-serialize (model)
  "Return normalized Org text for supported MODEL, preserving its structure.
Require recorded syntax context, as captured by `org-texmacs-parse-buffer'.
Only native blocks and paragraph/direct-inline-footnote island positions are
expressible in this first profile.  Native STM source uses single-line control
escapes, preserving leaf contents.  Other valid models may be unsupported.

Operate on an independent copy.  Recheck Org under recorded syntax, reusing
known STM trees without worker parsing.  Native STM serialization verifies
its source boundary.  No lowering, export preparation, Cite, Babel or file
acquisition runs.  Unsupported output signals
`org-texmacs-model-serialization-error'; invalid models signal
`org-texmacs-model-error'.  Native transport errors keep their conditions.
Return no partial text on failure."
  (let* ((context (org-texmacs--serialize-context model))
         (settings (plist-get context :heading-settings)))
    (cl-progv
     (mapcar #'car settings) (mapcar #'cdr settings)
     (let* ((snapshot (org-texmacs--model-snapshot model))
            (ast (nth 0 snapshot))
            (islands (nth 1 snapshot))
            (paths (nth 2 snapshot)))
       (org-texmacs--serialize-preflight
        ast islands paths (plist-get context :fragment-tags))
       (condition-case err
           (let* ((expected
                   (org-texmacs--serialize-signature
                    ast islands paths))
                  (rendered
                   (org-texmacs--serialize-render
                    ast islands context))
                  (text (car rendered)))
             (org-texmacs--serialize-check-output
              text (cadr rendered) context expected)
             (substring-no-properties text))
         ((org-texmacs-model-serialization-error
           org-texmacs-worker-error)
          (signal (car err) (cdr err)))
         (error
          (org-texmacs--serialize-fail
           (error-message-string err))))))))

;;;###autoload
(defun org-texmacs-model-to-buffer (model &optional name)
  "Serialize MODEL into a new editable Org buffer and return it.
Optional NAME defaults to `*org-texmacs-org*'; never reuse another buffer or
visit the original file.  Install captured syntax and resource base without
mode hooks, INCLUDE or SETUPFILE processing.  Serialize successfully before
allocating the output buffer; clean up a new buffer on initialization failure."
  (unless (or (null name) (stringp name))
    (org-texmacs--serialize-fail "Expected an Org buffer name"))
  (let* ((text (org-texmacs-model-serialize model))
         (context (org-texmacs--serialize-context model))
         (buffer (generate-new-buffer (or name "*org-texmacs-org*")))
         complete)
    (unwind-protect
        (progn
          (with-current-buffer buffer
            (let ((org-inhibit-startup t)
                  (change-major-mode-hook nil)
                  (after-change-major-mode-hook nil))
              (delay-mode-hooks
                (org-mode)))
            (org-texmacs--serialize-initialize context)
            (insert text)
            (goto-char (point-min)))
          (setq complete t)
          buffer)
      (unless (or complete (not (buffer-live-p buffer)))
        (kill-buffer buffer)))))

(provide 'org-texmacs-serialize)
;;; org-texmacs-serialize.el ends here
