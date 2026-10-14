;;; phase5-probes.el --- Locked frontend contract probes -*- lexical-binding: t; -*-
;; The isolated runner loads maintained project ERT helpers first.

(ert-deftest phase5-probe-loaded-frontend-guard-and-hooks ()
  (org-texmacs-test--with-bibliography-files
    (insert "Text\n")
    (let* ((calls 0)
          (org-export-before-processing-functions
           (append org-export-before-processing-functions
                   (list (lambda (_backend)
                           (cl-incf calls)
                           (should-error (org-export-as 'texmacs)))))))
      (should (org-texmacs-input-p
               (org-texmacs-prepare-buffer-preprocessed (current-buffer))))
      (should (= calls 1)))))

(ert-deftest phase5-probe-preprocessed-pdf-transaction ()
  (org-texmacs-test--with-worker
    (org-texmacs-test--with-bibliography-files
      (write-region "Included PDF text\n" nil "part.org" nil 'silent)
      (insert "#+INCLUDE: \"part.org\"\n")
      (should (string-prefix-p
               "%PDF-"
               (org-texmacs--preprocess-convert
                (current-buffer)
                (lambda (input) (org-texmacs-document-pdf (org-texmacs-document input)))
                nil nil nil)))
      (cl-letf (((symbol-function 'org-texmacs-document-pdf)
                 (lambda (_document)
                   (write-region "Changed dependency\n" nil "part.org" nil 'silent)
                   (encode-coding-string "%PDF-invalid" 'us-ascii))))
        (should-error
         (org-texmacs--preprocess-convert
          (current-buffer)
          (lambda (input) (org-texmacs-document-pdf (org-texmacs-document input)))
          nil nil nil)
         :type 'org-texmacs-document-error)))))

(ert-deftest phase5-probe-local-discovery-and-selection ()
  (org-texmacs-test--with-worker
    (org-texmacs-test--with-bibliography-files
      (insert "* Outside\nOther\n* Selected\n[cite:@external-key]\n#+print_bibliography:\n")
      (goto-char (point-min)) (search-forward "* Selected")
      (beginning-of-line)
      (let ((org-cite-global-bibliography '("refs.bib")))
        (should (string-match-p
                 "bib-list"
                 (org-texmacs--bibliography-convert
                  (current-buffer)
                  (lambda (input) (prin1-to-string
                                   (org-texmacs-document-body (org-texmacs-document input))))
                  nil (point) nil nil nil t)))))))

(ert-deftest phase5-probe-full-profile-versus-direct ()
  (org-texmacs-test--with-bibliography-files
    (insert "Text\n")
    (setq-local org-odd-levels-only t)
    (should (org-texmacs-input-p (org-texmacs-prepare-buffer (current-buffer))))
    (should-error (org-texmacs-prepare-buffer-preprocessed (current-buffer))
                  :type 'org-texmacs-document-error)))

(ert-run-tests-batch-and-exit "^phase5-probe-")
