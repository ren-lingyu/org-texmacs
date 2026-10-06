---
name: org-texmacs-development
description: Plan, implement, diagnose, or review org-texmacs parsing, structured Org-to-TeXmacs lowering, encoding, worker, document, or native-session behavior. Do not use for repository agent-governance maintenance or release-only bookkeeping.
---

# org-texmacs development

Extend or review org-texmacs while preserving its explicit-source, AST-first,
ownership, encoding, and consumer boundaries.

## Recover project state

Use the global `git-agent-workflow` skill and recover the validated GAW
workspace before substantive work.

For architecture, planning, implementation, or behavior review, read these
files completely:

- `../../memory/goals.md` for strict goals and adjustable choices;
- `../../memory/project.md` for the current interfaces and support boundary;
- `../../memory/current.md` for the active objective and next action.

Read `../../memory/backlog.md` when planning future scope, selecting the next
implementation node, or deciding whether an unsupported case is adopted,
deferred, unresolved, or requires re-adoption. Do not treat an unsupported
entry or historical idea as implementation authorization.

Read `../../memory/evidence.md` when a decision depends on earlier Org/TeXmacs
behavior, environment support, release validation, or a claimed failure. Treat
memory as a useful current record, not proof that stale runtime behavior still
holds; recheck material claims when necessary.

## Classify the change before acting

Identify the layer that owns the requested semantics:

- Org source and source-span discovery;
- TeXmacs island parsing;
- prepared-input ownership and snapshot capture;
- pure structural document lowering;
- provenance-aware native encoding;
- worker transport/protocol;
- native document/session consumption;
- downstream serialization, rendering, or export.

Do not solve a document-wide resolution problem in a local node handler, make a
worker reinterpret Org, or make a session reconstruct semantic input from
native state.

## Preserve core invariants

- Org remains the sole canonical source.
- Construct target trees directly from source AST and structured context; do
  not introduce a textual intermediary that must be parsed to recover known
  structure.
- Parse user-authored STM with TeXmacs rather than reimplementing its parser.
- Keep recursive Org content, literal/source-code content, and native STM
  content distinct.
- Preserve provenance until every source-dependent encoding decision is done.
- Use one coherent explicit source/configuration snapshot.
- Keep pure lowering free of source-buffer reads, workers, sessions, files, and
  rendering side effects.
- Reject unsupported semantics explicitly instead of silently dropping or
  flattening them.
- Preserve source and unrelated Org state on success and error paths.
- Do not widen the public support claim beyond maintained tests and native
  semantic evidence.

## Plan and implement in recoverable nodes

For a non-trivial change:

1. State the intended semantic mapping and its owning layer.
2. Identify relevant existing handlers, tests, Org behavior, and TeXmacs native
   evidence using minimal targeted reads.
3. Use focused probes only for facts not already established. Distinguish probe
   evidence from maintained regression coverage.
4. Split the work into the smallest independently reviewable and checkable
   nodes that preserve a valid package state.
5. Implement the node and its error boundary together with tests and user-facing
   documentation when the supported contract changes.
6. Run only validations authorized for the current task. Report environment,
   exit status, coverage, and unverified boundaries.
7. Update GAW memory when the verified project state, decision, blocker, or next
   action changes. Do not edit this skill merely because a feature was added.

Reference Org exporters such as `ox-latex` for semantic policy, selection, and
configuration behavior when relevant, but do not copy their string-output
transcoders into the AST-first pipeline.

## Review discipline

When diagnosing or reviewing, report evidence and impact without implementing a
fix unless the user authorizes a change. Separate correctness defects from
architecture smells, missing coverage, unsupported features, and later
consumer work.

This skill does not authorize file writes, test/build commands, network access,
ordinary Git mutations, releases, or GAW lifecycle operations.
