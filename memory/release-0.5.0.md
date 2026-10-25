# v0.5.0 release readiness

## Current reconciliation after source/package/test refactoring

Read-only review finds old mandatory feature work still delivered, with retained
regressions in split suites and all actual versions0.5.0 (header plus package
version/melpaVersion). No new functional release blocker identified; this is not
fresh runtime validation. Current source/package/test wiring is summarized in
current.md; ordinary project was clean at review intake. Previous documentation completion was
valid at its delivered baseline. User subsequently selects README synchronization
strictly against HEAD, without extra release-plan descriptions. Delivered README-only
change replaces packages.default/#default with named org-texmacs/emacs outputs,
removes Guile-driver claim, documents explicit package/test composition, two PDF
leaves/aggregates, logs/name output/failure checks and treefmt. Existing correct
source/straight lisp paths retained. Source/manifests/lock/drivers and complete
README diff reviewed; whitespace clean. No runtime tests/builds/formatting/network,
agent project staging/commit or extra release-plan edits. User staged and committed
exactly README; delivery verification matches expected parent, complete patch and
message below. Project index/worktree clean. Documentation sync complete.
Delivered message, also in tmp/commit.md: docs(readme): describe current Nix packages and
test layout. Full-index binary patch SHA256
23549812382c7c3519a5573066fad266ded887c26915073987bc2e127eceafa2; message SHA256
ef50036b272cf9a193a773889c218fea2bc1387309830a767c8aa6d63d7edf10.
No project commit executed by agent; no runtime rerun for delivery verification.

User explicitly TENTATIVELY decides Issue14 does not block0.5.0; revisable scope,
not permanent deferral or implementation authorization. Metadata experiments are
not production support. Representative combined documents remain optional at the
final decision, and no additional release-only full-check gate is added. Fonts,
PS route and Issues9/7 retain removed/later scope. Next remaining preparation:
optional document decision; tag/
publication are separate user-controlled actions, not agent-selected mutations.
No builds/tests/network; subsequent ordinary edits are limited to README.

## Version, documentation and comments: committed and verified

User supersedes the earlier three-gate reconciliation. Current primary goal is
version metadata and documentation/comments finalization:

- Package header and Nix package declarations now both read0.5.0 in the delivered
  commit; no tag/publication. Both were0.4.0 at clean main75762b0 task baseline.
- README usage/examples/support and release notes consolidated; since0.4.0 migration
  includes public API, dispatcher menu and preprocessing changes. State supported
  subset, stock vs patched caption-note AST input and known native layout limits.
- Relevant source commentary/docstrings reviewed and corrected against delivered code,
  ownership/reference/export contracts, options and current supported behavior.

User explicitly selected this work. Six-path candidate: README.org, flake.nix,
org-texmacs.el, org-texmacs-input.el, org-texmacs-document.el and org-texmacs-session.el.
README adds version overview/since0.4.0 API migration, menu/preprocessing defaults,
stock-vs-test-patched Org and native caption-note limits. Correct stale introductory
fontification exclusion, eight core options/edit-mode example, wrapper/name support,
region bibliography discovery and missing serialization/rendering errors. Source
edits are version metadata and commentary/docstrings only: bibliography native
duplicates, supported captions/blocks/notes/alignment, body-STM preflight guarantee,
and disposable-buffer PDF destination repair. No runtime branch/API/lock/test change.

