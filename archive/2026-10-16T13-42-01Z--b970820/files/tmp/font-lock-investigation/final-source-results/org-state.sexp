(font-lock-defaults (org-font-lock-keywords t nil nil backward-paragraph))
(font-lock-keywords (t ((org-font-lock-hook) ("^\\(\\**\\)\\(\\* \\)\\(.*\\)" (1 (org-get-level-face 1)) (2 (org-get-level-face 2)) (3 (org-get-level-face 3))) ("^[ 	]*\\(\\(|\\|\\+-[-+]\\).*\\S-\\)
?" (0 'org-table-row t) (1 'org-table t)) ("^[ 	]*|\\(?:.*?|\\)? *\\(:?=[^|
]*\\)" (1 'org-formula t)) ("^[ 	]*| *\\([#*]\\) *|" (1 'org-formula t)) ("^[ 	]*|\\( *\\([$!_^/]\\) *|.*\\)|" (1 'org-formula t)) ("| *\\(<[lrc]?[0-9]*>\\)" (1 'org-formula t)) ("^\\(?4:[ 	]*\\)\\(?1::\\(?2:\\S-+\\):\\)\\(?:\\(?3:$\\)\\|[ 	]+\\(?3:.*?\\)\\)\\(?5:[ 	]*\\)$" (1 'org-special-keyword t) (3 'org-property-value t)) (org-fontify-drawers) ("^&?%%(.*\\|<%%([^>
]*?>" (0 'org-sexp-date t)) (org-activate-links) (org-activate-tags (1 'org-tag prepend)) (org-activate-target-links (1 'org-link prepend)) (org-activate-dates (0 'org-date prepend)) (org-activate-footnote-links) ("<<<\\([^<>
 	]\\|[^<>
 	][^<>
]*[^<>
 	]\\)>>>" (0 'org-target prepend)) ("<<\\([^<>
 	]\\|[^<>
 	][^<>
]*[^<>
 	]\\)>>" (0 'org-target prepend)) (org-fontify-macros) ("^\\(\\*+\\)\\(?: +\\(DONE\\|TODO\\)\\)\\(?: +\\(.*?\\)\\)?[ 	]*$" (2 (org-get-todo-face 2) prepend)) ("^\\(\\*+\\)\\(?: +\\(?:DONE\\)\\)\\(?: +\\(.*?\\)\\)?[ 	]*$" (2 'org-headline-done prepend)) (org-font-lock-add-priority-faces) (org-font-lock-add-tag-faces) ("\\<DEADLINE:" (0 'org-special-keyword t)) ("\\<SCHEDULED:" (0 'org-special-keyword t)) ("\\<CLOSED:" (0 'org-special-keyword t)) ("\\<CLOCK:" (0 'org-special-keyword t)) (org-do-emphasis-faces) ("^[ 	]*\\(\\(?:[-+*]\\|\\(?:[0-9]+\\|[A-Za-z]\\)[.)]\\)\\(?:[ 	]+\\|$\\)\\)\\(?:\\[@\\(?:start:\\)?\\([0-9]+\\|[A-Za-z]\\)\\][ 	]*\\)?\\(?:\\(\\[[ X-]\\]\\)\\(?:[ 	]+\\|$\\)\\)?\\(?:\\(.*\\)[ 	]+::\\(?:[ 	]+\\|$\\)\\)?" 3 'org-checkbox prepend lax) ("\\[\\([0-9]*%\\)\\]\\|\\[\\([0-9]*\\)/\\([0-9]*\\)\\]" (0 (org-get-checkbox-statistics-face) prepend)) ("\\(?:^[ 	]*[-+]\\|^[ 	]+[*]\\)[ 	]+\\(.*?[ 	]+::\\)\\([ 	]+\\|$\\)" 1 'org-list-dt prepend) ("\\(@@\\)\\([a-z-]+:\\).*?\\(@@\\)" (1 'font-lock-comment-face prepend) (2 'org-tag prepend) (3 'font-lock-comment-face prepend)) ("^\\*+ \\(.*:ARCHIVE:.*\\)" (1 'org-archived prepend)) (org-do-latex-and-related) (org-fontify-entities) (org-raise-scripts) (org-activate-code (1 'org-code prepend)) (org-fontify-meta-lines-and-blocks) (org-fontify-inline-src-blocks) (org-cite-activate) ("^\\*+\\(?: +\\(DONE\\|TODO\\)\\)?\\(?: +\\[#\\(?:[A-Z]\\|[0-9]\\|[1-5][0-9]\\|6[0-4]\\)\\]\\)? +\\(?9:COMMENT\\)\\(?: \\|$\\)" (9 'org-special-keyword prepend)) (org-activate-folds)) (org-font-lock-hook (0 nil)) ("^\\(\\**\\)\\(\\* \\)\\(.*\\)" (1 (org-get-level-face 1)) (2 (org-get-level-face 2)) (3 (org-get-level-face 3))) ("^[ 	]*\\(\\(|\\|\\+-[-+]\\).*\\S-\\)
?" (0 'org-table-row t) (1 'org-table t)) ("^[ 	]*|\\(?:.*?|\\)? *\\(:?=[^|
]*\\)" (1 'org-formula t)) ("^[ 	]*| *\\([#*]\\) *|" (1 'org-formula t)) ("^[ 	]*|\\( *\\([$!_^/]\\) *|.*\\)|" (1 'org-formula t)) ("| *\\(<[lrc]?[0-9]*>\\)" (1 'org-formula t)) ("^\\(?4:[ 	]*\\)\\(?1::\\(?2:\\S-+\\):\\)\\(?:\\(?3:$\\)\\|[ 	]+\\(?3:.*?\\)\\)\\(?5:[ 	]*\\)$" (1 'org-special-keyword t) (3 'org-property-value t)) (org-fontify-drawers (0 nil)) ("^&?%%(.*\\|<%%([^>
]*?>" (0 'org-sexp-date t)) (org-activate-links (0 nil)) (org-activate-tags (1 'org-tag prepend)) (org-activate-target-links (1 'org-link prepend)) (org-activate-dates (0 'org-date prepend)) (org-activate-footnote-links (0 nil)) ("<<<\\([^<>
 	]\\|[^<>
 	][^<>
]*[^<>
 	]\\)>>>" (0 'org-target prepend)) ("<<\\([^<>
 	]\\|[^<>
 	][^<>
]*[^<>
 	]\\)>>" (0 'org-target prepend)) (org-fontify-macros (0 nil)) ("^\\(\\*+\\)\\(?: +\\(DONE\\|TODO\\)\\)\\(?: +\\(.*?\\)\\)?[ 	]*$" (2 (org-get-todo-face 2) prepend)) ("^\\(\\*+\\)\\(?: +\\(?:DONE\\)\\)\\(?: +\\(.*?\\)\\)?[ 	]*$" (2 'org-headline-done prepend)) (org-font-lock-add-priority-faces (0 nil)) (org-font-lock-add-tag-faces (0 nil)) ("\\<DEADLINE:" (0 'org-special-keyword t)) ("\\<SCHEDULED:" (0 'org-special-keyword t)) ("\\<CLOSED:" (0 'org-special-keyword t)) ("\\<CLOCK:" (0 'org-special-keyword t)) (org-do-emphasis-faces (0 nil)) ("^[ 	]*\\(\\(?:[-+*]\\|\\(?:[0-9]+\\|[A-Za-z]\\)[.)]\\)\\(?:[ 	]+\\|$\\)\\)\\(?:\\[@\\(?:start:\\)?\\([0-9]+\\|[A-Za-z]\\)\\][ 	]*\\)?\\(?:\\(\\[[ X-]\\]\\)\\(?:[ 	]+\\|$\\)\\)?\\(?:\\(.*\\)[ 	]+::\\(?:[ 	]+\\|$\\)\\)?" (3 'org-checkbox prepend lax)) ("\\[\\([0-9]*%\\)\\]\\|\\[\\([0-9]*\\)/\\([0-9]*\\)\\]" (0 (org-get-checkbox-statistics-face) prepend)) ("\\(?:^[ 	]*[-+]\\|^[ 	]+[*]\\)[ 	]+\\(.*?[ 	]+::\\)\\([ 	]+\\|$\\)" (1 'org-list-dt prepend)) ("\\(@@\\)\\([a-z-]+:\\).*?\\(@@\\)" (1 'font-lock-comment-face prepend) (2 'org-tag prepend) (3 'font-lock-comment-face prepend)) ("^\\*+ \\(.*:ARCHIVE:.*\\)" (1 'org-archived prepend)) (org-do-latex-and-related (0 nil)) (org-fontify-entities (0 nil)) (org-raise-scripts (0 nil)) (org-activate-code (1 'org-code prepend)) (org-fontify-meta-lines-and-blocks (0 nil)) (org-fontify-inline-src-blocks (0 nil)) (org-cite-activate (0 nil)) ("^\\*+\\(?: +\\(DONE\\|TODO\\)\\)?\\(?: +\\[#\\(?:[A-Z]\\|[0-9]\\|[1-5][0-9]\\|6[0-4]\\)\\]\\)? +\\(?9:COMMENT\\)\\(?: \\|$\\)" (9 'org-special-keyword prepend)) (org-activate-folds (0 nil))))
(font-lock-extra-managed-props nil)
(font-lock-fontify-region-function font-lock-default-fontify-region)
(font-lock-unfontify-region-function org-unfontify-region)
(font-lock-extend-region-functions (font-lock-extend-region-wholelines font-lock-extend-region-multiline))
(jit-lock-after-change-extend-region-functions nil)
(before-change-functions (org-before-change-function org-element--cache-before-change t))
(after-change-functions (org-element--cache-after-change org-fold-core--fix-folded-region t))
(org-src-fontify-natively t)
(org-fontify-whole-block-delimiter-line t)
(org-src-lang-modes (("C" . c) ("C++" . c++) ("asymptote" . asy) ("beamer" . latex) ("calc" . fundamental) ("cpp" . c++) ("ditaa" . artist) ("desktop" . conf-desktop) ("dot" . graphviz-dot) ("elisp" . emacs-lisp) ("ocaml" . tuareg) ("screen" . shell-script) ("sqlite" . sql) ("toml" . conf-toml) ("shell" . sh) ("ash" . sh) ("sh" . sh) ("bash" . sh) ("jsh" . sh) ("bash2" . sh) ("dash" . sh) ("dtksh" . sh) ("ksh" . sh) ("es" . sh) ("rc" . sh) ("itcsh" . sh) ("tcsh" . sh) ("jcsh" . sh) ("csh" . sh) ("ksh88" . sh) ("oash" . sh) ("pdksh" . sh) ("mksh" . sh) ("posix" . sh) ("wksh" . sh) ("wsh" . sh) ("zsh" . sh) ("rpm" . sh)))
