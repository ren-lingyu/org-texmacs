# org-texmacs current memory

## Active objective

v0.4.0 preparation is committed as c26985f8f24ce8c6b95ebf3dbb211fff8e276f45.
Its complete three-file diff on baseline 82552db matches
84b212a7b1b9c74e1309067a10d0a932ed70b93b0f3b541fba40f83ff906ce33.
README.org, org-texmacs.el and only flake.nix version line are committed. Header/Nix
versions are 0.4.0. README summarizes current document semantics/native consumers,
optional frontend, scopes/configuration, compatibility and deferred boundaries.
tmp/commit.md and tmp/release-v0.4.0.md are reviewed. Release notes remain a draft;
Metadata commit is verified; local v0.4.0 tag is absent. User explicitly requests
holding tag/publication while they review. Current next action is wait for user
review findings or an explicit instruction to resume release steps. Do not start
new implementation, checks, tag or publication work meanwhile. No tests were
rerun for this commit-state update. Ordinary tags/push/publication remain user-owned.
Narrowing commit 82552db matches its reviewed six-file hash on d71204d. Nineteen
feature/fix commits since v0.3.1 form the chosen scope: current bounded DOC-01
resolution plus .tm/PDF and synchronous dispatcher/naming/scope/configuration.
Visible-only/async, body-only fragments and generic API/publishing remain deferred
or separate. No full Org syntax parity, GUI layout or general pagination claim.
Do not interpret prepared package version or passing tests as a published release.
Scope guidance: ox-latex is a reference for shared Org export conventions,
not a feature inventory to copy wholesale. Current ox-texmacs is a bounded
dispatcher frontend, not a complete generic exporter: org-export-as and related
generic entry points still reject texmacs. Common selection/configuration/API
compatibility needs staged design under AST-first/owned-input constraints;
LaTeX-only compilation, templates and package controls are not project duties.
User places generic org-export-as API compatibility relatively late: treat it
as nonblocking later adaptation, not a prerequisite for subtree/configuration
work. Existing dispatcher and explicit source APIs provide the working path;
retain explicit rejection of unsupported generic calls until adaptation exists.
Unsupported syntax and deferred multi-session/incremental/editor conveniences
must not be presented as mandatory remaining work.
Frontend uses org-export-output-file-name and ordinary overwrite after checked
native bytes are complete. Public new-file-only APIs stay exclusive. Atomic
replacement, backups and target-version locking are not adopted prerequisites.
User rejected a standalone PDF preview command; no such command is adopted.
The frontend supports synchronous buffer/subtree/region/narrowing actions.
Generic string export/publishing, preprocessing and visible-only selection
remain unsupported.

## Baseline and staging

- Main HEAD observed on 2026-10-08:
  `c26985f8f24ce8c6b95ebf3dbb211fff8e276f45`.
  Its release-preparation diff against 82552db matches the verified three-file hash.
