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

### Completed selected Issue #3: export API and managed result lifecycle

User selected implementation after adopting the complete
contract in memory/export-api-contract.md. Accepted user-committed revision changes normal frontend/
explicit-source names and interactive boundary without aliases, adds managed
result ownership/reuse and transactional replacement, preserves conversion/file/
menu scope, and updates README/maintained ERT/real integration references.
Focused110/110, real fixtures9/9,396core ERT and complete isolated checks/strict
compilation/package-lint pass. Main's five paths/blobs/diff match reviewed
staged/validated candidate. Its final message has BREAKING-CHANGE and Closes: #3;
user explicitly judged selected scope sufficient for closure. Current ordinary
index empty, only user flake.nix dirty. Exact inputs and verification in
memory/evidence.md/current.md. Remote state unverified, no external issue write
or new release selected. Prior generic exporter/preview/atomic-file questions do not expand this
selected API/lifecycle scope.

### Completed selected Phase 5a-5d: formal frontend/preprocessing integration

INBOX section18 reviewed suitable and user now requested execution on Phase4
baseline; task isolated120s builds/240s checks/network authorized.5a four locked
probes pass, selected contract memory/frontend-preprocessing-contract.md.
Original review memory/frontend-preprocessing-plan-review.md.5a interface matrix before
5b full-buffer provider routing,5c preserved direct local scopes,5d real extension/
three-consumer regression. Keep PDF inside original transaction checks; guard
coexistence already covered by core loaded-frontend tests; expose provider limits
as default support change; independent buffer-local discovery boolean default nil
selected for both full/local exports. Eight new core and two new real frontend cases,
joint HTML/blog retarget;79focused/9real/381core ERT/all10checks accepted.
Seven project files user committed and identity verified; index empty/only user
mirror dirty. Contract/evidence/archive in current memory. Selected INBOX#1
architecture/frontend goals complete; BREAKING CHANGE and Closes: #1 retained in
verified message. Live issue page unavailable/no remote state change verified.
Generic exporter, full lifecycle/provenance/resources and key changes remain
deferred;#1 closure judged after selected frontend architecture acceptance.

### Completed selected Phase 4a-4d: working context and real interoperability

User selected rewritten section17; actual working-buffer/context6probes, cross-dir
implementation5core cases/32focused,7real SQLite/package/HTML/blog fixtures pass;
full373ERT/all10logged checks accepted. Contract memory/working-buffer-context-contract.md.
Final document base governs STM/relative bibliography, no original source recovery
or third-party DB/read interception. Default generic/export dispatcher policy and
STM actual resource/native relative-output enhancement remain separate; not automatic
requirements inferred from unsupported syntax. New optional integration runner needs
caller-supplied pinned extensions/runtime, no default dependency changes. User project
commit identity verified; index empty/only mirror dirty. Overall#1 closure must distinguish completed opt-in
interoperability from original proposal's frontend switch, now completed by Phase5; no external
issue mutation or silently expanded implementation. Latest17 targets complete.

### Completed: Phase 2c native preprocessing simplification

Newer INBOX section15 around1380 revises parameter-support plan: prefer native
preprocessing into owned final working Org and existing preparation; only needed
STM protection/dependency checks/resource origins. Parameters remain probe matrix,
not a mandate to extend mirror mapping. Reviewed suitable; investigated and minimum contract adopted. Exact original positions
and general AST provenance are not prerequisites. Review:
memory/include-parameters-plan-review.md. Fixed actual recursive reads,
stage-specific STM hazards, resource needs and observable field changes addressed
by adopted memory/preprocessing-contract.md and maintained regressions.
User now requested execution and INBOX correction: new plan is section16, old15
superseded. Nine native probes selected a fixed reader and line-preserving STM
shielding; minimal original/final/dependency snapshot contract adopted. Refactor
accepted:27 focused/368 ERT/all five current x86_64-linux checks pass; ordinary
user commit diff/message verified, index empty and only mirror dirty.
Exact-origin/occurrence prerequisites
removed explicitly from adapter INFO/docs/tests, no change to pure lowering.
Existing full-root/common-base/ordinary-level policy retained;
cross-directory resource policy and Phase4 integration separate, issue #1 open.

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

The first implementation node is committed as the local-link resolution revision: pure
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

The committed source-location node (the source-location snapshot revision) freezes `source-file` and
`resource-base` in owned input/results. Preparation expands context home
abbreviations once; pure construction never resolves ambient locations.
Original strings join snapshot consistency checks. An output destination must
not redefine the source-side link target.
This node was verified (217/217 ERT, compilation, and conditional Nix/package-lint
with the temporary mirror-source configuration), then reviewed and committed.
The user's overlay is excluded from project commits and pushes.

