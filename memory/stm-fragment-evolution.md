# STM fragment evolution: adopted design and experiment plan

## Authority and state

Source: the user's architecture handoff supplied in this conversation after
v0.7.1 finalization. These are adopted goals and constraints, not implemented
capabilities. The planning name v0.8.0 is provisional. Ordinary source changes,
release metadata changes and lifecycle/history operations are not authorized.
The current task authorizes memory organization and isolated E0–E2 experiments.
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

Prioritize E0–E2 now, then E3–E6; use E7/E8 when needed. Formal development needs
working nonrecursive objects, lexical isolation, AST-only roundtrip, preserved
ownership/islands, no unresolved export conflict and initial migration analysis.
Only external semantic conflicts require user decisions, not routine helpers.

## Open policy and later consumers

Old bare STM compatibility/removal/deprecation and fragment-tags/discovery API
migration are undecided pending E7. Parser extension, scoped advice/protection,
registration method and minimum-version changes remain evidence-driven.
Prototype Org 9.8.10 first, then verify APIs at declared Org 9.8 minimum; version
increases are acceptable when justified, not automatic from the development
version. Do not duplicate large Org internals merely to preserve compatibility.

OTP preview is a separate candidate consumer, not a prerequisite. OLP API and
Org 10.0 claims in the handoff are unverified here. Do not assume a stable
renderer registry or predeclare an unreleased dependency. Decide optional-module
versus whole-package minimum only after identifying and verifying actual APIs.
Update metadata/docs/checks together if a minimum increase is later adopted.
No new README syntax claims or changelog delivered entries before implementation;
register future scope only after experiments support it and scope is reviewed.
