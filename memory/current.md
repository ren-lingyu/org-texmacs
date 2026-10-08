# org-texmacs current memory

## Active objective

Bounded ox-texmacs dispatcher frontend is committed as
be284dd292cfb0a88ae51f0e6b692f94516f0bb1. Its complete six-file diff matches
the verified hash. The Org/ox-latex output convention extension is committed
as b4ee215224578577a3235f8954020baf74e585af; its complete five-file diff matches
the verified hash exactly. Subtree node is committed as
ee3e028fb829d508333fda40c705d811f4b2583e;
its six-file diff matches the reviewed hash on b4ee215. Region export is now
complete, verified and staged with exact-path approval. tmp/commit.md is reviewed;
await ordinary commit, then compare its six-file diff on baseline ee3e028 to
22765b0bf802059c2edb49fb3f8a549751b1240c17b43cd8bae419eb4827da58.
Active region selects body; subtreep still supplies configuration/naming. Private
full snapshot supplies global context and dependencies; private narrowed Org
parsing supports exact ordinary text ranges. Truncated STM islands fail before
workers. Other frontend flags and generic API adaptation remain deferred.
After commit verification, assess bounded body-only semantics as the next node.
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
The staged frontend supports synchronous whole-buffer/subtree/region actions.
Generic string export/publishing, preprocessing and visible-only/narrowed-source
selection remain unsupported.

## Baseline and staging

- Main HEAD observed on 2026-10-08:
  `ee3e028fb829d508333fda40c705d811f4b2583e`.
  Its subtree diff against b4ee215 matches the verified six-file hash.
- Frontend commit be284dd is verified against baseline b5100a9 hash d41f05a2...
  as recorded in evidence. Six region files are approved/staged;
  subtree files are committed.
  Full staged review and diff --check passed. Region SHA-256 on ee3e028:
  22765b0bf802059c2edb49fb3f8a549751b1240c17b43cd8bae419eb4827da58.
  No implementation is unstaged. The user's temporary
  `flake.nix` overlay remains excluded. It rewrites
  GNU ELPA fetchurl URLs to the remote USTC mirror. The configuration is retained
  locally only: never stage, commit or push that overlay. It is not a locally hosted mirror.
  Overlay SHA-256: `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
  Restoring the pre-fileset baseline/diff metadata reproduces that exact hash.
  Current raw unstaged flake diff SHA-256 is dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
- Local v0.3.1 annotated tag resolves to `880d4e00667907ef66985387b4865ec8d795d48d`.
  Later DOC-01/CONSUMER-01 features are local development, not release claims.
  Remote publication/signature remain unverified; release evidence is in evidence.md.

## Verified region node

- Five source preparation/document/byte/buffer adapters add optional fourth
  REGION, an owned nonempty integer pair after subtree-position. Region selects
  body with priority; subtree options/naming still apply when requested.
- Private narrowed parsing of the same full masked snapshot supports partial
  ordinary text without selected-text reconstruction or live source narrowing.
  Global configuration and explicit bibliography identities survive selection;
  selected footnote identity reconciliation prevents duplicate imports.
- Complete STM islands run only in emitted body/dependencies; truncated islands
  fail before workers. Scoped filtering/links and source provenance stay fixed.
  Point/mark/pair changes cannot redirect conversion; source edits reject output.
- Region 7/7 (14.17s), subtree 7/7 (10.79s), backend 11/11 (5.47s), and Nix all
  seven checks pass. Compilation/package-lint and installed ERT 298/298 (162.69s)
  pass. Structural/text/byte/contract assertions have no layout goldens.
- Per-node targeted Org reads and repeated focused 120s / Nix 180s checks were
  authorized. Initial footnote fixtures needed heading delimiters; one new
  82-column docstring failed compilation before wrapping. Final checks pass.
- No unique necessary raw artifact needs archive; maintained ERT retains full
  reproduction. Only pure text enters GAW; no PDFs, bytecode or generated caches.

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
  history. Current whole installed regression is 298/298; GUI layout/general
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
   verified/staged; await commit and compare its six-file diff
   to 22765b0b... above. Then assess bounded body-only semantics.
   Keep the mirror overlay excluded; no flake or lock changes belong to this node.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
