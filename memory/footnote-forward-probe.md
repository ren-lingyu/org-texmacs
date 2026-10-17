# Minimal anonymous-footnote forward links and PostScript

## Objective and authority

After Issue13 delivery, user selected checking whether main-text footnote markers
actually link to footnote bodies, using minimal `1[fn::1]\n2[fn::2]` and independent
native TeXmacs in fully isolated locked flakes; user specifically requested
 tree -> PostScript -> PDF. No production fix or new footnote semantics adopted.
User authorized repeating this exact command and related locked implementation/
output reads/copying:

```sh
timeout 600s nix build path:./tmp/footnote-forward-probe#checks.x86_64-linux.footnote-forward --no-link --no-write-lock-file --print-build-logs --print-out-paths
```

It may download locked inputs and write Nix store/cache/build-private HOME,
configs/logs/.tm/.ps/PDF, not root lock, production code or index. All task files
under verified ignored nonsymlink project tmp/footnote-forward-probe. Copies of
31runtime/package/test/Nix inputs verified against accepted stage4 manifest before
preparation and after experiment. Root flake includes original user mirror; probe
flake alone adds check. Baseline project sources exactly delivered Issue13.
Package is Nix-built from copied source; no system Emacs/user Org/TeXmacs config.

## Fixture and renderer matrix

Pinned x86_64-linux, Org9.8.10/Emacs31/TeXmacs2.1.5 with locked Ghostscript,
Poppler and pypdf. generic/article; adjacent lines and separate paragraphs.
Org source includes exactly the minimal two lines, no added special metadata;
export title/author/date/toc disabled through existing variables. Formal public
source/document/save/PDF functions used, source remains unchanged. Stored Org
output contains two native footnote(document(concat...)) objects. Independent
native tree uses two footnote(document STRING), no Org/package execution.

For each style/variant: Org package PDF; saved Org tm loaded and native PDF;
independent native tree PDF; both saved-Org and independent tree via explicit
export-postscript or print-to-file(.ps), each ps2pdf. Each native process has fresh
TEXMACS_HOME_PATH; Nix sandbox HOME/XDG isolated; two forced print passes before
PS export. Native stdout marker, PS magic, PDF body text and PDF target checks
reject empty output. Separate cross-page hlink/label positive controls for each
style in all3native routes, ensuring PS does not simply discard every hyperlink.
No caption, citation, repeated-name-note or layout repair mixed into minimal case.

## Verified outcome

Final build exit0, FORWARD-MATRIX-OK34.28footnote PDFs each have4actual Link
annotations:2upper main-text forward links have missing destinations,2lower
footnote body backlinks have registered destinations. Direction classified by
source coordinates, not numbers alone. Both anonymous notes fail, correcting
any inference that only whole document's first note fails. Direct PDF targets
/label0 and /label1 absent; Poppler href empty. Footnote content/markers render.

All16PS-converted footnote PDFs also fail both forward links. Raw PS contains
ANN references to #footnote-1/2, but no matching DEST definitions; #footnr-1/2
backlink DEST definitions do exist. Target-name loss therefore predates
Ghostscript, rather than arising only in direct PDF serializer. Other body
anchors have generated identifiers, not matching required footnote names.
No exact native binding/render callback root cause established.6positive-control
PDFs each1Link with destination on expected page2. Native PDF controls emit
existing duplicate-destination warnings; no claim those cause footnote failure.
Target existence does not certify exact landing position, especially PS output
whose coordinates were not accepted as correct. No GUI click/per-viewer evidence.
Independent native reproduction rules out exporter being a necessary cause;
it does not prove every backend/version/style fails. Headless locked versions only.

## Harness correction and evidence

First build failed because Poppler diagnostic stderr was concatenated into XML;
no outcome inferred. Split stdout/stderr, reran same authorized command, full
matrix completed. No native process/worker/PDF failure in final gate. No extra
full package test suite needed for temporary diagnostic-only work.
Successful output:
/nix/store/dib56d4d3r2bqlsn9fkrsdv1msg1jw11-org-texmacs-footnote-forward-probe
Copied root tmp/footnote-forward-probe/results. Source31manifest SHA256
1f4794c387806e5cfea147fcb3aa59ac61895cae5bba0e64aee134a35cb36265;
annotations.json SHA256bf825254ec8b994ed720c0cb48b0a5861ff23a6d901fcaab4219004912682aae.
Report with exact command and specimen PDF names: root task REPORT.md.

New PS/minimal-two-note reproduction not covered in maintained tests/history;
losing temporary harness/raw directional evidence would impair reproduction.
Selected11pure-text artifacts archived and byte-verified in archive-only checkpoint:
archive/2026-10-17T18-19-25Z--aa9adbc/MANIFEST.md.
Includes harness/config/lock/input identities/report/annotation JSON/PS destination
line extraction, excludes PDFs/PS font payload/XML/log duplicates/source checkout.
Old archives immutable. Source project HEAD is capture context, not exact runtime
source for all uncommitted probes, so no project parent inferred. Active memory
and skills excluded from archive checkpoint; no skill changes needed.

## Release implication and next action

Native forward-link limitation remains real and now reproduced with two simplest
anonymous notes and both PDF pipelines. PS route does not provide a solution.
Investigation complete; package fix not adopted. User must select deeper native
diagnosis, bounded handling or explicit release limitation/impact decision.
Other0.5.0 gates and Issue13 closure remain unchanged.

## Read-only mechanism assessment after user asked probable cause

Pinned installed packages/environment/env-float.ts lines119-127 inspected in the
actual probe dependency /nix/store/5ri673m8kksap2p2r7gwgqjfwh410sls-texmacs-2.1.5.
footnote macro emits label footnr-N for main-text marker, reference footnote-N;
render-footnote* uses set-binding(footnote-N, the-label, body), plus a hard-id locus
for backlink. Names literally agree; no obvious footnote-/footnr- spelling error.
Hypothesis, not established exact defect: body-side named binding fails to become
an exported named anchor when the floating footnote is typeset; shared layout/
binding/anchor path more likely than PDF-only serialization or Ghostscript. PS
contains ANN #footnote-N but no matching DEST, while backlink footnr-N DEST exists
and generated hard-id anchors exist. Numeric resolution/content presence does not
prove exportable destination registration. Extra passes/reloads previously failed
to fix symptom, reducing simple insufficient-pass explanation without ruling out
context/lifecycle issues. Need typesetter set-binding-to-anchor instrumentation
or controlled native intervention to locate exact code; neither performed/adopted.
No new runtime or original archive: installed source is locked/reproducible and
prior macro capture plus current PS extraction already retains needed evidence.
