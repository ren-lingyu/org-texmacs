;;; stm-leaf-probe.el --- Direct leaf experiment -*- lexical-binding: t; -*-
(require 'org-texmacs)
(defconst org-texmacs-leaf-root (expand-file-name default-directory))
(defun org-texmacs-leaf-run ()
  (let* ((temporary-file-directory (expand-file-name "tmp/" org-texmacs-leaf-root))
         (dir (make-temp-file "stm-leaf-" t))
         (process-environment (copy-sequence process-environment))
         (output (generate-new-buffer " *stm-leaf*")) (proc nil))
    (unwind-protect
        (progn
          (setenv "HOME" dir)
          (setenv "TEXMACS_HOME_PATH" (expand-file-name "config" dir))
          (let ((default-directory dir))
            (setq proc
              (make-process :name "stm-leaf" :buffer output :connection-type 'pipe
                :coding 'utf-8-unix :noquery t
                :command
                (list (executable-find org-texmacs-program) "-H" "-s" "-x"
                  (format "(begin (load %s) (load %s))"
                    (org-texmacs--scheme-string
                      (expand-file-name "org-texmacs-worker.scm" org-texmacs-leaf-root))
                    (org-texmacs--scheme-string
                      (expand-file-name "tmp/stm-leaf-probe.scm" org-texmacs-leaf-root)))))))
          (let ((deadline (+ (float-time) 80)))
            (while (and (process-live-p proc) (< (float-time) deadline))
              (accept-process-output proc 0.1)))
          (with-current-buffer output
            (goto-char (point-min))
            (insert (format "Emacs=%s Org=%s TeXmacs=%s\n" emacs-version (org-version)
                            (executable-find org-texmacs-program)))
            (goto-char (point-max))
            (insert (format "\nProcess=%S exit=%s\n" (process-status proc) (process-exit-status proc)))
            (let ((coding-system-for-write 'utf-8-unix))
              (write-region (point-min) (point-max)
                (expand-file-name "tmp/stm-leaf-results.log" org-texmacs-leaf-root) nil 'silent))
            (princ (buffer-string))
            (unless (and (eq (process-status proc) 'exit) (= (process-exit-status proc) 0)
                         (string-match-p "LEAF complete #t" (buffer-string)))
              (error "STM leaf probe incomplete or failed"))))
      (when (and proc (process-live-p proc)) (delete-process proc))
      (kill-buffer output)
      (delete-directory dir t))))
