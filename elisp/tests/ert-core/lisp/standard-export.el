;;; standard-export.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'oc)
(require 'org)
(require 'org-element)
(require 'org-id)
(require 'ox)
(require 'ox-texmacs)

(defun org-texmacs-test--body-hlinks (node)
  "Return (TARGET DESCRIPTION) for every hlink node in structural NODE."
  (cond
   ((stringp node)
    nil)
   ((and (consp node) (eq (car node) 'hlink))
    (cons
     (list (nth 2 node) (nth 1 node))
     (org-texmacs-test--body-hlinks (nth 1 node))))
   ((consp node)
    (cl-mapcan #'org-texmacs-test--body-hlinks (cdr node)))
   (t
    nil)))

(defun org-texmacs-test--assert-unavailable-id-link (input expected)
  "Assert INPUT owns an unavailable ID link with visible EXPECTED text."
  (let* ((query
          (plist-get
           (org-texmacs-input-info input)
           :texmacs-org-query))
         (links
          (org-element-map
           (org-texmacs-input-ast input) 'link #'identity))
         (unavailable (plist-get query :unavailable-links)))
    (should (= (length unavailable) 1))
    (should (memq (car unavailable) links))
    (should
     (equal (org-element-property :type (car unavailable)) "id"))
    (should-not (plist-get query :external-files))
    (should-not (plist-get query :targets))
    (cl-letf (((symbol-function 'org-export-resolve-id-link)
               (lambda (&rest _)
                 (ert-fail "Requeried unavailable ID")))
              ((symbol-function 'org-id-find)
               (lambda (&rest _) (ert-fail "Requeried ID database")))
              ((symbol-function 'org-texmacs--worker-call)
               (lambda (&rest _)
                 (ert-fail "Fallback started a worker"))))
      (let* ((document (org-texmacs-document input))
             (body (org-texmacs-document-body document)))
        (should (member expected (flatten-tree body)))
        (should-not (org-texmacs-test--body-hlinks body))
        (should-not (memq 'reference (flatten-tree body)))
        (should-not (org-texmacs-document-file-paths document))
        (should (equal document (org-texmacs-document input)))))))

(defun org-texmacs-test--file-target-leaves (document)
  "Return the target leaf at each file provenance path in DOCUMENT."
  (mapcar
   (lambda (path)
     (let ((node (org-texmacs-document-body document)))
       (dolist (index (butlast path))
         (setq node (nth (1+ index) node)))
       (should (equal (car (last path)) 1))
       (should (eq (car node) 'hlink))
       (should (= (length node) 3))
       (should (stringp (nth 2 node)))
       (nth 2 node)))
   (org-texmacs-document-file-paths document)))

(defun org-texmacs-test--register-id-locations (alist)
  "Install isolated org-id-locations from ALIST of (FILE . IDS)."
  (setq org-id-locations
        (org-id-alist-to-hash
         (mapcar
          (lambda (entry)
            (cons
             (abbreviate-file-name (file-truename (car entry)))
             (copy-sequence (cdr entry))))
          alist)))
  (setq org-id-files
        (mapcar
         (lambda (entry)
           (abbreviate-file-name (file-truename (car entry))))
         alist)))

(defmacro org-texmacs-test--with-id-files (source-text &rest body)
  "Create isolated source/target Org files and register target IDs.
SOURCE-TEXT becomes notes/source/source.org; notes/target/target.org carries a
file-level ID and a headline ID.  BODY sees `source', `target', `directory' and
`source-text' bound.  org-id-locations/org-id-locations-file/org-id-files and
the related tracking/scan state are isolated for the dynamic extent, so
fixtures never touch a user knowledge base."
  (declare (indent 1) (debug t))
  `(let*
       ((directory (make-temp-file "org-texmacs-id-" t))
        (source
         (expand-file-name "notes/source/source.org" directory))
        (target
         (expand-file-name "notes/target/target.org" directory))
        (source-text ,source-text)
        (org-id-locations nil)
        (org-id-locations-file (expand-file-name "ids" directory))
        (org-id-files nil)
        ;; org-id-find's unresolved fallback may call
        ;; org-id-update-id-locations; allow that scan but keep every
        ;; input private (nil agenda/extra, isolated files and locations).
        (org-id-track-globally t)
        (org-id--locations-checksum nil)
        (org-id-extra-files nil)
        (org-agenda-files nil)
        (org-export-use-babel nil))
     (unwind-protect
         (progn
           (make-directory (file-name-directory source) t)
           (make-directory (file-name-directory target) t)
           (let ((coding-system-for-write 'utf-8-unix))
             (write-region
              ":PROPERTIES:\n:ID: target-file-id\n:END:\n#+TITLE: Target\n\n* Target headline\n:PROPERTIES:\n:ID: target-headline-id\n:END:\n"
              nil
              target
              nil
              'silent)
             (write-region source-text nil source nil 'silent))
           (org-texmacs-test--register-id-locations
            (list
             (cons target '("target-file-id" "target-headline-id"))))
           ,@body)
       (delete-directory directory t))))

(ert-deftest org-texmacs-standard-export-script-options-final-ast ()
  (dolist (policy '(t {} nil))
    (dolist (late '(nil t))
      (with-temp-buffer
        (org-mode)
        (insert
         (format
          "#+OPTIONS: toc:nil title:nil author:nil date:nil ^:%s\n"
          policy)
         "Before x_i^2 y^{a_b} after.\n")
        (let* ((org-export-use-babel nil)
               (source (buffer-string))
               (calls 0)
               (org-export-filter-parse-tree-functions
                (and late
                     (list
                      (lambda (tree _backend _info)
                        (cl-incf calls)
                        (org-element-set-contents
                         (org-element-map
                          tree 'paragraph #'identity nil t)
                         "Before x"
                         (org-element-create 'subscript nil "i")
                         (org-element-create 'superscript nil "2")
                         " y"
                         (org-element-create
                          'superscript
                          '(:use-brackets-p t)
                          "a"
                          (org-element-create 'subscript nil "b"))
                         " after.\n")
                        tree))))
               (input (org-texmacs--standard-consume 'input))
               (body
                (org-texmacs-document-body
                 (org-texmacs-document input)))
               (sub
                (org-texmacs-test--caption-inline-footnote-nodes
                 body 'rsub))
               (sup
                (org-texmacs-test--caption-inline-footnote-nodes
                 body 'rsup))
               (text
                (apply #'concat
                       (cl-remove-if-not
                        #'stringp (flatten-tree body)))))
          (should
           (plist-member
            (org-texmacs-input-info input)
            :with-sub-superscript))
          (should
           (eq
            policy
            (plist-get
             (org-texmacs-input-info input)
             :with-sub-superscript)))
          (should
           (= calls
              (if late
                  1
                0)))
          (should (equal source (buffer-string)))
          (should
           (= (length sub)
              (if (eq policy t)
                  2
                0)))
          (should
           (= (length sup)
              (pcase policy
                ('t 2)
                ('{} 1)
                (_ 0))))
          (should
           (equal
            text
            (pcase policy
              ('t "Before xi2 yab after. ")
              ('{} "Before x_i^2 ya_b after. ")
              (_ "Before x_i^2 y^{a_b} after. ")))))))))

(ert-deftest org-texmacs-standard-export-script-final-info-metadata ()
  (dolist (policy '(t {} nil))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+TITLE: Title x_i^2 y^{a_b}\n#+OPTIONS: toc:nil author:nil date:nil\nBody.\n")
      (let* ((org-export-with-sub-superscripts t)
             (org-export-use-babel nil)
             (org-export-filter-parse-tree-functions
              (list
               (lambda (tree _backend info)
                 (plist-put info :with-sub-superscript policy)
                 tree)))
             (input (org-texmacs--standard-consume 'input))
             (body
              (org-texmacs-document-body
               (org-texmacs-document input))))
        (should
         (= (length
             (org-texmacs-test--caption-inline-footnote-nodes
              body 'rsub))
            (if (eq policy t)
                2
              0)))
        (should
         (= (length
             (org-texmacs-test--caption-inline-footnote-nodes
              body 'rsup))
            (pcase policy
              ('t 2)
              ('{} 1)
              (_ 0))))))))

(ert-deftest org-texmacs-standard-export-entity-options-and-late-nodes
    ()
  (dolist (enabled '(nil t))
    (dolist (late '(nil t))
      (with-temp-buffer
        (org-mode)
        (insert
         (format
          "#+OPTIONS: toc:nil title:nil author:nil date:nil e:%s\n"
          (if enabled
              "t"
            "nil"))
         "Before \\alpha{} \\copy after.\n")
        (let* ((org-export-use-babel nil)
               (calls 0)
               (source (buffer-string))
               (org-export-filter-parse-tree-functions
                (and late
                     (list
                      (lambda (tree _backend _info)
                        (cl-incf calls)
                        (org-element-set-contents
                         (org-element-map
                          tree 'paragraph #'identity nil t)
                         "Before "
                         (org-element-create
                          'entity
                          '(:name
                            "alpha"
                            :utf-8 "α"
                            :latex-math-p t
                            :use-brackets-p t
                            :post-blank 1))
                         (org-element-create
                          'entity
                          '(:name "copy" :utf-8 "©" :post-blank 1))
                         "after.\n")
                        tree))))
               (input (org-texmacs--standard-consume 'input))
               (info (org-texmacs-input-info input))
               (body
                (org-texmacs-document-body
                 (org-texmacs-document input))))
          (should (plist-member info :with-entities))
          (should (eq enabled (plist-get info :with-entities)))
          (should
           (= calls
              (if late
                  1
                0)))
          (should (equal source (buffer-string)))
          (if enabled
              (progn
                (should
                 (member
                  '(math "α")
                  (org-texmacs-test--caption-inline-footnote-nodes
                   body 'math)))
                (should (string-search "©" (prin1-to-string body))))
            (should-not
             (org-texmacs-test--caption-inline-footnote-nodes
              body 'math))
            (should
             (string-search "\\\\alpha{}" (prin1-to-string body)))
            (should
             (string-search "\\\\copy" (prin1-to-string body)))))))))

(ert-deftest
    org-texmacs-standard-export-entity-final-info-and-metadata
    ()
  (dolist (enabled '(nil t))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+TITLE: Title \\alpha\n#+OPTIONS: toc:nil date:nil author:nil\n"
       "Body.\n")
      (let* ((org-export-use-babel nil)
             (org-export-filter-parse-tree-functions
              (list
               (lambda (tree _backend info)
                 (plist-put info :with-entities enabled)
                 tree)))
             (input (org-texmacs--standard-consume 'input))
             (body
              (org-texmacs-document-body
               (org-texmacs-document input))))
        (if enabled
            (should
             (member
              '(math "α")
              (org-texmacs-test--caption-inline-footnote-nodes
               body 'math)))
          (should-not
           (org-texmacs-test--caption-inline-footnote-nodes
            body 'math))
          (should
           (string-search "\\\\alpha" (prin1-to-string body))))))))

(ert-deftest org-texmacs-standard-export-caption-note-boundary ()
  ;; Stock Org spelling stays literal, in both caption parts.
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+CAPTION[Short[fn::ShortNote]]: Long[fn::LongNote]\n| A |\n")
    (let ((body
           (org-texmacs-document-body
            (org-texmacs-document-from-buffer (current-buffer)))))
      (should-not (memq 'footnote (flatten-tree body)))
      (should (string-search "[fn::LongNote]" (prin1-to-string body)))
      (should
       (string-search "[fn::ShortNote]" (prin1-to-string body)))))
  ;; Positionless filter-created notes fail before STM parsing or numbering.
  ;; Deleted/ignored owners and unused definitions must not be resurrected.
  (dolist (part '(long short))
    (dolist (selection '(keep delete ignore unused-definition))
      (with-temp-buffer
        (org-mode)
        (insert "| $(math \"body\")$ |\n")
        (let ((org-export-use-babel nil)
              (org-export-filter-parse-tree-functions
               (list
                (lambda (tree _backend info)
                  (let* ((table
                          (org-element-map
                           tree 'table #'identity nil t))
                         (note
                          (org-element-create
                           'footnote-reference
                           '(:type inline)
                           "Note")))
                    (org-element-put-property
                     table
                     :caption
                     (list
                      (if (eq part 'long)
                          (cons (list "Long" note) nil)
                        (cons (list "Long") (list "Short" note)))))
                    (pcase selection
                      ('delete (org-element-extract-element table))
                      ('ignore
                       (plist-put info :ignore-list (list table)))
                      ('unused-definition
                       (org-element-extract-element table)
                       (org-element-set-contents
                        tree
                        (org-element-create
                         'footnote-definition
                         '(:label "unused")
                         table))))
                    tree)))))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (ert-fail
                        "Caption validation started native parsing")))
                    ((symbol-function 'org-texmacs--stm-read)
                     (lambda (&rest _)
                       (ert-fail
                        "Caption validation reached the STM reader")))
                    ((symbol-function 'org-export-get-footnote-number)
                     (lambda (&rest _)
                       (ert-fail
                        "Caption validation queried numbering"))))
            (if (eq selection 'keep)
                (let ((failure
                       (should-error
                        (org-texmacs-prepare-buffer (current-buffer))
                        :type 'org-texmacs-document-error)))
                  (should
                   (equal
                    (cadr failure)
                    "Caption footnotes are unsupported in standard source export")))
              (should
               (org-texmacs-input-p
                (org-texmacs-prepare-buffer (current-buffer)))))))))))

(ert-deftest org-texmacs-standard-export-native-body-raw-is-not-source
    ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-map
               tree 'special-block
               (lambda (node)
                 (org-element-set-contents
                  node
                  "(math \""
                  (org-export-raw-string "TARGET")
                  "\")")))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (_source)
                   (ert-fail "Target raw reached STM reader"))))
        (should-error
         (org-texmacs--standard-consume 'input)
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-standard-export-freezes-context-before-stm-parsing
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* Heading\n$(math \"x\")$\n")
    (let* ((formatter (make-symbol "standard-test-headline"))
           (original (lambda (&rest _arguments) "owned-heading"))
           (org-texmacs-format-headline-function formatter)
           (org-export-use-babel nil)
           (reader (symbol-function 'org-texmacs--stm-read))
           (changed (lambda (&rest _arguments) "changed-heading"))
           (calls 0))
      (fset formatter original)
      (unwind-protect
          (cl-letf (((symbol-function 'org-texmacs--stm-read)
                     (lambda (source)
                       (cl-incf calls)
                       (fset formatter changed)
                       (funcall reader source))))
            (let* ((input (org-texmacs--standard-consume 'input))
                   (body
                    (prin1-to-string
                     (org-texmacs-document-body
                      (org-texmacs-document input)))))
              (should (= calls 1))
              (should (eq (symbol-function formatter) changed))
              (should
               (eq
                (plist-get
                 (org-texmacs-input-info input)
                 :texmacs-format-headline-function)
                original))
              (should (string-match-p "owned-heading" body))
              (should-not (string-match-p "changed-heading" body))))
        (fmakunbound formatter)))))

(ert-deftest
    org-texmacs-standard-export-synthetic-text-is-not-a-fragment
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Replace.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-set-element
               (car (org-element-map tree 'paragraph #'identity))
               (org-element-create
                'paragraph nil "(ma" "th \"joined\")"))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (ert-fail
                    (list
                     "Synthetic plain text reached parser" source)))))
        (should-not
         (org-texmacs-input-islands
          (org-texmacs--standard-consume 'input)))))))

(ert-deftest org-texmacs-standard-export-uses-filtered-fragment-source
    ()
  (with-temp-buffer
    (org-mode)
    (insert "$(math \"~original~\")$\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-map
               tree 'stm-fragment
               (lambda (node)
                 (org-element-put-property
                  node
                  :stm-source "(math \"~filtered~\")")))
              tree))))
      (let ((reader (symbol-function 'org-texmacs--stm-read))
            sources)
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (source)
                     (push source sources)
                     (funcall reader source))))
          (should
           (equal
            (cdar
             (org-texmacs-input-islands
              (org-texmacs--standard-consume 'input)))
            '(math "~filtered~")))
          (should (equal sources (list "(math \"~filtered~\")"))))))))

(ert-deftest
    org-texmacs-standard-export-positionless-unsupported-affiliation-fails
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Text.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-set-element
               (car (org-element-map tree 'paragraph #'identity))
               (org-element-create
                'paragraph '(:attr_texmacs ("unsupported")) "Text."))
              tree))))
      (should-error
       (org-texmacs--standard-consume 'document)
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-standard-export-completes-requests-before-model
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "Left $(math \"first\")$ and $(math \"second\")$ right.\n")
    (let ((finish (symbol-function 'org-texmacs--prepared-complete))
          (calls 0)
          (fail-second t)
          complete)
      (cl-letf (((symbol-function 'org-texmacs--prepared-complete)
                 (lambda (input)
                   (should-not (org-texmacs-input-model input))
                   (should-not (org-texmacs-input-islands input))
                   (should
                    (= 2
                       (length
                        (org-texmacs-input-pending-requests input))))
                   (setq complete (funcall finish input))))
                ((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (cl-incf calls)
                   (if (= calls 1)
                       (progn
                         (should (equal source "(math \"first\")"))
                         '(math "first"))
                     (should (equal source "(math \"second\")"))
                     (when fail-second
                       (signal 'org-texmacs-parse-error
                               '("Second request failed")))
                     '(math "second")))))
        (should-error
         (org-texmacs--standard-consume 'input)
         :type 'org-texmacs-parse-error)
        (should (= calls 2))
        (should-not complete)
        (setq
         calls 0
         fail-second nil)
        (let* ((input (org-texmacs--standard-consume 'input))
               (islands (org-texmacs-input-islands input)))
          (should
           (eq
            (org-texmacs-input-model complete)
            (org-texmacs-input-model input)))
          (should-not (org-texmacs-input-pending-requests input))
          (should
           (eq
            islands
            (org-texmacs-model-islands
             (org-texmacs-input-model complete))))
          (should
           (equal
            (mapcar #'cdr islands)
            '((math "first") (math "second")))))))))

(ert-deftest org-texmacs-standard-export-positionless-island-ownership
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Replace this.\n")
    (let (final-node
          final-tree
          (calls 0)
          (org-export-use-babel nil))
      (let ((org-export-filter-parse-tree-functions
             (list
              (lambda (tree _backend _info)
                (setq final-node
                      (org-element-create
                       'paragraph nil "Left "
                       (org-element-create
                        'stm-fragment
                        '(:stm-source "(math \"new\")" :post-blank 1))
                       "right."))
                (org-element-set-element
                 (car
                  (org-element-map tree 'paragraph #'identity))
                 final-node)
                (setq final-tree tree)
                tree))))
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (text)
                     (cl-incf calls)
                     (should (equal text "(math \"new\")"))
                     '(math "new"))))
          (let* ((input (org-texmacs--standard-consume 'input))
                 (island (car (org-texmacs-input-islands input)))
                 (model (org-texmacs-input-model input)))
            (should (= calls 1))
            (should-not (org-element-property :begin final-node))
            (should
             (eq
              (org-texmacs-input-ast input)
              (org-texmacs-model-ast model)))
            (should
             (eq
              (org-texmacs-input-islands input)
              (org-texmacs-model-islands model)))
            (should-not
             (eq
              (org-element-property :parent (car island)) final-node))
            (should
             (memq
              (car island)
              (org-element-contents
               (org-element-property :parent (car island)))))
            (should (= (length (org-element-contents final-node)) 3))
            (org-element-set-contents final-node "External mutation")
            (should (equal (cdr island) '(math "new")))
            (should-not (eq (org-texmacs-input-ast input) final-tree))
            (should (org-texmacs-document input))))))))

(ert-deftest
    org-texmacs-standard-export-logical-exclusion-before-parsing
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Keep.\n\n$(math \"native-invalid\")$\n")
    (let ((org-export-use-babel nil)
          captured
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend info)
              (plist-put
               info
               :ignore-list
               (last (org-element-map tree 'paragraph #'identity)))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (_text) (ert-fail "Ignored STM parsed"))))
        (setq captured (org-texmacs--standard-consume 'input)))
      (should-not (org-texmacs-input-islands captured))
      (should
       (= (length
           (org-element-map
            (org-texmacs-input-ast captured) 'paragraph #'identity))
          1)))))

(ert-deftest
    org-texmacs-standard-export-native-source-property-and-movement
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* One\nOld.\n* Two\nNext.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (let* ((headings
                      (org-element-map tree 'headline #'identity))
                     (old
                      (car
                       (org-element-map tree 'paragraph #'identity)))
                     (block
                      (org-element-create
                       'special-block
                       '(:type
                         "equation*"
                         :texmacs-source "(sqrt \"new\")"))))
                (org-element-extract-element old)
                (org-element-adopt (cadr headings) block))
              tree))))
      (let ((reader (symbol-function 'org-texmacs--stm-read))
            sources)
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (source)
                     (push source sources)
                     (funcall reader source))))
          (let* ((input (org-texmacs--standard-consume 'input))
                 (island (car (org-texmacs-input-islands input))))
            (should (equal (cdr island) '(sqrt "new")))
            (should
             (eq
              (car island)
              (org-element-map
               (org-texmacs-input-ast input)
               'special-block
               #'identity
               nil
               t)))
            (should
             (equal
              (org-element-property
               :raw-value (org-element-property :parent (car island)))
              "Two"))
            (should-not (org-element-property :begin (car island))))
          (should (equal sources (list "(sqrt \"new\")"))))))))

(ert-deftest
    org-texmacs-standard-export-boundary-errors-before-native-effects
    ()
  (dolist (text
           '("$(math \"x\")\n"
             "$(math \"unterminated)\n"
             "$(math (sqrt \"x\"))extra$\n"))
    (with-temp-buffer
      (org-mode)
      (insert text)
      (let ((org-export-use-babel nil))
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (_source)
                     (ert-fail
                      "Invalid boundary reached STM reader"))))
          (should-error
           (org-texmacs--standard-consume 'input)
           :type 'org-texmacs-parse-error))))))

(ert-deftest
    org-texmacs-standard-export-stm-parse-error-and-source-preservation
    ()
  (with-temp-buffer
    (org-mode)
    (insert "$(math \"x\")$\n")
    (let ((source (buffer-string))
          (org-export-use-babel nil))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (_source)
                   (signal 'org-texmacs-parse-error
                           '("Invalid native data")))))
        (should-error
         (org-texmacs--standard-consume 'document)
         :type 'org-texmacs-parse-error))
      (should (equal source (buffer-string)))
      (should-not org-texmacs--standard-transaction)
      (should-not org-texmacs--standard-request))))

(ert-deftest
    org-texmacs-standard-export-fragment-positions-and-spacing
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "* Heading $(math \"heading\")$\n"
     "Before $(math \"body\")$  after.\n\n"
     "[[https://example.org][Link $(math \"link\")$]]\n\n"
     "#+CAPTION: Caption $(math \"caption\")$\n"
     "| $(math \"cell\")$ |\n")
    (let* ((document (org-texmacs--standard-consume 'document))
           (body (org-texmacs-document-body document))
           (trees
            (mapcar
             (lambda (path)
               (let ((node body))
                 (dolist (index path)
                   (setq node (nth (1+ index) node)))
                 node))
             (org-texmacs-document-stm-paths document))))
      (should
       (equal
        trees
        '((math "heading")
          (math "body")
          (math "link")
          (math "cell")
          (math "caption"))))
      (should
       (member
        '(concat "Before " (math "body") " " "after. ")
        (cdr body))))))

(ert-deftest
    org-texmacs-standard-export-keeps-native-body-carriers-literal
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+CAPTION: $(math \"caption\")$\n"
     "#+begin_texmacs\n"
     "(math \"Literal $(sqrt x)$ and incomplete $(\")\n"
     "#+end_texmacs\n")
    (let* ((input (org-texmacs--standard-consume 'input))
           (mapping (org-texmacs-input-islands input)))
      (should
       (equal
        (mapcar #'cdr mapping)
        '((math "Literal $(sqrt x)$ and incomplete $(")
          (math "caption"))))
      (should
       (equal
        (mapcar
         (lambda (entry) (org-element-type (car entry))) mapping)
        '(special-block stm-fragment))))))

(ert-deftest
    org-texmacs-standard-export-fragment-scope-across-backends
    ()
  (require 'ox-ascii)
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "$(math \"outer\")$\n")
    (let ((org-export-use-babel nil)
          (ordinary-registry org-element-all-objects)
          (ordinary-restrictions org-element-object-restrictions)
          (ordinary-cache org-element-use-cache)
          (worker-calls nil)
          nested-output)
      (let ((reader (symbol-function 'org-texmacs--stm-read)))
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (source)
                     (push source worker-calls)
                     (funcall reader source))))
          (let ((org-export-filter-parse-tree-functions
                 (list
                  (lambda (tree backend _info)
                    (pcase backend
                      ('texmacs
                       (should
                        (memq 'stm-fragment org-element-all-objects))
                       (with-temp-buffer
                         (org-mode)
                         (insert "$(math \"other backend\")$\n")
                         (setq nested-output (org-export-as 'ascii))))
                      ('ascii
                       (should
                        (eq
                         ordinary-registry org-element-all-objects))
                       (should
                        (eq
                         ordinary-restrictions
                         org-element-object-restrictions))
                       (should
                        (eq ordinary-cache org-element-use-cache))
                       (should-not
                        org-texmacs--fragment-object-active)
                       (should-not
                        (org-element-map
                         tree 'stm-fragment #'identity nil t))))
                    tree))))
            (should
             (org-texmacs-document-p
              (org-texmacs--standard-consume 'document))))))
      (should (string-match-p "other backend" nested-output))
      (should (equal worker-calls '("(math \"outer\")")))
      (should (eq ordinary-registry org-element-all-objects))
      (should-not org-texmacs--fragment-object-active))))

(ert-deftest
    org-texmacs-standard-export-real-preparation-and-structured-result
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Plain document.\n")
    (let ((calls 0)
          (before 0)
          (trees 0)
          (org-export-use-babel nil))
      (let ((org-export-before-processing-functions
             (list
              (lambda (backend)
                (should (eq backend 'texmacs))
                (cl-incf before))))
            (org-export-filter-parse-tree-functions
             (list
              (lambda (tree _backend _info)
                (cl-incf trees)
                (org-element-adopt
                 tree
                 (org-element-create
                  'section
                  nil
                  (org-element-create 'paragraph nil "Inserted")))
                tree))))
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (_document)
                     (cl-incf calls)
                     "<TeXmacs|probe>")))
          (let ((document (org-texmacs--standard-consume 'document)))
            (should (org-texmacs-document-p document))
            (should
             (string-match-p
              "Inserted"
              (prin1-to-string (org-texmacs-document-body document))))
            (should (= calls 0))
            (should (= before 1))
            (should (= trees 1)))
          (should (equal (org-export-as 'texmacs) "<TeXmacs|probe>"))
          (should (= calls 1)))))))

(ert-deftest
    org-texmacs-standard-export-node-filters-fail-before-effects
    ()
  (dolist (stage '(initial options ast))
    (with-temp-buffer
      (org-mode)
      (insert "Plain document.\n")
      (let* ((calls 0)
             (filter
              (lambda (text _backend _info)
                (cl-incf calls)
                text))
             (org-export-use-babel nil)
             (org-export-filter-paragraph-functions
              (when (eq stage 'initial)
                (list filter)))
             (org-export-filter-options-functions
              (when (eq stage 'options)
                (list
                 (lambda (info _backend)
                   (plist-put
                    info
                    :filter-paragraph (list filter))))))
             (org-export-filter-parse-tree-functions
              (when (eq stage 'ast)
                (list
                 (lambda (tree _backend info)
                   (plist-put info :filter-paragraph (list filter))
                   tree)))))
        (should-error
         (org-export-as 'texmacs)
         :type 'org-texmacs-document-error)
        (should (= calls 0))))))

(ert-deftest org-texmacs-standard-export-final-filters-see-final-text
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Plain document.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-body-functions
           (list
            (lambda (text _backend _info) (concat text " BODY"))))
          (org-export-filter-final-output-functions
           (list
            (lambda (text _backend _info) (concat text " FINAL")))))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document) "NATIVE")))
        (should
         (equal (org-export-as 'texmacs) "NATIVE BODY FINAL"))))))

(ert-deftest
    org-texmacs-standard-export-nested-normal-return-and-errors
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Outer document.\n")
    (let* ((nested nil)
           (returns 0)
           (advice
            (lambda (function &rest args)
              (prog1 (apply function args)
                (cl-incf returns))))
           (org-export-use-babel nil)
           (org-export-filter-parse-tree-functions
            (list
             (lambda (tree _backend _info)
               (unless nested
                 (setq nested t)
                 (unwind-protect
                     (with-temp-buffer
                       (org-mode)
                       (insert "Inner document.\n")
                       (should
                        (org-texmacs-model-p
                         (org-texmacs--standard-consume 'model))))
                   (setq nested nil)))
               tree))))
      (advice-add 'org-export-as :around advice)
      (unwind-protect
          (progn
            (let ((document
                   (org-texmacs--standard-consume 'document)))
              (should
               (string-match-p
                "Outer"
                (prin1-to-string
                 (org-texmacs-document-body document)))))
            (should (= returns 2))
            (let ((org-export-filter-final-output-functions
                   (list (lambda (text _backend _info) text))))
              (should-error
               (org-texmacs--standard-consume 'document)
               :type 'org-texmacs-document-error))
            (should-not org-texmacs--standard-request)
            (should-not org-texmacs--standard-transaction)
            (should
             (org-texmacs-document-p
              (org-texmacs--standard-consume 'document))))
        (advice-remove 'org-export-as advice)))))

(ert-deftest
    org-texmacs-standard-export-target-raw-is-not-literal-text
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Plain document.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions
           (list
            (lambda (tree _backend _info)
              (org-element-map
               tree 'paragraph
               (lambda (node)
                 (org-element-set-contents
                  node (org-export-raw-string "TARGET-CODE"))))
              tree))))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document)
                   (ert-fail "Unsupported raw serialized"))))
        (should-error
         (org-export-as 'texmacs)
         :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-standard-export-source-location-alias-change
    ()
  (dolist (kind '(file directory))
    (with-temp-buffer
      (org-mode)
      (insert "Plain document.\n")
      (let* ((location (copy-sequence "/tmp/source.org"))
             (directory (copy-sequence "/tmp/"))
             (org-export-use-babel nil))
        (setq
         buffer-file-name location
         default-directory directory)
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (_document)
                     (if (eq kind 'file)
                         (aset location 5 ?X)
                       (aset directory 1 ?X))
                     "<TeXmacs|probe>")))
          (should-error
           (org-export-as 'texmacs)
           :type 'org-texmacs-document-error))
        ;; External callback edits are detected, not reverted.
        (should
         (eq
          (if (eq kind 'file)
              (aref buffer-file-name 5)
            (aref default-directory 1))
          ?X))
        (setq buffer-file-name nil)))))

(ert-deftest
    org-texmacs-standard-export-native-consumer-nested-request
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Outer document.\n")
    (let ((org-export-use-babel nil))
      (cl-letf
          (((symbol-function 'org-texmacs-document-serialize)
            (lambda (_document) "NESTED-TEXT"))
           ((symbol-function 'org-texmacs-document-pdf)
            (lambda (_document)
              ;; Native waits can dispatch timers which start new exports.
              (should-not org-texmacs--standard-request)
              (with-temp-buffer
                (org-mode)
                (insert "Inner document.\n")
                (should
                 (equal (org-export-as 'texmacs) "NESTED-TEXT")))
              "%PDF-probe")))
        (should
         (equal
          (org-texmacs--standard-consume 'pdf) "%PDF-probe"))))))

(ert-deftest org-texmacs-standard-export-request-token-is-single-use
    ()
  (dolist (phase '(before after))
    (with-temp-buffer
      (org-mode)
      (insert "Outer document.\n")
      (let* ((active nil)
             (nested 0)
             (org-export-use-babel nil)
             (org-export-filter-options-functions
              (list
               (lambda (info _backend)
                 (should-not
                  (plist-member info :texmacs--result-token))
                 info)))
             (run-nested
              (lambda ()
                (setq active t)
                (unwind-protect
                    (with-temp-buffer
                      (org-mode)
                      (insert "Inner document.\n")
                      (should
                       (equal (org-export-as 'texmacs) "NESTED-TEXT"))
                      (cl-incf nested))
                  (setq active nil))))
             (advice
              (lambda (function &rest args)
                (when (and (not active) (eq phase 'before))
                  (funcall run-nested))
                (prog1 (apply function args)
                  (when (and (not active) (eq phase 'after))
                    (funcall run-nested))))))
        (advice-add 'org-export-as :around advice '((depth . -100)))
        (unwind-protect
            (cl-letf (((symbol-function
                        'org-texmacs-document-serialize)
                       (lambda (_document) "NESTED-TEXT")))
              (should
               (org-texmacs-document-p
                (org-texmacs--standard-consume 'document)))
              (should (= nested 1)))
          (advice-remove 'org-export-as advice))))))

(ert-deftest org-texmacs-standard-export-guards-ignore-other-backends
    ()
  (require 'ox-ascii)
  (with-temp-buffer
    (org-mode)
    (insert "Unrelated source.\n")
    (let ((org-export-use-babel nil)
          (org-export-filter-paragraph-functions
           (list
            (lambda (text _backend _info) (concat text "SENTINEL")))))
      (should (string-match-p "SENTINEL" (org-export-as 'ascii))))))

(ert-deftest org-texmacs-standard-export-body-only-before-processing
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Plain document.\n")
    (let ((org-export-before-processing-functions
           (list
            (lambda
              (_backend)
              (ert-fail "Body-only started preparation")))))
      (should-error
       (org-export-as 'texmacs nil nil t)
       :type 'user-error))))

(ert-deftest org-texmacs-standard-export-incomplete-stm-is-not-literal
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Math $(math \"x\".\n")
    (let ((org-export-use-babel nil))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document)
                   (ert-fail "Incomplete STM serialized as text"))))
        (should-error
         (org-export-as 'texmacs)
         :type 'org-texmacs-parse-error)))))

(ert-deftest
    org-texmacs-standard-export-unsupported-link-visible-content
    ()
  (let ((org-export-use-babel nil)
        (org-link-parameters (copy-tree org-link-parameters)))
    (org-link-set-parameters
     "shell"
     :follow
     (lambda (&rest _) (ert-fail "Followed a shell link"))
     :export
     (lambda (&rest _) (ert-fail "Called a shell export handler")))
    (cl-labels
     ((lower
       (source)
       (with-temp-buffer
         (org-mode)
         (insert
          "#+OPTIONS: toc:nil title:nil author:nil date:nil\n\n"
          source)
         (org-texmacs-document-from-buffer (current-buffer))))
      (visible-text
       (body)
       (apply #'concat
              (cl-remove-if-not #'stringp (flatten-tree body)))))
     (let*
         ((document
           (lower
            "A [[shell:echo][*Important* note]] [[shell:echo]] B.\n"))
          (plain (lower "A *Important* note shell:echo B.\n"))
          (body (org-texmacs-document-body document))
          (expected (org-texmacs-document-body plain)))
       (should (equal (visible-text body) (visible-text expected)))
       (should
        (equal
         (org-texmacs-test--caption-inline-footnote-nodes
          body 'strong)
         '((strong "Important"))))
       (should-not (org-texmacs-test--body-hlinks body))
       (should-not (org-texmacs-document-file-paths document))))))

(ert-deftest org-texmacs-standard-export-resolves-external-id-links ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "* Local headline\n:PROPERTIES:\n:ID: source-local-id\n:END:\n\n"
       "Local [[id:source-local-id][Local]].\n\n"
       "Local [[id:source-local-id]].\n\n"
       "External [[id:target-file-id][File target]].\n\n"
       "External [[id:target-headline-id][Headline target]].\n\n"
       "Formatted [[id:target-file-id][*Target* document]].\n\n"
       "Bare [[id:target-file-id]].\n\n"
       "File [[file:../target/target.org][Explicit file target]].\n")
    (with-temp-buffer
      (org-mode)
      (insert source-text)
      (setq
       buffer-file-name source
       default-directory (file-name-directory source))
      (let* ((document
              (org-texmacs-document-from-buffer (current-buffer)))
             (hlinks
              (org-texmacs-test--body-hlinks
               (org-texmacs-document-body document))))
        ;; External file-level and headline IDs lower to the same file target.
        (should
         (member '("../target/target.org" "File target") hlinks))
        (should
         (member '("../target/target.org" "Headline target") hlinks))
        ;; Structured descriptions are preserved, not flattened to text.
        (should
         (cl-some
          (lambda (hlink)
            (and (equal (car hlink) "../target/target.org")
                 (consp (cadr hlink))
                 (member 'strong (flatten-tree (cadr hlink)))))
          hlinks))
        ;; Bare external ID displays the resolved path.
        (should
         (member
          '("../target/target.org" "../target/target.org") hlinks))
        ;; Ordinary file link shares the same file target.
        (should
         (member
          '("../target/target.org" "Explicit file target") hlinks))
        ;; Internal ID link still produces a reference-based hlink.
        (should
         (cl-some
          (lambda (hlink)
            (and (equal (cadr hlink) "Local")
                 (stringp (car hlink))
                 (string-prefix-p "#org-texmacs-" (car hlink))))
          hlinks))
        ;; External targets carry file provenance.
        (should
         (= (length (org-texmacs-document-file-paths document)) 5))
        (dolist (path (org-texmacs-document-file-paths document))
          (should (consp path)))
        ;; Every provenance path names the matching hlink target leaf.
        (should
         (equal
          (org-texmacs-test--file-target-leaves document)
          (list
           "../target/target.org"
           "../target/target.org"
           "../target/target.org"
           "../target/target.org"
           "../target/target.org")))))))

(ert-deftest
    org-texmacs-standard-export-preserves-external-id-identity
    ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "A [[id:target-file-id][first]].\n"
       "B [[id:target-file-id][second]].\n")
    (with-temp-buffer
      (org-mode)
      (insert source-text)
      (setq
       buffer-file-name source
       default-directory (file-name-directory source))
      (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
             (links
              (org-element-map
               (org-texmacs-input-ast input) 'link
               (lambda (link)
                 (and (equal
                       (org-element-property
                        :path link)
                       "target-file-id")
                      link)))))
        (should (= (length links) 2))
        (dolist (link links)
          (should (equal (org-element-property :type link) "id"))
          (should
           (equal
            (org-element-property :path link) "target-file-id")))
        ;; Both links have an owned external file association.
        (let ((external
               (plist-get
                (plist-get
                 (org-texmacs-input-info input)
                 :texmacs-org-query)
                :external-files)))
          (should (= (length external) 2))
          (dolist (link links)
            (should
             (equal
              (cdr (assq link external))
              "../target/target.org"))))))))

(ert-deftest org-texmacs-standard-export-same-file-id-fallback ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Same\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "* Visible\nSee [[id:hidden-id][Hidden]].\n\n"
       "* Hidden :noexport:\n:PROPERTIES:\n:ID: hidden-id\n:END:\n")
    ;; Register the excluded same-file ID to the source file.
    (org-texmacs-test--register-id-locations
     (append
      (list (cons source '("hidden-id")))
      (list (cons target '("target-file-id" "target-headline-id")))))
    (with-temp-buffer
      (org-mode)
      (insert source-text)
      (setq
       buffer-file-name source
       default-directory (file-name-directory source))
      (org-texmacs-test--assert-unavailable-id-link
       (org-texmacs-prepare-buffer (current-buffer)) "Hidden"))))

(ert-deftest org-texmacs-standard-export-file-level-self-id-fallback
    ()
  (org-texmacs-test--with-id-files
      (concat
       ":PROPERTIES:\n:ID: source-file-id\n:END:\n"
       "#+TITLE: Self\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "See [[id:source-file-id][Self]].\n")
    (org-texmacs-test--register-id-locations
     (append
      (list (cons source '("source-file-id")))
      (list (cons target '("target-file-id" "target-headline-id")))))
    (with-temp-buffer
      (org-mode)
      (insert source-text)
      (setq
       buffer-file-name source
       default-directory (file-name-directory source))
      (org-texmacs-test--assert-unavailable-id-link
       (org-texmacs-prepare-buffer (current-buffer)) "Self"))))

(ert-deftest org-texmacs-standard-export-unresolved-id-fallback ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "See [[id:no-such-id][Missing]].\n")
    (with-temp-buffer
      (org-mode)
      (insert source-text)
      (setq
       buffer-file-name source
       default-directory (file-name-directory source))
      ;; Keep Org's real unresolved fallback, but exclude unrelated visiting
      ;; Org buffers from its database rescan even in interactive ERT.
      (let ((list-buffers (symbol-function 'org-buffer-list)))
        (cl-letf (((symbol-function 'org-buffer-list)
                   (lambda (&rest args)
                     (unless (equal args '(files t))
                       (apply list-buffers args)))))
          (dolist (policy '(nil t mark))
            (let ((org-export-with-broken-links policy))
              (org-texmacs-test--assert-unavailable-id-link
               (org-texmacs-prepare-buffer (current-buffer))
               "Missing"))))))))

(ert-deftest org-texmacs-standard-export-unavailable-internal-links ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil author:nil date:nil\n\n"
     "A [[#gone][*Gone*]] [[missing-target]] B.\n\n"
     "* Present\n:PROPERTIES:\n:CUSTOM_ID: present\n:END:\n"
     "[[#present][Here]]\n")
    (let* ((org-export-with-broken-links nil)
           (input (org-texmacs-prepare-buffer (current-buffer)))
           (query
            (plist-get
             (org-texmacs-input-info input)
             :texmacs-org-query))
           (unavailable (plist-get query :unavailable-links))
           (document (org-texmacs-document input))
           (body (org-texmacs-document-body document))
           (hlinks (org-texmacs-test--body-hlinks body)))
      (should (= (length unavailable) 2))
      (should (= (length hlinks) 1))
      (should (equal (cadar hlinks) "Here"))
      (should (member "Gone" (flatten-tree body)))
      (should (member "missing-target" (flatten-tree body)))
      (should (memq 'strong (flatten-tree body)))
      ;; The backend's handling must not change other Org exports.
      (require 'ox-ascii)
      (should-error (org-export-as 'ascii) :type 'user-error))))

(ert-deftest
    org-texmacs-standard-export-external-id-alt-default-directory
    ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "See [[id:target-file-id][File]].\n")
    (let ((other
           (file-name-as-directory
            (expand-file-name "alt" directory))))
      (make-directory other t)
      (with-temp-buffer
        (org-mode)
        (insert source-text)
        (setq
         buffer-file-name source
         default-directory other)
        (let* ((document
                (org-texmacs-document-from-buffer (current-buffer)))
               (hlinks
                (org-texmacs-test--body-hlinks
                 (org-texmacs-document-body document)))
               (relative (file-relative-name target other)))
          ;; The resolver path is relative to the captured resource base,
          ;; which is the buffer's non-default default-directory.
          (should (member (list relative "File") hlinks))
          (should (equal (expand-file-name relative other) target))
          (should
           (equal
            (org-texmacs-test--file-target-leaves
             document)
            (list relative))))))))

(ert-deftest org-texmacs-standard-export-external-id-hook-base-change
    ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "See [[id:target-file-id][File]].\n")
    (let ((other
           (file-name-as-directory
            (expand-file-name "hook" directory))))
      (make-directory other t)
      (with-temp-buffer
        (org-mode)
        (insert source-text)
        (setq
         buffer-file-name source
         default-directory (file-name-directory source))
        (let ((org-export-process-citations nil)
              (org-export-before-processing-functions
               (list
                (lambda (_backend)
                  ;; Standard hooks may move the export working copy.
                  (setq default-directory other)))))
          (let* ((input (org-texmacs-prepare-buffer (current-buffer)))
                 (external
                  (plist-get
                   (plist-get
                    (org-texmacs-input-info input)
                    :texmacs-org-query)
                   :external-files))
                 (frozen (cdar external)))
            ;; Live preparation interprets the resolver spelling against the
            ;; hook-changed working-copy base and freezes a correct absolute
            ;; path; the wrong captured base is not applied silently.
            (should (file-name-absolute-p frozen))
            (should
             (equal
              (file-truename frozen) (file-truename target)))))))))

(ert-deftest org-texmacs-standard-export-external-id-late-base-change
    ()
  (dolist (return-to-resource '(nil t))
    (org-texmacs-test--with-id-files
        (concat
         "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
         "See [[id:target-file-id][File]] and [cite:@key].\n")
      (let* ((resource (file-name-directory source))
             (collection
              (if return-to-resource
                  (file-name-directory target)
                resource))
             (late
              (if return-to-resource
                  resource
                (file-name-as-directory
                 (expand-file-name "decoy/source" directory))))
             (spelling (file-relative-name target collection))
             (decoy (expand-file-name spelling late))
             (expected
              (if return-to-resource
                  target
                spelling))
             (org-cite--processors
              (copy-sequence org-cite--processors))
             (org-export-process-citations t)
             (org-texmacs-cite-export-processor nil)
             (org-cite-export-processors
              '((t org-texmacs-test-id-base)))
             (org-export-before-processing-functions
              (list
               (lambda
                 (_backend)
                 (setq default-directory collection))))
             (calls 0))
        (make-directory late t)
        (make-directory (file-name-directory decoy) t)
        (with-temp-file decoy
          (insert "#+TITLE: Not the ID target\n"))
        (should (file-exists-p target))
        (should (file-exists-p decoy))
        (should-not (file-equal-p target decoy))
        (org-cite-register-processor
         'org-texmacs-test-id-base
         :cite-styles '((("nil")))
         :export-citation
         (lambda (_citation _style _backend info)
           ;; A real Cite callback runs after Org has collected :id-alist.
           (should
            (equal
             (cdr
              (assoc "target-file-id" (plist-get info :id-alist)))
             spelling))
           (should (equal default-directory collection))
           (cl-incf calls)
           (setq default-directory late)
           ;; A nested standard export must not replace the outer capture.
           (let ((org-export-process-citations nil)
                 (org-export-before-processing-functions nil))
             (with-temp-buffer
               (org-mode)
               (setq default-directory late)
               (insert "[[id:target-file-id][Nested]].\n")
               (should
                (equal
                 (org-texmacs-test--file-target-leaves
                  (org-texmacs-document-from-buffer (current-buffer)))
                 (list (file-relative-name target late))))))
           (org-element-create 'bold nil "Citation")))
        (with-temp-buffer
          (org-mode)
          (insert source-text)
          (setq
           buffer-file-name source
           default-directory resource)
          (let ((document
                 (org-texmacs-document-from-buffer (current-buffer))))
            (should (= calls 1))
            (should
             (equal
              (org-texmacs-test--file-target-leaves
               document)
              (list expected)))
            (should
             (equal
              (expand-file-name expected resource) target))))))))

(ert-deftest org-texmacs-query-external-id-path-rebases-diverged-base
    ()
  (let* ((directory (make-temp-file "org-texmacs-id-base-" t))
         (other
          (file-name-as-directory
           (expand-file-name "other" directory)))
         (target
          (expand-file-name "notes/target/target.org" directory)))
    (unwind-protect
        (let ((default-directory "/unrelated/"))
          ;; A known interpretation base needs no file-existence heuristic.
          (should-not (file-exists-p target))
          (should
           (equal
            target
            (org-texmacs--query-external-id-path
             "../notes/target/target.org" nil directory other)))
          (should
           (equal
            target
            (org-texmacs--query-external-id-path
             target nil directory nil)))
          (should
           (equal
            "notes/target/target.org"
            (org-texmacs--query-external-id-path
             "notes/target/target.org" nil directory directory)))
          (should-not
           (org-texmacs--query-external-id-path
            "../notes/target/target.org" target directory other)))
      (delete-directory directory t))))

(ert-deftest org-texmacs-query-external-id-path-unavailable-base ()
  (let* ((directory (make-temp-file "org-texmacs-id-base-" t))
         (target (expand-file-name "target.org" directory)))
    (unwind-protect
        (progn
          (with-temp-file target
            (insert "#+TITLE: Target\n"))
          (let ((default-directory
                 (file-name-as-directory directory)))
            ;; Existence does not establish where Org collected the path.
            (should-not
             (org-texmacs--query-external-id-path
              "target.org" nil directory nil))))
      (delete-directory directory t))))

(ert-deftest org-texmacs-standard-export-external-id-snapshot-frozen
    ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "See [[id:target-file-id][File]].\n")
    (let* ((input
            (with-temp-buffer
              (org-mode)
              (insert source-text)
              (setq
               buffer-file-name source
               default-directory (file-name-directory source))
              (org-texmacs-prepare-buffer (current-buffer))))
           (external
            (plist-get
             (plist-get
              (org-texmacs-input-info input)
              :texmacs-org-query)
             :external-files))
           (owned-links
            (org-element-map
             (org-texmacs-input-ast input) 'link #'identity))
           (document (org-texmacs-document input))
           (body (copy-tree (org-texmacs-document-body document))))
      ;; The association key is the final owned AST link node.
      (should (= (length external) 1))
      (should (memq (caar external) owned-links))
      ;; Later global state changes and repeated lowering cannot requery Org
      ;; or the ID database, start a worker, or change the frozen target.
      (cl-letf (((symbol-function 'org-export-resolve-id-link)
                 (lambda (&rest _)
                   (ert-fail "External ID resolver requery")))
                ((symbol-function 'org-id-find-id-file)
                 (lambda (&rest _) (ert-fail "ID database requery")))
                ((symbol-function 'org-id-find)
                 (lambda (&rest _) (ert-fail "ID database requery")))
                ((symbol-function 'org-texmacs--worker-call)
                 (lambda (&rest _)
                   (ert-fail "Repeated lowering started a worker"))))
        (org-texmacs-test--register-id-locations
         (list (cons target '("other-id"))))
        (let ((org-texmacs-link-org-files-as-pdf nil)
              (org-texmacs-pdf-file-links-as-absolute t)
              (default-directory "/unrelated/"))
          (should
           (equal
            body
            (org-texmacs-document-body (org-texmacs-document input))))
          (let ((again (org-texmacs-document input)))
            (should (equal body (org-texmacs-document-body again)))
            (should
             (eq
              (org-texmacs-document-link-org-files-as-pdf document)
              (org-texmacs-document-link-org-files-as-pdf again)))
            (should
             (eq
              (org-texmacs-document-pdf-file-links-as-absolute
               document)
              (org-texmacs-document-pdf-file-links-as-absolute
               again)))))))))

(ert-deftest org-texmacs-standard-export-external-id-subtree ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "* Selected\nSee [[id:target-file-id][File]].\n\n* Other\n")
    (with-temp-buffer
      (org-mode)
      (insert source-text)
      (setq
       buffer-file-name source
       default-directory (file-name-directory source))
      (goto-char (point-min))
      (search-forward "* Selected")
      (beginning-of-line)
      (let* ((document
              (org-texmacs-document-from-buffer
               (current-buffer) nil (point))))
        (should
         (member
          '("../target/target.org" "File")
          (org-texmacs-test--body-hlinks
           (org-texmacs-document-body document))))))))

(ert-deftest org-texmacs-standard-export-external-id-subtree-same-file
    ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Source\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "* Selected\nSee [[id:other-id][Other]].\n\n"
       "* Other\n:PROPERTIES:\n:ID: other-id\n:END:\n")
    (org-texmacs-test--register-id-locations
     (list
      (cons target '("target-file-id" "target-headline-id"))
      (cons source '("other-id"))))
    (with-temp-buffer
      (org-mode)
      (insert source-text)
      (setq
       buffer-file-name source
       default-directory (file-name-directory source))
      (goto-char (point-min))
      (search-forward "* Selected")
      (beginning-of-line)
      (org-texmacs-test--assert-unavailable-id-link
       (org-texmacs-prepare-buffer (current-buffer) nil (point))
       "Other"))))

(ert-deftest org-texmacs-standard-export-external-id-include ()
  (org-texmacs-test--with-id-files
      (concat
       "#+TITLE: Main\n#+OPTIONS: toc:nil author:nil date:nil\n\n"
       "#+INCLUDE: \"../part.org\"\n")
    (let ((part (expand-file-name "notes/part.org" directory)))
      (with-temp-file part
        (insert "* Included\nSee [[id:target-file-id][File]].\n"))
      (with-temp-buffer
        (org-mode)
        (insert source-text)
        (setq
         buffer-file-name source
         default-directory (file-name-directory source))
        (let ((document
               (org-texmacs-document-from-buffer (current-buffer))))
          (should
           (member
            '("../target/target.org" "File")
            (org-texmacs-test--body-hlinks
             (org-texmacs-document-body document)))))))))

(ert-deftest org-texmacs-standard-export-native-final-stm-matrix ()
  (org-texmacs-test--with-environment
   (dolist
       (pair
        '(("Left $(math (sqrt \"x\"))$ right.\n" . (math (sqrt "x")))
          ("$(math \"first line\nsecond line\")$\n"
           .
           (math "first line\nsecond line"))
          ("Note[fn::$(math \"first line\nsecond line\")$].\n"
           .
           (math "first line\nsecond line"))
          ("#+TITLE: ~literal~\n$(math (sqrt \"x\"))$\n"
           .
           (math (sqrt "x")))
          ("$(math \"*bold* [[https://example.org][link]] ~literal~\")$\n"
           .
           (math "*bold* [[https://example.org][link]] ~literal~"))
          ("Note[fn::$(math (sqrt \"x\"))$].\n" . (math (sqrt "x")))
          ("#+begin_texmacs\n(document \"a\n  b\")\n#+end_texmacs\n"
           .
           (document "a\n  b"))
          ("#+begin_texmacs\n(document \"*bold* [[https://example.org][link]]\")\n#+end_texmacs\n"
           .
           (document "*bold* [[https://example.org][link]]"))
          ("#+begin_equation\n(frac \"x\" \"y\")\n#+end_equation\n"
           .
           (frac "x" "y"))
          ("#+begin_equation*\n(sqrt \"中文\")\n#+end_equation*\n"
           .
           (sqrt "中文"))))
     (with-temp-buffer
       (org-mode)
       (insert (car pair))
       (let* ((org-export-use-babel nil)
              (before (buffer-string))
              (first (org-texmacs--standard-consume 'input))
              (second (org-texmacs--standard-consume 'input)))
         (should (equal before (buffer-string)))
         (should (= (length (org-texmacs-input-islands first)) 1))
         (should
          (equal (cdar (org-texmacs-input-islands first)) (cdr pair)))
         (should
          (equal
           (cdar (org-texmacs-input-islands second)) (cdr pair)))
         (should-not
          (eq
           (caar (org-texmacs-input-islands first))
           (caar (org-texmacs-input-islands second))))
         (should (org-texmacs-document first)))))))

(ert-deftest
    org-texmacs-standard-export-native-preprocessing-generated-stm
    ()
  (org-texmacs-test--with-environment
   (require 'ob-emacs-lisp)
   (let* ((leaf (expand-file-name "leaf.org" test-directory))
          (middle (expand-file-name "middle.org" test-directory)))
     (with-temp-file leaf
       (insert "$(math (sqrt \"include\"))$\n"))
     (with-temp-file middle
       (insert "#+INCLUDE: \"leaf.org\"\n"))
     (dolist
         (pair
          '(("#+MACRO: m $(math (sqrt \"macro\"))$\n{{{m}}}\n"
             .
             (math (sqrt "macro")))
            ("#+begin_src emacs-lisp :exports results :results raw\n\"$(math (sqrt \\\"babel\\\"))$\"\n#+end_src\n"
             .
             (math (sqrt "babel")))
            ("#+INCLUDE: \"middle.org\"\n"
             .
             (math (sqrt "include")))))
       (with-temp-buffer
         (org-mode)
         (setq default-directory
               (file-name-as-directory test-directory))
         (insert (car pair))
         (let* ((org-export-use-babel t)
                (org-confirm-babel-evaluate nil)
                (input (org-texmacs--standard-consume 'input)))
           (should
            (equal
             (cdar (org-texmacs-input-islands input)) (cdr pair)))
           (should
            (= (length (org-texmacs-input-islands input)) 1))))))))

(ert-deftest
    org-texmacs-standard-export-native-synthetic-stm-uses-final-ast
    ()
  (org-texmacs-test--with-environment
   (dolist (kind
            '(inline
               native))
     (with-temp-buffer
       (org-mode)
       (insert "$(math \"old\")$\n")
       (let* ((org-export-use-babel nil)
              (org-export-filter-parse-tree-functions
               (list
                (lambda (tree _backend _info)
                  (org-element-set-element
                   (car (org-element-map tree 'paragraph #'identity))
                   (if (eq kind 'inline)
                       (org-element-create
                        'paragraph nil
                        (org-element-create
                         'stm-fragment
                         '(:stm-source "(math (sqrt \"final\"))")))
                     (org-element-create
                      'special-block
                      '(:type
                        "texmacs"
                        :texmacs-source "(math (sqrt \"final\"))"))))
                  tree)))
              (input (org-texmacs--standard-consume 'input)))
         (should
          (equal
           (cdar (org-texmacs-input-islands input))
           '(math (sqrt "final")))))))))

(ert-deftest
    org-texmacs-standard-export-native-invalid-complete-stm-fails
    ()
  (org-texmacs-test--with-environment
   (dolist
       (text
        '("$(math #t)$\n"
          "#+begin_texmacs\n(math \"x\") (math \"y\")\n#+end_texmacs\n"))
     (with-temp-buffer
       (org-mode)
       (insert text)
       (let ((org-export-use-babel nil)
             (before (buffer-string)))
         (should-error
          (org-texmacs--standard-consume 'input)
          :type 'org-texmacs-error)
         (should (equal before (buffer-string))))))))

;;; standard-export.el ends here