32tracked inputs copied byte-identically to ignored tmp/release-0.5.0; no root
flake workaround remains at this task's clean baseline. User authorizes repeated
root commands `timeout 600s nix flake check --no-write-lock-file path:./tmp/release-0.5.0`
and `timeout 120s nix build --no-link --no-write-lock-file path:./tmp/release-0.5.0#default`,
plus reading results; network/store/cache/isolated logs/tests effects disclosed.
First full check stopped on a newly added84-column docstring. Rewrapped locally,
synchronized all32inputs and reran the same authorized command. Final full flake
check exit0:553/553stock ERT(379.866632s),6/6patched Org(2.836266s), strict
compilation/package-lint. Default no-link package build exit0. All32root/copy input
hashes still match accepted manifest; whitespace clean. Subsequent user-authorized staging includes exactly these six
paths; every staged blob matches the validated32input manifest.
Validated only current x86_64-linux locked environment, no wider platform claim.
No new representative document/check/app. This is actual-change validation, not an added release gate.
No new original archive needed: ordinary project history will preserve the authored
docs and prior native evidence is already retained; no skill changes. User has committed the exact candidate. Read-only verification confirms
one expected statement-caption parent, exact six-path full-index binary patch,
complete approved message and all32accepted input blobs (including unchanged lock).
Project index/worktree clean. No runtime rerun solely for commit verification.
Current project-parent association establishes delivery equivalence, not original
uncommitted runtime acceptance. Version/docs work complete; next user selects
final optional representative documents or explicit tag/publication actions.
Split unnecessary: versions, release/migration docs and corrected contracts form
one release-preparation change. Draft tmp/commit.md: chore(release): prepare
0.5.0 metadata and documentation; no issue-closing/breaking footer. Exact staged
full-index binary patch SHA2565e318864a1cd1537b423f96682a1aab421141985b57dfdfd1316a9b416bbf729;
message SHA25669f4fc65e9b3f59c49e6f1511faab608fd609f7ea478d5d20ae4980fda61f827.
The patch/message hashes above identify both staged and delivered bytes.
No unstaged project changes. Runtime tests not repeated for staging or commit alone.

Full nix flake check is already part of each commit workflow. It is not a separate
pre-release blocking task and must not be repeated solely to satisfy a second
release gate. Appropriate checks for actual edits and normal commit readiness
still apply; this decision does not waive failing tests or authorize commands.
Latest accepted553stock/6patched/full checks retain their actual baseline scope.

Representative combined mathematical documents are postponed to a final optional
decision: user will decide whether to do them and their format/integration, e.g.
nix flake check or nix run. No mandatory representative-document gate, fixed input
format, example fixture layout or new check/app has been adopted. Do not begin
that work as an implicit dependency of version/docs finalization.

Completed feature deliveries remain complete; native Chinese-font issue and
PS->PDF route remain removed/nonblocking. Issue9 stays after0.5.0/before0.6.0,
Issue7 deferred. Tag/publication remains a later explicit release action. Older
P0/P1/P2 adoption wording below is historical where superseded by this section.

## Chinese font issue removed from release blockers

User accepts reproduced font mixing as native TeXmacs behavior outside
org-texmacs responsibility, and explicitly removes it from active backlog and
pre0.5.0 blocking requirements. No font fix, mitigation, default policy or font
configuration/documentation is required to close this gate. This is scope closure,
not a claim that native font mixing is fixed or all Chinese fonts are correct.
Evidence retained in block-font-investigation.md and
archive/2026-10-18T13-47-27Z--75762b0/MANIFEST.md. Remaining release gates unchanged.

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
Native font follow-up was subsequently reproduced and removed from project
blockers by user. No font fix/configuration/docs requirement remains. Do not claim
global font correctness or0.5.0 readiness.

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

## Issue13 stage4 delivered; issue closed

Seven-file NAME/reference candidate passes57focused/539fullERT/patched5/strict
compile/lint/full flake/default build under pinned isolated environment. This
completes fourth-stage functional acceptance; exact user delivery verified.
Issue13 independently confirmed closed/completed. This is not release readiness. Preserve remaining independent
release gates below. Exact scope/identities: memory/issue-13-stage4.md.

## Current scope amendment: required Issue13, refocused later Issue9

Stage3 figure/table candidate implemented; parser/native gate,44focused,
full flake and no-link build pass; exact user-committed delivery verified. Adopted grammar/caption/source-proof
revisions and actual Org note boundary limitation: memory/issue-13-stage3.md.
No release or stage4 NAME claim.

User selected caption anonymous inline-footnote AST compatibility before stage4.
AST compatibility delivered and exact user commit verified: focused4/patched5/full flake/
default build pass. Stock production Org and isolated patched tests. AST conversion,
not native caption-footnote PDF layout, is acceptance; native defects documented,
no automatic split-anchor semantics. Current implementation/validation status:
caption-inline-footnotes.md. No additional mandatory release gate inferred.

