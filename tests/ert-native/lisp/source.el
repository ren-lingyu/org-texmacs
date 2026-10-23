;;; source.el --- native source regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-ast-filter-native-citation-and-owned-output ()
  (org-texmacs-test--with-worker
    (let* ((sources '(("refs.bib" . "@book{external-key, title={Filter book}, author={Ada Example}, year=2026}")))
           (text "#+bibliography: refs.bib\nA[cite:@managed-uuid].\n#+print_bibliography:\n")
           input expected)
      (with-temp-buffer
        (org-mode) (insert (replace-regexp-in-string "managed-uuid" "external-key" text))
        (let ((org-export-filter-parse-tree-functions nil))
          (setq expected (org-texmacs-document-from-buffer (current-buffer) sources))))
      (with-temp-buffer
        (org-mode) (insert text)
        (goto-char 3) (set-mark 5)
        (let ((before (org-texmacs-test--document-buffer-state (current-buffer)))
              (org-export-filter-parse-tree-functions
               '(org-texmacs-test--ast-filter-remap)))
          (setq input (org-texmacs-prepare-buffer (current-buffer) sources))
          (should (equal before (org-texmacs-test--document-buffer-state (current-buffer))))
          (should (equal (org-element-map (org-texmacs-input-ast input) 'citation-reference
                           (lambda (r) (org-element-property :key r))) '("external-key")))))
      (let* ((document (org-texmacs-document input))
             (session (org-texmacs-session-open)))
        (unwind-protect
            (progn
              (should (equal document expected))
              (org-texmacs-session-set-document session document)
              (should (equal (org-texmacs--session-read session)
                             (org-texmacs-test--native-hex (org-texmacs-document-body expected)))))
          (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-ast-filter-missing-key-after-native-parse ()
  (with-temp-buffer
    (org-mode)
    (insert "#+bibliography: refs.bib\n[cite:@managed-uuid]\n#+print_bibliography:\n")
    (let ((org-export-filter-parse-tree-functions '(org-texmacs-test--ast-filter-remap)) calls)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_text &optional syntax)
                   (push syntax calls)
                   '(document (bib-entry "book" "other" (document)))))
                ((symbol-function 'org-texmacs--bibliography-format)
                 (lambda (&rest _) (ert-fail "Unresolved key reached formatter")))
                ((symbol-function 'org-texmacs--worker-stop)
                 (lambda () (ert-fail "Unresolved key stopped healthy worker"))))
        (should-error (org-texmacs-prepare-buffer (current-buffer) '(("refs.bib" . "@book{other}")))
                      :type 'org-texmacs-document-error)
        (should (equal calls '(bibliography)))))))

(ert-deftest org-texmacs-ast-filter-rejects-non-key-mutations ()
  (dolist
      (mutation
       (list
        (lambda (tree _info) (org-element-copy tree t))
        (lambda (tree _info)
          (let ((p (org-element-map tree 'paragraph #'identity nil t)))
            (org-element-set-contents p "replacement")) tree)
        (lambda (tree _info)
          (org-element-map tree 'citation-reference
            (lambda (r) (org-element-put-property r :parent nil))) tree)
        (lambda (tree _info)
          (org-element-map tree 'citation-reference
            (lambda (r) (org-element-put-property r :begin 0))) tree)
        (lambda (tree _info)
          (org-element-map tree 'citation-reference
            (lambda (r) (org-element-put-property r :prefix '("changed")))) tree)
        (lambda (tree _info)
          (org-element-map tree 'citation-reference
            (lambda (r) (org-element-put-property r :key ""))) tree)
        (lambda (tree _info) (setcar tree 'raw) tree)
        (lambda (tree _info) (setcdr (last tree) tree) tree)
        (lambda (tree _info)
          (org-element-map tree 'special-block
            (lambda (b) (aset (org-element-property :type b) 0 ?X))) tree)
        (lambda (tree _info)
          (org-element-map tree 'paragraph
            (lambda (p)
              (let ((leaf (cl-find-if #'stringp (org-element-contents p))))
                (when (and leaf (> (length leaf) 0)) (aset leaf 0 ?X))))) tree)
        (lambda (tree _info) (insert "changed work text") tree)
        (lambda (tree _info) (put-text-property (point-min) (point-max) 'p0 t) tree)
        (lambda (tree _info) (setq-local org-footnote-section "Changed") tree)
        (lambda (tree info) (plist-put info :with-title nil) tree)))
    (with-temp-buffer
      (org-mode)
      (insert "#+bibliography: refs.bib\nText [cite:@managed-uuid].\n"
              "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n#+print_bibliography:\n")
      (let* ((source (current-buffer))
             (before (org-texmacs-test--document-buffer-state source))
             work
             (org-export-filter-parse-tree-functions
              (list (lambda (tree _backend info)
                      (setq work (current-buffer))
                      (funcall mutation tree info)))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) (ert-fail "Invalid filter started worker")))
                  ((symbol-function 'org-texmacs--worker-stop)
                   (lambda () (ert-fail "Invalid filter stopped healthy worker"))))
          (should-error (org-texmacs-prepare-buffer source '(("refs.bib" . "@book{external-key}")))
                        :type 'org-texmacs-document-error))
        (should-not (buffer-live-p work))
        (should (equal before (org-texmacs-test--document-buffer-state source)))))))

(ert-deftest org-texmacs-ast-filter-validates-each-nil-return ()
  (with-temp-buffer
    (org-mode) (insert "Text\n")
    (let* (second
           (org-export-filter-parse-tree-functions
            (list (lambda (tree _backend _info) (setcar tree 'raw) nil)
                  (lambda (tree _backend _info) (setq second t) (setcar tree 'org-data) tree))))
      (should-error (org-texmacs-prepare-buffer (current-buffer))
                    :type 'org-texmacs-document-error)
      (should-not second))))

(ert-deftest org-texmacs-ast-filter-order-nil-and-core-only-backend ()
  (with-temp-buffer
    (org-mode) (insert "Text\n")
    (let* ((registered org-export-registered-backends)
           (org-export-registered-backends
            (cl-remove-if (lambda (b) (eq (org-export-backend-name b) 'texmacs)) registered))
           (registry org-export-registered-backends)
           seen
           (org-export-filter-parse-tree-functions
            (list (lambda (tree backend info)
                    (push 'first seen)
                    (should (eq backend 'texmacs))
                    (should (eq (plist-get info :back-end) (org-export-get-backend backend)))
                    (should (eq (org-element-type tree) 'org-data)) nil)
                  (lambda (tree _backend _info) (push 'second seen) tree))))
      (should (org-texmacs-input-p (org-texmacs-prepare-buffer (current-buffer))))
      (should (equal (nreverse seen) '(first second)))
      (should (eq registry org-export-registered-backends))
      (should-not (org-export-get-backend 'texmacs)))))

(ert-deftest org-texmacs-ast-filter-error-unwinds-context ()
  (with-temp-buffer
    (org-mode) (insert "Text\n")
    (let* ((before (org-texmacs-test--document-buffer-state (current-buffer)))
           (registry org-export-registered-backends)
           work
           (org-export-filter-parse-tree-functions
            (list (lambda (_tree _backend _info)
                    (setq work (current-buffer)) (error "Controlled filter error")))))
      (should-error (org-texmacs-prepare-buffer (current-buffer)))
      (should-not (buffer-live-p work))
      (should (eq registry org-export-registered-backends))
      (should (equal before (org-texmacs-test--document-buffer-state (current-buffer))))
      (let ((org-export-filter-parse-tree-functions nil))
        (should (org-texmacs-input-p (org-texmacs-prepare-buffer (current-buffer))))))))

(ert-deftest org-texmacs-ast-filter-selection-and-restored-footnotes ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "#+bibliography: refs.bib\n* Root\nA[fn:n] [cite:@managed-uuid]\n"
              "#+print_bibliography:\n* Other\n[cite:@outside]\n\n[fn:n] [cite:@managed-uuid]\n")
      (goto-char (point-min)) (search-forward "* Root")
      (let ((org-export-filter-parse-tree-functions '(org-texmacs-test--ast-filter-remap)))
        (let ((input (org-texmacs-prepare-buffer
                      (current-buffer) '(("refs.bib" . "@book{external-key, title={Book}}")) (point))))
          (should (equal (org-element-map (org-texmacs-input-ast input) 'citation-reference
                           (lambda (r) (org-element-property :key r)))
                         '("external-key" "external-key")))
          (should (org-texmacs-document-p (org-texmacs-document input))))))))

(ert-deftest org-texmacs-ast-filter-settings-and-function-wait-checks ()
  (dolist (change '(list function))
    (with-temp-buffer
      (org-mode) (insert "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
      (let* ((source (current-buffer))
             (filter (lambda (tree _backend _info) tree))
             (org-export-filter-parse-tree-functions
              (if (eq change 'list) (list filter) '(org-texmacs-test--ast-filter-wait)))
             (old-function (and (fboundp 'org-texmacs-test--ast-filter-wait)
                                (symbol-function 'org-texmacs-test--ast-filter-wait))))
        (unwind-protect
            (progn
              (fset 'org-texmacs-test--ast-filter-wait filter)
              (cl-letf (((symbol-function 'org-texmacs--worker-request)
                         (lambda (&rest _)
                           (with-current-buffer source
                             (if (eq change 'list)
                                 (setq org-export-filter-parse-tree-functions nil)
                               (fset 'org-texmacs-test--ast-filter-wait
                                     (lambda (_tree _backend _info) nil))))
                           '(math "x"))))
                (should-error (org-texmacs-prepare-buffer source)
                              :type 'org-texmacs-document-error)))
          (if old-function (fset 'org-texmacs-test--ast-filter-wait old-function)
            (fmakunbound 'org-texmacs-test--ast-filter-wait)))))))

(ert-deftest org-texmacs-ast-filter-backend-order-and-snapshot-context ()
  (with-temp-buffer
    (org-mode)
    (setq-local buffer-file-name "/source/input.org")
    (setq-local default-directory "/resource/")
    (insert "#+TITLE: Rich *title*\nText\n")
    (let* (seen
           (backend (org-export-create-backend
                     :name 'texmacs
                     :filters
                     (list (cons :filter-parse-tree
                                 (lambda (tree _backend info)
                                   (push 'developer seen)
                                   (should (equal (plist-get info :input-file) "/source/input.org"))
                                   (should (equal default-directory "/resource/"))
                                   (should (equal (org-element-interpret-data (plist-get info :title))
                                                  "Rich *title*"))
                                   (should-not (plist-get info :bibliography)) tree)))))
           (org-export-registered-backends (cons backend org-export-registered-backends))
           (org-export-filter-parse-tree-functions
            (list (lambda (tree _backend _info) (push 'user seen) tree))))
      (should (org-texmacs-input-p (org-texmacs-prepare-buffer (current-buffer))))
      (should (equal (reverse seen) '(developer user)))
      (should (eq backend (org-export-get-backend 'texmacs))))))

(ert-deftest org-texmacs-ast-filter-nil-return-remaps-keys ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "#+bibliography: refs.bib\n[cite:@managed-uuid]\n#+print_bibliography:\n")
      (let ((org-export-filter-parse-tree-functions
             (list (lambda (tree backend info)
                     (org-texmacs-test--ast-filter-remap tree backend info) nil))))
        (let ((input (org-texmacs-prepare-buffer
                      (current-buffer) '(("refs.bib" . "@book{external-key, title={Book}}")))))
          (should (equal (cadr (plist-get (org-texmacs-input-info input)
                                         :texmacs-bibliography-output)) '("external-key"))))))))

(ert-deftest org-texmacs-ast-filter-rejects-buffer-context-switch ()
  (with-temp-buffer
    (org-mode) (insert "Text\n")
    (let* ((source (current-buffer))
           (before (org-texmacs-test--document-buffer-state source))
           (org-export-filter-parse-tree-functions
            (list (lambda (tree _backend _info) (set-buffer source) tree))))
      (should-error (org-texmacs-prepare-buffer source) :type 'org-texmacs-document-error)
      (should (equal before (org-texmacs-test--document-buffer-state source))))))

(ert-deftest org-texmacs-ast-filter-escaped-tree-cannot-change-owned-preparation ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (insert "#+bibliography: refs.bib\n[cite:@managed-uuid]\n"
              "(math \"x\")\n#+print_bibliography:\n")
      (let* (escaped
             (original-request (symbol-function 'org-texmacs--worker-request))
             (org-export-filter-parse-tree-functions
              (list (lambda (tree backend info)
                      (setq escaped tree)
                      (org-texmacs-test--ast-filter-remap tree backend info)))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest args)
                     (let ((result (apply original-request args)))
                       (org-element-map escaped 'citation-reference
                         (lambda (r) (org-element-put-property r :key "late-mutation")))
                       result))))
          (let ((input (org-texmacs-prepare-buffer
                        (current-buffer) '(("refs.bib" . "@book{external-key, title={Book}}")))))
            (should (equal (org-element-map (org-texmacs-input-ast input) 'citation-reference
                             (lambda (r) (org-element-property :key r))) '("external-key")))
            (should (equal (org-element-map escaped 'citation-reference
                             (lambda (r) (org-element-property :key r))) '("late-mutation")))
            (should (org-texmacs-document-p (org-texmacs-document input)))))))))

(ert-deftest org-texmacs-block-case-native-conversion ()
  (org-texmacs-test--with-worker
    (let (expected-body expected-paths expected-bytes)
      (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
        (with-temp-buffer
          (org-mode)
          (insert (format "#+BEGIN_%s\n" type)
                  "(concat \"MiXeDSentinel \" (math (frac \"1\" \"2\")))\n"
                  "#+END_TEXMACS\n")
          (goto-char (point-min))
          (let* ((state (org-texmacs-test--document-buffer-state (current-buffer)))
                 (input (org-texmacs-prepare-buffer (current-buffer)))
                 (block (org-element-map (org-texmacs-input-ast input)
                          'special-block #'identity nil t))
                 (document (org-texmacs-document input))
                 (bytes (org-texmacs-export-texmacs-from-buffer (current-buffer))))
            (should (equal (org-element-property :type block) type))
            (should (= (length (org-texmacs-input-islands input)) 1))
            (if expected-bytes
                (progn
                  (should (equal (org-texmacs-document-body document) expected-body))
                  (should (equal (org-texmacs-document-stm-paths document) expected-paths))
                  (should (equal bytes expected-bytes)))
              (setq expected-body (org-texmacs-document-body document)
                    expected-paths (org-texmacs-document-stm-paths document)
                    expected-bytes bytes)
              (should (string-match-p "MiXeDSentinel" bytes)))
            (should (equal state (org-texmacs-test--document-buffer-state (current-buffer))))))))))

(ert-deftest org-texmacs-context-option-precedence ()
  (let ((org-export-with-tags nil)
        (org-export-with-priority nil))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-tags t)
      (insert "* Heading :tag:\n")
      (let ((info (org-texmacs-input-info
                   (org-texmacs-prepare-buffer (current-buffer)))))
        (should (eq (plist-get info :with-tags) t))
        (should-not (plist-get info :with-priority)))
      (erase-buffer)
      (insert "#+OPTIONS: tags:nil pri:t\n* Heading :tag:\n")
      (let ((info (org-texmacs-input-info
                   (org-texmacs-prepare-buffer (current-buffer)))))
        (should-not (plist-get info :with-tags))
        (should (eq (plist-get info :with-priority) t))))))

(ert-deftest org-texmacs-context-options-affect-headline-presentation ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: todo:nil pri:t tags:nil toc:nil\n"
            "* TODO [#A] Title :tag:\n")
    (should
     (equal (org-texmacs-document-body
             (org-texmacs-document-from-buffer (current-buffer)))
            '(document (section (concat "[#A]" " " "Title")))))))

(ert-deftest org-texmacs-context-copies-rich-metadata ()
  (let (input)
    (with-temp-buffer
      (org-mode)
      (insert "#+TITLE: A *Bold* title\n"
              "#+AUTHOR: /Name/\n"
              "#+DATE: <2026-09-14>\n"
              "Body\n")
      (setq input (org-texmacs-prepare-buffer (current-buffer))))
    (let* ((info (org-texmacs-input-info input))
           (title (plist-get info :title))
           (author (plist-get info :author))
           (date (plist-get info :date))
           (document (org-texmacs-document input)))
      (should (equal (mapcar #'org-element-type title) '(plain-text bold plain-text)))
      (should (equal (mapcar #'org-element-type author) '(italic)))
      (should (equal (mapcar #'org-element-type date) '(timestamp)))
      (dolist (value (list title author date))
        (dolist (node value)
          (should (eq (org-element-property :parent node) value))))
      (should (eq (plist-get info :parse-tree) (org-texmacs-input-ast input)))
      (should
       (equal (org-texmacs-document-body document)
              '(document
                (doc-data
                 (doc-title (concat "A " (strong "Bold") " " "title"))
                 (doc-author (author-data (author-name (em "Name"))))
                 (doc-date "<2026-09-14>"))
                (concat "Body ")))))))

(ert-deftest org-texmacs-context-metadata-options-and-provenance ()
  (with-temp-buffer
    (org-mode)
    (insert "#+TITLE: 中 <alpha> (math \"hidden\")\n"
            "#+AUTHOR: Author\n"
            "#+DATE: 2026\n"
            "#+OPTIONS: author:nil\n"
            "Body (math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (source)
                 (should (equal source "(math \"x\")"))
                 '(math "x"))))
      (let ((document (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal (org-texmacs-document-body document)
                '(document
                  (doc-data (doc-title "中 <alpha> (math \"hidden\")")
                            (doc-date "2026"))
                  (concat "Body " (math "x") " "))))
        (should (equal (org-texmacs-document-stm-paths document) '((1 1))))))))

(ert-deftest org-texmacs-context-filters-tasks-before-worker ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: tasks:done toc:nil\n"
            "* TODO Hidden\n"
            "- unsupported list\n"
            "#+begin_texmacs\n(frac \"1\" \"2)\n#+end_texmacs\n"
            "* DONE Kept\nVisible\n")
    (let ((source (buffer-string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Filtered STM reached worker"))))
        (should
         (equal (org-texmacs-document-body
                 (org-texmacs-document-from-buffer (current-buffer)))
                '(document (section (concat (strong "DONE") " " "Kept"))
                           (concat "Visible ")))))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-context-archive-headline-discards-contents ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: arch:headline tags:nil toc:nil\n"
            "* Archived :ARCHIVE:\n"
            "#+begin_texmacs\n(frac \"1\" \"2)\n#+end_texmacs\n"
            "** Hidden child\n"
            "* Open\nVisible\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) (ert-fail "Archived STM reached worker"))))
      (should
       (equal (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              '(document (section "Archived") (section "Open")
                         (concat "Visible ")))))))

(ert-deftest org-texmacs-context-selects-and-excludes-headlines ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: toc:nil\n#+SELECT_TAGS: keep\n#+EXCLUDE_TAGS: drop\nPreamble\n"
            "* Parent\n"
            "** Chosen :keep:\nKept\n"
            "** Rejected :keep:drop:\n"
            "#+begin_texmacs\n(frac \"1\" \"2)\n#+end_texmacs\n"
            "** Sibling\nHidden\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) (ert-fail "Excluded STM reached worker"))))
      (should
       (equal (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              '(document (section "Parent")
                         (subsection (concat "Chosen" " " ":keep:"))
                         (concat "Kept ")))))))

(ert-deftest org-texmacs-context-expands-snapshotted-tag-groups ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-tag-groups-alist '(("group" . ("member"))))
    (insert "#+OPTIONS: toc:nil\n#+SELECT_TAGS: group\n"
            "* Kept :member:\nVisible\n"
            "* Hidden\nInvisible\n")
    (should
     (equal (org-texmacs-document-body
             (org-texmacs-document-from-buffer (current-buffer)))
            '(document (section (concat "Kept" " " ":member:"))
                       (concat "Visible "))))))

(ert-deftest org-texmacs-context-removes-comments ()
  (with-temp-buffer
    (org-mode)
    (insert "Before\n# hidden\n#+begin_comment\nHidden block\n#+end_comment\nAfter\n")
    (should
     (equal (org-texmacs-document-body
             (org-texmacs-document-from-buffer (current-buffer)))
            '(document (concat "Before ") (concat "After "))))))

(ert-deftest org-texmacs-context-does-not-enter-islands ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n"
            "#+SETUPFILE: /must/not/be/read\n"
            "#+begin_comment\nnative\n#+end_comment\n"
            "#+end_texmacs\n")
    (let (request)
      (cl-letf (((symbol-function 'org-file-contents)
                 (lambda (&rest _) (ert-fail "Read an external file")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (source) (setq request source) '(document "opaque"))))
        (let ((result (org-texmacs-document-from-buffer (current-buffer))))
          (should (string-match-p "SETUPFILE" request))
          (should (equal (org-texmacs-document-body result)
                         '(document (document "opaque"))))
          (should (equal (org-texmacs-document-stm-paths result) '((0)))))))))

(ert-deftest org-texmacs-context-rejects-preprocessing-without-reading ()
  (dolist (source '("#+SETUPFILE: /must/not/be/read\nBody\n"
                    "#+INCLUDE: /must/not/be/read\n"
                    "#+BIND: org-export-with-tags nil\n"
                    "#+MACRO: value expansion\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-file-contents)
                 (lambda (&rest _) (ert-fail "Read an external file")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) (ert-fail "Started worker"))))
        (should-error (org-texmacs-prepare-buffer (current-buffer))
                      :type 'org-texmacs-document-error)))))

(ert-deftest org-texmacs-context-rejects-unsupported-options ()
  (dolist (options '("f:nil" "foo:t"))
    (with-temp-buffer
      (org-mode)
      (insert "#+OPTIONS: " options "\nBody\n")
      (should-error (org-texmacs-prepare-buffer (current-buffer))
                    :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-context-file-options-remain-snapshotted ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: todo:nil tags:nil toc:nil\n* TODO Title :tag:\n(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (_source)
                 (setq-local org-export-with-todo-keywords t
                             org-export-with-tags t)
                 '(math "x"))))
      (should
       (equal (org-texmacs-document-body
               (org-texmacs-document-from-buffer (current-buffer)))
              '(document (section "Title") (math "x")))))))

(ert-deftest org-texmacs-fragment-issue10-object-and-delimiter-boundaries ()
  :tags '(issue10)
  (dolist (body '("(math \"~x\") ~tail~"
                  "*bold* (math \"[x]\") [[https://example.org][link]]"
                  "(math\n (frac \"1\" \"2\")) ~literal~"
                  "~(math \"code\")~ (math \"yes\")"
                  "*(math \"bold\")* (math \"yes\")"
                  "[[https://example.org][(math \"link\")]] (math \"yes\")"))
    (with-temp-buffer
      (org-mode) (insert "A[fn::" body "].\n")
      (let ((spans (org-texmacs-fragment-map (point-min) (point-max) #'identity)))
        (should (= (length spans) 1))
        (should-not (string-match-p "code\\|bold\\|link"
                                    (org-texmacs-fragment-span-source (car spans)))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_source) '(math "accepted"))))
        (should (= (length (org-texmacs-document-stm-paths
                            (org-texmacs-document-from-buffer (current-buffer)))) 1)))))
  (with-temp-buffer
    (org-mode) (insert "A[fn::(with \"mode\" \"math\" \"x\")].\n")
    (let ((org-texmacs-fragment-tags '("with")))
      (should (= (length (org-texmacs-fragment-map (point-min) (point-max) #'identity)) 1)))
    (let ((org-texmacs-fragment-tags nil))
      (should-not (org-texmacs-fragment-map (point-min) (point-max) #'identity)))))

(ert-deftest org-texmacs-fragment-issue10-invalid-candidates ()
  :tags '(issue10)
  (dolist (source '("A[fn::(math \"x\" ~)~].\n"
                    "A[fn::(math \"x\"].\n"
                    "A[fn:n:(math \"x\"]. )\n"
                    "A[fn::(math ;comment\n \"x\")].\n"
                    "A[fn::(math \"x]suffix\")].\n"))
    (with-temp-buffer
      (org-mode) (insert source)
      (let ((before (org-texmacs-test--document-buffer-state (current-buffer))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) (ert-fail "Invalid candidate started worker"))))
          (should-error (org-texmacs-fragment-map (point-min) (point-max) #'identity)
                        :type 'org-texmacs-error)
          (should-error (org-texmacs-fragment-at-point 1) :type 'org-texmacs-error)
          (should-error (org-texmacs-document-from-buffer (current-buffer))
                        :type 'org-texmacs-error))
        (should (equal before (org-texmacs-test--document-buffer-state (current-buffer))))))))

(ert-deftest org-texmacs-test-fragment-tree-real-parser ()
  (org-texmacs-test--with-worker
    (dolist (stree '((math (concat "α+" (frac "1" (sqrt "x")) "a\"b\\c"))
                     (math) (math (frac "1"))))
      (with-temp-buffer
        (org-mode)
        (insert "Before " (prin1-to-string stree) " after\n")
        (let* ((span (org-texmacs-test--first-fragment))
               (text (buffer-string))
               (position (point))
               (tick (buffer-modified-tick))
               (tree (org-texmacs-fragment-tree span)))
          (should (eq (org-element-type tree) 'math))
          (should-not (org-element-property :parent tree))
          (should (equal (org-texmacs--org-to-stree tree) stree))
          (org-element-map tree t
            (lambda (node)
              (unless (eq node tree)
                (let ((parent (org-element-property :parent node)))
                  (should parent)
                  (should (memq node (org-element-contents parent)))
                  (should (memq tree (org-element-lineage node)))))))
          (should (equal-including-properties (buffer-string) text))
          (should (= (point) position))
          (should (= (buffer-modified-tick) tick)))))))

(ert-deftest org-texmacs-test-fragment-tree-shares-worker-with-blocks ()
  (org-texmacs-test--with-worker
    (let ((org-element-use-cache t)
          (process nil))
      (with-temp-buffer
        (org-mode)
        (insert "Fragment (math \"x\")\n\n#+begin_texmacs\n(sqrt \"y\")\n#+end_texmacs\n")
        (let* ((span (org-texmacs-test--first-fragment))
               (first (org-texmacs-fragment-tree span)))
          (setq process org-texmacs--worker-process)
          (should (= org-texmacs--worker-request-id 1))
          (let ((second (org-texmacs-fragment-tree span)))
            (should-not (eq first second))
            (should (equal (org-texmacs--org-to-stree first)
                           (org-texmacs--org-to-stree second))))
          (should (= org-texmacs--worker-request-id 2)))
        (let* ((block (org-texmacs-test--first-block))
               (tree (org-texmacs-tree block)))
          (should (equal (org-texmacs--org-to-stree tree) '(sqrt "y")))
          (should (eq tree (org-texmacs-tree block)))
          (should (= org-texmacs--worker-request-id 3))
          (should (eq process org-texmacs--worker-process))))
      (with-temp-buffer
        (org-mode)
        (insert "Other buffer (math (frac \"1\" \"2\"))\n")
        (should (equal (mapcar #'org-texmacs--org-to-stree
                              (org-texmacs-fragment-map (point-min) (point-max)
                                                      #'org-texmacs-fragment-tree))
                       '((math (frac "1" "2")))))
        (should (= org-texmacs--worker-request-id 4))
        (should (eq process org-texmacs--worker-process))))))

(ert-deftest org-texmacs-test-fragment-tree-real-error-and-repair ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      ;; Balanced source reaches the worker, whose stree-shape check rejects
      ;; the numeric child.  This is not a tag-arity validation test.
      (insert "A (math 1) B\n")
      (let ((span (org-texmacs-test--first-fragment)))
        (dotimes (_ 2)
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-parse-error)
          (should (org-texmacs--worker-live-p)))
        (let ((process org-texmacs--worker-process))
          (should (= org-texmacs--worker-request-id 2))
          (goto-char (point-min))
          (search-forward "1")
          (replace-match "\"1\"" t t)
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)
          (should (= org-texmacs--worker-request-id 2))
          (should (equal (org-texmacs--org-to-stree
                          (org-texmacs-fragment-tree (org-texmacs-test--first-fragment)))
                         '(math "1")))
          (should (= org-texmacs--worker-request-id 3))
          (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-test-fragment-default-real-trees ()
  (org-texmacs-test--with-worker
    (let ((process nil)
          (calls 0))
      (dolist (stree org-texmacs-test--fragment-strees)
        (let ((single (prin1-to-string stree)))
          (dolist (source (list single (replace-regexp-in-string " (" "\n (" single t t)))
            (ert-info ((format "%S: %s" (car stree) source))
              (with-temp-buffer
                (org-mode)
                (insert "A " source " Z\n")
                (let* ((span (org-texmacs-test--first-fragment))
                       (text (buffer-string))
                       (tree (org-texmacs-fragment-tree span))
                       (again (org-texmacs-fragment-tree span)))
                  (cl-incf calls 2)
                  (unless process (setq process org-texmacs--worker-process))
                  (should (eq process org-texmacs--worker-process))
                  (should (= calls org-texmacs--worker-request-id))
                  (should (eq (org-element-type tree) (car stree)))
                  (should-not (org-element-property :parent tree))
                  (should-not (eq tree again))
                  (should (equal (org-texmacs--org-to-stree tree) stree))
                  (should (equal (org-texmacs--org-to-stree again) stree))
                  (org-element-map tree t
                    (lambda (node)
                      ;; Empty cell strings carry no text properties.
                      (unless (or (eq node tree) (equal node ""))
                        (let ((parent (org-element-property :parent node)))
                          (should parent)
                          (should (memq node (org-element-contents parent)))
                          (should (memq tree (org-element-lineage node)))))))
                  (let ((leaves (org-element-map tree 'plain-text #'identity))
                        (copies (org-element-map again 'plain-text #'identity)))
                    (cl-mapc (lambda (a b)
                               (unless (equal a "") (should-not (eq a b))))
                             leaves copies))
                  (should-not (text-properties-at 0 (org-texmacs-fragment-span-source span)))
                  (should (equal (buffer-string) text)))))))))))

(ert-deftest org-texmacs-test-fragment-tags-do-not-restrict-blocks ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (let ((org-element-use-cache t)
            (stree '(with "mode" "math" (concat (math "x") (equation* "y")))))
        (insert "Before (math \"a\")\n\n#+begin_texmacs\n"
                (prin1-to-string stree) "\n#+end_texmacs\n\nAfter (align* \"b\")\n")
        (let* ((block (org-texmacs-test--first-block))
               (org-texmacs-fragment-tags nil)
               (tree (org-texmacs-tree block))
               (process org-texmacs--worker-process))
          (should-not (org-texmacs-test--fragment-sources))
          (should (equal (org-texmacs--org-to-stree tree) stree))
          (dolist (tags '(nil ("math") ("with" "math" "equation*" "align*") invalid))
            (let ((org-texmacs-fragment-tags tags))
              (should (eq tree (org-texmacs-tree block)))))
          (should (= org-texmacs--worker-request-id 1))
          (let ((org-texmacs-fragment-tags '("math" "align*")))
            (should (equal (org-texmacs-test--fragment-sources)
                           '("(math \"a\")" "(align* \"b\")")))
            (org-texmacs-fragment-map (point-min) (point-max) #'org-texmacs-fragment-tree))
          (should (eq process org-texmacs--worker-process))
          (should (= org-texmacs--worker-request-id 3))
          (should (eq tree (org-texmacs-tree block))))))))

(ert-deftest org-texmacs-test-fragment-custom-real-error-and-repair ()
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode)
      (let ((org-texmacs-fragment-tags '("custom.tag*")))
        (insert "Before (custom.tag* 1) after\n")
        (let ((span (org-texmacs-test--first-fragment)))
          (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-parse-error)
          (should (org-texmacs--worker-live-p))
          (let ((process org-texmacs--worker-process))
            (goto-char (point-min))
            (search-forward "1")
            (replace-match "\"1\"" t t)
            (should-error (org-texmacs-fragment-tree span) :type 'org-texmacs-error)
            (should (= org-texmacs--worker-request-id 1))
            ;; Unknown tags can round-trip as AST, without proving semantics.
            (should (equal (org-texmacs--org-to-stree
                            (org-texmacs-fragment-tree (org-texmacs-test--first-fragment)))
                           '(custom.tag* "1")))
            (should (eq process org-texmacs--worker-process))
            (should (= org-texmacs--worker-request-id 2))))))))

(ert-deftest org-texmacs-source-location-explicit-buffer-snapshot ()
  (dolist (file '(nil "/source/notes.org"))
    (let (input)
      (with-temp-buffer
        (org-mode)
        (setq buffer-file-name file default-directory "/resources/override/")
        (insert "Text\n")
        (let ((source (current-buffer)))
          (with-temp-buffer
            (setq default-directory "/caller/")
            (setq input (org-texmacs-prepare-buffer source)))))
      (let ((result (org-texmacs-document input)))
        (should (equal (org-texmacs-document-source-file result) file))
        (should (equal (org-texmacs-document-resource-base result)
                       "/resources/override/"))
        (should (equal (org-texmacs-document-body result)
                       '(document (concat "Text "))))))))

(ert-deftest org-texmacs-source-location-indirect-buffer-context ()
  (with-temp-buffer
    (org-mode)
    (setq buffer-file-name "/source/base.org" default-directory "/base/")
    (insert "Text\n")
    (let ((indirect (clone-indirect-buffer nil nil)))
      (unwind-protect
          (with-current-buffer indirect
            (setq default-directory "/indirect/override/")
            (let ((input (org-texmacs-prepare-buffer indirect)))
              (should (equal (org-texmacs-input-source-file input) "/source/base.org"))
              (should (equal (org-texmacs-input-resource-base input)
                             "/indirect/override/"))))
        (kill-buffer indirect)))))

(ert-deftest org-texmacs-source-location-expands-home-during-preparation ()
  (with-temp-buffer
    (org-mode)
    (setq default-directory "~/" buffer-file-name "~/notes.org")
    (insert "Text\n")
    (let* ((home (expand-file-name "~/"))
           (input (org-texmacs-prepare-buffer (current-buffer))))
      (should (equal (org-texmacs-input-source-file input)
                     (concat home "notes.org")))
      (should (equal (org-texmacs-input-resource-base input) home))
      (should (equal default-directory "~/"))
      (should (equal buffer-file-name "~/notes.org"))
      (setq default-directory "/later/")
      (should (equal (org-texmacs-document-resource-base (org-texmacs-document input))
                     home)))))

(ert-deftest org-texmacs-source-location-invalidates-worker-snapshot ()
  (dolist (change '(file directory file-in-place directory-in-place))
    (with-temp-buffer
      (org-mode)
      (setq buffer-file-name (copy-sequence "/source/notes.org")
            default-directory (copy-sequence "/resources/base/"))
      (insert "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
      (let ((source (current-buffer))
            (tick (buffer-chars-modified-tick))
            (before (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (with-current-buffer source
                       (pcase change
                         ('file (setq buffer-file-name "/new/notes.org"))
                         ('directory (setq default-directory "/new/base/"))
                         ('file-in-place (aset buffer-file-name 1 ?X))
                         ('directory-in-place (aset default-directory 1 ?X))))
                     '(math "x"))))
          (let ((failure (should-error
                          (org-texmacs-document-from-buffer source)
                          :type 'org-texmacs-document-error)))
            (should (equal (cadr failure) "Source location changed during conversion"))))
        (should (= tick (buffer-chars-modified-tick)))
        (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-source-location-checks-after-preflight ()
  (with-temp-buffer
    (org-mode)
    (setq default-directory "/resources/base/")
    (insert "#+OPTIONS: toc:nil\n* Title\n")
    (let* ((source (current-buffer))
           (org-texmacs-format-headline-function
            (lambda (&rest _)
              (with-current-buffer source (setq default-directory "/new/base/"))
              "Title")))
      (should-error (org-texmacs-document-from-buffer source)
                    :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-test-tree-real-parser-and-cache ()
  (org-texmacs-test--with-worker
    (let ((org-element-use-cache t))
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_texmacs\n"
                "(with \"mode\" \"math\" (concat \"x+\" (frac \"1\" \"2\")))\n"
                "#+end_texmacs\n")
        (let* ((block (org-texmacs-test--first-block))
               (text (buffer-string))
               (position (point))
               (tick (buffer-chars-modified-tick))
               (tree (org-texmacs-tree block))
               (request-id org-texmacs--worker-request-id)
               (concat-node (nth 2 (org-element-contents tree)))
               (frac-node (nth 1 (org-element-contents concat-node))))
          (should (= request-id 1))
          (should (equal (org-texmacs--org-to-stree tree)
                         '(with "mode" "math" (concat "x+" (frac "1" "2")))))
          (should (eq (org-element-property :parent concat-node) tree))
          (should (eq (org-element-property :parent frac-node) concat-node))
          (dolist (leaf (org-element-contents frac-node))
            (should (eq (org-element-property :parent leaf) frac-node)))
          (should-not (org-element-property :parent tree))
          (should (equal (org-element-map tree '(with concat frac)
                          #'org-element-type)
                         '(with concat frac)))
          (should (eq (org-element-type block) 'special-block))
          (should (equal (buffer-string) text))
          (should (= (point) position))
          (should (= (buffer-chars-modified-tick) tick))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (_source) (ert-fail "Cache hit must not parse again"))))
            (should (eq tree (org-texmacs-tree (org-texmacs-test--first-block)))))
          (should (= request-id org-texmacs--worker-request-id)))))))

(ert-deftest org-texmacs-test-tree-edit-and-error-recovery ()
  (org-texmacs-test--with-worker
    (let ((org-element-use-cache t))
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
        (org-texmacs-tree (org-texmacs-test--first-block))
        (let ((process org-texmacs--worker-process))
          (goto-char (point-min))
          (search-forward "\"2\"")
          (replace-match "\"3\"" t t)
          (let ((block (org-texmacs-test--first-block)))
            (should (eq (org-element-cache-get-key block 'org-texmacs-tree
                                                  org-texmacs--cache-miss)
                        org-texmacs--cache-miss))
            (should (equal (org-texmacs--org-to-stree (org-texmacs-tree block))
                           '(frac "1" "3")))
            (should (= org-texmacs--worker-request-id 2)))
          ;; Remove the closing parenthesis.  Org still has a special block,
          ;; but the strict reader must reject its STM body.
          (goto-char (point-min))
          (search-forward ")")
          (delete-char -1)
          (let ((block (org-texmacs-test--first-block)))
            (dotimes (_ 2)
              (should-error (org-texmacs-tree block) :type 'org-texmacs-parse-error)
              (should (eq (org-element-cache-get-key block 'org-texmacs-tree
                                                    org-texmacs--cache-miss)
                          org-texmacs--cache-miss)))
            (should (= org-texmacs--worker-request-id 4)))
          (insert ")")
          (should (equal (org-texmacs--org-to-stree
                          (org-texmacs-tree (org-texmacs-test--first-block)))
                         '(frac "1" "3")))
          (should (= org-texmacs--worker-request-id 5))
          (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-test-tree-blocks-share-worker ()
  (org-texmacs-test--with-worker
    (let ((org-element-use-cache t))
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n\n"
                "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
        (let* ((first (org-texmacs-tree (org-texmacs-test--first-block)))
               (process org-texmacs--worker-process))
          (goto-char (point-max))
          (search-backward "#+begin_texmacs")
          (should (equal (org-texmacs--org-to-stree (org-texmacs-tree (org-element-at-point)))
                         '(sqrt "x")))
          (should (eq first (org-texmacs-tree (org-texmacs-test--first-block))))
          (should (= org-texmacs--worker-request-id 2))
          (should (eq process org-texmacs--worker-process)))))))

;;; source.el ends here
