# org-texmacs current memory

## Active objective

Bounded ox-texmacs dispatcher frontend is committed as
be284dd292cfb0a88ae51f0e6b692f94516f0bb1. Its complete six-file diff matches
the verified hash. The Org/ox-latex output convention extension is committed
as b4ee215224578577a3235f8954020baf74e585af; its complete five-file diff matches
the verified hash exactly. Subtree node is committed as
ee3e028fb829d508333fda40c705d811f4b2583e;
its six-file diff matches the reviewed hash on b4ee215. Region export is committed
as 7e6b4e001603a223933277d2704018877b86bada; its complete six-file diff on
baseline ee3e028 matches
22765b0bf802059c2edb49fb3f8a549751b1240c17b43cd8bae419eb4827da58.
Active region selects body; subtreep still supplies configuration/naming. Private
full snapshot supplies global context and dependencies; private narrowed Org
parsing supports exact ordinary text ranges. Truncated STM islands fail before
workers. Visible/body-only/async and generic API adaptation remain deferred.
Restricted ext-plist node is committed as
d71204d204a03b30491d5cdb2bd05d59dacd71a3; its complete five-file diff on
baseline 7e6b4e0 matches
145a3237df23501289289bbfe84554353dfc8d0147d7d2787ff090bb953b83a6.
External overrides are owned before prompts/workers; priority is global <
external < file < subtree. Only existing context keys are accepted, with typed
policies and raw Org string/nil metadata. Body-only is deferred by user choice:
Org skips outer templates, but complete native consumers define no embeddable
fragment format. Generic API adaptation stays deferred. User asked for next work
and remaining scope. Recommend bounded narrowed-buffer export next: reuse the
owned full snapshot/dependency machinery and preserve original restriction while
selecting accessible body. This recommendation is not yet implementation adoption
or check authorization. Visible-only and other Org flags remain separate design
questions; stage closure/release scope can follow common selection support.
Do not treat every unsupported feature as a mandatory completion requirement.
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
The committed frontend supports synchronous whole-buffer/subtree/region actions.
Generic string export/publishing, preprocessing and visible-only/narrowed-source
selection remain unsupported.

## Baseline and staging

- Main HEAD observed on 2026-10-08:
  `d71204d204a03b30491d5cdb2bd05d59dacd71a3`.
  Its override diff against 7e6b4e0 matches the verified five-file hash.
- Frontend commit be284dd is verified against baseline b5100a9 hash d41f05a2...
  as recorded in evidence. Region and five override files are committed:
  README.org, org-texmacs-context.el, org-texmacs.el, ox-texmacs.el, tests/ert/ert.el.
  Index is empty. Complete staged review and diff --check passed. SHA-256 on 7e6b4e0:
  145a3237df23501289289bbfe84554353dfc8d0147d7d2787ff090bb953b83a6.
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

## Verified external configuration node

- Five source adapters add optional fifth EXT-PLIST; dispatcher uses its existing
  fifth parameter. Validation/copy precedes preparation or frontend prompts.
  Unknown/duplicate keys, improper/cyclic lists and invalid values reject before
  workers, even if later settings would override them. Output/style/initial/
  parser/hooks/filter/bibliography fields remain excluded.
- Metadata is parsed in private keyword grammar and retains presence without file
  metadata keywords. Pure lowering consumes owned INFO. Caller plist/string/tag
  mutations during prompts/native waits affect only later calls.
- Final override focused 6/6 (7.33s), backend 11/11 (5.34s), subtree 7/7 (10.07s),
  region 7/7 (12.45s) and Nix all checks pass. Compilation/package-lint and final
  installed ERT 304/304 (169.37s) pass. Final Nix reruns two changed checks, using
  the other five already passing results. Assertions have no layout goldens.
- Per-node Org template/option reads and focused 120s / Nix 240s checks were
  authorized. Two 81-column docstrings were wrapped after compilation rejected
  them. Mutable test data now allocates fresh lists; final full checks include it.
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
  history. Current whole installed regression is 304/304; GUI layout/general
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
   Proposed next is narrowed-source scope; user adoption is pending. Body-only
   fragment/generic API remain deferred by user choice.
   Keep the mirror overlay excluded; no flake or lock changes belong to this node.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
