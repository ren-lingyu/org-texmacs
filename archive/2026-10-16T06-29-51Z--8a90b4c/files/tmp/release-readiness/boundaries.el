;;; boundaries.el --- Inline-note source boundary investigation -*- lexical-binding: t; -*-
(require 'json)
(let (records (out (getenv "PROBE_OUTPUT")))
 (dolist (source '("Text[fn::Before (math \"x\") after].\n"
                   "Text[fn:n:*Bold* (math \"x\") and (math \"y\")]. Again[fn:n].\n"
                   "Text[fn::(math \"[x]\")].\n"
                   "Text[fn::Before (math \"x\"]. After.\n"
                   "Text[fn::(math \"x\") /emphasis/].\n"
                   "Text[fn::=literal (math \"x\")=].\n"
                   "Text[fn::[[https://example.org][(math \"x\")]]].\n"
                   "Text[fn::(math \"x\")\ncontinued].\n"))
  (with-temp-buffer
   (org-mode) (insert source)
   (let ((ast (org-element-parse-buffer)) (spans (org-texmacs--fragment-collect (org-texmacs--fragment-tags))))
    (push (list :source source :spans (length spans)
                :notes (org-element-map ast 'footnote-reference
                         (lambda (n) (list :type (org-element-property :type n)
                                           :begin (org-element-property :begin n)
                                           :end (org-element-property :end n)
                                           :contents-begin (org-element-property :contents-begin n)
                                           :contents-end (org-element-property :contents-end n)
                                           :children (let ((print-circle t)) (prin1-to-string (org-element-contents n))))))) records))))
 (let ((coding-system-for-write 'utf-8-unix) (print-circle t))
  (with-temp-file (expand-file-name "boundaries.sexp" out) (prin1 (nreverse records) (current-buffer)))))
(let ((records (list (list :arglist (help-function-arglist 'org-src-font-lock-fontify-block)
                                  :documentation (documentation 'org-src-font-lock-fontify-block))))
      (output (getenv "PROBE_OUTPUT")))
  (dolist (case '(("paragraph" . "Before (math (frac \"1\" \"2\")) after.\n")
                  ("special-block" . "#+begin_texmacs\n(math (frac \"1\" \"2\"))\n#+end_texmacs\n")))
    (condition-case err
        (with-temp-buffer
          (org-mode) (insert (cdr case))
          (font-lock-mode 1) (font-lock-ensure)
          (let* ((before (buffer-substring-no-properties (point-min) (point-max)))
                 (modified (buffer-modified-p))
                 (tick (buffer-chars-modified-tick))
                 (region (if (equal (car case) "paragraph")
                             (let ((span (car (org-texmacs--fragment-collect (org-texmacs--fragment-tags)))))
                               (cons (org-texmacs-fragment-span-begin span) (org-texmacs-fragment-span-end span)))
                           (let ((node (car (org-element-map (org-element-parse-buffer) 'special-block #'identity))))
                             (cons (org-element-property :contents-begin node) (org-element-property :contents-end node))))))
            (org-src-font-lock-fontify-block "scheme" (car region) (cdr region))
            (goto-char (point-min)) (search-forward "\"1\"")
            (push (list (car case) :region region :string-face (get-text-property (- (point) 2) 'face)
                        :source-preserved (and (equal before (buffer-substring-no-properties (point-min) (point-max)))
                                               (eq modified (buffer-modified-p)) (= tick (buffer-chars-modified-tick)))) records)))
      (error (push (list (car case) :error (error-message-string err)) records))))
  (with-temp-file (expand-file-name "font-lock-facility.sexp" output)
    (let ((print-circle t)) (prin1 (nreverse records) (current-buffer)))))
(ert-run-tests-batch-and-exit '(or "^org-texmacs-document-quote-uniform-quotation$"
                                 "^org-texmacs-document-.*container"))
