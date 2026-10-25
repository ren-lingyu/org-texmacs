# org-texmacs active backlog

## Literate bilingual documentation package written, not validated

User requests an exported packages example with PDF in out and broad public
configuration coverage. Package-level complete isolation is mandatory; content
and layout equivalence suffice, non-body timestamp differences are allowed.
User subsequently authorizes files-only implementation, not validation.
User renames this to org-texmacs-documents: canonical docs/ input passes explicitly
as docs from flake fileset through the package overlay. Six bilingual guide/math/
figure-table builds use real INCLUDE chapters and Org-derived configuration/
bibliography; driver stays in pkgs, no separate README. Practical coverage replaces
mechanical option enumeration; native BibTeX type/concat/crossref behavior is shown.
No evaluation/tangle/build/formatter/test run; syntax, rendering, Chinese glyphs/
layout and formatting remain unverified. Details and next review/validation step:
memory/documents-package.md. Do not turn this into a default check
or release gate, change generic worker behavior, or reintroduce font repair.

## Issue14 document information delivered; issue completed

User tentatively excludes Issue14 from0.5.0 release blockers. Revisit if user
changes scope; release-blocking classification is independent of the
subsequently selected implementation below.

User now selects the reviewed plan for
https://github.com/ren-lingyu/org-texmacs/issues/14. Nine metadata fields, ordered
abstract/keyword structures, initial literal provenance and README are implemented
locally, with16core/3native/1PDF maintained cases. Org declarations override
global initial defaults. Whole-file keywords retain positions; partial export
uses one effective inherited/overridden value. creator:t is a labelled native
note, distinct from fixed PDF Creator. Native language-registry membership is
validated without testing font availability. Final full gate passes579default
cases, strict compilation/lint/aggregates;85root/copy inputs unchanged afterward.
User commits the exact reviewed15path candidate; expected parent/patch/message/
85inputs match. GitHub independently confirms CLOSED/COMPLETED at
2026-10-25T17:29:52Z. No agent project commit or external write. Subsequent
committed formatting and flake-input/check updates are separately reviewed in
post-issue14-flake.md and excluded from this original runtime acceptance.
Font work remains excluded. Contract/evidence: issue14-implementation.md;
preceding feasibility evidence: issue14-metadata.md.

## Tests optimization review after live-log delivery

First two user-selected nodes are implemented, accepted and delivery-verified:
shared testSupport.mkErtCheck and two PDF leaves27+32 under retained ert-pdf.
Authorized isolated gates pass all559default cases and exact-name inventory;
observed parallel PDF phase~129s versus prior serial231s, single-run comparison.
Optional9integration cases unchanged but not rerun this task. Deferred candidates:
further matrix phase timing and local unchanged-PDF inspection reuse. Preserve
all59PDF names/assertions and worker/config/error isolation, explicit dependency
arguments and no README/ancestor discovery. No shared workers, deleted cases or
removed native print passes. Further optimization unselected; details, acceptance
and resource caveats: tests-refactor.md optimization section.

User confirms the optimization project commit and now authorizes this follow-up:
set push-mark NOMSG to t at four frontend test calls (two native, two PDF) to
suppress ordinary "Mark set" messages without changing region behavior. Do not
mix it into the delivered Nix-only change. Four substitutions delivered in the
separate test commit; exact patch/message and clean project state verified.
User reports manual flake check passed with no "Mark set" output; supplied
subsequent exit0 invocation reuses realized outputs (0checks run). No agent rerun.
Delivery complete; no further output suppression selected.

## personal-nixpkgs test/check migration implemented and accepted

User-selected follow-up to the delivered test split replaces manual root
callPackage composition with llib.tests.mkChecks, six test-overlay.nix factories
and test.nix drivers; flake checks restored against the user's new package scope.
Patched-caption uses the real package override and lint receives an explicit
library. Existing cases/helpers and optional integration unchanged. Authorized
full path flake check passes553main+6patched cases, lint/aggregate/strict build on
x86_64-linux. No speed/coverage change or new future work adopted; no ordinary
index/history modification. User may review/stage delivery. Current interfaces
and acceptance limits: tests-refactor.md latest section.

## Tests migration/refactor committed and verified

