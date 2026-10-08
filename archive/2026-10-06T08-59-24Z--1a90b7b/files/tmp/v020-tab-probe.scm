;; Observe conversions; a non-inverse decode is data, not an automatic failure.
(define v020-tab-failed #f)
(define (v020-tab-log key value)
  (display "V020 ") (write key) (display " ")
  (org-texmacs-write-elisp value (current-output-port))
  (newline) (force-output))
(define (v020-tab-case key thunk)
  (catch #t (lambda () (v020-tab-log key (thunk)))
    (lambda args
      (set! v020-tab-failed #t)
      (v020-tab-log 'case-error (list key args)))))
(define (v020-tab-stree value)
  (if (tree? value) (tree->stree value) value))
(define (v020-tab-bytes node)
  (if (string? node) (map char->integer (string->list node))
      (cons (car node) (map v020-tab-bytes (cdr node)))))
(define (v020-tab-decode node)
  (if (string? node) (cork->utf8 node)
      (cons (car node) (map v020-tab-decode (cdr node)))))
(define (v020-tab-observe-native buffer label body)
  (v020-tab-case label
    (lambda ()
      (buffer-set-body buffer (stree->tree body))
      (let ((readback (tree->stree (buffer-get-body buffer))))
        (list (equal? body readback) (v020-tab-bytes body)
              (v020-tab-decode readback))))))
(catch #t
  (lambda ()
    (import-from (convert rewrite init-rewrite))
    (let ((buffer (buffer-new)))
      (for-each
        (lambda (source)
          (v020-tab-case 'leaf
            (lambda ()
              (let ((encoded (utf8->cork source)))
                (list source (map char->integer (string->list source))
                      (v020-tab-bytes encoded) (cork->utf8 encoded)
                      (equal? source (cork->utf8 encoded))))))
          (for-each
            (lambda (tag)
              (v020-tab-observe-native
                buffer (list 'encoded tag source)
                (org-texmacs-encode-body
                  (list 'document (list tag source)) '())))
            '(concat verbatim))
          (v020-tab-case 'code-snippet
            (lambda ()
              (let ((node (v020-tab-stree (code-snippet->texmacs source))))
                (v020-tab-observe-native buffer 'code-readback
                  (list 'document node))
                (list source (v020-tab-bytes node) (v020-tab-decode node)))))
          (v020-tab-case 'verbatim-utf8
            (lambda ()
              (let ((node (v020-tab-stree
                            (verbatim-snippet->texmacs source
                              '(("verbatim->texmacs:encoding" . "UTF-8"))))))
                (list source (v020-tab-bytes node) (v020-tab-decode node))))))
        '("\t" "a\tb" "a  b" "a\nb" "<alpha>" "中文\t<alpha>" "¯"))
      ;; Direct native byte observations distinguish the encoder from decoder.
      (for-each
        (lambda (byte)
          (v020-tab-case 'native-byte
            (lambda ()
              (let* ((native (string (integer->char byte)))
                     (decoded (cork->utf8 native)))
                (list byte decoded (v020-tab-bytes (utf8->cork decoded)))))))
        '(9 10 32))
      (buffer-close buffer))
    (v020-tab-log 'complete (not v020-tab-failed)))
  (lambda args (v020-tab-log 'fatal args)))
(quit-TeXmacs)
