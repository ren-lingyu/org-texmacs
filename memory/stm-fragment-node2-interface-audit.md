# Node 2 interface and cutover audit

The later user decision internalizes both Node 1 APIs without aliases at
the unified Node 4 cutover. The core plan owns that decision and the final
writer/serialization scope. The recommendations below are review history.

Source review of the delivered Node 1 baseline under the revised architecture.
These are implementation recommendations, pending review. No source changes
or runtime validation were performed.

The repository references the public org-texmacs-ast-parse-buffer in its
definition, README and fragment-object ERT tests. No production caller currently
uses it. The scoped context API supports that recognizer and the documented
Org traversal and interpretation of the resulting objects. External callers
were not audited. Recommend internalizing the source recognizer as part of
migration, updating README/tests and documenting the public break. Keep
org-texmacs-parse-buffer as the source-to-Model entry with its existing result,
source-state and native-wait guards. Leave the scoped context API decision tied
to actual traversal and interpretation uses. No new public name is needed.
The fragment interpreter uses :stm-source; recognition :value is raw carrier
metadata and is not needed for mathematical authority.

## Cutover dependencies

- parse-prepare masks native block bodies and old inline spans, associates
  raw requests, and constructs private placeholder mappings. parse-buffer
  then validates source state across native waits. Preserve native block
  protection and context, replace inline span acquisition with scoped object
  recognition, and complete a Model only with validated parsed mappings.
  Handle owned :stm-source/:value stripping during construction, including
  explicit model-create input. Validate keys and required mappings for
  snapshot as well as construction, using the existing owner transaction.
- serialize-preflight and serialize-render branch on string keys. The output
  guard invokes parse-prepare and reattaches known parsed trees by emitted
  source. Migrate admission, detached rendering, and guard together. Use a
  consumer-local interpreter/source map keyed by owned object identity and
  preserve the Org structural roundtrip guard. Use the existing native
  emission if needed for a minimal coordinated cutover, pending Node 3
  pure-writer work. Known-tree structural transformations remain parser-free.
- input ownership constructs a backing Model through private model-create
  after mapping copy/overlap checks. Public constructor validation alone
  misses this path. prepared-discover still emits old string-keyed inline
  requests. Coordinate prepared input and discovery with the Model invariant.
  Node 4 must recognize and use the final prepared/filtered objects, preserving
  native block acquisition, filters and Cite semantics.
- Document lowering's inline admission and paragraph-only display-math checks
  explicitly require string keys. Update both and test standalone display
  islands versus mixed inline content. Existing blank logic accepts object
  :post-blank and exact space/tab data in post-blanks. Verify both and avoid
  double emission. Inspect already has a generic node-island projection, but
  its string branch and fixtures still reflect the old representation.

Recommend keeping ownership/validation work independently testable as private
preparation. Land public key enforcement with the minimum producer and
consumer changes needed for source parsing, serialization and prepared input
to work end to end. If those changes require Node 4's recognition lifecycle,
treat Nodes 2–4 as separate review units with a coordinated integration gate,
rather than publishing intermediate broken public behavior or retaining a
second string-key representation. Node 5 can clean up remaining obsolete
discovery APIs and editor code. Inventory constructor, inspect, transform,
core/native serialization and Export fixtures and README examples during the
implementation plan. Do not convert historical atomic-root tests into new
object-island promises.
