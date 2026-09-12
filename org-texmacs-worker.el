;;; org-texmacs-worker.el --- TeXmacs worker for Org -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Share one lazy headless TeXmacs process across buffers.  Each synchronous
;; request gets its own Unix socket connection.  No Org edit hooks are needed.

;;; Code:

(require 'org-texmacs-core)

(define-error 'org-texmacs-worker-error "TeXmacs worker failure" 'org-texmacs-error)
(define-error 'org-texmacs-parse-error "Invalid STM source" 'org-texmacs-error)

(defcustom org-texmacs-worker-start-timeout 60
  "Maximum seconds to wait for the TeXmacs worker to start."
  :type 'number
  :group 'org-texmacs)

(defcustom org-texmacs-worker-request-timeout 10
  "Maximum seconds to wait for one TeXmacs response."
  :type 'number
  :group 'org-texmacs)

(defconst org-texmacs--worker-scheme-file
  (expand-file-name "org-texmacs-worker.scm"
                    (file-name-directory (or load-file-name buffer-file-name)))
  "Installed Scheme server next to this library.")

(defvar org-texmacs--worker-process nil)
(defvar org-texmacs--worker-directory nil)
(defvar org-texmacs--worker-socket nil)
(defvar org-texmacs--worker-buffer nil)
(defvar org-texmacs--worker-request-id 0)
(defvar org-texmacs--worker-busy nil)

(defun org-texmacs--worker-live-p ()
  "Return non-nil if the shared TeXmacs process is alive."
  (and org-texmacs--worker-process
       (process-live-p org-texmacs--worker-process)))

(defun org-texmacs--worker-stop ()
  "Stop the shared worker and remove its private socket directory.
Safe to call repeatedly.  The user's TeXmacs configuration is left intact."
  (let ((process org-texmacs--worker-process)
        (directory org-texmacs--worker-directory)
        (buffer org-texmacs--worker-buffer))
    ;; Clear state before deleting the process, since its sentinel may run.
    (setq org-texmacs--worker-process nil
          org-texmacs--worker-directory nil
          org-texmacs--worker-socket nil
          org-texmacs--worker-buffer nil)
    (remove-hook 'kill-emacs-hook #'org-texmacs--worker-stop)
    (unwind-protect
        (when (and process (process-live-p process))
          (delete-process process))
      (when (buffer-live-p buffer) (kill-buffer buffer))
      (when (and directory (file-directory-p directory))
        (delete-directory directory t)))))

(defun org-texmacs--worker-sentinel (process _event)
  "Clean up when shared worker PROCESS exits.  Ignore event text."
  (when (and (eq process org-texmacs--worker-process)
             (not (process-live-p process)))
    (org-texmacs--worker-stop)))

(defun org-texmacs--scheme-string (string)
  "Quote STRING for the Scheme reader without evaluating it.
Literal newlines and Unicode are preserved; quotes and backslashes are escaped."
  (let ((print-escape-newlines nil)
        (print-escape-control-characters nil)
        (print-escape-nonascii nil)
        (print-escape-multibyte nil)
        (print-length nil)
        (print-level nil))
    (prin1-to-string (substring-no-properties string))))

(defun org-texmacs--worker-wait (predicate process timeout)
  "Wait until PREDICATE succeeds while PROCESS lives, for TIMEOUT seconds.
Signal `org-texmacs-worker-error' on expiry or premature process exit."
  (unless (and (numberp timeout) (> timeout 0))
    (signal 'org-texmacs-worker-error '("Timeout must be positive")))
  (let ((deadline (+ (float-time) timeout)))
    (while (not (funcall predicate))
      (unless (and (process-live-p process) (< (float-time) deadline))
        (signal 'org-texmacs-worker-error '("Worker exited or timed out")))
      (accept-process-output process (min 0.05 (max 0 (- deadline (float-time))))))))

(defun org-texmacs--worker-start ()
  "Start the shared headless worker if necessary, and wait for readiness.
Use the user's normal environment.  Only the socket directory is temporary."
  (unless (org-texmacs--worker-live-p)
    (org-texmacs--worker-stop)
    (org-texmacs--ensure-setup)
    (unless (file-readable-p org-texmacs--worker-scheme-file)
      (signal 'org-texmacs-worker-error '("Scheme server file is missing")))
    (let ((ready nil))
      (unwind-protect
          (condition-case err
              (progn
                (setq org-texmacs--worker-directory
                      (make-temp-file "org-texmacs-" t)
                      org-texmacs--worker-socket
                      (expand-file-name "worker.sock" org-texmacs--worker-directory)
                      org-texmacs--worker-buffer
                      (generate-new-buffer " *org-texmacs-worker*"))
                (setq org-texmacs--worker-process
                      (make-process
                       :name "org-texmacs-worker"
                       :buffer org-texmacs--worker-buffer
                       :command
                       (list (executable-find org-texmacs-program) "-H" "-s" "-x"
                             (format "(begin (load %s) (org-texmacs-serve %s))"
                                     (org-texmacs--scheme-string org-texmacs--worker-scheme-file)
                                     (org-texmacs--scheme-string org-texmacs--worker-socket)))
                       :connection-type 'pipe :coding 'utf-8-unix :noquery t
                       :sentinel #'org-texmacs--worker-sentinel))
                (org-texmacs--worker-wait
                 (lambda ()
                   (and (buffer-live-p org-texmacs--worker-buffer)
                        (with-current-buffer org-texmacs--worker-buffer
                          (save-excursion
                            (goto-char (point-min))
                            (search-forward "ORG-TEXMACS-READY\n" nil t)))))
                 org-texmacs--worker-process org-texmacs-worker-start-timeout)
                (add-hook 'kill-emacs-hook #'org-texmacs--worker-stop)
                (setq ready t))
            (error
             (signal 'org-texmacs-worker-error
                     (list (error-message-string err)
                           (when (buffer-live-p org-texmacs--worker-buffer)
                             (with-current-buffer org-texmacs--worker-buffer
                               (buffer-substring-no-properties
                                (max (point-min) (- (point-max) 2000))
                                (point-max))))))))
        (unless ready (org-texmacs--worker-stop)))))
  org-texmacs--worker-process)

(defun org-texmacs--stree-p (node)
  "Return non-nil if NODE is a string or a proper tagged stree."
  (or (stringp node)
      (and (consp node) (symbolp (car node)) (car node)
           (proper-list-p node)
           (cl-every #'org-texmacs--stree-p (cdr node)))))

(defun org-texmacs--worker-decode (response id)
  "Read RESPONSE for request ID and return its stree.
Reject malformed envelopes and trailing data.  Source errors have their own
condition so callers can preserve a healthy worker."
  ;; Restrict the response reader, not subsequent validation or lazy loading.
  (let* ((parsed (let ((read-circle nil))
                   (read-from-string response)))
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

(defun org-texmacs--worker-request (source)
  "Parse SOURCE using the shared TeXmacs worker and return a stree.
SOURCE is STM data, never Scheme code to execute.  Only one request may run at
a time.  Parse errors preserve the worker; transport failures or cancellation
stop it so a later call can start a fresh process."
  (unless (stringp source)
    (signal 'wrong-type-argument (list 'stringp source)))
  (when org-texmacs--worker-busy
    (signal 'org-texmacs-worker-error '("Worker request already in progress")))
  (let ((org-texmacs--worker-busy t)
        (client nil)
        (healthy nil))
    (unwind-protect
        (condition-case err
            (progn
              (org-texmacs--worker-start)
              (with-temp-buffer
                (let ((id (cl-incf org-texmacs--worker-request-id)))
                  (setq client
                        (make-network-process
                         :name "org-texmacs-client" :family 'local
                         :service org-texmacs--worker-socket
                         :buffer (current-buffer) :coding 'utf-8-unix
                         :noquery t :sentinel #'ignore))
                  (process-send-string
                   client (format "(parse %d %s)\n" id (org-texmacs--scheme-string source)))
                  ;; EOF from the server frames the entire response, including
                  ;; partial reads.  The server stays alive after closing client.
                  (org-texmacs--worker-wait
                   (lambda () (not (process-live-p client)))
                   org-texmacs--worker-process org-texmacs-worker-request-timeout)
                  (prog1 (org-texmacs--worker-decode (buffer-string) id)
                    (setq healthy t)))))
          (org-texmacs-parse-error
           (setq healthy t)
           (signal (car err) (cdr err)))
          (error (signal 'org-texmacs-worker-error
                         (list (error-message-string err)))))
      (when (and client (process-live-p client)) (delete-process client))
      (unless healthy (org-texmacs--worker-stop)))))

(provide 'org-texmacs-worker)

;;; org-texmacs-worker.el ends here
