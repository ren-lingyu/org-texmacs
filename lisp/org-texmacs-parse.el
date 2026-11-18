;;; org-texmacs-parse.el --- Whole-source mathematical-document parsing -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Construct independent models from complete Org source snapshots.  Source
;; protection and STM discovery do not select an export body or lower content.

;;; Code:

(require 'org-texmacs-model)
(require 'org-texmacs-syntax)
(require 'org-texmacs-source)
(require 'org-texmacs-fragment-object)
(require 'org-texmacs-worker)

(defun org-texmacs--parse-copy (value)
  "Own resolved syntax VALUE without callbacks or buffer access."
  (org-texmacs--syntax-copy value))

(defun org-texmacs--parse-location (path)
  "Capture source PATH, retaining a model-domain error for invalid context."
  (condition-case err
      (org-texmacs--source-capture-path path)
    (org-texmacs-document-error
     (signal 'org-texmacs-model-error (cdr err)))))

(defun org-texmacs--parse-initialize (settings links base)
  "Install owned SETTINGS, LINKS and resource BASE in a private buffer.
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

(defun org-texmacs--parse-block-request (node blocks)
  "Collect the native body request for NODE from protected BLOCKS."
  (let ((record (assq (org-element-property :begin node) blocks)))
    (unless (and record
                 (equal
                  (nth 1 record)
                  (org-element-property :contents-begin node))
                 (equal
                  (nth 2 record)
                  (org-element-property :contents-end node)))
      (signal 'org-texmacs-model-error
              '("Native block protection changed its structure")))
    ;; The STM tree owns the body. Preserve the wrapper and affiliation.
    (org-element-set-contents node)
    (cons node (nth 3 record))))

(defun org-texmacs--parse-object-requests (ast blocks)
  "Collect source requests from recognized AST and captured native BLOCKS."
  (org-texmacs--call-with-ast-context
   (lambda ()
     (org-element-map
      ast '(stm-fragment special-block)
      (lambda (node)
        (cond
         ((eq (org-element-type node) 'stm-fragment)
          (cons node (org-element-property :stm-source node)))
         ((org-texmacs--native-body-kind node)
          (org-texmacs--parse-block-request node blocks))))
      nil nil nil t))))

(defun org-texmacs--parse-prepare (source settings links base)
  "Return (AST REQUESTS) for SOURCE under fixed SETTINGS, LINKS and BASE.
Protect raw native bodies before recognizing explicit carriers.
No Model, export selection, dependency acquisition or native operation runs
here."
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
         (org-texmacs--parse-initialize settings links base)
         (insert source)
         (let ((blocks (org-texmacs--parse-blocks)))
           (dolist (record blocks)
             (when (nth 1 record)
               (org-texmacs--parse-mask
                (nth 1 record) (nth 2 record)
                (replace-regexp-in-string
                 "[^ \t\r\n]" "x" (nth 3 record)))))
           (let ((ast
                  (org-texmacs--ast-parse-buffer (current-buffer))))
             (list
              ast
              (org-texmacs--parse-object-requests ast blocks)))))))))


;;;###autoload
(defun org-texmacs-parse-buffer (source-buffer)
  "Parse complete Org SOURCE-BUFFER into an independent mathematical model.
Capture full source and effective syntax without changing point, mark, text,
properties or narrowing.  Original narrowing does not select a model body.
Parse explicit STM fragment carriers and native texmacs/equation/equation*
blocks using the native STM worker.  Use Org's LaTeX-fragment positions and
composition rules.  Preserve opaque Org regions as ordinary Org.

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
           (settings (org-texmacs--parse-settings))
           (links (org-texmacs--parse-links))
           (source
            (save-restriction
              (widen)
              (buffer-substring-no-properties
               (point-min) (point-max))))
           (context
            (list
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
                (plist-get context :resource-base)))
              islands)
         (check)
         (dolist (request (cadr prepared))
           (check)
           (let ((tree
                  (org-texmacs--worker-request
                   (copy-sequence (cdr request)))))
             (check)
             ;; Own each result before the next native wait.
             (push (cons
                    (car request)
                    (org-texmacs--model-copy-stree tree))
                   islands)))
         (check)
         (org-texmacs-model-create
          (car prepared)
          :islands (nreverse islands)
          :context context))))))

(provide 'org-texmacs-parse)
;;; org-texmacs-parse.el ends here
