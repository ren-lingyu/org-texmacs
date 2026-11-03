;;; preprocess.el --- Standard deprecated wrapper composition -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-standard-legacy-preprocessed-generated-stm ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (write-region "(math \"Included\")\n" nil "part.org" nil 'silent)
     (insert
      "#+MACRO: island (math \"Macro\")\n{{{island}}}\n\n#+INCLUDE: part.org\n")
     (let ((source (current-buffer))
           (before (buffer-string)))
       (dolist (function
                '(org-texmacs-prepare-buffer-preprocessed
                  org-texmacs-document-from-buffer-preprocessed
                  org-texmacs-export-from-buffer-preprocessed))
         (let ((calls 0))
           (let ((org-export-before-processing-functions
                  (list (lambda (_) (cl-incf calls)))))
             (let ((result
                    (with-temp-buffer
                      (funcall function source))))
               (cond
                ((org-texmacs-input-p result)
                 (should
                  (= (length (org-texmacs-input-islands result)) 2)))
                ((org-texmacs-document-p result)
                 (should
                  (string-search
                   "Included"
                   (prin1-to-string
                    (org-texmacs-document-body result)))))
                (t
                 (should (string-search "Macro" result))
                 (should (string-search "Included" result))))))
           (should (= calls 1))
           (should (equal before (buffer-string)))))))))
