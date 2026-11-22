;;; ert-pdf-pdf.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-pdf-footnote-macro-matching ()
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "footnote-macros.scm" test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(let* ((binding '(set-binding (merge \"footnote-\" (arg \"nr\")) (value \"the-label\") \"body\"))\n"
        "       (m (list 'macro \"sym\" \"nr\" \"body\" (list 'float \"footnote\" \"\" binding)))\n"
        "       (copy (read (open-input-string (object->string m))))\n"
        "       (fixed (org-texmacs-pdf-footnote-anchor-macro m)))\n"
        " (if (not (and fixed (equal? m copy)\n"
        "  (equal? fixed (list 'macro \"sym\" \"nr\" \"body\"\n"
        "   (list 'float \"footnote\" \"\" (list 'concat (list 'label (cadr binding)) binding))))\n"
        "  (not (org-texmacs-pdf-footnote-anchor-macro fixed))\n"
        "  (not (org-texmacs-pdf-footnote-anchor-macro '(macro \"body\" \"Foreign\")))\n"
        "  (not (org-texmacs-pdf-footnote-anchor-macro\n"
        "   (list 'macro \"sym\" \"nr\" \"body\" (list 'float \"footnote\" \"\" binding binding))))\n"
        "  (not (org-texmacs-pdf-footnote-anchor-macro\n"
        "   '(macro \"sym\" \"nr\" \"body\" (float \"other\" \"\" \"Body\"))))))\n"
        " (error \"Footnote macro recognition/copy/idempotence failed\")))\n"
        "(define original-get-env get-env-tree)\n"
        "(set! get-env-tree (lambda args (error \"Unnecessary macro lookup\")))\n"
        "(if (org-texmacs-pdf-install-footnote-anchors\n"
        " (list '(\"generic\") '() (stree->tree '(document \"No notes\"))))\n"
        " (error \"No-note input changed\"))\n"
        "(for-each (lambda (key)\n"
        " (if (org-texmacs-pdf-install-footnote-anchors\n"
        "  (list '(\"generic\") (list (cons key (stree->tree \"Override\")))\n"
        "   (stree->tree '(document (footnote \"Body\")))))\n"
        "  (error \"Explicit macro override changed\")))\n"
        " '(\"footnote\" \"render-footnote\" \"render-footnote*\"))\n"
        "(set! get-env-tree original-get-env)\n"))
     (let ((org-texmacs--worker-scheme-file script))
       (should
        (equal
         (org-texmacs--worker-request "(math \"x\")")
         '(math "x")))))))

(ert-deftest org-texmacs-pdf-footnote-cleanup-failure-stops-worker ()
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "footnote-cleanup-failure.scm"
                            test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(define original-install org-texmacs-pdf-install-footnote-anchors)\n"
        "(set! org-texmacs-pdf-install-footnote-anchors (lambda (native)\n"
        " (if (not (original-install native)) (error \"No override before cleanup test\"))))\n"
        "(set! buffer-close (lambda args (error \"Injected close failure\")))\n"))
     (let ((org-texmacs--worker-scheme-file script))
       (with-temp-buffer
         (org-mode)
         (insert "CleanupFirst[fn::CleanupBody].\n")
         (let ((document
                (org-texmacs-document-from-buffer (current-buffer))))
           (should-error
            (org-texmacs-document-pdf document)
            :type 'org-texmacs-worker-error)
           (should-not (org-texmacs--worker-live-p))
           (should-not org-texmacs--worker-directory)))))))

(ert-deftest org-texmacs-pdf-cleanup-failure-stops-worker ()
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "pdf-cleanup-failure.scm"
                            test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(set! buffer-close (lambda args (error \"Injected cleanup failure\")))\n"))
     (let ((org-texmacs--worker-scheme-file script))
       (should-error
        (org-texmacs-document-pdf
         (org-texmacs--document-create :body '(document "Text")))
        :type 'org-texmacs-worker-error)
       (should-not (org-texmacs--worker-live-p))
       (should-not org-texmacs--worker-directory)))))

;;; ert-pdf-pdf.el ends here