The plain-local-file node, committed as the local file-link semantics revision, preserves raw hlink target leaves with
typed `file-paths` and translates them on a body copy only in the native bridge.
It passed 223/223 ERT and Nix/package-lint under the temporary mirror-source
configuration. The named-footnote node, committed as the named-footnote revision, resolves inline/separate
definitions and repeated references within one owned snapshot; see project
and current memory for its bounded contract and validation state. The next
DOC-01 bibliography foundation is committed as the owned bibliography foundation revision. Default bare citation
resolution and native plain bibliography output are committed as the citation and plain bibliography revision;
see project/current memory for the bounded contract. The named/captioned basic
table node is committed as the named-table and caption revision: owned long/short captions, native big-table
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
The bounded ox-texmacs frontend revision matches the verified six-file hash. Only the module
fileset entry was committed in flake; the mirror overlay stays outside history.

### Completed: bounded subtree export

Committed as the subtree export revision, verified against the reviewed six-file diff.
Preparation clips an owned full-source AST, applies restricted subtree EXPORT_*
overrides, drops root heading/metadata from body and restores needed footnotes.
Integer selection and captured property settings guard native waits. Bibliography
declarations use explicit text snapshots, with a print in selected scope; links
to targets outside emitted AST fail. Seven subtree and eleven backend cases
pass; final Nix passes all checks and installed ERT 291/291. Six files are
committed. Other selection scopes, generic
API adaptation, extra overrides and async remain later/separate boundaries.

### Completed: region export

Implemented and verified following the subtree export revision. Active region selects
body while subtreep still supplies configuration/naming. Optional fourth integer
pair is owned before waits. Partial ordinary text uses a private narrowed parse
of the full snapshot; needed notes and explicit bibliography stay owned.
Truncated islands and out-of-scope targets fail. Region 7/7, subtree 7/7, backend
11/11 and final Nix compilation/package-lint/installed ERT 298/298 pass. Six files
are committed as the region export revision, matching the verified diff. Body-only was assessed
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
are committed as the external configuration override revision, matching the verified diff. Body-only fragment format/consumer
remains deferred and unresolved; generic API adaptation stays relatively late.

### Completed: narrowed-source export

User selected this node after reviewing the plan. Narrowing is outer body scope;
region takes precedence within it, otherwise intersect subtree body. Full
snapshot supplies configuration/dependencies, with source restriction restored
before parsing/callbacks and preserved at prompts/waits. Private heading/naming
copy handles hidden metadata; changed restrictions invalidate output before write.
Empty narrowing is valid. Public signatures are unchanged. Seven focused cases,
all five existing export groups and final Nix compilation/package-lint/installed
ERT 311/311 pass. Six files are committed as the narrowed-source export revision, matching the verified diff.
Visible-only needs a separate frozen visibility contract and is not bundled.
Phase closure selected v0.4.0 as described below. Other exporter flags/unsupported
syntax are not automatically
required completion work.

### Completed: v0.4.0 release

The v0.4.0 release preparation revision and final HTML regression the final HTML coexistence regression revision are committed and verified
against their reviewed diff hashes. Annotated local/remote v0.4.0 tag object
feaf8c4ef501d50aa595090a0fa312c855071527 points to
the final HTML coexistence regression revision. GitHub release is published, non-draft
and non-prerelease, at https://github.com/ren-lingyu/org-texmacs/releases/tag/v0.4.0
on 2026-10-09 01:27:12 Asia/Shanghai. User performed commit/tag/publication;
agent verified identities through read-only Git/API calls. Previous review hold
is finished. Release scope is current bounded DOC-01 resolution and native
consumers/export frontend/scopes/configuration, including controlled HTML
coexistence regression. No new post-release implementation is automatically
selected; issue #1 remains unresolved later design. Final no-overlay installed
ERT 312/312/all Nix checks pass, with cache reuse and ELPA reachability still not
independently established. Other platforms/GUI/general pagination remain unverified.

### Completed: Org output naming and repeat export

User selected the narrower ox-latex convention after reviewing the proposal:
frontend uses org-export-output-file-name and ordinary overwrite of an existing
writable regular output, after source checks and native bytes are complete.
EXPORT_FILE_NAME is consumed as output metadata. Public new-file-only APIs keep
exclusive creation. Eleven focused cases pass 11/11; final Nix passes all seven
checks and installed ERT 284/284. The Org output naming and repeat-export revision matches the verified five-file
hash. Extra
overwrite confirmation, backups, atomic replacement and target-version locking
are not prerequisites or adopted behavior for this node. Any later work on
those guarantees remains a separate unresolved-design boundary.

