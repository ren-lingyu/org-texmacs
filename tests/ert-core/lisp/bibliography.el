;;; bibliography.el --- core bibliography regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-bibliography-input-ownership ()
  (let* ((path (copy-sequence "/source/references.bib"))
         (title (copy-sequence "Book"))
         (tree
          (list
           'document
           (list
            'bib-entry "book" "key"
            (list 'document (list 'bib-field "title" title)))))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil "Text")))
         (input
          (org-texmacs-input-create
           ast
           nil
           :bibliography (list (cons path tree))))
         (owned (org-texmacs-input-bibliography input)))
    (should (equal owned (list (cons path tree))))
    (should-not (eq (caar owned) path))
    (should-not (eq (cdar owned) tree))
    (aset path 1 ?X)
    (aset title 0 ?X)
    (should (equal (caar owned) "/source/references.bib"))
    (should (equal (nth 2 (cadr (nth 3 (cadr (cdar owned))))) "Book"))
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Pure input started worker")))
              ((symbol-function 'insert-file-contents)
               (lambda (&rest _) (ert-fail "Pure input read files"))))
      (should
       (equal
        (org-texmacs-document-body
         (org-texmacs-document input))
        '(document (concat "Text")))))))

(ert-deftest org-texmacs-bibliography-input-rejects-invalid-data ()
  (let* ((ast (org-element-create 'org-data nil))
         (entry
          '(bib-entry
            "book" "key" (document (bib-field "title" "Book"))))
         (tree (list 'document entry)))
    (dolist (data
             (list
              'invalid
              '(("relative.bib" document))
              (list (cons "/a.bib" '(concat "wrong")))
              (list (cons "/a.bib" tree) (cons "/a.bib" '(document)))
              '(("/a.bib" document
                 (bib-entry
                  "book" "key"
                  (document
                   (bib-field "title" "A") (bib-field "TITLE")))))))
      (should-error
       (org-texmacs-input-create ast nil :bibliography data)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-bibliography-view-owned-and-invalid ()
  (let* ((id (copy-sequence "/source/refs.bib"))
         (raw (copy-sequence "refs.bib"))
         (view
          (list :document (list (cons raw id)) :sources (list id)))
         (owned (org-texmacs--bibliography-view-copy view)))
    (aset id 1 ?X)
    (aset raw 0 ?X)
    (should
     (equal
      owned
      '(:document
        (("refs.bib" . "/source/refs.bib"))
        :sources ("/source/refs.bib")))))
  (dolist (view
           '(t
             (:sources ("relative.bib") :document nil)
             (:document nil :document nil)
             (:sources ("/a" "/a") :document nil)
             (:sources ("/a") :document (("refs" . "/b")))
             (:sources
              ("/a" "/b")
              :document (("refs" . "/a") ("refs" . "/b")))))
    (should-error
     (org-texmacs--bibliography-view-copy view)
     :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-bibliography-view-global-only-resolution ()
  (with-temp-buffer
    (org-mode)
    (insert "[cite:@managed-uuid]\n#+print_bibliography:\n")
    (setq-local default-directory "/source/")
    (let ((org-export-filter-parse-tree-functions
           '(org-texmacs-test--ast-filter-remap)))
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (text &rest _)
                   (if (equal text "@book{external-key}")
                       '(document
                         (bib-entry "book" "external-key" (document)))
                     '(document
                       (bib-entry "book" "unused" (document))))))
                ((symbol-function 'org-texmacs--bibliography-format)
                 (lambda (plan)
                   (list
                    (plist-get plan :prefix)
                    (plist-get plan :keys)
                    (plist-get plan :entries)
                    (list
                     'bib-list "1"
                     (list
                      'document
                      (list
                       'label
                       (concat
                        (plist-get plan :prefix)
                        "-external-key"))))))))
        (let ((input
               (org-texmacs--prepare-buffer
                (current-buffer)
                #'identity
                '(("refs.bib" . "@book{external-key}")
                  ("unused.bib" . "@book{unused}"))
                nil
                nil
                nil
                '(:document nil :sources ("/source/refs.bib")))))
          (should
           (= (length (org-texmacs-input-bibliography input)) 2))
          (should
           (equal
            (plist-get
             (org-texmacs-input-info input)
             :texmacs-bibliography-source-identities)
            '("/source/refs.bib")))
          (cl-letf (((symbol-function 'org-file-contents)
                     (lambda (&rest _)
                       (ert-fail "Pure planner read file"))))
            (should
             (org-texmacs-document-p
              (org-texmacs-document input)))))))))

(ert-deftest
    org-texmacs-bibliography-view-rejects-document-disagreement
    ()
  (with-temp-buffer
    (org-mode)
    (setq-local default-directory "/source/")
    (insert "#+bibliography: refs.bib\nText\n")
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Bad view started worker"))))
      (should-error
       (org-texmacs--prepare-buffer
        (current-buffer)
        #'identity
        '(("refs.bib" . "@book{key}"))
        nil
        nil
        nil
        '(:document nil :sources ("/source/refs.bib")))
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-bibliography-auto-private-discovery ()
  (org-texmacs-test--with-bibliography-files
   (insert
    "#+bibliography: refs.bib\n(math \"x\")\n#+begin_texmacs\n"
    "#+bibliography: island.bib\n#+SETUPFILE: secret.org\n#+end_texmacs\n")
   (setq-local org-link-abbrev-alist-local
               '(("paper" . "https://example.org/%s")))
   (let* ((source (buffer-string))
          (globals (list "a.bib" "b.bib" "a.bib"))
          (original (copy-tree globals))
          (calls 0)
          (spy
           (lambda (paths)
             (cl-incf calls)
             (should
              (equal
               org-link-abbrev-alist-local
               '(("paper" . "https://example.org/%s"))))
             (append paths '("./a.bib")))))
     (unwind-protect
         (progn
           (advice-add
            'org-cite-list-bibliography-files
            :filter-return spy)
           (cl-letf (((symbol-function 'org-file-contents)
                      (lambda (&rest _)
                        (ert-fail
                         "STM caused external keyword read"))))
             (let ((result
                    (org-texmacs--bibliography-discover
                     source
                     (org-texmacs--fragment-tags)
                     (org-texmacs--document-heading-settings)
                     (org-texmacs--document-link-settings)
                     (plist-put
                      (org-texmacs--document-options)
                      :texmacs-resource-base default-directory)
                     nil
                     default-directory
                     globals)))
               (should
                (equal
                 (car result)
                 '("refs.bib" "a.bib" "b.bib" "./a.bib")))
               (should (= calls 1))
               (should (equal globals original))
               (should (equal source (buffer-string))))))
       (advice-remove 'org-cite-list-bibliography-files spy)))))

(ert-deftest org-texmacs-bibliography-auto-acquire-and-receipts ()
  (org-texmacs-test--with-bibliography-files
   (let* ((provided
           '(("absent.bib" . "@book{explicit}")
             ("unused.bib" . "@book{unused}")))
          (result
           (org-texmacs--bibliography-acquire
            '("absent.bib" "refs.bib" "./refs.bib")
            default-directory
            provided
            nil))
          (texts (plist-get result :sources))
          (receipts (plist-get result :receipts)))
     (should (= (length texts) 3))
     (should (= (length receipts) 1))
     (should (equal (cdar texts) "@book{explicit}"))
     (should (string-match-p "Café" (cdr (nth 2 texts))))
     (org-texmacs--bibliography-check-receipts receipts)
     (write-region "@book{changed}" nil "refs.bib" nil 'silent)
     (should-error
      (org-texmacs--bibliography-check-receipts receipts)
      :type 'org-texmacs-document-error)
     (should (string-match-p "Café" (cdr (nth 2 texts)))))))

(ert-deftest org-texmacs-bibliography-auto-rejects-locations-and-files
    ()
  (org-texmacs-test--with-bibliography-files
   (dolist (path
            '(""
              "~/.bib"
              "https://example.org/ref.bib"
              "/ssh:host:/ref.bib"
              "bad\nname"))
     (should-error
      (org-texmacs--bibliography-local-path path default-directory)
      :type 'org-texmacs-document-error))
   (dolist (path '("missing.bib" "."))
     (should-error
      (org-texmacs--bibliography-acquire
       (list path) default-directory nil nil)
      :type 'org-texmacs-document-error))
   (make-symbolic-link
    (expand-file-name "refs.bib") (expand-file-name "link.bib"))
   (should-error
    (org-texmacs--bibliography-acquire
     '("link.bib") default-directory nil nil)
    :type 'org-texmacs-document-error)
   (add-name-to-file
    (expand-file-name "refs.bib") (expand-file-name "alias.bib"))
   (should-error
    (org-texmacs--bibliography-acquire
     '("refs.bib" "alias.bib") default-directory nil nil)
    :type 'org-texmacs-document-error)
   (let ((coding-system-for-write 'no-conversion))
     (write-region (unibyte-string 255) nil "invalid.bib"
                   nil
                   'silent))
   (should-error
    (org-texmacs--bibliography-acquire
     '("invalid.bib") default-directory nil nil)
    :type 'org-texmacs-document-error)
   (write-region (make-string 1048577 ?a) nil "large.bib" nil 'silent)
   (should-error
    (org-texmacs--bibliography-acquire
     '("large.bib") default-directory nil nil)
    :type 'org-texmacs-document-error)))

(ert-deftest org-texmacs-bibliography-auto-rejects-dropped-declaration
    ()
  (should-error
   (org-texmacs--bibliography-acquire
    nil "/source/" nil '(("refs.bib" . "/source/refs.bib")))
   :type 'org-texmacs-document-error))

(ert-deftest org-texmacs-bibliography-issue12-unused-duplicates ()
  :tags
  '(issue12)
  (let* ((ast (org-element-create 'org-data nil))
         (entry '(bib-entry "book" "unused" (document)))
         (sources
          (list
           (cons "/a.bib" (list 'document entry entry))
           (cons "/b.bib" (list 'document entry))))
         (input
          (org-texmacs-input-create ast nil :bibliography sources)))
    (should (equal sources (org-texmacs-input-bibliography input)))
    (should (org-texmacs-document-p (org-texmacs-document input)))))

(ert-deftest org-texmacs-bibliography-issue12-native-fields ()
  :tags
  '(issue12)
  (let* ((ast (org-element-create 'org-data nil))
         (tree
          '(document
            (bib-comment "Native metadata")
            (bib-entry
             "online" "key"
             (document
              (bib-field "title" "A")
              (bib-field "TITLE" "B")
              (bib-field "unknown" (native-value "C"))))))
         (input
          (org-texmacs-input-create
           ast nil
           :bibliography (list (cons "/a.bib" tree)))))
    (should
     (equal tree (cdar (org-texmacs-input-bibliography input))))))

(ert-deftest
    org-texmacs-bibliography-issue12-reference-and-label-contracts
    ()
  :tags
  '(issue12)
  (let ((plan '(:prefix "p" :keys ("key") :entries (document))))
    (dolist (body
             '((bib-list
                "1"
                (document (label "p-key") (cite "missing")))
               (bib-list
                "1" (document (label "p-key") (reference "missing")))
               (bib-list
                "1"
                (document
                 (label "p-key") (with-bib "other" (cite "key"))))))
      (cl-letf (((symbol-function 'org-texmacs--worker-call)
                 (lambda (_request) (list 'ok 1 body)))
                ((symbol-function 'org-texmacs--worker-stop)
                 (lambda ()
                   (ert-fail
                    "Unresolvable native reference stopped worker"))))
        (should-error
         (org-texmacs--bibliography-format plan)
         :type 'org-texmacs-document-error)))
    (let (stopped)
      (cl-letf (((symbol-function 'org-texmacs--worker-call)
                 (lambda (_request)
                   '(ok
                     1
                     (bib-list
                      "1"
                      (document (label "p-key") (label "p-key"))))))
                ((symbol-function 'org-texmacs--worker-stop)
                 (lambda () (setq stopped t))))
        (should-error
         (org-texmacs--bibliography-format plan)
         :type 'org-texmacs-worker-error)
        (should stopped)))))

;;; bibliography.el ends here
