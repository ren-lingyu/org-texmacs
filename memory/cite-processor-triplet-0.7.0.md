# v0.7.0 Cite declaration triplet follow-up

User explicitly asks to synchronize remaining usage/tests/comments/docs after
editing the existing Cite variable/helper. Main9f7f7c4, clean index, user diff only
lisp/org-texmacs-cite-native.el: default '(texmacs-native), Custom choice nil or
1/2/3-position list, docstring and helper (cons 'texmacs declaration). Preserve
these functional changes; they already match standard Org alist structure.

User clarifies motivation: reuse Org Cite's unified declaration instead of adding
parallel processor/style variables (no org-texmacs-cite-export-style). A future
(csl "/path/to/style.csl") uses the same interface. Motivation belongs in memory
and can inform the actual-diff message; user explicitly does not require prose
rationale in public docs, which should stay focused on format and use.

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

Focused flake gate passed324core/11CSL/7native against tmp/cite-triplet-focus;
canonical package source current, native test registration narrowed only inside
isolated copy to relevant native-cite.el. First pass, zero unexpected. New core
case validates raw full INFO and owned request style plain/alpha/abbrv; actual
native test exercises all four declarations and completed TM/text path. CSL case
adds (csl LOCAL-STYLE), verifies full triple and actual linked output. Public docs
show formats and restrictions, not mandatory rationale. Fresh single600s full check authorized and completed against167input snapshot
tmp/cite-triplet-final; no previous longer grant reused. No new archival need beyond maintained
tests/exact receipt. Native mathematical semantics unchanged.

Clarified responsibility: preference helper only prepends texmacs to declaration;
Org Cite selects/calls processor and passes bibliography style. Only the concrete
processor interprets style. No new preference-layer style parser or dispatch.
This is consistent with current code/tests, not an extra implementation request;
keep rationale/responsibility clarification in memory rather than public docs.
Complete7path diff and whitespace reviewed, index empty. Draft tmp/commit.md
updated for declaration feature; final acceptance and receipt are recorded below.

Final acceptance: command exit0, all12named checks pass,700defaultERT+actual5=705
unique tests, zero unexpected. Strict compile/lint/treefmt pass. Native282 runs
211.820402s; PDF document48 runs123.066443s; render29 runs159.469755s. Core324
and CSL11 outputs reused exactly from focused gate, not double-counted. Complete
7path diff/whitespace reviewed;167canonical input hashes match final snapshot,
ordinary index empty. Receipt cite-processor-triplet-0.7.0-inputs.json stores exact
parent/paths/message/source hashes/check outputs/log hashes and isolated overlay.
No additional manual native math experiment required for configuration-only scope.
No source changes after validation, state remains TODO, all ordinary changes
unstaged. Draft tmp/commit.md matches complete candidate, pending human delivery.
Single600s grant consumed. No additional project parent: accepted runtime tree is
uncommitted, not identical to parent9f7f7c4. Maintained tests and semantic receipt
suffice; no raw archive or temporary build directory retention needed.

Human delivery verified:21d5704 matches exact9f7f7c4 parent, seven changed paths,
complete approved message and all167committed plus current worktree hashes.
Ordinary index/worktree clean, no tag at HEAD. No unchanged runtime checks rerun.
This completes implementation, acceptance and human delivery; separate human
freeze/publication decisions remain, root TODO. Exact delivered state justifies
its GAW project-parent association; prior candidate checkpoint remains without one.
