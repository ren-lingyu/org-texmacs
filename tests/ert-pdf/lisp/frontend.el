;;; frontend.el --- pdf frontend regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-cleanup-full-native-file-exports ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-cleanup-source
    ;; Native INCLUDE uses another private buffer; guards must inspect SOURCE.
    (setq-local org-export-with-toc nil)
    (dolist (modified '(nil t))
      (set-buffer-modified-p modified)
      (goto-char 3)
      (set-mark 2)
      (dolist (discover '(nil t))
        (setq-local org-texmacs-export-discover-bibliography discover)
        (let ((before
               (org-texmacs-test--document-buffer-state
                (current-buffer)))
              (file buffer-file-name)
              (base default-directory))
          (dolist (command
                   '(org-texmacs-export-to-texmacs
                     org-texmacs-export-to-pdf))
            (let ((kinds
                   (org-texmacs-test--observe-cleanup
                    (lambda ()
                      (let ((output (funcall command)))
                        (should (file-regular-p output))
                        (if (eq command 'org-texmacs-export-to-pdf)
                            (should
                             (string-match-p
                              "Included cleanup sentinel"
                              (org-texmacs-test--pdf-text output)))
                          (with-temp-buffer
                            (insert-file-contents output)
                            (should
                             (string-match-p
                              "Included cleanup sentinel"
                              (buffer-string))))))))))
              (should (memq 'root kinds))
              (should (memq 'include kinds))
              (should
               (eq (and (memq 'bibliography kinds) t) discover)))
            (should
             (equal
              before
              (org-texmacs-test--document-buffer-state
               (current-buffer))))
            (should (equal file buffer-file-name))
            (should (equal base default-directory)))))))))

(ert-deftest org-texmacs-cleanup-errors-preserve-output-and-source ()
  (org-texmacs-test--with-cleanup-source
   (setq-local org-texmacs-export-discover-bibliography t)
   (insert "Initially modified\n")
   (set-mark 2)
   (let ((before
          (org-texmacs-test--document-buffer-state (current-buffer)))
         (file buffer-file-name)
         (base default-directory))
     (dolist (stage '(root include bibliography))
       (dolist (existing '(nil t))
         (dolist (entry
                  '((org-texmacs-export-to-texmacs . "source.tm")
                    (org-texmacs-export-to-pdf . "source.pdf")))
           (when (file-exists-p (cdr entry))
             (delete-file (cdr entry)))
           (when existing
             (write-region "Keep" nil (cdr entry) nil 'silent))
           (let ((kinds
                  (org-texmacs-test--observe-cleanup
                   (lambda ()
                     (should
                      (equal
                       (should-error
                        (funcall (car entry))
                        :type 'org-texmacs-document-error)
                       '(org-texmacs-document-error
                         "Cleanup sentinel"))))
                   stage)))
             (should (memq stage kinds)))
           (if existing
               (with-temp-buffer
                 (insert-file-contents-literally (cdr entry))
                 (should (equal (buffer-string) "Keep")))
             (should-not (file-exists-p (cdr entry))))
           (should
            (equal
             before
             (org-texmacs-test--document-buffer-state
              (current-buffer))))
           (should (equal file buffer-file-name))
           (should (equal base default-directory))))))))

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
        (dolist (index '(0 2 3 4))
          (let ((arguments (make-list 5 nil)))
            (setcar (nthcdr index arguments) t)
            (should-error
             (apply function arguments)
             :type 'user-error)))))
    (with-temp-buffer
      (should-error
       (org-texmacs-export-as-texmacs)
       :type 'user-error))))

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

(ert-deftest org-texmacs-export-backend-render-and-write-errors ()
  (org-texmacs-test--with-worker
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

(ert-deftest
    org-texmacs-export-backend-preprocessing-failure-no-output
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (setq buffer-file-name (expand-file-name "source.org"))
    (dolist (text
             '("#+INCLUDE: missing.org\n"
               "#+SETUPFILE: missing.org\n"
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

(ert-deftest org-texmacs-export-backend-local-route-and-discovery ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region
     "@book{external-key, title={LocalFrontendReference}}"
     nil
     "refs.bib"
     nil
     'silent)
    (insert
     "* Outside\nOther\n* Chosen\n[cite:@external-key]\n#+print_bibliography:\n")
    (setq buffer-file-name (expand-file-name "source.org"))
    (let ((org-cite-global-bibliography '("refs.bib"))
          (org-export-show-temporary-export-buffer nil)
          (org-export-before-processing-functions
           (list
            (lambda (&rest _)
              (ert-fail "Local export replayed preprocessing")))))
      (goto-char (point-min))
      (search-forward "* Chosen")
      (beginning-of-line)
      (should-error
       (org-texmacs-export-as-texmacs nil t)
       :type 'org-texmacs-document-error)
      (setq-local org-texmacs-export-discover-bibliography t)
      (dolist (scope '(subtree region narrowing))
        (save-restriction
          (goto-char (point-min))
          (search-forward "* Chosen")
          (beginning-of-line)
          (let ((begin (point))
                (transient-mark-mode t))
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
                  (with-current-buffer output
                    (should
                     (string-match-p "bib-list" (buffer-string)))
                    (kill-buffer output)))
              (let ((file
                     (org-texmacs-export-to-texmacs
                      nil (eq scope 'subtree))))
                (with-temp-buffer
                  (insert-file-contents-literally file)
                  (should
                   (string-match-p "bib-list" (buffer-string)))))
              (let ((file
                     (org-texmacs-export-to-pdf
                      nil (eq scope 'subtree))))
                (should
                 (string-match-p
                  "LocalFrontendReference"
                  (org-texmacs-test--pdf-text file)))))
            (setq mark-active nil))))))))

(ert-deftest org-texmacs-export-backend-dependency-and-option-waits ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (setq buffer-file-name (expand-file-name "source.org"))
    (dolist (change '(include bibliography option source))
      (dolist (format '(tm pdf))
        (write-region "Original text\n" nil "part.org" nil 'silent)
        (write-region
         "@book{external-key, title={Original}, author={Doe, Jane}, year={2026}}\n"
         nil
         "refs.bib"
         nil
         'silent)
        (erase-buffer)
        (insert "#+INCLUDE: part.org\n")
        (when (eq change 'bibliography)
          (insert
           "#+bibliography: refs.bib\n[cite:@external-key]\n#+print_bibliography:\n"))
        (setq-local org-texmacs-export-discover-bibliography
                    (eq change 'bibliography))
        (let* ((source (current-buffer))
               (file (concat "source." (symbol-name format)))
               (consumer
                (if (eq format 'pdf)
                    'org-texmacs-document-pdf
                  'org-texmacs-document-serialize)))
          (write-region "Keep" nil file nil 'silent)
          (cl-letf (((symbol-function consumer)
                     (lambda (_document)
                       (with-current-buffer source
                         (pcase change
                           ('include
                            (write-region "Changed" nil "part.org"
                                          nil 'silent))
                           ('bibliography
                            (write-region "Changed" nil "refs.bib"
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
            (should-error
             (funcall
              (if (eq format 'pdf)
                  'org-texmacs-export-to-pdf
                'org-texmacs-export-to-texmacs))
             :type 'org-texmacs-document-error))
          (with-temp-buffer
            (insert-file-contents-literally file)
            (should (equal "Keep" (buffer-string))))))))))

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
           (org-export-as 'texmacs)
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
          (special
           '(org-texmacs-export-from-buffer-preprocessed
             org-texmacs-export-from-buffer-discover-bibliography))
        (should (fboundp special))))))

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
         (let ((output (org-texmacs-export-as-texmacs nil t)))
           (unwind-protect
               (with-current-buffer output
                 (should
                  (string-match-p
                   "SubtreeTitleSentinel" (buffer-string)))
                 (should
                  (string-match-p
                   "SelectedBodySentinel" (buffer-string)))
                 (should-not
                  (string-match-p "Prefix\\|suffix" (buffer-string))))
             (kill-buffer output)))
         (dolist (entry
                  '((org-texmacs-export-to-texmacs . "tm")
                    (org-texmacs-export-to-pdf . "pdf")))
           (should
            (equal
             (funcall (car entry) nil t)
             (expand-file-name (concat "subtree." (cdr entry))
                               test-directory))))
         (should
          (equal
           (org-texmacs-export-to-texmacs)
           (expand-file-name "file.tm" test-directory)))
         (should
          (equal
           state
           (org-texmacs-test--document-buffer-state
            (current-buffer)))))))))

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
                  t
                  '(:title)
                  '(:title . "bad")
                  cycle
                  '(:title 42)
                  '(:title ("already parsed"))
                  '(:with-title t :with-title nil)
                  '(title "bad")
                  '(:headline-levels 6)
                  '(:section-numbers -1)
                  '(:with-author "yes")
                  '(:with-tasks (1))
                  '(:select-tags "tag")
                  '(:exclude-tags (t))
                  '(:with-tags invalid)
                  '(:options "toc:nil")
                  '(:export-file-name "other")
                  '(:texmacs-resource-base "/")
                  '(:filter-final-output ignore)
                  '(:bibliography "refs.bib")))
          (should-error
           (org-texmacs-prepare-buffer
            (current-buffer) nil nil nil options)
           :type 'org-texmacs-document-error)
          (dolist (command
                   '(org-texmacs-export-as-texmacs
                     org-texmacs-export-to-texmacs
                     org-texmacs-export-to-pdf))
            (should-error
             (funcall command nil nil nil nil options)
             :type 'user-error)))))))

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

;;; frontend.el ends here
