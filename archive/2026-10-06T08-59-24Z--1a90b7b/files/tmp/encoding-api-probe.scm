;; Fixed encoding observations; no IPC evaluation interface.
(define (api-log key value)
  (display "ENCODING ") (write key) (display " ")
  (org-texmacs-write-elisp value (current-output-port))
  (newline) (force-output))
(define (api-case key thunk)
  (catch #t (lambda () (api-log key (thunk)))
    (lambda args (api-log 'case-error (list key args)))))
(define (api-main)
  (import-from (convert tmml tmmltm))
  (for-each (lambda (name) (api-log 'capability (list name (defined? name))))
    '(utf8->cork cork->utf8 unescape-angles parse-tmml tmml->texmacs stree->tree))
  (for-each
    (lambda (s)
      (api-case 'leaf
        (lambda ()
          (let* ((encoded (utf8->cork s))
                 (restored (unescape-angles encoded)))
            (list s encoded restored (cork->utf8 restored)
                  (equal? restored (unescape-angles (utf8->cork restored))))))))
    '("ASCII" "中文" "α" "<alpha>" "<#4E2D>" "<less>" "<gtr>"
      "中文 α <alpha>" "<less>alpha<gtr>" "<" ">" "a<b>c"
      "<unknown-symbol>" "<unfinished" "quote\"slash\\" "é"))
  (for-each
    (lambda (pair)
      (api-case 'tmml-direct
        (lambda ()
          (let ((out (tmml->texmacs (car pair))))
            (list (car pair) out (cadr pair) (equal? out (cadr pair))
                  (equal? out (tree->stree (stree->tree out))))))))
    '(("<alpha>" "<less>alpha<gtr>")
      ((tm-sym "alpha") "<alpha>")
      ((tm-sym "#4E2D") "<#4E2D>")
      ((tm-sym "unknown-symbol") "<unknown-symbol>")
      ((!concat "中文 α " (tm-sym "alpha") " <alpha>")
       "<#4E2D><#6587> <alpha> <alpha> <less>alpha<gtr>")))
  (for-each
    (lambda (xml)
      (api-case 'tmml-xml
        (lambda ()
          (let* ((parsed (parse-tmml xml)) (out (tmml->texmacs parsed)))
            (list xml parsed out (equal? out (tree->stree (stree->tree out))))))))
    '("<math>α</math>" "<math>&lt;alpha&gt;</math>"
      "<math><tm-sym>alpha</tm-sym></math>"
      "<math>中文 α <tm-sym>alpha</tm-sym> &lt;alpha&gt;</math>"
      "<math xml:space=\"preserve\"> x  <tm-sym>alpha</tm-sym> y </math>"
      "<math> x  <tm-sym>alpha</tm-sym> y </math>"))
  (api-log 'complete #t))
(catch #t (lambda () (api-main))
  (lambda args (api-log 'failure args)))
(quit-TeXmacs)
