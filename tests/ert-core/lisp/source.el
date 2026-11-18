;;; source.el --- core source regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-test-stree-org-round-trip ()
  (let* ((mode (copy-sequence "mode"))
         (math (copy-sequence "math"))
         (sum (copy-sequence "x+"))
         (numerator (copy-sequence "1"))
         (denominator (copy-sequence "2"))
         (stree
          (list
           'with mode math
           (list 'concat sum (list 'frac numerator denominator))))
         (tree (org-texmacs--stree-to-org stree))
         (round-trip (org-texmacs--org-to-stree tree)))
    (should (equal round-trip stree))
    (dolist (string (list mode math sum numerator denominator))
      (should-not (text-properties-at 0 string)))
    (dolist (string
             (list
              (nth 1 round-trip)
              (nth 2 round-trip)
              (nth 1 (nth 3 round-trip))
              (nth 1 (nth 2 (nth 3 round-trip)))
              (nth 2 (nth 2 (nth 3 round-trip)))))
      (should-not (text-properties-at 0 string)))))

(ert-deftest org-texmacs-test-stree-to-org-copies-strings ()
  (let* ((source (copy-sequence "1"))
         (tree (org-texmacs--stree-to-org (list 'frac source "2")))
         (converted (car (org-element-contents tree))))
    (should (equal converted source))
    (should-not (eq converted source))
    (should-not (text-properties-at 0 source))))

(ert-deftest org-texmacs-test-stree-to-org-builds-parent-links ()
  (let* ((tree
          (org-texmacs--stree-to-org
           '(with "mode" "math" (concat "x+" (frac "1" "2")))))
         (root-contents (org-element-contents tree))
         (mode (nth 0 root-contents))
         (math (nth 1 root-contents))
         (concat-node (nth 2 root-contents))
         (concat-contents (org-element-contents concat-node))
         (sum (nth 0 concat-contents))
         (frac-node (nth 1 concat-contents))
         (frac-contents (org-element-contents frac-node)))
    (should (eq (org-element-property :parent mode) tree))
    (should (eq (org-element-property :parent math) tree))
    (should (eq (org-element-property :parent concat-node) tree))
    (should (eq (org-element-property :parent sum) concat-node))
    (should (eq (org-element-property :parent frac-node) concat-node))
    (dolist (string frac-contents)
      (should (eq (org-element-property :parent string) frac-node)))))

(ert-deftest org-texmacs-block-case-markers-and-raw-source ()
  (dolist (fold '(nil t))
    (dolist (begin '("begin" "BEGIN" "BeGiN"))
      (dolist (type '("texmacs" "TEXMACS" "TeXmAcS"))
        (dolist (end '("end" "END" "EnD"))
          (dolist (end-type '("texmacs" "TEXMACS" "TeXmAcS"))
            (with-temp-buffer
              (org-mode)
              (let ((body "(math (concat \"MiXeD α\" \"<alpha>\"))\n")
                    (case-fold-search fold))
                (insert
                 (format "#+%s_%s\n%s#+%s_%s\n"
                         begin
                         type
                         body
                         end
                         end-type))
                (goto-char (point-min))
                (let ((block (org-element-at-point))
                      (text (buffer-string))
                      (tick (buffer-modified-tick)))
                  (should (org-texmacs--block-p block))
                  (should
                   (equal (org-element-property :type block) type))
                  (should
                   (equal (org-texmacs--block-source block) body))
                  (should
                   (equal (org-element-property :type block) type))
                  (should (equal (buffer-string) text))
                  (should (= (point) (point-min)))
                  (should (= (buffer-modified-tick) tick))
                  (should (eq case-fold-search fold)))))))))))

(ert-deftest org-texmacs-source-location-owned-pure-input ()
  (let* ((file
          (propertize (copy-sequence "/source/notes.org")
                      'face
                      'bold))
         (directory (copy-sequence "/resources/link/../base/"))
         (ast
          (org-element-create
           'org-data nil
           (org-element-create 'paragraph nil "Text")))
         (input
          (org-texmacs-input-create
           ast
           nil
           :source-file file
           :resource-base directory))
         first)
    (aset file 1 ?X)
    (aset directory 1 ?X)
    (let ((default-directory "/unrelated/"))
      (cl-letf (((symbol-function 'buffer-substring-no-properties)
                 (lambda (&rest _)
                   (ert-fail "Unexpected buffer read"))))
        ;; Install the sentinel after function rebinding: native compilation's
        ;; trampoline setup may itself consult file handlers.
        (let ((file-name-handler-alist
               '(("." .
                  (lambda (&rest _)
                    (ert-fail "Unexpected file handler"))))))
          (setq first (org-texmacs-document input)))))
    (should
     (equal
      (org-texmacs-document-source-file first) "/source/notes.org"))
    (should
     (equal
      (org-texmacs-document-resource-base first)
      "/resources/link/../base/"))
    (should-not
     (text-properties-at 0 (org-texmacs-input-source-file input)))
    (should-not
     (eq
      (org-texmacs-input-resource-base input)
      (org-texmacs-document-resource-base first)))
    (should-not
     (eq
      (org-texmacs-input-source-file input)
      (org-texmacs-document-source-file first)))
    (aset (org-texmacs-document-resource-base first) 1 ?X)
    (aset (org-texmacs-document-source-file first) 1 ?X)
    (should
     (equal
      (org-texmacs-document-source-file
       (org-texmacs-document input))
      "/source/notes.org"))
    (should
     (equal
      (org-texmacs-document-resource-base
       (org-texmacs-document input))
      "/resources/link/../base/"))
    (let ((unspecified
           (org-texmacs-document (org-texmacs-input-create ast nil))))
      (should-not (org-texmacs-document-source-file unspecified))
      (should-not (org-texmacs-document-resource-base unspecified)))))

(ert-deftest org-texmacs-source-location-rejects-implicit-paths ()
  (let ((ast (org-element-create 'org-data nil)))
    (dolist (path
             '("" "relative/path" "~/notes.org" "/path\0suffix" t))
      (should-error
       (org-texmacs-input-create ast nil :source-file path)
       :type 'org-texmacs-document-error)
      (should-error
       (org-texmacs-input-create ast nil :resource-base path)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-test-block-p ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(frac \"1\" \"2\")\n#+end_texmacs\n")
    (goto-char (point-min))
    (should (org-texmacs--block-p (org-element-at-point))))
  (dolist (node
           (list
            nil
            "text"
            (org-element-create 'paragraph nil)
            (org-element-create 'special-block nil)
            (org-element-create 'special-block '(:type 42))
            (org-element-create 'special-block '(:type "example"))
            (org-element-create 'src-block '(:language "texmacs"))))
    (should-not (org-texmacs--block-p node))))

(ert-deftest org-texmacs-test-block-source-exact ()
  (dolist
      (body
       '("(frac \"1\" \"2\")\n"
         "\n\t(with \"mode\" \"math\"\n  (concat \"α *bold* [[link]]\" (sqrt \"x\")))\n\n"
         ""
         "\n\n"))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_texmacs\n" body "#+end_texmacs\n")
      (goto-char (point-min))
      (let* ((block (org-element-at-point))
             (before (buffer-string))
             (position (point))
             (tick (buffer-modified-tick)))
        (should (equal (org-texmacs--block-source block) body))
        (should (equal (buffer-string) before))
        (should (= (point) position))
        (should (= (buffer-modified-tick) tick))))))

(ert-deftest org-texmacs-test-block-source-strips-properties ()
  (with-temp-buffer
    (org-mode)
    (insert "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
    (goto-char (point-min))
    (let* ((block (org-element-at-point))
           (begin (org-element-property :contents-begin block))
           (end (org-element-property :contents-end block)))
      (put-text-property begin end 'org-texmacs-test-property t)
      (let ((source (org-texmacs--block-source block)))
        (should (equal source "(sqrt \"x\")\n"))
        (dotimes (index (length source))
          (should-not (text-properties-at index source)))))))

(ert-deftest org-texmacs-test-block-source-rejects-other-nodes ()
  (dolist (node
           (list
            nil
            (org-element-create 'paragraph nil)
            (org-element-create 'special-block '(:type "example"))))
    (should-error
     (org-texmacs--block-source node)
     :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-block-source-rejects-invalid-bounds ()
  (with-temp-buffer
    (insert "text")
    (dolist (bounds '((nil 3) (2 nil) (3 2) (0 2) (1 100) ("1" 2)))
      (let ((block
             (org-element-create
              'special-block
              (list
               :type "texmacs"
               :contents-begin (car bounds)
               :contents-end (cadr bounds)))))
        (should-error
         (org-texmacs--block-source block)
         :type 'org-texmacs-error)))))

(ert-deftest org-texmacs-test-tree-prefix-edit-remains-correct ()
  (let ((org-element-use-cache t)
        (calls 0))
    (with-temp-buffer
      (org-mode)
      (insert
       "Before\n\n#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
      (cl-letf (((symbol-function 'org-texmacs--worker-request)
                 (lambda (source)
                   (should (equal source "(sqrt \"x\")\n"))
                   (cl-incf calls)
                   '(sqrt "x"))))
        (org-texmacs-tree (org-texmacs-test--first-block))
        (goto-char (point-min))
        (insert "New prefix\n")
        (let ((block (org-texmacs-test--first-block)))
          (should
           (equal
            (org-texmacs--org-to-stree
             (org-texmacs-tree block))
            '(sqrt "x")))
          ;; Correctness does not depend on retaining the entry across a shift.
          (should (<= 1 calls 2)))))))

(ert-deftest org-texmacs-test-tree-rejects-wrong-block ()
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (_source)
               (ert-fail "Invalid block must not start parsing"))))
    (dolist (node
             (list
              nil
              (org-element-create 'special-block '(:type "example"))))
      (should-error
       (org-texmacs-tree node)
       :type 'org-texmacs-error))))

(ert-deftest org-texmacs-test-tree-rejects-text-changed-during-parse
    ()
  (let ((org-element-use-cache t))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_texmacs\n(sqrt \"x\")\n#+end_texmacs\n")
      (let ((block (org-texmacs-test--first-block)))
        (cl-letf
            (((symbol-function 'org-texmacs--worker-request)
              (lambda (_source)
                ;; Simulate an edit from a timer during process waiting.
                (goto-char (point-min))
                (search-forward "\"x\"")
                (replace-match "\"y\"" t t)
                '(sqrt "x"))))
          (should-error
           (org-texmacs-tree block)
           :type 'org-texmacs-error))
        (should
         (eq
          (org-element-cache-get-key
           (org-texmacs-test--first-block)
           'org-texmacs-tree
           org-texmacs--cache-miss)
          org-texmacs--cache-miss))))))

;;; source.el ends here
