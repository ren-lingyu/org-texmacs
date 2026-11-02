;;; model-inspect.el --- Independent model inspection regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Exercise readable projections and display without native or source operations.

;;; Code:

(require 'org-texmacs-inspect)

(defun org-texmacs-test--inspection-model ()
  "Return a small independently owned model for inspection tests."
  (let* ((leaf (copy-sequence "old STM source"))
         (paragraph
          (org-element-create 'paragraph nil "Before " leaf ".\n")))
    (org-texmacs-model-create
     (org-element-create 'org-data nil paragraph)
     :islands (list (cons leaf '(frac "1" "2"))))))

(ert-deftest
    org-texmacs-model-inspect-authoritative-independent-projection
    ()
  (let* ((model (org-texmacs-test--inspection-model))
         (ast (org-texmacs-model-ast model))
         (leaf (caar (org-texmacs-model-islands model)))
         (parent (org-element-parent leaf))
         projection)
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Inspection requested a worker")))
              ((symbol-function 'org-texmacs--document-lower)
               (lambda (&rest _)
                 (ert-fail "Inspection invoked lowering")))
              ((symbol-function 'org-texmacs-parse-buffer)
               (lambda (&rest _)
                 (ert-fail "Inspection parsed source")))
              ((symbol-function 'org-element-interpret-data)
               (lambda (&rest _)
                 (ert-fail "Inspection serialized Org")))
              ((symbol-function 'buffer-substring-no-properties)
               (lambda (&rest _)
                 (ert-fail "Inspection read a buffer"))))
      (setq projection (org-texmacs-model-inspect model)))
    (should
     (equal
      projection
      '(org-data
        nil (paragraph nil "Before " (stm (frac "1" "2")) ".\n"))))
    (should (eq ast (org-texmacs-model-ast model)))
    (should (eq parent (org-element-parent leaf)))
    (should (equal leaf "old STM source"))
    ;; The view can be edited without mutating the read-only model snapshot.
    (aset (nth 2 (nth 2 projection)) 0 ?X)
    (aset (cadr (cadr (nth 3 (nth 2 projection)))) 0 ?9)
    (should
     (equal
      (org-element-contents parent)
      '("Before " "old STM source" ".\n")))
    (should
     (equal
      (cdar (org-texmacs-model-islands model)) '(frac "1" "2")))))

(ert-deftest
    org-texmacs-model-inspect-secondary-caption-and-block-ownership
    ()
  (let* ((title-leaf (copy-sequence "stale title STM"))
         (caption-leaf (copy-sequence "stale caption STM"))
         (short (org-element-create 'italic nil "Short"))
         (block
          (org-element-create
           'special-block
           (list
            :type "texmacs"
            :parameters "kept"
            :caption
            (list
             (cons (list caption-leaf) (list short)) (cons nil nil)))
           (org-element-create 'paragraph nil "stale block STM")))
         (headline
          (org-element-create
           'headline
           (list
            :level 2
            :todo-keyword "READY"
            :raw-value "stale title STM"
            :title (list title-leaf))
           block))
         (model
          (org-texmacs-model-create
           (org-element-create 'org-data nil headline)
           :islands
           (list
            (cons title-leaf '(new-root "标题"))
            (cons block '(math (sqrt "x")))
            (cons caption-leaf "atomic caption"))))
         (view (org-texmacs-model-inspect model))
         (heading-view (nth 2 view))
         (block-view (nth 2 heading-view)))
    (should
     (equal
      (plist-get (cadr heading-view) :title)
      '((stm (new-root "标题")))))
    (should (= (plist-get (cadr heading-view) :level) 2))
    (should
     (equal (plist-get (cadr heading-view) :todo-keyword) "READY"))
    (should (equal (plist-get (cadr block-view) :parameters) "kept"))
    (should
     (equal
      (plist-get (cadr block-view) :caption)
      '((:long ((stm "atomic caption")) :short ((italic nil "Short")))
        (:long nil :short nil))))
    (should (equal (cddr block-view) '((stm (math (sqrt "x"))))))
    (should-not (string-match-p "stale" (prin1-to-string view)))
    (let* ((owned-heading
            (car
             (org-element-contents (org-texmacs-model-ast model))))
           (owned-block (car (org-element-contents owned-heading)))
           (old-body (car (org-element-contents owned-block))))
      (should
       (equal
        (org-element-contents old-body) '("stale block STM"))))))

(ert-deftest
    org-texmacs-model-inspect-custom-secondary-and-native-properties
    ()
  (let* ((text (copy-sequence "secondary island"))
         (node
          (org-element-create
           'unfamiliar-org-node
           (list
            :secondary '(:annotation)
            :annotation (list text)
            :raw-value "meaningful raw value"
            :checked t
            :explicit-nil nil)
           "" "  preserved \n"))
         (model
          (org-texmacs-model-create
           (org-element-create 'org-data nil node)
           :islands (list (cons text '(custom-root "中\\\""))))))
    (should
     (equal
      (org-texmacs-model-inspect model)
      '(org-data
        nil
        (unfamiliar-org-node
         (:annotation
          ((stm (custom-root "中\\\"")))
          :checked t
          :explicit-nil nil
          :raw-value "meaningful raw value")
         "" "  preserved \n"))))))

(ert-deftest
    org-texmacs-model-inspect-supplied-node-islands-hide-old-body-values
    ()
  ;; This valid supplied association need not be expressible by source discovery.
  (let* ((block
          (org-element-create
           'src-block '(:language "scheme" :value "old STM source")))
         (model
          (org-texmacs-model-create
           (org-element-create 'org-data nil block)
           :islands (list (cons block '(math "current"))))))
    (should
     (equal
      (org-texmacs-model-inspect model)
      '(org-data
        nil (src-block (:language "scheme") (stm (math "current"))))))
    (should
     (equal
      (org-element-property
       :value
       (car (org-element-contents (org-texmacs-model-ast model))))
      "old STM source"))))

(ert-deftest
    org-texmacs-model-inspect-autoloads-without-native-consumers
    ()
  (with-temp-buffer
    (let ((status
           (call-process
            (expand-file-name invocation-name invocation-directory)
            nil
            t
            nil
            "-Q"
            "--batch"
            "-L"
            (file-name-directory (locate-library "org"))
            "-L"
            (file-name-directory (locate-library "org-texmacs-model"))
            "--eval"
            (prin1-to-string
             '(progn
                (require 'org-texmacs-model)
                (unless (equal
                         (org-texmacs-model-inspect
                          (org-texmacs-model-create
                           (org-element-create 'org-data nil)))
                         '(org-data nil))
                  (error "Unexpected independent inspection"))
                (dolist (feature
                         '(org-texmacs-document
                           org-texmacs-input
                           ox-texmacs
                           org-texmacs-worker
                           org-texmacs-parse))
                  (when (featurep feature)
                    (error "Unexpected inspection dependency: %S"
                           feature)))
                (princ "inspection-only-ok"))))))
      (should (equal status 0))
      (should
       (string-match-p "inspection-only-ok" (buffer-string))))))

(ert-deftest org-texmacs-model-inspect-properties-order-and-references
    ()
  (let* ((first
          (org-element-create
           'paragraph '(:post-blank 2) "  first \n"))
         (second (org-element-create 'paragraph nil "second"))
         (ast (org-element-create 'org-data nil first second)))
    (org-element-put-property first :related-node second)
    (org-element-put-property second :related-node first)
    (org-element-put-property first :root ast)
    (org-element-put-property first :vector (vector second '(a . b)))
    (org-element-put-property first :begin 9999)
    (org-element-put-property first :org-element--private "hidden")
    (let* ((model (org-texmacs-model-create ast))
           (view (org-texmacs-model-inspect model))
           (properties (cadr (nth 2 view))))
      (should
       (equal
        properties
        '(:post-blank
          2
          :related-node (org-ref (contents 1))
          :root (org-ref nil)
          :vector [(org-ref (contents 1)) (a . b)])))
      (should
       (equal
        (cadr (nth 3 view)) '(:related-node (org-ref (contents 0)))))
      (should (equal (nth 2 (nth 2 view)) "  first \n")))))

(ert-deftest org-texmacs-model-inspect-complete-org-after-source-death
    ()
  (let (model)
    (with-temp-buffer
      (org-mode)
      (insert
       "# Retained comment\n\n* COMMENT Heading :noexport:\n"
       ":PROPERTIES:\n:CUSTOM_PROPERTY: retained\n:END:\n"
       "#+CAPTION[Short]: Long *caption*\n| Data |\n\n"
       "[fn:unused] Footnote with [[https://example.org][description]].\n")
      (setq model
            (org-texmacs-model-create (org-element-parse-buffer))))
    (cl-letf (((symbol-function 'org-texmacs--worker-request)
               (lambda (&rest _)
                 (ert-fail "Inspection requested a worker")))
              ((symbol-function 'org-texmacs--document-lower)
               (lambda (&rest _)
                 (ert-fail "Inspection invoked lowering"))))
      (let ((text
             (prin1-to-string (org-texmacs-model-inspect model))))
        (dolist (literal
                 '("(comment "
                   "(property-drawer "
                   "(node-property "
                   "(footnote-definition "
                   "(table "
                   "(link "
                   "description"
                   "Long "
                   "caption"
                   "Short"))
          (should (string-match-p (regexp-quote literal) text)))))))

(ert-deftest
    org-texmacs-model-inspect-rejects-invalid-parents-with-paths
    ()
  (let* ((model (org-texmacs-test--inspection-model))
         (leaf (caar (org-texmacs-model-islands model))))
    ;; Deliberately violate the read-only contract to exercise diagnostics.
    (org-element-put-property leaf :parent nil)
    (let ((err
           (should-error
            (org-texmacs-model-inspect model)
            :type 'org-texmacs-model-error)))
      (should
       (string-match-p
        "AST path (contents 0 contents 1)"
        (error-message-string err))))
    (should-not (org-element-parent leaf))))

(ert-deftest org-texmacs-model-inspect-rejects-damaged-snapshots ()
  (dolist (damage
           '(duplicate
             detached
             tree
             overlap
             cycle
             shared
             opaque
             property-cycle))
    (let* ((model (org-texmacs-test--inspection-model))
           (ast (org-texmacs-model-ast model))
           (paragraph (car (org-element-contents ast)))
           (mapping (org-texmacs-model-islands model))
           (leaf (caar mapping)))
      (pcase damage
        ('duplicate (setcdr mapping (list (car mapping))))
        ('detached (setcar (car mapping) (copy-sequence leaf)))
        ('tree (setcdr (car mapping) '(math 7)))
        ('overlap
         (setcdr mapping (list (cons paragraph '(math "whole")))))
        ('cycle (setcdr (last ast) (cdr ast)))
        ('shared (org-element-set-contents paragraph leaf leaf))
        ('opaque
         (org-element-put-property paragraph :bad (current-buffer)))
        ('property-cycle
         (let ((cycle (list 'value)))
           (setcdr cycle cycle)
           (org-element-put-property paragraph :bad cycle))))
      (let ((err
             (should-error
              (org-texmacs-model-inspect model)
              :type 'org-texmacs-model-error)))
        (should
         (string-match-p "AST path" (error-message-string err))))))
  (dolist (value '(nil text 3))
    (should-error
     (org-texmacs-model-inspect value)
     :type 'org-texmacs-model-error)))

(ert-deftest org-texmacs-model-display-new-read-only-complete-buffer
    ()
  (let* ((model (org-texmacs-test--inspection-model))
         (existing (generate-new-buffer " *inspection-existing*"))
         (source (current-buffer))
         (print-length 1)
         (print-level 1)
         (change-major-mode-hook
          (list
           (lambda () (ert-fail "Ran display change-mode hook"))))
         (after-change-major-mode-hook
          (list (lambda () (ert-fail "Ran display after-mode hook"))))
         (special-mode-hook
          (list (lambda () (ert-fail "Ran display mode hook"))))
         shown
         result)
    (unwind-protect
        (progn
          (with-current-buffer existing
            (insert "Keep this buffer"))
          (cl-letf (((symbol-function 'display-buffer)
                     (lambda (buffer &rest _) (setq shown buffer))))
            (setq result
                  (org-texmacs-model-display
                   model (buffer-name existing))))
          (should (eq source (current-buffer)))
          (should (eq shown result))
          (should-not (eq result existing))
          (should
           (equal
            (with-current-buffer existing
              (buffer-string))
            "Keep this buffer"))
          (with-current-buffer result
            (should buffer-read-only)
            (should (derived-mode-p 'special-mode))
            (should-not buffer-file-name)
            (should-not (buffer-modified-p))
            (should (= (point) (point-min)))
            (should
             (equal
              (read (buffer-string))
              (org-texmacs-model-inspect model)))))
      (when (buffer-live-p result)
        (kill-buffer result))
      (kill-buffer existing))))

(ert-deftest org-texmacs-model-display-errors-clean-only-new-buffer ()
  (let ((model (org-texmacs-test--inspection-model))
        (generate (symbol-function 'generate-new-buffer)))
    (dolist (operation '(pp special-mode display-buffer))
      (let (created)
        (cl-letf (((symbol-function 'generate-new-buffer)
                   (lambda (&rest args)
                     (setq created (apply generate args))))
                  ((symbol-function operation)
                   (lambda (&rest _)
                     (error "Expected display failure"))))
          (should-error (org-texmacs-model-display model)))
        (should (bufferp created))
        (should-not (buffer-live-p created))))
    (cl-letf (((symbol-function 'generate-new-buffer)
               (lambda (&rest _)
                 (ert-fail "Allocated before validation"))))
      (should-error
       (org-texmacs-model-display nil)
       :type 'org-texmacs-model-error)
      (should-error
       (org-texmacs-model-display model 5)
       :type 'org-texmacs-model-error))))

;;; model-inspect.el ends here
