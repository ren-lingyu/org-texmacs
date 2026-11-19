;;; org-texmacs-cite.el --- Structural citation contracts -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Pure contracts for native requests.  No processor dispatch or source access.

;;; Code:

(require 'org-texmacs-core)
(require 'subr-x)

(defun org-texmacs--cite-fail (message)
  "Reject a native request with MESSAGE."
  (signal 'org-texmacs-document-error (list message)))

(defun org-texmacs--cite-affix-empty-p (value)
  "Whether parsed affix VALUE has no non-whitespace content."
  (and (proper-list-p value)
       (cl-every
        (lambda (part)
          (and (stringp part) (string-blank-p part)))
        value)))

(defun org-texmacs--cite-key-p (key)
  "Whether KEY is supported by the native citation contract."
  (and (stringp key) (string-match-p "\\`[-A-Za-z0-9_:.+]+\\'" key)))

(defun org-texmacs--cite-detail (suffix)
  "Return owned native detail text for parsed reference SUFFIX, or nil.
Only plain text on one line is supported.  An optional leading comma is
citation punctuation, supplied by TeXmacs' `render-cite-detail' instead.
Do not interpret locator terms, infer page numbers or flatten Org objects."
  (unless (org-texmacs--cite-affix-empty-p suffix)
    (unless (and (proper-list-p suffix) (cl-every #'stringp suffix))
      (org-texmacs--cite-fail "Unsupported native citation detail"))
    (let ((detail (mapconcat #'substring-no-properties suffix "")))
      (when (string-match-p "[\r\n]" detail)
        (org-texmacs--cite-fail
         "Unsupported multiline citation detail"))
      (setq detail (string-trim detail))
      (when (string-prefix-p "," detail)
        (setq detail (string-trim (substring detail 1))))
      (when (string-empty-p detail)
        (org-texmacs--cite-fail "Empty native citation detail"))
      detail)))

(defun org-texmacs--cite-group (citation)
  "Validate CITATION and return owned (:keys KEYS :detail DETAIL).
KEYS retain reference order.  DETAIL is nil for a bare group or a plain
reference suffix for a single-key citation.  The native `cite-detail'
macro does not represent a group of independently qualified references."
  (unless (and (eq (org-element-type citation) 'citation)
               (null (org-element-property :style citation))
               (org-texmacs--cite-affix-empty-p
                (org-element-property :prefix citation))
               (org-texmacs--cite-affix-empty-p
                (org-element-property :suffix citation))
               (org-element-contents citation))
    (org-texmacs--cite-fail
     "Unsupported native citation style or affixes"))
  (let (keys
        detail)
    (dolist (reference (org-element-contents citation))
      (let ((key (org-element-property :key reference)))
        (unless (and (eq
                      (org-element-type reference)
                      'citation-reference)
                     (org-texmacs--cite-key-p key)
                     (org-texmacs--cite-affix-empty-p
                      (org-element-property :prefix reference)))
          (org-texmacs--cite-fail
           "Unsupported native citation reference"))
        (push (substring-no-properties key) keys)
        (when-let* ((suffix
                     (org-texmacs--cite-detail
                      (org-element-property :suffix reference))))
          (unless (= (length (org-element-contents citation)) 1)
            (org-texmacs--cite-fail
             "Native citation detail requires exactly one reference"))
          (setq detail suffix))))
    (list :keys (nreverse keys) :detail detail)))

(defun org-texmacs--cite-request-p (request fields)
  "Whether REQUEST is a plist with exactly the unique keyword FIELDS."
  (and (proper-list-p request)
       (= (length request) (* 2 (length fields)))
       (let ((names
              (cl-loop
               for (key _value) on request by #'cddr collect key)))
         (and (= (length names)
                 (length (delete-dups (copy-sequence names))))
              (null (cl-set-difference fields names))))))

(defun org-texmacs--cite-view (ast requests)
  "Validate REQUESTS against AST, returning a minimal native usage view.
REQUESTS is an identity alist, not a request to traverse AST for citations.
Only supplied carriers are interpreted; membership checks also visit metadata."
  (unless (proper-list-p requests)
    (org-texmacs--cite-fail "Expected native citation request alist"))
  (let ((nodes (make-hash-table :test #'eq))
        seen
        citations
        prints
        wanted
        print-request)
    (org-element-map
     ast t
     (lambda (node)
       (when (consp node)
         (puthash node t nodes)))
     nil nil nil t)
    (dolist (pair requests)
      (unless (and (consp pair)
                   (gethash (car pair) nodes)
                   (not (memq (car pair) seen))
                   (proper-list-p (cdr pair)))
        (org-texmacs--cite-fail
         "Detached, duplicate or invalid native citation request"))
      (push (car pair) seen)
      (let* ((node (car pair))
             (request (cdr pair))
             (keys (plist-get request :keys)))
        (unless (and (proper-list-p keys)
                     (cl-every #'org-texmacs--cite-key-p keys))
          (org-texmacs--cite-fail "Invalid native citation keys"))
        (pcase (plist-get request :kind)
          ('citation
           (let ((group (org-texmacs--cite-group node)))
             (unless (and (org-texmacs--cite-request-p
                           request
                           '(:kind :keys :detail))
                          (equal keys (plist-get group :keys))
                          (equal
                           (plist-get request :detail)
                           (plist-get group :detail)))
               (org-texmacs--cite-fail
                "Stale native citation request"))
             (push (cons node group) citations))
           (dolist (key keys)
             (unless (member key wanted)
               (setq wanted (append wanted (list key))))))
          ('bibliography
           (unless (and (org-texmacs--cite-request-p
                         request
                         '(:kind :keys :files :style))
                        (eq (org-element-type node) 'keyword)
                        (equal
                         (org-element-property :key node)
                         "PRINT_BIBLIOGRAPHY")
                        (string-blank-p
                         (or (org-element-property :value node) ""))
                        (= (length keys)
                           (length
                            (delete-dups (copy-sequence keys))))
                        (proper-list-p (plist-get request :files))
                        (cl-every
                         (lambda (file)
                           (and (stringp file)
                                (file-name-absolute-p file)))
                         (plist-get request :files))
                        (stringp (plist-get request :style))
                        (not
                         (string-empty-p (plist-get request :style))))
             (org-texmacs--cite-fail
              "Invalid native bibliography request"))
           (setq print-request request)
           (push node prints))
          (_
           (org-texmacs--cite-fail
            "Unknown native citation request kind")))))
    (unless (or (and (null citations) (null prints))
                (= (length prints) 1))
      (org-texmacs--cite-fail
       "Native citations require exactly one bibliography print"))
    (when (cl-set-difference
           wanted
           (plist-get print-request :keys)
           :test #'equal)
      (org-texmacs--cite-fail
       "Native bibliography request omits citation keys"))
    (when (and wanted (null (plist-get print-request :files)))
      (org-texmacs--cite-fail
       "Native citations require bibliography sources"))
    (list
     :citations (nreverse citations)
     :prints (nreverse prints)
     ;; Retain Org's order, realizing exclusions from the identity projection.
     :keys
     (cl-remove-if-not
      (lambda (key) (member key wanted))
      (plist-get print-request :keys))
     :files (plist-get print-request :files)
     :style (plist-get print-request :style))))

(provide 'org-texmacs-cite)
;;; org-texmacs-cite.el ends here
