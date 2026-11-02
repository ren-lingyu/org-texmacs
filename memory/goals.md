# org-texmacs project goals

## Purpose and project positioning

Build an Org-first mathematical-document AST framework. Org AST represents
native document structure and semantics; native TeXmacs STM trees represent
structured mathematical expressions; STM islands associate the two. The model
is logically unified without requiring physical grafting into one tree or a
third complete AST. Atomic STM text leaves may still be strings.

`ox-texmacs` is one consumer, not the abstraction center. TeXmacs document
lowering and export must not exclusively determine core representation and
operations. Existing export-driven coupling may be separated incrementally;
the new positioning does not demand an immediate whole-project refactor.

```text
Org buffer or supplied native AST structures
  -> complete mathematical-document AST (Org AST + parsed STM islands)
       -> structural inspection / transformation / normalized Org serialization
       -> consumer-specific TeXmacs document lowering and native output
```

These are intended responsibilities, not a claim that all core interfaces
already exist. Org remains the canonical authoring source.

## Core model and AST-first boundary

AST-first governs the complete mathematical-document model, not every input-
processing intermediate. Every recognized STM island must expose a parsed tree
before a complete model is returned. Consumers access and transform those trees
without reparsing STM source. STM tree -> text -> STM tree is not a routine
AST transformation mechanism; parsing at input boundaries and serialization at
output boundaries are allowed.

Construction may defer parsing through source/preparation stages and choose an
appropriate boundary. Leaving the original Org buffer does not itself require
immediate STM parsing. Core validity is independent of the TeXmacs document-
lowering subset: unsupported target Org structures must not by themselves
prevent core construction. Valid caller-supplied STM trees must not force a
parser restart. Native TeXmacs parsing is an expected core dependency; document
export is not implied by that dependency. STM initially supplies structure,
not formal mathematical semantics.

## Intended independent core capabilities

- Org buffer -> complete mathematical-document AST.
- Mathematical-document AST -> structured inspection representation, such as
  readable Lisp/S-expressions exposing Org structure and associated STM trees.
  This is distinct from regenerating Org source.
- Mathematical-document AST -> mathematical-document AST transformations.
- Mathematical-document AST -> semantically equivalent normalized Org text or
  buffer, without requiring original whitespace, line breaks or spelling.

Prefer native Org and TeXmacs parsers/serializers. The user's org-fmt inspiration
suggests structural equivalence and normalization idempotence for round-trip
validation; no particular native API or org-fmt implementation has been
investigated in this intake. Normalized STM serialization is sufficient;
multiline layout and a dedicated STM formatter are not required.

## Export consumer direction and current scope

Long term, `ox-texmacs` should be a standard Org Export consumer and cooperate
with extensions such as org-roam-organize through their standard Org mechanisms,
without requiring a separate adapter for each extension. Research preparation,
AST filters, Org Cite processors and export INFO separately to identify the
appropriate mathematical-document model construction boundary. Re-serializing
Org AST into a buffer alone does not establish standard-export compatibility.
Clarify core interfaces before adapting export compatibility.

Current scope is one mathematical document. Knowledge-base-wide models,
cross-document relation protocols, general knowledge graphs, OpenMath, MMT and
proof-assistant semantics remain independent future research. Do not add
speculative infrastructure or build a complex second application to demonstrate
core independence; construction, inspection and transformation interfaces suffice.

The user adopts this positioning for v0.6.0 on 2026-11-02 and then supplies their
preferred development guide for independent parsing, inspection, finite structural
transformation and normalized Org serialization. Existing TeXmacs export must
remain usable. Preferred stages, data contract and acceptance properties are
distilled in memory/core-ast-0.6.0.md. Exact API/type layout, release inventory and
later export-adaptation extent remain unfrozen. These goals do not authorize
ordinary source edits, builds or tests.

## Strict design constraints

- Org source is canonical. Native buffers, caches, serialized files, previews,
  and rendered output are derived state and must not silently become a second
  source of truth.
- AST/tree structure is the primary semantic interface. Do not flatten an
  existing structured representation into LaTeX, Markdown, XML, STM, or another
  output language and then parse it again to recover semantics.
- Parsing user-authored STM once with TeXmacs, transmitting structured strees,
  encoding string leaves, and final serialization are compatible with
  AST-first design.
- Preserve document semantics instead of silently dropping nodes or degrading
  them to ordinary text. Distinguish malformed core structures from valid
  structures unsupported by a consumer; enforce target-support errors at the
  appropriate consumer boundary.
- Inputs, source ownership, configuration, and context must be explicit or
  captured in a documented stable snapshot. Conversion must not depend on an
  accidental `current-buffer` or editor state.
- A conversion uses one coherent snapshot. Source or parser-setting changes
  during a worker wait must not produce a result assembled from multiple
  moments in time.
- Conversion must be non-destructive and composable with other legitimate Org
  callers. It must not alter source text, point, mark, narrowing, unrelated
  buffers, or global parser behavior as an undocumented side effect.
- Pure structural lowering and side-effectful consumers are separate concerns.
  Sessions consume a completed representation and do not reinterpret Org.
- Derived-state ownership and invalidation must be explainable. Clearing a
  cache or replacing a session must not lose document semantics.
