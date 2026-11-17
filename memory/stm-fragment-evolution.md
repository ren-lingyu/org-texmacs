# STM fragment evolution: adopted design and experiment plan

## Authority and state

Source: the user's architecture handoff supplied in this conversation after
v0.7.1 finalization. These are adopted goals and constraints, not implemented
capabilities. The planning name v0.8.0 is provisional. Ordinary source changes,
release metadata changes and lifecycle/history operations are not authorized.
The current task authorizes E7 compatibility review, minimum-version/editor
probes and memory maintenance; earlier results remain in their experiment topics.
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

E7 user decisions: remove bare inline STM recognition directly and retire the
old at-point/map/tree/span/tag-snapshot contracts rather than silently repurpose
them. Native blocks remain unchanged. New AST/source function signatures remain
for interface review. All structurally valid model trees stay valid; verified
source representability is a separate promise and contextual failure is allowed.
See stm-fragment-e7.md for migration, diagnostics and minimum-version evidence.
Prototype hooks/anchor details remain implementation choices. No hidden worker
fallback is introduced by a representation failure.

OTP preview is a separate candidate consumer, not a prerequisite. OLP API and
Org 10.0 claims in the handoff are unverified here. Do not assume a stable
renderer registry or predeclare an unreleased dependency. Decide optional-module
versus whole-package minimum only after identifying and verifying actual APIs.
Update metadata/docs/checks together if a minimum increase is later adopted.
No new README syntax claims or changelog delivered entries before implementation;
register future scope only after experiments support it and scope is reviewed.

## E5/E6 plan revision after E4

Candidate v0.8.0 scope is not frozen. E0–E4 support local native-compatible object
recognition, scoped registration, independent AST/source conversion and reuse of
the existing model owner/islands/copy/replacement. Do not default to full-source
masking, repairing native emphasis ambiguities, parallel graph ownership,
additional canonical ASTs or OTP/Org-10 prerequisites. U+FFFC remains a prototype
anchor, not a selected contract. E4's conservative writer limitation does not
establish Scheme/STM expressibility limits; preserve its original observations.

E5 must investigate scheme-string, STM wire transport, Scheme write,
texmacs->stm and stm-snippet->texmacs before extending a pure writer. Separate
generation from independent validation. Compare model structural validity,
writer acceptance, actual Scheme reader results, actual native STM parser results
and final Org semantic roundtrip. Exercise unusual symbols, strings/controls,
Unicode, nesting, invalid/cyclic and atomic inputs. Classify invalid model,
valid-but-unrepresentable, implementation limitation and native incompatibility
separately. Require no input mutation, deterministic output, meaningful whitespace
and island-position stability, and normalized-output idempotence. E3's whitespace
normalized signature alone is insufficient.

Model/AST conversion must remain worker-independent. Native serialization can
serve as a comparison oracle, not a hidden conversion dependency. If adequate
pure output cannot be established, report representable-domain versus optional
native source-output alternatives; changing conversion dependencies needs user
decision. Independent acceptance reparsing is allowed, conversion by reparsing
is not. Do not implement a full STM parser in Elisp.

E6 must execute real org-export-as 'texmacs, not simulate preparation. Verify
registration/transcoders and the entire standard parsing/filter/Cite lifecycle:
INCLUDE/SETUPFILE, macros, controlled Babel, selection, options/parse-tree filters,
fragment/parent deletion/modification/insertion, native Cite requests and identity,
external IDs, typed references and native blocks. Consume only final effective
AST; never restore source spans or copy preparation/recursive INCLUDE. Exercise
both nested-backend directions, sequential backends, exception recovery and batch
without minor mode, including advice/worker/resource cleanup.

Then E7 compatibility review must settle bare STM, fragment-tags/discovery APIs,
coexistence, error API, writer domain and minimum versions before scope freeze.
No published changelog/version edits follow from probes. OTP remains a separate
optional consumer. If later needed, pin an upstream Org development commit rather
than relying on unstable rolling ELPA archives; Org-10 OLP is not tested here.

## Candidate core after E5/E6 investigation

Proposed core remains scoped stm-fragment object integration, bidirectional
extended-AST/model adapters using existing ownership, explicit compound carriers,
verified normalization/representation and real standard Export integration.
Details/results: stm-fragment-e5.md and stm-fragment-e6.md. Bounded feasibility
is not full-domain acceptance; formal writer/error policy and E7 compatibility
review precede scope freeze. Do not promote prototype limitations into permanent
syntax restrictions or add hidden worker requirements.
