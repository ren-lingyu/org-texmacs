;;; org-texmacs-session.el --- Native buffer sessions for Org TeXmacs -*- lexical-binding: t; package-lint-main-file: "org-texmacs.el"; -*-

;; Copyright (C) 2026 aRenCoco
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; One explicit native buffer session in the shared worker.  Handles belong
;; to one process incarnation; restarting the worker never revives a handle.
;; No GUI windows, edit hooks or automatic updates are created.
;; Independent serialization and explicit new-file saving consume the same fields.

;;; Code:

(require 'org-texmacs-worker)
(require 'org-texmacs-document)

(defun org-texmacs--native-hex-stree-p (node)
  "Return non-nil for a stree whose leaves are lowercase hexadecimal bytes."
  (if (stringp node)
      (and (zerop (% (length node) 2))
           (let ((case-fold-search nil))
             (string-match-p "\\`[0-9a-f]*\\'" node)))
    (and (consp node) (car node) (symbolp (car node))
         (proper-list-p node)
         (cl-every #'org-texmacs--native-hex-stree-p (cdr node)))))

(defun org-texmacs--native-document-p (node)
  "Return non-nil for a complete native session diagnostic NODE."
  (and (consp node) (eq (car node) 'native-document) (= (length node) 4)
       (let ((style (nth 1 node)) (initial (nth 2 node))
             (body (nth 3 node)) keys)
         (and (consp style) (eq (car style) 'style) (cdr style)
              (cl-every (lambda (name)
                          (and (stringp name) (> (length name) 0)))
                        (cdr style))
              (consp initial) (eq (car initial) 'initial)
              (cl-every
               (lambda (entry)
                 (and (consp entry) (eq (car entry) 'associate)
                      (= (length entry) 3)
                      (stringp (cadr entry)) (> (length (cadr entry)) 0)
                      (not (member (cadr entry) keys))
                      (prog1 (org-texmacs--native-hex-stree-p (caddr entry))
                        (push (cadr entry) keys))))
               (cdr initial))
              (consp body) (eq (car body) 'body) (= (length body) 2)
              (consp (cadr body)) (eq (caadr body) 'document)
              (org-texmacs--native-hex-stree-p (cadr body))))))

(defun org-texmacs--native-decode-datum (datum operation)
  "Decode native response DATUM according to fixed OPERATION semantics."
  (pcase (car datum)
    ('ok
     (unless (org-texmacs--stree-p (nth 2 datum))
       (signal 'org-texmacs-worker-error '("Invalid response stree")))
     (let ((payload (nth 2 datum)))
       (cond
        ((memq operation '(session-open session-set session-close))
         (unless (and (consp payload) (= (length payload) 2)
                      (eq (car payload) (pcase operation
                                          ('session-open 'session)
                                          ('session-set 'updated)
                                          ('session-close 'closed)))
                      (stringp (cadr payload))
                      (string-match-p "\\`[1-9][0-9]*\\'" (cadr payload)))
           (signal 'org-texmacs-worker-error '("Invalid session response")))
         (cadr payload))
        ((eq operation 'encode)
         (unless (and (consp payload) (eq (car payload) 'native-body)
                      (= (length payload) 2)
                      (consp (cadr payload)) (eq (caadr payload) 'document)
                      (org-texmacs--native-hex-stree-p (cadr payload)))
           (signal 'org-texmacs-worker-error '("Invalid encoded body response")))
         (cadr payload))
        ((eq operation 'session-read)
         (unless (org-texmacs--native-document-p payload)
           (signal 'org-texmacs-worker-error '("Invalid native document response")))
         payload)
        ((eq operation 'serialize)
         (unless (and (consp payload) (eq (car payload) 'serialized-document)
                      (= (length payload) 3)
                      (stringp (cadr payload))
                      (string-match-p "\\`[0-9][[:alnum:].+-]*\\'" (cadr payload))
                      (stringp (caddr payload))
                      (org-texmacs--native-hex-stree-p (caddr payload)))
           (signal 'org-texmacs-worker-error '("Invalid serialized document response")))
         (let* ((hex (caddr payload))
                (bytes (make-string (/ (length hex) 2) 0))
                (header (concat "<TeXmacs|" (cadr payload) ">")))
           (dotimes (index (length bytes))
             (aset bytes index (string-to-number (substring hex (* index 2) (+ (* index 2) 2)) 16)))
           (unless (string-prefix-p header bytes)
             (signal 'org-texmacs-worker-error '("Serialized document header mismatch")))
           bytes))
        (t (signal 'org-texmacs-worker-error '("Unknown native operation"))))))
    ('session-error
     (unless (and (memq operation '(session-open session-set session-close session-read))
                  (stringp (nth 2 datum)))
       (signal 'org-texmacs-worker-error '("Unexpected session error response")))
     (signal 'org-texmacs-session-error (list (nth 2 datum))))
    ('encoding-error
     (unless (and (memq operation '(encode session-set serialize))
                  (stringp (nth 2 datum)))
       (signal 'org-texmacs-worker-error '("Unexpected encoding error response")))
     (signal 'org-texmacs-encoding-error (list (nth 2 datum))))
    ('serialization-error
     (unless (and (eq operation 'serialize) (stringp (nth 2 datum)))
       (signal 'org-texmacs-worker-error '("Unexpected serialization error response")))
     (signal 'org-texmacs-serialization-error (list (nth 2 datum))))
    (_ (signal 'org-texmacs-worker-error '("Unknown response status")))))

(defun org-texmacs--native-decode (response id operation)
  "Read and decode native RESPONSE for request ID and OPERATION.
This pure protocol helper does not change worker lifecycle state."
  (org-texmacs--native-decode-datum
   (org-texmacs--worker-read-response response id) operation))

(defun org-texmacs--native-call (make-request operation)
  "Run MAKE-REQUEST through the worker and decode native OPERATION.
Application errors preserve the worker.  Invalid native protocol payloads
stop it so a later call cannot reuse a semantically inconsistent peer."
  (let ((datum (org-texmacs--worker-call make-request)))
    (condition-case err
        (org-texmacs--native-decode-datum datum operation)
      ((org-texmacs-encoding-error org-texmacs-session-error org-texmacs-serialization-error)
       (signal (car err) (cdr err)))
      (org-texmacs-worker-error
       (org-texmacs--worker-stop)
       (signal (car err) (cdr err))))))

(defun org-texmacs--native-file-target (path base)
  "Translate a raw local file PATH using explicit resource BASE.
Return an absolute system path for TeXmacs's native URL handler.  Never read
files, expand a home abbreviation or infer a base from the current buffer."
  (unless (and (org-texmacs--document-local-file-path-p path)
               (or (null base) (org-texmacs--document-local-file-path-p base)))
    (signal 'org-texmacs-encoding-error '("Unsupported native file target")))
  (let ((file-name-handler-alist nil))
    (when base
      (condition-case err
          (setq base (org-texmacs--source-copy-path base))
        (org-texmacs-document-error
         (signal 'org-texmacs-encoding-error (cdr err)))))
    (unless (or (file-name-absolute-p path) base)
      (signal 'org-texmacs-encoding-error '("Relative native file target requires a resource base")))
    (let ((absolute (expand-file-name path (or base "/"))))
      ;; TeXmacs navigation interprets query/anchor and URL expression syntax.
      ;; Preserve these filenames structurally, but reject this native subset.
      (when (cl-some (lambda (character)
                       (string-match-p (regexp-quote character) absolute))
                     '("#" "?" "*" "$" "|" "\\" "[" "]"))
        (signal 'org-texmacs-encoding-error '("Unsupported character in native file target")))
      absolute)))

(defun org-texmacs--native-resolve-file-paths (body files stm-paths base)
  "Replace file target leaves in copied BODY using FILES and BASE.
Validate target roles and separation from STM-PATHS before serializing."
  (unless (proper-list-p files)
    (signal 'org-texmacs-encoding-error '("Expected proper file target paths")))
  (let (seen)
    (dolist (path files)
      (unless (and (proper-list-p path) path
                   (not (member path seen))
                   (cl-every (lambda (index) (and (integerp index) (>= index 0))) path))
        (signal 'org-texmacs-encoding-error '("Invalid or duplicate file target path")))
      (push path seen)
      (dolist (stm stm-paths)
        (let ((a path) (b stm))
          (while (and a b (= (car a) (car b)))
            (setq a (cdr a) b (cdr b)))
          (when (or (null a) (null b))
            (signal 'org-texmacs-encoding-error '("File target overlaps STM provenance")))))
      (let ((parent body) (steps path))
        (while (cdr steps)
          (let ((index (pop steps)))
            (unless (and (consp parent) (< index (length (cdr parent))))
              (signal 'org-texmacs-encoding-error '("File target path is out of bounds")))
            (setq parent (nth (1+ index) parent))))
        (unless (and (= (car steps) 1) (consp parent)
                     (eq (car parent) 'hlink) (= (length parent) 3)
                     (stringp (nth 2 parent)))
          (signal 'org-texmacs-encoding-error '("File target path does not name an hlink target")))
        (setcar (cddr parent)
                (org-texmacs--native-file-target (nth 2 parent) base))))))

(defun org-texmacs--native-document-wire (document)
  "Validate DOCUMENT and serialize its native fields as Scheme data.
Translate marked local file targets on a body copy using the captured resource
base.  Return style, initial, body and STM-path arguments without a process."
  (unless (org-texmacs-document-p document)
    (signal 'org-texmacs-encoding-error '("Expected a document result")))
  (let ((body nil) (style nil) (initial nil)
        (paths (org-texmacs-document-stm-paths document)))
    (condition-case err
        (setq body (org-texmacs--document-copy-stree
                    (org-texmacs-document-body document))
              style (org-texmacs--document-copy-style
                     (org-texmacs-document-style document))
              initial (org-texmacs--document-copy-initial
                       (org-texmacs-document-initial document)))
      (org-texmacs-document-error
       (signal 'org-texmacs-encoding-error (cdr err))))
    (unless (and (consp body) (eq (car body) 'document) (proper-list-p paths))
      (signal 'org-texmacs-encoding-error
              '("Expected document body and proper STM paths")))
    (dolist (path paths)
      (unless (proper-list-p path)
        (signal 'org-texmacs-encoding-error '("Invalid STM path")))
      (let ((node body))
        (dolist (index path)
          (unless (and (integerp index) (>= index 0) (consp node)
                       (< index (length (cdr node))))
            (signal 'org-texmacs-encoding-error '("STM path is out of bounds")))
          (setq node (nth (1+ index) node)))))
    (let ((rest paths))
      (while rest
        (dolist (other (cdr rest))
          (let ((a (car rest)) (b other))
            (while (and a b (= (car a) (car b)))
              (setq a (cdr a) b (cdr b)))
            (when (or (null a) (null b))
              (signal 'org-texmacs-encoding-error '("Overlapping STM paths")))))
        (setq rest (cdr rest))))
    (org-texmacs--native-resolve-file-paths
     body (org-texmacs-document-file-paths document) paths
     (org-texmacs-document-resource-base document))
    (cl-labels
        ((wire
          (node)
          (if (stringp node)
              (org-texmacs--scheme-string node)
            (when (eq (car node) 'raw-data)
              (signal 'org-texmacs-encoding-error '("raw-data is not supported")))
            (concat "(" (org-texmacs--scheme-string (symbol-name (car node)))
                    (mapconcat (lambda (child) (concat " " (wire child)))
                               (cdr node) "")
                    ")"))))
      ;; Serialize before starting the worker: invalid input has no process effects.
      (let ((style-wire
             (concat "(" (mapconcat #'org-texmacs--scheme-string style " ") ")"))
            (initial-wire
             (concat
              "("
              (mapconcat
               (lambda (entry)
                 (concat "(" (org-texmacs--scheme-string (car entry)) " "
                         (wire (cdr entry)) ")"))
               initial " ")
              ")"))
            (tree-wire (wire body))
            (paths-wire
             (concat "("
                     (mapconcat
                      (lambda (path)
                        (concat "(" (mapconcat #'number-to-string path " ") ")"))
                      paths " ")
                     ")")))
        (mapconcat #'identity
                   (list style-wire initial-wire tree-wire paths-wire) " ")))))

(defun org-texmacs--native-encode-document (document)
  "Encode text DOCUMENT and return a diagnostic hex-leaf body stree.
Validate all document fields, though only the body is returned.  Never feed
the result back to this encoder.  No files or persistent buffers are created."
  (let ((wire (org-texmacs--native-document-wire document)))
    (org-texmacs--native-call
     (lambda (id) (format "(encode %d %s)\n" id wire)) 'encode)))

(defun org-texmacs-document-serialize (document)
  "Return DOCUMENT as a complete native TeXmacs .tm byte string.
Consume a completed `org-texmacs-document' result using its explicit style,
initial environment, body and provenance.  Translate marked file links with
the captured resource base, then encode once and construct the file wrapper
with the running TeXmacs version.  Use TeXmacs's native serializer.
The returned unibyte string preserves native output bytes; write it with
`no-conversion' when a separate caller chooses to save it.  Never feed it back
to the document encoder.  No output file or native session is created, and an
existing live session is not read or updated.  The shared worker may start.
Preflight, encoding and serialization errors preserve a healthy worker;
invalid response payloads stop it.  No source buffer or resource file is read."
  (let ((wire (org-texmacs--native-document-wire document)))
    (org-texmacs--native-call
     (lambda (id) (format "(serialize %d %s)\n" id wire)) 'serialize)))

(defun org-texmacs--native-save-target (file)
  "Validate and own explicit local output FILE before conversion waits.
Require an existing parent and reject all existing targets without handlers."
  (let ((file-name-handler-alist nil))
    (unless (and (org-texmacs--document-local-file-path-p file)
                 (file-name-absolute-p file)
                 (not (string-match-p "\0" file))
                 (> (length (file-name-nondirectory file)) 0))
      (signal 'org-texmacs-error '("Expected an explicit absolute local output file")))
    (let ((target (substring-no-properties file)))
      (when (or (file-exists-p target) (file-symlink-p target))
        (signal 'file-already-exists (list "Output already exists" target)))
      (unless (file-directory-p (file-name-directory target))
        (signal 'file-missing (list "Output directory does not exist" target)))
      target)))

(defun org-texmacs--native-save-bytes (bytes target)
  "Write native unibyte BYTES to an already owned and validated TARGET.
Exclusive open rejects collisions after preflight; file errors propagate."
  (unless (and (stringp bytes) (not (multibyte-string-p bytes)))
    (signal 'org-texmacs-error '("Expected native output bytes")))
  (let ((file-name-handler-alist nil)
        (coding-system-for-write 'no-conversion)
        (inhibit-modification-hooks t)
        (write-region-annotate-functions nil)
        (write-region-post-annotation-function nil))
    (with-temp-buffer
      (set-buffer-multibyte nil)
      (setq buffer-file-format nil)
      (insert bytes)
      (write-region (point-min) (point-max) target nil 'silent nil 'excl))
    target))

(defun org-texmacs-document-save (document file)
  "Save DOCUMENT as a new native TeXmacs file at explicit absolute FILE.
FILE must name a local file in an existing directory.  Copy its identity before
serializing so mutation during a worker wait cannot redirect the write.
Return the copied path.  Never overwrite existing files, directories or
symlinks: exclusive creation checks collisions again at the actual open.
Complete `org-texmacs-document-serialize' before opening FILE.  Preserve its
native bytes without coding/format conversion, annotations or file handlers.
Do not create directories, visit the output or change a live native session.
Serialization errors create no output.  Filesystem errors propagate normally;
a write failure can leave a newly created partial file for the caller to
inspect.  This is exclusive creation, not atomic replacement or publication."
  (let ((target (org-texmacs--native-save-target file)))
    (org-texmacs--native-save-bytes (org-texmacs-document-serialize document) target)))

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
WIRE must already be validated by `org-texmacs--native-document-wire'."
  (org-texmacs--session-check session)
  (condition-case err
      (let ((result
             (org-texmacs--native-call
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
  "Create an empty native TeXmacs document buffer and return its opaque handle.
Start the shared worker lazily.  Only one session may be active; another
open signals `org-texmacs-session-error' without replacing the existing one.
Create an internal headless view required by TeXmacs document APIs, but no GUI
window or external document file.  The caller must explicitly close the
session.  Worker termination releases it and makes its handle stale."
  (let ((owner nil))
    (let ((key (org-texmacs--native-call
                (lambda (id)
                  (setq owner org-texmacs--worker-process)
                  (format "(session-open %d)\n" id))
                'session-open)))
      (unless (and (eq owner org-texmacs--worker-process) (org-texmacs--worker-live-p))
        (signal 'org-texmacs-session-error '("Worker exited while opening session")))
      (org-texmacs--session-create :key key :process owner))))

;;;###autoload
(defun org-texmacs-session-set-document (session document)
  "Replace SESSION's complete native state from text DOCUMENT and return SESSION.
DOCUMENT is a result from `org-texmacs-document', not a hex diagnostic tree.
Validate and encode style, initial environment and body before mutation, using
STM provenance for body islands, captured context for file targets, and source
semantics for initial
values.  Then replace style, clear old explicit initial values, set the new
initial environment and body, and read all fields back.  TeXmacs may normalize
the style list; initial comparison is unordered.  Preflight or encoding errors
leave the old document intact.  Native update/readback failure discards the
session; transport failure stops the worker and invalidates all its handles.
Do not update incrementally or promise rendering or pagination."
  (org-texmacs--session-check session)
  (let ((wire (org-texmacs--native-document-wire document)))
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
  (let ((document (org-texmacs--session-read-document session)))
    (cadr (assq 'body (cdr document)))))

(defun org-texmacs--session-read-document (session)
  "Read SESSION's style, initial and body as a diagnostic native stree.
Style and initial keys remain identifier strings.  Initial values and body
leaves are native bytes represented as lowercase hexadecimal strings."
  (org-texmacs--session-command session 'session-read))

(provide 'org-texmacs-session)

;;; org-texmacs-session.el ends here
