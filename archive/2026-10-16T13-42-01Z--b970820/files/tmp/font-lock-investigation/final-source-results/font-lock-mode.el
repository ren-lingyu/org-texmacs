(define-minor-mode font-lock-mode
  "Toggle syntax highlighting in this buffer (Font Lock mode).

When Font Lock mode is enabled, text is fontified as you type it:

 - Comments are displayed in `font-lock-comment-face';
 - Strings are displayed in `font-lock-string-face';
 - Certain other expressions are displayed in other faces
   according to the value of the variable `font-lock-keywords'.

To customize the faces (colors, fonts, etc.) used by Font Lock for
fontifying different parts of buffer text, use \\[customize-face].

You can enable Font Lock mode in any major mode automatically by
turning on in the major mode's hook.  For example, put in your
~/.emacs:

 (add-hook \\='c-mode-hook \\='turn-on-font-lock)

Alternatively, you can use Global Font Lock mode to automagically
turn on Font Lock mode in buffers whose major mode supports it
and whose major mode is one of `font-lock-global-modes'.  For
example, put in your ~/.emacs:

 (global-font-lock-mode t)

Where major modes support different levels of fontification, you
can use the variable `font-lock-maximum-decoration' to specify
which level you generally prefer.  When you turn Font Lock mode
on/off the buffer is fontified/defontified.

To add your own highlighting for some major mode, and modify the
highlighting selected automatically via the variable
`font-lock-maximum-decoration', you can use
`font-lock-add-keywords'.

To fontify a buffer, without turning on Font Lock mode and
regardless of buffer size, you can use \\[font-lock-fontify-buffer].

To fontify a block (the function or paragraph containing point,
or a number of lines around point), perhaps because modification
on the current line caused syntactic change on other lines, you
can use \\[font-lock-fontify-block].

You can set your own default settings for some mode, by setting a
buffer local value for `font-lock-defaults', via its mode hook.

The above is the default behavior of `font-lock-mode'; you may
specify your own function which is called when `font-lock-mode'
is toggled via `font-lock-function'."
  :after-hook (font-lock-initial-fontify)
  ;; Don't turn on Font Lock mode if we don't have a display (we're running a
  ;; batch job) or if the buffer is invisible (the name starts with a space).
  (when (or noninteractive (eq (aref (buffer-name) 0) ?\s))
    (setq font-lock-mode nil))
  (funcall font-lock-function font-lock-mode)
  ;; Arrange to unfontify this buffer if we change major mode later.
  (if font-lock-mode
      (add-hook 'change-major-mode-hook 'font-lock-change-mode nil t)
    (remove-hook 'change-major-mode-hook 'font-lock-change-mode t)))
