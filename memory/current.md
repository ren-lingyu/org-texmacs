# org-texmacs current memory

## Objective

CONSUMER-01's explicit-destination new-file saving node is implemented, verified
and staged with approval. `tmp/commit.md` contains its reviewed message; await
the user's ordinary project commit. The temporary mirror overlay stays excluded.

## Current baseline

- Main HEAD observed on 2026-10-07:
  `e7377e5767ca38411a497a635d5053f1729a2d5a`.
- Local v0.3.0 tag target:
  `8c157d06b7a8793b0bd312e8f0c41612a3640388`.
- Local v0.3.1 annotated tag resolves to
  `880d4e00667907ef66985387b4865ec8d795d48d`.
- Both local-link and source-location nodes are committed. At the start of
  resource-target work the only ordinary worktree change was the user's
  temporary overlay. `INBOX.md` remains ignored and was not modified by the agent.
- The local-file node is committed; the ordinary worktree initially contains
  only the temporary `flake.nix` overlay, which remains excluded from commits.
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

- Commit `e7377e5` matches the verified serialization diff hash; only the user's
  unchanged overlay is dirty at saving-node start. The next bounded consumer
  saves to an explicit absolute native local path, preserving serialized bytes
  and source resource semantics. The first saving boundary creates new files
  only, rejects existing targets (including symlinks), and does not auto-create
  directories. Replacement/backup policy and Org export remain separate nodes.
  The user authorized repeated saving-node focused/full ERT and Nix checks,
  each with timeout 120s. Eight combined serialization/save focused tests pass.
  The save API completes serialization before exclusive local creation, copies
  the destination before waits, isolates coding/format/annotation/file-handler
  effects and preserves caller state. Standard filesystem errors propagate;
  partial new output can remain after a write error. Atomic publication and
  replacement/backup policy are not implemented. Full local coverage passes
  246/246 + 11/11 (106.47s and 11.91s); Nix's seven checks pass including
  compilation, package-lint and installed ERT 257/257 (94.49s). Three explicit
  project files are approved/staged, with no implementation left unstaged;
  evidence records the reviewed hash. No independent temporary artifact needs
  archiving. Only the unchanged temporary overlay remains unstaged.

- Commit `544e246` matches the named-table diff hash exactly; node start has
  only the user's unchanged overlay dirty. The bounded DOC-01 architecture now
  covers local links/IDs, file targets, named notes, default citations/native
  bibliography and table references. It is sufficient to start the adopted
  CONSUMER-01 work without requiring broader Org coverage. Remaining DOC-01
  variants retain explicit unsupported boundaries; do not claim all DOC-01
  syntax complete. The first consumer constructs full native file-document
  structure and returns native serialized text from explicit document fields,
  independently of a live session, without writing output files. Related
  installed conversion/version Scheme reads are explicitly authorized.
- The independent serialization node is committed as `e7377e5`: public
  org-texmacs-document-serialize consumes explicit native fields, constructs
  version/style/body/optional initial structure in the native bridge, and uses
  serialize-texmacs. Exact native output travels as ASCII hex and is returned
  as an unibyte string. It does not open output files or mutate a session.
  Domain serialization errors preserve the worker; bad payloads stop it.
  Four new maintained cases cover byte/protocol preflight, native file roundtrip,
  session independence, completed Org features and native error recovery.
  The user authorized repeated focused/full ERT and Nix checks for this node,
  each with timeout 120s. Final four focused cases pass, including exact native
  file tree roundtrip and session-state preservation. Full local coverage of the
  pre-adjustment code passed 242/242 + 11/11 (109.71s and 11.88s); final focused
  tests cover the obsolete-helper removal. Final Nix passed all seven checks including
  compilation/package-lint and installed ERT 253/253 (96.29s). Five explicit
  paths were staged and then committed, matching evidence's reviewed diff hash.
  No output file or necessary raw temporary artifact
  was created. Only the unchanged user overlay remains unstaged.

- Commit `fe6c435` matches the previously verified eight-file citation diff
  exactly. Only the user's temporary overlay is dirty at node start. With
  explicitly authorized installed TeXmacs reads, env-base/env-float confirm
  native big-table counters and caption-detailed long/short captions. This
  bounded node targets named/captioned tables; uncaptioned named tables require
  described links rather than an invented numeric reference. Other named
  elements, figures/resources and advanced table semantics remain separate.
- Named/captioned tables are implemented in the worktree. Five focused ERT
  cases pass, including caption ownership after source disposal, long/short
  multiline captions, described-only uncaptioned anchors, ambiguity/filtering,
  unsupported metadata preflight, static label collisions and native literal/
  file-path provenance readback. Caption nodes are now reachable for mapping
  retention. Full disjoint ERT passes 238/238 + 11/11 (98.61s and 12.20s), and
  Nix's seven checks pass including installed ERT 249/249 (87.27s), compilation
  and package-lint under the unchanged local-only mirror overlay. All five
  named-table files were approved/staged and then committed as `544e246`;
  the commit matches evidence's reviewed diff hash. Its former `tmp/commit.md`
  has been replaced by the reviewed current consumer message.
  No new temporary probe file was needed; installed-source observations and maintained regressions
  hold the semantic evidence.
- First full local/Nix runs caught eight existing footnote/citation regressions:
  the widened affiliated-keyword guard accidentally rejected intrinsic footnote
  `:label`. That guard now checks table-only affiliated keys only on tables.
  All 18 focused citation/named-footnote/named-table cases pass after the fix;
  final complete local and Nix runs pass as recorded above.

