;;; org-texmacs-ast.el --- AST adapters for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Convert between TeXmacs strees and Org-compatible pseudo trees.

;;; Code:

(require 'org-texmacs-core)

(defun org-texmacs--stree-to-org (node)
  "Convert TeXmacs stree NODE to an Org-compatible pseudo tree.

Copy string nodes before adopting them into the Org tree.  This keeps Org's
text properties, including parent links, out of the source stree."
  (cond
   ((stringp node)
    (substring-no-properties node))
   ((consp node)
    (apply #'org-element-create
           (car node)
           nil
           (mapcar #'org-texmacs--stree-to-org
                   (cdr node))))
   (t
    node)))

(defun org-texmacs--org-to-stree (node)
  "Convert Org-compatible pseudo tree NODE to a TeXmacs stree.

Ignore Org's properties storage and remove text properties from copied string
nodes."
  (cond
   ((stringp node)
    (substring-no-properties node))
   ((and (consp node)
         (symbolp (car node)))
    (cons (car node)
          (mapcar #'org-texmacs--org-to-stree
                  (org-element-contents node))))
   (t
    node)))

(provide 'org-texmacs-ast)

;;; org-texmacs-ast.el ends here