User-selected cleanup is complete and user-committed: callPackage/explicit
dependencies, no README or parent-directory discovery, direct Emacs drivers,
isolated core/native/PDF groups plus ert aggregate and shared support. All553
main/6patched/9optional integration cases retain business assertions and matrices;
two example names/calls change to fixed test-owned fixtures. Two authorized full
checks pass, including runtime inventories and runner rejection controls.
Core ~1s; native ~177s and PDF ~210s can run independently/concurrently. No new
worker-sharing/deletion/benchmark task adopted. Delivery verification matches
single expected parent,48changed paths, full patch/message and all65accepted input
blobs; project index/worktree clean. No rerun for identical committed bytes.
No remaining implementation/delivery/tracking action; next user selects work;
details and evidence limits: memory/tests-refactor.md. No production/lock/ignore
or ordinary Git mutation; README running instructions synchronized.

## Version/documentation finalization committed and verified

User-selected six-path0.5.0 metadata/README/commentary candidate passes full isolated
flake(553stock/6patched/strict compile/lint) and default build. User committed exact candidate;
parent/patch/message/all32inputs verified; project index/worktree clean.
Version/docs complete; next user selects final optional documents or release actions.
No separate release-only complete-check gate or mandatory document/check/app.
Native fonts/PS route remain removed; no tag/publication. release-0.5.0.md holds
current scope/evidence; older pending-version wording is superseded by this state.

## Statement caption completion committed and verified

User selected adopted design; six-path candidate now passes focused75/75,
patched Org6/6, stock553/553, all7isolated flake checks/strict compilation/lint
and default build. Independent native direct/surround36cases per generic/article
passed before production, with readback/tm reload/font/layout/PDF destination
checks. Use one surround prefix, original STM roots indivisible; nonconcat/empty
separate prefix. All16types have long-only caption->dueto with existing inline,
reference/frozen ID/source-proof rules; short incl empty syntax and empty long
rejected. Example Org syntax exception retained. Root workaround/lock unchanged,
user committed exact six-path candidate; parent/diff/blobs/message verification
passes. Index empty, original flake workaround remains unstaged; no release
readiness claim. Remote issue13 public HTML freshly confirms CLOSED/COMPLETED after user-authorized retry.
Contract/results/native distinctions: statement-caption-implementation.md.
Adopted guidance: statement-caption-review.md. Necessary raw native evidence:
archive/2026-10-18T02-10-34Z--947289b/MANIFEST.md. Next user selects remaining release work,
remaining release gates unchanged.

## Block mapping / CJK bounded investigation completed

User recalls original fixed blocks primarily quote/center; archive red/green
quote reports and retained center positive controls now map to current regressions.
Fresh14/14block/native ERT58.636359s cover other current supported blocks too;
no further mapping defect established. Exact lost original source not recovered.
72font diagnostic PDFs:two Noto variable TTC matrices total48cases still
fallback (families listed but missing native masters); final24Fandol gives18real-
Chinese positives and6missing-font baselines. All8final configurations match text,
font specs/full names and geometry exactly across package/native/saved-tm reload. Full native
Fandol font setup plus FandolSong/chinese or FandolHei is a practical tested config;
font availability/registration required, native bold/italic/size differences remain.
User original environment/symptom not fully reproduced, no exporter patch justified.
No production/index/lock/user-flake change, no full release gate. Detailed scope,
authorization/diagnostics/limits and23text archive: block-font-investigation.md.
Native font follow-up was subsequently reproduced and removed from active
project scope by user decision. No font configuration/docs/fix task is pending.
Do not claim global font correctness or0.5.0 readiness.

## PDF footnote destination repair: delivered and verified

User-selected production repair is accepted on fixed isolated inputs. Worker
installs a same-key label before the original recognized render-footnote* binding
only in its disposable PDF buffer after first print. Native numbering is retained;
explicit footnote/render-footnote/render-footnote* inits and incompatible/already-
labelled macros are preserved. Source/prepared/serialized trees and sessions stay
unchanged. No API, protocol, global style/config or Org dependency change.

