# org-texmacs current memory

## Objective

Advance DOC-01 document-wide semantic resolution after the locally tagged
v0.3.1 ARCH-01 release. The first node is a resolution/context boundary tested
with internal links and IDs. The reproducible untracked bootstrap migration is
complete. Unaided bootstrap discovery remains a nonblocking later check.

## Current baseline

- Main HEAD observed on 2026-10-06:
  `880d4e00667907ef66985387b4865ec8d795d48d`.
- Local v0.3.0 tag target:
  `8c157d06b7a8793b0bd312e8f0c41612a3640388`.
- Local v0.3.1 annotated tag resolves to main HEAD
  `880d4e00667907ef66985387b4865ec8d795d48d`.
- The ordinary project worktree is clean; `INBOX.md` is an ignored reference
  note and was not modified by the agent.
- Root `GOALS.md` and `REVIEW.md` have been retired from the active project
  root. The generated root `AGENTS.md` remains the only active root agent
  document.
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
- The two retired root documents and 30 archived legacy probe/result files
  were verified byte-for-byte against
  `archive/2026-10-06T08-59-24Z--1a90b7b/`, then moved out of their former
  locations while preserving relative paths under local `tmp/old/`.
  `tmp/old/` is ignored, local, and disposable; the GAW archive remains the
  durable historical evidence.

## Blockers and uncertainties

- No project-code blocker is known.
- In the 2026-10-06 fresh session, `git gaw status` found the deployed worktree,
  `git gaw check` passed, and the agent recovered current state through the
  declared memory and project skill without reading the historical archive.
  The user supplied root `AGENTS.md` in the session prompt, so this does not
  establish unaided discovery of the root bootstrap. That remaining check does
  not block project work.

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
- The committed tree matches the verified diff; the ordinary worktree was clean
  immediately after the ARCH-01 commit.

## v0.3.1 local release state

- Project commit `880d4e00667907ef66985387b4865ec8d795d48d`
  (`build(release): prepare version 0.3.1 metadata`) changes the package header,
  Nix version, and README release wording. The local annotated v0.3.1 tag
  resolves to this commit. Remote publication and tag signature were not checked.
- `git diff --check` passed before the metadata commit. No build or test was
  run specifically for the version preparation; ARCH-01's preceding 203/203 ERT
  and Nix checks are recorded above.

## DOC-01 selection and assessment

- The user's 2026-10-06 `INBOX.md` note selects DOC-01 before CONSUMER-01 and
  identifies a document-wide resolution phase with internal links/IDs as the
  first implementation node. `memory/backlog.md` holds the adopted scope and
  unresolved design questions; the note adds no unique raw evidence requiring
  a separate archive copy.
- Current prepared input owns copied AST nodes and identity-keyed mappings, but
  lowering accepts only a finite self-contained URI-link set and has no general
  document-wide resolver. The proposed node therefore belongs between owned
  preparation and local lowering, without buffer reads in pure lowering.
- The proposed relative-resource base and Org exporter/helper reuse need
  version-specific verification before implementation. Cross-file/global ID
  lookup must not enter the first node through ambient state.

## Next actions

1. Plan the DOC-01 resolution boundary using focused Org semantics and current
   ownership/snapshot evidence, then implement the first internal-link/ID node
   when authorized. Keep file/resource path bases and global ID lookup explicit.
2. When a later fresh Codex session starts without user-supplied `AGENTS.md`,
   check whether it discovers the root bootstrap and project skill, then
   recovers active GAW memory without the historical archive. Mark this
   nonblocking check complete when observed; continue project work meanwhile.
