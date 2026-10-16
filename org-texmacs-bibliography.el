;;; org-texmacs-bibliography.el --- Opt-in bibliography acquisition -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;; Discover through Org Cite in a private STM-masked snapshot.  Only this
;; adapter reads bibliography files; pure preparation consumes owned data.

;;; Code:

(require 'org-texmacs)
(require 'oc)

(defun org-texmacs--bibliography-local-path (path base)
  "Classify local PATH before normalizing its identity against BASE."
  (unless (and (stringp path) (> (length path) 0)
               (not (string-match-p "[[:cntrl:]]" path))
               (not (string-prefix-p "~" path))
               (not (file-remote-p path)) (not (org-url-p path)))
    (signal 'org-texmacs-document-error '("Unsupported bibliography location")))
  (let ((file-name-handler-alist nil)) (expand-file-name path base)))

(defun org-texmacs--bibliography-globals ()
  "Own the effective Org Cite global bibliography configuration."
  (unless (and (proper-list-p org-cite-global-bibliography)
               (cl-every #'stringp org-cite-global-bibliography))
    (signal 'org-texmacs-document-error '("Invalid global bibliography configuration")))
  (mapcar #'substring-no-properties org-cite-global-bibliography))

(defun org-texmacs--bibliography-discover
    (source tags headings links base-info source-file resource-base globals)
  "Discover once from full owned SOURCE, returning paths and declarations.
TAGS, HEADINGS, LINKS and BASE-INFO are captured parser/context data.
SOURCE-FILE and RESOURCE-BASE must agree.  GLOBALS is an owned list."
  (unless resource-base
    (signal 'org-texmacs-document-error '("Discovery needs a local resource base")))
  (org-texmacs--bibliography-local-path resource-base resource-base)
  (when source-file
    (org-texmacs--bibliography-local-path source-file resource-base)
    (unless (equal (file-name-directory source-file)
                   (file-name-as-directory (expand-file-name resource-base)))
      (signal 'org-texmacs-document-error '("Bibliography source directory conflicts with resource base"))))
  ;; The normal private parser installs the captured link/heading settings and
  ;; masks every inline span before context rejection.  Its private callback
  ;; runs no user AST filters.  Reparse the full text to mask blocks even when
  ;; context has pruned their AST nodes from the selected body.
  (let (result)
    (let ((org-export-allow-bind-keywords nil))
      (org-texmacs--document-prepare-source
       source tags headings links (copy-sequence base-info) nil nil nil
       (lambda (prepared)
         (let ((work-buffer (current-buffer)))
           (unwind-protect
               (progn
                 (setq-local default-directory (copy-sequence resource-base))
                 (setq-local buffer-file-name (and source-file (copy-sequence source-file)))
                 (setq-local org-cite-global-bibliography (mapcar #'copy-sequence globals))
                 (org-element-map (org-element-parse-buffer) 'special-block
                   (lambda (block)
                     (when (org-texmacs--block-p block)
                       (let ((begin (org-element-property :contents-begin block))
                             (end (org-element-property :contents-end block)))
                         (when begin
                           (let ((mask (org-texmacs--fragment-mask
                                        (buffer-substring-no-properties begin end))))
                             (goto-char begin) (delete-region begin end) (insert mask)))))))
                 (let* ((buffer (current-buffer)) (text (buffer-string))
                        (paths (org-cite-list-bibliography-files)))
                   (unless (and (eq buffer (current-buffer))
                                (equal text (buffer-string))
                                (equal buffer-file-name source-file)
                                (equal default-directory resource-base)
                                (proper-list-p paths) (cl-every #'stringp paths))
                     (signal 'org-texmacs-document-error
                             '("Bibliography discovery changed its private context")))
                   (setq result
                         (list (mapcar #'substring-no-properties paths)
                               (plist-get (nth 4 prepared)
                                          :texmacs-bibliography-declarations))))
                 prepared)
             ;; Retire this owned view's file identity.
             (when (buffer-live-p work-buffer)
               (with-current-buffer work-buffer
                 (setq-local buffer-file-name nil))))))))
    result))

(defun org-texmacs--bibliography-file-attributes (path)
  "Observe bounded regular local PATH, rejecting symlink components."
  (let ((component path))
    (while (and component (not (equal component "/")))
      (when (file-symlink-p component)
        (signal 'org-texmacs-document-error '("Automatic dependency symlinks are unsupported")))
      (setq component (file-name-directory (directory-file-name component)))))
  (let ((attributes (file-attributes path 'integer)))
    (unless (and attributes (null (file-attribute-type attributes))
                 (file-readable-p path) (<= (file-attribute-size attributes) 1048576))
      (signal 'org-texmacs-document-error '("Dependency needs a readable regular file of at most 1 MiB")))
    (list (file-attribute-size attributes)
          (file-attribute-modification-time attributes)
          (file-attribute-status-change-time attributes)
          (file-attribute-inode-number attributes)
          (file-attribute-device-number attributes))))

(defun org-texmacs--bibliography-file-bytes (path)
  "Read at most 1 MiB plus an overflow byte from local PATH."
  (with-temp-buffer
    (set-buffer-multibyte nil)
    (insert-file-contents-literally path nil 0 1048577)
    (when (> (buffer-size) 1048576)
      (signal 'org-texmacs-document-error '("Dependency grew beyond 1 MiB")))
    (buffer-string)))

(defun org-texmacs--bibliography-acquire (paths base provided document &optional check)
  "Merge owned PROVIDED texts with PATHS under BASE and DOCUMENT declarations.
Return owned sources, effective view and observed dependency receipts."
  (let (identities receipts physical
        (sources (org-texmacs--bibliography-source-snapshot provided base)))
    (dolist (path paths)
      (let ((id (org-texmacs--bibliography-local-path path base)))
        (unless (member id identities) (setq identities (append identities (list id))))))
    (dolist (declaration document)
      (unless (member (cdr declaration) identities)
        (signal 'org-texmacs-document-error '("Discovery dropped a document bibliography declaration"))))
    (let ((file-name-handler-alist nil))
      (dolist (id identities)
        (when check (funcall check))
        (unless (assoc id sources)
          (let* ((before (org-texmacs--bibliography-file-attributes id))
                 (identity (nthcdr 3 before))
                 (bytes (org-texmacs--bibliography-file-bytes id))
                 (after (org-texmacs--bibliography-file-attributes id))
                 (text (decode-coding-string bytes 'utf-8-unix)))
            (when check (funcall check))
            (unless (and (equal before after)
                         (not (cl-some (lambda (c) (> c #x10ffff)) (string-to-list text)))
                         (equal bytes (encode-coding-string text 'utf-8-unix)))
              (signal 'org-texmacs-document-error '("Changed or non-UTF-8 bibliography file")))
            (when (member identity physical)
              (signal 'org-texmacs-document-error '("Automatic bibliography physical aliases are unsupported")))
            (push identity physical)
            (push (list (copy-sequence id) before (secure-hash 'sha256 bytes)) receipts)
            (setq sources (append sources (list (cons (copy-sequence id) text))))))))
    (list :sources sources :view (org-texmacs--bibliography-view-copy
                                 (list :document document :sources identities))
          :receipts (nreverse receipts))))

(defun org-texmacs--bibliography-check-receipts (receipts)
  "Verify RECEIPTS without replacing any captured bibliography text."
  (let ((file-name-handler-alist nil))
    (dolist (receipt receipts)
      (let* ((path (car receipt))
             (before (org-texmacs--bibliography-file-attributes path))
             (digest (secure-hash 'sha256 (org-texmacs--bibliography-file-bytes path)))
             (after (org-texmacs--bibliography-file-attributes path)))
        (unless (and (equal before after) (equal before (nth 1 receipt))
                     (equal digest (nth 2 receipt)))
          (signal 'org-texmacs-document-error '("Captured dependency changed during conversion")))))))

(cl-defun org-texmacs--bibliography-convert
    (source-buffer consumer provided subtree-position region ext-plist
                   &optional preprocessing (discover t))
  "Run CONSUMER in one opt-in SOURCE-BUFFER bibliography transaction.
PROVIDED, SUBTREE-POSITION, REGION and EXT-PLIST retain explicit API semantics."
  (unless (and (bufferp source-buffer) (buffer-live-p source-buffer))
    (signal 'org-texmacs-document-error '("Expected a live Org buffer object")))
  (with-current-buffer source-buffer
    (let* ((globals (and discover (org-texmacs--bibliography-globals)))
           (collector (symbol-function 'org-cite-list-bibliography-files))
           (options (org-texmacs--document-options))
           (style (org-texmacs--document-copy-style org-texmacs-document-style))
           (initial (org-texmacs--document-copy-initial org-texmacs-document-initial))
           (configuration-check
            (lambda ()
              ;; Native INCLUDE and callbacks may run in other private buffers.
              (with-current-buffer source-buffer
                (unless (and (or (not discover)
                                 (and (equal globals (org-texmacs--bibliography-globals))
                                      (eq collector (symbol-function 'org-cite-list-bibliography-files))))
                             (equal options (org-texmacs--document-options))
                             (equal style org-texmacs-document-style)
                             (equal initial org-texmacs-document-initial))
                  (signal 'org-texmacs-document-error
                          '("Bibliography transaction configuration changed")))))))
      (org-texmacs--prepare-buffer
       source-buffer consumer provided subtree-position region ext-plist nil
       (lambda (source tags headings links info file base texts check)
         (let* ((guard (lambda () (funcall check) (funcall configuration-check)))
                (_ (funcall guard))
                (composition (and preprocessing
                                  (funcall preprocessing source tags headings links
                                           info file base texts guard)))
                (working (if composition (plist-get composition :source) source))
                (composition-check (plist-get composition :check))
                (dependency-guard (lambda ()
                                    (funcall guard)
                                    (when composition-check (funcall composition-check))))
                (_ (funcall dependency-guard))
                (discovery (and discover (org-texmacs--bibliography-discover
                                         working tags headings links
                                         (org-combine-plists info (plist-get composition :context))
                                         file base globals)))
                (_ (funcall dependency-guard))
                (acquired (if discover
                              (org-texmacs--bibliography-acquire
                               (car discovery) base texts (cadr discovery) dependency-guard)
                            (list :sources texts)))
                (receipts (plist-get acquired :receipts)))
           (funcall dependency-guard)
           (org-combine-plists
            composition acquired
            (list :check
                  (lambda ()
                    (funcall configuration-check)
                    (when composition-check (funcall composition-check))
                    (org-texmacs--bibliography-check-receipts receipts))))))))))

;;;###autoload
(defun org-texmacs-document-from-buffer-discover-bibliography
    (source-buffer &optional bibliography-sources subtree-position region ext-plist)
  "Convert SOURCE-BUFFER with opt-in Org Cite bibliography discovery.
Return a completed document, using the same selection and restricted options
as `org-texmacs-document-from-buffer'.  BIBLIOGRAPHY-SOURCES supplies explicit
owned text snapshots; they win over disk and need not name existing files.
Discover once in a full private STM-masked Org view, including outside the
selected body.  Global bibliography and standard collector advice participate.
Only missing local regular UTF-8 files of at most 1 MiB are read.  Reject
symlinks, physical aliases, remote/URL/tilde paths and visiting directory/base
conflicts.  Unsupported preprocessing remains rejected before discovery.
Capture source/configuration before discovery; recheck it and acquired file
attributes/digests through native waits and before returning.  Observations
are not an atomic filesystem/database transaction or an ABA guarantee.
Run the existing restricted AST filters exactly once.  Do not save files,
retry changed dependencies or provide arbitrary advice with a sandbox."
  (org-texmacs--bibliography-convert
   source-buffer #'org-texmacs-document bibliography-sources
   subtree-position region ext-plist))

;;;###autoload
(defun org-texmacs-export-from-buffer-discover-bibliography
    (source-buffer &optional bibliography-sources subtree-position region ext-plist)
  "Export SOURCE-BUFFER with discovered bibliography to native .tm bytes.
BIBLIOGRAPHY-SOURCES, SUBTREE-POSITION, REGION and EXT-PLIST have the semantics
of `org-texmacs-document-from-buffer-discover-bibliography'.  Serialize inside
the same source/configuration/dependency checks, including a final check before
returning the unibyte string.  No output file or dispatcher action is created."
  (org-texmacs--bibliography-convert
   source-buffer
   (lambda (input) (org-texmacs-document-serialize (org-texmacs-document input)))
   bibliography-sources subtree-position region ext-plist))

(provide 'org-texmacs-bibliography)
;;; org-texmacs-bibliography.el ends here
