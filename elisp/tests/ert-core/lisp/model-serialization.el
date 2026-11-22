;;; model-serialization.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'org-texmacs-serialize)

(defun org-texmacs-test--parse-model-text (text)
  "Construct a model from complete Org TEXT in a disposable source buffer."
  (with-temp-buffer
    (org-mode)
    (insert text)
    (org-texmacs-parse-buffer (current-buffer))))

(defun org-texmacs-test--native-model (text)
  "Parse complete Org TEXT, disposing its source before returning the model."
  (with-temp-buffer
    (org-mode)
    (insert text)
    (org-texmacs-parse-buffer (current-buffer))))

(ert-deftest org-texmacs-model-serialize-empty-document ()
  (cl-letf (((symbol-function 'org-texmacs--worker-call)
             (lambda (&rest _)
               (ert-fail "Empty model needs no native process"))))
    (should
     (equal
      (org-texmacs-model-serialize
       (org-texmacs-test--parse-model-text ""))
      ""))))

(ert-deftest
    org-texmacs-model-serialize-full-org-without-native-output
    ()
  (let ((text
         (concat
          "#+TITLE: Demo\n#+INCLUDE: \"missing.org\"\n"
          "# Keep this comment\n\n* COMMENT Heading :noexport:\n"
          ":PROPERTIES:\n:CUSTOM_ID: kept\n:END:\n"
          "Body *bold*  tail and [[https://example.org][link]].\n\n"
          "- [ ] Task\n\n#+begin_unfamiliar\nRetained.\n"
          "#+end_unfamiliar\n\n[fn:unused] Kept definition.\n")))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (&rest _)
                 (ert-fail "Pure Org requested native output")))
              ((symbol-function 'org-texmacs--document-lower)
               (lambda (&rest _)
                 (ert-fail "Serialized through lowering"))))
      (let* ((model (org-texmacs-test--parse-model-text text))
             (before (org-texmacs-test--model-meaning model))
             (output (org-texmacs-model-serialize model))
             (again (org-texmacs-test--parse-model-text output)))
        (should
         (equal before (org-texmacs-test--model-meaning again)))
        (should
         (equal before (org-texmacs-test--model-meaning model)))
        (should (equal output (org-texmacs-model-serialize again)))
        (should (string-match-p "missing.org" output))
        (should (string-match-p "\\*bold\\*  tail" output))))))

