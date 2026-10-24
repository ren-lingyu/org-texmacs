;;; extensions.el --- Actual Org extension fixtures -*- lexical-binding: t; -*-
(require 'org-roam)
(require 'org-roam-include)
(require 'org-roam-organize)
(require 'org-roam-blog)
(require 'ucs-normalize)

(defconst org-texmacs-integration--section
  "22222222-2222-4222-8222-222222222222")
(defconst org-texmacs-integration--nested
  "33333333-3333-4333-8333-333333333333")
(defconst org-texmacs-integration--reference
  "55555555-5555-4555-8555-555555555555")
(defconst org-texmacs-integration--file
  "66666666-6666-4666-8666-666666666666")

(defun org-texmacs-integration--write (name text)
  (let ((coding-system-for-write 'utf-8-unix))
    (write-region text nil name nil 'silent)))

(defmacro org-texmacs-integration--fixture (&rest body)
  (declare (indent 0))
  `(let* ((root (make-temp-file "org-texmacs-real-extensions-" t))
          (notes (expand-file-name "notes/" root))
          (org-roam-directory notes)
          (org-roam-organize-directory notes)
          (org-roam-db-location (expand-file-name "roam.db" root))
          (org-roam-db--connection (make-hash-table :test #'equal))
          (org-id-locations nil)
          (org-id-locations-file (expand-file-name "ids" root))
          (org-roam-db-update-on-save nil)
          (org-roam-organize-registry
           '((:name
              "navigation"
              :tag "map"
              :directory "navigation"
              :moc t
              :basic t)
             (:name
              "literature"
              :tag "ref"
              :directory "literature"
              :cite t
              :bibliography t)))
          (org-publish-timestamp-directory
           (expand-file-name "timestamps/" root))
          (default-directory notes)
          (include-mode org-roam-include-mode)
          (organize-mode org-roam-organize-mode))
     (unwind-protect
         (progn
           (make-directory (expand-file-name "parts" notes) t)
           (make-directory (expand-file-name "literature" notes) t)
           (make-directory (expand-file-name "navigation" notes) t)
           (org-texmacs-integration--write
            (expand-file-name "parts/part.org" notes)
            (format
             ":PROPERTIES:\n:ID: %s\n:END:\n#+TITLE: Part\n* Section\n:PROPERTIES:\n:ID: %s\n:END:\nIncluded (math \"x\")\n#+ROAM_INCLUDE: %s :only-contents t\n"
             org-texmacs-integration--file
             org-texmacs-integration--section
             org-texmacs-integration--nested))
           (org-texmacs-integration--write
            (expand-file-name "parts/nested.org" notes)
            (format
             "#+TITLE: Nested\n* Nested\n:PROPERTIES:\n:ID: %s\n:END:\nNested content\n[[file:asset.txt][Asset]]\n"
             org-texmacs-integration--nested))
           (org-texmacs-integration--write
            (expand-file-name "literature/ref.org" notes)
            (format
             ":PROPERTIES:\n:ID: %s\n:ROAM_REFS: @real-key\n:BIBLIOGRAPHY: refs.bib\n:END:\n#+TITLE: Reference\n#+FILETAGS: :ref:\n"
             org-texmacs-integration--reference))
           (org-texmacs-integration--write
            (expand-file-name "literature/refs.bib" notes)
            "@book{real-key, author={Doe, Jane}, title={Actual fixture reference}, year={2026}}\n")
           (org-texmacs-integration--write
            (expand-file-name "root.org" notes)
            ":PROPERTIES:\n:ID: 44444444-4444-4444-8444-444444444444\n:END:\n#+TITLE: Root\n#+FILETAGS: :post:\nRoot content\n")
           (org-roam-db-sync)
           ,@body)
       (org-roam-include-mode
        (if include-mode
            1
          -1))
       (org-roam-organize-mode
        (if organize-mode
            1
          -1))
       (org-roam-db--close-all)
       (delete-directory root t))))

(defun org-texmacs-integration--enable (include organize)
  (when include
    (org-roam-include-mode 1)
    (should org-roam-include-mode))
  (when organize
    (org-roam-organize-mode 1)
    (should org-roam-organize-mode)))

(ert-deftest org-texmacs-integration-real-include-native-document ()
  (org-texmacs-test--with-worker
   (org-texmacs-integration--fixture
     (org-texmacs-integration--enable t nil)
     (should (org-roam-node-from-id org-texmacs-integration--section))
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name (expand-file-name "root.org" notes))
       (insert
        (format "#+ROAM_INCLUDE: %s :only-contents t\n"
                org-texmacs-integration--section))
       (let* ((before
               (org-texmacs-test--document-buffer-state
                (current-buffer)))
              (input
               (org-texmacs-prepare-buffer-preprocessed
                (current-buffer)))
              (working
               (plist-get
                (org-texmacs-input-info input)
                :texmacs-preprocessed-source)))
         (should (string-match-p "Included" working))
         (should (string-match-p "Nested content" working))
         (should (string-match-p "parts/asset.txt" working))
         (should-not (string-match-p "ROAM_INCLUDE" working))
         (should
          (org-texmacs-document-p (org-texmacs-document input)))
         (should
          (equal
           before
           (org-texmacs-test--document-buffer-state
            (current-buffer))))
         (should
          (string-match-p
           "TeXmacs"
           (org-texmacs-export-from-buffer-preprocessed
            (current-buffer)))))))))

(ert-deftest
    org-texmacs-integration-real-organize-cite-and-bibliography
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-integration--fixture
     (org-texmacs-integration--enable nil t)
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name (expand-file-name "root.org" notes))
       (insert
        (format "[cite:@%s]\n#+print_bibliography:\n"
                org-texmacs-integration--reference))
       (let* ((before (buffer-string))
              (input
               (org-texmacs-prepare-buffer-preprocessed
                (current-buffer) nil nil t)))
         (should
          (assoc
           (expand-file-name "literature/refs.bib" notes)
           (org-texmacs-input-bibliography input)))
         (should
          (equal
           (org-element-map
            (org-texmacs-input-ast input)
            'citation-reference
            (lambda (node) (org-element-property :key node)))
           '("real-key")))
         (should
          (string-match-p
           "bib-list"
           (prin1-to-string
            (org-texmacs-document-body
             (org-texmacs-document input)))))
         (should (equal before (buffer-string))))))))

(ert-deftest org-texmacs-integration-joint-html-and-blog-publication
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-integration--fixture
     (org-texmacs-integration--enable t t)
     (let*
         ((text
           (format
            "#+ROAM_INCLUDE: %s :only-contents t\n[cite:@%s]\n#+print_bibliography:\n"
            org-texmacs-integration--section
            org-texmacs-integration--reference))
          (org-roam-blog-directory notes)
          (org-roam-blog-publish-directory
           (expand-file-name "public" root))
          (org-roam-blog-publish-store "_org")
          (org-roam-blog-temporary-directory nil)
          (org-roam-blog-site-url nil)
          (org-roam-blog-export-default '(:template (:with-toc nil)))
          (org-roam-blog-content '((:name "posts" :tags ("post"))))
          (org-roam-blog-static nil)
          (org-roam-blog-sitemap '(:enable nil))
          (org-roam-blog-theindex '(:enable nil)))
       (make-directory org-roam-blog-publish-directory)
       (org-texmacs-integration--write
        (expand-file-name "root.org" notes)
        (concat
         ":PROPERTIES:\n:ID: 44444444-4444-4444-8444-444444444444\n:END:\n#+TITLE: Root\n#+FILETAGS: :post:\n"
         text))
       (org-roam-db-sync)
       (with-temp-buffer
         (org-mode)
         (setq buffer-file-name (expand-file-name "root.org" notes))
         (insert text)
         (let ((before (org-export-as 'html nil nil t)))
           (should (string-match-p "Nested content" before))
           (let ((org-texmacs-export-discover-bibliography t)
                 (org-export-show-temporary-export-buffer nil)
                 (output nil))
             (unwind-protect
                 (progn
                   (setq output (org-texmacs-export-as-texmacs))
                   (with-current-buffer output
                     (should
                      (string-match-p "TeXmacs" (buffer-string)))))
               (when (buffer-live-p output)
                 (kill-buffer output))))
           (should (equal before (org-export-as 'html nil nil t)))))
       (let ((result (org-roam-blog-publish)))
         (princ (format "BLOG result=%S\n" result))
         (should (eq (plist-get result :status) 'success))
         (should (plist-get result :promoted))
         (with-temp-buffer
           (insert-file-contents (car (plist-get result :promoted)))
           (should (search-forward "Nested content" nil t))
           (goto-char (point-min))
           (should
            (search-forward "Actual fixture reference" nil t))))))))

(ert-deftest
    org-texmacs-integration-real-include-mount-and-error-restoration
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-integration--fixture
     (org-texmacs-integration--enable t nil)
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name (expand-file-name "root.org" notes))
       (insert
        (format
         "* Mount\n:PROPERTIES:\n:ROAM_INCLUDE: %s\n:END:\nOld body\n** Old child\n"
         org-texmacs-integration--file))
       (let ((working
              (plist-get
               (org-texmacs-input-info
                (org-texmacs-prepare-buffer-preprocessed
                 (current-buffer)))
               :texmacs-preprocessed-source)))
         (should (string-match-p "Mount" working))
         (should (string-match-p "Section" working))
         (should (string-match-p "Nested content" working))
         (should-not (string-match-p "Old body\\|Old child" working)))
       (erase-buffer)
       (insert "#+ROAM_INCLUDE: absent-node\n")
       (let ((before
              (org-texmacs-test--document-buffer-state
               (current-buffer)))
             (reader (symbol-function 'org-file-contents))
             (expander
              (symbol-function 'org-export-expand-include-keyword))
             (search org-execute-file-search-functions))
         (should-error
          (org-texmacs-export-from-buffer-preprocessed
           (current-buffer))
          :type 'org-texmacs-document-error)
         (should
          (equal
           before
           (org-texmacs-test--document-buffer-state
            (current-buffer))))
         (should (eq reader (symbol-function 'org-file-contents)))
         (should
          (eq
           expander
           (symbol-function 'org-export-expand-include-keyword)))
         (should (equal search org-execute-file-search-functions))
         (should-not org-roam-include--export-buffer-p))
       (erase-buffer)
       (insert "Unrelated HTML\n")
       (should
        (string-match-p
         "Unrelated HTML" (org-export-as 'html nil nil t)))))))

(ert-deftest org-texmacs-integration-real-organize-missing-ref-error
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-integration--fixture
     (org-texmacs-integration--enable nil t)
     (org-texmacs-integration--write
      (expand-file-name "literature/ref.org" notes)
      (format
       ":PROPERTIES:\n:ID: %s\n:BIBLIOGRAPHY: refs.bib\n:END:\n#+TITLE: Reference\n#+FILETAGS: :ref:\n"
       org-texmacs-integration--reference))
     (org-roam-db-sync)
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name (expand-file-name "root.org" notes))
       (insert
        (format "[cite:@%s]\n#+print_bibliography:\n"
                org-texmacs-integration--reference))
       (let ((before
              (org-texmacs-test--document-buffer-state
               (current-buffer))))
         (should-error
          (org-texmacs-prepare-buffer-preprocessed
           (current-buffer) nil nil t))
         (should
          (equal
           before
           (org-texmacs-test--document-buffer-state
            (current-buffer))))
         (should-not org-texmacs--worker-process))))))

(ert-deftest
    org-texmacs-integration-mode-teardown-restores-standard-interfaces
    ()
  (let ((expander
         (symbol-function 'org-export-expand-include-keyword))
        (collector
         (symbol-function 'org-cite-list-bibliography-files))
        (before-hooks
         (copy-sequence org-export-before-processing-functions))
        (filters
         (copy-sequence org-export-filter-parse-tree-functions)))
    (org-texmacs-integration--fixture
      (org-texmacs-integration--enable t t))
    (should
     (eq
      expander (symbol-function 'org-export-expand-include-keyword)))
    (should
     (eq
      collector (symbol-function 'org-cite-list-bibliography-files)))
    (should
     (equal before-hooks org-export-before-processing-functions))
    (should (equal filters org-export-filter-parse-tree-functions))))

(ert-deftest org-texmacs-integration-real-include-parameters-and-cycle
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-integration--fixture
     (org-texmacs-integration--enable t nil)
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name (expand-file-name "root.org" notes))
       (insert
        (format
         "#+ROAM_INCLUDE: %s :only-contents t :lines \"1-2\" :minlevel 3\n"
         org-texmacs-integration--section))
       (let ((input
              (org-texmacs-prepare-buffer-preprocessed
               (current-buffer))))
         (should
          (string-match-p
           "Included"
           (plist-get
            (org-texmacs-input-info input)
            :texmacs-preprocessed-source)))
         (should-not
          (string-match-p
           "Nested content"
           (plist-get
            (org-texmacs-input-info input)
            :texmacs-preprocessed-source)))
         (should
          (= (length
              (plist-get
               (org-texmacs-input-info input)
               :texmacs-preprocessing-sources))
             1)))
       (org-texmacs-integration--write
        (expand-file-name "parts/nested.org" notes)
        (format
         "#+TITLE: Nested\n* Nested\n:PROPERTIES:\n:ID: %s\n:END:\n#+ROAM_INCLUDE: %s :only-contents t\n"
         org-texmacs-integration--nested
         org-texmacs-integration--section))
       (org-roam-db-sync)
       (erase-buffer)
       (insert
        (format "#+ROAM_INCLUDE: %s :only-contents t\n"
                org-texmacs-integration--section))
       (let ((before
              (org-texmacs-test--document-buffer-state
               (current-buffer))))
         (should-error
          (org-texmacs-prepare-buffer-preprocessed (current-buffer))
          :type 'org-texmacs-document-error)
         (should
          (equal
           before
           (org-texmacs-test--document-buffer-state
            (current-buffer)))))))))

(ert-deftest
    org-texmacs-integration-frontend-three-consumers-and-discovery
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-integration--fixture
     (org-texmacs-integration--enable t t)
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name (expand-file-name "root.org" notes))
       (insert
        (format
         "#+ROAM_INCLUDE: %s :only-contents t\n[cite:@%s]\n#+print_bibliography:\n"
         org-texmacs-integration--section
         org-texmacs-integration--reference))
       (let ((before
              (org-texmacs-test--document-buffer-state
               (current-buffer)))
             (org-export-show-temporary-export-buffer nil))
         (should-error
          (org-texmacs-export-as-texmacs)
          :type 'org-texmacs-document-error)
         (setq-local org-texmacs-export-discover-bibliography t)
         (let ((output (org-texmacs-export-as-texmacs))
               bytes)
           (unwind-protect
               (with-current-buffer output
                 (setq bytes (buffer-string))
                 (should (string-match-p "Nested content" bytes))
                 (should
                  (string-match-p "Actual fixture reference" bytes)))
             (kill-buffer output))
           (let ((file (org-texmacs-export-to-texmacs)))
             (with-temp-buffer
               (set-buffer-multibyte nil)
               (insert-file-contents-literally file)
               (should (equal bytes (buffer-string))))))
         (let* ((file (org-texmacs-export-to-pdf))
                (text
                 (ucs-normalize-NFKC-string
                  (org-texmacs-test--pdf-text file))))
           (should (string-match-p "Nested content" text))
           (should (string-match-p "Actual fixture reference" text)))
         (should
          (equal
           before
           (org-texmacs-test--document-buffer-state
            (current-buffer)))))))))

(ert-deftest
    org-texmacs-integration-frontend-errors-and-local-mount-refusal
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-integration--fixture
     (org-texmacs-integration--enable t t)
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name (expand-file-name "root.org" notes))
       (insert "#+ROAM_INCLUDE: absent-node\n")
       (dolist (entry
                '((org-texmacs-export-to-texmacs . "root.tm")
                  (org-texmacs-export-to-pdf . "root.pdf")))
         (let ((file (expand-file-name (cdr entry) notes)))
           (org-texmacs-integration--write file "Keep")
           (should-error
            (funcall (car entry))
            :type 'org-texmacs-document-error)
           (with-temp-buffer
             (insert-file-contents-literally file)
             (should (equal "Keep" (buffer-string))))))
       (erase-buffer)
       (insert
        (format
         "* Mount\n:PROPERTIES:\n:ROAM_INCLUDE: %s\n:END:\nOld body\n"
         org-texmacs-integration--file))
       (goto-char (point-min))
       (should-error
        (org-texmacs-export-as-texmacs nil t)
        :type 'org-texmacs-document-error)
       (should-not org-roam-include--export-buffer-p)))))

;;; extensions.el ends here
