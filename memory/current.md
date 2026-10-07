# org-texmacs current memory

## Active objective

The user-selected native rendering/PDF CONSUMER-01 node is complete within its
documented subset, with explicit output ownership and failure handling.
PDF implementation is verified and staged with approval. tmp/commit.md contains
the reviewed message. Await the user's ordinary commit, then verify its diff.
Interactive commit `1ed04db` is verified; the temporary mirror remains excluded.

## Baseline and staging

- Main HEAD observed on 2026-10-08:
  `1ed04db7d5635d4851f78bf89c2bb72e9693312a`.
  Its three-file interactive diff matches the previously verified hash exactly.
- Committed node: `README.org`, `org-texmacs.el`, `tests/ert/ert.el`.
  Diff SHA-256: `3f3a1f61d1f0b24ad984c6723ada568ec12a5b8015a9de968200ac32e9878d51`.
  Full staged review and diff --check passed before commit.
- Approved/staged PDF files: README.org, org-texmacs-core.el,
  org-texmacs-session.el, org-texmacs-worker.scm, org-texmacs.el,
  tests/ert/default.nix and tests/ert/ert.el. Full staged review and diff --check
  passed. No implementation is unstaged. The user's temporary
  `flake.nix` overlay remains excluded. It rewrites
  GNU ELPA fetchurl URLs to the remote USTC mirror. The configuration is retained
  locally only: never stage, commit or push it. It is not a locally hosted mirror.
  Overlay SHA-256: `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
- Local v0.3.1 annotated tag resolves to `880d4e00667907ef66985387b4865ec8d795d48d`.
  Later DOC-01/CONSUMER-01 features are local development, not release claims.
  Remote publication/signature remain unverified; release evidence is in evidence.md.

## PDF node and limits

- Completed-document PDF bytes/save and explicit-source PDF bytes/file/M-x
  adapters use the existing encoding and exclusive new-file writer. Source
  consistency is checked after native rendering, before writing final output.
- Headless rendering installs structured fields directly in a temporary native
  buffer, updates synchronously three times and calls native print-to-file.
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
- No generic Org backend/dispatcher, unrestricted preprocessing, overwrite,
  backup, atomic publication or native preview is implemented.
  File writes remain exclusive new-file creation; write errors can leave a
  partial new file. Source adapters guard through serialization before writing.

## Validation

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

1. Await the user's project commit; compare its seven-file diff against the
   verified staged SHA-256 on baseline 1ed04db:
   00164bbb3491e4addd74c75a0c53ab86cd8397855e659c25a572a5ae84044464.
   tmp/commit.md is the reviewed message. Keep flake.nix excluded.
   Related installed print/file/document-update Scheme reads and focused/full
   ERT plus Nix checks (timeout 120s) are authorized for this node. Tests may
   generate PDF only in isolated temporary directories; no binary enters GAW.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
