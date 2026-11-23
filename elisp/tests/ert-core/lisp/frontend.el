;;; frontend.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'ox)
(require 'ox-texmacs)

(defmacro org-texmacs-test--with-bibliography-files (&rest body)
  "Run BODY in a private directory with a real UTF-8 bibliography."
  (declare (indent 0) (debug t))
  `(let ((directory (make-temp-file "org-texmacs-bibliography-" t)))
     (unwind-protect
         (with-temp-buffer
           (org-mode)
           (setq-local default-directory
                       (file-name-as-directory directory))
           (let ((coding-system-for-write 'utf-8-unix))
             (write-region "@book{external-key, title={Café}}"
                           nil
                           (expand-file-name "refs.bib")
                           nil
                           'silent))
           ,@body)
       (delete-directory directory t))))

(defmacro org-texmacs-test--with-managed-export (&rest body)
  "Run BODY with checked byte exports and isolated managed results."
  (declare (indent 0) (debug t))
  `(let ((org-texmacs--export-managed-buffer nil)
         (org-export-show-temporary-export-buffer nil)
         (bytes (unibyte-string ?A))
         created
         (allocate (symbol-function 'generate-new-buffer)))
     (unwind-protect
         (cl-letf (((symbol-function 'generate-new-buffer)
                    (lambda (&rest args)
                      (let ((buffer (apply allocate args)))
                        (push buffer created)
                        buffer)))
                   ((symbol-function
                     'org-texmacs--export-byte-consumer)
                    (lambda (&rest _) (lambda (&rest _) bytes))))
           (with-temp-buffer
             (org-mode)
             (insert "Source.\n")
             ,@body))
       (dolist (buffer created)
         (when (buffer-live-p buffer)
           (with-current-buffer buffer
             (setq buffer-file-name nil))
           (let ((kill-buffer-query-functions nil))
             (kill-buffer buffer)))))))

(defun org-texmacs-test--observe-standard-cleanup
    (thunk &optional failure)
  "Call THUNK and check disposal of Org's working export buffers.
FAILURE injects an error in root, prepared or ast phase, after switching to a
separate user-owned buffer.  Return the observed phase names."
  (let ((source (current-buffer))
        (other (generate-new-buffer " *standard-user-owned*"))
        records)
    (unwind-protect
        (cl-labels
         ((observe
           (stage)
           (should-not (eq source (current-buffer)))
           (push (cons stage (current-buffer)) records)
           (when (eq stage failure)
             (goto-char (point-max))
             (insert "Injected copy change")
             (set-buffer other)
             (signal 'org-texmacs-document-error
                     '("Cleanup sentinel")))))
         (let ((org-export-before-processing-functions
                (append
                 org-export-before-processing-functions
                 (list (lambda (_) (observe 'root)))))
               (org-export-before-parsing-functions
                (append
                 org-export-before-parsing-functions
                 (list (lambda (_) (observe 'prepared)))))
               (org-export-filter-parse-tree-functions
                (append
                 org-export-filter-parse-tree-functions
                 (list
                  (lambda (tree _backend _info)
                    (observe 'ast)
                    tree)))))
           (funcall thunk))
         (should (buffer-live-p source))
         (should (buffer-live-p other))
         (dolist (record records)
           (should-not (buffer-live-p (cdr record))))
         (mapcar #'car (nreverse records)))
      (when (buffer-live-p other)
        (let ((kill-buffer-query-functions nil))
          (kill-buffer other))))))

(defmacro org-texmacs-test--with-cleanup-source (&rest body)
  "Run BODY in a real visiting Org buffer and a test-owned directory."
  (declare (indent 0) (debug t))
  `(org-texmacs-test--with-bibliography-files
     (write-region "Included cleanup sentinel\n" nil "part.org"
                   nil
                   'silent)
     (write-region "#+INCLUDE: \"part.org\"\n" nil "source.org"
                   nil
                   'silent)
     (let ((source
            (find-file-noselect (expand-file-name "source.org"))))
       (unwind-protect
           (with-current-buffer source
             (org-mode)
             ,@body)
         (when (buffer-live-p source)
           (with-current-buffer source
             (set-buffer-modified-p nil))
           (kill-buffer source))))))

(ert-deftest org-texmacs-cleanup-nonfile-include-capture ()
  (org-texmacs-test--with-bibliography-files
    (write-region "Included\n" nil "part.org" nil 'silent)
    (insert "#+INCLUDE: \"part.org\"\n")
    (let ((before
           (org-texmacs-test--document-buffer-state (current-buffer)))
          (org-export-use-babel nil))
      (should
       (equal
        (org-texmacs-test--observe-standard-cleanup
         (lambda ()
           (let ((input
                  (org-texmacs-prepare-buffer (current-buffer))))
             (should
              (string-search
               "Included"
               (prin1-to-string (org-texmacs-input-ast input)))))))
        '(root prepared ast)))
      (should
       (equal
        before
        (org-texmacs-test--document-buffer-state
         (current-buffer)))))))

(ert-deftest org-texmacs-cleanup-source-configuration-guard ()
  ;; Settings already consumed by Org belong to the prepared snapshot.
  ;; Native settings changing on the original source still invalidate publication.
  (with-temp-buffer
    (org-mode)
    (insert "Text.\n")
    (let* ((source (current-buffer))
           (org-export-use-babel nil)
           (org-export-filter-parse-tree-functions
            (list
             (lambda (tree _backend _info)
               (with-current-buffer source
                 (setq-local org-texmacs-document-style '("article")))
               tree))))
      (should-error
       (org-texmacs-prepare-buffer source)
       :type 'org-texmacs-document-error)
      (should (equal org-texmacs-document-style '("article"))))))

(ert-deftest
    org-texmacs-file-links-compose-with-inline-and-stm-provenance
    ()
  (let* ((file
          (org-element-create
           'link '(:type "file" :path "asset.pdf")))
         (bold (org-element-create 'bold nil file))
         (island (org-element-create 'stm-fragment nil))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil bold " " island)))
         (input
          (org-texmacs-input-create
           ast
           nil
           :resource-base "/base/"
           :islands
           (list (cons island '(math "x")))))
         (document (org-texmacs-document input)))
    (should
     (equal
      (org-texmacs-document-body document)
      '(document
        (concat
         (strong (hlink "asset.pdf" "asset.pdf")) " " (math "x")))))
    (should
     (equal (org-texmacs-document-file-paths document) '((0 0 0 1))))
    (should
     (equal (org-texmacs-document-stm-paths document) '((0 2))))
    (should
     (string-match-p
      (regexp-quote "/base/asset.pdf")
      (org-texmacs--native-document-wire document)))))

(ert-deftest
    org-texmacs-file-links-native-preflight-validates-provenance
    ()
  (cl-letf (((symbol-function 'org-texmacs--worker-start)
             (lambda (&rest _)
               (ert-fail
                "Invalid file provenance started a worker"))))
    (dolist (paths '(t (nil) ((9)) ((0 0 0)) ((0 0 1) (0 0 1))))
      (should-error
       (org-texmacs--native-encode-document
        (org-texmacs--document-create
         :body
         '(document (concat (hlink "asset" "asset.pdf")))
         :file-paths paths
         :resource-base "/base/"))
       :type 'org-texmacs-encoding-error))
    (should-error
     (org-texmacs--native-encode-document
      (org-texmacs--document-create
       :body
       '(document (concat (hlink "asset" "asset.pdf")))
       :file-paths
       '((0 0 1))
       :stm-paths
       '((0 0))
       :resource-base "/base/"))
     :type 'org-texmacs-encoding-error)))

(ert-deftest org-texmacs-file-links-native-rejects-reserved-syntax ()
  (dolist (path
           '("name#anchor.pdf"
             "name?query.pdf"
             "name*.pdf"
             "$name.pdf"
             "a|b.pdf"
             "a\\b.pdf"
             "a[b].pdf"))
    (let ((document
           (org-texmacs--document-create
            :body
            (list 'document (list 'hlink "asset" path))
            :file-paths '((0 1))
            :resource-base "/base/")))
      (dolist (pdf '(nil t))
        (should-error
         (org-texmacs--native-document-wire document pdf)
         :type 'org-texmacs-encoding-error))
      (should
       (equal
        (nth 2 (cadr (org-texmacs-document-body document))) path)))))

(ert-deftest org-texmacs-file-link-policies-are-captured ()
  (dolist (absolute '(nil t))
    (dolist (pdf '(nil t))
      (let*
          ((input
            (let ((org-texmacs-pdf-file-links-as-absolute absolute)
                  (org-texmacs-link-org-files-as-pdf pdf))
              (with-temp-buffer
                (org-mode)
                (setq default-directory "/captured/source/")
                (insert
                 "#+OPTIONS: title:nil author:nil date:nil toc:nil\n[[file:./article.org][Article]]\n")
                (org-texmacs-prepare-buffer (current-buffer)))))
           ;; Later settings do not affect prepared or completed documents.
           (org-texmacs-pdf-file-links-as-absolute (not absolute))
           (org-texmacs-link-org-files-as-pdf (not pdf))
           (document (org-texmacs-document input))
           (body (copy-tree (org-texmacs-document-body document)))
           (target
            (if pdf
                "./article.pdf"
              "./article.org")))
        (should
         (eq
          absolute
          (org-texmacs-document-pdf-file-links-as-absolute document)))
        (should
         (eq
          pdf (org-texmacs-document-link-org-files-as-pdf document)))
        (dolist (consumer '(nil t))
          (let* ((wire
                  (org-texmacs--native-document-wire
                   document consumer))
                 (tree (nth 2 (read (concat "(" wire ")")))))
            (should
             (equal
              (nth 2 (cadr (cadr tree)))
              (if (and consumer (not absolute))
                  target
                (expand-file-name target "/captured/source/"))))))
        (should (equal body (org-texmacs-document-body document)))
        (should
         (equal (nth 2 (cadr (cadr body))) "./article.org"))))))

(ert-deftest org-texmacs-file-link-policies-defaults-and-validation ()
  ;; Pure AST construction uses fixed defaults, not ambient user settings.
  (let ((org-texmacs-pdf-file-links-as-absolute t)
        (org-texmacs-link-org-files-as-pdf nil))
    (with-temp-buffer
      (org-mode)
      (insert "Text\n")
      (let ((document
             (org-texmacs-document
              (org-texmacs-input-create
               (org-element-parse-buffer) nil))))
        (should-not
         (org-texmacs-document-pdf-file-links-as-absolute document))
        (should
         (org-texmacs-document-link-org-files-as-pdf document)))))
  (dolist (settings '((invalid t) (nil invalid)))
    (let ((org-texmacs-pdf-file-links-as-absolute (car settings))
          (org-texmacs-link-org-files-as-pdf (cadr settings)))
      (with-temp-buffer
        (org-mode)
        (insert "Text\n")
        (should-error
         (org-texmacs-document-from-buffer (current-buffer))
         :type 'org-texmacs-document-error))))
  (dolist (document
           (list
            (org-texmacs--document-create
             :body
             '(document "Text")
             :pdf-file-links-as-absolute 'invalid)
            (org-texmacs--document-create
             :body
             '(document "Text")
             :link-org-files-as-pdf 'invalid)))
    (dolist (pdf '(nil t))
      (should-error
       (org-texmacs--native-document-wire document pdf)
       :type 'org-texmacs-encoding-error))))

(ert-deftest
    org-texmacs-file-link-policies-preserve-provenance-and-path-form
    ()
  (let* ((body
          '(document
            (hlink "./article.org" "./article.ORG")
            (hlink "Parent" "../peer.org")
            (hlink "Other" "chapter.org.gpg")
            (hlink "Web" "https://example.org/file.org")
            (hlink "Native" "native.org")))
         (document
          (org-texmacs--document-create
           :body body
           :resource-base "/captured/source/"
           :file-paths '((0 1) (1 1) (2 1))
           :stm-paths '((4))))
         (tree
          (nth
           2
           (read
            (concat
             "("
             (org-texmacs--native-document-wire document t)
             ")")))))
    (should
     (equal
      tree
      '("document"
        ("hlink" "./article.org" "./article.pdf")
        ("hlink" "Parent" "../peer.pdf")
        ("hlink" "Other" "chapter.org.gpg")
        ("hlink" "Web" "https://example.org/file.org")
        ("hlink" "Native" "native.org"))))
    (should (equal body (org-texmacs-document-body document))))
  (let ((document
         (org-texmacs--document-create
          :body
          '(document (hlink "Article" "article.org"))
          :file-paths '((0 1)))))
    (should
     (string-match-p
      "article.pdf" (org-texmacs--native-document-wire document t)))
    (should-error
     (org-texmacs--native-document-wire document)
     :type 'org-texmacs-encoding-error)))

(ert-deftest org-texmacs-cleanup-explicit-subtree-standard-preparation
    ()
  (org-texmacs-test--with-cleanup-source
    (erase-buffer)
    (insert "* Heading\nLocal text\n")
    (let ((before
           (org-texmacs-test--document-buffer-state (current-buffer)))
          (org-export-use-babel nil))
      (should
       (equal
        (org-texmacs-test--observe-standard-cleanup
         (lambda ()
           (should
            (org-texmacs-document-p
             (org-texmacs-document-from-buffer
              (current-buffer) nil 1)))))
        '(root prepared ast)))
      (should
       (equal
        before
        (org-texmacs-test--document-buffer-state
         (current-buffer)))))))

(ert-deftest org-texmacs-export-backend-dispatch-option-rejection ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert "Source.\n")
    (let ((org-export-dispatch-last-action nil)
          (org-export-dispatch-last-position (make-marker)))
      (cl-letf (((symbol-function 'read-file-name)
                 (lambda (&rest _)
                   (ert-fail
                    "Unsupported dispatcher option prompted"))))
        (dolist (option '(async body))
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
      (setq-local org-export-with-author nil)
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

(ert-deftest org-texmacs-export-backend-body-only-preprocessing-guard
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
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
        (should-error
         (org-export-as 'texmacs nil nil t)
         :type 'user-error))
      (should (equal original (buffer-string)))))
  (require 'ox-ascii)
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
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
    (setq-local org-export-with-author nil)
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
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
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

(ert-deftest
    org-texmacs-export-backend-nonfile-prompt-and-native-bytes
    ()
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
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
                        (should (derived-mode-p 'org-mode))
                        (should-not (eq (current-buffer) source))
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
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
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
    (goto-char 3)
    (set-mark 4)
    (narrow-to-region 2 7)
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
            explicit
            (org-texmacs-export-to-buffer (current-buffer)))))
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
        (setq-local org-export-with-author nil)
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
  (let ((org-export-default-language "en")
        input)
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
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
          "(\"generic\") ((\"language\" \"english\" org-literal)) (\"document\" (\"concat\" (\"hlink\" \"Figure\" \"/source/resources/figures/a.pdf\") \" \") (\"concat\" (\"hlink\" \"./notes.org\" \"/source/resources/notes.pdf\") \" \")) ()")))
      (should (equal before (org-texmacs-document-body document))))))

(ert-deftest
    org-texmacs-file-links-explicit-context-and-unsupported-semantics
    ()
  (let* ((link
          (org-element-create
           'link
           '(:type
             "file"
             :path "relative.pdf"
             :raw-link "file:relative.pdf")))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil link))))
    (let ((document
           (org-texmacs-document (org-texmacs-input-create ast nil))))
      (should
       (equal
        (org-texmacs-document-body document)
        '(document (concat "file:relative.pdf"))))
      (should-not (org-texmacs-document-file-paths document)))
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
      (setq-local org-export-with-author nil)
      (insert source "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
      (let* ((document
              (org-texmacs-document-from-buffer (current-buffer)))
             (body (org-texmacs-document-body document)))
        (should (org-texmacs-document-p document))
        (should-not (memq 'hlink (flatten-tree body)))
        (should-not (org-texmacs-document-file-paths document))))))

(ert-deftest org-texmacs-narrowing-config-and-source-state ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
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

(ert-deftest org-texmacs-narrowing-empty-and-preflight-boundaries ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _)
               (ert-fail "Invalid/empty narrowing started worker"))))
    (with-temp-buffer
      (org-mode)
      (setq-local org-export-with-author nil)
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
      (setq-local org-export-with-author nil)
      (insert "Body $(math \"x\")$.\n")
      (narrow-to-region 8 12)
      (let ((state
             (org-texmacs-test--document-buffer-state
              (current-buffer))))
        (should
         (org-texmacs-document-p
          (org-texmacs-document-from-buffer (current-buffer))))
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
      (setq-local org-export-with-author nil)
      (insert "#+INCLUDE: outside.org\nBody.\n")
      (search-backward "Body")
      (narrow-to-region (point) (point-max))
      (should
       (org-texmacs-document-p
        (org-texmacs-document-from-buffer (current-buffer)))))))

(ert-deftest org-texmacs-overrides-global-file-subtree-priority ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
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
             :with-author t
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
    (setq-local org-export-with-author t)
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
        (should-not (memq 'strong (flatten-tree body)))
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
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
     (insert
      "[fn:n] Note $(math \"x\")$.\n\n* Keep\nBody[fn:n].\n"
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

(ert-deftest org-texmacs-region-partial-text-and-file-context ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
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

(ert-deftest org-texmacs-region-headings-and-complete-native-block ()
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (setq-local org-export-with-author nil)
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

(ert-deftest org-texmacs-subtree-configuration-and-owned-selection ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author t)
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

(ert-deftest org-texmacs-subtree-date-and-filter-overrides ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author t)
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

(ert-deftest
    org-texmacs-cleanup-standard-errors-preserve-output-and-source
    ()
  (org-texmacs-test--with-cleanup-source
    (insert "Initially modified\n")
    (set-mark 2)
    (let ((before
           (org-texmacs-test--document-buffer-state (current-buffer)))
          (org-export-use-babel nil))
      (dolist (stage '(root prepared ast))
        (dolist (existing '(nil t))
          (dolist (entry
                   '((org-texmacs-export-to-texmacs . "source.tm")
                     (org-texmacs-export-to-pdf . "source.pdf")))
            (when (file-exists-p (cdr entry))
              (delete-file (cdr entry)))
            (when existing
              (write-region "Keep" nil (cdr entry) nil 'silent))
            (let ((phases
                   (org-texmacs-test--observe-standard-cleanup
                    (lambda ()
                      (should
                       (equal
                        (should-error
                         (funcall (car entry))
                         :type 'org-texmacs-document-error)
                        '(org-texmacs-document-error
                          "Cleanup sentinel"))))
                    stage)))
              (should (memq stage phases)))
            (if existing
                (with-temp-buffer
                  (insert-file-contents-literally (cdr entry))
                  (should (equal "Keep" (buffer-string))))
              (should-not (file-exists-p (cdr entry))))
            (should
             (equal
              before
              (org-texmacs-test--document-buffer-state
               (current-buffer))))))))))

(ert-deftest org-texmacs-export-backend-registration-and-installation
    ()
  (let ((backend (org-export-get-backend 'texmacs)))
    (should backend)
    (should-not (org-export-backend-menu backend))
    (should
     (equal
      (file-name-directory (locate-library "ox-texmacs"))
      (file-name-directory (locate-library "org-texmacs")))))
  (dolist (function
           '(org-texmacs-export-as-texmacs
             org-texmacs-export-to-texmacs org-texmacs-export-to-pdf))
    (should (commandp function))))

(ert-deftest org-texmacs-export-backend-rejects-unsupported-options ()
  (cl-letf (((symbol-function 'read-file-name)
             (lambda (&rest _)
               (ert-fail "Unsupported export prompted")))
            ((symbol-function 'org-texmacs-export-to-buffer)
             (lambda (&rest _)
               (ert-fail "Unsupported export converted")))
            ((symbol-function 'org-texmacs-export-texmacs-from-buffer)
             (lambda (&rest _) (ert-fail "Unsupported export wrote")))
            ((symbol-function 'org-texmacs-export-pdf-from-buffer)
             (lambda (&rest _)
               (ert-fail "Unsupported export rendered"))))
    (with-temp-buffer
      (org-mode)
      (insert "Whole buffer.\n")
      (dolist (function
               '(org-texmacs-export-as-texmacs
                 org-texmacs-export-to-texmacs
                 org-texmacs-export-to-pdf))
        (dolist (index '(0 3 4))
          (let ((arguments (make-list 5 nil)))
            (setcar (nthcdr index arguments) t)
            (should-error
             (apply function arguments)
             :type 'user-error)))))
    (with-temp-buffer
      (should-error
       (org-texmacs-export-as-texmacs)
       :type 'user-error))))

(ert-deftest org-texmacs-export-backend-render-and-write-errors ()
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (insert "Source.\n")
     (setq buffer-file-name
           (expand-file-name "source.org" test-directory))
     (let ((file (expand-file-name "source.pdf" test-directory)))
       (with-temp-file file
         (insert "PreviousOutput"))
       (cl-letf (((symbol-function 'org-texmacs-document-pdf)
                  (lambda (&rest _)
                    (signal 'org-texmacs-rendering-error
                            '("Rejected")))))
         (should-error
          (org-texmacs-export-to-pdf)
          :type 'org-texmacs-rendering-error))
       (with-temp-buffer
         (insert-file-contents-literally file)
         (should (equal "PreviousOutput" (buffer-string))))
       (let ((writer (symbol-function 'write-region)))
         (cl-letf (((symbol-function 'org-texmacs-document-pdf)
                    (lambda (&rest _)
                      (encode-coding-string "PartialPDF" 'us-ascii)))
                   ((symbol-function 'write-region)
                    (lambda (start _end target &rest _)
                      (funcall writer
                               start
                               (+ start 3)
                               target
                               nil
                               'silent)
                      (signal 'file-error
                              '("Injected write failure")))))
           (should-error
            (org-texmacs-export-to-pdf)
            :type 'file-error)))
       (with-temp-buffer
         (insert-file-contents-literally file)
         (should (equal "Par" (buffer-string))))))))

(ert-deftest
    org-texmacs-export-backend-preprocessing-failure-no-output
    ()
  (org-texmacs-test--with-environment
   (org-texmacs-test--with-bibliography-files
     (setq buffer-file-name (expand-file-name "source.org"))
     (dolist (text
              '("#+INCLUDE: missing.org\n"
                "#+begin_texmacs\n(math \"broken\"\n#+end_texmacs\n"))
       (erase-buffer)
       (insert text)
       (dolist (entry
                '((org-texmacs-export-to-texmacs . "source.tm")
                  (org-texmacs-export-to-pdf . "source.pdf")))
         (write-region "Keep" nil (cdr entry) nil 'silent)
         (should-error (funcall (car entry)))
         (with-temp-buffer
           (insert-file-contents-literally (cdr entry))
           (should (equal "Keep" (buffer-string)))))
       (let ((buffers (buffer-list)))
         (should-error (org-texmacs-export-as-texmacs))
         (should (equal buffers (buffer-list))))))))

(ert-deftest
    org-texmacs-export-backend-owned-include-and-source-option-waits
    ()
  (org-texmacs-test--with-environment
   (org-texmacs-test--with-bibliography-files
     (setq buffer-file-name (expand-file-name "source.org"))
     (dolist (change '(include option source))
       (dolist (format '(tm pdf))
         (setq-local org-texmacs-export-discover-bibliography nil)
         (write-region "Original text\n" nil "part.org" nil 'silent)
         (erase-buffer)
         (insert "#+INCLUDE: part.org\n")
         (let* ((org-export-use-babel nil)
                (source (current-buffer))
                (file (concat "source." (symbol-name format)))
                (consumer
                 (if (eq format 'pdf)
                     'org-texmacs-document-pdf
                   'org-texmacs-document-serialize)))
           (write-region "Keep" nil file nil 'silent)
           (cl-letf (((symbol-function consumer)
                      (lambda (document)
                        (should
                         (string-search
                          "Original text"
                          (prin1-to-string
                           (org-texmacs-document-body document))))
                        (with-current-buffer source
                          (pcase change
                            ('include
                             (write-region "Changed" nil "part.org"
                                           nil 'silent))
                            ('option
                             (setq-local
                              org-texmacs-export-discover-bibliography
                              t))
                            ('source
                             (goto-char (point-max))
                             (insert "Changed"))))
                        (encode-coding-string
                         "NativeBytes" 'us-ascii))))
             (if (eq change 'include)
                 (funcall
                  (if (eq format 'pdf)
                      'org-texmacs-export-to-pdf
                    'org-texmacs-export-to-texmacs))
               (should-error
                (funcall
                 (if (eq format 'pdf)
                     'org-texmacs-export-to-pdf
                   'org-texmacs-export-to-texmacs))
                :type 'org-texmacs-document-error)))
           (with-temp-buffer
             (insert-file-contents-literally file)
             (should
              (equal
               (if (eq change 'include)
                   "NativeBytes"
                 "Keep")
               (buffer-string))))))))))

(ert-deftest org-texmacs-export-menu-first-load-default-and-require ()
  (org-texmacs-test--menu-fresh-process
   '(progn
      (require 'ox-texmacs)
      (let ((backend (org-export-get-backend 'texmacs))
            (registry org-export-registered-backends)
            (hooks
             (copy-sequence org-export-before-processing-functions)))
        (should backend)
        (should-not (org-export-backend-menu backend))
        (dolist (command
                 '(org-texmacs-export-as-texmacs
                   org-texmacs-export-to-texmacs
                   org-texmacs-export-to-pdf))
          (should (commandp command)))
        (setq org-texmacs-export-menu-keys
              '(:prefix ?Z :buffer ?a :file ?b :pdf ?c))
        (require 'ox-texmacs)
        (should (eq registry org-export-registered-backends))
        (should (eq backend (org-export-get-backend 'texmacs)))
        (should-not (org-export-backend-menu backend))
        (should (equal hooks org-export-before-processing-functions))
        (with-temp-buffer
          (org-mode)
          (should-error
           (org-export-as 'texmacs nil nil t)
           :type 'user-error))))))

(ert-deftest
    org-texmacs-export-menu-first-load-explicit-dispatch-and-ownership
    ()
  (org-texmacs-test--menu-fresh-process
   '(progn
      (setq org-texmacs-export-menu-keys
            '(:prefix ?Z :buffer ?a :file ?b :pdf ?c))
      (require 'ox-texmacs)
      (let* ((backend (org-export-get-backend 'texmacs))
             (menu (org-export-backend-menu backend)))
        (should (equal (car menu) ?Z))
        (setcar (cdr org-texmacs-export-menu-keys) ?Y)
        (should (equal (car menu) ?Z))
        (dolist (entry
                 '((?a . org-texmacs-export-as-texmacs)
                   (?b . org-texmacs-export-to-texmacs)
                   (?c . org-texmacs-export-to-pdf)))
          (with-temp-buffer
            (org-mode)
            (insert "Text\n")
            (let ((events (list ?Z (car entry)))
                  (called nil)
                  (org-export-dispatch-use-expert-ui t)
                  (org-export-dispatch-last-action nil)
                  (org-export-dispatch-last-position (make-marker)))
              (cl-letf (((symbol-function 'read-event)
                         (lambda (&rest _)
                           (or (pop events)
                               (ert-fail "Input exhausted"))))
                        ((symbol-function (cdr entry))
                         (lambda (&rest args)
                           (should (cl-every #'null args))
                           (setq called t)
                           'exported)))
                (should (eq (org-export-dispatch) 'exported))
                (should called)))))
        (require 'ox-texmacs)
        (should (eq backend (org-export-get-backend 'texmacs)))))))

(ert-deftest org-texmacs-export-menu-valid-key-domains-and-fields ()
  (let ((org-export-registered-backends nil))
    (should-not (org-texmacs--export-menu-entry nil))
    (should
     (equal
      (org-texmacs--export-menu-entry
       '(:prefix ?界 :buffer ?字 :file ?文 :pdf ?档))
      '(?界
        "Export to TeXmacs"
        ((?字 "As TeXmacs buffer" org-texmacs-export-as-texmacs)
         (?文 "As .tm file" org-texmacs-export-to-texmacs)
         (?档 "As PDF file" org-texmacs-export-to-pdf)))))
    (should
     (org-texmacs--export-menu-entry
      '(:pdf ?p :file ?t :buffer ?T :prefix ?T)))
    (dolist (value
             '(t
               (:prefix ?Z)
               (:prefix ?Z :buffer ?a :file ?b :pdf ?c :other ?d)
               (:prefix ?Z :buffer ?a :file ?b :file ?c)
               (:prefix ?Z :buffer ?a :file ?a :pdf ?c)
               (:prefix ?Z :buffer "a" :file ?b :pdf ?c)
               (:prefix ?Z :buffer ?a :file ?b :pdf)))
      (should-error
       (org-texmacs--export-menu-entry value)
       :type 'user-error))
    (let ((cycle (list :prefix ?Z)))
      (setcdr (last cycle) cycle)
      (should-error
       (org-texmacs--export-menu-entry cycle)
       :type 'user-error))
    (dolist (key
             '(?q
               ??
               ?#
               ?&
               ?P
               0
               1
               2
               6
               7
               14
               16
               19
               22
               32
               127
               128
               #xd800
               #x200005a))
      (should-error
       (org-texmacs--export-menu-entry
        (list :prefix key :buffer ?a :file ?b :pdf ?c))
       :type 'user-error))
    (dolist (key '(?q ?? ?# ?& 2 14 32 127))
      (should-error
       (org-texmacs--export-menu-entry
        (list :prefix ?Z :buffer key :file ?b :pdf ?c))
       :type 'user-error))))

(ert-deftest org-texmacs-export-api-main-module-fresh-load ()
  (org-texmacs-test--menu-fresh-process
   '(progn
      (require 'org-texmacs)
      (should-not (featurep 'ox-texmacs))
      (dolist (entry
               '((org-texmacs-export-texmacs-from-buffer
                  source-buffer
                  &optional
                  bibliography-sources
                  subtree-position
                  region
                  ext-plist)
                 (org-texmacs-export-pdf-from-buffer
                  source-buffer
                  &optional
                  bibliography-sources
                  subtree-position
                  region
                  ext-plist)
                 (org-texmacs-export-to-buffer
                  source-buffer
                  &optional
                  bibliography-sources
                  subtree-position
                  region
                  ext-plist)
                 (org-texmacs-export-to-texmacs-file
                  source-buffer file &optional bibliography-sources)
                 (org-texmacs-export-to-pdf-file
                  source-buffer file &optional bibliography-sources)))
        (should (fboundp (car entry)))
        (should-not (commandp (car entry)))
        (should
         (equal (help-function-arglist (car entry) t) (cdr entry)))
        (should
         (equal
          (file-name-base
           (symbol-file (car entry) 'defun))
          "org-texmacs")))
      (dolist (retired
               '(org-texmacs-export-from-buffer
                 org-texmacs-export-to-file
                 org-texmacs-export-to-texmacs-pdf))
        (should-not (fboundp retired)))
      (dolist
          (retired
           '(org-texmacs-prepare-buffer-preprocessed
             org-texmacs-document-from-buffer-preprocessed
             org-texmacs-export-from-buffer-preprocessed
             org-texmacs-document-from-buffer-discover-bibliography
             org-texmacs-export-from-buffer-discover-bibliography))
        (should-not (fboundp retired)))
      (dolist (library
               '("org-texmacs-preprocess" "org-texmacs-bibliography"))
        (should-not (locate-library library))))))

(ert-deftest org-texmacs-export-api-frontend-fresh-load ()
  (org-texmacs-test--menu-fresh-process
   '(progn
      (require 'ox-texmacs)
      (dolist (command
               '(org-texmacs-export-as-texmacs
                 org-texmacs-export-to-texmacs
                 org-texmacs-export-to-pdf))
        (should (commandp command))
        (should
         (equal
          (help-function-arglist command t)
          '(&optional
            async subtreep visible-only body-only ext-plist)))
        (should
         (equal
          (file-name-base (symbol-file command 'defun)) "ox-texmacs"))
        (should (equal (interactive-form command) '(interactive nil)))
        (should (equal (command-modes command) '(org-mode)))
        (with-temp-buffer
          (should-error (funcall command) :type 'user-error)))
      (should-not (commandp 'org-texmacs-export-to-pdf-file))
      (should
       (equal
        (file-name-base
         (symbol-file 'org-texmacs-export-to-pdf-file 'defun))
        "org-texmacs"))
      (should-not
       (org-export-backend-menu (org-export-get-backend 'texmacs))))))

(ert-deftest
    org-texmacs-overrides-invalid-plists-before-prompts-and-workers
    ()
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: H:2\nBody.\n")
    (let ((cycle (list :with-title t)))
      (setcdr (cdr cycle) cycle)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid overrides started worker")))
                ((symbol-function 'read-file-name)
                 (lambda (&rest _)
                   (ert-fail "Invalid overrides prompted"))))
        (dolist (options
                 (list
                  t '(:title) '(:title . "bad") cycle '(title "bad")))
          (should-error
           (org-texmacs-prepare-buffer
            (current-buffer) nil nil nil options)
           :type 'org-texmacs-document-error)
          ;; All source APIs validate plist shape, leaving values to Org.
          (when (or (not (proper-list-p options))
                    (cl-oddp (length options))
                    (not (keywordp (car options))))
            (dolist (command
                     '(org-texmacs-export-as-texmacs
                       org-texmacs-export-to-texmacs
                       org-texmacs-export-to-pdf))
              (should-error
               (funcall command nil nil nil nil options)
               :type 'user-error))))))))

;;; frontend.el ends here
