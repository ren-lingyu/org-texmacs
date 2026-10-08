;; Direct STM leaf conversion experiment, without XML or TMML.
(define (leaf-log key value)
  (display "LEAF ") (write key) (display " ")
  (org-texmacs-write-elisp value (current-output-port))
  (newline) (force-output))
(define leaf-failures 0)
(define leaf-unescape #f)
(define (leaf-check key actual expected)
  (let ((same (equal? actual expected)))
    (if (not same) (set! leaf-failures (+ leaf-failures 1)))
    (leaf-log key (list actual expected same))))
(define (leaf-main)
  ;; Use the real helper, not a copied/reimplemented definition.
  (import-from (convert latex tmtex))
  (leaf-log 'helper-available (defined? 'unescape-angles))
  ;; Diagnostic access only; this is not a production API recommendation.
  (set! leaf-unescape
    (module-ref (resolve-module '(convert latex tmtex)) 'unescape-angles))
  (leaf-log 'private-helper (procedure? leaf-unescape))
  (let ((convert (lambda (s) (leaf-unescape (utf8->cork s)))))
    (for-each
      (lambda (s)
        (leaf-check 'unicode (convert s) (utf8->cork s)))
      '("ASCII" "中文" "α" "é" "x\ny\tz" "quote\"slash\\"))
    (for-each
      (lambda (s)
        (leaf-check 'native-spelling (convert s) s))
      '("<alpha>" "<#4E2D>" "<less>" "<gtr>" "<less>alpha<gtr>"
        "<unknown-symbol>" "<less><less>alpha<gtr><gtr>"))
    (leaf-check 'mixed (convert "中文 α <alpha> é <less>alpha<gtr>")
      (string-append (utf8->cork "中文 α ") "<alpha>"
                     (utf8->cork " é ") "<less>alpha<gtr>"))
    (leaf-check 'literal-decoded (cork->utf8 (convert "<less>alpha<gtr>")) "<alpha>")
    (leaf-check 'symbol-decoded (cork->utf8 (convert "<alpha>")) "α")
    (leaf-check 'org-literal (cork->utf8 (utf8->cork "<alpha>")) "<alpha>")
    (for-each
      (lambda (s)
        (leaf-log 'ambiguous-input
          (list s (utf8->cork s) (convert s))))
      '("<" ">" "a<b>c" "<unfinished" "中文 <unknown-symbol>"))
    ;; Demonstrate why provenance and exactly-once conversion remain required.
    (let ((once (convert "é")))
      (leaf-log 'repeat-conversion (list once (convert once) (equal? once (convert once)))))
    (let* ((tree (list 'document
                  (list 'concat (utf8->cork "Org <alpha> 中文 ")
                    (list 'math (convert "α <alpha> é <less>alpha<gtr>")))))
           (buf (buffer-new)))
      (dynamic-wind (lambda () #t)
        (lambda ()
          (buffer-set-body buf (stree->tree tree))
          (leaf-check 'body-readback (tree->stree (buffer-get-body buf)) tree))
        (lambda () (buffer-close buf)))))
  (leaf-log 'failures leaf-failures)
  (leaf-log 'complete (= leaf-failures 0)))
(catch #t (lambda () (leaf-main))
  (lambda args (leaf-log 'failure args)))
(quit-TeXmacs)
