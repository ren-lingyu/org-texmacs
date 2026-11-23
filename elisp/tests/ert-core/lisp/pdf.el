;;; pdf.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-texmacs)

(ert-deftest org-texmacs-pdf-preflight-protocol-and-source-wait ()
  (cl-letf (((symbol-function 'org-texmacs--worker-call)
             (lambda (&rest _)
               (ert-fail "Invalid PDF reached worker"))))
    (should-error
     (org-texmacs-document-pdf nil)
     :type 'org-texmacs-encoding-error)
    (should-error
     (org-texmacs-document-pdf
      (org-texmacs--document-create
       :body '(document (image "unowned.png"))))
     :type 'org-texmacs-rendering-error))
  (let ((stops 0))
    (cl-letf (((symbol-function 'org-texmacs--worker-call)
               (lambda (_request) '(ok 1 (rendered-pdf "00"))))
              ((symbol-function 'org-texmacs--worker-stop)
               (lambda () (cl-incf stops))))
      (should-error
       (org-texmacs-document-pdf
        (org-texmacs--document-create :body '(document "Text")))
       :type 'org-texmacs-worker-error)
      (should (= stops 1))))
  (org-texmacs-test--with-environment
   (with-temp-buffer
     (org-mode)
     (insert "Text.\n")
     (let ((source (current-buffer))
           (file (expand-file-name "stale.pdf" test-directory)))
       (cl-letf (((symbol-function 'org-texmacs-document-pdf)
                  (lambda (_document)
                    (with-current-buffer source
                      (insert "Changed"))
                    (encode-coding-string
                     "%PDF-1.4\n%%EOF\n" 'us-ascii)))
                 ((symbol-function 'org-texmacs--native-save-bytes)
                  (lambda (&rest _)
                    (ert-fail "Stale PDF was written"))))
         (should-error
          (org-texmacs-export-to-pdf-file source file)
          :type 'org-texmacs-document-error))
       (should-not (file-exists-p file))))))

;;; pdf.el ends here
