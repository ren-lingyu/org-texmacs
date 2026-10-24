;;; preprocess.el --- native preprocess regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest
    org-texmacs-preprocess-source-to-native-and-owned-snapshots
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region
     "(math \"x\")(math \"x\")\n[[file:asset.txt][Asset]]\n"
     nil
     "a.org"
     nil
     'silent)
    (write-region "(math \"x\")(math \"x\")\n" nil "b.org"
                  nil
                  'silent)
    (insert
     "#+INCLUDE: \"a.org\"\n#+INCLUDE: \"b.org\"\n#+INCLUDE: \"a.org\"\n")
    (setq-local buffer-file-name (expand-file-name "root.org"))
    (let* ((source (current-buffer))
           (before (org-texmacs-test--document-buffer-state source))
           (input (org-texmacs-prepare-buffer-preprocessed source))
           (info (org-texmacs-input-info input))
           (document (org-texmacs-document input))
           (session nil))
      (should (= (length (org-texmacs-input-islands input)) 6))
      (should
       (= (length (plist-get info :texmacs-preprocessing-sources)) 2))
      (should
       (equal
        (plist-get info :texmacs-original-source) (buffer-string)))
      (should-not (plist-member info :texmacs-island-origins))
      (should
       (equal
        before (org-texmacs-test--document-buffer-state source)))
      (unwind-protect
          (progn
            (setq session (org-texmacs-session-open))
            (org-texmacs-session-set-document session document)
            (let ((native
                   (prin1-to-string
                    (org-texmacs--session-read-document session))))
              (should (string-match-p "math" native))
              (should
               (string-match-p
                (org-texmacs-test--native-hex
                 (expand-file-name "asset.txt"))
                native)))
            (should
             (string-match-p
              "TeXmacs"
              (org-texmacs-export-from-buffer-preprocessed source))))
        (when session
          (org-texmacs-session-close session)))))))

