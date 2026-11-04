;;; org-texmacs-input.el --- Prepared inputs for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Owned snapshots for structural lowering, independent of source buffers.

;;; Code:

(require 'org-texmacs-document)
(require 'org-texmacs-model)

(cl-defstruct
 (org-texmacs-input
  (:constructor org-texmacs--input-create) (:copier nil))
 "Prepared structural input.  Treat all slots and nested data as read-only.
MODEL holds the common Org AST and parsed STM islands.  AST and ISLANDS
are compatibility accessors to that same owned graph, not separate copies.
POST-BLANKS and INFO belong to the export preparation context.
INFO contains fixed context and prepared views, not a request to collect
source configuration.
STYLE and INITIAL are copied TeXmacs document settings.
SOURCE-FILE is optional source identity; RESOURCE-BASE is the optional
fixed base for source-relative resources.  Neither is inferred from the other.
BIBLIOGRAPHY owns parsed BibTeX dependency trees keyed by source identity;
these native source-semantic trees are separate from the Org AST and islands."
 (model nil :read-only t)
 (ast nil :read-only t)
 (info nil :read-only t)
 (islands nil :read-only t)
 (post-blanks nil :read-only t)
 (style nil :read-only t)
 (initial nil :read-only t)
 (source-file nil :read-only t)
 (resource-base nil :read-only t)
 (bibliography nil :read-only t)
 (resolution nil :read-only t))

(defun org-texmacs--bibliography-copy (bibliography)
  "Validate and own prepared BIBLIOGRAPHY without parsing or file access.
Each unique absolute source path maps to a native bibliography document stree.
Preserve opaque native metadata and duplicate entries/fields.  Citation planning
checks ambiguity only for keys actually used by the document."
  (unless (proper-list-p bibliography)
    (signal 'org-texmacs-document-error
            '("Expected a bibliography alist")))
  (let (paths
        result)
    (dolist (source bibliography)
      (unless (and (consp source) (stringp (car source)))
        (signal 'org-texmacs-document-error
                '("Invalid bibliography source")))
      (let ((path (org-texmacs--source-copy-path (car source)))
            (tree (org-texmacs--document-copy-stree (cdr source))))
        (when (member path paths)
          (signal 'org-texmacs-document-error
                  '("Duplicate bibliography path")))
        (push path paths)
        (unless (and (consp tree) (eq (car tree) 'document))
          (signal 'org-texmacs-document-error
                  '("Expected a parsed bibliography document")))
        (dolist (entry (cdr tree))
          (when (and (consp entry) (eq (car entry) 'bib-entry))
            (unless (and (= (length entry) 4)
                         (stringp (nth 1 entry))
                         (> (length (nth 1 entry)) 0)
                         (stringp (nth 2 entry))
                         (> (length (nth 2 entry)) 0)
                         (consp (nth 3 entry))
                         (eq (car (nth 3 entry)) 'document))
              (signal 'org-texmacs-document-error
                      '("Invalid parsed bibliography entry")))
            (dolist (field (cdr (nth 3 entry)))
              (unless (and (consp field)
                           (eq (car field) 'bib-field)
                           (= (length field) 3)
                           (stringp (nth 1 field))
                           (> (length (nth 1 field)) 0))
                (signal 'org-texmacs-document-error
                        '("Invalid parsed bibliography field"))))))
        (push (cons path tree) result)))
    (nreverse result)))

(cl-defun
 org-texmacs--input-own
 (ast
  info
  &key
  islands
  post-blanks
  (style '("generic"))
  initial
  source-file
  resource-base
  bibliography)
 "Copy AST, INFO and context without allocating reference identities.
Internal intermediate ownership boundary; see `org-texmacs-input-create'."
 (unless (and (consp ast) (eq (car ast) 'org-data))
   (signal 'org-texmacs-document-error
           '("Expected a prepared Org document AST")))
 (unless (and (proper-list-p info) (zerop (% (length info) 2)))
   (signal 'org-texmacs-document-error
           '("Expected an options plist")))
 (let* ((owner
         (org-texmacs--model-owner-create
          :error-type 'org-texmacs-document-error
          :caption-reader #'org-texmacs--document-caption-lines))
        (new-ast (org-texmacs--model-copy-node owner ast nil))
        new-info
        seen)
   (setq
    info
    (or
     info
     '(:with-todo-keywords
       t
       :with-priority nil
       :with-tags t
       :texmacs-format-headline-function org-texmacs-format-headline-default-function)))
   (unless (memq :texmacs-date-timestamp-text-function info)
     (setq
      info
      (append
       info
       (list
        :texmacs-date-timestamp-text-function 'org-texmacs--document-date-timestamp-text))))
   (while info
     (let ((key (pop info))
           (value (pop info)))
       (unless (and (keywordp key) (not (memq key seen)))
         (signal 'org-texmacs-document-error
                 '("Invalid or duplicate options key")))
       (push key seen)
       (when (memq
              key
              '(:texmacs-format-headline-function
                :texmacs-date-timestamp-text-function))
         (setq value (indirect-function value))
         (unless (functionp value)
           (signal 'org-texmacs-document-error
                   '("Invalid presentation function"))))
       (setq new-info
             (append
              new-info
              (list
               key
               (cond
                ((memq
                  key
                  '(:texmacs-format-headline-function
                    :texmacs-date-timestamp-text-function))
                 value)
                ((eq key :texmacs-special-block-handlers)
                 (org-texmacs--document-copy-handlers value))
                ((memq key org-texmacs--context-rich-metadata)
                 (org-texmacs--model-copy-secondary owner value))
                (t
                 (org-texmacs--model-copy-data owner value))))))))
   ;; Rich INFO metadata joins the same ownership transaction before pending
   ;; properties and identity-keyed mappings are resolved.
   (org-texmacs--model-finish-owner owner)
   (let* ((new-islands
           (org-texmacs--model-copy-mapping
            owner islands #'org-texmacs--document-copy-stree))
          (_
           (org-texmacs--model-check-islands
            new-ast new-islands 'org-texmacs-document-error))
          (model
           (org-texmacs--model-create
            :ast new-ast
            :islands new-islands)))
     (org-texmacs--input-create
      :model model
      :ast new-ast
      :info new-info
      :islands new-islands
      :style (org-texmacs--document-copy-style style)
      :initial (org-texmacs--document-copy-initial initial)
      :source-file (org-texmacs--source-copy-path source-file)
      :resource-base (org-texmacs--source-copy-path resource-base)
      :bibliography (org-texmacs--bibliography-copy bibliography)
      :post-blanks
      (org-texmacs--model-copy-mapping
       owner post-blanks
       (lambda (value)
         (unless (and (stringp value)
                      (string-match-p "\\`[ \t]*\\'" value))
           (signal 'org-texmacs-document-error
                   '("Expected trailing spaces or tabs")))
         (substring-no-properties value)))))))

(defun org-texmacs--input-finalize (input)
  "Return INPUT with one owned, frozen reference resolution.
Unsupported semantic inputs retain their error until document lowering."
  (let* ((ast (org-texmacs-input-ast input))
         (static
          (org-texmacs--document-static-labels
           (org-texmacs-input-islands input)))
         (query
          (plist-get
           (org-texmacs-input-info input)
           :texmacs-org-query))
         (resolution
          (condition-case err
              (org-texmacs--document-allocate
               ast
               (org-texmacs--document-resolve
                ast
                (org-texmacs-input-islands input)
                static
                (org-texmacs-input-resource-base input)
                query)
               static query)
            (org-texmacs-document-error
             (org-texmacs--resolution-create :failure (cdr err))))))
    (setq input
          (org-texmacs--input-with-info
           input (org-texmacs-input-info input)
           resolution))
    (if (plist-member
         (org-texmacs-input-info input)
         :texmacs-cite-requests)
        (org-texmacs--input-cite-plan input)
      input)))

(defun org-texmacs--input-cite-plan (input)
  "Bind owned native requests in INPUT to a frozen structural output plan.
Select only requested keys from already parsed dependencies.  No file access,
processor calls, native formatting or independent citation collection occurs."
  (let* ((info (org-texmacs-input-info input))
         (view
          (org-texmacs--cite-view
           (org-texmacs-input-ast input)
           (plist-get info :texmacs-cite-requests)))
         (keys (plist-get view :keys))
         (static
          (org-texmacs--document-static-labels
           (org-texmacs-input-islands input)))
         (number 0)
         prefix
         selected)
    (while (progn
             (setq prefix
                   (format "org-texmacs-bib-%d" (cl-incf number)))
             (cl-some
              (lambda (key)
                (member (concat prefix "-" key) static))
              keys)))
    (when (or (org-texmacs-input-bibliography input)
              (plist-get info :texmacs-bibliography-output))
      (dolist (file (plist-get view :files))
        (unless (assoc file (org-texmacs-input-bibliography input))
          (org-texmacs--cite-fail
           "Missing owned native bibliography source")))
      (dolist (key keys)
        (let (matches)
          (dolist (source (org-texmacs-input-bibliography input))
            (when (member (car source) (plist-get view :files))
              (dolist (entry (cdr (cdr source)))
                (when (and (consp entry)
                           (eq (car entry) 'bib-entry)
                           (equal (nth 2 entry) key))
                  (push entry matches)))))
          (unless (= (length matches) 1)
            (org-texmacs--cite-fail
             "Missing or ambiguous native bibliography key"))
          (push (car matches) selected))))
    (org-texmacs--input-with-info
     input
     (plist-put
      (copy-sequence info)
      :texmacs-cite-plan
      (append
       view
       (list
        :prefix prefix
        :entries
        (cons 'document (nreverse selected))))))))

(defun org-texmacs--input-cite-result (input bibliography output)
  "Own prepared native BIBLIOGRAPHY and OUTPUT for request-bearing INPUT.
OUTPUT is the existing (PREFIX KEYS ENTRIES BODY) structural output view.
This boundary neither reads source files nor runs native parsing/formatting."
  (unless (plist-member
           (org-texmacs-input-info input)
           :texmacs-cite-requests)
    (org-texmacs--cite-fail "Expected native citation requests"))
  (unless (or (null output)
              (and (proper-list-p output) (= (length output) 4)))
    (org-texmacs--cite-fail
     "Invalid native bibliography result view"))
  (org-texmacs-input-create
   (org-texmacs-input-ast input)
   (plist-put
    (copy-sequence (org-texmacs-input-info input))
    :texmacs-bibliography-output output)
   :islands (org-texmacs-input-islands input)
   :post-blanks (org-texmacs-input-post-blanks input)
   :style (org-texmacs-input-style input)
   :initial (org-texmacs-input-initial input)
   :source-file (org-texmacs-input-source-file input)
   :resource-base (org-texmacs-input-resource-base input)
   :bibliography bibliography))

(defun org-texmacs--input-with-info (input info &optional resolution)
  "Finish private INPUT with owned INFO and optional frozen RESOLUTION.
Reuse owned AST identities; callers must not expose unfinished inputs."
  (org-texmacs--input-create
   :model (org-texmacs-input-model input)
   :ast (org-texmacs-input-ast input)
   :info info
   :islands (org-texmacs-input-islands input)
   :post-blanks (org-texmacs-input-post-blanks input)
   :style (org-texmacs-input-style input)
   :initial (org-texmacs-input-initial input)
   :source-file (org-texmacs-input-source-file input)
   :resource-base (org-texmacs-input-resource-base input)
   :bibliography (org-texmacs-input-bibliography input)
   :resolution
   (or resolution (org-texmacs-input-resolution input))))

;;;###autoload
(cl-defun
 org-texmacs-input-create
 (ast
  info
  &key
  islands
  post-blanks
  (style '("generic"))
  initial
  source-file
  resource-base
  bibliography)
 "Own AST, INFO, mappings and context, then freeze reference identities.
AST must be a fully parsed `org-data' tree, not Org's live cache.  Do not
resolve deferred properties, read buffers, discover STM or run a formatter.
ISLANDS maps AST node identities to already parsed text strees; POST-BLANKS
maps inline node identities to trailing spaces/tabs.  See the preparation
contract of `org-texmacs--document-lower'.  Unsupported lowering is diagnosed
by `org-texmacs-document', not by invoking it during this copy.

STYLE is a nonempty list of TeXmacs style identifier strings and defaults to
`(\"generic\")'.  INITIAL is an alist of unique nonempty environment identifier
strings to source-semantic text strees and defaults to nil.  Neither setting
is inferred from ambient Custom values.  Effective Org language and description
in INFO may override INITIAL defaults during pure document lowering.

SOURCE-FILE and RESOURCE-BASE are optional explicit absolute path strings,
copied without filesystem access or path expansion.  RESOURCE-BASE fixes
the source-relative resource base; SOURCE-FILE does not override it.  Omitted
values remain nil and are never inferred from the current buffer.

BIBLIOGRAPHY is an alist from explicit absolute source paths to already parsed
BibTeX document strees.  Copy its text trees and reject duplicate source paths
and malformed consumed entry/field structures.  Preserve native duplicate
entries and fields; resolution requires uniqueness only for used keys.
Never read those paths or parse source text here.  This slot
establishes prepared data ownership.  Citation lowering also requires fixed
INFO declaration identities and a prepared output view for bibliography print.
The view binds prefix, key order, selected entry trees and source-semantic body;
pure lowering verifies that it matches the current resolution plan.

Standard native Cite inputs instead carry :texmacs-cite-requests in INFO.
These are minimal node-associated requests, not full live export INFO.  Copy
and validate their identities, then freeze a native plan without recollecting
citations.  Native results bind the same prefix, keys and selected entries.
Pending requests remain inspectable but cannot produce a document until their
bibliography result is supplied.  Neither request ownership nor result
attachment performs file access or native processing.

Copy strings, lists and vectors, rebuild parent links, and remap references
to AST nodes in INFO and the mappings.  Copy parsed title, subtitle, author
and date as separately owned Org objects.  Copy supported captions as pairs
of long/short secondary strings.  Reject cyclic or multiply owned AST nodes,
detached/duplicate mapping keys, deferred values and opaque objects.
Discard Org's source buffer and parent bookkeeping.  INFO must be a plist
with unique keyword keys; nil selects fixed lowering defaults.  A supplied
headline formatter, private date timestamp converter and private special-block
handlers are resolved now and retained as opaque functions.  Handler registry
strings and list structure are independently owned;
mutable state captured by a user closure is not frozen.  Never mutate the
returned input, its accessors' values, or arguments from a formatter.
Org reference allocation occurs once after copying into this owned snapshot.
Mutable Org export caches are not retained.  Repeated document lowering uses
its fixed identities without further allocation or source access."
 (org-texmacs--input-finalize
  (org-texmacs--input-own
   ast
   info
   :islands islands
   :post-blanks post-blanks
   :style style
   :initial initial
   :source-file source-file
   :resource-base resource-base
   :bibliography bibliography)))

(provide 'org-texmacs-input)
;;; org-texmacs-input.el ends here
