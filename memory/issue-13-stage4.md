# Issue13 stage4: NAME and single-object references, delivered

## Intake, state and retention

User requested read-only review of updated project INBOX.md before implementation.
Initial reviewed source: 18366 bytes, SHA256
fb77dc04b8b4cb5aa14c7b8249f782ef80bb597d2e1df7b5be9719b2f9d51fcb.
Title: Issue #13 Stage 4: Org NAME 与单对象交叉引用. Source declares design
complete/pending implementation, baseline main@fae32879 and _agents@ebe3bad9.
Checked project HEAD and initial GAW HEAD both match the declared baselines.
The review checkpoint will advance GAW without changing ordinary project HEAD.
The reviewed guidance is a design input, not evidence of implemented/native
behavior and not authorization to modify project files or execute tests.

First-read retention assessment applied development/archive skills. No raw archive:
this memory extracts the substantive contract, concrete structures, examples,
review findings and unresolved validation. No unique experiment output/source
patch requiring original bytes was supplied. Losing exact prose would not impair
reproduction/interpretation after extraction. Mutability alone is insufficient.
Input hash binds this extraction to reviewed bytes; do not treat a later INBOX as
this version without equality. Project INBOX/source/index unchanged; original
ELPA overlay remains sole ordinary worktree change. No builds/tests/native runs.

## Adopted review supplement, current lifecycle

User appended section at INBOX.md line550, stating all four recommendations
adopted; original preceding18366bytes verified byte-identical by SHA256 above.
Updated source21282bytes SHA256
09ed92d403ffb88a0bc3fa77a05a35a619b7b75054eb40ad80c01bf595bba5cc.
No raw archive: supplement is fully distilled here with original-prefix identity;
no independent raw experimental evidence. Project/source/index unchanged.

All four concerns are addressed, no further architectural objection from static
review. Supplement takes precedence for lifecycle detail: split repeatable
validation (resolve effective targets/check ambiguity/validity, NO final random
IDs) from allocation (after effective owned AST and static native-label set are
known, use Org API once and freeze). This supersedes the earlier review's proposed
before-preflight final allocation, which was not a necessary design constraint.
Interpret earlier preflight/final identity consistency as same semantic target
relationships, not demanding final IDs during validation-only preflight. After
allocation every formal/repeated pure lower consumes the same frozen mapping.
No provisional final-ID allocation hidden in bibliography/preflight calls, no
post-freeze local reallocation; copying remaps node and link identities and direct
prepared-AST constructor obeys same lifecycle. Source-detectable rejection still
precedes body STM requests; final static collisions require real parsed islands.

Candidate collection is bounded to effective export objects: raw outer NAME only,
opaque internals, wrapper owns identity, inner body not independent, unused notes/
filtered/excluded objects omitted; caption/title/reachable-note links retained.
Strict ambiguity precedes Org target selection. Added raw fake-target, unused-note
name, filtering and nested-object regressions required.

Original NAME declaration counts/ownership evidence extends stage3 capture to
statements/equations/plain texmacs; reject duplicate/invalid metadata and truncated
NAME/owner regions, preserve scoped-reparse correspondence, ignore invalid
excluded owners. No generic source-provenance framework.
Slug explicitly binds case-fold-search nil; same per-character ASCII rule, no
underscore compression/trimming. Test nil/t ambient case and Unicode letters,
digits/confusables. Suggested implementation now meets reviewed static boundary.

Updated order:4A native placements plus Org API candidate comparisons and allocation
lifecycle design;4B validation/allocation separation, frozen map, NAME evidence,
object label lower;4C scopes/ownership/provenance/identity/native PDF regressions.
Review accepts this supplemented guidance as planning foundation. No tests,
implementation or new ordinary writes authorized. Native/pinned Org behavior
remains unverified by this static review; no further tightening proposed now.
Next: user request to plan/implement stage4 under these adopted constraints.

## Supplied intended contract

Motivation: finish required v0.5.0 Issue13 single-object identity on delivered
statements/equations/figure-table wrappers, following caption AST compatibility.
Org owns source/link semantics; org-texmacs maps identities to native trees;
TeXmacs owns counters, reference text, style/layout. Even equation*, proof and
starred figures/tables may carry label and undescribed reference; exporter does
not reject or interpret their native display value. Caption-footnote rendering
limits remain documented and do not block stage4.

