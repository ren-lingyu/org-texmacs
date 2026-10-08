# org-texmacs current memory

## Active objective

Bounded ox-texmacs dispatcher frontend is committed as
be284dd292cfb0a88ae51f0e6b692f94516f0bb1. Its complete six-file diff matches
the verified hash. The Org/ox-latex output convention extension is committed
as b4ee215224578577a3235f8954020baf74e585af; its complete five-file diff matches
the verified hash exactly. Index is empty; next-node selection is pending.
Recommend the next bounded frontend node be synchronous subtree export.
First establish Org-compatible selection/title/EXPORT_* and dependency rules;
capture subtree selection in owned preparation, not by casually narrowing the
live source. Resolve used footnotes and links against explicit owned context,
and define errors for dependencies outside the selected export scope. Keep
region/visible/body-only/async as separate boundaries. This is a proposal,
not adoption or implementation/check authorization.
Frontend uses org-export-output-file-name and ordinary overwrite after checked
native bytes are complete. Public new-file-only APIs stay exclusive. Atomic
replacement, backups and target-version locking are not adopted prerequisites.
User rejected a standalone PDF preview command; no such command is adopted.
The frontend only supports whole-buffer synchronous menu actions. Generic
string export/publishing, preprocessing and broader selection remain unsupported.

## Baseline and staging

- Main HEAD observed on 2026-10-08:
  `b4ee215224578577a3235f8954020baf74e585af`.
  Its output-convention diff against be284dd matches the verified five-file hash.
- Frontend commit be284dd is verified against baseline b5100a9 hash d41f05a2...
  as recorded in evidence. Committed output-convention files: README.org,
  org-texmacs-context.el, org-texmacs-session.el, ox-texmacs.el, tests/ert/ert.el.
  Full staged review and diff --check pass. SHA-256 on baseline be284dd:
  846a14267176678abb8ebda9c7097c12076e55563a8235ec0beb323d574de410.
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

## Committed Org output convention extension

- File actions use Org's naming helper for EXPORT_FILE_NAME/visiting stem/prompt
  and suffix enforcement, with captured source working directory. Preparation
  consumes output metadata without adding it to the native body.
- Captured local writable regular-or-absent targets are checked before and
  after conversion; known symlinks/directories/source aliases fail. Bytes finish
  under source consistency checks before opening output. Only the frontend
  enables private overwrite; public new-file APIs remain exclusive.
- Ordinary writes use no-conversion and suppress annotations/format handlers.
  Preparation/render/stale-source failure preserves old output. Write failure
  may leave partial overwritten output; no backup, atomicity or locking guarantee.
- Focused backend ERT passes 11/11 (5.32s); final Nix passes all seven checks,
  compilation/package-lint and installed ERT 284/284 (125.71s). Local installed
  Org naming/write-helper reads and repeated focused 120s / Nix 180s checks were
  authorized for this node. All temporary fixtures are maintained/regenerable;
  no unique raw artifact qualifies for archiving. Only pure text enters GAW.

## Initial committed dispatcher frontend

- Optional require ox-texmacs registers texmacs and menu T T/T t/T p for readonly
  byte buffer/new .tm/new PDF. Core loading alone does not install the frontend.
- Standard optional arguments are accepted syntactically but all non-nil values,
  active region/narrowing/non-Org sources fail before conversion or prompts.
  No bibliography files are read; explicit snapshots remain on existing Lisp APIs.
- Actions call owned source/native consumers directly. An early conditional
  org-export-before-processing-functions hook rejects generic string export for
  texmacs/derivatives before INCLUDE/macros/Babel. Other backends remain usable.
- New-file prompts capture source identity; display follows Org's temporary
  export buffer setting and failure removes only the new output view.
- Seven focused cases pass 7/7 (2.63s). Final Nix passes all seven checks,
  compilation/package-lint and installed ERT 280/280 (123.36s). Org source reads,
  focused ERT 120s and full Nix 180s were authorized for this node. Prompt/display
  behavior is simulated; real native .tm/PDF and unrelated ASCII export are covered.
- No necessary unique raw artifact needs archiving. The tmp fileset staging patch
  is regenerable from the project diff; only pure text enters GAW, never PDF/bytecode.

## PDF node and limits

- Completed-document PDF bytes/save and explicit-source PDF bytes/file/M-x
  adapters use the existing encoding and exclusive new-file writer. Source
  consistency is checked after native rendering, before writing final output.
