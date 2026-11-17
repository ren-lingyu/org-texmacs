;;; normalization.el --- independent E5 Org checks -*- lexical-binding: t; -*-
(load (expand-file-name "writer-functions.el" (file-name-directory load-file-name)) nil t)
(defun e5-normal-case (source tree)
  (e3-scope t
            (lambda ()
              (let* ((ast (e3-parse source))
                     (mapping (mapcar (lambda (f) (cons f tree)) (e3-fragments ast)))
                     (m (e4-no-parsing (lambda () (e4-convert-in ast mapping))))
                     (sig (e4-signature m))
                     (stable (format "%S" tree)) output)
                (condition-case e
                    (cl-letf (((symbol-function 'e4-write-tree) #'e5-stm-write))
                      (let* ((back (e4-no-parsing (lambda () (e4-convert-out m))))
                             (out (setq output (org-element-interpret-data (org-texmacs-model-ast back))))
                             (again (e4-convert-in (e3-parse out)))
                             (out2 (org-element-interpret-data (org-texmacs-model-ast
                                                               (e4-no-parsing (lambda () (e4-convert-out again)))))))
                        (list :input source :tree stable :output out
                              :model-signature-equal (equal sig (e4-signature again))
                              :idempotent (equal out out2)
                              :positions-before (e4-snap m) :positions-after (e4-snap again)
                              :signature-before (format "%S" sig) :signature-after (format "%S" (e4-signature again))
                              :input-tree-unchanged (equal stable (format "%S" tree))
                              :model-unchanged (equal sig (e4-signature m)))))
                  (error (list :input source :tree stable :output output :error (error-message-string e)
                               :model-unchanged (equal sig (e4-signature m)))))))))
(let (rows directory)
  (unwind-protect
      (progn
        (org-texmacs--worker-start) (setq directory org-texmacs--worker-directory)
        (dolist (source '("Before  $(math \"x\")$   after.\n"
                          "$(math \"x\")$$(math \"y\")$\n"
                          "*Before $(math \"x\")$ after.*\n"
                          "* Title $(math \"x\")$\nBody.\n"
                          "#+caption[Short $(math \"s\")$]: Long $(math \"l\")$\n| a |\n"
                          "[[https://example.invalid][$(math \"x\")$]]\n"
                          "Text [fn::$(math \"x\")$] end.\n"
                          "| Before $(math \"x\")$ after | B |\n"))
          (dolist (tree (list '(math "x") '(math "a\\\"b") '(math "a\nb") '(math "中文")
                              '(math "\\)$*_[[x]]") '(math "a|b")))
            (push (e5-normal-case source tree) rows)))
        (probe-write "normalization.json" (nreverse rows)))
    (org-texmacs--worker-stop))
  (let ((cycle (list 'math "x")) checks)
    (setcdr cycle (list cycle))
    (dolist (tree (list cycle '(math 3) nil))
      (push (condition-case e (progn (org-texmacs--model-copy-stree tree) "unexpected acceptance")
              (error (error-message-string e))) checks))
    (probe-write "invalid.json" checks))
  (probe-write "normalization-environment.json"
               (list :worker-live (org-texmacs--worker-live-p)
                     :directory-removed (and directory (not (file-exists-p directory))))))
(princ "E5 normalization completed\n")
