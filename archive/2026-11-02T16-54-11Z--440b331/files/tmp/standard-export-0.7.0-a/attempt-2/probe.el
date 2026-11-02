;;; probe.el --- Stage A isolated hypotheses -*- lexical-binding: t; -*-
(require 'ox)
(require 'oc-basic)
(require 'org-texmacs-model)

(defvar a--events nil)
(defvar a--capture nil)
(defvar a--mode 'inspect)
(defvar a--transaction nil)
(defvar a--shape 'element)
(defvar a--nested nil)
(defvar a--coding 'iso-latin-1-unix)

(defun a--event (event) (push event a--events))
(defun a--before (backend) (a--event (list 'before backend)))
(defun a--parsing (backend) (a--event (list 'parsing backend)))
(defun a--ast (tree backend info)
  (a--event (list 'ast backend (plist-get info :back-end))) tree)
(defun a--plain (text _info) (a--event 'plain) text)
(defun a--contents (_node contents _info) (a--event 'transcode) contents)
(defun a--noop (text _backend _info) text)
(defun a--post (text _backend _info) (a--event 'post) text)
(defun a--changed (text _backend _info) (concat text "changed"))

(defun a--resolve (tree)
  ;; Discover whether ordinary Org mapping resolves enough for the existing
  ;; strict snapshot owner. No source reconstruction or Org preparation copy.
  (org-element-map tree t #'identity nil nil nil t)
  tree)

(defun a--inner (_contents info)
  (a--event 'inner)
  (let* ((tree (a--resolve (plist-get info :parse-tree)))
         (model (org-texmacs-model-create tree))
         (types (org-element-map tree t #'org-element-type))
         (document
          (when (memq a--mode '(text document pdf))
            (org-texmacs-document
             (org-texmacs-input-create
              (org-texmacs-model-ast model)
              '(:with-title nil :with-author nil :with-date nil :with-toc nil
                :section-numbers nil :headline-levels 3)))))
         (result (list :model model :document document :types types
                       :backend (org-export-backend-name
                                 (plist-get info :back-end)))))
    (when a--nested
      (let ((a--nested nil) (a--mode 'inspect) (a--capture nil)
            (a--transaction nil))
        (with-temp-buffer
          (org-mode) (insert "Inner document\n")
          (should (stringp (org-export-as 'texmacs))))))
    (setq a--capture result)
    (when (memq a--mode '(document pdf))
      ;; Hypothesis: a per-call container hands off the document, while a normal
      ;; empty string return preserves export advice completion. Only compatible
      ;; effective string callbacks may see that internal consumer's empty tail.
      (dolist (key '(:filter-body :filter-final-output))
        (unless (cl-every (lambda (f) (eq f #'a--noop)) (plist-get info key))
          (error "Unproven effective output callback: %S" key)))
      (when-let* ((processor (org-cite-get-processor (org-cite-processor info))))
        (when (org-cite-processor-export-finalizer processor)
          (error "Unproven effective Cite finalizer")))
      (setf (plist-get a--transaction :result) result))
    (if (memq a--mode '(document pdf)) ""
      (if (eq a--mode 'text)
        (let* ((bytes (org-texmacs-document-serialize document))
               (text (decode-coding-string bytes a--coding)))
          (should (equal bytes (encode-coding-string text a--coding)))
          (plist-put a--capture :bytes bytes)
          text)
        "probe output\n"))))

(defun a--export-structured (mode)
  (let* ((a--mode mode)
         (a--transaction (list :tag (make-symbol "a-result"))))
    (should (stringp (org-export-as 'texmacs)))
    (or (plist-get a--transaction :result)
        (error "No structured result delivered"))))

(defun a--cite (_cite _style backend info)
  (a--event (list 'cite (org-export-backend-name backend)))
  (pcase a--shape
    ('string "TARGET-CODE")
    ('element (org-element-create 'bold nil "Structured"))
    ('secondary (list "Prefix " (org-element-create 'italic nil "Structured")))
    ('reentrant (org-export-data
                 (org-element-create 'bold nil "Reentrant") info))))
(defun a--bibliography (_keys _files _style _props _backend _info)
  (a--event 'bibliography)
  (org-element-create 'paragraph nil "Structured bibliography"))
(org-cite-register-processor 'a-probe
  :export-citation #'a--cite :export-bibliography #'a--bibliography
  :cite-styles '((("nil"))))

(defmacro a--environment (&rest body)
  `(let ((org-export-before-processing-functions
          (cons #'a--before
                (remove #'org-texmacs--export-reject-generic-preprocessing
                        (remove #'org-texmacs--preprocess-reject-generic
                                org-export-before-processing-functions))))
         (org-export-before-parsing-functions (list #'a--parsing))
         (org-export-filter-parse-tree-functions (list #'a--ast))
         (org-export-filter-final-output-functions nil)
         (org-export-filter-body-functions nil)
         (org-export-use-babel nil)
         (a--events nil) (a--capture nil) (a--mode 'inspect))
     ;; All test cases execute in an isolated batch Emacs. Replacement does not
     ;; affect project source or original maintained frontend tests.
     (org-export-define-backend
      'texmacs
      '((plain-text . a--plain) (section . a--contents)
        (paragraph . a--contents) (headline . a--contents)
        (bold . a--contents) (italic . a--contents)
        (inner-template . a--inner)))
     ,@body))

(ert-deftest a-01-real-identity-order-and-model ()
  (a--environment
   (with-temp-buffer
     (org-mode) (insert "Plain *Org* document.\n")
     (should (stringp (org-export-as 'texmacs)))
     (should (org-texmacs-model-p (plist-get a--capture :model)))
     (should (eq (plist-get a--capture :backend) 'texmacs))
     (should (= 1 (cl-count 'inner a--events)))
     (should (= 1 (cl-count 'before a--events :key #'car-safe)))
     (should (= 1 (cl-count 'ast a--events :key #'car-safe)))
     (should (memq 'transcode (reverse (cdr (memq 'inner a--events)))))
     (princ (format "ORDER %S\n" (reverse a--events))))))

(ert-deftest a-02-cite-return-matrix ()
  (a--environment
   (dolist (a--shape '(string element secondary reentrant))
     (let ((a--events nil))
       (with-temp-buffer
         (org-mode)
         (insert "#+cite_export: a-probe\nCitation [cite:@key].\n#+print_bibliography:\n")
         (org-export-as 'texmacs)
         (let ((types (plist-get a--capture :types)))
           (should (= 1 (cl-count 'cite a--events :key #'car-safe)))
           (should (= 1 (cl-count 'bibliography a--events)))
           (should-not (memq 'citation types))
           (if (memq a--shape '(string reentrant))
               (should (memq 'raw types))
             (should-not (memq 'raw types)))
           (princ (format "CITE %S => %S\n" a--shape types))))))))

(ert-deftest a-03-basic-emits-raw ()
  (a--environment
   (let* ((file (make-temp-file "basic-" nil ".bib"
                               "@book{k,author={Doe, Jane},title={A title},year={2026}}\n")))
     (unwind-protect
         (with-temp-buffer
           (org-mode)
           (insert (format "#+bibliography: %s\n#+cite_export: basic\n[cite:@k]\n#+print_bibliography:\n" file))
           (org-export-as 'texmacs)
           (should (memq 'raw (plist-get a--capture :types)))
           (princ (format "BASIC %S\n" (plist-get a--capture :types))))
       (delete-file file)))))

(ert-deftest a-04-structured-nesting-cleanup ()
  (org-texmacs-test--with-worker
   (a--environment
    (with-temp-buffer
      (org-mode) (insert "Outer document\n")
      (let* ((a--nested t)
             (result (a--export-structured 'document)))
        (should (org-texmacs-document-p (plist-get result :document)))
        (should (= 2 (cl-count 'inner a--events)))
        (should (= 2 (cl-count 'before a--events :key #'car-safe)))
        (should-not a--transaction)
        (should (string-match-p "Outer" (prin1-to-string
                                         (org-texmacs-document-body
                                          (plist-get result :document))))))))))

(ert-deftest a-05-text-file-bytes-unicode ()
  (org-texmacs-test--with-worker
   (a--environment
    (with-temp-buffer
      (org-mode) (insert "Unicode 中文 α é and literal <alpha>.\n")
      (let* ((a--mode 'text)
             (text (org-export-as 'texmacs))
             (bytes (plist-get a--capture :bytes))
             (target (expand-file-name "output.tm" default-directory))
             (org-export-coding-system a--coding))
        (should (string-match-p "<TeXmacs|" text))
        (org-export-to-file 'texmacs target)
        (with-temp-buffer
          (set-buffer-multibyte nil) (insert-file-contents-literally target)
          (should (equal (concat bytes "\n") (buffer-string))))
        (should-not (cl-some (lambda (c) (> c #x10ffff)) text))
        (princ (format "BYTES latin1-roundtrip=%S high-bytes=%S\n"
                       (equal bytes (encode-coding-string text a--coding))
                       (cl-count-if (lambda (c) (> c 127)) bytes))))))))

(defun a--normal-return-advice (function &rest args)
  (unwind-protect
      (prog1 (apply function args) (a--event 'normal-return))
    (a--event 'unwind)))

(ert-deftest a-08-normal-return-and-exception-isolation ()
  (a--environment
   (advice-add 'org-export-as :around #'a--normal-return-advice)
   (unwind-protect
       (with-temp-buffer
         (org-mode) (insert "Structured result\n")
         (should (plist-get (a--export-structured 'document) :document))
         (should (= 1 (cl-count 'normal-return a--events)))
         (should (= 1 (cl-count 'unwind a--events)))
         (let ((org-export-filter-final-output-functions (list #'a--changed)))
           (should-error (a--export-structured 'pdf)))
         (should (= 1 (cl-count 'normal-return a--events)))
         (should (= 2 (cl-count 'unwind a--events)))
         (should-not a--transaction)
         (should (plist-get (a--export-structured 'document) :document))
         (should (= 2 (cl-count 'normal-return a--events))))
     (advice-remove 'org-export-as #'a--normal-return-advice))))

(ert-deftest a-09-basic-raw-lowering-boundary ()
  (a--environment
   (let ((a--shape 'string) (a--mode 'document)
         (a--transaction (list :tag (make-symbol "a-result"))))
     (with-temp-buffer
       (org-mode) (insert "#+cite_export: a-probe\n[cite:@key]\n")
       (should-error (org-export-as 'texmacs)
                     :type 'org-texmacs-document-error)))))

(ert-deftest a-10-structured-processor-document-and-coding-reload ()
  (org-texmacs-test--with-worker
   (a--environment
    (with-temp-buffer
      (org-mode)
      (insert "#+cite_export: a-probe\n[cite:@key]\n#+print_bibliography:\n")
      (let ((a--shape 'element))
        (should (plist-get (a--export-structured 'document) :document))))
    (let ((script (expand-file-name "probe-coding.scm" test-directory)))
      (with-temp-file script
        (insert (format "(load %s)\n"
                        (org-texmacs--scheme-string org-texmacs--worker-scheme-file))
                "(define a-native-serialize serialize-texmacs)\n"
                "(set! serialize-texmacs (lambda (file)\n"
                " (let* ((bytes (a-native-serialize file))\n"
                "        (readback (parse-texmacs (string-append bytes \"\\n\"))))\n"
                " (if (not (equal? (tree->stree file) (tree->stree readback)))\n"
                "     (error \"Terminal newline changed native semantics\")) bytes)))\n"))
      (let* ((org-texmacs--worker-scheme-file script)
             (document (org-texmacs--document-create
                        :body '(document "Café 中 α <alpha>")))
             (bytes (org-texmacs-document-serialize document))
             (utf8 (decode-coding-string bytes 'utf-8-unix))
             (latin1 (decode-coding-string bytes 'iso-latin-1-unix)))
        (should (cl-some (lambda (c) (> c #x10ffff)) utf8))
        (should-not (cl-some (lambda (c) (> c #x10ffff)) latin1))
        (should (equal bytes (encode-coding-string latin1 'iso-latin-1-unix)))
        (princ "NATIVE terminal-newline-semantic-roundtrip=ok; utf8-raw-octets=present; latin1-reversible=ok\n"))))))

(ert-deftest a-06-pdf-direct-and-effective-filters ()
  (org-texmacs-test--with-worker
   (a--environment
    (with-temp-buffer
      (org-mode) (insert "Native PDF document.\n")
      (let* ((org-export-filter-final-output-functions (list #'a--noop))
             (result (a--export-structured 'pdf))
             (pdf (org-texmacs-document-pdf (plist-get result :document))))
        (should (string-prefix-p "%PDF-" pdf))
        (should-not (multibyte-string-p pdf)))
      (let ((org-export-filter-final-output-functions (list #'a--changed)))
        (should-error (a--export-structured 'pdf)))
      (should-not a--transaction)
      (let ((org-export-filter-final-output-functions (list #'a--post)))
        (org-export-as 'texmacs)
        (should (= 1 (cl-count 'post a--events))))))))

(ert-deftest a-07-other-backend-still-works ()
  (a--environment
   (require 'ox-ascii)
   (with-temp-buffer
     (org-mode) (insert "Unrelated exporter\n")
     (should (string-match-p "Unrelated exporter" (org-export-as 'ascii))))))
