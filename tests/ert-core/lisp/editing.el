;;; editing.el --- core editing regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-edit-fragment-lifecycle ()
  (dolist (carrier '(("$" . "$") ("\\(" . "\\)")))
    (let* ((open (car carrier))
           (close (cdr carrier))
           (payload "(math \"first\n literal\")")
           (original
            (concat "Before " open payload close "  after.\n")))
      (org-texmacs-test--with-edit-source
       original
       (search-forward "first")
       (let ((before (buffer-chars-modified-tick)))
         (org-edit-special)
         (setq editor (current-buffer))
         (should (derived-mode-p 'scheme-mode))
         (should (org-src-edit-buffer-p))
         (should (equal payload (buffer-string)))
         (org-edit-src-exit)
         (should (equal original (buffer-string)))
         (should (= before (buffer-chars-modified-tick))))
       (goto-char (point-min))
       (search-forward "first")
       (org-edit-special)
       (setq editor (current-buffer))
       (goto-char (point-min))
       (search-forward "first")
       (replace-match "saved" t t)
       (cl-letf (((symbol-function 'save-buffer) #'ignore))
         (org-edit-src-save))
       (switch-to-buffer source)
       (should
        (equal
         (string-replace "first" "saved" original) (buffer-string)))
       (goto-char (point-min))
       (search-forward "saved")
       (let ((org-src-ask-before-returning-to-edit-buffer nil))
         (org-edit-special))
       (should (eq editor (current-buffer)))
       (goto-char (point-min))
       (search-forward "saved")
       (replace-match "discard" t t)
       (org-edit-src-abort)
       (should
        (equal
         (string-replace "first" "saved" original) (buffer-string)))
       (goto-char (point-min))
       (search-forward "saved")
       (org-edit-special)
       (setq editor (current-buffer))
       (goto-char (point-min))
       (search-forward "saved")
       (replace-match "exited" t t)
       (org-edit-src-exit)
       (should
        (equal
         (string-replace "first" "exited" original)
         (buffer-string)))))))

(ert-deftest org-texmacs-edit-fragment-validates-save-and-exit ()
  (let ((original "Before $ (text) $ $(math \"x\")$ after.\n"))
    (org-texmacs-test--with-edit-source
     original
     (search-forward "math")
     (org-edit-special)
     (setq editor (current-buffer))
     (dolist (invalid
              '(""
                "plain"
                " (math \"x\")"
                "(math \"x\") "
                "(math \"x\""
                "(math \"open)"
                "(math \"x\\\")"
                "(math \"x\"))"
                "(a) (b)"))
       (erase-buffer)
       (insert invalid)
       (dolist (command '(org-edit-src-save org-edit-src-exit))
         (should-error (funcall command) :type 'user-error)
         (should (eq editor (current-buffer)))
         (should (buffer-modified-p))
         (should (equal invalid (buffer-string)))
         (should
          (equal
           original
           (with-current-buffer source
             (buffer-string))))))
     (let ((valid
            "(unknown (nested \"quoted \\\" text \\\\ and )\"))"))
       (erase-buffer)
       (insert valid)
       (org-edit-src-exit)
       (should
        (equal
         (string-replace "(math \"x\")" valid original)
         (buffer-string)))))))

(ert-deftest org-texmacs-edit-fragment-source-protection ()
  (let ((original "Before $ (text) $ $(math \"x\")$ after.\n"))
    (org-texmacs-test--with-edit-source
     original
     (search-forward "math")
     (let ((buffer-read-only t))
       (should-error (org-edit-special) :type 'buffer-read-only))
     (save-restriction
       (narrow-to-region (1- (point)) (line-end-position))
       (should-error (org-edit-special) :type 'user-error))
     (let ((major-mode-remap-alist
            '((scheme-mode
               . org-texmacs-test--fragment-failing-mode))))
       (cl-letf (((symbol-function
                   'org-texmacs-test--fragment-failing-mode)
                  (lambda () (error "Intentional mode failure"))))
         (should-error (org-edit-special) :type 'user-error)))
     (should (eq source (current-buffer)))
     (should (equal original (buffer-string)))
     (goto-char (point-min))
     (search-forward "math")
     (org-edit-special)
     (setq editor (current-buffer))
     (goto-char (point-min))
     (search-forward "\"x\"")
     (replace-match "\"edit\"" t t)
     (with-current-buffer source
       (setq buffer-read-only t))
     (unwind-protect
         (should-error (org-edit-src-exit) :type 'buffer-read-only)
       (with-current-buffer source
         (setq buffer-read-only nil)))
     (with-current-buffer source
       (narrow-to-region (point-min) (+ (point-min) 4)))
     (unwind-protect
         (should-error (org-edit-src-exit) :type 'user-error)
       (with-current-buffer source
         (widen)))
     (should (eq editor (current-buffer)))
     (with-current-buffer source
       (goto-char (point-min))
       (search-forward "\"x\"")
       (should-error
        (replace-match "\"outside\"" t t)
        :type 'user-error)
       ;; Simulate a source change made by a program bypassing Org's overlay.
       (let ((inhibit-modification-hooks t))
         (replace-match "\"outside\"" t t)))
     (should-error (org-edit-src-save) :type 'user-error)
     (should-error (org-edit-src-exit) :type 'user-error)
     (should (eq editor (current-buffer)))
     (org-edit-src-abort)
     (should
      (equal
       (string-replace "\"x\"" "\"outside\"" original)
       (buffer-string))))))

(ert-deftest org-texmacs-edit-fragment-org-contexts ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _)
               (ert-fail "Unexpected worker request")))
            ((symbol-function 'org-babel-get-src-block-info)
             (lambda (&rest _) (ert-fail "Unexpected Babel request")))
            ((symbol-function 'org-export-as)
             (lambda (&rest _) (ert-fail "Unexpected export"))))
    (dolist (container
             '("* Title %s here\n"
               "*Consider %s here.*\n"
               "| %s | tail |\n"
               "Text [fn::%s] end.\n"
               "[[https://example.invalid][%s]]\n"
               "#+caption: %s\n| a |\n"
               "#+caption[%s]: Long caption\n| a |\n"))
      (org-texmacs-test--with-edit-source
       (format container "\\((math \"x\")\\)")
       (search-forward "math")
       (org-edit-special)
       (setq editor (current-buffer))
       (should (equal "(math \"x\")" (buffer-string)))
       (org-edit-src-abort)))
    (dolist
        (text
         '("~$(math \"x\")$~\n"
           "Before $(math \"x\")$ after.\n"
           "#+begin_equation\n(math \"x\" $(math \"y\")$)\n#+end_equation\n"
           "#+begin_equation*\n(math \"x\" $(math \"y\")$)\n#+end_equation*\n"))
      (org-texmacs-test--with-edit-source
       text
       (search-forward
        (cond
         ((string-prefix-p "Before" text)
          "after")
         ((string-prefix-p "#+begin" text)
          "\"y\"")
         (t
          "x")))
       (should
        (eq
         'delegated
         (org-texmacs--edit-special (lambda () 'delegated))))))))

(ert-deftest org-texmacs-edit-block-roundtrip ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "Before\n#+begin_TEXMACS\n(document\n  (math \"x\"))\n#+end_TEXMACS\nAfter\n"
   (search-forward "(math")
   (let ((before (buffer-string)))
     (org-edit-special)
     (setq editor (current-buffer))
     (should (derived-mode-p 'scheme-mode))
     (should (org-src-edit-buffer-p))
     (goto-char (point-min))
     (search-forward "x")
     (replace-match "y" t t)
     (org-edit-src-exit)
     (should (eq (current-buffer) source))
     (should
      (equal
       (buffer-string) (string-replace "\"x\"" "\"y\"" before))))))

(ert-deftest org-texmacs-edit-block-indent-line ()
  :tags
  '(block-editing)
  (let* ((text "(document\n(math \"x\"))\n")
         (expected
          (with-temp-buffer
            (scheme-mode)
            (insert text)
            (goto-char (point-min))
            (forward-line)
            (indent-according-to-mode)
            (buffer-string))))
    (should-not (equal text expected))
    (org-texmacs-test--with-edit-source
     (concat
      "Before\n#+begin_texmacs\n" text "#+end_texmacs\nAfter\n")
     (setq-local org-texmacs--font-lock-enabled nil)
     (search-forward "(math")
     (org-indent-line)
     (should
      (equal
       (buffer-string)
       (concat
        "Before\n#+begin_texmacs\n"
        expected
        "#+end_texmacs\nAfter\n"))))))

(ert-deftest org-texmacs-edit-block-unchanged-and-abort ()
  :tags
  '(block-editing)
  (dolist (wrapper
           '(("#+begin_texmacs\n" "#+end_texmacs\n")
             ("- Item\n  #+BEGIN_TEXMACS\n" "  #+END_TEXMACS\n")
             ("#+begin_quote\n#+begin_texmacs\n"
              "#+end_texmacs\n#+end_quote\n")))
    (dolist (abort '(nil t))
      (org-texmacs-test--with-edit-source
       (concat
        (car wrapper)
        "  (document\n    \"line\n  literal\")\n"
        (cadr wrapper))
       (search-forward "(document")
       (let ((before (buffer-string)))
         (org-edit-special)
         (setq editor (current-buffer))
         (when abort
           (goto-char (point-max))
           (insert "CHANGED"))
         (if abort
             (org-edit-src-abort)
           (org-edit-src-exit))
         (should (equal before (buffer-string))))))))

(ert-deftest org-texmacs-edit-block-empty ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "#+begin_texmacs\n#+end_texmacs\n"
   (org-edit-special)
   (setq editor (current-buffer))
   (should (equal (buffer-string) ""))
   (insert "(math \"x\")\n")
   (org-edit-src-exit)
   (should
    (equal
     (buffer-string)
     "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"))))

(ert-deftest org-texmacs-edit-block-save-and-reuse ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"
   (forward-line)
   (org-edit-special)
   (setq editor (current-buffer))
   (goto-char (point-min))
   (search-forward "x")
   (replace-match "y" t t)
   ;; Org's save command normally also saves the source file.  Isolate that
   ;; unrelated I/O while retaining the real write-back and overlay lifecycle.
   (cl-letf (((symbol-function 'save-buffer) #'ignore))
     (org-edit-src-save))
   (with-current-buffer source
     (should (string-match-p "\"y\"" (buffer-string))))
   (switch-to-buffer source)
   (goto-char (point-min))
   (forward-line)
   (let ((org-src-ask-before-returning-to-edit-buffer nil))
     (org-edit-special))
   (should (eq editor (current-buffer)))
   (org-edit-src-exit)))

(ert-deftest org-texmacs-edit-block-reject-closing-line ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"
   (let ((before (buffer-string)))
     (org-edit-special)
     (setq editor (current-buffer))
     (goto-char (point-max))
     (insert "#+END_TEXMACS\n")
     (should-error (org-edit-src-exit) :type 'user-error)
     (should (buffer-live-p editor))
     (should
      (equal
       before
       (with-current-buffer source
         (buffer-string))))
     (org-edit-src-abort))))

(ert-deftest org-texmacs-edit-block-native-tab-and-region ()
  :tags
  '(block-editing)
  (let* ((body "(document\n(math \"x\")\n(math \"y\"))\n")
         (expected
          (with-temp-buffer
            (scheme-mode)
            (insert body)
            (indent-region (point-min) (point-max))
            (buffer-string))))
    (dolist (region '(nil t))
      (org-texmacs-test--with-edit-source
       (concat
        "Before\n#+begin_texmacs\n" body "#+end_texmacs\nAfter\n")
       (search-forward "(document") (beginning-of-line)
       (if region
           (let ((begin (point)))
             (search-forward "#+end_texmacs")
             (beginning-of-line)
             (org-indent-region begin (point)))
         (forward-line)
         (org-cycle)
         (forward-line)
         (org-cycle))
       (should
        (equal
         (buffer-string)
         (concat
          "Before\n#+begin_texmacs\n"
          expected
          "#+end_texmacs\nAfter\n")))))))

(ert-deftest org-texmacs-edit-block-container-indent-and-string ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "- Item\n  #+begin_texmacs\n  (document\n(math \"x\")\n  \"first\n literal\")\n  #+end_texmacs\n"
   (search-forward "(math")
   (org-indent-line)
   (beginning-of-line)
   (should (>= (current-indentation) 2))
   (search-forward "literal")
   (org-indent-line)
   (beginning-of-line)
   (should (looking-at " literal"))
   (should
    (string-prefix-p "- Item\n  #+begin_texmacs\n" (buffer-string)))
   (should (string-suffix-p "  #+end_texmacs\n" (buffer-string)))))

(ert-deftest org-texmacs-edit-block-read-only-and-narrowing ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "Before\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\nAfter\n"
   (search-forward "(math")
   (let ((before (buffer-string))
         (buffer-read-only t))
     (should-error (org-edit-special) :type 'buffer-read-only)
     (should-error (org-indent-line) :type 'buffer-read-only)
     (should (equal before (buffer-string))))
   (save-restriction
     (beginning-of-line)
     (narrow-to-region (point) (line-end-position))
     (should-error (org-edit-special) :type 'user-error)
     (should-not editor))))

(ert-deftest org-texmacs-edit-block-independent-of-export ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "#+begin_texmacs\n(math \"[[link]] *not Org*\")\n#+end_texmacs\n"
   (setq-local org-texmacs--font-lock-enabled nil)
   (cl-letf (((symbol-function 'org-texmacs--worker-request)
              (lambda (&rest _)
                (ert-fail "Unexpected worker request")))
             ((symbol-function 'org-babel-get-src-block-info)
              (lambda (&rest _)
                (ert-fail "Unexpected Babel request"))))
     (let ((before (buffer-string)))
       (org-edit-special)
       (setq editor (current-buffer))
       (org-edit-src-exit)
       (should (equal before (buffer-string)))))))

(ert-deftest org-texmacs-edit-other-org-contexts ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "#+begin_src scheme\n(display \"x\")\n#+end_src\n"
   (forward-line)
   (org-edit-special)
   (setq editor (current-buffer))
   (should (derived-mode-p 'scheme-mode))
   (should-not org-texmacs--edit-ready)
   (org-edit-src-abort))
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_other\ntext\n#+end_other\n")
    (goto-char (point-min))
    (should-error (org-edit-special) :type 'user-error)))

(ert-deftest org-texmacs-edit-mode-unavailable-or-failing ()
  :tags
  '(block-editing)
  (cl-letf (((symbol-function 'org-texmacs-test--failing-scheme-mode)
             (lambda () (error "Scheme mode initialization failed"))))
    (dolist (mode
             '(org-texmacs-test--missing-scheme-mode
               org-texmacs-test--failing-scheme-mode))
      (org-texmacs-test--with-edit-source
       "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"
       (let ((major-mode-remap-alist (list (cons 'scheme-mode mode)))
             (before (buffer-string))
             (tick (buffer-chars-modified-tick))
             (buffers (buffer-list)))
         (should-error (org-edit-special) :type 'user-error)
         (should (eq source (current-buffer)))
         (goto-char (point-min))
         (forward-line)
         (should-error (org-indent-line))
         (should (equal before (buffer-string)))
         (should (= tick (buffer-chars-modified-tick)))
         (should-not
          (cl-some
           (lambda (buffer)
             (with-current-buffer buffer
               (org-src-edit-buffer-p)))
           (cl-set-difference (buffer-list) buffers))))))))

(ert-deftest org-texmacs-edit-block-indent-point-and-failure ()
  :tags
  '(block-editing)
  (org-texmacs-test--with-edit-source
   "Before\n#+begin_texmacs\n(document\n(math \"x\"))\n#+end_texmacs\nAfter\n"
   (search-forward "(math")
   (org-indent-line)
   (should (looking-back "(math" (line-beginning-position)))
   (let ((before (buffer-string))
         (tick (buffer-chars-modified-tick)))
     (org-indent-line)
     (should (= tick (buffer-chars-modified-tick)))
     (cl-letf (((symbol-function 'org-texmacs--edit-indent-line)
                (lambda ()
                  (insert "Partial change")
                  (error "Indent failure"))))
       (should-error (org-indent-line)))
     (should (equal before (buffer-string))))))

(define-derived-mode
 org-texmacs-test-scheme-mode
 scheme-mode
 "STM test"
 (setq-local indent-line-function (lambda () (indent-line-to 4)))
 (font-lock-add-keywords
  nil '(("\\_<math\\_>" . 'font-lock-warning-face))
  'prepend))

(ert-deftest org-texmacs-edit-mode-org-src-dispatch ()
  :tags
  '(block-editing)
  (dolist (mapping '(language remap))
    (org-texmacs-test--with-edit-source
     "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"
     (if (eq mapping 'language)
         (setq-local org-src-lang-modes
                     (cons
                      '("scheme" . org-texmacs-test-scheme)
                      org-src-lang-modes))
       (setq-local major-mode-remap-alist
                   '((scheme-mode . org-texmacs-test-scheme-mode))))
     (should
      (eq
       (org-src-get-lang-mode "scheme")
       'org-texmacs-test-scheme-mode))
     (forward-line)
     (org-indent-line)
     (should (= (current-indentation) 4))
     (org-edit-special)
     (setq editor (current-buffer))
     (should (eq major-mode 'org-texmacs-test-scheme-mode))
     (org-edit-src-abort))
    (dolist (carrier '("$(math \"x\")$\n" "\\((math \"x\")\\)\n"))
      (org-texmacs-test--with-font-lock
       carrier
       (if (eq mapping 'language)
           (setq-local org-src-lang-modes
                       (cons
                        '("scheme" . org-texmacs-test-scheme)
                        org-src-lang-modes))
         (setq-local major-mode-remap-alist
                     '((scheme-mode . org-texmacs-test-scheme-mode))))
       (font-lock-flush) (font-lock-ensure)
       (let* ((math (org-texmacs-test--font-lock-position "math"))
              (face (get-text-property math 'face)))
         (should (memq 'font-lock-warning-face (ensure-list face)))
         (should (get-text-property math 'syntax-table))
         (dolist (position
                  (list (point-min) (1- (line-end-position))))
           (should-not
            (memq
             'font-lock-warning-face
             (ensure-list (get-text-property position 'face))))))))))

(ert-deftest org-texmacs-font-lock-default-and-ownership ()
  (org-texmacs-test--with-font-lock
   "Before $(math \"STRING\")$ after.\n"
   (let ((text (buffer-string))
         (tick (buffer-chars-modified-tick))
         (undo buffer-undo-list)
         (mark (mark t)))
     (goto-char 4)
     (font-lock-flush)
     (font-lock-ensure)
     (should (org-texmacs-test--font-lock-string-p "STRING"))
     (should
      (get-text-property
       (org-texmacs-test--font-lock-position "STRING") 'syntax-table))
     (should
      (equal
       (substring-no-properties text)
       (buffer-substring-no-properties (point-min) (point-max))))
     (should (= tick (buffer-chars-modified-tick)))
     (should-not (buffer-modified-p))
     (should (equal undo buffer-undo-list))
     (should (= 4 (point)))
     (should (equal mark (mark t))))))

(ert-deftest org-texmacs-font-lock-scheme-mode-failure ()
  (cl-letf (((symbol-function 'org-texmacs-test--failing-scheme-mode)
             (lambda () (error "Scheme mode initialization failed")))
            ((symbol-function 'backtrace-to-string)
             (lambda (&rest _) "Intentional mode failure")))
    (dolist (mode
             '(org-texmacs-test--missing-scheme-mode
               org-texmacs-test--failing-scheme-mode))
      (org-texmacs-test--with-font-lock
       "Outside *bold*. $(math \"x\")$\n"
       (setq-local major-mode-remap-alist
                   (list (cons 'scheme-mode mode)))
       (let ((before
              (buffer-substring-no-properties
               (point-min) (point-max)))
             (tick (buffer-chars-modified-tick)))
         (dotimes (_ 2)
           (font-lock-flush)
           (font-lock-ensure))
         (should
          (memq
           'bold
           (ensure-list
            (get-text-property
             (org-texmacs-test--font-lock-position "bold") 'face))))
         (should (eq major-mode 'org-mode))
         (should
          (equal
           before
           (buffer-substring-no-properties (point-min) (point-max))))
         (should (= tick (buffer-chars-modified-tick)))
         (should-not (buffer-modified-p)))))))

(ert-deftest org-texmacs-font-lock-opaque-and-disable ()
  (org-texmacs-test--with-font-lock
   "Outside *NORMAL*.\n\n$(math \"*BOLD* [[https://example.org][TEXT]]\")$\n"
   (setq-local org-hide-emphasis-markers t)
   (font-lock-flush)
   (font-lock-ensure)
   (should (org-texmacs-test--font-lock-string-p "TEXT"))
   (dolist (text '("[[" "TEXT" "*BOLD*"))
     (let ((p (org-texmacs-test--font-lock-position text)))
       (dolist (prop '(keymap mouse-face invisible org-emphasis))
         (should-not (get-text-property p prop)))))
   (setq-local org-texmacs--font-lock-enabled nil)
   (font-lock-ensure)
   (should-not (org-texmacs-test--font-lock-string-p "TEXT"))
   (should
    (get-text-property
     (org-texmacs-test--font-lock-position "TEXT") 'keymap))
   (should-not
    (get-text-property
     (org-texmacs-test--font-lock-position "TEXT") 'syntax-table))
   (setq-local org-texmacs--font-lock-enabled t)
   (font-lock-ensure)
   (should (org-texmacs-test--font-lock-string-p "TEXT"))))

(ert-deftest org-texmacs-font-lock-discovery-boundaries ()
  (org-texmacs-test--with-font-lock
   "* Heading $(math \"HEAD\")$\n\n| $(math \"TABLE\")$ |\n\n*em $(math \"EMPH\")$* =$(math \"CODE\")$= [[https://example.org][$(math \"LINK\")$]].\n\n#+begin_src text\n$(math \"SOURCE\")$\n#+end_src\n\nText $(math \"PARA\")$. [fn::Note $(math \"NOTE\")$].\n\n#+BeGiN_TeXmAcS\n(unknown \"BLOCK\")\n#+eNd_TeXmAcS\n\n#+begin_quote\n$(math \"QUOTE\")$\n#+end_quote\n\n- $(math \"LIST\")$\n\n[fn:n] $(math \"DEFINITION\")$\n"
   (dolist (word
            '("PARA"
              "NOTE"
              "BLOCK"
              "QUOTE"
              "LIST"
              "DEFINITION"
              "EMPH"
              "LINK"))
     (should (org-texmacs-test--font-lock-string-p word)))
   (dolist (word '("HEAD" "TABLE" "CODE" "SOURCE"))
     (should-not (org-texmacs-test--font-lock-string-p word)))))

(ert-deftest
    org-texmacs-font-lock-explicit-carriers-and-arbitrary-roots
    ()
  (org-texmacs-test--with-font-lock
   "Before $(unknown \"DOLLAR\")$ and \\((other \"BACKSLASH\")\\).\n\n(math \"BARE\")\n"
   (should (org-texmacs-test--font-lock-string-p "DOLLAR"))
   (should (org-texmacs-test--font-lock-string-p "BACKSLASH"))
   (should-not (org-texmacs-test--font-lock-string-p "BARE"))))

(ert-deftest org-texmacs-font-lock-edit-old-block-context ()
  (org-texmacs-test--with-font-lock
   "Before.\n\n#+begin_texmacs\n(unknown \"BLOCK\")\n#+end_texmacs\n\nAfter.\n"
   (should (org-texmacs-test--font-lock-string-p "BLOCK"))
   (goto-char (org-texmacs-test--font-lock-position "#+end_texmacs"))
   (delete-region (point) (line-end-position))
   (font-lock-ensure
    (line-beginning-position) (min (point-max) (1+ (point))))
   (should-not (org-texmacs-test--font-lock-string-p "BLOCK"))
   (insert "#+end_texmacs")
   (font-lock-ensure (line-beginning-position) (line-end-position))
   (should (org-texmacs-test--font-lock-string-p "BLOCK"))
   (goto-char
    (org-texmacs-test--font-lock-position "#+begin_texmacs"))
   (delete-region (point) (line-end-position))
   (font-lock-ensure)
   (should-not (org-texmacs-test--font-lock-string-p "BLOCK"))))

(ert-deftest org-texmacs-font-lock-incomplete-local-recovery ()
  (org-texmacs-test--with-font-lock
   "Good $(math \"GOOD\")$.\n\n[fn::Broken $(math \"BAD\"].\n\n$(math\n \"MULTI\")$\n"
   (should (org-texmacs-test--font-lock-string-p "GOOD"))
   (should (org-texmacs-test--font-lock-string-p "MULTI"))
   (goto-char (org-texmacs-test--font-lock-position "\"GOOD\""))
   (delete-char 1)
   (font-lock-ensure)
   (should-not (org-texmacs-test--font-lock-string-p "GOOD"))
   (should (org-texmacs-test--font-lock-string-p "MULTI"))
   (insert "\"")
   (font-lock-ensure)
   (should (org-texmacs-test--font-lock-string-p "GOOD"))))

(ert-deftest org-texmacs-font-lock-narrowing-mode-and-buffer-isolation
    ()
  (org-texmacs-test--with-font-lock
   "$(math \"OUTSIDE\")$\n\n$(math \"INSIDE\")$\n"
   (let ((source (current-buffer)))
     (org-texmacs-test--with-font-lock
      "$(math \"OTHER\")$\n"
      (setq-local org-texmacs--font-lock-enabled nil)
      (font-lock-ensure)
      (should-not (org-texmacs-test--font-lock-string-p "OTHER")))
     (should (eq source (current-buffer)))
     (should (org-texmacs-test--font-lock-string-p "OUTSIDE")))
   (goto-char (org-texmacs-test--font-lock-position "(math \"INSIDE"))
   (narrow-to-region (point) (point-max))
   (let ((bounds (cons (point-min) (point-max))))
     (setq-local org-texmacs--font-lock-enabled nil)
     (font-lock-ensure)
     (should (equal bounds (cons (point-min) (point-max))))
     (should-not (org-texmacs-test--font-lock-string-p "INSIDE")))
   (widen)
   (font-lock-ensure)
   (should-not (org-texmacs-test--font-lock-string-p "OUTSIDE"))
   (setq-local org-texmacs--font-lock-enabled t)
   (font-lock-ensure)
   (text-mode)
   (should-not
    (text-property-not-all
     (point-min) (point-max) 'org-texmacs--font-lock-owner nil))
   (should-not (get-text-property 2 'syntax-table))))

(ert-deftest org-texmacs-font-lock-local-work-and-no-native-process ()
  (org-texmacs-test--with-font-lock
   (apply #'concat (make-list 512 "Text $(math \"VALUE\")$ end.\n\n"))
   (let ((maximum 0)
         (calls 0)
         (original
          (and (fboundp 'org-texmacs--font-lock-paragraph-spans)
               (symbol-function
                'org-texmacs--font-lock-paragraph-spans))))
     (should original)
     (cl-letf (((symbol-function
                 'org-texmacs--font-lock-paragraph-spans)
                (lambda (begin end)
                  (setq
                   maximum (max maximum (- end begin))
                   calls (1+ calls))
                  (funcall original begin end)))
               ((symbol-function 'org-texmacs--worker-request)
                (lambda (&rest _)
                  (ert-fail "Fontification started a worker"))))
       (goto-char (/ (point-max) 2))
       (search-forward "VALUE")
       (insert "X")
       (font-lock-ensure (1- (point)) (point))
       (should (> calls 0))
       (should (< calls 8))
       (should (< maximum 100))))))

(ert-deftest org-texmacs-font-lock-global-default-and-font-lock-toggle
    ()
  (let ((original (default-value 'org-texmacs--font-lock-enabled)))
    (unwind-protect
        (progn
          (set-default 'org-texmacs--font-lock-enabled nil)
          (org-texmacs-test--with-font-lock
           "$(math \"GLOBAL\")$\n"
           (should-not
            (org-texmacs-test--font-lock-string-p "GLOBAL"))
           (set-default 'org-texmacs--font-lock-enabled t)
           (font-lock-ensure)
           (should (org-texmacs-test--font-lock-string-p "GLOBAL"))
           (font-lock-mode -1)
           (should-not (get-text-property 2 'syntax-table))
           (let ((noninteractive nil))
             (font-lock-mode 1))
           (font-lock-ensure)
           (should (org-texmacs-test--font-lock-string-p "GLOBAL"))
           (should-not
            (get 'org-texmacs--font-lock-enabled 'custom-type))
           (should-not (commandp 'org-texmacs--font-lock-setup))))
      (set-default 'org-texmacs--font-lock-enabled original))))

(ert-deftest org-texmacs-font-lock-restricted-block-header ()
  (org-texmacs-test--with-font-lock
   "#+begin_texmacs\n(math \"BODY\")\n#+end_texmacs\n"
   (let ((font-lock-dont-widen t))
     (goto-char (point-min))
     (narrow-to-region (point-min) (line-end-position))
     (font-lock-flush)
     (font-lock-ensure)
     (should-not
      (text-property-not-all
       (point-min) (point-max) 'org-texmacs--font-lock-owner nil)))))

;;; editing.el ends here
