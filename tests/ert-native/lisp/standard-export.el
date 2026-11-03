;;; standard-export.el --- Standard native output regressions -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-standard-export-native-entity-encoding ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil e:t\n"
      "Before \\alpha{} \\cdot \\rightarrow \\copy literal <alpha> After.\n")
     (let* ((document (org-texmacs--standard-consume 'document))
            (session (org-texmacs-session-open))
            (expected
             '(document
               (concat
                "Before "
                (math "<alpha>")
                " "
                (math "<cdot>")
                " "
                (math "<rightarrow>")
                " "
                "<copyright>"
                " "
                "literal <less>alpha<gtr> After. "))))
       (should-not (org-texmacs-document-stm-paths document))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (should
              (equal
               (org-texmacs--session-read session)
               (org-texmacs-test--native-hex expected))))
         (org-texmacs-session-close session))
       (should
        (string-search
         "<math|\\<alpha\\>>"
         (org-texmacs-document-serialize document)))))))

(ert-deftest org-texmacs-standard-export-native-final-stm-matrix ()
  (org-texmacs-test--with-worker
   (dolist
       (pair
        '(("Left (math (sqrt \"x\")) right.\n" . (math (sqrt "x")))
          ("(math \"first line\nsecond line\")\n"
           .
           (math "first line\nsecond line"))
          ("Note[fn::(math \"first line\nsecond line\")].\n"
           .
           (math "first line\nsecond line"))
          ("#+TITLE: ~literal~\n(math (sqrt \"x\"))\n"
           .
           (math (sqrt "x")))
          ("(math \"*bold* [[https://example.org][link]] ~literal~\")\n"
           .
           (math "*bold* [[https://example.org][link]] ~literal~"))
          ("Note[fn::(math (sqrt \"x\"))].\n" . (math (sqrt "x")))
          ("#+begin_texmacs\n(document \"a\n  b\")\n#+end_texmacs\n"
           .
           (document "a\n  b"))
          ("#+begin_texmacs\n(document \"*bold* [[https://example.org][link]]\")\n#+end_texmacs\n"
           .
           (document "*bold* [[https://example.org][link]]"))
          ("#+begin_equation\n(frac \"x\" \"y\")\n#+end_equation\n"
           .
           (frac "x" "y"))
          ("#+begin_equation*\n(sqrt \"中文\")\n#+end_equation*\n"
           .
           (sqrt "中文"))))
     (with-temp-buffer
       (org-mode)
       (insert (car pair))
       (let* ((org-export-use-babel nil)
              (before (buffer-string))
              (first (org-texmacs--standard-consume 'input))
              (second (org-texmacs--standard-consume 'input)))
         (should (equal before (buffer-string)))
         (should (= (length (org-texmacs-input-islands first)) 1))
         (should
          (equal (cdar (org-texmacs-input-islands first)) (cdr pair)))
         (should
          (equal
           (cdar (org-texmacs-input-islands second)) (cdr pair)))
         (should-not
          (eq
           (caar (org-texmacs-input-islands first))
           (caar (org-texmacs-input-islands second))))
         (should (org-texmacs-document first)))))))

(ert-deftest
    org-texmacs-standard-export-native-preprocessing-generated-stm
    ()
  (org-texmacs-test--with-worker
   (require 'ob-emacs-lisp)
   (let* ((leaf (expand-file-name "leaf.org" test-directory))
          (middle (expand-file-name "middle.org" test-directory)))
     (with-temp-file leaf
       (insert "(math (sqrt \"include\"))\n"))
     (with-temp-file middle
       (insert "#+INCLUDE: \"leaf.org\"\n"))
     (dolist
         (pair
          '(("#+MACRO: m (math (sqrt \"macro\"))\n{{{m}}}\n"
             .
             (math (sqrt "macro")))
            ("#+begin_src emacs-lisp :exports results :results raw\n\"(math (sqrt \\\"babel\\\"))\"\n#+end_src\n"
             .
             (math (sqrt "babel")))
            ("#+INCLUDE: \"middle.org\"\n"
             .
             (math (sqrt "include")))))
       (with-temp-buffer
         (org-mode)
         (setq default-directory
               (file-name-as-directory test-directory))
         (insert (car pair))
         (let* ((org-export-use-babel t)
                (org-confirm-babel-evaluate nil)
                (input (org-texmacs--standard-consume 'input)))
           (should
            (equal
             (cdar (org-texmacs-input-islands input)) (cdr pair)))
           (should
            (= (length (org-texmacs-input-islands input)) 1))))))))

(ert-deftest
    org-texmacs-standard-export-native-synthetic-stm-uses-final-ast
    ()
  (org-texmacs-test--with-worker
   (dolist (kind
            '(inline
               native))
     (with-temp-buffer
       (org-mode)
       (insert "(math \"old\")\n")
       (let* ((org-export-use-babel nil)
              (org-export-filter-parse-tree-functions
               (list
                (lambda (tree _backend _info)
                  (org-element-set-element
                   (car (org-element-map tree 'paragraph #'identity))
                   (if (eq kind 'inline)
                       (org-element-create
                        'paragraph nil "(math (sqrt \"final\"))")
                     (org-element-create
                      'special-block
                      '(:type
                        "texmacs"
                        :texmacs-source "(math (sqrt \"final\"))"))))
                  tree)))
              (input (org-texmacs--standard-consume 'input)))
         (should
          (equal
           (cdar (org-texmacs-input-islands input))
           '(math (sqrt "final")))))))))

(ert-deftest
    org-texmacs-standard-export-native-invalid-complete-stm-fails
    ()
  (org-texmacs-test--with-worker
   (dolist
       (text
        '("(math #t)\n"
          "#+begin_texmacs\n(math \"x\") (math \"y\")\n#+end_texmacs\n"))
     (with-temp-buffer
       (org-mode)
       (insert text)
       (let ((org-export-use-babel nil)
             (before (buffer-string)))
         (should-error
          (org-texmacs--standard-consume 'input)
          :type 'org-texmacs-error)
         (should (equal before (buffer-string))))))))

(ert-deftest org-texmacs-standard-export-native-text-file-and-source
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Café 中文 α and literal <alpha>.\n")
     (let* ((source (buffer-string))
            (org-export-use-babel nil)
            (org-export-coding-system 'iso-latin-1-unix)
            (text (org-export-as 'texmacs))
            (bytes (encode-coding-string text 'iso-latin-1-unix))
            (file (expand-file-name "standard.tm" test-directory)))
       (should (string-prefix-p "<TeXmacs|" text))
       (should-not (cl-some (lambda (c) (> c #x10ffff)) text))
       (org-export-to-file 'texmacs file)
       (with-temp-buffer
         (set-buffer-multibyte nil)
         (insert-file-contents-literally file)
         (should (equal (concat bytes "\n") (buffer-string))))
       (should (equal source (buffer-string)))))))

(ert-deftest
    org-texmacs-standard-export-native-pdf-without-text-serialization
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Standard native PDF.\n")
     (let ((org-export-use-babel nil))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (_document)
                    (ert-fail "PDF serialized .tm"))))
         (let ((pdf (org-texmacs--standard-consume 'pdf)))
           (should (string-prefix-p "%PDF-" pdf))
           (should-not (multibyte-string-p pdf))))))))
