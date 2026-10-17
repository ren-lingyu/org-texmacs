# v0.5.0 special-block plan and Issue9 boundary

## Stage3 guidance review

Figure/table wrappers and experimental stars remain planned. Detailed supplied
contract, prevalidation gates and three adopted user revisions/six extra gates:
memory/issue-13-stage3.md. No source implementation or tests authorized/performed
by the review/revision follow-up. Keep structure evidence before context loss, current
caption subset and bounded native table grammar explicit.

## Status, motivation and authority

Stage1 now user-selected for implementation: foundation (recursion, captured
private registry, input ownership, preflight and provenance) followed by formal
statements. Stage1 implemented/accepted/user-committed, exact delivery verified;
17focused/495fullERT/full flake/strict package compile/lint/build pass. All16
candidate types now verified under native generic style, including real titles/
counters/PDFs and representative tm reload. Details: memory/issue-13-stage1.md.
Updated handler contract prohibits external reuse of any contents descendant cons/string;
deep-rebuilt semantic duplication remains an unenforceable callback obligation.
Preflight guarantees rejection before body STM requests, not before bibliography
requests; custom handlers never receive placeholder contents. Stage2 equation
implementation is below; no figure/table/NAME implementation or Issue9 scope. Preserve/exclude user flake workaround.
Implementation command authority/current findings: memory/current.md. Initial
memory-only adoption below describes its original phase, not current authority.

Stage2 equation candidate implemented, focused29/29/native checks, full flake
ERT/compile/lint and no-link build pass; user committed the exact nine-path
feat(document) candidate, read-only delivery verification passed.
Full extracted source contract, four accepted corrections and test boundaries:
memory/issue-13-stage2.md. Accept native parser's structurally valid string/stree
datums without a mathematical root whitelist; source is raw, single-capture and
single-request, opaque throughout preprocessing/discovery/context. Pack exactly
one equation/equation* wrapper, preserve provenance, reserve names; no labels or
custom handler. Empty raw source is distinct from parsed empty-string datum.
Existing transport/session invalidation and partial-write limits remain intact.
Stage3 figure/table, stage4 NAME, Issue9 composite constituents remain distinct.

Original scope adopted from user INBOX dated2026-10-17. Issue13 is required for v0.5.0's first
usable Org-first mathematical writing subset. Earlier release scope omitted this
work and deferred broader names/references; the new split assigns single objects
to13 and composite constituents to9. That initial adoption was memory-only;
stage1 was subsequently selected/implemented/accepted as recorded above.

Sources read at2026-10-17T08:22:29Z:
- User INBOX.md,12736bytes,SHA256
  ab3242521be1b9c19bdf62fc39885e6a9433e93c2d2debf0068b78d868ba1620.
- https://github.com/ren-lingyu/org-texmacs/issues/13
  Support Org special-block lowering and core mathematical environments;
  open,updated2026-10-17T08:11:44Z,0comments,no milestone.
- https://github.com/ren-lingyu/org-texmacs/issues/9
  Support independently named constituents within composite TeXmacs structures;
  open,updated2026-10-17T08:11:46Z,1comment,no milestone.
Issue bodies independently read through GitHub connector and agree with INBOX.
Comments not needed/read for this body-based scope adoption. Source status and
native support differ: Issue13's Supported rows are delivery requirements, not
proof of present package/native behavior. No code investigation performed here.

## Invariants and private extension boundary

Org stays canonical; native STM remains opaque. Reuse owned prepared AST,
coherent conversion snapshots, input/source ownership, STM/file provenance,
worker isolation and pure lowering. No textual intermediary to recover known
structure. Unknown types, malformed structures and unsupported semantics fail
explicitly. Existing legacy table/STM behaviors retain their regressions.

Ordinary special-blocks get recursive preparation/lowering using Org :type,
:parameters and children. Small private handler dispatch only; candidate contract
(handler block contents info): owned prepared node, already lowered stree normally
(document ...), captured info; return structured stree, never STM source text.
Core owns provenance and validates identity/paths; handlers cannot copy/split/drop
provenance-bearing content without core support. Preflight must not treat worker
placeholders as final native islands. No stable public handler registry, handler
custom option, universal environment taxonomy/parameter DSL or general stree
editing API. Specific object handlers may impose different input/label contracts.
The existing opaque begin_texmacs escape hatch is not ordinary recursive prose.

## Built-in source semantics

Formal statements:
- Canonical begin_statement TYPE, exactly one required type token; compatibility
  begin_statement_TYPE and begin_TYPE accept no additional arguments.
- Explicit validated mapping for applicable native theorem/remark/exercise-like
  environments and proof; no invented exhaustive tag list before investigation.
- Recursive Org body -> (NATIVE-TAG (document ...)). Actual availability/layout,
  including proof, is style-dependent and needs evidence.
- begin_example stays Org's built-in example-block, not an alias. statement example
  and statement_example can represent that formal environment.
