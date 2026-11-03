;;; probe.el --- final Org clipping semantics -*- lexical-binding: t; -*-
(require 'ox-html)
(ert-deftest org-script-clipped-markers ()
  (dolist (kind '(equation plain-note heading-note))
    (with-temp-buffer
      (org-mode)
      (let ((org-export-use-babel nil)
            (org-export-with-sub-superscripts t))
        (insert
         (pcase kind
           ('equation "* Kept\n#+begin_equation*\n\"kept\"\n#+end_equation*\n")
           ('plain-note "Text[fn:n].\n\n[fn:n]\n#+begin_table\n| A |\n#+end_table\n")
           (_ "Text[fn:n].\n\n* Footnotes\n[fn:n]\n#+begin_table\n| A |\n#+end_table\n")))
        (goto-char (point-min))
        (search-forward (if (eq kind 'equation) "\"kept" "| A |"))
        (let* ((end (point))
               (clipped (buffer-substring-no-properties (point-min) end))
               (input
                (cl-letf (((symbol-function 'org-texmacs--worker-request)
                           (lambda (&rest _) (ert-fail "Native parser called"))))
                  (org-texmacs-prepare-buffer (current-buffer) nil nil (cons (point-min) end))))
               (ast (org-texmacs-input-ast input))
               (body (org-texmacs-document-body (org-texmacs-document input))))
          (message "KIND %S AST-NATIVE %S ISLANDS %S BODY %S" kind
                   (org-element-map ast 'special-block
                     (lambda (n) (org-element-property :type n)))
                   (org-texmacs-input-islands input) body)
          (should-not (org-texmacs-input-islands input))
          (with-temp-buffer
            (org-mode)
            (insert clipped)
            (let ((html (org-export-as 'html nil nil t)))
              (message "KIND %S HTML %S" kind html)
              (should (string-search (if (eq kind 'equation)
                                         "begin<sub>equation</sub>"
                                       "begin<sub>table</sub>") html)))))))))
