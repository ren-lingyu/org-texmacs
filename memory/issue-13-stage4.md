# Issue13 stage4: NAME and single-object references, read-only guidance review

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
