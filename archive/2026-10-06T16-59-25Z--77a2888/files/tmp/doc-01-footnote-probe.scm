(load "/home/lingyu/Projects/org-texmacs/org-texmacs-worker.scm")
(define (org-texmacs-parse-reply request)
  (list 'ok (cadr request)
        (org-texmacs-with-session-buffer
         (lambda ()
           (cons 'footnote-probe
                 (map (lambda (name)
                        (list 'definition name (tree->stree (get-env-tree name))))
                      '("footnote" "footnote-text" "footnotemark*"
                        "footnote-ref" "next-footnote")))))))
