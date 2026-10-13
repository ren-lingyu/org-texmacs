;;; org-texmacs-preprocess.el --- Bounded owned Org composition -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;; Compose an owned protected working document with native INCLUDE.  Original
;; source, include occurrences and generated text remain separate inputs.

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
  "Compose owned SOURCE under fixed parser/context and transaction CHECK.
TAGS, HEADINGS, LINKS, INFO, SOURCE-FILE and BASE are captured inputs.
HOOKS contains two captured hook states.  Return working text/origins/receipts."
  (unless (and base (not (nth 2 headings))
               (not (default-value 'org-odd-levels-only)))
    (org-texmacs--preprocess-fail "Composition needs a local base and ordinary headline levels"))
  (org-texmacs--bibliography-local-path base base)
  (when source-file
    (org-texmacs--bibliography-local-path source-file base)
    (unless (equal (file-name-directory source-file) (file-name-as-directory base))
      (org-texmacs--preprocess-fail "Composition source directory conflicts with resource base")))
  (setq base (file-name-as-directory base))
  (let ((directory nil)
        (nonce (substring (secure-hash 'sha256 (format "%s%s" source (float-time))) 0 20))
        (org-mode-hook nil) (change-major-mode-hook nil) (after-change-major-mode-hook nil)
        (delay-mode-hooks t) (org-inhibit-startup t)
        (kill-buffer-query-functions nil) (kill-buffer-hook nil)
        (org-export-use-babel nil) (org-export-allow-bind-keywords nil)
        (org-export-replace-macros nil) (org-element-use-cache nil)
        (filter-value (org-texmacs--context-filter-copy org-export-filter-parse-tree-functions))
        (style (org-texmacs--document-copy-style org-texmacs-document-style))
        (initial (org-texmacs--document-copy-initial org-texmacs-document-initial))
        (backend (car (org-texmacs--context-filter-state)))
        (include-function (symbol-function 'org-export-expand-include-keyword))
        (next 0) (total 0) origins payloads receipts mirrors cache
        (physical
         (when source-file
           (let* ((file-name-handler-alist nil)
                  (attributes (file-attributes source-file 'integer)))
             (when attributes
               (unless (null (file-attribute-type attributes))
                 (org-texmacs--preprocess-fail "Visiting source identity must be regular or absent"))
               (list (list (file-attribute-inode-number attributes)
                           (file-attribute-device-number attributes))))))))
    (setq directory (make-temp-file "org-texmacs-composition-" t))
    (unwind-protect
        (let ((org-export-registered-backends (cons backend org-export-registered-backends)))
          (cl-labels
              ((guard ()
                 (funcall check)
                 (unless (and (eq include-function (symbol-function 'org-export-expand-include-keyword))
                              (not (default-value 'org-odd-levels-only)))
                   (org-texmacs--preprocess-fail "Native composition configuration changed"))
                 (org-texmacs--bibliography-check-receipts receipts))
               (context (file)
                 (org-texmacs--preprocess-context tags headings links info file base filter-value)
                 (setq-local org-texmacs-document-style (copy-sequence style))
                 (setq-local org-texmacs-document-initial (org-texmacs--context-copy initial)))
               (capture (file)
                 (guard)
                 (or (cdr (assoc file cache))
                     (let* ((file-name-handler-alist nil)
                            (attrs (org-texmacs--bibliography-file-attributes file))
                            (identity (nthcdr 3 attrs)))
                       (when (or (> (car attrs) 65536) (member identity physical))
                         (org-texmacs--preprocess-fail "Large include or ambiguous physical source alias"))
                       (let* ((bytes (org-texmacs--bibliography-file-bytes file))
                              (new (org-texmacs--bibliography-file-attributes file))
                              (text (decode-coding-string bytes 'utf-8-unix)))
                         (guard)
                         (unless (and (equal attrs new) (<= (length bytes) 65536)
                                      (equal bytes (encode-coding-string text 'utf-8-unix))
                                      (not (cl-some (lambda (c) (> c #x10ffff)) text)))
                           (org-texmacs--preprocess-fail "Changed or non-UTF-8 include"))
                         (push identity physical) (push (cons file text) cache)
                         (push (list (copy-sequence file) attrs (secure-hash 'sha256 bytes)) receipts)
                         text))))
               (protect (file occurrence generated)
                 (let ((spans
                        (mapcar (lambda (span)
                                  (list (org-texmacs-fragment-span-begin span)
                                        (org-texmacs-fragment-span-end span) 'stm))
                                (org-texmacs--fragment-collect tags))))
                   (org-element-map (org-element-parse-buffer) 'special-block
                     (lambda (node)
                       (when (org-texmacs--block-p node)
                         (push (list (org-element-property :begin node)
                                     (org-element-property :end node) 'stm) spans))))
                   (dolist (span (sort spans (lambda (a b) (> (car a) (car b)))))
                     (protect-span span file occurrence generated))))
               (protect-span (span file occurrence generated)
                 (let* ((raw (buffer-substring-no-properties (car span) (cadr span)))
                        (token (format "TXMPAYLOAD%sX%d" nonce (length payloads))))
                   (push (list token raw (and (not generated) file)
                               (if generated -1 occurrence)
                               (and (not generated) (cons (car span) (cadr span)))
                               (nth 2 span)) payloads)
                   (delete-region (car span) (cadr span)) (goto-char (car span))
                   (insert token (if (string-suffix-p "\n" raw) "\n" ""))))
               (materialize (text file ancestors depth)
                 (guard)
                 (when (or (> depth 8) (>= next 32))
                   (org-texmacs--preprocess-fail "Composition depth or occurrence budget exceeded"))
                 (cl-incf total (string-bytes text))
                 (when (> total 262144)
                   (org-texmacs--preprocess-fail "Composition exceeds 256 KiB source budget"))
                 (when (string-match-p nonce text)
                   (org-texmacs--preprocess-fail "Reserved composition marker in source"))
                 (let* ((occurrence (prog1 next (cl-incf next)))
                        (mirror (expand-file-name (format "source-%d.org" occurrence) directory)))
                   (push (list occurrence (and file (copy-sequence file))
                               (substring-no-properties text)) origins)
                   (with-temp-buffer
                     (context file) (insert text) (protect file occurrence nil)
                     (when (zerop occurrence)
                       (org-texmacs--preprocess-stage (car hooks) #'guard)
                       (protect nil -1 t))
                     (let ((includes
                            (org-element-map (org-element-parse-buffer) 'keyword
                              (lambda (node)
                                (let ((key (org-element-property :key node)))
                                  (when (member key '("SETUPFILE" "BIND" "MACRO" "CITE_EXPORT"))
                                    (org-texmacs--preprocess-fail "Unsupported preprocessing directive"))
                                  (and (equal key "INCLUDE") node))))))
                       (dolist (node (reverse includes))
                         (let ((value (org-element-property :value node)))
                           (unless (and (string-match "\\`\"\\([^\"\n]+\\)\"[ \t]*\\'" value)
                                        (save-match-data (save-excursion
                                          (goto-char (org-element-property :begin node))
                                          (and (zerop (current-column))
                                               (not (org-in-commented-heading-p))))))
                             (org-texmacs--preprocess-fail "Only active column-zero bare quoted INCLUDE is supported"))
                           (let* ((raw (match-string 1 value))
                                  (id (org-texmacs--bibliography-local-path raw base)))
                             (when (string-match-p "\\(::\\|[$]\\)" raw)
                               (org-texmacs--preprocess-fail "Unsupported include search or environment path"))
                             (unless (equal (file-name-directory id) base)
                               (org-texmacs--preprocess-fail "Include resource directory conflicts with root"))
                             (when (member id ancestors)
                               (org-texmacs--preprocess-fail "Recursive include source"))
                             (let ((child (materialize (capture id) id (cons id ancestors) (1+ depth))))
                               (goto-char (org-element-property :begin node))
                               (delete-region (point) (line-beginning-position 2))
                               (insert (format "#+INCLUDE: \"%s\"\n" child)))))))
                     ;; Native keyword scanning must not acquire literal lines
                     ;; in source/other blocks that its parser interprets differently.
                     (goto-char (point-max))
                     (let ((case-fold-search t))
                       (while (re-search-backward "^[ \t]*#\\+\\(INCLUDE\\|SETUPFILE\\|BIND\\|MACRO\\|CITE_EXPORT\\):" nil t)
                         (let ((begin (line-beginning-position)) (end (line-beginning-position 2)))
                           (unless (string-prefix-p (format "#+INCLUDE: \"%s/" directory)
                                                    (buffer-substring-no-properties begin end))
                             (protect-span (list begin end 'literal) file occurrence nil)))))
                     (goto-char (point-min))
                     (insert (format "# TXMSTART%s:%d\n" nonce occurrence))
                     (goto-char (point-max)) (unless (bolp) (insert "\n"))
                     (insert (format "# TXMEND%s:%d\n" nonce occurrence))
                     (when (> (buffer-size) 262144)
                       (org-texmacs--preprocess-fail "Protected working source budget exceeded"))
                     (let ((coding-system-for-write 'utf-8-unix))
                       (write-region (point-min) (point-max) mirror nil 'silent))
                     (push (cons mirror (secure-hash 'sha256 (current-buffer))) mirrors))
                   mirror)))
            (let ((root (materialize source source-file (and source-file (list source-file)) 0))
                  output segments ranges)
              (with-temp-buffer
                (context source-file) (insert-file-contents root)
                (guard)
                (org-export-expand-include-keyword nil directory nil root)
                (guard)
                (setq output (buffer-string)))
              (dolist (mirror mirrors)
                (with-temp-buffer
                  (insert-file-contents (car mirror))
                  (unless (equal (cdr mirror) (secure-hash 'sha256 (current-buffer)))
                    (org-texmacs--preprocess-fail "Owned include mirror changed"))))
              (with-temp-buffer
                (context source-file)
                (let ((input output) stack parts seen)
                  (with-temp-buffer
                    (insert input) (goto-char (point-min))
                    (let ((start (point-min)))
                      (while (re-search-forward (format "^# TXM\\(START\\|END\\)%s:\\([0-9]+\\)\n" nonce) nil t)
                        (push (list 'text (buffer-substring start (match-beginning 0))) parts)
                        (push (list (intern (downcase (match-string 1)))
                                    (string-to-number (match-string 2))) parts)
                        (setq start (point)))
                      (push (list 'text (buffer-substring start (point-max))) parts)))
                  (dolist (part (nreverse parts))
                    (pcase (car part)
                      ('start
                       (when (memq (cadr part) seen)
                         (org-texmacs--preprocess-fail "Duplicate source occurrence boundary"))
                       (push (cadr part) seen) (push (cadr part) stack))
                      ('end
                       (unless (eq (pop stack) (cadr part))
                         (org-texmacs--preprocess-fail "Source occurrence boundary changed")))
                      ('text
                       (when (> (length (cadr part)) 0)
                         (unless stack (org-texmacs--preprocess-fail "Unowned native inclusion text"))
                         (let ((begin (point)))
                           (insert (cadr part))
                           (add-text-properties begin (point)
                             (list 'org-texmacs--preprocess-origin (car stack)
                                   'rear-nonsticky t)))))))
                  (unless (and (null stack) (= (length seen) (length origins)))
                    (org-texmacs--preprocess-fail "Missing source occurrence boundary")))
                (let ((after-change-functions
                       (list (lambda (begin end _old)
                               (let ((inhibit-modification-hooks t))
                                 (put-text-property begin end 'org-texmacs--preprocess-origin -1))))))
                  (org-texmacs--preprocess-stage (cadr hooks) #'guard))
                (dolist (payload payloads)
                  (goto-char (point-min))
                  (unless (search-forward (car payload) nil t)
                    (org-texmacs--preprocess-fail "Protected source marker lost"))
                  (let ((begin (match-beginning 0))
                        (raw (nth 1 payload)))
                    (replace-match (if (string-suffix-p "\n" raw) (substring raw 0 -1) raw) t t)
                    (put-text-property begin (point) 'org-texmacs--preprocess-origin (nth 3 payload))
                    (when (eq (nth 5 payload) 'stm)
                      (push (list (copy-marker begin t) (copy-marker (point))
                                  (nth 2 payload) (nth 3 payload) (nth 4 payload)) ranges)))
                  (when (search-forward (car payload) nil t)
                    (org-texmacs--preprocess-fail "Protected source marker duplicated")))
                (when (or (> (string-bytes (buffer-string)) 262144)
                          (string-match-p nonce (buffer-string)))
                  (org-texmacs--preprocess-fail "Working budget exceeded or reserved marker remains"))
                (let ((position (point-min)))
                  (while (< position (point-max))
                    (let* ((occurrence (or (get-text-property position 'org-texmacs--preprocess-origin) -1))
                           (end (next-single-property-change position 'org-texmacs--preprocess-origin nil (point-max))))
                      (unless (and (integerp occurrence) (>= occurrence -1)
                                   (or (= occurrence -1) (assq occurrence origins)))
                        (org-texmacs--preprocess-fail "Invalid working origin property"))
                      (push (list position end occurrence (cadr (assq occurrence origins))
                                  (if (< occurrence 0) 'generated 'derived)) segments)
                      (setq position end))))
                (setq output (buffer-substring-no-properties (point-min) (point-max)))
                (setq ranges
                      (mapcar (lambda (range)
                                (prog1 (list (marker-position (car range))
                                             (marker-position (cadr range))
                                             (nth 2 range) (nth 3 range) (nth 4 range))
                                  (set-marker (car range) nil) (set-marker (cadr range) nil))) ranges)))
              (guard)
              (list :source output :segments (nreverse segments) :ranges ranges
                    :origins (nreverse origins) :receipts receipts))))
      (delete-directory directory t))))

(defun org-texmacs--preprocess-annotate (composition prepared)
  "Attach owned COMPOSITION origins to PREPARED before AST filters.
Working ranges are explicit parser coordinates, not equal-text matches."
  (let ((segments (plist-get composition :segments))
        (ranges (plist-get composition :ranges))
        (islands (nth 1 prepared)) origin-map)
    (cl-labels
        ((walk (node)
           (when (consp node)
             (let ((begin (org-element-property :begin node))
                   (end (org-element-property :end node)))
               (when (and (integerp begin) (integerp end))
                 (org-element-put-property
                  node :texmacs-origin-context
                  (org-texmacs--context-copy
                   (cl-remove-if-not (lambda (segment)
                                       (and (< (car segment) end) (> (cadr segment) begin)))
                                     segments)))))
             (unless (assq node islands) (mapc #'walk (org-element-contents node))))))
      (walk (car prepared)))
    (dolist (request (nth 2 prepared))
      (let* ((working (nth 3 request))
             (range (cl-find-if (lambda (range)
                                 (and (= (car working) (car range))
                                      (>= (cdr working) (cadr range)))) ranges))
             (origin (list :source-file (and range (nth 2 range))
                           :occurrence (if range (nth 3 range) -1)
                           :original-range (and range (nth 4 range))
                           :working-range (cons (car working) (cdr working))
                           :kind (if (and range (nth 4 range)) 'original 'generated))))
        (push (cons (caar request) (org-texmacs--context-copy origin)) origin-map)))
    (setcar (nthcdr 4 prepared)
            (plist-put (nth 4 prepared) :texmacs-island-origins (nreverse origin-map)))))

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
                                :texmacs-source-origins (plist-get composition :segments)
                                :texmacs-composition-sources (plist-get composition :origins))
                 :annotate (lambda (prepared)
                             (org-texmacs--preprocess-annotate composition prepared))
                 :check (lambda ()
                          (funcall hook-check)
                          (org-texmacs--bibliography-check-receipts receipts)))))
       discover))))

;;;###autoload
(defun org-texmacs-prepare-buffer-preprocessed
    (source-buffer &optional bibliography-sources ext-plist discover-bibliography)
  "Prepare full SOURCE-BUFFER with opt-in protected native Org composition.
BIBLIOGRAPHY-SOURCES supplies explicit text snapshots; EXT-PLIST supplies the
existing restricted options.  DISCOVER-BIBLIOGRAPHY, exactly t or nil, enables
the separate Phase 3b bibliography reader over composed declarations.
Run captured before-processing/parsing hooks on private protected views and
native INCLUDE over fixed local UTF-8 mirrors.  Original text, source contexts,
occurrences and generated text are owned separately in INFO.  No full native
export lifecycle or source-position equivalence is claimed.
Only full unnarrowed sources with ordinary headline levels and a shared local
resource directory are supported.  INCLUDE accepts bare quoted complete files,
at most 64 KiB each, eight levels, 32 occurrences including root and 256 KiB
aggregate source/working bytes.  Reject symlink/remote/alias/parameter/directory
conflicts.  No macros, Babel, SETUPFILE or BIND processing is performed.
Hooks cannot change supported private configuration or original STM tokens;
arbitrary callback I/O is not sandboxed.  New STM has explicit generated origin.
Owned input has node-keyed island origins in :texmacs-island-origins.  Exact
original ranges belong to protected STM; ordinary ranges describe transformed
working context.  Root source and acquired dependency consistency is verified
through native waits and before return without retry or text replacement.
No subtree/region mapping, generic exporter, output file or menu is created."
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
