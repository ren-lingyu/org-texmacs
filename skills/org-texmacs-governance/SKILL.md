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

## Keep responsibilities separate

- Memory owns current facts, goals, architecture decisions, evidence, open
  questions, progress, and next actions.
- Skills own stable triggers, procedures, routing, templates, and deterministic
  helpers.
- GAW first-parent history owns superseded durable states and phase evolution.
- Root `AGENTS.md` is an untracked unconditional bootstrap artifact.
- Ordinary project source and its Git history are outside routine GAW memory
  maintenance.

Do not put current HEADs, release progress, test counts, temporary TODOs, or
conversation chronology into a skill. Change a skill only when a reusable
workflow or governance contract changes.

## Reproducible AGENTS bootstrap

`assets/AGENTS.md` is the normative concise bootstrap template. It is not
automatically deployed by selecting this skill.

Use the deterministic helper as follows:

```text
sh scripts/sync-agents --check
```

This is a read-only comparison. If the root bootstrap is missing or differs,
report the difference. Do not run the write mode unless the user explicitly
authorizes modification of the root `AGENTS.md`:

```text
sh scripts/sync-agents --write
```

The helper must affect only the root `AGENTS.md`, must refuse a symlink target,
and must not alter Git state or access the network. After a write, rerun
`--check` and inspect project status without staging the untracked artifact.

## Maintain GAW memory

Update current memory when a verified finding, adopted decision, objective,
blocker, state, or next action materially changes recovery. Do not create a
checkpoint for every wording edit. Before any checkpoint, inspect the entire
GAW index, stage explicit declared-workspace paths, inspect the staged diff,
run `git gaw check`, and use only `git gaw commit` with justified project
parents.

Retrospective checkpoints must reflect the supported historical order. Do not
project current file organization, goals, or skills into earlier states where
they did not yet exist.

## Archive retired source material

Use the `org-texmacs-gaw-archive` skill when historical agent documents or
their necessary plain-text probe evidence must be preserved outside active
memory. Do not copy archive contents into memory or treat them as current
instructions.

## Authorization boundary

Neither this skill nor a GAW plan authorizes project-worktree writes, tests,
network access, ordinary Git commits, tags, pushes, or GAW lifecycle changes.
Follow the root bootstrap and current user authorization for those actions.
