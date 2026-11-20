;;; setupfile.el --- Org 10 external parser syntax regressions -*- lexical-binding: t; -*-

(require 'ert)
(require 'org-texmacs)

(defun org-texmacs-setupfile-test--with-source
    (function &optional cycle)
  "Call FUNCTION with a visiting Org buffer and its nested setup file.
When CYCLE is non-nil, make the nested file refer back to the main file."
  (let* ((root (make-temp-file "org-texmacs-setupfile-" t))
         (main (expand-file-name "main.org" root))
         (setup (expand-file-name "config/top.setup" root))
         (nested (expand-file-name "config/nested/rules.setup" root))
         source)
    (unwind-protect
        (progn
          (make-directory (file-name-directory nested) t)
          (with-temp-file main
            (insert
             "#+SETUPFILE: config/top.setup\n"
             "#+INCLUDE: \"unexpanded.org\"\n")
            (when cycle
              (insert "#+TODO: LOCAL | LOCALDONE\n"))
            (insert
             "\n* READY Heading\n** FINISHED Child\n"
             "[[demo:item][Link]] $(math \"x\")$.\n"))
          (with-temp-file setup
            (insert "#+SETUPFILE: nested/rules.setup\n"))
          (with-temp-file nested
            (insert
             "#+TODO: READY | FINISHED\n"
             "#+LINK: demo https://example.test/%s\n")
            (when cycle
              (insert "#+SETUPFILE: ../../main.org\n")))
          (setq source (find-file-noselect main))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (_source &optional _syntax)
                       '(math "x"))))
            (funcall function source nested)))
      (when (buffer-live-p source)
        (kill-buffer source))
      (delete-directory root t))))

(defun org-texmacs-setupfile-test--syntax (ast)
  "Return the effective heading and link syntax in AST."
  (list
   (org-element-map
    ast 'headline
    (lambda (node)
      (list
       (org-element-property :todo-keyword node)
       (org-element-property :todo-type node))))
   (org-element-map
    ast 'link
    (lambda (node)
      (list
       (org-element-property :type node)
       (org-element-property :path node))))))

(defun org-texmacs-setupfile-test--semantics (model)
  "Return MODEL's headings, links, source declarations and STM trees."
  (let ((ast (org-texmacs-model-ast model)))
    (list
     (org-texmacs-setupfile-test--syntax ast)
     (org-element-map
      ast 'keyword
      (lambda (node)
        (list
         (org-element-property :key node)
         (org-element-property :value node))))
     (mapcar #'cdr (org-texmacs-model-islands model)))))

(defun org-texmacs-setupfile-test--change-config (file)
  "Change the effective TODO and link syntax in external FILE."
  (with-temp-file file
    (insert
     "#+TODO: REPLACED | CLOSED\n"
     "#+LINK: demo https://changed.test/%s\n")))

(ert-deftest org-texmacs-setupfile-uses-scoped-runtime ()
  (should
   (file-in-directory-p
    (symbol-file 'org-mode) (getenv "ORG_TEXMACS_TEST_EXPECTED_ORG")))
  (should
   (file-in-directory-p
    (symbol-file 'org-texmacs-parse-buffer)
    (getenv "ORG_TEXMACS_TEST_EXPECTED_PACKAGE"))))

(ert-deftest org-texmacs-setupfile-recursive-native-parity ()
  (dolist (org-element-use-cache '(nil t))
    (org-texmacs-setupfile-test--with-source
     (lambda (source _nested)
       (let* ((native
               (with-current-buffer source
                 (org-element-parse-buffer)))
              (expected (org-texmacs-setupfile-test--syntax native))
              (model (org-texmacs-parse-buffer source))
              (semantics
               (org-texmacs-setupfile-test--semantics model)))
         (should
          (equal
           expected
           '((("READY" todo) ("FINISHED" done))
             (("https" "//example.test/item")))))
         (should (equal (car semantics) expected))
         (should
          (equal
           (nth 1 semantics)
           '(("SETUPFILE" "config/top.setup")
             ("INCLUDE" "\"unexpanded.org\""))))
         (should (equal (nth 2 semantics) '((math "x")))))))))

(ert-deftest org-texmacs-setupfile-cycle-through-main-file ()
  (org-texmacs-setupfile-test--with-source
   (lambda (source _nested)
     (let* ((native
             (with-current-buffer source
               (org-element-parse-buffer)))
            (expected (org-texmacs-setupfile-test--syntax native))
            (model (org-texmacs-parse-buffer source))
            (ast (org-texmacs-model-ast model))
            (main (buffer-file-name source))
            (context (org-texmacs-model-context model))
            (text (org-texmacs-model-serialize model)))
       (should
        (equal (org-texmacs-setupfile-test--syntax ast) expected))
       (should (equal (org-element-property :path native) main))
       (should (equal (org-element-property :path ast) main))
       (dolist (key
                '(:todo-keyword-settings
                  :todo-keywords
                  :done-keywords
                  :link-abbrevs))
         (should
          (equal
           (org-element-property key ast)
           (org-element-property key native))))
       (should
        (= (length (org-element-property :todo-keyword-settings ast))
           2))
       (should
        (equal
         (sort
          (copy-sequence (org-element-property :todo-keywords ast))
          #'string<)
         '("FINISHED" "LOCAL" "LOCALDONE" "READY")))
       (should
        (equal
         (sort
          (copy-sequence (org-element-property :done-keywords ast))
          #'string<)
         '("FINISHED" "LOCALDONE")))
       (should
        (equal
         (org-element-property :link-abbrevs ast)
         '(("demo" . "https://example.test/%s"))))
       (with-temp-buffer
         (setq default-directory (plist-get context :resource-base))
         (org-mode)
         (insert text)
         (let ((buffer-file-name (plist-get context :source-file)))
           (should
            (equal
             (org-texmacs-setupfile-test--syntax
              (org-element-parse-buffer))
             expected))))))
   t))

(ert-deftest org-texmacs-setupfile-rechecks-syntax-across-worker-wait
    ()
  (org-texmacs-setupfile-test--with-source
   (lambda (source nested)
     (let (requested)
       (cl-letf (((symbol-function 'org-texmacs--worker-request)
                  (lambda (_source &optional _syntax)
                    (setq requested t)
                    (org-texmacs-setupfile-test--change-config nested)
                    '(math "x"))))
         (should-error
          (org-texmacs-parse-buffer source)
          :type 'org-texmacs-model-error))
       (should requested)))))

(ert-deftest org-texmacs-setupfile-serialization-and-owned-model ()
  (org-texmacs-setupfile-test--with-source
   (lambda (source nested)
     (let* ((model (org-texmacs-parse-buffer source))
            (expected (org-texmacs-setupfile-test--semantics model))
            (context (copy-tree (org-texmacs-model-context model)))
            (base (plist-get context :resource-base)))
       (kill-buffer source)
       (cl-labels
        ((check-text
          (text)
          (with-temp-buffer
            (setq default-directory base)
            (org-mode)
            (insert text)
            (should
             (equal
              (org-texmacs-setupfile-test--semantics
               (org-texmacs-parse-buffer (current-buffer)))
              expected)))))
        (check-text (org-texmacs-model-serialize model))
        (let ((output (org-texmacs-model-to-buffer model)))
          (unwind-protect
              (progn
                (should-not (buffer-file-name output))
                (should
                 (equal
                  (org-texmacs-setupfile-test--semantics
                   (org-texmacs-parse-buffer output))
                  expected)))
            (kill-buffer output)))
        (org-texmacs-setupfile-test--change-config nested)
        (should
         (equal
          (org-texmacs-setupfile-test--semantics model) expected))
        (should (equal (org-texmacs-model-context model) context))
        (let ((text
               (condition-case nil
                   (org-texmacs-model-serialize model)
                 (org-texmacs-model-serialization-error
                  nil))))
          (when text
            (check-text text))))))))
