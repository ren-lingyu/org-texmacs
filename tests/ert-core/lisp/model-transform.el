;;; model-transform.el --- Pure snapshot transformation regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Exercise native graph ownership without a parser or export consumer.

;;; Code:

(require 'org-texmacs-model)

(defun org-texmacs-test--transform-model ()
  "Return a supplied model with secondary objects and forward references."
  (let* ((leaf (copy-sequence "old inline"))
         (paragraph (org-element-create 'paragraph nil leaf))
         (caption (org-element-create 'italic nil "Caption"))
         (block
          (org-element-create
           'special-block
           (list
            :type "texmacs"
            :begin 9000
            :caption
            (list (cons (list caption) nil)))
           (org-element-create 'paragraph nil "old block")))
         (heading
          (org-element-create
           'headline
           (list
            :level 1
            :title
            (list (org-element-create 'bold nil "Title")))
           (org-element-create 'section nil paragraph block))))
    (org-element-put-property paragraph :peer block)
    (org-texmacs-model-create
     (org-element-create 'org-data nil heading)
     :islands
     (list
      (cons leaf '(math "inline"))
      (cons block '(math (frac "1" (sqrt "x")) "tail")))
     :context
     (list
      :fragment-tags (list (copy-sequence "math"))
      :heading-settings
      (list (cons 'test-setting (vector "value")))
      :link-settings (list :node block)))))

(defun org-texmacs-test--model-objects (model)
  "Collect MODEL's mutable objects, following references only once."
  (let ((seen (make-hash-table :test #'eq)))
    (cl-labels
     ((walk
       (value)
       (when (and (or (consp value) (stringp value) (vectorp value))
                  (not (gethash value seen)))
         (puthash value t seen)
         (cond
          ((consp value)
           (walk (car value))
           (walk (cdr value)))
          ((vectorp value)
           (mapc #'walk value))))))
     (walk (org-texmacs-model-ast model))
     (walk (org-texmacs-model-islands model))
     (walk (org-texmacs-model-context model)))
    seen))

(defun org-texmacs-test--models-disjoint (first second)
  "Assert FIRST and SECOND share no mutable internal objects."
  (let ((objects (org-texmacs-test--model-objects first))
        (others (org-texmacs-test--model-objects second)))
    (maphash
     (lambda (object _) (should-not (gethash object others)))
     objects)))

(ert-deftest org-texmacs-model-transform-is-pure-structure ()
  (let ((model (org-texmacs-test--transform-model)))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (&rest _) (ert-fail "Started worker")))
              ((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _) (ert-fail "Parsed STM")))
              ((symbol-function 'org-texmacs--worker-serialize-stm)
               (lambda (&rest _) (ert-fail "Serialized STM")))
              ((symbol-function 'org-texmacs-model-serialize)
               (lambda (&rest _) (ert-fail "Serialized model")))
              ((symbol-function 'org-texmacs-parse-buffer)
               (lambda (&rest _) (ert-fail "Parsed Org")))
              ((symbol-function 'org-element-interpret-data)
               (lambda (&rest _) (ert-fail "Interpreted Org")))
              ((symbol-function 'org-texmacs--document-lower)
               (lambda (&rest _) (ert-fail "Lowered model"))))
      (let* ((copy (org-texmacs-model-copy model))
             (node (caar (org-texmacs-model-islands copy)))
             (changed
              (org-texmacs-model-replace-stm copy node '(0) "new")))
        (should
         (equal
          (org-texmacs-model-island
           changed (caar (org-texmacs-model-islands changed)))
          '(math "new")))
        (org-texmacs-test--models-disjoint model copy)
        (org-texmacs-test--models-disjoint copy changed)))))

(ert-deftest
    org-texmacs-model-copy-remaps-context-and-secondary-ownership
    ()
  (let* ((model (org-texmacs-test--transform-model))
         (copy (org-texmacs-model-copy model))
         (block (car (nth 1 (org-texmacs-model-islands copy))))
         (paragraph
          (org-element-map
           (org-texmacs-model-ast copy) 'paragraph #'identity nil t))
         (caption (caar (car (org-element-property :caption block)))))
    (should
     (equal
      (org-texmacs-model-inspect model)
      (org-texmacs-model-inspect copy)))
    (org-texmacs-test--models-disjoint model copy)
    (should (eq (org-element-property :peer paragraph) block))
    (should
     (eq
      (plist-get
       (plist-get (org-texmacs-model-context copy) :link-settings)
       :node)
      block))
    (should (eq (org-element-parent caption) block))
    ;; Deliberate test-only mutation proves independence, not supported usage.
    (aset
     (car
      (plist-get (org-texmacs-model-context copy) :fragment-tags))
     0 ?X)
    (aset (cadr (cdar (org-texmacs-model-islands copy))) 0 ?X)
    (should
     (equal
      (plist-get
       (org-texmacs-model-context model)
       :fragment-tags)
      '("math")))
    (should
     (equal
      (cdar (org-texmacs-model-islands model)) '(math "inline")))))

(ert-deftest org-texmacs-model-island-requires-snapshot-local-identity
    ()
  (let* ((model (org-texmacs-test--transform-model))
         (node (caar (org-texmacs-model-islands model)))
         (tree (cdar (org-texmacs-model-islands model)))
         (copy (org-texmacs-model-copy model))
         (other (caar (org-texmacs-model-islands copy))))
    (should (eq tree (org-texmacs-model-island model node)))
    (should-error
     (org-texmacs-model-island copy node)
     :type 'org-texmacs-model-error)
    (should-error
     (org-texmacs-model-island model other)
     :type 'org-texmacs-model-error)
    (should-error
     (org-texmacs-model-island model (copy-sequence node))
     :type 'org-texmacs-model-error)
    (should-error
     (org-texmacs-model-island model (org-texmacs-model-ast model))
     :type 'org-texmacs-model-error)
    (should-error
     (org-texmacs-model-replace-stm copy node nil '(sqrt "x"))
     :type 'org-texmacs-model-error)
    (should (eq tree (org-texmacs-model-island model node)))))

(ert-deftest
    org-texmacs-model-replace-stm-nested-child-and-owned-replacement
    ()
  (let* ((model (org-texmacs-test--transform-model))
         (node (car (nth 1 (org-texmacs-model-islands model))))
         (replacement
          (list 'concat (copy-sequence "y") (copy-sequence "中")))
         (changed
          (org-texmacs-model-replace-stm
           model node '(0 1 0) replacement))
         (new-node (car (nth 1 (org-texmacs-model-islands changed)))))
    (org-texmacs-test--models-disjoint model changed)
    (aset (cadr replacement) 0 ?Z)
    (should
     (equal
      (org-texmacs-model-island changed new-node)
      '(math (frac "1" (sqrt (concat "y" "中"))) "tail")))
    (should
     (equal
      (org-texmacs-model-island model node)
      '(math (frac "1" (sqrt "x")) "tail")))
    (should
     (equal
      (cdar (org-texmacs-model-islands changed)) '(math "inline")))
    (should-error
     (org-texmacs-model-island changed node)
     :type 'org-texmacs-model-error)
    (should (org-texmacs-model-copy changed))))

(ert-deftest
    org-texmacs-model-replace-stm-root-atom-and-borrowed-subtree
    ()
  (let* ((model (org-texmacs-test--transform-model))
         (node (caar (org-texmacs-model-islands model)))
         (borrowed
          (cadr (cdr (nth 1 (org-texmacs-model-islands model)))))
         (changed
          (org-texmacs-model-replace-stm model node nil borrowed))
         (atom-model
          (org-texmacs-model-replace-stm
           changed
           (caar (org-texmacs-model-islands changed))
           nil
           "atom 中")))
    (should
     (equal
      (cdar (org-texmacs-model-islands changed))
      '(frac "1" (sqrt "x"))))
    (should
     (equal (cdar (org-texmacs-model-islands atom-model)) "atom 中"))
    (org-texmacs-test--models-disjoint model changed)
    (org-texmacs-test--models-disjoint changed atom-model)
    (should-error
     (org-texmacs-model-replace-stm
      atom-model
      (caar (org-texmacs-model-islands atom-model))
      '(0)
      "x")
     :type 'org-texmacs-model-error)))

(ert-deftest
    org-texmacs-model-transform-errors-preserve-input-and-use-paths
    ()
  (let* ((model (org-texmacs-test--transform-model))
         (node (car (nth 1 (org-texmacs-model-islands model))))
         (tree (org-texmacs-model-island model node))
         (before (org-texmacs-model-inspect model))
         (cycle (list 0)))
    (setcdr cycle cycle)
    (dolist (path
             (list '(-1) '("0") '(0.5) '(99) '(0 0 0) '(0 . 1) cycle))
      (let ((err
             (should-error
              (org-texmacs-model-replace-stm model node path "new")
              :type 'org-texmacs-model-error)))
        (should
         (string-match-p "AST path" (error-message-string err)))
        (should-not
         (string-match-p "9000" (error-message-string err))))
      (should (eq tree (org-texmacs-model-island model node)))
      (should (equal before (org-texmacs-model-inspect model))))
    (dolist (replacement '(nil 42 (math 42) (math . "bad")))
      (should-error
       (org-texmacs-model-replace-stm model node nil replacement)
       :type 'org-texmacs-model-error)
      (should (equal before (org-texmacs-model-inspect model))))))

(ert-deftest org-texmacs-model-transform-validates-existing-parents ()
  (let* ((model (org-texmacs-test--transform-model))
         (node (caar (org-texmacs-model-islands model))))
    (org-element-put-property node :parent nil)
    (should-error
     (org-texmacs-model-copy model)
     :type 'org-texmacs-model-error)
    (should-error
     (org-texmacs-model-replace-stm model node nil '(math "new"))
     :type 'org-texmacs-model-error)
    (should-not (org-element-parent node))))

(ert-deftest org-texmacs-model-copy-empty-context-and-invalid-input ()
  (let* ((model
          (org-texmacs-model-create
           (org-element-create 'org-data nil)))
         (copy (org-texmacs-model-copy model)))
    (org-texmacs-test--models-disjoint model copy)
    (should-not (org-texmacs-model-context copy))
    (should-not (org-texmacs-model-islands copy)))
  (should-error
   (org-texmacs-model-copy nil)
   :type 'org-texmacs-model-error)
  (should-error
   (org-texmacs-model-island nil nil)
   :type 'org-texmacs-model-error))

;;; model-transform.el ends here
