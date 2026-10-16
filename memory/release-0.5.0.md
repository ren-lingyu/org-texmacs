# v0.5.0 release readiness

## Current gate summary after committed deliveries

Read-only readiness reconciliation on2026-10-16; no new implementation or release
authority. Original INBOX is unchanged and has historical Open statuses; use the
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
- Item5: Chinese fonts only postponed in ordering, not explicitly removed from
  pre0.5.0 gate. Missing-font baseline exists; positive native CJK configuration/
  original inconsistency and practical conclusion still needed. Bounded fix,
  tested configuration or evidence-based explicit deferral can close it.
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
  strict compile/lint/full flake pass; not staged/committed. No added release gate
  inferred. See memory/block-editing-implementation.md.
  Contract/final evidence: memory/font-lock-implementation.md.
- Item7: representative mathematical full-document .tm/PDF workflow acceptance
  combining supported features still pending; short combined link fixtures and
  isolated original math regressions are useful but not whole release acceptance.
- Item8: latest test delivery accepted6focused/440core/full compile/lint, prior
  production repair9real extensions. Final stabilized release candidate requires
  complete authorized locked-flake/native/PDF gates; don't rerun merely to claim
  a fresh timestamp before remaining changes exist. Other-version/platform limits
  remain explicit.
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
5. **Chinese font consistency**: reproduce reported inconsistent font selection/
   glyph sizing in release environment. Separate style, initial environment,
   installed fonts, native fallback and package encoding/rendering effects. Bounded
   package fix or evidenced practical configuration; no generic CJK/font redesign.
   Neither causality nor a universal font guarantee established by earlier tests.
6. **STM font-lock**: feasibility investigation adopted; implementation conditional
   on acceptable semantics/compatibility/maintenance. Paragraph STM and TeXmacs
   special blocks; inspect Org native fontification, island boundaries, edits and
   ordinary markup interactions. Prefer existing facilities, avoid independent
   parser/editor framework. If infeasible/costly, record reason and defer explicitly.
   This narrowly re-adopts investigation from former AUTHORING-01 ideas, not
   general Scheme editing, live preview or full authoring assistance.

## P2: release verification and finalization

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

- #9 native substructure names/references, especially rows of multiline equations:
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
Chinese font investigation postponed; font-lock later. Original source-mapping
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
Chinese fonts remain postponed, font-lock and representative combined workflows
and release metadata/docs/notes remain separately selected work.
