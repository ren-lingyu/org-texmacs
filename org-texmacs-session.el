;;; org-texmacs-session.el --- Native buffer sessions for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; One explicit native buffer session in the shared worker.  Handles belong
;; to one process incarnation; restarting the worker never revives a handle.
;; No windows, document files, edit hooks or automatic updates are created.

;;; Code:

(require 'org-texmacs-worker)

(cl-defstruct (org-texmacs-session
               (:constructor org-texmacs--session-create)
               (:copier nil))
  "Opaque native buffer handle.  Callers must not mutate its slots."
  (key nil :read-only t)
  (process nil :read-only t)
  (closed nil))

(defun org-texmacs--session-live-p (session)
  "Return non-nil if SESSION still belongs to the current live worker."
  (and (org-texmacs-session-p session)
       (not (org-texmacs-session-closed session))
       (eq (org-texmacs-session-process session) org-texmacs--worker-process)
       (org-texmacs--worker-live-p)))

(defun org-texmacs--session-check (session)
  "Reject closed, stale or invalid SESSION without starting a worker."
  (unless (org-texmacs--session-live-p session)
    (signal 'org-texmacs-session-error '("Session is closed, stale or invalid"))))

(defun org-texmacs--session-command (session operation &optional wire)
  "Run fixed session OPERATION on SESSION, optionally with document WIRE.
WIRE must already be validated by `org-texmacs--worker-document-wire'."
  (org-texmacs--session-check session)
  (condition-case err
      (let ((result
             (org-texmacs--worker-call
              (lambda (id)
                ;; Check again after worker startup, before sending a handle.
                (org-texmacs--session-check session)
                (format "(%s %d %s%s)\n" operation id
                        (org-texmacs--scheme-string (org-texmacs-session-key session))
                        (if wire (concat " " wire) "")))
              operation)))
        (unless (or (eq operation 'session-read)
                    (equal result (org-texmacs-session-key session)))
          (org-texmacs--worker-stop)
          (signal 'org-texmacs-worker-error '("Mismatched session response")))
        result)
    (org-texmacs-session-error
     (setf (org-texmacs-session-closed session) t)
     (signal (car err) (cdr err)))))

;;;###autoload
(defun org-texmacs-session-open ()
  "Create an empty native TeXmacs body buffer and return its opaque handle.
Start the shared worker lazily.  Only one session may be active; another
open signals `org-texmacs-session-error' without replacing the existing one.
Create no view or external document file.  The caller must explicitly close
the session.  Worker termination releases it and makes its handle stale."
  (let ((owner nil))
    (let ((key (org-texmacs--worker-call
                (lambda (id)
                  (setq owner org-texmacs--worker-process)
                  (format "(session-open %d)\n" id))
                'session-open)))
      (unless (and (eq owner org-texmacs--worker-process) (org-texmacs--worker-live-p))
        (signal 'org-texmacs-session-error '("Worker exited while opening session")))
      (org-texmacs--session-create :key key :process owner))))

;;;###autoload
(defun org-texmacs-session-set-document (session document)
  "Replace SESSION's complete body with text DOCUMENT and return SESSION.
DOCUMENT is a result from `org-texmacs-document', not a hex diagnostic tree.
Encode once in the worker, using STM provenance, then set and read back the
native body.  Preflight or encoding errors leave the old body intact.
Native update/readback failure discards the session; transport failure stops
the worker and invalidates all its handles.  Do not update incrementally or
promise numbering, references, rendering, style or initial metadata mapping."
  (org-texmacs--session-check session)
  (let ((wire (org-texmacs--worker-document-wire document)))
    (org-texmacs--session-command session 'session-set wire))
  session)

;;;###autoload
(defun org-texmacs-session-close (session)
  "Close SESSION's native buffer and return nil, leaving the worker alive.
Repeated close, or close after worker termination, is a local no-op.  Never
restart a worker to close a stale handle or close a new worker's buffer."
  (unless (org-texmacs-session-p session)
    (signal 'org-texmacs-session-error '("Expected a session handle")))
  (when (org-texmacs--session-live-p session)
    (org-texmacs--session-command session 'session-close))
  (setf (org-texmacs-session-closed session) t)
  nil)

(defun org-texmacs--session-read (session)
  "Read SESSION's native body as a diagnostic hex-leaf stree, not text."
  (org-texmacs--session-command session 'session-read))

(provide 'org-texmacs-session)

;;; org-texmacs-session.el ends here
