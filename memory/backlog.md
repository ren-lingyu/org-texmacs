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

The user rejected a standalone org-texmacs-preview-pdf command on 2026-10-08
as unnecessary. Do not implement it or interpret historical "preview" wording
as commitment to that command. The initial bounded ox-texmacs node provided:
optional dispatcher backend with synchronous whole-buffer byte-buffer/.tm/PDF
actions, existing prompted new-file policy and no generic string preprocessing.
Async/subtree/visible/body-only/overrides, active regions and narrowing are
explicitly rejected. Generic Org export/publishing remains unsupported; a
conditional early hook rejects texmacs generic preprocessing. Seven focused
cases pass 7/7; final Nix passes all seven checks and installed ERT 280/280.
Frontend commit be284dd matches the verified six-file hash. Only the module
fileset entry was committed in flake; the mirror overlay stays outside history.

### Completed: bounded subtree export

Committed as ee3e028, verified against the reviewed six-file diff.
Preparation clips an owned full-source AST, applies restricted subtree EXPORT_*
overrides, drops root heading/metadata from body and restores needed footnotes.
Integer selection and captured property settings guard native waits. Bibliography
declarations use explicit text snapshots, with a print in selected scope; links
to targets outside emitted AST fail. Seven subtree and eleven backend cases
pass; final Nix passes all checks and installed ERT 291/291. Six files are
committed. Other selection scopes, generic
API adaptation, extra overrides and async remain later/separate boundaries.

### Completed: region export

Implemented and verified following subtree commit ee3e028. Active region selects
body while subtreep still supplies configuration/naming. Optional fourth integer
pair is owned before waits. Partial ordinary text uses a private narrowed parse
of the full snapshot; needed notes and explicit bibliography stay owned.
Truncated islands and out-of-scope targets fail. Region 7/7, subtree 7/7, backend
11/11 and final Nix compilation/package-lint/installed ERT 298/298 pass. Six files
are committed as 7e6b4e0, matching the verified diff. Body-only was assessed
in the configuration node below. Visible-only, async, unrestricted overrides
and generic API adaptation remain separate/deferred; no general preprocessing
or file readers are adopted.

### Completed: restricted ext-plist

Body-only is an **unresolved-design** boundary: Org skips outer templates, with
backend-specific inner content. Native complete .tm/PDF contracts do not define
an embeddable fragment format. Hiding title alone is not equivalent. Recommend
deferring fragment work and implementing restricted ext-plist overrides for
already supported configuration (global < external < file < subtree) through
owned preparation. User selected this configuration node; it is implemented and
verified. Five source adapters accept optional fifth EXT-PLIST; frontend uses its
existing fifth argument. Only current context keys/types are allowed, with unique
keys and raw metadata strings/nil. Copy before prompts/waits; private merge and
pure lowering preserve ownership. Focused overrides 6/6, backend 11/11, subtree
7/7, region 7/7 and final Nix compilation/package-lint/ERT 304/304 pass. Five files
are committed as d71204d, matching the verified diff. Body-only fragment format/consumer
remains deferred and unresolved; generic API adaptation stays relatively late.

### Proposed next: narrowed-source export

Recommendation after the user's status/plan request; not yet selected for
implementation. Reuse region selection/full snapshot dependency preparation to
export the source's accessible range while preserving its existing restriction.
Design priority with region/subtree and snapshot invalidation explicitly before
implementation. Visible-only needs a separate frozen visibility contract and
must not be silently bundled. Common source-scope support may be followed by
phase closure and release-scope review; no new release version is selected.

### Completed: Org output naming and repeat export

User selected the narrower ox-latex convention after reviewing the proposal:
frontend uses org-export-output-file-name and ordinary overwrite of an existing
writable regular output, after source checks and native bytes are complete.
EXPORT_FILE_NAME is consumed as output metadata. Public new-file-only APIs keep
exclusive creation. Eleven focused cases pass 11/11; final Nix passes all seven
checks and installed ERT 284/284. Commit b4ee215 matches the verified five-file
hash. Extra
overwrite confirmation, backups, atomic replacement and target-version locking
are not prerequisites or adopted behavior for this node. Any later work on
those guarantees remains a separate unresolved-design boundary.

