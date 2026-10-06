# org-texmacs current memory

## Objective

The DOC-01 source-location snapshot node is implemented and verified in the
ordinary worktree, ready for review. Next is the structured file/resource target
and native consumer path contract. The temporary mirror-source configuration
must remain uncommitted and unpushed. Bootstrap discovery remains nonblocking.

## Current baseline

- Main HEAD observed on 2026-10-06:
  `a3ba241d66dc1e1a89a9eb4c4fc678fef2f5bfb4`.
- Local v0.3.0 tag target:
  `8c157d06b7a8793b0bd312e8f0c41612a3640388`.
- Local v0.3.1 annotated tag resolves to
  `880d4e00667907ef66985387b4865ec8d795d48d`.
- The first local-link node is committed; the ordinary worktree now contains
  the verified, uncommitted source-location snapshot node and the user's
  temporary overlay. `INBOX.md` remains an ignored reference note and was not
  modified by the agent.
- Root `GOALS.md` and `REVIEW.md` have been retired from the active project
  root. The generated root `AGENTS.md` remains the only active root agent
  document.
- GAW `_agents` is valid and deployed at the repository `.agents` directory.
- GAW branch preservation and transfer are already solved and are not an open
  issue.
- The user added a temporary fetchurl overlay in `flake.nix` replacing GNU ELPA
  URLs with the remote USTC ELPA mirror. Only this configuration is retained
  locally: do not commit or push it, and exclude `flake.nix` from the project
  commit scope. This is not a locally hosted mirror. The node was completed
  before overlay validation; identify resulting validation as using this
  temporary, uncommitted mirror-source configuration.

## Current decisions

- The user's current GAW content policy permits only pure-text files in memory,
  skills, and archive. Do not stage/checkpoint bytecode, binaries, images, or
  binary containers. Keep regenerable compilation artifacts outside GAW.
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
- GNU ELPA availability failed Nix validation: on 2026-10-06 the user reported that
  `elpa.gnu.org` was inaccessible on multiple devices and through multiple
  network environments. Together with the agent's TLS failures inside and
  outside the sandbox, this indicates an external availability problem beyond
  this single execution environment; its precise cause is unverified. The
  current Nix checks passed using the user's temporary remote USTC mirror-source
  configuration. This does not establish restoration of the original endpoint.
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
- The first node is committed as `a3ba241`: a pure analysis phase resolves local
  headline/CUSTOM_ID/ID and paragraph dedicated-target links against the owned
  AST, returning identity-keyed label/link mappings consumed by local lowering.
  Missing/ambiguous targets fail in preflight; no external ID lookup is used.
- Final full ERT passed 210/210 with exit status 0; all ten package modules
  byte-compiled without warnings under Emacs 31.1 / Org 9.8-pre. Native
  label/reference readback, prepared input after source-buffer disposal,
  filtering, ambiguity, STM label collisions, low headlines, target priority,
  and broken-link preflight are covered. `memory/evidence.md` records the
  original worktree diff provenance and original Nix/package-lint gaps; the
  newer expanded-worktree checks below passed with the temporary configuration.
- The committed five-file diff matches the previously verified SHA-256 exactly.
- With explicit authorization to read five installed Org source files, source
  inspection and a focused Org 9.8-pre helper probe established that input-file
  identity and effective `default-directory` are distinct. Visiting a file does
  not override an explicitly changed effective directory. Relative paths remain
  relative in `org-export-file-uri` and the publishing relative-name helper.
- The source-location node retains explicit `source-file` and `resource-base` strings
  through owned input and pure lowering. Preparation expands home abbreviations
  once and checks copied original source-location strings across worker waits
  and lowering. Pure construction accepts absolute explicit strings or nil,
  preserves spelling/symlinks, and does not run file handlers or expand paths.
- The name `source-directory` was abandoned because it is an Emacs special
  variable and interfered with constructor/copy bindings. A full regression run
  also exposed legitimate `~/...` source directories; preparation now expands
  them once rather than rejecting ordinary buffers. Final full ERT passed
  217/217 and all modules compiled without warnings. Then Nix flake checking
  passed, including package-lint, package building and 217/217 installed-package
  ERT, using the user's temporary mirror-source configuration. File-link
  lowering/native path translation remain later work.
- Archive selection followed `org-texmacs-gaw-archive`: this node's temporary
  artifacts are regenerable bytecode caches; upstream probe conclusions and
  provenance are fully in evidence, and snapshot behavior is maintained in ERT.
  No separate archive snapshot is needed. The temporary overlay itself must
  not be committed or pushed; only its validation conditions are recorded.

## Next actions

1. Review the six-file source-location node diff; exclude the user's temporary
   `flake.nix` overlay from staging/commit. The project changes remain uncommitted.
2. Design resource targets/native path translation, including the boundary
   for file searches, tilde/remote paths, and consumer output destinations.
   Named footnotes and citations/bibliography remain later DOC-01 nodes.
3. When a later fresh Codex session starts without user-supplied `AGENTS.md`,
   check whether it discovers the root bootstrap and project skill, then
   recovers active GAW memory without the historical archive. Mark this
   nonblocking check complete when observed; continue project work meanwhile.
