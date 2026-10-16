;;; baseline.el --- Causal baseline -*- lexical-binding: t; -*-
(require 'ert)
(require 'org-texmacs)
(load (getenv "FONT_LOCK_TESTS") nil t)
(let* ((stats (ert-run-tests-batch "^org-texmacs-font-lock-"))
       (failed (ert-stats-completed-unexpected stats)))
  (unless (>= failed 6) (error "Expected at least six causal failures, got %s" failed))
  (message "Confirmed %s baseline failures" failed))
