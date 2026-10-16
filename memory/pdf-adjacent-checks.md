# Supplementary PDF derived-state checks (selected2026-10-16)

## Motivation, source and scope

User committed original PDF fix; exact committed delivery verified and recorded
in memory/pdf-links-investigation.md. User now asks for supplementary tests of
previously identified adjacent risks, and practical interactive steps where easy.
Current source is that committed fix, not original uncommitted repair candidate.
No business-code repair selected. Supplementary tests/ert/ert.el delivery now
user-committed and exactly verified; user flake remains unrelated/unstaged. No issue association or external writes.

## Completed automated checks

One new ERT with generic/article x short/flow fixtures. Source combines TOC,
described forward/back links, undescribed numeric heading reference, first and
repeated named footnote, grouped/repeated citations, owned bibliography and
explicit native page breaks. Flow variant adds40paragraphs of plain English,
not new mathematical syntax. Derive expected target pages from unique body
markers instead of hard-coded pagination. Check TOC title destinations/page
values, citation1/2and repeated citation target pages, repeated footnote and
heading reference. Preserve source state. Existing Poppler inspector factored
to return XML tree; recursively read styled anchor text via dom-texts.

Safe ignored nonsymlink tmp/pdf-links-adjacent has25current source/lock/test
identities and independent locked flake. Probes produce12PDFs:2styles x2sizes x
direct/native .tm reload2prints/reload6prints. Independently inspect raw named
destinations/annotations with pypdf and visible links with Poppler; compare page
counts, marker pages and normalized per-page text hashes. Extra passes are a
controlled stability comparison, not an arbitrary-document convergence guarantee.
Native subprocess timeout30s. Maintained tests inspect semantic target pages;
same-page exact entry/viewport landing is additionally assigned to manual clicks.

User authorized these repeatable commands plus necessary locked dependencies/results copying:

1. timeout 240s nix build 'path:./tmp/pdf-links-adjacent#checks.x86_64-linux.probes' --no-link --no-update-lock-file --print-build-logs --print-out-paths
2. timeout 180s nix build 'path:./tmp/pdf-links-adjacent#checks.x86_64-linux.focused' --no-link --no-update-lock-file --print-build-logs --print-out-paths
3. timeout 600s nix flake check path:./tmp/pdf-links-adjacent --no-update-lock-file --print-build-logs
These may fetch locked dependencies and write private build/home/Nix store/cache
and task tmp/log/PDF results. No system Emacs, root lock edits or user config
changes. New-test baseline/current sources are committed repair plus test delta.
No extra original-defect red run needed for coverage-only changes unless a newly
reproduced defect needs an independent causal control. Failures require diagnosis,
not automatic expansion into business fixes.

## Concrete manual check plan prepared

Temporary manual.org/refs.bib use only ASCII content and no new STM math:
AlphaDestination/AlphaBodySentinel, OmegaDestination/OmegaBodySentinel,
FirstTitleSentinel/SecondTitleSentinel bibliography entries and
NamedFootnoteBodySentinel. Check ready probe PDF when generated; manual source
can also be opened in user's Emacs. Enable buffer-local
org-texmacs-export-discover-bibliography=t to read the adjacent generated refs.bib,
then standard org-texmacs-export-to-pdf. No global config change required.

Click TOC Alpha/Omega entries, ForwardToOmega and BackToAlpha; confirm headings
and page values. Click grouped citation1/2and repeated citation to respective
FirstTitleSentinel/SecondTitleSentinel entries. Click Again's repeated footnote
number to NamedFootnoteBodySentinel and AlphaNumber's reference to Alpha heading.
Automatic page checks do not by themselves prove exact same-page entry landing;
manual clicks intentionally cover that distinction. First-use footnote/backlink
features not demanded beyond existing native support. Compare optional native
.tm GUI re-export and flowing document TOC if useful. Record filename, clicked
text and actual landing; viewer behavior can leave precise viewport uncertain.
Full actionable Chinese checklist at task tmp/MANUAL.md. No GUI launched by agent.

