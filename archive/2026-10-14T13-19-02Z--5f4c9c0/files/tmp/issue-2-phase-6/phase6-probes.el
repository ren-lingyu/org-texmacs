;;; phase6-probes.el --- Locked native menu investigation -*- lexical-binding: t; -*-
(require 'find-func)
(require 'ox)
(princ (format "ENV Emacs %s Org %s ox %s\n" emacs-version (org-version) (locate-library "ox")))
(let ((file (find-library-name "ox")))
  (with-temp-buffer
    (insert-file-contents file) (emacs-lisp-mode)
    (dolist (name '(org-export--dispatch-action))
      (goto-char (point-min))
      (when (re-search-forward (format "^(defun %s\\b" name) nil t)
        (beginning-of-line)
        (let ((begin (point)))
          (forward-sexp)
          (princ (format "SOURCE %s\n%s\n" name (buffer-substring-no-properties begin (point)))))))))

(ert-deftest phase6-probe-nil-menu ()
  (let ((org-export-registered-backends nil))
    (org-export-define-backend 'phase6-nil nil)
    (should (org-export-get-backend 'phase6-nil))
    (should-not (org-export-backend-menu (org-export-get-backend 'phase6-nil)))))

(ert-deftest phase6-probe-native-registration-identity ()
  (let ((org-export-registered-backends nil))
    (org-export-define-backend 'phase6-test nil :menu-entry '(?Z "First" ((?a "Action" ignore))))
    (org-export-define-backend 'phase6-test nil :menu-entry '(?Z "Second" ((?b "Action" ignore))))
    (princ (format "REGISTRY repeated-name=%S\n"
                   (mapcar (lambda (b) (list (org-export-backend-name b) (org-export-backend-menu b)))
                           org-export-registered-backends)))
    (should (= (length org-export-registered-backends) 1))))

(defun phase6-probe--menu (keys menu)
  (let ((events (append keys nil)))
    (cl-letf (((symbol-function 'read-event)
               (lambda (&rest _) (or (pop events) (error "Menu exhausted events"))))
              ((symbol-function 'read-char-exclusive)
               (lambda (&rest _) (or (pop events) (error "Menu exhausted events"))))
              ((symbol-function 'read-char)
               (lambda (&rest _) (or (pop events) (error "Menu exhausted events")))))
      (let ((org-export-registered-backends
             (cl-loop for entry in menu for i from 0
                      collect (org-export-create-backend
                               :name (intern (format "phase6-menu-%s" i)) :menu entry))))
        (org-export--dispatch-ui nil nil t)))))

(ert-deftest phase6-probe-native-menu-key-behavior ()
  (dolist (menu '(((?Z "Own" ((?a "A" ignore) (?b "B" forward-char))))
                  ((?Z "Own" ((?a "A" ignore))) (?Z "Other" ((?b "B" forward-char))))
                  ((?Z "Own" ((?a "A" ignore))) (?Z "Other" ((?a "B" forward-char))))))
    (dolist (keys '("Za" "Zb"))
      (condition-case err
          (princ (format "MENU %S KEYS %S RESULT %S\n" menu keys (phase6-probe--menu keys menu)))
        (error (princ (format "MENU %S KEYS %S ERROR %S\n" menu keys err)))))))

(ert-deftest phase6-probe-native-ui-dispatch-asserted ()
  (should (equal (phase6-probe--menu "Za" '((?Z "Own" ((?a "A" ignore))))) '(ignore)))
  (should (equal (phase6-probe--menu "Zb" '((?Z "Own" ((?a "A" ignore)))
                                            (?Z "Other" ((?b "B" forward-char)))))
                 '(forward-char))))

(ert-deftest phase6-probe-unicode-and-special-keys ()
  (should (equal (phase6-probe--menu "界字" '((?界 "Own" ((?字 "A" ignore))))) '(ignore)))
  (dolist (key '(?q ?? ?# ?& ?P 2 22 19 6 1 14 16 32 127))
    (condition-case err
        (princ (format "SPECIAL %S RESULT %S\n" key
                       (phase6-probe--menu (string key ?a) (list (list key "Own" '((?a "A" ignore)))))))
      (error (princ (format "SPECIAL %S ERROR %S\n" key err))))))

(ert-run-tests-batch-and-exit "^phase6-probe-")