Focused pdf-footnote6/6 passed29.555130s, including five new maintained regressions.
Full nix flake check exit0 (all checks passed: full stock ERT, patched Org, strict
compilation and lint); no-link default build exit0.32runtime inputs equal root and
isolated tmp/footnote-fix before/after all gates; original ELPA workaround and lock
unchanged. User committed all seven approved task paths; exact delivery verified. Coverage: generic/article,
anonymous/named-repeat/markup/cross-page, actual forward/back targets, repeated
exports, explicit macros, error cleanup/recovery, shared session/worker isolation
and cleanup-fatal shutdown. No GUI, PS exact landing, arbitrary-style or caption
layout guarantee. User adopts PS->PDF as completed diagnostic only,
not a feature/fallback/maintained acceptance path/release condition. No PS task
or added Ghostscript runtime dependency; preserve historical evidence only. See
footnote-forward-probe.md for disposition. Full contract/commands/identities: footnote-pdf-fix.md. Earlier
causal evidence and archived originals: footnote-forward-probe.md and
footnote-private-integration.md. Read-only verification confirms the exact single expected Issue13 stage4 parent,
seven paths/blobs, full binary patch and approved message; index empty, original
flake workaround alone unstaged, lock unchanged. No runtime rerun solely for
commit verification. Project-parent association grounds delivery equivalence,
not the original uncommitted runtime acceptance. Remaining release gates are
separate; next user selects readiness work. No agent ordinary commit or external
tracking action.

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

### Issue13: adopted required v0.5.0 special-block subset

Stage3 figure/table candidate implemented/accepted with adopted corrections;
user committed exact five paths, delivery verified; index empty, only flake overlay dirty. Native controls,44focused, full flake and no-link
build pass. Org footnote/raw-marker boundary restriction explicitly
adopted by user; no parser/text reconstruction. memory/issue-13-stage3.md.
Stage4 NAME is delivered and verified; Issue13 is closed/completed.
4A/4B/4C candidate accepted:57focused/539fullERT/patched5/strict compile/lint/
full flake/default build pass. Seven-file user delivery exactly verified; remote
Issue13 confirmed closed/completed. Contract/identity: issue-13-stage4.md.

Status: stage1 implemented/accepted/user-committed; exact delivery verified.17focused/
495fullERT/full flake/strict package compile/lint/build pass; generic native16
types and PDF accepted. Stage1 delivery evidence:
memory/issue-13-stage1.md. Stage3 delivery is above; NAME candidate accepted as described above.
Stage2 equation/equation* implemented/locally accepted: focused29/29/native generic/
article readback/PDF/reload, full flake ERT/compile/lint and no-link build pass.
User committed the exact nine-path reviewed candidate; parent/patch/message/
blobs verified; at that delivery index was empty with only flake overlay dirty. Raw STM remains
opaque across preprocessing/bibliography/context as well as preparation/scanner;
no math whitelist, recursive body or NAME. Full contract/acceptance/sequence and
retention decision: memory/issue-13-stage2.md. Stage3 candidate acceptance is
above; stage4 NAME/links delivered and verified, Issue13 closed/completed. No remaining stage2 implementation work.
Recursive private special-block handlers,
statement aliases, equation/equation*, explicit figure/table and bounded
single-object NAME/[[name]] support. Full source/label/provenance/validation
contract: memory/special-block-plan.md. Existing release gates are retained;
prior delivered editing/font-lock/bibliography do not establish this capability.

### Caption anonymous inline-footnote compatibility implementation

User selected implementation before Issue13 stage4. After native investigation,
final decision accepts correct AST/content conversion with no native PDF layout
promise; long and short caption notes supported equally. No auto split-note,
layout/counter/anchor workaround. Stock production Org, patched test closure only;
patch colocated with consumer, native runs from isolated flake. Local lower and unprepared-citation guard implemented; default focused4, patched5,
full flake/default build accepted; user-committed delivery verified. Detailed current
contract/evidence: caption-inline-footnotes.md. Stage4 follows this task.

### Issue9: independently named constituents of one native composite

Status: **adopted-later**, after0.5.0/before0.6.0. Initial aligned multiline
formula with independently named/numbered/referenced rows in one native subtree.
No composition syntax/algorithm chosen; subfigures/subtables future candidates.
Single-object block NAME references now belong to13;13 does not close9.
https://github.com/ren-lingyu/org-texmacs/issues/9
https://github.com/ren-lingyu/org-texmacs/issues/13

