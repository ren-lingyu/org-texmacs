;;; probe.el --- Compare effective footnote figure traversal -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'org)
(require 'ox-texmacs)
(require 'org-texmacs-input)

(defun probe-report (key value)
  (let ((print-length nil)
        (print-level nil)
        (print-escape-newlines t))
    (princ (format "%S %S\n" key value))))

(defun probe-figure (body)
  (concat "#+begin_figure\n" body "#+end_figure\n"))

(defun probe-source (scenario)
  (let ((legal (probe-figure
                "#+begin_texmacs\n(math \"ACTIVE-LEGAL\")\n#+end_texmacs\n"))
        (invalid (probe-figure "ACTIVE-INVALID\n"))
        (unused (probe-figure "UNUSED-INVALID\n"))
        (excluded (probe-figure "EXCLUDED-INVALID\n")))
    (concat "#+OPTIONS: toc:nil title:nil author:nil date:nil tags:nil\n"
            "* Kept\n"
            (if (eq scenario 'unused-invalid) "Visible alone.\n"
              "Visible[fn:n] and again[fn:n].\n")
            "* Hidden :noexport:\n"
            (when (eq scenario 'excluded-invalid) excluded)
            "[fn:n]\n"
            (pcase scenario
              ('active-invalid invalid)
              ('unused-invalid unused)
              (_ legal)))))

(defun probe-node-path (node)
  (let (path)
    (while node
      (push (pcase (org-element-type node)
              ('headline (list 'headline
                               (substring-no-properties
                                (or (org-element-property :raw-value node) ""))))
              ('footnote-definition
               (list 'footnote-definition (org-element-property :label node)))
              (type type))
            path)
      (setq node (org-element-parent node)))
    path))

(defun probe-figures (tree)
  (org-element-map tree 'special-block
    (lambda (node)
      (when (equal (org-element-property :type node) "figure")
        (list :path (probe-node-path node)
              :body-types (mapcar #'org-element-type
                                  (org-element-contents node)))))))

(defun probe-node-count (tree tag)
  (if (consp tree)
      (+ (if (eq (car tree) tag) 1 0)
         (cl-reduce #'+ (mapcar (lambda (child) (probe-node-count child tag))
                                (cdr tree))
                    :initial-value 0))
    0))

(defun probe-run (scenario entry)
  (with-temp-buffer
    (org-mode)
    (insert (probe-source scenario))
    (goto-char (point-min))
    (search-forward "* Kept")
    (beginning-of-line)
    (let* ((source (current-buffer))
           (subtree (point))
           (before (list (buffer-string) (buffer-chars-modified-tick) (point)))
           (query (symbol-function 'org-texmacs--query-snapshot))
           (worker (symbol-function 'org-texmacs--worker-request))
           (org-export-use-babel nil)
           (org-export-filter-parse-tree-functions
            (list (lambda (tree _backend _info)
                    (probe-report 'filter (probe-figures tree))
                    tree)))
           result)
      (probe-report 'case (list scenario entry))
      (cl-letf (((symbol-function 'org-texmacs--query-snapshot)
                 (lambda (tree &rest args)
                   (let* ((data (apply query tree args))
                          (definitions (org-element-map
                                           tree 'footnote-definition #'identity)))
                     (probe-report
                      'after-query
                      (list
                       :figures (probe-figures tree)
                       :notes
                       (mapcar (lambda (note)
                                 (let ((definition (nth 1 note)))
                                   (list (probe-node-path definition)
                                         :same-node-in-tree
                                         (and (memq definition definitions) t)
                                         :first (nth 3 note))))
                               (plist-get data :footnotes))))
                     data)))
                ((symbol-function 'org-texmacs--worker-request)
                 (lambda (source &optional operation)
                   (probe-report 'worker operation)
                   (funcall worker source operation))))
        (setq result
              (condition-case err
                  (let ((output (funcall entry source nil subtree)))
                    (if (org-texmacs-input-p output)
                        (list :input (probe-figures (org-texmacs-input-ast output))
                              :islands (length (org-texmacs-input-islands output)))
                      (let* ((body (org-texmacs-document-body output))
                             (repr (prin1-to-string body)))
                        (list :document
                              :figures (probe-node-count body 'big-figure)
                              :footnotes (probe-node-count body 'footnote)
                              :markers
                              (cl-remove-if-not
                               (lambda (marker) (string-search marker repr))
                               '("ACTIVE-LEGAL" "ACTIVE-INVALID"
                                 "UNUSED-INVALID" "EXCLUDED-INVALID"))))))
                (error (list :error (car err) (error-message-string err))))))
      (unless (equal before (list (buffer-string)
                                  (buffer-chars-modified-tick) (point)))
        (error "Source text, tick or point changed"))
      (probe-report 'result result))))

(probe-report 'versions (list emacs-version (org-version)))
(dolist (scenario '(active-legal active-invalid unused-invalid excluded-invalid))
  (dolist (entry '(org-texmacs-prepare-buffer org-texmacs-document-from-buffer))
    (probe-run scenario entry)))
