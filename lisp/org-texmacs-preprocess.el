;;; org-texmacs-preprocess.el --- Legacy standard wrappers -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-
;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Deprecated names delegate to the standard exporter.  They do not collect
;; files, merge options, prune trees or organize another preparation lifecycle.

;;; Code:

(require 'org-texmacs)

(defun org-texmacs-prepare-buffer-preprocessed
    (source-buffer
     &optional bibliography-sources ext-plist discover-bibliography)
  "Deprecated standard input wrapper for SOURCE-BUFFER.
BIBLIOGRAPHY-SOURCES and DISCOVER-BIBLIOGRAPHY must be nil."
  (when discover-bibliography
    (signal
     'org-texmacs-document-error
     '("Remove discovery switch; configure standard Org Cite")))
  (org-texmacs--standard-source-consume
   'input source-buffer bibliography-sources nil nil ext-plist))

(defun org-texmacs-document-from-buffer-preprocessed
    (source-buffer
     &optional bibliography-sources ext-plist discover-bibliography)
  "Deprecated standard document wrapper for SOURCE-BUFFER.
BIBLIOGRAPHY-SOURCES and DISCOVER-BIBLIOGRAPHY must be nil."
  (when discover-bibliography
    (signal
     'org-texmacs-document-error
     '("Remove discovery switch; configure standard Org Cite")))
  (org-texmacs--standard-source-consume
   'document source-buffer bibliography-sources nil nil ext-plist))

(defun org-texmacs-export-from-buffer-preprocessed
    (source-buffer
     &optional bibliography-sources ext-plist discover-bibliography)
  "Deprecated standard tm wrapper for SOURCE-BUFFER.
BIBLIOGRAPHY-SOURCES and DISCOVER-BIBLIOGRAPHY must be nil."
  (when discover-bibliography
    (signal
     'org-texmacs-document-error
     '("Remove discovery switch; configure standard Org Cite")))
  (org-texmacs--standard-source-consume
   'tm source-buffer bibliography-sources nil nil ext-plist))

(make-obsolete
 'org-texmacs-prepare-buffer-preprocessed
 'org-texmacs-prepare-buffer
 "0.7.0")
(make-obsolete
 'org-texmacs-document-from-buffer-preprocessed
 'org-texmacs-document-from-buffer
 "0.7.0")
(make-obsolete
 'org-texmacs-export-from-buffer-preprocessed
 'org-texmacs-export-texmacs-from-buffer
 "0.7.0")

(provide 'org-texmacs-preprocess)

;;; org-texmacs-preprocess.el ends here
