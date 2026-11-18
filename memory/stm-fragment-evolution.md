# STM fragment evolution: adopted design and experiment plan

Current v0.8.0 minimum: Org >=9.8.10, Emacs >=31.1. The user chose this
maintenance boundary, not because Org 9.8 was proved incompatible. Prior E7
9.8 successes remain historical evidence; separate 9.8 regression is no longer
a gate. Keep existing functional/scope tests, with 9.8.10 as the minimum baseline.

## Authority and state

Node 1 delivered under the original plan. The subsequent design decision in
stm-fragment-architecture-revision.md governs the interpretation of past
prototypes. Follow stm-fragment-core-plan.md for Nodes 2–6. E0–E7 retain the
observations established under their original assumptions.

## Adopted boundaries and reasons

The v0.6.0 architecture remains: one logical mathematical-document tree
implemented as a native Org AST plus identity-keyed parsed STM islands and
explicit context. Source recognition and native parsing construct the Model.
General transformations operate directly on the Model. Normalized Org source
and TeXmacs lowering consume it. Direct construction from parsed trees is pure.

The temporary nonrecursive stm-fragment recognition object may carry STM
source. The owned Model uses the object itself as a non-block island key,
keeps its Org structure and :post-blank, and strips :stm-source and :value.
Parsed island content is authoritative. String keys and placeholder anchors
were superseded, including for direct constructors. Native block keys retain
their existing semantics.

Accept $(...)$ and \((...)\), each enclosing exactly one complete compound STM
tree. Parentheses belong to STM; the outer delimiters belong to source syntax.
No tag whitelist, automatic math/concat wrappers, language guessing, LaTeX
fallback or silent plain-text recovery. Unknown tags enter native parsing.
Ordinary $x$ and \(x\) retain Org's interpretation, without promising LaTeX
export support. Atomic string roots have no support guarantee or dedicated
prohibition. Compound string leaves remain ordinary STM data.

Default normalized output is \((...)\): distinct opening/closing delimiters
avoid some single-dollar restrictions. Require structured equivalence, unchanged
STM content and idempotence. Output-delimiter configuration is deferred.

Initial containers and composition rules follow native latex-fragment in the
target Org version, not a parallel whitelist. Native combinations that parse
successfully are the minimum compatibility target. An allowed position does not
mean every fragment containing * composes successfully with outer emphasis.
Org-TeXmacs is not required to repair existing native parser nesting ambiguities
or boundary failures. Naturally supported extra combinations may be retained
without promising universal long-term support for them. Once completely
recognized, a fragment's interior is owned by STM lexical/native parsing and is
not recursively interpreted as Org markup. Org document boundaries and opaque
code/verbatim/source regions retain priority; no fragment crosses its structure.

