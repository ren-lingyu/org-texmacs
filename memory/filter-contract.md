# Phase 1 citation-key AST filter contract

Selected for implementation on 2026-10-13 under the user's instruction to
implement the revised issue #1 plan. Phase 1a design precedes Phase 1b code.
This file states the bounded contract, not generic exporter compatibility.

- Owning layer: explicit-source preparation. After STM discovery/masking,
  fully parsed Org AST, context selection/pruning/dependency recovery and
  island/post-blank construction, run filters inside the private Org buffer.
  Run them before all document resolution, bibliography planning/native work
  and org-texmacs-input-create. Pure input construction/lowering never runs them.
- Capture effective source-local/global org-export-filter-parse-tree-functions
  plus registered texmacs backend developer parse-tree filters using standard
  org-export-install-filters. Freeze selected function identities before parsing
  and recheck selection/function bindings with existing source checks across
  worker waits. Mutable state hidden inside user closures is not frozen.
- Execute through org-export-filter-apply-functions in installed order. Backend
  name/current-backend is texmacs; INFO :back-end is an independent backend copy.
  Core-only calls use a named Org backend object locally available to standard
  backend lookup while filters run, without globally registering a menu/frontend.
- INFO is a read-only restricted view: already supported effective context keys,
  explicit :input-file, :texmacs-resource-base and provided :bibliography path
  identities. :with-cite-processors is nil. Do not provide :input-buffer, final
  :parse-tree, exported-data caches, native bibliography output, global discovery,
  arbitrary source locals or claim a complete Org export environment. There is
  no options-filter phase, preprocessing hook, full annotate or string exporter.
- Work buffer is the package's private masked complete source snapshot, not a
  visiting buffer. It has copied supported heading/link/tag settings and captured
  resource directory. AST has selected body/restored dependencies. Filters must
  use the tree argument, not parse/read original source to reconstruct semantics.
- Initial mutation surface: existing citation-reference :key string only. Node
  identities, root, child order, parentage, strings/other properties, secondary
  objects, INFO and all prepared identity mappings/requests remain unchanged.
  Internal AST container topology is retained; rebuilding property containers is
  outside this first contract. Key must remain a nonempty string; existing citation
  preflight still enforces supported grammar, entries, styles and contexts.
- Validate after every filter, including nil-returning filters. Nil means keep
  current tree as in Org. A nonnil return must be the same root. Cycles/replaced
  subtrees, raw output, unrelated field/text/property/mapping/INFO mutation fail
  before worker calls, even if a later filter could have repaired them. Also reject
  work-buffer text/property edits, major-mode/location/restriction changes and
  returning from a callback in a different current buffer.
- Snapshot validation must not use mutable original fields as the expected values
  or recursively compare untrusted cyclic trees. Freeze original topology/value
  records and compare bounded original objects, permitting only identified key
  value cells. This checks more than root identity and catches detached/reparented
  mappings. Do not attempt repair/remapping after prohibited mutations.
- After the final filter, detach AST/INFO/mappings from references that callbacks
  could retain. Reuse the pure input owning constructor and remap request entries
  to independent adapter-owned mapping shells before native waits. Keep that
  temporary read-only input's nodes/value data unchanged; fill native results in
  separate mapping/INFO shells. Final public input owning still copies dependencies.
- Filter errors propagate; private buffer cleanup and dynamic Org bindings unwind.
  No worker is started by the package until validation/source checking/preflight
  succeed. Arbitrary user callback I/O or edits to external/global/source state are
  not sandboxed or rolled back. Source/filter configuration changes during waits
  invalidate conversion under the existing snapshot policy.
- Maintained tests must cover key remapping with explicit BibTeX/native output,
  no-filter compatibility, missing keys, nil returns, all rejection surfaces,
  selection/restored notes, filter settings/function rebinding during native waits,
  failure cleanup, core-only backend lookup, HTML coexistence and retained guard.
  Use project-locked Emacs/Org; no real Org-roam compatibility claim from fixtures.
- If this contract cannot be maintained, stop with evidence; do not remove guard,
  widen mutation scope, run full annotation or add pure-layer I/O as a fallback.
