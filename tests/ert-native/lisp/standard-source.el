;;; standard-source.el --- Standard source byte consumers -*- lexical-binding: t; -*-
(require 'ox-texmacs)

(ert-deftest org-texmacs-standard-source-source-selection ()
  (org-texmacs-test--with-worker
   (dolist (scope '(full subtree region both narrowing))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil title:nil author:nil date:nil\n* One\nFirst.\n* Two\nSecond.\n")
       (goto-char (point-min))
       (search-forward "First.")
       (let* ((begin (- (point) 6))
              (end (point))
              (subtree (and (memq scope '(subtree both)) begin))
              (region
               (and (memq scope '(region both)) (cons begin end)))
              (org-export-use-babel nil))
         (when (eq scope 'narrowing)
           (narrow-to-region begin end))
         (set-mark (point-min))
         (setq mark-active t)
         (let* ((before
                 (org-texmacs-test--document-buffer-state
                  (current-buffer)))
                (source (current-buffer))
                (expected
                 (save-mark-and-excursion
                   (let ((mark-active (and region t))
                         (transient-mark-mode t))
                     (when region
                       (goto-char begin)
                       (set-mark end))
                     (org-texmacs--standard-text-bytes
                      (org-export-as 'texmacs (and subtree t))))))
                (calls 0))
           (let ((org-export-before-processing-functions
                  (list (lambda (_) (cl-incf calls)))))
             (with-temp-buffer
               (should
                (equal
                 expected
                 (org-texmacs-export-texmacs-from-buffer
                  source nil subtree region nil)))))
           (should (= calls 1))
           (should
            (equal
             before
             (org-texmacs-test--document-buffer-state source)))))))))

(ert-deftest
    org-texmacs-standard-source-invalid-arguments-before-effects
    ()
  (with-temp-buffer
    (org-mode)
    (insert "* One\nFirst.\n* Two\nSecond.\n")
    (goto-char (point-min))
    (search-forward "Second.")
    (let ((region (cons (- (point) 7) (point)))
          (org-export-before-processing-functions
           (list
            (lambda (_)
              (ert-fail "Invalid request ran preparation")))))
      (should-error
       (org-texmacs-export-texmacs-from-buffer
        (current-buffer) nil 1 region nil)
       :type 'org-texmacs-document-error)
      (should-error
       (org-texmacs-export-texmacs-from-buffer
        (current-buffer) '(("x" . "text")) nil nil nil)
       :type 'org-texmacs-document-error)
      (should-error
       (org-texmacs-export-texmacs-from-buffer "name" nil nil nil nil)
       :type 'org-texmacs-document-error))))

(ert-deftest org-texmacs-standard-source-options-owned-before-hooks ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "Body.\n")
     (let* ((title (copy-sequence "Owned title"))
            (options (list :title title))
            (org-export-before-processing-functions
             (list (lambda (_) (aset title 0 ?X)))))
       (should
        (string-search
         "Owned title"
         (org-texmacs-export-texmacs-from-buffer
          (current-buffer) nil nil nil options)))))))

(ert-deftest org-texmacs-standard-source-pdf-direct-and-nested ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "#+OPTIONS: toc:nil title:nil author:nil date:nil\nOuter.\n")
     (let ((source (current-buffer))
           (calls 0)
           child)
       (let ((org-export-before-processing-functions
              (list
               (lambda (_)
                 (cl-incf calls)
                 (when (= calls 1)
                   (with-temp-buffer
                     (org-mode)
                     (insert "Inner.\n")
                     (setq child
                           (org-texmacs--standard-source-consume
                            'document
                            (current-buffer)
                            nil
                            nil
                            nil
                            nil))))))))
         (cl-letf (((symbol-function 'org-texmacs-document-serialize)
                    (lambda (&rest _)
                      (ert-fail "Structured output serialized TM"))))
           (should
            (string-prefix-p
             "%PDF-"
             (org-texmacs-export-pdf-from-buffer
              source nil nil nil nil)))))
       (should (= calls 2))
       (should
        (string-search
         "Inner."
         (prin1-to-string (org-texmacs-document-body child))))))))
