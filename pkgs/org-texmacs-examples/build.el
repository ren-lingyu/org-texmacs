;;; build.el --- Compile one explicit example source -*- lexical-binding: t; -*-

;; SPDX-License-Identifier: GPL-3.0-or-later

;; The Nix builder provides canonical Org inputs in a writable directory.
;; Tangle declared configuration/bibliography, load only the selected build
;; configuration, and consume one standard Org Export document snapshot.

(require 'org-texmacs)

(require 'ob-tangle)

(let* ((directory (getenv "ORG_TEXMACS_DOCUMENT_DIRECTORY"))
       (source (getenv "ORG_TEXMACS_DOCUMENT_SOURCE"))
       (output (getenv "ORG_TEXMACS_DOCUMENT_OUTPUT"))
       (configuration (getenv "ORG_TEXMACS_DOCUMENT_CONFIG_SOURCE"))
       (profile (getenv "ORG_TEXMACS_DOCUMENT_PROFILE"))
       (bibliography-source
        (getenv "ORG_TEXMACS_DOCUMENT_BIBLIOGRAPHY_SOURCE"))
       (bibliography (getenv "ORG_TEXMACS_DOCUMENT_BIBLIOGRAPHY")))
  (unless (cl-every
           (lambda (path) (and path (file-name-absolute-p path)))
           (list
            directory
            source
            output
            configuration
            bibliography-source
            bibliography))
    (error
     "Expected explicit absolute document, configuration and bibliography paths"))
  (unless (member profile '("generic" "article"))
    (error "Unknown example profile: %S" profile))
  (condition-case err
      (let ((default-directory (file-name-as-directory directory))
            (configuration-directory
             (file-name-directory configuration)))
        (message
         "Tangling configuration and bibliography (without evaluation)")
        (org-babel-tangle-file configuration nil "emacs-lisp")
        (org-babel-tangle-file bibliography-source)
        (unless (file-regular-p bibliography)
          (error "Bibliography was not generated: %s" bibliography))
        (load (expand-file-name "common.el" configuration-directory)
              nil
              t)
        (let ((profile-file
               (expand-file-name (concat profile ".el")
                                 configuration-directory)))
          (load profile-file nil t)
          ;; Include the selected configuration literally in the example.
          (copy-file
           profile-file
           (expand-file-name "profile.el" configuration-directory)))
        (with-temp-buffer
          (insert-file-contents source)
          (setq buffer-file-name source)
          (org-mode)
          (let*
              ((document
                (progn
                  (message
                   "Preparing %s with standard Org Export and native Org Cite"
                   source)
                  (org-texmacs-document-from-buffer
                   (current-buffer)))))
            (message "Saving native TeXmacs document")
            (org-texmacs-document-save document (concat output ".tm"))
            (message "Rendering PDF from the same document snapshot")
            (org-texmacs-document-save-pdf
             document (concat output ".pdf"))
            (message "Completed %s" source))))
    (error
     (message "Document failed: %s: %s"
              source
              (error-message-string err))
     ;; Preserve available native diagnostics before Emacs's worker cleanup.
     (let ((worker-log (get-buffer " *org-texmacs-worker*")))
       (when worker-log
         (message "TeXmacs worker output:\n%s"
                  (with-current-buffer worker-log
                    (buffer-string)))))
     (kill-emacs 1))))

;;; build.el ends here
