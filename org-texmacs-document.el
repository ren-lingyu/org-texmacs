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

(defconst org-texmacs--document-toc-tags
  '(toc-1 toc-2 toc-3 toc-4 toc-5)
  "Static TeXmacs table-of-contents tags for headline levels one through five.")

(defconst org-texmacs--document-toc-label-prefix "org-texmacs-toc-"
  "Private prefix for deterministic table-of-contents target labels.")

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

(defun org-texmacs--document-options ()
  "Snapshot supported Org document policies and the selected formatter.
File keywords are merged later from the prepared AST without following setup
files.  Do not run export preprocessing, BIND, hooks or filters here.
Capture `tab-width' for preformatted content.  Resolve a formatter symbol now
so later redefinition affects only new calls."
  (let ((formatter (indirect-function org-texmacs-format-headline-function))
        (info (plist-put (org-texmacs--context-base-options)
                         :texmacs-tab-width tab-width)))
    (unless (and (memq org-export-with-todo-keywords '(nil t))
                 (memq org-export-with-priority '(nil t))
                 (memq org-export-with-tags '(nil t not-in-toc))
                 (functionp formatter))
      (signal 'org-texmacs-document-error '("Invalid headline presentation options")))
    (plist-put info :texmacs-format-headline-function formatter)))

(cl-defstruct (org-texmacs-document
               (:constructor org-texmacs--document-create)
               (:copier nil))
  "Read-only structural result, before native encoding.
BODY is a text stree; STYLE is a list of TeXmacs style identifiers; INITIAL
is an alist of environment identifiers to source-semantic text strees.
STM-PATHS locate STM island roots only within BODY.  Each path contains
zero-based child indices, excluding tags.  Callers must not mutate any slot
or nested list/string.  No source buffer is retained."
  (body nil :read-only t)
  (stm-paths nil :read-only t)
  (style nil :read-only t)
  (initial nil :read-only t))

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

(defun org-texmacs--document-pack (tag parts)
  "Wrap lowered PARTS in TAG, prefixing their STM paths by child index."
  (let ((index 0) (children nil) (paths nil))
    (dolist (part parts)
      (push (org-texmacs-document-body part) children)
      (dolist (path (org-texmacs-document-stm-paths part))
        (push (cons index path) paths))
      (setq index (1+ index)))
    (org-texmacs--document-create
     :body (cons tag (nreverse children)) :stm-paths (nreverse paths))))

(defun org-texmacs--document-lower
    (ast &optional islands post-blanks info style initial)
  "Lower prepared Org AST and ISLANDS to a structural document result.

AST must be an `org-data' snapshot.  ISLANDS is an identity-keyed alist
of (NODE . STREE): NODE is a complete TeXmacs special block or a standalone
plain-text child of a paragraph.  A preparation layer must split text at
fragment boundaries and mask foreign markup before constructing this input.
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

POST-BLANKS optionally maps inline Org object identities to their original
trailing spaces/tabs.  Without an entry, use the nonnegative `:post-blank'
count.  Both inputs have prose whitespace semantics, not source fidelity.

Support paragraphs, plain text, basic emphasis, inline code/verbatim,
explicit line breaks, self-contained URI links, transparent Org sections,
relative headline levels one through five, lower-level headline lists, all
three Org plain-list types, quote/center blocks, and static example,
fixed-width and source blocks, plus basic rectangular Org tables.  Emit
supported title, author and date metadata as body `doc-data'.  When enabled,
emit a static table of contents with generated internal targets.
Link admission uses Org type, not raw source.  Accept anonymous inline
footnotes only as direct paragraph children.  Reject list checkboxes and
explicit counters; description terms use the existing inline subset.
Collapse ordinary spaces, tabs and soft newlines across Org inline text
boundaries.  Suppress leading whitespace at paragraph/title starts and after
explicit breaks; a final whitespace run remains one space.  Inline code is
literal, not preformatted.  Never normalize STM islands, merge adjacent
strings or flatten island strees.  Reject unsupported nodes and semantics.

Return a fresh result with STM root paths, retaining no Org properties or
source objects.  Do not read or modify source/caller buffers, encode text,
start a worker, or change AST/ISLANDS.  The caller must prepare all inputs
from one snapshot."
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
  (let ((used-islands nil) (used-blanks nil)
        (style (org-texmacs--document-copy-style (or style '("generic"))))
        (initial (org-texmacs--document-copy-initial initial))
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
        (static-labels (org-texmacs--document-static-labels islands))
        (info (or info '(:with-todo-keywords t :with-priority nil :with-tags t
                        :texmacs-format-headline-function
                        org-texmacs-format-headline-default-function))))
    (setq headline-limit
          (if (memq :headline-levels info) (plist-get info :headline-levels) 3)
          preformatted-tab-width
          (if (memq :texmacs-tab-width info) (plist-get info :texmacs-tab-width) 8)
          headline-formatter
          (if (memq :texmacs-format-headline-function info)
              (plist-get info :texmacs-format-headline-function)
            #'org-texmacs-format-headline-default-function)
          toc-setting
          (and (memq :with-toc info) (plist-get info :with-toc)))
    (unless (and (wholenump headline-limit) (<= headline-limit 5)
                 (integerp preformatted-tab-width) (> preformatted-tab-width 0)
                 (let ((value (if (memq :section-numbers info)
                                  (plist-get info :section-numbers) t)))
                   (or (memq value '(nil t)) (wholenump value)))
                 (or (memq toc-setting '(nil t)) (wholenump toc-setting))
                 (functionp headline-formatter))
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
               (unless (and (stringp node) (eq context 'paragraph))
                 (org-texmacs--document-fail node "Island outside paragraph text"))
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
               (unless (and (eq context 'paragraph)
                            (eq (org-element-property :type node) 'inline)
                            (null (org-element-property :label node))
                            (not (memq node ancestors)))
                 (org-texmacs--document-fail node "Unsupported footnote context or type"))
               (let* ((parts (inlines (org-element-contents node) 'footnote
                                      (cons node ancestors)))
                      (paragraph (org-texmacs--document-pack
                                  'concat (or parts
                                              (list (org-texmacs--document-create :body ""))))))
                 ;; The reference is visible; its body has separate whitespace state.
                 (setcar space nil)
                (cons (org-texmacs--document-pack
                        'footnote (list (org-texmacs--document-pack 'document (list paragraph))))
                       (blank node space))))
              ((and (consp node) (eq (org-element-type node) 'timestamp))
               (let ((year (org-element-property :year-start node))
                     (month (org-element-property :month-start node))
                     (day (org-element-property :day-start node)))
                 (unless (and (eq context 'date)
                              (memq (org-element-property :type node) '(active inactive))
                              (integerp year) (integerp month) (<= 1 month 12)
                              (integerp day) (<= 1 day 31)
                              (null (org-element-property :hour-start node))
                              (null (org-element-property :repeater-type node))
                              (null (org-element-property :warning-type node))
                              (null (org-element-contents node)))
                   (org-texmacs--document-fail node "Unsupported metadata timestamp"))
                 (cons (text (format "%04d-%02d-%02d" year month day) space)
                       (blank node space))))
              ((and (consp node) (eq (org-element-type node) 'link))
               (when (memq node ancestors)
                 (org-texmacs--document-fail node "Cyclic Org AST"))
               (let ((type (org-element-property :type node))
                     (path (org-element-property :path node)))
                 (unless (and (stringp type) (stringp path)
                              (member (downcase type) org-texmacs--supported-link-types))
                   (org-texmacs--document-fail node "Unsupported link type or path"))
                 (let* ((uri (concat (substring-no-properties type) ":"
                                     (substring-no-properties path)))
                        (parts (and (org-element-contents node)
                                    (inlines (org-element-contents node) 'link
                                             (cons node ancestors) space)))
                        (body (cond ((null parts)
                                     (setcar space nil)
                                     (org-texmacs--document-create :body (copy-sequence uri)))
                                    ((null (cdr parts)) (car parts))
                                    (t (org-texmacs--document-pack 'concat parts)))))
                   (cons (org-texmacs--document-pack
                          'hlink (list body (org-texmacs--document-create :body uri)))
                         (blank node space)))))
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
         (target-label (node)
           (when-let* ((name (cdr (assq node toc-labels))))
             (org-texmacs--document-pack
              'label (list (org-texmacs--document-create :body name)))))
         (low-headline-item (node context ancestors)
           (unless (and (consp node) (not (memq node ancestors))
                        (memq context '(org-data headline)))
             (org-texmacs--document-fail node "Unexpected low-level headline"))
           (let ((ancestors (cons node ancestors)))
             (check-affiliated node)
             (cons
              (org-texmacs--document-pack
               'concat
               (list (org-texmacs--document-pack 'item nil)
                     (headline-title node ancestors)))
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
         (check-affiliated (node)
           (let ((begin (org-element-property :begin node))
                 (post (org-element-property :post-affiliated node)))
             (when (and (integerp begin) (integerp post) (> post begin))
               (org-texmacs--document-fail node "Unsupported affiliated metadata")))
           (dolist (property '(:name :caption :attr_texmacs))
             (when (org-element-property property node)
               (org-texmacs--document-fail node "Unsupported affiliated metadata"))))
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
           (let ((contents (org-element-contents node)))
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
             (when (org-export-table-has-special-column-p node)
               (org-texmacs--document-fail node "Unsupported special table column"))
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
               (org-texmacs--document-pack
                'tabular
                (list
                 (org-texmacs--document-pack
                  'tformat
                  (append (nreverse rules)
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
                   (cons (org-texmacs--document-pack
                          'concat
                          (cons marker
                                (inlines (org-element-contents first)
                                         'paragraph ancestors)))
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
               (unless (org-texmacs--block-p node)
                 (org-texmacs--document-fail node "Island key is not a TeXmacs block"))
               (list (island node entry)))
              ((eq type 'section)
               (unless (memq context '(org-data headline))
                 (org-texmacs--document-fail node "Unexpected Org section"))
               (blocks (org-element-contents node) 'section ancestors))
              ((eq type 'paragraph)
               (list (org-texmacs--document-pack
                      'concat (inlines (org-element-contents node) 'paragraph ancestors))))
              ((memq type '(example-block fixed-width src-block))
               (unless (memq context
                             '(org-data section headline item quote-block center-block))
                 (org-texmacs--document-fail node "Unexpected preformatted block"))
               (list (org-texmacs--document-preformatted
                      node preformatted-tab-width)))
              ((eq type 'table)
               (unless (memq context
                             '(org-data section headline item quote-block center-block))
                 (org-texmacs--document-fail node "Unexpected Org table"))
               (list (table-block node ancestors)))
              ((eq type 'plain-list)
               (unless (memq context
                             '(org-data section headline item quote-block center-block))
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
                             '(org-data section headline item quote-block center-block))
                 (org-texmacs--document-fail node "Unexpected Org container block"))
               (list
                (org-texmacs--document-pack
                 (if (eq type 'quote-block) 'quote 'center)
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
                      (target (target-label node)))
                 (unless (and (<= relative headline-limit) tags)
                   (org-texmacs--document-fail node "Unsupported section headline"))
                 (cons (org-texmacs--document-pack
                        (if numbered (car tags) (cdr tags))
                        (list (headline-title node ancestors)))
                       (append (and target (list target))
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
        (org-texmacs--document-create
         :body (org-texmacs-document-body result)
         :stm-paths (org-texmacs-document-stm-paths result)
         :style style :initial initial)))))

(defun org-texmacs--document-heading-settings ()
  "Copy effective Org heading parser settings for transfer and comparison.
Keep TODO regexp, DONE keywords, odd-level policy and priority regexp.
Copy strings as well as lists so in-place edits invalidate the snapshot.
Do not rebuild effective values from TODO declarations or file keywords."
  (unless (and (or (null org-todo-regexp) (stringp org-todo-regexp))
               (proper-list-p org-done-keywords)
               (cl-every #'stringp org-done-keywords)
               (stringp org-priority-regexp))
    (signal 'org-texmacs-document-error '("Invalid Org heading settings")))
  (list (and org-todo-regexp (substring-no-properties org-todo-regexp))
        (mapcar #'substring-no-properties org-done-keywords)
        (and org-odd-levels-only t)
        (substring-no-properties org-priority-regexp)))

(defun org-texmacs--document-use-heading-settings (settings)
  "Install copied heading SETTINGS in the private Org parser buffer.
Call after `org-mode' initialization and before parsing any source.  Keep
buffer-local copies separate from the caller's snapshot and source buffer."
  (setq-local org-todo-regexp
              (and (nth 0 settings) (substring-no-properties (nth 0 settings))))
  (setq-local org-done-keywords (mapcar #'substring-no-properties (nth 1 settings)))
  (setq-local org-odd-levels-only (nth 2 settings))
  (setq-local org-priority-regexp (substring-no-properties (nth 3 settings))))

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

(defun org-texmacs--document-prepare-source (source tags headings links info)
  "Prepare SOURCE under private Org link syntax using fixed LINKS settings.
TAGS and HEADINGS are the conversion's other parser inputs.
Return prepared structure without invoking headline formatters or lowering.
Never register protocols globally or reset source element caches.  Keep
Org's internal regexp regeneration confined to this preparation boundary.
INFO is the fixed supported global and buffer-local context snapshot."
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
         source (org-texmacs--fragment-collect tags) headings (nth 2 links) info)))))

(defun org-texmacs--document-prepare
    (source spans heading-settings &optional abbrevs info)
  "Prepare SOURCE and discovered SPANS without starting a worker.
HEADING-SETTINGS is the source's effective heading configuration snapshot.
Install it locally after private mode initialization, before parsing source.
ABBREVS supplies source-local Org link abbreviations for the private parser.
INFO is the fixed context base to merge with supported source keywords.
Return (AST ISLANDS REQUESTS POST-BLANKS INFO).  Each request is
(ISLAND-ENTRY SOURCE TAG); TAG is nil for an unrestricted special block.
Island entries initially contain placeholder strees for structural validation.
All positions refer to the complete, unnarrowed source snapshot."
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
          ((register (node raw tag)
             (let ((entry (cons node '(concat ""))))
               (push entry islands)
               (push (list entry raw tag) requests)))
           (whitespace (node)
             (when (or (assq (org-element-type node) org-texmacs--document-markup-tags)
                       (memq (org-element-type node)
                             '(code verbatim line-break link footnote-reference)))
               (let* ((end (org-element-property :end node))
                      (count (or (org-element-property :post-blank node) 0)))
                 (push (cons node (buffer-substring-no-properties (- end count) end))
                       blanks))
               (mapc #'whitespace (org-element-contents node))))
           (paragraph (node)
             (let ((position (org-element-property :contents-begin node))
                   (children nil))
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
                                 (< (org-texmacs-fragment-span-begin (car remaining)) end))
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
                           (register leaf leaf (org-texmacs-fragment-span-tag span)))
                         (setq position stop)))
                     (when (< position end)
                       (push (buffer-substring-no-properties position end) children))
                     (setq position end))))
               (apply #'org-element-set-contents node (nreverse children))))
           (walk (node)
             (cond
              ((org-texmacs--block-p node)
               (register node (org-texmacs--block-source node) nil))
              ((eq (org-element-type node) 'paragraph) (paragraph node))
              ((memq (org-element-type node)
                     '(org-data section headline plain-list item
                       quote-block center-block))
               (when (eq (org-element-type node) 'headline)
                 (mapc #'whitespace (org-element-property :title node)))
               (when (eq (org-element-type node) 'item)
                 (mapc #'whitespace (org-element-property :tag node)))
               (mapc #'walk (org-element-contents node))))))
        (let ((ast (org-element-parse-buffer)))
          (walk ast)
          (when remaining
            (signal 'org-texmacs-document-error '("Unconsumed fragment spans")))
          (setq islands (nreverse islands) requests (nreverse requests))
          (org-texmacs--context-prepare ast islands requests blanks info))))))

(provide 'org-texmacs-document)

;;; org-texmacs-document.el ends here