17necessary original-byte text artifacts now archived and verified separately:
archive/2026-10-16T11-43-36Z--f4a194e/MANIFEST.md
No PDFs, full temporary workspace or duplicate native source retained. Existing PDF repair archive immutable.

## Diagnostic sequence

Initial probes generated all12PDFs but inspector stopped at missing named
destination /label6 in article-flow-direct.pdf. Poppler identifies empty href
on first-use footnote marker. This was a new observation, not a conclusion about native responsibility;
subsequent complete matrix confirmed repeated references remain valid. Original failed output
preserved in tmp/pdf-links-adjacent/initial-probe-results. Inspector was amended to record all dangling destinations instead of aborting
at the first; the same authorized command then completed matrix diagnosis. No business repair made.

## Completed matrix and focused findings

All12PDFs generated and inspected: generic/article x short4pages/flow9pages x
direct/reload2/reload6. Each has19raw annotations, exactly1missing named target
/label6 from the first footnote marker on page2. Poppler exposes an empty href
at First's marker, while repeated Again note links to page2. Extra native
reload/layout passes do not remove this observation. This separates it from
original all-links-missing defect, but does not establish whether incorrect
package tree or native footnote handling is causal. No repair in this task.

Page count, marker-page mapping and normalized per-page text agree across all
three consumers for all4fixtures. Focused6/6passes19.054185s; new ERT checks all
4direct PDFs for TOC values/links, forward/back described links, numeric heading
reference, grouped/repeated citation and repeated note target pages. First-use
note is recorded as a separate unresolved gap, not silently accepted as valid.
First focused attempt failed only because the new test omitted native TOC title
number prefixes; corrected to exact numbered title strings, retained diagnostic
log, no production modification. Full flake check subsequently passed as recorded below.

Initial probes used initial-inputs.json. Final focused/full use
candidate-inputs.json, differing only in the corrected test expectation. All
other24inputs byte-stable. Original report store output remains immutable;
results/ is a copied user-inspectable set. Manual First-versus-Again click
instructions explicitly record the new gap. No GUI launched.

## Final acceptance and handoff

Authorized600s full flake command exits0; applicable native x86_64-linux checks
pass. Core440/440 in285.609164s, focused6/6 in19.054185s; strict package
compilation and lint accepted (unchanged production package can reuse cache).
No separate9real-extension rerun in this test-only task. Other systems and
GUI clicks unverified. Final full-gate probes use corrected-test identities;
annotation/convergence reports byte-identical to copied results/ reports.
All24non-ERT inputs match committed production blobs and final25snapshot
identities rechecked. No additional project parent inferred for uncommitted
supplementary ERT runtime snapshot. Ordinary tests remain unstaged; user's
flake overlay preserved. No issue trailer/association or external state write.

User-facing next step: open tmp/pdf-links-adjacent/results/generic-short-direct.pdf
and follow MANUAL.md: TOC/headings, distinct same-page bibliography entries,
repeated note, then First-versus-Again comparison. Root cause of missing first-note
target requires a separate bounded control/investigation if selected; no native
footnote rewrite or package semantics change is authorized here. No new release
readiness or arbitrary-input convergence claim.

## User interactive feedback (2026-10-16)

User reports: clicking First's superscript1has no observable effect; other
checks basically meet expectations. This matches the independently inspected
first-note missing destination and strengthens the practical symptom evidence.
It does not identify the root cause or establish native responsibility. Exact
PDF filename/viewer not supplied; do not assert exhaustive same-page viewport
precision or all viewer configurations. Agent did not launch GUI. No repair
or further tests selected. User feedback extracted into memory; no new raw
archive justified, existing snapshot stays immutable.

User adds: clicking1before the footnote body jumps back to First1. Directional
manual evidence therefore distinguishes a functioning body-to-first-reference
backlink from a first-reference-to-body link with no observable effect. This
is consistent with different destination identifiers; it does not prove their
concrete mapping or why /label6 is absent. Next diagnosis should inspect both
annotation destinations and their independently emitted anchors, rather than
claiming all first-footnote navigation is missing.

## Read-only mechanism narrowing after directional feedback

