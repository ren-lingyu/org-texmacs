# N4: CSL math trace and conditional native converter gate

## Scope and source baseline

N3 human-delivered 6c7ac07ba4f4c936abe99fb15d1915df6e211deb; ordinary project/index clean.
N4 isolated fixtures copy the159 tracked inputs. No production change or LaTeX
support promise yet. Emacs31.1, Org9.8.10, TeXmacs2.1.5 and citeproc20260113.1047.

User refinement: trace BibLaTeX field -> CSL title -> Citeproc output -> final
Org AST to locate upstream losses without changing the processor. If admitted,
B promises only verified finite intact inline fragments already in final AST;
not preservation of original BibLaTeX math through Citeproc. This clarifies,
not broadens, N4/N5. Existing ownership/purity/error/native gates still apply.

## Verified initial final-AST matrix

Isolated tmp/inline-objects-0.7.0/n4-csl-flow-1, flow.el/flow.nix plus modified
isolated flake only. One ERT covers body and real .bib/CSL variants for4samples;
exits0 in2.790113s. Before-processing and AST filter counters are exactly1 per
transaction. Effective e/^/tex flags all t. Diagnostic AST projection is not a
third canonical AST. Raw outputs remain refused.

Body bare cdot becomes entity and lowers to local native math. CSL bare cdot
vanishes from the title. Body dollar-cdot is intact latex-fragment; CSL also
retains exact $\cdot$. Body alpha_i and frac remain intact fragments; CSL final
AST instead contains $_i$ and $ab$. These are actual math losses, not title
case changes. Existing lowering explicitly rejects all latex-fragment objects.
Final-AST need exists for cdot, triggering native converter investigation;
no source/.bib reread is permitted to repair the other cases.

Initial complete result: /nix/store/bhbjiacxlb1rrj552c932k1ajd2f96ln-org-texmacs-inline-csl-flow.
Layer-by-layer cause trace, native converter repeat/layout and archive review
remain pending; final B admit/defer decision is not made.

## Experimental harness failures, not product regressions

First native fixture inserted its run call before Scheme definitions because
insert-file-contents leaves point before inserted text: unbound run-probe and
45s process deadline. Corrected by goto-char point-max. Second run actually
reached convert but TeXmacs output redirection bypassed the expected string/file
ports; result printed to stdout and Elisp read hit end-of-file. Correct to
explicit Scheme ports. Direct guessed latex-snippet->texmacs is unbound; actual
available API is (convert source "latex-snippet" "texmacs-stree").
Preliminary observations (not acceptance): cdot becomes native math; malformed
fraction/missing dollar can produce the same tree as complete input; unknown
command becomes same-named native node. Need reliable retained evidence and
layout/repeat/error gate before drawing release conclusion.

## Final four-layer findings and native gate

CSL trace exits0/2ERT (8semantic cases) in2.719154s. Observer wrappers call originals
once and remove themselves on exit. Each before-processing/filter counter is1.
The character decoder preserves the4math inputs. During title conversion,
citeproc-bt--process-brackets removes bare cdot and alpha, turns frac arguments
into a plus nocase-span-b; citeproc-s-sentence-case-title leaves these results
unchanged. CSL title already lost math before formatting; rendered Org and final
AST retain only that resulting content. Dollar-cdot stays intact at every layer.
This is not a lowerer loss or ordinary title-case difference.
Final source/result: /nix/store/asa5y6x3hj5xzbrkqz5m9ysdlmp7m3s2-org-texmacs-inline-csl-flow.

Native final probe exits0/1ERT in5.633942s:10inputs x2operations x2rounds =40records,
all repetition comparisons true. Actual API convert source latex-snippet ->
texmacs-stree; registered parse-latex and latex->texmacs chain inspected. Positive
cdot/paren-cdot/alpha_i/fraction/Unicode alpha_i have expected native structures
and actual visually inspected PDF/raster layout. Five negative/out-of-scope
inputs are accepted, none explicitly refused: malformed brace repairs to the
same fraction; missing dollar repairs to the same alpha_i; missing argument
prints diagnostics but returns empty math; unknown command makes a same-name
native placeholder; custom macro becomes assign/macro and renders x.
These are class3 (no accepted fidelity contract), not successful support cases.
parse-latex does not provide a strict alternative: it synthesizes end-math for
missing-dollar, accepts arity-short frac and unknown commands without exception.
Malformed braces leave a different parsed shape but no explicit failure status.
The examined snippet registration exposes no strict error option. This bounded
negative result does not prove no other interface or future design could work.
Final native output: /nix/store/vbnrswhwaxricqvzsk7h4rm74051170f-org-texmacs-inline-latex-probe.

B is DEFERRED under the approved gate. Intact dollar-cdot is useful and converts,
but reliable finite accept/reject versus recovery was not established. Do not
introduce a handwritten LaTeX validator, special-case rewrite or claim malformed
inputs fail merely because the API returned a legal tree. No production converter,
map/ownership change, tex-option projection or raw interpretation is adopted.
Future B would promise only verified complete final-AST fragments; it would not
promise Citeproc preserves original BibLaTeX. A remains delivered and release is
not blocked by B. N5 will document the decision and retain a real CSL intact-
fragment error-boundary regression; final diff/checks/human delivery remain.

## Retention review

The negative controls and transformation observers are not in maintained product
history and have independent reproduction/audit value. Selected19small text
files plus manifest are immutable in archive/2026-11-04T02-45-07Z--6c7ac07/MANIFEST.md.
Exact159project input hashes for both experiments, baseline, actual bib/style,
drivers/results/diagnostics and all native asset hashes are retained. Source and
archive bytes compare equal before/after capture, HEAD unchanged. Binary TM/PDF/
PNG copies and redundant runs/failed harnesses/full dependency trees are omitted;
TM is text but its tree evidence already suffices. Viewed layout is described and
its binary hashes recorded; rebuild for visual audit. Archive raw log EOF blank
is preserved intentionally and does not represent a product whitespace defect.
