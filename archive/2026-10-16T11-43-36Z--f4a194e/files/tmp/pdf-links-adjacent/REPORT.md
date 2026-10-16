# Supplementary PDF derived-state investigation

Production source: committed PDF hyperlink repair f4a194e128bc97de7bd929e19713791dd53efe87.
All24non-ERT snapshot identities match that commit. Supplementary ERT is
uncommitted; exact patch and both initial/final input manifests retained.
Root user flake overlay excluded. Locked standalone flake uses Emacs31.1,
Org9.8.10, TeXmacs2.1.5, Poppler26.09.0 and pypdf6.19.0 on x86_64-linux.

Scope: tests/ert/ert.el only; no business-code repair, public API change,
README support expansion, issue write or release action. User authorized repeat
execution of the three exact commands in memory/pdf-adjacent-checks.md, locked
dependency access and task-local output copies. No system Emacs used.

## Probe results

12PDFs = generic/article x short/flow x direct/reload2/reload6. Short4pages,
flow9pages; flow reuses40paragraphs of plain English, not new math syntax.
All19annotations per PDF inspected, alongside visible text links and marker
pages. TOC/forward/back/heading/citation/repeated-footnote target-page checks
have no mismatch in any PDF. Direct/reload2/reload6 have equal page counts,
marker pages and normalized page-text hashes for all4fixture groups. This is
bounded evidence, not an arbitrary-document convergence guarantee.

Separate unresolved gap: exactly1dangling /label6 destination in each PDF,
from first-use footnote marker (First) on page2. Poppler exposes empty href
there. Repeated footnote marker (Again) resolves to the footnote's page2.
Original inspector aborted at this first missing target; amended inspector
records all missing targets and finishes the matrix without declaring them
valid. Initial failed12PDF output remains in initial-probe-results; final
copied output in results. Native .tm reload with2or6forced-layout prints also
retains the gap, which alone does not distinguish incorrect target tree from
native footnote handling. No causal fix claimed and no business code changed.
Native PDF duplicate-destination dictionary warnings also occur; not established
as causal, and not silently repaired.

## Maintained regression and diagnostics

One added ERT covers4direct PDFs, actual TOC page values and destination pages,
forward/back links, numeric heading reference, grouped/repeated citations,
repeated note and source-state preservation. Existing PDF XML helper factored;
styled anchors inspected recursively with dom-texts.

Initial focused5/6 failed solely because new TOC expectation omitted the native
number prefix. Corrected exact expectations to numbered title strings; no
production fix needed. Final focused6/6 passes in19.054185s. First-use note gap
is independently recorded, outside the passing repeated-reference assertions.
The test does not claim all annotations resolve.

## Manual checks and limits

MANUAL.md and manual.org/refs.bib provide concrete ASCII inputs and click steps.
Ready results/generic-short-direct.pdf permits TOC, heading links, citation1/2,
repeated citation and First-versus-Again footnote checks. Citation entries share
a page: automatic page checks cannot prove exact entry/viewport landing, so
manual clicks cover it. No GUI or human click result claimed. Native GUI
re-export and generic-flow-direct.pdf TOC checks are optional local comparisons.
PDFs and native binary dependencies are excluded from GAW archive; retain only
selected original text reports/scripts/manifests and acceptance logs. Existing
PDF repair archive is immutable and not duplicated wholesale.

Final full-gate probe reports annotations.json and convergence.json are byte-identical
to the copied results from the initial test snapshot. The corrected numbered-TOC
assertion does not alter probe fixtures or PDF inspection outcomes.

## Final gate

Authorized600s flake check exited0: all applicable checks pass on x86_64-linux.
Core440/440 in285.609164s; focused6/6 in19.054185s; complete probe repeated
with final corrected-test identities, reports byte-identical to copied results.
Strict package compilation/lint accepted; production package input unchanged
from prior committed repair so applicable outputs may be reused from Nix cache.
No separate real-extension9test gate rerun in this coverage-only task. Other
systems and manual GUI clicks not verified. Ordinary index remains untouched.
