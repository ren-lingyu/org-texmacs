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

(defconst org-texmacs--context-option-alist
  '((:title "TITLE" nil nil parse)
    (:date "DATE" nil nil parse)
    (:author "AUTHOR" nil user-full-name parse)
    (:select-tags "SELECT_TAGS" nil org-export-select-tags split)
    (:exclude-tags "EXCLUDE_TAGS" nil org-export-exclude-tags split)
    (:headline-levels nil "H" org-export-headline-levels)
    (:section-numbers nil "num" org-export-with-section-numbers)
    (:with-archived-trees nil "arch" org-export-with-archived-trees)
    (:with-author nil "author" org-export-with-author)
    (:with-date nil "date" org-export-with-date)
    (:with-priority nil "pri" org-export-with-priority)
    (:with-toc nil "toc" org-export-with-toc)
    (:with-tags nil "tags" org-export-with-tags)
    (:with-tasks nil "tasks" org-export-with-tasks)
    (:with-title nil "title" org-export-with-title)
    (:with-todo-keywords nil "todo" org-export-with-todo-keywords))
  "Org options deliberately accepted by document preparation.")

(defconst org-texmacs--context-source-keywords
  '("OPTIONS" "FILETAGS" "TITLE" "DATE" "AUTHOR" "SELECT_TAGS" "EXCLUDE_TAGS"
    "EXPORT_FILE_NAME")
  "Org keywords consumed by the restricted context adapter.")

(defconst org-texmacs--context-rejected-keywords
  '("SETUPFILE" "INCLUDE" "BIND" "MACRO" "CITE_EXPORT")
  "Source directives that require preprocessing outside this adapter.")

(defconst org-texmacs--context-export-properties
  '("EXPORT_TITLE" "EXPORT_AUTHOR" "EXPORT_DATE" "EXPORT_OPTIONS"
    "EXPORT_SELECT_TAGS" "EXPORT_EXCLUDE_TAGS" "EXPORT_FILE_NAME")
  "Supported subtree export properties; inert during whole-buffer lowering.")

(defun org-texmacs--context-subtree-settings ()
  "Own the source's property lookup settings used by subtree export."
  (org-texmacs--context-copy
   (list org-use-property-inheritance org-property-separators
         org-global-properties org-global-properties-fixed)))

