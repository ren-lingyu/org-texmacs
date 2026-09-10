;;; ert.el --- Tests for org-texmacs -*- lexical-binding: t; -*-

;;; Commentary:

;; ERT tests for org-texmacs.

;;; Code:

(require 'ert)
(require 'org-texmacs)

(ert-deftest org-texmacs-test-package-loads ()
  (should (featurep 'org-texmacs)))

(ert-deftest org-texmacs-test-setup-check-passes ()
  (let ((result (org-texmacs-check-setup)))
    (should (car result))
    (should (stringp (cdr result)))))

(ert-deftest org-texmacs-test-capability-types ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (command)
               (and (string= command "texmacs")
                    "/test/bin/texmacs"))))
    (let ((result
           (org-texmacs--check-capabilities
            '((org-element-create . function)
              (features . variable)
              (texmacs . executable)))))
      (should (car result)))))

(ert-deftest org-texmacs-test-capability-check-reports-all-failures ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (_command)
               nil)))
    (let ((result
           (org-texmacs--check-capabilities
            '((org-texmacs-test--missing-function . function)
              (org-texmacs-test--missing-variable . variable)
              (org-texmacs-test--missing-executable . executable)
              (org-element-create . unsupported)))))
      (should-not (car result))
      (dolist (name '(org-texmacs-test--missing-function
                      org-texmacs-test--missing-variable
                      org-texmacs-test--missing-executable
                      org-element-create))
        (should (string-match-p (regexp-quote (symbol-name name))
                                (cdr result)))))))

(ert-deftest org-texmacs-test-capability-check-rejects-malformed-input ()
  (let ((result (org-texmacs--check-capabilities
                 '(org-element-create . function))))
    (should-not (car result))
    (should (string-match-p "malformed"
                            (cdr result)))))

(ert-deftest org-texmacs-test-ensure-setup-signals-error ()
  (let ((org-texmacs--capability-alist
         '((org-texmacs-test--missing-function . function))))
    (should-error (org-texmacs--ensure-setup)
                  :type 'org-texmacs-error)))

(ert-deftest org-texmacs-test-stree-org-round-trip ()
  (let* ((mode (copy-sequence "mode"))
         (math (copy-sequence "math"))
         (sum (copy-sequence "x+"))
         (numerator (copy-sequence "1"))
         (denominator (copy-sequence "2"))
         (stree
          (list 'with
                mode
                math
                (list 'concat
                      sum
                      (list 'frac numerator denominator))))
         (tree (org-texmacs--stree-to-org stree))
         (round-trip (org-texmacs--org-to-stree tree)))
    (should (equal round-trip stree))
    (dolist (string (list mode math sum numerator denominator))
      (should-not (text-properties-at 0 string)))
    (dolist (string
             (list (nth 1 round-trip)
                   (nth 2 round-trip)
                   (nth 1 (nth 3 round-trip))
                   (nth 1 (nth 2 (nth 3 round-trip)))
                   (nth 2 (nth 2 (nth 3 round-trip)))))
      (should-not (text-properties-at 0 string)))))

(ert-deftest org-texmacs-test-stree-to-org-copies-strings ()
  (let* ((source (copy-sequence "1"))
         (tree (org-texmacs--stree-to-org (list 'frac source "2")))
         (converted (car (org-element-contents tree))))
    (should (equal converted source))
    (should-not (eq converted source))
    (should-not (text-properties-at 0 source))))

(ert-deftest org-texmacs-test-stree-to-org-builds-parent-links ()
  (let* ((tree
          (org-texmacs--stree-to-org
           '(with "mode" "math"
                  (concat "x+" (frac "1" "2")))))
         (root-contents (org-element-contents tree))
         (mode (nth 0 root-contents))
         (math (nth 1 root-contents))
         (concat-node (nth 2 root-contents))
         (concat-contents (org-element-contents concat-node))
         (sum (nth 0 concat-contents))
         (frac-node (nth 1 concat-contents))
         (frac-contents (org-element-contents frac-node)))
    (should (eq (org-element-property :parent mode) tree))
    (should (eq (org-element-property :parent math) tree))
    (should (eq (org-element-property :parent concat-node) tree))
    (should (eq (org-element-property :parent sum) concat-node))
    (should (eq (org-element-property :parent frac-node) concat-node))
    (dolist (string frac-contents)
      (should (eq (org-element-property :parent string)
                  frac-node)))))

;;; ert.el ends here
