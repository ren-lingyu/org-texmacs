;;; probe.el --- Standard Cite protocol probes -*- lexical-binding: t; -*-
(require 'ox-texmacs)
(require 'oc-basic)
(require 'oc-csl)
(message "CSL FINALIZER ACTUAL %S"
         (org-cite-processor-export-finalizer (org-cite-get-processor 'csl)))

(dolist (name '(org-cite-register-processor org-cite-get-references
                org-cite-list-bibliography-files org-cite-processor
                org-cite-basic-export-citation org-cite-basic-export-bibliography))
  (message "PUBLIC %S %S" name (and (fboundp name) (documentation name))))

(dolist (spec (append
              (mapcar (lambda (name) (cons "oc-csl" (symbol-name name)))
                      (list (org-cite-processor-export-citation (org-cite-get-processor 'csl))
                            (org-cite-processor-export-bibliography (org-cite-get-processor 'csl))
                            'org-cite-csl--output-format))
              '(("oc-csl" . "org-cite-csl-finalizer")
                ("oc-csl" . "org-cite-csl-export-citation")
                ("oc-csl" . "org-cite-csl-export-bibliography")
                ("oc-basic" . "org-cite-basic-export-citation")
                ("oc-basic" . "org-cite-basic-export-bibliography")
                ("ox" . "org-export-data"))))
  (when-let* ((file (or (locate-library (concat (car spec) ".el"))
                       (locate-library (concat (car spec) ".el.gz")))))
    (when (< (file-attribute-size (file-attributes file)) 1048576)
      (with-temp-buffer
        (insert-file-contents file)
        (emacs-lisp-mode)
        (goto-char (point-min))
        (when (search-forward (concat "(defun " (cdr spec) " ") nil t)
          (beginning-of-line)
          (let ((start (point)))
            (forward-sexp)
            (message "RUNTIME SOURCE %s\n%s" (cdr spec)
                     (buffer-substring-no-properties start (point)))))))))

(defvar d--shape 'element)
(defvar d--calls nil)
(defvar d--info nil)
(defun d--raws (tree)
  ;; `raw' is a pseudo object: asking org-element-map only for `raw' does
  ;; not descend into paragraph objects.  A full structured walk sees it.
  (org-element-map tree t (lambda (node) (and (consp node) (eq (car node) 'raw) node))))
(defun d--cite (citation style backend info)
  (push 'citation d--calls)
  (setq d--info info)
  (message "CITE ARGS SHAPE %S STYLE %S BACKEND %S BIB %S" d--shape style (org-export-backend-name backend) (plist-get info :bibliography))
  (pcase d--shape
    ('element (org-element-create 'bold nil "Structured"))
    ('secondary (list "Prefix " (org-element-create 'italic nil "Structured")))
    ('reentrant (let ((value (org-export-data (org-element-create 'bold nil "Nested") info)))
                  (message "REENTRANT VALUE %S" value) value))
    ('tree (org-element-create 'export-snippet '(:back-end "texmacs" :texmacs-tree (with-bib "refs" (cite "key")))))
    (_ "Target output")))
(defun d--bibliography (_keys _files style _props backend info)
  (push 'bibliography d--calls)
  (message "BIB ARGS %S %S" style (org-export-backend-name backend))
  (should (eq info d--info))
  (org-element-create 'special-block '(:type "texmacs" :texmacs-tree (with-bib "refs" (bib-list "1" (document (concat (bibitem* "1") (label "refs-key") "Entry")))))))
(org-cite-register-processor 'd-probe :export-citation #'d--cite
                             :export-bibliography #'d--bibliography
                             :cite-styles '((("nil"))))

(defun d--export (source processor inspect)
  (with-temp-buffer
    (org-mode) (insert source)
    (let ((org-export-use-babel nil)
          (org-cite-export-processors `((t ,processor)))
          (d--calls nil) (d--info nil))
      (cl-letf (((symbol-function 'org-texmacs--standard-inner)
                 (lambda (_contents info)
                   (funcall inspect (plist-get info :parse-tree) info)
                   "")))
        (org-export-as 'texmacs)))))

(ert-deftest d-basic-outputs-are-raw ()
  (let ((bib (make-temp-file "cite-probe-" nil ".bib")))
    (unwind-protect
        (progn
          (with-temp-file bib (insert "@book{key, author={Doe, Jane}, title={Fixture}, year={2026}}\n"))
          (d--export (format "#+bibliography: %s\n[cite:@key]\n#+print_bibliography:\n" bib) 'basic
                     (lambda (tree _info)
                       (let ((raw (d--raws tree)))
                         (let ((print-level 5) (print-length 8) (print-circle t))
                           (message "BASIC AST %S RAW %S" tree raw))
                         (should (= 2 (length raw)))))))
      (delete-file bib))))

(ert-deftest d-processor-return-shapes-and-reentrant-count ()
  (dolist (d--shape '(element secondary reentrant string tree))
    (d--export "[cite:@key]\n" 'd-probe
               (lambda (tree info)
                 (should (equal '(citation) d--calls))
                 (should (eq d--info info))
                 (let ((print-level 5) (print-length 8) (print-circle t))
                   (message "SHAPE %S AST %S" d--shape tree))
                 (pcase d--shape
                   ('element (should (org-element-map tree 'bold #'identity)))
                   ('secondary (should (org-element-map tree 'italic #'identity)))
                   ('tree (should (org-element-map tree 'export-snippet #'identity)))
                   (_ (should (= 1 (length (d--raws tree))))))))))

(ert-deftest d-structured-tree-property-survives-cite ()
  (let ((d--shape 'tree))
    (d--export "[cite:@key]\n#+print_bibliography:\n" 'd-probe
               (lambda (tree _info)
                 (should (equal '(bibliography citation) d--calls))
                 (should (equal '(with-bib "refs" (cite "key"))
                                (org-element-property :texmacs-tree
                                                      (car (org-element-map tree 'export-snippet #'identity)))))
                 (should (org-element-map tree 'special-block #'identity))))))

(ert-deftest d-native-processor-full-transaction ()
  (let ((bib (make-temp-file "cite-native-" nil ".bib")))
    (unwind-protect
        (progn
          (with-temp-file bib
            (insert "@book{key, author={Doe, Jane}, title={Fixture}, year={2026}}\n"))
          (with-temp-buffer
            (org-mode)
            (insert (format "#+bibliography: %s\n#+cite_export: texmacs plain\nText [cite:@key].\n#+print_bibliography:\n" bib))
            (let ((org-export-use-babel nil)
                  (org-texmacs-program (getenv "ORG_TEXMACS_TEST_PROGRAM")))
              (let ((document (org-texmacs--standard-consume 'document)))
                (message "NATIVE RESULT %S" document)
                (should document))
              (should (stringp (org-export-as 'texmacs))))))
      (delete-file bib))))

(ert-deftest d-csl-real-return-shape ()
  (require 'oc-csl)
  (let ((bib (make-temp-file "cite-csl-" nil ".bib"))
        (style (make-temp-file "cite-style-" nil ".csl")))
    (unwind-protect
        (progn
          (with-temp-file bib (insert "@book{key, author={Doe, Jane}, title={Fixture}, year={2026}}\n"))
          (with-temp-file style
            (insert "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Probe</title><id>https://example.org/probe</id><updated>2026-01-01T00:00:00+00:00</updated></info><citation><layout><text variable=\"title\"/></layout></citation><bibliography><layout><text variable=\"title\"/></layout></bibliography></style>"))
          (d--export (format "#+bibliography: %s\n#+cite_export: csl %s\n[cite:@key]\n#+print_bibliography:\n" bib style) 'csl
                     (lambda (tree _info)
                       (let ((print-circle t) (print-level 5) (print-length 12))
                         (message "CSL ACTUAL AST %S RAWCOUNT %d" tree (length (d--raws tree))))))
          (org-texmacs-test--with-worker
           (with-temp-buffer
             (org-mode)
             (insert (format "#+bibliography: %s\n#+cite_export: csl %s\n[cite:@key]\n#+print_bibliography:\n" bib style))
             (let ((org-export-use-babel nil))
               (message "CSL TEXT %S" (org-export-as 'texmacs))
               (message "CSL DOCUMENT %S" (org-texmacs--standard-consume 'document))
               (should (string-prefix-p "%PDF-" (org-texmacs--standard-consume 'pdf)))))))
      (delete-file bib) (delete-file style))))

(ert-deftest d-native-processor-locations ()
  (org-texmacs-test--with-worker
   (let ((bib (expand-file-name "refs.bib" default-directory)))
     (with-temp-file bib (insert "@book{key, author={Doe, Jane}, title={Fixture}, year={2026}}\n"))
     (dolist (body '("* Heading [cite:@key]\nText.\n"
                     "Note[fn::[cite:@key]].\n"
                     "Note[fn:x].\n\n[fn:x] [cite:@key]\n"
                     "| [cite:@key] | Cell |\n"
                     "#+caption: Caption [cite:@key]\n| Cell | Cell |\n"
                     "*Markup [cite:@key]*.\n"))
       (with-temp-buffer
         (org-mode)
         (insert (format "#+bibliography: %s\n#+cite_export: texmacs plain\n%s\n#+print_bibliography:\n" bib body))
         (let ((org-export-use-babel nil))
           (message "LOCATION %S" body)
           (let ((document (org-texmacs--standard-consume 'document)))
             (should (string-match-p "with-bib" (prin1-to-string document))))))))))

(ert-deftest d-processor-early-contract-errors ()
  (dolist (source '("#+cite_export: texmacs plain\n[cite:@key]\n"
                    "#+cite_export: texmacs plain\n[cite/t:@key]\n#+print_bibliography:\n"
                    "#+cite_export: texmacs plain\n[cite:@key]\n#+print_bibliography:\n#+print_bibliography:\n"))
    (with-temp-buffer
      (org-mode) (insert source)
      (let ((org-export-use-babel nil))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) (ert-fail "Unexpected native parser"))))
          (should-error (org-export-as 'texmacs) :type 'org-texmacs-document-error))))))
