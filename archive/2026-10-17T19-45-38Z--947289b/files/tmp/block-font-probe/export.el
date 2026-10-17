;;; export.el --- Isolated Chinese font export probe -*- lexical-binding: t; -*-
(require 'org-texmacs)
(require 'json)
(let* ((directory (getenv "PROBE_OUT"))
       (org-texmacs-document-style (list (getenv "PROBE_STYLE")))
       (font (getenv "PROBE_FONT"))
       (org-texmacs-document-initial
        (unless (equal font "") `(("font" . ,font) ("language" . "chinese"))))
       (name (getenv "PROBE_NAME"))
       (org-texmacs--worker-scheme-file
        (if (getenv "PROBE_REGISTER")
            (let ((loader (expand-file-name (concat name "-worker.scm") directory)))
              (with-temp-file loader
                (insert (format "(load %s)\n" (org-texmacs--scheme-string org-texmacs--worker-scheme-file))
                        (getenv "PROBE_REGISTER")))
              loader)
          org-texmacs--worker-scheme-file)))
  (unwind-protect
      (with-temp-buffer
        (org-mode)
        (insert "#+OPTIONS: toc:nil title:nil author:nil date:nil\n* 标题中文\n\n"
                "Body 中文测试 ABC xyz 123.\n\nRepeat 中文测试 ABC xyz 123.\n\n"
                "Strong *中文测试* End.\n\nItalic /中文测试/ End.\n\n"
                "Inline (math \"中文\") End.\n\n"
                "#+begin_quote\nQuote 中文测试.\n#+end_quote\n")
        (let* ((source (buffer-string))
               (tick (buffer-chars-modified-tick))
               (position (point))
               (document (org-texmacs-document-from-buffer (current-buffer)))
               (bytes (org-texmacs-document-serialize document))
               (base (expand-file-name name directory)))
          (org-texmacs-document-save document (concat base ".tm"))
          (org-texmacs-document-save-pdf document (concat base "-org.pdf"))
          (unless (and (equal source (buffer-string)) (= tick (buffer-chars-modified-tick))
                       (= position (point)) (equal bytes (org-texmacs-document-serialize document)))
            (error "Source or serialized document changed"))
          (with-temp-file (concat base "-document.sexp")
            (prin1 (list :body (org-texmacs-document-body document)
                         :stm-paths (org-texmacs-document-stm-paths document)
                         :style org-texmacs-document-style :initial org-texmacs-document-initial)
                   (current-buffer)))))
    (org-texmacs--worker-stop)))
