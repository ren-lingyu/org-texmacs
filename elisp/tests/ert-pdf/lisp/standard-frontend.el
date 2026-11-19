;;; standard-frontend.el --- Standard interactive consumers -*- lexical-binding: t; -*-
(require 'ox-texmacs)

(ert-deftest org-texmacs-standard-frontend-three-command-transaction
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (setq buffer-file-name
           (expand-file-name "source.org" default-directory))
     (insert
      "#+MACRO: m MacroSentinel
{{{m}}}
")
     (let ((org-export-use-babel nil)
           (org-export-show-temporary-export-buffer nil))
       (dolist (command
                '(org-texmacs-export-as-texmacs
                  org-texmacs-export-to-texmacs
                  org-texmacs-export-to-pdf))
         (let ((processing 0)
               (filtered 0)
               buffers)
           (let ((org-export-before-processing-functions
                  (list
                   (lambda (_)
                     (cl-incf processing)
                     (push (current-buffer) buffers))))
                 (org-export-filter-parse-tree-functions
                  (list
                   (lambda (tree _backend _info)
                     (cl-incf filtered)
                     (org-element-map
                      tree 'paragraph
                      (lambda (node)
                        (org-element-set-contents
                         node "MacroSentinel FilterSentinel")))
                     tree))))
             (cl-letf (((symbol-function 'org-texmacs--prepare-buffer)
                        (lambda (&rest _)
                          (ert-fail "Legacy preparation")))
                       ((symbol-function
                         'org-texmacs--preprocess-convert)
                        (lambda (&rest _)
                          (ert-fail "Legacy preprocessing")))
                       ((symbol-function
                         'org-texmacs--bibliography-convert)
                        (lambda (&rest _)
                          (ert-fail "Legacy bibliography"))))
               (let ((result (funcall command)))
                 (cond
                  ((bufferp result)
                   (should
                    (string-search
                     "FilterSentinel"
                     (with-current-buffer result
                       (buffer-string))))
                   (kill-buffer result))
                  ((eq command 'org-texmacs-export-to-pdf)
                   (should
                    (string-search
                     "FilterSentinel"
                     (org-texmacs-test--pdf-text result))))
                  (t
                   (with-temp-buffer
                     (insert-file-contents-literally result)
                     (should
                      (string-search
                       "FilterSentinel" (buffer-string)))))))))
           (should (= processing 1))
           (should (= filtered 1))
           (should
            (cl-every
             (lambda (buffer)
               (not (buffer-live-p buffer)))
             buffers))))))))

(ert-deftest
    org-texmacs-standard-frontend-native-selection-equivalence
    ()
  (org-texmacs-test--with-worker
   (dolist (scope
            '(full subtree region region-subtree narrowing visible))
     (with-temp-buffer
       (org-mode)
       (insert
        "#+OPTIONS: toc:nil author:nil date:nil
* First
First text.
* Second
Second text.
")
       (goto-char (point-min))
       (search-forward "First text.")
       (beginning-of-line)
       (let ((start (point))
             (transient-mark-mode t)
             (org-export-use-babel nil)
             (org-export-show-temporary-export-buffer nil))
         (pcase scope
           ((or 'region 'region-subtree)
            (set-mark start)
            (end-of-line)
            (setq mark-active t))
           ('narrowing (narrow-to-region start (line-end-position)))
           ('visible
            (save-excursion
              (org-back-to-heading t)
              (org-fold-hide-subtree))))
         (let* ((subtree (memq scope '(subtree region-subtree)))
                (expected
                 (encode-coding-string
                  (org-export-as
                   'texmacs subtree (eq scope 'visible))
                  'iso-latin-1-unix))
                (result
                 (org-texmacs-export-as-texmacs
                  nil subtree
                  (eq scope 'visible))))
           (unwind-protect
               (should
                (equal
                 expected
                 (with-current-buffer result
                   (buffer-string))))
             (kill-buffer result))))))))

(ert-deftest org-texmacs-standard-frontend-options-owned-before-prompt
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "Body.
")
     (let* ((org-export-use-babel nil)
            (title (copy-sequence "PromptSentinel"))
            (options (list :title title :with-toc nil)))
       (cl-letf (((symbol-function 'read-file-name)
                  (lambda (&rest _)
                    (aset title 0 ?X)
                    (expand-file-name "prompt.tm"
                                      default-directory))))
         (let ((file
                (org-texmacs-export-to-texmacs
                 nil nil nil nil options)))
           (with-temp-buffer
             (insert-file-contents-literally file)
             (should
              (string-search "PromptSentinel" (buffer-string))))))))))

(ert-deftest
    org-texmacs-standard-frontend-text-filters-and-byte-boundary
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "Body.
")
     (let ((org-export-use-babel nil)
           (org-export-show-temporary-export-buffer nil)
           (calls 0))
       (let ((org-export-filter-final-output-functions
              (list
               (lambda (text _backend _info)
                 (cl-incf calls)
                 (concat text " FilterSentinel")))))
         (let ((result (org-texmacs-export-as-texmacs)))
           (unwind-protect
               (should
                (string-suffix-p
                 " FilterSentinel"
                 (with-current-buffer result
                   (buffer-string))))
             (kill-buffer result)))
         (should (= calls 1)))
       (let ((org-export-filter-final-output-functions
              (list
               (lambda (text _backend _info)
                 (cl-incf calls)
                 (concat text "中")))))
         (should-error
          (org-texmacs-export-as-texmacs)
          :type 'org-texmacs-document-error)
         (should (= calls 2)))))))

(ert-deftest
    org-texmacs-standard-frontend-obsolete-flag-before-preparation
    ()
  (with-temp-buffer
    (org-mode)
    (let ((org-texmacs-export-discover-bibliography t)
          (org-export-before-processing-functions
           (list
            (lambda (_)
              (ert-fail "Obsolete option ran preparation")))))
      (should-error
       (org-texmacs-export-as-texmacs)
       :type 'user-error))))

(ert-deftest
    org-texmacs-standard-frontend-file-info-and-target-isolation
    ()
  (org-texmacs-test--with-worker
   (with-temp-buffer
     (org-mode)
     (insert
      "Body.
")
     (setq buffer-file-name
           (expand-file-name "source.org" default-directory))
     (let ((org-export-use-babel nil)
           (seen 0)
           (target (expand-file-name "source.tm" default-directory)))
       (let ((org-export-filter-final-output-functions
              (list
               (lambda (text _backend info)
                 (cl-incf seen)
                 (should (equal target (plist-get info :output-file)))
                 (aset (plist-get info :output-file) 0 ?X)
                 text))))
         (should
          (equal
           target
           (org-texmacs-export-to-texmacs
            nil nil nil nil '(:output-file "other.tm"))))
         (should (file-exists-p target))
         (should (= seen 1))
         (should-not (file-exists-p "other.tm")))))))
