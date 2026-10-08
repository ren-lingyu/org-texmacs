;;; inline-followup-20260911.el --- Targeted follow-up -*- lexical-binding: t; -*-
(require 'org-element)
(require 'cl-lib)
(require 'scheme)
;; Reuse definitions only; do not repeat the first probe's test runs.
(with-temp-buffer
  (insert-file-contents "tmp/inline-probe-20260911.el")
  (goto-char (point-min))
  (condition-case nil
      (while t
        (let ((form (read (current-buffer))))
          (when (memq (car-safe form) '(defun defvar)) (eval form t))))
    (end-of-file nil)))

(with-temp-buffer
  (org-mode)
  (inline-probe-report
   "ORG-SYNTAX"
   (mapcar (lambda (char) (list (char-to-string char) (char-to-string (char-syntax char))))
           '(?\" ?\\ ?\; ?\( ?\))))
  (insert "A (math ;; ) comment\n \"x\") B")
  (goto-char (point-min))
  (search-forward "(")
  (let ((start (1- (point))))
    (with-syntax-table scheme-mode-syntax-table
      (inline-probe-report "SCHEME-TABLE-COMMENT"
                           (buffer-substring-no-properties start (scan-sexps start 1)))
      (let ((parse-sexp-ignore-comments t)
            (parse-sexp-lookup-properties nil))
        (inline-probe-report "SCHEME-TABLE-IGNORE-COMMENTS"
                             (buffer-substring-no-properties start (scan-sexps start 1)))))))

(let* ((original (symbol-function 'org-element--object-lex))
       (org-element-all-objects (cons 'texmacs-inline org-element-all-objects))
       (org-element-object-restrictions
        (cons (cons 'paragraph (cons 'texmacs-inline
                                     (cdr (assq 'paragraph org-element-object-restrictions))))
              org-element-object-restrictions)))
  (cl-letf (((symbol-function 'org-element--object-lex)
             (lambda (restriction)
               (let ((native (save-excursion (funcall original restriction)))
                     (foreign (and (memq 'texmacs-inline restriction)
                                   (inline-probe-candidate))))
                 (if (and foreign (or (not native)
                                      (< (org-element-property :begin foreign)
                                         (org-element-property :begin native))))
                     foreign native)))))
    (with-temp-buffer
      (org-mode)
      (insert "A (math (frac \"1\" \"2\")) B\n")
      (let ((tree (org-element-parse-buffer)))
        (inline-probe-report "INTERPRET-WITHOUT-METHOD"
                             (substring-no-properties (org-element-interpret-data tree)))
        (cl-letf (((symbol-function 'org-element-texmacs-inline-interpreter)
                   (lambda (node _contents) (org-element-property :value node))))
          (inline-probe-report "INTERPRET-WITH-METHOD"
                               (substring-no-properties (org-element-interpret-data tree))))))))
