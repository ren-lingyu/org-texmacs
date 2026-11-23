;;; probe.el --- Export validation baseline -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'org)
(require 'ox-texmacs)
(require 'org-texmacs-input)

(defun probe-report (key value)
  (let ((print-length nil)
        (print-level nil)
        (print-escape-newlines t))
    (princ (format "%S %S\n" key value))))

(defun probe-block (ast type)
  (org-element-map ast 'special-block
    (lambda (block)
      (when (equal (org-element-property :type block) type) block))
    nil t))

(defun probe-caption (ast)
  (let* ((node (or (probe-block ast "theorem")
                   (error "Missing theorem in probe tree")))
         (caption (org-element-property :caption node)))
    (mapcar
     (lambda (line)
       (list (car line) (cdr line)))
     caption)))

(defun probe-status (value)
  (cond
   ((org-texmacs-input-p value)
    (list :input
          :failure (org-texmacs-resolution-failure
                    (org-texmacs-input-resolution value))
          :bibliography (length (org-texmacs-input-bibliography value))))
   ((org-texmacs-document-p value)
    (let ((body (prin1-to-string (org-texmacs-document-body value))))
      (list :document
            :figure (and (string-search "big-figure" body) t)
            :bibliography (and (string-search "bib-list" body) t)
            :citation (and (string-search "cite" body) t)
            :dueto (and (string-search "dueto" body) t))))
   (t (error "Unexpected probe result: %S" value))))

(defun probe-error (function)
  (condition-case err
      (probe-status (funcall function))
    (org-texmacs-document-error
     (list :error (car err) (error-message-string err)))
    (org-texmacs-worker-error
     (list :error (car err) (error-message-string err)))))

(defun probe-caption-case (name declaration)
  (with-temp-buffer
    (org-mode)
    (insert declaration "\n#+begin_theorem\nBody.\n#+end_theorem\n")
    (let ((org-export-use-babel nil)
          (filter-caption :unseen)
          (org-export-filter-parse-tree-functions nil))
      (setq org-export-filter-parse-tree-functions
            (list (lambda (ast _backend _info)
                    (setq filter-caption (probe-caption ast))
                    ast)))
      (let* ((parsed (probe-caption (org-element-parse-buffer)))
             (input (org-texmacs-prepare-buffer (current-buffer)))
             (owned (probe-caption (org-texmacs-input-ast input)))
             (result (probe-error
                      (lambda () (org-texmacs-document input)))))
        (probe-report name
                      (list :parsed parsed :filtered filter-caption
                            :owned owned :result result))
        result))))

(defun probe-break-target (ast)
  (org-element-map ast 'target
    (lambda (node) (org-element-put-property node :value "")))
  ast)

(defun probe-cite-case (name entry bib-file figure &optional transform broken)
  (with-temp-buffer
    (org-mode)
    (insert "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
            "#+cite_export: texmacs-native plain\n#+bibliography: "
            bib-file "\n\nText [cite:@one].\n\n"
            (if broken "Target <<probe>>.\n\n" "")
            figure "\n#+print_bibliography:\n")
    (let* ((org-export-use-babel nil)
           (org-export-filter-parse-tree-functions
            (when transform
              (list (lambda (ast _backend _info) (funcall transform ast)))))
           (snapshot (symbol-function 'org-texmacs--prepared-cite-snapshot))
           (fulfill (symbol-function 'org-texmacs--prepared-cite-fulfill))
           (worker (symbol-function 'org-texmacs--worker-request))
           events
           (text (buffer-string))
           (tick (buffer-chars-modified-tick))
           (orig-point (point))
           result)
      (cl-letf (((symbol-function 'org-texmacs--prepared-cite-snapshot)
                 (lambda (&rest args)
                   (push 'snapshot events)
                   (apply snapshot args)))
                ((symbol-function 'org-texmacs--prepared-cite-fulfill)
                 (lambda (&rest args)
                   (push 'fulfill events)
                   (apply fulfill args)))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (source &optional operation)
                   (push (list 'worker operation) events)
                   (funcall worker source operation))))
        (setq result (probe-error (lambda () (funcall entry (current-buffer))))))
      (unless (and (equal text (buffer-string))
                   (= tick (buffer-chars-modified-tick))
                   (= orig-point (point)))
        (error "Source text, tick or point changed"))
      (probe-report (list name entry)
                    (list :events (nreverse events) :result result))
      result)))

(defun probe-repair-figure (ast)
  (let ((paragraph (org-element-map (probe-block ast "figure") 'paragraph
                     (lambda (node)
                       (when (equal (org-element-contents node) '("Stray.\n"))
                         node))
                     nil t)))
    (unless paragraph (error "Missing repairable paragraph"))
    (org-element-extract-element paragraph)
    ast))

(probe-report 'versions (list emacs-version (org-version)
                              (file-name-nondirectory
                               (directory-file-name
                                (file-name-directory (locate-library "org"))))
                              (file-name-nondirectory
                               (directory-file-name
                                (file-name-directory
                                 (locate-library "org-texmacs"))))
                              org-texmacs-program))

(dolist (case '((caption-long . "#+CAPTION: Long")
                (caption-empty-short . "#+CAPTION[]: Long")
                (caption-short . "#+CAPTION[Short]: Long")
                (caption-empty-long . "#+CAPTION: ")))
  (probe-caption-case (car case) (cdr case)))

(let* ((bib (expand-file-name "references.bib" (getenv "HOME")))
       (figure "#+begin_figure\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n#+end_figure\n")
       (repairable "#+begin_figure\nStray.\n\n#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n#+end_figure\n"))
  (with-temp-file bib
    (insert "@book{one,title={One},author={Alpha, Ada},year={2026}}\n"))
  (dolist (entry '(org-texmacs-prepare-buffer org-texmacs-document-from-buffer))
    (probe-cite-case 'legal entry bib figure)
    (probe-cite-case 'illegal entry bib "#+begin_figure\nOnly prose.\n#+end_figure\n")
    (probe-cite-case 'filter-repair entry bib repairable #'probe-repair-figure)
    (probe-cite-case 'resolution-failure entry bib figure #'probe-break-target t))
  (with-temp-buffer
    (org-mode)
    (insert "Target <<probe>>.\n")
    (let ((input (org-texmacs-input-create
                  (probe-break-target (org-element-parse-buffer)) nil)))
      (probe-report 'independent-input
                    (list (probe-status input)
                          (probe-error (lambda () (org-texmacs-document input))))))))

(org-texmacs--worker-stop)
