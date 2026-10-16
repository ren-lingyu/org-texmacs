;;; probes.el --- Native bibliography controls -*- lexical-binding: t; -*-
(require 'org-texmacs)
(let ((results nil)
      (cases '((string . "@string{word={Native}}\n@book{key,title=word}")
               (concat . "@book{key,title={Native} # { Title}}")
               (preamble . "@preamble{\"Native preamble\"}\n@book{key,title={Book}}")
               (online . "@online{key,title={Online},url={https://example.org}}")
               (unknown . "@unknown{key,title={Unknown}}")
               (undefined . "@book{key,title=UNDEFINED}")
               (defined . "@string{UNDEFINED={Defined}}\n@book{key,title=UNDEFINED}")
               (after-defined . "@book{key,title=UNDEFINED}")
               (duplicate-key . "@book{key,title={A}}\n@book{key,title={B}}")
               (duplicate-field . "@book{key,title={A},TITLE={B}}")
               (malformed . "@book{key,title={Missing")
               (garbage . "unparsed trailing text")
               (empty . "")
               (child . "@book{child,title={Child},crossref={parent}}")
               (child-parent . "@book{child,title={Child},crossref={parent}}\n@book{parent,title={Parent}}")
               (xdata . "@book{key,title={Book},xdata={missing}}"))))
  (org-texmacs-test--with-worker
    (let ((script (expand-file-name "native.scm" test-directory)))
      (with-temp-file script
        (insert (format "(load %s)\n" (org-texmacs--scheme-string org-texmacs--worker-scheme-file))
                "(use-modules (convert bibtex bibtextm) (bibtex plain))\n"
                "(define (org-texmacs-parse-reply request)\n"
                " (catch #t (lambda ()\n"
                "  (let* ((raw (parse-bibtex-snippet (caddr request)))\n"
                "         (parsed (if (equal? raw \"\") '(document) raw))\n"
                "         (formatted (catch #t (lambda () (bib-process \"probe\" \"plain\" parsed))\n"
                "                      (lambda args '(format-error \"Native formatting failure\")))))\n"
                "   (list 'ok (cadr request)\n"
                "     (org-texmacs-bibliography-source-tree (list 'native-control (list 'version (texmacs-version)) raw formatted)))))\n"
                "  (lambda args (list 'error (cadr request) \"Native control failed\"))))\n"))
      (let ((org-texmacs--worker-scheme-file script))
        (dolist (case cases)
          (push (list (car case) (cdr case)
                      (condition-case err (org-texmacs--worker-request (cdr case))
                        (org-texmacs-error (list 'failure (error-message-string err))))) results)))))
  (with-temp-file (expand-file-name "native-results.el" (getenv "PROBE_OUTPUT"))
    (let ((print-length nil) (print-level nil))
      (pp (list :emacs emacs-version :org (org-version) :results (nreverse results)) (current-buffer))))
  (message "Native bibliography controls recorded: %d" (length cases)))