### v0.5.0 release readiness — version and documentation/comments

Current primary goal:0.5.0 version declarations plus README/support/examples,
release notes/since0.4.0 migration and relevant source comments/docstrings.
Per-commit full nix flake check is normal workflow, not an independent release
blocking item. Representative combined documents deferred to final optional user
decision (whether/format/integration, e.g.flake check or nix run), no mandatory
fixture/check/app work adopted. Authoritative scope: memory/release-0.5.0.md top.
Completed features stay complete; native Chinese fonts and PS route stay removed.
Issue9/7 remain later/deferred; no new source edit/test/tag/publication authority.

Earlier adoption/delivery progression below is historical, not additional pending
P0/P1/P2 work; current scope above takes precedence.


Status: Issue10 and Issue11 implementation/automated acceptance/user delivery
complete. Other release requirements **adopted-later**.
Earlier nine-item readiness plus the new required Issue13 gate, limits/decisions:
memory/release-0.5.0.md. Required P0: #10 inline-footnote STM, #11 equation
block/paragraph discrepancy resolution, prior block-mapping regression (confirm
original fixture). P1 originally included PDF annotations, Chinese fonts and
STM font-lock; user now removes the reproduced native Chinese-font issue from
active backlog/pre0.5.0 blockers. No native-font fix/configuration task remains.
Other implementation remains conditional, configuration or evidenced deferral permitted. P2 representative combined documents, complete locked-flake
tests/native/PDF/compile/lint and0.5.0 metadata/docs/migration/notes.
Investigation results: memory/release-0.5.0-investigation.md. #10 gap confirmed,
#11 concat/native reload cause isolated, links share native/config absence,
Earlier CJK missing-font control is superseded by native override reproduction;
user has removed this external issue from project backlog. STM font-lock bounded
investigation now complete: lexical colors reusable, naive integration property/
stale-range/soft-error/config gaps and64KiB scan~8s in the original prototype.
User-selected default-on/internal-variable Scheme presentation now implemented
and user-committed,11focused/451core/full compile/lint accepted. Exact delivery
verified; GUI acceptance pending, dense1MiB re-fontify~0.489s explicit. Current implementation:
memory/font-lock-implementation.md; investigation: memory/font-lock-investigation.md.
User selected final Issue11 implementation contract
in memory/issue-11-implementation.md: bare lifting, explicit known-display mixed
rejection, leading-list exception; no automatic splitting. Final14/14focused,
9/9real and430/430core pass, including strict compile/lint/full applicable flake
checks. Seven stale expectations migrated; user committed one coherent fix with
Closes:#11. Exact parent/three changed paths/all25input hashes/full draft message
verified; at that delivery index was empty with only user flake mirror unstaged.
Remote#11 verified closed/completed on2026-10-16.
Issue10 adopted contract implemented: memory/issue-10-plan.md. Final46focused/9real/
437core/full compile/lint pass,25final identities and5file reconstruction verified.
User committed exactly5task paths as one feat(document) delivery with Closes:#10.
Parent=Issue11 baseline, all25committed hashes/full approved message verified.
Index empty, existing user flake unstaged; remote#10 verified closed/completed
on2026-10-16. Remote timestamps/sources: memory/evidence.md.
No external writes. User-selected PDF-link consumer repair is now locally
implemented, accepted and user-committed: synchronous layout
before both prints, native annotations restored,2new ERT/README synchronized.
36focused/9real/439core/full strict compile/lint pass; see
memory/pdf-links-investigation.md. User-committed3file delivery now verified:
exact parent/paths/all25input hashes/full patch/full reviewed message. User now
selects supplementary adjacent tests/manual-check instructions; no business
repair or extra release scope adopted.
Supplementary12PDF matrix found stable TOC/page/reference behavior and one
separate gap: first-use footnote annotation points to absent /label6 in every
direct/reload2/reload6 PDF; repeated-note target remains valid. Cause, native
responsibility and release impact initially unestablished. Subsequent20native
controls reproduce without package code, so package wrapper not a necessary
cause. User's native interactive reproduction and supplied PDF destination
inspection now corroborate this beyond headless controls. Exact native
binding/PDF failure and release impact remain unresolved.
Retain bounded follow-up
candidate, not an adopted repair; memory/pdf-adjacent-checks.md.
Adopted priority11->10->PDF links; Chinese fonts were postponed and are now
removed as an external native issue by user decision; font-lock later.
No release/version authority. #9 adopted-later after
0.5.0 before0.6.0 for composite constituents only;13 owns single-object names.
#7 deferred and not a0.5.0 blocker. Earlier native footnote
placement/page-break concerns excluded absent actionable package regression.


