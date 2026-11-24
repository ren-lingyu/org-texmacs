;;; native-cite.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'oc)
(require 'org)
(require 'org-element)
(require 'ox)
(require 'ox-texmacs)

(require 'org-texmacs-cite-native)

(ert-deftest org-texmacs-native-cite-requests-and-owned-result ()
  (let*
      ((input
        (org-texmacs-test--native-cite-prepare
         "First [cite:@one] followed. Repeat /[cite:@one]/. Multiple [cite:@two; @one].\n\n#+print_bibliography:\nAfter.\n"))
       (requests
        (plist-get
         (org-texmacs-input-info input)
         :texmacs-cite-requests))
       (ready (org-texmacs-test--native-cite-fill input))
       (body (org-texmacs-test--native-cite-lower ready)))
    (should (= 4 (length requests)))
    (should-error
     (org-texmacs-test--native-cite-lower input)
     :type 'org-texmacs-document-error)
    (should (equal body (org-texmacs-test--native-cite-lower ready)))
    (should (memq 'cite (flatten-tree body)))
    (should (memq 'bib-list (flatten-tree body)))
    (should
     (< (string-search "First" (prin1-to-string body))
        (string-search "Mock one" (prin1-to-string body))))
    (should
     (< (string-search "Mock one" (prin1-to-string body))
        (string-search "After" (prin1-to-string body))))
    (dolist (pair
             (plist-get
              (org-texmacs-input-info ready)
              :texmacs-cite-requests))
      (should
       (org-element-map
        (org-texmacs-input-ast ready)
        t
        (lambda (node) (eq node (car pair)))
        nil
        t
        nil
        t))
      (should (eq pair (assq (car pair) requests))))
    (should
     (eq
      requests
      (plist-get
       (org-texmacs-input-info ready)
       :texmacs-cite-requests)))
    (should-not (org-texmacs-input-bibliography input))
    (should-not
     (plist-get
      (org-texmacs-input-info input)
      :texmacs-bibliography-output))))

(ert-deftest
    org-texmacs-native-cite-real-transaction-and-positionless-carriers
    ()
  (let ((bridge (symbol-function 'org-texmacs--standard-input))
        (org-export-before-processing-functions nil)
        (org-export-filter-parse-tree-functions nil)
        (processed 0)
        (filtered 0)
        captured)
    (push (lambda (_) (cl-incf processed))
          org-export-before-processing-functions)
    (push (lambda (tree _backend _info)
            (cl-incf filtered)
            tree)
          org-export-filter-parse-tree-functions)
    (cl-letf (((symbol-function 'org-texmacs--standard-input)
               (lambda (info state)
                 (setq captured
                       (plist-get info :texmacs-cite-requests))
                 (dolist (pair captured)
                   (org-element-put-property (car pair) :begin nil)
                   (org-element-put-property (car pair) :end nil))
                 (funcall bridge info state)))
              (org-texmacs-test--native-cite-fulfiller
               #'org-texmacs-test--native-cite-fill))
      (let ((input
             (org-texmacs-test--native-cite-prepare
              "Text [cite:@one] next.\n#+print_bibliography:\n")))
        (should (= processed 1))
        (should (= filtered 1))
        (should (= 1 (org-element-post-blank (caar captured))))
        (let ((body (org-texmacs-test--native-cite-lower input)))
          (org-element-put-property
           (caar captured)
           :prefix '("Changed"))
          (setcar (plist-get (cdar captured) :keys) "two")
          (should
           (equal
            body (org-texmacs-test--native-cite-lower input))))))))

(ert-deftest org-texmacs-native-cite-excluded-and-filtered-requests ()
  (dolist (scope '(nil subtree visible))
    (let*
        ((org-export-filter-parse-tree-functions
          (list
           (lambda (tree _backend _info)
             (org-element-map
              tree 'citation-reference
              (lambda (node)
                (when (equal "one" (org-element-property :key node))
                  (org-element-put-property node :key "two"))))
             (org-element-copy tree))))
         (text
          (if scope
              "* Keep\nText [cite:@one].\n#+print_bibliography:\n* Hidden\nExcluded [cite:@missing].\n"
            "Text [cite:@one].\n#+print_bibliography:\n"))
         (input (org-texmacs-test--native-cite-prepare text scope))
         (body
          (org-texmacs-test--native-cite-lower
           (org-texmacs-test--native-cite-fill input))))
      (should (string-search "Mock two" (prin1-to-string body)))
      (should-not (string-search "missing" (prin1-to-string body))))))

(ert-deftest org-texmacs-native-cite-single-reference-detail ()
  (let*
      ((input
        (org-texmacs-test--native-cite-prepare
         "First [cite:@one, chapter 1]. Again [cite:@one p. 7]. Bare [cite:@two; @one].\n#+print_bibliography:\n"))
       (requests
        (plist-get
         (org-texmacs-input-info input)
         :texmacs-cite-requests))
       (ready (org-texmacs-test--native-cite-fill input))
       (body (org-texmacs-test--native-cite-lower ready))
       (text (prin1-to-string body)))
    (should (equal (plist-get (cdar requests) :keys) '("one")))
    (should (equal (plist-get (cdar requests) :detail) "chapter 1"))
    (should (equal (plist-get (cdr (nth 1 requests)) :detail) "p. 7"))
    (should-not (plist-get (cdr (nth 2 requests)) :detail))
    (should
     (string-search "(cite-detail \"one\" \"chapter 1\")" text))
    (should (string-search "(cite-detail \"one\" \"p. 7\")" text))
    (should (string-search "(cite \"two\" \"one\")" text))
    (should (= 2 (length (org-texmacs--bibliography-labels body))))
    (aset (plist-get (cdar requests) :detail) 0 ?X)
    (should
     (equal body (org-texmacs-test--native-cite-lower ready)))))

(ert-deftest org-texmacs-native-cite-unsupported-requests ()
  (dolist
      (text
       '("[cite/t:@one]\n#+print_bibliography:\n"
         "[cite:see; @one]\n#+print_bibliography:\n"
         "[cite:see @one]\n#+print_bibliography:\n"
         "[cite:@one, /chapter/ 1]\n#+print_bibliography:\n"
         "[cite:@one p. 7; @two]\n#+print_bibliography:\n"
         "[cite:@one; @two p. 7]\n#+print_bibliography:\n"
         "[cite:@one; extra]\n#+print_bibliography:\n"
         "[cite:@one,]\n#+print_bibliography:\n"
         "[cite:@one]\n"
         "[cite:@one]\n#+print_bibliography:\n#+print_bibliography:\n"
         "[cite:@one]\n#+print_bibliography: :keyword test\n"))
    (should-error
     (org-texmacs-test--native-cite-prepare text)
     :type 'org-texmacs-document-error))
  (let ((input
         (org-texmacs-test--native-cite-prepare
          "[cite:@missing]\n#+print_bibliography:\n")))
    (should-error
     (org-texmacs-test--native-cite-fill input)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-native-cite-carrier-errors ()
  (dolist (fault '(detached duplicate stale stale-detail))
    (let ((bridge (symbol-function 'org-texmacs--standard-input)))
      (cl-letf (((symbol-function 'org-texmacs--standard-input)
                 (lambda (info state)
                   (let* ((requests
                           (plist-get info :texmacs-cite-requests))
                          (pair (car requests)))
                     (pcase fault
                       ('detached
                        (setcar pair (org-element-copy (car pair))))
                       ('duplicate
                        (plist-put
                         info
                         :texmacs-cite-requests (cons pair requests)))
                       ('stale
                        (setcar (plist-get (cdr pair) :keys) "wrong"))
                       ('stale-detail
                        (plist-put (cdr pair) :detail "chapter 2"))))
                   (funcall bridge info state))))
        (should-error
         (org-texmacs-test--native-cite-prepare
          "[cite:@one, chapter 1]\n#+print_bibliography:\n")
         :type 'org-texmacs-document-error))))
  (should
   (org-texmacs-input-p
    (org-texmacs-test--native-cite-prepare "Plain text.\n"))))

(ert-deftest org-texmacs-native-cite-native-label-and-entry-validation
    ()
  (let* ((input
          (org-texmacs-test--native-cite-prepare
           "[cite:@one]\n#+print_bibliography:\n"))
         (ready (org-texmacs-test--native-cite-fill input))
         (info (org-texmacs-input-info ready))
         (output (plist-get info :texmacs-bibliography-output))
         (sources (org-texmacs-input-bibliography ready))
         (ast (org-texmacs-input-ast ready))
         (before (org-texmacs-test--native-cite-lower ready))
         (external-output (copy-tree output))
         (owned
          (org-texmacs-input-create
           ast
           (plist-put
            (copy-sequence info)
            :texmacs-bibliography-output external-output)
           :bibliography sources)))
    (setcar external-output "wrong-prefix")
    (setcar (nth 3 external-output) 'document)
    (should
     (equal before (org-texmacs-test--native-cite-lower owned)))
    (let* ((prefix-mismatch (copy-tree output))
           (_ (setcar prefix-mismatch "wrong-prefix"))
           (stale
            (org-texmacs-input-create
             ast
             (plist-put
              (copy-sequence info)
              :texmacs-bibliography-output prefix-mismatch)
             :bibliography sources))
           (err
            (should-error
             (org-texmacs-test--native-cite-lower stale)
             :type 'org-texmacs-document-error)))
      (should
       (equal
        (cadr err) "Missing or stale prepared bibliography output")))
    (should-error
     (org-texmacs--bibliography-native-plan
      info (list (concat (car output) "-one")))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-native-cite-empty-and-default-isolation ()
  (let* ((input
          (org-texmacs-test--native-cite-prepare "Plain text.\n"))
         (body (org-texmacs-test--native-cite-lower input)))
    (should-not (memq 'cite (flatten-tree body))))
  (let ((org-cite-export-processors '((texmacs basic))))
    (with-temp-buffer
      (org-mode)
      (insert "Text [cite:@one].\n")
      (should-error
       (org-texmacs--standard-consume 'input)
       :type 'org-texmacs-document-error))
    (should (equal org-cite-export-processors '((texmacs basic))))))

(ert-deftest org-texmacs-native-cite-nested-and-failure-retry ()
  (let ((outer-fill #'identity)
        nested)
    (cl-letf
        ((org-texmacs-test--native-cite-fulfiller
          (lambda (input)
            (unless nested
              (progn
                (setq nested t)
                (should
                 (string-search
                  "Mock two"
                  (prin1-to-string
                   (org-texmacs-test--native-cite-lower
                    (org-texmacs-test--native-cite-prepare
                     "Inner [cite:@two].\n#+print_bibliography:\n"))))))
              (setq nested nil))
            (org-texmacs-test--native-cite-fill
             (funcall outer-fill input)))))
      (let ((body
             (org-texmacs-test--native-cite-lower
              (org-texmacs-test--native-cite-prepare
               "Outer [cite:@one].\n#+print_bibliography:\n"))))
        (should (string-search "Mock one" (prin1-to-string body)))
        (should-not
         (string-search "Mock two" (prin1-to-string body))))))
  (dolist (failure '(error quit))
    (cl-letf ((org-texmacs-test--native-cite-fulfiller
               (lambda (_)
                 (signal failure
                         '("Injected native preparation failure")))))
      (condition-case err
          (progn
            (org-texmacs-test--native-cite-prepare
             "[cite:@one]\n#+print_bibliography:\n")
            (ert-fail "Failure not propagated"))
        ((error quit)
         (should (eq (car err) failure))))))
  (should
   (org-texmacs-input-p
    (org-texmacs-test--native-cite-prepare
     "[cite:@one]\n#+print_bibliography:\n"))))

(ert-deftest org-texmacs-native-cite-supported-inline-contexts ()
  (dolist
      (text
       '("* Heading [cite:@one]\nText.\n#+print_bibliography:\n"
         "Text[fn::Note [cite:@one]].\n#+print_bibliography:\n"
         "Text[fn:note].\n#+print_bibliography:\n[fn:note] Note [cite:@one].\n"
         "| Cell [cite:@one] |\n#+print_bibliography:\n"
         "#+caption: Caption [cite:@one]\n| Cell |\n#+print_bibliography:\n"))
    (let ((body
           (org-texmacs-test--native-cite-lower
            (org-texmacs-test--native-cite-fill
             (org-texmacs-test--native-cite-prepare text)))))
      (should (memq 'cite (flatten-tree body))))))

(ert-deftest org-texmacs-native-cite-region-and-ignore-projection ()
  (let*
      ((input
        (org-texmacs-test--native-cite-prepare
         "Outside [cite:@missing].\n\nKeep region [cite:@one].\n#+print_bibliography:\nOutside tail [cite:@wrong].\n"
         'region))
       (body
        (org-texmacs-test--native-cite-lower
         (org-texmacs-test--native-cite-fill input))))
    (should (string-search "Mock one" (prin1-to-string body)))
    (should-not (string-search "missing" (prin1-to-string body))))
  (let ((bridge (symbol-function 'org-texmacs--standard-input)))
    (cl-letf (((symbol-function 'org-texmacs--standard-input)
               (lambda (info state)
                 (dolist (pair
                          (plist-get info :texmacs-cite-requests))
                   (when (equal
                          (plist-get (cdr pair) :keys) '("missing"))
                     (plist-put
                      info
                      :ignore-list
                      (cons
                       (org-element-parent (car pair))
                       (plist-get info :ignore-list)))))
                 (funcall bridge info state))))
      (let
          ((input
            (org-texmacs-test--native-cite-prepare
             "Keep [cite:@one].\n\nIgnore [cite:@missing].\n\n#+print_bibliography:\n")))
        (should
         (equal
          '("one")
          (plist-get
           (plist-get
            (org-texmacs-input-info input)
            :texmacs-cite-plan)
           :keys)))
        (should
         (org-texmacs-test--native-cite-lower
          (org-texmacs-test--native-cite-fill input)))))))

(ert-deftest org-texmacs-native-cite-filter-inserts-and-deletes ()
  (let ((org-export-filter-parse-tree-functions
         (list
          (lambda (tree _backend _info)
            (let ((old
                   (org-element-map
                    tree 'paragraph #'identity nil t)))
              (org-element-insert-before
               (apply #'org-element-create
                      'paragraph nil
                      (org-element-parse-secondary-string
                       "Added [cite:@two]." '(citation)))
               old)
              (org-element-extract-element old))
            tree))))
    (let ((body
           (org-texmacs-test--native-cite-lower
            (org-texmacs-test--native-cite-fill
             (org-texmacs-test--native-cite-prepare
              "Delete [cite:@missing].\n#+print_bibliography:\n")))))
      (should (string-search "Mock two" (prin1-to-string body)))
      (should-not (string-search "missing" (prin1-to-string body))))))

(ert-deftest org-texmacs-native-cite-sources-own-and-select-entries ()
  (let* ((input
          (org-texmacs-test--native-cite-prepare
           "[cite:@one]\n#+print_bibliography:\n"))
         (info (org-texmacs-input-info input))
         (plan (plist-get info :texmacs-cite-plan))
         (file (car (plist-get plan :files)))
         (title (copy-sequence "One"))
         (used
          (list
           'bib-entry "book" "one"
           (list 'document (list 'bib-field "title" title))))
         (unused '(bib-entry "book" "unused" (document)))
         (sources (list (list file 'document used unused unused)))
         (ready (org-texmacs--input-with-cite-sources input sources))
         (owned (org-texmacs-input-bibliography ready))
         (selected
          (plist-get
           (plist-get
            (org-texmacs-input-info ready)
            :texmacs-cite-plan)
           :entries)))
    (should (eq (cadr selected) (nth 2 (car owned))))
    (aset title 0 ?X)
    (should
     (equal
      (cadr selected)
      '(bib-entry "book" "one" (document (bib-field "title" "One")))))
    (dolist (bad
             (list
              nil
              (list (list file 'concat "Invalid"))
              (list (list file 'document unused))
              (list (list file 'document used used))))
      (should-error
       (org-texmacs--input-with-cite-sources input bad)
       :type 'org-texmacs-document-error)
      (should (eq info (org-texmacs-input-info input)))
      (should (eq plan (plist-get info :texmacs-cite-plan)))
      (should (equal (plist-get plan :entries) '(document)))
      (should-not (org-texmacs-input-bibliography input)))))

(ert-deftest org-texmacs-native-cite-static-labels-and-opaque-text ()
  (let* ((input
          (org-texmacs-test--native-cite-prepare
           "Text [cite:@one].\n\nIsland.\n\n#+print_bibliography:\n"))
         (ast (org-texmacs-input-ast input))
         (paragraphs (org-element-map ast 'paragraph #'identity))
         (fragment (org-element-create 'stm-fragment nil))
         (_ (org-element-set-contents (cadr paragraphs) fragment))
         (with-static
          (org-texmacs-input-create
           ast
           (org-texmacs-input-info input)
           :islands
           (list (cons fragment '(label "org-texmacs-bib-1-one"))))))
    (should
     (equal
      "org-texmacs-bib-2"
      (plist-get
       (plist-get
        (org-texmacs-input-info with-static)
        :texmacs-cite-plan)
       :prefix)))
    (should
     (org-texmacs-test--native-cite-lower
      (org-texmacs-test--native-cite-fill with-static)))))

(ert-deftest org-texmacs-native-cite-direct-standard-text-entry ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+bibliography: /fixtures/references.bib\n#+cite_export: texmacs-native\n"
     "Text [cite:@one].\n#+print_bibliography:\n")
    (let ((source (buffer-string))
          (processing 0)
          (filters 0)
          (org-export-use-babel nil)
          (org-export-before-processing-functions nil)
          (org-export-filter-parse-tree-functions nil))
      (push (lambda (_) (cl-incf processing))
            org-export-before-processing-functions)
      (push (lambda (tree _backend _info)
              (cl-incf filters)
              tree)
            org-export-filter-parse-tree-functions)
      (cl-letf (((symbol-function
                  'org-texmacs--prepared-cite-snapshot)
                 #'identity)
                ((symbol-function 'org-texmacs--prepared-cite-fulfill)
                 #'org-texmacs-test--native-cite-fill)
                ((symbol-function 'org-texmacs--bibliography-collect)
                 (lambda (&rest _)
                   (ert-fail "Source usage recollected")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Fixed data reached worker")))
                ((symbol-function 'org-texmacs-document-serialize)
                 (lambda (document)
                   (should
                    (memq
                     'cite
                     (flatten-tree
                      (org-texmacs-document-body document))))
                   (should
                    (memq
                     'bib-list
                     (flatten-tree
                      (org-texmacs-document-body document))))
                   "Fixture native text")))
        (should
         (equal "Fixture native text" (org-export-as 'texmacs))))
      (should (= processing 1))
      (should (= filters 1))
      (should (equal source (buffer-string))))))

;;; native-cite.el ends here
