;;; org-texmacs-prepared.el --- Prepared AST islands -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Adapt the final Org export tree without source coordinates or preparation.
;; Native parsing happens once during the private input ownership transaction.

;;; Code:

(require 'org-texmacs-input)
(require 'org-texmacs-fragment)
(require 'org-texmacs-worker)

(declare-function org-texmacs--bibliography-format "org-texmacs")

(defun org-texmacs--prepared-fail (message)
  "Reject incomplete or ambiguous prepared input with MESSAGE."
  (signal 'org-texmacs-document-error (list message)))

(defun org-texmacs--prepared-reject-raw (data)
  "Reject target-specific raw DATA before native input interpretation."
  ;; `raw' is a pseudo object.  A raw-only map misses paragraph contents.
  (when (org-element-map
         data t
         (lambda (node)
           (and (consp node) (eq (org-element-type node) 'raw)))
         nil t nil t)
    (org-texmacs--prepared-fail
     "Raw target output is unsupported; use a structured Org Cite processor")))

(defun org-texmacs--prepared-resolve (data)
  "Resolve DATA properties while live, preserving explicit filter values.
Some conditional deferred values survive the bulk resolver.  Public property
access materializes them without FORCE or replaying an overwritten value."
  (org-element-map
   data t
   (lambda (node)
     (when (consp node)
       (org-element-properties-resolve node)
       (org-element-properties-mapc
        (lambda (key _value _owner)
          (org-element-put-property
           node key (org-element-property key node)))
        node)))
   nil nil nil t))

(defun org-texmacs--prepared-copy (tree ignored &optional identities)
  "Own final TREE and apply Org's identity-keyed IGNORED list.
This realizes exclusion decisions already made by Org; it does not select or
prune export trees independently.  Detached ignore entries have no effect.
Optionally populate IDENTITIES with original-to-owned node associations."
  (let* ((owner
          (org-texmacs--model-owner-create
           :error-type 'org-texmacs-document-error
           :excluded-nodes
           (if (memq tree ignored)
               (org-element-contents tree)
             ignored)
           :secondary-normalizer
           (lambda (value)
             (if (stringp value)
                 (list value)
               value))
           :caption-reader #'org-texmacs--document-caption-lines))
         (copy (org-texmacs--model-copy-node owner tree nil)))
    (org-texmacs--model-finish-owner owner)
    (when identities
      (maphash
       (lambda (original owned)
         (puthash original owned identities))
       (org-texmacs--model-owner-nodes owner)))
    copy))

(defun org-texmacs--prepared-check-caption-notes (tree)
  "Reject caption footnotes in owned effective standard export TREE.
Stock Org leaves note-looking caption text literal.  Structured caption notes
remain supported by independent models and pure lowering, not source export."
  (org-element-map
   tree t
   (lambda (node)
     (when (and (consp node)
                (cl-some
                 (lambda (line)
                   (or (org-element-map
                        (car line)
                        'footnote-reference
                        #'identity
                        nil
                        t
                        nil
                        t)
                       (org-element-map
                        (cdr line)
                        'footnote-reference
                        #'identity
                        nil
                        t
                        nil
                        t)))
                 (org-element-property :caption node)))
       (org-texmacs--prepared-fail
        "Caption footnotes are unsupported in standard source export")))
   nil nil nil t))

(defun org-texmacs--prepared-cite-requests
    (tree requests ignored identities)
  "Migrate native REQUESTS from live TREE through prepared IDENTITIES.
Discard only associations excluded by Org's IGNORED decisions.  Detached or
duplicate associations fail instead of being guessed from source coordinates."
  (let ((nodes (make-hash-table :test #'eq))
        seen
        result)
    (unless (proper-list-p requests)
      (org-texmacs--cite-fail
       "Expected native citation request alist"))
    (org-element-map
     tree t
     (lambda (node)
       (when (consp node)
         (puthash node t nodes)))
     nil nil nil t)
    (dolist (pair requests)
      (unless (and (consp pair)
                   (gethash (car pair) nodes)
                   (not (memq (car pair) seen)))
        (org-texmacs--cite-fail
         "Detached or duplicate native citation carrier"))
      (push (car pair) seen)
      (if-let* ((owned (gethash (car pair) identities)))
          (push (cons owned (cdr pair)) result)
        (let ((node (car pair))
              excluded
              ancestors)
          (while node
            (when (memq node ancestors)
              (org-texmacs--cite-fail
               "Cyclic citation carrier ancestry"))
            (push node ancestors)
            (when (memq node ignored)
              (setq excluded t))
            (setq node (org-element-property :parent node)))
          (unless excluded
            (org-texmacs--cite-fail
             "Unmapped native citation carrier")))))
    (nreverse result)))

(defun org-texmacs--prepared-bibliography-state (file)
  "Return local FILE's resolved identity and change-sensitive attributes."
  (unless (and (org-texmacs--document-local-file-path-p file)
               (file-name-absolute-p file))
    (org-texmacs--cite-fail
     "Native bibliography requires an absolute local file"))
  (let* ((file-name-handler-alist nil)
         (identity (file-truename file))
         (attributes (file-attributes identity 'integer)))
    (unless (and attributes
                 (file-regular-p identity)
                 (file-readable-p identity))
      (org-texmacs--cite-fail
       "Native bibliography source is not a readable regular file"))
    (list
     identity
     (nth 5 attributes)
     (nth 6 attributes)
     (nth 7 attributes)
     (nth 10 attributes)
     (nth 11 attributes))))

(defun org-texmacs--prepared-bibliography-bytes (file)
  "Read local FILE as bytes for snapshot capture or integrity checking."
  (let ((file-name-handler-alist nil))
    (with-temp-buffer
      (set-buffer-multibyte nil)
      (insert-file-contents-literally file)
      (buffer-string))))

(defun org-texmacs--prepared-cite-snapshot (input)
  "Freeze active native bibliography files before any native wait for INPUT.
Use only the standard processor's owned requests, never bibliography discovery."
  (let* ((info (org-texmacs-input-info input))
         (view
          (org-texmacs--cite-view
           (org-texmacs-input-ast input)
           (plist-get info :texmacs-cite-requests)))
         identities
         snapshots)
    (condition-case err
        (dolist (file (plist-get view :files))
          (let* ((state
                  (org-texmacs--prepared-bibliography-state file))
                 (identity (car state))
                 (bytes
                  (org-texmacs--prepared-bibliography-bytes file))
                 (coding
                  (or coding-system-for-read
                      (detect-coding-string bytes t)
                      'utf-8-unix))
                 (text (decode-coding-string bytes coding)))
            (when (member identity identities)
              (org-texmacs--cite-fail
               "Duplicate native bibliography source identity"))
            (push identity identities)
            (unless (and (equal
                          state
                          (org-texmacs--prepared-bibliography-state
                           file))
                         (equal
                          bytes (encode-coding-string text coding)))
              (org-texmacs--cite-fail
               "Bibliography changed or could not be decoded losslessly"))
            (push (list
                   :path (substring-no-properties file)
                   :state state
                   :digest (secure-hash 'sha256 bytes)
                   :text text)
                  snapshots)))
      (file-error
       (signal 'org-texmacs-document-error
               (list
                "Cannot snapshot bibliography"
                (error-message-string err)))))
    (org-texmacs--input-with-info
     input
     (plist-put
      (copy-sequence info)
      :texmacs-bibliography-snapshots (nreverse snapshots)))))

(defun org-texmacs--prepared-cite-check (input)
  "Check INPUT's source fingerprints in an active source export transaction.
Independent input/document consumers never call this file-reading guard."
  (condition-case err
      (dolist (snapshot
               (plist-get
                (org-texmacs-input-info input)
                :texmacs-bibliography-snapshots))
        (let ((file (plist-get snapshot :path)))
          (unless (and (equal
                        (plist-get snapshot :state)
                        (org-texmacs--prepared-bibliography-state
                         file))
                       (equal
                        (plist-get snapshot :digest)
                        (secure-hash
                         'sha256
                         (org-texmacs--prepared-bibliography-bytes
                          file)))
                       (equal
                        (plist-get snapshot :state)
                        (org-texmacs--prepared-bibliography-state
                         file)))
            (org-texmacs--cite-fail
             "Bibliography changed during native export"))))
    (file-error
     (signal 'org-texmacs-document-error
             (list
              "Bibliography became unavailable"
              (error-message-string err))))))

(defun org-texmacs--prepared-cite-fulfill (input)
  "Parse and format owned bibliography snapshots for native request INPUT."
  (let* ((info (org-texmacs-input-info input))
         (plan (plist-get info :texmacs-cite-plan))
         (snapshots (plist-get info :texmacs-bibliography-snapshots)))
    (if (null (plist-get plan :prints))
        input
      (org-texmacs--prepared-cite-check input)
      (let ((sources
             (mapcar
              (lambda (snapshot)
                (prog1 (cons
                        (plist-get snapshot :path)
                        (org-texmacs--worker-request
                         (plist-get snapshot :text) 'bibliography))
                  (org-texmacs--prepared-cite-check input)))
              snapshots)))
        (setq input
              (org-texmacs--input-cite-result input sources nil))
        (let* ((output
                (org-texmacs--bibliography-format
                 (plist-get
                  (org-texmacs-input-info input)
                  :texmacs-cite-plan)))
               (result
                (org-texmacs--input-cite-result
                 input sources output)))
          (org-texmacs--prepared-cite-check result)
          ;; Keep only fingerprints after native interpretation; source text
          ;; is not needed by independent pure consumers or later copies.
          (org-texmacs--input-with-info
           result
           (plist-put
            (copy-sequence (org-texmacs-input-info result))
            :texmacs-bibliography-snapshots
            (mapcar
             (lambda (snapshot)
               (org-texmacs--context-copy
                (list
                 :path (plist-get snapshot :path)
                 :state (plist-get snapshot :state)
                 :digest (plist-get snapshot :digest))))
             snapshots))))))))

(defun org-texmacs--prepared-footnote-bodies (tree)
  "Give supplemental inline definitions in owned TREE a paragraph body.
Org may place inline objects directly in a supplemental footnote-definition.
Preserve those identities and wrap them structurally for document lowering."
  (org-element-map
   tree 'footnote-definition
   (lambda (definition)
     (let ((contents (org-element-contents definition)))
       (when (and contents
                  (cl-every
                   (lambda (node)
                     (or (stringp node)
                         (memq
                          (org-element-type node)
                          org-element-all-objects)))
                   contents))
         (let ((paragraph (org-element-create 'paragraph nil)))
           (apply #'org-element-set-contents paragraph contents)
           (org-element-set-contents definition paragraph))))))
  tree)

(defun org-texmacs--prepared-control-keywords (tree)
  "Remove consumed preparation/configuration directives from owned TREE.
Their effective values already belong to Org INFO.  Keep positional KEYWORDS
while bibliography acquisition remains with standard Org Cite."
  (org-element-map
   tree 'keyword
   (lambda (node)
     (when (member
            (org-element-property :key node)
            (append
             org-texmacs--context-source-keywords
             '("MACRO"
               "PROPERTY"
               "SETUPFILE"
               "INCLUDE"
               "BIND"
               "CITE_EXPORT"
               "BIBLIOGRAPHY")))
       (org-element-extract-element node))))
  tree)

(defun org-texmacs--prepared-affiliation (tree)
  "Project final TREE affiliation for the existing pure lowering contract.
Org has consumed RESULTS.  Derive other affiliations from actual properties,
including positionless nodes, instead of source-position evidence.  Unsupported
affiliations still reach the lowerer's explicit validation."
  (org-element-map
   tree t
   (lambda (node)
     (when (consp node)
       (let (keys)
         (org-element-put-property node :results nil)
         (org-element-properties-mapc
          (lambda (key value _owner)
            (let ((name (upcase (substring (symbol-name key) 1))))
              (when (and value
                         (not
                          (and (eq key :label)
                               (memq
                                (org-element-type node)
                                '(footnote-reference
                                  footnote-definition))))
                         (or (member
                              name org-element-affiliated-keywords)
                             (string-prefix-p "ATTR_" name)))
                (push name keys))))
          node)
         (org-element-put-property
          node
          :texmacs-affiliated-keywords (nreverse keys))
         (org-element-put-property
          node
          :post-affiliated (org-element-property :begin node)))))
   nil nil nil t)
  tree)

(defun org-texmacs--prepared-inline (node tags)
  "Split STM in direct contents of NODE using TAGS.
Return (KEY SOURCE TAG) requests keyed by new text identities.  Org objects
may contribute their interpreted syntax only inside a complete STM string;
ordinary Org objects outside islands remain structured and untouched."
  (when (string-match-p
         (concat "(" (regexp-opt tags t) "[ \t\r\n()]")
         (mapconcat (lambda (child)
                      (if (stringp child)
                          child
                        "\ufffc"))
                    (org-element-contents node)
                    ""))
    (let (parts
          ranges
          (offset 0)
          requests)
      (dolist (child (org-element-contents node))
        (let ((text
               (if (stringp child)
                   child
                 (if (eq (org-element-type child) 'raw)
                     "\ufffc"
                   (condition-case nil
                       (org-element-interpret-data child)
                     (error
                      "\ufffc"))))))
          (push text parts)
          (push (list
                 offset
                 (+ offset (length text))
                 child
                 (equal text "\ufffc"))
                ranges)
          (setq offset (+ offset (length text)))))
      (setq ranges (nreverse ranges))
      (with-temp-buffer
        (insert (apply #'concat (nreverse parts)))
        (goto-char (point-min))
        (let ((regexp (concat "(" (regexp-opt tags t)))
              spans)
          (while-let ((start (org-texmacs--fragment-next regexp)))
            (let* ((tag
                    (buffer-substring-no-properties
                     (1+ start) (point)))
                   (range
                    (cl-find-if
                     (lambda (r)
                       (<= (1+ (nth 0 r)) start (nth 1 r)))
                     ranges)))
              (when (and range (stringp (nth 2 range)))
                (let ((end (org-texmacs--fragment-end start)))
                  (unless end
                    (org-texmacs--prepared-fail
                     "Incomplete prepared STM fragment"))
                  (dolist (r ranges)
                    (unless (or (stringp (nth 2 r))
                                (<= (1+ (nth 1 r)) start)
                                (>= (1+ (nth 0 r)) end))
                      (unless (and
                               (not (nth 3 r))
                               (not
                                (eq
                                 (org-element-type (nth 2 r)) 'raw))
                               (<= start
                                   (1+ (nth 0 r))
                                   (1+ (nth 1 r))
                                   end)
                               (with-syntax-table
                                   org-texmacs--fragment-syntax-table
                                 (and (nth
                                       3
                                       (parse-partial-sexp
                                        start (1+ (nth 0 r))))
                                      (nth
                                       3
                                       (parse-partial-sexp
                                        start (1+ (nth 1 r)))))))
                        (org-texmacs--prepared-fail
                         "STM crosses an Org object boundary"))))
                  (push (list
                         (1- start) (1- end)
                         (buffer-substring-no-properties
                          start end)
                         tag)
                        spans)
                  (goto-char end)))))
          (let ((cursor 0)
                children)
            (cl-labels
             ((ordinary
               (begin end)
               (dolist (r ranges)
                 (let ((lo (max begin (nth 0 r)))
                       (hi (min end (nth 1 r)))
                       (child (nth 2 r)))
                   (when (< lo hi)
                     (push (if (stringp child)
                               (buffer-substring-no-properties
                                (1+ lo) (1+ hi))
                             child)
                           children))))))
             (dolist (span (nreverse spans))
               (ordinary cursor (nth 0 span))
               (let ((leaf (copy-sequence (nth 2 span))))
                 (push leaf children)
                 (push (list leaf leaf (nth 3 span)) requests))
               (setq cursor (nth 1 span)))
             (ordinary cursor offset))
            (apply #'org-element-set-contents
                   node
                   (nreverse children)))))
      (nreverse requests))))

(defun org-texmacs--prepared-discover
    (tree tags &optional defer-notes)
  "Recognize final TREE STM under TAGS, returning (KEY SOURCE TAG) requests.
Native blocks can supply complete :texmacs-source text explicitly.  Otherwise
their final structured contents are interpreted as input syntax, never reread
from potentially stale source positions.  No Org reparsing or export is done."
  (let (requests)
    (cl-labels
     ((walk
       (node)
       (when (consp node)
         (cond
          ((and defer-notes
                (or (eq (org-element-type node) 'footnote-definition)
                    (and (eq (org-element-type node) 'headline)
                         (org-element-property
                          :footnote-section-p node)))))
          ((eq (org-element-type node) 'raw)
           (org-texmacs--prepared-reject-raw node))
          ((org-texmacs--native-body-kind node)
           (org-texmacs--native-body-check node)
           (let ((raw
                  (if (org-element-property :texmacs-source node)
                      (org-element-property :texmacs-source node)
                    (progn
                      (org-texmacs--prepared-reject-raw
                       (org-element-contents node))
                      (org-element-interpret-data
                       (org-element-contents node))))))
             (unless (and (stringp raw) (> (length raw) 0))
               (org-texmacs--prepared-fail
                "Native STM block requires complete input"))
             (push
              (list node (substring-no-properties raw) nil) requests)
             (org-element-set-contents node)))
          ((or (eq (org-element-type node) 'paragraph)
               (and (eq (org-element-type node) 'footnote-reference)
                    (eq (org-element-property :type node) 'inline)))
           (when tags
             (setq requests
                   (append
                    (reverse
                     (org-texmacs--prepared-inline node tags))
                    requests)))
           (mapc #'walk (org-element-contents node)))
          (t
           (mapc #'walk (org-element-contents node))))
         (unless (and defer-notes
                      (or (eq
                           (org-element-type node)
                           'footnote-definition)
                          (org-element-property
                           :footnote-section-p node)))
           (dolist (key
                    (remq
                     :caption
                     (copy-sequence
                      (org-element-property :secondary node))))
             (org-texmacs--prepared-reject-raw
              (org-element-property key node)))
           (dolist (line (org-element-property :caption node))
             (org-texmacs--prepared-reject-raw (car line))
             (org-texmacs--prepared-reject-raw (cdr line)))))))
     (walk tree))
    (nreverse requests)))

(defun org-texmacs--prepared-parse (requests islands)
  "Fill private owned ISLANDS from already discovered REQUESTS.
The caller must own the complete input/context before the first native wait.
No intermediate input or placeholder island may be exposed to consumers."
  (cl-mapc
   (lambda (request island)
     (let ((parsed
            (org-texmacs--worker-request
             (copy-sequence (nth 1 request))))
           (tag (nth 2 request)))
       (when (and tag
                  (not
                   (and (consp parsed)
                        (symbolp (car parsed))
                        (equal tag (symbol-name (car parsed))))))
         (signal 'org-texmacs-parse-error
                 '("TeXmacs root differs from fragment tag")))
       (setcdr island (org-texmacs--document-copy-stree parsed))))
   requests islands))

(provide 'org-texmacs-prepared)
;;; org-texmacs-prepared.el ends here