The next selected node is stable PDF semantic regression for footnotes and
owned citation/bibliography output. No fixed pagination/pixel/byte assertions
are adopted. First native citation rendering failed with unresolved [?] values;
the print/update/final-print sequence committed as the PDF semantic regression and citation repair revision resolves them.
Final focused 8/8 and installed ERT 273/273 plus all Nix checks pass; three
files are committed and the diff matches the verified hash. Preview
and broader visual/multipage inspection remain later boundaries.

The user selected native rendering/PDF on 2026-10-08 as the next CONSUMER-01
node. Implementation committed as the native PDF consumer revision owns a temporary native buffer and PDF
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

The first node is committed as the native serialization revision: org-texmacs-document-serialize builds
complete native file-document structure from explicit encoded fields and returns
exact native .tm bytes independently of a session. Full local coverage and final
Nix checks (installed ERT 253/253) pass. The next bounded saving node uses an
explicit absolute local destination and creates new files without replacement.
Replacement/backup policy and Org export frontend policy remain separate. Reference tables,
attachments/auxiliary state and visual rendering retain separate boundaries.

The new-file saving node is committed as the explicit new-file saving revision: owned explicit destination,
native serialization before creation, exclusive open, exact byte writing and
caller-state isolation. Four new cases pass in the eight-case focused selector;
full local/Nix checks pass (installed ERT 257/257). The source-buffer frontend
implemented below extends preparation's consistency check through native
serialization and writes only after it passes, reusing the new-file writer. Full Org backend/
dispatcher preprocessing remains separately unresolved.
Write errors can leave partial new files; this documented boundary is covered
by regression. Atomic publication/replacement is not implied by exclusive open.

The explicit-source export adapter node is committed as the explicit-source export adapter revision: source preparation's
final check now encloses native serialization; bytes are returned or written to
an owned new-file destination afterward. Four new cases pass in twelve combined
focused cases, full local ERT passes 250/250 + 11/11, and Nix installed ERT
261/261 passes with compilation/package-lint. The next node adds M-x file export
and readonly native export buffers without generic backend/dispatcher preprocessing.
Dispatcher policy and replacement/publication remain separate boundaries.

The interactive node is committed as the interactive export revision: M-x buffer/file export, fresh readonly
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

### Explicit export menu key configuration — Phase 6 accepted and committed

INBOX section18.7 explicitly postpones this beyond Phase5. Future design direction:
TeXmacs export menu keys require explicit user configuration, provide no default
key values, and show recommended/example values only in documentation. At Phase5,
C-c C-e T registration/keys remained unchanged; this was not a Phase5/#1 completion
prerequisite. This direction was originally deferred, then selected as Phase6 below.
The detail was recovered during INBOX
coverage audit, beyond the earlier generic "menu keys deferred" summaries.
Original plan wording is preserved in the retired INBOX archive:
archive/2026-10-14T12-48-06Z--5f4c9c0/files/INBOX.md. Newly supplied INBOX Phase6
associated issue2 reviewed then user selected execution. Detailed review:
memory/export-menu-plan-review.md. One complete nil-default prefix/buffer/file/pdf
setting, registration at first module load, backend/commands/guard remain independent
of menu, no runtime refresh/fallback.6a locked native conflict/load probes first;
own/validate before registration, genuine fresh-load cases and compatibility docs.
Selected contract memory/export-menu-contract.md. Phase6a-6d accepted:5native,
84focused,386core,9real fixtures/all10checks/strictcompile/lint pass. Three project
files implementation/ERT/README user committed, exact blobs/message verified;
default menu now nil with explicit
pre-load configuration and documented migration. Eight necessary text artifacts
archived at archive/2026-10-14T13-19-02Z--5f4c9c0/MANIFEST.md. Index empty,
only user mirror dirty; no external issue write or further implementation selected.
Release migration notes remain for a future release.

### Org ecosystem preparation interoperability

