# B/C export validation design

The design was audited against the delivered A1 source and the GAW state
containing the footnote reachability evidence. The checkpoint's project
parent identifies the audited source tree. This record designs A2/B/C.
Production behavior remains at the audited baseline.

## Current flow

| Stage | Inputs and output | Responsibility and ordering |
| --- | --- | --- |
| `org-texmacs--standard-inner` and `org-texmacs--standard-input` in `elisp/src/org-texmacs-export.el` | Live final Org INFO to a projected AST, fixed options, STM requests, owned Cite carriers and query data | Standard Org Export has already run preparation, selection and filters. Resolve deferred properties while the working buffer is live. Project exclusions and Cite associations by identity. Discover STM requests, including the selected supplemental definitions. Capture link, footnote, headline and table data in `org-texmacs--query-snapshot` and project affiliation. Standard Org Cite processors have already contributed their AST or requests. |
| `org-texmacs--input-own` and `org-texmacs--prepared-cite-snapshot` | Projected data to an independent identity graph and a snapshot of active bibliography sources | Ownership copies caller-owned data and remaps request keys and query identities. Snapshot validates Cite usage and freezes file identity, bytes and fingerprint before STM parsing. This phase can access local files. |
| `org-texmacs--prepared-complete` and `org-texmacs--input-finalize` | Owned requests to parsed STM islands, frozen reference analysis and initial Native Cite plan | The Elisp STM codec supplies the Model's islands. Resolution and Cite prefix allocation both need static island labels. Resolve and allocate references from owned data and frozen Org facts. Independent Input can allocate from its own AST. Preserve resolution document errors as failure data, then construct the Native Cite plan from carriers and islands. This plan does not require successful resolution. |
| `org-texmacs--prepared-cite-fulfill` in `elisp/src/org-texmacs-prepared.el` | Snapshot plus a print-bearing plan to owned entries and formatted bibliography | Check fingerprints, ask the native worker to parse active files, attach parsed sources, format selected entries and attach owned output. Result attachment rebuilds owned Input and remaps identities through `org-texmacs--input-cite-result`. The current `standard-input` invokes fulfillment before it returns. |
| `org-texmacs-document` in `elisp/src/org-texmacs.el` delegates to `org-texmacs--document-lower` | A completed Input to Document stree and provenance | `standard-inner` currently reaches its Input/Model versus Document split after preparation and fulfillment. Lowering consumes frozen data, calls the required presentation functions and validates actual output. Native serialization or PDF rendering follows only for the requested consumer. Transaction guards cover source state and bibliography fingerprints through publication. |

The [export baseline probe](../archive/2026-11-23T19-29-58Z--9dfb18e/MANIFEST.md)
observed a real bibliography worker request before either an illegal figure
or a frozen resolution failure was reported by Document conversion. It also
established positive, filter-repaired and independent Input controls. The
[footnote probe](../archive/2026-11-24T05-25-23Z--5b396dc/MANIFEST.md)
showed that the same restored note may appear twice at the filter boundary.
Query selection kept one identity for both references, and lowering emitted
one footnote. Invalid unreferenced and excluded content did not block output.

## Rule ownership and semantic dependencies

| Rule and current site | Stable inputs and responsibility | Proposed treatment |
| --- | --- | --- |
| Wrapper shape in lowering's `figure-table` | Effective block kind, parameters, direct children and parent links suffice for the wrapper grammar. | Share one pure function returning the valid body node. It checks blank wrapper parameters, ignores existing blank spacing via `org-texmacs--figure-table-blank-p`, requires one direct child and retains current child kind rules. Run it early at the Document worker boundary and in normal wrapper lowering. |
| Inner block parameters and affiliation in `figure-table` and `check-affiliated` | Effective properties and wrapper/inner context. | Preserve the current inner affiliation and parameter checks in lowering. Keep the diagnostic order between those checks. |
| Statement, NAME, CAPTION and affiliation | `org-texmacs--document-statement-tag` and `org-texmacs--document-statement-caption` use the effective AST and already serve reference analysis as well as lowering. `check-affiliated` adds context-specific restrictions. | Keep shared rules and the existing prepared caption-note restriction, which applies to the Standard Export adapter. Keep rendering-specific checks in lowering. |
| STM roots and node context in `paragraph`, `inline`, `blocks`, list, footnote, headline and table lowering | Some rules use AST shape alone. Others need parsed roots, paragraph markers, frozen note numbering, emitted titles or other lowering context. | Keep the rules at their current sites. Continue to check exact mapping use. Model structural validity remains a separate contract. |
| Reference analysis and allocation in `org-texmacs--document-resolve`, `org-texmacs--document-allocate` and `org-texmacs--input-finalize` | Owned identities, parsed islands and frozen Org query facts. | Keep the existing analysis and saved failure. Share the re-signal of its original condition and payload between the early Document boundary and normal lowering. Keep final emitted-label verification. |
| Citation requests, bindings and formatting | `org-texmacs--cite-view` checks request identity and grammar. `org-texmacs--input-cite-plan` reserves a prefix against static island labels. Actual source entries, native output and emitted carriers are needed for later checks. | Preserve each boundary. Keep entry selection, result ownership, bibliography labels/references and consumption checks. Treat plan and result refactoring as a separate audit. |
| Native table normalization | Parsed STM supplies table root, format and rectangular-row shape. Constructing the normalized wrapper must keep the original island and provenance paths. | Remove the historical bypass. Run `org-texmacs--document-normalize-table` normally in lowering and leave its shape and wrapping logic together for the first implementation. |
| Custom functions and final Document integrity | `org-texmacs--document-handle-special` needs actual lowered contents and actual handler output. Label, stree and provenance checks need real output. | Call handlers and presentation functions only in real lowering. Preserve content identity, mutation, sharing, cycle and provenance checks. Keep final output and native consumer validations. |

