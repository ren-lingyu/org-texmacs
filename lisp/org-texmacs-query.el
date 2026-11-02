;;; org-texmacs-query.el --- Freeze standard Org queries -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Query the real Org export transaction before ownership changes identities.
;; Return finite structural data; keep INFO and its mutable caches out of models.

;;; Code:

(require 'ox)
(require 'org-texmacs-prepared)

(defun org-texmacs--query-snapshot
    (tree info identities &optional discover-note)
  "Freeze Org query results for adapted TREE using live INFO and IDENTITIES.
IDENTITIES maps original Org nodes to their adapted owned nodes.  Query original
nodes in the actual transaction; copied INFO retains old identity caches.
STM islands must already be discovered so their Org parsing residue is opaque."
  (let ((reachable (make-hash-table :test #'eq))
        (originals (make-hash-table :test #'eq))
        (visited (make-hash-table :test #'eq))
        (definitions (make-hash-table :test #'eq))
        (traversal
         (list
          :ignore-list
          (org-element-map
           tree 'headline
           (lambda (node)
             (and (org-element-property :footnote-section-p node)
                  node)))))
        targets
        notes
        headings
        references)
    (org-element-map
     tree t (lambda (node) (puthash node t reachable)) nil nil nil t)
    (maphash
     (lambda (original owned)
       (puthash owned original originals))
     identities)
    (cl-labels
     ((walk
       (data &optional in-note)
       (org-element-map
        data '(headline link footnote-reference)
        (lambda (owned)
          (unless (gethash owned visited)
            (puthash owned t visited)
            (let ((original (gethash owned originals)))
              (unless original
                (org-texmacs--prepared-fail
                 "Missing original Org query identity"))
              (pcase (org-element-type owned)
                ('headline
                 (let ((numbered
                        (org-export-numbered-headline-p
                         original info)))
                   (push (list
                          owned
                          (org-export-get-relative-level
                           original info)
                          (and numbered t)
                          (and numbered
                               (org-export-get-headline-number
                                original info)))
                         headings)))
                ('link
                 (when (member
                        (org-element-property :type owned)
                        '("fuzzy" "id" "custom-id"))
                   (let* ((original-target
                           (if (equal
                                (org-element-property
                                 :type owned)
                                "fuzzy")
                               (org-export-resolve-fuzzy-link
                                original info)
                             (org-export-resolve-id-link
                              original info)))
                          (target
                           (gethash original-target identities)))
                     (unless (and target (gethash target reachable))
                       (org-texmacs--prepared-fail
                        "Org target is outside the rendered mathematical document"))
                     (push (cons owned target) targets))))
                ('footnote-reference
                 (when in-note
                   (org-texmacs--prepared-fail
                    "Nested footnotes are unsupported"))
                 (let* ((body
                         (org-export-get-footnote-definition
                          original info))
                        (definition
                         (if (eq
                              (org-element-property :type original)
                              'inline)
                             original
                           (and body
                                (org-element-property
                                 :parent (car body)))))
                        (owned-definition
                         (gethash definition identities)))
                   (unless (and owned-definition
                                (gethash owned-definition reachable))
                     (org-texmacs--prepared-fail
                      "Org footnote definition is outside prepared structures"))
                   (push (list
                          owned owned-definition
                          (org-export-get-footnote-number
                           original info)
                          (and (org-export-footnote-first-reference-p
                                original info)
                               t))
                         notes)
                   (unless (gethash owned-definition definitions)
                     (puthash owned-definition t definitions)
                     (when (and discover-note
                                (eq
                                 (org-element-type
                                  owned-definition)
                                 'footnote-definition))
                       (funcall discover-note owned-definition))
                     (walk
                      (org-element-contents owned-definition)
                      t))))))))
        traversal nil '(footnote-definition) t)))
     (walk tree))
    ;; Org may keep unreferenced definitions and supplemental copies.  Its
    ;; query selects the definition identity that contributes native content.
    (org-element-map
     tree 'footnote-definition
     (lambda (node)
       (unless (gethash node definitions)
         (org-element-extract-element node))))
    (dolist (owned
             (delete-dups
              (append
               (mapcar #'cdr targets)
               (org-element-map
                tree 'special-block
                (lambda
                  (node)
                  (and (org-element-property :name node) node))))))
      (when owned
        (push (cons
               owned
               (org-export-get-reference
                (gethash owned originals) info))
              references)))
    (list
     :targets (nreverse targets)
     :footnotes (nreverse notes)
     :headlines (nreverse headings)
     :references (nreverse references))))

(provide 'org-texmacs-query)
;;; org-texmacs-query.el ends here
