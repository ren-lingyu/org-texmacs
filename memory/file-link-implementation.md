# File-link consumer policy implementation

## Delivery

User committed 32643f81c424c9a8265eb73525d35e4be03f4f6e, exactly 10 intended
paths (435 additions/49 deletions). Nine runtime/test/helper blobs match the
accepted isolated input bytes; README feature hunks were separated from example
documentation. Ordinary index empty; user subsequently stashed examples. No new
HEAD test run. Pre-delivery provenance and validation limits below still apply.

## Adopted contract and ownership

User explicitly requests source implementation following isolated relative-link
experiments. Final2Customs:
- org-texmacs-pdf-file-links-as-absolute=nil: PDF-only, preserve target form;
  t resolves relative marked file paths against captured source resource base.
- org-texmacs-link-org-files-as-pdf=t: final .org suffix becomes .pdf (case
  insensitive), uniformly across PDF/.tm/native sessions/diagnostic encoding.
  nil keeps original suffix. Other extensions incl .org.gpg unchanged.
No as-texmacs option adopted. Native .tm/session still use absolute file paths.
User clarifies combined Org/TeXmacs AST boundary; native session set-document
consumes already lowered completed document, not joint AST construction.

Preparation captures strict booleans in INFO; final readonly document slots
retain them. Pure input construction uses fixed defaults or explicit INFO, no
ambient variable reads in lowering/consumption. Original AST and completed body
retain raw file targets. Native bridge copies body then transforms only marked
hlink target leaves. No changes to link descriptions, URI links, authored STM,
target reads/existence checks, implicit builds, native protocol or worker Scheme.
Prepared/source consistency includes the added settings through existing options
snapshots. PDF's private wire selector requests relative policy, other consumers
keep source-base expansion. Invalid policy/provenance/path errors precede worker.

## Implementation and regressions

Runtime paths: lisp/org-texmacs-document.el and org-texmacs-session.el. README
describes defaults/scope/snapshot behavior and intentionally different link
targets between direct PDF and re-rendered absolute-target .tm files.

3newcore tests cover four settings combinations, frozen prepare/lower/consume
state, pure defaults independent of globals, invalid settings, case-insensitive
suffix mapping, untouched labels/URI/STM/other suffixes, original-tree ownership
and relative-PDF wire without a base. Existing reserved-syntax guards now check
both PDF/non-PDF wires. Native test covers both suffix settings in .tm/session,
ignored later global changes and STM preservation. Old native target expectations
updated for new default, including caption.org->caption.pdf.

PDF test covers all4settings combinations, exact seven actual URI annotations
with ./../space/Unicode/absolute/URI/STM paths, consumer-time global changes,
source body ownership, .tm-save/fresh-native-reload absolute targets. Inspector
adds URI field and resolves indirect action objects; links-only mode bypasses
Poppler text XML for Unicode URI targets. Existing text/geometry mode unchanged.
Helper preserves stderr in a separate disposable file for failure diagnostics,
without contaminating successful JSON with native/pypdf warnings.

## Authority and validation state

User authorizes repeated exact commands this implementation round:
`timeout 120s nix fmt --no-write-lock-file -- lisp/org-texmacs-document.el lisp/org-texmacs-session.el tests/ert-core/lisp/frontend.el tests/ert-native/lisp/frontend.el tests/ert-native/lisp/serialization.el tests/ert-pdf/lisp/pdf.el tests/ert-pdf/python/pdf-links.py`
`timeout 600s nix flake check -L --no-write-lock-file --max-jobs 2 path:/home/lingyu/Projects/org-texmacs/tmp/file-link-implementation`.
Separately authorizes ONE nix fmt for pkgs/org-texmacs-examples/build.el,
timeout120s; completed, only earlier reorganization formatting corrected.
Metadata-free108file current-worktree copy and inputs.json under the check root.
Agent does not alter ordinary index/lock/history/result. User-staged examples
stay separate from unstaged feature edits, apart from that driver formatting.

Initial gate stopped at driver treefmt. Next native run had one old caption
expectation, fixed;324native now pass.206core,6patched,33PDF-document pass.
Remaining PDF fixture/inspector issues diagnosed: Unicode URI makes Poppler XML
invalid; inspector now uses pypdf-only mode for this test. Intermediate merged
stderr contaminated JSON in warning cases, replaced with separate capture.
Bare hlink paragraphs produced duplicate native annotations; final fixture uses
real Org concat paragraphs and retains exact annotation/target assertions.
Final full gate exits0, all checks pass.597ERT:206core,324native,33PDF-document,
28PDF-render,6patched. Strict compilation/package-lint/treefmt/aggregates pass;
unchanged passing outputs cached. Final PDF-render28/28takes148.143938s,
new policy regression4.687840s. No runtime source changes after native acceptance.
All108root/copy/manifest inputs equal after gate. Manifest SHA256:
563dec3a7d450717613c1ab89e7f2b81de570832965ca3e39303923b8a1a6f1d.
Complete worktree-vs-font-HEAD candidate diff SHA256:
e5de0f806c038e4ed318a06d3d4d3dd281004c40f51edbd8bc0d35db0c3bb057.
Exact manifest/verification/report remain under tmp/file-link-implementation.
No additional project parent for uncommitted candidate; acceptance not a HEAD run.

No GUI clicks/platform-independent reader claim, optional extension suite or
reorganized example-package build performed. Two-entry generic index/article
example layout remains a separate user proposal, not part of this implementation.
Earlier native experiment evidence: memory/relative-link-probes.md.
