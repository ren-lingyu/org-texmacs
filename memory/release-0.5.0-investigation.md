# v0.5.0 isolated investigation,2026-10-16

## Scope and provenance

User explicitly requested retrying issue reads, local isolated investigation tests
and GAW recording after the initial read-only readiness review. No business-code
implementation or project edits selected. Work is in tmp/release-readiness; all
18copied module/worker/README/LICENSE/ERT/lock inputs match ordinary worktree and
committed main baseline exactly. Lock unchanged, root user flake mirror untouched,
ordinary index empty. Baseline is the verified Issue4 final date/audit revision.
This checkpoint's project association identifies actual tested package snapshot;
the untracked harness and source fixtures have their own retained identities.

All tests use isolated flake, Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux.
No system Emacs, dependency fetch/network or lock update. Offline Nix writes only
its normal store/cache and private build/tmp outputs; selected results copied to
the task tmp directory. Fresh native reload subprocesses have independent config.
Build success is not proof every recorded subprocess succeeded: statuses checked.

## Tracking retrieved successfully

GitHub connector retry succeeded where prior web lookups returned Cache miss.
#10/#11/#9/#7 are open, #4 closed/completed (closed2026-10-15T13:33:13Z).
Read complete issues plus all3 #4 scope comments; no remote writes. Raw issue
snapshot in retained issues.json. #4 comments establish table alignment belongs
to completed#8 and quotation repair already exists; final closed state supersedes
comments' historical open wording. No repeated implementation of these features.

#10 requires anonymous/named inline-definition STM, adjacent markup, multiple
fragments, separate-definition compatibility, repeated notes, malformed/crossing
inputs, ownership and PDF typesetting; excludes nested notes or all secondary
objects. #11 gives exact snake-lemma equation in block and standalone paragraph,
article style/A4/12.7mm margins, no chosen cause or fix. These exact expressions
are used in probes. #9 remains open source-identity/composition/native-reference
work after0.5.0 before0.6.0, no chosen ATTR_TEXMACS/placeholder/label syntax.
#7 remains deferred/nonblocking for this release; no async route selected.

## #10 confirmed reproduction and scope of repair

Anonymous inline [fn::...] and named [fn:n:...] each discover0islands and export
literal STM in footnote. Separate named definition discovers1island and emits
native math(frac...) with existing first-use/repeated-reference wrappers.
All3 exports succeed but inline output lacks desired semantics. Source-state
snapshots remain equal across all11Org probe cases. This is a missing supported
combination, not a thrown export error.

Eight source-boundary probes find0inline-note spans: ordinary, named/multiple,
balanced square brackets in STM string, unclosed STM, adjacent emphasis, verbatim,
link description, multiline note. Org exposes actual contents-begin/end even with
balanced [x] inside a quoted STM string; this does not prove arbitrary bracket
strings or malformed inputs safe. Existing exclusions must remain for literal/
link child objects. Do not treat silent current non-discovery as desired malformed
input behavior. The probe records actual Org secondary AST/offsets.

Static code confirms three coupled boundaries: paragraph-context discovery,
preparation splitting only paragraph string leaves (synthetic restored inline-note
paragraphs have no spans), and pure inline island handler rejects contexts other
than paragraph. Plan needs bounded inline-note span/masking, correct identity
mapping including restored definitions/filtering/scopes, and explicit footnote
lowering admission. No simple broad scan relaxation or final mechanism adopted.

## #11 reproduced; wrapper cause isolated

Original generated body has direct equation for block versus concat(equation," ")
for standalone paragraph. Under matched article/A4/12.7mm geometry, combined direct
PDF equation starts x116.16 then x36.00pt; numbers start x546.48 and386.10pt.
Individually, block starts116.16/number546.48, paragraph51.00/number401.10pt
(first-paragraph indent differs from following paragraph). Short x=1 also
reproduces under generic, so phenomenon is not unique to the long formula.

Independent native body fixtures with identical equation/style/initial show:
- direct equation starts116.16/number546.48pt;
- concat(equation), concat(equation,"") and concat(equation," ") all start51.00/
  number401.10pt.
Thus concat wrapper alone is sufficient; trailing whitespace is not decisive.
No production code changed. Mixed prose/display and ordinary inline math are
also exported as controls, not asserted equivalent to standalone display layout.

