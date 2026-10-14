# Phase 2c native preprocessing simplification review

## Revised direction supersedes the earlier mapping prerequisites

User requested review of newer INBOX plan around1380 on 2026-10-14. Two headings
numbered15 coexist; later simplification plan revises the earlier implementation
direction. Earlier parameters remain investigation cases, not a mandate to expand
protected mirror mapping. Recommend explicit supersession/renumbering in INBOX;
review leaves it untouched. This review authorizes no implementation/build/probe.

Revised direction is suitable and preferable: native Org preprocessing produces
owned working Org, then existing preparation builds AST/TeXmacs structures. This
is compatible with AST-first; preprocessing user Org is not serializing a known
target tree into another language to reconstruct it. No full org-export-as or
transcoding is required. Previous review overconstrained exact original positions
and general AST provenance as prerequisites: these are optional unless current
semantics require them. Keep original/final snapshots, actual fixed dependencies
and necessary resource origins. Existing implementation remains supported until
a new contract is experimentally adopted.

Investigation gates:

- Define finite native stages and captured parser/options/hooks before callbacks.
  No implicit full annotate-info, global ID/database reads, Babel/macros/BIND/
  SETUPFILE. Preserve generic guard, source isolation and existing API defaults.
- Native recursive reads must consume fixed owned bytes with actual identities;
  filename recording/post-read stat alone is insufficient for coherent snapshots.
  Compare private capture/read or projection approaches without prematurely
  choosing global reader replacement. Cover repeated/nested/footnote reads,
  native path semantics, budgets/aliases/cycles, checks through final return and
  cleanup. Bounded observations are not atomic FS/DB or callback sandboxing.
- Assess STM protection per stage with evidence. Protected adapter tests do not
  prove every unprotected stage is unsafe. Probe literal directives, headings,
  links/footnote-like payload, multiline STM, partial INCLUDE selection, generated
  STM and intentional hook rewrites. Final discovery alone cannot establish no
  truncation/change of original semantics. Protect or reject demonstrated hazards
  without reproducing Org selection and transformation algorithms.
- Final AST can own final island identities without original coordinates. Equal
  raw text cannot justify any original provenance that is retained. Common-base
  policy can avoid broad maps; native Org link relocation does not itself preserve
  relative STM resources. Cross-directory resource design stays separate.
- Test location/lines/only-contents/minlevel combinations, selected/excluded nested
  includes and external footnote extraction, headers/links/bib/STM semantics, fixed
  reads and cleanup. Phase1 filters and composed Phase3 discovery run once with
  unchanged explicit-text priority and transaction boundaries. Review any removal
  of documented original-range/occurrence INFO fields and associated tests/docs
  explicitly rather than silently weakening an observable contract.

Next on execution request: independent current-lock Org9.8.10 flake direct-native
probes, comparison with protected mirror, supported/rejected matrix and minimum
protection/dependency/resource contract before production refactor. Regression
belongs alongside each refactor node and full final gate. No new runtime evidence
in this review; existing35 focused/359 ERT/ten checks validate Phase2b only.
Phase4 follows selected finite Phase2c scope; issue #1 remains incomplete.

The earlier review below records the parameter-focused hypothesis. Its demands
for exact original mapping, universal occurrence provenance and protected-token
survival are superseded as prerequisites by the minimal-contract review above;
they remain candidate techniques only where a demonstrated semantic need exists.

User notified new INBOX.md section 15 on 2026-10-14. Reviewed plan on committed
bounded preprocessing baseline c525095 with only user mirror overlay dirty.
This is plan review, not authorization to implement or run new probes/builds.
INBOX remains untouched. Plan is coherent with canonical Org, AST-first lowering,
owned snapshots, protected STM, distinct occurrences and existing transaction.
Prioritize Phase2c-a investigation, contract gate, then independent implementation
nodes and maintained regression, before Phase4 joint real-package verification.
Cross-directory resources and src/example/export wrappers stay separate.

## Required refinements before implementation

- Native selection must refer to fixed original snapshot coordinates. Current
  materialize protects STM, rewrites nested directives, adds boundary lines and
  only then invokes native INCLUDE. Passing original lines/location into this
  projection is invalid without a proven mapping. Investigate native selection
  on original coordinates versus parameter translation into protected mirrors;
  do not preselect and apply selection twice or duplicate Org selection rules.
- Specify supported location forms and failures: headline/CUSTOM_ID syntax,
  missing/ambiguous matches, unsupported searches, only-contents value forms,
  minlevel policy, line endpoint/empty/reversed/out-of-range behavior and order
  when location and lines combine. These are questions for locked probes, not
  assumed native facts. Keep existing full-root/ordinary-level/common-base API.
- Validate selections against every original STM span before tokenization.
  Reject partial islands/blocks; whole tokens can be retained or omitted by
  declared selection. Require multiplicity only for retained/proven-dependency
  tokens, distinct per occurrence; never infer identity from equal raw text.
- Determine selected body plus dependency closure: native extraction of used
  footnotes outside selected lines, STM within extracted definitions, recursive
  includes inside selected versus excluded text, bibliography declarations,
  and links whose targets are omitted. Do not eagerly acquire all nested files
  or require all original tokens to survive partial inclusion. Reject unproven
  cases rather than importing unrelated content or guessing targets.
- Keep fixed per-file text/receipt identity separate from per-inclusion selected
  occurrence. Investigate recursion/cycle policy when one file contributes
  different selections; never solve this by sharing occurrence identity or by
  weakening depth/count/byte and physical-alias boundaries. Define charging for
  original reads, repeated selected bodies and extracted dependency content.
- Native minlevel/headline/footnote/link transformations must preserve existing
  supported target semantics and original STM ranges. Ordinary context remains
  derived, not an invented exact original character map. Explicit generated
  context, same-base resource policy and once-only bibliography/filter semantics
  remain. This work is include-content selection, not root region/subtree mapping.

## Investigation and acceptance

Use independent flake in project tmp with current project lock (Org9.8.10), never
stale local Org or unpinned upstream as runtime baseline. Probe native parser,
absolute-line and prepare-file helpers named in the user plan. Existing Phase2a
report/probes establish only whole-file behavior; no runtime parameter evidence
was obtained in this review. Study private helper semantics with version assertions.

Matrix: each parameter, useful combinations (especially location+lines and
only-contents+minlevel), missing/ambiguous/invalid/empty bounds, repeated equal STM
from same/different sections, multiline partial STM, nested selected/excluded
includes, external footnote definitions with STM, origin ranges and generated text,
retained/omitted targets and declarations, config/read/native-return dependency
changes, budgets/cleanup. Separate native-selection evidence from final maintained
Org-to-TeXmacs semantic/readback/bytes evidence; no byte-identical native text claim.

Phase2c-a should produce supported/rejected syntax matrix, ordered transform/map
contract, dependency policy and smallest independently valid implementation nodes.
Only proven combinations enter Phase2c-b. No full-native lifecycle, real package,
personal database, filesystem atomicity or issue closure claim. Phase4 remains
required for the separate adopted real interoperability objective; it need not wait
for every conceivable INCLUDE variant beyond the selected finite Phase2c profile.