User adopted2026-10-17 a mandatory Issue13 usable mathematical special-block
subset for0.5.0, not an optional extension. Stage1 recursion/private handlers and
formal statements now implemented/accepted/user-committed, exact delivery verified:
17focused/495fullERT/strict package compile/lint/full flake/build pass; generic
native16type/PDF and theorem/proof tm reload accepted. Stage3 delivery and accepted stage4 NAME/weak-anchor candidate are above; no release action. Full stage1
contract, candidate identities and limits: memory/issue-13-stage1.md.
Full source semantics and validation boundaries: memory/special-block-plan.md.
Stage2 equation/equation* candidate implemented with four corrections;
focused29/29/native generic/article/PDF/readback/reload, full flake ERT/compile/
lint and no-link build pass; exact user-committed delivery verified. memory/issue-13-stage2.md holds the
complete extracted contract and requirements, without relying on mutable INBOX.
Stage1's495ERT is not stage2 or final release evidence. All other gates unchanged.
This adds one required scope gate, not duplicated numbered legacy items:
private recursive handler/preparation/provenance path, formal statements,
single-expression equation/equation*, explicit figure/table wrappers and bounded
single-object NAME/[[name]] semantics. Native counters and object-specific label
placement required. Stage3 empty-caption/starred native/PDF evidence is above;
weak plain-STM anchors remain unverified and unimplemented.

Issue9 remains after0.5.0/before0.6.0, now multiple independently named constituents
inside one composite native structure, initially aligned rows with independent
numbering/references. It does not gate general single-object references in13;
shipping13 does not close9. No float/configuration/public handler API selected.

All other existing gates retain their status: original block-fixture linkage,
native first-note limit/release-impact assessment (Chinese fonts explicitly removed
by later user decision),
representative mathematical documents, final stabilized flake/native/PDF gate,
version/README/migration/notes. Existing font-lock/editing/Issue12 delivery records
remain valid; stage1 does not complete13 or make v0.5.0 ready. In particular
old restricted-BibTeX notes below describe the pre-Issue12 review, not current
bibliography behavior (see memory/issue-12-review.md).

Prior readiness/investigation sections below retain their historical scope and
observations; current scope uses this amendment and the concentrated design.
New INBOX replaces the old working handoff, not the preserved historical evidence.
Initial scope adoption was memory-only; current stage2 source implementation is
accepted locally as above. INBOX and existing archives remain unchanged.
No archive/config/skill mutation needed; design and source provenance fully
extracted in memory/special-block-plan.md. No project-parent inferred from main.

## Earlier gate summary after committed deliveries (before Issue13 adoption)

Read-only readiness reconciliation on2026-10-16; no new implementation or release
authority. Then-current INBOX had historical Open statuses; use the
committed delivery records for current local status. Still planned/not accepted.

- Items1/2: Issue10 inline-footnote STM and Issue11 bare display rendering are
  implemented, validated, user-committed and previously verified closed.
- Item3: quotation/block regressions exist and pass, but identity of the original
  INBOX block-mapping failure is still not linked explicitly to its retained test.
  This is a remaining fixture/acceptance check, not a demonstrated unfixed bug.
- Item4: package hyperlink sequencing repair committed; supplementary ERT delivery
  committed and25input hashes verified. Latest6focused/440core/full strict compile/
  lint acceptance transfers by bytes.12PDF target/pagination comparisons pass.
  Separate first-note forward gap reproduces in20native controls and user's
  native interactive .tm/PDF; retain/document native limitation and assess release
  impact, no package repair adopted. Full findings: memory/pdf-adjacent-checks.md.
- Former Item5: user removed the reproduced native Chinese-font issue from
  project backlog/pre0.5.0 blockers. No package repair or further font task required;
  retained evidence: block-font-investigation.md. Earlier pending status is superseded.
