# org-texmacs current memory

## Active objective

CONSUMER-01 interactive file/buffer export is implemented, verified and staged
with approval. `tmp/commit.md` contains the reviewed message. Await the user's
ordinary project commit, then verify its diff before continuing the plan.

## Baseline and staging

- Main HEAD observed on 2026-10-07:
  `ee225ad62ffedf529239f7a31fd4cc73e9743519`.
  Its four-file adapter diff matches the previously verified hash exactly.
- Approved staged node: `README.org`, `org-texmacs.el`, `tests/ert/ert.el`.
  Diff SHA-256: `3f3a1f61d1f0b24ad984c6723ada568ec12a5b8015a9de968200ac32e9878d51`.
  Full staged review and diff --check passed; no implementation is unstaged.
- Only the user's temporary `flake.nix` overlay remains unstaged. It rewrites
  GNU ELPA fetchurl URLs to the remote USTC mirror. The configuration is retained
  locally only: never stage, commit or push it. It is not a locally hosted mirror.
  Overlay SHA-256: `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
- Local v0.3.1 annotated tag resolves to `880d4e00667907ef66985387b4865ec8d795d48d`.
  Later DOC-01/CONSUMER-01 features are local development, not release claims.
  Remote publication/signature remain unverified; release evidence is in evidence.md.

## Implemented node and limits

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
  backup, atomic publication, native preview or rendering is implemented.
  File writes remain exclusive new-file creation; write errors can leave a
  partial new file. Source adapters guard through serialization before writing.

## Validation

- User authorized repeated focused/full ERT and Nix checks for this node, each
  timeout 120s. Sixteen focused serialization/save/export cases pass.
- Initial local non-worker bucket reached 251/254 then timed out at 120s, with
  no observed failure. Complete local coverage then passed disjoint document
  105/105 (43.83s), non-document/non-worker 149/149 (71.53s), worker 11/11 (11.88s).
  Prefer those smaller disjoint selectors for subsequent full local checks.
- Final Nix passes all seven checks including compilation/package-lint and
  installed ERT 265/265 (104.35s), using the unchanged temporary mirror overlay.
  A preceding build rejected wide new docstrings; only their wrapping changed.
- Display/prompt behavior is simulated in batch tests. Tests cover native bytes,
  fresh view ownership, mode-hook isolation, cleanup, prompt context switches and
  invalid-source preflight. Actual GUI layout/rendering remain unverified.
- No independent necessary raw temporary artifact was created. Generated test
  files/buffers are maintained, regenerable fixtures; no new archive is needed.

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

1. Await the user's commit of this three-file node; compare against the staged
   hash above. Keep flake.nix excluded.
2. Review dispatcher policy and replacement/backup/atomic-publication boundaries,
   followed by native rendering/preview as adopted consumer work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
