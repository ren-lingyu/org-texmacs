;;; native.el --- native STM acceptance probe -*- lexical-binding: t; -*-
(load (expand-file-name "probe.el" (file-name-directory load-file-name)) nil t)
(require 'org-texmacs)
(setq org-texmacs-program
      "/nix/store/axly2kr7x87iflyf6bpp2881wfw2zny4-texmacs-with-gotor-support-2.1.5/bin/texmacs"
      org-texmacs-worker-start-timeout 15
      org-texmacs-worker-request-timeout 5)
(let (rows directory socket startup)
  (unwind-protect
      (condition-case e
          (progn
            (org-texmacs--worker-start)
            (setq directory org-texmacs--worker-directory
                  socket org-texmacs--worker-socket)
            (dolist (s '("(math \"x\")" "(custom-tag \"x\")" "(x)"
                         "(math #bad)" "(math \"a\\\\)b\")"
                         "(math \"x\") (math \"y\")" "\"V\""))
              (push (list :input s :result
                          (condition-case err
                              (format "%S" (org-texmacs--worker-request s))
                            (error (list :error (error-message-string err))))) rows)))
        (error (setq startup (error-message-string e))))
    (org-texmacs--worker-stop))
  (probe-write "native.json"
               (list :startup-error startup :socket socket
                     :directory-removed (and directory (not (file-exists-p directory)))
                     :worker-live (org-texmacs--worker-live-p)
                     :rows (nreverse rows))))
(princ "native probe completed\n")
