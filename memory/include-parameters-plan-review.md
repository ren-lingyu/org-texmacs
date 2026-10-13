# Phase 2c INCLUDE parameter plan review

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
