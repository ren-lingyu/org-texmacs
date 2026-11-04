;;; native-cite-default.el --- Standard native default precedence -*- lexical-binding: t; -*-
(require 'ox-html)
(require 'ox-latex)

(defun org-texmacs-test--default-cite
    (configuration &optional declaration options)
  "Export with CONFIGURATION, DECLARATION and OPTIONS; return selected processor."
  (let ((org-cite-export-processors configuration)
        (org-export-use-babel nil)
        (org-texmacs-test--cite-result 'element)
        (org-texmacs-test--cite-calls nil)
        (bridge (symbol-function 'org-texmacs--standard-input))
        selected)
    (with-temp-buffer
      (org-mode)
      (insert
       "#+bibliography: /fixture/refs.bib\n"
       (if declaration
           (concat "#+cite_export: " declaration "\n")
         "")
       "Text [cite:@key].\n#+print_bibliography:\n")
      (cl-letf (((symbol-function
                  'org-texmacs--prepared-cite-snapshot)
                 #'identity)
                ((symbol-function 'org-texmacs--prepared-cite-fulfill)
                 #'identity)
                ((symbol-function 'org-texmacs--standard-input)
                 (lambda (info state)
                   (setq selected (org-cite-processor info))
                   (funcall bridge info state))))
        (org-texmacs--standard-consume 'input nil nil options)))
    (should (equal configuration org-cite-export-processors))
    selected))

(ert-deftest org-texmacs-native-default-standard-selection ()
  (should
   (eq (org-texmacs-test--default-cite '((t basic))) 'texmacs-native))
  (should-not (org-texmacs-test--default-cite nil))
  (should-not (org-texmacs-test--default-cite '((html basic))))
  (dolist (config
           '(((t org-texmacs-test-structured))
             ((texmacs org-texmacs-test-structured) (t basic))))
    (should
     (eq
      (org-texmacs-test--default-cite config)
      'org-texmacs-test-structured)))
  (should
   (eq
    (org-texmacs-test--default-cite nil
                                    "texmacs-native alpha")
    'texmacs-native))
  (should
   (eq
    (org-texmacs-test--default-cite '((t basic))
                                    "org-texmacs-test-structured")
    'org-texmacs-test-structured))
  (should
   (eq
    (org-texmacs-test--default-cite
     '((t basic))
     nil '(:cite-export "org-texmacs-test-structured"))
    'org-texmacs-test-structured))
  (should
   (eq
    (org-texmacs-test--default-cite
     '((t basic))
     "texmacs-native" '(:cite-export "org-texmacs-test-structured"))
    'texmacs-native)))

(ert-deftest org-texmacs-native-default-explicit-basic-still-rejected
    ()
  (dolist (case '((((texmacs basic)) nil) (((t basic)) "basic")))
    (should-error
     (org-texmacs-test--default-cite (car case) (cadr case))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-native-default-options-filter-selection ()
  (let ((org-export-filter-options-functions
         (list
          (lambda (info backend)
            (when (eq backend 'texmacs)
              (plist-put
               info
               :cite-export '(org-texmacs-test-structured nil nil)))
            info))))
    (should
     (eq
      (org-texmacs-test--default-cite '((t basic)))
      'org-texmacs-test-structured))))

(ert-deftest org-texmacs-native-default-other-backends-and-nesting ()
  (let ((org-cite-export-processors '((t basic)))
        (org-export-use-babel nil)
        processors)
    (with-temp-buffer
      (org-mode)
      (insert "Ordinary text.\n")
      (let ((org-export-filter-options-functions
             (list
              (lambda (info backend)
                (push
                 (cons backend (org-cite-processor info)) processors)
                info))))
        (org-export-as 'html nil nil t)
        (org-export-as 'latex nil nil t)
        (let ((org-export-before-processing-functions
               (list
                (lambda (backend)
                  (when (eq backend 'texmacs)
                    (org-export-as 'html nil nil t))))))
          (org-texmacs--standard-consume 'input))
        (org-export-as 'html nil nil t)))
    (should
     (equal
      (nreverse processors)
      '((html . basic)
        (latex . basic)
        (html . basic)
        (texmacs . texmacs-native)
        (html . basic))))
    (should (equal org-cite-export-processors '((t basic))))))

(ert-deftest org-texmacs-native-default-subtree-declaration-wins ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+bibliography: /fixture/refs.bib\n#+cite_export: texmacs-native\n"
     "* Selected\n:PROPERTIES:\n:EXPORT_CITE_EXPORT: org-texmacs-test-structured\n:END:\n"
     "[cite:@key]\n#+print_bibliography:\n* Other\nOutside.\n")
    (goto-char (point-min))
    (search-forward "* Selected")
    (beginning-of-line)
    (let ((org-cite-export-processors '((t basic)))
          (org-export-use-babel nil)
          (org-texmacs-test--cite-result 'element)
          (org-texmacs-test--cite-calls nil)
          selected
          (bridge (symbol-function 'org-texmacs--standard-input)))
      (cl-letf (((symbol-function 'org-texmacs--standard-input)
                 (lambda (info state)
                   (setq selected (org-cite-processor info))
                   (funcall bridge info state))))
        (org-texmacs--standard-consume 'input t))
      (should (eq selected 'org-texmacs-test-structured)))))

(ert-deftest org-texmacs-native-cite-inactive-alt-title-owned-request
    ()
  (let ((org-texmacs-test--native-cite-fulfiller
         #'org-texmacs-test--native-cite-fill))
    (dolist (case
             '((nil "* Heading [cite:@one]" nil)
               ("1" "* Heading [cite:@one]" t)
               ("1" "* Root\n** Heading [cite:@one]" nil)))
      (let*
          ((text
            (concat
             (when (car case)
               (concat "#+OPTIONS: toc:" (car case) "\n"))
             (cadr case)
             "\n:PROPERTIES:\n:ALT_TITLE: Alternate [cite:@two]\n:END:\n"
             "Text.\n#+print_bibliography:\n"))
           (input (org-texmacs-test--native-cite-prepare text))
           (body (org-texmacs-test--native-cite-lower input))
           (printed (prin1-to-string body)))
        (should
         (= 2
            (cl-count-if
             (lambda (label)
               (string-prefix-p "org-texmacs-bib-" label))
             (org-texmacs--bibliography-labels body))))
        (should
         (eq
          (and (string-search "Alternate" printed) t) (nth 2 case)))
        (should
         (equal body (org-texmacs-test--native-cite-lower input)))))))
