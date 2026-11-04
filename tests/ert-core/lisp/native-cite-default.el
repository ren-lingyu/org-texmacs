;;; native-cite-default.el --- Standard native default precedence -*- lexical-binding: t; -*-
(require 'ox-html)
(require 'ox-latex)

(cl-defun
 org-texmacs-test--default-cite
 (configuration
  &optional declaration options (preferred '(texmacs-native)) empty)
 "Export CONFIGURATION/DECLARATION/OPTIONS using PREFERRED; return full triplet.
When EMPTY, test standard options/selection without invoking Cite finalizers."
 (let ((org-texmacs-cite-export-processor preferred)
       (before (copy-tree configuration))
       (org-cite-export-processors configuration)
       (org-export-use-babel nil)
       (org-texmacs-test--cite-result 'element)
       (org-texmacs-test--cite-calls nil)
       (bridge (symbol-function 'org-texmacs--standard-input))
       selected)
   (with-temp-buffer
     (org-mode)
     (insert
      (if empty
          ""
        "#+bibliography: /fixture/refs.bib\n")
      (if declaration
          (concat "#+cite_export: " declaration "\n")
        "")
      (if empty
          "Plain text.\n"
        "Text [cite:@key].\n#+print_bibliography:\n"))
     (if empty
         (let ((info
                (org-export-get-environment
                 (org-export-get-backend 'texmacs) nil options)))
           (plist-put
            info
            :back-end (org-export-get-backend 'texmacs))
           (org-cite-store-export-processor info)
           (setq selected
                 (copy-sequence (plist-get info :cite-export))))
       (cl-letf (((symbol-function
                   'org-texmacs--prepared-cite-snapshot)
                  #'identity)
                 ((symbol-function
                   'org-texmacs--prepared-cite-fulfill)
                  #'identity)
                 ((symbol-function 'org-texmacs--standard-input)
                  (lambda (info state)
                    (setq selected
                          (copy-sequence
                           (plist-get info :cite-export)))
                    (funcall bridge info state))))
         (org-texmacs--standard-consume 'input nil nil options))))
   (should (eq configuration org-cite-export-processors))
   (should (equal before org-cite-export-processors))
   selected))

(ert-deftest org-texmacs-native-default-standard-selection ()
  (should
   (equal
    (org-texmacs-test--default-cite '((t basic)))
    '(texmacs-native nil nil)))
  (should
   (equal
    (org-texmacs-test--default-cite nil) '(texmacs-native nil nil)))
  (should-not (org-texmacs-test--default-cite nil nil nil nil))
  (should
   (equal
    (org-texmacs-test--default-cite '((html basic)))
    '(texmacs-native nil nil)))
  (should-not
   (org-texmacs-test--default-cite '((html basic)) nil nil nil))
  (dolist (config
           '(((t org-texmacs-test-structured))
             ((texmacs org-texmacs-test-structured) (t basic))))
    (should
     (equal
      (org-texmacs-test--default-cite config nil nil nil)
      '(org-texmacs-test-structured nil nil))))
  (should
   (equal
    (org-texmacs-test--default-cite
     nil "texmacs-native alpha")
    '(texmacs-native "alpha" nil)))
  (should
   (equal
    (org-texmacs-test--default-cite
     '((t basic)) "org-texmacs-test-structured")
    '(org-texmacs-test-structured nil nil)))
  (should
   (equal
    (org-texmacs-test--default-cite
     '((t basic)) nil '(:cite-export "org-texmacs-test-structured"))
    '(org-texmacs-test-structured nil nil)))
  (should
   (equal
    (org-texmacs-test--default-cite
     '((t basic))
     "texmacs-native"
     '(:cite-export "org-texmacs-test-structured"))
    '(texmacs-native nil nil)))
  (should
   (equal
    (org-texmacs-test--default-cite
     '((t basic))
     nil
     '(:cite-export "texmacs-native abbrv")
     '(texmacs-native "alpha"))
    '(texmacs-native "abbrv" nil)))
  (should
   (equal
    (org-texmacs-test--default-cite
     '((t basic))
     "texmacs-native abbrv"
     '(:cite-export "texmacs-native plain")
     '(texmacs-native "alpha"))
    '(texmacs-native "abbrv" nil))))

(ert-deftest org-texmacs-native-default-explicit-basic-still-rejected
    ()
  (dolist (preferred '((texmacs-native) (csl) nil))
    (dolist (case '((((texmacs basic)) nil) (((t basic)) "basic")))
      (should-error
       (org-texmacs-test--default-cite
        (car case) (cadr case) nil preferred)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-native-default-options-filter-selection ()
  (let ((org-export-filter-options-functions
         (list
          (lambda (info backend)
            (when (eq backend 'texmacs)
              (plist-put
               info
               :cite-export
               '(org-texmacs-test-structured "filter-bib" nil)))
            info))))
    (should
     (equal
      (org-texmacs-test--default-cite
       '((t basic)) nil nil '(texmacs-native "alpha"))
      '(org-texmacs-test-structured "filter-bib" nil)))))

(ert-deftest org-texmacs-native-default-other-backends-and-nesting ()
  (let ((org-cite-export-processors '((t basic)))
        (org-texmacs-cite-export-processor '(texmacs-native "alpha"))
        (org-export-use-babel nil)
        processors)
    (with-temp-buffer
      (org-mode)
      (insert "Ordinary text.\n")
      (let ((org-export-filter-options-functions
             (list
              (lambda (info backend)
                (push (cons
                       backend
                       (copy-sequence (plist-get info :cite-export)))
                      processors)
                info))))
        (org-export-as 'html nil nil t)
        (org-export-as 'latex nil nil t)
        (let ((org-export-before-processing-functions
               (list
                (lambda (backend)
                  (when (eq backend 'texmacs)
                    (org-export-as 'html nil nil t)
                    (let ((org-texmacs-cite-export-processor nil)
                          (org-export-before-processing-functions
                           nil))
                      (org-texmacs--standard-consume 'input)))))))
          (org-texmacs--standard-consume 'input))
        (org-export-as 'html nil nil t)))
    (should
     (equal
      (nreverse processors)
      '((html basic nil nil)
        (latex basic nil nil)
        (html basic nil nil)
        (texmacs basic nil nil)
        (texmacs texmacs-native "alpha" nil)
        (html basic nil nil))))
    (should (equal org-cite-export-processors '((t basic))))))

(ert-deftest org-texmacs-native-default-subtree-declaration-wins ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+bibliography: /fixture/refs.bib\n#+cite_export: texmacs-native alpha\n"
     "* Selected\n:PROPERTIES:\n:EXPORT_CITE_EXPORT: org-texmacs-test-structured subtree-bib\n:END:\n"
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
                   (setq selected
                         (copy-sequence
                          (plist-get info :cite-export)))
                   (funcall bridge info state))))
        (org-texmacs--standard-consume 'input t))
      (should
       (equal
        selected '(org-texmacs-test-structured "subtree-bib" nil))))))

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

(ert-deftest org-texmacs-cite-preference-configuration-matrix ()
  (dolist (case
           '(((texmacs-native) ((t basic)) (texmacs-native nil nil))
             ((texmacs-native "alpha")
              ((t basic))
              (texmacs-native "alpha" nil))
             ((texmacs-native "abbrv")
              nil
              (texmacs-native "abbrv" nil))
             ((texmacs-native "alpha" nil)
              ((t csl))
              (texmacs-native "alpha" nil))
             ((texmacs-native) ((t csl)) (texmacs-native nil nil))
             ((texmacs-native) nil (texmacs-native nil nil))
             ((texmacs-native "alpha")
              ((texmacs csl "backend.csl" "numeric") (t basic))
              (csl "backend.csl" "numeric"))
             ((csl "local.csl" "author-year")
              ((t basic))
              (csl "local.csl" "author-year"))
             (nil ((t basic)) (basic nil nil))
             (nil ((t csl "fallback.csl")) (csl "fallback.csl" nil))
             (nil nil nil)))
    (should
     (equal
      (org-texmacs-test--default-cite
       (nth 1 case) nil nil (car case) t)
      (nth 2 case)))))

(ert-deftest org-texmacs-cite-preference-keeps-original-configuration
    ()
  (dolist (preferred
           '(nil
             (texmacs-native)
             (texmacs-native "alpha" nil)
             (csl "local.csl")))
    (dolist (configuration '(nil ((t csl)) ((texmacs basic) (t csl))))
      (let* ((org-texmacs-cite-export-processor preferred)
             (org-cite-export-processors (copy-tree configuration))
             (original org-cite-export-processors)
             (before (copy-tree original))
             (effective (org-texmacs--cite-default-processors)))
        (should (eq original org-cite-export-processors))
        (should (equal before original))
        (if (or (null preferred) (assq 'texmacs original))
            (should (eq effective original))
          (should (equal (car effective) (cons 'texmacs preferred)))
          (should (eq (cdr effective) original)))))))

(ert-deftest org-texmacs-cite-preference-derived-backend-specificity
    ()
  (let ((org-export-registered-backends
         (copy-sequence org-export-registered-backends))
        (org-texmacs-cite-export-processor '(texmacs-native "alpha"))
        (org-export-use-babel nil))
    (org-export-define-derived-backend
     'org-texmacs-test-derived 'texmacs nil)
    (dolist (configuration
             '(((org-texmacs-test-derived org-texmacs-test-structured)
                (texmacs basic) (t basic))
               ((org-texmacs-test-derived org-texmacs-test-structured)
                (t basic))))
      (let ((org-cite-export-processors configuration)
            selected)
        (with-temp-buffer
          (org-mode)
          (insert "Plain text.\n")
          (let ((org-export-filter-options-functions
                 (list
                  (lambda (info _backend)
                    (setq selected
                          (copy-sequence
                           (plist-get info :cite-export)))
                    info))))
            (cl-letf (((symbol-function
                        'org-texmacs-document-serialize)
                       (lambda (_) "Text")))
              (org-export-as 'org-texmacs-test-derived)))
          (should
           (equal
            selected '(org-texmacs-test-structured nil nil))))))))

(ert-deftest org-texmacs-cite-preference-standard-processor-errors ()
  (let ((org-cite--processors (copy-sequence org-cite--processors)))
    (org-cite-register-processor
     'org-texmacs-test-no-export
     :follow #'ignore)
    (dolist (preferred
             '((org-texmacs-test-unregistered)
               (org-texmacs-test-no-export)))
      (should-error
       (org-texmacs-test--default-cite
        '((t basic)) nil nil preferred t)
       :type 'user-error))))

(ert-deftest org-texmacs-cite-preference-preload-and-runtime-changes
    ()
  (dolist (initial '(nil (basic) (texmacs-native "alpha" nil)))
    (org-texmacs-test--menu-fresh-process
     `(progn
        (should-not (featurep 'ox-texmacs))
        (let ((configured ',initial))
          (setq org-texmacs-cite-export-processor configured)
          (require 'ox-texmacs)
          (should (eq org-texmacs-cite-export-processor configured)))
        (let ((org-cite-export-processors '((t basic)))
              (org-export-use-babel nil)
              (bridge (symbol-function 'org-texmacs--standard-input))
              selected)
          (dolist (case
                   '((nil (basic nil nil))
                     ((texmacs-native) (texmacs-native nil nil))
                     ((texmacs-native "alpha")
                      (texmacs-native "alpha" nil))
                     ((texmacs-native "abbrv")
                      (texmacs-native "abbrv" nil))
                     ((texmacs-native "alpha" nil)
                      (texmacs-native "alpha" nil))
                     ((basic) (basic nil nil)) (nil (basic nil nil))))
            (setq org-texmacs-cite-export-processor (car case))
            (with-temp-buffer
              (org-mode)
              (insert "Plain text.\n")
              (cl-letf (((symbol-function
                          'org-texmacs--standard-input)
                         (lambda (info state)
                           (setq selected
                                 (copy-sequence
                                  (plist-get info :cite-export)))
                           (funcall bridge info state))))
                (org-texmacs--standard-consume 'input)))
            (should (equal selected (cadr case)))))))))

(ert-deftest
    org-texmacs-cite-preference-native-bibliography-style-handoff
    ()
  (dolist (case
           '(((texmacs-native) (texmacs-native nil nil) "plain")
             ((texmacs-native "alpha")
              (texmacs-native "alpha" nil)
              "alpha")
             ((texmacs-native "abbrv")
              (texmacs-native "abbrv" nil)
              "abbrv")
             ((texmacs-native "alpha" nil)
              (texmacs-native "alpha" nil)
              "alpha")))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+bibliography: /fixture/references.bib\nText [cite:@key].\n#+print_bibliography:\n")
      (let ((org-texmacs-cite-export-processor (car case))
            (org-cite-export-processors '((t basic)))
            (org-export-use-babel nil)
            (bridge (symbol-function 'org-texmacs--standard-input))
            selected)
        (cl-letf (((symbol-function 'org-texmacs--standard-input)
                   (lambda (info state)
                     (setq selected
                           (copy-sequence
                            (plist-get info :cite-export)))
                     (funcall bridge info state)))
                  ((symbol-function
                    'org-texmacs--prepared-cite-snapshot)
                   #'identity)
                  ((symbol-function
                    'org-texmacs--prepared-cite-fulfill)
                   #'identity)
                  ((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Request fixture started worker"))))
          (let* ((input (org-texmacs--standard-consume 'input))
                 (plan
                  (plist-get
                   (org-texmacs-input-info input)
                   :texmacs-cite-plan)))
            (should (equal selected (nth 1 case)))
            (should (equal (plist-get plan :style) (nth 2 case)))
            (should (equal (plist-get plan :keys) '("key")))))))))
