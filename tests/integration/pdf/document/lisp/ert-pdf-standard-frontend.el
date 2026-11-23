;;; ert-pdf-standard-frontend.el --- Org TeXmacs ERT cases -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'ox)

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

;;; ert-pdf-standard-frontend.el ends here
