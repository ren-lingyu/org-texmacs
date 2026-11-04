;;; org-texmacs-cite-native.el --- Native Org Cite export requests -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Standard Org Cite callbacks produce semantic carriers and transaction data.
;; Native bibliography fulfillment belongs to export preparation, not callbacks.

;;; Code:

(require 'oc)
(require 'ox)
(require 'org-texmacs-cite)

(defcustom org-texmacs-cite-export-processor 'texmacs-native
  "Preferred Org Cite export processor for TeXmacs.
When nil, use `org-cite-export-processors' without modification.
A non-nil value supplies a TeXmacs choice unless an explicit backend entry wins.
This controls export only; activate, follow and insert processors are unchanged."
  :type
  '(choice
    (const :tag "Use Org Cite configuration" nil)
    (symbol :tag "Processor"))
  :group 'org-texmacs)

(defun org-texmacs--cite-default-processors ()
  "Return the effective Org Cite processor configuration for TeXmacs."
  (if (or (null org-texmacs-cite-export-processor)
          (assq 'texmacs org-cite-export-processors))
      org-cite-export-processors
    (cons
     (list 'texmacs org-texmacs-cite-export-processor)
     org-cite-export-processors)))

(defun org-texmacs--cite-record (node request backend info)
  "Associate NODE with REQUEST in live INFO for BACKEND."
  (unless (org-export-derived-backend-p backend 'texmacs)
    (org-texmacs--cite-fail
     "Native citation processor requires the TeXmacs backend"))
  (plist-put
   info
   :texmacs-cite-requests
   (append
    (plist-get info :texmacs-cite-requests)
    (list (cons node request))))
  node)

(defun org-texmacs--cite-export-citation (citation style backend info)
  "Return a structural CITATION carrier for STYLE, BACKEND and INFO."
  (unless (and (null (car style)) (null (cdr style)))
    (org-texmacs--cite-fail "Unsupported native citation style"))
  (let* ((keys (org-texmacs--cite-keys citation))
         (node (org-element-copy citation)))
    (org-texmacs--cite-record
     node
     (list
      :kind 'citation
      :keys
      (mapcar #'substring-no-properties keys))
     backend info)))

(defun org-texmacs--cite-export-bibliography
    (keys files style properties backend info)
  "Return one bibliography carrier for KEYS, FILES, STYLE and PROPERTIES.
BACKEND and INFO belong to the current standard Org Cite transaction."
  (when properties
    (org-texmacs--cite-fail
     "Native bibliography print options are unsupported"))
  (let ((node
         (org-element-create
          'keyword
          (list
           :key
           (copy-sequence "PRINT_BIBLIOGRAPHY")
           :value ""))))
    (org-texmacs--cite-record
     node
     (list
      :kind 'bibliography
      :keys (mapcar #'substring-no-properties keys)
      :files
      (mapcar
       (lambda (file)
         (substring-no-properties (expand-file-name file)))
       files)
      :style (substring-no-properties (or style "plain")))
     backend info)
    ;; Org preserves this identity only through its list-of-elements return path.
    (list node)))

(org-cite-register-processor
 'texmacs-native
 :export-citation #'org-texmacs--cite-export-citation
 :export-bibliography #'org-texmacs--cite-export-bibliography
 :cite-styles '((("nil"))))

(provide 'org-texmacs-cite-native)
;;; org-texmacs-cite-native.el ends here
