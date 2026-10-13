;;; phase2-probes.el --- Locked Phase 2a probes -*- lexical-binding: t; -*-
(require 'ert)
(require 'org-texmacs)
(require 'ox-ascii)

(defmacro p2-files (&rest body)
  (declare (indent 0))
  `(let* ((directory (make-temp-file "phase2-fixtures-" t))
          (default-directory (file-name-as-directory directory)))
     (unwind-protect (progn ,@body) (delete-directory directory t))))
(defun p2-write (path text)
  (let ((coding-system-for-write 'utf-8-unix)) (write-region text nil path nil 'silent)))

(ert-deftest p2-00-locked-environment ()
  (should (string-prefix-p "31.1" emacs-version))
  (should (equal (org-version) "9.8.10"))
  (princ (format "Locked environment: Emacs %s, Org %s\n" emacs-version (org-version))))

(ert-deftest p2-01-native-stage-hook-return-is-ignored ()
  (with-temp-buffer
    (org-mode) (insert "Text\n")
    (let* (events
           (org-export-before-processing-functions
            (list (lambda (backend) (push (list 'before backend) events) 23)))
           (org-export-before-parsing-functions
            (list (lambda (backend) (push (list 'after backend) events) 'arbitrary)))
           (org-export-filter-parse-tree-functions
            (list (lambda (tree backend _info) (push (list 'filter backend) events) tree)))
           (org-export-use-babel nil) (org-export-replace-macros nil))
      (should (string-match-p "Text" (org-export-as 'ascii)))
      (should (equal (reverse events) '((before ascii) (after ascii) (filter ascii)))))))

(ert-deftest p2-02-native-cross-directory-links-not-stm-origin ()
  (p2-files
    (make-directory "parts")
    (p2-write "parts/a.org" "[[file:image.png]]\n#+begin_texmacs\n(image \"image.png\")\n#+end_texmacs\n")
    (with-temp-buffer
      (org-mode) (setq buffer-file-name (expand-file-name "root.org"))
      (insert "#+INCLUDE: \"parts/a.org\"\n")
      (org-export-expand-include-keyword)
      (should (string-match-p "file:parts/image.png" (buffer-string)))
      (should (string-match-p "(image \"image.png\")" (buffer-string))))))

(ert-deftest p2-03-repeat-equal-text-distinct-occurrences ()
  (p2-files
    (p2-write "a.org" "(math \"same\")\n")
    (p2-write "b.org" "(math \"same\")\n")
    (let* ((result (p2-model "#+INCLUDE: \"a.org\"\n#+INCLUDE: \"a.org\"\n#+INCLUDE: \"b.org\"\n" default-directory))
           (islands (plist-get result :islands)))
      (should (= (length islands) 3))
      (should (= (length (delete-dups (mapcar (lambda (x) (nth 3 x)) islands))) 3))
      (should (= (length (delete-dups (mapcar (lambda (x) (nth 2 x)) islands))) 2))
      (should (string-match-p "math" (plist-get result :source))))))

(ert-deftest p2-04-nested-includes-protected-directives-and-hooks ()
  (p2-files
    (p2-write "a.org" "* A\n#+INCLUDE: \"b.org\"\n")
    (p2-write "b.org" "#+begin_texmacs\n#+INCLUDE: \"absent.org\"\n#+SETUPFILE: absent.org\n#+end_texmacs\n")
    (let (events)
      (let ((result
       (p2-model "#+INCLUDE: \"a.org\"\n" default-directory
                 (lambda (_backend) (push 'before events) (goto-char (point-min)) (insert "Prefix\n") 12)
                 (lambda (_backend) (push 'after events) (goto-char (point-max)) (insert "Suffix\n")))))
        (should (cl-find -1 (plist-get result :segments) :key #'caddr)))
      (should (equal (reverse events) '(before after))))))

(ert-deftest p2-05-position-shifts-are-working-ranges ()
  (p2-files
    (p2-write "a.org" "(math \"x\")\n")
    (let* ((result (p2-model "Root\n#+INCLUDE: \"a.org\"\nTail\n" default-directory))
           (source (plist-get result :source)) (segments (plist-get result :segments)))
      (dolist (segment segments) (should (<= 1 (car segment) (cadr segment) (1+ (length source)))))
      (should (equal (cadr (assq 1 (plist-get result :origins))) (expand-file-name "a.org"))))))

(ert-deftest p2-06-cycle-missing-cross-directory-and-directives ()
  (p2-files
    (p2-write "a.org" "#+INCLUDE: \"a.org\"\n")
    (dolist (source '("#+INCLUDE: \"a.org\"\n" "#+INCLUDE: \"missing.org\"\n"
                      "#+INCLUDE: \"parts/a.org\"\n" "#+INCLUDE: \"a.org\" :lines \"1-2\"\n"
                      "#+SETUPFILE: absent.org\n" "#+BIND: org-export-use-babel t\n"))
      (should-error (p2-model source default-directory)))))

(ert-deftest p2-07-stm-marker-loss-is-not-text-equality-recovery ()
  (p2-files
    (should-error
     (p2-model "(math \"x\")\n" default-directory
               (lambda (_backend) (erase-buffer) (insert "(math \"x\")\n"))))))

(ert-deftest p2-08-native-selection-does-not-map-original-offsets ()
  (p2-files
    (p2-write "a.org" "Expanded content before selection\n")
    (with-temp-buffer
      (org-mode) (insert "#+INCLUDE: \"a.org\"\nSelected\n")
      (let ((original (save-excursion (goto-char (point-min)) (forward-line) (point))))
        (org-export-expand-include-keyword nil default-directory)
        (goto-char (point-min)) (search-forward "Selected")
        (should-not (= original (- (point) (length "Selected"))))))))

(ert-deftest p2-09-dependency-change-after-capture ()
  (p2-files
    (p2-write "a.org" "Original\n")
    (should-error (p2-model "#+INCLUDE: \"a.org\"\n" default-directory nil
                            (lambda (_backend) (p2-write "a.org" "Changed\n"))))))

(ert-deftest p2-10-whole-working-view-origin-distinction ()
  (p2-files
    (p2-write "a.org" "Included\n")
    (let* ((result (p2-model "Root\n#+INCLUDE: \"a.org\"\n" default-directory nil
                             (lambda (_backend) (goto-char (point-max)) (insert "Generated\n"))))
           (origins (plist-get result :segments)))
      (should (cl-find 0 origins :key #'caddr))
      (should (cl-find 1 origins :key #'caddr))
      (should (cl-find -1 origins :key #'caddr))
      (should-not (cadddr (cl-find -1 origins :key #'caddr))))))

(ert-deftest p2-11-whole-file-footnotes-retain-occurrence ()
  (p2-files
    (p2-write "a.org" "Text[fn:a]\n[fn:a] Note\n")
    (let ((result (p2-model "#+INCLUDE: \"a.org\"\n" default-directory)))
      (should (string-match-p "fn:-0-a" (plist-get result :source)))
      (should (cl-every (lambda (segment) (= (nth 2 segment) 1))
                        (plist-get result :segments))))))

(ert-run-tests-batch-and-exit "^p2-")
