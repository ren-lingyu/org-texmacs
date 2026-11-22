;;; ert-pdf-document.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(ert-deftest org-texmacs-caption-inline-footnote-native-layout-limit
    ()
  (let (missing)
    (org-texmacs-test--with-worker
     (dolist (style '("generic" "article"))
       (let* ((table '(tabular (tformat (table (row (cell "A"))))))
              (body
               `(document
                 (concat "Before" (footnote (document "BodyNoteOne")))
                 (big-table
                  ,table
                  (concat "CapA" (footnote (document "NoteA"))))
                 (big-figure
                  ,org-texmacs-test--issue13-stage3-graphic
                  (concat "CapB" (footnote (document "NoteB"))))
                 (big-table*
                  ,table
                  (concat "CapC" (footnote (document "NoteC"))))
                 (big-figure*
                  ,org-texmacs-test--issue13-stage3-graphic
                  (concat "CapD" (footnote (document "NoteD"))))
                 (concat
                  "After" (footnote (document "BodyNoteTwo")))))
              (document
               (org-texmacs--document-create
                :body body
                :style (list style)))
              (pdf
               (expand-file-name (concat style "-caption-note.pdf")
                                 test-directory))
              (tm
               (expand-file-name (concat style "-caption-note.tm")
                                 test-directory))
              (reload
               (expand-file-name (concat
                                  style "-caption-note-reload.pdf")
                                 test-directory))
              (session (org-texmacs-session-open)))
         (unwind-protect
             (progn
               (org-texmacs-session-set-document session document)
               (should
                (equal
                 (org-texmacs--session-read session)
                 (org-texmacs-test--native-hex body))))
           (org-texmacs-session-close session))
         (org-texmacs-document-save document tm)
         (org-texmacs-document-save-pdf document pdf)
         (let ((text (org-texmacs-test--pdf-text pdf))
               (geometry
                (org-texmacs-test--issue11-pdf-geometry pdf)))
           (message
            "Known native caption-footnote layout limit (%s): %s"
            style text)
           (dolist (token
                    '("CapA"
                      "CapB"
                      "CapC"
                      "CapD"
                      "NoteA"
                      "NoteB"
                      "NoteC"
                      "NoteD"
                      "BodyNoteOne"
                      "BodyNoteTwo"))
             (unless (= 1
                        (cl-count
                         token
                         geometry
                         :key #'car
                         :test #'equal))
               (push (list style token) missing)))
           (should (string-match-p "Table 1\\. CapA" text))
           (should (string-match-p "Figure 1\\. CapB" text)))
         (org-texmacs-test--issue11-reload-pdf
          tm reload test-directory)
         (org-texmacs-test--issue11-compare-pdfs pdf reload))))
    ;; Pinned native layout loses these bodies despite exact STM readback.
    ;; This records the native limit, not exporter acceptance of data loss.
    (should
     (equal
      (nreverse missing)
      '(("generic" "NoteA")
        ("generic" "NoteB")
        ("generic" "NoteC")
        ("generic" "NoteD")
        ("article" "NoteA")
        ("article" "NoteB")
        ("article" "NoteC")
        ("article" "NoteD"))))))

;;; ert-pdf-document.el ends here
