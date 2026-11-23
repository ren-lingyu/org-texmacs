;;; ert-cite-standard-cite.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'oc)
(require 'org)
(require 'ox)
(require 'ox-texmacs)

(require 'oc-csl)

(ert-deftest
    org-texmacs-standard-csl-text-and-pdf-without-serialization-roundtrip
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-csl
    (with-temp-buffer
      (org-mode)
      (insert
       csl-header
       "Text [cite:@key]. (math (sqrt \"x\"))\n#+print_bibliography:\n")
      (let ((org-export-use-babel nil)
            (before (buffer-string))
            (prepared 0))
        (let ((org-export-before-processing-functions
               (list (lambda (_) (cl-incf prepared)))))
          (should (string-match-p "TeXmacs" (org-export-as 'texmacs)))
          (should (= prepared 1))
          (setq prepared 0)
          (cl-letf
              (((symbol-function 'org-texmacs-document-serialize)
                (lambda (&rest _)
                  (ert-fail
                   "PDF must consume native document directly"))))
            (let ((pdf (org-texmacs--standard-consume 'pdf))
                  (file
                   (expand-file-name "citation.pdf"
                                     default-directory)))
              (should (string-prefix-p "%PDF-" pdf))
              (let ((coding-system-for-write 'no-conversion))
                (write-region pdf nil file nil 'silent))
              (let ((text (org-texmacs-test--pdf-text file)))
                (should (string-match-p "Reference Alpha" text))
                (should-not (string-search "<#200B>" text)))))
          (should (= prepared 1))
          (should (equal before (buffer-string)))))))))

(ert-deftest
    org-texmacs-standard-csl-zero-width-delimiters-render-without-visible-fallback
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert "ab\n\na\u200bb\n")
     (let* ((org-export-use-babel nil)
            (pdf (org-texmacs--standard-consume 'pdf))
            (file
             (expand-file-name "zero-width.pdf" default-directory)))
       (let ((coding-system-for-write 'no-conversion))
         (write-region pdf nil file nil 'silent))
       (should-not
        (string-search "<#200B>" (org-texmacs-test--pdf-text file)))
       (let* ((words
               (cl-remove-if-not
                (lambda (word) (equal (car word) "ab"))
                (org-texmacs-test--pdf-words file)))
              (widths
               (mapcar
                (lambda (word) (- (nth 3 word) (nth 1 word))) words)))
         (should (= (length words) 2))
         (should (< (abs (- (car widths) (cadr widths))) 0.01)))))))

(ert-deftest org-texmacs-standard-csl-interactive-command-consumers ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-csl
    (with-temp-buffer
      (org-mode)
      (setq buffer-file-name
            (expand-file-name "source.org" default-directory))
      (insert
       csl-header
       "[cite:@key]
 #+print_bibliography:
 ")
      (let ((org-export-use-babel nil)
            (org-export-show-temporary-export-buffer nil)
            (cite (symbol-function 'org-cite-csl-render-citation)))
        (dolist (command
                 '(org-texmacs-export-as-texmacs
                   org-texmacs-export-to-texmacs
                   org-texmacs-export-to-pdf))
          (let ((prepared 0)
                (citations 0))
            (let ((org-export-before-processing-functions
                   (list (lambda (_) (cl-incf prepared)))))
              (cl-letf (((symbol-function
                          'org-cite-csl-render-citation)
                         (lambda (&rest args)
                           (cl-incf citations)
                           (apply cite args))))
                (let ((result (funcall command)))
                  (cond
                   ((bufferp result)
                    (unwind-protect
                        (should
                         (string-match-p
                          "Reference Alpha"
                          (with-current-buffer result
                            (buffer-string))))
                      (kill-buffer result)))
                   ((eq command 'org-texmacs-export-to-pdf)
                    (should
                     (string-match-p
                      "Reference Alpha"
                      (org-texmacs-test--pdf-text result))))
                   (t
                    (with-temp-buffer
                      (insert-file-contents-literally result)
                      (should
                       (string-match-p
                        "Reference Alpha" (buffer-string)))))))))
            (should (= prepared 1))
            (should (= citations 1)))))))))

(ert-deftest org-texmacs-standard-csl-explicit-source-consumers ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-csl
    (with-temp-buffer
      (org-mode)
      (insert csl-header "[cite:@key]\n#+print_bibliography:\n")
      (let ((source (current-buffer))
            (cite (symbol-function 'org-cite-csl-render-citation)))
        (dolist (kind '(tm pdf buffer tm-file pdf-file))
          (let ((prepared 0)
                (citations 0)
                (file
                 (expand-file-name (format "source-%s" kind)
                                   default-directory)))
            (let ((org-export-before-processing-functions
                   (list (lambda (_) (cl-incf prepared)))))
              (cl-letf (((symbol-function
                          'org-cite-csl-render-citation)
                         (lambda (&rest args)
                           (cl-incf citations)
                           (apply cite args))))
                (let ((result
                       (with-temp-buffer
                         (pcase kind
                           ('tm
                            (org-texmacs-export-texmacs-from-buffer
                             source))
                           ('pdf
                            (org-texmacs-export-pdf-from-buffer
                             source))
                           ('buffer
                            (org-texmacs-export-to-buffer source))
                           ('tm-file
                            (org-texmacs-export-to-texmacs-file
                             source file))
                           ('pdf-file
                            (org-texmacs-export-to-pdf-file
                             source file))))))
                  (pcase kind
                    ('buffer
                     (unwind-protect
                         (with-current-buffer result
                           (should
                            (string-search
                             "Reference alpha" (buffer-string))))
                       (kill-buffer result)))
                    ('pdf (should (string-prefix-p "%PDF-" result)))
                    ('pdf-file
                     (should
                      (string-search
                       "Reference alpha"
                       (org-texmacs-test--pdf-text result))))
                    ('tm-file
                     (with-temp-buffer
                       (insert-file-contents-literally result)
                       (should
                        (string-search
                         "Reference alpha" (buffer-string)))))
                    (_
                     (should
                      (string-search "Reference alpha" result)))))))
            (should (= prepared 1))
            (should (= citations 1)))))))))

(ert-deftest
    org-texmacs-standard-csl-owned-bibliography-after-preparation
    ()
  (org-texmacs-test--with-worker
   (org-texmacs-test--with-csl
    (with-temp-buffer
      (org-mode)
      (setq buffer-file-name
            (expand-file-name "source.org" default-directory))
      (insert
       csl-header
       "[cite:@key]
 #+print_bibliography:
 ")
      (let ((org-export-use-babel nil)
            (original
             (with-temp-buffer
               (insert-file-contents csl-bibliography)
               (buffer-string))))
        (dolist (kind '(tm pdf))
          (with-temp-file csl-bibliography
            (insert original))
          (let* ((consumer
                  (if (eq kind 'pdf)
                      'org-texmacs-document-pdf
                    'org-texmacs-document-serialize))
                 (native (symbol-function consumer)))
            (cl-letf (((symbol-function consumer)
                       (lambda (document)
                         (should
                          (string-match-p
                           "Reference Alpha"
                           (prin1-to-string
                            (org-texmacs-document-body document))))
                         (with-temp-file csl-bibliography
                           (insert "Changed external bibliography"))
                         (funcall native document))))
              (let ((file
                     (if (eq kind 'pdf)
                         (org-texmacs-export-to-pdf)
                       (org-texmacs-export-to-texmacs))))
                (if (eq kind 'pdf)
                    (should
                     (string-match-p
                      "Reference Alpha"
                      (org-texmacs-test--pdf-text file)))
                  (with-temp-buffer
                    (insert-file-contents-literally file)
                    (should
                     (string-match-p
                      "Reference Alpha" (buffer-string))))))))))))))

;;; ert-cite-standard-cite.el ends here