Phase 3b A/B/C selected through the user's INBOX section 13 review/execute
request is complete and committed as the opt-in bibliography discovery revision.
Independent opt-in bibliography discovery/acquisition adapters preserve defaults, owned
effective declarations and fixed local texts, full STM masking, standard Cite
advice and whole-transaction checks. Contract memory/bibliography-contract.md;
final 17 focused/341 installed ERT/all nine checks pass. Details/limits in project
and evidence. Phase 3a research is archived at
archive/2026-10-13T13-27-14Z--c26b932/MANIFEST.md, not production validation.
User selected Phase 2a/2b execution after section14 review. Phase 2a twelve locked
probes/model/report/comparison complete and archived at
archive/2026-10-13T16-45-34Z--049a5a0/MANIFEST.md. Bounded Phase 2b A/B/C implemented
and verified, then user-committed: 18 new ERT, 35 focused (includes17 Phase3b),
359 installed ERT/all ten checks. Contract memory/preprocessing-contract.md;
architecture/validation in project/evidence. Full common-directory/bare-file
composition, owned original/working/context/node origins, fixed file receipts,
protected STM and captured standard hooks/native INCLUDE, separately requested Cite
integration. Old APIs unaffected. No full native lifecycle or arbitrary callback
sandbox/FS atomicity. Cross-directory STM resource encoding, original selection map,
INCLUDE parameters/partial footnote scope/odd-level normalization remain later
contracts rather than supported semantics. Seven-path commit identity/diff/message
verified; index empty, only user mirror remains unstaged. Phase 4 real package integration remains independently
selected work, with optional small managed bibliography test not a Phase 2 blocker.
No personal DB/package compatibility claim, file/menu policy or issue closure.

Phase 1a/1b are implemented, verified and committed as the citation-key AST filter
revision; the complete five-file committed diff matches validated bytes.
Contract lives in
memory/filter-contract.md. Standard filters may change citation keys only, with
per-callback graph/work-context validation and independent ownership before waits.
Focused 12/12, installed ERT 324/324 and all 8 isolated flake checks pass on the
current lock's Emacs 31.1 / Org 9.8.10. Broader ecosystem preparation remains
unresolved beyond the bounded Phase2b composition and Phase3b discovery above:
broader source-selection/native resource policies remain separate. Selected Phase4
cross-directory/actual-package combination is now accepted as described above.
Phase 0's stage table/candidate comparison/reproduction is preserved at
archive/2026-10-12T19-11-59Z--b229454/MANIFEST.md. Candidate A was selected by
the user's INBOX section 11 and is now the bounded implementation above. Contract
preserves node set/identity/parentage and STM source/ownership, allowing only
citation-reference :key changes. Replacement/raw/other mutations fail explicitly.
Broader mutation support needs a new contract; do not auto-switch to candidate B.
Full copy/annotate reuse adds ID lookup, mutable-local aliasing and source/STM
mapping hazards; disabling Cite output also skips discovery. Locked Org has no
after-includes hook. Retain the generic guard and pure-layer I/O boundary;
broader preprocessing and real integration need separate contracts; selected
bounded composition/bibliography acquisition contracts are implemented above.
No issue writes were made;
initial public-source lookup failed; later local source and actual SQLite fixtures
independently verify the selected extension behavior (Phase4 above).

Status: **unresolved-design**, following the user's 2026-10-09 v0.4.0 review note.
Tracking discussion: https://github.com/ren-lingyu/org-texmacs/issues/1,
"design: reconsider Org preprocessing and export integration boundaries".
The issue is explicitly nonblocking for v0.4.0 and requires choosing the
information flow/interface boundary before splitting implementation/joint tests.
Current independent preparation is a bounded implementation policy, not a strict
permanent ban on standard Org preprocessing. AST-first does not itself forbid
preprocessing user Org source in a private working buffer or applying AST filters.
Keep canonical source, coherent owned dependencies and STM/resource provenance.
Explore reuse of preprocessing, export parse-tree filters and Org Cite bibliography
discovery at the adapter boundary; choose neither a mandatory generic exporter
nor permanently isolated preparation before design. Solve post-preprocessing STM
spans/origins, subtree/region/narrowing mapping, external file/database snapshots
and user-hook consistency/side effects explicitly. Pure lowering must not query
Org-roam/global databases or implicitly read bibliography files.
The note reports org-roam-organize discovery and managed UUID remapping,
org-roam-include source composition, and org-roam-blog HTML publishing; these
external source claims were not independently checked in this repository review.
No such architecture refactor, recursive INCLUDE, broader citation semantics or
blog publishing rewrite is adopted for v0.4.0. User authorized finite controlled
HTML hook/advice/AST-filter regression; it is committed as the final HTML coexistence regression revision and in v0.4.0.
Backend focused 12/12 and no-overlay Nix installed ERT 312/312 pass. This tests
actual HTML output/source isolation/cleanup with fake extensions, not the three
real packages or databases. Existing README restrictions remain accurate; no
new docs or production semantics were required. Issue remains later design.
ELPA HEAD probes were authorized once each and both timed out; no endpoint
recovery/global-outage claim follows. Release is complete; any implementation
of this design topic or further network probes requires new scoped authorization.

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
