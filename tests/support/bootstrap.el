;;; bootstrap.el --- Ordered package loading -*- lexical-binding: t; -*-

;;; Commentary:

;; Test-owned support and fixtures.

;;; Code:

(require 'ert)

(require 'org-texmacs-worker)

(defconst org-texmacs-test--worker-loaded-document
  (featurep 'org-texmacs-document)
  "Whether loading the worker pulled in the document layer.")

(require 'org-texmacs)

(require 'ox-texmacs)

(require 'org-texmacs-bibliography)

(require 'org-texmacs-preprocess)

;;; bootstrap.el ends here
