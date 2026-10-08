;;; v020-inline-probe.el --- Node 0 observations -*- lexical-binding: t; -*-

(require 'org-texmacs)
(require 'org-element)

(defconst org-texmacs-v020-probe-root
  (file-name-directory (directory-file-name
                        (file-name-directory (or load-file-name buffer-file-name)))))

(defun org-texmacs-v020-probe-shape (node)
  "Return a compact, non-circular description of NODE."
  (if (stringp node)
      (substring-no-properties node)
    (list (org-element-type node)
          (mapcar (lambda (key) (list key (org-element-property key node)))
                  '(:type :path :raw-link :format :label :value :application
                    :search-option :post-blank :begin :end))
          (mapcar #'org-texmacs-v020-probe-shape (org-element-contents node))
          (when (eq (org-element-type node) 'headline)
            (mapcar #'org-texmacs-v020-probe-shape
                    (org-element-property :title node))))))

(defun org-texmacs-v020-probe-org ()
  "Observe actual Org parsing without starting TeXmacs."
  (princ (format "Emacs=%s Org=%s\n" emacs-version (org-version)))
  (dolist (source
           (append
            '("A /italic/ _underline_ +strike+ ~code <alpha>~ =literal= Z\n"
              "A *bold /italic/* \t_tail_\tZ\n"
              "A\\\\\nB\n" "A\nB\n"
              "* Title /italic/ [[https://example.org][*bold*]]\n"
              "A [fn::中文 *bold* ~code~ [[mailto:a@example.org][mail]]] Z\n"
              "A [fn::one][fn::two] Z\n"
              "A [fn:named:inline] [fn:named]\n\n[fn:named] definition\n"
              "A *bold [fn::note]* [[https://example.org][label [fn::note]]] Z\n"
              "A [fn::outer [fn::inner]] Z\n"
              "A [fn::] Z\n"
              "[[file:notes.org::*Heading]] [[./notes.org]] [[file+emacs:notes.org]]\n"
              "[[https://example.org/%20?q=a%26b&v=中文#part][label]]\n"
              "[[HTTPS://example.org]]\n")
            (mapcar (lambda (uri) (format "[[%s]] [[%s][*label*]] <%s> %s\n"
                                         uri uri uri uri))
                    '("http://example.org/a" "https://example.org/a"
                      "mailto:a@example.org" "ftp://example.org/a"
                      "ftps://example.org/a"))))
    (with-temp-buffer
      (let ((org-element-use-cache nil) (org-inhibit-startup t))
        (delay-mode-hooks (org-mode))
        (insert source)
        (let ((before (buffer-string)) (ast (org-element-parse-buffer)))
          (princ (format "ORG %S => %S\n" source
                         (org-texmacs-v020-probe-shape ast)))
          (unless (equal before (buffer-string)) (error "Parser changed source"))))))
  ;; Compare a synthetic source-local abbreviation with private mode defaults.
  ;; This observes configuration transport; it does not execute user callbacks.
  (dolist (copy-settings '(nil t))
    (with-temp-buffer
      (delay-mode-hooks (org-mode))
      (setq-local org-link-abbrev-alist-local '(("v020" . "https://example.org/%s")))
      (insert "[[v020:item][label]]\n")
      (let ((source (buffer-string))
            (settings (copy-tree org-link-abbrev-alist-local))
            (source-shape (org-texmacs-v020-probe-shape (org-element-parse-buffer))))
        (with-temp-buffer
          (delay-mode-hooks (org-mode))
          (when copy-settings (setq-local org-link-abbrev-alist-local settings))
          (insert source)
          (let ((private-shape (org-texmacs-v020-probe-shape (org-element-parse-buffer))))
            (princ (format "CONFIG copied=%S equal=%S source=%S private=%S\n"
                           copy-settings (equal source-shape private-shape)
                           source-shape private-shape)))))))
  (princ "ORG observations complete\n"))

(defun org-texmacs-v020-probe-native (&optional scheme-file)
  "Run fixed native cases in one isolated headless TeXmacs process."
  (let* ((temporary-file-directory (expand-file-name "tmp/" org-texmacs-v020-probe-root))
         (dir (make-temp-file "v020-native-" t))
         (process-environment (copy-sequence process-environment))
         (output (generate-new-buffer " *v020-native*"))
         (program (executable-find org-texmacs-program))
         proc)
    (unwind-protect
        (progn
          (unless program (error "TeXmacs executable unavailable"))
          (setenv "HOME" dir)
          (setenv "TEXMACS_HOME_PATH" (expand-file-name "config" dir))
          (setenv "TMPDIR" dir)
          (princ (format "Emacs=%s Org=%s TeXmacs=%s\n"
                         emacs-version (org-version) program))
          (let ((default-directory dir))
            (setq proc
                  (make-process
                   :name "v020-native" :buffer output :connection-type 'pipe
                   :coding 'utf-8-unix :noquery t
                   :command
                   (list program "-H" "-s" "-x"
                         (format "(begin (load %s) (load %s))"
                                 (org-texmacs--scheme-string
                                  (expand-file-name "org-texmacs-worker.scm"
                                                    org-texmacs-v020-probe-root))
                                 (org-texmacs--scheme-string
                                  (expand-file-name (or scheme-file "tmp/v020-inline-probe.scm")
                                                    org-texmacs-v020-probe-root)))))))
          (let ((deadline (+ (float-time) 80)))
            (while (and (process-live-p proc) (< (float-time) deadline))
              (accept-process-output proc 0.1)))
          (princ (with-current-buffer output (buffer-string)))
          (princ (format "Native process=%S exit=%S\n"
                         (process-status proc) (process-exit-status proc)))
          (unless (and (eq (process-status proc) 'exit)
                       (= (process-exit-status proc) 0)
                       (with-current-buffer output
                         (string-match-p "V020 complete #t" (buffer-string))))
            (error "Native probe incomplete or a case failed")))
      (when (and proc (process-live-p proc)) (delete-process proc))
      (kill-buffer output)
      ;; Only remove this invocation's own fresh directory.
      (delete-directory dir t))))
