;;; phase4-probes.el --- Locked working-context investigation -*- lexical-binding: t; -*-
(require 'ert)
(require 'org-texmacs-preprocess)
(require 'ox-ascii)
(require 'oc)
(require 'org-roam)

(defmacro p4-files (&rest body)
  (declare (indent 0))
  `(let* ((directory (make-temp-file "phase4-probes-" t))
          (default-directory (file-name-as-directory directory))
          (org-mode-hook nil) (org-inhibit-startup t) (org-element-use-cache nil))
     (unwind-protect (progn (make-directory "parts/sub" t) ,@body)
       (delete-directory directory t))))
(defun p4-write (name text)
  (let ((coding-system-for-write 'utf-8-unix)) (write-region text nil name nil 'silent)))
(defun p4-native (text)
  (with-temp-buffer
    (org-mode) (setq buffer-file-name (expand-file-name "root.org"))
    (insert text) (org-export-expand-include-keyword)
    (buffer-string)))

(ert-deftest p4-00-environment ()
  (should (string-prefix-p "31.1" emacs-version))
  (should (equal (org-version) "9.8.10"))
  (should (fboundp 'org-roam-db-sync))
  (should (sqlite-available-p))
  (princ (format "Emacs=%s Org=%s Org-roam-library=%s\n"
                 emacs-version (org-version) (locate-library "org-roam"))))

(ert-deftest p4-01-native-nested-context-links-and-notes ()
  (p4-files
    (p4-write "parts/a.org" "* Alpha\n#+INCLUDE: \"sub/b.org\" :only-contents t\n")
    (p4-write "parts/sub/b.org" "[[file:asset.txt][Asset]] [fn:a]\n[fn:a] Note\n")
    (let ((result (p4-native "#+INCLUDE: \"parts/a.org::*Alpha\" :only-contents t :minlevel 2\n")))
      (princ (format "NESTED %S\n" result))
      (should (string-match-p "parts/sub/asset.txt" result))
      (should (string-match-p "Note" result)))))

(ert-deftest p4-02-actual-export-working-context ()
  (p4-files
    (with-temp-buffer
      (org-mode) (setq buffer-file-name (expand-file-name "root.org"))
      (setq-local org-export-with-toc nil)
      (insert "* Heading\nText\n")
      (let* ((source (current-buffer)) (before (buffer-string)) events
             (org-export-use-babel nil) (org-export-replace-macros nil)
             (org-export-before-processing-functions
              (list (lambda (_backend)
                      (push (list :stage 'before :private (not (eq source (current-buffer)))
                                  :file buffer-file-name :directory default-directory
                                  :toc org-export-with-toc :mode major-mode) events))))
             (org-export-before-parsing-functions
              (list (lambda (_backend)
                      (push (list :stage 'after :file buffer-file-name
                                  :directory default-directory :toc org-export-with-toc) events)))))
        (should (string-match-p "Text" (org-export-as 'ascii)))
        (should (equal before (buffer-string)))
        (should (plist-get (cadr events) :private))
        (princ (format "CONTEXT %S\n" (reverse events)))))))

(ert-deftest p4-03-final-context-relative-bibliography ()
  (p4-files
    (p4-write "parts/a.org" "#+bibliography: refs.bib\nText\n")
    (let ((result (p4-native "#+INCLUDE: \"parts/a.org\"\n")))
      (with-temp-buffer
        (org-mode) (setq buffer-file-name (expand-file-name "root.org"))
        (insert result)
        (princ (format "BIB text=%S files=%S\n" result (org-cite-list-bibliography-files)))
        (should (string-match-p "bibliography: refs.bib" result))))))

(ert-deftest p4-04-current-adapter-directory-rejection ()
  (p4-files
    (p4-write "parts/a.org" "Text\n")
    (with-temp-buffer
      (org-mode) (insert "#+INCLUDE: \"parts/a.org\"\n")
      (should-error (org-texmacs-prepare-buffer-preprocessed (current-buffer))
                    :type 'org-texmacs-document-error))))

(ert-deftest p4-05-stm-relative-path-remains-working-text ()
  (p4-files
    (p4-write "parts/a.org" "(image \"asset.png\")\n")
    (should (equal (p4-native "#+INCLUDE: \"parts/a.org\"\n") "(image \"asset.png\")\n"))))

(ert-run-tests-batch-and-exit "^p4-")
