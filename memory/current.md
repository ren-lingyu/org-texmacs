# org-texmacs current memory

## Active objective

v0.4.0 metadata is committed as c26985f8f24ce8c6b95ebf3dbb211fff8e276f45;
its three-file diff matches prior verified hash 84b212a7... in evidence. User
review/INBOX note led to an authorized finite HTML composition regression.
That node is complete, verified and staged: only tests/ert/ert.el (61 lines).
Await ordinary test commit; compare its one-file diff on c26985f with
4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
tmp/commit.md is reviewed. Production code/README/version remain unchanged.
Backend focused 12/12 and unmirrored installed ERT 312/312/all Nix checks pass.
Test proves actual HTML preprocessing hook/include advice/AST filter coexistence,
output effects, private source state and cleanup; it is not actual integration
of three Org-roam packages or personal databases. UUID syntax remains valid;
missing UUID-to-BibTeX-key mapping is a semantic interoperability boundary.
Future information flow is tracked in issue #1:
https://github.com/ren-lingyu/org-texmacs/issues/1. Issue was read via GitHub
connector; design is nonblocking for v0.4.0 and chooses neither full generic
export nor permanently isolated preparation. AST-first/owned inputs/provenance
remain constraints; preprocessing reuse is later adapter design.
User still holds tag/publication for review. No ordinary commits/tags/pushes
were executed. After test commit verification, wait for user review/resumption;
refresh release-note draft validation before actual publication if requested.
ELPA observation is now recorded with actual checks below; no confirmed endpoint
recovery claim. Earlier mirror-backed validations remain historical facts.
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

- Main HEAD observed on 2026-10-09:
  `c26985f8f24ce8c6b95ebf3dbb211fff8e276f45`.
  Its release-preparation diff against 82552db matches the verified three-file hash.
- Metadata paths README.org, org-texmacs.el and flake.nix version line are
  committed. Only tests/ert/ert.el is approved/staged; no production changes are
  unstaged. Complete staged review/diff --check pass. SHA-256 on c26985f:
  4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
- User temporarily removed the uncommitted USTC overlay on 2026-10-09. flake.nix
  matches HEAD; do not reintroduce or stage workaround automatically. Previous
  mirror-backed validation/exclusion proof stays in evidence as historical state.
- Local v0.3.1 annotated tag resolves to `880d4e00667907ef66985387b4865ec8d795d48d`.
  v0.4.0 includes current DOC-01/CONSUMER-01 subset but is only prepared,
  not tagged or published. Earlier features are still local development until release.
  Remote publication/signature remain unverified; release evidence is in evidence.md.

## Verified review supplement

- New ERT uses actual HTML exporter and controlled temporary preprocessing hook,
  around-advice on include expansion, and parse-tree filter. Their output effects
  are asserted. No user database/include dependency is loaded. Source state is
  unchanged, no TeXmacs worker request is allowed, and advice is always removed;
  after cleanup, baseline HTML output returns. No production/doc edits needed.
- Focused backend 12/12 (5.353570s), including new case (0.005854s), pass.
  Exact Nix 240s check without overlay passes, with installed ERT 312/312
  (157.819934s) and all check results successful; two changed checks run and the
  other results are cached. Per-node repeated focused/Nix checks were authorized.
- User also authorized two one-shot HEAD probes for ELPA index/org-9.8.8.tar.
  Both failed curl exit 28 after 20s connection timeout, no HTTP response; no
  retry. No credentials/body downloads/files were used. This confirms neither
  endpoint recovery nor a global outage and does not contradict user's own
  observation. Cached Nix success alone is not fresh-download proof.
- Working INBOX/issue findings are now consolidated into this substantive
  validation checkpoint. INBOX was left untouched; no raw archive needed because
  relevant facts are distilled and maintained test retains full reproduction.
  Only pure text enters GAW. Test/metadata commits and tag/publication are distinct.

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
  history. Current whole installed regression is 312/312; GUI layout/general
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

- No project-code blocker. User observed ELPA apparently usable after temporarily
  removing overlay. Current unmirrored Nix gate passes, with cache reuse; both
  authorized HEAD probes timeout from this agent environment. Keep availability
  as not independently confirmed here; cause/global availability remain unknown.
  Original mirror-backed evidence must not be rewritten as upstream-backed.

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
   diff 84b212a7... in evidence. HTML regression is verified/staged; await test
   commit and compare one-file diff to 4461f4ad... above. User review is pending;
   hold tag/publication until explicit resumption. Body-only
   fragment/generic API remain deferred by user choice.
   Mirror overlay is removed and final no-overlay check passes. Two HEAD attempts
   timed out without retry; further probes need new authorization. No lock changes.
   Draft release notes still describe prior preparation validation; refresh them
   to latest test/environment evidence before publication when user resumes.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
