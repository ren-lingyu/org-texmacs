;;; worker-load-repro.el --- Bounded worker reproduction -*- lexical-binding: t; -*-

(require 'cl-lib)
(load (expand-file-name "tests/ert/ert.el") nil t)
(defvar org-texmacs-repro-results nil)

(defun org-texmacs-repro-settings ()
  (mapcar (lambda (name)
            (cons name (if (boundp name) (symbol-value name) :unbound)))
          '(load-in-progress read-circle read-symbol-shorthands
            print-circle print-gensym print-length print-level
            print-escape-newlines print-escape-control-characters)))

(defun org-texmacs-repro-log (label value)
  (let ((print-circle t) (print-length 30) (print-level 10))
    (princ (format "%s: %S\n" label value))))

(defun org-texmacs-repro-run (phase)
  (dotimes (iteration 3)
    (org-texmacs-repro-log "CASE" (list phase (1+ iteration)))
    (org-texmacs-repro-log "SETTINGS" (org-texmacs-repro-settings))
    (let ((decode (symbol-function 'org-texmacs--worker-decode))
          (reader (symbol-function 'read-from-string)))
      (condition-case err
          (org-texmacs-test--with-worker
            (cl-letf (((symbol-function 'org-texmacs--worker-decode)
                       (lambda (response id)
                         (org-texmacs-repro-log "RAW-RESPONSE" response)
                         (org-texmacs-repro-log "DECODE-SETTINGS"
                                                (org-texmacs-repro-settings))
                         (cl-letf (((symbol-function 'read-from-string)
                                    (lambda (&rest args)
                                      (condition-case read-error
                                          (apply reader args)
                                        (error
                                         (org-texmacs-repro-log "READ-ERROR" read-error)
                                         (org-texmacs-repro-log "READ-SETTINGS"
                                                                (org-texmacs-repro-settings))
                                         (when (fboundp 'backtrace-to-string)
                                           (princ (backtrace-to-string)))
                                         (signal (car read-error) (cdr read-error)))))))
                           (funcall decode response id)))))
              (let* ((stree '(math (frac "1" (sqrt "x"))))
                     (source (prin1-to-string stree)))
                (org-texmacs-repro-log "SOURCE" source)
                (let ((result (org-texmacs--worker-request source)))
                  (unless (equal result stree)
                    (error "Unexpected stree: %S" result))
                  (org-texmacs-repro-log "RESULT" result)
                  (push (list phase (1+ iteration) 'ok)
                        org-texmacs-repro-results)))))
        (error
         (org-texmacs-repro-log "CASE-ERROR" err)
         (push (list phase (1+ iteration) err) org-texmacs-repro-results))))))

(defun org-texmacs-repro-after-load ()
  (org-texmacs-repro-run 'after-load)
  (org-texmacs-repro-log "SUMMARY" (reverse org-texmacs-repro-results)))

(org-texmacs-repro-run 'during-load)

;;; worker-load-repro.el ends here