- Headless rendering installs structured fields directly in a temporary native
  buffer, updates synchronously three times and calls native print-to-file;
  the verified working-tree fix then updates three times and prints the final PDF.
  No .tm intermediary is reparsed; existing public session state is unchanged.
- Temporary PDFs live in the private worker directory; normal/error cleanup
  closes the buffer and removes the file. Cleanup failure stops the worker;
  worker stop removes its directory. Font caches retain normal native lifetime.
- Native rendering errors preserve healthy transport. Invalid PDF envelopes or
  cleanup failures stop it. Explicit image/include/extern/script/action/eval/
  raw-data trees are outside this subset. Installed styles/fonts are still
  resources, and custom styles are not sandboxed. No bibliography generation
  or automatic bibliography reads are introduced.
- Three updates resolve the maintained heading/table reference examples, not
  every possible layout. Visual layout, GUI preview and general convergence
  remain unverified. Poppler is an installed-test dependency only.

## Committed interactive frontend

- `org-texmacs-export-to-buffer` exports an explicit source to a fresh readonly
  unibyte special-mode buffer with no-conversion coding, no file format/visiting
  file/save offer. It owns derived native bytes and retains no source pointer.
  Lisp calls return without displaying; M-x captures current unnarrowed Org and
  displays after successful source checking. Existing views are never reused.
- Initialization suppresses mode hooks/change callbacks; failure removes only
  the newly allocated view. This is native source inspection, not GUI typesetting.
- `org-texmacs-export-to-file` now supports M-x. It captures source/directory
  before prompting, suggests the visiting file stem or export.tm, and uses the
  existing checked source export/new-file writer. Invalid/non-Org/narrowed
  sources fail before prompts; remote working directories are outside this chooser.
- Interactive commands pass nil bibliography snapshots. Explicit BibTeX text
  snapshots remain Lisp arguments; do not introduce automatic bibliography reads.
- These standalone APIs provide no generic string pipeline, preprocessing,
  overwrite, backup, atomic publication or native preview.
  File writes remain exclusive new-file creation; write errors can leave a
  partial new file. Source adapters guard through serialization before writing.

## Current semantic-node validation

- Tests normalize Poppler UTF-8 extraction, use short synthetic text in isolated
  native configurations and assert exact marker identities/unique bodies or
  bibliography titles. No bytes, pixels, coordinates or fixed pagination.
- Final focused checks use cached Poppler exec-path and pass 8/8 (19.27s),
  including both print phases' failure/recovery. Final Nix passes all seven
  checks with installed ERT 273/273 (122.88s), compilation and package-lint.
  Nix timeout is 180s for this node; sandbox initially denied daemon access,
  and the same authorized command was approved outside sandbox.
- All diagnostic behavior is reproducible from maintained tests/native repair;
  no necessary independent temporary artifact qualifies for archiving. Only
  pure text may enter GAW; binary PDFs remain test temporaries.

## Previous PDF consumer validation

- This PDF node has explicit repeated focused/full ERT and Nix authorization,
  timeout 120s. All six PDF cases pass, including malformed output, source
  changes during rendering, real printing failure/recovery, owned file cleanup
  and fatal cleanup worker disposal, plus actual interactive source export.
  Full local disjoint groups pass 105/105 (47.67s), 155/155 (88.28s), and
  11/11 (12.81s): 271 total, no unexpected results.
- Final Nix passes all seven checks (six cached, final ERT rebuilt), including
  compilation/package-lint and installed ERT 271/271 (116.48s) with mandatory
  Poppler PDF inspection: positive page count, heading/table numeric references
  and literal Unicode. A preceding final run timed out at installed ERT 268/271;
  the explicit authorized one-run retry passed. Initial cold dependency/build
  run also timed out. All checks used the unchanged temporary mirror overlay.
- All probes are maintained/regenerable ERT fixtures. No independent necessary
  temporary artifact needs archiving, and PDF binaries never enter GAW.

Prefer the three smaller disjoint local selectors above; the old combined
bucket can exceed 120s. Prompt/display interactions are simulated in batch;
native printing and independent PDF inspection are real. GUI layout is unverified.

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
   against the five-file hash 846a1426... above. Await the next-node selection.
   Keep the mirror overlay excluded; no flake or lock changes belong to this node.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
