;;; inline-derived-probe-20260911.el --- Derived scanner experiments -*- lexical-binding: t; -*-
(require 'ert)
(require 'cl-lib)
(require 'org-texmacs)
(load (expand-file-name "tests/ert/ert.el" default-directory) nil t)

(defvar derived-probe-table
  (let ((table (make-syntax-table)))
    (dolist (char '(?\[ ?\] ?\{ ?\} ?\; ?# ?\' ?` ?, ?|))
      (modify-syntax-entry char "." table))
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)
    table))

(defun derived-probe-boundary (start)
  "Return (STATUS END) within the current paragraph narrowing."
  (with-syntax-table derived-probe-table
    (let* ((parse-sexp-lookup-properties nil)
           (parse-sexp-ignore-comments nil)
           (end (condition-case nil (scan-sexps start 1) (scan-error nil)))
           (comment nil))
      ;; This is a small unsupported-syntax guard, not a Scheme lexer.
      (save-excursion
        (goto-char start)
        (while (and (not comment) (re-search-forward ";\\|#|" (or end (point-max)) t))
          (let ((marker (match-beginning 0)))
            (unless (save-excursion (nth 3 (parse-partial-sexp start marker)))
              (setq comment t)))))
      (cond (comment (list 'unsupported-comment nil))
            (end (list 'ok end))
            (t (list 'incomplete nil))))))

(defun derived-probe-scan (&optional disable-masking)
  "Discover spans using public Org operations and an isolated source copy.
The prototype only accepts paragraph context and excludes TeXmacs blocks.
On unsupported/incomplete input, leave the paragraph remainder as text."
  (let* ((source-buffer (current-buffer))
         (text (buffer-substring-no-properties (point-min) (point-max)))
         (offset (1- (point-min)))
         (paragraphs (org-element-map (org-element-parse-buffer 'element)
                         'paragraph #'identity))
         (spans nil))
    (with-temp-buffer
      (let ((shadow (current-buffer)) (org-element-use-cache nil))
        (org-mode)
        (insert text)
        (dolist (paragraph paragraphs)
          (unless (equal (org-element-property :type
                          (org-element-lineage paragraph '(special-block))) "texmacs")
            (with-current-buffer source-buffer
              (save-excursion
                (save-restriction
                  (narrow-to-region (org-element-property :contents-begin paragraph)
                                    (org-element-property :contents-end paragraph))
                  (goto-char (point-min))
                  (let ((stop nil))
                    (while (and (not stop) (search-forward "(math" nil t))
                      (let ((start (- (point) 5)))
                        (when (and (memq (char-after) '(?\s ?\t ?\r ?\n ?\( ?\)))
                                   (with-current-buffer shadow
                                     (goto-char (- start offset))
                                     (eq (org-element-type (org-element-context)) 'paragraph)))
                          (pcase-let ((`(,status ,end) (derived-probe-boundary start)))
                            (if (not (eq status 'ok))
                                (setq stop t)
                              (let ((raw (buffer-substring-no-properties start end)))
                                (push (list start end raw) spans)
                                (unless disable-masking
                                  (with-current-buffer shadow
                                    (goto-char (- start offset))
                                    (delete-region (point) (- end offset))
                                    (insert (replace-regexp-in-string "[^\n]" " " raw)))))
                              (goto-char end))))))))))))))
    (nreverse spans)))

(ert-deftest derived-probe-source-cases ()
  (dolist (case
           '(("A (math \"x\") B\n" "(math \"x\")")
             ("A (math (frac \"1\" (sqrt \"x\"))) B\n" "(math (frac \"1\" (sqrt \"x\")))")
             ("A (math (concat \"a)\\\"b\" \"c\\\\d\")) B\n" "(math (concat \"a)\\\"b\" \"c\\\\d\"))")
             ("A (math\n (frac \"1\" \"2\")) B\n" "(math\n (frac \"1\" \"2\"))")
             ("A (math \"x\") B (math \"y\") C\n" "(math \"x\")" "(math \"y\")")
             ("A (math(frac \"1\" \"2\")) B\n" "(math(frac \"1\" \"2\"))")
             ("A (mathjax \"x\") B (foo bar) C (math\"x\")\n")
             ("A (math (frac \"1\" \"2\") B\n\nNext ) paragraph.\n")
             ("A (math \"unclosed) B\n")
             ("A ~(math \"x\")~ B =(math \"y\")= C\n")
             ("A [[file:x][(math \"x\")]] B *(math \"y\")* C\n")
             ("A (math (concat \"*bold*\" \"[[file:x]]\" \"~code~\")) B\n"
              "(math (concat \"*bold*\" \"[[file:x]]\" \"~code~\"))")
             ("* Heading (math \"x\")\n")
             ("| cell (math \"x\") |\n")
             ("#+begin_src scheme\n(math \"x\")\n#+end_src\n")
             ("#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n")
             ("- Item (math \"x\")\n" "(math \"x\")")
             ("A (math (unknown ...)) B\n" "(math (unknown ...))")
             ("A (math \"literal ; #; #| |#\") B\n" "(math \"literal ; #; #| |#\")")
             ("A (math ;; ) comment\n \"x\") B\n")
             ("A (math #; (sqrt \"x\") \"y\") B\n")
             ("A (math #| ) comment |# \"x\") B\n")
             ("A (math ; comment (math \"not-a-formula\")\n \"x\") B (math \"y\")\n")
             ("A (math (frac \"1\" \"2\") B (math \"y\") C\n")))
    (ert-info ((car case))
      (with-temp-buffer
        (org-mode)
        (insert (car case))
        (let ((text (buffer-string)) (position (point))
              (tick (buffer-chars-modified-tick)))
          (should (equal (mapcar #'caddr (derived-probe-scan)) (cdr case)))
          (should (equal (buffer-string) text))
          (should (= (point) position))
          (should (= tick (buffer-chars-modified-tick))))))))

(ert-deftest derived-probe-crossing-native-markup ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math (concat \"~foo\" \"bar\")) after (math \"y\") end~ Z\n")
    (princ (format "WITHOUT-MASK %S\n" (mapcar #'caddr (derived-probe-scan t))))
    (princ (format "WITH-MASK %S\n" (mapcar #'caddr (derived-probe-scan))))
    (should (equal (mapcar #'caddr (derived-probe-scan))
                   '("(math (concat \"~foo\" \"bar\"))" "(math \"y\")")))))

(ert-deftest derived-probe-original-org-still-sees-markup ()
  (with-temp-buffer
    (org-mode)
    (insert "A (math (concat \"*bold*\" \"[[file:x]]\")) B\n")
    (derived-probe-scan)
    (should (equal (org-element-map (org-element-parse-buffer) '(bold link)
                    #'org-element-type) '(bold link)))))

(ert-deftest derived-probe-native-interpretation ()
  (dolist (text '("A (math (frac \"1\" \"2\")) B\n"
                  "A (math (concat \"*bold*\" \"[[file:x]]\")) B\n"
                  "A (math \"x\") B"
                  "A (math \"first\n\nsecond\") B\n"))
    (with-temp-buffer
      (org-mode)
      (insert text)
      (let ((result (substring-no-properties
                     (org-element-interpret-data (org-element-parse-buffer)))))
        (princ (format "NATIVE-ROUNDTRIP %S => %S exact=%S\n" text result (equal text result)))))))

(ert-deftest derived-probe-narrowing ()
  (with-temp-buffer
    (org-mode)
    (insert "Outside\n\nA (math \"x\") B\n\nEnd\n")
    (goto-char (point-min))
    (search-forward "A ")
    (let ((begin (- (point) 2)) (end (line-beginning-position 2)))
      (narrow-to-region begin end)
      (should (equal (mapcar #'caddr (derived-probe-scan)) '("(math \"x\")")))
      (should (= (point-min) begin))
      (should (= (point-max) end)))))

(ert-deftest derived-probe-worker-validation-limits ()
  (org-texmacs-test--with-worker
    (let ((org-texmacs-worker-start-timeout 10))
      (dolist (source '("(math (not-a-valid-texmacs-form \"x\"))"
                        "(math (frac \"1\"))" "(math)"
                        "(math (frac \"1\" \"2\" \"3\"))"))
        (princ (format "SEMANTIC-LIMIT %S => %S\n" source
                       (condition-case err (org-texmacs--worker-request source)
                         (error (list (car err) (error-message-string err))))))))))
