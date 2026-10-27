;;; org-texmacs-context.el --- Restricted Org context adapter -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Capture a fixed, explicitly supported subset of Org export options and
;; prune the prepared AST without invoking Org's export preprocessing pipeline.

;;; Code:

(require 'org-texmacs-core)
(require 'org-texmacs-source)
(require 'ox)

(defconst org-texmacs--context-rich-metadata
  '(:title :subtitle :author :date)
  "Fields owned as parsed Org secondary strings.")

(defconst org-texmacs--context-plain-metadata
  '(:email :language :keywords :description :creator)
  "Fields owned as literal text, without STM or inline discovery.")

(defun org-texmacs--context-metadata-keys ()
  "Return all supported metadata keys."
  (append
   org-texmacs--context-rich-metadata
   org-texmacs--context-plain-metadata))

(defun org-texmacs--context-metadata-name (key)
  "Return the source keyword for metadata KEY."
  (upcase (substring (symbol-name key) 1)))

(defconst org-texmacs--context-option-alist
  '((:title "TITLE" nil nil parse)
    (:subtitle "SUBTITLE" nil nil parse)
    (:email "EMAIL" nil user-mail-address t)
    (:language "LANGUAGE" nil org-export-default-language t)
    (:keywords "KEYWORDS" nil nil space)
    (:description "DESCRIPTION" nil nil newline)
    (:creator "CREATOR" nil org-export-creator-string)
    (:date "DATE" nil nil parse)
    (:author "AUTHOR" nil user-full-name parse)
    (:select-tags "SELECT_TAGS" nil org-export-select-tags split)
    (:exclude-tags "EXCLUDE_TAGS" nil org-export-exclude-tags split)
    (:headline-levels nil "H" org-export-headline-levels)
    (:section-numbers nil "num" org-export-with-section-numbers)
    (:with-archived-trees nil "arch" org-export-with-archived-trees)
    (:with-author nil "author" org-export-with-author)
    (:with-date nil "date" org-export-with-date)
    (:with-email nil "email" org-export-with-email)
    (:with-creator nil "creator" org-export-with-creator)
    (:with-priority nil "pri" org-export-with-priority)
    (:with-toc nil "toc" org-export-with-toc)
    (:with-tags nil "tags" org-export-with-tags)
    (:with-tasks nil "tasks" org-export-with-tasks)
    (:with-title nil "title" org-export-with-title)
    (:with-todo-keywords nil "todo" org-export-with-todo-keywords))
  "Org options deliberately accepted by document preparation.")

(defconst org-texmacs--context-source-keywords
  '("OPTIONS"
    "FILETAGS"
    "TITLE"
    "SUBTITLE"
    "EMAIL"
    "LANGUAGE"
    "DESCRIPTION"
    "CREATOR"
    "DATE"
    "AUTHOR"
    "SELECT_TAGS"
    "EXCLUDE_TAGS"
    "EXPORT_FILE_NAME")
  "Org keywords removed after restricted context capture.
KEYWORDS stays in the AST for independent positional presentation.")

(defconst org-texmacs--context-rejected-keywords
  '("SETUPFILE" "INCLUDE" "ROAM_INCLUDE" "BIND" "MACRO" "CITE_EXPORT")
  "Source directives that require preprocessing outside this adapter.")

(defconst org-texmacs--context-export-properties
  '("EXPORT_TITLE"
    "EXPORT_SUBTITLE"
    "EXPORT_EMAIL"
    "EXPORT_LANGUAGE"
    "EXPORT_KEYWORDS"
    "EXPORT_DESCRIPTION"
    "EXPORT_CREATOR"
    "EXPORT_AUTHOR"
    "EXPORT_DATE"
    "EXPORT_OPTIONS"
    "EXPORT_SELECT_TAGS"
    "EXPORT_EXCLUDE_TAGS"
    "EXPORT_FILE_NAME")
  "Supported subtree export properties; inert during whole-buffer lowering.")

(defun org-texmacs--context-subtree-settings ()
  "Own the source's property lookup settings used by subtree export."
  (org-texmacs--context-copy
   (list
    org-use-property-inheritance
    org-property-separators
    org-global-properties
    org-global-properties-fixed)))

(defun org-texmacs--context-option-value-p (key value)
  "Return non-nil when VALUE is valid for supported policy KEY."
  (pcase key
    (:headline-levels (and (wholenump value) (<= value 5)))
    (:texmacs-tab-width (and (integerp value) (> value 0)))
    ((or :section-numbers :with-toc)
     (or (memq value '(nil t)) (wholenump value)))
    (:with-archived-trees (memq value '(nil t headline)))
    (:with-tags (memq value '(nil t not-in-toc)))
    (:with-tasks
     (or (memq value '(nil t todo done))
         (and (proper-list-p value) (cl-every #'stringp value))))
    ((or :select-tags :exclude-tags)
     (and (proper-list-p value) (cl-every #'stringp value)))
    ((or :with-author
         :with-email
         :with-creator
         :with-date
         :with-priority
         :with-title
         :with-todo-keywords)
     (memq value '(nil t)))
    (_ nil)))

(defun org-texmacs--context-external-options (options)
  "Validate and own restricted external OPTIONS before prompts or workers.
Accept unique supported keys only.  Metadata values are raw Org strings or nil;
policy values use the existing typed INFO contract, not OPTIONS token strings."
  (unless (and (proper-list-p options) (zerop (% (length options) 2)))
    (signal 'org-texmacs-document-error
            '("Expected an external options plist")))
  (let (seen
        result)
    (while options
      (let ((key (pop options))
            (value (pop options)))
        (unless (and (assq key org-texmacs--context-option-alist)
                     (not (memq key seen)))
          (signal 'org-texmacs-document-error
                  (list
                   "Unsupported or duplicate external option" key)))
        (unless (if (memq key (org-texmacs--context-metadata-keys))
                    (or (null value) (stringp value))
                  (org-texmacs--context-option-value-p key value))
          (signal 'org-texmacs-document-error
                  (list "Invalid external option" key)))
        (push key seen)
        (setq result
              (append
               result (list key (org-texmacs--context-copy value))))))
    result))

(defun org-texmacs--context-merge-external (info)
  "Merge owned external options in INFO before file/subtree configuration.
Parse raw metadata with private Org syntax; never discover STM in metadata."
  (let ((options (plist-get info :texmacs-external-options))
        parsed
        metadata)
    (while options
      (let ((key (pop options))
            (value (pop options)))
        (when (memq key (org-texmacs--context-metadata-keys))
          (push (org-texmacs--context-metadata-name key) metadata))
        (when (memq key org-texmacs--context-rich-metadata)
          (setq value
                (org-element-parse-secondary-string
                 value (org-element-restriction 'keyword))))
        (setq parsed (append parsed (list key value)))))
    (org-combine-plists
     info parsed (list :texmacs-metadata-present metadata))))

(defun org-texmacs--context-copy (value)
  "Copy configuration VALUE without retaining mutable strings or conses."
  (cond
   ((stringp value)
    (substring-no-properties value))
   ((consp value)
    (cons
     (org-texmacs--context-copy (car value))
     (org-texmacs--context-copy (cdr value))))
   ((vectorp value)
    (apply #'vector (mapcar #'org-texmacs--context-copy value)))
   (t
    value)))

(defun org-texmacs--context-filter-copy (value &optional parents)
  "Copy filter configuration VALUE, retaining opaque function identities."
  (cond
   ((functionp value)
    value)
   ((stringp value)
    (substring-no-properties value))
   ((memq value parents)
    (signal 'org-texmacs-document-error
            '("Cyclic AST filter configuration")))
   ((consp value)
    (cons
     (org-texmacs--context-filter-copy (car value)
                                       (cons value parents))
     (org-texmacs--context-filter-copy (cdr value)
                                       (cons value parents))))
   ((vectorp value)
    (apply #'vector
           (mapcar
            (lambda (item)
              (org-texmacs--context-filter-copy item
                                                (cons value parents)))
            value)))
   ((recordp value)
    (apply #'record
           (cl-loop
            for index below (length value) collect
            (org-texmacs--context-filter-copy (aref value index)
                                              (cons value parents)))))
   ((or (null value) (symbolp value) (numberp value))
    value)
   (t
    (signal 'org-texmacs-document-error
            '("Opaque AST filter configuration")))))

(defun org-texmacs--context-filter-state ()
  "Capture the source's TeXmacs backend and effective AST filter functions.
Do not register a frontend or run callbacks.  Resolve function bindings now."
  (let* ((backend
          (org-texmacs--context-filter-copy
           (or (org-export-get-backend 'texmacs)
               (org-export-create-backend :name 'texmacs))))
         (filters
          (plist-get
           (org-export-install-filters (list :back-end backend))
           :filter-parse-tree)))
    (unless (and (proper-list-p filters)
                 (cl-every #'functionp filters))
      (signal 'org-texmacs-document-error
              '("Invalid Org AST filter list")))
    (list backend (mapcar #'indirect-function filters))))

(defun org-texmacs--context-filter-properties (string)
  "Describe STRING's text properties without copying referenced AST objects."
  (let ((position 0)
        result)
    (while (< position (length string))
      (let ((end
             (next-property-change position string (length string))))
        (push (list position end (text-properties-at position string))
              result)
        (setq position end)))
    (nreverse result)))

(defun org-texmacs--context-filter-snapshot (roots keys)
  "Freeze ROOTS' topology and values, except citation key cells in KEYS.
Return bounded validation functions over original objects.  Never recursively
compare an untrusted returned tree, or retain mutable fields as value copies."
  (let ((seen (make-hash-table :test #'eq))
        checks)
    (cl-labels
     ((same
       (left right)
       (and (= (length left) (length right))
            (cl-every #'eq left right)))
      (properties-same
       (left right)
       (and (= (length left) (length right))
            (cl-every
             (lambda (a b)
               (and (= (car a) (car b))
                    (= (cadr a) (cadr b))
                    (same (nth 2 a) (nth 2 b))))
             left right)))
      (walk
       (value)
       (unless (or (gethash value seen) (functionp value))
         (puthash value t seen)
         (cond
          ((stringp value)
           (let ((text (substring-no-properties value))
                 (properties
                  (org-texmacs--context-filter-properties value)))
             (push (lambda ()
                     (and (equal text (substring-no-properties value))
                          (properties-same
                           properties
                           (org-texmacs--context-filter-properties
                            value))))
                   checks)
             (dolist (run properties)
               (mapc #'walk (nth 2 run)))))
          ((consp value)
           (let ((left (car value))
                 (right (cdr value))
                 (key (gethash value keys)))
             (push (lambda ()
                     (and (or key (eq left (car value)))
                          (eq right (cdr value))))
                   checks)
             (unless key
               (walk left))
             (walk right)))
          ((or (vectorp value) (recordp value))
           (let ((items
                  (cl-loop
                   for
                   index
                   below
                   (length value)
                   collect
                   (aref value index))))
             (push (lambda ()
                     (same
                      items
                      (cl-loop
                       for
                       index
                       below
                       (length value)
                       collect
                       (aref value index))))
                   checks)
             (mapc #'walk items)))
          ((markerp value)
           (let ((position (marker-position value))
                 (buffer (marker-buffer value)))
             (push (lambda ()
                     (and (equal position (marker-position value))
                          (eq buffer (marker-buffer value))))
                   checks)))
          ((or (null value)
               (symbolp value)
               (numberp value)
               (bufferp value)))
          (t
           (signal 'org-texmacs-document-error
                   '("Opaque AST filter input")))))))
     (mapc #'walk roots))
    checks))

(defun org-texmacs--context-filter-apply
    (prepared state source-file resource-base bibliography)
  "Apply captured STATE filters to PREPARED in the private Org buffer.
Allow only existing citation-reference key changes; INFO is a restricted,
read-only view.  Do not run preprocessing, discovery or citation processors."
  (when (cadr state)
    (let* ((ast (car prepared))
           (backend (car state))
           (org-export-current-backend 'texmacs)
           (org-export-registered-backends
            (cons
             backend
             (cl-remove-if
              (lambda
                (entry)
                (eq (org-export-backend-name entry) 'texmacs))
              org-export-registered-backends)))
           (org-export-filter-parse-tree-functions
            (copy-sequence (cadr state)))
           (context (nth 4 prepared))
           (info
            (list
             :back-end backend
             :with-cite-processors nil
             :input-file (and source-file (copy-sequence source-file))
             :texmacs-resource-base
             (and resource-base (copy-sequence resource-base))
             :bibliography
             (mapcar
              (lambda (entry)
                (copy-sequence (car entry)))
              bibliography)))
           (keys (make-hash-table :test #'eq))
           (citations
            (org-element-map
             ast 'citation-reference
             (lambda (node)
               (unless (cl-some
                        #'org-texmacs--native-body-kind
                        (org-element-lineage node))
                 node))
             nil nil nil t))
           (buffer (current-buffer))
           (tick (buffer-modified-tick))
           (mode major-mode)
           (bounds (cons (point-min) (point-max)))
           (directory (copy-sequence default-directory))
           (file buffer-file-name)
           (settings
            '(org-todo-regexp
              org-done-keywords
              org-priority-regexp
              org-odd-levels-only
              org-footnote-section
              org-link-parameters
              org-link-abbrev-alist
              org-link-abbrev-alist-local
              org-texmacs-fragment-tags
              org-export-filter-parse-tree-functions))
           (values (mapcar #'symbol-value settings))
           checks)
      (dolist (option org-texmacs--context-option-alist)
        (setq info
              (append
               info
               (list (car option) (plist-get context (car option))))))
      (dolist (citation citations)
        (let ((cell (cdr (plist-member (cadr citation) :key))))
          (unless cell
            (signal 'org-texmacs-document-error
                    '("Missing citation key property")))
          (puthash cell t keys)))
      (setq checks
            (org-texmacs--context-filter-snapshot
             (list prepared info values) keys))
      (org-export-filter-apply-functions
       (mapcar
        (lambda (filter)
          (lambda (tree name view)
            (let ((result (funcall filter tree name view)))
              (unless (and (or (null result) (eq result ast))
                           (eq (current-buffer) buffer)
                           (buffer-live-p buffer)
                           (with-current-buffer buffer
                             (and (= tick (buffer-modified-tick))
                                  (eq mode major-mode)
                                  (equal
                                   bounds
                                   (cons (point-min) (point-max)))
                                  (equal directory default-directory)
                                  (equal file buffer-file-name)
                                  (cl-every
                                   (lambda (setting value)
                                     (eq
                                      (symbol-value setting) value))
                                   settings values)))
                           (cl-every #'funcall checks)
                           (cl-every
                            (lambda (citation)
                              (let ((key
                                     (org-element-property
                                      :key citation)))
                                (and (stringp key)
                                     (> (length key) 0))))
                            citations))
                (signal
                 'org-texmacs-document-error
                 '("AST filter may only change citation-reference keys")))
              result)))
        (cadr state))
       ast info)))
  prepared)

(defun org-texmacs--context-base-options ()
  "Snapshot supported global and source-buffer-local Org options.
Do not inspect source keywords or run BIND, SETUPFILE, hooks or filters."
  (let ((org-export-options-alist org-texmacs--context-option-alist))
    (append
     (org-export--get-global-options)
     (list
      :texmacs-tag-groups-alist (org-texmacs--context-copy org-tag-groups-alist)
      :texmacs-tag-groups-alist-for-agenda
      (org-texmacs--context-copy org-tag-groups-alist-for-agenda)))))

(defun org-texmacs--context-validate-options (value)
  "Reject unsupported or malformed option tokens in OPTIONS VALUE."
  (let ((allowed
         (delq
          nil
          (mapcar
           (lambda (entry) (nth 2 entry))
           org-texmacs--context-option-alist))))
    (with-temp-buffer
      (insert value)
      (goto-char (point-min))
      (while (re-search-forward "\\s-*\\(.+?\\):" nil t)
        (when (looking-at-p "\\S-")
          (unless (member-ignore-case (match-string 1) allowed)
            (signal 'org-texmacs-document-error
                    (list
                     "Unsupported #+OPTIONS key" (match-string 1))))
          (condition-case nil
              (read (current-buffer))
            (error
             (signal 'org-texmacs-document-error
                     '("Malformed #+OPTIONS value")))))))))

(defun org-texmacs--context-keywords
    (ast islands keywords &optional unique directory)
  "Collect KEYWORDS from AST without descending into ISLANDS.
Match the part of `org-collect-keywords' used by Org's in-buffer option
conversion, but never follow SETUPFILE.  UNIQUE and DIRECTORY retain the
standard collector result shape for completeness."
  (let ((wanted (mapcar #'upcase keywords))
        alist
        order)
    (cl-labels
     ((add
       (key value)
       (when (or (member key unique)
                 (member
                  key
                  (mapcar
                   #'org-texmacs--context-metadata-name
                   (org-texmacs--context-metadata-keys)))
                 (org-string-nw-p value))
         (let ((entry (assoc-string key alist t))
               (value
                (if directory
                    (cons value default-directory)
                  value)))
           (if entry
               (unless (member key unique)
                 (setcdr entry (cons value (cdr entry))))
             (push key order)
             (push (cons
                    key
                    (if (member key unique)
                        value
                      (list value)))
                   alist)))))
      (walk
       (node)
       (unless (or (assq node islands)
                   (org-texmacs--native-body-kind node))
         (when (consp node)
           (if (eq (org-element-type node) 'keyword)
               (let ((key (upcase (org-element-property :key node)))
                     (value (org-element-property :value node)))
                 (when (member
                        key org-texmacs--context-rejected-keywords)
                   (signal 'org-texmacs-document-error
                           (list
                            "Unsupported preprocessing directive"
                            key)))
                 (when (and (string= key "OPTIONS") (stringp value))
                   (org-texmacs--context-validate-options value))
                 (when (and (member key wanted) (stringp value))
                   (add key value)))
             (mapc #'walk (org-element-contents node)))))))
     (walk ast))
    (mapcar
     (lambda (key)
       (let ((entry (assoc-string key alist t)))
         (if (member key unique)
             entry
           (cons (car entry) (nreverse (cdr entry))))))
     (nreverse order))))

(defun org-texmacs--context-merge-options (ast islands base)
  "Merge source-local supported options from AST over BASE.
ISLANDS are traversal boundaries.  Use Org's own value conversion while
substituting a collector that cannot read SETUPFILE or external files."
  (let ((org-export-options-alist org-texmacs--context-option-alist))
    (condition-case err
        (org-combine-plists
         base
         (cl-letf (((symbol-function 'org-collect-keywords)
                    (lambda (keywords &optional unique directory)
                      (org-texmacs--context-keywords
                       ast islands keywords
                       unique directory))))
           (org-export--get-inbuffer-options)))
      (org-texmacs-document-error
       (signal (car err) (cdr err)))
      (error
       (signal 'org-texmacs-document-error
               (list
                "Invalid Org document options"
                (error-message-string err)))))))

(defun org-texmacs--context-parse-alt-title (headline)
  "Parse HEADLINE's ALT_TITLE with Org's headline object restrictions.
Store the result as owned secondary AST data before the source buffer goes
away.  Do not discover TeXmacs fragments in this document-wide metadata."
  (let ((value (org-element-property :ALT_TITLE headline)))
    (when value
      (unless (stringp value)
        (signal 'org-texmacs-document-error
                '("Invalid ALT_TITLE property")))
      (condition-case err
          (let ((parsed
                 (org-element-parse-secondary-string
                  value
                  (org-element-restriction 'headline)
                  headline)))
            (org-element-put-property headline :ALT_TITLE parsed)
            (org-element-put-property
             headline
             :secondary
             (cons
              :ALT_TITLE
              (delq
               :ALT_TITLE
               (org-element-property :secondary headline)))))
        (error
         (signal 'org-texmacs-document-error
                 (list
                  "Invalid ALT_TITLE property"
                  (error-message-string err))))))))

(defun org-texmacs--context-validate-info (info)
  "Validate the supported effective option subset in INFO."
  (unless (cl-every
           (lambda (key)
             (org-texmacs--context-option-value-p
              key (plist-get info key)))
           (cons
            :texmacs-tab-width
            (cl-remove-if
             (lambda (key)
               (memq key (org-texmacs--context-metadata-keys)))
             (mapcar #'car org-texmacs--context-option-alist))))
    (signal 'org-texmacs-document-error
            '("Invalid supported Org document options")))
  (dolist (key org-texmacs--context-plain-metadata)
    (unless (or (null (plist-get info key))
                (stringp (plist-get info key)))
      (signal 'org-texmacs-document-error
              (list "Invalid plain metadata" key))))
  info)

(defun org-texmacs--context-prune
    (ast islands info &optional defer-footnotes)
  "Prune supported non-exported structures from AST under fixed INFO.
Treat every ISLAND key as opaque.  When DEFER-FOOTNOTES is non-nil, leave
definition contents untouched until referenced definitions have been selected.
Return AST after in-place pruning."
  (let ((org-tag-groups-alist
         (org-texmacs--context-copy
          (plist-get info :texmacs-tag-groups-alist)))
        (org-tag-groups-alist-for-agenda
         (org-texmacs--context-copy
          (plist-get info :texmacs-tag-groups-alist-for-agenda))))
    (let ((selected
           (org-texmacs--context-selected-trees ast islands info))
          (excluded
           (cl-mapcan
            (lambda (tag) (org-tags-expand tag t))
            (plist-get info :exclude-tags))))
      (when (and selected
                 (org-element-type-p
                  (car (org-element-contents ast)) 'section))
        (org-element-extract (car (org-element-contents ast))))
      (cl-labels
       ((walk
         (node)
         (unless (or (assq node islands)
                     (org-texmacs--native-body-kind node))
           (let ((type (org-element-type node)))
             (cond
              ((memq type '(comment comment-block))
               (org-element-extract node))
              ((eq type 'footnote-definition)
               (unless defer-footnotes
                 (mapc
                  #'walk
                  (copy-sequence (org-element-contents node)))))
              ((eq type 'keyword)
               (when (member
                      (upcase (org-element-property :key node))
                      org-texmacs--context-source-keywords)
                 (org-element-extract node)))
              ((eq type 'property-drawer)
               (let ((parent (org-element-property :parent node)))
                 (while (and parent
                             (not
                              (eq
                               (org-element-type parent) 'headline)))
                   (setq parent
                         (org-element-property :parent parent)))
                 (unless
                     (and
                      parent
                      (cl-every
                       (lambda (property)
                         (and
                          (eq
                           (org-element-type property) 'node-property)
                          (member
                           (upcase
                            (org-element-property :key property))
                           (append
                            '("UNNUMBERED"
                              "ALT_TITLE"
                              "CUSTOM_ID"
                              "ID")
                            org-texmacs--context-export-properties))))
                       (org-element-contents node)))
                   (signal 'org-texmacs-document-error
                           '("Unsupported Org property drawer")))
                 ;; Resolve supported secondary values while the private
                 ;; source buffer still exists, then discard source syntax.
                 (org-element-property :UNNUMBERED parent)
                 (org-texmacs--context-parse-alt-title parent)
                 (org-element-property :CUSTOM_ID parent)
                 (org-element-property :ID parent)
                 (org-element-extract node)))
              ((eq type 'headline)
               (if (or (org-element-property :footnote-section-p node)
                       (org-export--skip-p
                        node info selected excluded))
                   (org-element-extract node)
                 (if (and (eq
                           (plist-get info :with-archived-trees)
                           'headline)
                          (org-element-property :archivedp node))
                     (org-element-set-contents node)
                   (mapc
                    #'walk
                    (copy-sequence (org-element-contents node))))))
              (t
               (mapc
                #'walk
                (copy-sequence (org-element-contents node)))))))))
       (mapc #'walk (copy-sequence (org-element-contents ast))))))
  ast)

(defun org-texmacs--context-selected-trees (ast islands info)
  "Return selected headline identities in AST without entering ISLANDS.
Follow Org's select-tag genealogy and descendant policy under fixed INFO."
  (let ((select
         (cl-mapcan
          (lambda (tag) (org-tags-expand tag t))
          (plist-get info :select-tags))))
    (cl-labels
     ((headlines
       (node)
       (let (result)
         (cl-labels
          ((walk
            (child)
            (unless (assq child islands)
              (when (consp child)
                (when (eq (org-element-type child) 'headline)
                  (push child result))
                (mapc #'walk (org-element-contents child))))))
          (walk node))
         (nreverse result))))
     (if (cl-some
          (lambda (tag) (member tag select))
          (plist-get info :filetags))
         (headlines ast)
       (let (selected)
         (cl-labels
          ((walk
            (node genealogy)
            (unless (or (assq node islands)
                        (org-texmacs--native-body-kind node))
              (when (consp node)
                (if (eq (org-element-type node) 'headline)
                    (if (cl-some
                         (lambda (tag) (member tag select))
                         (org-element-property :tags node))
                        (setq selected
                              (append
                               genealogy (headlines node) selected))
                      (mapc
                       (lambda (child)
                         (walk child (cons node genealogy)))
                       (org-element-contents node)))
                  (mapc
                   (lambda (child) (walk child genealogy))
                   (org-element-contents node)))))))
          (walk ast nil))
         selected)))))

(defun org-texmacs--context-footnote-definitions (ast islands)
  "Collect named definition nodes from AST without entering ISLANDS.
Keep parsed nodes, including inline definitions, rather than source spans."
  (let (definitions)
    (cl-labels
     ((walk
       (node ancestors)
       (when (and (consp node)
                  (not (assq node islands))
                  (not (org-texmacs--native-body-kind node)))
         (when (memq node ancestors)
           (signal 'org-texmacs-document-error
                   '("Cyclic footnote definition tree")))
         (when (and (or (eq
                         (org-element-type node) 'footnote-definition)
                        (and (eq
                              (org-element-type node)
                              'footnote-reference)
                             (eq
                              (org-element-property :type node)
                              'inline)))
                    (org-element-property :label node))
           (push node definitions))
         (let ((ancestors (cons node ancestors)))
           (when (eq (org-element-type node) 'headline)
             (mapc
              (lambda (child) (walk child ancestors))
              (org-element-property :title node)))
           (mapc
            (lambda (child) (walk child ancestors))
            (org-element-contents node))))))
     (walk ast nil))
    (nreverse definitions)))

(defun org-texmacs--context-preserve-footnotes
    (ast islands definitions info)
  "Keep definitions required by visible references in AST under fixed INFO.
DEFINITIONS was captured before pruning.  Restore only missing definitions
from this parsed snapshot; never fall back to a buffer or external data."
  (let ((reachable (org-texmacs--context-reachable ast islands))
        labels)
    (cl-labels
     ((walk
       (node)
       (when (and (consp node)
                  (not (assq node islands))
                  (not (org-texmacs--native-body-kind node))
                  (not
                   (eq (org-element-type node) 'footnote-definition)))
         (when (eq (org-element-type node) 'footnote-reference)
           (when-let* ((label (org-element-property :label node)))
             (cl-pushnew label labels :test #'equal)))
         (mapc #'walk (org-element-contents node)))))
     (walk ast))
    ;; Definitions are document data, not standalone body paragraphs.
    (dolist (definition definitions)
      (when (and (eq
                  (org-element-type definition) 'footnote-definition)
                 (gethash definition reachable)
                 (not
                  (member
                   (org-element-property :label definition) labels)))
        (org-element-extract definition)))
    (dolist (label labels)
      (let ((matching
             (cl-remove-if-not
              (lambda (definition)
                (equal
                 label (org-element-property :label definition)))
              definitions)))
        (unless (cl-some
                 (lambda (definition)
                   (gethash definition reachable))
                 matching)
          (dolist (definition matching)
            (let
                ((restored
                  (if (eq
                       (org-element-type definition)
                       'footnote-definition)
                      (progn
                        (org-element-extract definition)
                        definition)
                    (org-element-create
                     'footnote-definition (list :label label)
                     ;; Keep the original inline body interval in this fixed
                     ;; snapshot so fragment preparation can split its strings.
                     (apply #'org-element-create
                            'paragraph
                            (let ((begin
                                   (org-element-property
                                    :contents-begin definition))
                                  (end
                                   (org-element-property
                                    :contents-end definition)))
                              (and begin
                                   end
                                   (list
                                    :begin begin
                                    :end end
                                    :contents-begin begin
                                    :contents-end end
                                    :post-blank 0)))
                            (org-element-contents definition))))))
              (apply #'org-element-set-contents
                     ast
                     (append
                      (org-element-contents ast)
                      (list restored))))))))
    ;; Apply the same restricted policy to recovered definition contents.
    (org-texmacs--context-prune ast islands info)))

(defun org-texmacs--context-reachable (ast islands)
  "Return an eq table of nodes reachable from AST, treating ISLANDS as opaque."
  (let ((table (make-hash-table :test #'eq)))
    (cl-labels
     ((walk
       (node)
       (unless (gethash node table)
         (puthash node t table)
         (when (and (consp node)
                    (not (assq node islands))
                    (not (org-texmacs--native-body-kind node)))
           (mapc #'walk (org-element-contents node))
           ;; Captions are affiliated pairs of secondary strings, rather
           ;; than entries in `org-element-secondary-value-alist'.
           (dolist (line (org-element-property :caption node))
             (mapc #'walk (car line))
             (mapc #'walk (cdr line)))
           (dolist (key
                    (cdr
                     (assq
                      (org-element-type node)
                      org-element-secondary-value-alist)))
             (mapc #'walk (org-element-property key node)))))))
     (walk ast))
    table))

(defun org-texmacs--context-select-subtree (ast position info)
  "Select the subtree at snapshot POSITION in owned AST under INFO.
Apply restricted Org subtree overrides before dropping the root heading.
Keep global declarations in INFO; body dependencies are restored separately."
  (goto-char position)
  (condition-case nil
      (org-back-to-heading t)
    (error
     (signal 'org-texmacs-document-error
             '("No subtree at source position"))))
  (let* ((begin (point))
         (root
          (org-element-map
           ast 'headline
           (lambda (node)
             (and (= begin (org-element-property :begin node)) node))
           nil t))
         (settings (plist-get info :texmacs-subtree-settings))
         (org-use-property-inheritance (nth 0 settings))
         (org-property-separators (nth 1 settings))
         (org-global-properties (nth 2 settings))
         (org-global-properties-fixed (nth 3 settings))
         (org-entry-property-inherited-from (make-marker))
         (org-export-options-alist org-texmacs--context-option-alist))
    (unless root
      (signal 'org-texmacs-document-error
              '("Missing snapshot subtree")))
    (when-let* ((options
                 (org-entry-get begin "EXPORT_OPTIONS" 'selective)))
      (org-texmacs--context-validate-options options))
    (dolist (section (org-element-contents root))
      (when (org-element-type-p section 'section)
        (dolist (drawer (org-element-contents section))
          (when (org-element-type-p drawer 'property-drawer)
            (dolist (property (org-element-contents drawer))
              (let ((key
                     (upcase (org-element-property :key property))))
                (when (string= key "ROAM_INCLUDE")
                  (signal 'org-texmacs-document-error
                          '("Subtree mount requires preprocessing")))
                (when (and (string-prefix-p "EXPORT_" key)
                           (not
                            (member
                             key
                             org-texmacs--context-export-properties)))
                  (signal 'org-texmacs-document-error
                          (list
                           "Unsupported subtree export property"
                           key)))))))))
    (let* ((overrides (org-export--get-subtree-options))
           (metadata
            (copy-sequence
             (plist-get info :texmacs-metadata-present))))
      (dolist (key (org-texmacs--context-metadata-keys))
        (when (plist-member overrides key)
          (cl-pushnew
           (org-texmacs--context-metadata-name key)
           metadata
           :test #'equal)))
      (setq info
            (org-combine-plists
             info
             overrides
             (list :texmacs-metadata-present metadata))))
    ;; Root heading/title/properties are document configuration, not body.
    (let ((children (copy-sequence (org-element-contents root))))
      (when (org-element-type-p (car children) 'section)
        (dolist (node
                 (copy-sequence
                  (org-element-contents (car children))))
          (when (org-element-type-p node '(planning property-drawer))
            (org-element-extract node))))
      (dolist (child children)
        (org-element-put-property child :parent ast))
      (apply #'org-element-set-contents ast children))
    (org-texmacs--context-validate-info info)))

(defun org-texmacs--context-body-region
    (ast position region restriction)
  "Return body bounds under REGION, subtree POSITION and outer RESTRICTION.
Run in the complete private snapshot owning AST.  REGION takes priority;
otherwise intersect subtree body with RESTRICTION.  Empty bodies are allowed."
  (or region
      (when restriction
        (if (null position)
            restriction
          (goto-char position)
          (condition-case nil
              (org-back-to-heading t)
            (error
             (signal 'org-texmacs-document-error
                     '("No subtree at source position"))))
          (let ((root
                 (org-element-map
                  ast 'headline
                  (lambda (node)
                    (and (= (point)
                            (org-element-property :begin node))
                         node))
                  nil t)))
            (unless root
              (signal 'org-texmacs-document-error
                      '("Missing snapshot subtree")))
            (org-end-of-meta-data)
            (let ((begin
                   (min (cdr restriction)
                        (max (car restriction) (point)))))
              (cons
               begin
               (max begin
                    (min (cdr restriction)
                         (org-element-property :end root))))))))))

(defun org-texmacs--context-check-wrapper-region
    (ast islands info region definitions)
  "Reject REGION cuts through wrappers retained by AST's headline policy.
ISLANDS stay opaque; INFO supplies the selection policy.
DEFINITIONS supplies original footnote dependencies before body selection."
  (let* ((org-tag-groups-alist
          (org-texmacs--context-copy
           (plist-get info :texmacs-tag-groups-alist)))
         (org-tag-groups-alist-for-agenda
          (org-texmacs--context-copy
           (plist-get info :texmacs-tag-groups-alist-for-agenda)))
         (selected
          (org-texmacs--context-selected-trees ast islands info))
         (excluded
          (cl-mapcan
           (lambda (tag) (org-tags-expand tag t))
           (plist-get info :exclude-tags)))
         needed)
    (cl-labels
     ((walk
       (node &optional collect)
       (let ((type (org-element-type node)))
         (unless (or (and (eq type 'footnote-definition)
                          (or collect
                              (not
                               (member
                                (org-element-property
                                 :label node)
                                needed))))
                     (and selected
                          (eq type 'section)
                          (eq node (car (org-element-contents ast))))
                     (and (eq type 'headline)
                          (or (org-element-property
                               :footnote-section-p node)
                              (org-export--skip-p
                               node info selected excluded)
                              (and (eq
                                    (plist-get
                                     info
                                     :with-archived-trees)
                                    'headline)
                                   (org-element-property
                                    :archivedp node)))))
           (when (and collect
                      (eq type 'footnote-reference)
                      (integerp (org-element-property :begin node))
                      (<= (car region)
                          (org-element-property :begin node))
                      (< (org-element-property :begin node)
                         (cdr region)))
             (cl-pushnew
              (org-element-property :label node)
              needed
              :test #'equal))
           (when (and (not collect)
                      (or (org-texmacs--figure-table-kind node)
                          (org-texmacs--native-body-kind node)
                          (and (eq type 'special-block)
                               (org-element-property
                                :texmacs-affiliated-keywords node))))
             (let ((begin (org-element-property :begin node))
                   (end
                    (org-element-property :texmacs-source-end node)))
               (when (and (< begin (cdr region))
                          (< (car region) end)
                          (not
                           (<= (car region) begin end (cdr region))))
                 (signal
                  'org-texmacs-document-error
                  '("Region truncates a special-block wrapper")))))
           (unless (or (assq node islands)
                       (org-texmacs--native-body-kind node))
             (mapc
              (lambda (child) (walk child collect))
              (org-element-contents node)))))))
     (walk ast t) (walk ast)
     (dolist (definition definitions)
       (when (member (org-element-property :label definition) needed)
         (walk definition))))))

(defun org-texmacs--context-prepare
    (ast
     islands
     requests
     post-blanks
     base-info
     &optional
     subtree-position
     region)
  "Apply restricted context to prepared AST and associated mappings.
Return (AST ISLANDS REQUESTS POST-BLANKS INFO), retaining only mappings and
worker requests whose identity keys remain reachable after filtering.
Optional SUBTREE-POSITION clips the owned tree after configuration capture.
REGION is a frozen (BEGIN . END) pair; it takes precedence for body selection,
while retaining any subtree configuration.  Parse only the private snapshot."
  (let*
      ((base-info (org-texmacs--context-merge-external base-info))
       (metadata
        (append
         (plist-get base-info :texmacs-metadata-present)
         (mapcar
          #'car
          (org-texmacs--context-keywords
           ast islands
           (mapcar
            #'org-texmacs--context-metadata-name
            (org-texmacs--context-metadata-keys))))))
       (info
        (plist-put
         (plist-put
          (org-texmacs--context-validate-info
           (org-texmacs--context-merge-options ast islands base-info))
          :texmacs-metadata-present metadata)
         :parse-tree ast))
       (bibliography-declarations
        (mapcar
         (lambda (raw)
           (cons
            raw
            (caar
             (org-texmacs--bibliography-source-snapshot
              (list (cons (org-strip-quotes (string-trim raw)) ""))
              (plist-get base-info :texmacs-resource-base)))))
         (cdr
          (assoc
           "BIBLIOGRAPHY"
           (org-texmacs--context-keywords
            ast islands '("BIBLIOGRAPHY"))))))
       (view (plist-get base-info :texmacs-effective-bibliography))
       (_
        (when view
          (unless (equal
                   bibliography-declarations
                   (plist-get view :document))
            (signal
             'org-texmacs-document-error
             '("Effective bibliography disagrees with document declarations")))
          (setq
           info
           (plist-put
            info
            :texmacs-bibliography-document-declarations bibliography-declarations))
          (setq
           info
           (plist-put
            info
            :texmacs-bibliography-source-identities (plist-get view :sources)))
          (setq bibliography-declarations
                (append
                 bibliography-declarations
                 (mapcar
                  (lambda (id) (cons id id))
                  (cl-remove-if
                   (lambda (id)
                     (member
                      id (mapcar #'cdr bibliography-declarations)))
                   (plist-get view :sources)))))))
       (_
        (setq
         info
         (plist-put
          info
          :texmacs-bibliography-declarations bibliography-declarations)))
       (name-shapes (org-texmacs--name-source-shapes ast))
       (wrapper-shapes (org-texmacs--figure-table-source-shapes ast))
       (definitions
        (org-texmacs--context-footnote-definitions ast islands))
       (_
        (when subtree-position
          (setq info
                (org-texmacs--context-select-subtree
                 ast subtree-position info))))
       (_
        (when region
          (org-texmacs--context-check-wrapper-region
           ast islands info region definitions)
          (let* ((selected
                  (save-restriction
                    (narrow-to-region (car region) (cdr region))
                    (org-element-parse-buffer)))
                 (local-definitions
                  (org-texmacs--context-footnote-definitions
                   selected nil)))
            (org-texmacs--figure-table-source-shapes
             selected wrapper-shapes t)
            (org-texmacs--name-source-shapes selected name-shapes t)
            ;; A second Org parse gives partial ordinary text its normal
            ;; narrowed-buffer semantics, without rebuilding source text.
            ;; Replace matching definitions so retained ones have the same
            ;; identities as the selected body, not duplicate full trees.
            (setq definitions
                  (mapcar
                   (lambda (definition)
                     (or (cl-find-if
                          (lambda (local)
                            (and (eq
                                  (org-element-type local)
                                  (org-element-type definition))
                                 (equal
                                  (org-element-property :begin local)
                                  (org-element-property
                                   :begin definition))))
                          local-definitions)
                         definition))
                   definitions))
            (apply #'org-element-set-contents
                   ast
                   (org-element-contents selected))
            (dolist (child (org-element-contents ast))
              (org-element-put-property child :parent ast))
            (setq islands
                  (append
                   (mapcar
                    (lambda (node) (cons node '(concat "")))
                    (org-texmacs--native-body-blocks ast))
                   islands)))))
       (_ (org-texmacs--context-prune ast islands info t))
       (_
        (setq
         info
         (plist-put
          info
          :texmacs-keywords-positional
          (and (not subtree-position)
               (not region)
               (org-element-map
                ast 'keyword
                (lambda (node)
                  (equal (org-element-property :key node) "KEYWORDS"))
                nil t)))))
       (_
        (org-texmacs--context-preserve-footnotes
         ast islands definitions info))
       (reachable (org-texmacs--context-reachable ast islands))
       (islands
        (cl-remove-if-not
         (lambda (entry) (gethash (car entry) reachable)) islands))
       (post-blanks
        (cl-remove-if-not
         (lambda (entry)
           (gethash (car entry) reachable))
         post-blanks))
       (requests
        (cl-remove-if-not
         (lambda (request) (memq (car request) islands)) requests)))
    (list ast islands requests post-blanks info)))

(provide 'org-texmacs-context)
;;; org-texmacs-context.el ends here