Strictness has two stages: source adaptation rejects recognized but incomplete
$( / \(( starts recognized in legal non-opaque contexts; Model acquisition uses the native STM parser
and rejects invalid/multiple trees. Direct AST input does not undergo source
scanning. Editing may remain incomplete; no strict/lenient option is adopted.
Use Org literal mechanisms for delimiter text first; dedicated escaping remains
undecided pending actual difficulty. Do not implement a full STM parser in Elisp.

Standard Org preparation's final effective AST remains authoritative. Preserve
selection, INCLUDE/SETUPFILE, macros/Babel, options/AST filters and Cite without
copying preparation or recursive INCLUDE. Scoped recognition/protection in the
current parsing transaction may be investigated; restoring original source over
legitimate transformations is prohibited. Filters may modify/delete/generate
stm-fragment. Batch behavior must not require an interactive minor mode; nested
exports must isolate resources. Do not masquerade as persistent latex-fragment.
Existing texmacs/equation/equation* block semantics remain unchanged.

## Historical feasibility experiments

Use v0.7.1 read-only, isolated HOME/XDG/temp and batch Emacs without user init.
Record exact Emacs/Org (including loaded path)/TeXmacs versions, configuration,
inputs, AST/output/errors, exit status and reproducible probe paths. Never read
personal knowledge bases or ID databases. Worker/socket/cache isolation must be
checked before native worker experiments. Probe success is not maintained test
coverage. Label conclusions Confirmed, Refuted, Conditional, Unverified or
Decision required; distinguish lexical boundary recognition from native parsing.

- E0: native Org 9.8.10 matrix for both math delimiters, incomplete inputs,
  paragraph/headline/emphasis/table/footnote/link-description/caption, opaque
  code/verbatim/src/example, punctuation/newline/space, positions and parents.
- E1: minimal executable delimiter scanner, nesting/strings/escapes, delimiter
  text inside strings, adjacent fragments, malformed/multiple datum and trailing
  text, unknown tags; separately test native acceptance where safely available.
- E2: exploratory recognition/masking comparisons are retained as evidence.
  E2-prime now tests native-compatible paragraph/emphasis/secondary-string
  combinations, STM-string close delimiters, opaque precedence and strict
  lexical/native errors using a local object-parser extension first. Investigate
  prescanning/masking only after a concrete failure; do not scan all source just
  to force malformed STM detection inside Org-owned opaque content.
- E3: extended-object registration versus local pseudo-objects; native Org
  traversal/interpretation/copy/cache/reentrancy and source/AST roundtrip.
- E4: AST-first model/island conversion and reverse reconstruction, direct
  trees, replacement/copy and representation errors without source mediation.
- E5: normalization and structural signatures, awkward strings, idempotence.
- E6: standard export feasibility across selection, INCLUDE, preprocessing,
  filters, Cite, nested export and no-mode batch; never restore deleted content.
- E7: compatibility/API migration, old bare STM, editing/fontification/examples
  and integrations. E8: performance/cache/cleanup after correctness.

E0–E7 are complete for feasibility/compatibility purposes. The core plan now
owns the concrete interface decisions, node dependencies and acceptance gates.
Do not reopen exploration absent a new conflict found during implementation.
Only external semantic conflicts need user decisions, not routine helpers.

## Migration and evidence boundaries

E7 adopted direct retirement of bare recognition and its at-point/map/tree/
span/tag-snapshot contracts. Preserve native blocks and the separate one-way
:fragment-tags input normalization. Its earlier public adapter proposal is
superseded. Node 1's recognition API remains delivered pending caller review.
See the core plan for current Model invariants and output failure boundaries.
E4's string anchor and E6's separate blank sibling were prototype choices.
Use the ownership and whitespace findings to assess the object representation.

## OTP consumer boundary and release scheduling

OTP (Org TeXmacs Preview) is an independent consumer of the established parsed STM trees and source recognition facilities, displaying TeXmacs-native typesetting in an Org buffer.
It does not determine core AST structure, introduce a second authoritative
parser/math AST, or take over full-document Export. A single preview may consume
an already parsed STM tree directly without constructing a whole document model.
It may reuse a native worker, without adding hidden worker dependencies to pure
Model operations. Preview cache, scheduling and overlay/image lifecycle are
separate from model ownership.

Candidate v0.8.0 core remains scoped recognition/registration/interpretation,
object-island Model construction, writer/representability/normalization,
standard Export/filters/Cite, bare/discovery API migration, necessary editing/
fontification and formal tests/docs/examples/build checks. OTP is not part of
core acceptance or core scope freeze.

After core acceptance, the user confirmed that OTP stays deferred from
v0.8.0 and remains a priority candidate for v0.9.0. Reassess potential
org-latex-preview API reuse after Org 10.0 is formally released. The reason
for waiting is to evaluate the released API and avoid tying OTP to interfaces
from the Org development branch.

The preview probe is still pending. When OTP is revisited, test fragment API sufficiency,
independent native rendering to an Emacs image, overlay preview and clearing,
cleanup on buffer close or rendering failure, and requirements for scheduling,
caching and dependencies. Later candidates include automatic or incremental
preview, cancellation and interaction with Org editing and preview commands.

OLP is a mechanism to investigate, not an assumed shared framework or renderer
registry. Distinguish public reusable APIs, internal ideas and LaTeX-specific
parts by actual inspection. Core Org 9.8 evidence is not displaced by speculative
preview needs. If newer APIs are needed, first consider an optional module with
independent requirements; no automatic package-wide minimum increase or private
Org 10.0 API adoption. Concrete rendering format/backend, public OTP API,
scheduling/cache/overlay protocol and final v0.9.0 scope remain undecided.

No new README syntax claims or changelog delivered entries before implementation;
register future scope only after experiments support it and scope is reviewed.

## Completed investigation and implementation handoff

E0–E7 support local native-compatible objects, existing ownership/islands,
pure writer feasibility and real standard Export integration. Detailed bounded
observations remain in their individual topics, including the E4 writer limits
and E5/E6 counterexamples. Full-source masking, a parallel copier, hidden worker
conversion and native emphasis repair are not default implementation tasks.
The revised core plan owns the initial output domain, representation errors, context
migration and formal regression gates; no experiment success is a delivered
feature or release-state change.
