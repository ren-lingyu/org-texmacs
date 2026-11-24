;;; probe.el --- Headline provenance baseline -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'org)
(require 'ox-texmacs)

(defun probe-forward (todo todo-type priority parts tags info)
  (org-texmacs-format-headline-default-function
   todo todo-type priority parts tags info))

(defun probe-report (key value)
  (let ((print-escape-newlines t))
    (princ (format "%S %S\n" key value))))

(defun probe-check (value label)
  (unless value (error "Probe assertion failed: %S" label)))

(defun probe-document (source formatter)
  (with-temp-buffer
    (org-mode)
    (setq-local default-directory "/probe-source/")
    (insert "#+OPTIONS: author:nil title:nil date:nil\n" source)
    (let* ((org-export-use-babel nil)
           (org-texmacs-format-headline-function formatter)
           (input (org-texmacs-prepare-buffer (current-buffer)))
           (document (org-texmacs-document input)))
      (list :body (org-texmacs-document-body document)
            :stm (org-texmacs-document-stm-paths document)
            :files (org-texmacs-document-file-paths document)
            :tm-wire (org-texmacs--native-document-wire document)
            :pdf-wire (org-texmacs--native-document-wire document t)))))

(probe-report 'versions (list emacs-version (org-version)))
(dolist (case '((stm . "#+OPTIONS: toc:nil\n* Math $(math \"<alpha>\")$\n")
                (file . "#+OPTIONS: toc:nil\n* Read [[file:asset.pdf][Attachment]]\n")
                (body-file . "#+OPTIONS: toc:nil\n* Read\n[[file:asset.pdf][Attachment]]\n")
                (toc . "#+OPTIONS: toc:1 tags:not-in-toc\n* Visible :probe:\n:PROPERTIES:\n:ALT_TITLE: Short *title*\n:END:\n")))
  (let* ((id (car case))
         (default (probe-document (cdr case)
                                  #'org-texmacs-format-headline-default-function))
         (custom (probe-document (cdr case) #'probe-forward)))
    (probe-report (list id 'default) default)
    (probe-report (list id 'custom) custom)
    (probe-check (equal (plist-get default :body) (plist-get custom :body))
                 (list id 'equal-body))
    (pcase id
      ('stm
       (probe-check (and (plist-get default :stm) (not (plist-get custom :stm))
                         (not (equal (plist-get default :tm-wire)
                                     (plist-get custom :tm-wire))))
                    'stm-provenance))
      ('file
       (probe-check (and (equal default custom)
                         (equal (plist-get default :body)
                                '(document (section (concat "Read " "Attachment"))))
                         (not (plist-get default :files)))
                    'title-file-fallback))
      ('body-file
       (probe-check (and (equal default custom)
                         (plist-get default :files)
                         (string-match-p "/probe-source/asset.pdf"
                                         (plist-get default :tm-wire))
                         (not (string-match-p "/probe-source/asset.pdf"
                                              (plist-get default :pdf-wire))))
                    'body-file-provenance))
      ('toc
       (probe-check (equal default custom) 'toc-output)))))
(probe-report 'status 'passed)
