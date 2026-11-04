;;; standard-cite.el --- Real CSL and native output -*- lexical-binding: t; -*-
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
    org-texmacs-standard-csl-text-and-pdf-without-serialization-roundtrip
    ()
  (org-texmacs-test--with-csl
   (with-temp-buffer
     (org-mode)
     (insert
      csl-header
      "Text [cite:@key]. (math (sqrt \"x\"))\n#+print_bibliography:\n")
     (let ((org-export-use-babel nil)
           (before (buffer-string))
           (prepared 0))
       (let ((org-export-before-processing-functions
              (list (lambda (_) (cl-incf prepared)))))
         (should (string-match-p "TeXmacs" (org-export-as 'texmacs)))
         (should (= prepared 1))
         (setq prepared 0)
         (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                    (lambda (&rest _)
                      (ert-fail
                       "PDF must consume native document directly"))))
           (let ((pdf (org-texmacs--standard-consume 'pdf))
                 (file
                  (expand-file-name "citation.pdf"
                                    default-directory)))
             (should (string-prefix-p "%PDF-" pdf))
             (let ((coding-system-for-write 'no-conversion))
               (write-region pdf nil file nil 'silent))
             (let ((text (org-texmacs-test--pdf-text file)))
               (should (string-match-p "Reference Alpha" text))
               (should-not (string-search "<#200B>" text)))))
         (should (= prepared 1))
         (should (equal before (buffer-string))))))))

(ert-deftest org-texmacs-standard-csl-text-filters-and-native-refusal
    ()
  (org-texmacs-test--with-csl
   (with-temp-buffer
     (org-mode)
     (insert csl-header "[cite:@key]\n#+print_bibliography:\n")
     (let ((org-export-use-babel nil)
           (body-calls 0)
           (final-calls 0))
       (let ((org-export-filter-body-functions
              (list
               (lambda (text _backend _info)
                 (cl-incf body-calls)
                 (concat text " BODY"))))
             (org-export-filter-final-output-functions
              (list
               (lambda (text _backend _info)
                 (cl-incf final-calls)
                 (concat text " FINAL")))))
         (should
          (string-suffix-p " BODY FINAL" (org-export-as 'texmacs)))
         (should (= body-calls 1))
         (should (= final-calls 1))
         (should-error
          (org-texmacs--standard-consume 'pdf)
          :type 'org-texmacs-document-error)
         (should (= body-calls 1))
         (should (= final-calls 1)))))))

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

(ert-deftest
    org-texmacs-standard-csl-zero-width-delimiters-render-without-visible-fallback
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "ab\n\na\u200bb\n")
     (let* ((org-export-use-babel nil)
            (pdf (org-texmacs--standard-consume 'pdf))
            (file
             (expand-file-name "zero-width.pdf" default-directory)))
       (let ((coding-system-for-write 'no-conversion))
         (write-region pdf nil file nil 'silent))
       (should-not
        (string-search "<#200B>" (org-texmacs-test--pdf-text file)))
       (let* ((words
               (cl-remove-if-not
                (lambda (word) (equal (car word) "ab"))
                (org-texmacs-test--pdf-words file)))
              (widths
               (mapcar
                (lambda (word) (- (nth 3 word) (nth 1 word))) words)))
         (should (= (length words) 2))
         (should (< (abs (- (car widths) (cadr widths))) 0.01)))))))

(ert-deftest org-texmacs-standard-csl-interactive-command-consumers ()
  (org-texmacs-test--with-csl
   (with-temp-buffer
     (org-mode)
     (setq buffer-file-name
           (expand-file-name "source.org" default-directory))
     (insert
      csl-header
      "[cite:@key]
#+print_bibliography:
")
     (let ((org-export-use-babel nil)
           (org-export-show-temporary-export-buffer nil)
           (cite (symbol-function 'org-cite-csl-render-citation)))
       (dolist (command
                '(org-texmacs-export-as-texmacs
                  org-texmacs-export-to-texmacs
                  org-texmacs-export-to-pdf))
         (let ((prepared 0)
               (citations 0))
           (let ((org-export-before-processing-functions
                  (list (lambda (_) (cl-incf prepared)))))
             (cl-letf (((symbol-function
                         'org-cite-csl-render-citation)
                        (lambda (&rest args)
                          (cl-incf citations)
                          (apply cite args))))
               (let ((result (funcall command)))
                 (cond
                  ((bufferp result)
                   (unwind-protect
                       (should
                        (string-match-p
                         "Reference Alpha"
                         (with-current-buffer result
                           (buffer-string))))
                     (kill-buffer result)))
                  ((eq command 'org-texmacs-export-to-pdf)
                   (should
                    (string-match-p
                     "Reference Alpha"
                     (org-texmacs-test--pdf-text result))))
                  (t
                   (with-temp-buffer
                     (insert-file-contents-literally result)
                     (should
                      (string-match-p
                       "Reference Alpha" (buffer-string)))))))))
           (should (= prepared 1))
           (should (= citations 1))))))))

(ert-deftest org-texmacs-standard-csl-explicit-source-consumers ()
  (org-texmacs-test--with-csl
   (with-temp-buffer
     (org-mode)
     (insert csl-header "[cite:@key]\n#+print_bibliography:\n")
     (let ((source (current-buffer))
           (cite (symbol-function 'org-cite-csl-render-citation)))
       (dolist (kind '(tm pdf buffer tm-file pdf-file))
         (let ((prepared 0)
               (citations 0)
               (file
                (expand-file-name (format "source-%s" kind)
                                  default-directory)))
           (let ((org-export-before-processing-functions
                  (list (lambda (_) (cl-incf prepared)))))
             (cl-letf (((symbol-function
                         'org-cite-csl-render-citation)
                        (lambda (&rest args)
                          (cl-incf citations)
                          (apply cite args))))
               (let ((result
                      (with-temp-buffer
                        (pcase kind
                          ('tm
                           (org-texmacs-export-texmacs-from-buffer
                            source))
                          ('pdf
                           (org-texmacs-export-pdf-from-buffer
                            source))
                          ('buffer
                           (org-texmacs-export-to-buffer source))
                          ('tm-file
                           (org-texmacs-export-to-texmacs-file
                            source file))
                          ('pdf-file
                           (org-texmacs-export-to-pdf-file
                            source file))))))
                 (pcase kind
                   ('buffer
                    (unwind-protect
                        (with-current-buffer result
                          (should
                           (string-search
                            "Reference alpha" (buffer-string))))
                      (kill-buffer result)))
                   ('pdf (should (string-prefix-p "%PDF-" result)))
                   ('pdf-file
                    (should
                     (string-search
                      "Reference alpha"
                      (org-texmacs-test--pdf-text result))))
                   ('tm-file
                    (with-temp-buffer
                      (insert-file-contents-literally result)
                      (should
                       (string-search
                        "Reference alpha" (buffer-string)))))
                   (_
                    (should
                     (string-search "Reference alpha" result)))))))
           (should (= prepared 1))
           (should (= citations 1))))))))

(ert-deftest
    org-texmacs-standard-csl-owned-bibliography-after-preparation
    ()
  (org-texmacs-test--with-csl
   (with-temp-buffer
     (org-mode)
     (setq buffer-file-name
           (expand-file-name "source.org" default-directory))
     (insert
      csl-header
      "[cite:@key]
#+print_bibliography:
")
     (let ((org-export-use-babel nil)
           (original
            (with-temp-buffer
              (insert-file-contents csl-bibliography)
              (buffer-string))))
       (dolist (kind '(tm pdf))
         (with-temp-file csl-bibliography
           (insert original))
         (let* ((consumer
                 (if (eq kind 'pdf)
                     'org-texmacs-document-pdf
                   'org-texmacs-document-serialize))
                (native (symbol-function consumer)))
           (cl-letf (((symbol-function consumer)
                      (lambda (document)
                        (should
                         (string-match-p
                          "Reference Alpha"
                          (prin1-to-string
                           (org-texmacs-document-body document))))
                        (with-temp-file csl-bibliography
                          (insert "Changed external bibliography"))
                        (funcall native document))))
             (let ((file
                    (if (eq kind 'pdf)
                        (org-texmacs-export-to-pdf)
                      (org-texmacs-export-to-texmacs))))
               (if (eq kind 'pdf)
                   (should
                    (string-match-p
                     "Reference Alpha"
                     (org-texmacs-test--pdf-text file)))
                 (with-temp-buffer
                   (insert-file-contents-literally file)
                   (should
                    (string-match-p
                     "Reference Alpha" (buffer-string)))))))))))))
