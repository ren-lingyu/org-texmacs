;;; experiment.el --- native-compatible E2-prime -*- lexical-binding: t; -*-
(load (expand-file-name "support.el" (file-name-directory load-file-name)) nil t)
(require 'org-texmacs)
(setq org-texmacs-program
      "/nix/store/axly2kr7x87iflyf6bpp2881wfw2zny4-texmacs-with-gotor-support-2.1.5/bin/texmacs"
      org-texmacs-worker-start-timeout 15 org-texmacs-worker-request-timeout 5)
(defvar ep-calls nil)
(defun ep-parser (old &rest args)
  ;; Org calls this only when latex-fragment is allowed and preceding objects
  ;; did not already consume the text. Narrowing belongs to Org, not this probe.
  (if (or (looking-at-p "\\$(") (looking-at-p (regexp-quote "\\((")))
      (let* ((start (point))
             (call (list :start start :min (point-min) :max (point-max)))
             (span (progn (push call ep-calls)
                          (probe-scan start (point-max))))
             (end (plist-get span :end)) post)
        (save-excursion
          (goto-char end) (setq post (skip-chars-forward " \t")))
        (org-element-create
         'stm-fragment
         (list :begin start :end (+ end post) :post-blank post
               :value (buffer-substring-no-properties start end)
               :stm-source (plist-get span :tree))))
    (apply old args)))
(defun ep-objects (ast)
  (let (rows)
    (org-element-map ast '(stm-fragment latex-fragment bold code verbatim)
      (lambda (n)
        (push (list :type (symbol-name (org-element-type n))
                    :begin (org-element-property :begin n)
                    :end (org-element-property :end n)
                    :post-blank (org-element-property :post-blank n)
                    :parent (let ((p (org-element-property :parent n)))
                              (when p (symbol-name (org-element-type p))))
                    :value (org-element-property :value n)
                    :source (org-element-property :stm-source n)
                    :contents-count (length (org-element-contents n))) rows))
      nil nil nil t)
    (nreverse rows)))
(defun ep-parse (source extend)
  (with-temp-buffer
    (org-mode) (insert source)
    (let (ep-calls)
      (when extend (advice-add 'org-element-latex-fragment-parser :around #'ep-parser))
      (unwind-protect
          (condition-case e
              (let ((ast (org-element-parse-buffer)))
                (list :objects (ep-objects ast) :calls (nreverse ep-calls)
                      :ast (let ((print-circle t) (print-length nil) (print-level nil))
                             (prin1-to-string ast))))
            (error (list :error (error-message-string e) :calls (nreverse ep-calls))))
        (when extend (advice-remove 'org-element-latex-fragment-parser #'ep-parser))))))
(let (rows)
  (dolist (c '((paragraph . "Before %s after.\n")
               (bold . "*Consider %s here.*\n")
               (headline . "* Title %s here\n")
               (table . "| %s | tail |\n")
               (footnote . "Text [fn::%s] end.\n")
               (description . "[[https://example.invalid][%s]]\n")
               (caption . "#+caption: %s\n| a |\n")
               (code . "~%s~\n") (verbatim . "=%s=\n")
               (src . "#+begin_src text\n%s\n#+end_src\n")
               (example . "#+begin_example\n%s\n#+end_example\n")))
    (dolist (f '("$(math \"x\")$" "\\((math \"x\")\\)"
                 "\\((math (concat \"a\" \"*\" \"b\"))\\)"
                 "\\((math \"a\\\\)b\")\\)"
                 "\\((math \"x\"" "$(math #bad)$"))
      (let ((s (format (cdr c) f)))
        (push (list :context (symbol-name (car c)) :input s
                    :native (ep-parse s nil) :extended (ep-parse s t)
                    :native-validation nil) rows))))
  (dolist (s '("\\((math \"x\"\n\n))\\)\n"
               "\\((math \"x\"\n* Next\n))\\)\n"
               "\\((math \"a\"))\\)" ;; Deliberately extra paren.
               "$(math \"x\") extra$\n"
               "$(math \"x\") (math \"y\")$\n"
               "\\((custom-tag \"x\")\\)  tail\n"
               "$(x)$\n" "$x$ \\(x\\)\n"
               "\\((math \"[[a]] _b_ /c/\")\\) *outside*\n"
               "*Consider \\((math \"a* b\")\\) here.*\n"
               "~$(math \"unterminated~\n"
               "=\\((math #bad)=\n"))
    (push (list :context "edge" :input s :native (ep-parse s nil)
                :extended (ep-parse s t) :native-validation nil) rows))
  (setq rows (nreverse rows))
  ;; Stage C probe only: parse recognized sources after Org context selection.
  (let (directory socket native-status)
    (unwind-protect
        (condition-case e
            (progn
              (org-texmacs--worker-start)
              (setq directory org-texmacs--worker-directory socket org-texmacs--worker-socket)
              (dolist (row rows)
                (let ((ex (plist-get row :extended)) results)
                  (dolist (obj (plist-get ex :objects))
                    (when (equal (plist-get obj :type) "stm-fragment")
                      (push (list :source (plist-get obj :source)
                                  :result
                                  (condition-case err
                                      (format "%S" (org-texmacs--worker-request
                                                    (plist-get obj :source)))
                                    (error (list :error (error-message-string err))))) results)))
                  (setf (plist-get row :native-validation) (nreverse results)))))
          (error (setq native-status (error-message-string e))))
      (org-texmacs--worker-stop))
    (probe-write "results.json" rows)
    (probe-write "environment.json"
                 (list :emacs emacs-version :org (org-version)
                       :org-element (locate-library "org-element")
                       :cache org-element-use-cache :user-init user-init-file
                       :native-startup-error native-status :socket socket
                       :directory-removed (and directory (not (file-exists-p directory)))
                       :worker-live (org-texmacs--worker-live-p)
                       :advice-removed (not (advice-member-p #'ep-parser
                                                          'org-element-latex-fragment-parser))
                       :after-scope (ep-parse "\\((math \"x\")\\)\n" nil)))))
(princ "E2-prime completed\n")