Objects: equation/equation*, every built-in formal statement plus canonical
statement TYPE, statement_TYPE and direct aliases, figure/figure*, table/table*,
and plain texmacs block via bounded external weak anchor. Preserve existing
headline/CUSTOM_ID/ID/dedicated-target/naked-table behavior. Custom handlers do
not gain NAME automatically because their output has no universal insertion site.
One supported Org object has one valid NAME. Every newly supported named object
gets label even unreferenced; legacy naked-table referenced-only optimization may
remain. Any extra naked-table anchors from infrastructure unification need their
own compatibility verification and no visible numbering/layout change.

Links: [[name]] -> (reference ID); [[name][description]] -> (hlink DESC "#ID").
Both use the same target identity regardless of numbering. Same-document only,
no global org-id lookup/files/search/external resources. Use Org9.8 search-cell
APIs (org-export-search-cells, org-export-string-to-search-cell, fuzzy resolver)
and org-export-get-reference instead of growing bespoke matching/ID allocation.
Keep strict ambiguity: collect candidates using Org cells/rules/priority BEFORE
native resolver loses alternatives; identity-deduplicate candidates, count only
winning priority tier, reject actual multi-object ambiguity for used links. A
NAME/dedicated-target competition is ambiguous, not traversal/cache-order choice.
Unreferenced duplicate NAME alone does not reject. Verify whitespace/case/type
priority against locked Org, do not invent generic case folding or slug matching.
CUSTOM_ID/ID remain bounded, unique and local; no broadened resource semantics.

Use fresh conversion-private Org INFO whose parse-tree is effective owned AST;
mutable export caches/random allocation must not escape into pure lowering.
Freeze node->final label and link->target label identity mappings; no later
random allocator/fuzzy resolution/source reads. Preflight/final paths use same
assignments; AST traversal aliases must not allocate twice. Preserve coherence
across input copying and repeated pure lowering. Do not expose new public manager,
input argument, user setting, handler registry or worker protocol without need.

Final ID for NAME: org-texmacs-SLUG-ORGREFERENCE. Org supplies random suffix;
no second random generator and no cross-export byte-stability requirement.
Unnamed existing identities may omit slug. Same target stable per snapshot,
different targets unique, save/reload references valid. Slug rule is per-character
ASCII-only: A-Z lowercase, a-z/0-9 retained, every other character replaced by one
underscore. No collapsing, trimming, transliteration, normalization or truncation.
Examples eq:main -> eq_main; Thm--Main -> thm__main; A+B=C -> a_b_c;
张量范畴 -> ____. Slug is readable decoration, never source identity.
Check final full IDs against other allocations, static authored native label
strings and generated TOC/footnote/bibliography labels. Prefixes do not waive
collision checks. No source renaming or prefer-user-labels option.

## Native placement candidates, not verified facts

- Equation/equation*: (TAG (concat (label ID) ORIGINAL-STM)), label inside math
  counter scope. Original complete native expression remains intact, including
  strings/frac/concat/with and arbitrary structurally valid roots admitted by
  stage2. No new mathematical root whitelist; investigate native composition
  failure rather than silently narrowing old input contract.
- Formal statement: (TAG (document (label ID) BODY...)), inside environment.
  All16built-ins/aliases including proof; representative native theorem/lemma/
  proof and nested statement independence, existing recursive/nesting rules.
- Figure/table: (big-* BODY (surround (label ID) "" CAPTION)), including CAPTION
  "" when absent; stars retained, long/short caption-detailed retained, no new
  float-placement policy, unchanged native arity and body metadata ownership.
- Plain texmacs: (surround (label ID) "" ORIGINAL-STM), weak whole-block anchor,
  not internal native numbered-object identity. Do not inspect native object type
  or internal labels to choose insertion site, rewrite or split/reparse contents.
  Global static-label collision inventory is distinct from insertion semantics.

Wrap using existing structural/provenance packing: original STM subtree appears
once, STM/file paths remain correct. Source remains canonical, no STM/prose/text
roundtrip or native consumer reconstructing source. Reject unsupported native
placement with minimal reproduction and exact affected scope; do not improvise
semantic or native engine changes.

## Metadata, scope and acceptance

