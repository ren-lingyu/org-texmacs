;;; standard-source.el --- Standard explicit source outputs -*- lexical-binding: t; -*-

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
