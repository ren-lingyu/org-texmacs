;;; model.el --- Independent mathematical-document ownership regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Native Org AST and supplied STM trees, without native worker execution.

;;; Code:

(require 'org-texmacs-model)

(ert-deftest org-texmacs-model-loads-without-export-or-worker ()
  (with-temp-buffer
    (let ((status
           (call-process (expand-file-name invocation-name
                                           invocation-directory)
                         nil
                         t
                         nil
                         "-Q"
                         "--batch"
                         "-L"
                         (file-name-directory (locate-library "org"))
                         "-L"
                         (file-name-directory
                          (locate-library "org-texmacs-model"))
                         "--eval"
                         (prin1-to-string
                          '(progn
                             (require 'org-texmacs-model)
                             (dolist (feature
                                      '(org-texmacs-document
                                        org-texmacs-input
                                        ox-texmacs
                                        org-texmacs-worker))
                               (when (featurep feature)
                                 (error
                                  "Unexpected core dependency: %S"
                                  feature)))
                             (unless (org-texmacs-model-p
                                      (org-texmacs-model-create
                                       (org-element-create
                                        'org-data nil)))
                               (error
                                "Failed independent construction"))
                             (princ "model-only-ok"))))))
      (should (equal status 0))
      (should (string-match-p "model-only-ok" (buffer-string))))))

(ert-deftest org-texmacs-model-preserves-org-beyond-lowering ()
  (let (model)
    (with-temp-buffer
      (let ((org-element-use-cache nil))
        (org-mode)
        (insert
         "#+TITLE: Preserved\n#+INCLUDE: \"not-read.org\"\n"
         "# A comment\n\n* COMMENT Hidden :noexport:\n"
         ":PROPERTIES:\n:CUSTOM_PROPERTY: retained\n:END:\n"
         "- [ ] A task\n\n"
         "#+begin_unfamiliar\nKept text.\n#+end_unfamiliar\n\n"
         "[fn:unused] An unreferenced definition.\n")
        (let ((ast (org-element-parse-buffer))
              (text (buffer-string))
              (tick (buffer-modified-tick)))
          (cl-letf (((symbol-function 'org-texmacs--document-lower)
                     (lambda (&rest _)
                       (ert-fail "Core invoked lowering")))
                    ((symbol-function 'org-texmacs--document-resolve)
                     (lambda (&rest _)
                       (ert-fail "Core resolved references")))
                    ((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (ert-fail "Core requested worker")))
                    ((symbol-function 'buffer-substring-no-properties)
                     (lambda (&rest _)
                       (ert-fail "Core rescanned source"))))
            (setq model (org-texmacs-model-create ast)))
          (should (equal text (buffer-string)))
          (should (= tick (buffer-modified-tick))))))
    ;; The private source is now dead; every node still belongs to the model.
    (let ((ast (org-texmacs-model-ast model)))
      (dolist (type
               '(keyword
                 comment
                 headline
                 property-drawer
                 node-property
                 item
                 special-block
                 footnote-definition))
        (should (org-element-map ast type #'identity nil t)))
      (should
       (eq
        (org-element-property
         :checkbox (org-element-map ast 'item #'identity nil t))
        'off))
      (should-not (org-element-property :buffer ast)))))

(ert-deftest org-texmacs-model-owns-and-remaps-all-structures ()
  (let* ((leaf (copy-sequence "old source"))
         (title
          (org-element-create 'bold nil (copy-sequence "Title")))
         (caption
          (org-element-create 'italic nil (copy-sequence "Caption")))
         (block
          (org-element-create
           'special-block
           (list
            :type "texmacs"
            :caption
            (list (cons (list caption) nil)))
           (org-element-create 'paragraph nil leaf)))
         (heading
          (org-element-create
           'headline
           (list :level 1 :title (list title)) block))
         (ast (org-element-create 'org-data nil heading))
         (tree (list 'frac (copy-sequence "1") (copy-sequence "2")))
         (tags (list (copy-sequence "math")))
         (context (list :fragment-tags tags))
         (model
          (org-texmacs-model-create
           ast
           :islands (list (cons block tree))
           :context context))
         (owned (org-texmacs-model-ast model))
         (new-heading (car (org-element-contents owned)))
         (new-block (car (org-element-contents new-heading)))
         (new-title (car (org-element-property :title new-heading)))
         (new-caption
          (caar (car (org-element-property :caption new-block)))))
    (should (eq (caar (org-texmacs-model-islands model)) new-block))
    (should (eq (org-element-parent new-block) new-heading))
    (should (eq (org-element-parent new-title) new-heading))
    (should (eq (org-element-parent new-caption) new-block))
    (should-not (eq tree (cdar (org-texmacs-model-islands model))))
    (aset (cadr tree) 0 ?9)
    (aset (car tags) 0 ?X)
    (aset leaf 0 ?X)
    (org-element-set-contents title '("Changed"))
    (org-element-set-contents caption '("Changed"))
    (should
     (equal (cdar (org-texmacs-model-islands model)) '(frac "1" "2")))
    (should
     (equal
      (plist-get
       (org-texmacs-model-context model)
       :fragment-tags)
      '("math")))
    (should (equal (org-element-contents new-title) '("Title")))
    (should (equal (org-element-contents new-caption) '("Caption")))))

(ert-deftest
    org-texmacs-model-construction-does-not-check-expressibility
    ()
  (let* ((leaf (copy-sequence "(math old)"))
         (heading
          (org-element-create
           'headline (list :level 1 :title (list leaf))))
         (ast (org-element-create 'org-data nil heading))
         (model
          (cl-letf (((symbol-function 'org-texmacs--fragment-collect)
                     (lambda (&rest _)
                       (ert-fail "Rescanned supplied AST")))
                    ((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (ert-fail "Reparsed supplied tree")))
                    ((symbol-function 'org-texmacs--document-lower)
                     (lambda (&rest _)
                       (ert-fail "Checked output support"))))
            (org-texmacs-model-create
             ast
             :islands
             (list (cons leaf '(not-a-fragment-root "new")))
             :context '(:fragment-tags ("math"))))))
    (should
     (equal
      (cdar (org-texmacs-model-islands model))
      '(not-a-fragment-root "new")))
    (should
     (eq
      (caar (org-texmacs-model-islands model))
      (car
       (org-element-property
        :title
        (car
         (org-element-contents (org-texmacs-model-ast model))))))))
  ;; Atomic STM trees are valid too; no source spelling is consulted.
  (let* ((block
          (org-element-create 'special-block '(:type "texmacs")))
         (model
          (org-texmacs-model-create
           (org-element-create 'org-data nil block)
           :islands (list (cons block "atom 中")))))
    (should
     (equal (cdar (org-texmacs-model-islands model)) "atom 中"))))

(ert-deftest org-texmacs-model-remaps-forward-property-references ()
  (let* ((first (org-element-create 'paragraph nil "First"))
         (second (org-element-create 'paragraph nil "Second"))
         (ast (org-element-create 'org-data nil first second)))
    (org-element-put-property first :related-node second)
    (let* ((model (org-texmacs-model-create ast))
           (children
            (org-element-contents (org-texmacs-model-ast model))))
      (should
       (eq
        (org-element-property :related-node (car children))
        (cadr children))))))

(ert-deftest org-texmacs-model-rejects-invalid-island-ownership ()
  (let* ((leaf (copy-sequence "island"))
         (paragraph (org-element-create 'paragraph nil leaf))
         (ast (org-element-create 'org-data nil paragraph)))
    (dolist (mapping
             (list
              (list (cons (copy-sequence "island") '(math "x")))
              (list
               (cons leaf '(math "x")) (cons leaf '(math "y")))
              (list (cons leaf '(math 7)))
              (list
               (cons paragraph '(math "x")) (cons leaf '(math "y")))))
      (should-error
       (org-texmacs-model-create ast :islands mapping)
       :type 'org-texmacs-model-error))
    (let ((cycle (list 'math nil)))
      (setcar (cdr cycle) cycle)
      (should-error
       (org-texmacs-model-create
        ast
        :islands (list (cons leaf cycle)))
       :type 'org-texmacs-model-error))))

(ert-deftest org-texmacs-model-block-caption-is-outside-opaque-body ()
  (let* ((caption (copy-sequence "caption island"))
         (block
          (org-element-create
           'special-block
           (list
            :type "texmacs"
            :caption
            (list (cons (list caption) nil)))
           (org-element-create 'paragraph nil "old raw body")))
         (model
          (org-texmacs-model-create
           (org-element-create 'org-data nil block)
           :islands
           (list
            (cons block '(math "body"))
            (cons caption '(math "caption"))))))
    (should (= (length (org-texmacs-model-islands model)) 2))))

(ert-deftest org-texmacs-model-rejects-unowned-runtime-and-cyclic-data
    ()
  (let ((ast (org-element-create 'org-data nil)))
    (dolist (context
             (list
              '(:style ("generic"))
              '(:fragment-tags)
              '(:fragment-tags nil :fragment-tags nil)
              (list :source-file (current-buffer))))
      (should-error
       (org-texmacs-model-create ast :context context)
       :type 'org-texmacs-model-error))
    (let ((cycle (vector nil)))
      (aset cycle 0 cycle)
      (should-error
       (org-texmacs-model-create
        ast
        :context (list :heading-settings cycle))
       :type 'org-texmacs-model-error))
    (org-element-set-contents ast (list ast))
    (should-error
     (org-texmacs-model-create ast)
     :type 'org-texmacs-model-error)))

(ert-deftest org-texmacs-model-rejects-sharing-and-deferred-nodes ()
  (let* ((shared (org-element-create 'paragraph nil "Shared"))
         (ast (org-element-create 'org-data nil shared shared)))
    (should-error
     (org-texmacs-model-create ast)
     :type 'org-texmacs-model-error))
  (let ((ast (org-element-create 'org-data '(:deferred t))))
    (cl-letf (((symbol-function 'org-element-properties-mapc)
               (lambda (&rest _)
                 (ert-fail "Resolved deferred properties"))))
      (should-error
       (org-texmacs-model-create ast)
       :type 'org-texmacs-model-error))))

(ert-deftest org-texmacs-model-empty-caption-is-not-a-lowering-policy
    ()
  (let* ((table
          (org-element-create
           'table (list :caption (list (cons nil nil)))))
         (ast (org-element-create 'org-data nil table)))
    (should (org-texmacs-model-p (org-texmacs-model-create ast)))
    ;; The export constructor retains its earlier stricter caption boundary.
    (should-error
     (org-texmacs-input-create ast nil)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-model-and-export-share-owned-identities ()
  (let* ((leaf (copy-sequence "island"))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil leaf)))
         (input
          (org-texmacs-input-create
           ast nil
           :islands
           (list (cons leaf '(math "x")))))
         (model (org-texmacs-input-model input))
         (updated
          (org-texmacs--input-with-info
           input (org-texmacs-input-info input))))
    (should (org-texmacs-model-p model))
    (should
     (eq (org-texmacs-model-ast model) (org-texmacs-input-ast input)))
    (should
     (eq
      (org-texmacs-model-islands model)
      (org-texmacs-input-islands input)))
    (should-not (org-texmacs-model-context model))
    (should (eq model (org-texmacs-input-model updated)))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document updated))
      '(document (math "x"))))))

;;; model.el ends here
