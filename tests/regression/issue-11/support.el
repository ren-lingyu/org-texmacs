;;; support.el --- Suite-local fixtures -*- lexical-binding: t; -*-

(defconst org-texmacs-test--fragment-strees
  '((math (frac "1" (sqrt "x")))
    (equation (frac "1" (sqrt "x")))
    (equation* (frac "1" (sqrt "x")))
    (eqnarray
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1"))
       (row (cell "y") (cell "=") (cell "2")))))
    (eqnarray*
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1"))
       (row (cell "y") (cell "=") (cell "2")))))
    (align
     (tformat
      (table
       (row (cell "x") (cell "=1")) (row (cell "y") (cell "=2")))))
    (align*
     (tformat
      (table
       (row (cell "x") (cell "=1")) (row (cell "y") (cell "=2")))))
    (gather (tformat (table (row (cell "x=1")) (row (cell "y=2")))))
    (gather* (tformat (table (row (cell "x=1")) (row (cell "y=2")))))
    (eqsplit
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1+2"))
       (row (cell "") (cell "=") (cell "3")))))
    (eqsplit*
     (tformat
      (table
       (row (cell "x") (cell "=") (cell "1+2"))
       (row (cell "") (cell "=") (cell "3"))))))
  "Representative default roots, including actual multi-row formula tables.
These fixtures test AST preservation, not numbering or rendering semantics.")

(defun org-texmacs-test--issue11-source (context payload)
  "Wrap PAYLOAD in a supported CONTEXT, suppressing document metadata."
  (concat
   "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
   (pcase context
     ('body payload)
     ('quote (concat "#+begin_quote\n" payload "#+end_quote\n"))
     ('center (concat "#+begin_center\n" payload "#+end_center\n"))
     ('footnote
      (concat
       "Text[fn:n]. Again[fn:n].\n\n[fn:n]\n"
       (replace-regexp-in-string "^" "  " payload)))
     ('list
      (concat
       "- Intro\n\n" (replace-regexp-in-string "^" "  " payload))))))

;;; support.el ends here