(ert-deftest org-texmacs-preprocess-bibliography-uuid-and-filters-once
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region
     "#+bibliography: refs.bib\n[cite:@managed-uuid]\n#+print_bibliography:\n"
     nil
     "part.org"
     nil
     'silent)
    (insert "#+INCLUDE: \"part.org\"\n")
    (let* ((source (current-buffer))
           (before-text (buffer-string))
           (before-calls 0)
           (after-calls 0)
           (filter-calls 0)
           (discovery-calls 0)
           (org-export-before-processing-functions
            (list (lambda (_backend) (cl-incf before-calls))))
           (org-export-before-parsing-functions
            (list (lambda (_backend) (cl-incf after-calls))))
           (org-export-filter-parse-tree-functions
            (list
             (lambda (tree backend info)
               (cl-incf filter-calls)
               (org-texmacs-test--ast-filter-remap
                tree backend info))))
           (spy
            (lambda (paths)
              (cl-incf discovery-calls)
              paths)))
      (unwind-protect
          (progn
            (advice-add
             'org-cite-list-bibliography-files
             :filter-return spy)
            (let ((document
                   (org-texmacs-document-from-buffer-preprocessed
                    source nil nil t)))
              (should
               (string-match-p
                "bib-list"
                (prin1-to-string
                 (org-texmacs-document-body document)))))
            (should (= before-calls 1))
            (should (= after-calls 1))
            (should (= filter-calls 1))
            (should (= discovery-calls 1))
            (should (equal before-text (buffer-string))))
        (advice-remove 'org-cite-list-bibliography-files spy))))))

(ert-deftest org-texmacs-preprocess-discovery-off-and-old-api-defaults
    ()
  (org-texmacs-test--with-bibliography-files
   (insert "Text\n")
   (let ((org-cite-global-bibliography '("absent.bib")))
     (cl-letf (((symbol-function 'org-cite-list-bibliography-files)
                (lambda () (ert-fail "Unexpected discovery"))))
       (should
        (org-texmacs-document-p
         (org-texmacs-document-from-buffer-preprocessed
          (current-buffer))))))
   (erase-buffer) (insert "#+INCLUDE: \"missing.org\"\n")
   (cl-letf (((symbol-function 'org-export-expand-include-keyword)
              (lambda (&rest _)
                (ert-fail "Old API expanded includes"))))
     (should-error
      (org-texmacs-document-from-buffer (current-buffer))
      :type 'org-texmacs-document-error)
     (should-error
      (org-texmacs-document-from-buffer-discover-bibliography
       (current-buffer))
      :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-preprocess-whole-file-footnotes-and-generated-stm
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region
     "Text[fn:a]\n[fn:a] Note (math \"old\")\n" nil "part.org"
     nil 'silent)
    (insert "#+INCLUDE: \"part.org\"\n")
    (let* ((org-export-before-parsing-functions
            (list
             (lambda (_backend)
               (goto-char (point-max))
               (insert "\n(math \"new\")\n"))))
           (input
            (org-texmacs-prepare-buffer-preprocessed
             (current-buffer))))
      (should (= (length (org-texmacs-input-islands input)) 2))
      (should
       (string-match-p
        "new"
        (plist-get
         (org-texmacs-input-info input)
         :texmacs-preprocessed-source)))
      (should
       (string-match-p
        "footnote"
        (prin1-to-string
         (org-texmacs-document-body
          (org-texmacs-document input)))))))))

(ert-deftest
    org-texmacs-preprocess-rejects-selection-directory-and-odd-levels
    ()
  (org-texmacs-test--with-bibliography-files
   (insert "Text\nMore\n") (narrow-to-region 1 6)
   (should-error
    (org-texmacs-prepare-buffer-preprocessed (current-buffer))
    :type 'org-texmacs-document-error)
   (widen) (setq-local buffer-file-name "/other/root.org")
   (should-error
    (org-texmacs-prepare-buffer-preprocessed (current-buffer))
    :type 'org-texmacs-document-error)
   (setq-local
    buffer-file-name nil
    org-odd-levels-only t)
   (should-error
    (org-texmacs-prepare-buffer-preprocessed (current-buffer))
    :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-preprocess-rejects-source-and-hook-mutations
    ()
  (dolist (change '(source hooks filter directory explicit))
    (org-texmacs-test--with-bibliography-files
     (insert "Text\n")
     (let* ((source (current-buffer))
            (provided
             (list
              (cons "unused.bib" (copy-sequence "@book{unused}"))))
            (org-export-filter-parse-tree-functions nil)
            (org-export-before-processing-functions
             (list
              (lambda (_backend)
                (with-current-buffer source
                  (pcase change
                    ('source (insert "Changed"))
                    ('hooks
                     (setq org-export-before-parsing-functions
                           '(ignore)))
                    ('filter
                     (setq org-export-filter-parse-tree-functions
                           '(ignore)))
                    ('directory
                     (setq-local default-directory "/different/"))
                    ('explicit (aset (cdar provided) 0 ?X)))))))
            (org-export-before-parsing-functions nil))
       (cl-letf (((symbol-function 'org-texmacs--worker-request)
                  (lambda (&rest _)
                    (ert-fail
                     "Changed source reached native worker"))))
         (should-error
          (org-texmacs-prepare-buffer-preprocessed source provided)
          :type 'org-texmacs-document-error))))))

(ert-deftest
    org-texmacs-preprocess-rejects-dependency-changes-at-native-stages
    ()
  (org-texmacs-test--with-worker
   (dolist (target
            '(org-texmacs--worker-request
              org-texmacs--bibliography-format
              org-texmacs-document-serialize))
     (org-texmacs-test--with-bibliography-files
      (write-region
       "#+bibliography: refs.bib\n[cite:@external-key]\n#+print_bibliography:\n"
       nil
       "part.org"
       nil
       'silent)
      (insert "#+INCLUDE: \"part.org\"\n")
      (let ((original (symbol-function target))
            (path (expand-file-name "part.org")))
        (cl-letf (((symbol-function target)
                   (lambda (&rest args)
                     (prog1 (apply original args)
                       (write-region "Changed\n" nil path
                                     nil
                                     'silent)))))
          (should-error
           (org-texmacs-export-from-buffer-preprocessed
            (current-buffer) nil nil t)
           :type 'org-texmacs-document-error)))))))

(ert-deftest
    org-texmacs-preprocess-bounds-aliases-and-temporary-cleanup
    ()
  (org-texmacs-test--with-bibliography-files
   (make-directory "scratch")
   (let ((temporary-file-directory (expand-file-name "scratch/")))
     (write-region (make-string 65537 ?a) nil "large.org" nil 'silent)
     (insert "#+INCLUDE: \"large.org\"\n")
     (should-error
      (org-texmacs-prepare-buffer-preprocessed (current-buffer))
      :type 'org-texmacs-document-error)
     (should
      (equal
       (directory-files temporary-file-directory nil "^[^.]") nil))
     (write-region "Disk source\n" nil "root.org" nil 'silent)
     (add-name-to-file
      (expand-file-name "root.org") (expand-file-name "alias.org"))
     (setq-local buffer-file-name (expand-file-name "root.org"))
     (erase-buffer)
     (insert "#+INCLUDE: \"alias.org\"\n")
     (should-error
      (org-texmacs-prepare-buffer-preprocessed (current-buffer))
      :type 'org-texmacs-document-error)
     (should-not
      (directory-files temporary-file-directory nil "^[^.]"))
     (setq-local buffer-file-name nil)
     (erase-buffer)
     (insert "Text\n")
     (let ((org-export-before-parsing-functions
            (list
             (lambda (_backend) (error "Controlled hook failure")))))
       (should-error
        (org-texmacs-prepare-buffer-preprocessed (current-buffer))))
     (should-not
      (directory-files temporary-file-directory nil "^[^.]")))))

(ert-deftest org-texmacs-preprocess-rejects-include-read-mutations ()
  (dolist (change '(source file))
    (org-texmacs-test--with-bibliography-files
     (write-region "Included\n" nil "part.org" nil 'silent)
     (insert "#+INCLUDE: \"part.org\"\n")
     (let* ((source (current-buffer))
            (reader
             (symbol-function 'org-texmacs--bibliography-file-bytes)))
       (cl-letf (((symbol-function
                   'org-texmacs--bibliography-file-bytes)
                  (lambda (path)
                    (prog1 (funcall reader path)
                      (if (eq change 'source)
                          (with-current-buffer source
                            (insert "Changed"))
                        (write-region "Changed\n" nil path
                                      nil
                                      'silent))))))
         (should-error
          (org-texmacs-prepare-buffer-preprocessed source)
          :type 'org-texmacs-document-error))))))

(ert-deftest org-texmacs-preprocess-budgets-and-hook-created-stm ()
  (org-texmacs-test--with-bibliography-files
   (write-region "Small\n" nil "part.org" nil 'silent)
   (insert
    (apply #'concat (make-list 32 "#+INCLUDE: \"part.org\"\n")))
   (should-error
    (org-texmacs-prepare-buffer-preprocessed (current-buffer))
    :type 'org-texmacs-document-error)
   (erase-buffer) (insert "Text\n")
   (let
       ((org-export-before-processing-functions
         (list
          (lambda (_backend)
            (goto-char (point-max))
            (insert
             "#+begin_texmacs\n#+INCLUDE: \"absent.org\"\n#+end_texmacs\n")))))
     (cl-letf (((symbol-function 'org-texmacs--worker-request)
                (lambda (&rest _) '(concat "generated"))))
       (let ((input
              (org-texmacs-prepare-buffer-preprocessed
               (current-buffer))))
         (should (= (length (org-texmacs-input-islands input)) 1))
         (should
          (string-match-p
           "absent.org"
           (plist-get
            (org-texmacs-input-info input)
            :texmacs-preprocessed-source))))))))

(ert-deftest org-texmacs-preprocess-selected-stm-native-readback ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region
     "* Alpha\n(math \"[fn:a]\")\n* Beta\nOutside\n" nil "part.org"
     nil 'silent)
    (insert "#+INCLUDE: \"part.org::*Alpha\" :only-contents t\n")
    (let* ((input
            (org-texmacs-prepare-buffer-preprocessed
             (current-buffer)))
           (text
            (plist-get
             (org-texmacs-input-info input)
             :texmacs-preprocessed-source)))
      (should (equal text "(math \"[fn:a]\")\n"))
      (should
       (string-match-p
        "math"
        (prin1-to-string
         (org-texmacs-document-body (org-texmacs-document input)))))
      (should
       (string-match-p
        "TeXmacs"
        (org-texmacs-export-from-buffer-preprocessed
         (current-buffer))))))))

(ert-deftest org-texmacs-preprocess-selected-external-footnote-stm ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region
     "Text[fn:a]\nOutside\n[fn:a] Note (math \"x\")\n" nil "part.org"
     nil 'silent)
    (insert "#+INCLUDE: \"part.org\" :lines \"1-2\"\n")
    (let* ((input
            (org-texmacs-prepare-buffer-preprocessed
             (current-buffer)))
           (text
            (plist-get
             (org-texmacs-input-info input)
             :texmacs-preprocessed-source)))
      (should-not (string-match-p "Outside" text))
      (should (string-match-p "Note (math" text))
      (should
       (string-match-p
        "footnote"
        (prin1-to-string
         (org-texmacs-document-body
          (org-texmacs-document input)))))))))

(ert-deftest
    org-texmacs-preprocess-cross-directory-native-links-and-notes
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (make-directory "parts/sub" t)
    (write-region
     "* Alpha\n#+INCLUDE: \"sub/b.org\"\n" nil "parts/a.org"
     nil 'silent)
    (write-region
     "[[file:asset.txt][Asset]] [fn:a] (math \"x\")\n[fn:a] Note\n"
     nil
     "parts/sub/b.org"
     nil
     'silent)
    (insert
     "#+INCLUDE: \"parts/a.org::*Alpha\" :only-contents t :minlevel 2\n")
    (setq-local buffer-file-name (expand-file-name "root.org"))
    (let* ((before
            (org-texmacs-test--document-buffer-state
             (current-buffer)))
           (input
            (org-texmacs-prepare-buffer-preprocessed
             (current-buffer)))
           (text
            (plist-get
             (org-texmacs-input-info input)
             :texmacs-preprocessed-source))
           (document (org-texmacs-document input)))
      (should (string-match-p "parts/sub/asset.txt" text))
      (should (string-match-p "Note" text))
      (should
       (= (length
           (plist-get
            (org-texmacs-input-info input)
            :texmacs-preprocessing-sources))
          2))
      (should
       (string-match-p
        (regexp-quote (expand-file-name "parts/sub/asset.txt"))
        (prin1-to-string
         (org-texmacs--native-document-wire document))))
      (should
       (equal
        before
        (org-texmacs-test--document-buffer-state (current-buffer))))
      (should
       (string-match-p
        "TeXmacs"
        (org-texmacs-export-from-buffer-preprocessed
         (current-buffer))))))))

(ert-deftest
    org-texmacs-preprocess-cross-directory-final-bibliography-base
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (make-directory "parts")
    (write-region "Not BibTeX\n" nil "parts/refs.bib" nil 'silent)
    (write-region
     "#+bibliography: refs.bib\n[cite:@external-key]\n#+print_bibliography:\n"
     nil
     "parts/a.org"
     nil
     'silent)
    (insert "#+INCLUDE: \"parts/a.org\"\n")
    (let* ((input
            (org-texmacs-prepare-buffer-preprocessed
             (current-buffer) nil nil t))
           (bibliography (org-texmacs-input-bibliography input)))
      (should (assoc (expand-file-name "refs.bib") bibliography))
      (should-not
       (assoc (expand-file-name "parts/refs.bib") bibliography))
      (should
       (string-match-p
        "bib-list"
        (prin1-to-string
         (org-texmacs-document-body
          (org-texmacs-document input)))))))))

(ert-deftest org-texmacs-preprocess-completed-working-buffer-context
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (make-directory "parts")
    (write-region "* Included\nText (math \"x\")\n" nil "parts/a.org"
                  nil
                  'silent)
    (insert "#+INCLUDE: \"parts/a.org\"\n")
    (let ((canonical (buffer-string))
          (directory default-directory)
          (file (expand-file-name "root.org")))
      (with-temp-buffer
        (org-mode)
        (setq
         default-directory directory
         buffer-file-name file)
        (setq-local org-export-with-toc nil)
        (insert canonical)
        (org-export-expand-include-keyword)
        (let* ((before
                (org-texmacs-test--document-buffer-state
                 (current-buffer)))
               (org-export-before-processing-functions
                (list
                 (lambda
                   (&rest _)
                   (ert-fail "Preparation replayed preprocessing"))))
               (input (org-texmacs-prepare-buffer (current-buffer))))
          (should (equal (org-texmacs-input-source-file input) file))
          (should
           (equal (org-texmacs-input-resource-base input) directory))
          (should-not
           (plist-get (org-texmacs-input-info input) :with-toc))
          (should
           (org-texmacs-document-p (org-texmacs-document input)))
          (should
           (equal
            before
            (org-texmacs-test--document-buffer-state
             (current-buffer))))))
      (should (equal canonical (buffer-string)))))))

(ert-deftest
    org-texmacs-preprocess-cross-directory-partial-stm-rejected
    ()
  (org-texmacs-test--with-bibliography-files
   (make-directory "parts")
   (write-region
    "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n" nil "parts/a.org"
    nil 'silent)
   (insert "#+INCLUDE: \"parts/a.org\" :lines \"2-3\"\n")
   (should-error
    (org-texmacs-prepare-buffer-preprocessed (current-buffer))
    :type 'org-texmacs-document-error)))

;;; preprocess.el ends here
