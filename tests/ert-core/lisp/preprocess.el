;;; preprocess.el --- Public preparation boundaries -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-standard-prepare-public-filters-and-ownership
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Original.\n")
    (let ((source (current-buffer))
          (options 0)
          (trees 0))
      (let ((org-export-filter-options-functions
             (list
              (lambda (info backend)
                (should (eq backend 'texmacs))
                (cl-incf options)
                (plist-put info :with-author nil))))
            (org-export-filter-parse-tree-functions
             (list
              (lambda (tree backend _info)
                (should (eq backend 'texmacs))
                (should-not (eq source (current-buffer)))
                (cl-incf trees)
                (org-element-map
                 tree 'paragraph
                 (lambda (node)
                   (org-element-set-contents node "Filtered.")))
                tree))))
        (cl-letf (((symbol-function 'org-texmacs-document)
                   (lambda (&rest _)
                     (ert-fail "Preparation invoked lowering"))))
          (let* ((input (org-texmacs-prepare-buffer source))
                 (model (org-texmacs-input-model input)))
            (erase-buffer)
            (should-not
             (plist-get (org-texmacs-input-info input) :with-author))
            (should
             (string-search
              "Filtered."
              (prin1-to-string (org-texmacs-model-ast model)))))))
      (should (= options 1))
      (should (= trees 1)))))

(ert-deftest
    org-texmacs-standard-structured-source-migration-before-effects
    ()
  (with-temp-buffer
    (org-mode)
    (insert "Body.\n")
    (let ((org-export-before-processing-functions
           (list
            (lambda (_)
              (ert-fail "Old text snapshots ran preparation")))))
      (dolist (function
               '(org-texmacs-prepare-buffer
                 org-texmacs-document-from-buffer))
        (should-error
         (funcall function
                  (current-buffer)
                  '(("refs.bib" . "@book{key}")))
         :type 'org-texmacs-document-error))
      (should-error
       (org-texmacs-document-current-buffer
        '(("refs.bib" . "@book{key}")))
       :type 'org-texmacs-document-error))))