- Item6: bounded STM font-lock investigation complete (12/12 observational probes,
  locked Emacs31.1/Org9.8.10). Lexical highlighting feasible; naive integration
  has Org-property/stale-range/soft-error/config gaps and64KiB full scan~8s.
  Default-on font-lock now implemented/automatically accepted/user-committed:
  internal nil default/local override, no Customize/dedicated command;
  Scheme syntax properties, local context ownership and Org restoration.
  Final11focused/451core/full compile/lint pass,27candidate inputs verified.
  Dense1MiB full ensure17.4s/local re-fontify0.489s remains a measured limitation.
  Exact parent/5paths/patch/message and26committed source hashes verified;
  index empty, original flake overlay unstaged. Prior acceptance transfers by
  exact bytes. User now reports GUI font-lock basically usable: basic presentation
  user-accepted; detailed folding/third-party/navigation remains unverified.
  Block source-edit/indentation separately authorized, candidate implemented with
  custom Scheme-mode selection;30focused/478fullERT, fixed extension integration,
  strict compile/lint/full flake pass; user-committed; exact delivery verified. No added release gate
  inferred. See memory/block-editing-implementation.md.
  Contract/final evidence: memory/font-lock-implementation.md.
- Former Item7: representative combined documents are now a final optional user
  decision (whether/format, possibly flake check/nix run), not a release blocker.
- Former Item8: normal per-commit full nix flake check continues; user explicitly
  removes a separate release-only complete-check blocker. Existing test evidence
  retains its tested baseline/environment scope, no timestamp-only rerun required.
- Item9: actual package/Nix sources still0.4.0; update0.5.0 metadata, README support/
  examples/migration and release notes after scope stabilizes. Include native PDF
  first-note limit and current restricted BibTeX grammar/discovery behavior.

New bibliography finding: org-organize-mode expands discovery from refs.bib to
3personal sources including @online and template month=MM, rejected by current
restricted grammar. User reports these files work in ox-latex. Compatibility,
collection-policy and file-aware diagnostics remain unadopted follow-ups; don't
silently make full BibLaTeX support a pre0.5.0 requirement or rewrite personal
library. Native first-note engine repair likewise not newly adopted.

#9 stays after0.5.0/before0.6.0; #7 nonblocking export stays deferred. No new raw
archive for this reconciliation: existing implementation/test/native archives
and current extracted release gate suffice. INBOX/project/version/user flake
unchanged. Next implementation choice belongs to user; no task auto-selected.

## Adopted objective and authority

User supplied INBOX.md "v0.5.0 Release Readiness" and selected read-only review
and GAW extraction on2026-10-16. Status: planned, not release-ready. Aim: first
practically usable Org-first mathematical authoring release with embedded native
STM and complete .tm/PDF export within a documented, tested supported subset.
Not complete Org exporter parity. Existing canonical source, AST-first, STM
opacity, coherent ownership/snapshot/provenance and native consumer boundaries
remain constraints. This selects release priorities, not immediate implementation.
Initial review authorized memory only. User subsequently selected issue retry and
local isolated investigation/tests; findings in memory/release-0.5.0-investigation.md.
No project/INBOX/version edits, ordinary staging, dependency updates, tags/release
or external writes. Locked offline flake probes are now complete.

Source INBOX is ignored/untracked,8020bytes, SHA256
`a32561c1878fa48629554771ec3af1114560cb939ed228f391fd4cc9e75f2e68`.
It names baseline main@8a90b4c; read-only HEAD confirms full revision
`8a90b4c0f832204ffe6beab00cbea122bcf9de5e`. Ordinary index empty; only existing
user flake.nix mirror dirty, preserve/exclude it. This is the code review context,
not a new release candidate acceptance. Issue URLs below come from INBOX;
initial web lookups failed with Cache miss; subsequent connector reads verify
#10/#11/#9/#7 open and#4 closed/completed, including all3 #4 scope comments.

## P0: required completion

1. **#10 inline-footnote STM**, adopted-later required implementation.
   https://github.com/ren-lingyu/org-texmacs/issues/10
   Discover and lower STM inside anonymous [fn::...] and named [fn:name:...]
   inline definitions. Preserve separate footnote definitions, repeated references,
   source ownership, island boundaries and provenance. Reuse fragment/footnote
   infrastructure; no unrelated object discovery. Structural regressions plus
   native PDF verification required. Current static source shows paragraph-context
   admission in fragment-scan-paragraph; preparation whitespace recursion handles
   footnote objects but does not register their inline strings as islands; restored
   synthetic inline-note paragraphs deliberately have no fragment spans. This is
   a discovery/preparation/owned-mapping concern, not a request for pure lowering
   to read buffers or the native worker to reinterpret Org. No runtime reproduction
   or final implementation mechanism chosen this turn.
