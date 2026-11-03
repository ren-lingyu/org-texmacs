;;; standard-source.el --- Standard explicit source outputs -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-standard-script-native-binding-layout ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil num:nil ^:t\n"
      "The /first/ term is x_i^2.\n\nNested x^{a_b}.\n\n"
      "Styled anchor.\n\nIsland (math (frac \"a\" \"b\"))_i^2 tail.\n\n"
      "* Heading x_i^2\n#+CAPTION: Caption x_i^2\n| A |\n")
     (let* ((org-export-filter-parse-tree-functions
             (list
              (lambda (tree _backend _info)
                (org-element-map
                 tree 'paragraph
                 (lambda (node)
                   (when (equal
                          (substring-no-properties
                           (or (car (org-element-contents node)) ""))
                          "Styled anchor.\n")
                     (org-element-set-contents
                      node
                      "Styled "
                      (org-element-create 'bold nil "z")
                      (org-element-create 'subscript nil "j")
                      (org-element-create 'superscript nil "3")
                      " tail.\n"))))
                tree)))
            (input (org-texmacs--standard-consume 'input))
            (island
             (copy-tree (cdar (org-texmacs-input-islands input))))
            (document (org-texmacs-document input))
            (pdf (expand-file-name "scripts.pdf" test-directory))
            (tm (expand-file-name "scripts.tm" test-directory))
            (reload
             (expand-file-name "scripts-reload.pdf" test-directory)))
       (should-not
        (memq
         'math
         (flatten-tree (cadr (org-texmacs-document-body document)))))
       (org-texmacs-document-save-pdf document pdf)
       (org-texmacs-document-save document tm)
       (org-texmacs-test--issue11-reload-pdf tm reload test-directory)
       (should
        (equal island (cdar (org-texmacs-input-islands input))))
       (let ((words (org-texmacs-test--issue11-pdf-geometry pdf)))
         (cl-labels
          ((center (word) (/ (+ (nth 2 word) (nth 4 word)) 2.0))
           (word
            (text anchor)
            (let ((found
                   (cl-find-if
                    (lambda (item)
                      (and (equal (car item) text)
                           (< (abs (- (center item) (center anchor)))
                              12)
                           (>= (nth 1 item) (nth 1 anchor))))
                    words)))
              (should found)
              found))
           (pair
            (prefix base upper lower)
            (let* ((anchor
                    (cl-find prefix words :key #'car :test #'equal))
                   (_ (should anchor))
                   (base (word base anchor))
                   (up (word upper anchor))
                   (down (word lower anchor)))
              (should (< (center up) (center base)))
              (should (> (center down) (center base)))
              (should (< (abs (- (nth 1 up) (nth 1 down))) 2))
              (dolist (script (list up down))
                (should (>= (nth 1 script) (- (nth 3 base) 1)))
                (should
                 (< (- (nth 4 script) (nth 2 script))
                    (- (nth 4 base) (nth 2 base)))))))
           (raster
            (file)
            (with-temp-buffer
              (set-buffer-multibyte nil)
              (should
               (= 0
                  (call-process "pdftoppm"
                                nil
                                t
                                nil
                                "-f"
                                "1"
                                "-singlefile"
                                "-scale-to"
                                "1200"
                                "-gray"
                                file)))
              (buffer-string))))
          (pair "The" "x" "2" "i")
          (pair "Styled" "z" "3" "j")
          (pair "Heading" "x" "2" "i")
          (pair "Caption" "x" "2" "i")
          (let* ((anchor
                  (cl-find "Nested" words :key #'car :test #'equal))
                 (x (word "x" anchor))
                 (a (word "a" anchor))
                 (b (word "b" anchor)))
            (should (< (center a) (center x)))
            (should (> (center b) (center a)))
            (should (> (nth 1 b) (nth 1 a)))
            (should
             (< (- (nth 4 b) (nth 2 b)) (- (nth 4 a) (nth 2 a)))))
          (let* ((anchor
                  (cl-find "Island" words :key #'car :test #'equal))
                 (a (word "a" anchor))
                 (b (word "b" anchor))
                 (up (word "2" anchor))
                 (down (word "i" anchor))
                 (middle (/ (+ (center a) (center b)) 2.0)))
            (should (< (center up) middle))
            (should (> (center down) middle))
            (should (< (abs (- (nth 1 up) (nth 1 down))) 2))
            (should (>= (nth 1 up) (max (nth 3 a) (nth 3 b)))))
          (should (equal (raster pdf) (raster reload)))))))))

(ert-deftest org-texmacs-standard-entity-native-layout-and-reload ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil e:t\n"
      "Before \\alpha{} \\cdot \\rightarrow \\copy literal <alpha> After.\n")
     (let* ((document (org-texmacs--standard-consume 'document))
            (expected
             (org-texmacs--document-create
              :body
              '(document
                (concat
                 "Before "
                 (math "<alpha>")
                 " "
                 (math "<cdot>")
                 " "
                 (math "<rightarrow>")
                 " "
                 "<copyright>"
                 " "
                 "literal <less>alpha<gtr> After. "))
              :stm-paths '(nil)
              :style (org-texmacs-document-style document)
              :initial (org-texmacs-document-initial document)))
            (actual (expand-file-name "entity.pdf" test-directory))
            (reference
             (expand-file-name "reference.pdf" test-directory))
            (tm (expand-file-name "entity.tm" test-directory))
            (reload (expand-file-name "reloaded.pdf" test-directory)))
       (org-texmacs-document-save-pdf document actual)
       (org-texmacs-document-save-pdf expected reference)
       (org-texmacs-document-save document tm)
       (org-texmacs-test--issue11-reload-pdf tm reload test-directory)
       ;; Math fonts do not reliably extract as Unicode. Compare actual ink to
       ;; independently authored native symbols, also after a saved TM reload.
       (cl-labels
        ((raster
          (file)
          (with-temp-buffer
            (set-buffer-multibyte nil)
            (should
             (= 0
                (call-process "pdftoppm"
                              nil
                              t
                              nil
                              "-f"
                              "1"
                              "-singlefile"
                              "-scale-to"
                              "1200"
                              "-gray"
                              file)))
            (buffer-string))))
        (should (equal (raster actual) (raster reference)))
        (should (equal (raster actual) (raster reload))))
       (let ((text (org-texmacs-test--pdf-text actual)))
         (dolist (token '("Before" "©" "literal <alpha>" "After."))
           (should (string-search token text))))))))

(ert-deftest org-texmacs-standard-source-five-output-consumers ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil\nBodySentinel.\n")
     (let ((source (current-buffer))
           (org-export-use-babel nil)
           (serialize
            (symbol-function 'org-texmacs-document-serialize)))
       (dolist (kind '(tm pdf buffer tm-file pdf-file))
         (let ((calls 0)
               (filters 0)
               (target
                (expand-file-name (format "new-%s" kind)
                                  test-directory)))
           (let ((org-export-before-processing-functions
                  (list (lambda (_) (cl-incf calls))))
                 (org-export-filter-parse-tree-functions
                  (list
                   (lambda (tree _backend info)
                     (cl-incf filters)
                     (when (memq kind '(tm-file pdf-file))
                       (should
                        (equal target (plist-get info :output-file)))
                       (aset (plist-get info :output-file) 0 ?X))
                     tree))))
             (cl-letf (((symbol-function 'org-texmacs--prepare-buffer)
                        (lambda (&rest _)
                          (ert-fail "Legacy preparation")))
                       ((symbol-function
                         'org-texmacs-document-serialize)
                        (if (memq kind '(pdf pdf-file))
                            (lambda (&rest _)
                              (ert-fail "PDF serialized TM"))
                          serialize)))
               (with-temp-buffer
                 (let ((result
                        (pcase kind
                          ('tm
                           (org-texmacs-export-texmacs-from-buffer
                            source))
                          ('pdf
                           (org-texmacs-export-pdf-from-buffer
                            source))
                          ('buffer
                           (org-texmacs-export-to-buffer source))
                          ('tm-file
                           (org-texmacs-export-to-texmacs-file
                            source target))
                          ('pdf-file
                           (org-texmacs-export-to-pdf-file
                            source target)))))
                   (pcase kind
                     ('buffer
                      (unwind-protect
                          (with-current-buffer result
                            (should
                             (string-search
                              "BodySentinel" (buffer-string))))
                        (kill-buffer result)))
                     ((or 'tm-file 'pdf-file)
                      (should (equal target result))
                      (should (file-exists-p target)))
                     (_ (should-not (multibyte-string-p result))))))))
           (should (= calls 1))
           (should (= filters 1))))))))

(ert-deftest org-texmacs-standard-source-text-tail-and-pdf-refusal ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Body.\n")
     (let ((calls 0))
       (let ((org-export-filter-final-output-functions
              (list
               (lambda (text _backend _info)
                 (cl-incf calls)
                 (concat text " FinalSentinel")))))
         (should
          (string-suffix-p
           " FinalSentinel"
           (org-texmacs-export-texmacs-from-buffer (current-buffer))))
         (should (= calls 1))
         (should-error
          (org-texmacs-export-pdf-from-buffer (current-buffer))
          :type 'org-texmacs-document-error)
         (should (= calls 1)))))))