- No extra title/parameter DSL or statement-specific nesting grammar; special
  support for statement nesting is not a release goal.

Equations:
- begin_equation / begin_equation* each contain one complete native STM expression,
  parsed by the existing worker/parser, not recursively as Org prose.
- Emit (equation BODY)/(equation* BODY); formula-specific internal label placement,
  not generic exterior surround for equation numbering.
- Independently named/numbered aligned rows excluded; that is Issue9.

Explicit figures and tables:
- figure/table -> big-figure/big-table, numbered even without caption.
- figure*/table* -> big-figure*/big-table*, unnumbered experimental source syntax
  and mapping with no forward/backward compatibility or LaTeX parity promise.
  Org parsing and native behavior must be verified before delivery.
- Figure body: exactly one embedded begin_texmacs block containing native
  diagram/figure STM. External image import not a prerequisite.
- Table body: exactly one Org table OR one embedded begin_texmacs block. Native
  roots restricted to valid table, tformat containing table, or full tabular;
  supply missing enclosing tformat/tabular structure according to known root,
  preserving one valid tabular body, without arbitrary internal STM rewriting.
- Wrapper owns NAME/CAPTION; conflicting inner affiliated metadata rejects.
  Unique-body, root validity and STM/file provenance need coverage.
- Caption and numbering independent: missing caption still produces
  (big-figure BODY "")/(big-table BODY ""), with normal Figure N./Table N.
  display and proper native caption/counter label scope. Visual/number/PDF
  behavior is a requirement to verify, not established evidence.
- begin_table becomes preferred semantic table interface. Naked Org tables remain
  lower-priority compatibility input, not deprecated; preserve their current
  caption-dependent numbering/reference/lowering. No feature-parity requirement;
  reuse table-to-tabular body lowering where possible.
- Object category is separate from native (float ...) placement. Whether/when to
  emit float or positioning parameters remains undecided. No generic begin_float
  or public placement configuration adopted.

## Bounded single-object names and references (Issue13)

Relax NAME rejection for admitted blocks and integrate into the existing
identity-keyed Org name/link resolver. [[name]] uses the same allocated private
label as its target; retain ambiguity/native-label collision checks. TeXmacs owns
numbering, no parallel Emacs counters. Keeping org-texmacs-ref-N names is fine.

Insertion depends on object: equation/equation* inside formula; statement inside
native statement scope; figure/table inside caption/counter scope even with empty
caption. Unnumbered objects may offer descriptive anchored links, without an
invented meaningful automatic numeric reference.

Named plain begin_texmacs weak-anchor candidate:
(surround (label ID) "" ORIGINAL-STM), outside unchanged opaque subtree. Verify
representative native roots/contexts/layout/links. No arbitrary STM inspection or
rewriting to infer numbering or label position; no general numeric/PDF-target
promise for arbitrary roots. Prefer labels only on actually referenced names,
consistent with existing resolver; this enable condition remains to finalize
before implementation, not an already proven mechanism.

## Required evidence and remaining decisions

Before/while separately authorized development: pinned Org/native parsing of
starred block names; explicit applicable statement tag mapping/style behavior;
equation/statement labels in counter scope; numbered empty-caption figure/table
display and references; raw STM surround preservation and bounded anchors;
single-body/conflicting metadata/table root errors; prepared-island preflight and
identity/provenance paths; recursive Org and nested STM; native .tm and PDF
numbering/links; legacy raw STM/naked table regressions. No experiment authorized
by this plan. Prior478ERT editing delivery does not validate new13 semantics.

## Issue9 refocus and sequencing

Issue9 remains adopted-later after0.5.0/before0.6.0: independently named Org
constituents assembled as one native composite structure. Initial required case
is one aligned multiline formula with independent per-row Org identity, native
numbering, labels/references and shared layout. Demonstrate one composite native
AST and independent PDF references, preserving provenance and native counters.
Issue13's single-object completion does not close9, and9 is not a prerequisite
for ordinary NAME/[[name]] block support in13.

No ATTR_TEXMACS syntax, placeholders, composition/merge algorithm, generalized
handler tree reparenting or multirow environment selected. Independently numbered
subfigures/subtables are future candidates, not9 acceptance. General STM reuse,
arbitrary dependency graphs, float placement and counter replacement excluded.

## Release and retention

Add Issue13 as one mandatory scope gate, not duplicate old release items. Existing
original block-fixture linkage, bounded CJK outcome, native first-note limitation
assessment, representative full documents, final locked-flake/native/PDF gate and
metadata/docs/notes retain their current statuses. No release-ready claim.
Detailed shared readiness remains memory/release-0.5.0.md. Historical research and
original archives remain unchanged. No raw archive: active adopted plan and source
observations are fully distilled here; no retired document or unique experimental
evidence. This planning checkpoint has zero added project parents; current main
was inspected only for ordinary-worktree preservation, not tested against13.
