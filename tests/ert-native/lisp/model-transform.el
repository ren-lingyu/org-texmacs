;;; model-transform.el --- Native transformed model round trips -*- lexical-binding: t; -*-

;;; Commentary:

;; Transform structures directly, then validate their independent Org output.

;;; Code:

(require 'org-texmacs-serialize)

(defun org-texmacs-test--transformed-round-trip (model)
  "Assert supported MODEL's structure and normalization survive Org output."
  (let* ((text (org-texmacs-model-serialize model))
         (again
          (with-temp-buffer
            (org-mode)
            (insert text)
            (org-texmacs-parse-buffer (current-buffer)))))
    (should
     (equal
      (org-texmacs-test--model-meaning model)
      (org-texmacs-test--model-meaning again)))
    (should (equal text (org-texmacs-model-serialize again)))))

(ert-deftest org-texmacs-model-native-transformed-subtrees-round-trip
    ()
  (org-texmacs-test--with-worker
   (let* ((model
           (with-temp-buffer
             (org-mode)
             (insert
              "# Keep\n* COMMENT Heading\n"
              "Before (math (frac \"1\" \"2\")).\n\n"
              "#+CAPTION: Caption *kept*\n#+begin_texmacs\n"
              "(math \"old\")\n#+end_texmacs\n")
             (org-texmacs-parse-buffer (current-buffer))))
          (before (org-texmacs-test--model-meaning model))
          copy
          changed)
     (cl-letf (((symbol-function 'org-texmacs--worker-call)
                (lambda (&rest _)
                  (ert-fail "Transformation started worker")))
               ((symbol-function 'org-texmacs-model-serialize)
                (lambda (&rest _)
                  (ert-fail "Transformation used text"))))
       (setq
        copy (org-texmacs-model-copy model)
        changed
        (org-texmacs-model-replace-stm
         copy
         (caar
          (org-texmacs-model-islands copy))
         '(0 1) '(sqrt "中\nx")))
       (setq changed
             (org-texmacs-model-replace-stm
              changed
              (car (nth 1 (org-texmacs-model-islands changed)))
              nil
              '(frac "3" "4"))))
     (org-texmacs-test--transformed-round-trip copy)
     (org-texmacs-test--transformed-round-trip changed)
     (should
      (equal
       (mapcar #'cdr (org-texmacs-model-islands changed))
       '((math (frac "1" (sqrt "中\nx"))) (frac "3" "4"))))
     (should
      (equal before (org-texmacs-test--model-meaning model))))))

(ert-deftest
    org-texmacs-model-native-root-change-outside-output-domain
    ()
  (org-texmacs-test--with-worker
   (let* ((model
           (with-temp-buffer
             (org-mode)
             (insert "Before (math \"old\").\n")
             (org-texmacs-parse-buffer (current-buffer))))
          (changed
           (org-texmacs-model-replace-stm
            model
            (caar (org-texmacs-model-islands model))
            nil
            '(frac "1" "2"))))
     (should (org-texmacs-model-inspect changed))
     (should (org-texmacs-model-copy changed))
     (cl-letf (((symbol-function 'org-texmacs--worker-call)
                (lambda (&rest _)
                  (ert-fail "Inexpressible output reached worker"))))
       (should-error
        (org-texmacs-model-serialize changed)
        :type 'org-texmacs-model-serialization-error))
     (should
      (equal
       (cdar (org-texmacs-model-islands changed)) '(frac "1" "2")))
     (should
      (equal
       (cdar (org-texmacs-model-islands model)) '(math "old"))))))

(ert-deftest org-texmacs-model-native-root-change-with-captured-tags
    ()
  (org-texmacs-test--with-worker
   (let* ((model
           (with-temp-buffer
             (org-mode)
             (setq-local org-texmacs-fragment-tags '("math" "frac"))
             (insert "Before (math \"old\").\n")
             (org-texmacs-parse-buffer (current-buffer))))
          (changed
           (org-texmacs-model-replace-stm
            model
            (caar (org-texmacs-model-islands model))
            nil
            '(frac "1" "2"))))
     (let ((org-texmacs-fragment-tags '("math" "frac")))
       (org-texmacs-test--transformed-round-trip changed)))))

;;; model-transform.el ends here
