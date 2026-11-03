;;; source.el --- native source regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-block-case-native-conversion ()
  (org-texmacs-test--with-worker
   (let (expected-body
         expected-paths
         expected-bytes)
     (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
       (with-temp-buffer
         (org-mode)
         (setq-local org-export-with-author nil)
         (insert
          (format "#+BEGIN_%s\n" type)
          "(concat \"MiXeDSentinel \" (math (frac \"1\" \"2\")))\n"
          "#+END_TEXMACS\n")
         (goto-char (point-min))
         (let* ((state
                 (org-texmacs-test--document-buffer-state
                  (current-buffer)))
                (input (org-texmacs-prepare-buffer (current-buffer)))
                (block
                 (org-element-map
                  (org-texmacs-input-ast input)
                  'special-block
                  #'identity
                  nil
                  t))
                (document (org-texmacs-document input))
                (bytes
                 (org-texmacs-export-texmacs-from-buffer
                  (current-buffer))))
           (should (equal (org-element-property :type block) type))
           (should (= (length (org-texmacs-input-islands input)) 1))
           (if expected-bytes
               (progn
                 (should
                  (equal
                   (org-texmacs-document-body document)
                   expected-body))
                 (should
                  (equal
                   (org-texmacs-document-stm-paths
                    document)
                   expected-paths))
                 (should (equal bytes expected-bytes)))
             (setq
              expected-body (org-texmacs-document-body document)
              expected-paths (org-texmacs-document-stm-paths document)
              expected-bytes bytes)
             (should (string-match-p "MiXeDSentinel" bytes)))
           (should
            (equal
             state
             (org-texmacs-test--document-buffer-state
              (current-buffer))))))))))

(ert-deftest org-texmacs-context-option-precedence ()
  (let ((org-export-with-tags nil)
        (org-export-with-priority nil))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (setq-local org-export-with-tags t)
      (insert "* Heading :tag:\n")
      (let ((info
             (org-texmacs-input-info
              (org-texmacs-prepare-buffer (current-buffer)))))
        (should (eq (plist-get info :with-tags) t))
        (should-not (plist-get info :with-priority)))
      (erase-buffer)
      (insert "#+OPTIONS: tags:nil pri:t\n* Heading :tag:\n")
      (let ((info
             (org-texmacs-input-info
              (org-texmacs-prepare-buffer (current-buffer)))))
        (should-not (plist-get info :with-tags))
        (should (eq (plist-get info :with-priority) t))))))

