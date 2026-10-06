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
- Grow from islands and a finite body subset toward a structured whole-document
  model, including effective configuration, metadata, references, style, and
  initial environment where their semantics are understood.
- Keep structural conversion independent from consumers such as a live native
  session, serialization, rendering, preview, or export.
- Prefer TeXmacs-native facilities for serialization and typesetting instead of
  reimplementing them in Emacs Lisp.

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