Serialized .tm text visually represents both equation contents alike. Native
load of that .tm yields two direct equation nodes, removing the problematic
concat wrapper, and re-exported PDF starts both at116.16pt, both numbers546.48pt.
Four corrected reloads exit0 with RELOAD-OK; readback tree and geometry retained.
This explains why serialization/readback equivalence did not establish direct
PDF semantics. Do not adopt serialize/reparse as production conversion or generic
normalization. #11 is a confirmed package-produced structural distinction with
native context consequences; choose bounded fix preserving mixed paragraphs,
opacity, original STM identity and provenance after a separate implementation plan.

## PDF links: shared headless-native limitation in tested configuration

Four PDFs: package export, independent native hlink body, and native load/export
of each .tm. All PDF1.4, no object streams, contain0 /Annots,/URI,/Subtype /Link;
Poppler pdfinfo -url lists header only. Rendered links remain visible. This tests
actual emitted annotations, not just text extraction or hlink tree presence.
Current package path alone does not explain absence; headless native controls
share it. Fixed print/update/print compared, not arbitrary GUI export commands,
all PDF converters or user preferences. Native tm-print definitions inspected in temporary results
for future preference/export-path audit; no cause/config fix beyond this fixture
proven. No independent PDF link system or unconditional native limitation claim.

## Chinese fonts: isolated missing-font baseline, not user's full symptom

Package and independent native reference produce same extracted text/fontspecs,
including red literal <#4E2D>... fallback, not real Chinese glyphs. Heading/body
size differences include expected style differences; no within-role size defect
established. Native .tm reload warns missing font and also produces fallback.
Only Computer/European Modern font families appear in these PDFs; no usable CJK
font established in this fresh isolated configuration. Evidence points to an
unmet native font environment for this fixture, not a demonstrated package-only
encoding defect. Need known CJK font/native config positive control and user's
practical environment before claiming inconsistent Chinese font selection fixed
or reproduced. No font install/download, user config or system change performed.

## STM font-lock feasibility

Default actual paragraph/special-block STM strings/tag have nil face; ordinary
begin_src scheme positive control gets font-lock-string-face with org-block.
Manual bounded calls to existing Org org-src-font-lock-fontify-block(lang,start,end)
with lang scheme work for configured paragraph fragment and TeXmacs block body;
string face becomes(font-lock-string-face org-block), source text/modified flag/
character tick remain unchanged. No custom parser or business code needed for
this feasibility control. It is not a working editor feature: incremental edits,
refontification/cleanup, multi-buffer/local settings, malformed syntax, large-file
cost and interaction with Org's own fontification remain untested. Adopted P1
investigation has a positive implementation direction, not automatic completion.

## Checks, diagnostics and reproduction

Three target commands, each timeout120s:
`nix build 'path:./tmp/release-readiness#checks.x86_64-linux.TARGET' --offline --no-link --no-update-lock-file --print-build-logs --print-out-paths`.
TARGET=probes,comparisons,boundaries; comparisons/boundaries repeated after added
or corrected harness work. No full release regression run. Initial probes selector
matched only quotation/center PDF1/1 (1.887187s), not presumed block structural
tests. Final boundaries selected explicit quotation plus list/native and quote/
center containers,3/3 (2.080349s). Earlier boundary3/3 ran before font-lock probe.
These establish focused baseline regression, not whole-release readiness or
identity of every reported historical block bug.

Initial comparisons Lisp lacked closing parenthesis: build failed before native
comparison. Next run gave4valid wrapper PDFs but4reload subprocesses timed out25s
with nested use-modules error; build exit0 did not make those successes. Corrected
script loads a file with top-level use-modules; all4reloads subsequently exit0.
The failed intermediate results are not acceptance. Extracted in diagnostics.md.
Some Poppler bbox output contains XML-invalid math control characters, so generic
XML parser failed; bounded word-tag/attribute extraction retains original files
unchanged. Geometry summary JSON records numeric results, not byte/pixel goldens.

Necessary original pure-text harness/lock/input identities, exact repros, trees,
reload status/scripts, extracted PDF metrics/fonts/annotation counts and focused
logs selected for immutable archive. No PDFs/binaries/dependency tree/full tmp.
Operational conclusions and limits extracted here.37necessary original-byte text
artifacts verified in separate immutable archive-only checkpoint:
archive/2026-10-16T06-29-51Z--8a90b4c/MANIFEST.md.
No user INBOX retirement or original-file edits. Temporary native print definitions
were not selected: inspected preference defaults do not establish annotation cause;
retained controls/harness and extracted configuration limit suffice.

Next: plan bounded #10/#11 fixes from this evidence, finish hyperlink native-export
configuration and CJK-font positive controls, design font-lock edit/cleanup behavior,
then representative workflows/full gate/metadata/docs under separate selection.
v0.5.0 remains planned, not accepted/released.
