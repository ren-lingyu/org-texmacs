# STM fragment evolution: adopted design and experiment plan

Current v0.8.0 minimum: Org >=9.8.10, Emacs >=31.1. The user chose this
maintenance boundary, not because Org 9.8 was proved incompatible. Prior E7
9.8 successes remain historical evidence; separate 9.8 regression is no longer
a gate. Keep existing functional/scope tests, with 9.8.10 as the minimum baseline.

## Authority and state

Source: the user's architecture handoff supplied in this conversation after
v0.7.1 finalization. These are adopted goals and constraints, not implemented
capabilities. The v0.8.0 core interfaces and six implementation gates are now frozen in
stm-fragment-core-plan.md. The user requested node 1 immediately after the plan
checkpoint. Develop directly in the ordinary worktree; keep release metadata unchanged. Earlier E0–E7 findings remain evidence, not new experimental tasks.
The handoff is sufficiently distilled here; raw duplication has no independent
retention value. No experiment result is inferred from the handoff.

## Adopted boundaries and reasons

Preserve the AST-first framework: native Org structure + native STM trees +
identity-based islands + explicit captured context, without a third canonical
AST or custom mathematical semantic objects. Each stage is independently usable:
source -> extended Org AST -> complete model -> transformed model -> extended
Org AST -> normalized source. Model-to-AST conversion must not use source text
as an intermediate. Direct AST and already-parsed-tree constructors remain pure,
owned and independent of source parsing, export preparation or workers.

stm-fragment is a nonrecursive extended Org object carrying STM source. During
conversion the island's parsed STM tree becomes authoritative; no second equally
authoritative source/object representation is required in the complete model.
Reverse conversion reconstructs the object directly without parsing known trees.
First evaluate existing string-leaf anchors for position, order, whitespace,
post-blank, identity and reverse reconstruction; change anchors only if needed.

Accept $(...)$ and \((...)\), each enclosing exactly one complete compound STM
tree. Parentheses belong to STM; the outer delimiters belong to source syntax.
No tag whitelist, automatic math/concat wrappers, language guessing, LaTeX
fallback or silent plain-text recovery. Unknown tags enter native parsing.
Ordinary $x$ and \(x\) retain Org's interpretation, without promising LaTeX
export support. Valid atomic trees remain legal in direct models even though
this fragment syntax cannot express them; report representation failure without
changing the model or wrapping its tree.

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
$( / \(( starts recognized in legal non-opaque contexts; AST conversion uses the native STM parser
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

## Experiments and acceptance

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

## Open policy and later consumers

E7 user decisions: remove bare inline STM recognition directly and retire the
old at-point/map/tree/span/tag-snapshot contracts rather than silently repurpose
them. Native blocks remain unchanged. Frozen AST/source signatures and writer/context rules are in
stm-fragment-core-plan.md. All structurally valid model trees stay valid; verified
source representability is a separate promise and contextual failure is allowed.
See stm-fragment-e7.md for migration, diagnostics and minimum-version evidence.
Prototype hooks/anchor details remain implementation choices. No hidden worker
fallback is introduced by a representation failure.

## OTP consumer boundary and release scheduling

OTP (Org TeXmacs Preview) is an independent consumer of the established STM
fragment/AST facilities, displaying TeXmacs-native typesetting in an Org buffer.
It does not determine core AST structure, introduce a second authoritative
parser/math AST, or take over full-document Export. A single preview may consume
an already parsed STM tree directly without constructing a whole document model.
It may reuse a native worker, without adding hidden worker dependencies to pure
AST/model conversion. Preview cache, scheduling and overlay/image lifecycle are
separate from model ownership.

Candidate v0.8.0 core remains scoped recognition/registration/interpretation,
bidirectional existing-owner adapters, writer/representability/normalization,
standard Export/filters/Cite, bare/discovery API migration, necessary editing/
fontification and formal tests/docs/examples/build checks. OTP is not part of
core acceptance or core scope freeze.

After core implementation is stable and principal regressions/release preparation
pass, evaluate OTP as the LAST non-blocking candidate. A bounded isolated probe
should test fragment API sufficiency, independent native rendering to an Emacs
image, a simple overlay preview/clear cycle, cleanup on buffer close/render error,
and any extra scheduling/cache/dependency requirements. No full-source rescan,
whole Export transaction or generic preview framework is a prerequisite.
This experiment has not been executed and no preview is delivered.

Only consider a minimal v0.8.0 OTP after separate review: core architecture/APIs
stay stable; the module is independent and inert when disabled; preview, clear,
error recovery and maintainable regressions are feasible at bounded complexity;
no package-wide Org 10.0-pre requirement, complex async scheduler or persistent
cache is needed. Experiment success does not authorize implementation or expand
release scope. If these conditions are not met, release a ready v0.8.0 core and
make OTP a PRIORITY CANDIDATE for v0.9.0. Neither release promises every preview
feature. Later candidates include automatic/incremental preview, cancellation,
cache, overlays/resources and interaction with Org editing/preview commands.

OLP is a mechanism to investigate, not an assumed shared framework or renderer
registry. Distinguish public reusable APIs, internal ideas and LaTeX-specific
parts by actual inspection. Core Org 9.8 evidence is not displaced by speculative
preview needs. If newer APIs are needed, first consider an optional module with
independent requirements; no automatic package-wide minimum increase or private
Org 10.0 API adoption. Concrete rendering format/backend, public OTP API,
scheduling/cache/overlay protocol and final v0.9.0 scope remain undecided.

Order: implement the frozen six-node core plan; validate core (including
necessary E8 checks); evaluate OTP last and decide inclusion or deferral.
OTP non-delivery never blocks an otherwise accepted v0.8.0 core release.

No new README syntax claims or changelog delivered entries before implementation;
register future scope only after experiments support it and scope is reviewed.

## Completed investigation and implementation handoff

E0–E7 support local native-compatible objects, existing ownership/islands,
pure writer feasibility and real standard Export integration. Detailed bounded
observations remain in their individual topics, including the E4 writer limits
and E5/E6 counterexamples. Full-source masking, a parallel copier, hidden worker
conversion and native emphasis repair are not default implementation tasks.
The frozen plan owns the initial output domain, representation errors, context
migration and formal regression gates; no experiment success is a delivered
feature or release-state change.