2. **#11 display-equation discrepancy**, adopted-later required investigation
   and resolution. https://github.com/ren-lingyu/org-texmacs/issues/11
   User reports same standalone STM equation aligns/numbers differently in PDF
   from TeXmacs special block versus paragraph fragment; serialized .tm appears
   equivalent. That equivalence and the cause remain unverified observations.
   Compare exact owned body/paragraph structure, STM source-semantic paths,
   encoded native trees, style/initial and native context; compare direct PDF
   with native load/export of saved .tm when applicable. Cover standalone display
   environments and ordinary mixed paragraphs. Fix package lowering if confirmed;
   if native/config dependent, establish an evidenced resolution and clear boundary.
   No preselected display-tag list, generic tree normalization or special-case fix.
   Production direct PDF installs fields in a private native buffer and uses
   update/print/update/print; serialization independently wraps native fields.
   Native .tm reload is a diagnostic comparison, not an adopted textual conversion
   intermediary. Preserve AST-first, opaque STM, provenance and paragraph semantics.
3. **Previously fixed block mapping**, adopted-later release regression.
   INBOX reports fixed; identify exact original failure/fixture before declaring
   release acceptance. Existing quotation repair and native PDF regressions are
   available evidence, but INBOX does not explicitly equate its original failure
   to that quote-block defect. Confirm identity, fragment/block ownership, intended
   source->STM mapping and provenance, retain/add focused regression. No redesign
   unless a concrete additional defect appears.

## P1: bounded investigation required, implementation conditional

4. **PDF hyperlinks**: earlier observation of hlink nodes without expected
   clickable PDF annotations is reported, not reproduced here. Compare direct PDF,
   serialized .tm native reload/export and independent native reference under
   matched style/config. Inspect actual PDF annotations; rendered/extracted text
   or hlink readback alone does not establish clickability. Attribute package,
   native engine or configuration cause. Fix actionable package defects, otherwise
   document verified native limit/configuration. No independent PDF link system.
6. **STM font-lock**: feasibility investigation adopted; implementation conditional
   on acceptable semantics/compatibility/maintenance. Paragraph STM and TeXmacs
   special blocks; inspect Org native fontification, island boundaries, edits and
   ordinary markup interactions. Prefer existing facilities, avoid independent
   parser/editor framework. If infeasible/costly, record reason and defer explicitly.
   This narrowly re-adopts investigation from former AUTHORING-01 ideas, not
   general Scheme editing, live preview or full authoring assistance.

## Earlier P2 proposal (superseded by current user scope above)

7. Representative real mathematical Org document(s) must combine supported inline
   STM/special blocks/equations/footnotes/internal references, citations+bibliography
   where configured, tables, metadata, style/initial and repeated .tm/PDF exports.
   Assess practical usability, distinguish structural correctness from native
   visual behavior. Existing tmp/realworld_test examples may be candidates, not
   automatically sufficient coverage or permission to read large/binary outputs.
8. Complete maintained ERT, native integration, PDF semantic regressions, strict
   byte compilation, package-lint and full nix flake check. Isolated checks must
   use locked flake rather than system Emacs, with separately authorized exact
   commands/timeouts/network/store/cache/result access. Review failures/limits;
   only claim tested Emacs/Org/TeXmacs/platform versions. Prior423core/37focused/
   9real/strict compile/lint gate belongs to date/audit baseline, not new release
   validation. Full minimum Org9.8 behavior and other platforms remain unproven.
9. After scope stabilizes, update all actual package/Nix version sources to0.5.0,
   prepare notes and README examples/support/error/migration boundaries. Current
   read-only sources org-texmacs.el and flake.nix still declare0.4.0. Include inline
   footnote STM and equation outcome plus hyperlinks/fonts/font-lock fixes,
   configuration or explicit deferral. Cover since-v0.4.0 breaking API/menu and
   preprocessing changes already recorded, not just new P0 fixes. Describe first
   practically usable supported subset, without claiming full Org export support.
   Metadata/tag/release operations have not been selected/executed in this review.

