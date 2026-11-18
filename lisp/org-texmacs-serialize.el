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

(defun org-texmacs--serialize-fail (message &optional path reason tag)
  "Signal unsupported serialization MESSAGE at PATH, with REASON and TAG."
  (signal 'org-texmacs-model-serialization-error
          (cons
           (format "%s at AST path %S" message path)
           (when reason
             (list (list :reason reason :path path :tag tag))))))

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
       "Recorded Org syntax context is required"
       nil 'unsupported-context))
    (dolist (setting settings)
      (unless (and (consp setting)
                   (memq
                    (car setting) org-texmacs--parse-syntax-variables)
                   (not (memq (car setting) seen)))
        (org-texmacs--serialize-fail "Unsupported syntax setting"
                                     nil
                                     'unsupported-context))
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
      (org-texmacs--serialize-fail "Incomplete recorded Org syntax"
                                   nil
                                   'unsupported-context))
    (unless (or (null (plist-get context :resource-base))
                (and (stringp (plist-get context :resource-base))
                     (file-name-absolute-p
                      (plist-get context :resource-base))))
      (org-texmacs--serialize-fail "Invalid resource base"
                                   nil
                                   'unsupported-context))
    context))

(defun org-texmacs--serialize-preflight (ast islands paths)
  "Check AST and ISLANDS against supported Org output syntax."
  (dolist (entry islands)
    (let ((key (car entry)))
      (when (org-texmacs--native-body-kind key)
        (let ((parameters (org-element-property :parameters key)))
          (unless (or (null parameters)
                      (and (stringp parameters)
                           (not
                            (string-match-p "[\r\n]" parameters))))
            (org-texmacs--serialize-fail
             "Island is not expressible at this location"
             (gethash key paths) 'org-container))))))
  (cl-labels
   ((walk
     (node)
     (when (consp node)
       (let ((type (org-element-type node)))
         (unless (and (or (memq type org-texmacs--serialize-types)
                          (eq type 'stm-fragment))
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

(defun org-texmacs--serialize-stm-source (tree path)
  "Write validated STM TREE for PATH without a worker or the Lisp printer."
  (let ((case-fold-search nil))
    (cl-labels
     ((write-node
       (node)
       (if (stringp node)
           (concat
            "\""
            (mapconcat (lambda (ch)
                         (pcase ch
                           (?\\ (make-string 4 ?\\))
                           (?\" (concat (make-string 3 ?\\) "\""))
                           (?\n "\\n")
                           (?\r "\\r")
                           (?\t "\\t")
                           (_ (char-to-string ch))))
                       node
                       "")
            "\"")
         (let* ((tag (car node))
                (name (symbol-name tag)))
           (unless (and (string-match-p "\\`[!-~]+\\'" name)
                        (not (string-match-p "[\"'`,;|]" name)))
             (org-texmacs--serialize-fail "Unsupported STM symbol"
                                          path
                                          'unsupported-symbol
                                          tag))
           (concat
            "("
            (when (string-match-p "\\`[0-9:#]" name)
              "\\'")
            (replace-regexp-in-string "[\\\\()]"
                                      (lambda (match)
                                        (concat "\\" match))
                                      name
                                      t t)
            (mapconcat (lambda (child)
                         (concat " " (write-node child)))
                       (cdr node)
                       "")
            ")")))))
     (write-node tree))))

(defun org-texmacs--serialize-object-records
    (ast islands paths sources)
  "Return ordered object output records for AST and ISLANDS."
  (org-element-map
   ast '(stm-fragment special-block)
   (lambda (node)
     (when-let* ((entry (assq node islands)))
       (list
        (gethash node paths)
        (org-element-type node)
        (gethash node sources)
        (cdr entry))))
   nil nil nil t))

(defun org-texmacs--serialize-render (ast islands context paths)
  "Restore AST ISLANDS structurally and interpret Org using CONTEXT.
Return (TEXT SOURCES), where SOURCES is an ordered object record list."
  (let ((blocks (make-hash-table :test #'eq))
        (object-sources (make-hash-table :test #'eq))
        (interpreter
         (symbol-function 'org-element-special-block-interpreter)))
    (dolist (entry islands)
      (let* ((key (car entry))
             (source
              (org-texmacs--serialize-stm-source
               (cdr entry) (gethash key paths))))
        (puthash key source object-sources)
        (if (eq (org-element-type key) 'stm-fragment)
            (org-element-put-property key :stm-source source)
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
          (list
           (or (org-element-interpret-data ast) "")
           (org-texmacs--serialize-object-records
            ast islands paths object-sources)))))))

(defun org-texmacs--serialize-match-objects (ast requests records)
  "Attach known trees to AST REQUESTS by matching ordered output RECORDS."
  (unless (= (length requests) (length records))
    (org-texmacs--serialize-fail "Org output changed the island count"
                                 nil
                                 'org-container))
  (let ((paths (org-texmacs--model-node-paths ast)))
    (cl-mapcar
     (lambda (request record)
       (let* ((node (car request))
              (path (gethash node paths)))
         (unless (and (equal path (nth 0 record))
                      (eq (org-element-type node) (nth 1 record))
                      (equal
                       (string-trim (cdr request)) (nth 2 record)))
           (org-texmacs--serialize-fail
            "Org output changed an STM island"
            path 'org-container))
         (cons node (nth 3 record))))
     requests records)))

(defun org-texmacs--serialize-check-output
    (text sources context expected)
  "Check serialized TEXT under CONTEXT against EXPECTED structure.
Associate recognized SOURCES with known trees; do not invoke the STM parser."
  (let* ((prepared
          (org-texmacs--parse-prepare
           text
           (plist-get context :heading-settings)
           (plist-get context :link-settings)
           (plist-get context :resource-base)))
         (islands
          (org-texmacs--serialize-match-objects
           (car prepared) (cadr prepared) sources))
         (model
          (org-texmacs--model-own (car prepared) islands context))
         (snapshot (org-texmacs--model-snapshot model)))
    (unless (equal
             expected
             (apply #'org-texmacs--serialize-signature snapshot))
      (org-texmacs--serialize-fail
       "Org output would change model structure"
       nil 'org-container))))

;;;###autoload
(defun org-texmacs-model-serialize (model)
  "Return normalized Org text for supported MODEL, preserving its structure.
Require recorded syntax context, as captured by `org-texmacs-parse-buffer'.
Emit explicit STM carriers and native blocks from the current island trees.
Source representability depends on the STM encoding and Org container.

Operate on an independent copy.  Recheck Org under recorded syntax, reusing
known STM trees without invoking a worker.  No lowering, export preparation,
Cite, Babel or file
acquisition runs.  Unsupported output signals
`org-texmacs-model-serialization-error'; invalid models signal
`org-texmacs-model-error'.
Return no partial text on failure."
  (org-texmacs--call-with-ast-context
   (lambda () (org-texmacs--serialize-model model))))

(defun org-texmacs--serialize-model (model)
  "Serialize MODEL through the selected internal representation."
  (let* ((context (org-texmacs--serialize-context model))
         (settings (plist-get context :heading-settings)))
    (cl-progv
     (mapcar #'car settings) (mapcar #'cdr settings)
     (let* ((snapshot (org-texmacs--model-snapshot model))
            (ast (nth 0 snapshot))
            (islands (nth 1 snapshot))
            (paths (nth 2 snapshot)))
       (org-texmacs--serialize-preflight ast islands paths)
       (condition-case err
           (let* ((expected
                   (org-texmacs--serialize-signature
                    ast islands paths))
                  (rendered
                   (org-texmacs--serialize-render
                    ast islands context paths))
                  (text (car rendered)))
             (org-texmacs--serialize-check-output
              text (cadr rendered) context expected)
             (substring-no-properties text))
         ((org-texmacs-model-serialization-error
           org-texmacs-worker-error)
          (signal (car err) (cdr err)))
         (error
          (org-texmacs--serialize-fail (error-message-string err)
                                       nil
                                       'org-container)))))))

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
