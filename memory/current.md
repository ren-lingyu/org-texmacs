# org-texmacs current memory

## Active objective

v0.4.0 is released. User committed final HTML regression as
46ccf6eb7120022c734115ec7876e7d150082f9b, created tag and published GitHub release.
One-file test diff on c26985f matches verified SHA-256
4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
Local annotated tag v0.4.0 object feaf8c4ef501d50aa595090a0fa312c855071527
peels to that commit. GitHub tag ref matches the same object. Release API confirms
https://github.com/ren-lingyu/org-texmacs/releases/tag/v0.4.0,
draft=false, prerelease=false, published_at=2026-10-08T17:27:12Z
(2026-10-09 01:27:12 Asia/Shanghai). Project and memory candidate are coherent;
no new source edits or tests are needed for this identity/state verification.
The user's review/publication hold has ended through their completed release.
No new implementation or post-release checks are authorized by this notification.
Current action is release handoff; await selection of subsequent work.
Future information flow remains unresolved in issue #1:
https://github.com/ren-lingyu/org-texmacs/issues/1. Do not automatically implement
preprocessing reuse/generic export or broaden citation/resource semantics.
Release scope includes bounded DOC-01 resolution, native .tm/PDF consumers and
synchronous dispatcher/naming/scopes/configuration. HTML composition regression
is controlled hook/advice/filter coexistence, not real three-package/database
integration. Production code/README/version remained unchanged in final test node.
Final no-overlay Nix gate passes 312/312 with cache reuse; original endpoint
recovery is not independently established (two HEAD attempts timed out). Earlier
mirror-backed checks remain historical facts. Ordinary release operations were
performed by user; agent only read local Git and remote release/tag metadata.
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
  `46ccf6eb7120022c734115ec7876e7d150082f9b`.
  Its one-file HTML regression diff against c26985f matches the verified hash.
- Metadata paths README.org, org-texmacs.el and flake.nix version line are
  committed. HTML regression is committed; ordinary worktree/index are clean.
  Prior staged review/diff --check passed. SHA-256 on c26985f:
  4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
- User temporarily removed the uncommitted USTC overlay on 2026-10-09. flake.nix
  matches HEAD; do not reintroduce or stage workaround automatically. Previous
  mirror-backed validation/exclusion proof stays in evidence as historical state.
- Local v0.3.1 annotated tag resolves to `880d4e00667907ef66985387b4865ec8d795d48d`.
  v0.4.0 is published at the verified tag/commit above. Tag includes a PGP
  signature block; cryptographic signature verification was not performed.
  Release/tag identity evidence and remaining limits are in evidence.md.

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
  Only pure text enters GAW. Test/metadata commit and release identities were
  later verified; no new tests were run solely for publication verification.

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
   diff 84b212a7... in evidence. HTML commit 46ccf6e matches 4461f4ad... above;
   local/remote v0.4.0 tag and published release are verified. Release phase is
   complete. Await user selection of subsequent work. Body-only
   fragment/generic API remain deferred by user choice.
   Mirror overlay is removed and final no-overlay check passes. Two HEAD attempts
   timed out without retry; further probes need new authorization. No lock changes.
   Published release notes are now authoritative for publication scope. Old tmp
   drafts are regenerable preparation artifacts, not remaining release tasks.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