## Outside this gate

- #9 independently named constituents within one composite native structure,
  initially separately numbered/referenced aligned rows (single objects belong to13):
  https://github.com/ren-lingyu/org-texmacs/issues/9
  adopted-later between v0.5.0 and v0.6.0, separate development after this release.
- #7 nonblocking exports remains deferred, not assigned to0.5.0. Existing synchronous
  command blocking, size budgets and worker timeout boundaries alone do not block
  this release. No parallel execution route or limit increase adopted.
- GUI preview, incremental sync, complete Org semantics, general STM authoring and
  unadopted advanced Org structures excluded. Earlier footnote-to-physical-bottom
  placement and heading/page-break observations are not blockers unless new evidence
  identifies an actionable package regression.

## Review, readiness and next action

Plan is coherent and appropriately separates mandatory fixes, investigations and
release acceptance. #10/#11 must be resolved with regressions; block fix confirmed;
all three P1 investigations must have evidenced outcomes; representative documents
and complete maintained checks pass; native/unsupported limits documented.
P1 completion may mean a fix, tested configuration, or justified deferral, not
mandatory implementation. #11 stays a required resolution, not silently downgraded
by that P1 flexibility. No design picked before its diagnosis.

Isolated investigation now reproduces #10/#11 and establishes bounded P1 controls;
see investigation record for evidence/limits. User now selected Issue11 final
implementation plan, now locally implemented/validated and user-committed:
memory/issue-11-implementation.md; priority11->10->PDF links. Final430core/14focused/
9real/full compile/lint pass. Delivery exact parent/paths/all25input hashes/message
verified; local delivery complete, remote Issue11 verified closed/completed
on2026-10-16.
Issue10 final user-selected plan now implemented/accepted/user-committed:
memory/issue-10-plan.md;46focused/9real/437core/strictcompile/lint/full gate pass.
Delivery parent=Issue11 baseline,5changed paths/all25committed input hashes/full
reviewed message verified; index empty, user flake unstaged. Remote#10 verified
closed/completed on2026-10-16; timestamps/sources: memory/evidence.md. This is not full release acceptance.
Chinese font investigation was postponed, then reproduced natively and removed
from project backlog/blockers by user; font-lock later. Original source-mapping
fixture linkage for item3 remains distinct. Then P1 conclusions, real-document
and complete gate, metadata/docs. No further user answer needed merely to record
this plan. Remote issue facts can be checked when available without inventing them.

Initial review archive assessment: active plan, no retirement, unique experiment or irreplaceable
raw failure evidence. Full operational requirements/review/limits extracted here
and routed through current/goals/backlog/project/evidence; no original-byte archive
needed. INBOX and existing archives unchanged. Planning checkpoint has no inferred
project parent; explicitly named baseline is review context, not new test provenance.
Subsequent experiments now have independently valuable raw evidence selected
separately, without retiring or archiving this active INBOX plan.

## PDF hyperlink outcome after Issue10/11

User selected item4. A package native-consumer sequencing defect is now repaired
and automatically accepted: update-current-buffer alone invalidates; actual
update-forced before each existing print preserves native link state for PDF
annotations. Baseline/native-only force/final matrices establish causality,
final12PDFs contain exact external URI and valid internal targets. Two maintained
regressions cover cross-page jumps, released source/repeats/reload and both new
layout failure phases with cleanup/retry/public-session isolation. README updated.
36focused/9real/439core/full7checks/strict compilation/lint pass, x86_64-linux only.
Three-file delivery user-committed and exact inputs/diff/message verified; no
issue association or release write. Full contract
and immutable text evidence: memory/pdf-links-investigation.md. Item4 package
repair/automatic verification is complete; this is not complete release readiness.
Chinese font issue is now removed from project backlog/release blockers by user;
font-lock and representative combined workflows and release metadata/docs/notes
retain their separately recorded statuses.
