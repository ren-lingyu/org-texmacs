;;; bibliography.el --- native bibliography regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-bibliography-native-authority ()
  :tags
  '(issue12)
  (with-temp-buffer
    (org-mode)
    (insert "Text\n")
    (let ((source "Opaque text interpreted only by TeXmacs")
          seen)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (text &optional syntax)
                   (setq seen (list text syntax))
                   '(document
                     (bib-entry
                      "native-type" "native-key"
                      (document
                       (bib-field "native-field" "Normalized"))))))
                ((symbol-function 'find-file-noselect)
                 (lambda (&rest _)
                   (ert-fail "Explicit source opened a file"))))
        (let ((input
               (org-texmacs-prepare-buffer
                (current-buffer) (list (cons "refs.bib" source)))))
          (should (equal seen (list source 'bibliography)))
          (should-not
           (plist-get
            (org-texmacs-input-info input)
            :texmacs-bibliography-output))
          (should
           (equal
            (nth
             1 (cadr (cdar (org-texmacs-input-bibliography input))))
            "native-type")))))))

(ert-deftest org-texmacs-bibliography-source-snapshot-and-preflight ()
  (with-temp-buffer
    (org-mode)
    (setq-local default-directory "/source/base/")
    (insert "Text\n")
    (let* ((name (copy-sequence "refs.bib"))
           (text (copy-sequence "@book{key, title={Book}}"))
           (sources (list (cons name text)))
           calls)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (value &optional syntax)
                   (push (list value syntax) calls)
                   '(document
                     (bib-entry
                      "book"
                      "key"
                      (document (bib-field "title" "Book")))))))
        (let ((input
               (org-texmacs-prepare-buffer (current-buffer) sources)))
          (should (equal calls (list (list text 'bibliography))))
          (should
           (equal
            (caar (org-texmacs-input-bibliography input))
            "/source/base/refs.bib"))
          (aset text 0 ?X)
          (aset name 0 ?X)
          (should
           (equal
            (caar (org-texmacs-input-bibliography input))
            "/source/base/refs.bib"))))
      (setq calls nil)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Invalid bibliography started worker"))))
        (dolist (bad '((("a.bib" . "") ("./a.bib" . ""))))
          (should-error
           (org-texmacs-prepare-buffer (current-buffer) bad)
           :type 'org-texmacs-document-error)))
      (should (equal (buffer-string) "Text\n")))))

(ert-deftest org-texmacs-bibliography-source-rechecks-worker-waits ()
  (dolist (stage '(stm bibliography))
    (dolist (change '(text path alias list))
      (with-temp-buffer
        (org-mode)
        (insert
         (if (eq stage 'stm)
             "(math \"x\")\n"
           "Text\n"))
        (let* ((text (copy-sequence "@book{key}"))
               (path (copy-sequence "refs.bib"))
               (sources (list (cons path text))))
          (cl-letf (((symbol-function 'org-texmacs--worker-request)
                     (lambda (_source &optional syntax)
                       (when (eq
                              syntax
                              (and (eq stage 'bibliography)
                                   'bibliography))
                         (pcase change
                           ('text (aset text 0 ?X))
                           ('path (aset path 0 ?X))
                           ('alias
                            (setcar (car sources) "./refs.bib"))
                           ('list
                            (setcdr
                             sources
                             (list
                              (cons "other.bib" "@book{other}"))))))
                       (if syntax
                           '(document
                             (bib-entry "book" "key" (document)))
                         '(math "x")))))
            (should-error
             (org-texmacs-prepare-buffer (current-buffer) sources)
             :type 'org-texmacs-document-error)))))))

(ert-deftest
    org-texmacs-bibliography-preparation-retains-lowering-boundary
    ()
  (dolist (source
           '("[cite:@key]\n"
             "#+bibliography: missing.bib\n"
             "#+print_bibliography: :unsupported t\n"))
    (with-temp-buffer
      (org-mode)
      (insert source)
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (ert-fail "Unsupported citation started worker"))))
        (should-error
         (org-texmacs-prepare-buffer
          (current-buffer) '(("refs.bib" . "@book{key}")))
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-bibliography-invalid-native-payload-stops-worker
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Text\n")
    (dolist (response
             '((concat "wrong")
               (document (bib-entry "book" "key"))
               (document
                (bib-entry
                 "book" "key" (document (bib-field "broken"))))))
      (let (stopped)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (&rest _) response))
                  ((symbol-function 'org-texmacs--worker-stop)
                   (lambda () (setq stopped t))))
          (should-error
           (org-texmacs-prepare-buffer
            (current-buffer) '(("refs.bib" . "@book{key}")))
           :type 'org-texmacs-worker-error)
          (should stopped))))))

(ert-deftest org-texmacs-bibliography-native-parsing-and-worker-reuse
    ()
  (org-texmacs-test--with-worker
   (let (input)
     (with-temp-buffer
       (org-mode)
       (insert "Text\n")
       (setq
        input
        (org-texmacs-prepare-buffer
         (current-buffer)
         '(("refs.bib"
            .
            "% Comment\n  @Book{key, Title={中 <alpha>}, year=2026}")
           ("empty.bib" . "")))))
     (let* ((raw (cdar (org-texmacs-input-bibliography input)))
            (parsed
             (cons
              'document
              (cl-remove-if-not
               (lambda (node)
                 (and (consp node) (eq (car node) 'bib-entry)))
               (cdr raw))))
            (process org-texmacs--worker-process))
       (should
        (cl-find-if
         (lambda (node)
           (and (consp node) (eq (car node) 'bib-comment)))
         (cdr raw)))
       (should
        (equal
         parsed
         '(document
           (bib-entry
            "book" "key"
            (document
             (bib-field "title" "<#4E2D> <less>alpha<gtr>")
             (bib-field "year" "2026"))))))
       (should
        (equal
         (org-texmacs--worker-request "(math \"x\")") '(math "x")))
       (should (eq process org-texmacs--worker-process))
       (should
        (equal
         (cdr
          (nth 1 (org-texmacs-input-bibliography input)))
         '(document)))
       (should
        (equal
         (org-texmacs-document-body
          (org-texmacs-document input))
         '(document (concat "Text "))))))))

(ert-deftest org-texmacs-bibliography-auto-default-api-is-explicit ()
  (with-temp-buffer
    (org-mode)
    (insert "Text\n")
    (cl-letf (((symbol-function 'org-cite-list-bibliography-files)
               (lambda () (ert-fail "Old API discovered files")))
              ((symbol-function 'org-texmacs--bibliography-file-bytes)
               (lambda (&rest _) (ert-fail "Old API read files"))))
      (should
       (org-texmacs-document-p
        (org-texmacs-document-from-buffer (current-buffer)))))))

(ert-deftest org-texmacs-bibliography-auto-source-to-native ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (insert "[cite:@managed-uuid]\n#+print_bibliography:\n")
    (setq-local buffer-file-name (expand-file-name "unsaved.org"))
    (let* ((source (current-buffer))
           (before (org-texmacs-test--document-buffer-state source))
           (calls 0)
           (filters 0)
           (org-cite-global-bibliography '("refs.bib" "./refs.bib"))
           (org-export-filter-parse-tree-functions
            (list
             (lambda (tree backend info)
               (cl-incf filters)
               (should
                (equal
                 (plist-get info :bibliography)
                 (list (expand-file-name "refs.bib"))))
               (org-texmacs-test--ast-filter-remap
                tree backend info))))
           (spy
            (lambda (paths)
              (cl-incf calls)
              paths))
           (session nil))
      (unwind-protect
          (progn
            (advice-add
             'org-cite-list-bibliography-files
             :filter-return spy)
            (let
                ((document
                  (org-texmacs-document-from-buffer-discover-bibliography
                   source)))
              (should (= calls 1))
              (should (= filters 1))
              (setq session (org-texmacs-session-open))
              (org-texmacs-session-set-document session document)
              (let ((native
                     (org-texmacs--session-read-document session)))
                (should
                 (string-match-p
                  (org-texmacs-test--native-hex
                   "external-key")
                  (prin1-to-string native)))
                (should
                 (string-match-p
                  "bib-list" (prin1-to-string native)))))
            (setq
             calls 0
             filters 0)
            (let
                ((bytes
                  (org-texmacs-export-from-buffer-discover-bibliography
                   source)))
              (should-not (multibyte-string-p bytes))
              (should (string-match-p "external-key" bytes))
              (should (= calls 1))
              (should (= filters 1)))
            (should
             (equal
              before
              (org-texmacs-test--document-buffer-state source))))
        (advice-remove 'org-cite-list-bibliography-files spy)
        (when session
          (org-texmacs-session-close session)))))))

(ert-deftest
    org-texmacs-bibliography-auto-explicit-priority-with-advice
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (insert "[cite:@external-key]\n#+print_bibliography:\n")
    (let ((org-cite-global-bibliography nil)
          (spy (lambda (_paths) '("absent.bib" "./absent.bib"))))
      (unwind-protect
          (progn
            (advice-add
             'org-cite-list-bibliography-files
             :filter-return spy)
            (cl-letf (((symbol-function
                        'org-texmacs--bibliography-file-attributes)
                       (lambda (&rest _)
                         (ert-fail "Explicit identity was statted"))))
              (should
               (org-texmacs-document-p
                (org-texmacs-document-from-buffer-discover-bibliography
                 (current-buffer)
                 '(("absent.bib"
                    .
                    "@book{external-key, title={Owned}}")
                   ("unused.bib" . "@book{unused}")))))))
        (advice-remove 'org-cite-list-bibliography-files spy))))))

(ert-deftest
    org-texmacs-bibliography-auto-rejects-preprocessing-and-conflict
    ()
  (org-texmacs-test--with-bibliography-files
   (dolist (directive
            '("#+SETUPFILE: absent.org\n"
              "#+INCLUDE: absent.org\n"
              "#+BIND: org-cite-global-bibliography nil\n"
              "#+MACRO: x text\n"
              "#+CITE_EXPORT: csl\n"))
     (erase-buffer)
     (insert directive)
     (let ((org-export-allow-bind-keywords t))
       (cl-letf (((symbol-function 'org-cite-list-bibliography-files)
                  (lambda ()
                    (ert-fail
                     "Unsupported directive reached discovery"))))
         (should-error
          (org-texmacs-document-from-buffer-discover-bibliography
           (current-buffer))
          :type 'org-texmacs-document-error))))
   (erase-buffer)
   (insert "Text\n")
   (setq-local buffer-file-name "/different/source.org")
   (should-error
    (org-texmacs-document-from-buffer-discover-bibliography
     (current-buffer))
    :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-bibliography-auto-masks-outside-restriction
    ()
  (org-texmacs-test--with-bibliography-files
   (insert
    "Text\n#+begin_texmacs\n#+bibliography: missing.bib\n"
    "#+SETUPFILE: absent.org\n#+end_texmacs\n")
   (narrow-to-region 1 6)
   (let ((org-cite-global-bibliography nil)
         (before
          (org-texmacs-test--document-buffer-state (current-buffer))))
     (cl-letf (((symbol-function 'org-file-contents)
                (lambda (&rest _)
                  (ert-fail "Excluded STM triggered reads"))))
       (should
        (org-texmacs-document-p
         (org-texmacs-document-from-buffer-discover-bibliography
          (current-buffer)))))
     (should
      (equal
       before
       (org-texmacs-test--document-buffer-state (current-buffer)))))))

(ert-deftest org-texmacs-bibliography-auto-rejects-discovery-mutations
    ()
  (dolist (change
           '(source
             globals filters explicit directory options collector))
    (org-texmacs-test--with-bibliography-files
     (insert "Text\n")
     (let* ((source (current-buffer))
            (org-cite-global-bibliography nil)
            (org-export-filter-parse-tree-functions nil)
            (provided
             (list (cons "refs.bib" (copy-sequence "@book{key}"))))
            (calls 0)
            private
            (collector
             (symbol-function 'org-cite-list-bibliography-files)))
       (unwind-protect
           (cl-letf (((symbol-function
                       'org-cite-list-bibliography-files)
                      (lambda ()
                        (cl-incf calls)
                        (setq private (current-buffer))
                        (with-current-buffer source
                          (pcase change
                            ('source (insert "Changed"))
                            ('globals
                             (setq org-cite-global-bibliography
                                   '("other.bib")))
                            ('filters
                             (setq
                              org-export-filter-parse-tree-functions
                              '(ignore)))
                            ('explicit (aset (cdar provided) 0 ?X))
                            ('directory
                             (setq-local default-directory
                                         "/different/"))
                            ('options
                             (setq-local org-export-with-toc
                                         (not org-export-with-toc)))
                            ('collector
                             (fset 'org-cite-list-bibliography-files
                                   #'ignore))))
                        '("refs.bib")))
                     ((symbol-function 'org-texmacs--worker-request)
                      (lambda (&rest _)
                        (ert-fail
                         "Changed discovery reached native worker"))))
             (should-error
              (org-texmacs-document-from-buffer-discover-bibliography
               source provided)
              :type 'org-texmacs-document-error)
             (should (= calls 1))
             (should-not (buffer-live-p private)))
         (fset 'org-cite-list-bibliography-files collector))))))

(ert-deftest
    org-texmacs-bibliography-auto-rejects-acquisition-mutations
    ()
  (dolist (change '(source file))
    (org-texmacs-test--with-bibliography-files
     (insert "Text\n")
     (let* ((source (current-buffer))
            (org-cite-global-bibliography '("refs.bib"))
            (reader
             (symbol-function 'org-texmacs--bibliography-file-bytes)))
       (cl-letf (((symbol-function
                   'org-texmacs--bibliography-file-bytes)
                  (lambda (path)
                    (prog1 (funcall reader path)
                      (if (eq change 'source)
                          (with-current-buffer source
                            (insert "Changed"))
                        (write-region "@book{changed}" nil path
                                      nil
                                      'silent)))))
                 ((symbol-function 'org-texmacs--worker-request)
                  (lambda (&rest _)
                    (ert-fail
                     "Changed acquisition reached native worker"))))
         (should-error
          (org-texmacs-document-from-buffer-discover-bibliography
           source)
          :type 'org-texmacs-document-error))))))

(ert-deftest
    org-texmacs-bibliography-auto-rejects-native-wait-mutations
    ()
  (dolist (change '(file source globals filters explicit))
    (org-texmacs-test--with-bibliography-files
     (insert "(math \"x\")\n")
     (let* ((source (current-buffer))
            (org-cite-global-bibliography '("refs.bib"))
            (org-export-filter-parse-tree-functions nil)
            (path (expand-file-name "refs.bib"))
            (calls 0)
            (provided
             (list
              (cons "unused.bib" (copy-sequence "@book{unused}")))))
       (cl-letf (((symbol-function 'org-texmacs--worker-request)
                  (lambda (&rest _)
                    (cl-incf calls)
                    (with-current-buffer source
                      (pcase change
                        ('file
                         (write-region "@book{changed}" nil path
                                       nil
                                       'silent))
                        ('source (insert "Changed"))
                        ('globals
                         (setq org-cite-global-bibliography nil))
                        ('filters
                         (setq org-export-filter-parse-tree-functions
                               '(ignore)))
                        ('explicit (aset (cdar provided) 0 ?X))))
                    '(math "x"))))
         (should-error
          (org-texmacs-document-from-buffer-discover-bibliography
           source provided)
          :type 'org-texmacs-document-error)
         (should (= calls 1)))))))

(ert-deftest org-texmacs-bibliography-auto-rejects-before-byte-return
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (insert "Text\n")
    (let ((org-cite-global-bibliography '("refs.bib"))
          (path (expand-file-name "refs.bib")))
      (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                 (lambda (_document)
                   (write-region "@book{changed}" nil path
                                 nil
                                 'silent)
                   "unpublished")))
        (should-error
         (org-texmacs-export-from-buffer-discover-bibliography
          (current-buffer))
         :type 'org-texmacs-document-error))))))

(ert-deftest
    org-texmacs-bibliography-auto-rejects-native-dependency-stages
    ()
  (org-texmacs-test--with-worker
   (dolist (target
            '(org-texmacs--worker-request
              org-texmacs--bibliography-format org-texmacs-document))
     (org-texmacs-test--with-bibliography-files
      (insert "[cite:@managed-uuid]\n#+print_bibliography:\n")
      (let* ((org-cite-global-bibliography '("refs.bib"))
             (path (expand-file-name "refs.bib"))
             (discovery-calls 0)
             (filter-calls 0)
             (org-export-filter-parse-tree-functions
              (list
               (lambda (tree backend info)
                 (cl-incf filter-calls)
                 (org-texmacs-test--ast-filter-remap
                  tree backend info))))
             (original (symbol-function target))
             (spy
              (lambda (paths)
                (cl-incf discovery-calls)
                paths)))
        (unwind-protect
            (progn
              (advice-add
               'org-cite-list-bibliography-files
               :filter-return spy)
              (cl-letf (((symbol-function target)
                         (lambda (&rest args)
                           (prog1 (apply original args)
                             (write-region "@book{changed}" nil path
                                           nil
                                           'silent)))))
                (should-error
                 (org-texmacs-document-from-buffer-discover-bibliography
                  (current-buffer))
                 :type 'org-texmacs-document-error))
              (should (= discovery-calls 1))
              (should (= filter-calls 1)))
          (advice-remove 'org-cite-list-bibliography-files spy)))))))

(ert-deftest org-texmacs-bibliography-issue12-native-constructs ()
  :tags
  '(issue12)
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+bibliography: refs.bib\n[cite:@key]\n#+print_bibliography:\n")
     (let*
         ((source
           "@string{word={Native}}\n@preamble{\"Unused preamble\"}\n@online{key, title=word # { Title}, year=2026}\n")
          (input
           (org-texmacs-prepare-buffer
            (current-buffer) (list (cons "refs.bib" source))))
          (document (org-texmacs-document input)))
       (should
        (string-match-p
         "Native"
         (prin1-to-string (org-texmacs-document-body document))))
       (should
        (string-match-p
         "Title"
         (prin1-to-string (org-texmacs-document-body document))))
       (should (org-texmacs--worker-live-p))))))

(ert-deftest org-texmacs-bibliography-issue12-used-key-boundary ()
  :tags
  '(issue12)
  (dolist (entries
           '((document)
             (document (bib-comment "Only metadata"))
             (document
              (bib-entry "book" "key" (document))
              (bib-entry "misc" "key" (document)))))
    (with-temp-buffer
      (org-mode)
      (insert
       "#+bibliography: refs.bib\n[cite:@key]\n(math \"x\")\n#+print_bibliography:\n")
      (let (calls)
        (cl-letf (((symbol-function 'org-texmacs--worker-request)
                   (lambda (_text &optional syntax)
                     (push syntax calls)
                     entries))
                  ((symbol-function 'org-texmacs--worker-stop)
                   (lambda ()
                     (ert-fail
                      "Key resolution stopped healthy worker")))
                  ((symbol-function 'org-texmacs--bibliography-format)
                   (lambda (&rest _)
                     (ert-fail "Unresolved key reached formatter"))))
          (should-error
           (org-texmacs-prepare-buffer
            (current-buffer) '(("refs.bib" . "Native input")))
           :type 'org-texmacs-document-error)
          (should (equal calls '(bibliography)))))))
  (org-texmacs-test--with-worker
   (dolist (body '("Text\n" "[cite:@other]\n#+print_bibliography:\n"))
     (with-temp-buffer
       (org-mode)
       (insert "#+bibliography: refs.bib\n" body)
       (should
        (org-texmacs-input-p
         (org-texmacs-prepare-buffer
          (current-buffer)
          '(("refs.bib"
             .
             "@book{key,title={A}}\n@book{key,title={B}}\n@book{other,title={Other}}")))))))))

(ert-deftest
    org-texmacs-bibliography-issue12-declared-source-ambiguity
    ()
  :tags
  '(issue12)
  (org-texmacs-test--with-worker
   (dolist (declared '(nil t))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+bibliography: a.bib\n"
        (if declared
            "#+bibliography: b.bib\n"
          "")
        "[cite:@key]\n#+print_bibliography:\n")
       (let ((sources
              '(("a.bib" . "@book{key,title={A}}")
                ("b.bib" . "@book{key,title={B}}"))))
         (if declared
             (should-error
              (org-texmacs-prepare-buffer (current-buffer) sources)
              :type 'org-texmacs-document-error)
           (should
            (org-texmacs-input-p
             (org-texmacs-prepare-buffer
              (current-buffer) sources)))))))))

(ert-deftest
    org-texmacs-bibliography-issue12-native-reference-boundary
    ()
  :tags
  '(issue12)
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (let
         ((source
           "@book{child,title={ChildTitle},crossref={parent}}\n@book{parent,title={ParentTitle}}"))
       (insert
        "#+bibliography: refs.bib\n[cite:@child]\n#+print_bibliography:\n")
       (should-error
        (org-texmacs-prepare-buffer
         (current-buffer) (list (cons "refs.bib" source)))
        :type 'org-texmacs-document-error)
       (should (org-texmacs--worker-live-p))
       (goto-char (point-min))
       (search-forward "@child")
       (insert "; @parent")
       (let* ((input
               (org-texmacs-prepare-buffer
                (current-buffer) (list (cons "refs.bib" source))))
              (document (org-texmacs-document input)))
         (should
          (equal
           (car
            (car (last (org-texmacs-document-body document))))
           'with-bib))
         (should
          (string-match-p
           "(cite \"parent\")"
           (prin1-to-string (org-texmacs-document-body document))))
         (cl-letf (((symbol-function 'org-texmacs--worker-request)
                    (lambda (&rest _)
                      (ert-fail "Pure lowering invoked parser")))
                   ((symbol-function 'insert-file-contents)
                    (lambda (&rest _)
                      (ert-fail "Pure lowering read dependency"))))
           (should
            (equal document (org-texmacs-document input)))))))))

(ert-deftest
    org-texmacs-bibliography-issue12-native-recovery-and-isolation
    ()
  :tags
  '(issue12)
  (org-texmacs-test--with-worker
   (let* ((defined
           (org-texmacs--worker-request
            "@string{word={Defined}}\n@book{key,title=word}"
            'bibliography))
          (undefined
           (org-texmacs--worker-request
            "@book{key,title=word}" 'bibliography))
          (recovered
           (org-texmacs--worker-request
            "@book{key,title={Recovered" 'bibliography)))
     (should (string-match-p "Defined" (prin1-to-string defined)))
     (should-not
      (string-match-p "Defined" (prin1-to-string undefined)))
     (should (string-match-p "Recovered" (prin1-to-string recovered)))
     (should
      (equal
       (org-texmacs--worker-request "(math \"x\")") '(math "x"))))))

(ert-deftest org-texmacs-bibliography-issue12-discovered-native-input
    ()
  :tags
  '(issue12)
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-bibliography-files
    (write-region
     "@string{word={Discovered}}\n@online{key,title=word # { Title}}"
     nil
     "refs.bib"
     nil
     'silent)
    (insert "[cite:@key]\n#+print_bibliography:\n")
    (let ((org-cite-global-bibliography '("refs.bib")))
      (should
       (string-match-p
        "Discovered"
        (prin1-to-string
         (org-texmacs-document-body
          (org-texmacs-document-from-buffer-discover-bibliography
           (current-buffer))))))))))

(ert-deftest
    org-texmacs-bibliography-issue12-metadata-owned-after-worker-wait
    ()
  :tags
  '(issue12)
  (with-temp-buffer
    (org-mode)
    (insert "Text\n(math \"x\")\n")
    (let* ((metadata (copy-sequence "Metadata"))
           (tree
            (list
             'document (list 'bib-comment metadata)
             '(bib-entry
               "online" "key"
               (document (bib-field "title" "Native")))))
           (parse-count 0))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (_text &optional syntax)
                   (if syntax
                       (progn
                         (cl-incf parse-count)
                         tree)
                     (aset metadata 0 ?X)
                     '(math "x")))))
        (let ((input
               (org-texmacs-prepare-buffer
                (current-buffer)
                '(("refs.bib" . "Opaque native input")))))
          (should (= parse-count 1))
          (should
           (equal
            (cadr
             (cadr (cdar (org-texmacs-input-bibliography input))))
            "Metadata")))))))

(ert-deftest org-texmacs-bibliography-issue12-native-failure-recovery
    ()
  :tags
  '(issue12)
  (org-texmacs-test--with-worker
   (let ((script
          (expand-file-name "native-failure.scm" test-directory)))
     (with-temp-file script
       (insert
        (format "(load %s)\n"
                (org-texmacs--scheme-string
                 org-texmacs--worker-scheme-file))
        "(use-modules (convert bibtex bibtextm))\n"
        "(define native-parser parse-bibtex-snippet)\n"
        "(set! parse-bibtex-snippet (lambda (text)\n"
        "  (if (equal? text \"ForceNativeError\") (error \"Controlled native failure\")\n"
        "      (native-parser text))))\n"))
     (let ((org-texmacs--worker-scheme-file script))
       (with-temp-buffer
         (org-mode)
         (insert "Text\n")
         (let ((before
                (org-texmacs-test--document-buffer-state
                 (current-buffer))))
           (should-error
            (org-texmacs-prepare-buffer
             (current-buffer) '(("refs.bib" . "ForceNativeError")))
            :type 'org-texmacs-parse-error)
           (should (org-texmacs--worker-live-p))
           (let ((process org-texmacs--worker-process))
             (should
              (org-texmacs-input-p
               (org-texmacs-prepare-buffer
                (current-buffer)
                '(("refs.bib" . "@book{key,title={Recovered}}")))))
             (should (eq process org-texmacs--worker-process)))
           (should
            (equal
             before
             (org-texmacs-test--document-buffer-state
              (current-buffer))))))))))

(ert-deftest org-texmacs-bibliography-issue12-native-behavior-controls
    ()
  :tags
  '(issue12)
  (org-texmacs-test--with-worker
   (dolist
       (case
        '(("@string{word={StringTitle}}\n@book{key,title=word}"
           "book"
           "StringTitle")
          ("@book{key,title={Concat} # {Title}}" "book" "ConcatTitle")
          ("@preamble{\"UnusedPreamble\"}\n@book{key,title={BookTitle}}"
           "book"
           "BookTitle")
          ("@online{key,title={OnlineTitle}}" "online" "OnlineTitle")
          ("@unknown{key,title={UnknownTitle}}"
           "unknown"
           "UnknownTitle")
          ("@book{key,title=UNDEFINED}" "book" "UNDEFINED")))
     (let* ((tree
             (org-texmacs--worker-request (car case) 'bibliography))
            (entry
             (cl-find-if
              (lambda (node)
                (and (consp node) (eq (car node) 'bib-entry)))
              (cdr tree))))
       (should (equal (nth 1 entry) (nth 1 case)))
       (should (equal (nth 2 (cadr (nth 3 entry))) (nth 2 case)))
       (should-not
        (string-match-p "UnusedPreamble" (prin1-to-string tree)))))
   (with-temp-buffer
     (org-mode)
     (insert
      "#+bibliography: refs.bib\n[cite:@key]\n#+print_bibliography:\n")
     (let*
         ((input
           (org-texmacs-prepare-buffer
            (current-buffer)
            '(("refs.bib"
               .
               "@book{key,title={FirstFieldSentinel},TITLE={SecondFieldSentinel},xdata={missing},related={missing},entryset={missing}}"))))
          (entry
           (cl-find-if
            (lambda (node)
              (and (consp node) (eq (car node) 'bib-entry)))
            (cdr (cdar (org-texmacs-input-bibliography input)))))
          (body
           (prin1-to-string
            (org-texmacs-document-body
             (org-texmacs-document input)))))
       (should (= 5 (length (cdr (nth 3 entry)))))
       (should (string-match-p "FirstFieldSentinel" body))
       (should-not (string-match-p "SecondFieldSentinel" body))))))

;;; bibliography.el ends here
