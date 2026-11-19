;;; pdf.el --- pdf regression support -*- lexical-binding: t; -*-

;;; Commentary:

;; Test-owned support and fixtures.

;;; Code:

(defvar org-texmacs-test--pdf-inspector
  (getenv "ORG_TEXMACS_TEST_PDF_LINKS")
  "Explicitly supplied PDF destination inspector.")

(defun org-texmacs-test--issue13-stage3-graphic-ink (pdf)
  "Find non-text graphic ink near the first Diagram label in PDF.
Rasterize using existing Poppler, excluding the label's word box."
  (let* ((word
          (cl-find
           "Diagram"
           (org-texmacs-test--issue11-pdf-geometry pdf)
           :key #'car
           :test #'equal))
         (box (cdr word))
         (center (/ (+ (nth 1 box) (nth 3 box)) 2.0))
         (count 0)
         xs
         ys)
    (should word)
    (with-temp-buffer
      (set-buffer-multibyte nil)
      (should
       (= 0
          (call-process "pdftoppm"
                        nil
                        t
                        nil
                        "-f"
                        "1"
                        "-singlefile"
                        "-gray"
                        "-r"
                        "72"
                        pdf)))
      (goto-char (point-min))
      (should (looking-at "P5\n\\([0-9]+\\) \\([0-9]+\\)\n255\n"))
      (let ((width (string-to-number (match-string 1)))
            (height (string-to-number (match-string 2)))
            (start (match-end 0)))
        (cl-loop
         for
         y
         from
         (max 0 (floor (- center 20)))
         below
         (min height (ceiling (+ center 20)))
         do
         (cl-loop
          for
          x
          from
          (max 0 (floor (- (car box) 35)))
          below
          (min width (ceiling (+ (nth 2 box) 35)))
          do
          (when (and (not
                      (and (<= (- (car box) 2) x (+ (nth 2 box) 2))
                           (<= (- (nth 1 box) 2)
                               y
                               (+ (nth 3 box) 2))))
                     (< (char-after (+ start (* y width) x)) 128))
            (cl-incf count)
            (push x xs)
            (push y ys))))))
    (should (> count 50))
    (list
     (apply #'min xs)
     (apply #'min ys)
     (apply #'max xs)
     (apply #'max ys))))

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

(defun org-texmacs-test--pdf-word (words text)
  "Find exactly one word TEXT in WORDS and return its coordinate list."
  (let ((matches
         (cl-remove-if-not
          (lambda (word) (equal (car word) text)) words)))
    (should (= (length matches) 1))
    (cdar matches)))

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

(defun org-texmacs-test--adjacent-pdf-targets (file)
  "Check FILE's derived link destinations and TOC values against actual pages."
  (let* ((tree (org-texmacs-test--pdf-link-tree file))
         (pages (dom-by-tag tree 'page))
         (page-texts
          (mapcar
           (lambda (page)
             (cons
              (string-to-number (dom-attr page 'number))
              (mapconcat #'dom-texts (dom-by-tag page 'text) " ")))
           pages))
         links)
    (dolist (page pages)
      (dolist (link (dom-by-tag page 'a))
        (push (list
               (string-to-number (dom-attr page 'number))
               (dom-texts link)
               (dom-attr link 'href))
              links)))
    (cl-labels
     ((page-of
       (marker)
       (let ((matches
              (cl-remove-if-not
               (lambda (entry)
                 (string-match-p marker (cdr entry)))
               page-texts)))
         (should (= 1 (length matches)))
         (caar matches)))
      (jumps
       (text target &optional from)
       (cl-remove-if-not
        (lambda (link)
          (and (or (null from) (= from (car link)))
               (equal text (nth 1 link))
               (string-suffix-p
                (format ".html#%d" target) (nth 2 link))))
        links)))
     (let ((alpha (page-of "AlphaBodySentinel"))
           (omega (page-of "OmegaBodySentinel"))
           (note (page-of "NamedFootnoteBodySentinel"))
           (first (page-of "FirstTitleSentinel"))
           (second (page-of "SecondTitleSentinel")))
       (should (jumps "1 AlphaDestination" alpha 1))
       (should (jumps "2 OmegaDestination" omega 1))
       (should (jumps "ForwardToOmega" omega))
       (should (jumps "BackToAlpha" alpha))
       (should (jumps "1" first alpha))
       (should (jumps "2" second alpha))
       (should (jumps "1" first omega))
       ;; Numeric headline reference and repeated footnote must both link.
       (should (jumps "1" alpha omega))
       (should (jumps "1" note omega))
       (when (= alpha note)
         (should (>= (length (jumps "1" note omega)) 2)))
       (dolist (entry
                `(("AlphaDestination" . ,alpha)
                  ("OmegaDestination" . ,omega)))
         (should
          (string-match-p
           (format "%s[[:space:].]*%d\\b"
                   (car entry)
                   (cdr entry))
           (cdar page-texts))))))))

(defun org-texmacs-test--issue11-reload-pdf (tm pdf directory)
  "Render saved TM to PDF in an independent native process under DIRECTORY."
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
          "(begin (catch #t (lambda () (load-buffer (system->url %S)) (do ((pass 0 (+ pass 1))) ((= pass 3)) (update-current-buffer)) (update-forced) (print-to-file (system->url %S)) (do ((pass 0 (+ pass 1))) ((= pass 3)) (update-current-buffer)) (update-forced) (print-to-file (system->url %S)) (display \"ISSUE11-RELOAD-OK\\n\")) (lambda args (display \"ISSUE11-RELOAD-ERROR\") (write args))) (quit-TeXmacs))\n"
          tm pdf pdf))))
    (unwind-protect
        (with-temp-buffer
          (setq process
                (make-process
                 :name "org-texmacs-test-issue11-reload"
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
            (string-match-p "ISSUE11-RELOAD-OK" (buffer-string))))
          (should (file-exists-p pdf)))
      (when (and process (process-live-p process))
        (delete-process process)))))

(defun org-texmacs-test--issue11-pdf-geometry (pdf)
  "Return PDF word text and boxes, tolerating native math control characters.
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

(defun org-texmacs-test--issue11-compare-pdfs (actual expected)
  "Check text and per-word geometry of ACTUAL and EXPECTED in matched contexts."
  (should
   (equal
    (org-texmacs-test--pdf-text actual)
    (org-texmacs-test--pdf-text expected)))
  (let ((words (org-texmacs-test--issue11-pdf-geometry actual))
        (reference (org-texmacs-test--issue11-pdf-geometry expected)))
    (should (= (length words) (length reference)))
    (cl-mapc
     (lambda (a b)
       (should (equal (car a) (car b)))
       (cl-mapc
        (lambda (x y) (should (<= (abs (- x y)) 1.0)))
        (cdr a)
        (cdr b)))
     words reference)))

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

;;; pdf.el ends here
