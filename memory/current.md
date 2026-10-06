# org-texmacs persistent memory

## State represented

This checkpoint reconstructs the planning state on 2026-09-15 after the
v0.3.0 scope, interfaces, and prerequisite Org/TeXmacs probes had converged,
but before implementation nodes began. It has no additional project parent;
v0.2.1 is the release baseline, not asserted provenance for every probe.

## Baseline and objective

- Released baseline: v0.2.1 at
  `9988476b7ae98f33375d9c62ef4234890ce8b39c`.
- Preserve explicit source ownership, snapshot consistency, pure structural
  lowering, provenance-aware encoding, and the single native session.
- Expand the finite body model into a structured document representation with
  selected Org document-wide semantics and a complete native document state.

## Fixed interface design

```text
Org AST + parsed TeXmacs islands + fixed INFO
  -> prepared org-texmacs input
  -> pure org-texmacs document lowering
  -> body + style + initial + provenance
  -> one native document session
```

- A prepared-input constructor owns already parsed AST, INFO, islands, and
  post-blank mappings. It does not read a buffer, parse deferred source, invoke
  formatters, or start workers.
- The pure document core accepts prepared input only.
- A buffer adapter captures supported Org semantics, parses islands, preserves
  consistency checks, and returns prepared input.
- Owned input copies mutable AST/string structure, rebuilds parent links, and
  remaps identity-keyed mappings. It rejects cyclic, multiply owned, duplicate,
  detached, or opaque input.
- The document result carries body, style, initial, and STM provenance as
  separate fields. Body paths remain relative to the body tree.
- The body `(document ...)` is the TeXmacs buffer body, not a serialized full
  file wrapper.

## Restricted Org semantic context

- Reuse selected native Org option merging, metadata parsing, filtering,
  headline policy, and numbering semantics without invoking a string exporter.
- Support only explicitly listed options and reject unsupported directives or
  structures before worker requests.
- Do not automatically read SETUPFILE/INCLUDE, execute BIND/Babel/macros/export
  hooks, perform ID lookup, or fall back to the source buffer for missing
  footnotes.
- Discover and mask TeXmacs islands before Org pruning, isolate foreign
  subtrees, remove mappings for filtered content, and parse only retained STM.

## Required v0.3 semantic scope

- Restricted `#+OPTIONS` and task/archive/select/exclude/comment filtering.
- Rich title, author, date, relative headline levels, numbering, UNNUMBERED,
  and ALT_TITLE behavior.
- Unordered, ordered, and description lists; quote and center containers.
- Static example, fixed-width, and source blocks without execution.
- Basic rectangular Org tables with explicit rejection of advanced semantics.
- A static TOC using TeXmacs toc, label, hlink, and pageref structures.
- First-class style and structured initial environment fields.
- Native updates that validate and encode all fields before mutation, replace
  style/initial/body, verify readback, and invalidate a damaged session.

## Explicitly deferred

- Complete Org feature coverage and unrestricted exporter preprocessing.
- Internal/file/ID links, named footnotes, citations, bibliography, and general
  reference resolution.
- Complete TeXmacs file wrappers and serialization.
- PDF, preview, GUI validation, visual pagination, and multi-session support.

## Probe evidence and caution

Prerequisite probes confirmed the selected Org filtering, metadata, list,
preformatted, table, and TOC inputs and the needed TeXmacs document-style,
initial, buffer, and readback facilities on Emacs 31.1, Org 9.8-pre, and
TeXmacs 2.1.5. Probe scripts and failures are evidence for the plan, not the
formal regression suite. Each implementation node must turn the relevant
behavior into maintained tests.

## Implementation sequence

1. Prepared input and pure core.
2. Restricted Org context and filtering.
3. Lists and quote/center containers.
4. style/initial result fields, metadata, and headline policy.
5. Static preformatted blocks.
6. Basic tables.
7. Static TOC.
8. Complete native document consumption.
9. Documentation, installation, and release validation.

Each node must remain independently checkable and reviewable before the next.
The version number changes only after the functional and validation loop is
complete.

## Next action

Implement node 1, preserving all v0.2.1 source/snapshot invariants and adding
ownership, parent-link, mapping, pure-core, and buffer-adapter regressions.
