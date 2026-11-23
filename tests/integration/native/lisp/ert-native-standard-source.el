;;; ert-native-standard-source.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'ox)

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

(ert-deftest
    org-texmacs-standard-source-macro-and-include-generate-stm
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (write-region "$(math \"Included\")$\n" nil "part.org"
                   nil
                   'silent)
     (insert
      "#+MACRO: island $(math \"Macro\")$\n{{{island}}}\n\n#+INCLUDE: part.org\n")
     (let ((source (current-buffer))
           (before (buffer-string)))
       (dolist (function
                '(org-texmacs-prepare-buffer
                  org-texmacs-document-from-buffer
                  org-texmacs-export-texmacs-from-buffer))
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

;;; ert-native-standard-source.el ends here
