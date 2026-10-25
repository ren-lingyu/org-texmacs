# org-texmacs project goals

## Purpose

Use Org as the sole canonical source for a structured document that can be
lowered directly into TeXmacs document trees and consumed by TeXmacs-native
facilities. TeXmacs islands are an implementation technique inside the larger
document model, not the final boundary of the project.

```text
Org source and semantics
  -> structured Org document input with parsed TeXmacs islands
  -> structured TeXmacs document representation
  -> TeXmacs native tree/state
  -> independent consumers
```

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
- Preserve document semantics instead of silently dropping unsupported nodes or
  degrading them to ordinary text. Unsupported semantics must have an explicit
  boundary or error.
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
blocking gate. Representative combined documents are a final optional user decision
(whether and format, possibly flake check/nix run), not an adopted prerequisite.
Chinese font issue and PS route have been removed from blocking scope.
After the source/package/test refactors, user selected README-only synchronization
to HEAD without extra release-plan narrative; local candidate is reviewed and
unstaged, no runtime validation selected. Existing version declarations remain0.5.0.
User tentatively excludes Issue14 from0.5.0 blocking scope; this is
revisable and does not select implementation or permanent deferral.
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
