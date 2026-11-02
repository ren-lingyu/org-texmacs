;;; model-parser.el --- Native independent model parser regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Real native STM parsing without document lowering or native sessions.

;;; Code:

(require 'org-texmacs-parse)

(ert-deftest org-texmacs-model-parse-native-trees-and-detached-source
    ()
  (org-texmacs-test--with-worker
   (let (model)
     (with-temp-buffer
       (org-mode)
       (insert
        "* COMMENT Kept :noexport:\n"
        ":PROPERTIES:\n:ANY_PROPERTY: retained\n:END:\n"
        "Body (math (frac \"α\" \"2\")).\n\n"
        "#+begin_texmacs\n\"原子 <alpha>\"\n#+end_texmacs\n\n"
        "#+begin_equation\n(frac \"1\" \"2\")\n#+end_equation\n")
       (let ((state
              (org-texmacs-test--document-buffer-state
               (current-buffer))))
         (cl-letf (((symbol-function 'org-texmacs--document-lower)
                    (lambda (&rest _)
                      (ert-fail "Native model invoked lowering")))
                   ((symbol-function 'org-texmacs-session-open)
                    (lambda (&rest _)
                      (ert-fail "Native model opened a session"))))
           (setq model (org-texmacs-parse-buffer (current-buffer))))
         (should
          (equal
           state
           (org-texmacs-test--document-buffer-state
            (current-buffer))))))
     (should
      (equal
       (mapcar #'cdr (org-texmacs-model-islands model))
       '((math (frac "α" "2")) "原子 <alpha>" (frac "1" "2"))))
     (should
      (org-element-map
       (org-texmacs-model-ast model)
       'property-drawer
       #'identity
       nil
       t))
     (dolist (entry (org-texmacs-model-islands model))
       (when (consp (car entry))
         (should-not (org-element-contents (car entry)))))
     (org-texmacs--worker-stop)
     (should (= (length (org-texmacs-model-islands model)) 3)))))

(ert-deftest org-texmacs-model-parse-native-errors-preserve-worker ()
  (org-texmacs-test--with-worker
   (dolist
       (text
        '("(math 7)\n"
          "* COMMENT Excluded\n#+begin_texmacs\n(math 7)\n#+end_texmacs\n"))
     (with-temp-buffer
       (org-mode)
       (insert text)
       (should-error
        (org-texmacs-parse-buffer (current-buffer))
        :type 'org-texmacs-parse-error)))
   (let ((worker org-texmacs--worker-process))
     (should (process-live-p worker))
     (with-temp-buffer
       (org-mode)
       (insert "(math \"recovered\")\n")
       (should
        (equal
         (cdar
          (org-texmacs-model-islands
           (org-texmacs-parse-buffer (current-buffer))))
         '(math "recovered"))))
     (should (eq worker org-texmacs--worker-process)))))

(ert-deftest
    org-texmacs-model-parse-native-context-and-unused-footnotes
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "* A\nBody[fn::Inline (math \"中\\\"\\\\\")].\n\n"
      "[fn:unused] Not selected (math (sqrt \"x\")).\n")
     (let ((model (org-texmacs-parse-buffer (current-buffer))))
       (should
        (equal
         (mapcar #'cdr (org-texmacs-model-islands model))
         '((math "中\"\\") (math (sqrt "x")))))
       (should
        (plist-member
         (org-texmacs-model-context model)
         :heading-settings))
       (should
        (org-element-map
         (org-texmacs-model-ast model)
         'footnote-definition
         #'identity
         nil
         t))))))

;;; model-parser.el ends here