(ert-deftest org-texmacs-context-options-affect-headline-presentation
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: todo:nil pri:t tags:nil toc:nil\n"
     "* TODO [#A] Title :tag:\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (section (concat "[#A]" " " "Title")))))))

(ert-deftest org-texmacs-context-copies-rich-metadata ()
  (let (input)
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert
       "#+TITLE: A *Bold* title\n"
       "#+AUTHOR: /Name/\n#+OPTIONS: author:t\n"
       "#+DATE: <2026-09-14>\n"
       "Body\n")
      (setq input (org-texmacs-prepare-buffer (current-buffer))))
    (let* ((info (org-texmacs-input-info input))
           (title (plist-get info :title))
           (author (plist-get info :author))
           (date (plist-get info :date))
           (document (org-texmacs-document input)))
      (should
       (equal
        (mapcar #'org-element-type title)
        '(plain-text bold plain-text)))
      (should (equal (mapcar #'org-element-type author) '(italic)))
      (should (equal (mapcar #'org-element-type date) '(timestamp)))
      (dolist (value (list title author date))
        (dolist (node value)
          (should (eq (org-element-property :parent node) value))))
      (should-not (plist-member info :parse-tree))
      (should
       (equal
        (org-texmacs-document-body document)
        '(document
          (doc-data
           (doc-title (concat "A " (strong "Bold") " " "title"))
           (doc-author
            (author-data (author-name (em "Name"))))
           (doc-date "<2026-09-14>"))
          (concat "Body ")))))))

(ert-deftest org-texmacs-context-metadata-options-and-provenance ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+TITLE: 中 <alpha> (math \"hidden\")\n"
     "#+AUTHOR: Author\n"
     "#+DATE: 2026\n"
     "#+OPTIONS: author:nil\n"
     "Body (math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (source)
                 (should (equal source "(math \"x\")"))
                 '(math "x"))))
      (let ((document
             (org-texmacs-document-from-buffer (current-buffer))))
        (should
         (equal
          (org-texmacs-document-body document)
          '(document
            (doc-data
             (doc-title "中 <alpha> (math \"hidden\")")
             (doc-date "2026"))
            (concat "Body " (math "x") " "))))
        (should
         (equal
          (org-texmacs-document-stm-paths document) '((1 1))))))))

(ert-deftest org-texmacs-context-filters-tasks-before-worker ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: tasks:done toc:nil\n"
     "* TODO Hidden\n"
     "- unsupported list\n"
     "#+begin_texmacs\n(frac \"1\" \"2)\n#+end_texmacs\n"
     "* DONE Kept\nVisible\n")
    (let ((source (buffer-string)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Filtered STM reached worker"))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document
            (section
             (concat (strong "DONE") " " "Kept"))
            (concat "Visible ")))))
      (should (equal source (buffer-string))))))

(ert-deftest org-texmacs-context-archive-headline-discards-contents ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: arch:headline tags:nil toc:nil\n"
     "* Archived :ARCHIVE:\n"
     "#+begin_texmacs\n(frac \"1\" \"2)\n#+end_texmacs\n"
     "** Hidden child\n"
     "* Open\nVisible\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Archived STM reached worker"))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document
          (section "Archived")
          (section "Open")
          (concat "Visible ")))))))

(ert-deftest org-texmacs-context-selects-and-excludes-headlines ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\n#+SELECT_TAGS: keep\n#+EXCLUDE_TAGS: drop\nPreamble\n"
     "* Parent\n"
     "** Chosen :keep:\nKept\n"
     "** Rejected :keep:drop:\n"
     "#+begin_texmacs\n(frac \"1\" \"2)\n#+end_texmacs\n"
     "** Sibling\nHidden\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Excluded STM reached worker"))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document
          (section "Parent")
          (subsection
           (concat "Chosen" " " ":keep:"))
          (concat "Kept ")))))))

(ert-deftest org-texmacs-context-standard-tag-selection ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq-local org-tag-groups-alist '(("group" . ("member"))))
    (insert
     "#+OPTIONS: toc:nil\n#+SELECT_TAGS: group\n"
     "* Kept :member:\nVisible\n"
     "* Hidden\nInvisible\n")
    (require 'ox-ascii)
    (should
     (string-search "Invisible" (org-export-as 'ascii nil nil t)))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document
        (section (concat "Kept" " " ":member:"))
        (concat "Visible ")
        (section "Hidden")
        (concat "Invisible "))))))

(ert-deftest org-texmacs-context-removes-comments ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "Before\n# hidden\n#+begin_comment\nHidden block\n#+end_comment\nAfter\n")
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document-from-buffer (current-buffer)))
      '(document (concat "Before ") (concat "After "))))))

