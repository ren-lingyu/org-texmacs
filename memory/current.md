# org-texmacs persistent memory

## State represented

This checkpoint reconstructs the v0.3.0 release state on 2026-09-23. It is
grounded in project commit
`8c157d06b7a8793b0bd312e8f0c41612a3640388`, the commit selected by the local
`v0.3.0` tag.

## Release outcome

v0.3.0 completes the planned structured-document expansion while preserving
the v0.2.1 explicit-source, snapshot-consistency, and non-destructive behavior.

```text
explicit Org source
  -> prepared owned input
  -> pure structured document lowering
  -> body + style + initial + provenance
  -> source-aware native encoding
  -> one persistent native TeXmacs document session
```

## Public construction boundary

- `org-texmacs-input-create` constructs owned prepared input from already
  parsed structures.
- `org-texmacs-document` is the pure prepared-input lowering core.
- `org-texmacs-prepare-buffer` is the explicit source-buffer adapter.
- `org-texmacs-document-from-buffer` composes preparation and lowering.
- `org-texmacs-document-current-buffer` remains a thin convenience wrapper.
- Prepared input and results do not retain the source buffer or share mutable
  AST/string ownership with callers.

## Supported structured semantics

- Restricted Org options and filtering for tasks, archive, select/exclude,
  comments, tags, H, num, and toc within the documented subset.
- Rich title, author, and explicit date metadata.
- Relative five-level sectioning, starred sections, low-level nested lists,
  TODO/priority/tags formatting, UNNUMBERED, and ALT_TITLE.
- Unordered, ordered, and description lists and nested quote/center containers.
- Static example, fixed-width, and source blocks with snapshot tab expansion
  and no Babel/noweb/coderef/highlighting execution.
- Basic rectangular Org tables with structural rule borders and explicit
  rejection of formulas, cookies, special columns, merges, and irregular rows.
- Static TeXmacs TOC trees with deterministic generated labels, hlink, and
  pageref, respecting the filtered context and known static STM labels.
- Existing paragraphs, supported inline objects, external URI links, anonymous
  inline footnotes, and block/fragment TeXmacs islands.

## Complete native document state

- Results contain style, structured initial environment, body, and body-relative
  STM provenance.
- Native updates validate and encode every field before mutation, then apply
  style, clear old explicit initial values, set new initial values and body,
  and verify combined readback.
- TeXmacs package normalization of style is accepted; initial is compared as an
  unordered unique key/value mapping.
- Preflight failures preserve the old session. Native update/readback failures
  discard the damaged session; cleanup or transport failures stop the worker.
- The public session remains single-active-session and headless. An internal
  headless view is allowed; no GUI window or external file is opened.

## Validation boundary

- 202/202 ERT tests passed with zero unexpected results.
- Seven x86_64-linux Nix flake checks passed.
- An independent default package build passed.
- Local and straight installation probes passed, covering all ten Lisp
  modules, the adjacent worker Scheme file, installed version metadata,
  prepared/core/buffer equivalence, full native document replacement, source
  preservation, parsing, and worker/cache reuse.
- Other systems, GUI rendering, visual pagination, serialization, and PDF were
  not verified.

## Known deferred architecture issue

The worker still depends on the high-level document module for parts of
document wire validation/encoding. The issue was observed against the node-4
snapshot and deliberately did not block v0.3.0 because no correctness failure
was established. A post-release behavior-preserving refactor should move
document representation concerns toward the session/native bridge while
leaving transport and protocol-envelope validation in the worker.

## Explicitly outside v0.3.0

- Complete Org exporter preprocessing and arbitrary Org elements.
- Internal/file/ID link resolution, named footnotes, citations, bibliography,
  and general references.
- Complete TeXmacs file document wrappers and serialization.
- Save/export/PDF, preview, live synchronization, incremental mutation, and
  multi-document or multi-session operation.

## Next durable direction

Re-review the deferred worker/document layering issue against the completed
wire before expanding downstream consumers. Keep v0.3.0's public semantics and
failure behavior stable during any refactor.
