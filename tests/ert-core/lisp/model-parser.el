;;; model-parser.el --- Whole-source model parsing regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Test discovery, preservation and snapshot guards with controlled STM parsing.

;;; Code:

(require 'org-texmacs-parse)

(ert-deftest org-texmacs-model-parse-complete-source-without-export ()
  (with-temp-buffer
    (org-mode)
    (insert
     "#+TITLE: Original\n#+INCLUDE: \"missing.org\"\n"
     "#+SETUPFILE: missing.setup\n#+BIBLIOGRAPHY: absent.bib\n"
     "#+MACRO: example unused\n# Keep this comment\n\n"
     "* COMMENT Hidden :noexport:\n"
     ":PROPERTIES:\n:CUSTOM_PROPERTY: kept\n:END:\n"
     "- [ ] A task\n\n"
     "#+begin_unknown\nOrdinary Org.\n#+end_unknown\n\n"
     "* Visible\nSelected text.\n\n[fn:unused] Retained definition.\n")
    (goto-char (point-min))
    (search-forward "Selected")
    (set-mark (point))
    (narrow-to-region (line-beginning-position) (line-end-position))
    (let ((state
           (org-texmacs-test--document-buffer-state (current-buffer)))
          (org-mode-hook
           (list (lambda () (ert-fail "Ran private mode hook"))))
          model)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "No islands need a worker")))
                ((symbol-function 'org-texmacs--document-lower)
                 (lambda (&rest _) (ert-fail "Ran lowering")))
                ((symbol-function 'org-texmacs--context-prepare)
                 (lambda (&rest _) (ert-fail "Ran export context")))
                ((symbol-function 'org-export-expand-include-keyword)
                 (lambda (&rest _) (ert-fail "Expanded INCLUDE"))))
        (setq model (org-texmacs-parse-buffer (current-buffer))))
      (should
       (equal
        state
        (org-texmacs-test--document-buffer-state (current-buffer))))
      (let ((ast (org-texmacs-model-ast model)))
        (should
         (= (length (org-element-map ast 'headline #'identity)) 2))
        (dolist (type
                 '(comment
                   property-drawer
                   node-property
                   item
                   special-block
                   footnote-definition))
          (should (org-element-map ast type #'identity nil t)))
        (should
         (= (length (org-element-map ast 'keyword #'identity)) 5))
        (should-not (org-texmacs-model-islands model))))))

(ert-deftest org-texmacs-model-parse-blocks-inline-and-unused-notes ()
  (let (model
        calls)
    (with-temp-buffer
      (org-mode)
      (insert
       "Before (math (frac \"1\" \"2\")).\n\n"
       "A[fn::Inside (math \"note\")].\n\n"
       "#+NAME: raw\n#+CAPTION: Caption (math \"ordinary\")\n"
       "#+begin_TeXmAcS extra parameters\n"
       "(math \"raw\n * not a headline\n#+INCLUDE: not-read.org\")\n"
       "#+end_TeXmAcS\n\n"
       "[fn:unused] Another (math \"unused\").\n")
      (let ((state
             (org-texmacs-test--document-buffer-state
              (current-buffer))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (raw &optional _syntax)
                     (push raw calls)
                     (read raw))))
          (setq model (org-texmacs-parse-buffer (current-buffer))))
        (should
         (equal
          state
          (org-texmacs-test--document-buffer-state
           (current-buffer))))))
    (should (= (length calls) 4))
    (should
     (equal
      (mapcar #'cdr (org-texmacs-model-islands model))
      '((math (frac "1" "2"))
        (math "note")
        (math "raw\n * not a headline\n#+INCLUDE: not-read.org")
        (math "unused"))))
    (let* ((ast (org-texmacs-model-ast model))
           (block
            (org-element-map ast 'special-block #'identity nil t)))
      (should-not (org-element-map ast 'headline #'identity))
      (should (equal (org-element-property :name block) "raw"))
      (should
       (equal
        (org-element-property :parameters block) "extra parameters"))
      (should-not (org-element-contents block))
      (should (assq block (org-texmacs-model-islands model)))
      (should (org-element-property :caption block))
      (should
       (org-element-map ast 'footnote-definition #'identity nil t)))))

