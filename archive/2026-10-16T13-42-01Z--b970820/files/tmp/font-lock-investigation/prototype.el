;;; prototype.el --- Investigation-only presentation prototype -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'org-src)
(require 'org-texmacs-fragment)

(defvar-local fl-cache-key nil)
(defvar-local fl-cache-spans nil)
(defvar-local fl-scan-count 0)
(defvar-local fl-soft-errors nil)
(defvar-local fl-enabled nil)
(defconst fl-keywords '((fl-match (0 nil))))

(defun fl-spans ()
  "Use existing canonical recognition, once per text/configuration snapshot."
  (let ((key (list (buffer-chars-modified-tick)
                   (condition-case nil (org-texmacs--fragment-tags) (error :invalid))
                   (point-min) (point-max))))
    (unless (equal key fl-cache-key)
      (setq fl-scan-count (1+ fl-scan-count) fl-cache-spans nil)
      (condition-case err
          (setq fl-cache-spans
                (org-texmacs-fragment-map
                 (point-min) (point-max)
                 (lambda (span)
                   (list (org-texmacs-fragment-span-begin span)
                         (org-texmacs-fragment-span-end span) 'fragment))))
        (error (push err fl-soft-errors)))
      (let ((offset (1- (point-min)))
            (source (buffer-substring-no-properties (point-min) (point-max))))
        (with-temp-buffer
          (let ((org-element-use-cache nil) (org-inhibit-startup t))
            (delay-mode-hooks (org-mode))
            (insert source)
            (let ((blocks (org-element-map (org-element-parse-buffer 'element)
                              'special-block
                            (lambda (node)
                              (when (org-texmacs--block-p node)
                                (let ((b (org-element-property :contents-begin node))
                                      (e (org-element-property :contents-end node)))
                                  (and b e (< b e)
                                       (list (+ offset b) (+ offset e) 'block))))))))
              ;; Keep the source buffer's cache assignment outside this view.
              (setq source blocks))))
        (setq fl-cache-spans (nconc fl-cache-spans source)))
      (setq fl-cache-spans (sort fl-cache-spans (lambda (a b) (< (car a) (car b))))
            fl-cache-key key))
    fl-cache-spans))

(defun fl-face-without-block (face)
  (cond ((eq face 'org-block) nil)
        ((and (listp face) (not (keywordp (car face)))) (remq 'org-block face))
        (t face)))

(defun fl-paint (begin end)
  "Reuse Org's helper in a private view; transfer only face runs."
  (let ((text (buffer-substring-no-properties begin end)) runs)
    (save-match-data
      (with-temp-buffer
        (delay-mode-hooks (org-mode))
        ;; The Org helper expects a preceding character for indentation logic.
        (insert "\n" text)
        (org-src-font-lock-fontify-block "scheme" 2 (point-max))
        (let ((p 2) q)
          (while (< p (point-max))
            (setq q (next-single-property-change p 'face nil (point-max)))
            (let ((face (fl-face-without-block (get-text-property p 'face))))
              (when face (push (list (- p 2) (- q 2) face) runs)))
            (setq p q)))))
    (with-silent-modifications
      (remove-text-properties begin end '(face nil))
      (dolist (run runs)
        (put-text-property (+ begin (car run)) (+ begin (cadr run)) 'face (nth 2 run)))
      (add-text-properties begin end '(fl-owned t font-lock-multiline t)))))

(defun fl-match (limit)
  (when (and fl-enabled org-src-fontify-natively)
    (let ((span (cl-find-if (lambda (s) (and (> (cadr s) (point)) (< (car s) limit)))
                            (fl-spans))))
      (when span
        (fl-paint (car span) (cadr span))
        (goto-char (cadr span))
        (set-match-data (list (car span) (cadr span)))
        t))))

(defun fl-extend ()
  (when fl-enabled
    (let ((old-beg font-lock-beg) (old-end font-lock-end))
      (dolist (span (fl-spans))
        (when (and (< (car span) font-lock-end) (> (cadr span) font-lock-beg))
          (setq font-lock-beg (min font-lock-beg (car span))
                font-lock-end (max font-lock-end (cadr span)))))
      (or (/= old-beg font-lock-beg) (/= old-end font-lock-end)))))

(defun fl-after-change (&rest _)
  (setq fl-cache-key nil))

(defun fl-refresh ()
  (setq fl-cache-key nil)
  (font-lock-flush)
  (font-lock-ensure))

(defun fl-enable ()
  (setq fl-enabled t fl-cache-key nil)
  (setq-local font-lock-extra-managed-props
              (cons 'fl-owned (remove 'fl-owned font-lock-extra-managed-props)))
  (font-lock-add-keywords nil fl-keywords 'append)
  (add-hook 'font-lock-extend-region-functions #'fl-extend t t)
  (add-hook 'after-change-functions #'fl-after-change nil t)
  (add-hook 'change-major-mode-hook #'fl-disable nil t)
  (fl-refresh))

(defun fl-disable ()
  (setq fl-enabled nil fl-cache-key nil fl-cache-spans nil)
  (font-lock-remove-keywords nil fl-keywords)
  (remove-hook 'font-lock-extend-region-functions #'fl-extend t)
  (remove-hook 'after-change-functions #'fl-after-change t)
  (remove-hook 'change-major-mode-hook #'fl-disable t)
  (save-restriction
    (widen)
    (with-silent-modifications
      (remove-text-properties (point-min) (point-max) '(fl-owned nil))
      (font-lock-unfontify-region (point-min) (point-max)))
    (setq-local font-lock-extra-managed-props (remove 'fl-owned font-lock-extra-managed-props))
    (font-lock-flush)
    (font-lock-ensure)))

(provide 'fl-investigation-prototype)
