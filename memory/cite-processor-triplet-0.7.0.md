# v0.7.0 Cite declaration triplet follow-up

User explicitly asks to synchronize remaining usage/tests/comments/docs after
editing the existing Cite variable/helper. Main9f7f7c4, clean index, user diff only
lisp/org-texmacs-cite-native.el: default '(texmacs-native), Custom choice nil or
1/2/3-position list, docstring and helper (cons 'texmacs declaration). Preserve
these functional changes; they already match standard Org alist structure.

Non-nil declaration = (PROCESSOR [BIBLIOGRAPHY-STYLE [CITATION-STYLE]]), without
backend. nil delegates unchanged. No old symbol compatibility alias/branch.
Explicit texmacs entry and more-specific derived entry win via standard Org;
document/subtree/external/filter priority unchanged, no global mutation/new
processor lifecycle, AST/STM ownership or native citation-style expansion.
Native citation style remains default-only; third position preserved for Org.

Modify test helper to return copied full INFO :cite-export triplet; use equal,
assert concrete style positions for 1/2/3 declaration lengths, alpha/abbrv and
nil delegation/config precedence. Validate raw native INFO (native nil nil)
plus actual native bibliography callback/owned request style plain, and explicit
alpha/abbrv. Retain existing declaration/subtree/external/filter/nested/HTML/
LaTeX/derived/errors/preload/runtime/config identity tests, using declaration
lists rather than symbols. Actual native and CSL tests use declaration format;
full-triplet assertions must not be replaced by name-only checks.

Docs: README default/alpha/abbrv/full third-slot/nil examples and Org priorities;
existing root completed item/detail describe declarations and supported style
boundary. No version/state/tag/release change. One reviewable human commit with
exact input receipt/draft, GAW checkpoint. Scoped affected ERT before necessary
compile/lint/fmt/full validation; no repeat mathematical visual experiments for
this interface-only change. Separate human freeze after delivery. No external
issue action named, no raw archive needed after sufficient semantic extraction.
