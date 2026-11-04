# v0.7.0 prerelease inline mathematics execution plan

## Authority, baseline and current gate

The user approves the final revised N0-N5 plan with "Implement the plan".
This is the last feature work before v0.7.0 release. Source baseline is the
human-delivered E3 f6aa2ae; ordinary worktree/index and validated GAW were clean
at execution intake. The original A-E3 implementation is complete, not repeated.
The original guide, both refinements and the final acceptance supplement are
fully distilled here. This supersedes review-only status in the review note.

N0: update coordinated memory and create a plan checkpoint before project edits.
N1: CHANGELOG.org only: explicitly requested TODO -> NEXT and unchecked planned
items; full diff review and proposed message, then wait for human commit.
N2: entity lowering, effective options, encoding, native proof, tests/docs;
review/checks and human delivery before N3.
N3: subscript/superscript lowering and native binding/mode proof, options,
tests/docs; review/checks and human delivery before N4.
N4: isolated flake-based real CSL dataflow and, only if needed, native snippet
experiments. Review retention and archive selected indispensable text evidence;
record a no-extra-mechanism/admit/defer result before production changes.
N5: conditional local LaTeX conversion if admitted, otherwise document deferral;
complete tests/docs/release notes, final diff/checks/memory and human delivery.
Every production node must preserve a valid package, report full progress before
the next node, sync user docs and prepare tmp/commit.md. No ordinary project
staging/commit/history/tag/publication. No automatic DONE/CLOSED. The user's
specific request authorizes the N1 TODO -> NEXT transition despite skill defaults.

## A: mandatory native entity and script support

Standard Org preparation remains authoritative. Thin context projection may add
:with-entities, :with-sub-superscript (singular INFO key), and only when needed
:with-latex. The corresponding Lisp variable org-export-with-sub-superscripts
is plural. Preserve absent versus explicit nil; pure structured input has fixed
enabled defaults rather than consulting dynamic editor settings.

Org's initial option rewrites precede parse-tree filters and Cite. Do not rerun
preparation over already prepared data. Apply local effective-INFO decisions to
remaining objects, including late filter/Cite-created objects. Do not infer
interpretation merely from final-node existence. e:nil retains entity spelling;
^:nil retains script syntax and appropriate braces; ^:{} interprets bracketed
scripts only. Preserve the standard handling of recursive child objects and
post-blank; use source-independent properties/standard interpretation, not source
rescanning. Compare targeted outcomes against Org's existing option semantics.

Entities use Org semantic properties/Unicode plus local math structure as needed;
verify Cork/native encoding, ordinary text entities and literal <alpha> versus
entity \alpha. Never mark an entire paragraph math/native to encode one entity,
output residual LaTeX, or silently substitute unsupported symbols.
Scripts use native rsub/rsup where native evidence proves the intended binding.
Verify x_i^2, x^{a_b}, "The /first/ term is x_i^2.", headings, captions, ordinary
paragraphs and neighboring STM. Consecutive scripts bind to the intended base;
inline emphasis must not select a different base. Text remains text-mode outside
local math, recursive contents/whitespace must not leak outward, and STM islands
stay opaque. A matching tag alone is not semantic success. Adjust a local native
structure only with real tree/layout evidence; record/revise if a candidate fails.

Tests include e:t/nil and ^:t/{}/nil, normal and late generated nodes, structured
and standard source APIs, exact trees, real native TM/PDF/layout, nonmutation,
ownership and repeatability. Independent model validity/Org serialization and
target support remain separate. No new public API or unrelated caption-note work.

## B: conditional CSL-triggered finite LaTeX conversion

User selected: only unmet actual CSL final-AST needs trigger implementation.
Body Org is a control/general applicability test, not an independent release
feature trigger. Compare \cdot (entity) and $\cdot$ (latex-fragment) as distinct
semantic paths. Real .bib and body fixtures also cover $\alpha_i$ and
$\frac{a}{b}$. Trace original input, post-Cite final AST, prepared native input,
TeXmacs tree and real TM/PDF/layout. Distinguish normal CSL title case from actual
math loss. If A suffices, do not add machinery merely to finish B.

Only if a needed complete latex-fragment survives, investigate native TeXmacs
snippet conversion for inline $...$ and \(...\). No display math, preamble,
packages, custom macros, arbitrary BibLaTeX fields or full LaTeX claim. No custom
LaTeX parser, Citeproc internals/title-field recognition, .bib reread to restore
lost data, replacement processor or parallel bibliography preparation.

User follow-up clarifies B only guarantees verified finite complete fragments
already preserved in final Org AST, not upstream BibLaTeX preservation. Trace
BibLaTeX field -> CSL title -> Citeproc output -> final AST without processor
changes; keep cdot and unknown/recovery controls in the native experiment.

Explore capability/loading, math wrappers/tree shape, Cork/Unicode, ownership,
copy/node identity, malformed input, unknown commands/macros and recovery loss.
For every representative input classify: (1) success with expected structure AND
real layout, (2) identifiable refusal without misleading output, or (3) accepted
but fidelity unproven because of repair/placeholders/dropping. Class (3) is not
success. Repeat the same inputs and require stable trees and failure classes.
Record source versions, invocation, input/output/errors and layout evidence enough
to reproduce classification. A legal serializable STM tree alone is insufficient.

Admit only if real CSL needs survive as fragments; conversion is independent of
Citeproc internals; a bounded supported range has reliable fidelity/error rules;
ownership can be handled locally without significant model/island/standard-flow
redesign; and mathematical tree plus layout tests pass. Any failed gate means
explicit deferral without blocking A or the release. Do not weaken gates to keep
a preselected converter design.

If admitted, convert before pure lowering; prefer a private data-only worker operation
and separately owned Org-node -> converted-native-tree context view, validated
through the experiment and existing identity remapping. Do not place arbitrary fragment keys into STM islands. Publish
only complete prepared results; preserve AST/model independence, source state and
cleanup/error behavior. Pure lowering reads prepared results only, no worker/file/
source buffer. tex:nil omits fragments without conversion; tex:verbatim preserves
source syntax without conversion. Missing enabled preparation fails explicitly.
Test all three tex settings, including late generated nodes, before worker effects.

## Checks, retention and release closure

Keep standard Cite/CSL, basic/raw refusal, STM, pure/model API, encoding, PDF and
source-state regressions. Use existing core/native/PDF/real integration checks,
with native rendering evidence in addition to structural assertions. Existing
637defaultERT+actual4/all12checks/four-example acceptance is baseline only.
Use standing user nix fmt/build/eval/flake-check authority within this plan;
disclose exact command, scope, writes/network and timeout. Reuse accepted identical
inputs rather than replaying unchanged tests. Isolate unknown behavior with a
minimal flake fixture before dependent production work.

Review each experiment for retention; preserve necessary text fixtures/invocations/
outputs/manifests selectively, not the whole temporary tree. GAW archive excludes
binary images/PDFs; record rendering observations and reproducible references.
The supplied conversational notes need accurate semantic extraction, not a raw
archive: their original bytes add no independent evidence value after this plan.
Update README, root summary and detailed v0.7.0 release notes with demonstrated
node/option scope, entity-versus-LaTeX distinction, actual CSL trace, native proof
and explicit failures/limits. No unverified capability enters formal support.
Keep version0.7.0 and NEXT; finalization/tag/publication remain human-controlled.
