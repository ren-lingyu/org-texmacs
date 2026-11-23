;;; ert-pdf-frontend.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'ox)
(require 'ox-texmacs)

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

(ert-deftest
    org-texmacs-standard-context-native-pdf-selected-footnote-binding
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil author:nil date:nil\n* Selected\nFirst[fn:n], again[fn:n].\n** Destination\nSee [[*Destination]].\n* Other\n\n[fn:n] Footnote sentinel.\n")
     (goto-char (point-min))
     (search-forward "* Selected")
     (beginning-of-line)
     (let* ((org-export-use-babel nil)
            (file
             (expand-file-name "standard-note.pdf" test-directory))
            (bytes
             (cl-letf (((symbol-function
                         'org-texmacs-document-serialize)
                        (lambda (_)
                          (ert-fail "Standard PDF serialized .tm"))))
               (org-texmacs--standard-consume 'pdf t))))
       (let ((coding-system-for-write 'no-conversion))
         (write-region bytes nil file nil 'silent))
       (let ((text (org-texmacs-test--pdf-text file)))
         (should (string-match-p "Footnote sentinel" text))
         (should
          (string-match-p
           "First[[:space:]]*1.*again[[:space:]]*1" text))
         (should-not (string-match-p "Footnotes\\|[?][?]" text)))))))

(ert-deftest org-texmacs-cleanup-full-standard-file-exports ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-cleanup-source
     (setq-local org-export-with-toc nil)
     (dolist (modified '(nil t))
       (set-buffer-modified-p modified)
       (goto-char 3)
       (set-mark 2)
       (let ((before
              (org-texmacs-test--document-buffer-state
               (current-buffer)))
             (org-export-use-babel nil))
         (dolist (command
                  '(org-texmacs-export-to-texmacs
                    org-texmacs-export-to-pdf))
           (let ((phases
                  (org-texmacs-test--observe-standard-cleanup
                   (lambda ()
                     (let ((file (funcall command)))
                       (should (file-regular-p file))
                       (if (eq command 'org-texmacs-export-to-pdf)
                           (should
                            (string-search
                             "Included cleanup sentinel"
                             (org-texmacs-test--pdf-text file)))
                         (with-temp-buffer
                           (insert-file-contents-literally file)
                           (should
                            (string-search
                             "Included cleanup sentinel"
                             (buffer-string))))))))))
             (should (equal phases '(root prepared ast))))
           (should
            (equal
             before
             (org-texmacs-test--document-buffer-state
              (current-buffer))))))))))

(ert-deftest org-texmacs-export-backend-dispatch-and-native-consumers
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "WholeBufferSentinel.\n")
     (setq buffer-file-name
           (expand-file-name "source.org" test-directory))
     (let ((source (current-buffer))
           (original (buffer-string))
           (org-export-dispatch-last-action nil)
           (org-export-dispatch-last-position (make-marker))
           (org-export-show-temporary-export-buffer nil))
       (progn
         (cl-letf (((symbol-function 'display-buffer)
                    (lambda (&rest _)
                      (ert-fail
                       "Hidden export buffer was displayed"))))
           (let ((output (org-texmacs-export-as-texmacs)))
             (unwind-protect
                 (with-current-buffer output
                   (should buffer-read-only)
                   (should-not (multibyte-string-p (buffer-string)))
                   (should
                    (string-match-p
                     "WholeBufferSentinel" (buffer-string))))
               (kill-buffer output))))
         (dolist (consumer
                  '((org-texmacs-export-to-texmacs . "tm")
                    (org-texmacs-export-to-pdf . "pdf")))
           (let ((file
                  (expand-file-name (concat "source." (cdr consumer))
                                    test-directory)))
             (cl-letf (((symbol-function 'org-export--dispatch-ui)
                        (lambda (&rest _) (list (car consumer))))
                       ((symbol-function 'read-file-name)
                        (lambda (&rest _)
                          (ert-fail
                           "Visiting source unexpectedly prompted"))))
               (should (equal file (org-export-dispatch))))
             (with-temp-buffer
               (set-buffer-multibyte nil)
               (insert-file-contents-literally file)
               (if (equal (cdr consumer) "pdf")
                   (should (string-prefix-p "%PDF-" (buffer-string)))
                 (should
                  (string-prefix-p "<TeXmacs|" (buffer-string)))
                 (should
                  (string-match-p
                   "WholeBufferSentinel" (buffer-string)))))
             (with-current-buffer source
               (should (equal file (funcall (car consumer)))))))
         (should
          (equal
           original
           (with-current-buffer source
             (buffer-string)))))))))

(ert-deftest org-texmacs-export-backend-preprocessed-three-consumers
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (make-directory "parts")
    (write-region "IncludedFrontendSentinel\n" nil "parts/a.org"
                  nil
                  'silent)
    (insert
     "#+EXPORT_FILE_NAME: selected-name\n#+INCLUDE: \"parts/a.org\"\n")
    (setq buffer-file-name (expand-file-name "source.org"))
    (let* ((before
            (org-texmacs-test--document-buffer-state
             (current-buffer)))
           (hooks 0)
           (filters 0)
           (org-export-before-processing-functions
            (append
             org-export-before-processing-functions
             (list (lambda (_backend) (cl-incf hooks)))))
           (org-export-filter-parse-tree-functions
            (list
             (lambda (tree _backend _info)
               (cl-incf filters)
               tree)))
           (org-export-show-temporary-export-buffer nil)
           (output (org-texmacs-export-as-texmacs))
           bytes)
      (unwind-protect
          (with-current-buffer output
            (setq bytes (buffer-string))
            (should buffer-read-only)
            (should-not enable-multibyte-characters)
            (should (eq buffer-file-coding-system 'no-conversion))
            (should
             (string-match-p "IncludedFrontendSentinel" bytes)))
        (kill-buffer output))
      (let ((file (org-texmacs-export-to-texmacs)))
        (should (equal file (expand-file-name "selected-name.tm")))
        (with-temp-buffer
          (set-buffer-multibyte nil)
          (insert-file-contents-literally file)
          (should (equal bytes (buffer-string)))))
      (let ((file (org-texmacs-export-to-pdf)))
        (should (equal file (expand-file-name "selected-name.pdf")))
        (should
         (string-match-p
          "IncludedFrontendSentinel"
          (org-texmacs-test--pdf-text file))))
      (should (= hooks 3))
      (should (= filters 3))
      (should
       (equal
        before
        (org-texmacs-test--document-buffer-state
         (current-buffer))))))))

(ert-deftest org-texmacs-export-backend-selected-standard-preparation
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region "Included selection sentinel\n" nil "part.org"
                  nil
                  'silent)
    (insert "* Outside\nOther\n* Chosen\n#+INCLUDE: part.org\n")
    (setq buffer-file-name (expand-file-name "source.org"))
    (let ((org-export-use-babel nil)
          (org-export-show-temporary-export-buffer nil)
          (hooks 0))
      (let ((org-export-before-processing-functions
             (list (lambda (_) (cl-incf hooks)))))
        (dolist (scope '(subtree region narrowing))
          (save-mark-and-excursion
            (save-restriction
              (goto-char (point-min))
              (search-forward "* Chosen")
              (beginning-of-line)
              (let ((begin (point))
                    (transient-mark-mode t)
                    (mark-active nil))
                (pcase scope
                  ('region
                   (set-mark begin)
                   (goto-char (point-max))
                   (setq mark-active t))
                  ('narrowing (narrow-to-region begin (point-max))))
                (let ((output
                       (org-texmacs-export-as-texmacs
                        nil (eq scope 'subtree))))
                  (unwind-protect
                      (should
                       (string-search
                        "Included selection sentinel"
                        (with-current-buffer output
                          (buffer-string))))
                    (kill-buffer output)))
                (let ((file
                       (org-texmacs-export-to-texmacs
                        nil (eq scope 'subtree))))
                  (with-temp-buffer
                    (insert-file-contents-literally file)
                    (should
                     (string-search
                      "Included selection sentinel"
                      (buffer-string)))))
                (let ((file
                       (org-texmacs-export-to-pdf
                        nil (eq scope 'subtree))))
                  (should
                   (string-search
                    "Included selection sentinel"
                    (org-texmacs-test--pdf-text file)))))))))
      (should (= hooks 9))))))

(ert-deftest org-texmacs-narrowing-native-frontend-naming-and-state ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+EXPORT_FILE_NAME: file.other\n#+OPTIONS: toc:nil\n"
      "* Chosen\n:PROPERTIES:\n:EXPORT_TITLE: SubtreeTitleSentinel\n"
      ":EXPORT_FILE_NAME: subtree.other\n:END:\nPrefix SelectedBodySentinel suffix.\n")
     (search-backward "SelectedBodySentinel")
     (let ((begin (point))
           (end (+ (point) (length "SelectedBodySentinel")))
           (org-export-show-temporary-export-buffer nil))
       (narrow-to-region begin end)
       (goto-char begin)
       (set-mark end)
       (setq mark-active nil)
       (let ((state
              (org-texmacs-test--document-buffer-state
               (current-buffer))))
         ;; Org cannot select a subtree whose heading is inaccessible.
         (should-error
          (org-export-as 'texmacs t)
          :type 'outline-before-first-heading)
         (dolist (command
                  '(org-texmacs-export-as-texmacs
                    org-texmacs-export-to-texmacs
                    org-texmacs-export-to-pdf))
           (should-error
            (funcall command nil t)
            :type 'outline-before-first-heading))
         (let ((output (org-texmacs-export-as-texmacs)))
           (unwind-protect
               (with-current-buffer output
                 (should-not
                  (string-match-p
                   "SubtreeTitleSentinel" (buffer-string)))
                 (should
                  (string-match-p
                   "SelectedBodySentinel" (buffer-string)))
                 (should-not
                  (string-match-p "Prefix\\|suffix" (buffer-string))))
             (kill-buffer output)))
         (should
          (equal
           (org-texmacs-export-to-texmacs)
           (expand-file-name "file.tm" test-directory)))
         (should
          (equal
           state
           (org-texmacs-test--document-buffer-state
            (current-buffer)))))))))

(ert-deftest org-texmacs-overrides-native-menu-consumers-and-region ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Prefix RegionBodySentinel suffix.\n")
     (setq buffer-file-name
           (expand-file-name "source.org" test-directory))
     (search-backward "RegionBodySentinel")
     (let ((begin (point))
           (end (+ (point) (length "RegionBodySentinel")))
           (transient-mark-mode t)
           (org-export-show-temporary-export-buffer nil)
           (options
            '(:title
              "*ExternalTitleSentinel*"
              :author nil
              :with-toc nil)))
       (push-mark end t t)
       (let ((output
              (org-texmacs-export-as-texmacs
               nil nil nil nil options)))
         (unwind-protect
             (with-current-buffer output
               (should
                (string-match-p
                 "ExternalTitleSentinel" (buffer-string)))
               (should
                (string-match-p "RegionBodySentinel" (buffer-string)))
               (should-not
                (string-match-p "Prefix\\|suffix" (buffer-string))))
           (kill-buffer output)))
       (let ((file
              (org-texmacs-export-to-texmacs
               nil nil nil nil options)))
         (should
          (equal file (expand-file-name "source.tm" test-directory)))
         (with-temp-buffer
           (set-buffer-multibyte nil)
           (insert-file-contents-literally file)
           (should
            (string-match-p "ExternalTitleSentinel" (buffer-string)))
           (should-not
            (string-match-p "Prefix\\|suffix" (buffer-string)))))
       (let ((file
              (org-texmacs-export-to-pdf nil nil nil nil options)))
         (with-temp-buffer
           (set-buffer-multibyte nil)
           (insert-file-contents-literally file)
           (should (string-prefix-p "%PDF-" (buffer-string)))))
       (should (= begin (point)))
       (should (= end (mark)))
       (should mark-active)))))

(ert-deftest org-texmacs-region-dispatch-and-subtree-priority ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+TITLE: FileTitleSentinel\n#+OPTIONS: toc:nil\n"
      "#+EXPORT_FILE_NAME: region.other\n* Chosen\n:PROPERTIES:\n"
      ":EXPORT_TITLE: SubtreeTitleSentinel\n:EXPORT_FILE_NAME: subtree.other\n:END:\n"
      "Prefix RegionBodySentinel suffix.\n* Outside\nElse.\n")
     (setq buffer-file-name
           (expand-file-name "source.org" test-directory))
     (goto-char (point-min))
     (search-forward "RegionBodySentinel")
     (let ((end (point))
           (begin (match-beginning 0))
           (transient-mark-mode t)
           (org-export-show-temporary-export-buffer nil)
           (org-export-dispatch-last-action nil)
           (org-export-dispatch-last-position (make-marker)))
       (goto-char begin)
       (push-mark end t t)
       (dolist (subtreep '(nil t))
         (let ((output (org-texmacs-export-as-texmacs nil subtreep)))
           (unwind-protect
               (with-current-buffer output
                 (should buffer-read-only)
                 (should
                  (string-match-p
                   "RegionBodySentinel" (buffer-string)))
                 (should
                  (string-match-p
                   (if subtreep
                       "SubtreeTitleSentinel"
                     "FileTitleSentinel")
                   (buffer-string)))
                 (should-not
                  (string-match-p
                   "Prefix\\|suffix\\|Else" (buffer-string))))
             (kill-buffer output))))
       (dolist (consumer
                '((org-texmacs-export-to-texmacs . "tm")
                  (org-texmacs-export-to-pdf . "pdf")))
         (cl-letf (((symbol-function 'org-export--dispatch-ui)
                    (lambda (&rest _)
                      (list (car consumer) 'subtree))))
           (let ((file
                  (expand-file-name (concat "subtree." (cdr consumer))
                                    test-directory)))
             (should (equal file (org-export-dispatch)))
             (with-temp-buffer
               (set-buffer-multibyte nil)
               (insert-file-contents-literally file)
               (if (equal (cdr consumer) "pdf")
                   (should (string-prefix-p "%PDF-" (buffer-string)))
                 (should
                  (string-match-p
                   "RegionBodySentinel" (buffer-string)))
                 (should-not
                  (string-match-p
                   "Prefix\\|suffix\\|Else" (buffer-string))))))))
       (should (= begin (point)))
       (should (= end (mark)))
       (should mark-active)
       (should-not (buffer-narrowed-p))))))

(ert-deftest org-texmacs-subtree-dispatch-file-naming-and-source-state
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+TITLE: File title\n#+OPTIONS: toc:nil\n* Chosen\n"
      ":PROPERTIES:\n:EXPORT_FILE_NAME: chosen.other\n:END:\nSubtreeBodySentinel.\n"
      "* Outside\nOutsideBodySentinel.\n")
     (setq buffer-file-name
           (expand-file-name "source.org" test-directory))
     (goto-char (point-min))
     (search-forward "SubtreeBodySentinel")
     (let ((original (buffer-string))
           (position (point))
           (org-export-dispatch-last-action nil)
           (org-export-dispatch-last-position (make-marker))
           (org-export-show-temporary-export-buffer nil))
       (let ((output (org-texmacs-export-as-texmacs nil t)))
         (unwind-protect
             (with-current-buffer output
               (should buffer-read-only)
               (should
                (string-match-p
                 "SubtreeBodySentinel" (buffer-string)))
               (should-not
                (string-match-p
                 "OutsideBodySentinel" (buffer-string))))
           (kill-buffer output)))
       (dolist (consumer
                '((org-texmacs-export-to-texmacs . "tm")
                  (org-texmacs-export-to-pdf . "pdf")))
         (cl-letf (((symbol-function 'org-export--dispatch-ui)
                    (lambda (&rest _) (list (car consumer) 'subtree)))
                   ((symbol-function 'read-file-name)
                    (lambda (&rest _)
                      (ert-fail "Named subtree prompted"))))
           (let ((file
                  (expand-file-name (concat "chosen." (cdr consumer))
                                    test-directory)))
             (should (equal file (org-export-dispatch)))
             (with-temp-buffer
               (set-buffer-multibyte nil)
               (insert-file-contents-literally file)
               (if (equal (cdr consumer) "pdf")
                   (should (string-prefix-p "%PDF-" (buffer-string)))
                 (should
                  (string-match-p
                   "SubtreeBodySentinel" (buffer-string)))
                 (should-not
                  (string-match-p
                   "OutsideBodySentinel\\|File title"
                   (buffer-string))))))))
       (should (= position (point)))
       (should (equal original (buffer-string)))))))

;;; ert-pdf-frontend.el ends here
