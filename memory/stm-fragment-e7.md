# E7: compatibility decisions and interface migration

## Authority and scope

User explicitly adopted three decisions during this review: remove automatic
bare inline STM recognition directly, without a legacy transition switch; retire
the old fragment discovery/span contracts in favor of extended AST/source APIs;
and preserve all structurally valid model trees while promising source output
only within its verified representable domain. Native blocks are unchanged.
These are candidate next-version decisions, not capabilities delivered on main.
The planning version remains provisional until public interfaces and scope are
reviewed. No formal source, README, changelog or version change is authorized.

A and B are separate. A does NOT require every structurally valid tree to have a
source representation: unknown/empty/whitespace symbols remain legal at model
level, even when output fails. B explicitly permits source failure when a valid
tree cannot safely inhabit an Org container. Keep model validity/copy/replacement
independent, leave the input unchanged, and never silently wrap/change a tree or
repair native Org nesting. E5's writer shortcomings are not thereby declared
permanent STM syntax limits. Unknown roots still enter recognition/native parsing
without a tag whitelist.

## Current API audit and adopted migration

Baseline APIs are documented in README's fragment section and implemented in
org-texmacs-fragment.el / org-texmacs.el:

- fragment-at-point/map return source SPANS, not AST nodes. Map promises source
  ordering including nil callback results, accessible-region filtering without
  truncation, narrowing as boundary, source-buffer callbacks and state guards.
- fragment-span includes buffer/tick/bounds/raw source/root tag and a copied
  fragment-tags snapshot. Stale checks depend on edits and the full ordered tag
  list. fragment-tree runs a fresh native parse and returns a distinct Org-compatible
  pseudo tree, not a model island or stm-fragment object.
- fragment-tags filters literal roots, supports local/dynamic binding, and nil
  disables old discovery. Parse/context/serialize and fontification also consume it.

It would be misleading to change fragment-map to return stm-fragment under the
same compatibility claim. The user chose explicit retirement of old contracts,
not a legacy compatibility layer or silent return-type change. Retire the public
old at-point/map/tree and span/tag-snapshot promises together in the candidate
release, with migration notes and replacements. New exact function names and
signatures are deliberately still subject to interface review.

New explicit carriers do not use fragment-tags as a whitelist or disable switch.
Do not repurpose it into an undocumented filter. Existing model context accepts
:fragment-tags as historical syntax data: review its migration separately rather
than silently changing direct model validity because its source effect disappears.
This review establishes repository call sites, not absence of external callers;
no personal Emacs config or external dependent repositories were scanned.

Source migration wraps complete old inline compound STM in explicit carriers,
with default output using the backslash form. Bare `(math "x")` subsequently
receives ordinary Org interpretation; exact literal display should use Org's
literal mechanisms. No automatic bulk migration tool is adopted. Existing native
texmacs/equation/equation* blocks and their cache/edit APIs retain their contracts.
Direct model-create/copy/island/replacement remain independent; source-buffer
parse APIs should retain their established result types instead of becoming AST
APIs silently. Direct AST plus known parsed trees stays pure; conversion from
unparsed fragment source may explicitly use native parsing in its designated
phase, not as a hidden constructor or reverse-conversion dependency.

## Error strategy and writer-domain boundary

Adopted semantic split: invalid model/source errors differ from valid-model
representation failure. Reusing the existing model-serialization-error family
for source representation failure is the compatibility-preserving implementation
recommendation; exact diagnostic payload/path schema remains interface work.
Do not report those failures as model-error merely because source is unavailable.
Atomic roots outside compound fragment syntax, unsupported writer encoding and
Org container mismatch must be diagnosable separately. E5's empty/whitespace
symbol cases can be reported unsupported in a verified initial output domain;
that is not a new invalid-tree rule or a claim no future encoding can exist.
No hidden worker fallback or automatic math/concat wrapping is adopted.

Before formal scope freeze, specify the writer's supported encoding domain and
how it rejects unsafe Org output. The accepted layered policy resolves whether
failure is allowed; it does not automatically turn a finite probe matrix into a
complete writer specification. No all-valid-tree source promise is made.

## Minimum version — Confirmed for representative probes

Source release_9.8 fixed at upstream commit 89df5bf46ba214db44eea898cc7cacc0b27fd760
was actually loaded under Emacs 31.1. Generated only org-version/autoload metadata;
eight key org-mode, org-element create/copy/map/class/interpret/parse and
org-export-as definitions were verified under that source directory. The old
preparation derivation was no longer present; source itself reused cached input.
No 9.8.10 module-origin substitution is accepted as a 9.8 result.

E3's 24 registered roundtrip comparisons pass on 9.8, as do cache context switches
and cleanup observations. E6's 21 real standard Export cases give the same 19
successes/two expected failures, with output assertions covering final filters,
INCLUDE/SETUPFILE/macros/Babel, selection, whitespace, native Cite selection,
wrappers/typed references, cross-file ID and nested backend recovery. These are
isolated prototypes with E6's recorded lowering patch, not formal implementation
or the complete new-release ERT/PDF/platform matrix. Exit codes and separate
assertions pass. Keep declared Org >=9.8 / Emacs >=31.1 unless later implementation
provides a concrete contrary need; there is no present evidence to raise them.

Evidence/replay for minimum/editor probes:
archive/2026-11-17T17-51-22Z--dd4deff/files/tmp/stm-e7/.
Exact paths and source pin/generation details are in the archive. No full upstream
source duplicate or design-message transcript is needed for recovery.

## Editing/fontification scope

Current 9.8.10 baseline fontification probe: bare STM and native-block strings
receive Scheme faces; the new explicit carriers/unknown root do not. Code stays
org-code, incomplete editing does not error, text/tick are unchanged, and native
parser invocation was prohibited. Existing source editing recognizes complete
native blocks, not new inline objects. This is a concrete migration gap, not
proof the old editor already supports the new syntax.

Recommended necessary scope: reconnect the existing worker-free Scheme
fontification to the new scoped recognizer, respect opaque regions and allow
incomplete editing; preserve native-block source editing. No inline-specific
source editor, new general minor mode or OTP preview is needed to deliver core
AST conversions. Validate incremental invalidation/faces/region boundaries in
its own implementation node; no speculative preview framework is adopted.

## Interface review and development handoff

The user decisions settle bare-syntax and old-API policy, and A/B failure
semantics. Remaining review is concrete: new source/AST/adapter names and
signatures, formal output encoding/error payload rules, and :fragment-tags context
cleanup compatibility. Then review candidate scope/development nodes explicitly:
scoped object/parser; existing-owner AST adapters; pure writer/normalization;
standard Export integration (including E6 context/whitespace fixes); legacy API
removal and editor adaptation; synchronized docs/examples/regressions. Do not
copy experimental scripts unchanged into production or mark features delivered.
No new major architectural contradiction was discovered; scope is not frozen
merely because these representative minimum-version probes passed.
