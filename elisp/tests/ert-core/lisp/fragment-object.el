;;; fragment-object.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)

(require 'org-texmacs-fragment-object)

(require 'ox-ascii)

(defun org-texmacs-object-test--parse (source)
  (with-temp-buffer
    (delay-mode-hooks
      (org-mode))
    (insert source)
    (org-texmacs--ast-parse-buffer (current-buffer))))

(defun org-texmacs-object-test--fragments (ast)
  (org-texmacs--call-with-ast-context
   (lambda ()
     (org-element-map ast 'stm-fragment #'identity nil nil nil t))))

(defun org-texmacs-object-test--render (ast)
  (org-texmacs--call-with-ast-context
   (lambda () (org-element-interpret-data ast))))

(ert-deftest org-texmacs-object-carriers-and-native-fallback ()
  (let*
      ((ast
        (org-texmacs-object-test--parse
         "$(custom-tag \"x\")$ \\((x)\\) (math \"bare\") $x$ \\(x\\)\n"))
       (fragments (org-texmacs-object-test--fragments ast)))
    (should
     (equal
      (mapcar
       (lambda (n) (org-element-property :stm-source n)) fragments)
      '("(custom-tag \"x\")" "(x)")))
    (should
     (= 2 (length (org-element-map ast 'latex-fragment #'identity))))
    (dolist (node fragments)
      (should-not (org-element-contents node))
      (should
       (eq
        'paragraph
        (org-element-type (org-element-property :parent node)))))))

(ert-deftest org-texmacs-object-secondary-and-container-roundtrip ()
  (dolist (container
           '("Before %s after.\n"
             "* Title %s here\n"
             "*Consider %s here.*\n"
             "| %s | tail |\n"
             "Text [fn::%s] end.\n"
             "[[https://example.invalid][%s]]\n"
             "#+caption: %s\n| a |\n"
             "#+caption[%s]: Long %s\n| a |\n"))
    (dolist (carrier '("$(math \"x\")$" "\\((math \"x\")\\)"))
      (let* ((source
              (if (string-match-p "Long" container)
                  (format container carrier carrier)
                (format container carrier)))
             (ast (org-texmacs-object-test--parse source))
             (fragments (org-texmacs-object-test--fragments ast))
             (rendered (org-texmacs-object-test--render ast))
             (again (org-texmacs-object-test--parse rendered)))
        (should
         (= (length fragments)
            (if (string-match-p "Long" container)
                2
              1)))
        (should
         (= (length fragments)
            (length (org-texmacs-object-test--fragments again))))
        (should
         (equal rendered (org-texmacs-object-test--render again)))
        (should
         (equal
          (mapcar
           (lambda (n)
             (org-element-property :stm-source n))
           fragments)
          (mapcar
           (lambda (n) (org-element-property :stm-source n))
           (org-texmacs-object-test--fragments again))))
        (let ((types
               '(headline
                 paragraph
                 bold
                 table
                 table-row
                 table-cell
                 link
                 footnote-reference)))
          (should
           (equal
            (org-element-map
             ast types #'org-element-type nil nil nil t)
            (org-element-map
             again types #'org-element-type nil nil nil t))))
        (dolist (node fragments)
          (should
           (equal
            "(math \"x\")"
            (org-element-property :stm-source node))))))))

(ert-deftest org-texmacs-object-native-parent-forms ()
  (let* ((headline
          (org-texmacs-object-test--parse
           "* Title \\((math \"x\")\\)\n"))
         (caption
          (org-texmacs-object-test--parse
           "#+caption: \\((math \"x\")\\)\n| a |\n")))
    (should
     (eq
      'headline
      (org-element-type
       (org-element-property
        :parent
        (car (org-texmacs-object-test--fragments headline))))))
    ;; Compare with actual native secondary-list parenting, not ordinary contents.
    (let* ((node (car (org-texmacs-object-test--fragments caption)))
           (parent (org-element-property :parent node))
           (native
            (with-temp-buffer
              (delay-mode-hooks
                (org-mode))
              (insert "#+caption: \\(x\\)\n| a |\n")
              (car
               (org-element-map
                (org-element-parse-buffer)
                'latex-fragment
                #'identity
                nil
                nil
                nil
                t))))
           (native-parent (org-element-property :parent native)))
      (should (eq (car parent) node))
      (should (eq (car native-parent) native))
      (should
       (equal
        (org-element-type parent)
        (org-element-type native-parent))))))

(ert-deftest org-texmacs-object-interior-is-not-org ()
  (dolist (payload
           '("(math (concat \"a\" \"*\" \"_\" \"[[x]]\"))"
             "(math (concat \"a\" \"\\\\)\" \"b\"))"
             "(custom-tag (concat \"a$)b\" \"\\\"q\\\"\"))"
             "(math\n (frac \"a\" \"b\"))"))
    (let* ((ast
            (org-texmacs-object-test--parse
             (concat "\\(" payload "\\)\n")))
           (node (car (org-texmacs-object-test--fragments ast))))
      (should (equal payload (org-element-property :stm-source node)))
      (should-not (org-element-contents node))
      (should-not
       (org-element-map ast '(bold underline link) #'identity)))))

(ert-deftest org-texmacs-object-opaque-and-literal-priority ()
  (dolist (container
           '("~%s~\n"
             "=%s=\n"
             "#+begin_src text\n%s\n#+end_src\n"
             "#+begin_example\n%s\n#+end_example\n"))
    (dolist (payload '("\\((math \"x\")\\)" "$(math \"incomplete"))
      (should-not
       (org-texmacs-object-test--fragments
        (org-texmacs-object-test--parse
         (format container payload)))))))

(ert-deftest org-texmacs-object-strict-carrier-boundaries ()
  (dolist (source
           '("$(math \"x\"\n"
             "$(math \"x\")\n"
             "\\((math \"x\")\n"
             "$(math \"x\") extra$\n"
             "$(math \"x\") (math \"y\")$\n"
             "\\((math \"x\"\n\n))\\)\n"
             "\\((math \"x\"\n* Heading\n))\\)\n"))
    (should-error
     (org-texmacs-object-test--parse source)
     :type 'org-texmacs-parse-error)))

(ert-deftest org-texmacs-object-lexical-is-not-native-validation ()
  ;; Structurally balanced source must reach conversion, not an Elisp STM reader.
  (should
   (= 1
      (length
       (org-texmacs-object-test--fragments
        (org-texmacs-object-test--parse "$(math #bad)$\n"))))))

(ert-deftest org-texmacs-object-adjacency-and-post-blank ()
  (let* ((ast (org-texmacs-object-test--parse "A $(x)$$(y)$  Z\n"))
         (nodes (org-texmacs-object-test--fragments ast))
         (out (org-texmacs-object-test--render ast)))
    (should
     (equal
      '(0 2)
      (mapcar
       (lambda (n) (org-element-property :post-blank n)) nodes)))
    (should (equal "A \\((x)\\)\\((y)\\)  Z\n" out))
    (should
     (equal
      out
      (org-texmacs-object-test--render
       (org-texmacs-object-test--parse out))))))

(ert-deftest org-texmacs-object-scope-nesting-and-error-restoration ()
  (let ((objects org-element-all-objects)
        (restrictions org-element-object-restrictions)
        (parser (symbol-function 'org-element-latex-fragment-parser))
        (interpreter
         (and (fboundp 'org-element-stm-fragment-interpreter)
              (symbol-function
               'org-element-stm-fragment-interpreter))))
    (should-error
     (org-texmacs--call-with-ast-context
      (lambda ()
        (should (memq 'stm-fragment org-element-all-objects))
        (org-texmacs--call-with-ast-context
         (lambda ()
           (should
            (= 1 (cl-count 'stm-fragment org-element-all-objects)))
           (should
            (= 1
               (length
                (org-texmacs-object-test--fragments
                 (org-texmacs-object-test--parse "$(x)$\n")))))))
        (error "test exception"))))
    (should (eq objects org-element-all-objects))
    (should (eq restrictions org-element-object-restrictions))
    (should
     (eq parser (symbol-function 'org-element-latex-fragment-parser)))
    (should
     (eq
      interpreter
      (and (fboundp 'org-element-stm-fragment-interpreter)
           (symbol-function
            'org-element-stm-fragment-interpreter))))))

(ert-deftest org-texmacs-object-other-backend-unchanged ()
  (let* ((text "Before $(math \"x\")$ after.\n")
         (before (org-export-string-as text 'ascii t)))
    (org-texmacs-object-test--parse text)
    (should (equal before (org-export-string-as text 'ascii t)))
    (should-error
     (org-texmacs-object-test--parse "$(x)\n")
     :type 'org-texmacs-parse-error)
    (should (equal before (org-export-string-as text 'ascii t)))))

(ert-deftest org-texmacs-object-worker-free-and-cache-isolated ()
  (let ((org-element-use-cache t))
    (cl-letf (((symbol-function 'org-texmacs--stm-read)
               (lambda (&rest _) (ert-fail "Recognition parsed STM")))
              ((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) (error "Unexpected worker"))))
      (with-temp-buffer
        (delay-mode-hooks
          (org-mode))
        (insert "Before $(x)$ after.\n")
        (goto-char 10)
        (let ((before (org-element-context)))
          (should
           (= 1
              (length
               (org-texmacs-object-test--fragments
                (org-texmacs--ast-parse-buffer (current-buffer))))))
          (should (equal before (org-element-context)))
          (should org-element-use-cache))))))

(ert-deftest org-texmacs-object-source-preservation-and-independence
    ()
  (let (ast)
    (with-temp-buffer
      (delay-mode-hooks
        (org-mode))
      (insert "Before $(x)$ after.\n* Title $(y)$\n")
      (put-text-property 1 3 'face 'bold)
      (goto-char 6)
      (set-mark 2)
      (setq mark-active t)
      (narrow-to-region 2 15)
      (let ((before (buffer-substring (point-min) (point-max)))
            (bounds (cons (point-min) (point-max)))
            (position (point))
            (mark-position (mark))
            (tick (buffer-chars-modified-tick))
            (property-tick (buffer-modified-tick))
            (modified (buffer-modified-p)))
        (setq ast (org-texmacs--ast-parse-buffer (current-buffer)))
        (should
         (equal-including-properties
          before (buffer-substring (point-min) (point-max))))
        (should (equal bounds (cons (point-min) (point-max))))
        (should (= position (point)))
        (should (= mark-position (mark)))
        (should mark-active)
        (should (= tick (buffer-chars-modified-tick)))
        (should (= property-tick (buffer-modified-tick)))
        (should (eq modified (buffer-modified-p)))))
    (should (= 2 (length (org-texmacs-object-test--fragments ast))))
    (org-texmacs--call-with-ast-context
     (lambda ()
       (org-element-map
        ast t
        (lambda (node)
          (should-not (org-element-property :buffer node))
          (should-not (org-element-property-raw :deferred node)))
        nil nil nil t)))
    (should
     (string-match-p "Title" (org-texmacs-object-test--render ast)))))

(ert-deftest org-texmacs-object-org-copy-is-traversable ()
  (org-texmacs--call-with-ast-context
   (lambda ()
     (let* ((ast
             (org-texmacs-object-test--parse
              "* Heading $(x)$\nBody $(y)$\n"))
            (copy (org-element-copy ast t)))
       (should-not (eq ast copy))
       (should
        (= 2 (length (org-texmacs-object-test--fragments copy))))
       (should
        (equal
         (org-texmacs-object-test--render ast)
         (org-texmacs-object-test--render copy)))))))

(ert-deftest
    org-texmacs-object-interpreter-rejects-invalid-direct-source
    ()
  (dolist (source '("(x) (y)" "\"atomic\"" "(x"))
    (should-error
     (org-texmacs--call-with-ast-context
      (lambda ()
        (org-element-interpret-data
         (org-element-create
          'stm-fragment (list :stm-source source)))))
     :type 'org-texmacs-parse-error)))

(ert-deftest org-texmacs-object-direct-ast-without-source-buffer ()
  (org-texmacs--call-with-ast-context
   (lambda ()
     (let* ((node
             (org-element-create
              'stm-fragment '(:stm-source "(custom-tag \"x\")")))
            (paragraph
             (org-element-create 'paragraph nil "Before " node))
            (ast (org-element-create 'org-data nil paragraph)))
       (should
        (eq
         node (car (org-element-map ast 'stm-fragment #'identity))))
       (should
        (equal
         "Before \\((custom-tag \"x\")\\)\n"
         (org-element-interpret-data ast)))))))

(ert-deftest org-texmacs-object-rejects-invalid-buffer ()
  (should-error
   (org-texmacs--ast-parse-buffer nil)
   :type 'org-texmacs-model-error)
  (with-temp-buffer
    (should-error
     (org-texmacs--ast-parse-buffer (current-buffer))
     :type 'org-texmacs-model-error)))

(ert-deftest org-texmacs-object-owned-syntax-snapshot ()
  (let (ast
        captured)
    (with-temp-buffer
      (delay-mode-hooks
        (org-mode))
      (setq-local org-link-abbrev-alist
                  (list (cons "demo" "https://example.test/%s")))
      (insert "$(x)$\n")
      (setq ast (org-texmacs--ast-parse-buffer (current-buffer)))
      (setq captured (org-element-property :org-texmacs-syntax ast))
      (should
       (equal
        (plist-get
         (plist-get captured :link-settings)
         :global)
        org-link-abbrev-alist))
      (setcdr (car org-link-abbrev-alist) "changed")
      (should
       (equal
        (cdr
         (car
          (plist-get (plist-get captured :link-settings) :global)))
        "https://example.test/%s")))
    (should (plist-member captured :heading-settings))
    (should (= 1 (length (org-texmacs-object-test--fragments ast))))))

(ert-deftest org-texmacs-object-owned-file-link-syntax-snapshot ()
  (dolist (org-element-use-cache '(nil t))
    (with-temp-buffer
      (let ((org-link-abbrev-alist
             '(("global" . "https://global.test/%s")))
            (expected '(("demo" . "https://example.test/%s"))))
        (insert "#+LINK: demo https://example.test/%s\n\n$(x)$\n")
        (org-mode)
        (goto-char (- (point-max) 2))
        (set-mark (1- (point)))
        (setq mark-active t)
        (narrow-to-region (line-beginning-position) (point-max))
        (set-buffer-modified-p nil)
        (let ((text
               (save-restriction
                 (widen)
                 (buffer-string)))
              (position (point))
              (m (mark))
              (bounds (cons (point-min) (point-max)))
              (tick (buffer-modified-tick)))
          (cl-labels
           ((capture
             ()
             (plist-get
              (org-element-property
               :org-texmacs-syntax
               (org-texmacs--ast-parse-buffer (current-buffer)))
              :link-settings)))
           (let* ((links (capture))
                  (local (plist-get links :local)))
             (should (plist-member links :local))
             (should (equal local expected))
             (should
              (equal (plist-get links :global) org-link-abbrev-alist))
             (should-not (assoc "demo" (plist-get links :global)))
             (aset (cdar local) 0 ?X)
             (setcdr (car local) "changed")
             (should (equal (plist-get (capture) :local) expected))))
          (should
           (equal-including-properties
            text
            (save-restriction
              (widen)
              (buffer-string))))
          (should (= position (point)))
          (should (= m (mark)))
          (should mark-active)
          (should (equal bounds (cons (point-min) (point-max))))
          (should (= tick (buffer-modified-tick)))
          (should-not (buffer-modified-p)))))))

(ert-deftest org-texmacs-object-error-preserves-source-state ()
  (with-temp-buffer
    (delay-mode-hooks
      (org-mode))
    (insert "Before $(math \"x\"\n")
    (goto-char 4)
    (set-mark 2)
    (setq mark-active t)
    (narrow-to-region 2 (point-max))
    (let ((text (buffer-string))
          (position (point))
          (m (mark))
          (bounds (cons (point-min) (point-max)))
          (tick (buffer-modified-tick))
          (chars (buffer-chars-modified-tick))
          (modified (buffer-modified-p)))
      (should-error
       (org-texmacs--ast-parse-buffer (current-buffer))
       :type 'org-texmacs-parse-error)
      (should (equal-including-properties text (buffer-string)))
      (should (= position (point)))
      (should (= m (mark)))
      (should mark-active)
      (should (= tick (buffer-modified-tick)))
      (should (= chars (buffer-chars-modified-tick)))
      (should (eq modified (buffer-modified-p)))
      (should (equal bounds (cons (point-min) (point-max)))))))

(ert-deftest org-texmacs-object-suspended-context-is-native ()
  (org-texmacs--call-with-ast-context
   (lambda ()
     (with-temp-buffer
       (delay-mode-hooks
         (org-mode))
       (insert "\\((x)\\)\n")
       (let ((org-texmacs--fragment-object-active nil))
         (should
          (org-element-map
           (org-element-parse-buffer) 'latex-fragment #'identity)))
       (should
        (org-element-map
         (org-element-parse-buffer) 'stm-fragment #'identity))))))

(ert-deftest org-texmacs-object-real-container-limits ()
  (dolist (source
           '("\\((math \"x\"\n* Heading\n)\\)\n"
             "\\((math \"x\"\n#+begin_src text\n)\\)\n#+end_src\n"
             "\\((math \"x\"\n#+begin_quote\n)\\)\n#+end_quote\n"
             "| \\((math \"x\" | other |\n| )\\) | tail |\n"
             "* Title \\((math \"x\"\n)\\)\n"
             "#+caption: \\((math \"x\"\n| )\\) |\n"
             "[[https://example.test][\\((math \"x\"]]\n)\\)\n"))
    (let ((scan (symbol-function 'org-texmacs--fragment-object-scan))
          (create (symbol-function 'org-element-create))
          (objects (symbol-function 'org-element--parse-objects))
          expected-end
          limits
          fragments)
      (cl-letf (((symbol-function 'org-texmacs--fragment-object-scan)
                 (lambda (start limit)
                   (should (integerp expected-end))
                   (should (= limit expected-end))
                   (push (list start limit (point-max)) limits)
                   (funcall scan start limit)))
                ((symbol-function 'org-element--parse-objects)
                 (lambda (beg end &rest args)
                   (let ((old expected-end))
                     (setq expected-end end)
                     (unwind-protect
                         (apply objects beg end args)
                       (setq expected-end old)))))
                ((symbol-function 'org-element-create)
                 (lambda (type &rest args)
                   (when (eq type 'stm-fragment)
                     (push args fragments))
                   (apply create type args))))
        (should-error
         (org-texmacs-object-test--parse source)
         :type 'org-texmacs-parse-error))
      (should limits)
      (should-not fragments))))

(ert-deftest org-texmacs-object-snapshot-copy-boundary ()
  (let (ast
        source-heading)
    (with-temp-buffer
      (delay-mode-hooks
        (org-mode))
      (setq-local org-entities-user
                  (list (list "demo" "X" nil "X" "X" "X" "X")))
      (setq source-heading org-entities-user)
      (insert "* Title $(x)$\n")
      (setq ast (org-texmacs--ast-parse-buffer (current-buffer)))
      (let* ((snapshot (org-element-property :org-texmacs-syntax ast))
             (owned
              (cdr
               (assq
                'org-entities-user
                (plist-get snapshot :heading-settings)))))
        (should-not (eq source-heading owned))
        (should-not (eq (car source-heading) (car owned)))
        (setcar (car owned) "copied")
        (should (equal "demo" (caar source-heading)))))
    (org-texmacs--call-with-ast-context
     (lambda ()
       (let* ((snapshot
               (org-element-property :org-texmacs-syntax ast))
              (copy (org-element-copy ast t)))
         (should
          (eq
           snapshot (org-element-property :org-texmacs-syntax copy)))
         ;; Native custom-property copying is shallow: do not promise ownership.
         (setcar snapshot :changed)
         (should
          (eq
           :changed
           (car (org-element-property :org-texmacs-syntax copy))))
         (org-element-map ast 'stm-fragment #'identity)
         (org-element-interpret-data ast)
         (should
          (eq
           snapshot
           (org-element-property :org-texmacs-syntax ast))))))))

(ert-deftest org-texmacs-object-inner-error-and-normal-restoration ()
  (dolist (cache '(nil t))
    (let ((org-element-use-cache cache)
          (objects org-element-all-objects)
          (restrictions org-element-object-restrictions)
          (parser
           (symbol-function 'org-element-latex-fragment-parser))
          (interpreter
           (and (fboundp 'org-element-stm-fragment-interpreter)
                (symbol-function
                 'org-element-stm-fragment-interpreter))))
      (should
       (eq
        'done
        (org-texmacs--call-with-ast-context
         (lambda ()
           (condition-case nil
               (org-texmacs--call-with-ast-context
                (lambda () (error "inner")))
             (error
              nil))
           (should
            (= 1 (cl-count 'stm-fragment org-element-all-objects)))
           (should
            (= 1
               (length
                (org-texmacs-object-test--fragments
                 (org-texmacs-object-test--parse "$(x)$\n")))))
           'done))))
      (should (eq cache org-element-use-cache))
      (should (eq objects org-element-all-objects))
      (should (eq restrictions org-element-object-restrictions))
      (should
       (eq
        parser (symbol-function 'org-element-latex-fragment-parser)))
      (should
       (eq
        interpreter
        (and (fboundp 'org-element-stm-fragment-interpreter)
             (symbol-function
              'org-element-stm-fragment-interpreter)))))))

(ert-deftest org-texmacs-object-no-external-preparation ()
  (cl-letf (((symbol-function 'org-texmacs--stm-read)
             (lambda (&rest _) (ert-fail "Recognition parsed STM")))
            ((symbol-function 'org-export-as)
             (lambda (&rest _) (ert-fail "Export invoked")))
            ((symbol-function 'insert-file-contents)
             (lambda (&rest _) (ert-fail "File read")))
            ((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _) (ert-fail "Worker invoked"))))
    (should
     (org-texmacs-object-test--fragments
      (org-texmacs-object-test--parse
       "#+include: missing.org\n$(x)$\n")))))

(ert-deftest org-texmacs-object-invalid-buffer-classes ()
  (let ((dead (generate-new-buffer " *dead object test*")))
    (kill-buffer dead)
    (dolist (input (list 42 "not a buffer" dead))
      (should-error
       (org-texmacs--ast-parse-buffer input)
       :type 'org-texmacs-model-error))))

;;; fragment-object.el ends here