Existing generic-short raw report identifies first-use forward annotation
/label6 missing, body backlink /label7 present and repeated-note /label9 present.
Project lowering (org-texmacs-document.el footnote branch) delegates first use
to native footnote with surround(label(org-texmacs-fn-*), empty, document body);
repeat uses rsup/with/reference to the explicit package label. Thus first-use
native navigation and repeated explicit-reference navigation are separate routes.
Do not infer a shared target from the displayed number1.

Previously captured locked native pdf_hummus_renderer.cpp shows href allocates
an ID with get_label_id even without a registered anchor. anchor appends to
dests; flush_dests writes only that list. This explains how a clickable Link
annotation can name /label6 without any corresponding PDF destination. It does
not establish which upstream anchor was omitted or mismatched.

Leading hypotheses: native footnote auto-target not emitted/registered;
interaction between package surround/body shape and native footnote expansion;
or native collection/serialization loses/mismatches that specific anchor.
No native footnote macro definition inspected in this bounded read, so do not
assign blame or exact target spelling. Stable reload2/reload6 makes a simple
insufficient-pass explanation less likely for these fixtures. No new execution,
source edit, archive or causal verification in this read-only diagnosis.

## Native causal experiment scope and harness diagnostics

User selected and authorized repeat execution of:
timeout 240s nix build 'path:./tmp/footnote-targets#checks.x86_64-linux.probes' --no-link --no-update-lock-file --print-build-logs --print-out-paths
with necessary locked dependency access and result reading/copying. Standalone
flake shares prior lock and uses native TeXmacs/Poppler/pypdf, no system Emacs.
20unique conditions: atom/document/document-label/surround-label/existing .tm
xgeneric/article x2/6forced prints. Fresh private native config each process,
30s subprocess timeout; no production code or public protocol changes.

Two initial harness failures excluded: missing with-buffer import, then a
body-marker guard rejected page-number-only output after printing left the
buffer context. Added utils library cursor and moved printing inside explicit
with-buffer. No invalid PDF accepted as product evidence. Macro read before
layout was uninit; later valid runs sampled after first forced layout, extending
to render-footnote and render-footnote*. Actual definitions appear in native
stdout logs rather than nominal output-port files. Each valid run completed all
20conditions; expanded sampling leaves annotation report byte-identical.

## Native-only causal controls completed

Final exact authorized240s flake command exits0.20conditions =5inputs x2styles
x2/6forced-print passes. Native atom/document each2annotations (1missing forward,
1valid backlink); explicit label/surround each3 (same missing forward, valid
backlink/repeat); package .tm each19 (same directional outcome). Backlink target
coordinates lie inside first-marker rectangle in all20. Actual First/body text
asserted, no blank output accepted. All20run without Emacs/org-texmacs modules;
16minimal native trees do not derive from package lowering. Package surround
and explicit-label wrappers therefore are not necessary causes. Bare controls
also reproduce without duplicate-destination warnings.

Post-layout native footnote reference uses footnote-<nr>, separate first marker
label footnr-<nr>. render-footnote* body emits set-binding of footnote-<nr> and
backlink to #footnr-<nr>. Literal prefixes agree; runtime expanded key values and
PDF anchor callbacks not instrumented. Narrowed to current native headless
footnote binding/PDF destination path, not exact macro/C++ defect or native GUI
failure. Extra2/6passes do not help these fixtures. No workaround/intervention,
production change, maintained-test change or full-suite rerun in this experiment.

Native write/display capture is on process stdout; selected generic/article
atom logs retain actual initialized macros. Nominal macro files are blank,
not evidence. Earlier pre-layout uninit capture and two initialization/focus
failures excluded. Supplementing macros leaves raw annotation report byte-equal
across valid runs. Task final-inputs.json identifies final5input bytes; inputs.json
the first valid pre-diagnostic phase. .tm controls byte-identical to prior matrix.
13necessary original-byte text artifacts verified/archived separately:
archive/2026-10-16T12-12-14Z--f4a194e/MANIFEST.md
No PDFs, dependency binaries/configs, full tmp or blank macro files archived.
No project parent inferred for native-only synthetic fixtures. Project HEAD is
capture context, not committed provenance of generated control .tm files.
Further diagnosis would compare runtime footnote key/anchor registration with
PDF destination collection, or a separate native GUI export. Neither adopted
nor executed. User can inspect complete-results/generic-atom-2.pdf as minimal
native reproduction. Main files/index unchanged in this experiment.