(ert-deftest
    org-texmacs-model-serialize-authoritative-block-and-inline
    ()
  (let ((parsed
         (org-texmacs-test--parse-model-text
          (concat
           "Before $(math \"inline\")$.\n\n"
           "#+CAPTION: Caption\n#+begin_texmacs\n"
           "(math \"old\")\n#+end_texmacs\n"))))
    (let* ((replacement
            (mapcar
             (lambda (entry)
               (cons
                (car entry)
                (if (eq (org-element-type (car entry)) 'special-block)
                    '(frac "new" "2")
                  (cdr entry))))
             (org-texmacs-model-islands parsed)))
           (model
            (org-texmacs-model-create
             (org-texmacs-model-ast parsed)
             :islands replacement
             :context
             (org-texmacs-model-context parsed))))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Serialization requested native parsing")))
                ((symbol-function 'org-texmacs--stm-read)
                 (lambda (&rest _)
                   (ert-fail "Output guard reparsed STM")))
                ((symbol-function 'org-texmacs--worker-serialize-stm)
                 (lambda (&rest _)
                   (ert-fail "Serialization invoked a worker"))))
        (let ((output (org-texmacs-model-serialize model)))
          (should
           (string-match-p
            (regexp-quote "\\((math \"inline\")\\)") output))
          (should (string-match-p "frac \"new\" \"2\"" output))
          (should-not (string-match-p "old" output))
          (should
           (equal
            (mapcar
             #'cdr (org-texmacs-model-islands model))
            '((math "inline") (frac "new" "2")))))))))

(ert-deftest
    org-texmacs-model-serialize-discards-preparsed-block-residue
    ()
  (let* ((context
          (org-texmacs-model-context
           (org-texmacs-test--parse-model-text "")))
         (model
          (with-temp-buffer
            (org-mode)
            (insert
             "#+begin_equation* kept\nOLD RESIDUE\n#+end_equation*\n")
            (let* ((ast (org-element-parse-buffer))
                   (block
                    (org-element-map
                     ast 'special-block #'identity nil t)))
              (org-texmacs-model-create
               ast
               :islands
               (list (cons block '(sqrt "new")))
               :context context)))))
    (cl-letf (((symbol-function 'org-texmacs--worker-serialize-stm)
               (lambda (_tree) "(sqrt \"new\")")))
      (let ((output (org-texmacs-model-serialize model)))
        (should (string-match-p "begin_equation\\* kept" output))
        (should (string-match-p "sqrt \"new\"" output))
        (should-not (string-match-p "RESIDUE" output))
        (should
         (equal
          (org-element-contents
           (car
            (org-element-contents
             (org-element-map
              (org-texmacs-model-ast model)
              'special-block
              #'identity
              nil
              t))))
          '("OLD RESIDUE\n")))))))

(ert-deftest
    org-texmacs-model-serialize-rejects-valid-inexpressible-islands
    ()
  (let* ((base (org-texmacs-test--parse-model-text "Text.\n"))
         (context (org-texmacs-model-context base)))
    (dolist (position '(paragraph headline))
      (let* ((leaf (org-element-create 'stm-fragment nil))
             (node
              (if (eq position 'headline)
                  (org-element-create
                   'headline (list :level 1 :title (list leaf)))
                (org-element-create 'paragraph nil leaf)))
             (model
              (org-texmacs-model-create
               (org-element-create 'org-data nil node)
               :context context
               :islands
               (list
                (cons
                 leaf
                 (if (eq position 'headline)
                     '(math (bad\ tag "title"))
                   '(bad\ tag "2")))))))
        (cl-letf (((symbol-function
                    'org-texmacs--worker-serialize-stm)
                   (lambda (&rest _)
                     (ert-fail
                      "Inexpressible model reached worker"))))
          (let ((err
                 (should-error
                  (org-texmacs-model-serialize model)
                  :type 'org-texmacs-model-serialization-error)))
            (should
             (string-match-p
              "AST path" (error-message-string err)))))))))

(ert-deftest
    org-texmacs-model-serialize-explicit-context-and-node-support
    ()
  (let* ((plain
          (org-texmacs-model-create
           (org-element-create 'org-data nil)))
         (context
          (org-texmacs-model-context
           (org-texmacs-test--parse-model-text ""))))
    (should-error
     (org-texmacs-model-serialize plain)
     :type 'org-texmacs-model-serialization-error)
    (let ((model
           (org-texmacs-model-create
            (org-element-create
             'org-data
             nil
             (org-element-create 'future-org-extension nil "Keep"))
            :context context)))
      (should-error
       (org-texmacs-model-serialize model)
       :type 'org-texmacs-model-serialization-error)
      (should (org-texmacs-model-inspect model)))))

(ert-deftest
    org-texmacs-model-serialize-rejects-loss-and-unmapped-source
    ()
  (let* ((base (org-texmacs-test--parse-model-text "Ordinary.\n"))
         (ast (car (org-texmacs--model-snapshot base)))
         (context (org-texmacs-model-context base))
         (paragraph
          (org-element-map ast 'paragraph #'identity nil t)))
    ;; Deliberate supplied metadata has no native Org textual representation.
    (org-element-put-property
     paragraph
     :unexpressed-property "must survive")
    (let ((model (org-texmacs-model-create ast :context context)))
      (should-error
       (org-texmacs-model-serialize model)
       :type 'org-texmacs-model-serialization-error))
    (let ((model
           (org-texmacs-model-create
            (org-element-create
             'org-data nil
             (org-element-create
              'paragraph nil "$(math \"unmapped\")$\n"))
            :context context)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Serialization requested native parsing")))
                ((symbol-function 'org-texmacs--stm-read)
                 (lambda (&rest _)
                   (ert-fail "Output guard started STM parser"))))
        (should-error
         (org-texmacs-model-serialize model)
         :type 'org-texmacs-model-serialization-error)))))

(ert-deftest
    org-texmacs-model-to-buffer-is-editable-and-retains-syntax
    ()
  (let* ((model
          (org-texmacs-test--parse-model-text "* Heading\nText.\n"))
         (existing (generate-new-buffer " *model-org-existing*"))
         (source (current-buffer))
         (org-mode-hook
          (list (lambda () (ert-fail "Output mode hook ran"))))
         output)
    (unwind-protect
        (progn
          (with-current-buffer existing
            (insert "Untouched"))
          (setq output
                (org-texmacs-model-to-buffer
                 model (buffer-name existing)))
          (should (eq source (current-buffer)))
          (should-not (eq output existing))
          (should
           (equal
            (with-current-buffer existing
              (buffer-string))
            "Untouched"))
          (with-current-buffer output
            (should (derived-mode-p 'org-mode))
            (should-not buffer-read-only)
            (should-not buffer-file-name)
            (should
             (equal
              default-directory
              (plist-get
               (org-texmacs-model-context model)
               :resource-base)))
            (should
             (equal
              (org-texmacs-test--model-meaning model)
              (org-texmacs-test--model-meaning
               (org-texmacs-parse-buffer output))))))
      (when (buffer-live-p output)
        (kill-buffer output))
      (kill-buffer existing))))

(ert-deftest org-texmacs-model-to-buffer-failure-allocation-boundary
    ()
  (let ((model (org-texmacs-test--parse-model-text "Text.\n")))
    (cl-letf (((symbol-function 'org-texmacs-model-serialize)
               (lambda (&rest _)
                 (signal 'org-texmacs-model-serialization-error
                         '("Expected"))))
              ((symbol-function 'generate-new-buffer)
               (lambda (&rest _)
                 (ert-fail "Allocated before serialization"))))
      (should-error
       (org-texmacs-model-to-buffer model)
       :type 'org-texmacs-model-serialization-error))
    (let ((generate (symbol-function 'generate-new-buffer))
          created)
      (cl-letf (((symbol-function 'org-texmacs-model-serialize)
                 (lambda (_) "Text.\n"))
                ((symbol-function 'generate-new-buffer)
                 (lambda (&rest args)
                   (setq created (apply generate args))))
                ((symbol-function 'org-texmacs--serialize-initialize)
                 (lambda (&rest _)
                   (error "Expected initialization failure"))))
        (should-error (org-texmacs-model-to-buffer model)))
      (should-not (buffer-live-p created)))))

(ert-deftest
    org-texmacs-model-serialize-captured-todo-and-link-context
    ()
  (let (model
        output)
    (let ((org-link-parameters
           (cons '("saved-type" :follow ignore) org-link-parameters)))
      (with-temp-buffer
        (insert
         "#+TODO: READY | FINISHED\n"
         "#+LINK: saved saved-type:%s\n"
         "*** FINISHED Title\n[[saved:item][Link]]\n")
        (org-mode)
        (setq-local org-odd-levels-only t)
        (setq model (org-texmacs-parse-buffer (current-buffer)))))
    (should
     (equal
      (org-element-property
       :type
       (org-element-map
        (org-texmacs-model-ast model) 'link #'identity nil t))
      "saved-type"))
    (let ((regexes
           (list
            org-link-types-re
            org-link-plain-re
            org-element--object-regexp)))
      (unwind-protect
          (progn
            (setq output (org-texmacs-model-to-buffer model))
            (let* ((again (org-texmacs-parse-buffer output))
                   (ast (org-texmacs-model-ast again))
                   (heading
                    (org-element-map ast 'headline #'identity nil t))
                   (link
                    (org-element-map ast 'link #'identity nil t)))
              (should (= (org-element-property :level heading) 2))
              (should
               (eq (org-element-property :todo-type heading) 'done))
              (should
               (equal (org-element-property :type link) "saved-type"))
              (should
               (equal (org-element-property :path link) "item")))
            (should
             (equal
              regexes
              (list
               org-link-types-re
               org-link-plain-re
               org-element--object-regexp))))
        (when (buffer-live-p output)
          (kill-buffer output))))))

(ert-deftest org-texmacs-worker-serialize-stm-wire-and-error-lifecycle
    ()
  (let (request
        (stops 0))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (builder)
                 (setq request (funcall builder 7))
                 '(ok 7 (serialized-stm "(math \"中\")"))))
              ((symbol-function 'org-texmacs--worker-stop)
               (lambda () (cl-incf stops))))
      (should
       (equal
        (org-texmacs--worker-serialize-stm '(math "中"))
        "(math \"中\")"))
      (should (equal (read request) '(serialize-stm 7 ("math" "中"))))
      (should (zerop stops)))
    (dolist (reply
             '((stm-serialization-error 7 "unsupported")
               (ok 7 (wrong "x"))
               (ok 7 (serialized-stm "\n"))))
      (let ((before stops))
        (cl-letf (((symbol-function 'org-texmacs--worker-call)
                   (lambda (_) reply))
                  ((symbol-function 'org-texmacs--worker-stop)
                   (lambda () (cl-incf stops))))
          (should-error
           (org-texmacs--worker-serialize-stm '(math "x"))
           :type
           (if (eq (car reply) 'stm-serialization-error)
               'org-texmacs-model-serialization-error
             'org-texmacs-worker-error)))
        (should
         (= stops
            (+ before
               (if (eq (car reply) 'stm-serialization-error)
                   0
                 1))))))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (&rest _)
                 (ert-fail "Invalid tree started worker"))))
      (let ((cycle (list 'math nil)))
        (setcar (cdr cycle) cycle)
        (should-error
         (org-texmacs--worker-serialize-stm cycle)
         :type 'org-texmacs-model-serialization-error)))))

(ert-deftest org-texmacs-model-serialize-preserves-external-id-link ()
  (let ((text "#+TITLE: T\n[[id:external-id][Target]].\n"))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (&rest _)
                 (ert-fail "ID round trip needs no native process")))
              ((symbol-function 'org-id-find)
               (lambda (&rest _)
                 (ert-fail "Model parsing queried the ID database")))
              ((symbol-function 'org-id-find-id-file)
               (lambda (&rest _)
                 (ert-fail "Model parsing queried the ID database"))))
      (let* ((model (org-texmacs-test--parse-model-text text))
             (before (org-texmacs-test--model-meaning model))
             (output (org-texmacs-model-serialize model)))
        ;; The original id: identity round-trips; no file path or suffix
        ;; conversion is invented by the model layer.
        (should
         (string-match-p
          (regexp-quote "[[id:external-id][Target]]") output))
        (should-not (string-match-p "external-id.org" output))
        (should-not (string-match-p "external-id.pdf" output))
        (should
         (equal
          before
          (org-texmacs-test--model-meaning
           (org-texmacs-test--parse-model-text output))))
        (should
         (equal
          output
          (org-texmacs-model-serialize
           (org-texmacs-test--parse-model-text output))))))))

(ert-deftest org-texmacs-object-serialization-is-pure-and-idempotent
    ()
  (let ((org-texmacs-program
         "/nonexistent/org-texmacs-test-executable"))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (&rest _)
                 (ert-fail "Model attempted native I/O")))
              ((symbol-function 'org-texmacs--worker-start)
               (lambda (&rest _) (ert-fail "Model started TeXmacs"))))
      (let*
          ((model
            (org-texmacs-test--parse-model-text
             (concat
              "* COMMENT Title $(math \"title\")$ :noexport:\n"
              "Before $(math \"x\")$$(math \"x\")$  after.\n\n"
              "A[fn::Note $(math \"note\")$].\n\n"
              "[[https://example.test][Before $(math \"link\")$ after]]\n\n"
              "| $(math \"cell\")$ |\n\n"
              "#+caption[$(math \"short\")$]: $(math \"long\")$\n"
              "#+name: block\n#+begin_texmacs\n(math \"block\")\n#+end_texmacs\n\n"
              "#+begin_equation\n(math \"equation\")\n#+end_equation\n\n"
              "#+begin_equation*\n\"atom\"\n#+end_equation*\n\n"
              "[fn:unused] Retained $(math \"unused\")$.\n")))
           (first
            (car
             (rassoc '(math "x") (org-texmacs-model-islands model))))
           (changed
            (org-texmacs-model-replace-stm
             model first '(0) "changed"))
           (output
            (cl-letf (((symbol-function 'org-texmacs--stm-read)
                       (lambda (&rest _)
                         (ert-fail "Serialization reread STM text"))))
              (org-texmacs-model-serialize changed)))
           (again (org-texmacs-test--parse-model-text output)))
        (should (= 12 (length (org-texmacs-model-islands again))))
        (should
         (equal
          (org-texmacs-test--model-meaning changed)
          (org-texmacs-test--model-meaning again)))
        (should (equal output (org-texmacs-model-serialize again)))
        (should
         (string-match-p
          (regexp-quote
           "Before \\((math \"changed\")\\)\\((math \"x\")\\)  after.")
          output))
        (should
         (string-match-p (regexp-quote "#+name: block") output))
        (should (string-match-p (regexp-quote "[fn:unused]") output)))
      (should-error
       (org-texmacs-test--parse-model-text "$(math 123)$\n")
       :type 'org-texmacs-parse-error))))

(ert-deftest
    org-texmacs-object-serialization-reports-representation-failures
    ()
  (dolist (fixture
           '(("| $(math \"x\")$ |\n" "a|b" org-container)
             ("[[https://example.test][$(math \"x\")$]]\n"
              "a]]b"
              org-container)
             ("$(math \"x\")$\n"
              (math (bad\ tag "x"))
              unsupported-symbol)))
    (let* ((model (org-texmacs-test--parse-model-text (car fixture)))
           (key (caar (org-texmacs-model-islands model)))
           (new (cadr fixture))
           (changed
            (org-texmacs-model-replace-stm
             model key (and (stringp new) '(0)) new))
           (before (org-texmacs-model-inspect changed)))
      (let ((err
             (should-error
              (org-texmacs-model-serialize changed)
              :type 'org-texmacs-model-serialization-error)))
        (should (eq (plist-get (nth 2 err) :reason) (nth 2 fixture))))
      (should (equal before (org-texmacs-model-inspect changed))))))

(ert-deftest org-texmacs-model-native-org-round-trip-and-idempotence
    ()
  (org-texmacs-test--with-environment
   (let* ((model
           (org-texmacs-test--native-model
            (concat
             "#+TITLE: Native model\n# Kept comment\n\n"
             "* COMMENT Heading :noexport:\n"
             ":PROPERTIES:\n:CUSTOM_PROPERTY: kept\n:END:\n"
             "Before $(math (frac \"α\" \"中\"))$.\n\n"
             "A[fn::Note $(math (sqrt \"x\"))$].\n\n"
             "#+CAPTION: Caption *kept*\n"
             "#+begin_TeXmAcS extra parameters\n"
             "(math \"old block\")\n#+end_TeXmAcS\n\n"
             "[fn:unused] Retained $(math \"unused\")$.\n")))
          (before (org-texmacs-test--model-meaning model))
          output)
     (cl-letf (((symbol-function 'org-texmacs--document-lower)
                (lambda (&rest _)
                  (ert-fail "Org serialization invoked lowering")))
               ((symbol-function 'org-texmacs-session-open)
                (lambda (&rest _)
                  (ert-fail "Org serialization opened a session")))
               ((symbol-function 'org-texmacs--worker-request)
                (lambda (&rest _)
                  (ert-fail
                   "Org serialization requested native work")))
               ((symbol-function 'org-texmacs--stm-read)
                (lambda (&rest _)
                  (ert-fail "Output guard reparsed known STM"))))
       (setq output (org-texmacs-model-serialize model)))
     (let ((again (org-texmacs-test--native-model output)))
       (should (equal before (org-texmacs-test--model-meaning again)))
       (should (equal output (org-texmacs-model-serialize again))))
     (should
      (equal before (org-texmacs-test--model-meaning model))))))

(ert-deftest org-texmacs-model-native-block-root-and-delimiter-leaves
    ()
  (org-texmacs-test--with-environment
   (dolist (kind '("texmacs" "equation" "equation*"))
     (let* ((parsed
             (org-texmacs-test--native-model
              (concat
               "#+begin_"
               kind
               " extra\n(math \"old\")\n"
               "#+end_"
               kind
               "\n")))
            (tree '(sqrt "new\n* Heading\n#+end_texmacs\n\t中\"\\"))
            (model
             (org-texmacs-model-create
              (org-texmacs-model-ast parsed)
              :context (org-texmacs-model-context parsed)
              :islands
              (list
               (cons
                (caar (org-texmacs-model-islands parsed)) tree))))
            (text (org-texmacs-model-serialize model))
            (again (org-texmacs-test--native-model text)))
       (should-not (string-match-p "old" text))
       (should
        (equal
         (mapcar #'cdr (org-texmacs-model-islands again))
         (list tree)))
       (should
        (equal
         (org-texmacs-test--model-meaning model)
         (org-texmacs-test--model-meaning again)))
       (should (equal text (org-texmacs-model-serialize again)))))))

(ert-deftest org-texmacs-model-native-generated-buffer-round-trip ()
  (org-texmacs-test--with-environment
   (let* ((model
           (org-texmacs-test--native-model
            "Before $(math (frac \"1\" \"2\"))$.\n"))
          output)
     (unwind-protect
         (progn
           (setq output (org-texmacs-model-to-buffer model))
           (should
            (equal
             (org-texmacs-test--model-meaning model)
             (org-texmacs-test--model-meaning
              (org-texmacs-parse-buffer output)))))
       (when (buffer-live-p output)
         (kill-buffer output))))))

;;; model-serialization.el ends here
