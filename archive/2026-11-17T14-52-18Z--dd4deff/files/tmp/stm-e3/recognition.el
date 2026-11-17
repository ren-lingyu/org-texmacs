;;; recognition.el --- lexical recognition -*- lexical-binding: t; -*-
(defvar ep-calls nil)
(defun ep-parser (old &rest args)
  ;; Org calls this only when latex-fragment is allowed and preceding objects
  ;; did not already consume the text. Narrowing belongs to Org, not this probe.
  (if (or (looking-at-p "\\$(") (looking-at-p (regexp-quote "\\((")))
      (let* ((start (point))
             (call (list :start start :min (point-min) :max (point-max)))
             (span (progn (push call ep-calls)
                          (probe-scan start (point-max))))
             (end (plist-get span :end)) post)
        (save-excursion
          (goto-char end) (setq post (skip-chars-forward " \t")))
        (org-element-create
         'stm-fragment
         (list :begin start :end (+ end post) :post-blank post
               :value (buffer-substring-no-properties start end)
               :stm-source (plist-get span :tree))))
    (apply old args)))