Admit exactly one nonempty valid NAME only on supported objects. Reject duplicate
NAME on one object, invalid/empty names, unsupported CAPTION/ATTR/affiliated keys,
wrapper/inner body conflicts, parser-unowned NAME and custom-handler NAME.
Retain stage3 pre-prune evidence and scoped-reparse owned rebinding; NAME and its
object must be selected together, no mappings to excluded targets. Pure lowering
consumes saved owned metadata only, never source buffer.

4A first: independent native STM controls (not exporter tests), generic/article,
consecutive equations, varied roots, numbered/starred alternation, statements and
nesting, caption/empty caption/long-short figures and tables, raw weak surround.
Distinguish valid STM, native label/reference binding, save/reopen persistence,
and usable PDF link targets. No assertion of meaningful numeric text for
unnumbered environments. Continue native calls through isolated directory flake.

4B: baseline Org comparison tests, strict fuzzy ambiguity, Org target/reference
allocation, slug/ID formatting, frozen identity resolution, metadata support,
object-specific label placements, existing reference/hlink output, global ID
collision/integrity. No new dependencies, public options/API or worker protocol.

4C: forward/back/self/multiple links; named unreferenced and unused duplicate
names; used duplicates reject; target/NAME/headline priority; Org whitespace/case;
ID/CUSTOM_ID/headline compatibility; broken/excluded links; described/undescribed;
slug collisions, ASCII/punctuation/Unicode/underscore rules; full-ID uniqueness
and native static collision; random IDs not written back or fixed in assertions;
repeat snapshot use; source/AST unchanged, no mutable INFO escape; full/subtree/
region/narrow/noexport selection; original STM/file provenance under wrappers;
metadata/ambiguity early rejection where detectable; native worker recovery;
preflight/final same IDs. Native real tm readback/PDF links/layout/reload plus
naked-table/opacity/caption/starred/counter/footnote/TOC/citation/bibliography
regressions. Focused ERT, complete locked flake/strict compile/lint/default build,
README syntax/examples/native-display and weak-anchor limitations. No commands
newly authorized by review. Assess Issue13 closure only after complete stage4
acceptance; no Issue9 closure, release claim or publication implied.

Issue9 owns multiple independent constituents inside one native composite:
aligned-row identities/counters, subfigures/subtables, shared composite modeling.
Not this stage: generalized custom-handler label protocol, raw internal identity
inference, cross-document lookup, stable cross-export IDs, label-format config,
numbering/display/layout reinterpretation or caption-footnote repair.

## Original read-only findings (now addressed by adopted supplement)

Overall design is coherent with goals. Org allocator/random suffix and labels on
all newly named objects supersede earlier provisional deterministic/ref-only
preferences in special-block-plan.md; no larger architecture redesign needed.

1. Make snapshot allocation lifecycle executable, not only a diagram. Current
   org-texmacs.el calls document-resolve at bibliography collection (~482),
   bibliography plan (~498), preflight lowering (~508), post-body plan (~528),
   and pure lowering (document.el~857). input-create (~227) copies AST again.
   Replacing allocator only inside resolver would allocate repeatedly or leave
   mappings keyed to old nodes. Originally suggested allocating once before preflight (superseded by the
   adopted validation-first/allocation-later supplement), carry
   frozen assignments through relevant consumers, remap all owned node/link keys
   on copy; direct AST input-create must establish same contract before pure
   document. Late parsed-island label conflicts must reject or use a coherent
   pre-freeze strategy, never silently reassign IDs after preflight. Distinguish
   early source checks from final static-collision checks; existing bibliography
   worker-before-preflight allowance remains.
2. Define exact semantic candidate view before Org native indexing. Existing
   resolver skips island subtrees and unused note definitions, scans reachable
   definitions and caption/title secondary AST. Register NAME on raw block's
   outer node while keeping descendants opaque. Do not pass unfiltered masked
   AST to generic Org traversal and admit fake targets/links from raw STM, unused
   notes or excluded scope. Restrict emitted eligible owners/links; inner figure/
   table-body metadata must not silently become independent identity. Use owned
   structures/adapters and Org matching, not reparsing or custom string matcher.
   Add raw fake-target, unused-note duplicate target, selected/reachable-note and
   caption-link regressions, with candidate identity deduplication per priority.