The next selected node is stable PDF semantic regression for footnotes and
owned citation/bibliography output. No fixed pagination/pixel/byte assertions
are adopted. First native citation rendering failed with unresolved [?] values;
the print/update/final-print sequence committed as b5100a9 resolves them.
Final focused 8/8 and installed ERT 273/273 plus all Nix checks pass; three
files are committed and the diff matches the verified hash. Preview
and broader visual/multipage inspection remain later boundaries.

The user selected native rendering/PDF on 2026-10-08 as the next CONSUMER-01
node. Implementation committed as db33c14 owns a temporary native buffer and PDF
inside the worker directory, uses three synchronous low-level updates and the
native printer, and returns bytes or saves a new file after source checking.
Six PDF cases and full local 271/271 pass. Final Nix passes all seven checks
with installed ERT 271/271 and mandatory Poppler inspection. Seven files are
committed and their diff matches the verified hash. The temporary overlay stays excluded.
No GUI preview or overwrite policy is included; PDF binaries remain outside GAW.

### CONSUMER-01: Add stable complete-document consumers

Status: **adopted-later** for remaining frontend/consumer semantics. Native
document construction, serialization, saving, checked whole-buffer exports,
PDF and bounded dispatcher/naming/reexports are implemented. Subtree selection
and region selection are committed. Generic Org export API integration,
other selection/configuration contracts and publishing are still bounded design
questions; no full syntax parity prerequisite is introduced. Backup/atomic
publication and a standalone preview command are not completion requirements.

Generic org-export-as/to-file compatibility is a nonblocking later adaptation
per the user's priority guidance. It is not a prerequisite for subtree scope
or configuration work through existing dispatcher/explicit-source APIs. Its
AST-first/preprocessing contract remains unresolved; current explicit rejection
must remain until a supported adapter is implemented.

The first node is committed as `e7377e5`: org-texmacs-document-serialize builds
complete native file-document structure from explicit encoded fields and returns
exact native .tm bytes independently of a session. Full local coverage and final
Nix checks (installed ERT 253/253) pass. The next bounded saving node uses an
explicit absolute local destination and creates new files without replacement.
Replacement/backup policy and Org export frontend policy remain separate. Reference tables,
attachments/auxiliary state and visual rendering retain separate boundaries.

The new-file saving node is committed as `0ee17c4`: owned explicit destination,
native serialization before creation, exclusive open, exact byte writing and
caller-state isolation. Four new cases pass in the eight-case focused selector;
full local/Nix checks pass (installed ERT 257/257). The source-buffer frontend
implemented below extends preparation's consistency check through native
serialization and writes only after it passes, reusing the new-file writer. Full Org backend/
dispatcher preprocessing remains separately unresolved.
Write errors can leave partial new files; this documented boundary is covered
by regression. Atomic publication/replacement is not implied by exclusive open.

The explicit-source export adapter node is committed as `ee225ad`: source preparation's
final check now encloses native serialization; bytes are returned or written to
an owned new-file destination afterward. Four new cases pass in twelve combined
focused cases, full local ERT passes 250/250 + 11/11, and Nix installed ERT
261/261 passes with compilation/package-lint. The next node adds M-x file export
and readonly native export buffers without generic backend/dispatcher preprocessing.
Dispatcher policy and replacement/publication remain separate boundaries.

The interactive node is committed as `1ed04db`: M-x buffer/file export, fresh readonly
native byte views, captured source identity before prompts and failed-view
cleanup. Four new cases pass in sixteen combined focused tests; full local ERT
passes 105/105 + 149/149 + 11/11 and Nix installed ERT 265/265 passes with
compilation/package-lint. Interactive bibliography
snapshots default to nil; explicit Lisp arguments retain the chosen data model.

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
features, arbitrary Org elements, dynamic source execution and nested footnotes.
Broader citation/bibliography variants, file resources and cross-file ID lookup
remain separately scoped; current local links, named notes and bare default
citations/plain bibliography are already implemented. Continue to reject
unsupported cases explicitly; unsupported syntax alone does not adopt work.

## Historical provenance

The full historical wording and probes remain non-authoritative evidence in:

```text
archive/2026-10-06T08-59-24Z--1a90b7b/
```

Relevant legacy areas include the inline validation boundaries, TeXmacs buffer
state and synchronization discussion, `PLAN-2026-09-13-01`, and
`PLAN-2026-09-14-02`. Consult them only when this backlog or current evidence is
insufficient; do not load the archive during ordinary recovery.
