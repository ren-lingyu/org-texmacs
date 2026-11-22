;;; pdf.el --- Repository ERT pdf fixtures -*- lexical-binding: t; -*-

(defun org-texmacs-test--pdf-compare-text-and-geometry
    (actual expected)
  "Check that ACTUAL and EXPECTED match in text and per-word geometry."
  (should
   (equal
    (org-texmacs-test--pdf-text actual)
    (org-texmacs-test--pdf-text expected)))
  (let ((words (org-texmacs-test--pdf-words-tolerant actual))
        (reference (org-texmacs-test--pdf-words-tolerant expected)))
    (should (= (length words) (length reference)))
    (cl-mapc
     (lambda (a b)
       (should (equal (car a) (car b)))
       (cl-mapc
        (lambda (x y) (should (<= (abs (- x y)) 1.0)))
        (cdr a)
        (cdr b)))
     words reference)))

(defun org-texmacs-test--pdf-words-tolerant (pdf)
  "Return word text and bounding boxes from PDF, tolerating math controls.
Poppler can emit XML-invalid controls in mathematical glyph text; match its
bounded word records rather than interpreting the whole output as XML."
  (with-temp-buffer
    (let ((coding-system-for-read 'utf-8-unix))
      (should
       (= 0 (call-process "pdftotext" nil t nil "-bbox" pdf "-"))))
    (goto-char (point-min))
    (let (words)
      (while
          (re-search-forward
           "<word xMin=\"\\([0-9.]+\\)\" yMin=\"\\([0-9.]+\\)\" xMax=\"\\([0-9.]+\\)\" yMax=\"\\([0-9.]+\\)\">\\([^<]*\\)</word>"
           nil t)
        (push (cons
               (match-string-no-properties 5)
               (mapcar
                (lambda (index)
                  (string-to-number (match-string index)))
                '(1 2 3 4)))
              words))
      (should words)
      (nreverse words))))

(defun org-texmacs-test--pdf-render-from-saved-tm (tm pdf directory)
  "Open saved document TM in a fresh TeXmacs process and render it to PDF.
Use DIRECTORY for the script and temporary TeXmacs configuration."
  (let* ((script (expand-file-name "reload.scm" directory))
         (process-environment (copy-sequence process-environment))
         process)
    (setenv "TEXMACS_HOME_PATH"
            (expand-file-name "reload-config" directory))
    (let ((coding-system-for-write 'utf-8-unix))
      (with-temp-file script
        (insert
         "(use-modules (generic document-edit))\n"
         (format
          "(begin (catch #t (lambda () (load-buffer (system->url %S)) (do ((pass 0 (+ pass 1))) ((= pass 3)) (update-current-buffer)) (update-forced) (print-to-file (system->url %S)) (do ((pass 0 (+ pass 1))) ((= pass 3)) (update-current-buffer)) (update-forced) (print-to-file (system->url %S)) (display \"PDF-RENDER-FROM-SAVED-TM-OK\\n\")) (lambda args (display \"PDF-RENDER-FROM-SAVED-TM-ERROR\") (write args))) (quit-TeXmacs))\n"
          tm pdf pdf))))
    (unwind-protect
        (with-temp-buffer
          (setq process
                (make-process
                 :name "org-texmacs-test-pdf-render-from-saved-tm"
                 :buffer (current-buffer)
                 :connection-type 'pipe
                 :coding 'utf-8-unix
                 :noquery t
                 :sentinel #'ignore
                 :command
                 (list
                  org-texmacs-program
                  "-H"
                  "-s"
                  "-x"
                  (format "(load %S)" script))))
          (let ((deadline (+ (float-time) 45)))
            (while (and (process-live-p process)
                        (< (float-time) deadline))
              (accept-process-output process 0.1)))
          (ert-info
           ((buffer-string))
           (should-not (process-live-p process))
           (should (= 0 (process-exit-status process)))
           (should
            (string-match-p
             "PDF-RENDER-FROM-SAVED-TM-OK" (buffer-string))))
          (should (file-exists-p pdf)))
      (when (and process (process-live-p process))
        (delete-process process)))))

(defvar org-texmacs-test--pdf-inspector
  (getenv "ORG_TEXMACS_TEST_PDF_LINKS")
  "Explicitly supplied PDF destination inspector.")

(defun org-texmacs-test--pdf-link-tree (file)
  "Return Poppler's XML inspection of FILE, including actual PDF links."
  (require 'dom)
  (require 'xml)
  (let ((program (executable-find "pdftohtml")))
    (when (getenv "ORG_TEXMACS_TEST_STRICT_TOOLS")
      (should program))
    (unless program
      (ert-skip "PDF link inspection requires Poppler pdftohtml"))
    (with-temp-buffer
      (let ((coding-system-for-read 'utf-8-unix))
        (should
         (= 0
            (call-process program
                          nil
                          t
                          nil
                          "-xml"
                          "-i"
                          "-hidden"
                          "-stdout"
                          file))))
      (car (xml-parse-region (point-min) (point-max))))))

(defun org-texmacs-test--pdf-links (file)
  "Return FILE's actual PDF annotations as (TEXT . DESTINATION) pairs."
  (mapcar
   (lambda (link)
     (cons (dom-texts link) (dom-attr link 'href)))
   (dom-by-tag (org-texmacs-test--pdf-link-tree file) 'a)))

(defun org-texmacs-test--pdf-note-edge (inspection from to)
  "Assert a real link FROM text to TO's footnote line in INSPECTION."
  (let* ((source (org-texmacs-test--pdf-note-text inspection from))
         (target (org-texmacs-test--pdf-note-text inspection to))
         (box (alist-get 'rect source))
         (links
          (cl-remove-if-not
           (lambda (link)
             (let* ((rect (alist-get 'rect link))
                    (y (/ (+ (nth 1 rect) (nth 3 rect)) 2)))
               (and (= (alist-get 'page source)
                       (alist-get 'page link))
                    (<= (- (nth 1 box) 3) y (+ (nth 3 box) 3)))))
           (alist-get 'links inspection)))
         (distance
          (lambda (link)
            (let* ((rect (alist-get 'rect link))
                   (x (/ (+ (car rect) (nth 2 rect)) 2)))
              (max 0 (- (car box) x) (- x (nth 2 box)))))))
    (should links)
    (let* ((link
            (car
             (sort (copy-sequence links)
                   (lambda (a b)
                     (< (funcall distance a) (funcall distance b))))))
           (point (alist-get 'target link))
           (target-box (alist-get 'rect target))
           (line
            (cl-remove-if-not
             (lambda (text)
               (and (= (alist-get 'page target)
                       (alist-get 'page text))
                    (< (abs
                        (- (nth 1 (alist-get 'rect text))
                           (nth 1 target-box)))
                       3)))
             (alist-get 'texts inspection)))
           (left
            (apply #'min
                   (mapcar
                    (lambda (text)
                      (car (alist-get 'rect text)))
                    line)))
           (right
            (apply #'max
                   (mapcar
                    (lambda (text)
                      (nth 2 (alist-get 'rect text)))
                    line)))
           (top
            (apply #'min
                   (mapcar
                    (lambda (text)
                      (nth 1 (alist-get 'rect text)))
                    line)))
           (bottom
            (apply #'max
                   (mapcar
                    (lambda (text)
                      (nth 3 (alist-get 'rect text)))
                    line)))
           (em (- bottom top)))
      (should
       (<= (funcall distance link) (* 2 (- (nth 3 box) (nth 1 box)))))
      (should point)
      (should (= (alist-get 'page point) (alist-get 'page target)))
      ;; Native zero-width anchors can adjoin a run's end.  Check the correct
      ;; body line, including all markup runs, rather than a hard-coded point.
      (should (<= (- left em) (alist-get 'x point) (+ right em)))
      (should (<= (- top 2) (alist-get 'y point) (+ bottom 2)))
      link)))

(defun org-texmacs-test--pdf-note-inspect (file &optional links-only)
  "Inspect actual link targets and text rectangles in FILE.
LINKS-ONLY skips Poppler text XML and returns native PDF annotations only."
  (let ((python (executable-find "python3")))
    (when (getenv "ORG_TEXMACS_TEST_STRICT_TOOLS")
      (should python))
    (unless python
      (ert-skip
       "Footnote destination inspection requires Python/pypdf"))
    (unless (and org-texmacs-test--pdf-inspector
                 (file-name-absolute-p
                  org-texmacs-test--pdf-inspector)
                 (file-readable-p org-texmacs-test--pdf-inspector))
      (error
       "ORG_TEXMACS_TEST_PDF_LINKS must name the PDF inspector"))
    (let ((stderr (make-temp-file "org-texmacs-pdf-inspector-")))
      (unwind-protect
          (with-temp-buffer
            (let ((status
                   (apply #'call-process
                          python
                          nil
                          (list t stderr)
                          nil
                          org-texmacs-test--pdf-inspector
                          file
                          (and links-only '("--links-only")))))
              (unless (eq status 0)
                (goto-char (point-max))
                (insert-file-contents stderr)
                (ert-fail (buffer-string))))
            (goto-char (point-min))
            (json-parse-buffer
             :object-type 'alist
             :array-type 'list
             :null-object nil
             :false-object nil))
        (delete-file stderr)))))

(defun org-texmacs-test--pdf-note-text (inspection word)
  "Find the unique text run containing WORD in INSPECTION."
  (let ((matches
         (cl-remove-if-not
          (lambda (text)
            (string-match-p
             (regexp-quote word) (alist-get 'text text)))
          (alist-get 'texts inspection))))
    (should (= 1 (length matches)))
    (car matches)))

(defun org-texmacs-test--pdf-text (file)
  "Extract FILE's PDF text and normalize whitespace, without layout assertions."
  (let ((program (executable-find "pdftotext")))
    (when (getenv "ORG_TEXMACS_TEST_STRICT_TOOLS")
      (should program))
    (unless program
      (ert-skip "PDF semantic inspection requires Poppler pdftotext"))
    (with-temp-buffer
      (let ((coding-system-for-read 'utf-8-unix))
        (should
         (= 0
            (call-process program
                          nil
                          t
                          nil
                          "-enc"
                          "UTF-8"
                          file
                          "-"))))
      (replace-regexp-in-string
       "[[:space:]\f]+" " " (buffer-string)))))

(defun org-texmacs-test--pdf-words (file)
  "Return FILE's PDF words as (TEXT XMIN YMIN XMAX YMAX) lists."
  (require 'dom)
  (require 'xml)
  (let ((program (executable-find "pdftotext")))
    (when (getenv "ORG_TEXMACS_TEST_STRICT_TOOLS")
      (should program))
    (unless program
      (ert-skip "PDF layout inspection requires Poppler"))
    (with-temp-buffer
      (let ((coding-system-for-read 'utf-8-unix))
        (should
         (= 0 (call-process program nil t nil "-bbox" file "-"))))
      (let ((tree (car (xml-parse-region (point-min) (point-max)))))
        (mapcar
         (lambda (word)
           (cons
            (dom-text word)
            (mapcar
             (lambda (key)
               (string-to-number (dom-attr word key)))
             '(xMin yMin xMax yMax))))
         (dom-by-tag tree 'word))))))

;;; pdf.el ends here
