;;; org-texmacs-source.el --- Org block sources for TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Read STM source directly from the buffer bounds of an Org special block.
;; Org's parsed children are not the source representation for TeXmacs.

;;; Code:

(require 'org-texmacs-core)

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
