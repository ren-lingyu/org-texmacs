;;; org-texmacs-fragment-object.el --- Scoped STM Org objects -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Explicit STM carriers are nonrecursive Org objects.  Recognition uses Org's
;; latex-fragment dispatch and container restrictions, without changing ordinary
;; Org parsing outside a synchronous scope.  Lexical recognition is independent
;; of native STM validation and never starts a worker.
;;
;; Use `org-texmacs--call-with-ast-context' for Org traversal, copy and
;; interpretation of extended ASTs.  Org's copy semantics are not model ownership.

;;; Code:

(require 'org)
(require 'org-texmacs-core)
(require 'org-texmacs-source)
(require 'org-texmacs-syntax)

(defvar org-texmacs--fragment-object-active nil
  "Non-nil in a synchronous extended-AST transaction.
Export integration may suspend this binding for another backend.")

(defvar org-texmacs--fragment-object-org-context nil
  "Org settings to restore for another backend inside a TeXmacs export.")

(defconst org-texmacs--fragment-object-syntax-table
  (let ((table (make-syntax-table)))
    (dolist (character '(?\[ ?\] ?\{ ?\} ?\; ?# ?\' ?` ?, ?|))
      (modify-syntax-entry character "." table))
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)
    table)
  "STM lexical boundaries only; this is not a Scheme or STM reader.")