(ert-deftest org-texmacs-context-file-options-remain-snapshotted ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: todo:nil tags:nil toc:nil\n* TODO Title :tag:\n(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (_source)
                 (setq-local
                  org-export-with-todo-keywords t
                  org-export-with-tags t)
                 '(math "x"))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))
        '(document (section "Title") (math "x")))))))

(ert-deftest
    org-texmacs-fragment-issue10-object-and-delimiter-boundaries
    ()
  :tags
  '(issue10)
  (dolist
      (body
       '("(math \"~x\") ~tail~"
         "*bold* (math \"[x]\") [[https://example.org][link]]"
         "(math\n (frac \"1\" \"2\")) ~literal~"
         "~(math \"code\")~ (math \"yes\")"
         "*(math \"bold\")* (math \"yes\")"
         "[[https://example.org][(math \"link\")]] (math \"yes\")"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert "A[fn::" body "].\n")
      (let ((spans
             (org-texmacs-fragment-map
              (point-min) (point-max) #'identity)))
        (should (= (length spans) 1))
        (should-not
         (string-match-p
          "code\\|bold\\|link"
          (org-texmacs-fragment-span-source (car spans)))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_source) '(math "accepted"))))
        (should
         (= (length
             (org-texmacs-document-stm-paths
              (org-texmacs-document
               (org-texmacs-test--input-from-model
                (org-texmacs-parse-buffer (current-buffer))))))
            1)))))
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "A[fn::(with \"mode\" \"math\" \"x\")].\n")
    (let ((org-texmacs-fragment-tags '("with")))
      (should
       (= (length
           (org-texmacs-fragment-map
            (point-min) (point-max) #'identity))
          1)))
    (let ((org-texmacs-fragment-tags nil))
      (should-not
       (org-texmacs-fragment-map
        (point-min) (point-max) #'identity)))))

(ert-deftest org-texmacs-fragment-issue10-invalid-candidates ()
  :tags
  '(issue10)
  (dolist (source
           '("A[fn::(math \"x\" ~)~].\n"
             "A[fn::(math \"x\"].\n"
             "A[fn:n:(math \"x\"]. )\n"
             "A[fn::(math ;comment\n \"x\")].\n"
             "A[fn::(math \"x]suffix\")].\n"))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (insert source)
      (let ((before
             (org-texmacs-test--document-buffer-state
              (current-buffer))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Invalid candidate started worker"))))
          (should-error
           (org-texmacs-fragment-map
            (point-min) (point-max) #'identity)
           :type 'org-texmacs-error)
          (should-error
           (org-texmacs-fragment-at-point 1)
           :type 'org-texmacs-error)
          (should-error
           (org-texmacs-document-from-buffer (current-buffer))
           :type 'org-texmacs-error))
        (should
         (equal
          before
          (org-texmacs-test--document-buffer-state
           (current-buffer))))))))

(ert-deftest org-texmacs-test-fragment-tree-real-parser ()
  (org-texmacs-test--with-worker
   (dolist (stree
            '((math (concat "α+" (frac "1" (sqrt "x")) "a\"b\\c"))
              (math) (math (frac "1"))))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert "Before " (prin1-to-string stree) " after\n")
       (let* ((span (org-texmacs-test--first-fragment))
              (text (buffer-string))
              (position (point))
              (tick (buffer-modified-tick))
              (tree (org-texmacs-fragment-tree span)))
         (should (eq (org-element-type tree) 'math))
         (should-not (org-element-property :parent tree))
         (should (equal (org-texmacs--org-to-stree tree) stree))
         (org-element-map
          tree t
          (lambda (node)
            (unless (eq node tree)
              (let ((parent (org-element-property :parent node)))
                (should parent)
                (should (memq node (org-element-contents parent)))
                (should (memq tree (org-element-lineage node)))))))
         (should (equal-including-properties (buffer-string) text))
         (should (= (point) position))
         (should (= (buffer-modified-tick) tick)))))))

(ert-deftest org-texmacs-test-fragment-tree-shares-worker-with-blocks
    ()
  (org-texmacs-test--with-worker
   (let ((org-element-use-cache t)
         (process nil))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert
        "Fragment (math \"x\")\n\n#+begin_texmacs\n(sqrt \"y\")\n#+end_texmacs\n")
       (let* ((span (org-texmacs-test--first-fragment))
              (first (org-texmacs-fragment-tree span)))
         (setq process org-texmacs--worker-process)
         (should (= org-texmacs--worker-request-id 1))
         (let ((second (org-texmacs-fragment-tree span)))
           (should-not (eq first second))
           (should
            (equal
             (org-texmacs--org-to-stree first)
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
       (setq-local org-export-with-author nil)
       (insert "Other buffer (math (frac \"1\" \"2\"))\n")
       (should
        (equal
         (mapcar
          #'org-texmacs--org-to-stree
          (org-texmacs-fragment-map
           (point-min) (point-max) #'org-texmacs-fragment-tree))
         '((math (frac "1" "2")))))
       (should (= org-texmacs--worker-request-id 4))
       (should (eq process org-texmacs--worker-process))))))

(ert-deftest org-texmacs-test-fragment-tree-real-error-and-repair ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     ;; Balanced source reaches the worker, whose stree-shape check rejects
     ;; the numeric child.  This is not a tag-arity validation test.
     (insert "A (math 1) B\n")
     (let ((span (org-texmacs-test--first-fragment)))
       (dotimes (_ 2)
         (should-error
          (org-texmacs-fragment-tree span)
          :type 'org-texmacs-parse-error)
         (should (org-texmacs--worker-live-p)))
       (let ((process org-texmacs--worker-process))
         (should (= org-texmacs--worker-request-id 2))
         (goto-char (point-min))
         (search-forward "1")
         (replace-match "\"1\"" t t)
         (should-error
          (org-texmacs-fragment-tree span)
          :type 'org-texmacs-error)
         (should (= org-texmacs--worker-request-id 2))
         (should
          (equal
           (org-texmacs--org-to-stree
            (org-texmacs-fragment-tree
             (org-texmacs-test--first-fragment)))
           '(math "1")))
         (should (= org-texmacs--worker-request-id 3))
         (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-test-fragment-default-real-trees ()
  (org-texmacs-test--with-worker
   (let ((process nil)
         (calls 0))
     (dolist (stree org-texmacs-test--fragment-strees)
       (let ((single (prin1-to-string stree)))
         (dolist (source
                  (list
                   single
                   (replace-regexp-in-string " (" "\n (" single t t)))
           (ert-info
            ((format "%S: %s" (car stree) source))
            (with-temp-buffer
              (org-mode)
              (setq-local org-export-with-author nil)
              (insert "A " source " Z\n")
              (let* ((span (org-texmacs-test--first-fragment))
                     (text (buffer-string))
                     (tree (org-texmacs-fragment-tree span))
                     (again (org-texmacs-fragment-tree span)))
                (cl-incf calls 2)
                (unless process
                  (setq process org-texmacs--worker-process))
                (should (eq process org-texmacs--worker-process))
                (should (= calls org-texmacs--worker-request-id))
                (should (eq (org-element-type tree) (car stree)))
                (should-not (org-element-property :parent tree))
                (should-not (eq tree again))
                (should
                 (equal (org-texmacs--org-to-stree tree) stree))
                (should
                 (equal (org-texmacs--org-to-stree again) stree))
                (org-element-map
                 tree t
                 (lambda (node)
                   ;; Empty cell strings carry no text properties.
                   (unless (or (eq node tree) (equal node ""))
                     (let ((parent
                            (org-element-property :parent node)))
                       (should parent)
                       (should
                        (memq node (org-element-contents parent)))
                       (should
                        (memq tree (org-element-lineage node)))))))
                (let ((leaves
                       (org-element-map tree 'plain-text #'identity))
                      (copies
                       (org-element-map
                        again 'plain-text #'identity)))
                  (cl-mapc
                   (lambda (a b)
                     (unless (equal a "")
                       (should-not (eq a b))))
                   leaves copies))
                (should-not
                 (text-properties-at
                  0
                  (org-texmacs-fragment-span-source span)))
                (should (equal (buffer-string) text)))))))))))

(ert-deftest org-texmacs-test-fragment-tags-do-not-restrict-blocks ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (let ((org-element-use-cache t)
           (stree
            '(with
              "mode" "math" (concat (math "x") (equation* "y")))))
       (insert
        "Before (math \"a\")\n\n#+begin_texmacs\n"
        (prin1-to-string stree)
        "\n#+end_texmacs\n\nAfter (align* \"b\")\n")
       (let* ((block (org-texmacs-test--first-block))
              (org-texmacs-fragment-tags nil)
              (tree (org-texmacs-tree block))
              (process org-texmacs--worker-process))
         (should-not (org-texmacs-test--fragment-sources))
         (should (equal (org-texmacs--org-to-stree tree) stree))
         (dolist (tags
                  '(nil
                    ("math")
                    ("with" "math" "equation*" "align*")
                    invalid))
           (let ((org-texmacs-fragment-tags tags))
             (should (eq tree (org-texmacs-tree block)))))
         (should (= org-texmacs--worker-request-id 1))
         (let ((org-texmacs-fragment-tags '("math" "align*")))
           (should
            (equal
             (org-texmacs-test--fragment-sources)
             '("(math \"a\")" "(align* \"b\")")))
           (org-texmacs-fragment-map
            (point-min) (point-max) #'org-texmacs-fragment-tree))
         (should (eq process org-texmacs--worker-process))
         (should (= org-texmacs--worker-request-id 3))
         (should (eq tree (org-texmacs-tree block))))))))

(ert-deftest org-texmacs-test-fragment-custom-real-error-and-repair ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (let ((org-texmacs-fragment-tags '("custom.tag*")))
       (insert "Before (custom.tag* 1) after\n")
       (let ((span (org-texmacs-test--first-fragment)))
         (should-error
          (org-texmacs-fragment-tree span)
          :type 'org-texmacs-parse-error)
         (should (org-texmacs--worker-live-p))
         (let ((process org-texmacs--worker-process))
           (goto-char (point-min))
           (search-forward "1")
           (replace-match "\"1\"" t t)
           (should-error
            (org-texmacs-fragment-tree span)
            :type 'org-texmacs-error)
           (should (= org-texmacs--worker-request-id 1))
           ;; Unknown tags can round-trip as AST, without proving semantics.
           (should
            (equal
             (org-texmacs--org-to-stree
              (org-texmacs-fragment-tree
               (org-texmacs-test--first-fragment)))
             '(custom.tag* "1")))
           (should (eq process org-texmacs--worker-process))
           (should (= org-texmacs--worker-request-id 2))))))))

(ert-deftest org-texmacs-source-location-explicit-buffer-snapshot ()
  (dolist (file '(nil "/source/notes.org"))
    (let (input)
      (with-temp-buffer
        (org-mode)
        (setq-local org-export-with-author nil)
        (setq
         buffer-file-name file
         default-directory "/resources/override/")
        (insert "Text\n")
        (let ((source (current-buffer)))
          (with-temp-buffer
            (setq default-directory "/caller/")
            (setq input (org-texmacs-prepare-buffer source)))))
      (let ((result (org-texmacs-document input)))
        (should
         (equal (org-texmacs-document-source-file result) file))
        (should
         (equal
          (org-texmacs-document-resource-base result)
          "/resources/override/"))
        (should
         (equal
          (org-texmacs-document-body result)
          '(document (concat "Text "))))))))

(ert-deftest org-texmacs-source-location-indirect-buffer-context ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq
     buffer-file-name "/source/base.org"
     default-directory "/base/")
    (insert "Text\n")
    (let ((indirect (clone-indirect-buffer nil nil)))
      (unwind-protect
          (with-current-buffer indirect
            (setq default-directory "/indirect/override/")
            (let ((input (org-texmacs-prepare-buffer indirect)))
              (should
               (equal
                (org-texmacs-input-source-file input)
                "/source/base.org"))
              (should
               (equal
                (org-texmacs-input-resource-base input)
                "/indirect/override/"))))
        (kill-buffer indirect)))))

(ert-deftest
    org-texmacs-source-location-expands-home-during-preparation
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq
     default-directory "~/"
     buffer-file-name "~/notes.org")
    (insert "Text\n")
    (let* ((home (expand-file-name "~/"))
           (input (org-texmacs-prepare-buffer (current-buffer))))
      (should
       (equal
        (org-texmacs-input-source-file input)
        (concat home "notes.org")))
      (should (equal (org-texmacs-input-resource-base input) home))
      (should (equal default-directory "~/"))
      (should (equal buffer-file-name "~/notes.org"))
      (setq default-directory "/later/")
      (should
       (equal
        (org-texmacs-document-resource-base
         (org-texmacs-document input))
        home)))))

(ert-deftest org-texmacs-source-location-invalidates-worker-snapshot
    ()
  (dolist (change '(file directory file-in-place directory-in-place))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
      (setq
       buffer-file-name (copy-sequence "/source/notes.org")
       default-directory (copy-sequence "/resources/base/"))
      (insert "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
      (let ((source (current-buffer))
            (tick (buffer-chars-modified-tick))
            (before (buffer-string)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (with-current-buffer source
                       (pcase change
                         ('file
                          (setq buffer-file-name "/new/notes.org"))
                         ('directory
                          (setq default-directory "/new/base/"))
                         ('file-in-place (aset buffer-file-name 1 ?X))
                         ('directory-in-place
                          (aset default-directory 1 ?X))))
                     '(math "x"))))
          (let ((failure
                 (should-error
                  (org-texmacs-document-from-buffer source)
                  :type 'org-texmacs-document-error)))
            (should
             (equal
              (cadr failure)
              "Standard export source or native settings changed"))))
        (should (= tick (buffer-chars-modified-tick)))
        (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-source-location-checks-after-preflight ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (setq default-directory "/resources/base/")
    (insert "#+OPTIONS: toc:nil\n* Title\n")
    (let* ((source (current-buffer))
           (org-texmacs-format-headline-function
            (lambda (&rest _)
              (with-current-buffer source
                (setq default-directory "/new/base/"))
              "Title")))
      (should-error
       (org-texmacs-document-from-buffer source)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-test-tree-real-parser-and-cache ()
  (org-texmacs-test--with-worker
   (let ((org-element-use-cache t))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert
        "#+begin_texmacs\n"
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
         (should
          (equal
           (org-texmacs--org-to-stree tree)
           '(with "mode" "math" (concat "x+" (frac "1" "2")))))
         (should (eq (org-element-property :parent concat-node) tree))
         (should
          (eq (org-element-property :parent frac-node) concat-node))
         (dolist (leaf (org-element-contents frac-node))
           (should
            (eq (org-element-property :parent leaf) frac-node)))
         (should-not (org-element-property :parent tree))
         (should
          (equal
           (org-element-map
            tree '(with concat frac) #'org-element-type)
           '(with concat frac)))
         (should (eq (org-element-type block) 'special-block))
         (should (equal (buffer-string) text))
         (should (= (point) position))
         (should (= (buffer-chars-modified-tick) tick))
         (cl-letf (((symbol-function 'org-texmacs--worker-request)
                    (lambda (_source)
                      (ert-fail "Cache hit must not parse again"))))
           (should
            (eq
             tree
             (org-texmacs-tree (org-texmacs-test--first-block)))))
         (should (= request-id org-texmacs--worker-request-id)))))))

(ert-deftest org-texmacs-test-tree-edit-and-error-recovery ()
  (org-texmacs-test--with-worker
   (let ((org-element-use-cache t))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
       (org-texmacs-tree (org-texmacs-test--first-block))
       (let ((process org-texmacs--worker-process))
         (goto-char (point-min))
         (search-forward "\"2\"")
         (replace-match "\"3\"" t t)
         (let ((block (org-texmacs-test--first-block)))
           (should
            (eq
             (org-element-cache-get-key
              block 'org-texmacs-tree org-texmacs--cache-miss)
             org-texmacs--cache-miss))
           (should
            (equal
             (org-texmacs--org-to-stree
              (org-texmacs-tree block))
             '(frac "1" "3")))
           (should (= org-texmacs--worker-request-id 2)))
         ;; Remove the closing parenthesis.  Org still has a special block,
         ;; but the strict reader must reject its STM body.
         (goto-char (point-min))
         (search-forward ")")
         (delete-char -1)
         (let ((block (org-texmacs-test--first-block)))
           (dotimes (_ 2)
             (should-error
              (org-texmacs-tree block)
              :type 'org-texmacs-parse-error)
             (should
              (eq
               (org-element-cache-get-key
                block 'org-texmacs-tree org-texmacs--cache-miss)
               org-texmacs--cache-miss)))
           (should (= org-texmacs--worker-request-id 4)))
         (insert ")")
         (should
          (equal
           (org-texmacs--org-to-stree
            (org-texmacs-tree (org-texmacs-test--first-block)))
           '(frac "1" "3")))
         (should (= org-texmacs--worker-request-id 5))
         (should (eq process org-texmacs--worker-process)))))))

(ert-deftest org-texmacs-test-tree-blocks-share-worker ()
  (org-texmacs-test--with-worker
   (let ((org-element-use-cache t))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert
        "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n\n"
        "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
       (let* ((first
               (org-texmacs-tree (org-texmacs-test--first-block)))
              (process org-texmacs--worker-process))
         (goto-char (point-max))
         (search-backward "#+begin_texmacs")
         (should
          (equal
           (org-texmacs--org-to-stree
            (org-texmacs-tree (org-element-at-point)))
           '(sqrt "x")))
         (should
          (eq
           first (org-texmacs-tree (org-texmacs-test--first-block))))
         (should (= org-texmacs--worker-request-id 2))
         (should (eq process org-texmacs--worker-process)))))))

;;; source.el ends here
