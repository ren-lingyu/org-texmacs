;;; worker.el --- core worker regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-encoding-rejects-invalid-input-before-worker
    ()
  (cl-letf (((symbol-function 'org-texmacs--worker-start)
             (lambda () (ert-fail "Invalid input started worker"))))
    (should-error
     (org-texmacs--native-encode-document nil)
     :type 'org-texmacs-encoding-error)
    (dolist (paths
             '(((2))
               ((-1))
               ((0 0))
               (("0"))
               ((0) (0))
               (() (0))
               ((0) (0 1))
               ((0 . 1))))
      (should-error
       (org-texmacs--native-encode-document
        (org-texmacs--document-create
         :body
         '(document "x")
         :stm-paths paths))
       :type 'org-texmacs-encoding-error))
    (should-error
     (org-texmacs--native-encode-document
      (org-texmacs--document-create :body '(document (raw-data "x"))))
     :type 'org-texmacs-encoding-error)))

(ert-deftest org-texmacs-encoding-wire-is-data ()
  (cl-letf
      (((symbol-function 'org-texmacs--native-call)
        (lambda (make-request operation)
          (should (eq operation 'encode))
          (should
           (equal
            (funcall make-request 7)
            "(encode 7 (\"generic\") () (\"document\" (\"custom.tag*\" \"<alpha>\")) ((0)))\n"))
          'encoded)))
    (should
     (eq
      (org-texmacs--native-encode-document
       (org-texmacs--document-create
        :body
        '(document (custom.tag* "<alpha>"))
        :stm-paths '((0))))
      'encoded))))

(ert-deftest org-texmacs-encoding-decode-contract ()
  (should
   (equal
    (org-texmacs--native-decode
     "(ok 1 (native-body (document \"e9\")))" 1 'encode)
    '(document "e9")))
  (dolist (response
           '("(ok 2 (native-body (document \"00\")))"
             "(ok 1 (document \"00\"))"
             "(ok 1 (native-body (document \"f\")))"
             "(ok 1 (native-body (document \"gg\")))"
             "(ok 1 (native-body (document \"é\")))"
             "(ok 1 (native-body (document \"00\"))) extra"))
    (should-error
     (org-texmacs--native-decode response 1 'encode)
     :type 'org-texmacs-worker-error))
  (should-error
   (org-texmacs--native-decode
    "(encoding-error 1 \"invalid\")" 1 'encode)
   :type 'org-texmacs-encoding-error)
  (should-error
   (org-texmacs--worker-decode "(encoding-error 1 \"invalid\")" 1)
   :type 'org-texmacs-worker-error))

(ert-deftest org-texmacs-test-input-pure-core ()
  (let* ((ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil "Hello")))
         (input (org-texmacs-input-create ast nil)))
    (cl-letf (((symbol-function 'org-texmacs--document-options)
               (lambda () (ert-fail "Unexpected option capture")))
              ((symbol-function 'org-texmacs--document-prepare-source)
               (lambda (&rest _)
                 (ert-fail "Unexpected source parsing")))
              ((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Unexpected worker request")))
              ((symbol-function 'buffer-substring-no-properties)
               (lambda (&rest _)
                 (ert-fail "Unexpected source read"))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document input))
        '(document (concat "Hello")))))
    (dolist (value (list nil t ast (current-buffer)))
      (should-error
       (org-texmacs-document value)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-test-input-ownership-and-mapping ()
  (let* ((leaf (copy-sequence "island"))
         (bold (org-element-create 'bold nil "B"))
         (paragraph (org-element-create 'paragraph nil leaf bold))
         (ast (org-element-create 'org-data nil paragraph))
         (stree (list 'math (copy-sequence "x")))
         (blanks (copy-sequence "\t"))
         (info
          (list
           :parse-tree ast
           :custom (list (copy-sequence "fixed"))))
         (input
          (org-texmacs-input-create
           ast
           info
           :islands (list (cons leaf stree))
           :post-blanks (list (cons bold blanks))))
         (new-ast (org-texmacs-input-ast input))
         (new-paragraph (car (org-element-contents new-ast)))
         (new-leaf (car (org-element-contents new-paragraph)))
         (new-bold (cadr (org-element-contents new-paragraph))))
    (should-not (eq ast new-ast))
    (should-not (eq leaf new-leaf))
    (should (eq (org-element-property :parent paragraph) ast))
    (should (eq (org-element-property :parent new-paragraph) new-ast))
    (should
     (eq (org-element-property :parent new-leaf) new-paragraph))
    (should
     (eq (org-element-property :parent new-bold) new-paragraph))
    (should (eq (caar (org-texmacs-input-islands input)) new-leaf))
    (should
     (eq (caar (org-texmacs-input-post-blanks input)) new-bold))
    (should
     (eq
      (plist-get (org-texmacs-input-info input) :parse-tree) new-ast))
    (aset leaf 0 ?X)
    (aset (cadr stree) 0 ?y)
    (aset blanks 0 ?\s)
    (aset (car (plist-get info :custom)) 0 ?X)
    (org-element-set-contents paragraph nil)
    (should
     (equal
      (plist-get (org-texmacs-input-info input) :custom) '("fixed")))
    (let* ((first (org-texmacs-document input))
           (body (org-texmacs-document-body first)))
      (should
       (equal body '(document (concat (math "x") (strong "B") " "))))
      (should (equal (org-texmacs-document-stm-paths first) '((0 0))))
      (aset (cadr (cadr (cadr body))) 0 ?z)
      (should
       (equal
        (org-texmacs-document-body (org-texmacs-document input))
        '(document (concat (math "x") (strong "B") " ")))))))

(ert-deftest org-texmacs-test-input-secondary-ownership ()
  (let* ((bold (org-element-create 'bold nil "Title"))
         (heading
          (org-element-create
           'headline
           (list :level 1 :raw-value "Title" :title (list bold))))
         (ast
          (org-element-create
           'org-data (list :buffer (current-buffer)) heading))
         (input (org-texmacs-input-create ast nil))
         (copy (org-texmacs-input-ast input))
         (new-heading (car (org-element-contents copy)))
         (new-bold (car (org-element-property :title new-heading))))
    (should-not (org-element-property :buffer copy))
    (should-not (eq bold new-bold))
    (should (eq (org-element-property :parent new-bold) new-heading))
    (should
     (eq
      (org-element-property
       :parent (car (org-element-contents new-bold)))
      new-bold))
    (org-element-set-contents bold '("Changed"))
    (should
     (equal
      (org-texmacs-document-body
       (org-texmacs-document input))
      '(document (section (strong "Title")))))))

(ert-deftest org-texmacs-test-input-document-settings-ownership ()
  (let* ((style
          (list
           (copy-sequence "generic") (copy-sequence "number-europe")))
         (key (copy-sequence "par-first"))
         (value
          (list 'tuple (copy-sequence "中") (copy-sequence "<alpha>")))
         (initial (list (cons key value)))
         (input
          (org-texmacs-input-create
           (org-element-create 'org-data nil)
           nil
           :style style
           :initial initial))
         (first (org-texmacs-document input)))
    (should
     (equal
      (org-texmacs-input-style input) '("generic" "number-europe")))
    (should
     (equal
      (org-texmacs-input-initial input)
      '(("par-first" tuple "中" "<alpha>"))))
    (should
     (equal
      (org-texmacs-document-style first)
      '("generic" "number-europe")))
    (should
     (equal
      (org-texmacs-document-initial first)
      '(("par-first" tuple "中" "<alpha>"))))
    (aset (car style) 0 ?X)
    (aset key 0 ?X)
    (aset (caddr value) 0 ?X)
    (aset (car (org-texmacs-document-style first)) 0 ?X)
    (aset (cadddr (car (org-texmacs-document-initial first))) 0 ?X)
    (let ((second (org-texmacs-document input)))
      (should
       (equal
        (org-texmacs-document-style second)
        '("generic" "number-europe")))
      (should
       (equal
        (org-texmacs-document-initial second)
        '(("par-first" tuple "中" "<alpha>")))))))

(ert-deftest org-texmacs-test-input-rejects-invalid-document-settings
    ()
  (let ((ast (org-element-create 'org-data nil)))
    (dolist (style
             '(nil () ("generic" "") ("generic" 1) ("generic" . "x")))
      (should-error
       (org-texmacs-input-create ast nil :style style)
       :type 'org-texmacs-document-error))
    (dolist (initial
             '((1)
               (("" . "x"))
               (("key" . 1))
               (("key" . "x") ("key" . "y"))
               (("key" . "x") . "tail")))
      (should-error
       (org-texmacs-input-create ast nil :initial initial)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-test-input-rejects-invalid-ownership ()
  (let* ((leaf (copy-sequence "x"))
         (paragraph (org-element-create 'paragraph nil leaf))
         (ast (org-element-create 'org-data nil paragraph)))
    (dolist (mapping
             (list
              (list (cons (copy-sequence "x") '(math "x")))
              (list (cons leaf '(math "x")) (cons leaf '(math "y")))))
      (should-error
       (org-texmacs-input-create ast nil :islands mapping)
       :type 'org-texmacs-document-error))
    (should-error
     (org-texmacs-input-create
      ast
      nil
      :post-blanks (list (cons leaf "x")))
     :type 'org-texmacs-document-error)
    (should-error
     (org-texmacs-input-create
      ast nil
      :islands (list (cons leaf '(math 1))))
     :type 'org-texmacs-document-error)
    (org-element-set-contents ast (list paragraph paragraph))
    (should-error
     (org-texmacs-input-create ast nil)
     :type 'org-texmacs-document-error)
    (org-element-set-contents ast (list ast))
    (should-error
     (org-texmacs-input-create ast nil)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-test-input-rejects-unresolved-and-opaque-data
    ()
  (let ((ast (org-element-create 'org-data nil)))
    (dolist (info
             (list
              '(:key)
              '(:key t :key nil)
              '(key value)
              (list :source (current-buffer))))
      (should-error
       (org-texmacs-input-create ast info)
       :type 'org-texmacs-document-error))
    (let ((cycle (list 'cycle)))
      (setcdr cycle cycle)
      (should-error
       (org-texmacs-input-create ast (list :custom cycle))
       :type 'org-texmacs-document-error))
    (org-element-put-property ast :deferred t)
    (cl-letf (((symbol-function 'org-element-properties-mapc)
               (lambda (&rest _)
                 (ert-fail
                  "Must reject before property resolution"))))
      (should-error
       (org-texmacs-input-create ast nil)
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-test-input-captures-formatter-without-calling-it
    ()
  (let* ((ast
          (org-element-create
           'org-data nil
           (org-element-create
            'headline '(:level 1 :raw-value "T" :title ("T")))))
         (calls 0)
         input)
    (cl-letf (((symbol-function 'org-texmacs-test--input-formatter)
               (lambda (&rest _)
                 (cl-incf calls)
                 "First")))
      (setq input
            (org-texmacs-input-create
             ast
             '(:texmacs-format-headline-function
               org-texmacs-test--input-formatter)))
      (should (zerop calls))
      (cl-letf (((symbol-function 'org-texmacs-test--input-formatter)
                 (lambda (&rest _) "Second")))
        (should
         (equal
          (org-texmacs-document-body
           (org-texmacs-document input))
          '(document (section "First")))))
      (should (= calls 1)))))

(ert-deftest org-texmacs-test-input-defaults-ignore-ambient-options ()
  (let ((org-export-with-todo-keywords nil)
        (org-export-with-priority t)
        (org-export-with-tags nil)
        (org-texmacs-format-headline-function
         (lambda (&rest _)
           (ert-fail "Unexpected ambient formatter"))))
    (let* ((ast
            (org-element-create
             'org-data nil
             (org-element-create
              'headline
              '(:level
                1
                :raw-value "T"
                :title ("T")
                :todo-keyword "TODO"
                :todo-type todo
                :tags ("tag")))))
           (input (org-texmacs-input-create ast nil)))
      (should
       (equal
        (org-texmacs-document-body (org-texmacs-document input))
        '(document
          (section (concat (strong "TODO") " " "T" " " ":tag:"))))))))

(ert-deftest org-texmacs-test-setup-check-passes ()
  (let ((result (org-texmacs-check-setup)))
    (should (car result))
    (should (stringp (cdr result)))))

(ert-deftest org-texmacs-test-capability-types ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (command)
               (and (string= command "texmacs")
                    "/test/bin/texmacs"))))
    (let ((result
           (org-texmacs--check-capabilities
            '((org-element-create . function)
              (features . variable)
              (texmacs . executable)))))
      (should (car result)))))

(ert-deftest org-texmacs-test-capability-check-reports-all-failures ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (_command) nil)))
    (let ((result
           (org-texmacs--check-capabilities
            '((org-texmacs-test--missing-function . function)
              (org-texmacs-test--missing-variable . variable)
              (org-texmacs-test--missing-executable . executable)
              (org-element-create . unsupported)))))
      (should-not (car result))
      (dolist (name
               '(org-texmacs-test--missing-function
                 org-texmacs-test--missing-variable
                 org-texmacs-test--missing-executable
                 org-element-create))
        (should
         (string-match-p
          (regexp-quote (symbol-name name)) (cdr result)))))))

(ert-deftest org-texmacs-test-capability-check-rejects-malformed-input
    ()
  (let ((result
         (org-texmacs--check-capabilities
          '(org-element-create . function))))
    (should-not (car result))
    (should (string-match-p "malformed" (cdr result)))))

(ert-deftest org-texmacs-test-ensure-setup-signals-error ()
  (let ((org-texmacs--capability-alist
         '((org-texmacs-test--missing-function . function))))
    (should-error
     (org-texmacs--ensure-setup)
     :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-worker-rejects-reentrant-request ()
  (let ((org-texmacs--worker-busy t))
    (cl-letf (((symbol-function 'org-texmacs--worker-start)
               (lambda ()
                 (ert-fail
                  "A nested request must not touch the worker"))))
      (should-error
       (org-texmacs--worker-request "(sqrt \"x\")")
       :type 'org-texmacs-worker-error))))

(ert-deftest org-texmacs-test-worker-rejects-invalid-responses ()
  (dolist (response
           '("(ok 2 (sqrt \"x\"))"
             "(ok 1 (sqrt \"x\")) extra"
             "(ok 1 (sqrt 42))"
             "(unknown 1 \"x\")"
             "(error 1 42)"))
    (should-error
     (org-texmacs--worker-decode response 1)
     :type 'org-texmacs-worker-error)))

(ert-deftest org-texmacs-test-worker-decode-scopes-reader-settings ()
  (dolist (setting '(t nil))
    (let ((read-circle setting)
          (reader (symbol-function 'read-from-string))
          (predicate (symbol-function 'org-texmacs--stree-p))
          (response "(ok 1 (math \"x\"))")
          (reader-settings nil)
          (validation-settings nil))
      (cl-letf (((symbol-function 'read-from-string)
                 (lambda (string &rest args)
                   (when (equal string response)
                     (push read-circle reader-settings))
                   (apply reader string args)))
                ((symbol-function 'org-texmacs--stree-p)
                 (lambda (node)
                   (push read-circle validation-settings)
                   (funcall predicate node))))
        (should
         (equal (org-texmacs--worker-decode response 1) '(math "x"))))
      (should (equal reader-settings '(nil)))
      (should validation-settings)
      (should
       (cl-every
        (lambda (value) (eq value setting)) validation-settings))
      (should (eq read-circle setting)))))

(ert-deftest org-texmacs-test-worker-decode-rejects-reader-references
    ()
  (let ((read-circle t))
    (dolist (response
             '("(ok 1 #1=(math . #1#))"
               "(ok 1 (concat #1=\"x\" #1#))"))
      (should-error
       (org-texmacs--worker-decode response 1)
       :type 'invalid-read-syntax)
      (should read-circle)
      (should
       (equal
        (org-texmacs--worker-decode
         "(ok 1 (sqrt \"x\"))" 1)
        '(sqrt "x"))))))

(ert-deftest
    org-texmacs-test-worker-decode-escaped-response-and-errors
    ()
  (should
   (equal
    (org-texmacs--worker-decode
     "(\\o\\k 1 (\\m\\a\\t\\h \"中文\"))\n" 1)
    '(math "中文")))
  (should-error
   (org-texmacs--worker-decode "(error 1 \"Invalid STM source\")" 1)
   :type 'org-texmacs-parse-error)
  (should
   (equal
    (org-texmacs--worker-decode "(ok 1 (math \"x\"))" 1)
    '(math "x"))))

;;; worker.el ends here