(defun org-texmacs--fragment-object-scan (start limit)
  "Return (END SOURCE) for an explicit compound carrier at START.
LIMIT is the owning Org container's accessible end.  Require an immediate
closing carrier after one balanced compound datum.  Only parentheses, strings
and escapes are recognized here; native STM validity belongs to conversion.
Signal `org-texmacs-parse-error' for a recognized incomplete carrier."
  (save-excursion
    (goto-char start)
    (let* ((dollar (looking-at-p (regexp-quote "$(")))
           (slash (looking-at-p (regexp-quote "\\((")))
           (offset
            (if dollar
                1
              2))
           (close
            (if dollar
                "$"
              "\\)"))
           end)
      (unless (or dollar slash)
        (signal 'org-texmacs-parse-error
                '("Expected an STM carrier")))
      (save-restriction
        (narrow-to-region start limit)
        (with-syntax-table org-texmacs--fragment-object-syntax-table
          (let ((parse-sexp-lookup-properties nil)
                (parse-sexp-ignore-comments nil))
            (setq end
                  (condition-case nil
                      (scan-sexps (+ start offset) 1)
                    (scan-error
                     nil))))))
      (unless (and end (<= (+ end (length close)) limit))
        (signal 'org-texmacs-parse-error
                (list
                 "Incomplete STM carrier in Org container" start)))
      (goto-char end)
      (unless (looking-at-p (regexp-quote close))
        (signal
         'org-texmacs-parse-error
         (list
          "Expected STM closing delimiter immediately after tree"
          start)))
      (list
       (+ end (length close))
       (buffer-substring-no-properties (+ start offset) end)))))

(defun org-texmacs--fragment-object-parser (original &rest arguments)
  "Adapt ORIGINAL with ARGUMENTS only in an extended-AST transaction.
Org owns the dispatch, opaque regions, recursive nesting and narrowing.
Org 9.8.10 org-element--parse-objects narrows to BEG/END before calling the
object lexer, including secondary strings; point-max is that container bound."
  (if (and org-texmacs--fragment-object-active
           (or (looking-at-p (regexp-quote "$("))
               (looking-at-p (regexp-quote "\\(("))))
      (save-match-data
        (let* ((start (point))
               (span
                (org-texmacs--fragment-object-scan start (point-max)))
               (end (car span))
               (post
                (save-excursion
                  (goto-char end)
                  (skip-chars-forward " \t"))))
          (org-element-create
           'stm-fragment
           (list
            :begin start
            :end (+ end post)
            :post-blank post
            :stm-source (cadr span)))))
    (apply original arguments)))

(defun org-texmacs--fragment-object-parse-elements
    (original
     beg end mode structure granularity visible-only accumulator)
  "Let ORIGINAL parse native block bodies without STM carrier recognition.
Org parses a block's affiliation before descending into its body."
  (let ((org-texmacs--fragment-object-active
         (and org-texmacs--fragment-object-active
              (not (org-texmacs--native-body-kind accumulator)))))
    (funcall original
             beg
             end
             mode
             structure
             granularity
             visible-only
             accumulator)))

(defun org-texmacs--fragment-object-interpreter (node _contents)
  "Normalize the lexically complete STM carrier NODE.
This does not certify native STM validity or safe embedding in every container."
  (let ((source (org-element-property :stm-source node)))
    (unless (and (stringp source) (not (org-element-contents node)))
      (signal 'org-texmacs-model-error
              '("Expected a nonrecursive STM object with source")))
    (let ((text (concat "\\(" source "\\)")))
      (condition-case err
          (with-temp-buffer
            (insert text)
            (let ((span
                   (org-texmacs--fragment-object-scan
                    (point-min) (point-max))))
              (unless (= (car span) (point-max))
                (signal 'org-texmacs-parse-error
                        '("Extra data in STM fragment source")))))
        (org-texmacs-parse-error
         (signal (car err) (cdr err))))
      text)))

(defun org-texmacs--call-with-ast-context (function)
  "Call zero-argument FUNCTION with scoped extended Org AST support.
Register nonrecursive `stm-fragment' wherever Org permits `latex-fragment'.
Bind the registry, restrictions and interpreter locally; restore parser advice
on normal, nested and exceptional exits.  Disable live Org caching within the
scope so extended objects cannot enter another backend's cache.  Loading this
module alone changes no parser or backend.  Never start a native worker."
  (let* ((org-texmacs--fragment-object-org-context
          (or org-texmacs--fragment-object-org-context
              (list
               org-element-all-objects
               org-element-object-restrictions
               org-element-use-cache
               (and (fboundp 'org-element-stm-fragment-interpreter)
                    (symbol-function
                     'org-element-stm-fragment-interpreter)))))
         (org-texmacs--fragment-object-active t)
         (org-element-use-cache nil)
         (org-element-all-objects
          (cons
           'stm-fragment
           (remq 'stm-fragment org-element-all-objects)))
         (org-element-object-restrictions
          (mapcar
           (lambda (entry)
             (if (memq 'latex-fragment (cdr entry))
                 (cons
                  (car entry)
                  (cons
                   'stm-fragment (remq 'stm-fragment (cdr entry))))
               entry))
           org-element-object-restrictions))
         installed)
    (unwind-protect
        (progn
          (dolist (binding
                   '((org-element-latex-fragment-parser
                      . org-texmacs--fragment-object-parser)
                     (org-element--parse-elements
                      . org-texmacs--fragment-object-parse-elements)))
            (unless (advice-member-p (cdr binding) (car binding))
              (advice-add (car binding) :around (cdr binding))
              (push binding installed)))
          (cl-letf (((symbol-function
                      'org-element-stm-fragment-interpreter)
                     #'org-texmacs--fragment-object-interpreter))
            (funcall function)))
      (dolist (binding installed)
        (advice-remove (car binding) (cdr binding))))))

(defun org-texmacs--call-without-ast-context (function)
  "Call FUNCTION with the Org settings outside the current fragment scope."
  (if (not org-texmacs--fragment-object-org-context)
      (funcall function)
    (pcase-let* ((`(,objects ,restrictions ,cache ,interpreter)
                  org-texmacs--fragment-object-org-context)
                 (org-texmacs--fragment-object-active nil)
                 (org-texmacs--fragment-object-org-context nil)
                 (org-element-all-objects objects)
                 (org-element-object-restrictions restrictions)
                 (org-element-use-cache cache))
      (cl-letf (((symbol-function
                  'org-element-stm-fragment-interpreter)
                 interpreter))
        (funcall function)))))

(defun org-texmacs--ast-parse-buffer (source-buffer)
  "Return an independent extended Org AST for complete SOURCE-BUFFER.
Require a live Org buffer.  Preserve its point, mark, text, properties and
narrowing.  Use effective Org syntax, ignoring narrowing as body selection.
Store independent :org-texmacs-syntax metadata on the root; this is not
document content and never retains a live source buffer.
The caller owns the returned mutable AST, including native secondary strings;
no live source buffer is needed afterward.  Preserve Org's native parent forms.
Never run Export preparation, STM validation, file lookup or a native worker.
Malformed recognized carriers signal `org-texmacs-parse-error'.  Invalid buffer
arguments signal `org-texmacs-model-error'.  Custom Org callbacks are not
sandboxed.  Use `org-texmacs--call-with-ast-context' for later Org operations."
  (unless (and (bufferp source-buffer)
               (buffer-live-p source-buffer)
               (with-current-buffer source-buffer
                 (derived-mode-p 'org-mode)))
    (signal 'org-texmacs-model-error
            '("Expected a live Org source buffer")))
  (with-current-buffer source-buffer
    (save-excursion
      (save-restriction
        (save-match-data
          (widen)
          (let ((syntax (org-texmacs--syntax-capture)))
            (org-texmacs--call-with-ast-context
             (lambda ()
               (let ((ast (org-element-parse-buffer)))
                 ;; Org resolves deferred values before returning.  Drop its
                 ;; transient source handles, including those on secondary nodes.
                 (org-element-map
                  ast t
                  (lambda (node)
                    (org-element-put-property node :buffer nil))
                  nil nil nil t)
                 (org-element-put-property
                  ast
                  :org-texmacs-syntax syntax)
                 ast)))))))))

(provide 'org-texmacs-fragment-object)

;;; org-texmacs-fragment-object.el ends here
