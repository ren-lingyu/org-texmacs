;;; model-serialization.el --- Native model round-trip regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Native STM source and normalized Org, without TeXmacs document lowering.

;;; Code:

(require 'org-texmacs-serialize)

(defun org-texmacs-test--native-model (text)
  "Parse complete Org TEXT, disposing its source before returning the model."
  (with-temp-buffer
    (org-mode)
    (insert text)
    (org-texmacs-parse-buffer (current-buffer))))

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

(ert-deftest org-texmacs-model-native-org-round-trip-and-idempotence
    ()
  (org-texmacs-test--with-worker
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
                  (ert-fail "Output guard reparsed known STM"))))
       (setq output (org-texmacs-model-serialize model)))
     (let ((again (org-texmacs-test--native-model output)))
       (should (equal before (org-texmacs-test--model-meaning again)))
       (should (equal output (org-texmacs-model-serialize again))))
     (should
      (equal before (org-texmacs-test--model-meaning model))))))

(ert-deftest org-texmacs-model-native-block-root-and-delimiter-leaves
    ()
  (org-texmacs-test--with-worker
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
  (org-texmacs-test--with-worker
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

;;; model-serialization.el ends here
