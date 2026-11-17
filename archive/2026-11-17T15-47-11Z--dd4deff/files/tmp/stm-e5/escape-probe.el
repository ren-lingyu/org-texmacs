;;; escape-probe.el --- targeted native alternatives -*- lexical-binding: t; -*-
(load (expand-file-name "writer-functions.el" (file-name-directory load-file-name)) nil t)
(let (rows)
  (unwind-protect
      (dolist (s '("(math \"a\\|b\")" "(math \"a\\]b\")"
                   "(math \"a\\x7cb\")" "(math \"a\\x5d;b\")"
                   "(math \"a\\u007cb\")"))
        (push (list :source s :result (condition-case e (format "%S" (e4-stm-read s))
                                       (error (error-message-string e)))) rows))
    (org-texmacs--worker-stop))
  (probe-write "escape-alternatives.json" (nreverse rows)))
(probe-write "purity.json"
             (let* ((tree '(custom-tag "a\\\"b\n中文"))
                    (before (e5-stm-write tree))
                    (after (with-temp-buffer (insert "unrelated")
                                             (let ((tab-width 3) (case-fold-search nil)) (e5-stm-write tree)))))
               (list :deterministic (equal before (e5-stm-write tree))
                     :buffer-independent (equal before after) :source before)))
(princ "escape alternatives completed\n")
