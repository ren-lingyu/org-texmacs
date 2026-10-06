;;; inline-probe-20260911.el --- Scoped environment probe -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'org-texmacs)
(load (expand-file-name "tests/ert/ert.el" default-directory) nil t)

(defun inline-probe-report (label value)
  (let ((print-circle t) (print-length nil) (print-level nil))
    (princ (format "%s %S\n" label value))))

(defvar inline-probe-syntax
  (let ((table (make-syntax-table)))
    (dolist (char '(?\[ ?\] ?\{ ?\} ?\; ?# ?\' ?` ?, ?|))
      (modify-syntax-entry char "." table))
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)
    table))

(defun inline-probe-end (start &optional dedicated)
  (let ((parse-sexp-lookup-properties nil))
    (condition-case nil
        (if dedicated
            (with-syntax-table inline-probe-syntax (scan-sexps start 1))
          (scan-sexps start 1))
      (scan-error nil))))

(defun inline-probe-candidate ()
  (save-excursion
    (let (found)
      (while (and (not found) (search-forward "(math" nil t))
        (let ((start (- (point) 5)))
          (when (memq (char-after) '(?\s ?\t ?\n ?\r ?\( ?\) ?\"))
            (when-let* ((end (inline-probe-end start t)))
              (setq found
                    (org-element-create
                     'texmacs-inline
                     (list :begin start :end end :post-blank 0
                           :value (buffer-substring-no-properties start end)
                           :buffer (current-buffer))))))))
      found)))

(defun inline-probe-summary (tree)
  (mapcar (lambda (node)
            (if (stringp node) (substring-no-properties node)
              (list (org-element-type node)
                    (org-element-property :value node))))
          (org-element-contents tree)))

(let ((cases '("A (math \"x\") B"
               "A (math (frac \"1\" (sqrt \"x\"))) B"
               "A (math (concat \"f(x)\" \"=\" \"1\")) B"
               "A (math (concat \"a)\\\"b\" \"c\\\\d\")) B"
               "A (math \"x\") B (math \"y\") C"
               "A (foo bar) B"
               "A (mathjax \"x\") B"
               "A (math (frac \"1\" \"2\") B"
               "A (math \"unclosed) B"
               "A (math\n (frac \"1\" \"2\")) B"
               "A (math (frac \"a[b\" \"c}d\")) B"
               "A (math ;; ) comment\n \"x\") B"
               "A (math\"x\") B"
               "A (math(frac \"1\" \"2\")) B"
               "A (math (unknown ...)) B")))
  (dolist (source cases)
    (with-temp-buffer
      (org-mode)
      (insert source)
      (goto-char (point-min))
      (search-forward "(")
      (let* ((start (1- (point)))
             (org-end (inline-probe-end start))
             (custom-end (inline-probe-end start t)))
        (inline-probe-report
         "SCAN" (list source
                      :org (and org-end (buffer-substring-no-properties start org-end))
                      :dedicated (and custom-end (buffer-substring-no-properties start custom-end))))))))

(with-temp-buffer
  (org-mode)
  (insert "A (math (concat \"*bold*\" \"[[file:x]]\")) B\n")
  (inline-probe-report
   "ORG-NATIVE"
   (org-element-map (org-element-parse-buffer) 'paragraph #'inline-probe-summary)))

;; The bindings below exist only for this batch probe.  No global advice or
;; source edits are installed.  Only paragraph permits the prototype object.
(let* ((original-lex (symbol-function 'org-element--object-lex))
       (org-element-all-objects (cons 'texmacs-inline org-element-all-objects))
       (org-element-object-restrictions
        (cons (cons 'paragraph
                    (cons 'texmacs-inline
                          (cdr (assq 'paragraph org-element-object-restrictions))))
              (assq-delete-all 'paragraph (copy-tree org-element-object-restrictions))))
       (org-element-use-cache t))
  (cl-letf (((symbol-function 'org-element--object-lex)
             (lambda (restriction)
               (let ((native (save-excursion (funcall original-lex restriction)))
                     (foreign (and (memq 'texmacs-inline restriction)
                                   (inline-probe-candidate))))
                 (if (and foreign
                          (or (not native)
                              (< (org-element-property :begin foreign)
                                 (org-element-property :begin native))))
                     foreign native)))))
    (dolist (source '("A (math (frac \"1\" \"2\")) B\n"
                      "A (math \"x\") B (math \"y\") C\n"
                      "A (math (concat \"*bold*\" \"[[file:x]]\")) B\n"
                      "A ~(math \"x\")~ B =(math \"y\")= C\n"
                      "A [[file:x][(math \"x\")]] B\n"
                      "A *(math \"x\")* B\n"
                      "A (mathjax \"x\") B (foo bar) C\n"
                      "A (math (frac \"1\" \"2\") B\n\nNew paragraph ) end.\n"
                      "#+begin_src scheme\n(math \"x\")\n#+end_src\n"
                      "* Heading (math \"x\")\n"))
      (with-temp-buffer
        (org-mode)
        (insert source)
        (let* ((tree (org-element-parse-buffer))
               (objects (org-element-map tree 'texmacs-inline #'identity)))
          (inline-probe-report
           "ORG-PROTOTYPE"
           (list source
                 :paragraphs (org-element-map tree 'paragraph #'inline-probe-summary)
                 :objects (mapcar (lambda (node)
                                    (list (org-element-property :value node)
                                          :parent (org-element-type
                                                   (org-element-property :parent node))))
                                  objects))))))
    (with-temp-buffer
      (org-mode)
      (insert "A (math \"x\") B\n")
      (goto-char (point-min))
      (search-forward "\"x")
      (let ((object (org-element-context)))
        (inline-probe-report "CONTEXT" (org-element-type object))
        (inline-probe-report "CACHE-TARGET" (org-element-type (org-element-at-point object)))
        (org-element-cache-store-key object 'inline-probe 'cached)
        (inline-probe-report "CACHE-SAME" (org-element-cache-get-key object 'inline-probe 'missing))
        (inline-probe-report "CACHE-FRESH"
                             (org-element-cache-get-key (org-element-context) 'inline-probe 'missing))
        (delete-char -1)
        (insert "y")
        (inline-probe-report "CACHE-EDIT"
                             (org-element-cache-get-key (org-element-context) 'inline-probe 'missing))))))

(org-texmacs-test--with-worker
  (let ((org-texmacs-worker-start-timeout 10))
    (dolist (source '("(math \"x\")" "(math (frac \"1\" \"2\"))"
                      "(math (concat \"x+\" (sqrt \"y\")))" "(math)"
                      "(mathjax \"x\")" "(math\"x\")" "(math(frac \"1\" \"2\"))"
                      "(math ;; comment\n \"x\")"))
      (inline-probe-report
       "TEXMACS"
       (list source
             (condition-case err (org-texmacs--worker-request source)
               (error (list (car err) (error-message-string err)))))))))

(inline-probe-report "RESTORED" (not (memq 'texmacs-inline org-element-all-objects)))
