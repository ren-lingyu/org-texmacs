;;; ert.el --- Tests for org-texmacs -*- lexical-binding: t; -*-

;;; Commentary:

;; ERT tests for org-texmacs.

;;; Code:

(require 'ert)
(require 'org-texmacs)

(ert-deftest org-texmacs-test-package-loads ()
  (should (featurep 'org-texmacs)))

;;; ert.el ends here
