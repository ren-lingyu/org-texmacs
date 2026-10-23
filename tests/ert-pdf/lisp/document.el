;;; document.el --- pdf document regressions -*- lexical-binding: t; -*-

;;; Commentary:

;; Migrated regression cases; preserve assertion and isolation semantics.

;;; Code:

(ert-deftest org-texmacs-caption-inline-footnote-native-layout-limit ()
  (let (missing)
    (org-texmacs-test--with-worker
      (dolist (style '("generic" "article"))
        (let* ((table '(tabular (tformat (table (row (cell "A"))))))
               (body `(document
                       (concat "Before" (footnote (document "BodyNoteOne")))
                       (big-table ,table (concat "CapA" (footnote (document "NoteA"))))
                       (big-figure ,org-texmacs-test--issue13-stage3-graphic
                                   (concat "CapB" (footnote (document "NoteB"))))
                       (big-table* ,table (concat "CapC" (footnote (document "NoteC"))))
                       (big-figure* ,org-texmacs-test--issue13-stage3-graphic
                                    (concat "CapD" (footnote (document "NoteD"))))
                       (concat "After" (footnote (document "BodyNoteTwo")))))
               (document (org-texmacs--document-create :body body :style (list style)))
               (pdf (expand-file-name (concat style "-caption-note.pdf") test-directory))
               (tm (expand-file-name (concat style "-caption-note.tm") test-directory))
               (reload (expand-file-name (concat style "-caption-note-reload.pdf") test-directory))
               (session (org-texmacs-session-open)))
          (unwind-protect
              (progn
                (org-texmacs-session-set-document session document)
                (should (equal (org-texmacs--session-read session)
                               (org-texmacs-test--native-hex body))))
            (org-texmacs-session-close session))
          (org-texmacs-document-save document tm)
          (org-texmacs-document-save-pdf document pdf)
          (let ((text (org-texmacs-test--pdf-text pdf))
                (geometry (org-texmacs-test--issue11-pdf-geometry pdf)))
            (message "Known native caption-footnote layout limit (%s): %s" style text)
            (dolist (token '("CapA" "CapB" "CapC" "CapD" "NoteA" "NoteB" "NoteC" "NoteD"
                             "BodyNoteOne" "BodyNoteTwo"))
              (unless (= 1 (cl-count token geometry :key #'car :test #'equal))
                (push (list style token) missing)))
            (should (string-match-p "Table 1\\. CapA" text))
            (should (string-match-p "Figure 1\\. CapB" text)))
          (org-texmacs-test--issue11-reload-pdf tm reload test-directory)
          (org-texmacs-test--issue11-compare-pdfs pdf reload))))
    ;; Pinned native layout loses these bodies despite exact STM readback.
    ;; This records the native limit, not exporter acceptance of data loss.
    (should (equal (nreverse missing)
                   '(("generic" "NoteA") ("generic" "NoteB")
                     ("generic" "NoteC") ("generic" "NoteD")
                     ("article" "NoteA") ("article" "NoteB")
                     ("article" "NoteC") ("article" "NoteD"))))))

(ert-deftest org-texmacs-document-issue11-file-provenance-and-source-errors ()
  :tags '(issue11)
  (let* ((leaf (copy-sequence "island"))
         (link (org-element-create 'link '(:type "file" :path "asset.pdf")))
         (ast (org-element-create 'org-data nil
                                  (org-element-create 'quote-block nil
                                                      (org-element-create 'paragraph nil leaf "\n")
                                                      (org-element-create 'paragraph nil link))))
         (input (org-texmacs-input-create ast nil :resource-base "/base/"
                                          :islands (list (cons leaf '(math "<alpha>")))))
         (result (org-texmacs-document input)))
    (should (equal (org-texmacs-document-stm-paths result) '((0 0 0))))
    (should (equal (org-texmacs-document-file-paths result) '((0 0 1 0 1))))
    (should (string-match-p (regexp-quote "/base/asset.pdf") (org-texmacs--native-document-wire result)))
    (should (equal (cadr (org-texmacs-document-body result))
                   '(quotation (document (math "<alpha>") (concat (hlink "asset.pdf" "asset.pdf")))))))
  (org-texmacs-test--with-worker
    (with-temp-buffer
      (org-mode) (insert "Before (equation \"x\") after.\n")
      (let ((before (org-texmacs-test--document-buffer-state (current-buffer)))
            (file (expand-file-name "should-not-exist.pdf" test-directory)))
        (cl-letf (((symbol-function 'org-texmacs-document-pdf)
                   (lambda (&rest _) (ert-fail "Rejected paragraph rendered PDF"))))
          (should-error (org-texmacs-export-to-pdf-file (current-buffer) file)
                        :type 'org-texmacs-document-error))
        (should-not (file-exists-p file))
        (should (equal before (org-texmacs-test--document-buffer-state (current-buffer))))))))

;;; document.el ends here
