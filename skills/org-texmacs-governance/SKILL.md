---
name: org-texmacs-governance
description: Audit, restore, or evolve org-texmacs repository agent governance, including its GAW memory layout, namespaced project skills, and reproducible untracked AGENTS.md bootstrap. Do not use for ordinary package implementation.
---

# org-texmacs governance

Maintain the repository's agent-facing governance without turning skills into
project memory or changing the ordinary project branch.

## Establish the GAW boundary

Use the global `git-agent-workflow` skill. Confirm `git gaw status`, enter the
reported GAW worktree, run `git gaw check`, and read `.gaw/config` before GAW
writes or checkpoints. Do not initialize, deploy, rename, delete, recover, or
rewrite GAW lifecycle state without explicit user direction.

Recover the active state from `../../memory/current.md`. Read other memory only
when the governance task needs it:

- `../../memory/goals.md` for the authoritative project goals;
- `../../memory/project.md` for the current project contract;
- `../../memory/evidence.md` for provenance and validation boundaries.
- `../../memory/backlog.md` for adopted future work, deferred candidates, and
  unresolved design boundaries.

These `../../memory/` references are GAW-worktree data under this project's
declared layout: `skills/<skill>/` and `memory/` share the GAW worktree root.
They are not bundled skill resources. Locate `assets/` and `scripts/` within
this skill root; resolve other skills by identity through the available catalog.
The global GAW skill and public CLI must be available externally. Read the
global memory, archive or project-skill workflow detail when relevant; retain
the complete project procedure and stricter local constraints here.

Keep machine-specific executable bindings and installation paths in host/session
configuration; do not record Nix store paths in project guidance or current
knowledge. Tool versions may be recorded as verification context, explaining
which workflow was exercised with that version. Such observations do not require
future agents to locate the same installed version. Project guidance names tools
and needed capabilities/config compatibility. Historical raw evidence keeps its
original context and bytes.

## Keep responsibilities separate

- Memory owns current facts, goals, architecture decisions, evidence, open
  questions, progress, and next actions.
- Skills own stable triggers, procedures, routing, templates, and deterministic
  helpers.
- GAW first-parent history owns superseded durable states and phase evolution.
- Root `AGENTS.md` is an untracked deployed artifact whose canonical template
  is owned by this skill. It routes recovery but does not own durable project
  state.
- Ordinary project source and its Git history are outside routine GAW memory
  maintenance.

Do not put current HEADs, release progress, test counts, temporary TODOs, or
conversation chronology into a skill. Change a skill only when a reusable
workflow or governance contract changes.

## Reproducible AGENTS bootstrap

`assets/AGENTS.md` is the normative concise bootstrap template. It is not
automatically deployed by selecting this skill.

The root copy may be removed and rebuilt. A successful reconstruction must not
depend on loading the historical archive or on facts that exist only in the
root artifact.

Use the deterministic helper as follows:

```text
sh scripts/sync-agents --check
```

This is a read-only comparison. If the root bootstrap is missing or differs,
report the difference. During authorized GAW governance maintenance, the user
permits synchronizing the generated, ignored root `AGENTS.md` from the reviewed
template without separate confirmation. Confirm it is untracked/ignored, inspect
the difference and preserve unrelated user edits; then use:

```text
sh scripts/sync-agents --write
```

The helper must affect only the root `AGENTS.md`, must refuse a symlink target,
and must not alter Git state or access the network. After a write, rerun
`--check` and inspect project status without staging the untracked artifact.

## Maintain GAW memory

Treat the first user-requested read/review of supplied material as an intake
boundary, not just preparation for later work. In that turn, assess original
retention under `org-texmacs-gaw-archive` and distill recovery-relevant content
into memory. Record the retention decision/reason and identify the observed
source version with supported byte count/digest/provenance when applicable.
Assume a later read can return changed bytes or no file; do not postpone this
work to implementation, replacement, cleanup or handoff. Archive only material
with independent original-byte value, without treating active inputs as retired.
A later file is not the first-read original unless equality is established.
If writes are explicitly prohibited, give the assessment and distilled content
in the reply, explain what remains unpreserved, and respect the restriction.

Update current memory when a verified finding, adopted decision, objective,
blocker, state, or next action materially changes recovery. Do not create a
checkpoint for every wording edit. Before any checkpoint, inspect the entire
GAW index, stage explicit declared-workspace paths, inspect the staged diff,
run `git gaw check`, and use only `git gaw commit` with justified project
parents.

Review coordination across the whole current workspace before checkpointing:
goals, state, skills, callers and archive guidance must agree using this snapshot's
own terms and layout. Preserve earlier snapshots under their own conventions.
Record the motivation, intended outcome, implementation/verification limits and
useful related work in memory. Do not infer completion of an external issue from
a project commit, or mutate external tracking without separate authorization.

Separate all changed `.gaw/` paths from workspace changes when forming checkpoints,
including additions, deletions, content, modes and cross-boundary moves. Compare
with the first-parent tree; `git gaw check` validates candidate readiness but does
not replace this transition review. Keep each intentional intermediate state valid.

When the user explicitly authorizes a `.gaw/config` update, create a dedicated
checkpoint containing only `.gaw/config`. Keep related memory and skill changes
in a separate subsequent checkpoint. Inspect the complete index before each
commit so already-staged memory cannot enter the configuration checkpoint.

For this project's archive references, prefer archive paths and manifest history
over copying GAW checkpoint OIDs into durable memory. Keep ordinary project OIDs
when they independently locate an implementation, validation baseline or release;
do not remove project provenance or content digests merely because they are hashes.

For a retained literal project commit OID in memory, associate the exact project
commit directly and state beside the literal that it is a non-first parent of
that checkpoint. Put a multi-commit summary in a dedicated checkpoint and declare
every non-GAW commit it mentions as a non-first parent. Prefer later prose about
capabilities, conclusions and limits over carrying old OIDs forward. Keep precise
commit/validation relationships in their historical checkpoints. Treat unavoidable
exceptions individually and justify them; do not make them routine. Preserve raw
archive bytes and diagnostic OID data under the archive skill's separate contract.

Keep a checkpoint's additional project parents homogeneous in provenance purpose.
Do not assign start/result or other business roles by second/third parent position.
When separate supported phases each have recovery value, checkpoint those states
separately against their actual project snapshots. Do not manufacture checkpoints
just to rearrange parents. Express causes and phase relationships in memory prose.

Retrospective checkpoints must reflect the supported historical order. Do not
project current file organization, goals, or skills into earlier states where
they did not yet exist.

During explicitly authorized candidate-history reconstruction, retain the source
branch for review and object reachability. Do not use an old GAW checkpoint as an
additional project parent. Diagnostic mapping text alone does not retain objects.

## Archive retired source material

Use the `org-texmacs-gaw-archive` skill when historical agent documents or
necessary temporary evidence must be preserved outside active memory. Do not
copy archive contents into memory or treat them as current instructions.

## Authorization boundary

Neither this skill nor a GAW plan authorizes project-worktree writes, tests,
network access, ordinary Git commits, tags, pushes, or GAW lifecycle changes.
Follow the root bootstrap and current user authorization for those actions.
