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
      (unless (and (stringp path) (> (length path) 0)
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
      (unless (and (stringp path) (> (length path) 0)
                   (not (string-match-p "\0" path))
                   (file-name-absolute-p path))
        (signal 'org-texmacs-document-error
                '("Expected an absolute source buffer location")))
      (org-texmacs--source-copy-path
       (if (string-prefix-p "~" path) (expand-file-name path) path)))))

(defun org-texmacs--bibliography-source-snapshot (sources resource-base)
  "Copy explicit path-to-text SOURCES using captured RESOURCE-BASE.
Resolve source identities without opening files or running file handlers."
  (unless (proper-list-p sources)
    (signal 'org-texmacs-document-error '("Expected bibliography source text alist")))
  (let ((file-name-handler-alist nil) paths result)
    (dolist (entry sources)
      (unless (and (consp entry) (stringp (car entry)) (> (length (car entry)) 0)
                   (not (string-match-p "\0" (car entry))) (stringp (cdr entry)))
        (signal 'org-texmacs-document-error '("Invalid bibliography source text")))
      (unless (or (file-name-absolute-p (car entry)) resource-base)
        (signal 'org-texmacs-document-error '("Relative bibliography identity needs resource base")))
      (let ((path (org-texmacs--source-copy-path
                   (expand-file-name (car entry) resource-base))))
        (when (member path paths)
          (signal 'org-texmacs-document-error '("Duplicate bibliography source identity")))
        (push path paths)
        (push (cons path (substring-no-properties (cdr entry))) result)))
    (nreverse result)))

(defun org-texmacs--block-p (node)
  "Return non-nil when Org NODE is a TeXmacs special block."
  (and (consp node)
       (eq (org-element-type node) 'special-block)
       (equal (org-element-property :type node) "texmacs")))

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
    (signal 'org-texmacs-error
            '("Expected a TeXmacs special block")))
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
              '("TeXmacs block contents are outside the accessible buffer or invalid"))))))

(provide 'org-texmacs-source)

;;; org-texmacs-source.el ends here
