;;; probe.el --- Standard query protocol -*- lexical-binding: t; -*-
(require 'ox-texmacs)
(require 'org-texmacs-query)

(dolist (name '(org-export-get-footnote-definition org-export-get-footnote-number
                org-export-footnote-first-reference-p org-export-get-headline-number
                org-export-numbered-headline-p org-export-get-relative-level
                org-export-resolve-id-link org-export-resolve-fuzzy-link
                org-export-get-ordinal org-export-get-reference))
  (message "PUBLIC %S %S" name (and (fboundp name) (documentation name))))

(defun c--inspect (source inspect &optional select subtree visible filter)
  (with-temp-buffer
    (org-mode) (insert source)
    (when select (funcall select))
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions (and filter (list filter))))
      (cl-letf (((symbol-function 'org-texmacs--standard-inner)
                 (lambda (_contents info)
                   (funcall inspect (plist-get info :parse-tree) info) "")))
        (org-export-as 'texmacs subtree visible)))))

(ert-deftest c-footnote-outside-narrowing-and-subtree ()
  (dolist (scope '(narrow subtree))
    (c--inspect
     "* Selected\nNote[fn:n].\n* Other\nOutside.\n\n[fn:n] External definition.\n"
     (lambda (tree info)
       (let* ((ref (car (org-element-map tree 'footnote-reference #'identity)))
              (body (org-export-get-footnote-definition ref info)))
         (message "NOTE SCOPE %S DEF %S IGNORE %S DEF-IN-TREE %S" scope
                  (substring-no-properties (org-element-interpret-data body))
                  (org-element-map (plist-get info :ignore-list) t #'org-element-type)
                  (and (memq (org-element-property :parent (car body))
                             (org-element-map tree 'footnote-definition #'identity)) t))
         (should (string-match-p "External definition" (org-element-interpret-data body)))
         (should (= 1 (org-export-get-footnote-number ref info)))))
     (lambda () (goto-char (point-min))
       (when (eq scope 'narrow)
         (narrow-to-region (point-min) (save-excursion (re-search-forward "^\\* Other") (match-beginning 0)))))
     (eq scope 'subtree))))

(ert-deftest c-headline-and-duplicate-link-query ()
  (c--inspect "#+OPTIONS: toc:t num:2\n* Same\n[[*Same]]\n** Child\n* Same\n"
              (lambda (tree info)
                (let* ((headings (org-element-map tree 'headline #'identity))
                       (link (car (org-element-map tree 'link #'identity))))
                  (should (eq (car (last headings)) (org-export-resolve-fuzzy-link link info)))
                  (should (equal '(1) (org-export-get-headline-number (car headings) info)))
                  (should (equal '(1 1) (org-export-get-headline-number (cadr headings) info)))
                  (should (= 1 (org-export-get-relative-level (car headings) info)))))))

(ert-deftest c-filter-inserted-headline-gets-standard-numbering ()
  (c--inspect "* Existing\nText.\n"
              (lambda (tree info)
                (let ((headings (org-element-map tree 'headline #'identity)))
                  (should (equal '(2) (org-export-get-headline-number (cadr headings) info)))))
              nil nil nil
              (lambda (tree _backend _info)
                (org-element-adopt tree (org-element-create 'headline '(:level 1 :raw-value "New" :title ("New")))) tree)))

(ert-deftest c-selected-headline-offset ()
  (c--inspect "* Parent\n** Selected\n*** Child\nBody.\n* Other\n"
              (lambda (tree info)
                (message "OFFSET %S NUMBERS %S" (plist-get info :headline-offset)
                         (org-element-map tree 'headline
                                          (lambda (n) (list (org-export-get-relative-level n info)
                                                            (org-export-get-headline-number n info))))))
              (lambda () (goto-char (point-min)) (re-search-forward "^\\*\\* Selected") (beginning-of-line)) t))

(ert-deftest c-footnote-definition-and-cache-shapes ()
  (c--inspect "Inline[fn:a:Inline definition] again[fn:a]. Anonymous[fn::Anon]. Standard[fn:b].\n\n[fn:b] Standard definition.\n"
              (lambda (tree info)
                (message "IGNORE TYPES %S HEADINGS %S"
                         (mapcar #'org-element-type (plist-get info :ignore-list))
                         (org-element-map tree 'headline (lambda (n) (org-element-property :raw-value n))))
                (org-element-map tree 'footnote-reference
                                 (lambda (ref)
                                   (let* ((body (org-export-get-footnote-definition ref info))
                                          (first (car body)))
                                     (message "DEF SHAPE %S BODY %S FIRST %S PARENT %S NUMBER %S FIRSTREF %S"
                                              (org-element-property :label ref)
                                              (mapcar #'org-element-type body)
                                              (org-element-type first)
                                              (org-element-type (org-element-property :parent first))
                                              (org-export-get-footnote-number ref info)
                                              (org-export-footnote-first-reference-p ref info))))))))

(ert-deftest c-copy-info-footnote-cache-counterexample ()
  (c--inspect "* First\n[fn:n] and [[*Same]].\n* Same\nText.\n\n[fn:n] Definition.\n"
              (lambda (tree info)
                (org-element-map tree t (lambda (n) (when (consp n) (org-element-properties-resolve n))) nil nil nil t)
                (let* ((copy (org-texmacs--prepared-copy tree nil))
                       (context (copy-sequence info))
                       (ref (car (org-element-map copy 'footnote-reference #'identity)))
                       (link (car (org-element-map copy 'link #'identity))))
                  (plist-put context :parse-tree copy)
                  (plist-put context :resolve-fuzzy-link-cache nil)
                  (should (memq (org-export-resolve-fuzzy-link link context)
                                (org-element-map copy 'headline #'identity)))
                  ;; A copied tree is not the same cache identity universe.
                  (should-not (org-export-get-footnote-number ref context copy))))))

(defun c--snapshot (tree info)
  (org-element-map tree t (lambda (n) (when (consp n) (org-element-properties-resolve n))) nil nil nil t)
  (let* ((identities (make-hash-table :test #'eq))
         (copy (org-texmacs--prepared-copy tree (plist-get info :ignore-list) identities))
         (requests (org-texmacs--prepared-discover copy (org-texmacs--fragment-tags))))
    (list copy (org-texmacs--query-snapshot copy info identities) requests)))

(ert-deftest c-owning-original-query-results-preserves-selected-footnotes ()
  (c--inspect "* Selected\nNote[fn:n].\n* Other\n\n[fn:n] External.\n"
              (lambda (tree info)
                (pcase-let* ((`(,copy ,facts ,requests) (c--snapshot tree info))
                             (note (car (plist-get facts :footnotes)))
                             (input (org-texmacs--input-own copy (list :texmacs-org-query facts))))
                  (should-not requests)
                  (should (= 1 (nth 2 note)))
                  (should (nth 3 note))
                  (should (eq (org-element-type (nth 1 note)) 'footnote-definition))
                  (should (memq (nth 1 note) (org-element-map copy 'footnote-definition #'identity)))
                  (should (plist-get (org-texmacs-input-info input) :texmacs-org-query))))
              (lambda () (goto-char (point-min))) t))

(ert-deftest c-stm-org-objects-are-opaque-to-query-dispatch ()
  (c--inspect "(math \"[[missing]]\")\n"
              (lambda (tree info)
                (pcase-let ((`(,_copy ,facts ,requests) (c--snapshot tree info)))
                  (should (= (length requests) 1))
                  (should-not (plist-get facts :targets))))))
