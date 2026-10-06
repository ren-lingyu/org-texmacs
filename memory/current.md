# org-texmacs current memory

## Objective

Select the next implementation scope from the adopted downstream work. The
verified, behavior-preserving `ARCH-01` worker/document layering refactor is
committed, and the reproducible untracked bootstrap migration is complete. A
future fresh context should independently confirm discovery and recovery
routing, but that validation does not block project work.

## Current baseline

- Main HEAD observed on 2026-10-06:
  `ec72c89b71ffd1df27d9cdb22c4f6c8e1a4f6491`.
- Local v0.3.0 tag target:
  `8c157d06b7a8793b0bd312e8f0c41612a3640388`.
- The ordinary project worktree is clean after the ARCH-01 commit.
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

## Completed ARCH-01 refactor

- Project commit `ec72c89b71ffd1df27d9cdb22c4f6c8e1a4f6491`
  (`refactor(worker): decouple transport from native session protocol`) records
  the verified four-file layering refactor.
- Shared condition types now live in core. The worker owns transport framing,
  generic envelope reading, and STM parse response semantics. The session/native
  bridge owns document preflight/wire serialization, native encoding, and
  native/session response contracts.
- `org-texmacs-worker.el` no longer requires `org-texmacs-document.el`; a test
  records this load boundary before loading the complete package.
- The remaining `org-texmacs--document-copy-stree` helper retains document
  validation/error semantics and is no longer used by worker transport. No
  genuinely generic worker-owned stree copy remained to move into core/AST.
- Public APIs and the Scheme request/response wire remain unchanged. A static
  review additionally fixed the pre-transmission failure boundary so a local
  request-builder error preserves the healthy worker.
- On 2026-10-06, full ERT passed 203/203 with exit status 0 using
  `emacs-twist`. `nix flake check -L --no-write-lock-file` also exited 0,
  covering the declared package, ERT, package-lint, and development-shell
  outputs. Nix fetched one source path from `cache.nixos.org`; the lockfile and
  ordinary tracked files outside this refactor were not changed.
- The committed tree matches the verified diff, and the ordinary worktree is
  clean.

## Next actions

1. Select the next implementation scope from adopted work rather than treating
   unsupported cases or deferred candidates as automatic commitments.
2. In a future fresh Codex context, verify skill discovery and recovery from
   active GAW memory without reading the historical archive.
