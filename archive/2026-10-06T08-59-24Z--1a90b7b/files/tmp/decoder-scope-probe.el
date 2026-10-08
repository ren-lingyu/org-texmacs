;;; decoder-scope-probe.el --- Cold decoder scope comparison -*- lexical-binding: t; -*-
(require 'org-texmacs)
(defconst org-texmacs-scope-root default-directory)
;; Only functional difference from the production decoder: read-circle scope.
(defun org-texmacs-scope-narrow (response id)
  (let* ((parsed (let ((read-circle nil)) (read-from-string response)))
         (datum (car parsed)))
    (unless (and (string-match-p "\\`[ \t\r\n]*\\'" (substring response (cdr parsed)))
                 (proper-list-p datum) (= (length datum) 3)
                 (eql (nth 1 datum) id))
      (signal 'org-texmacs-worker-error '("Malformed or mismatched response")))
    (pcase (car datum)
      ('ok
       (unless (org-texmacs--stree-p (nth 2 datum))
         (signal 'org-texmacs-worker-error '("Invalid response stree")))
       (nth 2 datum))
      ('error
       (unless (stringp (nth 2 datum))
         (signal 'org-texmacs-worker-error '("Invalid error response")))
       (signal 'org-texmacs-parse-error (list (nth 2 datum))))
      (_ (signal 'org-texmacs-worker-error '("Unknown response status"))))))
(defun org-texmacs-scope-run (variant)
  (let ((decoder (if (eq variant 'original) #'org-texmacs--worker-decode
                   #'org-texmacs-scope-narrow))
        (events nil) (all-pass t))
    ;; No decoder/reader warm-up or backtrace printing before first case.
    (dolist (case
             '((normal "(ok 1 (with \"mode\" \"math\" (math (frac \"ASCII\" \"2\"))))\n"
                       value (with "mode" "math" (math (frac "ASCII" "2"))))
               (escaped "(\\o\\k 1 (\\m\\a\\t\\h \"中文\"))\n" value (math "中文"))
               (circle "(ok 1 #1=(math . #1#))" error invalid-read-syntax)
               (sharing "(ok 1 (concat #1=\"x\" #1#))" error invalid-read-syntax)
               (trailing "(ok 1 (math \"x\")) (other)" error org-texmacs-worker-error)
               (id "(ok 2 (math \"x\"))" error org-texmacs-worker-error)
               (stree "(ok 1 42)" error org-texmacs-worker-error)
               (remote-error "(error 1 \"Invalid STM source\")" error org-texmacs-parse-error)
               (unknown "(other 1 (math \"x\"))" error org-texmacs-worker-error)
               (after-errors "(ok 1 (sqrt \"x\"))" value (sqrt "x"))))
      (let* ((outcome (condition-case err (list 'value (funcall decoder (nth 1 case) 1))
                        (error (list 'error (car err) (cdr err)))))
             (pass (and (eq (car outcome) (nth 2 case))
                        (equal (nth 1 outcome) (nth 3 case)))))
        (unless pass (setq all-pass nil))
        (push (list (car case) :pass pass :outcome outcome) events)))
    (let ((coding-system-for-write 'utf-8-unix)
          (print-circle t) (print-length nil) (print-level nil))
      (with-temp-buffer
        (insert (format "variant=%S emacs=%s org=%s all-pass=%S\n"
                        variant emacs-version (org-version) all-pass))
        (dolist (event (reverse events)) (insert (format "%S\n" event)))
        (write-region (point-min) (point-max)
          (expand-file-name (format "tmp/decoder-scope-%s.log" variant) org-texmacs-scope-root)
          nil 'silent)
        (princ (buffer-string))))))