3. Slug suggested regex needs explicit ambient-case independence. Bind
   case-fold-search nil for ASCII replacement (or explicit character mapping),
   then lowercase ASCII. Test both ambient settings and Unicode confusables,
   not just Chinese. This is a static determinism concern, not a claim that a
   specific locked-runtime Unicode case has already been reproduced.
4. Extend source metadata completeness explicitly beyond old figure/table gate.
   Capture relevant original NAME occurrences before context cleanup; validate
   only retained owners, and region must contain NAME plus whole newly named
   statement/equation/raw wrapper. Do not reject invalid excluded owners, infer
   missing parser structure by text reconstruction, or just trust final :name
   after duplicate/unowned metadata was discarded. Add truncated-name/block and
   excluded-invalid cases; preserve prior body-request preflight guarantee.

PDF acceptance precision: described nonempty hlink should have a real destination;
structural reference/native binding for unnumbered targets must not accidentally
become a fixed nonempty/numeric visible-text requirement. Do not turn arbitrary
raw roots into an unbounded PDF guarantee. Native placement remains 4A evidence,
not a static review result.

External check used current upstream Org ox.el (main), not exact locked9.8.10:
https://raw.githubusercontent.com/bzg/org-mode/main/lisp/ox.el.
It corroborates cache mutation, search-cell normalization/priority and the need
to enumerate candidates first. Requested pinned raw release URL unavailable via
browser. Exact locked-version API behavior and source/native tests remain 4A/4B
acceptance work, not completed evidence. No shell network or tests run.

Current adoption and next action are in the supplement section above. Keep
ordinary workspace read-only until separately requested implementation.

## Implementation selected

User requested implementing the final proposed plan. Scope includes stage4 code,
maintained tests and README, not ordinary index/history changes. User selected
pre-freeze collision avoidance via Org allocator; retain rejected-reference
reservations, max64attempts, then document error. Frozen conflicts reject.
Private ownership-only constructor is required for filter-own-preparation's
placeholder data. Direct input-create finalizes; source path finalizes after body
parse and preserves frozen mapping while adding native bibliography output.
Three exact repeated validation commands requested in current conversation;
await authorization before execution. Tests/native via isolated flake under root
tmp/issue13-stage4. No production edits or runtime findings yet at selection.

### 4A runtime acceptance and 4B progress

User authorized requested three commands for repeated use in this task, all runs
in tmp/issue13-stage4. Independent controls precede production edits. Focused
46/46pass76.975155s, including2new native/API tests; generic/article41targets each
cover all statement types, varied equation roots/stars, nested statement,12figure/
table caption variants and4raw roots. Exact native readback, first numbered
reference, native PDF annotation destinations/page existence and tm reload/PDF
comparison passed. Org9.8.10 actual library origin reported; own reference cache,
fuzzy named/headline/target and whitespace behavior verified. No general native
numbering interpretation beyond numbered first-equation control.
Initial harness EOF fixed; Poppler merges adjacent same-page annotations, so token
membership rather than exact annotation-text association used, destinations still
checked. Existing44focused cases passed. No raw archive selected yet: maintained
controls preserve reproduction; no unique investigation output to retain.

4B production edits then started: private ownership-only constructor for filter
isolation, post-copy frozen resolution slot, finalization through Org allocator;
invalid semantic input caches its document-error until pure lowering (existing
constructor error boundary). Source adapter appends bibliography output without
AST identity change/reallocation. Generic NAME source counts/owner evidence and
scoped rebinding/region checks; object-specific labels/provenance packing.
Pure kernel no allocator or fuzzy resolver, direct internal tests route through
prepared input. Static candidate index excludes opaque internals/unused notes,
Org API resolves only bounded preindexed candidates. Strict build caught an extra
closing paren and docstring widths, corrected. Functional focused run underway;
no final implementation acceptance or full build claim.

### Functional candidate review

Focused55/55passed83.587464s with independent41native targets/style and real
exporter generic/article tm/readback/PDF/reload. Real exporter verifies labels,
long/short caption internal/file links, note-body links and STM/file provenance.
All statement variants including proof, unused names, same-used-name ambiguity,
original metadata/scopes, frozen repeated lower/no worker/buffer/random/fuzzy calls,
64attempt allocation bounds and late custom-generated collision are covered.
Additional static review corrected candidate identity dedup to eq and moved raw
native region completeness from unfiltered source walk to selection-aware context;
new excluded-truncated-native regression passes. Added synthetic equal-target
ambiguity and nested named statements/path checks. Direct constructor invalid
semantics retained until document by frozen failure data, no mutable cache escape.

