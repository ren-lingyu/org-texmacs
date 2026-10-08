# org-texmacs current memory

## Active objective

Bounded ox-texmacs dispatcher frontend is committed as
be284dd292cfb0a88ae51f0e6b692f94516f0bb1. Its complete six-file diff matches
the verified hash. The Org/ox-latex output convention extension is committed
as b4ee215224578577a3235f8954020baf74e585af; its complete five-file diff matches
the verified hash exactly. Subtree export/configuration/dependency node is now
complete, verified and staged with approval. tmp/commit.md is reviewed; await
the user's ordinary commit and verify its six-file diff on baseline b4ee215.
Selection is a source integer in owned full-source preparation. Root heading
provides title/EXPORT_* overrides and is omitted from the body. Used footnotes
and explicit bibliography come from the same snapshot; scope-external targets
fail. Region/visible/body-only/async and generic API adaptation remain deferred.
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
The staged frontend supports synchronous whole-buffer/subtree actions. Generic
string export/publishing, preprocessing and broader selection remain unsupported.

## Baseline and staging

- Main HEAD observed on 2026-10-08:
  `b4ee215224578577a3235f8954020baf74e585af`.
  Its output-convention diff against be284dd matches the verified five-file hash.
- Frontend commit be284dd is verified against baseline b5100a9 hash d41f05a2...
  as recorded in evidence. Current approved/staged files: README.org,
  org-texmacs-context.el, org-texmacs-document.el, org-texmacs.el, ox-texmacs.el,
  tests/ert/ert.el. Full staged review and diff --check pass. SHA-256 on b4ee215:
  3be6de01e224286021f2b3361f14098efae89208ad72db0660fad81a73e73090.
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

## Verified subtree node

- Source adapters accept optional third subtree-position after bibliography
  texts; nil keeps whole-buffer behavior. No new public input slot or worker
  reinterpretation of Org is added. Snapshot configuration/used footnotes are
  captured before structural clipping and native requests.
- Supported title/author/date/options/select/exclude/file-name EXPORT fields
  use Org helpers and captured property lookup settings; root metadata is absent
  from body. Unknown root EXPORT fields/options and CITE_EXPORT fail explicitly.
- Out-of-scope body/unused definitions are not converted. Restored definitions
  may precede the selected body in source; span matching follows clipped AST
  traversal and bounds. Relative source/file resource identities stay intact.
- Source point moves cannot redirect selection. Property settings mutations
  across native waits reject output. A private marker and save-excursion keep
  property/output-name helpers from disturbing live source state.
- Final subtree focused 7/7 (9.53s), backend regression 11/11 (4.65s), and final
  Nix all seven checks pass, with compilation/package-lint and installed ERT
  291/291 (132.40s). Tests assert structure/bytes/contracts, not layout goldens.
  Related local Org fragments and repeated focused 120s / Nix 180s checks were
  authorized. Earlier dependency-span failure and a definition-like citation
  fixture were corrected; maintained cases retain reproduction.
- No necessary unique raw artifact needs archive. Tests regenerate fixtures;
  only pure text enters GAW and binary PDF/bytecode never does.

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
  history. Current whole installed regression is 291/291; GUI layout/general
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
   against its five-file hash recorded in evidence. Subtree node is verified /
   staged; await its commit and compare the six-file diff to 3be6de01... above.
   Keep the mirror overlay excluded; no flake or lock changes belong to this node.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
