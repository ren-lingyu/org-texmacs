;;; standard-source.el --- Standard explicit source outputs -*- lexical-binding: t; -*-

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
