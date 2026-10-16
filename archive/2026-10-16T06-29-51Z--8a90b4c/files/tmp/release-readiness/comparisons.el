;;; comparisons.el --- Native diagnostic controls -*- lexical-binding: t; -*-
(require 'json)
(defvar rr-output (getenv "PROBE_OUTPUT"))
(defun rr-write (name value)
  (let ((coding-system-for-write 'utf-8-unix) (print-circle t))
    (with-temp-file (expand-file-name name rr-output) (prin1 value (current-buffer)) (insert "\n"))))
(let* ((first (getenv "FIRST_PROBE"))
       (body (with-temp-buffer (insert-file-contents (expand-file-name "equation-combined-tree.sexp" first)) (read (current-buffer))))
       (equation (cadr body))
       (initial '(("page-type" . "a4") ("page-odd" . "12.7mm") ("page-even" . "12.7mm")
                  ("page-right" . "12.7mm") ("page-top" . "12.7mm") ("page-bot" . "12.7mm"))))
 (org-texmacs-test--with-worker
  (dolist (case `(("direct" . (document ,equation))
                  ("concat-single" . (document (concat ,equation)))
                  ("concat-empty" . (document (concat ,equation "")))
                  ("concat-space" . (document (concat ,equation " ")))))
    (let* ((name (car case)) (doc (org-texmacs--document-create
                                  :style '("article") :initial initial :body (cdr case)
                                  :stm-paths (list (if (equal name "direct") '(0) '(0 0))))))
      (rr-write (concat name "-tree.sexp") (cdr case))
      (org-texmacs-document-save-pdf doc (expand-file-name (concat name ".pdf") rr-output))))
 ;; Native reload/export in a fresh TeXmacs process, no production protocol edits.
 (dolist (name '("equation-combined" "links" "links-native" "chinese"))
  (let* ((file (expand-file-name (concat name ".tm") first))
         (pdf (expand-file-name (concat name "-reloaded.pdf") rr-output))
         (treefile (expand-file-name (concat name "-reloaded-tree.sexp") rr-output))
         (scheme (format "(begin (catch #t (lambda () (load-buffer (system->url %S)) (call-with-output-file %S (lambda (p) (write (tree->stree (buffer-get-body (current-buffer))) p))) (do ((pass 0 (+ pass 1))) ((= pass 3)) (update-current-buffer)) (print-to-file (system->url %S)) (do ((pass 0 (+ pass 1))) ((= pass 3)) (update-current-buffer)) (print-to-file (system->url %S)) (display \"RELOAD-OK\\n\")) (lambda args (display \"RELOAD-ERROR:\") (write args) (newline))) (quit-TeXmacs))" file treefile pdf pdf))
         (process-environment (copy-sequence process-environment)))
    (setenv "TEXMACS_HOME_PATH" (expand-file-name (concat "config-" name) temporary-file-directory))
    (with-temp-buffer
      (let ((status (let ((script (expand-file-name (concat name "-reload.scm") rr-output)))
                      (let ((coding-system-for-write 'utf-8-unix))
                        (with-temp-file script
                          (insert "(use-modules (generic document-edit))\n" scheme "\n")))
                      (call-process "timeout" nil t nil "25s" org-texmacs-program "-H" "-s" "-x"
                                    (format "(load %S)" script)))))
        (rr-write (concat name "-reload-status.sexp") (list :status status :output (buffer-string)))))))
 ;; Preserve exact relevant native definitions for causal/configuration audit.
 (let ((root (expand-file-name "share/TeXmacs" (getenv "TEXMACS_PACKAGE"))))
  (dolist (path '("progs/texmacs/texmacs/tm-files.scm" "progs/texmacs/texmacs/tm-print.scm"
                  "packages/standard/std-math.ts"))
    (let ((file (expand-file-name path root)))
      (when (and (file-regular-p file) (< (file-attribute-size (file-attributes file)) 1048576))
        (copy-file file (expand-file-name (file-name-nondirectory path) rr-output)))))))
)
