;;; standard-context.el --- Standard preparation and query regressions -*- lexical-binding: t; -*-

(require 'ox-texmacs)

(ert-deftest
    org-texmacs-standard-context-options-filter-controls-native-output
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: num:t tags:t todo:t\n* TODO Heading :shown:\nBody.\n")
    (let ((org-export-use-babel nil)
          (calls 0))
      (let ((org-export-filter-options-functions
             (list
              (lambda (info _backend)
                (cl-incf calls)
                (dolist (key
                         '(:section-numbers
                           :with-todo-keywords
                           :with-tags
                           :with-toc))
                  (setq info (plist-put info key nil)))
                info))))
        (let* ((input (org-texmacs--standard-consume 'input))
               (query
                (plist-get
                 (org-texmacs-input-info input)
                 :texmacs-org-query))
               (body
                (org-texmacs-document-body
                 (org-texmacs-document input))))
          (should (= calls 1))
          (should-not (nth 2 (car (plist-get query :headlines))))
          (should (memq 'section* (flatten-tree body)))
          (should-not
           (string-match-p
            "TODO\\|shown" (prin1-to-string body))))))))

(ert-deftest
    org-texmacs-standard-context-conditional-properties-are-resolved
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* Actual\nBody.\n")
    (let* ((org-export-use-babel nil)
           (model (org-texmacs--standard-consume 'model))
           (headline
            (car
             (org-element-map
              (org-texmacs-model-ast model) 'headline #'identity))))
      (should-not
       (org-element-property-raw :footnote-section-p headline))
      (should-not (org-element-property-raw :archivedp headline)))))

(ert-deftest
    org-texmacs-standard-context-disabled-inline-options-follow-org
    ()
  (let ((body
         (org-texmacs-test--standard-body
          "#+OPTIONS: *:nil ^:nil\n*bold* and x_{sub}.\n")))
    (should-not (memq 'strong (flatten-tree body)))
    (should (string-match-p "bold" (prin1-to-string body)))))

(defun org-texmacs-test--standard-body
    (source &optional select subtree visible options)
  "Lower SOURCE through standard export, applying SELECT before preparation."
  (with-temp-buffer
    (org-mode)
    (insert source)
    (when select
      (funcall select))
    (let ((org-export-use-babel nil))
      (org-texmacs-document-body
       (org-texmacs--standard-consume
        'document subtree visible options)))))

(ert-deftest
    org-texmacs-standard-context-full-subtree-region-narrowing
    ()
  (let
      ((source
        "* First\nfirsttoken.\n* Selected\nselectedtoken.\n* Other\nothertoken.\n"))
    (dolist (scope '(full subtree region narrow))
      (let* ((body
              (org-texmacs-test--standard-body
               source
               (lambda ()
                 (when (memq scope '(subtree region narrow))
                   (goto-char (point-min))
                   (search-forward "* Selected")
                   (beginning-of-line)
                   (let ((start (point))
                         (stop
                          (save-excursion
                            (search-forward "* Other")
                            (beginning-of-line)
                            (point))))
                     (pcase scope
                       ('narrow (narrow-to-region start stop))
                       ('region
                        (setq-local transient-mark-mode t)
                        (set-mark stop)
                        (activate-mark))))))
               (eq scope 'subtree)))
             (text (prin1-to-string body)))
        (should (string-match-p "selectedtoken" text))
        (if (eq scope 'full)
            (should (string-match-p "othertoken" text))
          (should-not
           (string-match-p "othertoken\\|firsttoken" text)))))))

(ert-deftest
    org-texmacs-standard-context-comment-noexport-archive-selection
    ()
  (let
      ((body
        (org-texmacs-test--standard-body
         "#+OPTIONS: arch:nil\n* Kept\nkepttoken.\n* COMMENT Comment\ncommenttoken.\n* Excluded :noexport:\nexcludedtoken.\n* Archived :ARCHIVE:\narchivedtoken.\n")))
    (should (string-match-p "kepttoken" (prin1-to-string body)))
    (should-not
     (string-match-p
      "commenttoken\\|excludedtoken\\|archivedtoken"
      (prin1-to-string body)))))

(ert-deftest org-texmacs-standard-context-select-tags-and-visible-only
    ()
  (let
      ((body
        (org-texmacs-test--standard-body
         "#+SELECT_TAGS: chosen\n* Kept :chosen:\nkepttoken.\n* Other\nothertoken.\n")))
    (should (string-match-p "kepttoken" (prin1-to-string body)))
    (should-not (string-match-p "othertoken" (prin1-to-string body))))
  (let ((body
         (org-texmacs-test--standard-body
          "* Visible\nvisibletoken.\n* Hidden\nhiddentoken.\n"
          (lambda ()
            (goto-char (point-min))
            (search-forward "* Hidden")
            (org-fold-hide-subtree))
          nil
          t)))
    (should (string-match-p "visibletoken" (prin1-to-string body)))
    (should-not
     (string-match-p "hiddentoken" (prin1-to-string body)))))

(ert-deftest org-texmacs-standard-context-duplicate-target-follows-org
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* Same\n[[*Same]]\n* Same\nTarget.\n")
    (let ((org-export-use-babel nil)
          actual
          (query (symbol-function 'org-export-resolve-fuzzy-link)))
      (cl-letf (((symbol-function 'org-export-resolve-fuzzy-link)
                 (lambda (link info &rest types)
                   (let ((target (apply query link info types)))
                     (setq actual
                           (org-element-property :begin target))
                     target))))
        (let* ((input (org-texmacs--standard-consume 'input))
               (resolution (org-texmacs-input-resolution input))
               (target
                (cdar (org-texmacs-resolution-targets resolution))))
          (should (= actual (org-element-property :begin target)))
          (should
           (cdr
            (assq
             target (org-texmacs-resolution-labels resolution)))))))))

(ert-deftest
    org-texmacs-standard-context-external-footnotes-and-repeat
    ()
  (dolist (scope '(full subtree narrow))
    (let*
        ((body
          (org-texmacs-test--standard-body
           "* Selected\nNote[fn:n] repeated[fn:n], anonymous[fn::Anon].\n* Other\n\n[fn:n] externaldefinition.\n"
           (lambda ()
             (goto-char (point-min))
             (when (eq scope 'narrow)
               (narrow-to-region
                (point-min)
                (save-excursion
                  (search-forward "* Other")
                  (beginning-of-line)
                  (point)))))
           (eq scope 'subtree)))
         (text (prin1-to-string body)))
      (should (string-match-p "externaldefinition" text))
      (should-not (string-match-p "Footnotes" text))
      (should (= (cl-count 'footnote (flatten-tree body)) 2))
      (should (= (cl-count 'reference (flatten-tree body)) 1)))))

(ert-deftest org-texmacs-standard-context-unused-footnotes-are-opaque
    ()
  (should
   (org-texmacs-test--standard-body
    "Body.\n\n[fn:unused] [[missing-target]].\n"))
  ;; Org checks missing definitions during its own preparation, even here.
  (should-error
   (org-texmacs-test--standard-body
    "Body.\n\n[fn:unused] [fn:undefined].\n")
   :type 'user-error))

(ert-deftest
    org-texmacs-standard-context-footnote-flags-and-inline-definition
    ()
  (let ((body
         (org-texmacs-test--standard-body
          "First[fn:n:Inline definition], again[fn:n].\n")))
    (should (= (cl-count 'footnote (flatten-tree body)) 1))
    (should (= (cl-count 'reference (flatten-tree body)) 1)))
  (let ((body
         (org-texmacs-test--standard-body
          "#+OPTIONS: f:nil\nBody[fn:n].\n\n[fn:n] hiddennote.\n")))
    (should-not (memq 'footnote (flatten-tree body)))))

(ert-deftest
    org-texmacs-standard-context-no-legacy-preparation-or-query-replay
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* Heading\nText[fn:n], [[*Heading]].\n\n[fn:n] Note.\n")
    (let ((org-export-use-babel nil))
      (cl-letf (((symbol-function 'org-texmacs--context-merge-options)
                 (lambda (&rest _) (ert-fail "Legacy merge")))
                ((symbol-function 'org-texmacs--context-prune)
                 (lambda (&rest _) (ert-fail "Legacy prune")))
                ((symbol-function
                  'org-texmacs--context-select-subtree)
                 (lambda (&rest _) (ert-fail "Legacy selection")))
                ((symbol-function 'org-texmacs--context-filter-apply)
                 (lambda (&rest _) (ert-fail "Legacy filters")))
                ((symbol-function
                  'org-texmacs--context-footnote-definitions)
                 (lambda (&rest _) (ert-fail "Legacy notes"))))
        (let ((input (org-texmacs--standard-consume 'input)))
          (cl-letf (((symbol-function 'org-export-resolve-fuzzy-link)
                     (lambda (&rest _) (ert-fail "Query replay")))
                    ((symbol-function 'org-export-get-reference)
                     (lambda (&rest _) (ert-fail "Reference replay")))
                    ((symbol-function 'org-export-get-footnote-number)
                     (lambda (&rest _) (ert-fail "Footnote replay"))))
            (should (org-texmacs-document input))
            (should (org-texmacs-document input))))))))

(ert-deftest
    org-texmacs-standard-context-headline-numbering-after-ast-filter
    ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: toc:t\n* Existing\nText.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-adopt
               tree
               (org-element-create
                'headline
                '(:level
                  1
                  :raw-value "Inserted"
                  :title ("Inserted"))))
              tree))))
      (let* ((input (org-texmacs--standard-consume 'input))
             (facts
              (plist-get
               (org-texmacs-input-info input)
               :texmacs-org-query))
             (last (car (last (plist-get facts :headlines)))))
        (should (equal '(2) (nth 3 last)))
        (should
         (string-match-p
          "2 "
          (prin1-to-string
           (org-texmacs-document-body
            (org-texmacs-document input)))))))))