## Supplementary ERT staging and message readiness

User requested message; index was initially empty. Per git-maintenance staged-only
rule requested exact single-file staging; user then explicitly authorized stage
and message. Only tests/ert/ert.el staged, user flake excluded. Initial default
sandbox index write was read-only; identical authorized operation succeeded with
required filesystem permission. Full staged diff reviewed; whitespace check
clean; all25index input hashes equal accepted adjacent manifest. Prior6focused/
440core/full acceptance transfers by byte identity, no new tests. One coherent
test(pdf) change, split not necessary, difficulty low. Native first-note failure
is not repaired/covered as successful here. No issue footer/association invented.
Final tmp/commit.md contains:

```text
test(pdf): verify link destinations and TOC page numbers

- 提取共用 PDF XML 检查函数, 递归读取带样式的链接文字.
- 增加 `generic` / `article` 样式下长短文档的回归测试, 核对目录页码, 标题跳转, 组合及重复文献引用和重复脚注的目标页.
- 验证导出前后源 buffer 状态保持一致.

```

No new raw archive: exact tests.patch, manifests and acceptance already archived;
full draft retained in current memory. Ordinary commit not executed. Next user
commit, then verify exact delivery; no issue lookup unless an association is added.

## User commit delivery verified

Read-only inspection confirms test(pdf): verify link destinations and TOC page
numbers, one parent=committed PDF repair, exactly tests/ert/ert.el. Complete
message matches reviewed tmp/commit.md; patch equals archived tests.patch;
all25committed input hashes equal accepted candidate manifest. Index empty,
only original user flake unstaged. Prior6focused/440core/full acceptance transfers
by exact bytes; no rerun solely for commit verification. No issue association or
closure footer, so no corresponding remote status query required. Additional
project parent supports this exact delivery verification, not retrospective
runtime provenance for earlier uncommitted suite or native synthetic controls.
No new raw archive: committed patch/history and extracted verification suffice.
Native first-note failure remains separately diagnosed, no repair selected.

## User native interactive reproduction and supplied artifacts

User asks to defer manual.org bibliography troubleshooting. Reports directly
creating a new file and inserting footnote in TeXmacs from nix develop, exporting
PDF, first reference says "destinition not found". Supplied pair:
tmp/realworld_test/test_footnote.{tm,pdf}. Agent read files, did not launch GUI.
329byte .tm header2.1.5/generic/paper, only native footnote(Test), no package
surround. Saved references contain both footnote-1 and footnr-1 tuple(1,1).
8436byte PDF1.4 uncompressed dictionary inspection: catalog24uses Dests11;
annotation7first marker /Dest /label0, absent from Dests11 (only label1/2/3);
annotation8body backlink /Dest /label1 exists, target x162.96/y754.8 within first
marker rect162.66,751.62,167.22,757.32. Concrete artifact confirms missing PDF
destination, beyond viewer report. PDF SHA256 f68a3add30bc20e465673a881c630f6478fa44ed4e2ade1884e3186857b31bf5.
TM SHA2569292549cfdf671067de2d8b6a7d8c87c2788985215f5d54c4ccc1b82ce02b339.

User's independent native interactive report plus artifact matches headless
controls. Package worker and buffer lifecycle not necessary; native saved
reference records exist yet PDF forward destination absent. Does not trace
runtime original-key-to-ID mapping or exact macro/C++ loss. GUI operation and
file pairing provenance are user-reported, not independently witnessed; no
blanket claim across other versions/configurations. No tests/builds or product
changes in this read-only inspection. Minimal user .tm plus authored PDF
identity/dictionary report archived as2original-byte text captures:
archive/2026-10-16T12-55-42Z--b970820/MANIFEST.md
PDF binary excluded by project pure-text rule; original user files unchanged.
Current project HEAD only capture context; no extra project parent inferred.
No adopted package workaround or external issue write. Bibliography topic paused
per user's request; native anchor/PDF diagnosis remains separate.

