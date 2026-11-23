;;; ert-native-model-serialization.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'org-texmacs)

(require 'org-texmacs-serialize)

(ert-deftest org-texmacs-model-native-stm-source-round-trips ()
  (org-texmacs-test--with-worker
   (dolist (tree
            (list
             '(frac "1" "2")
             '(math (sqrt "α中😀"))
             '(concat "a" "b")
             '(tuple)
             ""
             "atomic α中é😀"
             '(math "quotes \" and \\ and\n\r\t")
             '(math "\n* Heading\n#+end_texmacs\n")
             '(math "<alpha> <less> <gtr> <#4E2D>")
             (list (intern "123") "x")
             (list (intern "数学") "x")
             '(raw-data "x")))
     (let ((source (org-texmacs--worker-serialize-stm tree)))
       (should-not (string-match-p "[\r\n\t]" source))
       (should (equal tree (org-texmacs--worker-request source)))))))

(ert-deftest org-texmacs-model-native-unsupported-stm-preserves-parser
    ()
  (org-texmacs-test--with-worker
   (org-texmacs--worker-request "(math \"ready\")")
   (let ((process org-texmacs--worker-process))
     (dolist (tag '("a b" "a)b" "#t"))
       (should-error
        (org-texmacs--worker-serialize-stm (list (intern tag) "x"))
        :type 'org-texmacs-model-serialization-error)
       (should (eq process org-texmacs--worker-process)))
     (should
      (equal
       (org-texmacs--worker-request
        "(sqrt \"recovered\")")
       '(sqrt "recovered")))
     (should (process-live-p process)))))

(ert-deftest org-texmacs-object-writer-native-round-trip ()
  (org-texmacs-test--with-worker
   (dolist (tree '("atomic" (custom-tag) (math (sqrt "α中😀"))))
     (let ((source (org-texmacs--serialize-stm-source tree nil)))
       (should-not (string-match-p "[\r\n\t]" source))
       (should (equal tree (org-texmacs--worker-request source)))))))

(ert-deftest org-texmacs-stm-native-differential ()
  (org-texmacs-test--with-worker
   ;; Check canonical writer output directly against TeXmacs.
   (let ((atoms '("" "α中😀" "\\" "\"" "\n" "\r" "\t" "n")))
     (dolist (left atoms)
       (dolist (right atoms)
         (let* ((tree (list 'math (concat left right)))
                (source (org-texmacs--stm-write tree)))
           (should (equal (org-texmacs--worker-request source) tree))
           (should (equal (org-texmacs--stm-read source) tree))))))
   (dolist (tree
            '("原子"
              (a-b (a_b (a* (a0))))
              (tuple)
              (math (frac "1" "2"))
              (math "quote \" slash \\ tail\n\r\t")))
     (let ((source (org-texmacs--worker-serialize-stm tree)))
       (should
        (equal
         (org-texmacs--stm-read source)
         (org-texmacs--worker-request source)))))
   ;; Check reader semantics independently of either writer.
   (dolist (counts '((4 . 1) (8 . 2)))
     (let* ((source (concat "\"" (make-string (car counts) ?\\) "\""))
            (expected (make-string (cdr counts) ?\\)))
       (should (equal (org-texmacs--worker-request source) expected))
       (should (equal (org-texmacs--stm-read source) expected))))
   (dolist (source
            '("(math \"quote \\\" slash \\\\ tail\")"
              "  (\tMath\t(Frac \"α\" \"β\")\n \"\") \t\n"
              "\"line one\nline two\tend\""
              "(math \"literal <alpha> <less> <gtr>\")"))
     (should
      (equal
       (org-texmacs--stm-read source)
       (org-texmacs--worker-request source))))))

;;; ert-native-model-serialization.el ends here
