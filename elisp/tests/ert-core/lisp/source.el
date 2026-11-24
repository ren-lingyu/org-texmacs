;;; source.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'org-texmacs)
(require 'ox)

(defun org-texmacs-test--first-block ()
  "Return a fresh Org element at the first TeXmacs block opening."
  (save-excursion
    (goto-char (point-min))
    (search-forward "#+begin_texmacs")
    (beginning-of-line)
    (org-element-at-point)))

(defun org-texmacs-test--org-to-stree (node)
  "Convert Org-compatible pseudo tree NODE to a TeXmacs stree.

Ignore Org's properties storage and remove text properties from copied string
nodes."
  (cond
   ((stringp node)
    (substring-no-properties node))
   ((and (consp node) (symbolp (car node)))
    (cons
     (car node)
     (mapcar
      #'org-texmacs-test--org-to-stree (org-element-contents node))))
   (t
    node)))

(ert-deftest org-texmacs-test-stree-org-round-trip ()
  (let* ((mode (copy-sequence "mode"))
         (math (copy-sequence "math"))
         (sum (copy-sequence "x+"))
         (numerator (copy-sequence "1"))
         (denominator (copy-sequence "2"))
         (stree
          (list
           'with mode math
           (list 'concat sum (list 'frac numerator denominator))))
         (tree (org-texmacs--stree-to-org stree))
         (round-trip (org-texmacs-test--org-to-stree tree)))
    (should (equal round-trip stree))
    (dolist (string (list mode math sum numerator denominator))
      (should-not (text-properties-at 0 string)))
    (dolist (string
             (list
              (nth 1 round-trip)
              (nth 2 round-trip)
              (nth 1 (nth 3 round-trip))
              (nth 1 (nth 2 (nth 3 round-trip)))
              (nth 2 (nth 2 (nth 3 round-trip)))))
      (should-not (text-properties-at 0 string)))))

(ert-deftest org-texmacs-test-stree-to-org-copies-strings ()
  (let* ((source (copy-sequence "1"))
         (tree (org-texmacs--stree-to-org (list 'frac source "2")))
         (converted (car (org-element-contents tree))))
    (should (equal converted source))
    (should-not (eq converted source))
    (should-not (text-properties-at 0 source))))

(ert-deftest org-texmacs-test-stree-to-org-builds-parent-links ()
  (let* ((tree
          (org-texmacs--stree-to-org
           '(with "mode" "math" (concat "x+" (frac "1" "2")))))
         (root-contents (org-element-contents tree))
         (mode (nth 0 root-contents))
         (math (nth 1 root-contents))
         (concat-node (nth 2 root-contents))
         (concat-contents (org-element-contents concat-node))
         (sum (nth 0 concat-contents))
         (frac-node (nth 1 concat-contents))
         (frac-contents (org-element-contents frac-node)))
    (should (eq (org-element-property :parent mode) tree))
    (should (eq (org-element-property :parent math) tree))
    (should (eq (org-element-property :parent concat-node) tree))
    (should (eq (org-element-property :parent sum) concat-node))
    (should (eq (org-element-property :parent frac-node) concat-node))
    (dolist (string frac-contents)
      (should (eq (org-element-property :parent string) frac-node)))))

(ert-deftest org-texmacs-block-case-markers-and-raw-source ()
  (dolist (fold '(nil t))
    (dolist (begin '("begin" "BEGIN" "BeGiN"))
      (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
        (dolist (end '("end" "END" "EnD"))
          (dolist (end-type '("texmacs" "TEXMACS" "TeXmAcS"))
            (with-temp-buffer
              (org-mode)
              (let ((body "(math (concat \"MiXeD α\" \"<alpha>\"))\n")
                    (case-fold-search fold))
                (insert
                 (format "#+%s_%s\n%s#+%s_%s\n"
                         begin
                         type
                         body
                         end
                         end-type))
                (goto-char (point-min))
                (let ((block (org-element-at-point))
                      (text (buffer-string))
                      (tick (buffer-modified-tick)))
                  (should (org-texmacs--block-p block))
                  (should
                   (equal (org-element-property :type block) type))
                  (should
                   (equal (org-texmacs--block-source block) body))
                  (should
                   (equal (org-element-property :type block) type))
                  (should (equal (buffer-string) text))
                  (should (= (point) (point-min)))
                  (should (= (buffer-modified-tick) tick))
                  (should (eq case-fold-search fold)))))))))))

(ert-deftest org-texmacs-source-location-owned-pure-input ()
  (let* ((file
          (propertize (copy-sequence "/source/notes.org")
                      'face
                      'bold))
         (directory (copy-sequence "/resources/link/../base/"))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil "Text")))
         (input
          (org-texmacs-input-create
           ast
           nil
           :source-file file
           :resource-base directory))
         first)
    (aset file 1 ?X)
    (aset directory 1 ?X)
    (let ((default-directory "/unrelated/"))
      (cl-letf (((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _)
                   (ert-fail "Unexpected buffer read"))))
        ;; Install the sentinel after function rebinding: native compilation's
        ;; trampoline setup may itself consult file handlers.
        (let ((file-name-handler-alist
               '(("." .
                  (lambda (&rest _)
                    (ert-fail "Unexpected file handler"))))))
          (setq first (org-texmacs-document input)))))
    (should
     (equal
      (org-texmacs-document-source-file first) "/source/notes.org"))
    (should
     (equal
      (org-texmacs-document-resource-base first)
      "/resources/link/../base/"))
    (should-not
     (text-properties-at 0 (org-texmacs-input-source-file input)))
    (should-not
     (eq
      (org-texmacs-input-resource-base input)
      (org-texmacs-document-resource-base first)))
    (should-not
     (eq
      (org-texmacs-input-source-file input)
      (org-texmacs-document-source-file first)))
    (aset (org-texmacs-document-resource-base first) 1 ?X)
    (aset (org-texmacs-document-source-file first) 1 ?X)
    (should
     (equal
      (org-texmacs-document-source-file
       (org-texmacs-document input))
      "/source/notes.org"))
    (should
     (equal
      (org-texmacs-document-resource-base
       (org-texmacs-document input))
      "/resources/link/../base/"))
    (let ((unspecified
           (org-texmacs-document (org-texmacs-input-create ast nil))))
      (should-not (org-texmacs-document-source-file unspecified))
      (should-not (org-texmacs-document-resource-base unspecified)))))

(ert-deftest org-texmacs-source-location-rejects-implicit-paths ()
  (let ((ast (org-element-create 'org-data nil)))
    (dolist (path
             '("" "relative/path" "~/notes.org" "/path\0suffix" t))
      (should-error
       (org-texmacs-input-create ast nil :source-file path)
       :type 'org-texmacs-document-error)
      (should-error
       (org-texmacs-input-create ast nil :resource-base path)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-test-block-p ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
    (goto-char (point-min))
    (should (org-texmacs--block-p (org-element-at-point))))
  (dolist (node
           (list
            nil
            "text"
            (org-element-create 'paragraph nil)
            (org-element-create 'special-block nil)
            (org-element-create 'special-block '(:type 42))
            (org-element-create 'special-block '(:type "example"))
            (org-element-create 'src-block '(:language "texmacs"))))
    (should-not (org-texmacs--block-p node))))

(ert-deftest org-texmacs-test-block-source-exact ()
  (dolist
      (body
       '("(frac \"1\" \"2\")\n"
         "\n\t(with \"mode\" \"math\"\n  (concat \"α *bold* [[link]]\" (sqrt \"x\")))\n\n"
         ""
         "\n\n"))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_texmacs\n" body "#+end_texmacs\n")
      (goto-char (point-min))
      (let* ((block (org-element-at-point))
             (before (buffer-string))
             (position (point))
             (tick (buffer-modified-tick)))
        (should (equal (org-texmacs--block-source block) body))
        (should (equal (buffer-string) before))
        (should (= (point) position))
        (should (= (buffer-modified-tick) tick))))))

(ert-deftest org-texmacs-test-block-source-strips-properties ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
    (goto-char (point-min))
    (let* ((block (org-element-at-point))
           (begin (org-element-property :contents-begin block))
           (end (org-element-property :contents-end block)))
      (put-text-property begin end 'org-texmacs-test-property t)
      (let ((source (org-texmacs--block-source block)))
        (should (equal source "(sqrt \"x\")\n"))
        (dotimes (index (length source))
          (should-not (text-properties-at index source)))))))

(ert-deftest org-texmacs-test-block-source-rejects-other-nodes ()
  (dolist (node
           (list
            nil
            (org-element-create 'paragraph nil)
            (org-element-create 'special-block '(:type "example"))))
    (should-error
     (org-texmacs--block-source node)
     :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-block-source-rejects-invalid-bounds ()
  (with-temp-buffer
    (insert "text")
    (dolist (bounds '((nil 3) (2 nil) (3 2) (0 2) (1 100) ("1" 2)))
      (let ((block
             (org-element-create
              'special-block
              (list
               :type "texmacs"
               :contents-begin (car bounds)
               :contents-end (cadr bounds)))))
        (should-error
         (org-texmacs--block-source block)
         :type 'org-texmacs-error)))))

(ert-deftest org-texmacs-test-tree-prefix-edit-remains-correct ()
  (let ((org-element-use-cache t)
        (calls 0))
    (with-temp-buffer
      (org-mode)
      (insert
       "Before\n\n#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (should (equal source "(sqrt \"x\")\n"))
                   (cl-incf calls)
                   '(sqrt "x"))))
        (org-texmacs-tree (org-texmacs-test--first-block))
        (goto-char (point-min))
        (insert "New prefix\n")
        (let ((block (org-texmacs-test--first-block)))
          (should
           (equal
            (org-texmacs-test--org-to-stree
             (org-texmacs-tree block))
            '(sqrt "x")))
          ;; Correctness does not depend on retaining the entry across a shift.
          (should (<= 1 calls 2)))))))

(ert-deftest org-texmacs-test-tree-rejects-wrong-block ()
  (cl-letf (((symbol-function 'org-texmacs--stm-read)
             (lambda (_source)
               (ert-fail "Invalid block must not start parsing"))))
    (dolist (node
             (list
              nil
              (org-element-create 'special-block '(:type "example"))))
      (should-error
       (org-texmacs-tree node)
       :type 'org-texmacs-error))))

(ert-deftest org-texmacs-test-tree-rejects-text-changed-during-parse
    ()
  (let ((org-element-use-cache t))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
      (let ((block (org-texmacs-test--first-block)))
        (cl-letf
            (((symbol-function 'org-texmacs--stm-read)
              (lambda (_source)
                ;; Edit during acquisition and ensure the old tree stays uncached.
                (goto-char (point-min))
                (search-forward "\"x\"")
                (replace-match "\"y\"" t t)
                '(sqrt "x"))))
          (should-error
           (org-texmacs-tree block)
           :type 'org-texmacs-error))
        (should
         (eq
          (org-element-cache-get-key
           (org-texmacs-test--first-block)
           'org-texmacs-tree
           org-texmacs--cache-miss)
          org-texmacs--cache-miss))))))

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
     "Body $(math \"x\")$\n")
    (let ((reader (symbol-function 'org-texmacs--stm-read))
          sources)
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (push source sources)
                   (should (equal source "(math \"x\")"))
                   (funcall reader source))))
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
            (org-texmacs-document-stm-paths document) '((1 1))))))
      (should (= (length sources) 1)))))

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
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (&rest _)
                   (ert-fail "Filtered STM reached STM reader"))))
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
    (cl-letf (((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _)
                 (ert-fail "Archived STM reached STM reader"))))
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
    (cl-letf (((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _)
                 (ert-fail "Excluded STM reached STM reader"))))
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
     "#+OPTIONS: todo:nil tags:nil toc:nil\n* TODO Title :tag:\n$(math \"x\")$\n")
    (let ((reader (symbol-function 'org-texmacs--stm-read))
          (calls 0))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (source)
                   (cl-incf calls)
                   (setq-local
                    org-export-with-todo-keywords t
                    org-export-with-tags t)
                   (funcall reader source))))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer (current-buffer)))
          '(document (section "Title") (math "x")))))
      (should (= calls 1)))))

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

(ert-deftest org-texmacs-source-location-invalidates-stm-snapshot ()
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
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
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
  (org-texmacs-test--with-environment
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
         (should (= request-id 0))
         (should
          (equal
           (org-texmacs-test--org-to-stree tree)
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
         (cl-letf (((symbol-function 'org-texmacs--stm-read)
                    (lambda (_source)
                      (ert-fail "Cache hit must not parse again"))))
           (should
            (eq
             tree
             (org-texmacs-tree (org-texmacs-test--first-block)))))
         (should (= request-id org-texmacs--worker-request-id)))))))

(ert-deftest org-texmacs-test-tree-edit-and-error-recovery ()
  (org-texmacs-test--with-environment
   (let ((org-element-use-cache t))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
       (org-texmacs-tree (org-texmacs-test--first-block))
       (progn
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
             (org-texmacs-test--org-to-stree
              (org-texmacs-tree block))
             '(frac "1" "3")))
           (should-not (org-texmacs--worker-live-p)))
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
           (should-not (org-texmacs--worker-live-p)))
         (insert ")")
         (should
          (equal
           (org-texmacs-test--org-to-stree
            (org-texmacs-tree (org-texmacs-test--first-block)))
           '(frac "1" "3")))
         (should-not (org-texmacs--worker-live-p))
         (should (= org-texmacs--worker-request-id 0)))))))

(ert-deftest org-texmacs-test-tree-blocks-cache-independently ()
  (org-texmacs-test--with-environment
   (let ((org-element-use-cache t))
     (with-temp-buffer
       (org-mode)
       (setq-local org-export-with-author nil)
       (insert
        "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n\n"
        "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
       (let ((first
              (org-texmacs-tree (org-texmacs-test--first-block))))
         (goto-char (point-max))
         (search-backward "#+begin_texmacs")
         (should
          (equal
           (org-texmacs-test--org-to-stree
            (org-texmacs-tree (org-element-at-point)))
           '(sqrt "x")))
         (should
          (eq
           first (org-texmacs-tree (org-texmacs-test--first-block))))
         (should-not (org-texmacs--worker-live-p))
         (should (= org-texmacs--worker-request-id 0)))))))

;;; source.el ends here