- Three release paths are committed: README.org, org-texmacs.el and
  flake.nix (version hunk only). Index is empty; staged review/diff --check passed.
  SHA-256 on 82552db:
  84b212a7b1b9c74e1309067a10d0a932ed70b93b0f3b541fba40f83ff906ce33.
  No release changes remain unstaged. The user's temporary
  `flake.nix` overlay remains excluded. It rewrites
  GNU ELPA fetchurl URLs to the remote USTC mirror. The configuration is retained
  locally only: never stage, commit or push that overlay. It is not a locally hosted mirror.
  Overlay SHA-256: `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
  Restoring pre-fileset/pre-release version and diff metadata reproduces that hash.
  Current raw unstaged flake diff SHA-256 is
  2af6574fe8302fa7a5e64d3e93e8955cf7c36f0a4c6c2f135a2edffe8b65032a.
  Normalizing version context and blob IDs to pre-release values reproduces
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc exactly,
  proving the mirror content is unchanged. Committed flake equals baseline plus
  its single version line; overlay is excluded.
- Local v0.3.1 annotated tag resolves to `880d4e00667907ef66985387b4865ec8d795d48d`.
  v0.4.0 includes current DOC-01/CONSUMER-01 subset but is only prepared,
  not tagged or published. Earlier features are still local development until release.
  Remote publication/signature remain unverified; release evidence is in evidence.md.

## Verified release preparation

- User selected v0.4.0; no new source semantics are introduced in this node.
  Package header and Nix trivialBuild version agree; native TeXmacs version header
  remains tied to running TeXmacs and is not replaced with package version.
- All seven Nix checks pass for emacs-org-texmacs-0.4.0, compilation/package-lint
  and installed ERT 311/311 (155.04s). README loading examples are covered by
  installed tests. Repeated exact Nix 240s checks were authorized for this node.
- Validation uses local/uncommitted remote ELPA mirror config. Original endpoint
  recovery is unverified; exclude overlay and lock changes from release commits.
  Other platforms, GUI layout and general pagination remain unverified.
- tmp/release-version.patch is a reviewed version-only staging aid. It was
  applied to index with approval; no direct ordinary commits/tags/pushes occurred.
- Release notes and patch are regenerable preparation artifacts, not GAW archive
  evidence. No necessary unique temporary evidence needs archive. Only pure text
  enters GAW; no binary packages/PDF/bytecode are included.

## Existing consumer boundaries

- Complete native .tm bytes/save, PDF bytes/save and readonly byte views already
  consume owned documents. Native encoding retains literal/STM/file provenance.
  Org remains canonical; no textual target intermediary is reparsed.
- Frontend writes use ordinary overwrite after source checking; write failure
  may leave partial output. Explicit new-file APIs retain exclusive creation.
- PDF uses owned temporary native buffer/file, bounded print/update/final-print
  phases and native font/style resources. Existing sessions are isolated; worker
  cleanup failure stops transport. Explicit resource/executable primitives are
  outside the PDF subset, and custom installed styles are not sandboxed.
- Earlier validation/progress details belong in project.md, evidence.md and GAW
  history. Current whole installed regression is 311/311; GUI layout/general
  pagination convergence are unverified. Use maintained structural/text checks.

## Persistent workflow and knowledge

- GAW `_agents` is valid/deployed at `.agents`; branch preservation/transfer is
  solved. Use public GAW interfaces, never lifecycle mutation without direction.
- `goals.md` is authoritative constraints; `project.md` is current architecture/
  support; `evidence.md` holds provenance and verification limits; `backlog.md`
  holds adopted/deferred/unresolved scope. Superseded progress stays in GAW history.
- Root AGENTS.md is an ignored generated bootstrap, reproducible through the
  namespaced governance skill. Retired GOALS.md/REVIEW.md and eligible historical
  probes are in the archive, not normal recovery inputs. INBOX.md remains ignored
  and untouched; its adopted plan was distilled without needing a raw copy.
- Only pure-text files may enter GAW memory, skills or archive. Archive necessary
  unique temporary evidence selectively via the archive skill; never bytecode,
  images, binary containers or regenerable caches.
- After each completed node, request exact-path project git add approval directly,
  then draft tmp/commit.md from the approved staged diff. Ordinary commits/pushes/
  tags/history changes remain the user's action. Preserve unrelated changes.
- Existing DOC-01 covers the critical cross-node architecture, enough for active
  CONSUMER-01. Broader unsupported Org syntax is not an automatic commitment.
  Keep pure lowering, owned snapshots, native encoding and consumers separate.

## Blockers and next actions

- No project-code blocker. Original GNU ELPA availability is not established:
  user reported failure across devices/networks; successful mirror checks do not
  prove endpoint restoration. Cause remains unverified; detailed evidence persists.

1. PDF commit db33c14 is verified against the seven-file SHA-256 on baseline 1ed04db:
   00164bbb3491e4addd74c75a0c53ab86cd8397855e659c25a572a5ae84044464.
   Semantic commit b5100a9 is now verified by its three-file diff SHA-256
   against baseline db33c14. Frontend commit be284dd is now verified against
   d41f05a2... as recorded in evidence. Naming/reexport commit b4ee215 is verified
   against its five-file hash recorded in evidence. Subtree commit ee3e028 is
   verified against the six-file diff hash 3be6de01... above. Region is
   committed as 7e6b4e0 and verified against six-file hash 22765b0b... above.
   Override commit d71204d is verified against five-file diff 145a3237... above.
   Narrowing commit 82552db is verified against six-file diff fdeb09f1... in
   evidence. v0.4.0 preparation commit c26985f is verified against three-file
   diff 84b212a7... above. User review is pending; hold tag/publication and further
   work until user feedback or an explicit resume instruction. Body-only
   fragment/generic API remain deferred by user choice.
   Keep the mirror overlay excluded; only the Nix version hunk belongs to
   this node, with no lock changes.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
