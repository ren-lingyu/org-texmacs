;;; standard-cite.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'oc-csl)

(ert-deftest
    org-texmacs-standard-csl-retained-latex-fragment-is-explicitly-unsupported
    ()
  (org-texmacs-test--with-csl
   (with-temp-file csl-bibliography
     (insert
      "@article{key, title={Properties of $\\cdot$}, author={Someone, A}, year={2026}}\n"))
   (dolist (case '(body bibliography))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: e:t ^:t tex:t\n"
        (if (eq case 'body)
            "Entity \\cdot and fragment $\\cdot$.\n"
          (concat csl-header "[cite:@key]\n#+print_bibliography:\n")))
       (let* ((source (buffer-string))
              (org-export-use-babel nil)
              (processing 0)
              (filters 0)
              captured
              (bridge (symbol-function 'org-texmacs--standard-input))
              (org-export-before-processing-functions
               (list (lambda (_) (cl-incf processing))))
              (org-export-filter-parse-tree-functions
               (list
                (lambda (tree _backend _info)
                  (cl-incf filters)
                  tree))))
         (cl-letf
             (((symbol-function 'org-texmacs--standard-input)
               (lambda (info state)
                 (setq captured (funcall bridge info state))))
              ((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail
                  "Unsupported LaTeX must not start native conversion"))))
           (let ((error
                  (should-error
                   (org-export-as 'texmacs)
                   :type 'org-texmacs-document-error)))
             (should (equal (nth 1 error) "Unsupported inline node"))
             (should (eq (nth 2 error) 'latex-fragment))))
         (should (= processing 1))
         (should (= filters 1))
         (should (equal source (buffer-string)))
         (let ((ast (org-texmacs-input-ast captured)))
           (should
            (equal
             (org-element-map
              ast 'latex-fragment
              (lambda (node) (org-element-property :value node)))
             (if (eq case 'body)
                 '("$\\cdot$")
               '("$\\cdot$" "$\\cdot$"))))
           (should
            (= (length (org-element-map ast 'entity #'identity))
               (if (eq case 'body)
                   1
                 0)))))))))

(ert-deftest org-texmacs-standard-csl-transaction-info-and-key-filter
    ()
  (org-texmacs-test--with-csl
   (with-temp-buffer
     (org-mode)
     (insert csl-header "[cite:@alias]\n#+print_bibliography:\n")
     (let ((org-export-use-babel nil)
           (prepared 0)
           (filtered 0)
           (citations 0)
           (bibliographies 0)
           live
           citation-info)
       (let ((org-export-before-processing-functions
              (list (lambda (_) (cl-incf prepared))))
             (org-export-filter-parse-tree-functions
              (list
               (lambda (tree _backend info)
                 (cl-incf filtered)
                 (setq live (plist-get info :bibliography))
                 (org-element-map
                  tree 'citation-reference
                  (lambda (reference)
                    (org-element-put-property reference :key "key")))
                 tree)))
             (cite (symbol-function 'org-cite-csl-render-citation))
             (bibliography
              (symbol-function 'org-cite-csl-render-bibliography)))
         (cl-letf (((symbol-function 'org-cite-csl-render-citation)
                    (lambda (citation style backend info)
                      (cl-incf citations)
                      (should
                       (eq live (plist-get info :bibliography)))
                      (setq citation-info info)
                      (should
                       (equal
                        '("key")
                        (org-cite-get-references citation t)))
                      (should
                       (equal
                        (list csl-bibliography)
                        (plist-get info :bibliography)))
                      (funcall cite citation style backend info)))
                   ((symbol-function
                     'org-cite-csl-render-bibliography)
                    (lambda (keys files style props backend info)
                      (cl-incf bibliographies)
                      (should (eq citation-info info))
                      (should (equal '("key") keys))
                      (should (equal (list csl-bibliography) files))
                      (funcall bibliography
                               keys
                               files
                               style
                               props
                               backend
                               info)))
                   ((symbol-function 'org-texmacs--worker-request)
                    (lambda (&rest _)
                      (ert-fail
                       "Structured CSL requested native work")))
                   ((symbol-function 'org-texmacs--stm-read)
                    (lambda (&rest _)
                      (ert-fail
                       "Structured CSL needs no STM parser"))))
           (let* ((input (org-texmacs--standard-consume 'input))
                  (ast (org-texmacs-input-ast input))
                  (body
                   (org-texmacs-document-body
                    (org-texmacs-document input))))
             (should (org-element-map ast 'italic #'identity))
             (should-not (org-element-map ast 'citation #'identity))
             (should (string-match-p "hlink" (prin1-to-string body)))
             (should
              (string-match-p
               "Reference Alpha" (prin1-to-string body)))
             (should-not
              (string-match-p
               "Reference Beta" (prin1-to-string body))))))
       (should (= prepared 1))
       (should (= filtered 1))
       (should (= citations 1))
       (should (= bibliographies 1))))))

(ert-deftest org-texmacs-standard-csl-supported-locations-and-affixes
    ()
  (org-texmacs-test--with-csl
   (dolist (source
            '("* Heading [cite:@key]\nText.\n"
              "Note[fn::[cite:@key]].\n"
              "Note[fn:x].\n\n[fn:x] [cite:@key]\n"
              "| [cite:@key] | Cell |\n"
              "#+caption: Caption [cite:@key]\n| Cell | Cell |\n"
              "*Markup [cite:@key]*.\n"
              "[cite:*see* @key]\n"
              "[cite:@key p. 4]\n"))
     (with-temp-buffer
       (org-mode)
       (if (string-match-p "see" source)
           (let ((style
                  (expand-file-name "affix.csl" default-directory)))
             (with-temp-file style
               (insert
                (string-replace
                 " prefix=\"[\" suffix=\"]\""
                 ""
                 org-texmacs-test--csl-style)))
             (insert
              (format "#+bibliography: %s\n#+cite_export: csl %s\n"
                      csl-bibliography style)))
         (insert csl-header))
       (insert source "\n#+print_bibliography:\n")
       (let ((org-export-use-babel nil))
         (let* ((input (org-texmacs--standard-consume 'input))
                (body
                 (org-texmacs-document-body
                  (org-texmacs-document input))))
           (should
            (string-match-p "Reference Alpha" (prin1-to-string body)))
           (when (string-match-p "see" source)
             (should
              (org-element-map
               (org-texmacs-input-ast input) 'bold #'identity)))))))))

(ert-deftest
    org-texmacs-standard-csl-finalizer-advice-refused-before-effects
    ()
  (org-texmacs-test--with-csl
   (with-temp-buffer
     (org-mode)
     (insert csl-header "[cite:@key]\n#+print_bibliography:\n")
     (let ((org-export-use-babel nil)
           (calls 0))
       (let ((advice (lambda (&rest _) (cl-incf calls))))
         (unwind-protect
             (progn
               (advice-add 'org-cite-csl-finalizer :before advice)
               (should-error
                (org-texmacs--standard-consume 'document)
                :type 'org-texmacs-document-error)
               (should (= calls 0)))
           (advice-remove 'org-cite-csl-finalizer advice)))))))

(ert-deftest org-texmacs-standard-csl-user-default-preserved ()
  (org-texmacs-test--with-csl
   (dolist (setting
            (list
             (list nil `((t csl ,csl-style)))
             (list
              '(texmacs-native "alpha")
              `((texmacs csl ,csl-style) (t basic)))
             (list (list 'csl csl-style) '((t basic)))))
     (let ((org-texmacs-cite-export-processor (car setting))
           (org-cite-export-processors (cadr setting))
           (org-export-use-babel nil)
           declaration)
       (with-temp-buffer
         (org-mode)
         (insert
          "#+bibliography: "
          csl-bibliography
          "\n[cite:@key]\n#+print_bibliography:\n")
         (let* ((org-export-filter-options-functions
                 (list
                  (lambda (info _backend)
                    (setq declaration
                          (copy-sequence
                           (plist-get info :cite-export)))
                    info)))
                (document
                 (org-texmacs-document-from-buffer (current-buffer)))
                (body (org-texmacs-document-body document)))
           (should (equal declaration (list 'csl csl-style nil)))
           (should
            (string-search "Reference alpha" (prin1-to-string body)))
           (should (memq 'hlink (flatten-tree body)))
           (should-not (memq 'with-bib (flatten-tree body)))))))))

;;; standard-cite.el ends here
