# org-texmacs active backlog

## Purpose and status model

This file records still-valid future work that must survive replacement of the
legacy root documents. It is not a support matrix, an implementation
authorization, or an append-only copy of historical plans.

Use these status labels:

- **active-next**: the next adopted project change selected for implementation;
- **adopted-later**: required by the current goals, but not the next change;
- **deferred-candidate**: plausible work whose need, scope, or ordering still
  requires evidence or a later decision;
- **unresolved-design**: a semantic boundary that must be decided before its
  owning feature is implemented;
- **re-adoption-required**: an older idea that is not part of the current goals
  unless the user adopts it again.

Unsupported syntax is not automatically backlog work. Move an item into an
adopted status only when it follows from `memory/goals.md` or a later explicit
decision.

## Active next

### DOC-01: Complete document-wide semantic resolution

Status: **adopted-later** for remaining bounded variants; its critical resolution
architecture is implemented. Selected by the user's 2026-10-06 `INBOX.md` note after
the locally tagged v0.3.1 release. Prioritize this architecture before
`CONSUMER-01`; do not require all Org syntax before consumer work begins.

Grow the current prepared-input and document model only where semantics require
whole-document knowledge. The adopted direction includes internal/fuzzy,
custom-ID and ID links, file/resource references, named footnotes, general
references, citations/bibliography, and the effective configuration they need.
Unsupported constructs such as checkboxes, advanced tables, Babel, and arbitrary
Org elements are not thereby adopted.

The first implementation node is committed as `a3ba241`: pure
document-wide analysis creates identity-keyed local link/label mappings consumed
by lowering. Its supported contract is in `memory/project.md`; full ERT and
byte compilation passed. The expanded source-context worktree now also passed
Nix/package-lint checks using a temporary, uncommitted remote mirror-source
configuration. Retain a reviewable boundary when extending semantics. Local
handlers must not query buffers or guess global state. Cross-file ID lookup
and any global ID database remain separate
boundaries; do not silently introduce ambient queries.

After that boundary is stable, extend file/resources, named footnotes, and
citations/bibliography in bounded nodes. For file/resources, retain source-side
relative path meaning across consumers. A proposed representation is the raw
relative path plus a source/resource base captured by the buffer adapter in the
owned snapshot; a consumer may translate it for an output destination while
preserving the target. Source inspection and an Org 9.8-pre probe selected the
source buffer's effective `default-directory` as the base for both visiting-file
and non-file buffers; source file identity is separate and does not override an
explicit directory. Do not rewrite raw resource paths to absolute form early
or choose a base inside a local link handler.

The committed source-location node (`b09b451`) freezes `source-file` and
`resource-base` in owned input/results. Preparation expands context home
abbreviations once; pure construction never resolves ambient locations.
Original strings join snapshot consistency checks. An output destination must
not redefine the source-side link target.
This node was verified (217/217 ERT, compilation, and conditional Nix/package-lint
with the temporary mirror-source configuration), then reviewed and committed.
The user's overlay is excluded from project commits and pushes.

The plain-local-file node, committed as `77a2888`, preserves raw hlink target leaves with
typed `file-paths` and translates them on a body copy only in the native bridge.
It passed 223/223 ERT and Nix/package-lint under the temporary mirror-source
configuration. The named-footnote node, committed as `a242eb2`, resolves inline/separate
definitions and repeated references within one owned snapshot; see project
and current memory for its bounded contract and validation state. The next
DOC-01 bibliography foundation is committed as `8e1abf7`. Default bare citation
resolution and native plain bibliography output are committed as `fe6c435`;
see project/current memory for the bounded contract. The named/captioned basic
table node is committed as `544e246`: owned long/short captions, native big-table
reference labels, described-only uncaptioned anchors and metadata preflight.
Remaining general-reference/resource scope stays separately bounded while
CONSUMER-01 is active. Use native evidence before mapping other named elements.
Keep broader citation variants,
entry dependencies, global processors and resource behavior separately scoped.

Remaining **unresolved-design** boundaries include file search options,
tilde/remote targets/context, broader native URL escaping and consumer output
destinations. Org LaTeX source also shows
that undescribed unnumbered-headline links use title text; review the native
reference presentation policy before claiming equivalent visual behavior.

