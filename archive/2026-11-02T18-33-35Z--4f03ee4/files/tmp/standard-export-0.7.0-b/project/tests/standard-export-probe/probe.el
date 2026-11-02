;;; probe.el --- Stage B final AST input probes -*- lexical-binding: t; -*-
(require 'ox-texmacs)
(require 'org-texmacs-prepared)

(defun b--capture (source inspect &optional filter)
  (with-temp-buffer
    (org-mode)
    (insert source)
    (let ((org-export-use-babel nil)
          (org-export-filter-parse-tree-functions (and filter (list filter))))
      (cl-letf (((symbol-function 'org-texmacs--standard-inner)
                 (lambda (_contents info)
                   (let ((tree (plist-get info :parse-tree)))
                     (org-element-map tree t #'identity nil nil nil t)
                     (funcall inspect tree info)
                     ""))))
        (org-export-as 'texmacs)))))

(ert-deftest b-inline-org-markup-splits-stm ()
  (b--capture "A (math \"*bold* [[https://example.org][link]]\") tail.\n"
              (lambda (tree _info)
                (let ((p (car (org-element-map tree 'paragraph #'identity))))
                  (should (org-element-map p 'bold #'identity))
                  (should (org-element-map p 'link #'identity))
                  (should (equal (org-element-interpret-data p)
                                 "A (math \"*bold* [[https://example.org][link]]\") tail.\n"))))))

(ert-deftest b-native-body-interpretation-preserves-this-fixture ()
  (let ((raw "(document \"a\n  b\")\n"))
    (b--capture (concat "#+begin_texmacs\n" raw "#+end_texmacs\n")
                (lambda (tree _info)
                  (let* ((block (car (org-element-map tree 'special-block #'identity)))
                         (text (org-element-interpret-data (org-element-contents block))))
                    (message "NATIVE RAW %S INTERPRETED %S" raw text)
                    (should (equal raw text)))))))

(ert-deftest b-positionless-synthetic-node-is-usable ()
  (b--capture "Old text.\n"
              (lambda (tree _info)
                (let ((p (car (org-element-map tree 'paragraph #'identity))))
                  (should-not (org-element-property :begin p))
                  (should (equal (org-element-contents p) '("(math (sqrt \"x\"))\n")))))
              (lambda (tree _backend _info)
                (let* ((p (car (org-element-map tree 'paragraph #'identity)))
                       (new (org-element-create 'paragraph nil "(math (sqrt \"x\"))\n")))
                  (org-element-set-element p new))
                tree)))

(ert-deftest b-synthetic-native-block-can-carry-complete-input ()
  (b--capture "Old text.\n"
              (lambda (tree _info)
                (let ((n (car (org-element-map tree 'special-block #'identity))))
                  (should-not (org-element-property :begin n))
                  (should (equal (org-element-property :texmacs-source n)
                                 "(document \"*literal*\")"))))
              (lambda (tree _backend _info)
                (let ((p (car (org-element-map tree 'paragraph #'identity))))
                  (org-element-set-element
                   p (org-element-create 'special-block
                                         '(:type "texmacs" :texmacs-source "(document \"*literal*\")"))))
                tree)))

(ert-deftest b-ignore-list-is-not-physical-deletion ()
  (b--capture "#+OPTIONS: toc:nil\n* Keep\nYes.[fn:a]\n\n[fn:a] Footnote.\n"
              (lambda (tree info)
                (message "IGNORE %S TREE %S" (plist-get info :ignore-list)
                         (org-element-map tree 'headline (lambda (n) (org-element-property :raw-value n)))))))

(ert-deftest b-native-body-interpretation-matrix ()
  (dolist (raw '("(document \"  spaces  \" )\n"
                 "(document \"a\n\nb\")\n"
                 "(document \"a\n,#+fake: value\nb\")\n"
                 "(document \"a\n- item\n- next\nb\")\n"
                 "(document \"[[a][b]] ~x~\")\n"))
    (b--capture (concat "#+begin_texmacs\n" raw "#+end_texmacs\n")
                (lambda (tree _info)
                  (let* ((block (car (org-element-map tree 'special-block #'identity)))
                         (text (and block (org-element-interpret-data (org-element-contents block)))))
                    (should (equal raw text)))))))

(ert-deftest b-native-heading-is-an-org-structure-boundary ()
  (b--capture "#+begin_texmacs\n(document \"a\n* heading\nb\")\n#+end_texmacs\n"
              (lambda (tree _info)
                (should-not (org-element-map tree 'special-block #'identity))
                (should (org-element-map tree 'headline #'identity)))))

(defun b--input (info state)
  (let* ((tree (plist-get info :parse-tree))
         (_ (org-element-map tree t #'identity nil nil nil t))
         (owned (org-texmacs--prepared-copy tree (plist-get info :ignore-list)))
         (islands (org-texmacs--prepared-islands owned (org-texmacs--fragment-tags))))
    (org-texmacs-input-create owned '(:with-title nil :with-author nil :with-date nil :with-toc nil)
                              :islands islands :source-file (nth 5 state) :resource-base (nth 6 state))))

(ert-deftest b-native-late-adapter-preserves-and-lowers-islands ()
  (org-texmacs-test--with-worker
    (dolist (pair '(("A (math (sqrt \"x\")) tail.\n" . (math (sqrt "x")))
                    ("A (math \"*bold* [[https://example.org][link]]\") tail.\n" . (math "*bold* [[https://example.org][link]]"))
                    ("#+begin_texmacs\n(document \"a\n  b\")\n#+end_texmacs\n" . (document "a\n  b"))
                    ("#+begin_equation*\n(frac \"x\" \"y\")\n#+end_equation*\n" . (frac "x" "y"))))
      (with-temp-buffer
        (org-mode) (insert (car pair))
        (let ((org-export-use-babel nil))
          (cl-letf (((symbol-function 'org-texmacs--standard-input) #'b--input))
            (let* ((input (org-texmacs--standard-consume 'input))
                   (islands (org-texmacs-input-islands input)))
              (should (= (length islands) 1))
              (should (equal (cdar islands) (cdr pair)))
              (should (org-texmacs-document input)))))))))

(ert-deftest b-adapter-obeys-ignore-identities ()
  (b--capture "Keep.\n\nSkip.\n"
              (lambda (tree info)
                (let ((copy (org-texmacs--prepared-copy tree (plist-get info :ignore-list))))
                  (should (= (length (org-element-map copy 'paragraph #'identity)) 1))
                  (should (= (length (org-element-map tree 'paragraph #'identity)) 2))))
              (lambda (tree _backend info)
                (plist-put info :ignore-list (last (org-element-map tree 'paragraph #'identity))) tree)))

(ert-deftest b-adapter-rejects-cross-object-and-incomplete-before-worker ()
  (dolist (text '("(math *x*)\n" "(math \"x\"\n" "(math (sqrt *x*))\n"))
    (b--capture text
                (lambda (tree _info)
                  (let ((copy (org-texmacs--prepared-copy tree nil)))
                    (cl-letf (((symbol-function 'org-texmacs--worker-request)
                               (lambda (_source) (ert-fail "Worker ran before boundary check"))))
                      (should-error (org-texmacs--prepared-islands copy '("math"))
                                    :type 'org-texmacs-document-error)))))))
