# org-texmacs current memory

## Objective

Begin `ARCH-01`, the behavior-preserving worker/document layering refactor.
The reproducible untracked bootstrap migration is complete. A future fresh
context should independently confirm discovery and recovery routing, but that
validation no longer blocks project work.

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
- Checkpoint `ab46bc0` records the active backlog and complete bootstrap
  recovery surface.
- The concise root `AGENTS.md` was deployed from the governance skill and its
  helper passed a real remove/rebuild comparison. The original generated copy
  and reconstructed copy both had SHA-256
  `9252649558075d08f6f990d30dd365a12bc28a1fe2e3a3554d5d0aeac1ab68df`.
  The project worktree remained clean and the root artifact remained ignored.

## Blockers and uncertainties

- No project-code blocker is known.
- A genuine fresh-context recovery drill cannot be completed inside the
  context that authored the migration. It remains a later validation step.

## Current ARCH-01 worktree state

- The ordinary worktree contains an uncommitted behavior-preserving layering
  refactor in `org-texmacs-core.el`, `org-texmacs-worker.el`,
  `org-texmacs-session.el`, and `tests/ert/ert.el`.
- Shared condition types now live in core. The worker owns transport framing,
  generic envelope reading, and STM parse response semantics. The session/native
  bridge owns document preflight/wire serialization, native encoding, and
  native/session response contracts.
- `org-texmacs-worker.el` no longer requires `org-texmacs-document.el`; a test
  records this load boundary before loading the complete package.
- Public APIs and the Scheme request/response wire are intended to remain
  unchanged. `git diff --check` passes, but ERT and Nix checks have not yet been
  run against this worktree, so the node is not yet verified or commit-ready.

## Next actions

1. Run the full ERT suite and Nix checks for the ARCH-01 worktree; repair any
   regressions within the same layering scope.
2. Review the complete diff and, if verified, prepare it as one independently
   commit-ready architecture node and update project/backlog memory.
3. In a future fresh Codex context, verify skill discovery and recovery from
   active GAW memory without reading the historical archive.
