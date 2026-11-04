;;; flow.el --- standard CSL inline mathematics dataflow -*- lexical-binding: t; -*-
(require 'oc-csl)
(ert-deftest flow-library-inspection ()
  (let* ((out (file-name-directory (getenv "ORG_TEXMACS_TEST_NAMES_FILE")))
         (src (getenv "ORG_TEXMACS_PROBE_CITEPROC_SOURCE")))
    (message "CSL-SOURCE %s DIRECTORY=%S" src (file-directory-p src))
    (when (file-directory-p src)
      (dolist (name '("citeproc-bibtex.el" "citeproc-biblatex.el" "citeproc-itemgetters.el" "citeproc.el" "citeproc-formatters.el" "citeproc-rt.el"))
        (let ((p (expand-file-name name src)))
          (when (file-exists-p p) (copy-file p (expand-file-name name out))))))
    (let ((p (getenv "ORG_TEXMACS_PROBE_INIT_LATEX")))
      (message "NATIVE-CONVERTER-SOURCE %s EXISTS=%S" p (file-exists-p p))
      (when (file-exists-p p)
        (copy-file p (expand-file-name "init-latex.scm" out))))
    (with-temp-file (expand-file-name "flow-function-docs.txt" out)
      (dolist (sym (apropos-internal "\\`\\(citeproc.*\\(?:bibtex\\|render\\|item\\|csl\\)\\|org-cite-csl.*\\)" #'fboundp))
        (insert (format "%S %S\n%s\n" sym (help-function-arglist sym) (documentation sym t)))))))
(defconst flow-style
  "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Inline math flow</title><id>https://example.org/inline-math-flow</id><updated>2026-01-01T00:00:00+00:00</updated></info><citation><layout prefix=\"[\" suffix=\"]\"><text variable=\"title\" font-style=\"italic\"/></layout></citation><bibliography><layout><text variable=\"title\" font-style=\"italic\"/></layout></bibliography></style>")
(defun flow-view (node)
  "Diagnostic projection only: drop source bookkeeping, retain node semantics."
  (if (stringp node) (substring-no-properties node)
    (let* ((type (org-element-type node))
           (props
            (pcase type
              ('entity (list :name (org-element-property :name node)
                             :utf-8 (org-element-property :utf-8 node)
                             :math (org-element-property :latex-math-p node)))
              ((or 'latex-fragment 'latex-environment 'code 'verbatim 'raw)
               (list :value (org-element-property :value node)))
              ((or 'subscript 'superscript)
               (list :brackets (org-element-property :use-brackets-p node)))
              ('link (list :type (org-element-property :type node)
                           :path (org-element-property :path node)))
              ('target (list :value (org-element-property :value node))))))
      (cons type (cons props (mapcar #'flow-view (org-element-contents node)))))))
(defun flow-run (source stem out)
  (with-temp-buffer
    (org-mode)
    (insert source)
    (let* ((org-export-use-babel nil)
           (org-export-with-latex t)
           (org-export-with-entities t)
           (org-export-with-sub-superscripts t)
           (processing 0) (filters 0) live trace observers
           (bridge (symbol-function 'org-texmacs--standard-input))
           (org-export-before-processing-functions
            (list (lambda (_) (cl-incf processing))))
           (org-export-filter-parse-tree-functions
            (list (lambda (tree _backend _info) (cl-incf filters) tree)))
           (record (list :case stem :source source)))
      (with-temp-file (expand-file-name (concat stem ".org") out) (insert source))
      (dolist (symbol '(citeproc-blt-entry-to-csl citeproc-bt-entry-to-csl
                        citeproc-blt--to-csl-title citeproc-bt--decode
                        citeproc-bt--process-brackets citeproc-s-sentence-case-title
                        citeproc-render-citations citeproc-render-bib))
        (let* ((sym symbol)
               (observer
                (lambda (original &rest args)
                  (let ((result (apply original args)))
                    (push (list :function sym
                                :input (copy-tree
                                        (if (memq sym '(citeproc-render-citations citeproc-render-bib))
                                            (list :format (nth 1 args))
                                          (car args)))
                                :output (copy-tree result)) trace)
                    result))))
          (advice-add sym :around observer)
          (push (cons sym observer) observers)))
      (unwind-protect
       (condition-case err
          (let ((input
                 (cl-letf (((symbol-function 'org-texmacs--standard-input)
                            (lambda (info state)
                              (setq live
                                    (mapcar (lambda (key) (cons key (plist-get info key)))
                                            '(:with-entities :with-sub-superscript :with-latex)))
                              (funcall bridge info state))))
                   (org-texmacs-prepare-buffer (current-buffer)))))
            (setq record (append record (list :live-options live :ast (flow-view (org-texmacs-input-ast input)))))
            (condition-case failure
                (let* ((doc (org-texmacs-document input))
                       (session (org-texmacs-session-open))
                       (pdf (expand-file-name (concat stem ".pdf") out))
                       native)
                  (unwind-protect
                      (progn (org-texmacs-session-set-document session doc)
                             (setq native (org-texmacs--session-read session)))
                    (org-texmacs-session-close session))
                  (org-texmacs-document-save doc (expand-file-name (concat stem ".tm") out))
                  (org-texmacs-document-save-pdf doc pdf)
                  (should (= 0 (call-process "pdftoppm" nil nil nil "-f" "1"
                                             "-singlefile" "-scale-to" "1600" "-png"
                                             pdf (expand-file-name stem out))))
                  (setq record (append record (list :lowered (org-texmacs-document-body doc)
                                                   :native native :pdf-text (org-texmacs-test--pdf-text pdf)))))
              (org-texmacs-document-error
               (setq record (append record (list :lowering-error failure))))))
        (error (setq record (append record (list :preparation-error err)))))
       (dolist (pair observers) (advice-remove (car pair) (cdr pair))))
      (setq record (append record (list :trace (nreverse trace))))
      (should (= processing 1))
      (should (= filters 1))
      (message "FLOW %s AST=%S ERROR=%S" stem (plist-get record :ast)
               (or (plist-get record :lowering-error) (plist-get record :preparation-error)))
      (message "LAYERS %s %S" stem (plist-get record :trace))
      record)))
(ert-deftest inline-math-standard-csl-dataflow ()
  (org-texmacs-test--with-worker
   (let* ((out (file-name-directory (getenv "ORG_TEXMACS_TEST_NAMES_FILE")))
          (style (expand-file-name "flow.csl" out))
          (header "#+OPTIONS: toc:nil title:nil author:nil date:nil e:t ^:t tex:t\n")
          (samples '(("entity" . "\\cdot") ("symbol" . "$\\cdot$")
                     ("greek" . "$\\alpha_i$") ("fraction" . "$\\frac{a}{b}$")))
          records)
     (with-temp-file style (insert flow-style))
     (message "VERSIONS: Emacs=%s Org=%s Citeproc=%s"
              emacs-version (org-version) (getenv "ORG_TEXMACS_PROBE_CITEPROC_VERSION"))
     (dolist (sample samples)
       (let* ((name (car sample)) (math (cdr sample))
              (bib (expand-file-name (concat name ".bib") out)))
         (with-temp-file bib
           (insert "@article{key,\n title={Properties of " math "},\n author={Someone, A},\n year={2026}}\n"))
         (push (flow-run (concat header "Body " math ".\n") (concat "body-" name) out) records)
         (push (flow-run (concat header "#+bibliography: " bib "\n#+cite_export: csl " style
                                 "\n[cite:@key]\n#+print_bibliography:\n")
                         (concat "csl-" name) out) records)))
     (with-temp-file (expand-file-name "flow-evidence.sexp" out)
       (let ((print-length nil) (print-level nil) (print-circle t)
             (print-escape-control-characters t) (print-escape-newlines t))
         (prin1 (nreverse records) (current-buffer)) (insert "\n"))))))
