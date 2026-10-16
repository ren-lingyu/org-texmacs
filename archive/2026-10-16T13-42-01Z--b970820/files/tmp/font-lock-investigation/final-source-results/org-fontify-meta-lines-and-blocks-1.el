(defun org-fontify-meta-lines-and-blocks-1 (limit)
  "Fontify #+ lines and blocks."
  (let ((case-fold-search t))
    (when (re-search-forward
	   (rx bol (group (zero-or-more (any " \t")) "#"
			  (group (group (or (seq "+" (one-or-more (any "a-zA-Z")) (optional ":"))
					    (any " \t")
					    eol))
				 (optional (group "_" (group (one-or-more (any "a-zA-Z"))))))
			  (zero-or-more (any " \t"))
			  (group (group (zero-or-more (not (any " \t\n"))))
				 (zero-or-more (any " \t"))
				 (group (zero-or-more nonl)))))
	   limit t)
      (let ((beg (match-beginning 0))
	    (end-of-beginline (match-end 0))
	    (lang (match-string 7)) ; The language, if it is a source block.
	    (bol-after-beginline (line-beginning-position 2))
	    (dc1 (downcase (match-string 2)))
	    (dc3 (downcase (match-string 3)))
	    (whole-blockline org-fontify-whole-block-delimiter-line)
	    beg-of-endline end-of-endline nl-before-endline quoting block-type)
	(cond
	 ((and (match-end 4) (equal dc3 "+begin"))
	  ;; Truly a block
	  (setq block-type (downcase (match-string 5))
		;; Src, example, export, maybe more.
		quoting (member block-type org-protecting-blocks))
	  (when (re-search-forward
		 (rx-to-string `(group bol (or (seq (one-or-more "*") space)
					       (seq (zero-or-more (any " \t"))
						    "#+end"
						    ,(match-string 4)
						    word-end
						    (zero-or-more nonl)))))
		 ;; We look further than LIMIT on purpose.
		 nil t)
	    ;; We do have a matching #+end line.
	    (setq beg-of-endline (match-beginning 0)
		  end-of-endline (match-end 0)
		  nl-before-endline (1- (match-beginning 0)))
	    (when quoting
	      (org-remove-flyspell-overlays-in bol-after-beginline nl-before-endline)
	      (remove-text-properties beg end-of-endline
				      '(display t invisible t intangible t)))
	    (add-text-properties
	     beg end-of-endline '(font-lock-fontified t font-lock-multiline t))
	    (org-remove-flyspell-overlays-in beg bol-after-beginline)
	    (org-remove-flyspell-overlays-in nl-before-endline end-of-endline)
            (cond
	     ((and org-src-fontify-natively
                   ;; Skip fontification of empty source-blocks
                   (< bol-after-beginline beg-of-endline)
                   ;; Technically, according to the
                   ;; `org-src-fontify-natively' docstring, we should
                   ;; only fontify src blocks.  However, it is common
                   ;; to use undocumented fontification of export and
                   ;; example blocks. (The latter which do not support a
                   ;; language specifier.) Keep this undocumented feature
                   ;; for user convenience.
                   (member block-type '("src" "export" "example")))
	      (save-match-data
                (org-src-font-lock-fontify-block (or lang "") bol-after-beginline beg-of-endline))
	      (add-text-properties bol-after-beginline beg-of-endline '(src-block t)))
	     (quoting
	      (add-text-properties
	       bol-after-beginline beg-of-endline
	       (list 'face
		     (list :inherit
			   (let ((face-name
				  (intern (format "org-block-%s" lang))))
			     (append (and (facep face-name) (list face-name))
				     '(org-block)))))))
	     ((not org-fontify-quote-and-verse-blocks))
	     ((string= block-type "quote")
	      (add-face-text-property
	       bol-after-beginline beg-of-endline 'org-quote t))
	     ((string= block-type "verse")
	      (add-face-text-property
	       bol-after-beginline beg-of-endline 'org-verse t)))
	    ;; Fontify the #+begin and #+end lines of the blocks
	    (add-text-properties
	     beg (if whole-blockline bol-after-beginline end-of-beginline)
	     '(face org-block-begin-line))
	    (unless (eq (char-after beg-of-endline) ?*)
	      (add-text-properties
	       beg-of-endline
	       (if whole-blockline
		   (let ((beg-of-next-line (1+ end-of-endline)))
		     (min (point-max) beg-of-next-line))
		 (min (point-max) end-of-endline))
	       '(face org-block-end-line)))
	    t))
	 ((member dc1 '("+title:" "+subtitle:" "+author:" "+email:" "+date:"))
	  (org-remove-flyspell-overlays-in
	   (match-beginning 0)
	   (if (equal "+title:" dc1) (match-end 2) (match-end 0)))
	  (add-text-properties
	   beg (match-end 3)
	   (if (member (intern (substring dc1 1 -1)) org-hidden-keywords)
	       '(font-lock-fontified t invisible t)
	     '(font-lock-fontified t face org-document-info-keyword)))
	  (add-text-properties
	   (match-beginning 6) (min (point-max) (1+ (match-end 6)))
	   (if (string-equal dc1 "+title:")
	       '(font-lock-fontified t face org-document-title)
	     '(font-lock-fontified t face org-document-info))))
	 ((string-prefix-p "+caption" dc1)
	  (org-remove-flyspell-overlays-in (match-end 2) (match-end 0))
	  (remove-text-properties (match-beginning 0) (match-end 0)
				  '(display t invisible t intangible t))
	  ;; Handle short captions
	  (save-excursion
	    (forward-line 0)
	    (looking-at (rx (group (zero-or-more (any " \t"))
				   "#+caption"
				   (optional "[" (zero-or-more nonl) "]")
				   ":")
			    (zero-or-more (any " \t")))))
	  (add-text-properties (line-beginning-position) (match-end 1)
			       '(font-lock-fontified t face org-meta-line))
	  (add-text-properties (match-end 0) (line-end-position)
			       '(font-lock-fontified t face org-block))
	  t)
	 ((member dc3 '(" " ""))
	  ;; Just a comment, the plus was not there
	  (org-remove-flyspell-overlays-in beg (match-end 0))
	  (add-text-properties
	   beg (match-end 0)
	   '(font-lock-fontified t face font-lock-comment-face)))
	 (t ;; Just any other in-buffer setting, but not indented
	  (org-remove-flyspell-overlays-in (match-beginning 0) (match-end 0))
	  (remove-text-properties (match-beginning 0) (match-end 0)
				  '(display t invisible t intangible t))
	  (add-text-properties beg (match-end 0)
			       '(font-lock-fontified t face org-meta-line))
	  t))))))
