;;; org-texmacs-bibliography.el --- Legacy standard wrappers -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-
;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Deprecated names delegate to the standard exporter.  They do not collect
;; files, merge options, prune trees or organize another preparation lifecycle.

;;; Code:

(require 'org-texmacs)

(defun org-texmacs-document-from-buffer-discover-bibliography
    (source-buffer
     &optional bibliography-sources subtree-position region ext-plist)
  "Deprecated standard document wrapper for SOURCE-BUFFER.
BIBLIOGRAPHY-SOURCES must be nil; configure standard Org Cite."
  (org-texmacs--standard-source-consume
   'document
   source-buffer
   bibliography-sources
   subtree-position
   region
   ext-plist))

(defun org-texmacs-export-from-buffer-discover-bibliography
    (source-buffer
     &optional bibliography-sources subtree-position region ext-plist)
  "Deprecated standard tm wrapper for SOURCE-BUFFER.
BIBLIOGRAPHY-SOURCES must be nil; configure standard Org Cite."
  (org-texmacs--standard-source-consume
   'tm
   source-buffer
   bibliography-sources
   subtree-position
   region
   ext-plist))

(make-obsolete
 'org-texmacs-document-from-buffer-discover-bibliography
 'org-texmacs-document-from-buffer
 "0.7.0")
(make-obsolete
 'org-texmacs-export-from-buffer-discover-bibliography
 'org-texmacs-export-texmacs-from-buffer
 "0.7.0")

(provide 'org-texmacs-bibliography)

;;; org-texmacs-bibliography.el ends here
