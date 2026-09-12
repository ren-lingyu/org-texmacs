;; org-texmacs-worker.scm --- Headless STM parser service
;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;; Loaded by TeXmacs, not standalone Guile.  Source is data, never evaluated.

(define (org-texmacs-stree? node)
  (or (string? node)
      (and (list? node) (pair? node) (symbol? (car node))
           (let loop ((children (cdr node)))
             (or (null? children)
                 (and (org-texmacs-stree? (car children))
                      (loop (cdr children))))))))

(define (org-texmacs-parse source)
  (let* ((port (open-input-string source))
         (datum (read port)))
    (if (or (eof-object? datum)
            (not (eof-object? (read port)))
            (not (org-texmacs-stree? datum)))
        (error "Expected exactly one STM datum"))
    (let ((tree (tree->stree (stm-snippet->texmacs source))))
      (if (not (org-texmacs-stree? tree))
          (error "Parser returned an invalid stree"))
      tree)))

(define (org-texmacs-wire-tree node)
  ;; Tags travel as strings, avoiding cross-reader symbol syntax differences.
  (cond ((string? node) node)
        ((and (list? node) (pair? node) (string? (car node))
              (not (string=? (car node) "raw-data")))
         (cons (string->symbol (car node))
               (map org-texmacs-wire-tree (cdr node))))
        (else (error "Invalid text tree"))))

(define (org-texmacs-check-paths body paths)
  (if (not (list? paths)) (error "Invalid STM paths"))
  (for-each
   (lambda (path)
     (if (not (list? path)) (error "Invalid STM path"))
     (let loop ((node body) (steps path))
       (if (pair? steps)
           (let ((index (car steps)))
             (if (not (and (integer? index) (>= index 0) (pair? node)
                           (< index (length (cdr node)))))
                 (error "STM path is out of bounds"))
             (loop (list-ref (cdr node) index) (cdr steps))))))
   paths)
  (let outer ((rest paths))
    (if (pair? rest)
        (begin
          (for-each
           (lambda (other)
             (let prefix ((a (car rest)) (b other))
               (cond ((or (null? a) (null? b)) (error "Overlapping STM paths"))
                     ((= (car a) (car b)) (prefix (cdr a) (cdr b))))))
           (cdr rest))
          (outer (cdr rest))))))

(define (org-texmacs-encode-body body paths)
  ;; Only this operation requires encoding/native tree capabilities.
  (for-each
   (lambda (name)
     (if (not (defined? name)) (error "Missing encoding capability" name)))
   '(utf8->cork string-replace stree->tree tree->stree))
  (org-texmacs-check-paths body paths)
  (let walk ((node body) (path '()) (stm? #f))
    (let ((native-source? (or stm? (member path paths))))
      (if (string? node)
          (let ((encoded (utf8->cork node)))
            (if native-source?
                ;; Preserve STM source notation, including explicit <less>/<gtr>.
                (string-replace (string-replace encoded "<less>" "<") "<gtr>" ">")
                encoded))
          (cons (car node)
                (let children ((rest (cdr node)) (index 0))
                  (if (null? rest) '()
                      (cons (walk (car rest) (append path (list index)) native-source?)
                            (children (cdr rest) (+ index 1))))))))))

(define (org-texmacs-hex-tree node)
  ;; Encode native bytes as ASCII hex, not as UTF-8 text on the socket.
  (if (string? node)
      (apply string-append
             (map (lambda (character)
                    (let* ((byte (char->integer character))
                           (hex (number->string byte 16)))
                      (if (> byte 255) (error "Expected native bytes"))
                      (if (< byte 16) (string-append "0" hex) hex)))
                  (string->list node)))
      (cons (car node) (map org-texmacs-hex-tree (cdr node)))))

(define (org-texmacs-encode-reply request)
  (let ((id (cadr request)))
    (catch #t
      (lambda ()
        (let ((body (org-texmacs-wire-tree (caddr request))))
          (if (not (and (pair? body) (eq? (car body) 'document)))
              (error "Expected document body"))
          (let* ((encoded (org-texmacs-encode-body body (cadddr request)))
                 (native (tree->stree (stree->tree encoded))))
            (if (not (equal? encoded native)) (error "Native tree changed structure"))
            (list 'ok id (list 'native-body (org-texmacs-hex-tree native))))))
      (lambda args (list 'encoding-error id "Invalid document encoding request")))))

(define (org-texmacs-reply request)
  (if (and (list? request) (= (length request) 4)
           (eq? (car request) 'encode)
           (integer? (cadr request)) (> (cadr request) 0))
      (org-texmacs-encode-reply request)
      (org-texmacs-parse-reply request)))

(define (org-texmacs-parse-reply request)
  (if (and (list? request) (= (length request) 3)
           (eq? (car request) 'parse)
           (integer? (cadr request)) (> (cadr request) 0)
           (string? (caddr request)))
      (let ((id (cadr request)))
        (catch #t
          (lambda () (list 'ok id (org-texmacs-parse (caddr request))))
          (lambda args (list 'error id "Invalid STM source"))))
      '(error 0 "Invalid request")))

(define (org-texmacs-write-elisp datum port)
  ;; Guile's hexadecimal string escapes are not delimited the same way in
  ;; Emacs Lisp.  Emit literal characters, escaping only quotes/backslashes.
  ;; Escape symbol characters too, so numeric-looking tags stay symbols.
  ;; This writes response data; it does not parse or evaluate STM source.
  (cond
   ((string? datum)
    (write-char #\" port)
    (for-each
     (lambda (character)
       (if (or (char=? character #\") (char=? character #\\))
           (write-char #\\ port))
       (write-char character port))
     (string->list datum))
    (write-char #\" port))
   ((symbol? datum)
    (let ((name (symbol->string datum)))
      (if (string=? name "")
          (display "##" port)
          (for-each
           (lambda (character)
             (write-char #\\ port)
             (write-char character port))
           (string->list name)))))
   ((list? datum)
    (display "(" port)
    (let loop ((items datum))
      (if (pair? items)
          (begin
            (org-texmacs-write-elisp (car items) port)
            (if (pair? (cdr items)) (display " " port))
            (loop (cdr items)))))
    (display ")" port))
   (else (write datum port))))

(define (org-texmacs-serve socket-path)
  ;; Check the Scheme interfaces here, in the runtime that provides them.
  (for-each
   (lambda (name)
     (if (not (defined? name)) (error "Missing worker capability" name)))
   '(socket bind listen accept close-port force-output AF_UNIX SOCK_STREAM
     stm-snippet->texmacs tree->stree))
  (let ((server (socket AF_UNIX SOCK_STREAM 0)))
    (bind server AF_UNIX socket-path)
    (listen server 1)
    (display "ORG-TEXMACS-READY\n")
    (force-output)
    (let loop ()
      (let ((client (car (accept server))))
        ;; Includes read/write failures and a client disconnecting early.
        (catch #t
          (lambda ()
            (org-texmacs-write-elisp (org-texmacs-reply (read client)) client)
            (newline client)
            (force-output client))
          (lambda args #f))
        (catch #t (lambda () (close-port client)) (lambda args #f)))
      (loop))))
