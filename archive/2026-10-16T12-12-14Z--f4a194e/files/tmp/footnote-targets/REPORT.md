# Native footnote target causal controls

User selected experiments and explicitly authorized repeat240s standalone flake
probes command, locked dependency access and result reads/copies. Native-only
locked TeXmacs2.1.5/Poppler26.09.0/pypdf6.19.0 on x86_64-linux. No Emacs or
org-texmacs module executed in this experiment. No business-code, ordinary index,
lockfile or user configuration changes. Private native config per process;
30s subprocess timeout. Final exact command exits0.

Command: timeout 240s nix build 'path:./tmp/footnote-targets#checks.x86_64-linux.probes' --no-link --no-update-lock-file --print-build-logs --print-out-paths

## Conditions and observed result

20unique conditions: generic/article x2/6forced-layout/print passes x5inputs.
16minimal inputs create native trees directly in a new buffer.4controls load
previous package-generated .tm files, copied byte-exactly from the adjacent
matrix. Those serialized controls originate in committed production source plus
uncommitted supplementary ERT fixture, not an independently committed .tm input.
All input bytes identified in final-inputs.json. Initial inputs.json identifies
the first valid matrix before added macro diagnostics.

| Footnote body | Links per PDF | Missing forward target | Backlink | Explicit repeat |
| --- | ---: | --- | --- | --- |
| Atomic text | 2 | yes | valid | absent by design |
| document(text) | 2 | yes | valid | absent by design |
| document(concat(label, text)) | 3 | yes | valid | valid |
| surround(label, empty, document(concat(text))) | 3 | yes | valid | valid |
| Existing package .tm | 19 | yes | valid | valid in original/current reports |

Each row has4conditions. All20have exactly1missing first-use forward destination.
Minimal forward points to absent /label0; backlink /label1 resolves to first
superscript coordinates. Package forward /label6 missing; backlink /label7 valid.
Directional summary checks backlink target page/x/y inside first-marker rectangle
for all20. Both labelled minimal variants have valid repeat references. Sampling
expanded macro definitions after layout does not alter annotations.json bytes.
The bare native controls emit no duplicate-destination warnings but still fail,
so duplicate-destination warnings are not necessary for this symptom either.

## Native macro mechanism

Post-first-layout environment definitions are in complete-results/generic-atom-2.log
and article-atom-2.log. TeXmacs write/display use native stdout, so nominal
*-macros.sexp files contain only newlines and are not claimed as macro evidence.
The retained process logs contain the actual definitions.

Native footnote creates a reference to merge("footnote-", the-footnote) and a
label merge("footnr-", the-footnote). render-footnote delegates to render-footnote*;
that body's float contains a hyperlink back to #footnr-<nr> and set-binding
merge("footnote-", nr), value(the-label), "body". Static forward/body prefixes
therefore agree, while back navigation is independently constructed. Runtime
expanded key identities and native PDF anchor callbacks were not instrumented:
missing target may reflect binding/anchor emission, collection or runtime name
mismatch. No exact C++ defect or blanket native GUI defect claimed.

Conclusion: package surround/explicit-label wrappers are not necessary causes.
Current locked native headless footnote-to-PDF path independently reproduces
forward failure with working backlink;2vs6passes do not repair it. This narrows
follow-up to native footnote body binding/PDF destination handling. GUI export,
other TeXmacs versions and any workaround/intervention remain untested.

## Harness diagnostics and retention

First attempt failed before valid PDF because with-buffer module unavailable;
added utils library cursor as in worker. Second was rejected by body-marker
assertion (only page number): print had left buffer scope. Moved print into
with-buffer. Neither failure is product evidence. First valid matrix completed;
subsequent identical matrices added post-layout macro and render-footnote*
diagnostics. Pre-layout macro values were uninit; excluded from conclusions.
No production repair, new maintained ERT or full-suite rerun in this native-only
investigation. Prior uncommitted supplementary ERT remains unchanged.

Selectively retain scripts/lock/input identities/control text,20-condition raw
annotation report, directional summary, native macro logs, final gate log and
this extraction in GAW. Exclude PDFs, blank macro files, complete tmp/native
configs and superseded harness output; original diagnostics extracted here.
No single committed project snapshot represents these native-only synthetic
fixtures, so no additional project parent inferred for evidence checkpoint.
