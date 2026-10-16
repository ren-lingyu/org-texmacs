# Interactive check (not executed by the agent)

Use a fresh Emacs loading the candidate package. If using the unstaged source
through Nix, choose an explicit path flake so the new module is included.
Open manual.org in this task directory, then `(require 'org-texmacs)`.

1. Ordinary Org bold/link remain styled and clickable. STM strings use Scheme
   string faces, including multiline, inline footnote and mixed-case block.
   The Org-looking string inside STM keeps its literal delimiters visible;
   it must not become an active Org link or hide emphasis delimiters.
2. Type and undo an opening quote/parenthesis. Delete and restore block begin/end
   lines. Colors must recover without errors and without repainting stale bodies.
3. Move over STM parentheses with ordinary Emacs sexp navigation. This is Scheme
   editing syntax, not native validation; do not evaluate source as Scheme.
4. Evaluate `(setq-local org-texmacs--font-lock-enabled nil)`. Normal redisplay
   should restore ordinary Org presentation. Set it to t again to restore STM.
5. Narrow/widen, fold/unfold headings, toggle Font Lock and change major mode.
   Check boundaries, cleanup and absence of unexpected modified/undo entries.

Real GUI redisplay, folding and third-party mode interaction require this manual
check; batch hook tests do not certify those behaviors. Dense 1 MiB synthetic
full-buffer ensure is expensive; it is not a measurement of visible-only JIT
painting. Local context lookup also has a measured size-dependent cost.
