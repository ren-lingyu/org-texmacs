;;; frontend.el --- native frontend regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest
    org-texmacs-cleanup-local-discovery-and-direct-preparation
    ()
  (org-texmacs-test--with-cleanup-source
   (erase-buffer)
   (insert "* Heading\nLocal text\n")
   (setq-local org-texmacs-export-discover-bibliography t)
   (let ((before
          (org-texmacs-test--document-buffer-state (current-buffer)))
         (file buffer-file-name))
     (should
      (org-texmacs-input-p
       (org-texmacs-prepare-buffer (current-buffer))))
     (save-restriction
       (narrow-to-region 1 (point-max))
       (let
           ((kinds
             (org-texmacs-test--observe-cleanup
              (lambda ()
                (should
                 (org-texmacs-document-p
                  (org-texmacs-document-from-buffer-discover-bibliography
                   (current-buffer) nil 1)))))))
         (should (equal kinds '(bibliography)))))
     (should
      (equal
       before
       (org-texmacs-test--document-buffer-state (current-buffer))))
     (should (equal file buffer-file-name)))))

(ert-deftest org-texmacs-export-backend-dispatch-option-rejection ()
  (with-temp-buffer
    (org-mode)
    (insert "Source.\n")
    (let ((org-export-dispatch-last-action nil)
          (org-export-dispatch-last-position (make-marker)))
      (cl-letf (((symbol-function 'read-file-name)
                 (lambda (&rest _)
                   (ert-fail
                    "Unsupported dispatcher option prompted"))))
        (dolist (option '(async visible body))
          (cl-letf (((symbol-function 'org-export--dispatch-ui)
                     (lambda (&rest _)
                       (list
                        #'org-texmacs-export-to-texmacs option))))
            (should-error
             (org-export-dispatch)
             :type 'user-error)))))))

(ert-deftest org-texmacs-export-backend-buffer-display-error-cleanup
    ()
  (let ((org-texmacs--export-managed-buffer nil))
    (with-temp-buffer
      (org-mode)
      (let ((output
             (generate-new-buffer " *texmacs-frontend-failure*"))
            (existing
             (generate-new-buffer " *texmacs-frontend-existing*"))
            (org-export-show-temporary-export-buffer t))
        (unwind-protect
            (cl-letf (((symbol-function
                        'org-texmacs--export-byte-consumer)
                       (lambda (&rest _)
                         (lambda (&rest _) (unibyte-string ?A))))
                      ((symbol-function
                        'org-texmacs--export-byte-buffer)
                       (lambda (&rest _) output))
                      ((symbol-function 'display-buffer)
                       (lambda (&rest _) (error "Display failure"))))
              (should-error (org-texmacs-export-as-texmacs))
              (should-not (buffer-live-p output))
              (should (buffer-live-p existing)))
          (when (buffer-live-p output)
            (kill-buffer output))
          (kill-buffer existing))))))

(ert-deftest org-texmacs-export-backend-generic-preprocessing-guard ()
  (with-temp-buffer
    (org-mode)
    (insert "#+INCLUDE: never-read.org\nSource.\n")
    (let ((original (buffer-string)))
      (cl-letf (((symbol-function 'org-export-expand-include-keyword)
                 (lambda (&rest _)
                   (ert-fail
                    "TeXmacs generic export expanded INCLUDE")))
                ((symbol-function 'org-babel-exp-process-buffer)
                 (lambda (&rest _)
                   (ert-fail
                    "TeXmacs generic export invoked Babel"))))
        (should-error (org-export-as 'texmacs) :type 'user-error))
      (should (equal original (buffer-string)))))
  (require 'ox-ascii)
  (with-temp-buffer
    (org-mode)
    (insert "UnrelatedBackendSentinel.\n")
    (should
     (string-match-p
      "UnrelatedBackendSentinel" (org-export-as 'ascii nil nil t)))))

(ert-deftest
    org-texmacs-export-backend-html-hook-advice-filter-isolation
    ()
  ;; Exercise actual HTML export with controlled extension points.  This is
  ;; not a joint Org-roam package/database integration test.
  (require 'ox-html)
  (with-temp-buffer
    (org-mode)
    (insert "FilterInputSentinel.\n")
    (goto-char 3)
    (set-mark 8)
    (setq mark-active nil)
    (set-buffer-modified-p nil)
    (let* ((source (current-buffer))
           (state (org-texmacs-test--document-buffer-state source))
           (org-export-use-babel nil)
           (options '(:with-toc nil :section-numbers nil))
           (baseline (org-export-as 'html nil nil t options))
           events
           (preprocess
            (lambda (backend)
              (when (eq backend 'html)
                (should-not (eq source (current-buffer)))
                (push 'hook events)
                (goto-char (point-max))
                (insert "\nHookBodySentinel.\n"))))
           (include-advice
            (lambda (original &rest arguments)
              (when (eq org-export-current-backend 'html)
                (push 'advice events))
              (apply original arguments)))
           (filter
            (lambda (tree backend _info)
              (when (eq backend 'html)
                (push 'filter events)
                (org-element-map
                 tree 'paragraph
                 (lambda (paragraph)
                   (when (cl-some
                          (lambda (part)
                            (and (stringp part)
                                 (string-match-p
                                  "FilterInputSentinel" part)))
                          (org-element-contents paragraph))
                     (org-element-set-contents
                      paragraph "FilterOutputSentinel.")))))
              tree)))
      (should (string-match-p "FilterInputSentinel" baseline))
      (unwind-protect
          (let ((org-export-before-processing-functions
                 (append
                  (copy-sequence
                   org-export-before-processing-functions)
                  (list preprocess)))
                (org-export-filter-parse-tree-functions
                 (append
                  (copy-sequence
                   org-export-filter-parse-tree-functions)
                  (list filter))))
            (advice-add
             'org-export-expand-include-keyword
             :around include-advice)
            (cl-letf (((symbol-function 'org-texmacs--worker-request)
                       (lambda (&rest _)
                         (ert-fail
                          "HTML export started TeXmacs worker"))))
              (let ((output (org-export-as 'html nil nil t options)))
                (dolist (phase '(hook advice filter))
                  (should (memq phase events)))
                (should (string-match-p "HookBodySentinel" output))
                (should
                 (string-match-p "FilterOutputSentinel" output))
                (should-not
                 (string-match-p "FilterInputSentinel" output)))))
        (advice-remove
         'org-export-expand-include-keyword include-advice))
      (should-not
       (advice-member-p
        include-advice 'org-export-expand-include-keyword))
      (should
       (equal baseline (org-export-as 'html nil nil t options)))
      (should
       (equal
        state (org-texmacs-test--document-buffer-state source))))))

(ert-deftest org-texmacs-export-backend-source-wait-before-output ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Source.\n")
     (setq buffer-file-name
           (expand-file-name "stale.org" test-directory))
     (let ((source (current-buffer))
           (file (expand-file-name "stale.tm" test-directory)))
       (with-temp-file file
         (insert "PreviousOutput"))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (ert-fail "Known output unexpectedly prompted")))
                 ((symbol-function 'org-texmacs-document-serialize)
                  (lambda (_document)
                    (with-current-buffer source
                      (insert "Changed"))
                    (encode-coding-string
                     "<TeXmacs|2.1.5>" 'us-ascii)))
                 ((symbol-function 'org-texmacs--native-save-bytes)
                  (lambda (&rest _)
                    (ert-fail "Stale frontend export was written"))))
         (should-error
          (org-texmacs-export-to-texmacs)
          :type 'org-texmacs-document-error))
       (with-temp-buffer
         (insert-file-contents-literally file)
         (should (equal (buffer-string) "PreviousOutput")))))))

(ert-deftest org-texmacs-export-backend-keyword-naming-and-reexport ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq buffer-file-name
           (expand-file-name "source.org" test-directory))
     (insert "#+EXPORT_FILE_NAME: chosen.other\nOldBodySentinel.\n")
     (let ((file (expand-file-name "chosen.tm" test-directory)))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (ert-fail "Named output unexpectedly prompted"))))
         (should (equal file (org-texmacs-export-to-texmacs)))
         (erase-buffer)
         (insert
          "#+EXPORT_FILE_NAME: chosen.other\nNewBodySentinel.\n")
         (should (equal file (org-texmacs-export-to-texmacs))))
       (with-temp-buffer
         (insert-file-contents-literally file)
         (should (string-match-p "NewBodySentinel" (buffer-string)))
         (should-not
          (string-match-p
           "OldBodySentinel\\|EXPORT_FILE_NAME" (buffer-string))))))))

(ert-deftest
    org-texmacs-export-backend-nonfile-prompt-and-native-bytes
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Source.\n")
     (let ((source (current-buffer))
           (prompt-buffer
            (generate-new-buffer " *texmacs-output-prompt*"))
           (bytes (unibyte-string ?A 0 255))
           (org-export-coding-system 'utf-16)
           (write-region-annotate-functions
            (list (lambda (&rest _) '((1 . "Injected"))))))
       (unwind-protect
           (cl-letf (((symbol-function 'read-file-name)
                      (lambda (&rest _)
                        (should (eq source (current-buffer)))
                        (set-buffer prompt-buffer)
                        "chosen.other"))
                     ((symbol-function
                       'org-texmacs-document-serialize)
                      (lambda (_document &rest _)
                        (should (eq (current-buffer) source))
                        bytes)))
             (let ((file
                    (expand-file-name "chosen.tm" test-directory)))
               (should (equal file (org-texmacs-export-to-texmacs)))
               (should (eq source (current-buffer)))
               (with-temp-buffer
                 (set-buffer-multibyte nil)
                 (insert-file-contents-literally file)
                 (should (equal bytes (buffer-string))))))
         (kill-buffer prompt-buffer))))))

(ert-deftest
    org-texmacs-export-backend-source-name-and-target-preflight
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Source.\n")
     (setq buffer-file-name
           (expand-file-name "source.tm" test-directory))
     (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                (lambda (&rest _)
                  (encode-coding-string "NativeBytes" 'us-ascii))))
       (should
        (equal
         (concat buffer-file-name ".tm")
         (org-texmacs-export-to-texmacs)))
       (should-not (file-exists-p buffer-file-name)))
     (let* ((file (expand-file-name "protected.tm" test-directory))
            (link (expand-file-name "link.tm" test-directory)))
       (with-temp-file file
         (insert "Keep"))
       (make-symbolic-link file link)
       (cl-letf (((symbol-function 'org-export-output-file-name)
                  (lambda (&rest _) link))
                 ((symbol-function 'org-texmacs-document-serialize)
                  (lambda (&rest _)
                    (ert-fail "Invalid target converted"))))
         (should-error
          (org-texmacs-export-to-texmacs)
          :type 'file-error))
       (cl-letf (((symbol-function 'org-export-output-file-name)
                  (lambda (&rest _) file))
                 ((symbol-function 'file-writable-p)
                  (lambda (&rest _) nil))
                 ((symbol-function 'org-texmacs-document-serialize)
                  (lambda (&rest _)
                    (ert-fail "Unwritable target converted"))))
         (should-error
          (org-texmacs-export-to-texmacs)
          :type 'file-error))
       (with-temp-buffer
         (insert-file-contents-literally file)
         (should (equal "Keep" (buffer-string))))))))

(ert-deftest org-texmacs-export-backend-full-provider-profile ()
  (org-texmacs-test--with-bibliography-files
   (insert "Text\n")
   (setq-local org-odd-levels-only t)
   (should-error
    (org-texmacs-export-as-texmacs)
    :type 'org-texmacs-document-error)
   (should
    (org-texmacs-input-p
     (org-texmacs-prepare-buffer (current-buffer))))
   (setq-local org-odd-levels-only nil)
   (erase-buffer)
   (insert (make-string 262145 ?a))
   (should-error
    (org-texmacs-export-as-texmacs)
    :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-export-backend-local-preprocessing-refusal ()
  (org-texmacs-test--with-bibliography-files
   (dolist
       (text
        '("* Mount\n:PROPERTIES:\n:ROAM_INCLUDE: missing-id\n:END:\nOld body\n"
          "* Heading\n#+ROAM_INCLUDE: missing-id\n"
          "* Heading\n#+INCLUDE: missing.org\n"))
     (erase-buffer)
     (insert text)
     (goto-char (point-min))
     (should-error
      (org-texmacs-export-as-texmacs nil t)
      :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-export-backend-discovery-disabled-and-invalid
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (insert "Text\n")
    (let ((org-export-show-temporary-export-buffer nil))
      (cl-letf (((symbol-function 'org-cite-list-bibliography-files)
                 (lambda (&rest _)
                   (ert-fail "Disabled discovery called collector")))
                ((symbol-function 'org-texmacs--bibliography-acquire)
                 (lambda (&rest _)
                   (ert-fail "Disabled discovery acquired files"))))
        (kill-buffer (org-texmacs-export-as-texmacs))))
    (setq-local org-texmacs-export-discover-bibliography 'invalid)
    (cl-letf (((symbol-function 'read-file-name)
               (lambda (&rest _)
                 (ert-fail "Invalid discovery prompted"))))
      (should-error
       (org-texmacs-export-to-texmacs)
       :type 'user-error)))))

(ert-deftest
    org-texmacs-export-backend-discovery-captured-before-prompt
    ()
  (org-texmacs-test--with-bibliography-files
   (insert "Text\n")
   (cl-letf (((symbol-function 'read-file-name)
              (lambda (&rest _)
                (setq-local org-texmacs-export-discover-bibliography
                            t)
                "chosen.tm")))
     (should-error
      (org-texmacs-export-to-texmacs)
      :type 'org-texmacs-document-error))
   (should-not (file-exists-p "chosen.tm"))))

(ert-deftest
    org-texmacs-export-menu-first-load-invalid-preserves-registry
    ()
  (org-texmacs-test--menu-fresh-process
   '(progn
      (org-export-define-backend
       'texmacs
       nil
       :menu-entry '(?Z "Prior" ((?a "Prior" ignore))))
      (setq org-texmacs-export-menu-keys '(:prefix ?Z :buffer ?a))
      (let ((backend (org-export-get-backend 'texmacs))
            (registry org-export-registered-backends)
            (hooks
             (copy-sequence org-export-before-processing-functions)))
        (should-error (require 'ox-texmacs) :type 'user-error)
        (should (eq backend (org-export-get-backend 'texmacs)))
        (should (eq registry org-export-registered-backends))
        (should (equal hooks org-export-before-processing-functions))
        (should-not (featurep 'ox-texmacs))))))

(ert-deftest
    org-texmacs-export-menu-native-shared-prefix-and-conflicts
    ()
  (let ((org-export-registered-backends nil))
    (org-export-define-backend
     'menu-peer
     nil
     :menu-entry '(?Z "Peer" ((?x "Peer" ignore))))
    (let* ((backend (org-export-get-backend 'menu-peer))
           (original (org-export-backend-menu backend))
           (menu
            (org-texmacs--export-menu-entry
             '(:prefix ?Z :buffer ?a :file ?b :pdf ?c))))
      (org-export-define-backend 'texmacs nil :menu-entry menu)
      (dolist (keys '("Zx" "Za"))
        (let ((events (append keys nil)))
          (cl-letf (((symbol-function 'read-event)
                     (lambda (&rest _)
                       (or (pop events)
                           (ert-fail "Input exhausted")))))
            (should
             (equal
              (org-export--dispatch-ui nil nil t)
              (if (equal keys "Zx")
                  '(ignore)
                '(org-texmacs-export-as-texmacs)))))))
      (should-error
       (org-texmacs--export-menu-entry
        '(:prefix ?Z :buffer ?x :file ?b :pdf ?c))
       :type 'user-error)
      (should (eq original (org-export-backend-menu backend)))
      (org-export-define-backend
       'menu-peer
       nil
       :menu-entry '(?Z "Direct" ignore))
      (should-error
       (org-texmacs--export-menu-entry
        '(:prefix ?Z :buffer ?a :file ?b :pdf ?c))
       :type 'user-error))))

(ert-deftest org-texmacs-export-managed-buffer-reuse-and-source-state
    ()
  (org-texmacs-test--with-managed-export
   (goto-char 3) (set-mark 4) (narrow-to-region 2 7)
   (let* ((source (current-buffer))
          (state
           (list
            (buffer-string)
            (point)
            (mark)
            (point-min)
            (point-max)
            (buffer-modified-p)))
          (output (org-texmacs-export-as-texmacs)))
     (setq bytes (unibyte-string 0 128 255 ?B))
     (should (eq output (org-texmacs-export-as-texmacs)))
     (with-current-buffer output
       (should (equal (buffer-string) bytes))
       (should buffer-read-only)
       (should-not (buffer-modified-p))
       (should-not enable-multibyte-characters)
       (should (eq major-mode 'special-mode))
       (should (eq buffer-file-coding-system 'no-conversion))
       (should-not buffer-file-name)
       (should (eq buffer-undo-list t)))
     (should (eq source (current-buffer)))
     (should
      (equal
       state
       (list
        (buffer-string)
        (point)
        (mark)
        (point-min)
        (point-max)
        (buffer-modified-p)))))))

(ert-deftest
    org-texmacs-export-managed-buffer-foreign-and-explicit-results
    ()
  (org-texmacs-test--with-managed-export
   (let ((foreign (generate-new-buffer "*Org TeXmacs Export*")))
     (with-current-buffer foreign
       (insert "User content"))
     (let ((output (org-texmacs-export-as-texmacs))
           explicit)
       (should-not (eq output foreign))
       (should (eq output (org-texmacs-export-as-texmacs)))
       (cl-letf (((symbol-function
                   'org-texmacs-export-texmacs-from-buffer)
                  (lambda (&rest _) bytes))
                 ((symbol-function 'display-buffer)
                  (lambda (&rest _)
                    (ert-fail "Explicit API displayed output"))))
         (setq explicit
               (org-texmacs-export-to-buffer (current-buffer)))
         (should-not
          (eq
           explicit (org-texmacs-export-to-buffer (current-buffer)))))
       (setq bytes (unibyte-string ?B))
       (should (eq output (org-texmacs-export-as-texmacs)))
       (with-current-buffer explicit
         (should (equal (buffer-string) (unibyte-string ?A))))
       (with-current-buffer foreign
         (should (equal (buffer-string) "User content")))))))

(ert-deftest
    org-texmacs-export-managed-buffer-kill-and-source-lifetime
    ()
  (org-texmacs-test--with-managed-export
   (let ((output (org-texmacs-export-as-texmacs))
         (source (generate-new-buffer " *Transient Org source*")))
     (with-current-buffer source
       (org-mode)
       (insert "Other source.\n")
       (should (eq output (org-texmacs-export-as-texmacs))))
     (kill-buffer source)
     (should (buffer-live-p output))
     (kill-buffer output)
     (let ((replacement (org-texmacs-export-as-texmacs)))
       (should-not (eq replacement output))
       (should (eq replacement (org-texmacs-export-as-texmacs)))))))

(ert-deftest org-texmacs-export-managed-buffer-user-relinquishment ()
  (dolist (takeover
           '(rename
             modify mode file readonly coding ownership narrowing))
    (org-texmacs-test--with-managed-export
     (let ((output (org-texmacs-export-as-texmacs)))
       (with-current-buffer output
         (pcase takeover
           ('rename (rename-buffer " *User renamed result*" t))
           ('modify
            (let ((inhibit-read-only t))
              (insert "User edit"))
            ;; Resetting the modified flag must not make it reusable.
            (set-buffer-modified-p nil))
           ('mode (fundamental-mode))
           ('file (setq buffer-file-name "/user-owned.tm"))
           ('readonly (setq buffer-read-only nil))
           ('coding (setq buffer-file-coding-system 'utf-8))
           ('ownership (setq org-texmacs--export-buffer-owner nil))
           ('narrowing (narrow-to-region 1 1))))
       (let ((previous
              (with-current-buffer output
                (buffer-string))))
         (setq bytes (unibyte-string ?B))
         (should-not (eq output (org-texmacs-export-as-texmacs)))
         (with-current-buffer output
           (should (equal (buffer-string) previous)))
         (should (buffer-live-p output)))))))

(ert-deftest org-texmacs-export-managed-buffer-conversion-failure ()
  (org-texmacs-test--with-managed-export
   (let ((output (org-texmacs-export-as-texmacs)))
     (cl-letf (((symbol-function 'org-texmacs--export-byte-consumer)
                (lambda (&rest _)
                  (lambda (&rest _)
                    (signal 'org-texmacs-document-error
                            '("Changed source")))))
               ((symbol-function 'generate-new-buffer)
                (lambda (&rest _)
                  (ert-fail "Conversion failure allocated output"))))
       (should-error
        (org-texmacs-export-as-texmacs)
        :type 'org-texmacs-document-error))
     (with-current-buffer output
       (should (equal (buffer-string) (unibyte-string ?A))))
     (should (eq output (org-texmacs-export-as-texmacs))))))

(ert-deftest org-texmacs-export-managed-buffer-content-commit-rollback
    ()
  (org-texmacs-test--with-managed-export
   (let* ((output (org-texmacs-export-as-texmacs))
          (insert-function (symbol-function 'insert)))
     (with-current-buffer output
       (goto-char (point-max)))
     (setq bytes (unibyte-string ?B ?C))
     (cl-letf (((symbol-function 'insert)
                (lambda (&rest args)
                  (apply insert-function args)
                  (when (eq (current-buffer) output)
                    (error
                     "Failed after partial content replacement")))))
       (should-error (org-texmacs-export-as-texmacs)))
     (with-current-buffer output
       (should (equal (buffer-string) (unibyte-string ?A)))
       (should (= (point) (point-max)))
       (should buffer-read-only)
       (should-not (buffer-modified-p))
       (should (eq buffer-undo-list t)))
     (should (eq output (org-texmacs-export-as-texmacs)))
     (with-current-buffer output
       (should (equal (buffer-string) bytes))))))

(ert-deftest
    org-texmacs-export-managed-buffer-display-failure-contract
    ()
  (org-texmacs-test--with-managed-export
   (let ((output (org-texmacs-export-as-texmacs))
         (org-export-show-temporary-export-buffer t))
     (setq bytes (unibyte-string ?B))
     (cl-letf (((symbol-function 'display-buffer)
                (lambda (&rest _) (error "Display failure"))))
       (should-error (org-texmacs-export-as-texmacs))
       (should (buffer-live-p output))
       (with-current-buffer output
         (should (equal (buffer-string) bytes)))
       (kill-buffer output)
       (should-error (org-texmacs-export-as-texmacs))
       (should-not (buffer-live-p (car created)))
       (should-not org-texmacs--export-managed-buffer))
     (let ((org-export-show-temporary-export-buffer nil))
       (should (buffer-live-p (org-texmacs-export-as-texmacs)))))))

(ert-deftest org-texmacs-export-managed-buffer-no-mode-or-change-hooks
    ()
  (org-texmacs-test--with-managed-export
   (let ((special-mode-hook
          (list (lambda () (ert-fail "Mode hook ran"))))
         (change-major-mode-hook
          (list (lambda () (ert-fail "Mode-change hook ran"))))
         (after-change-major-mode-hook
          (list (lambda () (ert-fail "Mode callback ran")))))
     (let ((output (org-texmacs-export-as-texmacs)))
       (with-current-buffer output
         (setq-local before-change-functions
                     (list
                      (lambda (&rest _)
                        (ert-fail "Change hook ran"))))
         (setq-local after-change-functions
                     (list
                      (lambda (&rest _)
                        (ert-fail "Change callback ran")))))
       (setq bytes (unibyte-string ?B))
       (should (eq output (org-texmacs-export-as-texmacs)))))))

(ert-deftest
    org-texmacs-file-links-preserve-raw-targets-and-frozen-base
    ()
  (let ((org-export-default-language "en") input)
    (with-temp-buffer
      (org-mode)
      (setq default-directory "/source/resources/")
      (insert "[[file:figures/a.pdf][Figure]]\n\n[[./notes.org]]\n")
      (cl-letf (((symbol-function 'find-file-noselect)
                 (lambda (&rest _)
                   (ert-fail "Linked resource was read")))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Plain file link started a worker"))))
        (setq input (org-texmacs-prepare-buffer (current-buffer)))))
    (let* ((document (org-texmacs-document input))
           (before (copy-tree (org-texmacs-document-body document))))
      (should
       (equal
        before
        '(document
          (concat (hlink "Figure" "figures/a.pdf") " ")
          (concat (hlink "./notes.org" "./notes.org") " "))))
      (should
       (equal
        (org-texmacs-document-file-paths document)
        '((0 0 1) (1 0 1))))
      (let ((second (org-texmacs-document input)))
        (should-not
         (eq
          (last (car (org-texmacs-document-file-paths document)))
          (last (car (org-texmacs-document-file-paths second))))))
      (let ((default-directory "/unrelated/"))
        (should
         (equal
          (org-texmacs--native-document-wire document)
          "(\"generic\") ((\"language\" \"english\" org-literal)) (\"document\" (\"concat\" (\"hlink\" \"Figure\" \"/source/resources/figures/a.pdf\") \" \") (\"concat\" (\"hlink\" \"./notes.org\" \"/source/resources/notes.org\") \" \")) ()")))
      (should (equal before (org-texmacs-document-body document))))))

(ert-deftest
    org-texmacs-file-links-explicit-context-and-unsupported-semantics
    ()
  (let* ((link
          (org-element-create
           'link '(:type "file" :path "relative.pdf")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil link))))
    (should-error
     (org-texmacs-document (org-texmacs-input-create ast nil))
     :type 'org-texmacs-document-error)
    (org-element-put-property link :path "/absolute.pdf")
    (should
     (equal
      (org-texmacs-document-file-paths
       (org-texmacs-document (org-texmacs-input-create ast nil)))
      '((0 0 1)))))
  (dolist (source
           '("[[file:~/notes.pdf]]\n"
             "[[file:/ssh:host:/notes.pdf]]\n"
             "[[file:notes.org::#target]]\n"
             "[[file+emacs:notes.org]]\n"
             "#+OPTIONS: toc:nil\n* [[file:notes.pdf][Title]]\n"))
    (with-temp-buffer
      (org-mode)
      (insert source "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Unsupported resource started parsing"))))
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-file-links-native-readback-and-preflight-preservation
    ()
  (org-texmacs-test--with-worker
   ;; Launch under the existing fixture directory, then exercise a source
   ;; resource base that need not exist or be read by conversion.
   (org-texmacs--worker-start)
   (with-temp-buffer
     (org-mode)
     (setq default-directory "/tmp/org-resource/root/")
     (insert "[[file:子/é <alpha>%20.pdf][Resource]]\n")
     (let* ((document
             (org-texmacs-document-from-buffer (current-buffer)))
            (session (org-texmacs-session-open))
            (process org-texmacs--worker-process))
       (unwind-protect
           (progn
             (org-texmacs-session-set-document session document)
             (let ((native (org-texmacs--session-read session)))
               (should
                (equal
                 native
                 (org-texmacs-test--native-hex
                  '(document
                    (concat
                     (hlink
                      "Resource"
                      "/tmp/org-resource/root/<#5B50>/é <less>alpha<gtr>%20.pdf")
                     " ")))))
               (erase-buffer)
               (insert "[[file:name#fragment.pdf][Rejected]]\n")
               (should-error
                (org-texmacs-session-set-document
                 session
                 (org-texmacs-document-from-buffer (current-buffer)))
                :type 'org-texmacs-encoding-error)
               (should (eq process org-texmacs--worker-process))
               (should
                (equal native (org-texmacs--session-read session)))))
         (org-texmacs-session-close session))))))

(ert-deftest org-texmacs-narrowing-config-and-source-state ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+TITLE: FileTitleSentinel\n#+OPTIONS: toc:nil\n"
     "* Outside\n- [X] UnsupportedOutsideSentinel\n\n"
     "Prefix SelectedBodySentinel suffix.\n")
    (search-backward "SelectedBodySentinel")
    (let ((begin (point))
          (end (+ (point) (length "SelectedBodySentinel"))))
      (put-text-property
       begin end 'org-texmacs-test-property "retained")
      (narrow-to-region begin end)
      (goto-char begin)
      (set-mark end)
      (setq mark-active t)
      (let* ((source (current-buffer))
             (state (org-texmacs-test--document-buffer-state source)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Plain narrowing started worker"))))
          (let* ((input
                  (org-texmacs-prepare-buffer
                   source
                   nil
                   nil
                   nil
                   '(:title "ExternalTitleSentinel")))
                 (body
                  (prin1-to-string
                   (org-texmacs-document-body
                    (org-texmacs-document input)))))
            (should (string-match-p "FileTitleSentinel" body))
            (should (string-match-p "SelectedBodySentinel" body))
            (should-not
             (string-match-p
              "Prefix\\|suffix\\|Outside\\|ExternalTitleSentinel"
              body))
            (should
             (equal
              state
              (org-texmacs-test--document-buffer-state source)))))))))

(ert-deftest
    org-texmacs-narrowing-owned-notes-bibliography-and-islands
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil\n#+bibliography: refs.bib\n"
      "[fn:n] Note (math \"x\") [cite:@b].\n\n* Main\n"
      "Selected (math \"y\") [fn:n] [fn:inline] [cite:@a] [[./asset.org]].\n"
      "#+print_bibliography:\n* Outside\nOutside[fn:inline:OwnedInlineNote].\n"
      "#+begin_texmacs\n(math\n#+end_texmacs\n")
     (goto-char (point-min))
     (search-forward "Selected")
     (let ((begin (match-beginning 0)))
       (search-forward "* Outside")
       (narrow-to-region begin (match-beginning 0))
       (let* ((input
               (org-texmacs-prepare-buffer
                (current-buffer)
                '(("refs.bib"
                   .
                   "@book{a, title={A}}\n@book{b, title={B}}"))))
              (document (org-texmacs-document input))
              (body (org-texmacs-document-body document)))
         (should (= 2 (cl-count 'footnote (flatten-tree body))))
         (should (= 2 (cl-count 'math (flatten-tree body))))
         (should
          (string-match-p "OwnedInlineNote" (prin1-to-string body)))
         (should
          (equal
           (nth
            1
            (plist-get
             (org-texmacs-input-info input)
             :texmacs-bibliography-output))
           '("b" "a")))
         (should (org-texmacs-document-file-paths document))
         (should
          (equal
           default-directory
           (org-texmacs-document-resource-base document)))
         (should
          (string-prefix-p
           "<TeXmacs|"
           (org-texmacs-document-serialize document))))))))

(ert-deftest
    org-texmacs-narrowing-subtree-intersection-and-region-priority
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil\n* Chosen\n:PROPERTIES:\n"
     ":EXPORT_TITLE: SubtreeTitleSentinel\n:END:\nRootPrefix ExcludedPrefix.\n"
     "SelectedBodySentinel.\n** Child\nChildBodySentinel.\n"
     "* Outside\nOutsideBodySentinel.\n")
    (goto-char (point-min))
    (search-forward "SelectedBodySentinel")
    (let ((begin (match-beginning 0)))
      (narrow-to-region begin (point-max))
      (let ((body
             (prin1-to-string
              (org-texmacs-document-body
               (org-texmacs-document-from-buffer
                (current-buffer) nil begin)))))
        (should (string-match-p "SubtreeTitleSentinel" body))
        (should (string-match-p "SelectedBodySentinel" body))
        (should (string-match-p "ChildBodySentinel" body))
        (should-not
         (string-match-p
          "ExcludedPrefix\\|OutsideBodySentinel" body)))
      (goto-char begin)
      (search-forward "OutsideBodySentinel")
      (let ((region (cons (match-beginning 0) (point))))
        (let ((body
               (prin1-to-string
                (org-texmacs-document-body
                 (org-texmacs-document-from-buffer
                  (current-buffer) nil begin region)))))
          (should (string-match-p "SubtreeTitleSentinel" body))
          (should (string-match-p "OutsideBodySentinel" body))
          (should-not
           (string-match-p
            "SelectedBodySentinel\\|ChildBodySentinel" body))))
      (should-error
       (org-texmacs-prepare-buffer (current-buffer) nil 1)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-narrowing-empty-and-preflight-boundaries ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _)
               (ert-fail "Invalid/empty narrowing started worker"))))
    (with-temp-buffer
      (org-mode)
      (insert "* Heading\nBody.\n")
      (narrow-to-region 5 5)
      (should
       (equal
        '(document)
        (org-texmacs-document-body
         (org-texmacs-document-from-buffer (current-buffer)))))
      (should-error
       (org-texmacs-prepare-buffer (current-buffer) nil nil '(5 . 5))
       :type 'org-texmacs-document-error))
    (with-temp-buffer
      (org-mode)
      (insert "Body (math \"x\").\n")
      (narrow-to-region 8 12)
      (let ((state
             (org-texmacs-test--document-buffer-state
              (current-buffer))))
        (should-error
         (org-texmacs-prepare-buffer (current-buffer))
         :type 'org-texmacs-document-error)
        (should
         (equal
          state
          (org-texmacs-test--document-buffer-state
           (current-buffer)))))
      (should-error
       (org-texmacs-prepare-buffer (current-buffer) nil nil '(1 . 12))
       :type 'org-texmacs-document-error))
    (with-temp-buffer
      (org-mode)
      (insert "#+INCLUDE: outside.org\nBody.\n")
      (search-backward "Body")
      (narrow-to-region (point) (point-max))
      (should-error
       (org-texmacs-prepare-buffer (current-buffer))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-narrowing-prompts-and-restriction-changes ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Prefix SelectedBodySentinel suffix.\n")
     (search-backward "SelectedBodySentinel")
     (let* ((begin (point))
            (end (+ (point) (length "SelectedBodySentinel")))
            (source (current-buffer)))
       (narrow-to-region begin end)
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (should (eq source (current-buffer)))
                    (should (= begin (point-min)))
                    (should (= end (point-max)))
                    "prompt.other")))
         (let ((file (org-texmacs-export-to-texmacs)))
           (should
            (equal
             file (expand-file-name "prompt.tm" test-directory)))
           (with-temp-buffer
             (set-buffer-multibyte nil)
             (insert-file-contents-literally file)
             (should
              (string-match-p "SelectedBodySentinel" (buffer-string)))
             (should-not
              (string-match-p "Prefix\\|suffix" (buffer-string))))))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (with-current-buffer source
                      (widen))
                    "changed.other"))
                 ((symbol-function 'org-texmacs--worker-request)
                  (lambda (&rest _)
                    (ert-fail "Restriction change started worker"))))
         (should-error
          (org-texmacs-export-to-texmacs)
          :type 'user-error)
         (should-not (buffer-narrowed-p))
         (should-not
          (file-exists-p
           (expand-file-name "changed.tm" test-directory))))
       (narrow-to-region begin end)
       (should-not (commandp 'org-texmacs-export-to-texmacs-file))))))

(ert-deftest
    org-texmacs-narrowing-native-waits-reject-changes-before-write
    ()
  (org-texmacs-test--with-worker
   (dolist (change '(widen shift hidden-text))
     (with-temp-buffer
       (org-mode)
       (insert "Prefix SelectedBodySentinel suffix.\n")
       (setq buffer-file-name
             (expand-file-name "source.org" test-directory))
       (search-backward "SelectedBodySentinel")
       (let* ((begin (point))
              (end (+ begin (length "SelectedBodySentinel")))
              (source (current-buffer))
              (file (expand-file-name "source.tm" test-directory))
              (serialize
               (symbol-function 'org-texmacs-document-serialize)))
         (write-region "PreviousOutput" nil file nil 'silent)
         (narrow-to-region begin end)
         (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                    (lambda (document)
                      (with-current-buffer source
                        (pcase change
                          ('widen (widen))
                          ('shift (narrow-to-region (1+ begin) end))
                          ('hidden-text
                           (save-restriction
                             (widen)
                             (goto-char 1)
                             (insert "X")))))
                      (funcall serialize document))))
           (should-error
            (org-texmacs-export-to-texmacs)
            :type 'org-texmacs-document-error))
         (with-temp-buffer
           (insert-file-contents-literally file)
           (should (equal "PreviousOutput" (buffer-string)))))))))

(ert-deftest org-texmacs-overrides-global-file-subtree-priority ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+TITLE: FileTitleSentinel\n#+OPTIONS: toc:nil num:t H:2\n"
     "* Root\n:PROPERTIES:\n:EXPORT_TITLE: SubtreeTitleSentinel\n"
     ":EXPORT_OPTIONS: num:nil H:3\n:END:\nBody.\n** Child\nChildBody.\n")
    (let ((org-export-with-section-numbers nil)
          (org-export-headline-levels 5)
          (options
           '(:title
             "ExternalTitleSentinel"
             :author "ExternalAuthorSentinel"
             :section-numbers nil
             :headline-levels 1
             :with-toc nil)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Ordinary overrides started worker"))))
        (let* ((input
                (org-texmacs-prepare-buffer
                 (current-buffer) nil nil nil options))
               (info (org-texmacs-input-info input))
               (body
                (prin1-to-string
                 (org-texmacs-document-body
                  (org-texmacs-document input)))))
          (should (plist-get info :section-numbers))
          (should (= 2 (plist-get info :headline-levels)))
          (should (string-match-p "FileTitleSentinel" body))
          (should (string-match-p "ExternalAuthorSentinel" body))
          (should-not (string-match-p "ExternalTitleSentinel" body)))
        (goto-char (point-min))
        (search-forward "* Root")
        (let* ((input
                (org-texmacs-prepare-buffer
                 (current-buffer) nil (point) nil options))
               (info (org-texmacs-input-info input))
               (body
                (prin1-to-string
                 (org-texmacs-document-body
                  (org-texmacs-document input)))))
          (should-not (plist-get info :section-numbers))
          (should (= 3 (plist-get info :headline-levels)))
          (should (string-match-p "SubtreeTitleSentinel" body))
          (should-not
           (string-match-p
            "FileTitleSentinel\\|ExternalTitleSentinel" body)))))))

(ert-deftest org-texmacs-overrides-rich-metadata-and-explicit-nil ()
  (with-temp-buffer
    (org-mode)
    (insert "BodySentinel.\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Metadata started worker"))))
      (let* ((document
              (org-texmacs-document-from-buffer
               (current-buffer) nil nil nil
               '(:title
                 "*RichTitleSentinel* 中文 <alpha>"
                 :author "ExternalAuthorSentinel"
                 :date "ExternalDateSentinel"
                 :with-toc nil)))
             (body (org-texmacs-document-body document)))
        (should (memq 'strong (flatten-tree body)))
        (should (string-match-p "中文 <alpha>" (prin1-to-string body)))
        (should
         (string-match-p
          "ExternalAuthorSentinel" (prin1-to-string body)))
        (should
         (string-match-p
          "ExternalDateSentinel" (prin1-to-string body))))
      (let ((body
             (org-texmacs-document-body
              (org-texmacs-document-from-buffer
               (current-buffer)
               nil
               nil
               nil
               '(:title nil :author nil :date nil :with-toc nil)))))
        (should-not (memq 'doc-data (flatten-tree body)))
        (should
         (string-match-p "BodySentinel" (prin1-to-string body)))))))

(ert-deftest org-texmacs-overrides-filtering-and-owned-dependencies ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "[fn:n] Note (math \"x\").\n\n* Keep\nBody[fn:n].\n"
      "* Skip :skip:\n#+begin_texmacs\n(math\n#+end_texmacs\n")
     (let* ((options
             (list
              :exclude-tags (list "skip")
              :with-toc nil
              :with-title nil))
            (input
             (org-texmacs-prepare-buffer
              (current-buffer) nil nil nil options))
            (body
             (org-texmacs-document-body
              (org-texmacs-document input))))
       (should (= 1 (cl-count 'footnote (flatten-tree body))))
       (should (memq 'math (flatten-tree body)))
       (should-not (string-match-p "Skip" (prin1-to-string body)))
       (setcar (plist-get options :exclude-tags) "Keep")
       (should
        (equal
         body
         (org-texmacs-document-body
          (org-texmacs-document input))))))))

(ert-deftest
    org-texmacs-overrides-owned-across-prompt-and-native-waits
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "BodySentinel.\n")
     (let* ((title (copy-sequence "ExternalTitleSentinel"))
            (tags (list (copy-sequence "skip")))
            (options
             (list :title title :exclude-tags tags :with-toc nil))
            (serialize
             (symbol-function 'org-texmacs-document-serialize)))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (aset title 0 ?X)
                    (aset (car tags) 0 ?X)
                    (plist-put options :with-title nil)
                    (funcall serialize document))))
         (let ((bytes
                (org-texmacs-export-texmacs-from-buffer
                 (current-buffer) nil nil nil options)))
           (should (string-match-p "ExternalTitleSentinel" bytes))))
       (setq options
             (list
              :title (copy-sequence "PromptTitleSentinel")
              :with-toc nil))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (aset (plist-get options :title) 0 ?X)
                    (expand-file-name "prompt.tm" test-directory))))
         (let ((file
                (org-texmacs-export-to-texmacs
                 nil nil nil nil options)))
           (with-temp-buffer
             (set-buffer-multibyte nil)
             (insert-file-contents-literally file)
             (should
              (string-match-p
               "PromptTitleSentinel" (buffer-string))))))))))

(ert-deftest org-texmacs-region-partial-text-and-file-context ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+TITLE: FileTitleSentinel\n#+OPTIONS: toc:nil num:nil\n"
     "* Outside\n- [X] UnsupportedOutsideSentinel\n\n"
     "Prefix SelectedBodySentinel suffix.\n")
    (search-backward "SelectedBodySentinel")
    (let* ((begin (point))
           (end (+ begin (length "SelectedBodySentinel")))
           (region (cons begin end))
           (source (current-buffer))
           (original (buffer-string))
           (position (point)))
      (push-mark (point-max) t t)
      (let ((mark (mark))
            (active mark-active))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail "Plain region started worker"))))
          (let* ((input
                  (org-texmacs-prepare-buffer source nil nil region))
                 (body
                  (org-texmacs-document-body
                   (org-texmacs-document input)))
                 (printed (prin1-to-string body)))
            (should (string-match-p "FileTitleSentinel" printed))
            (should (string-match-p "SelectedBodySentinel" printed))
            (should-not
             (string-match-p "Prefix\\|suffix\\|Outside" printed))
            (setcar region 1)
            (should
             (equal
              body
              (org-texmacs-document-body
               (org-texmacs-document input))))))
        (should (= position (point)))
        (should (= mark (mark)))
        (should (eq active mark-active))
        (should-not (buffer-narrowed-p))
        (should (equal original (buffer-string)))))))

(ert-deftest org-texmacs-region-footnote-dependencies-and-islands ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil\n[fn:before] Note (math \"x\").\n\n* Main\n"
      "Selected (math \"y\") [fn:before] [fn:local] [fn:inline].\n\n"
      "[fn:local] LocalNoteSentinel.\n\n"
      "* Outside\nOutside[fn:inline:InlineNoteSentinel].\n"
      "#+begin_texmacs\n(math\n#+end_texmacs\n")
     (goto-char (point-min))
     (search-forward "Selected")
     (let ((begin (match-beginning 0))
           (request (symbol-function 'org-texmacs--worker-request))
           seen)
       (search-forward "* Outside")
       (let ((end (match-beginning 0)))
         (cl-letf (((symbol-function 'org-texmacs--worker-request)
                    (lambda (text &rest args)
                      (push text seen)
                      (apply request text args))))
           (let* ((document
                   (org-texmacs-document-from-buffer
                    (current-buffer) nil nil (cons begin end)))
                  (body (org-texmacs-document-body document)))
             (should
              (equal
               (nreverse seen) '("(math \"y\")" "(math \"x\")")))
             (should (= 3 (cl-count 'footnote (flatten-tree body))))
             (should
              (string-match-p
               "LocalNoteSentinel" (prin1-to-string body)))
             (should
              (string-match-p
               "InlineNoteSentinel" (prin1-to-string body)))
             (should-not
              (string-match-p "Outside" (prin1-to-string body)))
             (should
              (string-prefix-p
               "<TeXmacs|"
               (org-texmacs-document-serialize document))))))))))

(ert-deftest org-texmacs-region-headings-and-complete-native-block ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil num:nil\n* Outside\nElse.\n"
      "** Kept\nSee [[*Target]].\n*** Target\nBody.\n"
      "#+begin_texmacs\n(document (math \"x\"))\n#+end_texmacs\n\n"
      "*** Hidden :noexport:\n- [X] ExcludedBodySentinel\n")
     (goto-char (point-min))
     (search-forward "** Kept")
     (let* ((begin (match-beginning 0))
            (document
             (org-texmacs-document-from-buffer
              (current-buffer) nil nil (cons begin (point-max))))
            (body (org-texmacs-document-body document)))
       (should (memq 'section* (flatten-tree body)))
       (should (memq 'subsection* (flatten-tree body)))
       (should (memq 'reference (flatten-tree body)))
       (should (memq 'math (flatten-tree body)))
       (should-not
        (string-match-p
         "Outside\\|Else\\|ExcludedBodySentinel"
         (prin1-to-string body))))
     ;; The closing block line is sufficient: trailing blank lines need not
     ;; be selected to keep the native island complete.
     (goto-char (point-min))
     (search-forward "#+begin_texmacs")
     (let ((begin (match-beginning 0)))
       (search-forward "#+end_texmacs")
       (forward-line 1)
       (should
        (memq
         'math
         (flatten-tree
          (org-texmacs-document-body
           (org-texmacs-document-from-buffer
            (current-buffer) nil nil (cons begin (point)))))))))))

(ert-deftest org-texmacs-region-invalid-boundaries-and-link-scope ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _)
               (ert-fail "Invalid region started worker"))))
    (with-temp-buffer
      (org-mode)
      (insert "Body (math \"x\").\n")
      (dolist (region
               '(t (1 2) (1 . 1) (0 . 2) (1 . 999) (1 . marker)))
        (should-error
         (org-texmacs-prepare-buffer (current-buffer) nil nil region)
         :type 'org-texmacs-document-error))
      (should-error
       (org-texmacs-prepare-buffer (current-buffer) nil nil '(8 . 12))
       :type 'org-texmacs-document-error))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n\nElse.\n")
      (should-error
       (org-texmacs-prepare-buffer
        (current-buffer) nil nil '(17 . 25))
       :type 'org-texmacs-document-error))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+OPTIONS: toc:nil\nSee [[*Outside]].\n* Outside\nElse.\n")
      (goto-char (point-min))
      (search-forward "See")
      (let ((begin (match-beginning 0)))
        (search-forward "* Outside")
        (should-error
         (org-texmacs-prepare-buffer
          (current-buffer) nil nil (cons begin (match-beginning 0)))
         :type 'org-texmacs-document-error)))
    (with-temp-buffer
      (org-mode)
      (insert "#+INCLUDE: secret.org\nBody.\n")
      (search-backward "Body")
      (should-error
       (org-texmacs-prepare-buffer
        (current-buffer) nil nil (cons (point) (point-max)))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-region-owned-bibliography-and-resource-base
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil\n#+bibliography: refs.bib\n"
      "[fn:n] Note [cite:@b].\n\n* Main\nSelected [fn:n] [cite:@a] [[./asset.org]].\n"
      "#+print_bibliography:\n* Outside\n[cite:@missing]\n")
     (goto-char (point-min))
     (search-forward "Selected")
     (let ((begin (match-beginning 0)))
       (search-forward "* Outside")
       (let* ((sources
               '(("refs.bib"
                  .
                  "@book{a, title={A}}\n@book{b, title={B}}")))
              (input
               (org-texmacs-prepare-buffer
                (current-buffer)
                sources
                nil
                (cons begin (match-beginning 0))))
              (document (org-texmacs-document input)))
         (should
          (equal
           (nth
            1
            (plist-get
             (org-texmacs-input-info input)
             :texmacs-bibliography-output))
           '("b" "a")))
         (should
          (equal
           default-directory
           (org-texmacs-document-resource-base document)))
         (should (org-texmacs-document-file-paths document))
         (should-not
          (string-match-p
           "missing"
           (prin1-to-string
            (org-texmacs-document-body document)))))))))

(ert-deftest org-texmacs-region-frozen-selection-and-stale-source ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil\nPrefix SelectedBodySentinel suffix.\n")
     (search-backward "SelectedBodySentinel")
     (let* ((source (current-buffer))
            (region
             (cons
              (point) (+ (point) (length "SelectedBodySentinel"))))
            (serialize
             (symbol-function 'org-texmacs-document-serialize)))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (setcar region 1)
                    (with-current-buffer source
                      (goto-char (point-max))
                      (push-mark 1 t t))
                    (funcall serialize document))))
         (let ((bytes
                (org-texmacs-export-texmacs-from-buffer
                 source nil nil region)))
           (should (string-match-p "SelectedBodySentinel" bytes))
           (should-not (string-match-p "Prefix\\|suffix" bytes))))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (with-current-buffer source
                      (insert " changed"))
                    (funcall serialize document))))
         (should-error
          (org-texmacs-export-texmacs-from-buffer
           source nil nil (cons 1 (point-max)))
          :type 'org-texmacs-document-error))))))

(ert-deftest org-texmacs-subtree-configuration-and-owned-selection ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+TITLE: File title\n#+AUTHOR: File author\n#+OPTIONS: toc:nil\n"
     "* Parent\n:PROPERTIES:\n:EXPORT_AUTHOR: Inherited author\n:END:\n"
     "** TODO Chosen\n:PROPERTIES:\n:EXPORT_TITLE: *Local* title\n"
     ":EXPORT_OPTIONS: num:nil H:2 toc:nil date:nil\n:END:\nSelectedBodySentinel.\n"
     "*** Child\nChildBodySentinel.\n* Outside\n- [X] UnsupportedOutsideSentinel\n")
    (goto-char (point-min))
    (search-forward "SelectedBodySentinel")
    (let ((source (current-buffer))
          (position (point))
          (original (buffer-string))
          (org-use-property-inheritance '("EXPORT_AUTHOR"))
          (org-entry-property-inherited-from (copy-marker 3)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Ordinary subtree started worker"))))
        (let* ((input
                (org-texmacs-prepare-buffer source nil position))
               (body
                (org-texmacs-document-body
                 (org-texmacs-document input)))
               (printed (prin1-to-string body)))
          (should (string-match-p "Local" printed))
          (should (string-match-p "Inherited author" printed))
          (should-not
           (string-match-p
            "File title\\|File author\\|UnsupportedOutsideSentinel"
            printed))
          (should (= 1 (cl-count 'section* (flatten-tree body))))
          (should-not (memq 'section (flatten-tree body)))
          (let ((org-use-property-inheritance nil))
            (should
             (equal
              body
              (org-texmacs-document-body
               (org-texmacs-document input)))))
          (should
           (= 3
              (marker-position org-entry-property-inherited-from)))))
      (should (= position (point)))
      (should (equal original (buffer-string))))))

(ert-deftest org-texmacs-subtree-external-footnotes-and-stm-order ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil\n[fn:before] Before (math \"x\").\n\n"
      "* Chosen\nSelected (math \"y\") [fn:before] [fn:inline].\n"
      "* Outside\nElse[fn:inline:Owned *inline* body.].\n"
      "#+begin_texmacs\n(math\n#+end_texmacs\n")
     (goto-char (point-min))
     (search-forward "* Chosen")
     (let ((request (symbol-function 'org-texmacs--worker-request))
           seen)
       (cl-letf (((symbol-function 'org-texmacs--worker-request)
                  (lambda (text &rest arguments)
                    (push text seen)
                    (apply request text arguments))))
         (let* ((document
                 (org-texmacs-document-from-buffer
                  (current-buffer) nil (point)))
                (body (org-texmacs-document-body document)))
           (should
            (equal (nreverse seen) '("(math \"y\")" "(math \"x\")")))
           (should (= 2 (cl-count 'footnote (flatten-tree body))))
           (should (string-match-p "Owned" (prin1-to-string body)))
           (should-not (string-match-p "Else" (prin1-to-string body)))
           (should
            (string-prefix-p
             "<TeXmacs|"
             (org-texmacs-document-serialize document)))))))))

(ert-deftest org-texmacs-subtree-date-and-filter-overrides ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+AUTHOR: File author\n#+DATE: File date\n#+OPTIONS: toc:nil\n"
     "* Parent\n:PROPERTIES:\n:EXPORT_AUTHOR: Parent author\n:END:\n"
     "** Chosen\n:PROPERTIES:\n:EXPORT_DATE: Subtree date\n"
     ":EXPORT_EXCLUDE_TAGS: drop\n:END:\nRoot body.\n"
     "*** Keep\nKeepBodySentinel.\n*** Drop :drop:\n- [X] ExcludedBodySentinel\n")
    (goto-char (point-min))
    (search-forward "** Chosen")
    (let ((org-use-property-inheritance nil))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail
                    "Filtered ordinary subtree started worker"))))
        (let ((body
               (prin1-to-string
                (org-texmacs-document-body
                 (org-texmacs-document-from-buffer
                  (current-buffer) nil (point))))))
          (should (string-match-p "Subtree date" body))
          (should (string-match-p "File author" body))
          (should (string-match-p "KeepBodySentinel" body))
          (should-not
           (string-match-p
            "Parent author\\|File date\\|ExcludedBodySentinel"
            body)))))))

(ert-deftest org-texmacs-subtree-links-and-invalid-scope-preflight ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _)
               (ert-fail "Invalid scope started worker"))))
    (with-temp-buffer
      (org-mode)
      (insert
       "Preamble.\n* Chosen\n[[*Inner]]\n** Inner\nBody.\n* Outside\nElse.\n")
      (let ((source (current-buffer)))
        (should-error
         (org-texmacs-prepare-buffer source nil 1)
         :type 'org-texmacs-document-error)
        (should-error
         (org-texmacs-prepare-buffer source nil -1)
         :type 'org-texmacs-document-error)
        (goto-char (point-min))
        (search-forward "* Chosen")
        (let ((position (point)))
          (should
           (memq
            'reference
            (flatten-tree
             (org-texmacs-document-body
              (org-texmacs-document-from-buffer
               source nil position)))))
          (search-forward "[[*Inner]]")
          (replace-match "[[*Outside]]" t t)
          (should-error
           (org-texmacs-prepare-buffer source nil position)
           :type 'org-texmacs-document-error))))
    (with-temp-buffer
      (org-mode)
      (insert
       "* Chosen\n:PROPERTIES:\n:EXPORT_OPTIONS: d:nil\n:END:\nBody.\n")
      (should-error
       (org-texmacs-prepare-buffer (current-buffer) nil 1)
       :type 'org-texmacs-document-error))
    (with-temp-buffer
      (org-mode)
      (insert "#+CITE_EXPORT: basic\n* Chosen\nBody (math \"x\").\n")
      (goto-char (point-min))
      (search-forward "* Chosen")
      (should-error
       (org-texmacs-prepare-buffer (current-buffer) nil (point))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-subtree-owned-bibliography-and-resource-base
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil\n#+bibliography: refs.bib\n"
      "[fn:r] Note [cite:@b].\n\n* Chosen\nBody [fn:r] [cite:@a] [[./asset.org]].\n"
      "#+print_bibliography:\n* Outside\n[cite:@missing]\n")
     (goto-char (point-min))
     (search-forward "* Chosen")
     (let*
         ((position (point))
          (sources
           '(("refs.bib"
              .
              "@book{a, title={A}}\n@book{b, title={B}}\n@book{unused, title={Unused}}")))
          (input
           (org-texmacs-prepare-buffer
            (current-buffer) sources position))
          (document (org-texmacs-document input)))
       (should
        (equal
         (nth
          1
          (plist-get
           (org-texmacs-input-info input)
           :texmacs-bibliography-output))
         '("b" "a")))
       (should
        (equal
         (org-texmacs-document-resource-base document)
         default-directory))
       (should (org-texmacs-document-file-paths document))
       (should-not
        (string-match-p
         "missing\\|Unused"
         (prin1-to-string (org-texmacs-document-body document))))
       (should
        (string-prefix-p
         "<TeXmacs|" (org-texmacs-document-serialize document)))))))

(ert-deftest org-texmacs-subtree-selection-and-property-waits ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil\n* First\nFirstBodySentinel.\n* Second\nSecondBodySentinel.\n")
     (goto-char (point-min))
     (search-forward "FirstBodySentinel")
     (let ((source (current-buffer))
           (position (point))
           (serialize
            (symbol-function 'org-texmacs-document-serialize)))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (document)
                    (with-current-buffer source
                      (goto-char (point-max)))
                    (funcall serialize document))))
         (let ((bytes
                (org-texmacs-export-texmacs-from-buffer
                 source nil position)))
           (should (string-match-p "FirstBodySentinel" bytes))
           (should-not (string-match-p "SecondBodySentinel" bytes)))))
     (goto-char (point-min))
     (search-forward "FirstBodySentinel")
     (let ((org-use-property-inheritance
            (list (copy-sequence "EXPORT_AUTHOR"))))
       (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                  (lambda (_document)
                    (aset (car org-use-property-inheritance) 0 ?X)
                    (encode-coding-string
                     "<TeXmacs|2.1.5>" 'us-ascii))))
         (should-error
          (org-texmacs-export-texmacs-from-buffer
           (current-buffer) nil (point))
          :type 'org-texmacs-document-error))))))

;;; frontend.el ends here