### Completed local Issue #4 and Issue #8 deliveries; remote tracking distinct

Selected A+B implementation complete, both separately user-committed. Exact A
three-file blobs, B parent/path set/all25final input blobs and messages verified.
A fixes quote uniformly to quotation, retaining bounded center/code/list behavior.
B adds at most one complete plain<l>/<c>/<r> format row anywhere; duplicates,
partial/mixed/width declarations reject, with existing special-column/formula/group
limits and source/provenance ownership preserved. Seven maintained regressions;
23focused/413core/9real/native10/strict compilation/lint pass in locked x86_64-linux.
Separate A/B patches and committed delivery verified; ordinary index empty,
only user flake change remains unstaged. A Refs:#4, B Closes:#8.
Full contract/evidence/archive in memory/block-table-implementation.md/current.md.

Issue4 remaining date repair/native audit now implemented and fully locally
validated; date A and audit B separately user-committed and identity verified.
Local delivery complete; connector now verifies Issue4 closed/completed,
publication refs unverified. Complete
raw timestamp literal, private captured advice helper, bounded tag audit and
native style limits documented;423core/37focused/9real/full compile/lint pass.
Seven date tests replace one rejection, four audit PDF tests added. See
memory/issue-4-closure.md. Sequential deliveries verified: B parent=A, two paths,
all25accepted blobs/full Closes:#4 message match; ordinary index empty, only user
flake mirror dirty. No external closure performed.
B independently tracked by closed/completed Issue8:
https://github.com/ren-lingyu/org-texmacs/issues/8.
GitHub read confirms closure. Latest #4 scope comment excludes completed #8
from remaining work (issuecomment-6191090701); table/caption audit still allowed,
NAME deferred. User-authorized followup issuecomment-6191193468 posted and
re-fetched, clarifying quotation repair also complete; tracking gap resolved.
Issue7 remains accepted motivation without async implementation selected.

### Completed selected Issue #6: private temporary-buffer cleanup

User selected reviewed lifetime-only repair and continuous GAW updates. Root
composition/INCLUDE capture/bibliography discovery all confirmed with runtime
kill-entry danger-state assertions. Three bounded unwind-protect repairs and
five maintained regressions implemented. User confirms no-INCLUDE no-popup but
reports INCLUDE configuration error; reproduced with source-local with-toc=nil.
Configuration guard now source-anchored, five maintained tests and exact user
fixture's8native tm/PDF outputs pass. Revised406core/9real/full Nix compile/lint
pass; user confirms revised interactive behavior meets expectations and committed
exactly three accepted paths. Committed blobs/diff/message match reviewed candidate,
including Closes: #6. Remote state unverified; no further Issue6 work selected.
Earlier405core gate covers previous candidate only. No new public
API, INCLUDE mapping, rendering or output policy change. Current details and
authorization in memory/current.md; original review extracted separately.
Tracking https://github.com/ren-lingyu/org-texmacs/issues/6, no external writes.

### Completed selected Issue #5: case-insensitive Org TeXmacs wrappers

User selected source/fragment/doc/test changes and GAW
maintenance. The adopted boundary is Org wrapper names only, preserving raw
AST/source/STM and intentional native/inline tag case sensitivity. Shared block
predicate and fragment exclusion synchronized; explicit internal dependency added.
Five maintained ERT cover162marker/name cases, native output, fragment exclusion,
preprocessing and bibliography shielding.114focused/9real/401core/complete Nix
strict compilation/lint pass; user committed exactly four accepted paths. Committed
blobs/diff match validated/reviewed candidate; message has Closes: #5 with explicit
user closure intent. No further implementation selected; remote state unverified.
Exact scope/authorization/status in memory/current.md. Issue association
https://github.com/ren-lingyu/org-texmacs/issues/5 supplied by user; public page
fetch failed, no remote state/content claim or external write selected.

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

