;;; org-texmacs-parse.el --- Whole-source mathematical-document parsing -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Construct independent models from complete Org source snapshots.  Source
;; protection and STM discovery do not select an export body or lower content.

;;; Code:

(require 'org-texmacs-model)
(require 'org-texmacs-source)
(require 'org-texmacs-fragment)
(require 'org-texmacs-worker)

(defconst org-texmacs--parse-syntax-variables
  '(org-todo-regexp
    org-todo-keywords
    org-todo-keywords-1
    org-done-keywords
    org-odd-levels-only
    org-priority-regexp
    org-priority-highest
    org-priority-lowest
    org-priority-default
    org-footnote-section
    org-emph-re
    org-verbatim-re
    org-match-substring-regexp
    org-match-substring-with-braces-regexp
    org-entities-user
    org-list-allow-alphabetical
    org-plain-list-ordered-item-terminator
    org-element-affiliated-keywords
    org-element-dual-keywords
    org-element-parsed-keywords
    org-element-multiple-keywords
    org-element-secondary-value-alist
    org-element-keyword-translation-alist
    org-target-link-regexp
    org-target-link-regexps)
  "Effective native syntax retained independently of export configuration.
Only bound variables are captured.  Link types and abbreviations are handled
separately; link follow/export handlers are not syntax and are not captured.")

(defun org-texmacs--parse-copy (value)
  "Own resolved syntax VALUE without callbacks or buffer access."
  (org-texmacs--model-copy-data
   (org-texmacs--model-owner-create) value))

(defun org-texmacs--parse-location (path)
  "Capture source PATH, retaining a model-domain error for invalid context."
  (condition-case err
      (org-texmacs--source-capture-path path)
    (org-texmacs-document-error
     (signal 'org-texmacs-model-error (cdr err)))))

(defun org-texmacs--parse-settings ()
  "Capture effective native Org syntax as explicit variable/value pairs."
  (mapcar
   (lambda (symbol)
     (cons symbol (org-texmacs--parse-copy (symbol-value symbol))))
   (cl-remove-if-not #'boundp org-texmacs--parse-syntax-variables)))

(defun org-texmacs--parse-links ()
  "Capture link names and abbreviations without retaining handler functions."
  (unless (and (proper-list-p org-link-parameters)
               (cl-every
                (lambda (entry)
                  (and (consp entry) (stringp (car entry))))
                org-link-parameters))
    (signal 'org-texmacs-model-error '("Invalid Org link registry")))
  (org-texmacs--parse-copy
   (list
    :types (mapcar #'car org-link-parameters)
    :global org-link-abbrev-alist
    :local org-link-abbrev-alist-local)))

(defun org-texmacs--parse-initialize (settings links tags base)
  "Install owned SETTINGS, LINKS, TAGS and resource BASE in a private buffer.
Call only after initializing an empty Org buffer, before inserting source."
  (dolist (setting settings)
    (set
     (make-local-variable (car setting))
     (org-texmacs--parse-copy (cdr setting))))
  (setq-local org-link-abbrev-alist-local
              (org-texmacs--parse-copy (plist-get links :local)))
  (setq-local org-link-abbrev-alist
              (org-texmacs--parse-copy (plist-get links :global)))
  (setq-local org-link-parameters
              (mapcar
               (lambda (name) (list (copy-sequence name)))
               (plist-get links :types)))
  ;; A let binding made in a buffer with local link settings does not follow
  ;; a switch to another buffer.  Install syntax in each private buffer.
  (dolist (variable
           '(org-link-types-re
             org-link-angle-re
             org-link-plain-re
             org-link-bracket-re
             org-link-any-re
             org-element--object-regexp
             org-element-paragraph-separate))
    (set (make-local-variable variable) (symbol-value variable)))
  (org-link-make-regexps)
  (org-element--set-regexps)
  (setq-local org-texmacs-fragment-tags
              (org-texmacs--parse-copy tags))
  (when base
    (setq-local default-directory (copy-sequence base))))

(defun org-texmacs--parse-mask (begin end replacement)
  "Replace private snapshot interval BEGIN..END with equal-length REPLACEMENT."
  (unless (= (- end begin) (length replacement))
    (signal 'org-texmacs-model-error
            '("Invalid STM protection interval")))
  (goto-char begin)
  (delete-region begin end)
  (insert replacement))

(defun org-texmacs--parse-blocks ()
  "Capture outermost native-block intervals and raw source before protection.
Return records (NODE-BEGIN CONTENTS-BEGIN CONTENTS-END RAW-SOURCE)."
  (mapcar
   (lambda (node)
     (list
      (org-element-property :begin node)
      (org-element-property :contents-begin node)
      (org-element-property :contents-end node)
      (org-texmacs--native-body-source node)))
   (org-texmacs--native-body-blocks
    (org-element-parse-buffer 'element))))

(defun org-texmacs--parse-associate (ast blocks spans source)
  "Associate AST with captured BLOCKS and inline SPANS from SOURCE.
The current private buffer contains equal-length protection.  Return
(ISLANDS REQUESTS); requests reference the island cells that will be filled
after native parsing.  Keep all ordinary Org content and affiliation."
  (let ((remaining spans)
        islands
        requests)
    (cl-labels
     ((register
       (key raw tag)
       (let ((entry (cons key '(concat ""))))
         (push entry islands)
         (push (list entry raw tag) requests)))
      (inline
        (node)
        (let ((begin (org-element-property :contents-begin node))
              (end (org-element-property :contents-end node)))
          (if (not
               (and begin
                    end remaining
                    (< (org-texmacs-fragment-span-begin
                        (car remaining))
                       end)))
              (mapc #'walk (org-element-contents node))
            (let ((position begin)
                  children)
              (dolist (child (org-element-contents node))
                (if (not (stringp child))
                    (progn
                      (walk child)
                      (push child children)
                      (setq position
                            (org-element-property :end child)))
                  (let ((stop (+ position (length child))))
                    (unless (equal
                             (substring-no-properties child)
                             (buffer-substring-no-properties
                              position stop))
                      (signal
                       'org-texmacs-model-error
                       '("Cannot associate STM with normalized Org text")))
                    (while (and remaining
                                (< (org-texmacs-fragment-span-begin
                                    (car remaining))
                                   stop))
                      (let* ((span (pop remaining))
                             (start
                              (org-texmacs-fragment-span-begin span))
                             (finish
                              (org-texmacs-fragment-span-end span)))
                        (unless (<= position start finish stop)
                          (signal
                           'org-texmacs-model-error
                           '("STM crosses an Org object boundary")))
                        (when (< position start)
                          (push (substring source
                                           (1- position)
                                           (1- start))
                                children))
                        (let ((leaf
                               (copy-sequence
                                (org-texmacs-fragment-span-source
                                 span))))
                          (push leaf children)
                          (register
                           leaf
                           leaf
                           (org-texmacs-fragment-span-tag span)))
                        (setq position finish)))
                    (when (< position stop)
                      (push (substring source (1- position) (1- stop))
                            children))
                    (setq position stop))))
              (apply #'org-element-set-contents
                     node
                     (nreverse children))))))
      (walk
       (node)
       (when (consp node)
         (cond
          ((org-texmacs--native-body-kind node)
           (let ((record
                  (assq (org-element-property :begin node) blocks)))
             (unless (and record
                          (equal
                           (nth 1 record)
                           (org-element-property
                            :contents-begin node))
                          (equal
                           (nth 2 record)
                           (org-element-property :contents-end node)))
               (signal
                'org-texmacs-model-error
                '("Native block protection changed its structure")))
             (register node (nth 3 record) nil)
             ;; The tree, not protected text or old Org parsing residue,
             ;; owns the mathematical body.  Keep wrapper properties.
             (org-element-set-contents node)))
          ((or (eq (org-element-type node) 'paragraph)
               (and (eq (org-element-type node) 'footnote-reference)
                    (eq (org-element-property :type node) 'inline)))
           (inline
             node))
          (t
           (mapc #'walk (org-element-contents node)))))))
     (walk ast))
    (when remaining
      (signal 'org-texmacs-model-error
              '("Unassociated STM source spans")))
    (list (nreverse islands) (nreverse requests))))

(defun org-texmacs--parse-prepare
    (source settings links tags base context)
  "Build detached structural input for SOURCE under fixed syntax CONTEXT.
Protect raw native bodies and recognized inline spans before the full parse.
No export selection, dependency acquisition or native operation runs here."
  (let ((org-link-parameters
         (mapcar
          (lambda (name)
            (list (copy-sequence name)))
          (plist-get links :types)))
        (org-link-abbrev-alist
         (org-texmacs--parse-copy (plist-get links :global)))
        (org-link-types-re org-link-types-re)
        (org-link-angle-re org-link-angle-re)
        (org-link-plain-re org-link-plain-re)
        (org-link-bracket-re org-link-bracket-re)
        (org-link-any-re org-link-any-re)
        (org-element--object-regexp org-element--object-regexp)
        (org-element-paragraph-separate
         org-element-paragraph-separate))
    (cl-progv
     (mapcar #'car settings)
     (mapcar #'cdr settings)
     (org-link-make-regexps)
     (org-element--set-regexps)
     (with-temp-buffer
       (let ((org-element-use-cache nil)
             (org-inhibit-startup t)
             (change-major-mode-hook nil)
             (after-change-major-mode-hook nil))
         (delay-mode-hooks
           (org-mode))
         (org-texmacs--parse-initialize settings links tags base)
         (insert source)
         (let ((blocks (org-texmacs--parse-blocks)))
           (dolist (record blocks)
             (when (nth 1 record)
               (org-texmacs--parse-mask
                (nth 1 record) (nth 2 record)
                (replace-regexp-in-string
                 "[^ \t\r\n]" "x" (nth 3 record)))))
           (let ((spans
                  (org-texmacs--fragment-collect
                   tags
                   (lambda ()
                     (org-texmacs--parse-initialize
                      settings links tags base)))))
             (dolist (span spans)
               (org-texmacs--parse-mask
                (org-texmacs-fragment-span-begin span)
                (org-texmacs-fragment-span-end span)
                (org-texmacs--fragment-mask
                 (org-texmacs-fragment-span-source span))))
             (let* ((ast (org-element-parse-buffer))
                    (prepared
                     (org-texmacs--parse-associate
                      ast blocks spans source))
                    (model
                     (org-texmacs-model-create
                      ast
                      :islands (car prepared)
                      :context context)))
               (list
                model
                (cl-mapcar
                 (lambda (request owned-entry)
                   (list owned-entry (nth 1 request) (nth 2 request)))
                 (cadr prepared)
                 (org-texmacs-model-islands model)))))))))))

;;;###autoload
(defun org-texmacs-parse-buffer (source-buffer)
  "Parse complete Org SOURCE-BUFFER into an independent mathematical model.
Capture full source and effective syntax without changing point, mark, text,
properties or narrowing.  Original narrowing does not select a model body.
Parse recognized texmacs/equation/equation* blocks and configured paragraph
and direct inline-footnote fragments with the native STM worker.  Preserve
unrecognized contexts as ordinary Org, including titles, captions and code.

Keep comments, drawers, all footnote definitions and export-excluded content.
Do not run INCLUDE, Babel, export preprocessing/filters, Cite processors,
bibliography acquisition/formatting, reference resolution or document lowering.
Native block parameters and affiliation are retained without target validation.
Parsed STM trees own island content; raw block parsing residue is discarded.
The returned model needs no live source buffer or worker.

Capture syntax/source CONTEXT explicitly and reject source, mode, narrowing,
location or effective syntax changes across native waits.  Source changes by
external callbacks are not rolled back.  Native parse/transport errors retain
their existing conditions; structural/snapshot failures use
`org-texmacs-model-error'.  User-defined native Org parser callbacks are not
sandboxed.  Core constructor/inspection operations do not need this worker."
  (unless (and (bufferp source-buffer) (buffer-live-p source-buffer))
    (signal 'org-texmacs-model-error
            '("Expected a live Org source buffer")))
  (with-current-buffer source-buffer
    (unless (derived-mode-p 'org-mode)
      (signal 'org-texmacs-model-error
              '("Expected an Org source buffer")))
    (let* ((mode major-mode)
           (tick (buffer-chars-modified-tick))
           (bounds (cons (point-min) (point-max)))
           (file (buffer-file-name (buffer-base-buffer)))
           (directory default-directory)
           (tags (org-texmacs--fragment-tags))
           (settings (org-texmacs--parse-settings))
           (links (org-texmacs--parse-links))
           (source
            (save-restriction
              (widen)
              (buffer-substring-no-properties
               (point-min) (point-max))))
           (context
            (list
             :fragment-tags tags
             :heading-settings settings
             :link-settings links
             :source-file (org-texmacs--parse-location file)
             :resource-base (org-texmacs--parse-location directory))))
      ;; Keep source identities independent from mutable caller strings.
      (setq
       file (and file (substring-no-properties file))
       directory (and directory (substring-no-properties directory)))
      (cl-labels
       ((check
         ()
         (unless (buffer-live-p source-buffer)
           (signal 'org-texmacs-model-error
                   '("Source buffer was killed")))
         (with-current-buffer source-buffer
           (unless (and (eq major-mode mode)
                        (derived-mode-p 'org-mode)
                        (= tick (buffer-chars-modified-tick))
                        (equal bounds (cons (point-min) (point-max)))
                        (equal
                         file (buffer-file-name (buffer-base-buffer)))
                        (equal directory default-directory)
                        (equal tags (org-texmacs--fragment-tags))
                        (equal settings (org-texmacs--parse-settings))
                        (equal links (org-texmacs--parse-links)))
             (signal
              'org-texmacs-model-error
              '("Source or syntax changed during model parsing"))))))
       (check)
       (let* ((prepared
               (org-texmacs--parse-prepare
                source
                settings
                links
                tags
                (plist-get context :resource-base)
                context))
              (model (car prepared)))
         (check)
         (dolist (request (cadr prepared))
           (check)
           (let ((tree
                  (org-texmacs--worker-request
                   (copy-sequence (nth 1 request))))
                 (tag (nth 2 request)))
             (check)
             (when (and tag
                        (not
                         (and (consp tree)
                              (symbolp (car tree))
                              (equal tag (symbol-name (car tree))))))
               (signal 'org-texmacs-parse-error
                       '("TeXmacs root differs from fragment tag")))
             (setcdr
              (car request) (org-texmacs--model-copy-stree tree))))
         (check)
         model)))))

(provide 'org-texmacs-parse)
;;; org-texmacs-parse.el ends here