## Consumer boundary and ordering

Keep the two-argument `org-texmacs--standard-input` bridge and end it at
`org-texmacs--input-finalize`. Its internal return is now the complete
owned structural input and initial Cite plan, with the snapshot still
available for any required fulfillment. Move the fulfillment call into
`org-texmacs--standard-inner`. Use the existing `:texmacs-cite-requests` INFO
key to identify native preparation, including the empty-request path.

- For `input` and internal `model`, keep the current preparation and
  fulfillment behavior. `prepare-buffer` can return an Input whose AST
  cannot be lowered or whose resolution stores a failure. It still obtains
  the bibliography output required by its existing contract.
- For `document`, `text` and `pdf`, run the early checks only when the
  native Cite plan has an active print request. The `.tm` path enters via
  `text`. A prepared Input or Model is never validated as a Document
  merely because it shares preparation with these consumers.
- First surface a frozen resolution failure. Then visit wrapper nodes in
  the order already stored in `org-texmacs-resolution-nodes`. On success
  perform normal fulfillment followed by one actual lowering call.
  Independent `org-texmacs-document` keeps its normal lowering and the
  same shared grammar checks.

The existing node list is sufficient for finding these wrappers. The resolver
walk skips opaque island contents, ordinary traversal of standalone footnote
definitions and standard footnote-section headlines.
`org-texmacs--document-standard-notes` uses frozen query records to visit each
selected note body on its first reference. The allocator preserves the node
sequence in the result. Reuse this sequence after successful resolution and
before fulfillment rebuilds Input. This needs no new source walk, footnote
selector, cached validation state, or intermediate Document. The early check
only tests wrapper grammar, with actual contexts and output checks still
owned by lowering.

Org, snapshot, STM parse and initial Cite plan errors can be reported during
shared preparation. After preparation succeeds, frozen resolution failure
takes precedence over direct wrapper errors, and the first wrapper error in
the existing node sequence wins. This changes the timing of the two reported
Document blockers relative to native parse and format. On inputs that proceed
to fulfillment, preserve the pre-request, post-parse, post-format and
publication guards. Actual native bibliography or handler result errors are
reported only when their results are available. If an input is rejected by
the early boundary, no result is published or bibliography parse/format
requested. Snapshot still precedes STM parsing and retains its existing
protection window on successful paths. No snapshot mutation experiment is
needed for this design.

## A2/B/C implementation handoff

1. Land A2 and B together. Extract the wrapper body function and shared frozen
   failure handling. Delete all three `:texmacs-special-block-preflight`
   branches: resolving without a frozen result, bypassing native table
   normalization, and returning unhandled special-block contents. Normal
   lowering requires frozen resolution, normalizes native tables and calls
   the actual handler. Replace flag assertions with observable behavior.
   Update obsolete wording in lowering, formatter docs and README where
   it refers to this mode. Keep distinct serializer and native validation.
2. Land C at the shared export consumer boundary. Move fulfillment and add the
   Document checks as described above. Keep the existing private bridge
   signature. Tests that observe completed bibliography data should observe
   the actual consumer return rather than assume the bridge returns a fulfilled
   Input. Keep Input ownership, reference allocation and Native Cite result
   attachment intact. Document the changed timing for the two blockers.
3. Keep source and bibliography transaction checks at their existing points.
   Revisit the conditional filesystem probe only if implementation changes
   the successful snapshot or native-wait check window.

## Regression and acceptance

- Use a real active bibliography, citation and print request for the accepted
  figure control and for a genuine bibliography failure. Verify real figure,
  citation and bibliography output on success. For direct wrapper and frozen
  resolution failures, assert condition and diagnostic plus zero native parse
  and format calls. Test both failures together and keep snapshot error
  precedence when preparation fails.
- Exercise filter repair and filter-created invalid structure. Keep the
  selected/restored footnote pair with duplicate references, including a
  legal and an illegal active figure and the excluded and unused controls.
  Cover the `prepare-buffer` return contract, internal Model structure and
  independent Input lowering. Check representative Document, text and PDF
  entry points through their common boundary.
- Assert no handler or formatter calls for the early failures, and preserve
  the existing successful call semantics. Retain failure and provenance
  checks for actual handler output, normal native table wrapping, and source
  and bibliography transaction regressions.
- Run the maintained Nix matrix: both Core and CSL variants, Org 10.0-pre
  SETUPFILE, repository Native, PDF and other integration/regression checks,
  package build, compilation, package-lint and treefmt. Run the full flake
  check and build the examples separately. Report actual execution, cache
  reuse and observed artifacts. The existing default matrix runs repository
  Native and PDF against stock Org. Require additional dual-Org native runs
  only if the implementation changes a variant-specific native boundary.