(defun org-texmacs--context-copy (value)
  "Copy configuration VALUE without retaining mutable strings or conses."
  (cond
   ((stringp value) (substring-no-properties value))
   ((consp value)
    (cons (org-texmacs--context-copy (car value))
          (org-texmacs--context-copy (cdr value))))
   ((vectorp value) (apply #'vector (mapcar #'org-texmacs--context-copy value)))
   (t value)))

(defun org-texmacs--context-base-options ()
  "Snapshot supported global and source-buffer-local Org options.
Do not inspect source keywords or run BIND, SETUPFILE, hooks or filters."
  (let ((org-export-options-alist org-texmacs--context-option-alist))
    (append
     (org-export--get-global-options)
     (list :texmacs-tag-groups-alist
           (org-texmacs--context-copy org-tag-groups-alist)
           :texmacs-tag-groups-alist-for-agenda
           (org-texmacs--context-copy org-tag-groups-alist-for-agenda)))))

(defun org-texmacs--context-validate-options (value)
  "Reject unsupported or malformed option tokens in OPTIONS VALUE."
  (let ((allowed (delq nil (mapcar (lambda (entry) (nth 2 entry))
                                    org-texmacs--context-option-alist))))
    (with-temp-buffer
      (insert value)
      (goto-char (point-min))
      (while (re-search-forward "\\s-*\\(.+?\\):" nil t)
        (when (looking-at-p "\\S-")
          (unless (member-ignore-case (match-string 1) allowed)
            (signal 'org-texmacs-document-error
                    (list "Unsupported #+OPTIONS key" (match-string 1))))
          (condition-case nil
              (read (current-buffer))
            (error
             (signal 'org-texmacs-document-error
                     '("Malformed #+OPTIONS value")))))))))

(defun org-texmacs--context-keywords (ast islands keywords &optional unique directory)
  "Collect KEYWORDS from AST without descending into ISLANDS.
Match the part of `org-collect-keywords' used by Org's in-buffer option
conversion, but never follow SETUPFILE.  UNIQUE and DIRECTORY retain the
standard collector result shape for completeness."
  (let ((wanted (mapcar #'upcase keywords)) alist order)
    (cl-labels
        ((add (key value)
           (when (or (member key unique) (org-string-nw-p value))
             (let ((entry (assoc-string key alist t))
                   (value (if directory (cons value default-directory) value)))
               (if entry
                   (unless (member key unique) (setcdr entry (cons value (cdr entry))))
                 (push key order)
                 (push (cons key (if (member key unique) value (list value))) alist)))))
         (walk (node)
           (unless (assq node islands)
             (when (consp node)
               (if (eq (org-element-type node) 'keyword)
                   (let ((key (upcase (org-element-property :key node)))
                         (value (org-element-property :value node)))
                     (when (member key org-texmacs--context-rejected-keywords)
                       (signal 'org-texmacs-document-error
                               (list "Unsupported preprocessing directive" key)))
                     (when (and (string= key "OPTIONS") (stringp value))
                       (org-texmacs--context-validate-options value))
                     (when (and (member key wanted) (stringp value))
                       (add key value)))
                 (mapc #'walk (org-element-contents node)))))))
      (walk ast))
    (mapcar
     (lambda (key)
       (let ((entry (assoc-string key alist t)))
         (if (member key unique) entry
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
                       ast islands keywords unique directory))))
           (org-export--get-inbuffer-options)))
      (org-texmacs-document-error (signal (car err) (cdr err)))
      (error
       (signal 'org-texmacs-document-error
               (list "Invalid Org document options" (error-message-string err)))))))

(defun org-texmacs--context-parse-alt-title (headline)
  "Parse HEADLINE's ALT_TITLE with Org's headline object restrictions.
Store the result as owned secondary AST data before the source buffer goes
away.  Do not discover TeXmacs fragments in this document-wide metadata."
  (let ((value (org-element-property :ALT_TITLE headline)))
    (when value
      (unless (stringp value)
        (signal 'org-texmacs-document-error '("Invalid ALT_TITLE property")))
      (condition-case err
          (let ((parsed
                 (org-element-parse-secondary-string
                  value (org-element-restriction 'headline) headline)))
            (org-element-put-property headline :ALT_TITLE parsed)
            (org-element-put-property
             headline :secondary
             (cons :ALT_TITLE
                   (delq :ALT_TITLE (org-element-property :secondary headline)))))
        (error
         (signal 'org-texmacs-document-error
                 (list "Invalid ALT_TITLE property" (error-message-string err))))))))

(defun org-texmacs--context-validate-info (info)
  "Validate the supported effective option subset in INFO."
  (unless
      (and (wholenump (plist-get info :headline-levels))
           (<= (plist-get info :headline-levels) 5)
           (integerp (plist-get info :texmacs-tab-width))
           (> (plist-get info :texmacs-tab-width) 0)
           (let ((value (plist-get info :section-numbers)))
             (or (memq value '(nil t)) (wholenump value)))
           (memq (plist-get info :with-archived-trees) '(nil t headline))
           (memq (plist-get info :with-author) '(nil t))
           (memq (plist-get info :with-date) '(nil t))
           (memq (plist-get info :with-priority) '(nil t))
           (let ((value (plist-get info :with-toc)))
             (or (memq value '(nil t)) (wholenump value)))
           (memq (plist-get info :with-tags) '(nil t not-in-toc))
           (let ((value (plist-get info :with-tasks)))
             (or (memq value '(nil t todo done))
                 (and (proper-list-p value) (cl-every #'stringp value))))
           (memq (plist-get info :with-title) '(nil t))
           (memq (plist-get info :with-todo-keywords) '(nil t))
           (proper-list-p (plist-get info :select-tags))
           (cl-every #'stringp (plist-get info :select-tags))
           (proper-list-p (plist-get info :exclude-tags))
           (cl-every #'stringp (plist-get info :exclude-tags)))
    (signal 'org-texmacs-document-error '("Invalid supported Org document options")))
  info)

(defun org-texmacs--context-prune (ast islands info &optional defer-footnotes)
  "Prune supported non-exported structures from AST under fixed INFO.
Treat every ISLAND key as opaque.  When DEFER-FOOTNOTES is non-nil, leave
definition contents untouched until referenced definitions have been selected.
Return AST after in-place pruning."
  (let ((org-tag-groups-alist
         (org-texmacs--context-copy (plist-get info :texmacs-tag-groups-alist)))
        (org-tag-groups-alist-for-agenda
         (org-texmacs--context-copy
          (plist-get info :texmacs-tag-groups-alist-for-agenda))))
    (let ((selected (org-texmacs--context-selected-trees ast islands info))
          (excluded (cl-mapcan (lambda (tag) (org-tags-expand tag t))
                               (plist-get info :exclude-tags))))
      (when (and selected
                 (org-element-type-p (car (org-element-contents ast)) 'section))
        (org-element-extract (car (org-element-contents ast))))
      (cl-labels
          ((walk (node)
             (unless (assq node islands)
               (let ((type (org-element-type node)))
                 (cond
                  ((memq type '(comment comment-block))
                   (org-element-extract node))
                  ((eq type 'footnote-definition)
                   (unless defer-footnotes
                     (mapc #'walk (copy-sequence (org-element-contents node)))))
                  ((eq type 'keyword)
                   (when (member (upcase (org-element-property :key node))
                                 org-texmacs--context-source-keywords)
                     (org-element-extract node)))
                  ((eq type 'property-drawer)
                   (let ((parent (org-element-property :parent node)))
                     (while (and parent (not (eq (org-element-type parent) 'headline)))
                       (setq parent (org-element-property :parent parent)))
                     (unless (and parent
                                  (cl-every
                                   (lambda (property)
                                     (and (eq (org-element-type property) 'node-property)
                                          (member (upcase
                                                   (org-element-property :key property))
                                                  (append '("UNNUMBERED" "ALT_TITLE"
                                                            "CUSTOM_ID" "ID")
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
                           (org-export--skip-p node info selected excluded))
                       (org-element-extract node)
                     (if (and (eq (plist-get info :with-archived-trees) 'headline)
                              (org-element-property :archivedp node))
                         (org-element-set-contents node)
                       (mapc #'walk (copy-sequence (org-element-contents node))))))
                  (t (mapc #'walk (copy-sequence (org-element-contents node)))))))))
        (mapc #'walk (copy-sequence (org-element-contents ast))))))
  ast)

(defun org-texmacs--context-selected-trees (ast islands info)
  "Return selected headline identities in AST without entering ISLANDS.
Follow Org's select-tag genealogy and descendant policy under fixed INFO."
  (let ((select (cl-mapcan (lambda (tag) (org-tags-expand tag t))
                           (plist-get info :select-tags))))
    (cl-labels
        ((headlines (node)
           (let (result)
             (cl-labels ((walk (child)
                           (unless (assq child islands)
                             (when (consp child)
                               (when (eq (org-element-type child) 'headline)
                                 (push child result))
                               (mapc #'walk (org-element-contents child))))))
               (walk node))
             (nreverse result))))
      (if (cl-some (lambda (tag) (member tag select)) (plist-get info :filetags))
          (headlines ast)
        (let (selected)
          (cl-labels
              ((walk (node genealogy)
                 (unless (assq node islands)
                   (when (consp node)
                     (if (eq (org-element-type node) 'headline)
                         (if (cl-some (lambda (tag) (member tag select))
                                      (org-element-property :tags node))
                             (setq selected
                                   (append genealogy (headlines node) selected))
                           (mapc (lambda (child)
                                   (walk child (cons node genealogy)))
                                 (org-element-contents node)))
                       (mapc (lambda (child) (walk child genealogy))
                             (org-element-contents node)))))))
            (walk ast nil))
          selected)))))

(defun org-texmacs--context-footnote-definitions (ast islands)
  "Collect named definition nodes from AST without entering ISLANDS.
Keep parsed nodes, including inline definitions, rather than source spans."
  (let (definitions)
    (cl-labels ((walk (node ancestors)
                  (when (and (consp node) (not (assq node islands)))
                    (when (memq node ancestors)
                      (signal 'org-texmacs-document-error '("Cyclic footnote definition tree")))
                    (when (and (or (eq (org-element-type node) 'footnote-definition)
                                   (and (eq (org-element-type node) 'footnote-reference)
                                        (eq (org-element-property :type node) 'inline)))
                               (org-element-property :label node))
                      (push node definitions))
                    (let ((ancestors (cons node ancestors)))
                      (when (eq (org-element-type node) 'headline)
                        (mapc (lambda (child) (walk child ancestors))
                              (org-element-property :title node)))
                      (mapc (lambda (child) (walk child ancestors))
                            (org-element-contents node))))))
      (walk ast nil))
    (nreverse definitions)))

(defun org-texmacs--context-preserve-footnotes (ast islands definitions info)
  "Keep definitions required by visible references in AST under fixed INFO.
DEFINITIONS was captured before pruning.  Restore only missing definitions
from this parsed snapshot; never fall back to a buffer or external data."
  (let ((reachable (org-texmacs--context-reachable ast islands)) labels)
    (cl-labels ((walk (node)
                  (when (and (consp node) (not (assq node islands))
                             (not (eq (org-element-type node) 'footnote-definition)))
                    (when (eq (org-element-type node) 'footnote-reference)
                      (when-let* ((label (org-element-property :label node)))
                        (cl-pushnew label labels :test #'equal)))
                    (mapc #'walk (org-element-contents node)))))
      (walk ast))
    ;; Definitions are document data, not standalone body paragraphs.
    (dolist (definition definitions)
      (when (and (eq (org-element-type definition) 'footnote-definition)
                 (gethash definition reachable)
                 (not (member (org-element-property :label definition) labels)))
        (org-element-extract definition)))
    (dolist (label labels)
      (let ((matching (cl-remove-if-not
                       (lambda (definition)
                         (equal label (org-element-property :label definition)))
                       definitions)))
        (unless (cl-some (lambda (definition) (gethash definition reachable)) matching)
          (dolist (definition matching)
            (let ((restored
                   (if (eq (org-element-type definition) 'footnote-definition)
                       (progn (org-element-extract definition) definition)
                     (org-element-create
                      'footnote-definition (list :label label)
                      (apply #'org-element-create 'paragraph nil
                             (org-element-contents definition))))))
              (apply #'org-element-set-contents ast
                     (append (org-element-contents ast) (list restored))))))))
    ;; Apply the same restricted policy to recovered definition contents.
    (org-texmacs--context-prune ast islands info)))

(defun org-texmacs--context-reachable (ast islands)
  "Return an eq table of nodes reachable from AST, treating ISLANDS as opaque."
  (let ((table (make-hash-table :test #'eq)))
    (cl-labels
        ((walk (node)
           (unless (gethash node table)
             (puthash node t table)
             (when (and (consp node) (not (assq node islands)))
               (mapc #'walk (org-element-contents node))
               ;; Captions are affiliated pairs of secondary strings, rather
               ;; than entries in `org-element-secondary-value-alist'.
               (dolist (line (org-element-property :caption node))
                 (mapc #'walk (car line))
                 (mapc #'walk (cdr line)))
               (dolist (key (cdr (assq (org-element-type node)
                                       org-element-secondary-value-alist)))
                 (mapc #'walk (org-element-property key node)))))))
      (walk ast))
    table))

(defun org-texmacs--context-select-subtree (ast position info)
  "Select the subtree at snapshot POSITION in owned AST under INFO.
Apply restricted Org subtree overrides before dropping the root heading.
Keep global declarations in INFO; body dependencies are restored separately."
  (goto-char position)
  (condition-case nil (org-back-to-heading t)
    (error (signal 'org-texmacs-document-error '("No subtree at source position"))))
  (let* ((begin (point))
         (root (org-element-map ast 'headline
                 (lambda (node) (and (= begin (org-element-property :begin node)) node))
                 nil t))
         (settings (plist-get info :texmacs-subtree-settings))
         (org-use-property-inheritance (nth 0 settings))
         (org-property-separators (nth 1 settings))
         (org-global-properties (nth 2 settings))
         (org-global-properties-fixed (nth 3 settings))
         (org-entry-property-inherited-from (make-marker))
         (org-export-options-alist org-texmacs--context-option-alist))
    (unless root (signal 'org-texmacs-document-error '("Missing snapshot subtree")))
    (when-let* ((options (org-entry-get begin "EXPORT_OPTIONS" 'selective)))
      (org-texmacs--context-validate-options options))
    (dolist (section (org-element-contents root))
      (when (org-element-type-p section 'section)
        (dolist (drawer (org-element-contents section))
          (when (org-element-type-p drawer 'property-drawer)
            (dolist (property (org-element-contents drawer))
              (let ((key (upcase (org-element-property :key property))))
                (when (and (string-prefix-p "EXPORT_" key)
                           (not (member key org-texmacs--context-export-properties)))
                  (signal 'org-texmacs-document-error
                          (list "Unsupported subtree export property" key)))))))))
    (let* ((overrides (org-export--get-subtree-options))
           (metadata (copy-sequence (plist-get info :texmacs-metadata-present))))
      (dolist (entry '((:title . "TITLE") (:author . "AUTHOR") (:date . "DATE")))
        (when (plist-member overrides (car entry))
          (cl-pushnew (cdr entry) metadata :test #'equal)))
      (setq info (org-combine-plists info overrides
                                    (list :texmacs-metadata-present metadata))))
    ;; Root heading/title/properties are document configuration, not body.
    (let ((children (copy-sequence (org-element-contents root))))
      (when (org-element-type-p (car children) 'section)
        (dolist (node (copy-sequence (org-element-contents (car children))))
          (when (org-element-type-p node '(planning property-drawer))
            (org-element-extract node))))
      (dolist (child children) (org-element-put-property child :parent ast))
      (apply #'org-element-set-contents ast children))
    (org-texmacs--context-validate-info info)))

(defun org-texmacs--context-prepare
    (ast islands requests post-blanks base-info &optional subtree-position)
  "Apply restricted context to prepared AST and associated mappings.
Return (AST ISLANDS REQUESTS POST-BLANKS INFO), retaining only mappings and
worker requests whose identity keys remain reachable after filtering.
Optional SUBTREE-POSITION clips the owned tree after configuration capture."
  (let* ((metadata
          (mapcar #'car
                  (org-texmacs--context-keywords
                   ast islands '("TITLE" "AUTHOR" "DATE"))))
         (info (plist-put
                (plist-put
                 (org-texmacs--context-validate-info
                  (org-texmacs--context-merge-options ast islands base-info))
                 :texmacs-metadata-present metadata)
                :parse-tree ast))
         (bibliography-declarations
          (mapcar (lambda (raw)
                    (cons raw (caar (org-texmacs--bibliography-source-snapshot
                                     (list (cons (org-strip-quotes (string-trim raw)) ""))
                                     (plist-get base-info :texmacs-resource-base)))))
                  (cdr (assoc "BIBLIOGRAPHY"
                              (org-texmacs--context-keywords ast islands '("BIBLIOGRAPHY"))))))
         (_ (setq info (plist-put info :texmacs-bibliography-declarations bibliography-declarations)))
         (definitions (org-texmacs--context-footnote-definitions ast islands))
         (_ (when subtree-position
              (setq info (org-texmacs--context-select-subtree ast subtree-position info))))
         (_ (org-texmacs--context-prune ast islands info t))
         (_ (org-texmacs--context-preserve-footnotes ast islands definitions info))
         (reachable (org-texmacs--context-reachable ast islands))
         (islands (cl-remove-if-not (lambda (entry) (gethash (car entry) reachable))
                                    islands))
         (post-blanks
          (cl-remove-if-not (lambda (entry) (gethash (car entry) reachable)) post-blanks))
         (requests (cl-remove-if-not (lambda (request) (memq (car request) islands))
                                     requests)))
    (list ast islands requests post-blanks info)))

(provide 'org-texmacs-context)
;;; org-texmacs-context.el ends here