Intermediate full check533ERT:527pass6fail. Four direct private kernel tests had
newline calls missed by migration; one aligned/plain independent export comparison
assumed identical random IDs; serializer's dynamic expected marker incorrectly
picked first label, which was a footnote. Fixture entrypoints/structural comparison/
actual-reference marker corrected. New candidate adds Unicode/slugsame-identity
and custom-handler NAME boundaries. Strict package compilation/lint passed;
final focused/full running, no completion claim. No runtime raw archive needed:
maintained controls plus this causal extraction sufficient; no unique original
artifacts needed for interpretation. Final input manifest will be refreshed after
all source changes; initial inputs.json was preparation-only, not final identity.

## Final accepted candidate and handoff

Fourth-stage implementation now accepted, not staged/committed. Final focused
57/57pass84.812325s. Final full flake exit0, stock539/539ERT402.926507s,
patched Org5/5pass2.951475s, strict compilation and package-lint pass; no-link
default package build exit0. Native independent controls and real source exporter
cover generic/article readback, direct PDF/native annotations and tm reload.
Pinned x86_64-linux/Org9.8.10/TeXmacs2.1.5 only; no GUI/other systems/style claim.
Earlier533ERT6fail outcome is intermediate, not final status. Corrections were
fixture entrypoints/random-ID assumptions, not lowered correctness checks.

Final inspection: candidate uniqueness deduplicates by eq; same-structure synthetic
targets remain ambiguous. Native region completeness now occurs under effective
selection rather than unfiltered initial native scan. Truncated noexport native
owners do not block; selected NAME/whole-block cuts reject before body worker.
Explicit early name type/nonblank guard avoids calling Org string operations on
invalid prepared AST. Public input constructor retains ownership validation and
caches semantic document-error until document, preserving existing error boundary.
Final formal kernel consumes frozen mappings; preflight is validation-only.
Direct callers construct/own before allocation; internal filter detachment uses
ownership-only path. No new public args/options/dependencies/worker operations.

Org matching/cache integration uses canonical owned AST in private INFO and
preseeded candidate search-cell cache, preventing Org's generic traversal from
entering raw internals/unused definitions. Native allocator owns randomness and
same-node binding. Pre-freeze collisions remove rejected direct target binding
while retaining numeric reservations, call Org again, max64attempts. Frozen map
contains only node/link IDs, target relationships, file and footnote context;
mutable Org INFO/hash caches are discarded. AST is copied before final allocation,
so no stale identity keys cross that copy. Finishing bibliography INFO reuses the
owned AST/frozen map without allocating or exposing unfinished intermediates.

Output labels must appear exactly once in final native body, including static
source/custom-handler conflicts detected after freeze; no local reallocation.
Stage4 source objects all label even unused/unnumbered; bare Org table optimization
retained. Caption/counter scope, native equation concat and statement internal
label preserve STM/file paths. Reference text remains native authority. Existing
caption anonymous footnote/native layout limitations remain unchanged.

### Commands, scope and retention

All runs from root tmp/issue13-stage4 isolated flake. User authorized repeated:
```sh
timeout 300s nix develop --no-write-lock-file path:.#checks.x86_64-linux.ert --command emacs -Q --batch -L . --load tests/ert/ert.el --eval '(ert-run-tests-batch-and-exit "issue13")'
timeout 600s nix flake check --no-write-lock-file path:.
timeout 120s nix build --no-link --no-write-lock-file path:.#default
```
No timeout failure in final acceptance. Relevant failed/successful Nix logs read
locally/offline for diagnostics/counts; no extra runtime scope. Source and isolated
31-input bytes rechecked after gates; no further source edits. Original user ELPA
mirror overlay stays root/isolated only and must be excluded from feature commit.
INBOX unchanged09ed92d4...; lock/version unchanged, index empty. No GAW skill,
archive, config, ordinary staging/history or external issue/release writes.
No new raw archive: maintained test controls, exact accepted identities and causal
extraction are sufficient; temp build logs/regenerable source copies lack unique
retention value. Runtime uncommitted, so checkpoint uses no project parent;
later delivered equivalence must be recorded separately, not retroactive runtime
provenance. Source baseline remains caption compatibility commit for comparison.

