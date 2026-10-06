;;; reader-boundary-repro.el --- Capture decoder failures -*- lexical-binding: t; -*-
(require 'org-texmacs)
(load (expand-file-name "tests/ert/ert.el") nil t)
(defconst org-texmacs-reader-probe-root default-directory)
(defvar org-texmacs-reader-probe-raw nil)
(defvar org-texmacs-reader-probe-events nil)
(defun org-texmacs-reader-probe-offline ()
  "Capture a cold decoder failure without starting any worker."
  (let ((response "(ok 1 (with \"mode\" \"math\" (math (frac \"ASCII\" \"2\")))))\n")
        (trace nil) (result nil))
    (setq result
      (catch 'probe-debug
        (let ((debug-on-error t) (debug-on-signal t)
              (debugger (lambda (&rest args)
                          (setq trace (backtrace-to-string))
                          (throw 'probe-debug args))))
          (org-texmacs--worker-decode response 1))))
    (let ((coding-system-for-write 'utf-8-unix))
      (with-temp-buffer
        (insert (format "RESULT: %S\nTRACE:\n%s\n" result trace))
        (write-region (point-min) (point-max)
                      (expand-file-name "tmp/reader-boundary-offline.log" org-texmacs-reader-probe-root)
                      nil 'silent)
        (princ (buffer-string))))))
(defun org-texmacs-reader-probe-record (key value)
  (push (cons key value) org-texmacs-reader-probe-events))
(defun org-texmacs-reader-probe-run ()
  (let ((temporary-file-directory (expand-file-name "tmp/" org-texmacs-reader-probe-root))
        (org-texmacs-reader-probe-events nil)
        (org-texmacs-reader-probe-raw nil)
        (decode (symbol-function 'org-texmacs--worker-decode))
        (source "(with \"mode\" \"math\" (math (frac \"ASCII\" \"2\")))"))
    (unwind-protect
        (condition-case failure
            (org-texmacs-test--with-worker
              ;; Do not warm up the decoder or reader before the first request.
              (cl-letf (((symbol-function 'org-texmacs--worker-decode)
                         (lambda (response id)
                           (setq org-texmacs-reader-probe-raw (copy-sequence response))
                           (org-texmacs-reader-probe-record 'raw-response response)
                           (condition-case inner
                               (funcall decode response id)
                             (error
                              (org-texmacs-reader-probe-record 'decode-error inner)
                              (signal (car inner) (cdr inner)))))))
                (org-texmacs-reader-probe-record 'source source)
                (org-texmacs-reader-probe-record 'result (org-texmacs--worker-request source))))
          (error (org-texmacs-reader-probe-record 'request-error failure)))
      ;; Only after the original attempt: isolate reader vs decoder, no worker retry.
      (when org-texmacs-reader-probe-raw
        (condition-case failure
            (org-texmacs-reader-probe-record 'reader-only
              (let ((read-circle nil)) (read-from-string org-texmacs-reader-probe-raw)))
          (error (org-texmacs-reader-probe-record 'reader-only-error failure)))
        (condition-case failure
            (org-texmacs-reader-probe-record 'decode-replay
              (funcall decode org-texmacs-reader-probe-raw 1))
          (error (org-texmacs-reader-probe-record 'decode-replay-error failure))))
      (org-texmacs-reader-probe-record 'environment
        (list emacs-version (org-version) (executable-find org-texmacs-program)
              :reader-file (symbol-file 'read-from-string)
              :reader-subr (subrp (symbol-function 'read-from-string))
              :read-circle read-circle :load-in-progress load-in-progress))
      (let ((coding-system-for-write 'utf-8-unix)
            (print-circle t) (print-length nil) (print-level nil))
        (with-temp-buffer
          (dolist (event (reverse org-texmacs-reader-probe-events))
            (insert (format "%s: %S\n" (car event) (cdr event))))
          (write-region (point-min) (point-max)
                        (expand-file-name "tmp/reader-boundary-repro.log" org-texmacs-reader-probe-root)
                        nil 'silent)
          (princ (buffer-string)))))))