## Reopened manual bibliography validation triage

User now reports enabling discovery reaches org-texmacs--bibliography-validate-source
and fails "Malformed or unsupported BibTeX entry", suspects another package.
Read-only check: task refs.bib still185bytes/two ordinary @book entries, same
fixture accepted by explicit-source tests. Validation error is Emacs-side
bibtex-valid-entry returning nil, before native bibliography parsing. Automatic
collector intentionally includes org-cite-global-bibliography and collector advice;
acquire validates every collected missing source, not only local declaration.
Thus an additional global/advised source with unsupported/malformed entries is
a concrete hypothesis; not established for user's actual running Emacs. Parser
customization/advice or loaded-version differences also unverified. No claim
of package conflict or new reproducible regression.

Suggested bounded interactive isolation: in manual.org set buffer-local
org-cite-global-bibliography=nil, retain discovery=t, retry standard PDF command.
If still failing, inspect org-cite-list-bibliography-files for extra paths before
blaming refs.bib/parser. User environment/collector output not yet supplied.
Current error lacks failing file identity, a verified diagnostic limitation,
not an adopted implementation task. No code changes or new tests executed.

## User-mode collection comparison and authorized external inspection

User reports disabling org-organize-mode makes manual export succeed. Normal
org-cite-list-bibliography-files returns only refs.bib; failing mode-enabled
state returns refs.bib plus3specific literature files. Thus mode-dependent
collection expansion is observed, not evidence of BibTeX parser mutation. Exact
org-organize implementation/global-versus-advice source not traced.

User explicitly authorized read-only checks of these3external files this turn:
under /home/lingyu/org/roam/literature/,
- 093cfe86-4239-4b7e-b2cb-988f6b5c71bc/cite.bib:480bytes,SHA256 c71ef5b36b252d9eac2c8c9ac6f194e56a86e96a1dd38d07bbeb965cc6d1bb36.
- 23fd3654-0b6b-4b12-a814-030e0789deb4/bibliography.bib:475bytes,SHA256 c1733513fd5a15ca4af413bdfe4e2c7097ceb021ba43bf7efe66e6571b8df126.
- 2a54185a-1ae2-4cf6-8451-7f17cf7fccc8/cite.bib:473bytes,SHA256 9f4863c21e73fb620a1b686c860f423204d6fe07530a2f7cb45683bb59e80163.
All regular, no symlink components, below1MiB. No edits, Emacs execution,
build/test/network or external copying authorized/performed. Do not treat this
limited read authorization as future general access to the personal library.

Read-only contract findings: second file line1uses @online, absent from fixed
standard BibTeX entry-type list in bibliography-validate-source. This is a
concrete input corresponding to Malformed or unsupported BibTeX entry. Third
file line6has month=MM, a bare string identifier rejected by current literal-only
field grammar (string constants unsupported); additional bounded rejection even
if @online addressed. First file @article has braced fields, no identified
violation of these specific rules; no new runtime parsing/formatting acceptance
claimed. No user-environment replay pinpointing exact failing-file stack frame.

User explicitly says these files work in ox-latex. Preserve that fact and do
not call the personal library corrupt or generally invalid BibTeX/BibLaTeX.
The demonstrated mismatch is current org-texmacs standard-type/literal-only
support boundary versus user's working LaTeX bibliography pipeline. Collector
acquisition validates all collected files/entries before lowering even when
entries are uncited. This broad preflight and missing filename in errors make
the mode-expanded library fail inconveniently. Do not rewrite @online or personal
templates to hide unsupported semantics. BibLaTeX expansion, collection changes
and richer file/entry diagnostics are follow-up candidates, not adopted repairs.

No raw archive of personal external BibTeX files: read-only scope, minimal
extracted facts/identities suffice; no need to copy personal entries into GAW.
Current manual workaround (user-confirmed) is disabling mode; exact failing
inputs and support-policy rationale now known by static inspection. Further
runtime reproduction/design requires selection and separate command authority.
