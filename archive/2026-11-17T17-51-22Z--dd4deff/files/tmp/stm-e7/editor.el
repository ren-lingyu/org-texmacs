;;; editor.el --- current editing contract probe -*- lexical-binding: t; -*-
(setq load-prefer-newer t)
(require 'org-texmacs)
(require 'org-texmacs-font-lock)
(require 'org-texmacs-edit)
(require 'json)
(let (rows)
  (cl-letf (((symbol-function 'org-texmacs--worker-request)
             (lambda (&rest _) (error "fontification invoked native parser"))))
    (dolist (source '("Before (math \"x\") after.\n"
                      "Before $(math \"x\")$ after.\n"
                      "Before \\((custom-tag \"x\")\\) after.\n"
                      "~$(math \"x\")$~\n"
                      "Before $(math \"x\"\n"
                      "#+begin_texmacs\n(math \"x\")\n#+end_texmacs\n"))
      (with-temp-buffer
        (org-mode) (insert source)
        (font-lock-mode 1)
        (let ((tick (buffer-chars-modified-tick)) error-result face context)
          (condition-case e
              (progn
                (font-lock-ensure (point-min) (point-max))
                (goto-char (point-min)) (search-forward "\"x\"")
                (setq face (get-text-property (- (point) 2) 'face))
                (goto-char (point-min))
                (setq context (org-texmacs--edit-context)))
            (error (setq error-result (error-message-string e))))
          (push (list :input source :error error-result :x-face (format "%S" face)
                      :block-edit-context (and context t)
                      :text-unchanged (equal source (buffer-string))
                      :character-tick-unchanged (= tick (buffer-chars-modified-tick))) rows)))))
  (with-temp-file "tmp/stm-e7/editor.json" (insert (json-encode (vconcat (nreverse rows))) "\n")))
(princ "editor probe completed\n")