Study relevant `ox-latex`, `ox-html`, and `ox-publish` conventions and suitable
helpers. External Org preprocessing, setup files, includes, macros, hooks, and
global ID lookup must remain explicit and bounded; do not adopt the full export
pipeline when it reads files or dynamic state outside the owned snapshot.

## Adopted downstream work

### CONSUMER-01: Add stable complete-document consumers

Status: **active-next**. The stable bounded DOC-01 architecture now covers the
critical ordinary-document cross-node semantics; fuller Org syntax is not a
prerequisite. Start with complete native document construction and returning
serialized text independently of a session. Output file writes, export frontend,
rendering and preview remain later consumer nodes.

The first node is verified and staged: org-texmacs-document-serialize builds
complete native file-document structure from explicit encoded fields and returns
exact native .tm bytes independently of a session. Full local coverage and final
Nix checks (installed ERT 253/253) pass; await the user's commit. Then review
explicit-destination saving and Org export frontend policy. Reference tables,
attachments/auxiliary state and visual rendering retain separate boundaries.

Build complete TeXmacs file-document construction and independent consumers for
native serialization/save, Org export integration, rendering/PDF, and preview.
Begin after a stable DOC-01 resolution architecture covers the critical
cross-node semantics of ordinary complete documents; full Org syntax coverage
is not a prerequisite.
Keep the AST-first rule: construct known target structure directly and use
TeXmacs-native serialization or rendering interfaces rather than generating an
intermediate text format that must be reparsed to recover structure.

The relationship between a future `ox-texmacs` frontend and the current
document construction API is an **unresolved-design** question. Export policy
and preprocessing belong above the reusable document constructor, not inside
local lowering handlers.

Visual output, pagination, page setup, and installed-system behavior need
native or GUI evidence before they can be claimed as verified.

## Deferred candidates

### SESSION-01: Multi-document or multi-session operation

Status: **deferred-candidate**.

The current public contract intentionally exposes one active native document
session. Add multi-document/session behavior only when a concrete consumer
needs it and ownership, failure isolation, cleanup, and concurrency semantics
have been designed.

### INCREMENTAL-01: Local native mutation and incremental synchronization

Status: **deferred-candidate**.

Full body replacement is the current correctness baseline. A local mutation
path would require stable target paths or identities, invalidation rules, stale
result rejection, failure-to-full-sync fallback, reference/auxiliary-state
readiness rules, and performance evidence. Do not add live edit hooks or a
second incremental AST cache merely for convenience.

### INLINE-01: Expand or optimize inline TeXmacs discovery

Status: **deferred-candidate**.

The maintained configured-fragment subset is sufficient for the current
contract. Before broadening it, probe the exact intended Scheme-reader surface,
including comments, character literals, extensions, malformed-input recovery,
overlap and precedence with Org objects, complex-container/region boundaries,
large-document performance, and relevant Org-version behavior. Inline caches
or augmented live ASTs require separate evidence and adoption.

### AUTHORING-01: Editing assistance

Status: **re-adoption-required**.

Font locking, Scheme editing assistance, preview-oriented UX, and similar
authoring conveniences appeared in early exploration but are not current
architecture commitments. Re-adopt and scope them before implementation.

## Current unsupported cases are not automatic commitments

Examples include checkbox and explicit list-counter semantics, advanced table
features, arbitrary Org elements, dynamic source execution, nested footnotes,
citations, bibliography, and general internal/file/ID links. Some are covered
by adopted document work above; others remain unsupported until separately
adopted. Continue to fail explicitly rather than silently flattening them.

## Historical provenance

The full historical wording and probes remain non-authoritative evidence in:

```text
archive/2026-10-06T08-59-24Z--1a90b7b/
```

Relevant legacy areas include the inline validation boundaries, TeXmacs buffer
state and synchronization discussion, `PLAN-2026-09-13-01`, and
`PLAN-2026-09-14-02`. Consult them only when this backlog or current evidence is
insufficient; do not load the archive during ordinary recovery.
