;;; support.el --- Suite-local fixtures -*- lexical-binding: t; -*-

(defun org-texmacs-test--example-document ()
  "Exercise the fixed document fixture."
  (with-temp-buffer
    (org-mode)
    (setq-local org-export-with-author nil)
    (insert
     "#+OPTIONS: toc:nil\n"
     "* 中\n"
     "Text *bold* <alpha> $(math \"α <alpha>\")$ end.\n\n"
     "#+begin_texmacs\n"
     "(with \"mode\" \"math\" (frac \"中\" \"2\"))\n"
     "#+end_texmacs\n")
    (org-texmacs-document-from-buffer (current-buffer))))

(defun org-texmacs-test--example-session ()
  "Exercise the fixed session fixture."
  (let ((document
         (with-temp-buffer
           (org-mode)
           (setq-local org-export-with-author nil)
           (insert "Text $(math \"α\")$\n")
           (org-texmacs-document-from-buffer (current-buffer)))))
    (let ((session (org-texmacs-session-open)))
      (unwind-protect
          (progn
            (org-texmacs-session-set-document session document)
            t)
        (org-texmacs-session-close session)))))

(defconst org-texmacs-test--cite-bib
  (concat
   "@book{one,author={Alpha, Adelaide},title={Properties of $\\alpha_i$},year={2026},publisher={Press}}\n"
   "@book{two,author={Zulu, Zachary},title={Ratio $\\frac{a}{b}$},year={2025},publisher={Press}}\n"))

(defun org-texmacs-test--cite-source (file style &optional keys)
  "Prepare FILE using explicit native STYLE and citation KEYS."
  (with-temp-buffer
    (org-mode)
    (insert
     "#+OPTIONS: toc:nil title:nil author:nil date:nil\n"
     "#+bibliography: "
     file
     "\n#+cite_export: texmacs-native "
     style
     "\n"
     "First [cite:"
     (or keys "@two; @one")
     "]. Again [cite:@one].\n"
     "#+print_bibliography:\n")
    (let ((org-export-use-babel nil))
      (org-texmacs-prepare-buffer (current-buffer)))))

(defun org-texmacs-test--reference-map (body)
  "Map BODY's random labels to structural fixture names, preserving static IDs."
  (let* ((labels (org-texmacs--document-output-labels body))
         (reserved
          (cl-remove-if-not
           (lambda (id)
             (string-match-p "\\`org-texmacs-ref-[0-9]+\\'" id))
           labels))
         (next 0)
         result)
    (dolist (id labels)
      (when (string-match-p "\\`org-texmacs-.*org[0-9a-f]+\\'" id)
        (let (canonical)
          (while (progn
                   (setq canonical
                         (format "org-texmacs-ref-%d" (cl-incf next)))
                   (member canonical reserved)))
          (push (cons id canonical) result))))
    (nreverse result)))

(defun org-texmacs-test--rewrite-references (tree mapping)
  "Copy TREE, replacing complete label/reference strings using MAPPING."
  (cond
   ((stringp tree)
    (or (cdr (assoc tree mapping))
        (and (string-prefix-p "#" tree)
             (when-let* ((id
                          (cdr (assoc (substring tree 1) mapping))))
               (concat "#" id)))
        tree))
   ((consp tree)
    (mapcar
     (lambda (child)
       (org-texmacs-test--rewrite-references child mapping))
     tree))
   (t
    tree)))

(defun org-texmacs-test--stable-reference-body (document)
  "Return DOCUMENT body with random references renamed for structural comparison."
  (let ((body (org-texmacs-document-body document)))
    (org-texmacs-test--rewrite-references
     body (org-texmacs-test--reference-map body))))

(defun org-texmacs-test--expand-references (tree document)
  "Expand TREE's fixture labels to DOCUMENT's actual IDs before native encoding."
  (org-texmacs-test--rewrite-references
   tree
   (mapcar
    (lambda (entry) (cons (cdr entry) (car entry)))
    (org-texmacs-test--reference-map
     (org-texmacs-document-body document)))))

;;; support.el ends here
