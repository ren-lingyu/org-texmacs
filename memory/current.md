# org-texmacs current memory

## Active objective

Issue #1 Phase 0 is complete on 2026-10-13: user authorized investigation,
isolated tests and necessary GAW archive. Independent flake probes pass 14/14,
0 unexpected (0.124683s), on Emacs 31.1 / Org 9.8.10 selected by the updated
project lock. User committed lock update as b22945493102edc1823fe063f9d278ba628bdf5e;
eleven copied Lisp sources and lock match this exact committed snapshot. User
reapplied the uncommitted USTC flake.nix overlay; preserve it unstaged. Mirror
transport was authorized and retains original source hashes. Local Org 9.8-pre
and the old-lock 9.8.8 environment are not development baselines.
Reproducible evidence, stage/API/side-effect table and two adapter candidates:
archive/2026-10-12T19-11-59Z--b229454/MANIFEST.md, with REPORT.md / REPRODUCE.md
under files/tmp/issue-1-phase-0/. Archive-only checkpoint is byte-verified;
locate it through manifest first-parent history. Full project checks, native/PDF
output and real external-package integration have not run; no production edits
or GitHub issue writes were made. Historical 312/312 is not current validation.

Confirmed: no after-includes hook in locked Org; filters precede INFO :parse-tree
collection and citation output replacement. Full annotate still calls org-id-find
with Cite processors disabled. Org copy aliases mutable local configuration;
preprocessing changes STM offsets and replacement AST invalidates island keys.
Controlled native INCLUDE relocates nested local file links but does not provide
a complete origin map in observed fixtures. Bibliography discovery retains
relative paths and can read SETUPFILE. Pure lowering must not acquire that I/O.
Standard filter tools with actual texmacs backend remap private citation keys
without generic export. The user's new INBOX section 11 adopts candidate A as
the preferred direction and explicitly selects Phase 1a contract design next;
Phase 1b production implementation waits for that contract. Planned first scope:
preserve node set, identities, parent/child relations and STM source/ownership;
only citation-reference :key may change. Reject replacement AST, raw output,
other semantic mutations and invalid island/post-blank mappings explicitly;
root identity alone is insufficient. Define supported INFO fields, real texmacs
backend identity, private Org context, snapshot/filter ownership and exact stage
placement before resolution, bibliography planning and input-create. This plan
is adopted, but the detailed contract is not yet finalized or implemented.
Full annotation remains research only. If candidate A cannot meet the minimal
contract, stop with evidence rather than automatically switching to candidate B.
Next action: Phase 1a citation-key AST-filter contract, including negative-test
obligations and source/error/wait consistency. Preserve the generic guard,
canonical source, coherent ownership and provenance. Later phases remain conditional: bounded
source composition, bibliography discovery, real extension/frontend integration.
The local report is ready for issue discussion; external posting needs separate
authorization. Evidence.md records validation limits and capture audit details.

v0.4.0 is released. User committed final HTML regression as
the final HTML coexistence regression revision, created tag and published GitHub release.
One-file test diff on the v0.4.0 release preparation revision matches verified SHA-256
4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
Local annotated tag v0.4.0 object feaf8c4ef501d50aa595090a0fa312c855071527
peels to that commit. GitHub tag ref matches the same object. Release API confirms
https://github.com/ren-lingyu/org-texmacs/releases/tag/v0.4.0,
draft=false, prerelease=false, published_at=2026-10-08T17:27:12Z
(2026-10-09 01:27:12 Asia/Shanghai). Project and memory candidate are coherent;
no new source edits or tests are needed for this identity/state verification.
The user's review/publication hold has ended through their completed release.
No new implementation or post-release checks are authorized by this notification.
The user adopted the rebuilt GAW history and restored its branch name to
`_agents`. Local status/check confirm that `_agents` is the sole local GAW branch,
selected/deployed at `.agents`, with the verified reconstruction handoff at its
tip before this adoption record. The user reports backing up the old GAW branch
remotely; the remote ref name and backup contents were not independently checked.
Do not assume the old history is still available through a local branch or mutate
backup/branch/remote state without explicit direction.

