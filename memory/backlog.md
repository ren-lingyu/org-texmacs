# org-texmacs active backlog

## Purpose and status model

This file records still-valid future work that must survive replacement of the
legacy root documents. It is not a support matrix, an implementation
authorization, or an append-only copy of historical plans.

Use these status labels:

- **active-next**: the next adopted project change selected for implementation;
- **adopted-later**: required by the current goals, but not the next change;
- **deferred-candidate**: plausible work whose need, scope, or ordering still
  requires evidence or a later decision;
- **unresolved-design**: a semantic boundary that must be decided before its
  owning feature is implemented;
- **re-adoption-required**: an older idea that is not part of the current goals
  unless the user adopts it again.

Unsupported syntax is not automatically backlog work. Move an item into an
adopted status only when it follows from `memory/goals.md` or a later explicit
decision.

## Active next

No item is currently selected. `ARCH-01` was completed by project commit
`ec72c89b71ffd1df27d9cdb22c4f6c8e1a4f6491`; its prior active plan remains in
GAW first-parent history rather than as a completed item in this active file.

## Adopted downstream work

### DOC-01: Complete document-wide semantic resolution

Status: **adopted-later**.

Grow the current prepared-input and document model only where semantics require
whole-document knowledge. The durable direction includes internal/ID/file
links, references, citations and bibliography, named footnotes, and additional
effective configuration. Preserve the existing separation between local node
lowering and document-wide resolution.

Before file/resource support, resolve this **unresolved-design** question:
relative resources may need a base derived from the source location, prepared
document state, or consumer/export destination. Do not let a local link handler
choose that policy implicitly.

External Org preprocessing such as setup files, includes, macros, or hooks must
remain explicit and bounded. It must not weaken the owned snapshot or pure
lowering contract.

### CONSUMER-01: Add stable complete-document consumers

Status: **adopted-later**.

Build complete TeXmacs file-document construction and independent consumers for
native serialization/save, Org export integration, rendering/PDF, and preview.
Keep the AST-first rule: construct known target structure directly and use
TeXmacs-native serialization or rendering interfaces rather than generating an
intermediate text format that must be reparsed to recover structure.

The relationship between a future `ox-texmacs` frontend and the current
document construction API is an **unresolved-design** question. Export policy
and preprocessing belong above the reusable document constructor, not inside
local lowering handlers.

Visual output, pagination, page setup, and installed-system behavior need
native or GUI evidence before they can be claimed as verified.

## Deferred candidates

### SESSION-01: Multi-document or multi-session operation

Status: **deferred-candidate**.

The current public contract intentionally exposes one active native document
session. Add multi-document/session behavior only when a concrete consumer
needs it and ownership, failure isolation, cleanup, and concurrency semantics
have been designed.

### INCREMENTAL-01: Local native mutation and incremental synchronization

Status: **deferred-candidate**.

Full body replacement is the current correctness baseline. A local mutation
path would require stable target paths or identities, invalidation rules, stale
result rejection, failure-to-full-sync fallback, reference/auxiliary-state
readiness rules, and performance evidence. Do not add live edit hooks or a
second incremental AST cache merely for convenience.

### INLINE-01: Expand or optimize inline TeXmacs discovery

Status: **deferred-candidate**.

The maintained configured-fragment subset is sufficient for the current
contract. Before broadening it, probe the exact intended Scheme-reader surface,
including comments, character literals, extensions, malformed-input recovery,
overlap and precedence with Org objects, complex-container/region boundaries,
large-document performance, and relevant Org-version behavior. Inline caches
or augmented live ASTs require separate evidence and adoption.

### AUTHORING-01: Editing assistance

Status: **re-adoption-required**.

Font locking, Scheme editing assistance, preview-oriented UX, and similar
authoring conveniences appeared in early exploration but are not current
architecture commitments. Re-adopt and scope them before implementation.

## Current unsupported cases are not automatic commitments

Examples include checkbox and explicit list-counter semantics, advanced table
features, arbitrary Org elements, dynamic source execution, named footnotes,
citations, bibliography, and general internal/file/ID links. Some are covered
by adopted document work above; others remain unsupported until separately
adopted. Continue to fail explicitly rather than silently flattening them.

## Historical provenance

The full historical wording and probes remain non-authoritative evidence in:

```text
archive/2026-10-06T08-59-24Z--1a90b7b/
```

Relevant legacy areas include the inline validation boundaries, TeXmacs buffer
state and synchronization discussion, `PLAN-2026-09-13-01`, and
`PLAN-2026-09-14-02`. Consult them only when this backlog or current evidence is
insufficient; do not load the archive during ordinary recovery.
