;;; document-boundary-probe.el --- Isolated observations -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'org-texmacs)
(load (expand-file-name "tests/ert/ert.el") nil t)
(defconst org-texmacs-probe-root (expand-file-name default-directory))
(defvar org-texmacs-probe-output nil)
(defun org-texmacs-probe-log (key value)
  (push (format "%s %S\n" key value) org-texmacs-probe-output))
(defun org-texmacs-probe-org ()
  (dolist (source '("First *bold*  after\tend.\nNext line.\n"
                    "* A *bold* title\n\n** Second\n*** Third\n***** Jump\n"
                    "* \n"
                    "Before (math (concat \"*not-org*\" \"[[file:x]]\"))  (math \"α\") after.\n"
                    "#+begin_texmacs\n(document (math \"x\"))\n#+end_texmacs\n"
                    "#+begin_texmacs\n\"atomic\"\n#+end_texmacs\n"))
    (with-temp-buffer
      (delay-mode-hooks (org-mode))
      (insert source)
      (let ((tick (buffer-chars-modified-tick)) (spans nil))
        (org-texmacs-probe-log 'source source)
        (org-element-map (org-element-parse-buffer) '(headline paragraph bold special-block)
          (lambda (node)
            (org-texmacs-probe-log 'node
              (list (org-element-type node)
                    :begin (org-element-property :begin node)
                    :end (org-element-property :end node)
                    :post-blank (org-element-property :post-blank node)
                    :level (org-element-property :level node)
                    :raw-title (org-element-property :raw-value node)))) )
        ;; Secondary title objects are inspected explicitly, without parent cycles.
        (org-element-map (org-element-parse-buffer) 'headline
          (lambda (node)
            (org-element-map (org-element-property :title node) 'bold
              (lambda (bold)
                (org-texmacs-probe-log 'title-bold
                  (list (org-element-property :post-blank bold)
                        (mapcar #'substring-no-properties (org-element-contents bold))))))))
        (org-texmacs-fragment-map (point-min) (point-max)
          (lambda (span) (push (org-texmacs-fragment-span-source span) spans)))
        (org-texmacs-probe-log 'spans (nreverse spans))
        (unless (and (equal source (buffer-string)) (= tick (buffer-chars-modified-tick)))
          (error "Source mutated")))))
  (org-texmacs-probe-log 'org-complete t))
(defun org-texmacs-probe-native ()
  (org-texmacs-test--with-worker
    (dolist (leaf '("ASCII" "中文" "α" "<alpha>" "<#4E2D>" "<less>" "<gtr>"
                    "中文 α <alpha>" "quote\"slash\\"))
      (let* ((input (list 'with "mode" "math" (list 'math (list 'frac leaf "2"))))
             (parsed (org-texmacs--worker-request (prin1-to-string input)))
             (back (org-texmacs--org-to-stree (org-texmacs--stree-to-org parsed))))
        (org-texmacs-probe-log 'parse (list input back (equal input back)))
        (unless (equal input back) (error "Parser changed test input"))))
    (dolist (source '("\"atomic\"" "(document (math \"x\"))"))
      (with-temp-buffer
        (delay-mode-hooks (org-mode))
        (insert "#+begin_texmacs\n" source "\n#+end_texmacs\n")
        (goto-char (point-min))
        (org-texmacs-probe-log 'block
          (org-texmacs--org-to-stree (org-texmacs-tree (org-element-at-point)))))))
  (let ((process-environment (copy-sequence process-environment))
        (dir (make-temp-file "native-" t)) (proc nil))
    (unwind-protect
        (with-temp-buffer
          (setenv "HOME" dir)
          (setenv "TEXMACS_HOME_PATH" (expand-file-name "config" dir))
          (let ((default-directory dir))
            (setq proc (make-process :name "document-boundary" :buffer (current-buffer)
                         :coding 'utf-8-unix :connection-type 'pipe :noquery t
                         :command (list (executable-find org-texmacs-program) "-H" "-s" "-x"
                           (format "(load %s)" (org-texmacs--scheme-string
                             (expand-file-name "tmp/document-boundary-native.scm" org-texmacs-probe-root)))))))
          (let ((deadline (+ (float-time) 80)))
            (while (and (process-live-p proc) (< (float-time) deadline))
              (accept-process-output proc 0.1)))
          (org-texmacs-probe-log 'native-output (buffer-string))
          (org-texmacs-probe-log 'native-exit (list (process-status proc) (process-exit-status proc)))
          (unless (and (eq (process-status proc) 'exit) (= (process-exit-status proc) 0)
                       (string-match-p "BOUNDARY complete #t" (buffer-string)))
            (error "Native experiment failed or timed out")))
      (when (and proc (process-live-p proc)) (delete-process proc))
      (delete-directory dir t))))
(defun org-texmacs-probe-run (group)
  (let* ((org-texmacs-probe-output nil)
         (temporary-file-directory (expand-file-name "tmp/" org-texmacs-probe-root))
         (report (expand-file-name (format "tmp/document-boundary-%s.log" group) org-texmacs-probe-root)))
    (unwind-protect
        (progn
          (org-texmacs-probe-log 'environment
            (list emacs-version (org-version) (locate-library "org")
                  (executable-find org-texmacs-program)))
          (pcase group ('org (org-texmacs-probe-org)) ('native (org-texmacs-probe-native))
            (_ (error "Unknown group"))))
      (let ((coding-system-for-write 'utf-8-unix))
        (write-region (apply #'concat (nreverse org-texmacs-probe-output)) nil report nil 'silent))
      (princ (format "Report: %s\n" report)))))
