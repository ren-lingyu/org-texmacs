;;; experiment.el --- E3 extended AST experiment -*- lexical-binding: t; -*-
(load (expand-file-name "support.el" (file-name-directory load-file-name)) nil t)
(load (expand-file-name "recognition.el" (file-name-directory load-file-name)) nil t)
(require 'cl-lib)
(defvar e3-active nil)
(defvar e3-base-objects org-element-all-objects)
(defvar e3-base-restrictions org-element-object-restrictions)
(defvar e3-ep-calls nil)
(defun e3-parser (old &rest args)
  (if e3-active (apply #'ep-parser old args) (apply old args)))
(defun e3-interpreter (node _contents)
  (let ((source (org-element-property :stm-source node)))
    (unless (stringp source) (error "missing STM source"))
    (concat "\\(" source "\\)")))
(defun e3-scope (register thunk)
  (let* ((e3-active t)
         (ep-calls nil)
         (org-element-all-objects
          (if register (cons 'stm-fragment org-element-all-objects)
            org-element-all-objects))
         (org-element-object-restrictions
          (if register
              (mapcar (lambda (entry)
                        (if (memq 'latex-fragment (cdr entry))
                            (cons (car entry) (cons 'stm-fragment (cdr entry)))
                          entry)) org-element-object-restrictions)
            org-element-object-restrictions))
         (owned (not (advice-member-p #'e3-parser 'org-element-latex-fragment-parser))))
    (when owned (advice-add 'org-element-latex-fragment-parser :around #'e3-parser))
    (unwind-protect
        (cl-letf (((symbol-function 'org-element-stm-fragment-interpreter) #'e3-interpreter))
          (funcall thunk))
      (when owned (advice-remove 'org-element-latex-fragment-parser #'e3-parser)))))
(defun e3-parse (source)
  (with-temp-buffer (org-mode) (insert source) (org-element-parse-buffer)))
(defun e3-fragments (ast)
  (org-element-map ast 'stm-fragment #'identity nil nil nil t))
(defun e3-payloads (ast)
  (mapcar (lambda (n) (org-element-property :stm-source n)) (e3-fragments ast)))
(defun e3-describe (ast)
  (mapcar
   (lambda (n)
     (list :source (org-element-property :stm-source n)
           :begin (org-element-property :begin n) :end (org-element-property :end n)
           :post-blank (org-element-property :post-blank n)
           :parent (format "%s" (org-element-type (org-element-property :parent n)))
           :secondary (format "%s" (org-element-secondary-p n))
           :class (format "%s" (org-element-class n))
           :children (length (org-element-contents n)))) (e3-fragments ast)))
(defun e3-normal-text (s)
  (string-trim (replace-regexp-in-string "[ \t\n]+" " " (substring-no-properties s))))
(defun e3-graph-copy (value &optional memo)
  "Copy the explicit Org AST graph, remapping internal identity references."
  (let* ((memo (or memo (make-hash-table :test #'eq)))
         (known (gethash value memo)))
    (or known
        (cond
         ((stringp value)
          (let ((out (substring-no-properties value)) (i 0))
            (puthash value out memo)
            (while (< i (length value))
              (let ((end (next-property-change i value (length value))))
                (set-text-properties i end (e3-graph-copy (text-properties-at i value) memo) out)
                (setq i end))) out))
         ((consp value)
          (let ((out (cons nil nil)))
            (puthash value out memo)
            (setcar out (e3-graph-copy (car value) memo))
            (setcdr out (e3-graph-copy (cdr value) memo)) out))
         ((vectorp value)
          (let ((out (make-vector (length value) nil)))
            (puthash value out memo)
            (dotimes (i (length value)) (aset out i (e3-graph-copy (aref value i) memo))) out))
         (t value)))))
(defun e3-signature (data)
  ;; Positions, raw delimiter spelling and Org's normalized layout are not
  ;; semantic identity. Preserve exact STM source; full tree signatures are E4/5.
  (cond ((null data) nil)
        ((stringp data) (e3-normal-text data))
        ((not (consp data)) data)
        ((and (symbolp (car data)) (org-element-type data))
         (let* ((type (org-element-type data)) props)
           (dolist (key '(:level :raw-link :type :value :stm-source :title :caption))
             (let ((value (org-element-property key data)))
               (when value
                 (push (cons key (if (eq key :stm-source) value
                                   (e3-signature value))) props))))
           ;; STM value includes original carrier, excluded from signature.
           (when (eq type 'stm-fragment) (setq props (assq-delete-all :value props)))
           (list type (nreverse props) (mapcar #'e3-signature (org-element-contents data)))))
        (t (cons (e3-signature (car data)) (e3-signature (cdr data))))))
(defun e3-trial (source registered cache)
  (let ((org-element-use-cache cache))
    (e3-scope
     registered
     (lambda ()
       (condition-case err
           (let* ((a (e3-parse source))
                  (before (prin1-to-string (e3-signature a)))
                  (copy (org-element-copy a t))
                  (graph (e3-graph-copy a))
                  (out (org-element-interpret-data a))
                  (b (e3-parse out))
                  (out2 (org-element-interpret-data b))
                  (copy-out (org-element-interpret-data copy)))
             (list :registered registered :cache cache :input source
                   :fragments (e3-describe a) :copy-fragments (e3-describe copy)
                   :graph-fragments (e3-describe graph)
                   :native-copy-distinct
                   (cl-mapcar (lambda (x y) (not (eq x y))) (e3-fragments a) (e3-fragments copy))
                   :graph-copy-distinct
                   (cl-mapcar (lambda (x y) (not (eq x y))) (e3-fragments a) (e3-fragments graph))
                   :graph-source-distinct
                   (cl-mapcar (lambda (x y) (not (eq (org-element-property :stm-source x)
                                                    (org-element-property :stm-source y))))
                              (e3-fragments a) (e3-fragments graph))
                   :graph-parents-remapped
                   (cl-mapcar (lambda (x y)
                                (let ((px (org-element-parent x)) (py (org-element-parent y)))
                                  (if px (and py (not (eq px py))) (not py))))
                              (e3-fragments a) (e3-fragments graph))
                   :graph-output-equal (equal out (org-element-interpret-data graph))
                   :output out :output2 out2 :copy-output copy-out
                   :payloads-preserved (equal (e3-payloads a) (e3-payloads b))
                   :signature-equal (equal (e3-signature a) (e3-signature b))
                   :idempotent (equal out out2)
                   :copy-output-equal (equal out copy-out)
                   :source-ast-unchanged (equal before (prin1-to-string (e3-signature a)))
                   :signature-before (format "%S" (e3-signature a))
                   :signature-after (format "%S" (e3-signature b))))
         (error (list :input source :registered registered :cache cache
                      :error (error-message-string err))))))))
(let (rows)
  (dolist (registered '(nil t))
    (dolist (cache '(nil t))
      (dolist (source '("Before $(math \"x\")$  after.\n"
                        "$(math \"x\")$$(concat \"y\")$\n"
                        "*Consider $(math \"x\")$ here.*\n"
                        "* Title $(math \"x\")$ and *bold*\nBody.\n"
                        "#+caption: Before $(math \"x\")$ after\n| a |\n"
                        "#+caption[Short $(math \"s\")$]: Long $(math \"l\")$\n| a |\n"
                        "[[https://example.invalid][Before $(math \"x\")$ after]]\n"
                        "Text [fn::Before $(math \"x\")$ after] end.\n"
                        "| Before $(math \"x\")$ after | B |\n"
                        "\\((math \"a\\\\)b\")\\) *after*\n"
                        "~$(math #bad)$~ and =$bad=\n"
                        "$(custom-tag \"x\")$\n"))
        (push (e3-trial source registered cache) rows))))
  (probe-write "roundtrip.json" (nreverse rows)))
;; Independent AST construction: no source parser, no complete STM model.
(probe-write
 "construction.json"
 (e3-scope
  t
  (lambda ()
    (let* ((node (org-element-create 'stm-fragment
                                     '(:stm-source "(custom-tag \"direct\")" :post-blank 2)))
           (ast (org-element-create 'org-data nil
                                   (org-element-create 'section nil
                                                       (org-element-create 'paragraph nil
                                                                           "Before " node "after.\n"))))
           (out (org-element-interpret-data ast))
           (parsed (e3-parse out)))
      (list :output out :fragments (e3-describe ast)
            :reparsed (e3-describe parsed)
            :payloads-equal (equal (e3-payloads ast) (e3-payloads parsed)))))))
(probe-write
 "scope.json"
 (list :objects-restored (equal org-element-all-objects e3-base-objects)
       :restrictions-restored (equal org-element-object-restrictions e3-base-restrictions)
       :advice-removed (not (advice-member-p #'e3-parser 'org-element-latex-fragment-parser))
       :interpreter-restored (not (fboundp 'org-element-stm-fragment-interpreter))
       :ordinary-after (probe-parse "$(math \"x\")$\n")
       :nested
       (e3-scope t
                 (lambda ()
                   (let* ((before (e3-payloads (e3-parse "$(math \"outer\")$\n")))
                          (ordinary (let ((e3-active nil)
                                          (org-element-all-objects e3-base-objects)
                                          (org-element-object-restrictions e3-base-restrictions))
                                      (probe-parse "$(math \"inner\")$\n")))
                          (after (e3-payloads (e3-parse "$(math \"outer\")$\n"))))
                     (list :before before :ordinary ordinary :after after))))
       :emacs emacs-version :org (org-version) :org-library (locate-library "org-element")
       :worker-process (bound-and-true-p org-texmacs--worker-process)))
(probe-write
 "copy-and-cache.json"
 (e3-scope
  t
  (lambda ()
    (let* ((source "* Title $(math \"title\")$\n#+caption[Short $(math \"short\")$]: Long $(math \"long\")$\n| $(math \"cell\")$ |\n\n[[https://example.invalid][$(math \"link\")$]]\n")
           (a (e3-parse source)) (copy (e3-graph-copy a))
           (before (org-element-interpret-data a))
           (nodes (e3-fragments copy)))
      (dolist (n nodes)
        (org-element-put-property n :stm-source "(math \"changed\")"))
      (let ((changed (org-element-interpret-data copy)))
        (list :independent-mutation (equal before (org-element-interpret-data a))
              :changed-output changed
              :changed-payload-count (length (e3-fragments (e3-parse changed)))
              :expected-count (length nodes)
              :new-payloads (e3-payloads (e3-parse changed))
              :copy-parent-descriptions (e3-describe copy)
              :native-copy-control
              (let* ((e3-active nil)
                     (native (e3-parse "#+caption: $x$\n| $y$ |\n"))
                     (nc (org-element-copy native t))
                     (ns (org-element-map native 'latex-fragment #'identity nil nil nil t))
                     (cs (org-element-map nc 'latex-fragment #'identity nil nil nil t)))
                (cl-mapcar (lambda (x y)
                             (list :distinct (not (eq x y))
                                   :original-parent (format "%s" (org-element-type (org-element-parent x)))
                                   :copy-parent (format "%s" (org-element-type (org-element-parent y))))) ns cs))))))))
(probe-write
 "live-cache.json"
 (with-temp-buffer
   (org-mode) (setq-local org-element-use-cache t)
   (insert "Before $(math \"x\")$ after.\n")
   (goto-char 10)
   (let ((before (org-element-type (org-element-context))) during after edited)
     (e3-scope t (lambda () (setq during (org-element-type (org-element-context)))))
     (setq after (org-element-type (org-element-context)))
     (goto-char (point-min)) (search-forward "\"x\"") (replace-match "\"y\"" t t)
     (goto-char 10)
     (e3-scope t (lambda () (setq edited (org-element-property :stm-source (org-element-context)))))
     (list :before (format "%s" before) :during (format "%s" during)
           :after (format "%s" after) :edited edited))))
(probe-write
 "direct-secondary.json"
 (e3-scope
  t
  (lambda ()
    (let* ((title (org-element-create 'stm-fragment '(:stm-source "(math \"title\")")))
           (caption (org-element-create 'stm-fragment '(:stm-source "(math \"caption\")")))
           (description (org-element-create 'stm-fragment '(:stm-source "(math \"link\")")))
           (head (org-element-create 'headline (list :level 1 :title (list "Title " title))))
           (table (org-element-create 'table (list :caption (list (cons (list "Caption " caption) nil)))
                                      (org-element-create 'table-row '(:type standard)
                                                          (org-element-create 'table-cell nil "A"))))
           (link (org-element-create 'link '(:type "https" :path "//example.invalid" :raw-link "https://example.invalid") description))
           (ast (org-element-create 'org-data nil head
                                    (org-element-create 'section nil table
                                                        (org-element-create 'paragraph nil link))))
           (out (org-element-interpret-data ast))
           (back (e3-parse out)))
      (list :output out :reparsed-payloads (e3-payloads back)
            :reparsed (e3-describe back)
            :idempotent (equal out (org-element-interpret-data back)))))))
(let ((failed nil))
  (condition-case nil (e3-scope t (lambda () (error "intentional cleanup probe")))
    (error (setq failed t)))
  (probe-write "error-cleanup.json"
               (list :error-observed failed
                     :objects-restored (equal e3-base-objects org-element-all-objects)
                     :restrictions-restored (equal e3-base-restrictions org-element-object-restrictions)
                     :advice-removed (not (advice-member-p #'e3-parser 'org-element-latex-fragment-parser))
                     :interpreter-restored (not (fboundp 'org-element-stm-fragment-interpreter)))))
(princ "E3 completed\n")
