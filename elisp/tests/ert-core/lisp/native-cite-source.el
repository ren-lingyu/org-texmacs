;;; native-cite-source.el --- Native source snapshot regressions -*- lexical-binding: t; -*-

(defconst org-texmacs-test--native-source-text
  "@book{one,title={One},author={Alpha, Ada},year={2026}}\n")
(defconst org-texmacs-test--native-source-tree
  '(document
    (bib-entry
     "book" "one"
     (document (bib-field "title" "One") (bib-field "year" "2026")))))

(defun org-texmacs-test--native-source-format (plan)
  "Return a fixed native output for the already selected PLAN."
  (list
   (plist-get plan :prefix)
   (plist-get plan :keys)
   (plist-get plan :entries)
   (list
    'bib-list "1"
    (list
     'document
     (list
      'concat '(bibitem* "1")
      (list
       'label (concat (plist-get plan :prefix) "-one"))
      "One")))))

(defmacro org-texmacs-test--with-native-source (&rest body)
  "Run BODY with a real file and fixed native processing only."
  (declare (indent 0) (debug t))
  `(let* ((directory (make-temp-file "native-source-" t))
          (bib-file (expand-file-name "references.bib" directory))
          (parse-calls 0)
          (format-calls 0))
     (unwind-protect
         (progn
           (with-temp-file bib-file
             (insert org-texmacs-test--native-source-text))
           (cl-letf (((symbol-function 'org-texmacs--worker-request)
                      (lambda (source &optional syntax)
                        (cl-incf parse-calls)
                        (should (eq syntax 'bibliography))
                        (should
                         (equal
                          source
                          org-texmacs-test--native-source-text))
                        (copy-tree
                         org-texmacs-test--native-source-tree)))
                     ((symbol-function
                       'org-texmacs--bibliography-format)
                      (lambda (plan)
                        (cl-incf format-calls)
                        (org-texmacs-test--native-source-format
                         plan))))
             ,@body))
       (delete-directory directory t))))

(defun org-texmacs-test--native-source-input (file &optional body)
  "Prepare a real source declaring FILE, with default or explicit BODY."
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+cite_export: texmacs-native plain\n#+bibliography: "
     file
     "\n"
     (or body "Text [cite:@one].\n#+print_bibliography:\n"))
    (let ((org-export-use-babel nil))
      (org-texmacs-prepare-buffer (current-buffer)))))

(ert-deftest org-texmacs-native-source-snapshot-and-pure-repeat ()
  (org-texmacs-test--with-native-source
    (let* ((input (org-texmacs-test--native-source-input bib-file))
           (snapshot
            (car
             (plist-get
              (org-texmacs-input-info input)
              :texmacs-bibliography-snapshots)))
           (body (org-texmacs-test--native-cite-lower input)))
      (should (= parse-calls 1))
      (should (= format-calls 1))
      (should (equal (plist-get snapshot :path) bib-file))
      (should-not (plist-member snapshot :text))
      (delete-file bib-file)
      (should
       (equal body (org-texmacs-test--native-cite-lower input)))
      (should-error
       (org-texmacs--prepared-cite-check input)
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-native-source-unused-declaration-does-not-read
    ()
  (let ((parse-calls 0))
    (cl-letf (((symbol-function
                'org-texmacs--prepared-bibliography-bytes)
               (lambda (&rest _)
                 (ert-fail "Unused bibliography was read")))
              ((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (cl-incf parse-calls)
                 (ert-fail "Unused bibliography was parsed"))))
      (should
       (org-texmacs-input-p
        (org-texmacs-test--native-source-input "/missing/unused.bib"
                                               "Plain text.\n")))
      (should (= parse-calls 0)))))

(ert-deftest org-texmacs-native-source-rejects-alias-and-missing-files
    ()
  (org-texmacs-test--with-native-source
    (let ((alias (expand-file-name "alias.bib" directory)))
      (make-symbolic-link bib-file alias)
      (should-error
       (org-texmacs-test--native-source-input
        (concat bib-file " " alias))
       :type 'org-texmacs-document-error))
    (should (= parse-calls 0))
    (dolist (file
             (list
              directory (expand-file-name "missing.bib" directory)))
      (should-error
       (org-texmacs-test--native-source-input file)
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-native-source-changes-during-parse-and-retries
    ()
  (org-texmacs-test--with-native-source
    (let ((parse (symbol-function 'org-texmacs--worker-request)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source &optional syntax)
                   (prog1 (funcall parse source syntax)
                     (with-temp-file bib-file
                       (insert "Changed during parse"))))))
        (should-error
         (org-texmacs-test--native-source-input bib-file)
         :type 'org-texmacs-document-error)))
    (should (= parse-calls 1))
    (should (= format-calls 0))
    (with-temp-file bib-file
      (insert org-texmacs-test--native-source-text))
    (should
     (org-texmacs-input-p
      (org-texmacs-test--native-source-input bib-file)))))

(ert-deftest org-texmacs-native-source-freezes-before-stm-wait ()
  (org-texmacs-test--with-native-source
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (_source &optional syntax)
                 (should-not syntax)
                 (with-temp-file bib-file
                   (insert "Changed during STM parse"))
                 '(math "x"))))
      (should-error
       (org-texmacs-test--native-source-input
        bib-file
        "Text [cite:@one].\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n#+print_bibliography:\n")
       :type 'org-texmacs-document-error))
    (should (= format-calls 0))))

(ert-deftest org-texmacs-native-source-changes-during-format ()
  (org-texmacs-test--with-native-source
    (cl-letf (((symbol-function 'org-texmacs--bibliography-format)
               (lambda (plan)
                 (with-temp-file bib-file
                   (insert "Changed during formatting"))
                 (org-texmacs-test--native-source-format plan))))
      (should-error
       (org-texmacs-test--native-source-input bib-file)
       :type 'org-texmacs-document-error))))

(ert-deftest
    org-texmacs-native-source-final-text-filter-change-is-detected
    ()
  (org-texmacs-test--with-native-source
    (with-temp-buffer
      (org-mode)
      (insert
       "#+cite_export: texmacs-native plain\n#+bibliography: "
       bib-file
       "\n"
       "Text [cite:@one].\n#+print_bibliography:\n")
      (let ((org-export-use-babel nil)
            (org-export-filter-final-output-functions
             (list
              (lambda (text _backend _info)
                (with-temp-file bib-file
                  (insert "Changed in final filter"))
                text))))
        (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                   (lambda (_) "Native")))
          (should-error
           (org-export-as 'texmacs)
           :type 'org-texmacs-document-error))))))

(ert-deftest
    org-texmacs-native-source-worker-errors-and-quit-do-not-publish
    ()
  (org-texmacs-test--with-native-source
    (dolist (failure '(org-texmacs-worker-error quit))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (&rest _)
                   (signal failure
                           '("Injected native source failure")))))
        (condition-case err
            (progn
              (org-texmacs-test--native-source-input bib-file)
              (ert-fail "Failure not propagated"))
          ((error quit)
           (should (eq (car err) failure))))))
    (should
     (org-texmacs-input-p
      (org-texmacs-test--native-source-input bib-file)))))

(ert-deftest org-texmacs-native-format-style-wire-and-clean-rejection
    ()
  (let* ((plan
          '(:prefix
            "p"
            :keys ("one")
            :entries (document)
            :style "alpha"))
         (body
          '(bib-list
            "1"
            (document (concat (bibitem* "A26") (label "p-one"))))))
    (cl-letf
        (((symbol-function 'org-texmacs--worker-call)
          (lambda (make-request)
            (should
             (equal
              (funcall make-request 7)
              "(format-bibliography 7 \"p\" (\"document\") \"alpha\")\n"))
            (list 'ok 7 body))))
      (should
       (equal (nth 3 (org-texmacs--bibliography-format plan)) body))))
  (cl-letf
      (((symbol-function 'org-texmacs--worker-call)
        (lambda (_)
          '(error
            1
            "Unknown or unavailable native bibliography style")))
       ((symbol-function 'org-texmacs--worker-stop)
        (lambda ()
          (ert-fail
           "A clean style rejection discarded a healthy worker"))))
    (should-error
     (org-texmacs--bibliography-format
      '(:prefix "p" :keys nil :entries (document) :style "unknown"))
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-native-source-pdf-change-is-detected ()
  (org-texmacs-test--with-native-source
    (with-temp-buffer
      (org-mode)
      (insert
       "#+cite_export: texmacs-native plain\n#+bibliography: "
       bib-file
       "\n"
       "Text [cite:@one].\n#+print_bibliography:\n")
      (cl-letf (((symbol-function 'org-texmacs-document-pdf)
                 (lambda (_document)
                   (with-temp-file bib-file
                     (insert "Changed during PDF"))
                   (string-as-unibyte "%PDF-1.4\n"))))
        (should-error
         (org-texmacs--standard-consume 'pdf)
         :type 'org-texmacs-document-error)))))

(ert-deftest
    org-texmacs-native-source-checks-content-with-stable-attributes
    ()
  (org-texmacs-test--with-native-source
    (let* ((input (org-texmacs-test--native-source-input bib-file))
           (state
            (plist-get
             (car
              (plist-get
               (org-texmacs-input-info input)
               :texmacs-bibliography-snapshots))
             :state)))
      (with-temp-file bib-file
        (insert "Changed while attributes appear stable"))
      (cl-letf (((symbol-function
                  'org-texmacs--prepared-bibliography-state)
                 (lambda (_) state)))
        (should-error
         (org-texmacs--prepared-cite-check input)
         :type 'org-texmacs-document-error)))))
