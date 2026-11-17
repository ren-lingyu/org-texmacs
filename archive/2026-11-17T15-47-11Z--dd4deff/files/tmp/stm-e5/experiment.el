;;; experiment.el --- E5 writer comparison -*- lexical-binding: t; -*-
(load (expand-file-name "e4-adapter.el" (file-name-directory load-file-name)) nil t)
(defun e5-pure (tree)
  (cond ((stringp tree) (org-texmacs--scheme-string tree))
        ((consp tree) (concat "(" (symbol-name (car tree))
                              (mapconcat (lambda (c) (concat " " (e5-pure c))) (cdr tree) "") ")"))
        (t (error "invalid structured tree"))))
(defun e5-request (tree)
  (let* ((pure (e5-pure tree))
         (reply (org-texmacs--worker-call
                 (lambda (id)
                   (format "(probe-writers %d %s %s %s)\n" id
                           (org-texmacs--worker-stm-wire tree)
                           (org-texmacs--scheme-string pure)
                           (org-texmacs--scheme-string (e5-stm-write tree))))))
         (results (nth 2 reply)))
    (if (eq (car reply) 'error) (list :error results)
      (cl-mapcar
       (lambda (label r)
         (if (symbolp r) (list :writer label :error (symbol-name r))
           (list :writer label :source (decode-coding-string (apply #'unibyte-string (car r)) 'utf-8)
                 :scheme-read (nth 1 r) :native-stm (nth 2 r) :worker-parse (nth 3 r))))
       '(scheme-write texmacs-to-stm pure-elisp pure-stm) results))))
(defun e5-stm-write (tree)
  (cond
   ((stringp tree)
    (let ((s (replace-regexp-in-string "\\\\" "\\\\" tree t t)))
      (setq s (replace-regexp-in-string "\"" "\\\"" s t t))
      (setq s (org-texmacs--scheme-string s))
      (dolist (p '(("\n" . "\\n") ("\r" . "\\r") ("\t" . "\\t")))
        (setq s (replace-regexp-in-string (car p) (cdr p) s t t))) s))
   ((consp tree)
    (let* ((name (symbol-name (car tree)))
           (escaped (replace-regexp-in-string "[\\\\() \t\n]"
                                              (lambda (s) (concat "\\" s)) name t t)))
      (when (string-match-p "\\`\\(?:[0-9]\\|[:#]\\)" name)
        (setq escaped (concat "\\'" escaped)))
      (concat "(" escaped (mapconcat (lambda (c) (concat " " (e5-stm-write c))) (cdr tree) "") ")")))
   (t (error "invalid tree"))))
(let ((org-texmacs--worker-scheme-file (expand-file-name "writers.scm" probe-root))
      rows directory)
  (unwind-protect
      (progn
        (org-texmacs--worker-start) (setq directory org-texmacs--worker-directory)
        (dolist (tree
                 (append
                  '((x) (math "x") (math (concat "a" "+" "b")) (custom-tag "x"))
                  (mapcar (lambda (s) (list (intern s) "x"))
                          '("a-b" "a_b" "a*" "+" "-" "." "1" "1e2" "#t" "with space" "a|b" "a\\b" "a(b)" "λ" "" ":tag" "foo?"))
                  (mapcar (lambda (s) (list 'math s))
                          (list "" "quote\" slash\\" "a\\)b" "$*_[[x]]" "a\nb" "a\tb" "a\rb"
                                (string 0) (string 1) (string 7) (string 8) (string 27) (string 127)
                                "中文 λ α" "\\\"\\)$*_*"))
                  (list '(math (concat (concat (concat "deep")))))
                  '("V")))
          (let ((before (format "%S" tree)))
            (push
             (condition-case e
                 (progn (org-texmacs--model-copy-stree tree)
                        (list :tree before :model-valid t :compound (consp tree)
                              :writers (e5-request tree) :unchanged (equal before (format "%S" tree))))
               (error (list :tree before :error (error-message-string e)))) rows)))
        (probe-write "writers.json" (nreverse rows)))
    (org-texmacs--worker-stop))
  (probe-write "environment.json" (list :emacs emacs-version :org (org-version)
                                        :org-library (locate-library "org-element")
                                        :worker-live (org-texmacs--worker-live-p)
                                        :directory-removed (and directory (not (file-exists-p directory))))))
(princ "E5 writer comparison completed\n")
