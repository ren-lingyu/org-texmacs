;;; frontend.el --- core frontend regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-cleanup-nonfile-include-capture ()
  (org-texmacs-test--with-bibliography-files
   (write-region "Included\n" nil "part.org" nil 'silent)
   (insert "#+INCLUDE: \"part.org\"\n")
   (let ((before
          (org-texmacs-test--document-buffer-state (current-buffer)))
         (kinds
          (org-texmacs-test--observe-cleanup
           (lambda ()
             (should
              (equal
               (plist-get (org-texmacs-test--compose) :source)
               "Included\n"))))))
     (should (equal (sort kinds #'string-lessp) '(include root)))
     (should
      (equal
       before
       (org-texmacs-test--document-buffer-state (current-buffer)))))))

(ert-deftest org-texmacs-cleanup-source-configuration-guard ()
  (dolist (discover '(nil t))
    (org-texmacs-test--with-cleanup-source
     (setq-local org-export-with-toc nil)
     (let ((source (current-buffer)))
       (should
        (equal
         (should-error
          (org-texmacs--bibliography-convert
           source #'identity nil nil nil nil
           (lambda (_text
                    _tags
                    _headings
                    _links
                    _info
                    _file
                    _base
                    _texts
                    check)
             (with-temp-buffer
               (org-mode)
               ;; This matches the snapshot; the actual source has changed.
               (setq-local org-export-with-toc nil)
               (with-current-buffer source
                 (setq-local org-export-with-toc t))
               (funcall check)))
           discover)
          :type 'org-texmacs-document-error)
         '(org-texmacs-document-error
           "Bibliography transaction configuration changed")))
       ;; External callback changes are detected, not rolled back by the package.
       (should org-export-with-toc)))))

;;; font-lock-tests.el --- Embedded Scheme presentation regressions -*- lexical-binding: t; -*-

(ert-deftest
    org-texmacs-file-links-compose-with-inline-and-stm-provenance
    ()
  (let* ((file
          (org-element-create
           'link '(:type "file" :path "asset.pdf")))
         (bold (org-element-create 'bold nil file))
         (island (copy-sequence "STM"))
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
                (insert "[[file:./article.org][Article]]\n")
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
         (org-texmacs-prepare-buffer (current-buffer))
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

;;; frontend.el ends here
