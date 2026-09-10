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

(define (org-texmacs-reply request)
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
