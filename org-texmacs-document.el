;;; org-texmacs-document.el --- Document lowering for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Pure structural lowering of prepared Org trees and TeXmacs islands.
;; Source discovery and native encoding are separate operations.  These trees
;; contain text, not native TeXmacs bytes; STM paths preserve source semantics.

;;; Code:


(require 'org-texmacs-core)
(require 'org-texmacs-source)
(require 'org-texmacs-fragment)
(require 'org-texmacs-context)
(require 'ox)

(defconst org-texmacs--document-markup-tags
  '((bold . strong) (italic . em) (underline . underline)
    (strike-through . strike-through))
  "TeXmacs tags for recursively lowered Org inline markup.")

(defconst org-texmacs--supported-link-types
  '("http" "https" "mailto" "ftp" "ftps")
  "Org link types accepted as self-contained URI targets.")

(defconst org-texmacs--document-list-tags
  '((unordered . itemize) (ordered . enumerate) (descriptive . description))
  "TeXmacs environment tags for Org's three native plain-list types.")

(defconst org-texmacs--document-section-tags
  '((section . section*) (subsection . subsection*)
    (subsubsection . subsubsection*) (paragraph . paragraph*)
    (subparagraph . subparagraph*))
  "Numbered and unnumbered TeXmacs tags for sectioning levels one through five.")

(defconst org-texmacs--document-display-math-tags
  '(equation equation* eqnarray eqnarray* align align* gather gather* eqsplit eqsplit*)
  "Known native display roots that cannot be embedded in paragraph concat.
This is a lowering boundary, not a fragment discovery configuration.")

(defconst org-texmacs--document-toc-tags
  '(toc-1 toc-2 toc-3 toc-4 toc-5)
  "Static TeXmacs table-of-contents tags for headline levels one through five.")

(defconst org-texmacs--document-toc-label-prefix "org-texmacs-toc-"
  "Private prefix for deterministic table-of-contents target labels.")

(defconst org-texmacs--document-reference-label-prefix "org-texmacs-ref-"
  "Private prefix for resolved Org reference target labels.")

(defconst org-texmacs--document-footnote-label-prefix "org-texmacs-fn-"
  "Private prefix for named footnote reference targets.")

(defconst org-texmacs--document-statement-tags
  '(theorem proposition lemma corollary axiom definition notation conjecture
    remark example note warning convention exercise problem proof)
  "Explicit native formal-statement tags; availability depends on style.")

(defvar org-texmacs--document-special-block-handlers nil
  "Private alist mapping ordinary block types to pure handler functions.
Handlers receive BLOCK, lowered CONTENTS and captured INFO, all read-only.
Return a stree containing CONTENTS exactly once, without modifying it or
sharing any descendant outside it.  Do not duplicate source-semantic content
by copying or rebuilding it either; this last rule cannot be fully checked.
No stable extension API is promised.  Captured closure state is not frozen.")

(defun org-texmacs--document-copy-handlers (handlers)
  "Validate, resolve and own the private HANDLERS registry."
  (unless (proper-list-p handlers)
    (signal 'org-texmacs-document-error '("Invalid special-block handlers")))
  (let (seen)
    (mapcar
     (lambda (entry)
       (unless (and (consp entry) (stringp (car entry))
                    (string-match-p "\\`[^ \t\r\n]+\\'" (car entry)))
         (signal 'org-texmacs-document-error '("Invalid special-block handler entry")))
       (let* ((key (downcase (car entry)))
              (function (condition-case nil (indirect-function (cdr entry))
                          (error nil))))
         (when (or (member key seen) (member key '("texmacs" "statement" "equation" "equation*"
                                                                  "figure" "figure*" "table" "table*"))
                   (string-prefix-p "statement_" key)
                   (member key (mapcar #'symbol-name org-texmacs--document-statement-tags))
                   (not (functionp function)))
           (signal 'org-texmacs-document-error '("Invalid or reserved special-block handler")))
         (push key seen)
         (cons (substring-no-properties key) function)))
     handlers)))

(defun org-texmacs--document-statement-tag (node)
  "Resolve NODE's statement syntax; return nil for an ordinary custom type."
  (let* ((raw (org-element-property :type node))
         (parameters (org-element-property :parameters node)))
    (unless (and (stringp raw) (> (length raw) 0)
                 (or (null parameters) (stringp parameters)))
      (org-texmacs--document-fail node "Invalid special-block type or parameters"))
    (let* ((type (downcase raw))
           (tokens (split-string (or parameters "") "[ \t\r\n]+" t))
           (name (cond ((equal type "statement")
                        (unless (= (length tokens) 1)
                          (org-texmacs--document-fail node "Statement requires exactly one type"))
                        (downcase (car tokens)))
                       ((string-prefix-p "statement_" type) (substring type 10))
                       ((member type (mapcar #'symbol-name
                                              org-texmacs--document-statement-tags)) type))))
      (when name
        (unless (and (member name (mapcar #'symbol-name
                                         org-texmacs--document-statement-tags))
                     (or (equal type "statement") (null tokens)))
          (org-texmacs--document-fail node "Unsupported statement type or parameters"))
        (intern name)))))

(defcustom org-texmacs-document-style '("generic")
  "TeXmacs style names captured by buffer document preparation.
Each conversion copies this list into its prepared input and result.  These
strings are TeXmacs identifiers, not ordinary Org text leaves."
  :type '(repeat string)
  :group 'org-texmacs)

(defcustom org-texmacs-document-initial nil
  "TeXmacs initial environment captured by buffer document preparation.
The value is an alist of unique nonempty string keys to text strees.  Keys are
TeXmacs identifiers.  Entire values have TeXmacs source semantics, including
native notation such as <alpha>; use <less> and <gtr> for literal brackets."
  :type '(alist :key-type string :value-type sexp)
  :group 'org-texmacs)

(defcustom org-texmacs-format-headline-function
  #'org-texmacs-format-headline-default-function
  "Function presenting headline metadata and lowered title parts.
Called with TODO, TODO-TYPE, PRIORITY, TITLE-PARTS, TAGS and INFO.  Metadata
disabled by INFO is nil; TITLE-PARTS is a list of text strees, not Org nodes.
Return one text stree for the fixed sectioning node's sole title child.
All output leaves have Org literal semantics, not STM source semantics.
INFO is a conversion-local options plist.  Treat inputs as read-only and
prefer a side-effect-free formatter.  Calls may occur during preflight and
final lowering; no invocation count is guaranteed.  Custom function side
effects are the caller's responsibility."
  :type 'function
  :group 'org-texmacs)

(defun org-texmacs-format-headline-default-function
    (todo _todo-type priority title-parts tags _info)
  "Return a fresh text title stree without side effects.
TODO becomes strong text, PRIORITY a literal cookie, and TAGS an explicit
tag string.  Preserve TITLE-PARTS without merging adjacent text."
  (let ((parts (append (and todo (list (list 'strong todo) " "))
                       (and priority
                            (list (concat "[#" (org-priority-to-string priority) "]") " "))
                       title-parts
                       (and tags (list " " (org-make-tag-string tags))))))
    (org-texmacs--document-copy-stree
     (if (= (length parts) 1) (car parts) (cons 'concat parts)))))

(defun org-texmacs--document-date-timestamp-text (raw)
  "Return RAW date metadata timestamp text unchanged.
This private function may be advised to customize display.  It receives an
owned string, including Org delimiters, and must return a string.  Calls may
occur during preflight and lowering; no invocation count is guaranteed.
Keep advice side-effect-free.  The conversion captures this function's
definition, not mutable state captured by advice."
  raw)

(defun org-texmacs--document-options ()
  "Snapshot supported Org document policies and the selected formatter.
File keywords are merged later from the prepared AST without following setup
files.  Do not run export preprocessing, BIND, hooks or filters here.
Capture `tab-width' for preformatted content.  Resolve a formatter symbol now
so later redefinition affects only new calls."
  (let ((formatter (indirect-function org-texmacs-format-headline-function))
        (date-formatter (indirect-function 'org-texmacs--document-date-timestamp-text))
        (info (plist-put (org-texmacs--context-base-options)
                         :texmacs-tab-width tab-width)))
    (unless (and (memq org-export-with-todo-keywords '(nil t))
                 (memq org-export-with-priority '(nil t))
                 (memq org-export-with-tags '(nil t not-in-toc))
                 (functionp formatter) (functionp date-formatter))
      (signal 'org-texmacs-document-error '("Invalid headline presentation options")))
    (setq info (plist-put info :texmacs-format-headline-function formatter))
    (setq info (plist-put info :texmacs-special-block-handlers
                         (org-texmacs--document-copy-handlers
                          org-texmacs--document-special-block-handlers)))
    (plist-put info :texmacs-date-timestamp-text-function date-formatter)))

(cl-defstruct (org-texmacs-document
               (:constructor org-texmacs--document-create)
               (:copier nil))
  "Read-only structural result, before native encoding.
BODY is a text stree; STYLE is a list of TeXmacs style identifiers; INITIAL
is an alist of environment identifiers to source-semantic text strees.
STM-PATHS locate source-semantic roots within BODY, including native bibliography
output and authored STM islands.  Each path contains
zero-based child indices, excluding tags.  SOURCE-FILE and RESOURCE-BASE
are copied source identity and resource-base strings, or nil.
FILE-PATHS locate Org file-link target string leaves in BODY, separate from
STM roots.  Consumers use RESOURCE-BASE without changing these raw leaves.
Callers must not mutate any slot
or nested list/string.  No source buffer is retained."
  (body nil :read-only t)
  (stm-paths nil :read-only t)
  (style (list "generic") :read-only t)
  (initial nil :read-only t)
  (source-file nil :read-only t)
  (resource-base nil :read-only t)
  (file-paths nil :read-only t))

(defun org-texmacs--document-fail (node message)
  "Signal a conversion error for NODE with MESSAGE and source context."
  (signal 'org-texmacs-document-error
          (list message
                (if (stringp node) 'plain-text (org-element-type node))
                (unless (stringp node) (org-element-property :begin node)))))

(defun org-texmacs--document-copy-stree (node &optional ancestors)
  "Validate and copy text stree NODE without sharing strings or conses.
ANCESTORS detects cycles; repeated, non-cyclic subtrees are copied separately."
  (cond
   ((stringp node) (substring-no-properties node))
   ((and (consp node) (car node) (symbolp (car node))
         (proper-list-p node) (not (memq node ancestors)))
    (cons (car node)
          (mapcar (lambda (child)
                    (org-texmacs--document-copy-stree child (cons node ancestors)))
                  (cdr node))))
   (t (signal 'org-texmacs-document-error '("Invalid island stree")))))

(defun org-texmacs--document-output-labels (body)
  "Collect only static label strings in validated BODY, retaining duplicates."
  (when (consp body)
    (append (and (eq (car body) 'label) (= (length body) 2)
                 (stringp (cadr body)) (list (cadr body)))
            (cl-mapcan #'org-texmacs--document-output-labels (cdr body)))))

(defun org-texmacs--document-static-labels (islands)
  "Return copied static TeXmacs label names visible in ISLANDS.
Only a `(label STRING)' has a statically knowable name.  Validate traversed
strees and reject cycles instead of guessing through dynamic label bodies."
  (let (labels)
    (cl-labels
        ((walk (node ancestors)
           (cond
            ((stringp node))
            ((and (consp node) (car node) (symbolp (car node))
                  (proper-list-p node) (not (memq node ancestors)))
             (when (and (eq (car node) 'label) (null (cddr node))
                        (stringp (cadr node)))
               (push (substring-no-properties (cadr node)) labels))
             (mapc (lambda (child) (walk child (cons node ancestors))) (cdr node)))
            (t (signal 'org-texmacs-document-error '("Invalid island stree"))))))
      (dolist (entry islands) (walk (cdr entry) nil)))
    (delete-dups (nreverse labels))))

(cl-defstruct (org-texmacs-resolution
               (:constructor org-texmacs--resolution-create)
               (:copier nil))
  "Conversion-local links and target labels keyed by owned AST node identity."
  (links nil :read-only t)
  (labels nil :read-only t)
  (files nil :read-only t)
  (footnotes nil :read-only t)
  (targets nil :read-only t)
  (nodes nil :read-only t)
  (failure nil :read-only t))

(defun org-texmacs--document-local-file-path-p (path)
  "Return non-nil for a plain local file PATH with explicit source semantics.
Home abbreviations and remote/file-search semantics require additional context."
  (and (stringp path) (> (length path) 0)
       (cl-every (lambda (character) (and (>= character 32) (/= character 127)))
                 (string-to-list path))
       (not (string-prefix-p "~" path))
       (not (string-prefix-p "//" path))
       (not (string-match-p "\\`/[^/]*:" path))))

(defun org-texmacs--document-caption-lines (node)
  "Return NODE's parsed caption pairs, validating their secondary shape.
Each pair contains a nonempty long secondary string and an optional short one.
No source buffer is consulted."
  (let ((caption (org-element-property :caption node)))
    (unless (and (proper-list-p caption)
                 (cl-every (lambda (line)
                             (and (consp line) (car line)
                                  (proper-list-p (car line))
                                  (proper-list-p (cdr line))))
                           caption))
      (org-texmacs--document-fail node "Invalid parsed caption"))
    caption))


(defun org-texmacs--document-named-block-p (node)
  "Return non-nil when NODE admits a Stage4 NAME identity."
  (and (eq (org-element-type node) 'special-block)
       (or (org-texmacs--native-body-kind node)
           (org-texmacs--figure-table-kind node)
           (org-texmacs--document-statement-tag node))))

(defun org-texmacs--document-statement-caption (node)
  "Validate NODE's statement caption before scanning any secondary links.
Consume owned source evidence when present; never consult the source buffer.
Return the long-only caption pairs."
  (let* ((lines (org-texmacs--document-caption-lines node))
         (proof (org-element-property :texmacs-name-source node))
         (rows (and (proper-list-p proof) (nth 3 proof))))
    (when proof
      (unless (and (proper-list-p proof) (= (length proof) 4)
                   (equal (car proof)
                          (list (org-element-property :type node)
                                (org-element-property :begin node)
                                (org-element-property :post-affiliated node)
                                (org-element-property :texmacs-source-end node)))
                   (proper-list-p rows)
                   (cl-every (lambda (row)
                               (and (proper-list-p row) (= (length row) 2)
                                    (memq (car row) '(nil t)) (stringp (cadr row)))) rows))
        (org-texmacs--document-fail node "Original statement caption evidence differs")))
    ;; Syntax evidence catches CAPTION[] even when Org erases its empty short AST.
    ;; Reject it before traversing either long or short links.
    (when (or (cl-some #'car rows) (cl-some #'cdr lines))
      (org-texmacs--document-fail node "Statement short captions are unsupported"))
    (when (or (cl-some (lambda (row) (string-blank-p (cadr row))) rows)
              (cl-some (lambda (line)
                         (cl-every (lambda (part) (and (stringp part) (string-blank-p part)))
                                   (car line))) lines))
      (org-texmacs--document-fail node "Empty statement caption"))
    (when (and proof (/= (length rows) (length lines)))
      (org-texmacs--document-fail node "Original statement caption evidence differs"))
    lines))

(defun org-texmacs--reference-slug (name)
  "Return NAME's per-character ASCII slug independently of case folding."
  (let ((case-fold-search nil))
    (downcase (replace-regexp-in-string "[^A-Za-z0-9]" "_" name))))

(defun org-texmacs--document-allocate (ast analysis static)
  "Freeze AST's ANALYSIS with Org-allocated references, reserving STATIC labels.
The mutable Org cache remains local and is never returned."
  (let ((info (list :parse-tree ast :internal-references nil :crossrefs nil))
        (reserved (append static (mapcar (lambda (entry) (nth 2 (cdr entry)))
                                        (org-texmacs-resolution-footnotes analysis))))
        (selected (mapcar #'cdr (org-texmacs-resolution-targets analysis))) labels)
    (dolist (node (org-texmacs-resolution-nodes analysis))
      (when (or (memq node selected)
                (and (org-texmacs--document-named-block-p node)
                     (org-element-property :name node)))
        (let ((name (org-element-property :name node)) candidate (attempt 0))
          (while (and (< attempt 64) (or (null candidate) (member candidate reserved)))
            (setq attempt (1+ attempt))
            (when candidate
              ;; Keep numeric search-cell reservations, but drop this target's
              ;; rejected direct binding so Org allocates another reference.
              (plist-put info :internal-references
                         (cl-remove-if (lambda (entry) (eq (cdr entry) node))
                                       (plist-get info :internal-references))))
            (setq candidate (concat "org-texmacs-"
                                    (and name (concat (org-texmacs--reference-slug name) "-"))
                                    (org-export-get-reference node info))))
          (when (member candidate reserved)
            (org-texmacs--document-fail node "Unable to allocate a unique label"))
          (push candidate reserved)
          (push (cons node candidate) labels))))
    (setq labels (nreverse labels))
    (org-texmacs--resolution-create
     :labels labels
     :links (mapcar (lambda (entry) (cons (car entry) (cdr (assq (cdr entry) labels))))
                    (org-texmacs-resolution-targets analysis))
     :targets (org-texmacs-resolution-targets analysis)
     :nodes (org-texmacs-resolution-nodes analysis)
     :files (org-texmacs-resolution-files analysis)
     :footnotes (org-texmacs-resolution-footnotes analysis))))

(defun org-texmacs--document-resolve (ast islands static-labels resource-base)
  "Validate local Org links in AST without allocating final references.
ISLANDS are opaque.  STATIC-LABELS reserves user-authored STM labels.
Return node-identity mappings only; never
read a source buffer, query an ID database or invoke an export consumer."
  (let ((definitions (org-texmacs--context-footnote-definitions ast islands))
        custom-ids ids links order resolved files
        footnote-references notes footnotes)
    (cl-labels
        ((scan (node ancestors)
           (unless (and (consp node)
                        (eq (org-element-type node) 'footnote-definition))
             (when (consp node)
               (when (memq node ancestors)
                 (org-texmacs--document-fail node "Cyclic Org AST"))
               (push node order)
               (let ((type (org-element-type node)))
                 (cond
                  ((eq type 'headline)
                   (let ((custom (org-element-property :CUSTOM_ID node))
                         (id (org-element-property :ID node))
                         (raw (org-element-property :raw-value node)))
                     (when (and (stringp custom) (> (length custom) 0))
                       (push (cons custom node) custom-ids))
                     (when (and (stringp id) (> (length id) 0))
                       (push (cons id node) ids))
                     (unless (stringp raw)
                       (org-texmacs--document-fail node "Invalid headline title"))))
                  ((eq type 'target)
                   (let ((value (org-element-property :value node)))
                     (unless (and (stringp value) (> (length value) 0))
                       (org-texmacs--document-fail node "Invalid dedicated target"))))
                  ((eq type 'link) (push node links))
                  ((eq type 'footnote-reference)
                   (when (cl-some
                          (lambda (ancestor)
                            (and (consp ancestor)
                                 (memq (org-element-type ancestor)
                                       '(footnote-definition footnote-reference))))
                          ancestors)
                     (org-texmacs--document-fail node "Nested footnotes are unsupported"))
                   (push node footnote-references)))
                 (let ((ancestors (cons node ancestors)))
                   (when (eq type 'headline)
                     (mapc (lambda (part) (scan part ancestors))
                           (org-element-property :title node)))
                   (when (or (eq type 'table) (org-texmacs--figure-table-kind node)
                             (and (eq type 'special-block)
                                  (org-texmacs--document-statement-tag node)))
                     (dolist (line (if (and (eq type 'special-block)
                                           (org-texmacs--document-statement-tag node))
                                      (org-texmacs--document-statement-caption node)
                                    (org-texmacs--document-caption-lines node)))
                       (mapc (lambda (part) (scan part ancestors)) (car line))
                       (mapc (lambda (part) (scan part ancestors)) (cdr line))))
                   (unless (or (assq node islands)
                               (org-texmacs--native-body-kind node)
                               (and (eq type 'footnote-reference)
                                    (org-element-property :label node)))
                     (mapc (lambda (child) (scan child ancestors))
                           (org-element-contents node))))))))
         (choose (node candidates)
           (let ((matches (cl-delete-duplicates (mapcar #'cdr candidates) :test #'eq)))
             (cond
              ((null matches)
               (org-texmacs--document-fail node "Unresolved internal link"))
              ((cdr matches)
               (org-texmacs--document-fail node "Ambiguous internal link"))
              (t (car matches)))))
         (lookup (key mapping)
           (cl-remove-if-not (lambda (entry) (equal key (car entry))) mapping)))
      (scan ast nil)
      (let ((reserved (copy-sequence static-labels)) (next 1))
        (dolist (reference (nreverse footnote-references))
          (when-let* ((name (org-element-property :label reference)))
            (unless (and (stringp name) (> (length name) 0))
              (org-texmacs--document-fail reference "Invalid named footnote label"))
            (let ((note (cdr (assoc name notes))))
              (unless note
                (let ((matching
                       (cl-remove-if-not
                        (lambda (definition)
                          (equal name (org-element-property :label definition)))
                        definitions))
                      anchor)
                  (unless (= (length matching) 1)
                    (org-texmacs--document-fail
                     reference (if matching "Ambiguous footnote definition"
                                 "Unresolved named footnote")))
                  (while
                      (progn
                        (setq anchor (concat org-texmacs--document-footnote-label-prefix
                                             (number-to-string next))
                              next (1+ next))
                        (member anchor reserved)))
                  (push anchor reserved)
                  ;; Shared immutable data: first occurrence, definition, anchor.
                  (setq note (list reference (car matching) anchor))
                  (push (cons name note) notes)
                  (mapc (lambda (child) (scan child (list (car matching))))
                        (org-element-contents (car matching)))))
              (push (cons reference note) footnotes)))))
      (setq links (nreverse links) order (nreverse order))
      (let ((cells (make-hash-table :test #'equal)))
        (dolist (node order)
          (when (or (memq (org-element-type node) '(headline target table))
                    (org-texmacs--document-named-block-p node))
            (when-let* ((name (org-element-property :name node)))
              (unless (and (stringp name) (not (string-blank-p name)))
                (org-texmacs--document-fail node "Invalid object NAME")))
            (dolist (cell (org-export-search-cells node))
              (push node (gethash cell cells)))))
        (let ((org-info (list :parse-tree ast :resolve-fuzzy-link-cache
                              (copy-hash-table cells))))
          (dolist (link links)
            (let* ((type (org-element-property :type link))
                   (path (org-element-property :path link))
                   (kind (and (stringp type) (downcase type)))
                   (target
                    (when (member kind '("custom-id" "id" "fuzzy"))
                      (unless (and (stringp path) (> (length path) 0))
                        (org-texmacs--document-fail link "Invalid internal link path"))
                      (pcase kind
                        ("custom-id" (choose link (lookup path custom-ids)))
                        ("id" (choose link (lookup path ids)))
                        ("fuzzy"
                         (let* ((search (org-export-string-to-search-cell path))
                                (matches (cl-mapcan (lambda (cell) (copy-sequence (gethash cell cells))) search))
                                (preferred (cl-remove-if
                                            (lambda (node) (eq (org-element-type node) 'headline)) matches))
                                (chosen (choose link (mapcar (lambda (node) (cons nil node))
                                                            (or preferred matches)))))
                           (unless (eq chosen (org-export-resolve-fuzzy-link link org-info))
                             (org-texmacs--document-fail link "Inconsistent Org link resolution"))
                           chosen))))))
              (when target
                (when (and (eq (org-element-type target) 'table)
                           (null (org-element-property :caption target))
                           (null (org-element-contents link)))
                  (org-texmacs--document-fail
                   link "Uncaptioned table reference requires a description"))
                (push (cons link target) resolved))
              (when (equal kind "file")
                (unless (and (org-texmacs--document-local-file-path-p path)
                             (null (org-element-property :search-option link))
                             (null (org-element-property :application link))
                             (or (null resource-base)
                                 (org-texmacs--document-local-file-path-p resource-base)))
                  (org-texmacs--document-fail link "Unsupported file link or resource context"))
                (let ((file-name-handler-alist nil))
                  (unless (or (file-name-absolute-p path) resource-base)
                    (org-texmacs--document-fail link "Relative file link requires a resource base")))
                (push (cons link (substring-no-properties path)) files))))))
      (org-texmacs--resolution-create
       :links (mapcar (lambda (entry) (cons (car entry) "")) (nreverse (copy-sequence resolved)))
       :targets (nreverse resolved) :nodes order
       :files (nreverse files) :footnotes (nreverse footnotes)))))

(defun org-texmacs--bibliography-collect (ast islands info sources resolution)
  "Collect actual citation usage from owned Org structures, without BibTeX parsing.
SOURCES lists available identities.  Check only source-independent contracts;
entry identities are resolved later against owned native ASTs."
  (let ((declarations (plist-get info :texmacs-bibliography-declarations))
        citations keys prints visited)
    (dolist (declaration declarations)
      (unless (member (cdr declaration) sources)
        (signal 'org-texmacs-document-error '("Bibliography declaration needs explicit source data"))))
    (cl-labels
        ((affix-empty (value)
           (and (proper-list-p value)
                (cl-every (lambda (part) (and (stringp part) (string-blank-p part))) value)))
         (walk (node parent)
           (when (and (consp node) (not (assq node islands)))
             (pcase (org-element-type node)
               ('footnote-definition nil)
               ('footnote-reference
                (let ((note (cdr (assq node (org-texmacs-resolution-footnotes resolution)))))
                  (if note
                      (unless (memq note visited)
                        (push note visited)
                        (mapc (lambda (child) (walk child (nth 1 note)))
                              (org-element-contents (nth 1 note))))
                    (mapc (lambda (child) (walk child node)) (org-element-contents node)))))
               ('citation
                (unless (and parent (memq (org-element-type parent)
                                           '(paragraph footnote-reference)))
                  (org-texmacs--document-fail node "Unsupported citation context"))
                (unless (and (null (org-element-property :style node))
                             (affix-empty (org-element-property :prefix node))
                             (affix-empty (org-element-property :suffix node))
                             (org-element-contents node))
                  (org-texmacs--document-fail node "Unsupported citation style or affixes"))
                (let (group)
                  (dolist (reference (org-element-contents node))
                    (let ((key (org-element-property :key reference)))
                      (unless (and (eq (org-element-type reference) 'citation-reference)
                                   (stringp key) (string-match-p "\\`[-A-Za-z0-9_:.+]+\\'" key)
                                   (affix-empty (org-element-property :prefix reference))
                                   (affix-empty (org-element-property :suffix reference)))
                        (org-texmacs--document-fail node "Unsupported citation reference"))
                      (unless (member key keys) (setq keys (append keys (list key))))
                      (push key group)))
                  (push (cons node (nreverse group)) citations)))
               ('keyword
                (pcase (upcase (org-element-property :key node))
                  ("BIBLIOGRAPHY"
                   (unless (assoc (org-element-property :value node) declarations)
                     (org-texmacs--document-fail node "Unprepared bibliography declaration")))
                  ("PRINT_BIBLIOGRAPHY"
                   (unless (string-blank-p (or (org-element-property :value node) ""))
                     (org-texmacs--document-fail node "Bibliography print options are unsupported"))
                   (push node prints))))
               (_
                (when (eq (org-element-type node) 'headline)
                  (mapc (lambda (child) (walk child node)) (org-element-property :title node)))
                (mapc (lambda (child) (walk child node)) (org-element-contents node)))))))
      (walk ast nil))
    (unless (or (and (null keys) (null prints)) (= (length prints) 1))
      (signal 'org-texmacs-document-error '("Citations require exactly one bibliography print")))
    (when (and keys (null declarations))
      (signal 'org-texmacs-document-error '("Unresolved citation key")))
    (list :keys keys :citations (nreverse citations) :prints prints)))

(defun org-texmacs--bibliography-plan (ast islands info bibliography resolution static-labels)
  "Resolve used citation keys against owned native BIBLIOGRAPHY trees.
Only effective declared sources participate.  Unused duplicate entries remain
opaque data; used keys must have exactly one candidate.  Never query buffers,
files, native parsers or field semantics."
  (let* ((usage (org-texmacs--bibliography-collect
                 ast islands info (mapcar #'car bibliography) resolution))
         (keys (plist-get usage :keys))
         (declarations (mapcar #'cdr (plist-get info :texmacs-bibliography-declarations)))
         (entries (make-hash-table :test #'equal)) selected)
    (dolist (source bibliography)
      (when (member (car source) declarations)
        (dolist (entry (cdr (cdr source)))
          (when (and (consp entry) (eq (car entry) 'bib-entry))
            (push entry (gethash (nth 2 entry) entries))))))
    (dolist (key keys)
      (let ((matches (gethash key entries)))
        (unless matches
          (signal 'org-texmacs-document-error (list "Unresolved citation key" key)))
        (when (cdr matches)
          (signal 'org-texmacs-document-error (list "Ambiguous bibliography key" key)))
        (push (car matches) selected)))
    (let ((number 1) prefix)
      (while (progn
               (setq prefix (format "org-texmacs-bib-%d" number) number (1+ number))
               (cl-some (lambda (key) (member (concat prefix "-" key) static-labels)) keys)))
      (append usage (list :prefix prefix :entries (cons 'document (nreverse selected)))))))

(defun org-texmacs--bibliography-labels (body)
  "Return every static label in owned native BODY, retaining duplicates.
Dynamic label structures cannot satisfy the bibliography output contract."
  (let (labels)
    (cl-labels ((walk (node)
                  (when (consp node)
                    (when (eq (car node) 'label)
                      (unless (and (= (length node) 2) (stringp (cadr node)))
                        (signal 'org-texmacs-document-error '("Invalid bibliography label")))
                      (push (cadr node) labels))
                    (mapc #'walk (cdr node)))))
      (walk body))
    (nreverse labels)))

(defun org-texmacs--bibliography-check-references (body prefix)
  "Check native BODY references under its captured bibliography PREFIX.
Do not inspect entry fields or expand dependencies.  A native dependency must
resolve against labels actually generated for this bibliography."
  (let ((labels (org-texmacs--bibliography-labels body)))
    (cl-labels
        ((walk (node current-prefix)
           (when (consp node)
             (pcase (car node)
               ('with-bib
                (unless (and (= (length node) 3) (stringp (cadr node)))
                  (signal 'org-texmacs-document-error '("Unsupported native bibliography context")))
                (walk (nth 2 node) (cadr node)))
               ((or 'cite 'reference 'pageref)
                (unless (and (cdr node)
                             (cl-every (lambda (target)
                                         (and (stringp target)
                                              (member (if (eq (car node) 'cite)
                                                          (concat current-prefix "-" target)
                                                        target)
                                                      labels)))
                                       (cdr node)))
                  (signal 'org-texmacs-document-error
                          '("Unresolved native bibliography reference"))))
               (_ (mapc (lambda (child) (walk child current-prefix)) (cdr node)))))))
      (walk body prefix))))

(defun org-texmacs--document-unnumbered-value (headline)
  "Return HEADLINE's effective inherited Org UNNUMBERED value."
  (org-export-get-node-property :UNNUMBERED headline t))

(defun org-texmacs--document-numbered-headline-p (headline relative info)
  "Return non-nil when HEADLINE at RELATIVE level is numbered under INFO."
  (let ((numbering (if (memq :section-numbers info)
                       (plist-get info :section-numbers)
                     t)))
    (and (not (org-not-nil (org-texmacs--document-unnumbered-value headline)))
         (or (eq numbering t)
             (and (wholenump numbering) (<= relative numbering))))))

(defun org-texmacs--document-copy-style (style)
  "Validate and copy TeXmacs STYLE identifier strings."
  (unless (and (proper-list-p style) style
               (cl-every (lambda (name)
                           (and (stringp name) (> (length name) 0)))
                         style))
    (signal 'org-texmacs-document-error '("Invalid TeXmacs document style")))
  (mapcar #'substring-no-properties style))

(defun org-texmacs--document-copy-initial (initial)
  "Validate and copy TeXmacs INITIAL environment entries."
  (unless (proper-list-p initial)
    (signal 'org-texmacs-document-error '("Invalid TeXmacs initial environment")))
  (let (keys)
    (mapcar
     (lambda (entry)
       (unless (and (consp entry) (stringp (car entry)) (> (length (car entry)) 0)
                    (not (member (car entry) keys)))
         (signal 'org-texmacs-document-error '("Invalid TeXmacs initial environment")))
       (push (car entry) keys)
       (cons (substring-no-properties (car entry))
             (org-texmacs--document-copy-stree (cdr entry))))
     initial)))

(defun org-texmacs--document-expand-tabs (string width)
  "Return a copy of STRING with tabs expanded at display columns of WIDTH."
  (unless (and (stringp string) (integerp width) (> width 0))
    (signal 'org-texmacs-document-error '("Invalid preformatted tab width")))
  (let ((column 0) output)
    (dotimes (index (length string))
      (let ((character (aref string index)))
        (cond
         ((= character ?\t)
          (let ((count (- width (% column width))))
            (dotimes (_ count) (push ?\s output))
            (setq column (+ column count))))
         ((= character ?\n)
          (push character output)
          (setq column 0))
         (t
          (push character output)
          (setq column (+ column (max 0 (char-width character))))))))
    (concat (nreverse output))))

(defun org-texmacs--document-preformatted (node width)
  "Lower prepared preformatted NODE using the fixed tab WIDTH."
  (let ((type (org-element-type node))
        (value (org-element-property :value node)))
    (unless (and (memq type '(example-block fixed-width src-block))
                 (stringp value) (null (org-element-contents node)))
      (org-texmacs--document-fail node "Invalid preformatted block"))
    (when (memq type '(example-block src-block))
      (let ((switches (org-element-property :switches node)))
        (unless (or (null switches)
                    (and (stringp switches)
                         (string-match-p "\\`[ \t]*-i[ \t]*\\'" switches)))
          (org-texmacs--document-fail node "Unsupported code block switches")))
      (when (and (eq type 'src-block)
                 (org-element-property :parameters node))
        (org-texmacs--document-fail node "Unsupported source block parameters")))
    (setq value
          (substring-no-properties
           (if (and (memq type '(example-block src-block))
                    (org-element-property :preserve-indent node))
               value
             (let ((tab-width width))
               (org-remove-indentation value)))))
    ;; Org block values have one syntactic final newline; it is not a code line.
    (when (and (> (length value) 0)
               (= (aref value (1- (length value))) ?\n))
      (setq value (substring value 0 -1)))
    (setq value (org-texmacs--document-expand-tabs value width))
    (org-texmacs--document-pack
     'code
     (list
      (org-texmacs--document-pack
       'document
       (mapcar (lambda (line) (org-texmacs--document-create :body line))
               (or (split-string value "\n" nil) '(""))))))))

(defun org-texmacs--document-table-alignment (contents)
  "Extract at most one complete alignment row from validated CONTENTS.
Return (ROWS ALIGNMENTS FORMAT-ROW), keeping ROWS in source order.
ALIGNMENTS is nil or a list of column strings l, c or r.  FORMAT-ROW is the
removed row identity or nil.  Never mutate the Org AST."
  (let ((case-fold-search nil) rows alignment format-row)
    (dolist (row contents)
      (if (eq (org-element-property :type row) 'rule)
          (push row rows)
        (let* ((fields
                (mapcar
                 (lambda (cell)
                   (let ((values (org-element-contents cell)))
                     (when (and (proper-list-p values) (cl-every #'stringp values))
                       (string-trim (apply #'concat values)))))
                 (org-element-contents row)))
               (control
                (or (org-export-table-row-is-special-p row nil)
                    (cl-some
                     (lambda (text)
                       (and text (string-match-p
                                  "\\`<\\(?:[lcr][0-9]*\\|[0-9]+\\)>\\'" text)))
                     fields))))
          (if (not control)
              (push row rows)
            (unless (cl-every (lambda (text) (member text '("<l>" "<c>" "<r>")))
                              fields)
              (org-texmacs--document-fail row "Unsupported table control row"))
            (when alignment
              (org-texmacs--document-fail row "Multiple table alignment rows"))
            (setq alignment (mapcar (lambda (text) (substring text 1 2)) fields)
                  format-row row)))))
    (list (nreverse rows) alignment format-row)))

(defun org-texmacs--document-pack (tag parts)
  "Wrap lowered PARTS in TAG, prefixing provenance paths by child index."
  (let ((index 0) (children nil) (paths nil) (file-paths nil))
    (dolist (part parts)
      (push (org-texmacs-document-body part) children)
      (dolist (path (org-texmacs-document-stm-paths part))
        (push (cons index path) paths))
      (dolist (path (org-texmacs-document-file-paths part))
        (push (cons index path) file-paths))
      (setq index (1+ index)))
    (org-texmacs--document-create
     :body (cons tag (nreverse children)) :stm-paths (nreverse paths)
     :file-paths (nreverse file-paths))))

(defun org-texmacs--document-handle-special (handler node contents info)
  "Call HANDLER for NODE with CONTENTS and INFO, preserving provenance."
  (let* ((body (org-texmacs-document-body contents))
         (owned (make-hash-table :test #'eq)) checks found prefix)
    ;; Remember original edges, not just equal values.  A callback can replace
    ;; equal children, or introduce cycles; checks must not traverse that graph.
    (cl-labels
        ((remember (value)
           (unless (gethash value owned)
             (when (or (consp value) (stringp value))
               (puthash value t owned)
               (if (stringp value)
                   (let ((saved (copy-sequence value)))
                     (push (lambda () (equal-including-properties value saved)) checks))
                 (let ((left (car value)) (right (cdr value)))
                   (push (lambda () (and (eq left (car value))
                                        (eq right (cdr value)))) checks)
                   (remember left) (remember right))))))
         (visit (value path ancestors)
           (cond
            ((eq value body)
             (setq found (1+ (or found 0)) prefix path))
            ((gethash value owned)
             (org-texmacs--document-fail node "Handler shares a contents descendant"))
            ((stringp value))
            ((and (consp value) (car value) (symbolp (car value))
                  (proper-list-p value) (not (memq value ancestors)))
             (let ((tail (cdr value)) (index 0))
               (while tail
                 (when (gethash tail owned)
                   (org-texmacs--document-fail node "Handler shares contents list structure"))
                 (visit (car tail) (append path (list index)) (cons value ancestors))
                 (setq tail (cdr tail) index (1+ index)))))
            (t (org-texmacs--document-fail node "Invalid or cyclic handler stree")))))
      (remember body)
      (let ((output (funcall handler node body info)))
        (unless (cl-every #'funcall checks)
          (org-texmacs--document-fail node "Handler modified contents"))
        (visit output nil nil)
        (unless (eq found 1)
          (org-texmacs--document-fail node "Handler must retain contents exactly once"))
        (org-texmacs--document-create
         :body (org-texmacs--document-copy-stree output)
         :stm-paths (mapcar (lambda (path) (append prefix path))
                            (org-texmacs-document-stm-paths contents))
         :file-paths (mapcar (lambda (path) (append prefix path))
                             (org-texmacs-document-file-paths contents)))))))

(defun org-texmacs--document-statement-prefix (contents prefix)
  "Insert packed PREFIX into document CONTENTS without rewriting STM roots.
Wrap a first concat with surround.  Otherwise prepend a separate paragraph."
  (let* ((body (org-texmacs-document-body contents))
         (first (cadr body))
         (wrap (and (consp first) (eq (car first) 'concat)))
         (prefix-body (org-texmacs-document-body prefix)))
    (org-texmacs--document-create
     :body (if wrap (cons 'document (cons (list 'surround prefix-body "" first) (cddr body)))
             (cons 'document (cons prefix-body (cdr body))))
     :stm-paths (mapcar (lambda (path)
                         (if wrap (if (zerop (car path)) (append '(0 2) (cdr path)) path)
                           (cons (1+ (car path)) (cdr path))))
                       (org-texmacs-document-stm-paths contents))
     :file-paths (append
                  (mapcar (lambda (path) (append (if wrap '(0 0) '(0)) path))
                          (org-texmacs-document-file-paths prefix))
                  (mapcar (lambda (path)
                            (if wrap (if (zerop (car path)) (append '(0 2) (cdr path)) path)
                              (cons (1+ (car path)) (cdr path))))
                          (org-texmacs-document-file-paths contents))))))

(defun org-texmacs--document-lower
    (ast &optional islands post-blanks info style initial source-file resource-base bibliography frozen-resolution)
  "Lower prepared Org AST and ISLANDS to a structural document result.

AST must be an `org-data' snapshot.  ISLANDS is an identity-keyed alist
of (NODE . STREE): NODE is a complete TeXmacs special block or a standalone
plain-text child of a paragraph or inline footnote body.  A preparation
layer must split text at fragment boundaries and mask foreign markup before
constructing this input.
This function never discovers or parses fragments.  Every mapping must be
consumed exactly once; each mapped root contributes one output child.
INFO fixes metadata, headline/TOC output policies and formatter for this
conversion.
When omitted, use fixed default policies and the default formatter, without
reading dynamic export settings.  Custom formatters should be side-effect-free.
STYLE is a nonempty list of TeXmacs style identifiers, defaulting to
`(\"generic\")'.  INITIAL is an alist of TeXmacs environment identifiers to
source-semantic text strees.  They are copied into the returned result and do
not affect BODY lowering or its STM paths.
SOURCE-FILE and RESOURCE-BASE are explicit source location strings, or nil.
Copy them into the result without expanding paths or accessing the filesystem.

POST-BLANKS optionally maps inline Org object identities to their original
trailing spaces/tabs.  Without an entry, use the nonnegative `:post-blank'
count.  Both inputs have prose whitespace semantics, not source fidelity.

Support paragraphs, plain text, basic emphasis, inline code/verbatim,
explicit line breaks, self-contained URI links, transparent Org sections,
same-document headline/ID and dedicated-target links resolved from AST,
plain local body file links with raw target paths and file provenance,
relative headline levels one through five, lower-level headline lists, all
three Org plain-list types, quote/center blocks, and static example,
fixed-width and source blocks, plus basic rectangular Org tables.  Emit
supported title, author and date metadata as body `doc-data'.  When enabled,
emit a static table of contents with generated internal targets.
Link admission uses Org type, not raw source.  Accept paragraph footnote
references with anonymous inline or named inline/separate definitions.
Emit named bodies once at first use and share labels for repeated references.
Caption contexts also accept anonymous inline footnote ASTs, including their
existing native layout limitations; no caption STM discovery is performed.
Reject nested footnotes, list checkboxes and
explicit counters; description terms use the existing inline subset.
Collapse ordinary spaces, tabs and soft newlines across Org inline text
boundaries.  Suppress leading whitespace at paragraph/title starts and after
explicit breaks; a final whitespace run remains one space.  Inline code is
literal, not preformatted.  Never normalize STM islands, merge adjacent
strings or flatten island strees.  Reject unsupported nodes and semantics.
An ordinary paragraph or inline footnote body containing exactly one island
and otherwise only ASCII prose whitespace emits that island directly.
Other paragraphs retain concat; known display-math roots cannot be mixed
into them.  Leading list paragraphs retain their marker/concat and reject
display roots even when otherwise bare.

Return a fresh result with STM root paths, retaining no Org properties or
source objects.  Do not read or modify source/caller buffers, encode text,
start a worker, or change AST/ISLANDS.  The caller must prepare all inputs
from one snapshot.
Ordinary special blocks recursively lower into a body document and an explicit
statement environment or captured private handler.  Built-in dispatch also
handles raw equations and explicit figure/table wrappers.  Object-specific
NAME/CAPTION rules retain original STM subtrees.  INFO's custom handler registry
defaults to empty, never the dynamic registry.  Custom handlers are skipped
when private preflight INFO is set; that temporary result is not a document
for consumers.  Final handlers must preserve contents identity and provenance."
  (unless (and (consp ast) (eq (org-element-type ast) 'org-data))
    (signal 'org-texmacs-document-error '("Expected an Org document AST")))
  (dolist (mapping (list islands post-blanks))
    (unless (proper-list-p mapping)
      (signal 'org-texmacs-document-error '("Expected a proper mapping alist")))
    (let ((keys nil))
      (dolist (entry mapping)
        (unless (and (consp entry) (or (stringp (car entry)) (consp (car entry)))
                     (not (memq (car entry) keys)))
          (signal 'org-texmacs-document-error '("Invalid or duplicate mapping key")))
        (push (car entry) keys))))
  (let* ((used-islands nil) (used-blanks nil)
        (style (org-texmacs--document-copy-style (or style '("generic"))))
        (initial (org-texmacs--document-copy-initial initial))
        (source-file (org-texmacs--source-copy-path source-file))
        (resource-base (org-texmacs--source-copy-path resource-base))
        (headline-minimum nil)
        (headline-limit nil)
        (toc-setting nil)
        (toc-depth nil)
        (toc-labels nil)
        (headline-numbering nil)
        (headline-title-parts nil)
        (headline-alt-parts nil)
        (preformatted-tab-width nil)
        (headline-formatter nil)
        (date-formatter nil)
        (special-handlers nil)
        (static-labels (org-texmacs--document-static-labels islands))
        (info (or info '(:with-todo-keywords t :with-priority nil :with-tags t
                        :texmacs-format-headline-function
                        org-texmacs-format-headline-default-function)))
        (resolution (or frozen-resolution
                        (and (plist-get info :texmacs-special-block-preflight)
                             (org-texmacs--document-resolve ast islands static-labels resource-base))
                        (signal 'org-texmacs-document-error '("Missing frozen resolution"))))
        (citation-plan nil))
    (when (org-texmacs-resolution-failure resolution)
      (signal 'org-texmacs-document-error (org-texmacs-resolution-failure resolution)))
    (setq citation-plan (org-texmacs--bibliography-plan
                         ast islands info bibliography resolution static-labels))
    (setq special-handlers
          (org-texmacs--document-copy-handlers
           (plist-get info :texmacs-special-block-handlers)))
    (setq headline-limit
          (if (memq :headline-levels info) (plist-get info :headline-levels) 3)
          preformatted-tab-width
          (if (memq :texmacs-tab-width info) (plist-get info :texmacs-tab-width) 8)
          headline-formatter
          (if (memq :texmacs-format-headline-function info)
              (plist-get info :texmacs-format-headline-function)
            #'org-texmacs-format-headline-default-function)
          date-formatter
          (if (memq :texmacs-date-timestamp-text-function info)
              (plist-get info :texmacs-date-timestamp-text-function)
            (indirect-function 'org-texmacs--document-date-timestamp-text))
          toc-setting
          (and (memq :with-toc info) (plist-get info :with-toc)))
    (unless (and (wholenump headline-limit) (<= headline-limit 5)
                 (integerp preformatted-tab-width) (> preformatted-tab-width 0)
                 (let ((value (if (memq :section-numbers info)
                                  (plist-get info :section-numbers) t)))
                   (or (memq value '(nil t)) (wholenump value)))
                 (or (memq toc-setting '(nil t)) (wholenump toc-setting))
                 (functionp headline-formatter) (functionp date-formatter))
      (signal 'org-texmacs-document-error '("Invalid headline lowering options")))
    (setq toc-depth
          (cond ((eq toc-setting t) headline-limit)
                ((wholenump toc-setting) (min toc-setting headline-limit))))
    (cl-labels ((minimum (node ancestors)
                  (unless (assq node islands)
                    (when (consp node)
                      (when (memq node ancestors)
                        (org-texmacs--document-fail node "Cyclic Org AST"))
                      (when (eq (org-element-type node) 'headline)
                        (let ((level (org-element-property :level node)))
                          (when (and (integerp level) (> level 0)
                                     (or (null headline-minimum)
                                         (< level headline-minimum)))
                            (setq headline-minimum level))))
                      (let ((ancestors (cons node ancestors)))
                        (mapc (lambda (child) (minimum child ancestors))
                              (org-element-contents node)))))))
      (minimum ast nil))
    (when toc-depth
      (let ((counters (make-vector 5 0))
            (reserved static-labels)
            (next-label 1))
        (cl-labels
            ((new-label ()
               (let (candidate)
                 (while
                     (progn
                       (setq candidate
                             (concat org-texmacs--document-toc-label-prefix
                                     (number-to-string next-label))
                             next-label (1+ next-label))
                       (member candidate reserved)))
                 (push candidate reserved)
                 candidate))
             (walk (node ancestors)
               (unless (assq node islands)
                 (when (consp node)
                   (when (memq node ancestors)
                     (org-texmacs--document-fail node "Cyclic Org AST"))
                   (when (eq (org-element-type node) 'headline)
                     (let* ((level (org-element-property :level node))
                            (relative
                             (and (integerp level) headline-minimum
                                  (1+ (- level headline-minimum))))
                            (unnumbered
                             (org-texmacs--document-unnumbered-value node)))
                       (unless (and (integerp relative) (> relative 0))
                         (org-texmacs--document-fail node "Invalid headline level"))
                       (when (<= relative headline-limit)
                         (when (org-texmacs--document-numbered-headline-p
                                node relative info)
                           (let ((index (1- relative)))
                             (aset counters index (1+ (aref counters index)))
                             (cl-loop for deeper from relative below 5
                                      do (aset counters deeper 0))
                             (push
                              (cons node
                                    (cl-loop for index below relative
                                             collect (aref counters index)))
                              headline-numbering)))
                         (when (and (<= relative toc-depth)
                                    (not (equal unnumbered "notoc")))
                           (push (cons node (new-label)) toc-labels)))))
                   (let ((ancestors (cons node ancestors)))
                     (mapc (lambda (child) (walk child ancestors))
                           (org-element-contents node)))))))
          (walk ast nil))
        (setq toc-labels (nreverse toc-labels)
              headline-numbering (nreverse headline-numbering))))
    (cl-labels
        ((text (string space)
           (let ((value (replace-regexp-in-string
                         "[ \t\r\n]+" " " (substring-no-properties string))))
             (when (and (car space) (> (length value) 0) (= (aref value 0) ?\s))
               (setq value (substring value 1)))
             (when (> (length value) 0)
               (setcar space (= (aref value (1- (length value))) ?\s)))
             (org-texmacs--document-create :body value)))
         (island (node entry)
           (when (memq entry used-islands)
             (org-texmacs--document-fail node "Island occurs more than once"))
           (push entry used-islands)
           (org-texmacs--document-create
            :body (org-texmacs--document-copy-stree (cdr entry))
            :stm-paths (list nil)))
         (blank (node space)
           (let ((entry (assq node post-blanks))
                 (count (or (org-element-property :post-blank node) 0)))
             (unless (and (integerp count) (>= count 0))
               (org-texmacs--document-fail node "Invalid inline post-blank"))
             (let ((value (if entry (cdr entry) (make-string count ?\s))))
               (unless (and (stringp value) (string-match-p "\\`[ \t]*\\'" value))
                 (org-texmacs--document-fail node "Expected trailing spaces or tabs"))
               (when entry
                 (when (memq entry used-blanks)
                   (org-texmacs--document-fail node "Whitespace mapping reused"))
                 (push entry used-blanks))
               (unless (equal value "") (list (text value space))))))
         (inline (node context ancestors space)
           (let ((entry (assq node islands)))
             (cond
              (entry
               (unless (and (stringp node) (memq context '(paragraph footnote)))
                 (org-texmacs--document-fail node "Island outside paragraph or footnote text"))
               ;; An island is opaque, even if its root is an atomic string.
               (setcar space nil)
               (list (island node entry)))
              ((stringp node) (list (text node space)))
              ((and (consp node)
                    (assq (org-element-type node) org-texmacs--document-markup-tags))
               (when (memq node ancestors)
                 (org-texmacs--document-fail node "Cyclic Org AST"))
               (let* ((ancestors (cons node ancestors))
                      (type (org-element-type node))
                      (parts (inlines (org-element-contents node) type ancestors space))
                      ;; Native markup macros take exactly one body argument.
                      (body (cond ((null parts)
                                   (org-texmacs--document-create :body ""))
                                  ((null (cdr parts)) (car parts))
                                  (t (org-texmacs--document-pack 'concat parts)))))
                 (cons (org-texmacs--document-pack
                        (cdr (assq type org-texmacs--document-markup-tags))
                        (list body))
                       (blank node space))))
              ((and (consp node) (eq (org-element-type node) 'footnote-reference))
               (unless (and (or (eq context 'paragraph)
                                (and (eq context 'caption)
                                     (eq (org-element-property :type node) 'inline)
                                     (null (org-element-property :label node))))
                            (memq (org-element-property :type node) '(inline standard))
                            (not (cl-some
                                  (lambda (ancestor)
                                    (and (consp ancestor)
                                         (memq (org-element-type ancestor)
                                               '(footnote-definition footnote-reference))))
                                  ancestors))
                            (not (memq node ancestors)))
                 (org-texmacs--document-fail node "Unsupported footnote context or type"))
               (let* ((note (cdr (assq node (org-texmacs-resolution-footnotes resolution))))
                      (definition (if note (nth 1 note) node))
                      (anchor (and note (nth 2 note)))
                      (first (or (null note) (eq node (car note)))))
                 (when (and (null note)
                            (or (org-element-property :label node)
                                (not (eq (org-element-property :type node) 'inline))))
                   (org-texmacs--document-fail node "Unresolved footnote reference"))
                 (setcar space nil)
                 (cons
                  (if (not first)
                      (org-texmacs--document-pack
                       'rsup
                       (list (org-texmacs--document-pack
                              'with
                              (list (org-texmacs--document-create :body "font-shape")
                                    (org-texmacs--document-create :body "right")
                                    (org-texmacs--document-pack
                                     'reference
                                     (list (org-texmacs--document-create :body anchor)))))))
                    (let* ((body
                            (if (eq (org-element-type definition) 'footnote-definition)
                                (org-texmacs--document-pack
                                 'document
                                 (blocks (org-element-contents definition)
                                         'footnote-definition (cons definition ancestors)))
                              (org-texmacs--document-pack
                               'document
                               (list (paragraph definition (cons definition ancestors)
                                                nil 'footnote)))))
                           (labelled
                            (if anchor
                                (org-texmacs--document-pack
                                 'surround
                                 (list (org-texmacs--document-pack
                                        'label (list (org-texmacs--document-create :body anchor)))
                                       (org-texmacs--document-create :body "") body))
                              body)))
                      (org-texmacs--document-pack 'footnote (list labelled))))
                       (blank node space))))
              ((and (consp node) (eq (org-element-type node) 'citation))
               (unless (memq context '(paragraph footnote))
                 (org-texmacs--document-fail node "Unsupported citation context"))
               (unless (assq node (plist-get citation-plan :citations))
                 (org-texmacs--document-fail node "Unprepared citation"))
               (setcar space nil)
               (cons (org-texmacs--document-pack
                      'with-bib
                      (list (org-texmacs--document-create :body (plist-get citation-plan :prefix))
                            (org-texmacs--document-pack
                             'cite (mapcar (lambda (key) (org-texmacs--document-create :body key))
                                           (cdr (assq node (plist-get citation-plan :citations)))))))
                     (blank node space)))
              ((and (consp node) (eq (org-element-type node) 'timestamp))
               (let ((raw (org-element-property :raw-value node)))
                 (unless (and (eq context 'date) (stringp raw) (> (length raw) 0)
                              (not (memq node ancestors))
                              (null (org-element-contents node)))
                   (org-texmacs--document-fail node "Invalid or unsupported metadata timestamp"))
                 ;; Preserve the full literal, including delimiters and spaces.
                 ;; Advice sees no source-owned or prepared-input-owned string.
                 (let ((value (funcall date-formatter (substring-no-properties raw))))
                   (unless (stringp value)
                     (org-texmacs--document-fail node "Date timestamp conversion must return text"))
                   (when (> (length value) 0)
                     (setcar space (memq (aref value (1- (length value)))
                                         '(?\s ?\t ?\r ?\n))))
                   (cons (org-texmacs--document-create
                          :body (substring-no-properties value))
                         (blank node space)))))
              ((and (consp node) (eq (org-element-type node) 'link))
               (when (memq node ancestors)
                 (org-texmacs--document-fail node "Cyclic Org AST"))
               (let ((type (org-element-property :type node))
                     (path (org-element-property :path node))
                     (file (cdr (assq node (org-texmacs-resolution-files resolution))))
                     (reference (cdr (assq node
                                           (org-texmacs-resolution-links resolution)))))
                 (unless (and (stringp type) (stringp path)
                              (or reference file
                                  (member (downcase type)
                                          org-texmacs--supported-link-types)))
                   (org-texmacs--document-fail node "Unsupported link type or path"))
                 (when (and file (cadr space))
                   (org-texmacs--document-fail node "Unsupported file link in title or metadata"))
                 (let* ((uri (and (not reference)
                                  (or file
                                      (concat (substring-no-properties type) ":"
                                              (substring-no-properties path)))))
                        (parts (and (org-element-contents node)
                                    (inlines (org-element-contents node) 'link
                                             (cons node ancestors) space)))
                        (body (cond ((null parts)
                                     (setcar space nil)
                                     (and uri
                                          (org-texmacs--document-create
                                           :body (copy-sequence uri))))
                                    ((null (cdr parts)) (car parts))
                                    (t (org-texmacs--document-pack 'concat parts)))))
                   (cons (if file
                             (let ((result (org-texmacs--document-pack
                                            'hlink
                                            (list body
                                                  (org-texmacs--document-create :body file)))))
                               (org-texmacs--document-create
                                :body (org-texmacs-document-body result)
                                :stm-paths (org-texmacs-document-stm-paths result)
                                :file-paths (append (org-texmacs-document-file-paths result)
                                                    (list (list 1)))))
                           (if (and reference (null parts))
                             (org-texmacs--document-pack
                              'reference
                              (list (org-texmacs--document-create :body reference)))
                           (org-texmacs--document-pack
                            'hlink
                            (list body
                                  (org-texmacs--document-create
                                   :body (if reference (concat "#" reference) uri))))))
                         (blank node space)))))
              ((and (consp node) (eq (org-element-type node) 'target))
               (unless (eq context 'paragraph)
                 (org-texmacs--document-fail node "Unsupported target context"))
               (let ((label (cdr (assq node
                                       (org-texmacs-resolution-labels resolution)))))
                 (cons (if label
                           (org-texmacs--document-pack
                            'label (list (org-texmacs--document-create :body label)))
                         (org-texmacs--document-create :body ""))
                       (blank node space))))
              ((and (consp node) (memq (org-element-type node) '(code verbatim)))
               (let ((value (org-element-property :value node)))
                 (unless (and (stringp value) (null (org-element-contents node)))
                   (org-texmacs--document-fail node "Invalid literal inline node"))
                 (cons (org-texmacs--document-pack 'verbatim (list (text value space)))
                       (blank node space))))
              ((and (consp node) (eq (org-element-type node) 'line-break))
               (when (or (cadr space)
                         (org-element-contents node))
                 (org-texmacs--document-fail node "Unsupported line break context"))
               (setcar space t)
               (cons (org-texmacs--document-pack 'next-line nil) (blank node space)))
              (t (org-texmacs--document-fail node "Unsupported inline node")))))
         (inlines (nodes context ancestors &optional space)
           (unless (proper-list-p nodes)
             (signal 'org-texmacs-document-error '("Invalid inline contents")))
           ;; Share whitespace state through formatting, but not across blocks.
           ;; The second slot rejects explicit breaks in heading/metadata text.
           (let ((space (or space (list t (memq context '(title toc-title author date))))))
             (apply #'append
                    (mapcar (lambda (node) (inline node context ancestors space)) nodes))))
         (one-body (parts)
           (cond
            ((null parts) (org-texmacs--document-create :body ""))
            ((null (cdr parts)) (car parts))
            (t (org-texmacs--document-pack 'concat parts))))
         (paragraph (node ancestors &optional marker context)
           (let ((contents (org-element-contents node)) bare other)
             (unless (proper-list-p contents)
               (org-texmacs--document-fail node "Invalid paragraph contents"))
             ;; Test source identities before whitespace: an opaque island may
             ;; itself lower to an empty or whitespace-only atomic string.
             (dolist (child contents)
               (cond
                ((and (stringp child) (assq child islands))
                 (if bare (setq other t) (setq bare child)))
                ((and (stringp child) (string-match-p "\\`[ \t\r\n]*\\'" child)))
                (t (setq other t))))
             (if (and bare (not other) (not marker))
                 (island bare (assq bare islands))
               (dolist (child contents)
                 (let ((entry (and (stringp child) (assq child islands))))
                   (when (and entry (consp (cdr entry))
                              (memq (cadr entry) org-texmacs--document-display-math-tags))
                     (org-texmacs--document-fail
                      node "Display STM requires a standalone paragraph or TeXmacs block"))))
               (let ((parts (inlines contents (or context 'paragraph) ancestors)))
                 (org-texmacs--document-pack
                  'concat (append (and marker (list marker))
                                  (or parts
                                      (and (eq context 'footnote)
                                           (list (org-texmacs--document-create
                                                  :body ""))))))))))
         (metadata-field (tag nodes context ancestors)
           (unless (proper-list-p nodes)
             (signal 'org-texmacs-document-error '("Invalid parsed document metadata")))
           (let ((parts (inlines nodes context ancestors)))
             (unless parts
               (signal 'org-texmacs-document-error '("Empty document metadata")))
             (org-texmacs--document-pack tag (list (one-body parts)))))
         (metadata (ancestors)
           (let ((present
                  (if (memq :texmacs-metadata-present info)
                      (plist-get info :texmacs-metadata-present)
                    (or (plist-get info :title) (plist-get info :author)
                        (plist-get info :date))))
                 parts)
             (when present
               (when (and (if (memq :with-title info) (plist-get info :with-title) t)
                          (plist-get info :title))
                 (push (metadata-field 'doc-title (plist-get info :title)
                                       'title ancestors)
                       parts))
               (when (and (if (memq :with-author info) (plist-get info :with-author) t)
                          (plist-get info :author))
                 (push
                  (org-texmacs--document-pack
                   'doc-author
                   (list
                    (org-texmacs--document-pack
                     'author-data
                     (list
                      (metadata-field 'author-name (plist-get info :author)
                                      'author ancestors)))))
                  parts))
               (when (and (if (memq :with-date info) (plist-get info :with-date) t)
                          (plist-get info :date))
                 (push (metadata-field 'doc-date (plist-get info :date)
                                       'date ancestors)
                       parts)))
             (and parts
                  (list (org-texmacs--document-pack 'doc-data (nreverse parts))))))
         (relative-level (node)
           (let ((level (org-element-property :level node)))
             (unless (and headline-minimum (integerp level) (> level 0))
               (org-texmacs--document-fail node "Invalid headline level"))
             (1+ (- level headline-minimum))))
         (low-headline-p (node)
           (and (consp node) (eq (org-element-type node) 'headline)
                (> (relative-level node) headline-limit)))
         (headline-parts (node toc ancestors)
           (let ((raw (org-element-property :raw-value node)))
             (unless (and (stringp raw) (string-match-p "[^ \t\r\n]" raw))
               (org-texmacs--document-fail node "Empty headline title"))
             (when (org-element-property :commentedp node)
               (org-texmacs--document-fail node "Unsupported headline metadata"))
             (let* ((has-alt
                     (and toc
                          (or (memq :ALT_TITLE (org-element-property :secondary node))
                              (org-element-property :ALT_TITLE node))))
                    (cache (if has-alt headline-alt-parts headline-title-parts))
                    (entry (assq node cache)))
               (if entry (cdr entry)
                 (let* ((nodes (if has-alt
                                   (org-element-property :ALT_TITLE node)
                                 (org-element-property :title node)))
                        (parts
                         (and (proper-list-p nodes)
                              (inlines nodes (if has-alt 'toc-title 'title)
                                       ancestors))))
                   (unless parts
                     (org-texmacs--document-fail
                      node (if has-alt "Empty or invalid ALT_TITLE"
                             "Empty headline title")))
                   (if has-alt
                       (push (cons node parts) headline-alt-parts)
                     (push (cons node parts) headline-title-parts))
                   parts)))))
         (headline-title (node ancestors &optional toc)
           (let* ((parts (headline-parts node toc ancestors))
                  (todo (and (plist-get info :with-todo-keywords)
                             (org-element-property :todo-keyword node))))
             (org-texmacs--document-create
              :body
              (org-texmacs--document-copy-stree
               (funcall headline-formatter
                        (and todo (substring-no-properties todo))
                        (and todo (org-element-property :todo-type node))
                        (and (plist-get info :with-priority)
                             (org-element-property :priority node))
                        (mapcar #'org-texmacs-document-body parts)
                        (and (if toc (eq (plist-get info :with-tags) t)
                               (plist-get info :with-tags))
                             (mapcar #'substring-no-properties
                                     (org-element-property :tags node)))
                        info)))))
         (toc-entry (mapping ancestors)
           (let* ((node (car mapping))
                  (label (cdr mapping))
                  (relative (relative-level node))
                  (tag (nth (1- relative) org-texmacs--document-toc-tags))
                  (number (cdr (assq node headline-numbering)))
                  (title (headline-title node (cons node ancestors) t))
                  (left
                   (one-body
                    (append
                     (and number
                          (list
                           (org-texmacs--document-create
                            :body
                            (concat (mapconcat #'number-to-string number ".") " "))))
                     (list title)))))
             (unless tag
               (org-texmacs--document-fail node "Unsupported TOC headline level"))
             (org-texmacs--document-pack
              tag
              (list
               (org-texmacs--document-pack
                'hlink
                (list left
                      (org-texmacs--document-create :body (concat "#" label))))
               (org-texmacs--document-pack
                'pageref (list (org-texmacs--document-create :body label)))))))
         (toc (ancestors)
           (and toc-labels
                (list
                 (org-texmacs--document-pack
                  'table-of-contents
                  (list
                   (org-texmacs--document-create :body "org-texmacs-toc")
                   (org-texmacs--document-pack
                    'document
                    (mapcar (lambda (mapping) (toc-entry mapping ancestors))
                            toc-labels)))))))
         (target-labels (node)
           (delq nil
                 (mapcar
                  (lambda (name)
                    (and name
                         (org-texmacs--document-pack
                          'label (list (org-texmacs--document-create :body name)))))
                  (list (cdr (assq node toc-labels))
                        (cdr (assq node
                                   (org-texmacs-resolution-labels resolution)))))))
         (low-headline-item (node context ancestors)
           (unless (and (consp node) (not (memq node ancestors))
                        (memq context '(org-data headline)))
             (org-texmacs--document-fail node "Unexpected low-level headline"))
           (let ((ancestors (cons node ancestors)))
             (check-affiliated node)
             (append
              (list
               (org-texmacs--document-pack
                'concat
                (list (org-texmacs--document-pack 'item nil)
                      (headline-title node ancestors))))
              (target-labels node)
              (blocks (org-element-contents node) 'headline ancestors))))
         (blocks (nodes context ancestors)
           (unless (proper-list-p nodes)
             (signal 'org-texmacs-document-error '("Invalid block contents")))
           (let (result)
             (while nodes
               (if (low-headline-p (car nodes))
                   (let (headlines)
                     (while (and nodes (low-headline-p (car nodes)))
                       (push (pop nodes) headlines))
                     (setq headlines (nreverse headlines))
                     (setq result
                           (nconc
                            result
                            (list
                             (org-texmacs--document-pack
                              'itemize
                              (list
                               (org-texmacs--document-pack
                                'document
                                (apply #'append
                                       (mapcar
                                        (lambda (node)
                                          (low-headline-item node context ancestors))
                                        headlines)))))))))
                 (setq result (nconc result (block (pop nodes) context ancestors)))))
             result))
         (check-affiliated (node &optional inner)
           (let ((begin (org-element-property :begin node))
                 (post (org-element-property :post-affiliated node))
                 (keys (org-element-property :texmacs-affiliated-keywords node))
                 (table (and (not inner) (eq (org-element-type node) 'table)))
                 (wrapper (and (not inner) (org-texmacs--figure-table-kind node)))
                 (named (and (not inner) (org-texmacs--document-named-block-p node)))
                 (statement (and (not inner) (eq (org-element-type node) 'special-block)
                                 (org-texmacs--document-statement-tag node))))
             (when statement (org-texmacs--document-statement-caption node))
             (when (and (integerp begin) (integerp post) (> post begin)
                        (not (and (or table named) keys)))
               (org-texmacs--document-fail node "Unsupported affiliated metadata"))
             (when-let* ((proof (org-element-property :texmacs-name-source node)))
               (unless (equal proof
                              (list (list (org-element-property :type node) begin post
                                          (org-element-property :texmacs-source-end node))
                                    (org-element-property :name node) keys (nth 3 proof)))
                 (org-texmacs--document-fail node "Original NAME evidence differs")))
             (when (org-element-property :name node)
               (unless (and (stringp (org-element-property :name node))
                            (not (string-blank-p (org-element-property :name node))))
                 (org-texmacs--document-fail node "Invalid object NAME")))
             (when keys
               (unless (and (or table named) (proper-list-p keys)
                            (cl-every (lambda (key) (member key (if (or table wrapper statement)
                                                                 '("NAME" "CAPTION") '("NAME")))) keys)
                            (<= (cl-count "NAME" keys :test #'equal) 1)
                            (or (not (member "NAME" keys))
                                (let ((name (org-element-property :name node)))
                                  (and (stringp name) (> (length name) 0))))
                            (or (not (member "CAPTION" keys))
                                (org-element-property :caption node)))
                 (org-texmacs--document-fail node "Unsupported affiliated metadata")))
             (org-element-properties-mapc
              (lambda (key value _owner)
                (when (and value
                           (or (string-prefix-p ":attr_" (symbol-name key))
                               (and (eq (org-element-type node) 'table)
                                    (memq key '(:header :headers :results :resname :plot :label :data)))
                               (and (not (or table named)) (eq key :name))
                               (and (not (or table wrapper statement)) (eq key :caption))))
                  (org-texmacs--document-fail node "Unsupported affiliated metadata")))
              node)))
         (caption-long (node ancestors)
           (let (long)
             (dolist (line (org-texmacs--document-caption-lines node))
               (when long (push (org-texmacs--document-create :body " ") long))
               (push (one-body (inlines (car line) 'caption ancestors)) long))
             (one-body (nreverse long))))
         (caption-text (node ancestors)
           (let ((long (caption-long node ancestors)) short)
             (dolist (line (org-texmacs--document-caption-lines node))
               (when (cdr line)
                 (when short (push (org-texmacs--document-create :body " ") short))
                 (push (one-body (inlines (cdr line) 'caption ancestors)) short)))
             (if short
                 (org-texmacs--document-pack
                  'caption-detailed (list long
                                          (one-body (nreverse short))))
               long)))
         (table-caption (node ancestors)
           (let ((caption (caption-text node ancestors))
                 (label (cdr (assq node (org-texmacs-resolution-labels resolution)))))
             (if label
                 (org-texmacs--document-pack
                  'surround
                  (list (org-texmacs--document-pack
                         'label (list (org-texmacs--document-create :body label)))
                        (org-texmacs--document-create :body "") caption))
               caption)))
         (figure-table (node ancestors)
           (let* ((kind (org-texmacs--figure-table-kind node))
                  (children (cl-remove-if #'org-texmacs--figure-table-blank-p
                                          (org-element-contents node)))
                  (proof (org-element-property :texmacs-figure-table-source node))
                  (child (car children)))
             (unless (and (or (null (org-element-property :parameters node))
                              (and (stringp (org-element-property :parameters node))
                                   (string-match-p "\\`[ \t\r\n]*\\'"
                                                   (org-element-property :parameters node))))
                          (= (length children) 1)
                          (eq (org-element-parent child) node)
                          (or (org-texmacs--block-p child)
                              (and (memq kind '(table table*))
                                   (eq (org-element-type child) 'table))))
               (org-texmacs--document-fail node "Expected exactly one direct figure/table body"))
             (when proof
               (unless (and (proper-list-p proof) (= (length proof) 2)
                            (equal (car proof)
                                   (list kind (org-element-property :begin node)
                                         (org-element-property :post-affiliated node)
                                         (org-element-property :texmacs-source-end node)))
                            (equal (cadr proof)
                                   (mapcar #'org-texmacs--figure-table-node-shape children)))
                 (org-texmacs--document-fail node "Original figure/table structure differs")))
             (check-affiliated child t)
             (when (and (org-texmacs--block-p child)
                        (let ((parameters (org-element-property :parameters child)))
                          (not (or (null parameters)
                                   (and (stringp parameters)
                                        (string-match-p "\\`[ \t\r\n]*\\'" parameters))))))
               (org-texmacs--document-fail child "Inner native block parameters are unsupported"))
             (let* ((body (if (org-texmacs--block-p child)
                              (let ((entry (assq child islands)))
                                (unless entry
                                  (org-texmacs--document-fail child "Missing native figure/table body"))
                                (island child entry))
                            (table-block child (cons child ancestors))))
                    (body (if (and (memq kind '(table table*))
                                   (org-texmacs--block-p child)
                                   (not (plist-get info :texmacs-special-block-preflight)))
                              (org-texmacs--document-normalize-table body) body)))
               (org-texmacs--document-pack
                (intern (concat "big-" (symbol-name kind)))
                (list body (table-caption node ancestors))))))
         (table-cell (node ancestors)
           (unless (and (consp node) (eq (org-element-type node) 'table-cell)
                        (not (memq node ancestors))
                        (proper-list-p (org-element-contents node)))
             (org-texmacs--document-fail node "Invalid or cyclic table cell"))
           (org-texmacs--document-pack
            'cell
            (list
             (one-body
              (inlines (org-element-contents node) 'table-cell
                       (cons node ancestors))))))
         (table-rule (row property)
           (org-texmacs--document-pack
            'cwith
            (mapcar
             (lambda (value) (org-texmacs--document-create :body value))
             (list (format "%d" row) (format "%d" row) "1" "-1"
                   property "1ln"))))
         (table-block (node ancestors)
           (let ((contents (org-element-contents node)) alignment)
             (unless (and (eq (org-element-property :type node) 'org)
                          (null (org-element-property :tblfm node))
                          (proper-list-p contents) contents)
               (org-texmacs--document-fail node "Unsupported or invalid Org table"))
             ;; Validate ownership and shape before calling Org table predicates.
             (dolist (row contents)
               (unless (and (consp row) (eq (org-element-type row) 'table-row)
                            (eq (org-element-parent row) node)
                            (not (memq row ancestors)))
                 (org-texmacs--document-fail row "Invalid or cyclic table row"))
               (let ((type (org-element-property :type row))
                     (cells (org-element-contents row)))
                 (cond
                  ((eq type 'rule)
                   (unless (null cells)
                     (org-texmacs--document-fail row "Invalid table rule")))
                  ((eq type 'standard)
                   (unless (and (proper-list-p cells) cells
                                (cl-every
                                 (lambda (cell)
                                   (and (consp cell)
                                        (eq (org-element-type cell) 'table-cell)
                                        (eq (org-element-parent cell) row)
                                        (not (memq cell ancestors))))
                                 cells))
                     (org-texmacs--document-fail row "Invalid table row")))
                  (t (org-texmacs--document-fail row "Unsupported table row")))))
             (let* ((plan (org-texmacs--document-table-alignment contents))
                    (filtered (car plan))
                    (view node))
               (setq alignment (cadr plan))
               (when alignment
                 ;; A format row must not hide a special column.  Reparent only
                 ;; copied rows; prepared input and source identities stay intact.
                 (setq view (org-element-copy node t))
                 (apply #'org-element-set-contents view
                        (cl-loop for original in contents
                                 for copied in (org-element-contents view)
                                 unless (eq original (nth 2 plan)) collect copied)))
               (when (org-export-table-has-special-column-p view)
                 (org-texmacs--document-fail node "Unsupported special table column"))
               (setq contents filtered))
             (let ((columns nil) (row-number 0) (previous-rule nil)
                   rows rules)
               (dolist (row contents)
                 (if (eq (org-element-property :type row) 'rule)
                     (progn
                       (when previous-rule
                         (org-texmacs--document-fail row "Consecutive table rules"))
                       (push (table-rule (max 1 row-number)
                                         (if (zerop row-number)
                                             "cell-tborder"
                                           "cell-bborder"))
                             rules)
                       (setq previous-rule t))
                   (let ((cells (org-element-contents row)))
                     (when (org-export-table-row-is-special-p row nil)
                       (org-texmacs--document-fail row "Unsupported table control row"))
                     (if columns
                         (unless (= (length cells) columns)
                           (org-texmacs--document-fail row "Non-rectangular Org table"))
                       (setq columns (length cells)))
                     (push
                      (org-texmacs--document-pack
                       'row
                       (mapcar (lambda (cell)
                                 (table-cell cell (cons row ancestors)))
                               cells))
                      rows)
                     (cl-incf row-number)
                     (setq previous-rule nil))))
               (unless (> row-number 0)
                 (org-texmacs--document-fail node "Org table has no data rows"))
               (when (and alignment (/= (length alignment) columns))
                 (org-texmacs--document-fail node "Table alignment column count differs"))
               (org-texmacs--document-pack
                'tabular
                (list
                 (org-texmacs--document-pack
                  'tformat
                  (append
                   (cl-loop for value in alignment for column from 1
                            collect
                            (org-texmacs--document-pack
                             'cwith
                             (mapcar
                              (lambda (text) (org-texmacs--document-create :body text))
                              (list "1" "-1" (number-to-string column)
                                    (number-to-string column) "cell-halign" value))))
                   (nreverse rules)
                   (list
                    (org-texmacs--document-pack
                     'table (nreverse rows))))))))))
         (list-item (node kind ancestors)
           (when (or (org-element-property :checkbox node)
                     (org-element-property :counter node))
             (org-texmacs--document-fail node "Unsupported list checkbox or counter"))
           (let* ((tag (org-element-property :tag node))
                  (marker
                   (if (and (eq kind 'descriptive) tag)
                       (progn
                         (unless (proper-list-p tag)
                           (org-texmacs--document-fail node "Invalid description term"))
                         (let* ((parts (inlines tag 'description-tag ancestors))
                                (body (cond
                                       ((null parts)
                                        (org-texmacs--document-create :body ""))
                                       ((null (cdr parts)) (car parts))
                                       (t (org-texmacs--document-pack 'concat parts)))))
                           (org-texmacs--document-pack 'item* (list body))))
                     (org-texmacs--document-pack 'item nil)))
                  (contents (org-element-contents node))
                  (first (car contents)))
             (if (and first (org-element-type-p first 'paragraph))
                 (progn
                   (check-affiliated first)
                   (cons (paragraph first ancestors marker)
                         (blocks (cdr contents) 'item ancestors)))
               (cons marker (blocks contents 'item ancestors)))))
         (block (node context ancestors)
           (unless (and (consp node) (not (memq node ancestors)))
             (org-texmacs--document-fail node "Invalid or cyclic block node"))
           (let ((ancestors (cons node ancestors))
                 (type (org-element-type node))
                 (entry (assq node islands)))
             (check-affiliated node)
             (cond
              (entry
               (let ((kind (org-texmacs--native-body-kind node)))
                 (unless kind
                   (org-texmacs--document-fail node "Island key is not a native-body block"))
                 (org-texmacs--native-body-check node)
                 (let* ((body (island node entry))
                        (labels (target-labels node)))
                   (list (if (eq kind 'texmacs)
                             (if labels
                                 (org-texmacs--document-pack
                                  'surround (list (car labels) (org-texmacs--document-create :body "") body))
                               body)
                           (org-texmacs--document-pack
                            kind (list (if labels (org-texmacs--document-pack 'concat (append labels (list body)))
                                         body))))))))
              ((org-texmacs--native-body-kind node)
               (org-texmacs--document-fail node "Missing native-body island"))
              ((eq type 'section)
               (unless (memq context '(org-data headline))
                 (org-texmacs--document-fail node "Unexpected Org section"))
               (blocks (org-element-contents node) 'section ancestors))
              ((eq type 'footnote-definition) nil)
              ((and (eq type 'keyword)
                    (equal (upcase (org-element-property :key node)) "BIBLIOGRAPHY")) nil)
              ((and (eq type 'keyword)
                    (equal (upcase (org-element-property :key node)) "PRINT_BIBLIOGRAPHY"))
               (unless (memq context '(org-data section headline))
                 (org-texmacs--document-fail node "Unsupported bibliography print context"))
               (let ((output (plist-get info :texmacs-bibliography-output)))
                 (unless (and output
                              (equal (nth 0 output) (plist-get citation-plan :prefix))
                              (equal (nth 1 output) (plist-get citation-plan :keys))
                              (equal (nth 2 output) (plist-get citation-plan :entries)))
                   (org-texmacs--document-fail node "Missing or stale prepared bibliography output"))
                 (let ((body (org-texmacs--document-copy-stree (nth 3 output))))
                   (unless (and (consp body) (eq (car body) 'bib-list) (= (length body) 3)
                                (equal (sort (org-texmacs--bibliography-labels body) #'string-lessp)
                                       (sort (mapcar (lambda (key)
                                                       (concat (plist-get citation-plan :prefix) "-" key))
                                                     (plist-get citation-plan :keys)) #'string-lessp)))
                     (org-texmacs--document-fail node "Invalid prepared bibliography labels"))
                   (org-texmacs--bibliography-check-references body (nth 0 output))
                   (list (org-texmacs--document-create
                          :body (list 'with-bib (copy-sequence (nth 0 output)) body)
                          :stm-paths '((1)))))))
              ((eq type 'paragraph)
               (list (paragraph node ancestors)))
              ((org-texmacs--figure-table-kind node)
               (list (figure-table node ancestors)))
              ((eq type 'special-block)
               (let* ((tag (org-texmacs--document-statement-tag node))
                      (handler (and (not tag)
                                    (cdr (assoc (downcase (org-element-property :type node))
                                                special-handlers)))))
                 (unless (or tag handler)
                   (org-texmacs--document-fail node "Unsupported special-block type"))
                 (let ((contents (org-texmacs--document-pack
                                  'document
                                  (blocks (org-element-contents node) 'special-block ancestors))))
                   (list
                    (cond
                     (tag
                      (let* ((labels (target-labels node))
                             (caption (org-texmacs--document-statement-caption node))
                             (parts (append labels
                                            (when caption
                                              (list (org-texmacs--document-pack
                                                     'dueto (list (caption-long node ancestors))))))))
                        (org-texmacs--document-pack
                         tag (list (if parts
                                       (org-texmacs--document-statement-prefix
                                        contents (org-texmacs--document-pack 'concat parts))
                                     contents)))))
                     ((plist-get info :texmacs-special-block-preflight) contents)
                     (t (org-texmacs--document-handle-special handler node contents info)))))))
              ((memq type '(example-block fixed-width src-block))
               (unless (memq context
                             '(org-data section headline item quote-block center-block footnote-definition special-block))
                 (org-texmacs--document-fail node "Unexpected preformatted block"))
               (list (org-texmacs--document-preformatted
                      node preformatted-tab-width)))
              ((eq type 'table)
               (unless (memq context
                             '(org-data section headline item quote-block center-block footnote-definition special-block))
                 (org-texmacs--document-fail node "Unexpected Org table"))
               (let ((body (table-block node ancestors))
                     (label (cdr (assq node (org-texmacs-resolution-labels resolution)))))
                 (list
                  (if (org-element-property :caption node)
                      (org-texmacs--document-pack
                       'big-table (list body (table-caption node ancestors)))
                    (if label
                        (org-texmacs--document-pack
                         'surround
                         (list (org-texmacs--document-pack
                                'label (list (org-texmacs--document-create :body label)))
                               (org-texmacs--document-create :body "") body))
                      body)))))
              ((eq type 'plain-list)
               (unless (memq context
                             '(org-data section headline item quote-block center-block footnote-definition special-block))
                 (org-texmacs--document-fail node "Unexpected Org plain list"))
               (let* ((kind (org-element-property :type node))
                      (tag (cdr (assq kind org-texmacs--document-list-tags)))
                      (items (org-element-contents node)))
                 (unless (and tag (proper-list-p items) items
                              (cl-every (lambda (item)
                                          (org-element-type-p item 'item))
                                        items))
                   (org-texmacs--document-fail node "Invalid Org plain list"))
                 (list
                  (org-texmacs--document-pack
                   tag
                   (list
                    (org-texmacs--document-pack
                     'document (blocks items kind ancestors)))))))
              ((memq type '(quote-block center-block))
               (unless (memq context
                             '(org-data section headline item quote-block center-block footnote-definition special-block))
                 (org-texmacs--document-fail node "Unexpected Org container block"))
               (list
                (org-texmacs--document-pack
                 (if (eq type 'quote-block) 'quotation 'center)
                 (list
                  (org-texmacs--document-pack
                   'document (blocks (org-element-contents node) type ancestors))))))
              ((eq type 'item)
               (unless (memq context '(unordered ordered descriptive))
                 (org-texmacs--document-fail node "Unexpected Org list item"))
               (list-item node context ancestors))
              ((eq type 'headline)
               (unless (memq context '(org-data headline))
                 (org-texmacs--document-fail node "Unexpected headline"))
               (let* ((relative (relative-level node))
                      (tags (nth (1- relative) org-texmacs--document-section-tags))
                      (numbered
                       (org-texmacs--document-numbered-headline-p
                        node relative info))
                      (targets (target-labels node)))
                 (unless (and (<= relative headline-limit) tags)
                   (org-texmacs--document-fail node "Unsupported section headline"))
                 (cons (org-texmacs--document-pack
                        (if numbered (car tags) (cdr tags))
                        (list (headline-title node ancestors)))
                       (append targets
                               (blocks (org-element-contents node)
                                       'headline ancestors)))))
              (t (org-texmacs--document-fail node "Unsupported or unprepared block"))))))
      (let ((result (org-texmacs--document-pack
                     'document
                     (append (metadata (list ast))
                             (toc (list ast))
                             (blocks (org-element-contents ast) 'org-data (list ast))))))
        (unless (and (= (length used-islands) (length islands))
                     (= (length used-blanks) (length post-blanks)))
          (signal 'org-texmacs-document-error '("Unused preparation mappings")))
        (when frozen-resolution
          (let ((labels (org-texmacs--document-output-labels (org-texmacs-document-body result))))
            (dolist (entry (org-texmacs-resolution-labels frozen-resolution))
              (unless (= 1 (cl-count (cdr entry) labels :test #'equal))
                (org-texmacs--document-fail (car entry) "Missing or conflicting frozen label")))))
        (org-texmacs--document-create
         :body (org-texmacs-document-body result)
         :stm-paths (org-texmacs-document-stm-paths result)
         :file-paths (org-texmacs-document-file-paths result)
         :style style :initial initial
         :source-file source-file :resource-base resource-base)))))

(defun org-texmacs--document-heading-settings ()
  "Copy effective Org heading parser settings for transfer and comparison.
Keep TODO regexp, DONE keywords, odd-level policy and priority regexp.
Copy strings as well as lists so in-place edits invalidate the snapshot.
Capture `org-footnote-section' so special footnote headings use source policy.
Do not rebuild effective values from TODO declarations or file keywords."
  (unless (and (or (null org-todo-regexp) (stringp org-todo-regexp))
               (proper-list-p org-done-keywords)
               (cl-every #'stringp org-done-keywords)
               (stringp org-priority-regexp)
               (or (null org-footnote-section) (stringp org-footnote-section)))
    (signal 'org-texmacs-document-error '("Invalid Org heading settings")))
  (list (and org-todo-regexp (substring-no-properties org-todo-regexp))
        (mapcar #'substring-no-properties org-done-keywords)
        (and org-odd-levels-only t)
        (substring-no-properties org-priority-regexp)
        (and org-footnote-section (substring-no-properties org-footnote-section))))

(defun org-texmacs--document-use-heading-settings (settings)
  "Install copied heading SETTINGS in the private Org parser buffer.
Call after `org-mode' initialization and before parsing any source.  Keep
buffer-local copies separate from the caller's snapshot and source buffer."
  (setq-local org-todo-regexp
              (and (nth 0 settings) (substring-no-properties (nth 0 settings))))
  (setq-local org-done-keywords (mapcar #'substring-no-properties (nth 1 settings)))
  (setq-local org-odd-levels-only (nth 2 settings))
  (setq-local org-priority-regexp (substring-no-properties (nth 3 settings)))
  (setq-local org-footnote-section
              (and (nth 4 settings) (substring-no-properties (nth 4 settings)))))

(defun org-texmacs--document-copy-link-setting (value)
  "Copy parser setting VALUE, including mutable strings."
  (cond ((stringp value) (substring-no-properties value))
        ((consp value)
         (cons (org-texmacs--document-copy-link-setting (car value))
               (org-texmacs--document-copy-link-setting (cdr value))))
        (t value)))

(defun org-texmacs--document-link-settings ()
  "Snapshot effective link registration and abbreviation settings."
  (mapcar #'org-texmacs--document-copy-link-setting
          (list org-link-parameters org-link-abbrev-alist org-link-abbrev-alist-local)))

(defun org-texmacs--document-prepare-source
    (source tags headings links info &optional subtree-position region restriction
            filter)
  "Prepare SOURCE under private Org link syntax using fixed LINKS settings.
TAGS and HEADINGS are the conversion's other parser inputs.
Return prepared structure without invoking headline formatters or lowering.
Never register protocols globally or reset source element caches.  Keep
Org's internal regexp regeneration confined to this preparation boundary.
INFO is the fixed supported global and buffer-local context snapshot.
Optional FILTER consumes the completed preparation in its private Org buffer.
Optional SUBTREE-POSITION selects a subtree in that complete source snapshot.
REGION selects its (BEGIN . END) body while retaining subtree configuration.
RESTRICTION is the source's captured outer body boundary, not a live narrowing."
  (let ((org-link-parameters (org-texmacs--document-copy-link-setting (nth 0 links)))
        (org-link-abbrev-alist (org-texmacs--document-copy-link-setting (nth 1 links)))
        (org-link-types-re org-link-types-re)
        (org-link-angle-re org-link-angle-re)
        (org-link-plain-re org-link-plain-re)
        (org-link-bracket-re org-link-bracket-re)
        (org-link-any-re org-link-any-re)
        (org-element--object-regexp org-element--object-regexp)
        (org-element-paragraph-separate org-element-paragraph-separate))
    (dolist (type org-texmacs--supported-link-types)
      (unless (assoc type org-link-parameters)
        (push (list type) org-link-parameters)))
    (org-link-make-regexps)
    (org-element--set-regexps)
    (with-temp-buffer
      (let ((org-element-use-cache nil) (org-inhibit-startup t))
        (delay-mode-hooks (org-mode))
        (setq-local org-texmacs-fragment-tags tags)
        (insert source)
        (org-texmacs--document-prepare
         source (org-texmacs--fragment-collect tags) headings (nth 2 links) info
         subtree-position region restriction filter)))))

(defun org-texmacs--document-prepare
    (source spans heading-settings &optional abbrevs info subtree-position region
            restriction filter)
  "Prepare SOURCE and discovered SPANS without starting a worker.
HEADING-SETTINGS is the source's effective heading configuration snapshot.
Install it locally after private mode initialization, before parsing source.
ABBREVS supplies source-local Org link abbreviations for the private parser.
INFO is the fixed context base to merge with supported source keywords.
Return (AST ISLANDS REQUESTS POST-BLANKS INFO).  Each request is
(ISLAND-ENTRY SOURCE TAG); TAG is nil for an unrestricted special block.
Island entries initially contain placeholder strees for structural validation.
All positions refer to the complete, unnarrowed source snapshot.
Optional SUBTREE-POSITION selects a body plus owned dependencies before walking.
REGION takes precedence for body selection; reject truncated STM islands.
Optional FILTER is called after context and mapping construction, before return.
RESTRICTION bounds the body, intersecting subtree selection when REGION is nil."
  (with-temp-buffer
    (let ((org-element-use-cache nil)
          (org-inhibit-startup t)
          (remaining spans)
          (islands nil) (requests nil) (blanks nil))
      (delay-mode-hooks (org-mode))
      (org-texmacs--document-use-heading-settings heading-settings)
      (setq-local org-link-abbrev-alist-local
                  (org-texmacs--document-copy-link-setting abbrevs))
      (insert source)
      (dolist (span spans)
        (goto-char (org-texmacs-fragment-span-begin span))
        (delete-region (point) (org-texmacs-fragment-span-end span))
        (insert (org-texmacs--fragment-mask
                 (org-texmacs-fragment-span-source span))))
      (cl-labels
          ((register (node raw tag &optional begin end)
             (let* ((entry (cons node '(concat "")))
                    (request (list entry raw tag)))
               ;; Composition needs coordinates for inline string identity keys.
               ;; Retain them before context/filter owning; legacy requests keep
               ;; their existing three fields.  Pure INFO later owns origins.
               (when (plist-get info :texmacs-source-origins)
                 (setq request
                       (append request
                               (list (cons (or begin (org-element-property :begin node))
                                           (or end (org-element-property :end node)))))))
               (push entry islands)
               (push request requests)))
           (whitespace (node)
             (when (or (assq (org-element-type node) org-texmacs--document-markup-tags)
                       (memq (org-element-type node)
                             '(code verbatim line-break link footnote-reference)))
               (let* ((end (org-element-property :end node))
                      (count (or (org-element-property :post-blank node) 0)))
                 (push (cons node (buffer-substring-no-properties (- end count) end))
                       blanks))
               (if (and (eq (org-element-type node) 'footnote-reference)
                        (eq (org-element-property :type node) 'inline))
                   (paragraph node)
                 (mapc #'whitespace (org-element-contents node)))))
           (paragraph (node)
             (let ((position (org-element-property :contents-begin node))
                   (children nil))
               (if (null position)
                   ;; Coordinate-less synthetic paragraphs carry already parsed
                   ;; inline data, not source fragment intervals.
                   (mapc #'whitespace (org-element-contents node))
               (dolist (child (org-element-contents node))
                 (if (not (stringp child))
                     (progn
                       (whitespace child)
                       (push child children)
                       (setq position (org-element-property :end child)))
                   (let ((end (+ position (length child))))
                     ;; Fail closed if Org normalized a leaf or a mask became markup.
                     (unless (equal (substring-no-properties child)
                                    (buffer-substring-no-properties position end))
                       (org-texmacs--document-fail node "Org text differs from snapshot"))
                     (while (and remaining
                                 (< (org-texmacs-fragment-span-begin (car remaining)) end)
                                 ;; Restored dependencies can have earlier
                                 ;; source positions than this paragraph.
                                 (or (not (or subtree-position region))
                                     (>= (org-texmacs-fragment-span-begin (car remaining))
                                         (org-element-property :contents-begin node))))
                       (let* ((span (pop remaining))
                              (begin (org-texmacs-fragment-span-begin span))
                              (stop (org-texmacs-fragment-span-end span)))
                         (unless (<= position begin stop end)
                           (org-texmacs--document-fail node "Fragment crosses an Org object"))
                         (when (< position begin)
                           (push (buffer-substring-no-properties position begin) children))
                         (let ((leaf (copy-sequence
                                      (org-texmacs-fragment-span-source span))))
                           (push leaf children)
                           (register leaf leaf (org-texmacs-fragment-span-tag span) begin stop))
                         (setq position stop)))
                     (when (< position end)
                       (push (buffer-substring-no-properties position end) children))
                     (setq position end))))
               (apply #'org-element-set-contents node (nreverse children)))))
           (walk (node)
             (cond
              ((org-texmacs--native-body-kind node)
               (register node (org-texmacs--native-body-source node) nil))
              ((eq (org-element-type node) 'paragraph) (paragraph node))
              ((or (eq (org-element-type node) 'table)
                   (org-texmacs--figure-table-kind node)
                   (and (eq (org-element-type node) 'special-block)
                        (ignore-errors (org-texmacs--document-statement-tag node))))
               (org-element-put-property node :texmacs-affiliated-keywords
                                         (org-texmacs--source-affiliated-keys node))
               (dolist (line (org-texmacs--document-caption-lines node))
                 (mapc #'whitespace (car line))
                 (mapc #'whitespace (cdr line)))
               (when (eq (org-element-type node) 'special-block)
                 (mapc #'walk (org-element-contents node))))
              ((memq (org-element-type node)
                     '(org-data section headline plain-list item footnote-definition
                       quote-block center-block special-block))
               (when (eq (org-element-type node) 'headline)
                 (mapc #'whitespace (org-element-property :title node)))
               (when (eq (org-element-type node) 'item)
                 (mapc #'whitespace (org-element-property :tag node)))
               (mapc #'walk (org-element-contents node))))))
        (let ((ast (org-element-parse-buffer)))
          (org-texmacs--name-source-shapes ast)
          (org-texmacs--figure-table-source-shapes ast)
          (setq region (org-texmacs--context-body-region
                        ast subtree-position region restriction))
          (when (and region (< (car region) (cdr region)))
            (cl-labels ((complete (begin end)
                          (when (and (< begin (cdr region)) (< (car region) end)
                                     (not (<= (car region) begin end (cdr region))))
                            (signal 'org-texmacs-document-error
                                    '("Region truncates a TeXmacs island")))))
              (dolist (span spans)
                (complete (org-texmacs-fragment-span-begin span)
                          (org-texmacs-fragment-span-end span)))))
          (when (or subtree-position region)
            ;; Prune owned full-source structure before walking/validating body.
            ;; Block placeholders make STM opaque while collecting dependencies.
            (let* ((opaque (mapcar (lambda (node) (cons node '(concat "")))
                                   (org-texmacs--native-body-blocks ast)))
                   (scoped (org-texmacs--context-prepare
                            ast opaque nil nil info subtree-position region))
                   paragraphs)
              (cl-labels ((collect (node)
                            (unless (org-texmacs--native-body-kind node)
                              (when (org-element-type-p node 'paragraph)
                                (push node paragraphs))
                              (mapc #'collect (org-element-contents node)))))
                (collect ast))
              (setq paragraphs (nreverse paragraphs))
              (setq info (nth 4 scoped)
                    remaining
                    ;; Dependencies may precede the selected subtree in source
                    ;; but follow its body in AST order.  Match that traversal.
                    (cl-mapcan
                     (lambda (paragraph)
                       (let ((begin (org-element-property :begin paragraph))
                             (end (org-element-property :end paragraph)))
                         (when (and (integerp begin) (integerp end))
                           (cl-remove-if-not
                            (lambda (span)
                              (<= begin (org-texmacs-fragment-span-begin span)
                                  (org-texmacs-fragment-span-end span) end)) remaining))))
                     paragraphs))))
          (walk ast)
          (when remaining
            (signal 'org-texmacs-document-error '("Unconsumed fragment spans")))
          (setq islands (nreverse islands) requests (nreverse requests))
          (let ((prepared
                 (if (or subtree-position region)
                     (list ast islands requests blanks info)
                   (org-texmacs--context-prepare ast islands requests blanks info))))
            (if filter (funcall filter prepared) prepared)))))))

(defun org-texmacs--document-normalize-table (document)
  "Validate and wrap raw table DOCUMENT, retaining its original STM root."
  (let* ((root (org-texmacs-document-body document))
         (format (cond ((eq (car-safe root) 'table) nil)
                       ((eq (car-safe root) 'tformat) root)
                       ((and (eq (car-safe root) 'tabular) (= (length root) 2)
                             (eq (car-safe (cadr root)) 'tformat)) (cadr root))
                       (t (signal 'org-texmacs-document-error '("Unsupported native table root")))))
         (table (if format (car (last format)) root)) width)
    (when format
      (unless (and (cdr format)
                   (cl-every (lambda (item)
                               (or (and (eq (car-safe item) 'twith) (= (length item) 3))
                                   (and (eq (car-safe item) 'cwith) (= (length item) 7))))
                             (butlast (cdr format))))
        (signal 'org-texmacs-document-error '("Invalid native table format"))))
    (unless (and (eq (car-safe table) 'table) (cdr table))
      (signal 'org-texmacs-document-error '("Missing native table rows")))
    (dolist (row (cdr table))
      (unless (and (eq (car-safe row) 'row) (cdr row)
                   (cl-every (lambda (cell) (and (eq (car-safe cell) 'cell) (= (length cell) 2)))
                             (cdr row))
                   (or (null width) (= width (length (cdr row)))))
        (signal 'org-texmacs-document-error '("Invalid or nonrectangular native table row")))
      (setq width (length (cdr row))))
    (cond ((eq (car root) 'tabular) document)
          ((eq (car root) 'tformat) (org-texmacs--document-pack 'tabular (list document)))
          (t (org-texmacs--document-pack
              'tabular (list (org-texmacs--document-pack 'tformat (list document))))))))

(defun org-texmacs--document-check-native-requests (prepared)
  "Validate selected raw equation requests in PREPARED before native parsing."
  (dolist (request (nth 2 prepared))
    (let ((node (caar request)))
      (when (memq (org-texmacs--native-body-kind node) '(equation equation*))
        (org-texmacs--native-body-check node)
        (when (string-match-p "\\`[ \t\r\n]*\\'" (nth 1 request))
          (org-texmacs--document-fail node "Empty equation source"))))))

(provide 'org-texmacs-document)

;;; org-texmacs-document.el ends here
