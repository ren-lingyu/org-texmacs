;;; experiment.el --- E4 island model adapters -*- lexical-binding: t; -*-
(load (expand-file-name "e3-scope.el" (file-name-directory load-file-name)) nil t)
(require 'org-texmacs-model)
(require 'ox)
(require 'org-texmacs-worker)
(require 'org-texmacs-serialize)
(setq org-texmacs-program "/nix/store/axly2kr7x87iflyf6bpp2881wfw2zny4-texmacs-with-gotor-support-2.1.5/bin/texmacs"
      org-texmacs-worker-start-timeout 15 org-texmacs-worker-request-timeout 5)
(defvar e4-direction nil)
(defvar e4-trees nil)
(defvar e4-parse-count 0)
(defun e4-stm-read (source)
  (cl-incf e4-parse-count)
  (org-texmacs--worker-request source))
(defun e4-write-tree (tree)
  "Conservative source generator for this probe; not a full STM serializer."
  (cond ((stringp tree)
         (when (string-match-p "[\n\r\t\0]" tree) (error "unexercised control character"))
         (org-texmacs--scheme-string tree))
        ((and (consp tree) (symbolp (car tree))
              (string-match-p "\\`[A-Za-z][A-Za-z0-9_.*+?!:/<>=-]*\\'"
                              (symbol-name (car tree))))
         (concat "(" (symbol-name (car tree))
                 (mapconcat (lambda (child) (concat " " (e4-write-tree child))) (cdr tree) "")
                 ")"))
        (t (error "STM tree not expressible by probe writer"))))
(defun e4-anchor (post)
  ;; One nonempty placeholder, followed by exactly the fragment's post-blank.
  ;; No raw STM content survives here; island tree is sole authority.
  (concat (string #xfffc) (make-string post ?\s)))
(defun e4-post (anchor)
  (unless (stringp anchor) (error "probe only supports string island anchors"))
  (if (string-match "[ \t]*\\'" anchor) (- (length anchor) (match-beginning 0)) 0))
(defun e4-copy-adapter (original owner old parent)
  (let* ((nodes (org-texmacs--model-owner-nodes owner))
         (entry (assq old e4-trees)))
    (cond
     ((and (eq e4-direction 'forward) (eq (org-element-type old) 'stm-fragment))
      (when (gethash old nodes) (error "multiply owned fragment"))
      (unless (and entry (null (org-element-contents old))) (error "missing parsed fragment tree"))
      (let* ((post (or (org-element-property :post-blank old) 0))
             (new (e4-anchor post)))
        (unless (natnump post) (error "invalid post-blank"))
        (puthash old new nodes)
        (org-element-put-property new :parent parent)
        new))
     ((and (eq e4-direction 'reverse) entry)
      (when (gethash old nodes) (error "multiply owned island"))
      (unless (consp (cdr entry)) (error "atomic STM has no compound fragment representation"))
      (let ((new (org-element-create 'stm-fragment
                                     (list :stm-source (e4-write-tree (cdr entry))
                                           :post-blank (e4-post old) :parent parent))))
        (puthash old new nodes) new))
     (t (funcall original owner old parent)))))
(defun e4-convert-in (ast &optional explicit-trees context)
  (let* ((e4-direction 'forward)
         (e4-trees (or explicit-trees
                       (mapcar (lambda (n) (cons n (e4-stm-read (org-element-property :stm-source n))))
                               (e3-fragments ast)))))
    (advice-add 'org-texmacs--model-copy-node :around #'e4-copy-adapter)
    (unwind-protect
        (org-texmacs-model-create ast :islands e4-trees :context context)
      (advice-remove 'org-texmacs--model-copy-node #'e4-copy-adapter))))
(defun e4-convert-out (model)
  ;; Existing model-copy validates ownership/parent relationships first.
  (let* ((copy (org-texmacs-model-copy model))
         (e4-direction 'reverse)
         (e4-trees (org-texmacs-model-islands copy)))
    (advice-add 'org-texmacs--model-copy-node :around #'e4-copy-adapter)
    (unwind-protect
        ;; Reuse existing owner transaction for AST, captions and context refs.
        (org-texmacs-model-create (org-texmacs-model-ast copy)
                                 :context (org-texmacs-model-context copy))
      (advice-remove 'org-texmacs--model-copy-node #'e4-copy-adapter))))
(defun e4-signature (model)
  (let ((s (org-texmacs--model-snapshot model t)))
    (org-texmacs--serialize-signature (nth 0 s) (nth 1 s) (nth 2 s))))
(defun e4-snap (model)
  (mapcar (lambda (entry)
            (list :anchor (substring-no-properties (car entry))
                  :parent (format "%s" (org-element-type (org-element-parent (car entry))))
                  :tree (format "%S" (cdr entry)))) (org-texmacs-model-islands model)))
(defun e4-no-parsing (fn)
  (cl-letf (((symbol-function 'org-element-parse-buffer)
             (lambda (&rest _) (error "unexpected Org parse")))
            ((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _) (error "unexpected STM parse")))
            ((symbol-function 'org-texmacs--worker-serialize-stm)
             (lambda (&rest _) (error "unexpected reparsing serializer")))
            ((symbol-function 'e3-graph-copy)
             (lambda (&rest _) (error "parallel copier forbidden in E4"))))
    (funcall fn)))
(defun e4-trial (source)
  (e3-scope
   t
   (lambda ()
     (condition-case err
         (let* ((input (e3-parse source))
                (original-signature (format "%S" (e3-signature input)))
                (frags (e3-fragments input))
                (model (e4-convert-in input))
                (before (e4-signature model))
                (copy (e4-no-parsing (lambda () (org-texmacs-model-copy model))))
                (reverse (e4-no-parsing (lambda () (e4-convert-out copy))))
                (back (org-texmacs-model-ast reverse))
                (output (org-element-interpret-data back))
                (again (e4-convert-in (e3-parse output)))
                (replacement (list 'math (copy-sequence "changed")))
                (first (caar (org-texmacs-model-islands model)))
                (changed (and first (e4-no-parsing
                                    (lambda () (org-texmacs-model-replace-stm model first nil replacement)))))
                (old-key-rejected
                 (and first (condition-case nil (progn (org-texmacs-model-island copy first) nil)
                              (org-texmacs-model-error t)))))
           (when changed (setcar (cdr replacement) "external mutation"))
           (list :input source :input-fragments (length frags) :model-islands (e4-snap model)
                 :no-fragment-nodes (null (e3-fragments (org-texmacs-model-ast model)))
                 :model-signature (format "%S" before)
                 :copy-equal (equal before (e4-signature copy))
                 :copy-keys-distinct
                 (cl-every #'identity (cl-mapcar (lambda (x y) (not (eq (car x) (car y))))
                                                 (org-texmacs-model-islands model) (org-texmacs-model-islands copy)))
                 :old-key-rejected old-key-rejected
                 :reverse-fragments (e3-describe back) :output output
                 :roundtrip-equal (equal before (e4-signature again))
                 :roundtrip-signature (format "%S" (e4-signature again))
                 :model-unchanged (equal before (e4-signature model))
                 :input-unchanged (equal original-signature (format "%S" (e3-signature input)))
                 :replacement-owned (and changed (equal (cdar (org-texmacs-model-islands changed)) '(math "changed")))
                 :replacement-output
                 (when changed (org-element-interpret-data (org-texmacs-model-ast
                                                           (e4-no-parsing (lambda () (e4-convert-out changed))))))))
       (error (list :input source :error (error-message-string err)))))))
(let (rows directory)
  (unwind-protect
      (progn
        (org-texmacs--worker-start) (setq directory org-texmacs--worker-directory)
        (dolist (source '("Before $(math \"x\")$  after.\n"
                          "$(math \"x\")$$(math \"y\")$\n"
                          "* Title $(math \"x\")$\nBody.\n"
                          "#+caption[Short $(math \"s\")$]: Long $(math \"l\")$\n| a |\n"
                          "[[https://example.invalid][Before $(math \"x\")$ after]]\n"
                          "Text [fn::$(math \"x\")$] end.\n"
                          "| $(math \"x\")$ | $(math \"y\")$ |\n"
                          "*Before $(math \"x\")$ after.*\n"
                          "\\((custom-tag \"a\\\\)b\")\\) tail\n"))
          (push (e4-trial source) rows))
        (probe-write "results.json" (nreverse rows)))
    (org-texmacs--worker-stop))
  (probe-write "environment.json"
               (list :emacs emacs-version :org (org-version) :org-library (locate-library "org-element")
                     :parse-requests e4-parse-count :worker-live (org-texmacs--worker-live-p)
                     :directory-removed (and directory (not (file-exists-p directory)))
                     :copy-advice-removed (not (advice-member-p #'e4-copy-adapter 'org-texmacs--model-copy-node)))))
(probe-write
 "direct-and-ownership.json"
 (e3-scope
  t
  (lambda ()
    (let* ((payload (list 'math (copy-sequence "authoritative")))
           (fragment (org-element-create 'stm-fragment '(:stm-source "(math \"stale\")" :post-blank 2)))
           (ast (org-element-create 'org-data (list :peer fragment :peer-vector (vector fragment))
                                   (org-element-create 'section nil
                                                       (org-element-create 'paragraph nil "Before " fragment "after.\n"))))
           (model (e4-no-parsing
                   (lambda () (e4-convert-in ast (list (cons fragment payload))
                                            '(:heading-settings ((org-odd-levels-only . nil)))))))
           (key (caar (org-texmacs-model-islands model)))
           (original-signature (e4-signature model))
           (copy (e4-no-parsing (lambda () (org-texmacs-model-copy model))))
           (copy-key (caar (org-texmacs-model-islands copy)))
           (reverse (e4-no-parsing (lambda () (e4-convert-out model))))
           (out-ast (org-texmacs-model-ast reverse))
           (out-fragment (car (e3-fragments out-ast)))
           (nested (e4-no-parsing
                    (lambda () (org-texmacs-model-replace-stm model key '(0) "nested-change")))))
      ;; Constructor must own all mutable caller inputs.
      (aset (cadr payload) 0 ?X)
      (org-element-put-property fragment :stm-source "(math \"caller changed\")")
      (org-element-put-property ast :peer nil)
      (list :tree-authoritative (equal (org-texmacs-model-island model key) '(math "authoritative"))
            :caller-mutation-isolated (equal original-signature (e4-signature model))
            :model-peer-remapped (eq key (org-element-property :peer (org-texmacs-model-ast model)))
            :model-vector-peer-remapped (eq key (aref (org-element-property :peer-vector (org-texmacs-model-ast model)) 0))
            :copy-peer-remapped (eq copy-key (org-element-property :peer (org-texmacs-model-ast copy)))
            :copy-tree-distinct (not (eq (cdr (car (org-texmacs-model-islands model)))
                                         (cdr (car (org-texmacs-model-islands copy)))))
            :copy-context-distinct (not (eq (org-texmacs-model-context model) (org-texmacs-model-context copy)))
            :copy-mutation-isolated
            (progn
              (aset (cadr (org-texmacs-model-island copy copy-key)) 0 ?Z)
              (equal original-signature (e4-signature model)))
            :reverse-peer-remapped (eq out-fragment (org-element-property :peer out-ast))
            :reverse-vector-peer-remapped (eq out-fragment (aref (org-element-property :peer-vector out-ast) 0))
            :reverse-output (org-element-interpret-data out-ast)
            :nested-replacement (equal (cdar (org-texmacs-model-islands nested)) '(math "nested-change"))
            :nested-peer-remapped (eq (caar (org-texmacs-model-islands nested))
                                     (org-element-property :peer (org-texmacs-model-ast nested)))
            :original-after-replacement (equal original-signature (e4-signature model))
            :invalid-path-rejected
            (condition-case nil (progn (org-texmacs-model-replace-stm model key '(9) "bad") nil)
              (org-texmacs-model-error t))
            :invalid-replacement-unchanged (equal original-signature (e4-signature model)))))))
(probe-write
 "atomic-and-failure.json"
 (e3-scope
  t
  (lambda ()
    (let* ((anchor (e4-anchor 0))
           (ast (org-element-create 'org-data nil
                                   (org-element-create 'section nil
                                                       (org-element-create 'paragraph nil anchor))))
           (model (e4-no-parsing (lambda () (org-texmacs-model-create ast :islands (list (cons anchor "V"))))))
           (signature (e4-signature model))
           (copy (e4-no-parsing (lambda () (org-texmacs-model-copy model)))) error-result)
      (condition-case e (e4-no-parsing (lambda () (e4-convert-out model)))
        (error (setq error-result (error-message-string e))))
      (list :atomic-model-valid (equal (cdar (org-texmacs-model-islands model)) "V")
            :copy-valid (equal signature (e4-signature copy))
            :representation-error error-result
            :model-unchanged (equal signature (e4-signature model))
            :still-copyable-after-error (equal signature (e4-signature (org-texmacs-model-copy model)))
            :copy-hook-removed (not (advice-member-p #'e4-copy-adapter 'org-texmacs--model-copy-node))
            :atomic-replacement-valid
            (let* ((compound (org-texmacs-model-replace-stm model (caar (org-texmacs-model-islands model)) nil '(math "ok")))
                   (atomic (org-texmacs-model-replace-stm compound (caar (org-texmacs-model-islands compound)) nil "atomic")))
              (equal (cdar (org-texmacs-model-islands atomic)) "atomic")))))))
(probe-write
 "caption-parent-guard.json"
 (e3-scope
  t
  (lambda ()
    (let* ((f (org-element-create 'stm-fragment '(:stm-source "(math \"caption\")")))
           (table (org-element-create 'table (list :caption (list (cons (list f) nil)))
                                      (org-element-create 'table-row '(:type standard)
                                                          (org-element-create 'table-cell nil "A"))))
           (ast (org-element-create 'org-data nil (org-element-create 'section nil table)))
           (model (e4-no-parsing (lambda () (e4-convert-in ast (list (cons f '(math "caption")))))))
           (copy (org-texmacs-model-copy model))
           (key (caar (org-texmacs-model-islands copy)))
           (before (e4-signature model))
           (owner-type (org-element-type (org-element-parent key))))
      ;; Damage only an expendable copy to confirm the existing model guard.
      (org-element-put-property key :parent nil)
      (list :normalized-parent (symbol-name owner-type)
            :damaged-parent-rejected
            (condition-case nil (progn (org-texmacs-model-copy copy) nil)
              (org-texmacs-model-error t))
            :original-unchanged (equal before (e4-signature model)))))))
(princ "E4 complete\n")
