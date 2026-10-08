# org-texmacs current memory

## Active objective

Narrowing export node is complete, verified and staged with exact-path approval.
Await user's ordinary commit, then compare its six-file diff on baseline
d71204d204a03b30491d5cdb2bd05d59dacd71a3 with
fdeb09f1bd80199c367eb7c605c2d68ec5383dad1c0bdf616fe9b3ccbd05c39d.
tmp/commit.md is reviewed. Subtree/region/ext-plist nodes are already committed;
ext-plist commit d71204d matches its verified five-file hash recorded in evidence.
Narrowing is the outer body boundary; region wins within it, otherwise intersect
subtree body. Full source copy restores restriction before parsing/callbacks;
private snapshots supply global configuration and required dependencies. Hidden
headings/naming metadata use private copies and prompts use original restriction.
Captured bounds are checked after waits; external changes are rejected, not undone.
Empty narrowing is allowed; explicit region remains nonempty. Public signatures
are unchanged. Visible-only/async, body-only fragment and generic API stay separate
or deferred. After commit verification, review phase closure/release scope rather
than assuming every Org exporter flag must be implemented.
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
The staged frontend supports synchronous buffer/subtree/region/narrowing actions.
Generic string export/publishing, preprocessing and visible-only selection
remain unsupported.

## Baseline and staging

- Main HEAD observed on 2026-10-08:
  `d71204d204a03b30491d5cdb2bd05d59dacd71a3`.
  Its override diff against 7e6b4e0 matches the verified five-file hash.
- Six narrowing files are approved/staged: README.org, org-texmacs-context.el,
  org-texmacs-document.el, org-texmacs.el, ox-texmacs.el, tests/ert/ert.el.
  Complete staged review and diff --check pass. SHA-256 on d71204d:
  fdeb09f1bd80199c367eb7c605c2d68ec5383dad1c0bdf616fe9b3ccbd05c39d.
  No implementation remains unstaged. The user's temporary
  `flake.nix` overlay remains excluded. It rewrites
  GNU ELPA fetchurl URLs to the remote USTC mirror. The configuration is retained
  locally only: never stage, commit or push that overlay. It is not a locally hosted mirror.
  Overlay SHA-256: `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
  Restoring the pre-fileset baseline/diff metadata reproduces that exact hash.
  Current raw unstaged flake diff SHA-256 is dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
- Local v0.3.1 annotated tag resolves to `880d4e00667907ef66985387b4865ec8d795d48d`.
  Later DOC-01/CONSUMER-01 features are local development, not release claims.
  Remote publication/signature remain unverified; release evidence is in evidence.md.

## Verified narrowing node

- Existing source adapters/M-x/dispatcher accept narrowed sources. Core copies
  complete text with a brief saved restriction, then parses only private buffers.
  Boundaries are frozen/rechecked, including prompt paths. No new public slot,
  worker operation, external file read or general preprocessing is introduced.
- Scope composition is narrowing outer bound, explicit region priority, otherwise
  subtree intersection. Metadata/dependencies use full snapshot; empty body is
  valid, while explicit region is nonempty. Out-of-scope targets/truncated STM
  and unsupported preprocessing directives retain explicit preflight errors.
- Private heading/naming copy resolves hidden metadata. Filename is dynamically
  bound only for lookup; temporary copy is not a visiting buffer at disposal.
  File prompts run in original source outside private property bindings.
  Source narrowing/point/mark/properties/modified state retain isolation.
- Final narrowing 7/7 (10.09s), backend 11/11 (5.51s), serialization 16/16
  (17.77s), subtree 7/7 (9.89s), region 7/7 (12.38s), overrides 6/6 (7.50s)
  pass. Final Nix passes all seven checks, compilation/package-lint and installed
  ERT 311/311 (176.95s). Tests assert stable structure/text/bytes/contracts.
- Targeted Org reads and repeated focused 120s / Nix 240s checks were authorized.
  First full ERT was 310/311 because an updated legacy rejection test's expected
  body missed existing normalized trailing space/concat. Corrected assertion;
  final full check passes with final private filename binding.
- No unique necessary temporary artifact needs archive. Maintained ERT retains
  complete reproduction; no PDFs, bytecode or generated caches enter GAW.

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
   Narrowing node is verified/staged; await commit and compare six-file diff to
   fdeb09f1... above. Then review phase closure and release scope. Body-only
   fragment/generic API remain deferred by user choice.
   Keep the mirror overlay excluded; no flake or lock changes belong to this node.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
