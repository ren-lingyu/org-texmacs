;;; environment.el --- Version-sensitive investigation -*- lexical-binding: t; -*-
(require 'org)
(require 'ox)
(require 'oc)
(with-temp-file "environment.txt"
  (insert (format "Emacs: %s\nOrg: %s\nExecutable: %s%s\n"
                  emacs-version (org-version) invocation-directory invocation-name))
  (dolist (feature '(org ox oc))
    (insert (format "%s: %s\n" feature (locate-library (symbol-name feature)))))
  (dolist (fn '(org-export-as org-export--annotate-info org-export-copy-buffer
                org-export-expand-include-keyword org-export-filter-apply-functions
                org-cite-list-bibliography-files org-cite-process-citations))
    (insert (format "%s: %S\n" fn (help-function-arglist fn t)))))
(princ (with-temp-buffer (insert-file-contents "environment.txt") (buffer-string)))
