# N4 isolated experiment review

Non-authoritative experimental evidence; not a production support declaration.
Project baseline and exact159file experiment hashes: reproduction.json. Only the
isolated flakes and added drivers differ from baseline. Recreate each snapshot
from that Git tree, restore its recorded flake and drivers, then run:

```
timeout 120s nix build --no-link --no-write-lock-file --print-build-logs --print-out-paths path:./tmp/inline-objects-0.7.0/n4-csl-flow-1#checks.x86_64-linux.inline-csl-flow
timeout 120s nix build --no-link --no-write-lock-file --print-build-logs --print-out-paths path:./tmp/inline-objects-0.7.0/n4-native-latex-1#checks.x86_64-linux.inline-latex-probe
```

Locked x86_64-linux Emacs31.1/Org9.8.10/TeXmacs2.1.5/citeproc20260113.1047.
CSL check2/2 passes; semantic matrix covers8 body/real bibliography variants.
Observers invoke original functions once, remove advice in unwind-protect; hooks
and AST filters run once. Captured source paths contain build/store locations;
these are evidence of each run, not portable source requirements.

## Four-layer result

Every input has title prefix `Properties of `. Actual parsed BibLaTeX fields,
CSL item/title and Citeproc-rendered Org strings are in flow-evidence.sexp :trace;
:ast is a diagnostic projection of prepared Org, not a canonical third AST.

| Field suffix | CSL title suffix | Rendered Org suffix | Final Org object |
| --- | --- | --- | --- |
| bare cdot command | removed | removed | plain title text |
| dollar-cdot | unchanged | unchanged | intact latex-fragment |
| dollar-alpha_i | $_i$ | $_i$ | latex-fragment with alpha lost |
| dollar-frac{a}{b} | $a<span class="nocase">b</span>$ | $ab$ | latex-fragment without fraction |

Loss occurs in citeproc-bt--process-brackets during BibLaTeX-to-CSL conversion.
The initial character decode and subsequent sentence-case step do not cause
these losses. CSL styling removes the nocase span as formatting, not math.
Body controls retain original latex-fragment values; bare body cdot is an entity
that lowers to local native math. Existing lowering refuses latex-fragment.
No processor modification, source restoration or second bibliography pipeline.

## Native API and repeatability

Registered chain inspected in original init-latex.scm: latex-snippet ->
latex-tree uses parse-latex; latex-tree -> texmacs-tree uses latex->texmacs.
Actual conversion invocation: (convert source "latex-snippet" "texmacs-stree").
Additional probe: (parse-latex source). Guessed latex-snippet->texmacs is not
bound and is not the supported API; final experiment does not use it.
Each10input is converted and parsed twice:40records, all repeat comparisons true.
One ERT passes; passing measures experiment completion, not B admission.
Native source leaves preserve ASCII STM symbol notation and decode Cork bytes.

## Required three-way classification

1. Success with expected structure/layout: dollar-cdot and paren-cdot -> local
math <cdot>; alpha_i and Unicode alpha_i -> alpha with rsub i; frac -> frac a b.
Five outputs were visually inspected as inline math between Before/after text.
2. Explicit refusal: none of the five negative/out-of-scope controls is refused
by the investigated conversion API.
3. Accepted without an admissible fidelity contract: missing-brace yields the
same fraction tree and layout as complete input; missing-dollar yields the same
alpha_i tree and layout; missing-argument emits convert-error on stdout but
returns empty math and renders an empty gap; unknown command returns a same-name
native node and renders a colored placeholder; newcommand executes conversion
semantics into assign/macro and renders x (outside the supported candidate scope).
These controls are not counted as successes even when the tree is legal or the
render appears reasonable. No pipeline LaTeX execution is added to production.

parse-latex is not a strict-validation substitute: it synthesizes the same closing
math tuple for missing-dollar as valid input, returns frac with only one argument
without throwing, and represents unknown commands as ordinary tuples. Malformed
brace output differs but has no explicit failure status. The inspected converter
registration offers no strict snippet error option. This is a bounded finding,
not a proof that no other TeXmacs interface can ever provide suitable validation.

B is deferred: a complete valid cdot fragment can convert, but a reliable finite
accept/reject contract is not established. Do not infer support from valid native
trees, add a handwritten LaTeX parser, or repair Citeproc losses from original bib.
Future B would guarantee only verified intact final-AST fragments, not BibLaTeX
preservation. Ownership/map/option production design is not adopted or certified.

## Artifact retention

Retain minimal drivers, original selected outputs, actual bib/style inputs and
hash manifest; reconstruct the unchanged project and dependencies from baseline
and lock. Full dependency sources, earlier failed harnesses, redundant flow runs,
binary PDF/PNG and full copied project trees are omitted. Native asset hashes
record the ten TM/PDF/raster triples and their store location; images were viewed
in this session but are not archived under the text-only GAW rule. Rebuild to
review binary layout. Text records and classifications preserve the gate reason.
