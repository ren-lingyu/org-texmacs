;;; session.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org-texmacs)

(ert-deftest org-texmacs-session-invalid-and-stale-handles ()
  (let ((org-texmacs--worker-process nil)
        (stale (org-texmacs--session-create :key "1" :process 'old)))
    (cl-letf (((symbol-function 'org-texmacs--worker-start)
               (lambda () (ert-fail "Stale handle started worker"))))
      (should-error
       (org-texmacs-session-set-document stale nil)
       :type 'org-texmacs-session-error)
      (should-error
       (org-texmacs-session-close nil)
       :type 'org-texmacs-session-error)
      (should-not (org-texmacs-session-close stale))
      (should-not (org-texmacs-session-close stale))
      (should (org-texmacs-session-closed stale)))))

(ert-deftest org-texmacs-session-response-contract ()
  (should
   (equal
    (org-texmacs--native-decode
     "(ok 1 (session \"2\"))" 1 'session-open)
    "2"))
  (dolist (response
           '("(ok 1 (session \"0\"))"
             "(ok 1 (closed \"1\"))"
             "(ok 1 (session 1))"
             "(ok 1 (session \"1\" \"2\"))"))
    (should-error
     (org-texmacs--native-decode response 1 'session-open)
     :type 'org-texmacs-worker-error))
  (should-error
   (org-texmacs--native-decode
    "(session-error 1 \"invalid\")" 1 'session-set)
   :type 'org-texmacs-session-error)
  (should-error
   (org-texmacs--native-decode
    "(session-fatal 1 \"cleanup\")" 1 'session-close)
   :type 'org-texmacs-worker-error)
  (let ((response
         '(native-document
           (style "generic")
           (initial (associate "par-first" "32666e"))
           (body (document "00")))))
    (should
     (equal
      (org-texmacs--native-decode
       "(ok 1 (native-document (style \"generic\") (initial (associate \"par-first\" \"32666e\")) (body (document \"00\"))))"
       1
       'session-read)
      response)))
  (dolist
      (response
       '("(ok 1 (native-body (document \"00\")))"
         "(ok 1 (native-document (style) (initial) (body (document \"00\"))))"
         "(ok 1 (native-document (style \"generic\") (initial (associate \"x\" \"0g\")) (body (document \"00\"))))"
         "(ok 1 (native-document (style \"generic\") (initial (associate \"x\" \"00\") (associate \"x\" \"00\")) (body (document \"00\"))))"))
    (should-error
     (org-texmacs--native-decode response 1 'session-read)
     :type 'org-texmacs-worker-error)))

;;; session.el ends here
