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
                "1"
                (document
                 (label "p-key") (cite-detail "missing" "chapter 1")))
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
