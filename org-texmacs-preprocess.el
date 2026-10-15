;;; org-texmacs-preprocess.el --- Bounded owned Org composition -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;; Native INCLUDE consumes fixed source snapshots in a private transaction.
;; Line-preserving STM protection keeps native parameter semantics separate
;; from final AST construction; general original provenance is not required.

;;; Code:

(require 'org-texmacs)
(require 'org-texmacs-bibliography)

(defvar org-texmacs--preprocess-stage-functions nil
  "Private captured hooks, separate from generic export hook variables.")

(defun org-texmacs--preprocess-fail (message)
  "Reject unsupported or inconsistent composition with MESSAGE."
  (signal 'org-texmacs-document-error (list message)))

(defun org-texmacs--preprocess-hooks ()
  "Capture effective preprocessing hook values and function identities."
  (mapcar
   (lambda (name)
     (let ((value (symbol-value name)) (global (default-value name)) functions)
       (unless (and (proper-list-p value) (proper-list-p global))
         (org-texmacs--preprocess-fail "Expected preprocessing hook lists"))
       (dolist (item value)
         (setq functions (append functions (if (eq item t) global (list item)))))
       (unless (cl-every #'functionp functions)
         (org-texmacs--preprocess-fail "Invalid preprocessing hook function"))
       (list (org-texmacs--context-filter-copy value)
             (org-texmacs--context-filter-copy global)
             (mapcar (lambda (function)
                       (cons function (if (symbolp function)
                                          (symbol-function function) function)))
                     functions))))
   '(org-export-before-processing-functions org-export-before-parsing-functions)))

(defun org-texmacs--preprocess-hooks-same-p (left right)
  "Compare captured LEFT and RIGHT hook configuration and resolved functions."
  (cl-every
   (lambda (pair)
     (let ((a (car pair)) (b (cdr pair)))
       (and (equal (car a) (car b)) (equal (cadr a) (cadr b))
            (= (length (nth 2 a)) (length (nth 2 b)))
            (cl-every #'eq (mapcar #'cdr (nth 2 a)) (mapcar #'cdr (nth 2 b))))))
   (cl-mapcar #'cons left right)))

(defun org-texmacs--preprocess-reject-generic (backend)
  "Keep generic export of TeXmacs BACKEND rejected in private working views."
  (when (org-export-derived-backend-p backend 'texmacs)
    (org-texmacs--preprocess-fail "Use the explicit preprocessing adapter")))

(defun org-texmacs--preprocess-private-state ()
  "Own supported configuration for a private hook's validation boundary."
  (list major-mode (org-texmacs--document-heading-settings)
        (org-texmacs--document-link-settings) (org-texmacs--document-options)
        (org-texmacs--fragment-tags)
        (org-texmacs--document-copy-style org-texmacs-document-style)
        (org-texmacs--document-copy-initial org-texmacs-document-initial)
        (and buffer-file-name (copy-sequence buffer-file-name))
        (copy-sequence default-directory)
        (org-texmacs--context-filter-copy org-export-filter-parse-tree-functions)))

(defun org-texmacs--preprocess-stage (state check)
  "Run captured hook STATE once under original transaction CHECK."
  (let ((buffer (current-buffer))
        (configuration (org-texmacs--preprocess-private-state))
        (org-export-current-backend 'texmacs)
        (org-texmacs--preprocess-stage-functions
         (mapcar #'cdr
                 (cl-remove-if
                  (lambda (pair)
                    (eq (car pair) 'org-texmacs--export-reject-generic-preprocessing))
                  (nth 2 state)))))
    (funcall check)
    ;; This bounded stage uses native hook return/order semantics, while the
    ;; original hook variables still protect nested generic exporter calls.
    (let ((functions org-texmacs--preprocess-stage-functions))
      (setq org-texmacs--preprocess-stage-functions
            (mapcar
             (lambda (function)
               (lambda (backend)
                 (funcall check)
                 (funcall function backend)
                 (unless (and (eq buffer (current-buffer)) (buffer-live-p buffer)
                              (not (buffer-narrowed-p))
                              (equal configuration (org-texmacs--preprocess-private-state)))
                   (org-texmacs--preprocess-fail "Preprocessing hook changed private configuration"))
                 (funcall check))) functions))
      (run-hook-with-args 'org-texmacs--preprocess-stage-functions 'texmacs))
    (unless (and (eq buffer (current-buffer)) (buffer-live-p buffer)
                 (not (buffer-narrowed-p))
                 (equal configuration (org-texmacs--preprocess-private-state))
                 (eq org-export-current-backend 'texmacs)
                 (not org-export-use-babel) (not org-export-allow-bind-keywords)
                 (not org-export-replace-macros))
      (org-texmacs--preprocess-fail "Preprocessing hook changed private configuration"))
    (funcall check)))

(defun org-texmacs--preprocess-context (tags headings links info file base filter-value)
  "Initialize a private parser with TAGS, HEADINGS, LINKS and INFO.
FILE and BASE preserve source context.  FILTER-VALUE is captured configuration."
  (delay-mode-hooks (org-mode))
  (setq-local default-directory (copy-sequence base))
  (setq-local buffer-file-name (and file (copy-sequence file)))
  (setq-local org-texmacs-fragment-tags (mapcar #'copy-sequence tags))
  (setq-local tab-width (plist-get info :texmacs-tab-width))
  (org-texmacs--document-use-heading-settings headings)
  (setq-local org-link-parameters (org-texmacs--document-copy-link-setting (nth 0 links)))
  (setq-local org-link-abbrev-alist (org-texmacs--document-copy-link-setting (nth 1 links)))
  (setq-local org-link-abbrev-alist-local (org-texmacs--document-copy-link-setting (nth 2 links)))
  (dolist (variable '(org-link-types-re org-link-angle-re org-link-plain-re
                     org-link-bracket-re org-link-any-re org-element--object-regexp
                     org-element-paragraph-separate))
    (make-local-variable variable))
  (org-link-make-regexps) (org-element--set-regexps)
  (dolist (option org-texmacs--context-option-alist)
    (when-let* ((variable (nth 3 option)))
      (set (make-local-variable variable)
           (if (eq variable 'user-full-name)
               (org-element-interpret-data (plist-get info (car option)))
             (org-texmacs--context-copy (plist-get info (car option)))))))
  (setq-local org-export-filter-parse-tree-functions
              (org-texmacs--context-filter-copy filter-value))
  (setq-local org-export-before-processing-functions
              (cons #'org-texmacs--preprocess-reject-generic
                    (copy-sequence org-export-before-processing-functions))))

(defun org-texmacs--preprocess-compose
    (source tags headings links info source-file base check hooks)
  "Compose SOURCE with native INCLUDE and fixed owned dependency reads.
TAGS, HEADINGS, LINKS, INFO, SOURCE-FILE and BASE are captured context.
CHECK and HOOKS guard the original transaction.
Return working text and receipts."
  (unless (and base (not (nth 2 headings))
               (not (default-value 'org-odd-levels-only)))
    (org-texmacs--preprocess-fail "Composition needs a local base and ordinary headline levels"))
  (org-texmacs--bibliography-local-path base base)
  (setq base (file-name-as-directory base))
  (when source-file
    (org-texmacs--bibliography-local-path source-file base)
    (unless (equal (file-name-directory source-file) base)
      (org-texmacs--preprocess-fail "Composition source directory conflicts with resource base")))
  (let* ((nonce (substring (secure-hash 'sha256 (format "%s%s" source (float-time))) 0 20))
         (org-mode-hook nil) (change-major-mode-hook nil) (after-change-major-mode-hook nil)
         (delay-mode-hooks t) (org-inhibit-startup t) (org-element-use-cache nil)
         (kill-buffer-query-functions nil) (kill-buffer-hook nil)
         (org-export-use-babel nil) (org-export-allow-bind-keywords nil)
         (org-export-replace-macros nil)
         (filter-value (org-texmacs--context-filter-copy org-export-filter-parse-tree-functions))
         (style (org-texmacs--document-copy-style org-texmacs-document-style))
         (initial (org-texmacs--document-copy-initial org-texmacs-document-initial))
         (backend (car (org-texmacs--context-filter-state)))
         (expand (symbol-function 'org-export-expand-include-keyword))
         (parser (symbol-function 'org-export-parse-include-value))
         (prepare (symbol-function 'org-export--prepare-file-contents))
         (reader (symbol-function 'org-file-contents))
         (active-reader reader)
         (native-functions
          (mapcar (lambda (name) (cons name (symbol-function name)))
                  '(org-file-contents org-export-parse-include-value
                    org-export--prepare-file-contents org-export-expand-include-keyword
                    org-export--inclusion-absolute-lines)))
         (active-functions native-functions)
         (depth -1) (occurrences 1) (total (string-bytes source))
         cache receipts payloads physical)
    (when (> total 262144) (org-texmacs--preprocess-fail "Source exceeds 256 KiB"))
    (when source-file
      (let ((attrs (file-attributes source-file 'integer)))
        (when attrs
          (unless (null (file-attribute-type attrs))
            (org-texmacs--preprocess-fail "Visiting source identity must be regular or absent"))
          (push (list (file-attribute-inode-number attrs)
                      (file-attribute-device-number attrs)) physical))))
    (cl-labels
        ((guard ()
           (funcall check)
           (unless (and (not (default-value 'org-odd-levels-only))
                        (eq active-reader (symbol-function 'org-file-contents))
                        (cl-every (lambda (entry)
                                    (eq (cdr entry) (symbol-function (car entry))))
                                  active-functions))
             (org-texmacs--preprocess-fail "Native composition configuration changed"))
           (org-texmacs--bibliography-check-receipts receipts))
         (context (file)
           (org-texmacs--preprocess-context
            tags headings links info file (if file (file-name-directory file) base) filter-value)
           (setq-local org-texmacs-document-style (copy-sequence style))
           (setq-local org-texmacs-document-initial (org-texmacs--context-copy initial)))
         (protect ()
           (when (string-match-p nonce (buffer-string))
             ;; Existing tokens are allowed on the root's second protection pass.
             (let ((text (buffer-string)))
               (dolist (payload payloads)
                 (setq text (replace-regexp-in-string
                             (regexp-quote (car payload)) "" text t t)))
               (when (string-match-p nonce text)
                 (org-texmacs--preprocess-fail "Reserved STM marker in source"))))
           (let ((spans (mapcar (lambda (span)
                                 (cons (org-texmacs-fragment-span-begin span)
                                       (org-texmacs-fragment-span-end span)))
                               (org-texmacs--fragment-collect tags))))
             (org-element-map (org-element-parse-buffer) 'special-block
               (lambda (node)
                 (when (org-texmacs--block-p node)
                   (push (cons (org-element-property :begin node)
                               (org-element-property :end node)) spans))))
             (dolist (span (sort spans (lambda (a b) (> (car a) (car b)))))
               (let* ((raw (buffer-substring-no-properties (car span) (cdr span)))
                      (id (length payloads))
                      (start (format "TXMB%sX%dA" nonce id))
                      (end (format "TXME%sX%dZ" nonce id))
                      (newlines (cl-count ?\n raw))
                      (trailing (string-suffix-p "\n" raw))
                      (token (concat start (make-string (- newlines (if trailing 1 0)) ?\n)
                                     end (if trailing "\n" ""))))
                 (push (list token raw start end) payloads)
                 (delete-region (car span) (cdr span)) (goto-char (car span))
                 (insert token)))
             spans))
         (capture (file)
           (guard)
           (setq file (org-texmacs--bibliography-local-path file base))
           (or (cdr (assoc file cache))
               (let* ((attrs (org-texmacs--bibliography-file-attributes file))
                      (identity (nthcdr 3 attrs)))
                 (when (or (> (car attrs) 65536) (member identity physical))
                   (org-texmacs--preprocess-fail "Large include or ambiguous physical source alias"))
                 (let* ((bytes (org-texmacs--bibliography-file-bytes file))
                        (after (org-texmacs--bibliography-file-attributes file))
                        (text (decode-coding-string bytes 'utf-8-unix)))
                   (guard)
                   (unless (and (equal attrs after) (<= (length bytes) 65536)
                                (equal bytes (encode-coding-string text 'utf-8-unix))
                                (not (cl-some (lambda (c) (> c #x10ffff)) text)))
                     (org-texmacs--preprocess-fail "Changed or non-UTF-8 include"))
                   (cl-incf total (length bytes))
                   (when (> total 262144) (org-texmacs--preprocess-fail "Source budget exceeded"))
                   (push identity physical)
                   (push (list (copy-sequence file) attrs (secure-hash 'sha256 bytes)) receipts)
                   (with-temp-buffer
                     (let ((work-buffer (current-buffer)))
                       (unwind-protect
                           (progn
                             (context file) (insert text)
                             (let ((spans (protect)))
                               (let ((entry (list text (buffer-string) spans)))
                                 (push (cons file entry) cache) entry)))
                         ;; Retire this owned view's file identity.
                         (when (buffer-live-p work-buffer)
                           (with-current-buffer work-buffer
                             (setq-local buffer-file-name nil))))))))))
         (selection (entry lines)
           (when lines
             (with-temp-buffer
               (insert (car entry))
               (let* ((ends (split-string lines "-"))
                      (first (string-to-number (car ends)))
                      (last (string-to-number (cadr ends)))
                      (begin (progn (goto-char (point-min))
                                    (unless (zerop first) (forward-line (1- first))) (point)))
                      (end (if (zerop last) (point-max)
                             (goto-char (point-min)) (forward-line (1- last)) (point))))
                 (dolist (span (nth 2 entry))
                   (when (and (< (car span) end) (> (cdr span) begin)
                              (not (and (<= begin (car span)) (>= end (cdr span)))))
                     (org-texmacs--preprocess-fail "INCLUDE selection truncates STM")))))))
         (counts ()
           (mapcar (lambda (payload)
                     (save-excursion
                       (goto-char (point-min))
                       (let ((count 0))
                         (while (search-forward (car payload) nil t) (cl-incf count)) count)))
                   payloads)))
      (with-temp-buffer
        (let ((work-buffer (current-buffer)))
          (unwind-protect
              (progn
                (context source-file) (insert source) (protect)
                (let ((before (counts)))
                  (org-texmacs--preprocess-stage (car hooks) #'guard)
                  (unless (equal before (counts))
                    (org-texmacs--preprocess-fail "Preprocessing changed protected STM")))
                (protect)
                (when (> (string-bytes (buffer-string)) 262144)
                  (org-texmacs--preprocess-fail "Protected root working budget exceeded"))
                ;; Scoped reader substitution preserves native paths and line selection.
                ;; It does not persistently advise Org or service unrelated callers.
                (let ((org-export-registered-backends (cons backend org-export-registered-backends)))
                  (cl-letf (((symbol-function 'org-export-parse-include-value)
                             (lambda (value &optional directory)
                               (when (string-match-p "\\`[ \t]*\"?~" value)
                                 (org-texmacs--preprocess-fail "Tilde include paths are unsupported"))
                               (let* ((parameters (funcall parser value directory))
                                      (file (plist-get parameters :file)))
                                 (unless (and file (not (plist-get parameters :env))
                                              (not (plist-get parameters :block))
                                              (not (plist-get parameters :coding-system))
                                              (not (plist-get parameters :unmatched))
                                              (or (not (plist-get parameters :minlevel))
                                                  (> (plist-get parameters :minlevel) 0)))
                                   (org-texmacs--preprocess-fail "Unsupported INCLUDE parameters"))
                                 (org-texmacs--bibliography-local-path file base)
                                 (cl-incf occurrences)
                                 (when (> occurrences 32) (org-texmacs--preprocess-fail "Occurrence budget exceeded"))
                                 (capture file) parameters)))
                            ((symbol-function 'org-file-contents)
                             (lambda (file &optional _noerror _nocache)
                               (copy-sequence (cadr (capture file)))))
                            ((symbol-function 'org-export--prepare-file-contents)
                             (lambda (file &optional lines ind level id footnotes includer)
                               (selection (capture file) lines)
                               (funcall prepare file lines ind level id footnotes includer)))
                            ((symbol-function 'org-export-expand-include-keyword)
                             (lambda (&rest args)
                               (cl-incf depth)
                               (unwind-protect
                                   (progn
                                     (when (> depth 8) (org-texmacs--preprocess-fail "Include depth exceeded"))
                                     (apply expand args))
                                 (cl-decf depth)))))
                    (setq active-reader (symbol-function 'org-file-contents))
                    (setq active-functions
                          (mapcar (lambda (entry)
                                    (cons (car entry) (symbol-function (car entry)))) native-functions))
                    (condition-case err
                        (org-export-expand-include-keyword nil base nil source-file)
                      (org-texmacs-document-error (signal (car err) (cdr err)))
                      (error (org-texmacs--preprocess-fail (error-message-string err))))))
                (setq active-reader reader)
                (setq active-functions native-functions)
                (guard)
                (let ((before (counts)))
                  (org-texmacs--preprocess-stage (cadr hooks) #'guard)
                  (unless (equal before (counts))
                    (org-texmacs--preprocess-fail "Preprocessing changed protected STM")))
                (org-element-map (org-element-parse-buffer) 'keyword
                  (lambda (node)
                    (when (member (org-element-property :key node)
                                  '("SETUPFILE" "BIND" "MACRO" "CITE_EXPORT"))
                      (org-texmacs--preprocess-fail "Unsupported preprocessing directive"))))
                (dolist (payload payloads)
                  (goto-char (point-min))
                  (while (search-forward (car payload) nil t)
                    (replace-match (nth 1 payload) t t)))
                (when (or (> (string-bytes (buffer-string)) 262144)
                          (string-match-p nonce (buffer-string)))
                  (org-texmacs--preprocess-fail "Working budget exceeded or partial STM marker remains"))
                (guard)
                (list :source (buffer-substring-no-properties (point-min) (point-max))
                      :sources (mapcar (lambda (entry) (cons (copy-sequence (car entry))
                                                           (copy-sequence (cadr entry)))) cache)
                      :receipts receipts))
            ;; Retire this owned view's file identity.
            (when (buffer-live-p work-buffer)
              (with-current-buffer work-buffer
                (setq-local buffer-file-name nil)))))))))

(defun org-texmacs--preprocess-convert (source-buffer consumer sources options discover)
  "Run opt-in SOURCE-BUFFER composition through CONSUMER.
SOURCES and OPTIONS are explicit inputs.  DISCOVER separately enables Cite."
  (unless (and (bufferp source-buffer) (buffer-live-p source-buffer))
    (org-texmacs--preprocess-fail "Expected a live Org buffer object"))
  (unless (memq discover '(nil t))
    (org-texmacs--preprocess-fail "Expected an explicit bibliography discovery boolean"))
  (with-current-buffer source-buffer
    (unless (and (derived-mode-p 'org-mode) (not (buffer-narrowed-p)))
      (org-texmacs--preprocess-fail "Preprocessing requires a full unnarrowed Org source"))
    (let* ((buffer source-buffer)
           (hooks (org-texmacs--preprocess-hooks))
           (hook-check
            (lambda ()
              (with-current-buffer buffer
                (unless (org-texmacs--preprocess-hooks-same-p
                         hooks (org-texmacs--preprocess-hooks))
                  (org-texmacs--preprocess-fail "Preprocessing hook configuration changed"))))))
      (org-texmacs--bibliography-convert
       source-buffer consumer sources nil nil options
       (lambda (source tags headings links info file base _texts check)
         (let* ((guard (lambda () (funcall check) (funcall hook-check)))
                (composition (org-texmacs--preprocess-compose
                              source tags headings links info file base guard hooks))
                (receipts (plist-get composition :receipts)))
           (list :source (plist-get composition :source)
                 :context (list :texmacs-original-source (copy-sequence source)
                                :texmacs-preprocessed-source (plist-get composition :source)
                                :texmacs-preprocessing-sources (plist-get composition :sources))
                 :check (lambda ()
                          (funcall hook-check)
                          (org-texmacs--bibliography-check-receipts receipts)))))
       discover))))

;;;###autoload
(defun org-texmacs-prepare-buffer-preprocessed
    (source-buffer &optional bibliography-sources ext-plist discover-bibliography)
  "Prepare full SOURCE-BUFFER with opt-in native Org composition.
BIBLIOGRAPHY-SOURCES supplies explicit texts; EXT-PLIST restricted options.
DISCOVER-BIBLIOGRAPHY is exactly t or nil and separately enables Cite discovery.
Run captured preprocessing hooks in a private view and native INCLUDE with fixed
local UTF-8 source reads.  STM shielding preserves line counts for location,
only-contents, lines and minlevel selection.  Partial STM selections fail.
INFO owns original/final working text and acquired original dependency texts;
no exact original position, occurrence or generic AST origin map is promised.
Full unnarrowed ordinary-level sources and a local resource base are required.
Cross-directory INCLUDE uses native link relocation.  STM and bibliography paths
use the final working document context, without recovering original directories.
Includes have limits of 64 KiB/file, eight levels, 32 expansions including root
and 256 KiB original-source/final-working bytes.  Reject unsupported wrappers,
paths, aliases, configuration changes and damaged protected STM.  No full native
export lifecycle, macro/Babel/SETUPFILE/BIND execution, file or menu is added.
Source/configuration/dependency checks enclose native waits and final return;
callbacks are not sandboxed and no atomic filesystem guarantee is made."
  (org-texmacs--preprocess-convert
   source-buffer #'identity bibliography-sources ext-plist discover-bibliography))

;;;###autoload
(defun org-texmacs-document-from-buffer-preprocessed
    (source-buffer &optional bibliography-sources ext-plist discover-bibliography)
  "Return a document from full SOURCE-BUFFER with protected Org composition.
BIBLIOGRAPHY-SOURCES, EXT-PLIST and DISCOVER-BIBLIOGRAPHY have the semantics
of `org-texmacs-prepare-buffer-preprocessed'.  Lower inside the same original
source/hook/dependency checks.  No final file or live source AST is changed."
  (org-texmacs--preprocess-convert
   source-buffer #'org-texmacs-document bibliography-sources ext-plist discover-bibliography))

;;;###autoload
(defun org-texmacs-export-from-buffer-preprocessed
    (source-buffer &optional bibliography-sources ext-plist discover-bibliography)
  "Return native .tm bytes from full SOURCE-BUFFER with protected composition.
BIBLIOGRAPHY-SOURCES, EXT-PLIST and DISCOVER-BIBLIOGRAPHY follow
`org-texmacs-prepare-buffer-preprocessed'.  Serialize inside the same original
source/hook/dependency checks, including final validation before byte return.
No output file is published; checks are not an atomic FS/DB or ABA guarantee."
  (org-texmacs--preprocess-convert
   source-buffer
   (lambda (input) (org-texmacs-document-serialize (org-texmacs-document input)))
   bibliography-sources ext-plist discover-bibliography))

(provide 'org-texmacs-preprocess)
;;; org-texmacs-preprocess.el ends here
