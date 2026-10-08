;;; v020-boundary-probe.el --- Isolated follow-up observations -*- lexical-binding: t; -*-

(load (expand-file-name "v020-inline-probe.el"
                        (file-name-directory (or load-file-name buffer-file-name)))
      nil t)

(defconst org-texmacs-v020-link-state-variables
  '(org-link-parameters org-link-types-re org-link-angle-re org-link-plain-re
    org-link-bracket-re org-link-any-re org-element--object-regexp
    org-element-paragraph-separate))

(defun org-texmacs-v020-link-state ()
  (mapcar (lambda (symbol) (copy-tree (symbol-value symbol)))
          org-texmacs-v020-link-state-variables))

(defun org-texmacs-v020-link-observe ()
  (let ((ast (org-element-parse-buffer)) spans)
    (org-texmacs-fragment-map
     (point-min) (point-max)
     (lambda (span)
       (push (org-texmacs-fragment-span-source span) spans)))
    (list (org-element-map ast 'link
            (lambda (node)
              (list (org-element-property :type node)
                    (org-element-property :path node)
                    (org-element-property :format node))))
          (nreverse spans))))

(defun org-texmacs-v020-probe-links (&optional private-regexps)
  "Observe scoped Org registration and its cache reset, without a worker."
  (princ (format "Emacs=%s Org=%s\n" emacs-version (org-version)))
  (with-temp-buffer
    (delay-mode-hooks (org-mode))
    (setq-local org-element-use-cache nil)
    (insert "[[ftps://example.org/a]] <ftps://example.org/a> ftps://example.org/a\n\n"
            "[[ftps://example.org/a][(math \"hidden\")]] (math \"visible\")\n")
    (let ((before (org-texmacs-v020-link-state))
          (source (buffer-string))
          (parsed (org-texmacs-v020-link-observe))
          (reset-function (symbol-function 'org-element-cache-reset))
          reset-calls)
      (princ (format "LINK before=%S\n" parsed))
      ;; All syntax bindings are conversion-local; no user buffer is visited.
      (let ((org-link-parameters (copy-tree org-link-parameters))
            (org-link-types-re org-link-types-re)
            (org-link-angle-re org-link-angle-re)
            (org-link-plain-re org-link-plain-re)
            (org-link-bracket-re org-link-bracket-re)
            (org-link-any-re org-link-any-re)
            (org-element--object-regexp org-element--object-regexp)
            (org-element-paragraph-separate org-element-paragraph-separate))
        (cl-letf (((symbol-function 'org-element-cache-reset)
                   (lambda (&rest args)
                     (push args reset-calls)
                     (apply reset-function args))))
          (if private-regexps
              (progn
                (unless (assoc "ftps" org-link-parameters)
                  (push '("ftps") org-link-parameters))
                (org-link-make-regexps)
                (org-element--set-regexps))
            (org-link-set-parameters "ftps")))
        (when (and private-regexps reset-calls)
          (error "Private regexp construction reset Org caches"))
        (let ((registered (org-texmacs-v020-link-observe)))
          (princ (format "LINK registered=%S resets=%S\n" registered reset-calls))
          (unless (equal (mapcar #'car (car registered))
                         '("ftps" "ftps" "ftps" "ftps"))
            (error "Scoped registration did not recognize all forms"))
          (with-temp-buffer
            (delay-mode-hooks (org-mode))
            (setq-local org-element-use-cache nil)
            (insert source)
            (let ((private (org-texmacs-v020-link-observe)))
              (princ (format "LINK private=%S equal=%S\n"
                             private (equal registered private)))
              (unless (equal registered private)
                (error "Private parse differs"))))))
      (princ (format "LINK restored=%S source-unchanged=%S parse-restored=%S\n"
                     (equal before (org-texmacs-v020-link-state))
                     (equal source (buffer-string))
                     (equal parsed (org-texmacs-v020-link-observe))))
      (unless (and (equal before (org-texmacs-v020-link-state))
                   (equal source (buffer-string))
                   (equal parsed (org-texmacs-v020-link-observe)))
        (error "Probe leaked syntax state or changed source"))))
  (princ "LINK observations complete\n"))

(defun org-texmacs-v020-probe-tabs ()
  "Compare native tab conversions, reusing isolated process setup."
  (org-texmacs-v020-probe-native "tmp/v020-tab-probe.scm"))

(defun org-texmacs-v020-probe-private-links ()
  "Observe private syntax construction without the registration side effect."
  (org-texmacs-v020-probe-links t))

(defun org-texmacs-v020-probe-leaf-apis ()
  "Observe leaf APIs separately from snippet/document conversion."
  (org-texmacs-v020-probe-native "tmp/v020-leaf-api-probe.scm"))

