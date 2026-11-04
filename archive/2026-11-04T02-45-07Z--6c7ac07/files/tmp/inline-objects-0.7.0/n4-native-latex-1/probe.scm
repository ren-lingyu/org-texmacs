(use-modules (generic document-edit))
(define (source-node n)
  (if (string? n)
      (apply string-append
             (map (lambda (c) (if (> (char->integer c) 127)
                                  (cork->utf8 (string c)) (string c)))
                  (string->list n)))
      (if (pair? n) (cons (car n) (map source-node (cdr n))) n)))
(define samples
  '((cdot "$\\cdot$") (paren-cdot "\\(\\cdot\\)")
    (greek "$\\alpha_i$") (fraction "$\\frac{a}{b}$")
    (unicode "$α_i$") (missing-brace "$\\frac{a}{b$")
    (missing-argument "$\\frac{a}$") (unknown "$\\orgtexmacsunknown{a}$")
    (missing-dollar "$\\alpha_i")
    (macro "$\\newcommand{\\myop}{x}\\myop$")))
(define (attempt round op entry)
  (catch #t
    (lambda ()
      (let* ((source (cadr entry))
             (result (if (eq? op 'parse)
                         (parse-latex source)
                         (convert source "latex-snippet" "texmacs-stree")))
             (data (if (tree? result) (tree->stree result) result)))
        (list 'ok round op (car entry) source (source-node data))))
    (lambda args (list 'error round op (car entry) (cadr entry)
                       (let ((p (open-output-string))) (write args p) (get-output-string p))))))
(define (run-probe output)
  (call-with-output-file output
    (lambda (port)
      (write
       (list
        (list 'capabilities
              (if (defined? 'latex-snippet->texmacs) 'yes 'no)
              (if (defined? 'convert) 'yes 'no))
        (apply append
               (map (lambda (round)
                      (apply append
                             (map (lambda (op)
                                    (map (lambda (entry) (attempt round op entry)) samples))
                                  '(convert parse))))
                    '(1 2)))) port)
      (newline port)))
  (display "LATEX-PROBE-DONE\n"))
