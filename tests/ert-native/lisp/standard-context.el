;;; standard-context.el --- Native standard Org context regressions -*- lexical-binding: t; -*-

(ert-deftest
    org-texmacs-standard-context-native-selected-note-and-references
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "* Selected\nFirst[fn:n], again[fn:n].\n** Destination\n[[*Destination]].\n* Other\n\n[fn:n] External (math (sqrt \"x\")).\n")
     (goto-char (point-min))
     (let* ((org-export-use-babel nil)
            (input (org-texmacs--standard-consume 'input t))
            (document (org-texmacs-document input)))
       (should (= (length (org-texmacs-input-islands input)) 1))
       (should
        (equal
         (cdar (org-texmacs-input-islands input)) '(math (sqrt "x"))))
       (should
        (= (cl-count
            'footnote
            (flatten-tree (org-texmacs-document-body document)))
           1))
       (should-not
        (string-match-p
         "Footnotes"
         (prin1-to-string (org-texmacs-document-body document))))
       (should
        (string-prefix-p
         "<TeXmacs|" (org-texmacs-document-serialize document)))))))

(ert-deftest
    org-texmacs-standard-context-native-setup-include-and-resource-base
    ()
  (org-texmacs-test--with-worker
   (let* ((subdir (expand-file-name "sub" test-directory))
          (leaf (expand-file-name "leaf.org" subdir))
          (middle (expand-file-name "middle.org" test-directory))
          (setup (expand-file-name "settings.org" test-directory)))
     (make-directory subdir)
     (with-temp-file setup
       (insert
        "#+TITLE: Setup title\n#+OPTIONS: toc:nil num:nil author:nil date:nil\n"))
     (with-temp-file leaf
       (insert
        "omittedtoken\n* Included\n[[file:asset.pdf][asset]] (math (sqrt \"x\")).\n"))
     (with-temp-file middle
       (insert
        "#+INCLUDE: \"sub/leaf.org\" :lines \"2-\" :minlevel 2\n"))
     (with-temp-buffer
       (org-mode)
       (setq buffer-file-name
             (expand-file-name "main.org" test-directory))
       (insert
        "#+SETUPFILE: \"settings.org\"\n* Parent\n#+INCLUDE: \"middle.org\"\n")
       (let* ((org-export-use-babel nil)
              (input (org-texmacs--standard-consume 'input))
              (info (org-texmacs-input-info input))
              (query (plist-get info :texmacs-org-query))
              (file
               (cdar
                (org-texmacs-resolution-files
                 (org-texmacs-input-resolution input))))
              (body
               (org-texmacs-document-body
                (org-texmacs-document input))))
         (should-not (plist-get info :with-toc))
         (should-not (plist-get info :section-numbers))
         (should
          (equal '(1 2) (mapcar #'cadr (plist-get query :headlines))))
         (should
          (equal
           (expand-file-name file
                             (org-texmacs-input-resource-base input))
           (expand-file-name "asset.pdf" subdir)))
         (should (= (length (org-texmacs-input-islands input)) 1))
         (should-not
          (string-match-p "omittedtoken" (prin1-to-string body)))
         (should
          (string-match-p "Setup title" (prin1-to-string body))))))))

(ert-deftest
    org-texmacs-standard-context-native-filter-moves-named-island
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "* One\n#+NAME: formula\n#+begin_equation\n(sqrt \"x\")\n#+end_equation\n* Two\nSee [[formula]].\n")
     (let* ((org-export-use-babel nil)
            (org-export-filter-parse-tree-functions
             (list
              (lambda (tree _backend _info)
                (let ((block
                       (car
                        (org-element-map
                         tree 'special-block #'identity)))
                      (destination
                       (cadr
                        (org-element-map tree 'headline #'identity))))
                  (org-element-extract-element block)
                  (org-element-adopt destination block))
                tree)))
            (input (org-texmacs--standard-consume 'input))
            (island (caar (org-texmacs-input-islands input)))
            (target
             (cdar
              (org-texmacs-resolution-targets
               (org-texmacs-input-resolution input)))))
       (should (eq target island))
       (should
        (equal
         "Two"
         (org-element-property
          :raw-value (org-element-property :parent island))))
       (should
        (string-prefix-p
         "<TeXmacs|"
         (org-texmacs-document-serialize
          (org-texmacs-document input))))))))
