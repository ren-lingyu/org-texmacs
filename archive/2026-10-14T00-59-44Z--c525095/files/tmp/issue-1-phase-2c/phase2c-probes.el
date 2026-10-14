;;; phase2c-probes.el --- Direct native composition probes -*- lexical-binding: t; -*-
(require 'ert)
(require 'org-texmacs)
(require 'ox-html)

(defmacro p2c-files (&rest body)
  (declare (indent 0))
  `(let* ((directory (make-temp-file "phase2c-" t))
          (default-directory (file-name-as-directory directory))
          (org-mode-hook nil) (org-inhibit-startup t) (org-element-use-cache nil))
     (unwind-protect (progn ,@body) (delete-directory directory t))))
(defun p2c-write (name text)
  (let ((coding-system-for-write 'utf-8-unix)) (write-region text nil name nil 'silent)))
(defun p2c-native (text)
  (with-temp-buffer
    (org-mode) (setq buffer-file-name (expand-file-name "root.org"))
    (insert text) (org-export-expand-include-keyword)
    (buffer-string)))

(ert-deftest p2c-00-environment ()
  (should (string-prefix-p "31.1" emacs-version))
  (should (equal (org-version) "9.8.10")))

(ert-deftest p2c-01-parameter-matrix ()
  (p2c-files
    (p2c-write "part.org" "Preamble\n* Alpha\n:PROPERTIES:\n:CUSTOM_ID: alpha\n:END:\nFirst\nSecond\n** Child\nChild body\n* Beta\nOutside\n")
    (dolist (value '("\"part.org::*Alpha\"" "\"part.org::#alpha\" :only-contents t"
                     "\"part.org\" :lines \"6-8\"" "\"part.org::*Alpha\" :minlevel 3"
                     "\"part.org::*Alpha\" :only-contents t :lines \"1-3\""
                     "\"part.org::*Alpha\" :lines \"2-4\""))
      (let ((result (p2c-native (format "#+INCLUDE: %s\n" value))))
        (princ (format "CASE %s -> %S\n" value result))
        (should-not (string-match-p "Outside" result))))))

(ert-deftest p2c-02-selected-nested-dependencies ()
  (p2c-files
    (p2c-write "part.org" "* Selected\nKept\n* Excluded\n#+INCLUDE: \"absent.org\"\n")
    (should (string-match-p "Kept" (p2c-native "#+INCLUDE: \"part.org::*Selected\"\n")))))

(ert-deftest p2c-03-external-footnote-stm ()
  (p2c-files
    (p2c-write "part.org" "Selected[fn:a]\nOutside\n[fn:a] Note (math \"x\")\n")
    (let ((result (p2c-native "#+INCLUDE: \"part.org\" :lines \"1-2\"\n")))
      (princ (format "FOOTNOTE %S\n" result))
      (should (string-match-p "Note (math" result))
      (should-not (string-match-p "Outside" result)))))

(ert-deftest p2c-04-stm-native-effects ()
  (p2c-files
    (dolist (text '("#+begin_texmacs\n#+INCLUDE: \"absent.org\"\n#+end_texmacs\n"
                    "(math \"[fn:a]\")\n[fn:a] Note\n"
                    "(concat \"\n* Payload heading\n\")\n"))
      (p2c-write "part.org" text)
      (condition-case err
          (princ (format "STM input=%S result=%S\n" text (p2c-native "#+INCLUDE: \"part.org\" :minlevel 3\n")))
        (error (princ (format "STM input=%S error=%S\n" text err)))))))

(ert-deftest p2c-05-fixed-native-reader ()
  (p2c-files
    (p2c-write "part.org" "* Alpha\nFixed\n")
    (let ((reader (symbol-function 'org-file-contents)) cache reads)
      (cl-letf (((symbol-function 'org-file-contents)
                 (lambda (file &optional noerror nocache)
                   (push file reads)
                   (copy-sequence (or (cdr (assoc file cache))
                                      (let ((text (funcall reader file noerror nocache)))
                                        (push (cons file text) cache)
                                        (p2c-write "part.org" "* Alpha\nChanged\n") text))))))
        (let ((result (p2c-native "#+INCLUDE: \"part.org::*Alpha\"\n#+INCLUDE: \"part.org::*Alpha\"\n")))
          (should-not (string-match-p "Changed" result))
          (should (= (length cache) 1))
          (princ (format "FIXED reads=%d result=%S\n" (length reads) result)))))))

(ert-deftest p2c-06-partial-stm-native-selection ()
  (p2c-files
    (p2c-write "part.org" "(concat \"\nBody\n\")\n")
    (let ((result (p2c-native "#+INCLUDE: \"part.org\" :lines \"2-3\"\n")))
      (princ (format "PARTIAL STM %S\n" result))
      (should (string-match-p "Body" result)))))

(ert-deftest p2c-07-repeated-footnote-native-identity ()
  (p2c-files
    (p2c-write "part.org" "Text[fn:a]\n[fn:a] Note\n")
    (princ (format "REPEATED %S\n" (p2c-native "#+INCLUDE: \"part.org\"\n#+INCLUDE: \"part.org\"\n")))))

(ert-deftest p2c-08-line-preserving-protection ()
  (p2c-files
    (let* ((raw "(concat \"\n* Payload [fn:a]\n\")")
           (protected "TXMBEGIN\n\nTXMEND")
           (contents (concat "* Alpha\n" protected "\n* Beta\nOutside\n")))
      (p2c-write "part.org" contents)
      (dolist (value '("\"part.org::*Alpha\" :only-contents t"
                       "\"part.org\" :lines \"2-5\""
                       "\"part.org::*Alpha\" :minlevel 3"))
        (let ((result (p2c-native (format "#+INCLUDE: %s\n" value))))
          (should (string-match (regexp-quote protected) result))
          (setq result (replace-match raw t t result))
          (should (string-match-p (regexp-quote raw) result))
          (princ (format "PROTECTED %s -> %S\n" value result)))))))

(ert-run-tests-batch-and-exit "^p2c-")
