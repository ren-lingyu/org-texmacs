;;; native-cite.el --- Native processor ownership regressions -*- lexical-binding: t; -*-

(require 'org-texmacs-cite-native)

(defvar org-texmacs-test--native-cite-fulfiller #'identity)

(defun org-texmacs-test--native-cite-fill (input)
  "Complete INPUT with fixed native data, without reading bibliography files."
  (let* ((plan
          (plist-get
           (org-texmacs-input-info input)
           :texmacs-cite-plan))
         (sources
          (mapcar
           (lambda (file)
             (cons
              file
              '(document
                (bib-entry
                 "book" "one" (document (bib-field "title" "One")))
                (bib-entry
                 "book" "two" (document (bib-field "title" "Two"))))))
           (plist-get plan :files)))
         (prepared (org-texmacs--input-cite-result input sources nil))
         (view
          (plist-get
           (org-texmacs-input-info prepared)
           :texmacs-cite-plan))
         (prefix (plist-get view :prefix))
         (keys (plist-get view :keys))
         (body
          (list
           'bib-list (number-to-string (length keys))
           (cons
            'document
            (cl-loop
             for key in keys for n from 1 collect
             (list
              'concat (list 'bibitem* (number-to-string n))
              (list
               'label (concat prefix "-" key))
              (concat "Mock " key)))))))
    (org-texmacs--input-cite-result
     prepared sources
     (list prefix keys (plist-get view :entries) body))))

(defun org-texmacs-test--native-cite-prepare (text &optional scope)
  "Prepare TEXT in a genuine export, optionally using subtree or visible SCOPE."
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+bibliography: /fixtures/references.bib\n"
     "#+cite_export: texmacs-native plain\n"
     text)
    (when (eq scope 'subtree)
      (goto-char (point-min))
      (re-search-forward "^\\* Keep")
      (beginning-of-line))
    (when (eq scope 'visible)
      (goto-char (point-min))
      (re-search-forward "^\\* Hidden")
      (beginning-of-line)
      (org-fold-hide-subtree))
    (let ((org-export-use-babel nil)
          (source (buffer-string))
          input
          region)
      (when (eq scope 'region)
        (goto-char (point-min))
        (search-forward "Keep region")
        (beginning-of-line)
        (let ((begin (point)))
          (search-forward "Outside tail")
          (beginning-of-line)
          (setq region (cons begin (point)))))
      (cl-letf (((symbol-function
                  'org-texmacs--prepared-cite-snapshot)
                 #'identity)
                ((symbol-function 'org-texmacs--prepared-cite-fulfill)
                 org-texmacs-test--native-cite-fulfiller)
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Mock native preparation started worker"))))
        (setq input
              (if region
                  (org-texmacs-prepare-buffer
                   (current-buffer) nil nil region)
                (org-texmacs--standard-consume
                 'input (eq scope 'subtree) (eq scope 'visible)))))
      (should (equal source (buffer-string)))
      input)))

(defun org-texmacs-test--native-cite-lower (input)
  "Lower INPUT while forbidding native work and source citation collection."
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _)
               (ert-fail "Pure citation lowering started worker")))
            ((symbol-function 'org-texmacs--worker-call)
             (lambda (&rest _)
               (ert-fail "Pure citation lowering called worker")))
            ((symbol-function 'insert-file-contents)
             (lambda (&rest _)
               (ert-fail "Pure citation lowering read file")))
            ((symbol-function 'org-texmacs--bibliography-collect)
             (lambda (&rest _)
               (ert-fail
                "Prepared native citations were recollected"))))
    (org-texmacs-document-body (org-texmacs-document input))))

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
      (should-not (assq (car pair) requests)))
    (aset (car (plist-get (cdar requests) :keys)) 0 ?X)
    (should
     (equal body (org-texmacs-test--native-cite-lower ready)))))

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

(ert-deftest org-texmacs-native-cite-unsupported-requests ()
  (dolist
      (text
       '("[cite/t:@one]\n#+print_bibliography:\n"
         "[cite:see; @one]\n#+print_bibliography:\n"
         "[cite:@one p. 7]\n#+print_bibliography:\n"
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
  (dolist (fault '(detached duplicate stale))
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
                        (setcar
                         (plist-get (cdr pair) :keys) "wrong"))))
                   (funcall bridge info state))))
        (should-error
         (org-texmacs-test--native-cite-prepare
          "[cite:@one]\n#+print_bibliography:\n")
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
         (before (org-texmacs-test--native-cite-lower ready)))
    (let ((malformed (copy-tree output)))
      (setcar malformed "wrong-prefix")
      (should-error
       (org-texmacs-test--native-cite-lower
        (org-texmacs--input-cite-result ready sources malformed))
       :type 'org-texmacs-document-error))
    (let ((duplicates (copy-tree sources)))
      (setcdr
       (cdar duplicates)
       (append
        (cdr (cdar duplicates)) (list (cadr (cdar duplicates)))))
      (should-error
       (org-texmacs--input-cite-result ready duplicates output)
       :type 'org-texmacs-document-error))
    (should-error
     (org-texmacs--bibliography-native-plan
      info (list (concat (car output) "-one")))
     :type 'org-texmacs-document-error)
    (let ((copy
           (org-texmacs--input-cite-result ready sources output)))
      (setcdr (cdar sources) nil)
      (should
       (equal before (org-texmacs-test--native-cite-lower copy))))))

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

(ert-deftest org-texmacs-native-cite-result-needs-owned-sources ()
  (let* ((input
          (org-texmacs-test--native-cite-prepare
           "[cite:@one]\n#+print_bibliography:\n"))
         (ready (org-texmacs-test--native-cite-fill input))
         (output
          (plist-get
           (org-texmacs-input-info ready)
           :texmacs-bibliography-output)))
    (should-error
     (org-texmacs--input-cite-result input nil output)
     :type 'org-texmacs-document-error)
    (should-error
     (org-texmacs--input-cite-result input nil '(invalid))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-native-cite-static-labels-and-opaque-text ()
  (let* ((input
          (org-texmacs-test--native-cite-prepare
           "Text [cite:@one].\n\nIsland.\n\n#+print_bibliography:\n"))
         (ast (org-texmacs-input-ast input))
         (paragraphs (org-element-map ast 'paragraph #'identity))
         (with-static
          (org-texmacs-input-create
           ast (org-texmacs-input-info input)
           :islands
           (list
            (cons
             (car (org-element-contents (cadr paragraphs)))
             '(label "org-texmacs-bib-1-one"))))))
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