- The committed citation node binds explicit document bibliography declarations,
  resolves default bare ASCII-key groups in a pure footnote-aware plan, and
  prepares native plain output before public input construction. INFO owns a
  checked `(prefix keys selected-entries body)` view; pure lowering verifies
  the view and label set. Generated output retains source-semantic provenance.
  Native formatting preserves worker prefix/style/default-style state and
  returns domain errors without stopping healthy transport; invalid payloads
  stop it. Native Cork text is converted to source-compatible UTF-8 while ASCII
  notation remains intact. Global bibliography/export processors are not used.
  Styles, affixes, dependency fields, multiple prints and non-paragraph/inline
  footnote citation contexts remain explicit errors. Twelve focused tests pass.
  Full local testing passed 233/233 + 11/11 in disjoint selectors (117.17 and
  13.21 seconds) after the earlier 120-second timeout. Final Nix passed
  compilation, package-lint and installed ERT 244/244 (101.89 seconds). Eight
  explicit files were staged with approval, reviewed and hashed, then committed
  as `fe6c435`, matching that hash; the temporary overlay remains untouched.
- Foundation commit `8e1abf7` matches its verified seven-file diff exactly.
  Its recorded verification and constraints remain in evidence/project memory.
- Citations/bibliography design review established a usable low-level native
  path from explicit BibTeX text to `bib-entry` trees to `bib-list`, without
  bibliography files/database APIs. Native parsing recovers malformed input,
  so strict validation is required before claiming acceptance. Citation key
  ordering must traverse definition bodies at first footnote use, not physical
  definition order. The user selected explicit path-to-BibTeX-text snapshots.
  The committed foundation owns explicit source trees, validates local syntax
  before worker calls, checks native signatures and rechecks dependencies across
  waits. Default citation/keyword lowering is now implemented in `fe6c435`.
  Only related installed source reads are authorized, not user bibliography data access.
- Named footnotes now resolve within the owned AST snapshot. Separate and
  labeled inline definitions are collected before filtering; required removed
  definitions are reattached to the prepared AST without buffer fallback.
  First use emits a labelled native footnote body; later uses emit a superscript
  reference to its private anchor. Unused separate definitions and their worker
  requests are discarded. Missing/ambiguous definitions and nested references
  fail during preflight. The source's footnote-section setting is copied and
  rechecked; its special headline is omitted. Focused ERT currently passes
  14/14, including native tree round trips, block bodies and typed provenance.
  Full local ERT passes 232/232 (108.25 seconds). Nix checks pass with the
  unchanged temporary mirror-source configuration, including package-lint,
  compilation and installed ERT 232/232 (84.47 seconds). GUI numbering remains
  unverified. The later commit `a242eb2` matches the verified diff exactly.
- For this DOC-01 node (named footnotes), the user asked the agent to request
  path-specific `git add` approval directly after completing implementation,
  validation and review, then draft `tmp/commit.md` from the approved staged
  diff. Exclude the temporary overlay and unrelated changes. This instruction
  requests an approval workflow, not blanket staging authorization; ordinary
  project commits remain the user's action. The requested staging/message
  workflow is now complete.
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
  ERT, using the user's temporary mirror-source configuration. The file-link
  node below now consumes this context for its bounded local-file subset.
- Source-location archive selection followed `org-texmacs-gaw-archive`: that node's temporary
  artifacts are regenerable bytecode caches; upstream probe conclusions and
  provenance are fully in evidence, and snapshot behavior is maintained in ERT.
  No separate archive snapshot is needed. The temporary overlay itself must
  not be committed or pushed; only its validation conditions are recorded.

## Plain local file-link node

- Source-location commit `b09b451` matches the earlier verified six-file diff.
- Pure document analysis accepts plain local body file links without search
  options, application hints, tilde targets or remote context. Raw paths remain
  in body `hlink` nodes; new `file-paths` locate typed target leaves and compose
  with containers independently of STM provenance. Relative paths require an
  explicit captured base; no resource files are opened or read.
- The native bridge validates target roles, duplicates/bounds and STM
  separation, then rewrites only marked leaves on a copied body using the
  captured base. Ordinary native encoding remains in the existing worker;
  the Scheme protocol is unchanged. Reserved navigation/URL expression
  characters fail native preflight and preserve the healthy session/worker.
- Six new maintained cases passed in full ERT 223/223 (exit 0). Nix package,
  package-lint and installed-package ERT 223/223 also passed using the unchanged
  temporary, uncommitted remote mirror-source configuration. GUI following of
  links remains unverified. Evidence records the exact worktree diff hash.
- Three native URL probe artifacts are archived under
  `archive/2026-10-06T14-50-30Z--b09b451/`, in archive-only checkpoint `9d8d351`
  with exact project parent `b09b451`. Every artifact and manifest is plain text;
  no active memory, overlay or binary was included in that archive checkpoint.

## Next actions

1. Await the user's ordinary project commit of the three-file new-file saving
   node. Compare its diff with evidence's hash before marking it committed.
   Keep the temporary overlay out of commits and pushes.
2. Review replacement/backup/atomic-publication policy and the Org export
   frontend boundary as later CONSUMER-01 nodes. Remaining DOC-01
   general-reference/resource variants remain separately scoped; fuller Org
   coverage is not a prerequisite for consumer work.
   Citation styles/affixes, crossref dependencies, global bibliography/export
   configuration, broader resources and cross-file IDs retain explicit bounds.
3. When a later fresh Codex session starts without user-supplied `AGENTS.md`,
   check whether it discovers the root bootstrap and project skill, then
   recovers active GAW memory without the historical archive. Mark this
   nonblocking check complete when observed; continue project work meanwhile.