(ert-deftest org-texmacs-model-parse-block-boundaries-follow-org ()
  (dolist (kind '("texmacs" "equation" "equation*"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_"
       kind
       "\n\"first\n"
       "* Actual headline\nlast\"\n#+end_"
       kind
       "\n")
      (let ((state
             (org-texmacs-test--document-buffer-state
              (current-buffer))))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _)
                     (ert-fail
                      "An incomplete Org block is not an island"))))
          (let* ((model (org-texmacs-parse-buffer (current-buffer)))
                 (ast (org-texmacs-model-ast model))
                 (headlines
                  (org-element-map ast 'headline #'identity))
                 (text (org-element-interpret-data ast)))
            (should-not (org-texmacs-model-islands model))
            (should-not
             (org-element-map ast 'special-block #'identity))
            (should (= (length headlines) 1))
            (should
             (equal
              (org-element-property
               :raw-value (car headlines))
              "Actual headline"))
            (dolist (literal
                     (list
                      (concat "#+begin_" kind)
                      "\"first"
                      "last\""
                      (concat "#+end_" kind)))
              (should (string-match-p (regexp-quote literal) text)))))
        (should
         (equal
          state
          (org-texmacs-test--document-buffer-state
           (current-buffer))))))))

(ert-deftest
    org-texmacs-model-parse-recognition-and-preservation-are-separate
    ()
  (with-temp-buffer
    (org-mode)
    (insert
     "* Heading (math \"title\")\n"
     "*bold (math \"emphasis\")* and =(math code)=.\n\n"
     "| Cell (math \"cell\") |\n\n"
     "#+CAPTION: Caption (math \"caption\")\n| Data |\n\n"
     "#+begin_src scheme\n(math \"code\")\n#+end_src\n\n"
     "Plain (math \"recognized\").\n")
    (let (calls)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (raw &optional _syntax)
                   (push raw calls)
                   (read raw))))
        (let ((model (org-texmacs-parse-buffer (current-buffer))))
          (should (equal calls '("(math \"recognized\")")))
          (dolist (type '(headline bold verbatim table src-block))
            (should
             (org-element-map
              (org-texmacs-model-ast model) type #'identity nil t)))
          (should
           (= (length (org-texmacs-model-islands model)) 1)))))))

(ert-deftest org-texmacs-model-parse-effective-heading-and-link-syntax
    ()
  (let ((org-link-parameters
         (cons '("model-test" :follow ignore) org-link-parameters)))
    (with-temp-buffer
      (org-mode)
      (setq-local org-todo-regexp "\\(READY\\|FINISHED\\)")
      (setq-local org-done-keywords '("FINISHED"))
      (setq-local org-odd-levels-only t)
      (setq-local org-link-abbrev-alist-local
                  '(("local" . "model-test:%s")))
      (insert
       "*** FINISHED Heading\n[[local:item][Link]] (math \"x\").\n")
      (let ((regexes
             (list
              org-link-types-re
              org-link-plain-re
              org-element--object-regexp))
            model)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_raw &optional _syntax) '(math "x"))))
          (setq model (org-texmacs-parse-buffer (current-buffer))))
        (let* ((ast (org-texmacs-model-ast model))
               (heading
                (org-element-map ast 'headline #'identity nil t))
               (link (org-element-map ast 'link #'identity nil t))
               (context (org-texmacs-model-context model)))
          (should (= (org-element-property :level heading) 2))
          (should
           (eq (org-element-property :todo-type heading) 'done))
          (should
           (equal
            (org-element-property :todo-keyword heading) "FINISHED"))
          (should
           (equal (org-element-property :type link) "model-test"))
          (should (equal (org-element-property :path link) "item"))
          (should
           (assoc
            'org-todo-regexp (plist-get context :heading-settings)))
          (should
           (member
            "model-test"
            (plist-get (plist-get context :link-settings) :types))))
        (should
         (equal
          regexes
          (list
           org-link-types-re
           org-link-plain-re
           org-element--object-regexp)))))))

(ert-deftest
    org-texmacs-model-parse-guards-source-and-syntax-across-waits
    ()
  (dolist (change
           '(text mode bounds file directory tags headings links))
    (with-temp-buffer
      (org-mode)
      (insert "(math \"x\")\n")
      (let ((source (current-buffer)))
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_raw &optional _syntax)
                     (with-current-buffer source
                       (pcase change
                         ('text
                          (goto-char (point-max))
                          (insert "Changed"))
                         ('mode (setq major-mode 'text-mode))
                         ('bounds (narrow-to-region 1 2))
                         ('file
                          (setq buffer-file-name
                                "/tmp/model-changed.org"))
                         ('directory (setq default-directory "/tmp/"))
                         ('tags
                          (setq-local org-texmacs-fragment-tags nil))
                         ('headings
                          (setq-local org-odd-levels-only
                                      (not org-odd-levels-only)))
                         ('links
                          (setq-local
                           org-link-abbrev-alist-local
                           '(("changed"
                              .
                              "https://example.org/%s"))))))
                     '(math "x"))))
          (should-error
           (org-texmacs-parse-buffer source)
           :type 'org-texmacs-model-error))
        (setq buffer-file-name nil)))))

(ert-deftest org-texmacs-model-parse-ignores-export-only-settings ()
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")\n")
    (let ((source (current-buffer)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_raw &optional _syntax)
                   (with-current-buffer source
                     (setq-local org-export-with-toc
                                 (not org-export-with-toc)))
                   '(math "x"))))
        (should
         (org-texmacs-model-p (org-texmacs-parse-buffer source)))))))

(ert-deftest org-texmacs-model-parse-rejects-killed-source ()
  (let ((source (generate-new-buffer " *model-source-lifetime*")))
    (unwind-protect
        (progn
          (with-current-buffer source
            (org-mode)
            (insert "(math \"x\")\n"))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (&rest _)
                       (kill-buffer source)
                       '(math "x"))))
            (should-error
             (org-texmacs-parse-buffer source)
             :type 'org-texmacs-model-error)))
      (when (buffer-live-p source)
        (kill-buffer source)))))

(ert-deftest
    org-texmacs-model-parse-validates-source-and-native-results
    ()
  (dolist (source
           (list nil "text" (generate-new-buffer " *model-non-org*")))
    (unwind-protect
        (should-error
         (org-texmacs-parse-buffer source)
         :type 'org-texmacs-model-error)
      (when (bufferp source)
        (kill-buffer source))))
  (with-temp-buffer
    (org-mode)
    (insert "(math \"x\")\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) '(frac "1" "2"))))
      (should-error
       (org-texmacs-parse-buffer (current-buffer))
       :type 'org-texmacs-parse-error))
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (signal 'org-texmacs-parse-error '("Invalid")))))
      (should-error
       (org-texmacs-parse-buffer (current-buffer))
       :type 'org-texmacs-parse-error))))

(ert-deftest
    org-texmacs-model-parse-checks-source-after-private-preparation
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Ordinary text.\n")
    (let ((source (current-buffer))
          (prepare (symbol-function 'org-texmacs--parse-prepare)))
      (cl-letf (((symbol-function 'org-texmacs--parse-prepare)
                 (lambda (&rest arguments)
                   (prog1 (apply prepare arguments)
                     (with-current-buffer source
                       (insert "Changed"))))))
        (should-error
         (org-texmacs-parse-buffer source)
         :type 'org-texmacs-model-error)))))

(ert-deftest
    org-texmacs-model-parse-raw-block-parameters-are-not-target-policy
    ()
  (dolist (kind '("texmacs" "equation" "equation*"))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+begin_"
       kind
       " retained parameter\n\"atom\"\n#+end_"
       kind
       "\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (raw &optional _syntax) (read raw))))
        (let* ((model (org-texmacs-parse-buffer (current-buffer)))
               (entry (car (org-texmacs-model-islands model))))
          (should (equal (cdr entry) "atom"))
          (should
           (equal
            (org-element-property
             :parameters (car entry))
            "retained parameter"))
          (should-not (org-element-contents (car entry))))))))

;;; model-parser.el ends here
