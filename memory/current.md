# org-texmacs current memory

## Objective

Complete the reproducible untracked bootstrap migration: preserve a curated
active backlog, checkpoint the recovery surface, deploy the concise root
`AGENTS.md`, and prove deterministic reconstruction. After that migration is
verified, perform the worker/document layering refactor as a
behavior-preserving post-v0.3 change.

## Current baseline

- Main HEAD observed on 2026-10-06:
  `1a90b7bd2e0f60601cdf6003edf1ccbc79afce18`.
- Local v0.3.0 tag target:
  `8c157d06b7a8793b0bd312e8f0c41612a3640388`.
- The ordinary project worktree was clean when retrospective reconstruction
  began.
- GAW `_agents` is valid and deployed at the repository `.agents` directory.
- GAW branch preservation and transfer are already solved and are not an open
  issue.

## Current decisions

- `memory/goals.md` is the current authoritative project-goal source.
- `memory/project.md` records the current architecture and supported contract.
- `memory/evidence.md` records durable evidence and validation boundaries.
- `memory/backlog.md` records adopted future work, deferred candidates, and
  unresolved design boundaries without turning unsupported syntax into an
  automatic commitment.
- This file records only the active objective, state, decisions, blockers, and
  next actions.
- Repository skills use the `org-texmacs-` namespace and contain reusable
  procedures, triggers, routing, templates, and deterministic helpers, not
  version progress or historical facts.
- Root `AGENTS.md` remains an untracked unconditional bootstrap artifact. Its
  normative template and deterministic deployment helper live in the
  governance skill, so the root artifact may be removed and rebuilt without
  losing durable project state.
- The legacy root documents and their directly referenced plain-text probes
  are preserved as non-authoritative evidence under
  `archive/2026-10-06T08-59-24Z--1a90b7b/`. Archive contents are evidence, not
  an ordinary recovery source.
- Future temporary artifacts should use the same GAW archive convention when
  losing them would materially impair interpretation, reproduction, audit, or
  handoff of durable work. Select them explicitly, preserve project-relative
  paths, and prefer individual plain-text files over tar or other containers.
- The known worker-to-document dependency inversion should be repaired after
  governance migration without changing public APIs, document wire semantics,
  session failure behavior, or v0.3 coverage.

## Completed GAW migration work

- Retrospective GAW history has been reconstructed through v0.1.0, v0.2.0,
  GOALS adoption, v0.2.1, v0.3 planning, the node-4 review, v0.3.0 release, and
  the post-release GAW migration decision.
- Current memory is normalized into goals, project model, evidence, and active
  handoff files.
- `org-texmacs-governance` and `org-texmacs-development` have been created as
  focused repository skills. Both passed the skill-creator structural
  validator.
- The governance bootstrap helper passed shell syntax validation. Its read-only
  check reports the existing legacy root AGENTS differs from the concise asset,
  as expected; write mode was not run.
- The root `archive` workspace and `org-texmacs-gaw-archive` skill now define a
  reproducible plain-text archive workflow. Checkpoint `dbc0df9` preserves the
  three root Markdown documents and 30 directly relevant probe/result files,
  with project commit `1a90b7b` as its exact project parent.
- The still-valid unimplemented work has been curated into
  `memory/backlog.md`; obsolete early-version TODOs were not copied forward.

## Blockers and uncertainties

- No project-code blocker is known.
- A genuine fresh-context recovery drill cannot be completed inside the
  context that authored the migration. It remains a later validation step.

## Next actions

1. Checkpoint the backlog and recovery-routing changes, deploy the concise root
   AGENTS bootstrap under the current user authorization, and verify a
   remove/rebuild cycle byte-for-byte.
2. In a fresh Codex context, verify skill discovery, trigger boundaries, and
   recovery from active GAW memory without reading the historical archive.
3. Re-audit the completed v0.3 worker/session/document boundary and plan the
   behavior-preserving layering refactor.