- Internal formatter functions must obey their fixed input/output contract and
  avoid package-induced side effects. User functions are recommended to do the
  same; the package is not required to sandbox arbitrary user code.

## Usage goals

- Support an Org-first authoring workflow with structured TeXmacs content.
- Present embedded STM with default-on Scheme editing properties and an internal
  disable override, preserving Org ownership boundaries and export semantics.
- Grow from islands and a finite body subset toward a structured whole-document
  model, including effective configuration, metadata, references, style, and
  initial environment where their semantics are understood.
- Keep structural conversion independent from consumers such as a live native
  session, serialization, rendering, preview, or export.
- Prefer TeXmacs-native facilities for serialization and typesetting instead of
  reimplementing them in Emacs Lisp.

## Adopted v0.5.0 release objective

Historical baseline: v0.5.0 implementation and local release finalization are
complete as recorded in memory/current.md. The release-era scope and progression
below explain prior decisions, not unfinished gates or the new framework scope.
The positioning above takes precedence for subsequent design. Issue9's earlier
scheduling and Issue7's deferred proposal do not identify the newly announced
core feature.

First practically usable release for Org-first mathematical writing with embedded
native STM and complete .tm/PDF exports inside a tested supported subset.
Issue13 is required for v0.5.0: private recursive special-block extension point,
formal statements, single-expression equation/equation*, explicit figure/table
wrappers and bounded single-object NAME/[[name]] semantics. Stage1 recursive
handlers/formal statements are locally implemented and accepted. Stage4 NAME/reference
implementation is now accepted/user-committed, exact delivery verified;
Issue13 independently confirmed closed/completed;57focused/539fullERT/
full flake/build pass (issue-13-stage4.md). Stage3 figure/table candidate is implemented,
focused/full flake/build accepted, user-committed and delivery verified; see issue-13-stage3.md. Stage2 equation candidate is
implemented/accepted/user-committed including full flake/build; exact delivery
verified (issue-13-stage2.md).
Stage1 evidence: memory/issue-13-stage1.md. Full design and verification
boundaries: memory/special-block-plan.md.

Existing inline-footnote/display-equation fixes, prior block-fixture confirmation,
bounded links/fonts/font-lock outcomes, representative documents, final checks
and metadata/docs retain their established statuses; no existing gate completed
by this scope update. Detailed readiness: memory/release-0.5.0.md.
User now prioritizes0.5.0 version metadata and documentation/comments finalization.
The selected six-path candidate is now locally accepted by isolated full flake
(553stock/6patched/strict compile/lint) and default build. User committed exact candidate; delivery verification confirms
parent/patch/message/all32inputs, project index/worktree clean. Version/docs complete.
Details: release-0.5.0.md. This does not select tag/publication.
Full nix flake check is already routine per commit, not an additional release-only
blocking gate. User now selects review of a standalone configuration/documentation
example package exposed through packages, with PDFs in out. Package-level complete
isolation and content/layout reproducibility are required; byte identity is not.
User subsequently selected and delivered org-texmacs-examples with package-local
bilingual sources, two entries per language and literate Org configuration/
bibliography with native INCLUDE composition. Four-document package build is
accepted before final navigation/prose edits, which have static review only.
Independent reviewed GoToR renderer package and unchanged Fandol wrapper compose
for examples/devShell; ordinary Lisp package keeps plain TeXmacs. This is not a
release prerequisite or default check. Only en/zh, no exhaustive option matrix.
Automatic bibliography insertion and abstract/TOC ordering changes are explicitly
deferred. Details/validation limits: memory/documents-package.md. Authored prose
uses ASCII punctuation, including commas instead of ideographic commas. No
general font/layout repair or PS route is selected.
After the source/package/test refactors, user selected README-only synchronization
to HEAD without extra release-plan narrative; user committed the reviewed README-only
change; exact parent/patch/message verified and project clean, no runtime rerun. Existing version declarations remain0.5.0.
User tentatively excludes Issue14 from0.5.0 blocking scope; this is
revisable, not permanent deferral. User subsequently selects its independent
implementation, now user-committed/delivery-verified with Issue14 independently
confirmed CLOSED/COMPLETED (issue14-implementation.md). No Issue14 work remains;
that selection did not change release policy or include font work.
Complete Org parity, async export, preview and general authoring assistance are
not release requirements. Issue9 now owns independently named constituents inside
one composite native structure, initially separately numbered/referenced aligned
formula rows, after0.5.0/before0.6.0. Issue13 does not close9;9 does not gate
single-object names in13. Issue7 stays deferred. This objective does not authorize
implementation, builds, tests, next-node selection or release operations.

## Soft goals

- Persistent workers and sessions should avoid needless startup overhead.
- Incremental conversion, subtree mutation, multiple sessions, and typesetter
  cache reuse are desirable only after correctness, ownership, and failure
  semantics are stable and measurements justify the complexity.

## Adjustable implementation choices

Module boundaries, private data structures, IPC details, version partitioning,
and the exact order of later consumers may change when evidence supports a
better path. Such changes must continue to satisfy the strict constraints
above.

This file states goals, not the current support matrix or an authorization to
implement every listed capability in the next release.
