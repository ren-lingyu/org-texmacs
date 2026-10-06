# org-texmacs persistent memory

## State represented

This checkpoint reconstructs the durable project state at the v0.2.1 release
on 2026-09-14. It is grounded in project commit
`9988476b7ae98f33375d9c62ef4234890ce8b39c`.

## Objective achieved

Harden the existing v0.2 whole-document pipeline around an explicit canonical
Org source, one coherent snapshot, and non-destructive/composable behavior,
without expanding the supported document semantics.

## Public source contract

- `(org-texmacs-document SOURCE-BUFFER)` requires a live, non-narrowed Org
  buffer and is the main whole-document entry.
- `(org-texmacs-document-current-buffer)` is the separate convenience wrapper.
- The old zero-argument main entry is intentionally not retained as a
  compatibility branch; callers must migrate explicitly.
- Source text, mode, narrowing, parser settings, consistency checks, and output
  context are all anchored to the same source buffer.

## Snapshot and consistency contract

- Source text and the supported parser settings are captured at conversion
  start and checked again across worker waits and after lowering.
- Detectable changes to source text, mode, narrowing, fragment tags, heading
  settings, or link settings reject the in-flight result instead of mixing
  states or retrying indefinitely.
- Output INFO and formatter selection are frozen for the current conversion;
  later rebinding affects the next call.
- The result does not retain the source buffer, marker state, or an implicit
  dependency on the caller's current buffer.

## Isolation and side effects

- Preparation returns structure and performs parsing in a private buffer.
- Preflight checks occur outside temporary dynamic parser scopes.
- Pure lowering consumes prepared structures and does not read a source buffer
  or start a worker.
- Source text, modified state, point, mark, narrowing, text properties, and
  relevant local settings are preserved on success and error paths.
- Formatter callbacks do not leak package-controlled Org parser state into
  other buffers. The package does not attempt to sandbox arbitrary user
  functions.

## Validation boundary

The final v0.2.1 verification recorded 156/156 ERT tests passing, Nix flake
checks and an independent build passing, and local and straight installation
probes passing. The installed-package probes covered both public entries,
cold-start document/session behavior, repeated native updates, and
fragment/block worker/cache reuse. Validation was on x86_64-linux; remote
release state and tag signatures were not established.

## Unchanged semantic boundary

The release deliberately retains the v0.2 body subset and single active
session. It does not add complete Org effective configuration, document
metadata, common container structures, tables, TOC, style/initial state,
serialization, PDF, preview, or multi-session support.

## Next durable direction

Use the explicit-source and snapshot-safe interface as the baseline for a
structured document expansion. Before implementation, define a prepared-input
boundary, a finite restricted Org semantic context, a complete document result
shape, and independently verifiable v0.3 nodes.