### Export responsiveness during synchronous operation

Status: **deferred-candidate**, development motivation explicitly user-accepted;
concrete design and implementation remain unselected.

Tracked by open [Issue #7: Support nonblocking Org-to-TeXmacs exports](https://github.com/ren-lingyu/org-texmacs/issues/7),
created at user's request after checking existing issues1–6. Proposal covers
frontend buffer/tm/PDF responsiveness, existing synchronous APIs, source/dependency
guards, ownership/error/cancel cleanup and shared worker coexistence. Includes
measured motivation and distinguishes failed large explicit exports from normal
frontend256KiB rejection. Implementation route/parallelism degree/job contracts
remain design questions; no business-code implementation selected by publication.

User considers current static investigation and byte-step measurements sufficient
to motivate developing parallel/nonblocking export. Near-linear observed scaling
still gives perceptible blocking and tens-of-seconds waits for this math workload.
Do not require more profiling merely to justify that motivation. Separate allowing
editing during export from multiple simultaneous native conversions; execution
route/parallelism degree/cancellation/stale-source policy remain design decisions.
This acceptance does not authorize immediate business edits or new tests.

After accepting Issue6 interactive behavior, user reported a slight "卡手" feeling
during "非并行导出" and asked to record it separately after preparing the current
commit. This is a user-reported responsiveness observation, not a measured
performance regression. User clarified symptom means perceptible blocking after
invoking export. Subsequent selected batch stage measurements characterize fixed
realworld input below; no direct key-latency trace in user interactive Emacs.

Keep separate from committed Issue6 correctness fix. User subsequently selected
read-only nonblocking-export feasibility investigation; completed findings in
memory/nonblocking-export-investigation.md. Feasible, prototype relatively small,
reliable compatibility medium to high effort. Same-process cooperative threads,
callback worker jobs and child Emacs compared; no route adopted. Dynamic busy
binding is not a cross-thread mutex; child configuration/hooks/DB portability and
long-lived source guards are important boundaries. No benchmark/prototype/code
change or async/parallel implementation selected during static phase. Subsequent
user-authorized independent flake matrix completes96native exports over1/2/4/8x
realworld math, direct/single-INCLUDE, tm/PDF, cold/warm. Results extracted in
memory/export-timing-results.md: warm wait-path shares89.8–95.8%, no measured GC,
STM requests3–24 at~50ms each; INCLUDE overhead small. Request completion waits
on a different process from socket client; polling/wakeup investigation is next
candidate, not proven fix or selected implementation. Request-latency isolation
remains optional optimization investigation, not prerequisite to accepting the
nonblocking development motivation above. No further
benchmark/prototype/code work authorized merely by this candidate.
User later separately selected and authorized larger no-INCLUDE measurements:
memory/large-document-timing.md.16outcomes,10successes/4standard256KiB budget
rejections/2explicit-source native errors.1MiB explicit tm/PDF~29/31s succeed;
4MiB reaches~116–118s then final serialize/render wait fails at~10s/defaultdeadline,
after1920sequentialSTM parses. Source guards preserved. Byte growth also increases
math requests; no prose-size isolation. Optimization, timeout/limit policy and
nonblocking implementation remain unselected; these results add a large native
response boundary to any eventual design, not an automatic demand to lift limits.

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

Status: **re-adoption-required** for general editing assistance. Bounded STM
font-lock is delivered and GUI basic usability user-accepted; detailed navigation,
third-party interaction and large-input cost remain explicit. User now separately
adopts texmacs-block Scheme source editing and block-local indentation, with
org-texmacs-edit-mode public choice (scheme-mode default, optional user-installed
scheme-ts-mode/grammar). Candidate implemented and verified:30focused/478fullERT, fixed extension
integration, strict compile/lint/full flake pass; user-committed; exact delivery verified.
No Babel, paragraph editing, preview UX or broader Scheme execution adopted.
No additional release gate inferred. See memory/block-editing-implementation.md,
memory/font-lock-implementation.md and memory/release-0.5.0.md.

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
