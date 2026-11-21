;;; org-texmacs-stm.el --- Native STM text subset -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Read and write a subset of native STM without running TeXmacs.
;; Tree ownership is independent of the syntax supported by this codec.

;;; Code:

(require 'org-texmacs-core)

(defun org-texmacs--stm-copy (tree &optional error-type ancestors)
  "Validate and copy STM TREE without native parsing.
ERROR-TYPE defaults to `org-texmacs-model-error'.  ANCESTORS detects cycles;
noncyclic repeated subtrees are copied independently."
  (cond
   ((stringp tree)
    (substring-no-properties tree))
   ((and (consp tree)
         (car tree)
         (symbolp (car tree))
         (proper-list-p tree)
         (not (memq tree ancestors)))
    (cons
     (car tree)
     (mapcar
      (lambda (child)
        (org-texmacs--stm-copy child
                               error-type
                               (cons tree ancestors)))
      (cdr tree))))
   (t
    (signal (or error-type 'org-texmacs-model-error)
            '("Invalid island stree")))))

(defconst org-texmacs--stm-tag-regexp "[A-Za-z][A-Za-z0-9_*-]*"
  "Unescaped tag names in the supported native STM text subset.")

(defun org-texmacs--stm-text-char-p (character)
  "Return non-nil when CHARACTER is supported inside an STM string."
  (or (memq character '(?\n ?\r ?\t))
      (and (<= 32 character #x10ffff)
           (not (<= 127 character 159))
           (not (<= #xd800 character #xdfff)))))

(defun org-texmacs--stm-unquote (characters)
  "Apply native scm_unquote to the already unescaped CHARACTERS.
TeXmacs runs this pass after unslash, including on hand-written STM."
  (let (decoded)
    (while characters
      (let ((character (pop characters)))
        (when (and (= character ?\\)
                   (memq (car characters) '(?\\ ?\")))
          (setq character (pop characters)))
        (push character decoded)))
    (concat (nreverse decoded))))

(defun org-texmacs--stm-read (source)
  "Read one owned STM tree from SOURCE under the native syntax subset."
  (unless (stringp source)
    (signal 'org-texmacs-parse-error '("Expected STM text")))
  (let ((cursor 0)
        (end (length source))
        (case-fold-search nil)
        (read-symbol-shorthands nil))
    (cl-labels
     ((peek () (and (< cursor end) (aref source cursor)))
      (take
       ()
       (prog1 (peek)
         (cl-incf cursor)))
      (space () (memq (peek) '(?\s ?\t ?\n ?\r)))
      (skip
       ()
       (while (space)
         (take)))
      (fail
       (message)
       (signal 'org-texmacs-parse-error (list message cursor)))
      (read-string ()
                   (take)
                   (let (characters)
                     (while (not (eq (peek) ?\"))
                       (let ((character (take)))
                         (unless (and character
                                      (org-texmacs--stm-text-char-p
                                       character))
                           (fail
                            "Unterminated or invalid STM string"))
                         (when (= character ?\\)
                           (setq character
                                 (pcase (take)
                                   (?n ?\n)
                                   (?r ?\r)
                                   (?t ?\t)
                                   (?\" ?\")
                                   (?\\ ?\\)
                                   (_
                                    (fail
                                     "Unsupported STM escape")))))
                         (push character characters)))
                     (take)
                     (org-texmacs--stm-unquote
                      (nreverse characters))))
      (read-list
       () (take) (skip)
       (unless (and (string-match org-texmacs--stm-tag-regexp source
                                  cursor)
                    (= (match-beginning 0) cursor))
         (fail "Unsupported STM tag"))
       (let ((tag (intern (match-string-no-properties 0 source)))
             children)
         (setq cursor (match-end 0))
         (unless tag
           (fail "Unsupported STM tag"))
         (while (space)
           (skip)
           (unless (eq (peek) ?\))
             (push (read-tree) children)))
         (unless (eq (take) ?\))
           (fail "Expected STM list separator"))
         (cons tag (nreverse children))))
      (read-tree
       ()
       (pcase (peek)
         (?\" (read-string))
         (?\( (read-list))
         (_ (fail "Expected an STM string or tagged list")))))
     (save-match-data
       (skip)
       (let ((tree (read-tree)))
         (skip)
         (unless (= cursor end)
           (fail "Trailing STM input"))
         tree)))))

(defun org-texmacs--stm-write (tree)
  "Write TREE in the supported native STM subset."
  (let ((case-fold-search nil)
        (read-symbol-shorthands nil))
    (cl-labels
     ((fail
       (message reason value)
       (signal 'org-texmacs-model-serialization-error
               (list message (list :reason reason :value value))))
      (write-node
       (node)
       (if (stringp node)
           (concat
            "\""
            (mapconcat (lambda (character)
                         (pcase character
                           (?\" (concat (make-string 3 ?\\) "\""))
                           (?\\ (make-string 4 ?\\))
                           (?\n "\\n")
                           (?\r "\\r")
                           (?\t "\\t")
                           (_
                            (unless (org-texmacs--stm-text-char-p
                                     character)
                              (fail
                               "Unsupported STM character"
                               'unsupported-character
                               character))
                            (char-to-string character))))
                       node
                       "")
            "\"")
         (let* ((tag (car node))
                (name (symbol-name tag)))
           (unless (and (eq (intern-soft name) tag)
                        (string-match-p
                         (concat
                          "\\`" org-texmacs--stm-tag-regexp "\\'")
                         name))
             (fail "Unsupported STM symbol" 'unsupported-symbol tag))
           (concat
            "(" name
            (mapconcat (lambda (child)
                         (concat " " (write-node child)))
                       (cdr node)
                       "")
            ")")))))
     (write-node
      (org-texmacs--stm-copy
       tree
       'org-texmacs-model-serialization-error)))))

(provide 'org-texmacs-stm)
;;; org-texmacs-stm.el ends here