Project procedures now reflect the available global GAW skill and compatible
public CLI. The maintenance motivation is coherent recovery and faithful
archive interpretation: checked capture HEAD is distinct from original provenance,
and project parents require supported evidence. Archive/development/governance
skills, management README and bootstrap template are coordinated; pure-text-only
capture, archive-only snapshots, SHA-256 and config-only checkpoints remain local
requirements. Historical snapshots/configs are unchanged. Existing OID/provenance
work remains in evidence/history; issue #1 concerns later project architecture,
not this maintenance. No external tracking change or project implementation is
selected. Resource/name/data-root review and public GAW readiness checks pass;
no project tests or network calls were needed. Machine-specific executable
bindings are supplied by host/session instructions, not project bootstrap or
current memory. The bootstrap is synchronized from the reviewed template to the
ordinary project's ignored, untracked AGENTS.md. The user permits this routine
generated-file sync within authorized GAW governance maintenance without separate
confirmation; preserve unrelated edits and verify exactness through the helper.

Reconstruction results and validation limits remain in evidence.md and
`archive/2026-10-08T18-49-17Z--46ccf6e/`. Its diagnostic journal records historical
branch names/OIDs, not active identities; archived files/manifests remain unchanged.
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

- Current main is the user's flake-input update revision b229454; lock selects
  Org 9.8.10. Ordinary index is empty and flake.nix has the user's unstaged mirror
  overlay. Production Lisp remains v0.4.0; Phase 0 changed no package code.
  Release-era observations below describe their historical baseline.
- Main HEAD observed on 2026-10-09:
  the final HTML coexistence regression revision.
  Its one-file HTML regression diff against the v0.4.0 release preparation revision matches the verified hash.
- Metadata paths README.org, org-texmacs.el and flake.nix version line are
  committed. HTML regression is committed; ordinary worktree/index are clean.
  Prior staged review/diff --check passed. SHA-256 on the v0.4.0 release preparation revision:
  4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
- User temporarily removed the uncommitted USTC overlay on 2026-10-09. flake.nix
  matches HEAD; do not reintroduce or stage workaround automatically. Previous
  mirror-backed validation/exclusion proof stays in evidence as historical state.
- Local v0.3.1 annotated tag resolves to the v0.3.1 release revision.
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

- `.gaw/config` now explicitly declares version 1 with archive, skills and memory
  role groups for the same three existing directories. Use a v1-compatible GAW CLI;
  role metadata changes discovery, not the flattened workspace/protection boundary.
  Historical config states remain unchanged.
- This workflow review and public status/check were performed with GAW 0.6.0,
  which accepts this v1 workspace. This is verification context, not a requirement
  to find that same installed version. Interpret
  historical snapshots under their own conventions; no historical migration is
  needed to resume with updated skills. The global workflow is an external
  available dependency, not included among this project's bundled resources.
- GAW `_agents` now contains the adopted rebuilt history and is valid/deployed at
  `.agents`. Old-history remote backup is user-reported, not independently checked.
  Use public GAW interfaces, never lifecycle mutation without direction.
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

1. The native PDF consumer revision is verified against the seven-file SHA-256 on the baseline interactive export revision:
   00164bbb3491e4addd74c75a0c53ab86cd8397855e659c25a572a5ae84044464.
   The PDF semantic regression and citation repair revision is now verified by its three-file diff SHA-256
   against the baseline native PDF consumer revision. The bounded ox-texmacs frontend revision is now verified against
   d41f05a2... as recorded in evidence. The Org output naming and repeat-export revision is verified
   against its five-file hash recorded in evidence. The subtree export revision is
   verified against the six-file diff hash 3be6de01... above. Region is
   committed as the region export revision and verified against six-file hash 22765b0b... above.
   The external configuration override revision is verified against five-file diff 145a3237... above.
   The narrowed-source export revision is verified against six-file diff fdeb09f1... in
   evidence. The v0.4.0 release preparation revision is verified against three-file
   diff 84b212a7... in evidence. The final HTML coexistence regression revision matches 4461f4ad... above;
   local/remote v0.4.0 tag and published release are verified. Release phase is
   complete. User has selected issue #1 investigation as described above. Body-only
   fragment/generic API remain deferred by user choice.
   At release closure the overlay was removed and the no-overlay check passed.
   Two release-era HEAD attempts timed out. Current lock/mirror state and the
   newly authorized Phase 0 checks are recorded above.
   Published release notes are now authoritative for publication scope. Old tmp
   drafts are regenerable preparation artifacts, not remaining release tasks.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
