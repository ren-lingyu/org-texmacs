;;; org-texmacs.el --- TeXmacs trees in Org -*- lexical-binding: t; -*-

;; Copyright (C) 2026 aRenCoco

;; Author: aRenCoco
;; Maintainer: aRenCoco
;; Version: 0.0.1
;; Package-Requires: ((emacs "31.1") (org "9.8"))
;; Keywords: outlines
;; URL: https://github.com/ren-lingyu/org-texmacs
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Provide TeXmacs tree integration for Org.  Use
;; `org-texmacs-check-setup' to inspect the runtime capabilities required by
;; the package.

;;; Code:

(require 'org-texmacs-core)
(require 'org-texmacs-ast)
(require 'org-texmacs-source)
(require 'org-texmacs-worker)

;;;###autoload
(defun org-texmacs-check-setup ()
  "Check whether Org TeXmacs runtime capabilities are available.

Return a cons cell whose car is the boolean result and whose cdr is a
human-readable report.  When called interactively, also display that report."
  (interactive)
  (let ((result (org-texmacs--setup-check)))
    (when (called-interactively-p 'interactive)
      (message "%s"
               (concat
                (if (car result)
                    "Org TeXmacs setup checks passed.\n"
                  "Org TeXmacs setup checks failed.\n")
                (cdr result))))
    result))

(provide 'org-texmacs)

;;; org-texmacs.el ends here