### Final identity

31-input manifest root tmp/issue13-stage4/final-inputs.json SHA256:
1f4794c387806e5cfea147fcb3aa59ac61895cae5bba0e64aee134a35cb36265.
Seven-path feature diff --binary against caption compatibility baseline SHA256:
76907fc1b5a1c7070911b26d5fe0e4b21c4de4e35cf167a9c71b3a3200915d6b.
Seven paths860insertions/231deletions, all tracked. Other task runtime inputs are
unchanged baseline files; original user flake excluded from feature diff.

```text
d4467aa45d6c6a322ddc70a5287f9b080fe074957a7b5cf647e844d51e43d1b6  README.org
4fb892b8d94d5d5a0a68ef1f8387c68df76e89bd7b354c297d6ddd3f9c6eae2f  org-texmacs-context.el
2bd82dc1852c2208d7bd5096959b2e9c2bd999ef6aabf18aa9f63702c623c476  org-texmacs-document.el
5d187a47eab6810c4c2151433c3878fce2a8eb60b7fbba83216d1bb9c61dd694  org-texmacs-input.el
9ee47eeaefc79b2469e618ebb545346bb273f8b64091ccad9351088f1d118851  org-texmacs-source.el
d6f177a02d963ea6547ee066bc7ca07bb5967e50227bad5c86aad5b193af8477  org-texmacs.el
46c66a57dab6555f3ee0d9e858d0e2c093aee4a886c3ea58863f67f523164e21  tests/ert/ert.el
54effce5b08cfe75c4a32de982ce81f31ed07afd77c7a944598175ca88538cb7  flake.nix (unchanged user mirror)
118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a  flake.lock
```

Commit preparation: user authorized staging the seven accepted paths, excluding
flake.nix. Complete staged review confirms binary diff SHA25676907fc1b5a1c7070911b26d5fe0e4b21c4de4e35cf167a9c71b3a3200915d6b,
860insertions/231deletions, whitespace clean, no unstaged feature differences.
Only original user flake overlay remains unstaged. Split not necessary, difficulty
medium: allocation/freezing, lowering consumers, fixture migration/native tests
and README are one strongly coupled capability. No multi-round polling needed.
Final staged-only message root tmp/commit.md, subject "feat(document): support named
blocks and Org reference resolution", footer Closes:#13, SHA256
c82f96b76189d4b2d2db3ee587a6347d2f44bcec70c3e14d1c75c244ab0df6cd.
No ordinary commit, new source edits or repeated runtime gates. Next: user commits,
then compare parent/path set/full patch/message/accepted blobs. Stage4 acceptance
alone is not release or Issue13 remote closure. Issue9 remains independent later work.

User adopted Closes:#13 after explicit overall closure assessment against the
current public issue body. Its bounded requirements are covered by stages1-4;
Issue9 and remaining release gates do not block13 closure. Message updated only,
no external closure or project index change.

## Delivered-equivalence verification

User reported commit, independently verified single parent equals the caption
compatibility baseline; exactly seven feature paths, full binary patch SHA256
76907fc1b5a1c7070911b26d5fe0e4b21c4de4e35cf167a9c71b3a3200915d6b,
exact approved message SHA256c82f96b76189d4b2d2db3ee587a6347d2f44bcec70c3e14d1c75c244ab0df6cd
with Closes:#13 and all accepted blobs match. Lock unchanged; index empty;
only original flake workaround remains unstaged, matching accepted overlay hash.
Prior acceptance transfers by exact byte identity; no runtime commands repeated.
Project-parent association records this delivery verification, not retrospective
runtime provenance for the originally uncommitted candidate.
GitHub Issue13 is closed/completed, closed_at2026-10-17T18:01:20Z, independently read through the connector; no external write by agent.
Four stages complete the adopted bounded issue scope. No release/tag/publication
performed; remaining release gates and Issue9 boundary stay independently scoped.
No new original archive needed: committed code/message plus extracted identities
preserve delivery evidence. Implementation and runtime sections above describe
supported development-time states; pending staging/commit instructions are retired.
