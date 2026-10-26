;;; preprocess.el --- core preprocess regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-preprocess-original-and-working-snapshots ()
  (with-temp-buffer
    (org-mode)
    (insert "Original\n")
    (let* ((canonical (buffer-string))
           (working (copy-sequence "Derived\n"))
           (context
            (list
             :texmacs-original-source canonical
             :texmacs-source-origins '((1 9 0 nil derived))))
           (input
            (org-texmacs--prepare-buffer
             (current-buffer) #'identity nil nil nil nil nil
             (lambda (&rest _)
               (list
                :sources nil
                :source working
                :context context)))))
      (should
       (equal
        (plist-get
         (org-texmacs-input-info input)
         :texmacs-original-source)
        "Original\n"))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document input))
        '(document (concat "Derived "))))
      (aset working 0 ?X)
      (setcar
       (cadr (memq :texmacs-source-origins context)) '(invalid))
      (should
       (equal
        (plist-get
         (org-texmacs-input-info input)
         :texmacs-source-origins)
        '((1 9 0 nil derived))))
      (should (equal (buffer-string) canonical)))))

(ert-deftest org-texmacs-preprocess-island-ranges-owned-before-filters
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Canonical\n")
    (let ((filters 0)
          (org-export-filter-parse-tree-functions nil))
      (setq org-export-filter-parse-tree-functions
            (list
             (lambda (tree _backend _info)
               (cl-incf filters)
               tree)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _) '(math "x"))))
        (let* ((input
                (org-texmacs--prepare-buffer
                 (current-buffer) #'identity nil nil nil nil nil
                 (lambda (&rest _)
                   (list
                    :sources nil
                    :source "(math \"x\")\n(math \"x\")\n"
                    :context '(:texmacs-source-origins t)
                    :annotate
                    (lambda (prepared)
                      (setcar
                       (nthcdr 4 prepared)
                       (plist-put
                        (nth 4 prepared)
                        :texmacs-island-origins
                        (mapcar
                         (lambda
                           (request)
                           (cons (caar request) (nth 3 request)))
                         (nth 2 prepared)))))))))
               (origins
                (plist-get
                 (org-texmacs-input-info input)
                 :texmacs-island-origins)))
          (should (= filters 1))
          (should
           (equal (mapcar #'cdr origins) '((1 . 11) (12 . 22))))
          (should
           (eq
            (caar origins) (caar (org-texmacs-input-islands input))))
          (should-not (eq (caar origins) (car (cadr origins))))
          (should
           (org-texmacs-document-p (org-texmacs-document input))))))))

(ert-deftest
    org-texmacs-preprocess-original-source-guard-before-working-parse
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Original\n")
    (let ((source (current-buffer)))
      (should-error
       (org-texmacs--prepare-buffer
        source #'identity nil nil nil nil nil
        (lambda (&rest _)
          (with-current-buffer source
            (insert "Changed"))
          '(:sources nil :source "Derived\n")))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-preprocess-component-native-fixed-sources ()
  (org-texmacs-test--with-bibliography-files
   (write-region "(math \"same\")\n" nil "a.org" nil 'silent)
   (write-region "#+INCLUDE: \"a.org\"\n" nil "b.org" nil 'silent)
   (insert "#+INCLUDE: \"a.org\"\n#+INCLUDE: \"b.org\"\n")
   (let ((result (org-texmacs-test--compose)))
     (should (= (length (plist-get result :sources)) 2))
     (should (= (length (plist-get result :receipts)) 2))
     (should
      (equal
       (plist-get result :source)
       "(math \"same\")\n(math \"same\")\n"))
     (should-not (plist-member result :ranges)))))

(ert-deftest
    org-texmacs-preprocess-component-hooks-generated-and-protected
    ()
  (org-texmacs-test--with-bibliography-files
   (insert
    "#+begin_texmacs\n#+INCLUDE: \"absent.org\"\n#+SETUPFILE: absent.org\n#+end_texmacs\n")
   (let* (events
          (org-export-before-processing-functions
           (list
            (lambda (backend)
              (should (eq backend 'texmacs))
              (push 'before events)
              (goto-char (point-min))
              (insert "Generated prefix\n")
              23)))
          (org-export-before-parsing-functions
           (list
            (lambda (_backend)
              (push 'after events)
              (goto-char (point-max))
              (insert "Generated suffix\n")
              nil)))
          (result (org-texmacs-test--compose)))
     (should (equal (reverse events) '(before after)))
     (should (string-match-p "absent.org" (plist-get result :source)))
     (should
      (string-match-p "Generated suffix" (plist-get result :source)))
     (should-not (plist-member result :ranges)))))

(ert-deftest
    org-texmacs-preprocess-component-rejects-marker-and-config-edits
    ()
  (dolist (change '(text directory options mode))
    (org-texmacs-test--with-bibliography-files
     (insert "(math \"x\")\n")
     (let ((org-export-before-processing-functions
            (list
             (lambda (_backend)
               (pcase change
                 ('text
                  (erase-buffer)
                  (insert "(math \"x\")\n"))
                 ('directory
                  (setq-local default-directory "/different/"))
                 ('options
                  (setq-local org-export-with-toc
                              (not org-export-with-toc)))
                 ('mode (fundamental-mode)))))))
       (should-error
        (org-texmacs-test--compose)
        :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-preprocess-component-rejects-files-and-parameters
    ()
  (org-texmacs-test--with-bibliography-files
   (write-region "#+INCLUDE: \"a.org\"\n" nil "a.org" nil 'silent)
   (dolist (text
            '("#+INCLUDE: \"a.org\"\n"
              "#+INCLUDE: \"missing.org\"\n"
              "#+INCLUDE: \"a.org\" :lines \"1-2\"\n"
              "#+INCLUDE: \"parts/a.org\"\n"
              "#+SETUPFILE: absent.org\n"
              "#+BIND: org-export-use-babel t\n"))
     (erase-buffer)
     (insert text)
     (should-error
      (org-texmacs-test--compose)
      :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-preprocess-component-native-guard-and-mode-hook-isolation
    ()
  (org-texmacs-test--with-bibliography-files
   (insert "Text\n")
   (let ((org-mode-hook
          (list (lambda () (ert-fail "Private mode hook ran"))))
         (org-export-before-processing-functions
          (list
           (lambda (_backend)
             (should-error
              (org-export-as 'texmacs)
              :type 'org-texmacs-document-error)))))
     (should
      (string-match-p
       "Text" (plist-get (org-texmacs-test--compose) :source)))))
  (with-temp-buffer
    (org-mode)
    (insert "Text\n")
    (should-error (org-export-as 'texmacs) :type 'user-error)))

(ert-deftest org-texmacs-preprocess-native-parameter-combinations ()
  (org-texmacs-test--with-bibliography-files
   (write-region
    "* Alpha\n:PROPERTIES:\n:CUSTOM_ID: alpha\n:END:\nFirst\nSecond\n** Child\nBody\n* Beta\nOutside\n"
    nil
    "part.org"
    nil
    'silent)
   (dolist (value
            '("\"part.org::#alpha\" :only-contents t :lines \"1-3\""
              "\"part.org::*Alpha\" :only-contents t :lines \"1-3\""))
     (erase-buffer)
     (insert (format "#+INCLUDE: %s\n" value))
     (should
      (equal
       (plist-get (org-texmacs-test--compose) :source)
       "First\nSecond\n")))
   (erase-buffer)
   (insert "#+INCLUDE: \"part.org::*Alpha\" :minlevel 3\n")
   (let ((text (plist-get (org-texmacs-test--compose) :source)))
     (should (string-match-p "^\\*\\*\\* Alpha" text))
     (should (string-match-p "^\\*\\*\\*\\* Child" text))
     (should-not (string-match-p "Outside" text)))))

(ert-deftest org-texmacs-preprocess-lines-protect-multiline-stm ()
  (org-texmacs-test--with-bibliography-files
   (write-region
    "* Alpha\n#+begin_texmacs\n(concat \"\nSTM [fn:a]\n\")\n#+end_texmacs\n* Beta\n"
    nil
    "part.org"
    nil
    'silent)
   (insert "#+INCLUDE: \"part.org\" :lines \"2-7\" :minlevel 3\n")
   (should
    (equal
     (plist-get (org-texmacs-test--compose) :source)
     "#+begin_texmacs\n(concat \"\nSTM [fn:a]\n\")\n#+end_texmacs\n"))
   (erase-buffer) (insert "#+INCLUDE: \"part.org\" :lines \"3-4\"\n")
   (should-error
    (org-texmacs-test--compose)
    :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-preprocess-selection-avoids-excluded-reads ()
  (org-texmacs-test--with-bibliography-files
   (write-region
    "* Selected\nKept\n* Excluded\n#+INCLUDE: \"absent.org\"\n"
    nil
    "part.org"
    nil
    'silent)
   (insert "#+INCLUDE: \"part.org::*Selected\" :only-contents t\n")
   (let ((result (org-texmacs-test--compose)))
     (should (equal (plist-get result :source) "Kept\n"))
     (should (= (length (plist-get result :receipts)) 1)))))

(ert-deftest
    org-texmacs-preprocess-native-reader-restored-after-failure
    ()
  (org-texmacs-test--with-bibliography-files
   (insert "#+INCLUDE: \"missing.org\"\n")
   (let ((reader (symbol-function 'org-file-contents))
         (parser (symbol-function 'org-export-parse-include-value)))
     (should-error
      (org-texmacs-test--compose)
      :type 'org-texmacs-document-error)
     (should (eq reader (symbol-function 'org-file-contents)))
     (should
      (eq
       parser (symbol-function 'org-export-parse-include-value))))))

(ert-deftest
    org-texmacs-preprocess-selected-same-file-native-cycle-policy
    ()
  (org-texmacs-test--with-bibliography-files
   (write-region "* Alpha\nFirst\n* Beta\nSecond\n" nil "part.org"
                 nil
                 'silent)
   (insert
    "#+INCLUDE: \"part.org::*Alpha\" :only-contents t\n#+INCLUDE: \"part.org::*Beta\" :only-contents t\n")
   (let ((result (org-texmacs-test--compose)))
     (should (equal (plist-get result :source) "First\nSecond\n"))
     (should (= (length (plist-get result :sources)) 1)))
   (erase-buffer)
   (insert "#+INCLUDE: \"part.org::*Alpha\" :only-contents t\n")
   ;; Locked Org considers nested location-only references to the same file
   ;; recursive even when their headings differ.  Keep its policy.
   (write-region
    "* Alpha\n#+INCLUDE: \"part.org::*Beta\" :only-contents t\n* Beta\nKept\n"
    nil
    "part.org"
    nil
    'silent)
   (should-error
    (org-texmacs-test--compose)
    :type 'org-texmacs-document-error)
   (write-region
    "* Alpha\n#+INCLUDE: \"part.org::*Alpha\" :only-contents t\n"
    nil
    "part.org"
    nil
    'silent)
   (should-error
    (org-texmacs-test--compose)
    :type 'org-texmacs-document-error)))

(ert-deftest
    org-texmacs-preprocess-fixed-read-copies-and-parameter-errors
    ()
  (org-texmacs-test--with-bibliography-files
   (write-region "* Alpha\nFirst\n* Beta\nSecond\n" nil "part.org"
                 nil
                 'silent)
   (insert
    "#+INCLUDE: \"part.org::*Alpha\" :only-contents t\n#+INCLUDE: \"part.org::*Beta\" :only-contents t\n")
   (let ((prepare
          (symbol-function 'org-export--prepare-file-contents)))
     (cl-letf (((symbol-function 'org-export--prepare-file-contents)
                (lambda (file &rest args)
                  (let ((copy (org-file-contents file)))
                    (aset copy 0 ?X))
                  (apply prepare file args))))
       (should
        (equal
         (plist-get (org-texmacs-test--compose) :source)
         "First\nSecond\n"))))
   (dolist (value
            '("\"part.org::*Absent\""
              "\"part.org\" :unknown t"
              "\"~/part.org\""
              "\"part.org\" :minlevel 0"
              "\"part.org\" :lines \"bad\""))
     (erase-buffer)
     (insert (format "#+INCLUDE: %s\n" value))
     (should-error
      (org-texmacs-test--compose)
      :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-preprocess-native-depth-and-invalid-utf8 ()
  (org-texmacs-test--with-bibliography-files
   (dotimes (i 10)
     (write-region (if (= i 9)
                       "End\n"
                     (format "#+INCLUDE: \"p%d.org\"\n" (1+ i)))
                   nil (format "p%d.org" i)
                   nil 'silent))
   (insert "#+INCLUDE: \"p0.org\"\n")
   (should-error
    (org-texmacs-test--compose)
    :type 'org-texmacs-document-error)
   (let ((coding-system-for-write 'no-conversion))
     (write-region (unibyte-string 255) nil "bad.org" nil 'silent))
   (erase-buffer) (insert "#+INCLUDE: \"bad.org\"\n")
   (should-error
    (org-texmacs-test--compose)
    :type 'org-texmacs-document-error)))

(defun org-texmacs-test--native-include-text (source)
  "Expand SOURCE through native Org with the current explicit file context."
  (let ((base default-directory)
        (file buffer-file-name))
    (with-temp-buffer
      (org-mode)
      (setq-local default-directory base)
      (setq-local buffer-file-name file)
      (insert source)
      (org-export-expand-include-keyword nil base nil file)
      (buffer-string))))

(ert-deftest org-texmacs-preprocess-literal-include-native-escaping ()
  (org-texmacs-test--with-bibliography-files
   (let ((raw
          (concat
           "Text[fn::(math \"unfinished].\n"
           "* Literal heading\n#+INCLUDE: \"missing.org\"\n"
           "#+begin_texmacs\n(concat \"hello\n#+end_src\nbye\")\n"
           "#+end_texmacs\n#+end_example\n,#+begin_src\n")))
     (write-region raw nil "literal.txt" nil 'silent)
     (dolist (wrapper
              '("src emacs-lisp"
                "src org"
                "src bibtex"
                "example"
                "export html"))
       (erase-buffer)
       (insert (format "#+INCLUDE: \"literal.txt\" %s\n" wrapper))
       (let* ((source (buffer-string))
              (native (org-texmacs-test--native-include-text source))
              (result (org-texmacs-test--compose)))
         (should (equal (plist-get result :source) native))
         (should (equal source (buffer-string)))
         (should
          (equal
           (cdr
            (assoc
             (expand-file-name "literal.txt")
             (plist-get result :sources)))
           raw))
         (should (= 1 (length (plist-get result :receipts)))))))))

(ert-deftest org-texmacs-preprocess-literal-lines-ignore-stm-spans ()
  (org-texmacs-test--with-bibliography-files
   (write-region "(math\n  \"x\")\n" nil "part.org" nil 'silent)
   (dolist (wrapper '("src org" "example"))
     (erase-buffer)
     (insert
      (format "#+INCLUDE: \"part.org\" %s :lines \"2-3\"\n" wrapper))
     (should
      (equal
       (plist-get (org-texmacs-test--compose) :source)
       (org-texmacs-test--native-include-text (buffer-string)))))))

(ert-deftest org-texmacs-preprocess-literal-code-never-executes ()
  (org-texmacs-test--with-bibliography-files
   (write-region "(error \"INCLUDE executed source\")\n" nil "code.el"
                 nil
                 'silent)
   (insert "#+INCLUDE: \"code.el\" src emacs-lisp\n")
   (cl-letf (((symbol-function 'org-babel-execute-src-block)
              (lambda (&rest _) (ert-fail "Executed Babel")))
             ((symbol-function 'org-texmacs--worker-request)
              (lambda (&rest _) (ert-fail "Parsed literal STM"))))
     (let* ((input
             (org-texmacs-prepare-buffer-preprocessed
              (current-buffer)))
            (body
             (org-texmacs-document-body
              (org-texmacs-document input))))
       (should-not (org-texmacs-input-islands input))
       (should
        (string-match-p
         "INCLUDE executed source" (prin1-to-string body)))
       (should (string-match-p "code" (prin1-to-string body)))))))

(ert-deftest
    org-texmacs-preprocess-wrapper-target-errors-after-expansion
    ()
  (org-texmacs-test--with-bibliography-files
   (write-region "Text\n" nil "part.txt" nil 'silent)
   (dolist (wrapper
            '("export html" "src org :tangle never-created.el"))
     (erase-buffer)
     (insert (format "#+INCLUDE: \"part.txt\" %s\n" wrapper))
     (should
      (string-match-p
       "Text" (plist-get (org-texmacs-test--compose) :source)))
     (let ((err
            (should-error
             (org-texmacs-document-from-buffer-preprocessed
              (current-buffer))
             :type 'org-texmacs-document-error)))
       (should-not
        (string-match-p
         "INCLUDE parameters" (error-message-string err)))))
   (should-not (file-exists-p "never-created.el"))))

(ert-deftest
    org-texmacs-preprocess-mixed-views-share-original-snapshot
    ()
  (org-texmacs-test--with-bibliography-files
   (let* ((raw "(math \"x\")\n")
          (forms
           '("#+INCLUDE: \"part.org\"\n"
             "#+INCLUDE: \"part.org\" src org\n"
             "#+INCLUDE: \"part.org\" quote\n")))
     (write-region raw nil "part.org" nil 'silent)
     (dolist (order (list forms (reverse forms)))
       (erase-buffer)
       (insert (apply #'concat (append order order)))
       (let ((result (org-texmacs-test--compose)))
         (should (= 1 (length (plist-get result :sources))))
         (should (= 1 (length (plist-get result :receipts))))
         (should (equal (cdar (plist-get result :sources)) raw))
         (should
          (equal
           (plist-get result :source)
           (org-texmacs-test--native-include-text
            (buffer-string)))))))))

(ert-deftest
    org-texmacs-preprocess-mixed-reader-copies-and-relative-paths
    ()
  (org-texmacs-test--with-bibliography-files
   (write-region "(math \"x\")\n" nil "part.org" nil 'silent)
   (insert
    "#+INCLUDE: \"part.org\" src org\n"
    "#+INCLUDE: \"part.org\" quote\n")
   (let ((prepare
          (symbol-function 'org-export--prepare-file-contents)))
     (cl-letf (((symbol-function 'org-export--prepare-file-contents)
                (lambda (file &rest args)
                  (let ((copy
                         (org-file-contents
                          (file-relative-name file
                                              default-directory))))
                    (aset copy 0 ?X))
                  (apply prepare file args))))
       (should
        (equal
         (plist-get (org-texmacs-test--compose) :source)
         (org-texmacs-test--native-include-text (buffer-string))))))))

(ert-deftest org-texmacs-preprocess-wrapper-native-branch-semantics ()
  (org-texmacs-test--with-bibliography-files
   (write-region
    "* Alpha\n#+INCLUDE: \"missing.org\"\n* Beta\nOther\n"
    nil
    "part.org"
    nil
    'silent)
   (dolist (suffix '("src org" "example" "quote" "theorem"))
     (erase-buffer)
     (insert
      (format "#+INCLUDE: \"part.org::*Alpha\" %s :only-contents t\n"
              suffix))
     (should
      (equal
       (plist-get (org-texmacs-test--compose) :source)
       (org-texmacs-test--native-include-text (buffer-string))))))
  (org-texmacs-test--with-bibliography-files
   ;; A COMMENT wrapper owns literal text; it must not discover malformed STM
   ;; by parsing its file outside the eventual wrapper context.
   (write-region "Text[fn::(math \"unfinished].\n" nil "part.org"
                 nil
                 'silent)
   (insert "#+INCLUDE: \"part.org\" comment\n")
   (should
    (equal
     (plist-get (org-texmacs-test--compose) :source)
     (org-texmacs-test--native-include-text (buffer-string))))))

(ert-deftest
    org-texmacs-preprocess-native-body-selected-before-protection
    ()
  (org-texmacs-test--with-bibliography-files
   (write-region
    "Discard\n(concat \"* Heading\n[fn:x] #+INCLUDE: missing.org\n\")\nDiscard\n"
    nil
    "part.stm"
    nil
    'silent)
   (dolist (wrapper '("texmacs" "equation" "equation*" "TeXmAcS"))
     (erase-buffer)
     (insert
      (format "#+INCLUDE: \"part.stm\" \"%s\" :lines \"2-5\"\n"
              wrapper))
     (let ((org-export-before-parsing-functions
            (list
             (lambda (_backend)
               (should-not
                (string-match-p
                 "Heading\\|missing.org" (buffer-string)))))))
       (should
        (equal
         (plist-get (org-texmacs-test--compose) :source)
         (org-texmacs-test--native-include-text (buffer-string))))))))

(ert-deftest
    org-texmacs-preprocess-nested-modes-and-helper-restoration
    ()
  (org-texmacs-test--with-bibliography-files
   (let* ((names
           '(org-file-contents
             org-export-parse-include-value
             org-export--prepare-file-contents
             org-export--blindly-expand-include
             org-export-expand-include-keyword
             org-export--inclusion-absolute-lines))
          (functions (mapcar #'symbol-function names)))
     (write-region "Text[fn::(math \"unfinished].\n" nil "literal.txt"
                   nil
                   'silent)
     (write-region "* Child\nKept\n" nil "child.org" nil 'silent)
     (write-region
      (concat
       "#+INCLUDE: \"literal.txt\" src org\n"
       "#+INCLUDE: \"child.org::*Child\" :only-contents t\n")
      nil "parent.org"
      nil 'silent)
     (insert "#+INCLUDE: \"parent.org\"\n")
     (should
      (string-match-p
       "Kept" (plist-get (org-texmacs-test--compose) :source)))
     (should
      (cl-every #'eq functions (mapcar #'symbol-function names)))
     (write-region "#+INCLUDE: \"missing.org\"\n" nil "child.org"
                   nil
                   'silent)
     (should-error
      (org-texmacs-test--compose)
      :type 'org-texmacs-document-error)
     (should
      (cl-every #'eq functions (mapcar #'symbol-function names))))))

(ert-deftest
    org-texmacs-preprocess-wrapper-budgets-and-dependency-guards
    ()
  (org-texmacs-test--with-bibliography-files
   (write-region (make-string 30000 ?x) nil "part.txt" nil 'silent)
   (insert
    (apply #'concat
           (make-list 9 "#+INCLUDE: \"part.txt\" src org\n")))
   (should-error
    (org-texmacs-test--compose)
    :type 'org-texmacs-document-error)
   (erase-buffer)
   (insert
    (apply #'concat
           (make-list 32 "#+INCLUDE: \"part.txt\" example\n")))
   (should-error
    (org-texmacs-test--compose)
    :type 'org-texmacs-document-error)
   (write-region "Original\n" nil "part.txt" nil 'silent)
   (erase-buffer)
   (insert "#+INCLUDE: \"part.txt\" src org\n")
   (let ((org-export-before-parsing-functions
          (list
           (lambda (_backend)
             (write-region "Changed\n" nil "part.txt" nil 'silent)))))
     (should-error
      (org-texmacs-prepare-buffer-preprocessed (current-buffer))
      :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-preprocess-new-helper-identity-guard ()
  (org-texmacs-test--with-bibliography-files
   (write-region "Text\n" nil "part.org" nil 'silent)
   (insert "#+INCLUDE: \"part.org\" src org\n")
   (let ((original
          (symbol-function 'org-export--blindly-expand-include))
         (prepare
          (symbol-function 'org-export--prepare-file-contents)))
     (cl-letf (((symbol-function 'org-export--prepare-file-contents)
                (lambda (&rest args)
                  (fset 'org-export--blindly-expand-include #'ignore)
                  (apply prepare args))))
       (should-error
        (org-texmacs-test--compose)
        :type 'org-texmacs-document-error))
     (should
      (eq
       original
       (symbol-function 'org-export--blindly-expand-include))))))

;;; preprocess.el ends here
