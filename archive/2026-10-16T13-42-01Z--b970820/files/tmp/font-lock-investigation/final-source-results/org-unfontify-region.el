(defun org-unfontify-region (beg end &optional _maybe_loudly)
  "Remove fontification and activation overlays from links."
  (font-lock-default-unfontify-region beg end)
  (with-silent-modifications
    (decompose-region beg end)
    (remove-text-properties beg end
			    '(mouse-face t keymap t org-linked-text t
					 invisible t intangible t
					 org-emphasis t
                                         syntax-table t))
    (org-fold-core-update-optimization beg end)
    (org-remove-font-lock-display-properties beg end)))
