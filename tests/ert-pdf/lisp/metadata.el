;;; metadata.el --- PDF document information -*- lexical-binding: t; -*-

;;; Code:

(defun org-texmacs-test--metadata-pdf-info (file)
  "Return UTF-8 pdfinfo output for FILE."
  (with-temp-buffer
    (let ((coding-system-for-read 'utf-8-unix))
      (should (= 0 (call-process "pdfinfo" nil t nil "-enc" "UTF-8" file))))
    (buffer-string)))

(ert-deftest org-texmacs-metadata-pdf-visible-hidden-and-reloaded ()
  (org-texmacs-test--with-worker
   (dolist (style '("generic" "article"))
     (with-temp-buffer
       (org-mode)
       (insert org-texmacs-test--metadata-source)
       (let* ((org-texmacs-document-style (list style))
              (document (org-texmacs-document-from-buffer (current-buffer)))
              (tm (expand-file-name (concat style ".tm") test-directory))
              (pdf (expand-file-name (concat style ".pdf") test-directory))
              (reload (expand-file-name (concat style "-reload.pdf") test-directory)))
         (org-texmacs-document-save document tm)
         (org-texmacs-document-save-pdf document pdf)
         (org-texmacs-test--issue11-reload-pdf tm reload test-directory)
         (dolist (file (list pdf reload))
           (let ((text (org-texmacs-test--pdf-text file))
                 (info (org-texmacs-test--metadata-pdf-info file))
                 (position 0))
             (dolist (token '("TitleSentinel" "SubtitleSentinel" "AuthorSentinel"
                              "email@example.test" "DateSentinel" "GeneratorSentinel"))
               (should (string-match-p (regexp-quote token) text)))
             (dolist (token '("FirstSummary" "FirstKeywords" "MiddleSentinel"
                              "SecondSummary" "SecondKeywords" "BodySentinel"))
               (let ((next (string-match (regexp-quote token) text position)))
                 (should next)
                 (setq position (+ next (length token)))))
             (should (= 2 (let ((start 0) (count 0))
                            (while (string-match "\\bAbstract\\b" text start)
                              (setq start (match-end 0) count (1+ count))) count)))
             (should-not (string-match-p "HiddenSubject" text))
             (should (string-match-p "^Subject: +HiddenSubject <alpha> & \"quoted\"$" info))
             (should (string-match-p "^Title: +TitleSentinel$" info))
             (should (string-match-p "^Author: +AuthorSentinel$" info))
             (should (string-match-p "^Creator: +TeXmacs " info))
             (should-not (string-match-p "^Keywords:.*FirstKeywords" info)))))))))

;;; metadata.el ends here
