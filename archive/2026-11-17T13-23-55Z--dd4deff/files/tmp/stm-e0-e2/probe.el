;;; probe.el --- isolated exploratory probes -*- lexical-binding: t; -*-
(setq load-prefer-newer t)
(require 'org)
(require 'org-element)
(require 'json)
(require 'org-texmacs-fragment)
(setq org-element-use-cache nil)
(defvar probe-root (file-name-directory load-file-name))
(defun probe-json (data)
  (cond ((and (listp data) (keywordp (car data)))
         (let ((h (make-hash-table :test #'equal)))
           (while data
             (let ((k (pop data)) (v (pop data)))
               (puthash (substring (symbol-name k) 1) (probe-json v) h))) h))
        ((consp data) (vconcat (mapcar #'probe-json data)))
        (t data)))
(defun probe-write (name data)
  (with-temp-file (expand-file-name name probe-root)
    (insert (json-encode (probe-json data)) "\n")))
(defun probe-scan (start limit)
  "Lexical carrier scan only. LIMIT is supplied by the owning context."
  (save-excursion
    (goto-char start)
    (let* ((dollar (looking-at-p "\\$("))
           (slash (looking-at-p (regexp-quote "\\((")))
           (tree-start (+ start (if dollar 1 2)))
           end)
      (unless (or dollar slash) (error "not-carrier"))
      (save-restriction
        (narrow-to-region start limit)
        (with-syntax-table org-texmacs--fragment-syntax-table
          (let ((parse-sexp-lookup-properties nil)
                (parse-sexp-ignore-comments nil))
            (setq end (condition-case nil (scan-sexps tree-start 1)
                        (scan-error (error "incomplete-tree")))))))
      (unless (and end (<= end limit)) (error "incomplete-tree"))
      (goto-char end)
      (unless (and (<= (+ end (if dollar 1 2)) limit)
                   (looking-at-p (regexp-quote (if dollar "$" "\\)"))))
        (error "missing-immediate-carrier-close"))
      (list :begin start :end (+ end (if dollar 1 2))
            :tree (buffer-substring-no-properties tree-start end)))))
(defun probe-records (ast)
  (let (rows)
    (org-element-map ast
        '(headline paragraph bold italic underline code verbatim latex-fragment
          table-cell footnote-reference link src-block example-block)
      (lambda (n)
        (push (list :type (symbol-name (org-element-type n))
                    :begin (org-element-property :begin n)
                    :end (org-element-property :end n)
                    :post-blank (org-element-property :post-blank n)
                    :value (org-element-property :value n)
                    :parent (let ((p (org-element-property :parent n)))
                              (when p (symbol-name (org-element-type p))))) rows))
      nil nil nil t)
    (nreverse rows)))
(defun probe-parse (source)
  (with-temp-buffer
    (org-mode) (insert source)
    (let ((ast (org-element-parse-buffer)))
      (list :nodes (probe-records ast)
            :ast (let ((print-circle t) (print-level nil) (print-length nil))
                   (prin1-to-string ast))))))
(probe-write "environment.json"
             (list :emacs emacs-version :org (org-version)
                   :org-element (locate-library "org-element")
                   :cache org-element-use-cache :user-init user-init-file
                   :home (getenv "HOME") :temporary-directory temporary-file-directory))
(let* ((forms '("$x$" "\\(x\\)" "\\(unclosed" "$(math \"x\")$"
                "\\((math (concat \"a\" \"*\" \"b\"))\\)"))
       (containers '((paragraph . "Before %s after.\n")
                     (headline . "* Title %s here\n")
                     (bold . "*Consider %s here.*\n")
                     (table . "| %s | tail |\n")
                     (footnote . "Text [fn::%s] end.\n")
                     (description . "[[https://example.invalid][%s]]\n")
                     (caption . "#+caption: %s\n| a |\n")
                     (code . "~%s~\n") (verbatim . "=%s=\n")
                     (src . "#+begin_src text\n%s\n#+end_src\n")
                     (example . "#+begin_example\n%s\n#+end_example\n"))) rows)
  (dolist (c containers)
    (dolist (f forms)
      (let ((s (format (cdr c) f)))
        (push (list :container (symbol-name (car c)) :form f :input s
                    :result (probe-parse s)) rows))))
  (dolist (s '("a\\(x\\), b\n" "a $x$ b\n" "\\(x\ny\\)  z\n"
               "\\(x\n\ny\\)\n" "\\(x\n* Heading\ny\\)\n"))
    (push (list :container "boundary" :input s :result (probe-parse s)) rows))
  (probe-write "e0.json" (nreverse rows)))
(let (rows)
  (dolist (s '("$(math \"x\")$" "\\((math (frac \"a\" \"b\"))\\)"
               "\\((math (concat \"a\" \"*\" \"b\"))\\)"
               "\\((math (concat \"a\" \"\\\\)\" \"b\"))\\)"
               "\\((custom-tag \"x\")\\)" "$(x)$"
               "$(math \"a$)b\")$" "$(math \"a\\\"b\")$"
               "$(math\n \"x\")$" "$(math \"x\")$$(concat \"y\")$"
               "$(math \"x\"" "$(math \"x\")" "$(math \"x\") extra$"
               "$(math \"x\") (math \"y\")$" "$\"x\"$"
               "$(math #bad)$" "$(math \"x\")$ trailing"))
    (with-temp-buffer
      (insert s)
      (push (list :input s :result
                  (condition-case e (probe-scan 1 (point-max))
                    (error (list :error (error-message-string e))))) rows)))
  ;; Explicit owner limit rejects a close located in a later container.
  (with-temp-buffer
    (insert "$(math \"x\"\n\n) $\n")
    (push (list :input (buffer-string) :limit 12 :result
                (condition-case e (probe-scan 1 12)
                  (error (list :error (error-message-string e))))) rows))
  (probe-write "e1.json" (nreverse rows)))
(defun probe-object-adapter (old &rest args)
  "Recognition-only surrogate: not a proposed production latex object."
  (if (or (looking-at-p "\\$(") (looking-at-p (regexp-quote "\\((")))
      (let* ((span (probe-scan (point) (point-max)))
             (begin (point)) (end (plist-get span :end)))
        (org-element-create 'latex-fragment
                            (list :begin begin :end end :post-blank 0
                                  :value (buffer-substring-no-properties begin end))))
    (apply old args)))
(let (rows)
  (dolist (s '("*Consider \\((math (concat \"a\" \"*\" \"b\"))\\) here.*\n"
               "*Consider \\((math \"a* b\")\\) here.*\n"
               "| \\((math (concat \"a\" \"_\" \"b\"))\\) |\n"
               "~\\((math \"x\")\\)~\n"
               "=\\((math \"x\")\\)=\n"
               "\\((math \"[[x]] _a_ /b/ =c=\")\\) *outside*\n"
               "\\((math \"a\\\\)b\")\\) end\n"))
    (let ((native (probe-parse s)) object-only masked spans)
      (advice-add 'org-element-latex-fragment-parser :around #'probe-object-adapter)
      (unwind-protect
          (setq object-only (condition-case e (probe-parse s)
                              (error (list :error (error-message-string e)))))
        (advice-remove 'org-element-latex-fragment-parser #'probe-object-adapter))
      ;; Local equal-length masking feasibility probe. Opaque ownership is
      ;; checked first; this is deliberately not a complete source adapter.
      (with-temp-buffer
        (org-mode) (insert s)
        (let ((opaque (org-element-map (org-element-parse-buffer)
                          '(code verbatim src-block example-block)
                        (lambda (n) (cons (org-element-property :begin n)
                                          (org-element-property :end n))))))
          (goto-char (point-min))
          (while (re-search-forward "\\$(\\|\\\\((" nil t)
            (let ((start (match-beginning 0)))
              (unless (seq-some (lambda (r) (and (<= (car r) start)
                                                 (< start (cdr r)))) opaque)
                (let* ((span (probe-scan start (point-max)))
                       (end (plist-get span :end)))
                  (push span spans)
                  (goto-char start)
                  (while (< (point) end)
                    (unless (eq (char-after) ?\n)
                      (delete-char 1) (insert "x") (backward-char))
                    (forward-char))))))
          (setq masked (list :source (buffer-string)
                             :result (probe-parse (buffer-string))))))
      (push (list :input s :native native :object-only object-only
                  :masked masked :spans (nreverse spans)) rows)))
  (probe-write "e2.json" (nreverse rows)))
(princ "E0/E1/E2 probe completed\n")
