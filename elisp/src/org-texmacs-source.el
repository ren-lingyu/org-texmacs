;;; org-texmacs-source.el --- Org source capture for TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Read STM source directly from the buffer bounds of an Org special block.
;; Org's parsed children are not the source representation for TeXmacs.
;; Copy source location strings without consulting the filesystem.

;;; Code:

(require 'org-texmacs-core)

(defun org-texmacs--source-copy-path (path)
  "Validate and copy an explicit absolute source PATH, or nil.
Preserve spelling and symlinks.  Do not expand a path, resolve a home
directory, run file handlers or consult the filesystem."
  (when path
    (let ((file-name-handler-alist nil))
      (unless (and (stringp path)
                   (> (length path) 0)
                   (not (string-prefix-p "~" path))
                   (not (string-match-p "\0" path))
                   (file-name-absolute-p path))
        (signal 'org-texmacs-document-error
                '("Expected an explicit absolute source location"))))
    (substring-no-properties path)))

(defun org-texmacs--source-capture-path (path)
  "Capture source buffer PATH, or nil, during preparation.
An absolute path may use a home-directory abbreviation.  Expand that
abbreviation once now; do not defer it to pure lowering or a consumer."
  (when path
    (let ((file-name-handler-alist nil))
      (unless (and (stringp path)
                   (> (length path) 0)
                   (not (string-match-p "\0" path))
                   (file-name-absolute-p path))
        (signal 'org-texmacs-document-error
                '("Expected an absolute source buffer location")))
      (org-texmacs--source-copy-path
       (if (string-prefix-p "~" path)
           (expand-file-name path)
         path)))))

(defun org-texmacs--block-p (node)
  "Return non-nil when Org NODE is a TeXmacs special block.
Compare its wrapper name without case, preserving NODE and its STM contents."
  (and (consp node)
       (eq (org-element-type node) 'special-block)
       (let ((type (org-element-property :type node)))
         (and (stringp type) (equal (downcase type) "texmacs")))))

(defun org-texmacs--native-body-name-kind (name)
  "Return the native raw-body kind for block NAME, or nil."
  (when (stringp name)
    (cdr
     (assoc
      (downcase name)
      '(("texmacs" . texmacs)
        ("equation" . equation)
        ("equation*" . equation*))))))

(defun org-texmacs--native-body-kind (node)
  "Return the native raw-body kind of NODE, or nil."
  (when (and (consp node) (eq (org-element-type node) 'special-block))
    (org-texmacs--native-body-name-kind
     (org-element-property :type node))))

(defun org-texmacs--native-body-blocks (ast)
  "Collect outermost native-body blocks in AST order without entering them."
  (let (blocks)
    (cl-labels
     ((walk
       (node)
       (when (consp node)
         (if (org-texmacs--native-body-kind node)
             (push node blocks)
           (mapc #'walk (org-element-contents node))))))
     (walk ast))
    (nreverse blocks)))

(defun org-texmacs--native-body-check (node)
  "Validate equation NODE parameters without reading its source."
  (when (memq
         (org-texmacs--native-body-kind node) '(equation equation*))
    (let ((parameters (org-element-property :parameters node)))
      (unless (or (null parameters)
                  (and (stringp parameters)
                       (string-match-p
                        "\\`[ \t\r\n]*\\'" parameters)))
        (signal 'org-texmacs-document-error
                '("Equation parameters are unsupported"))))))

(defun org-texmacs--native-body-source (block)
  "Read raw native BLOCK contents in the accessible source buffer."
  (unless (org-texmacs--native-body-kind block)
    (signal 'org-texmacs-error '("Expected a native-body block")))
  (let ((begin (org-element-property :contents-begin block))
        (end (org-element-property :contents-end block)))
    (cond
     ((and (null begin) (null end))
      "")
     ((and (integerp begin)
           (integerp end)
           (<= (point-min) begin end (point-max)))
      (buffer-substring-no-properties begin end))
     (t
      (signal 'org-texmacs-error
              '("Invalid native-body contents bounds"))))))

(defun org-texmacs--figure-table-kind (node)
  "Return the structural figure/table kind of NODE, or nil."
  (when (and (consp node) (eq (org-element-type node) 'special-block))
    (let ((type (org-element-property :type node)))
      (when (stringp type)
        (cdr
         (assoc
          (downcase type)
          '(("figure" . figure)
            ("figure*" . figure*)
            ("table" . table)
            ("table*" . table*))))))))

(defun org-texmacs--figure-table-blank-p (node)
  "Recognize metadata-free whitespace paragraphs used for spacing."
  (and (eq (org-element-type node) 'paragraph)
       (not (org-element-property :name node))
       (not (org-element-property :caption node))
       (not (org-element-property :texmacs-affiliated-keywords node))
       (let (attribute)
         (org-element-properties-mapc
          (lambda (key value _owner)
            (when (and value
                       (string-prefix-p ":attr_" (symbol-name key)))
              (setq attribute t)))
          node)
         (not attribute))
       (let ((begin (org-element-property :begin node))
             (post (org-element-property :post-affiliated node)))
         (or (null post) (equal begin post)))
       (org-element-contents node)
       (cl-every
        (lambda (text)
          (and (stringp text)
               (string-match-p "\\`[ \t\r\n]*\\'" text)))
        (org-element-contents node))))

(defun org-texmacs--block-source (block)
  "Return the raw STM source of TeXmacs special BLOCK as a string.

BLOCK must be an up-to-date Org element from the current buffer, with its
contents accessible under the current narrowing.  Read its contents bounds
without consulting parsed children or changing the buffer or point.  Strip
text properties but preserve whitespace.  An empty block has no contents
bounds in Org and yields an empty string.

Signal `org-texmacs-error' for a non-TeXmacs block or invalid contents bounds.
Bounds checks cannot detect a stale element or an element from another buffer;
the caller is responsible for supplying the correct element."
  (unless (org-texmacs--block-p block)
    (signal 'org-texmacs-error '("Expected a TeXmacs special block")))
  (org-texmacs--native-body-source block))

(provide 'org-texmacs-source)

;;; org-texmacs-source.el ends here
