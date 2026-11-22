;;; support.el --- Suite-local fixtures -*- lexical-binding: t; -*-

(defun org-texmacs-test--metadata-pdf-info (file)
  "Return UTF-8 pdfinfo output for FILE."
  (with-temp-buffer
    (let ((coding-system-for-read 'utf-8-unix))
      (should
       (= 0 (call-process "pdfinfo" nil t nil "-enc" "UTF-8" file))))
    (buffer-string)))

(defun org-texmacs-test--observe-standard-cleanup
    (thunk &optional failure)
  "Call THUNK and check disposal of Org's working export buffers.
FAILURE injects an error in root, prepared or ast phase, after switching to a
separate user-owned buffer.  Return the observed phase names."
  (let ((source (current-buffer))
        (other (generate-new-buffer " *standard-user-owned*"))
        records)
    (unwind-protect
        (cl-labels
         ((observe
           (stage)
           (should-not (eq source (current-buffer)))
           (push (cons stage (current-buffer)) records)
           (when (eq stage failure)
             (goto-char (point-max))
             (insert "Injected copy change")
             (set-buffer other)
             (signal 'org-texmacs-document-error
                     '("Cleanup sentinel")))))
         (let ((org-export-before-processing-functions
                (append
                 org-export-before-processing-functions
                 (list (lambda (_) (observe 'root)))))
               (org-export-before-parsing-functions
                (append
                 org-export-before-parsing-functions
                 (list (lambda (_) (observe 'prepared)))))
               (org-export-filter-parse-tree-functions
                (append
                 org-export-filter-parse-tree-functions
                 (list
                  (lambda (tree _backend _info)
                    (observe 'ast)
                    tree)))))
           (funcall thunk))
         (should (buffer-live-p source))
         (should (buffer-live-p other))
         (dolist (record records)
           (should-not (buffer-live-p (cdr record))))
         (mapcar #'car (nreverse records)))
      (when (buffer-live-p other)
        (let ((kill-buffer-query-functions nil))
          (kill-buffer other))))))

(defmacro org-texmacs-test--with-cleanup-source (&rest body)
  "Run BODY in a real visiting Org buffer and a test-owned directory."
  (declare (indent 0) (debug t))
  `(org-texmacs-test--with-bibliography-files
    (write-region "Included cleanup sentinel\n" nil "part.org"
                  nil
                  'silent)
    (write-region "#+INCLUDE: \"part.org\"\n" nil "source.org"
                  nil
                  'silent)
    (let ((source
           (find-file-noselect (expand-file-name "source.org"))))
      (unwind-protect
          (with-current-buffer source
            (org-mode)
            ,@body)
        (when (buffer-live-p source)
          (with-current-buffer source
            (set-buffer-modified-p nil))
          (kill-buffer source))))))

;;; support.el ends here
