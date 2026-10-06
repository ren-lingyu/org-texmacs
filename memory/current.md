# org-texmacs persistent memory

## State represented

This checkpoint reconstructs the project state on 2026-09-14 after the
AST-first direction and updated project goals were adopted, but before v0.2.1
implementation. It is a planning and architecture state without an additional
project-commit parent.

## Current baseline

- Released baseline: v0.2.0 at
  `c115285639f6d40e40de378b6e2da4a79f3c1cd0`.
- Existing capability: finite structured body lowering, STM provenance,
  source-aware native encoding, and a persistent single native body session.
- Existing public whole-document construction still selects the current Org
  buffer implicitly.

## Adopted architecture direction

- The long-term path is Org source and semantics to a structured document
  representation, then to TeXmacs document trees and independent consumers.
- TeXmacs islands remain directly parsed structured input; they are not the
  whole-document architecture by themselves.
- A lowering operation conceptually consumes an Org AST, associated TeXmacs
  islands, provenance, and a fixed configuration snapshot.
- UTF-8 structural lowering remains separate from native TeXmacs encoding.
- INFO, style, initial state, metadata, and resolution context may be separate
  structured inputs or result fields; AST-first does not require putting every
  concern into one physical tree.
- File serialization and rendering remain downstream consumers, not an
  intermediate truth source.

## Identified interface gap

v0.2.0 internally prepares a private source snapshot, but its public document
entry chooses `current-buffer`. That does not satisfy the newly adopted strict
requirement for an explicit canonical source. Existing tests also do not yet
fully cover a different caller/source buffer, callback-time isolation, source
death, or all success and failure paths.

## Decided next release scope

v0.2.1 will harden the existing v0.2 pipeline without expanding document
semantics:

- require a live Org source buffer in the main document entry;
- provide a separate current-buffer convenience wrapper;
- bind source text, parser settings, output INFO, and consistency checks to one
  source snapshot;
- preserve the source and unrelated Org callers across success, error, and
  worker-wait paths;
- add regression tests for ownership, snapshot consistency, and composability.

The release deliberately does not add full `#+OPTIONS`, metadata, lists,
tables, TOC, style/initial, serialization, preview, or multi-session support.

## Open implementation risk

Existing helpers may still read dynamic `current-buffer` or buffer-local state,
especially around source checks and private link parsing. The implementation
must remove hidden source selection rather than merely wrapping the old entry
in one broad `with-current-buffer` form.

## Next action

Implement and verify the v0.2.1 explicit-source and snapshot-hardening plan in
small independently checkable nodes, then establish it as the new release
baseline before expanding document semantics.
