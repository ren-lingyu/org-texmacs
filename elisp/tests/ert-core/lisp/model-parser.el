;;; model-parser.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'org-texmacs)
(require 'org-texmacs-serialize)
(require 'ox)

(require 'org-texmacs-parse)

(ert-deftest org-texmacs-model-parse-complete-source-without-export ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+TITLE: Original\n#+INCLUDE: \"missing.org\"\n"
     "#+SETUPFILE: missing.setup\n#+BIBLIOGRAPHY: absent.bib\n"
     "#+MACRO: example unused\n# Keep this comment\n\n"
     "* COMMENT Hidden :noexport:\n"
     ":PROPERTIES:\n:CUSTOM_PROPERTY: kept\n:END:\n"
     "- [ ] A task\n\n"
     "#+begin_unknown\nOrdinary Org.\n#+end_unknown\n\n"
     "* Visible\nSelected text.\n\n[fn:unused] Retained definition.\n")
    (goto-char (point-min))
    (search-forward "Selected")
    (set-mark (point))
    (narrow-to-region (line-beginning-position) (line-end-position))
    (let ((state
           (org-texmacs-test--document-buffer-state (current-buffer)))
          (org-mode-hook
           (list (lambda () (ert-fail "Ran private mode hook"))))
          model)
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (&rest _)
                   (ert-fail "No islands need parsing")))
                ((symbol-function 'org-texmacs--document-lower)
                 (lambda (&rest _) (ert-fail "Ran lowering")))
                ((symbol-function 'org-texmacs--context-prepare)
                 (lambda (&rest _) (ert-fail "Ran export context")))
                ((symbol-function 'org-export-expand-include-keyword)
                 (lambda (&rest _) (ert-fail "Expanded INCLUDE"))))
        (setq model (org-texmacs-parse-buffer (current-buffer))))
      (should
       (equal
        state
        (org-texmacs-test--document-buffer-state (current-buffer))))
      (let ((ast (org-texmacs-model-ast model)))
        (should
         (= (length (org-element-map ast 'headline #'identity)) 2))
        (dolist (type
                 '(comment
                   property-drawer
                   node-property
                   item
                   special-block
                   footnote-definition))
          (should (org-element-map ast type #'identity nil t)))
        (should
         (= (length (org-element-map ast 'keyword #'identity)) 5))
        (should-not (org-texmacs-model-islands model))))))

(ert-deftest org-texmacs-model-parse-blocks-inline-and-unused-notes ()
  (let (model
        calls)
    (with-temp-buffer
      (org-mode)
      (insert
       "Before $(math (frac \"1\" \"2\"))$.\n\n"
       "A[fn::Inside $(math \"note\")$].\n\n"
       "#+NAME: raw\n#+CAPTION: Caption (math \"ordinary\")\n"
       "#+begin_TeXmAcS extra parameters\n"
       "(math \"raw\n * not a headline\n#+INCLUDE: not-read.org\")\n"
       "#+end_TeXmAcS\n\n"
       "[fn:unused] Another $(math \"unused\")$.\n")
      (let ((state
             (org-texmacs-test--document-buffer-state
              (current-buffer))))
        (let ((reader (symbol-function 'org-texmacs--stm-read)))
          (cl-letf (((symbol-function 'org-texmacs--stm-read)
                     (lambda (raw &optional _syntax)
                       (push raw calls)
                       (funcall reader raw))))
            (setq model (org-texmacs-parse-buffer (current-buffer)))))
        (should
         (equal
          state
          (org-texmacs-test--document-buffer-state
           (current-buffer))))))
    (should (= (length calls) 4))
    (should
     (equal
      (mapcar #'cdr (org-texmacs-model-islands model))
      '((math (frac "1" "2"))
        (math "note")
        (math "raw\n * not a headline\n#+INCLUDE: not-read.org")
        (math "unused"))))
    (let* ((ast (org-texmacs-model-ast model))
           (block
            (org-element-map ast 'special-block #'identity nil t)))
      (should-not (org-element-map ast 'headline #'identity))
      (should (equal (org-element-property :name block) "raw"))
      (should
       (equal
        (org-element-property :parameters block) "extra parameters"))
      (should-not (org-element-contents block))
      (should (assq block (org-texmacs-model-islands model)))
      (should (org-element-property :caption block))
      (should
       (org-element-map ast 'footnote-definition #'identity nil t)))))

(ert-deftest org-texmacs-model-parse-block-boundaries-follow-org ()
  (dolist (kind '("texmacs" "equation" "equation*"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_"
       kind
       "\n\"first\n"
       "* Actual headline\nlast\"\n#+end_"
       kind
       "\n")
      (let ((state
             (org-texmacs-test--document-buffer-state
              (current-buffer))))
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (&rest _)
                     (ert-fail
                      "An incomplete Org block is not an island"))))
          (let* ((model (org-texmacs-parse-buffer (current-buffer)))
                 (ast (org-texmacs-model-ast model))
                 (headlines
                  (org-element-map ast 'headline #'identity))
                 (text (org-element-interpret-data ast)))
            (should-not (org-texmacs-model-islands model))
            (should-not
             (org-element-map ast 'special-block #'identity))
            (should (= (length headlines) 1))
            (should
             (equal
              (org-element-property
               :raw-value (car headlines))
              "Actual headline"))
            (dolist (literal
                     (list
                      (concat "#+begin_" kind)
                      "\"first"
                      "last\""
                      (concat "#+end_" kind)))
              (should (string-match-p (regexp-quote literal) text)))))
        (should
         (equal
          state
          (org-texmacs-test--document-buffer-state
           (current-buffer))))))))

(ert-deftest
    org-texmacs-model-parse-recognition-and-preservation-are-separate
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Heading (math \"title\")\n"
     "*bold (math \"emphasis\")* and =(math code)=.\n\n"
     "| Cell (math \"cell\") |\n\n"
     "#+CAPTION: Caption (math \"caption\")\n| Data |\n\n"
     "#+begin_src scheme\n(math \"code\")\n#+end_src\n\n"
     "Plain $(math \"recognized\")$.\n")
    (let (calls)
      (let ((reader (symbol-function 'org-texmacs--stm-read)))
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (raw &optional _syntax)
                     (push raw calls)
                     (funcall reader raw))))
          (let ((model (org-texmacs-parse-buffer (current-buffer))))
            (should (equal calls '("(math \"recognized\")")))
            (dolist (type '(headline bold verbatim table src-block))
              (should
               (org-element-map
                (org-texmacs-model-ast model) type #'identity nil t)))
            (should
             (= (length (org-texmacs-model-islands model)) 1))))))))

(ert-deftest org-texmacs-model-parse-effective-heading-and-link-syntax
    ()
  (let ((default-headings "* TODO Parent\n*** DONE Child\n"))
    (cl-labels
     ((headings
       (ast)
       (org-element-map
        ast 'headline
        (lambda (node)
          (mapcar
           (lambda (key) (org-element-property key node))
           '(:level :todo-keyword :todo-type)))))
      (link-target
       (ast)
       (let ((node (org-element-map ast 'link #'identity nil t)))
         (list
          (org-element-property :type node)
          (org-element-property :path node)))))
     (dolist (declared '(nil t))
       (let (expected
             model)
         (with-temp-buffer
           (when declared
             (insert
              "#+TODO: READY | FINISHED\n#+TODO: REVIEW | ACCEPTED\n"))
           (insert
            "#+LINK: local https://example.test/%s\n"
            (if declared
                "* READY Parent\n*** FINISHED Child\n*** REVIEW Check\n*** ACCEPTED Last\n"
              default-headings)
            "[[local:item][Link]] $(math \"x\")$.\n")
           (org-mode)
           (setq-local org-odd-levels-only t)
           (let ((regexes
                  (list
                   org-link-types-re
                   org-link-plain-re
                   org-element--object-regexp))
                 (native (org-element-parse-buffer)))
             (setq expected (headings native))
             (if declared
                 (should
                  (equal
                   expected
                   '((1 "READY" todo)
                     (2 "FINISHED" done)
                     (2 "REVIEW" todo)
                     (2 "ACCEPTED" done))))
               (should
                (equal (mapcar #'caddr expected) '(todo done))))
             (should
              (equal
               (link-target native) '("https" "//example.test/item")))
             (setq model (org-texmacs-parse-buffer (current-buffer)))
             (should
              (equal
               regexes
               (list
                org-link-types-re
                org-link-plain-re
                org-element--object-regexp)))))
         (let* ((ast (org-texmacs-model-ast model))
                (context (org-texmacs-model-context model))
                (links (plist-get context :link-settings)))
           (should (equal (headings ast) expected))
           (should
            (equal
             (link-target ast) '("https" "//example.test/item")))
           (should
            (equal
             (plist-get links :local)
             '(("local" . "https://example.test/%s"))))
           (should (member "https" (plist-get links :types))))
         (let ((output (org-texmacs-model-to-buffer model)))
           (unwind-protect
               (let ((ast
                      (org-texmacs-model-ast
                       (org-texmacs-parse-buffer output))))
                 (should (equal (headings ast) expected))
                 (should
                  (equal
                   (link-target ast)
                   '("https" "//example.test/item"))))
             (kill-buffer output))))))))

(ert-deftest
    org-texmacs-model-parse-guards-source-and-syntax-during-parsing
    ()
  (dolist (change
           '(text mode bounds file directory headings links registry))
    (with-temp-buffer
      (org-mode)
      (insert "$(math \"x\")$\n")
      (let ((source (current-buffer))
            (org-link-abbrev-alist
             (list (cons "original" "https://example.test/%s")))
            (org-link-parameters (copy-tree org-link-parameters)))
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (_raw &optional _syntax)
                     (with-current-buffer source
                       (pcase change
                         ('text
                          (goto-char (point-max))
                          (insert "Changed"))
                         ('mode (setq major-mode 'text-mode))
                         ('bounds (narrow-to-region 1 2))
                         ('file
                          (setq buffer-file-name
                                "/tmp/model-changed.org"))
                         ('directory (setq default-directory "/tmp/"))
                         ('headings
                          (setq-local org-odd-levels-only
                                      (not org-odd-levels-only)))
                         ('links
                          (setcdr
                           (car org-link-abbrev-alist)
                           "https://changed.test/%s"))
                         ('registry
                          (push '("model-wait-test"
                                  :follow ignore)
                                org-link-parameters))))
                     '(math "x"))))
          (should-error
           (org-texmacs-parse-buffer source)
           :type 'org-texmacs-model-error))
        (setq buffer-file-name nil)))))

(ert-deftest org-texmacs-model-parse-ignores-export-only-settings ()
  (with-temp-buffer
    (org-mode)
    (insert "$(math \"x\")$\n")
    (let ((source (current-buffer))
          (original org-export-with-toc)
          (reader (symbol-function 'org-texmacs--stm-read)))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (raw)
                   (with-current-buffer source
                     (setq-local org-export-with-toc
                                 (not org-export-with-toc)))
                   (funcall reader raw))))
        (should
         (org-texmacs-model-p (org-texmacs-parse-buffer source))))
      (should (eq org-export-with-toc (not original))))))

(ert-deftest org-texmacs-model-parse-rejects-killed-source ()
  (let ((source (generate-new-buffer " *model-source-lifetime*")))
    (unwind-protect
        (progn
          (with-current-buffer source
            (org-mode)
            (insert "$(math \"x\")$\n"))
          (cl-letf (((symbol-function 'org-texmacs--stm-read)
                     (lambda (&rest _)
                       (kill-buffer source)
                       '(math "x"))))
            (should-error
             (org-texmacs-parse-buffer source)
             :type 'org-texmacs-model-error)))
      (when (buffer-live-p source)
        (kill-buffer source)))))

(ert-deftest
    org-texmacs-model-parse-validates-source-and-propagates-stm-errors
    ()
  (dolist (source
           (list nil "text" (generate-new-buffer " *model-non-org*")))
    (unwind-protect
        (should-error
         (org-texmacs-parse-buffer source)
         :type 'org-texmacs-model-error)
      (when (bufferp source)
        (kill-buffer source))))
  (with-temp-buffer
    (org-mode)
    (insert "$(math \"x\")$\n")
    (cl-letf (((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _)
                 (signal 'org-texmacs-parse-error '("Invalid")))))
      (should-error
       (org-texmacs-parse-buffer (current-buffer))
       :type 'org-texmacs-parse-error))))

(ert-deftest
    org-texmacs-model-parse-checks-source-after-private-preparation
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Ordinary text.\n")
    (let ((source (current-buffer))
          (prepare (symbol-function 'org-texmacs--parse-prepare)))
      (cl-letf (((symbol-function 'org-texmacs--parse-prepare)
                 (lambda (&rest arguments)
                   (prog1 (apply prepare arguments)
                     (with-current-buffer source
                       (insert "Changed"))))))
        (should-error
         (org-texmacs-parse-buffer source)
         :type 'org-texmacs-model-error)))))

(ert-deftest org-texmacs-model-parse-publishes-only-complete-requests
    ()
  (with-temp-buffer
    (org-mode)
    (insert "$(math \"first\")$ $(math \"second\")$\n")
    (let ((create (symbol-function 'org-texmacs-model-create))
          (calls 0)
          (fail-second t)
          published)
      (cl-letf (((symbol-function 'org-texmacs-model-create)
                 (lambda (&rest args)
                   (should (= calls 2))
                   (setq published (apply create args))))
                ((symbol-function 'org-texmacs--stm-read)
                 (lambda (_raw)
                   (cl-incf calls)
                   (if (= calls 1)
                       '(math "first")
                     (when fail-second
                       (signal 'org-texmacs-parse-error
                               '("Second request failed")))
                     '(math "second")))))
        (should-error
         (org-texmacs-parse-buffer (current-buffer))
         :type 'org-texmacs-parse-error)
        (should (= calls 2))
        (should-not published)
        (setq
         calls 0
         fail-second nil)
        (should
         (eq (org-texmacs-parse-buffer (current-buffer)) published))
        (should
         (equal
          (mapcar
           #'cdr (org-texmacs-model-islands published))
          '((math "first") (math "second"))))))))

(ert-deftest
    org-texmacs-model-parse-raw-block-parameters-are-not-target-policy
    ()
  (dolist (kind '("texmacs" "equation" "equation*"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_"
       kind
       " retained parameter\n\"atom\"\n#+end_"
       kind
       "\n")
      (let* ((model (org-texmacs-parse-buffer (current-buffer)))
             (entry (car (org-texmacs-model-islands model))))
        (should (equal (cdr entry) "atom"))
        (should
         (equal
          (org-element-property :parameters (car entry))
          "retained parameter"))
        (should-not (org-element-contents (car entry)))))))

(ert-deftest org-texmacs-model-object-parser-acquires-structural-keys
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Heading $(math \"title\")$\n"
     "Before $(math \"body\")$  after.\n"
     "~$(math \"opaque\")$~ (math \"bare\")\n\n"
     "#+caption: $(math \"caption\")$\n"
     "#+begin_texmacs\n(math \"block\")\n#+end_texmacs\n")
    (let (requests)
      (let ((reader (symbol-function 'org-texmacs--stm-read)))
        (cl-letf (((symbol-function 'org-texmacs--stm-read)
                   (lambda (raw)
                     (let ((parsed (funcall reader raw)))
                       (push (cadr parsed) requests)
                       parsed))))
          (let* ((source (buffer-string))
                 (model (org-texmacs-parse-buffer (current-buffer)))
                 (islands (org-texmacs-model-islands model))
                 (body (car (rassoc '(math "body") islands)))
                 (caption (car (rassoc '(math "caption") islands)))
                 (block (car (rassoc '(math "block") islands))))
            (should (equal source (buffer-string)))
            (should
             (equal
              (sort requests #'string<)
              '("block" "body" "caption" "title")))
            (should (eq (org-element-type body) 'stm-fragment))
            (should (equal (org-element-property :post-blank body) 2))
            (should (eq (org-element-parent caption) block))
            (should (eq (org-element-type block) 'special-block))
            (should-not (org-element-property :stm-source body))
            (should-not
             (org-element-property
              :org-texmacs-syntax (org-texmacs-model-ast model)))
            (should
             (plist-member
              (org-texmacs-model-context model)
              :link-settings))))))))

(ert-deftest
    org-texmacs-model-object-parser-guards-source-during-parsing
    ()
  (with-temp-buffer
    (org-mode)
    (insert "$(math \"x\")$\n")
    (let ((source (current-buffer)))
      (cl-letf (((symbol-function 'org-texmacs--stm-read)
                 (lambda (_raw)
                   (with-current-buffer source
                     (goto-char (point-max))
                     (insert "Edited"))
                   '(math "x"))))
        (should-error
         (org-texmacs-parse-buffer source)
         :type 'org-texmacs-model-error)))))

(ert-deftest org-texmacs-model-parse-native-trees-and-detached-source
    ()
  (org-texmacs-test--with-environment
   (let (model)
     (with-temp-buffer
       (org-mode)
       (insert
        "* COMMENT Kept :noexport:\n"
        ":PROPERTIES:\n:ANY_PROPERTY: retained\n:END:\n"
        "Body $(math (frac \"α\" \"2\"))$.\n\n"
        "#+begin_texmacs\n\"原子 <alpha>\"\n#+end_texmacs\n\n"
        "#+begin_equation\n(frac \"1\" \"2\")\n#+end_equation\n")
       (let ((state
              (org-texmacs-test--document-buffer-state
               (current-buffer))))
         (cl-letf (((symbol-function 'org-texmacs--document-lower)
                    (lambda (&rest _)
                      (ert-fail "Native model invoked lowering")))
                   ((symbol-function 'org-texmacs-session-open)
                    (lambda (&rest _)
                      (ert-fail "Native model opened a session"))))
           (setq model (org-texmacs-parse-buffer (current-buffer))))
         (should
          (equal
           state
           (org-texmacs-test--document-buffer-state
            (current-buffer))))))
     (should
      (equal
       (mapcar #'cdr (org-texmacs-model-islands model))
       '((math (frac "α" "2")) "原子 <alpha>" (frac "1" "2"))))
     (should
      (org-element-map
       (org-texmacs-model-ast model)
       'property-drawer
       #'identity
       nil
       t))
     (dolist (entry (org-texmacs-model-islands model))
       (when (consp (car entry))
         (should-not (org-element-contents (car entry)))))
     (should (= (length (org-texmacs-model-islands model)) 3)))))

(ert-deftest
    org-texmacs-model-parse-native-context-and-unused-footnotes
    ()
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (insert
      "* A\nBody[fn::Inline $(math \"中\\\"\\\\\")$].\n\n"
      "[fn:unused] Not selected $(math (sqrt \"x\"))$.\n")
     (let ((model (org-texmacs-parse-buffer (current-buffer))))
       (should
        (equal
         (mapcar #'cdr (org-texmacs-model-islands model))
         '((math "中\"\\") (math (sqrt "x")))))
       (should
        (plist-member
         (org-texmacs-model-context model)
         :heading-settings))
       (should
        (org-element-map
         (org-texmacs-model-ast model)
         'footnote-definition
         #'identity
         nil
         t))))))

;;; model-parser.el ends here
