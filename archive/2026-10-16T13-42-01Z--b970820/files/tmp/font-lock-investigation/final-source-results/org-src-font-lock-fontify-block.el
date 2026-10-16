(defun org-src-font-lock-fontify-block (lang start end)
  "Fontify code block between START and END using LANG's syntax.
This function is called by Emacs's automatic fontification, as long
as `org-src-fontify-natively' is non-nil."
  (let ((modified (buffer-modified-p)) native-tab-width)
    (remove-text-properties start end '(face nil))
    (when-let* ((lang-mode (org-src-get-lang-mode-if-bound lang)))
      (condition-case nil
          (let ((string (buffer-substring-no-properties start end))
	        (org-buffer (current-buffer)))
	    (with-current-buffer
	        (get-buffer-create
	         (format " *org-src-fontification:%s*" lang-mode))
	      (let ((inhibit-modification-hooks nil))
	        (erase-buffer)
	        ;; Add string and a final space to ensure property change.
	        (insert string " "))
	      (unless (eq major-mode lang-mode) (funcall lang-mode))
              (setq native-tab-width tab-width)
              (font-lock-ensure)
	      (let ((pos (point-min)) next
	            ;; Difference between positions here and in org-buffer.
	            (offset (- start (point-min))))
	        (while (setq next (next-property-change pos))
	          ;; Handle additional properties from font-lock, so as to
	          ;; preserve, e.g., composition.
                  ;; FIXME: We copy 'font-lock-face property explicitly because
                  ;; `font-lock-mode' is not enabled in the buffers starting from
                  ;; space and the remapping between 'font-lock-face and 'face
                  ;; text properties may thus not be set.  See commit
                  ;; 453d634bc.
	          (dolist (prop (append '(font-lock-face face syntax-table) font-lock-extra-managed-props))
		    (let ((new-prop (get-text-property pos prop)))
                      (when new-prop
                        (if (not (eq prop 'invisible))
		            (put-text-property
		             (+ offset pos) (+ offset next) prop new-prop
		             org-buffer)
                          ;; Special case.  `invisible' text property may
                          ;; clash with Org folding.  Do not assign
                          ;; `invisible' text property directly.  Use
                          ;; property alias instead.
                          (let ((invisibility-spec
                                 (or
                                  ;; ATOM spec.
                                  (and (memq new-prop buffer-invisibility-spec)
                                       new-prop)
                                  ;; (ATOM . ELLIPSIS) spec.
                                  (assq new-prop buffer-invisibility-spec))))
                            (with-current-buffer org-buffer
                              ;; Add new property alias.
                              (unless (memq 'org-src-invisible
                                            (cdr (assq 'invisible char-property-alias-alist)))
                                (setq-local
                                 char-property-alias-alist
                                 (cons (cons 'invisible
			                     (nconc (cdr (assq 'invisible char-property-alias-alist))
                                                    '(org-src-invisible)))
		                       (remove (assq 'invisible char-property-alias-alist)
			                       char-property-alias-alist))))
                              ;; Carry over the invisibility spec, unless
                              ;; already present.  Note that there might
                              ;; be conflicting invisibility specs from
                              ;; different major modes.  We cannot do much
                              ;; about this then.
                              (when invisibility-spec
                                (add-to-invisibility-spec invisibility-spec))
                              (put-text-property
		               (+ offset pos) (+ offset next)
                               'org-src-invisible new-prop
		               org-buffer)))))))
	          (setq pos next)))
              (let ((new-table (syntax-table)))
                (alter-text-property
                 start end 'syntax-table
                 (lambda (old-table) (or old-table new-table))
                 org-buffer))
              (set-buffer-modified-p nil)))
        (error
         (message "Native code fontification error in %S at pos%d\n Error: %S"
                  (current-buffer) start
                  (when (and (fboundp 'backtrace-get-frames)
                             (fboundp 'backtrace-to-string))
                    (backtrace-to-string (backtrace-get-frames 'backtrace)))))))
    ;; Add Org faces.
    (let ((src-face (nth 1 (assoc-string lang org-src-block-faces t))))
      (when (or (facep src-face) (listp src-face))
        (font-lock-append-text-property start end 'face src-face))
      (font-lock-append-text-property start end 'face 'org-block))
    ;; Display native tab indentation characters as spaces
    (when native-tab-width
      (save-excursion
        (goto-char start)
        (let ((indent-offset
	       (if (org-src-preserve-indentation-p) 0
	         (+ (progn (backward-char)
                           (org-current-text-indentation))
	            org-src-content-indentation))))
          (while (re-search-forward "^[ ]*\t" end t)
            (let* ((b (and (eq indent-offset (move-to-column indent-offset))
                           (point)))
                   (e (progn (skip-chars-forward "\t") (point)))
                   (s (and b (make-string (* (- e b) native-tab-width) ? ))))
              (when (and b (< b e)) (add-text-properties b e `(display ,s)))
              (forward-char))))))
    (add-text-properties
     start end
     '(font-lock-fontified t fontified t font-lock-multiline t))
    (set-buffer-modified-p modified)))
