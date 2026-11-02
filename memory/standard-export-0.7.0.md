# v0.7.0 Standard Org Export Integration: guide intake and read-only review

## Status, provenance and authority

On 2026-11-02 the user supplied the eleven-section v0.7.0 development guide
directly in chat, requested read-only review, and identified subsequent Plan
mode planning before implementation. Baseline is v0.6.0,
8ae564724b3919abc155df174bedd9b5078285c3, matching current ordinary HEAD/local tag.
This records the requested version direction and reviewed constraints, not an
approved executable plan or permission for implementation, tests or builds.
Previous v0.6.0 runtime authority has expired. Ordinary project worktree/index
remain unchanged. Normal authorized GAW maintenance continues.

Retention assessment: the chat guide's requirements, priorities, stages and
acceptance cases are distilled here. No repository-file original exists for
this input and no independent original-byte retention need was identified;
no raw archive or byte-exact capture is claimed. Earlier source research in
memory/standard-org-export.md remains background; this guide supplies the new
version direction and revises its source-fidelity emphasis.

## Required architecture and priorities

Make `(org-export-as 'texmacs)` a genuine usable standard backend. Org owns
buffer copying, document selection, before-processing/before-parsing hooks,
INCLUDE/SETUPFILE/macros/Babel, environment/options and precedence, options/AST
filters, pruning, footnote preparation and Cite selection/processing/finalization.
Do not replay selected hooks/filters and label it standard integration.

Consume the prepared native Org AST + INFO inside the actual standard export
invocation. Build the existing Org AST + parsed STM-islands mathematical model;
no third AST. Keep generic model syntax/structural context distinct from
consumer INFO, style/initial, resources, references and output policy. Preserve
identity mappings across every copy and associated data. Reuse existing pure
TeXmacs lowering, native serialization and PDF rendering. Source Org remains
canonical; no routine STM-tree -> string -> reparsed-tree intermediary.
`org-texmacs-parse-buffer` remains independent and performs no export preparation.

Priority: standard Org semantics, then AST-first integrity/maintainability, then
non-core legacy frontend implementation details. The first two are mandatory,
not tradeable. This is export restructuring, not a general syntax expansion.
Unsupported output structures may fail explicitly without invalidating core
models. No extension-specific compatibility code, custom recursive INCLUDE,
wholesale early deletion, or fallback to custom preparation by default.

## Handoff and STM constraints

Investigate `inner-template` first as a candidate after final AST/Cite processing;
it is not a chosen implementation. Verify live dynamic scope/INFO, deferred
property resolution, earlier `org-export-data` traversal, extra transcoder effects,
processor execution counts and standard entry preservation. Compare alternatives
if unsuitable; do not default to advice on/copying `org-export--annotate-info`.

A thin prepared adapter receives the final tree/INFO, recognizes/parses effective
islands, resolves deferred properties, adapts identity/ownership, honors logical
exclusion such as `:ignore-list`, and supplies lowering context. It must not
redo selection, pruning, options precedence, INCLUDE or Cite processing.

Treat standard preprocessing output as the export input. Legal STM introduced
or changed by macros, Babel, INCLUDE or hooks is acceptable; equality with original
Org bytes is not required. First try one late discovery/parse pass. Only proven
failures justify earlier recognition/protection; Org must still own recursion.
Reject malformed/incomplete STM, forbidden structural crossings, unreliable
associations, truncation and incorrect concatenation; do not guess repairs.
Use final filtered structures as authority, not stale source coordinates when
filters insert/replace/move/delete nodes. Reuse fragment/native-body recognition
where its assumptions hold, rather than rerunning the full source parser and
losing standard AST/Cite/filter results.

## Migration and public contracts

Remove the standard path's reliance on custom option merging, subtree/region
selection, pruning/selected-tree/footnote preservation, key-only AST filtering,
independent hook/INCLUDE composition, bibliography discovery/Cite simulation and
the generic-export guard. Legal standard AST filters must be able to insert,
delete and replace nodes, beyond citation-key edits. Migrate call paths before
deciding whether old functions/files can be removed; deletion/line count is not
an independent objective.

Retain independent model APIs and pure document lowering. Prefer routing export
conveniences through the backend. Existing independent preparation may remain
when its standalone purpose is explicit; it is not the new backend's semantic
authority. Inventory every public API, callers, compatibility choice, tests and
documentation. Explicitly document/test changed behavior rather than hide it in
compatibility branches. Keep native handlers, math environments, style/initial,
labels/number bindings, worker and consumers. Prefer Org's reference/numbering
results when applicable while retaining native document responsibilities.

## Cite and output requirements

Use ordinary bibliography acquisition, processor selection, AST key filtering,
citation/bibliography processing and applicable finalization in one real
`org-export-as` dynamic transaction. Prioritize built-in basic; then investigate
csl and explicitly supported combinations. Real current org-roam-organize through
its normal mode/interfaces is a required integration case, without private
filter calls, artificial private bindings or extension-specific production code.
Processors can call `org-export-data`, return target strings instead of nodes,
and have format-specific finalizers. Prefer reuse; only after support analysis
consider a TeXmacs processor implementing the ordinary Org Cite protocol.
Do not restore manual keys/bibliography handling for one extension.

Standard export returns text. Native `.tm` serialization returns unibyte bytes;
PDF rendering returns PDF bytes. Prove reversible `.tm` bytes/text conversion
and file coding/newline behavior, rather than assume generic file export keeps
bytes intact. PDF shares standard preparation/model construction and renders
the completed native document directly, without `.tm` file round trips.
Promise only verified text-output-filter behavior; string filters are not
automatically structural STM transformations.

## Guide stages and release acceptance

A: isolated minimal real backend; prove standard preparation, final AST/INFO,
callback ordering and model construction; export plain Org without STM/Cite.
Do not migrate the entire frontend. Compare handoff candidates if necessary.
B: fragments/native blocks/math environments plus generated STM; identity,
deferred values, logical exclusion and ownership, with minimal protection.
C: standard options/selection/pruning/footnotes/references and unrestricted legal
AST filters; retire duplicated context preparation from the standard path.
D: ordinary Cite, then real extension/UUID/bibliography/INFO/dynamic-scope cases;
native bibliography output and explicit processor support boundary.
E: public command migration, text/PDF/file/error contracts, selective cleanup,
README/CHANGELOG/examples and complete validation using existing test systems.

Release gates: real usable standard entry; one Org-owned standard preparation;
parsed native STM in models; shared core/lowering with no string AST;
standard Cite plus real extension evidence; no unexplained native/PDF regressions;
old duplicate logic absent from standard path and remaining standalone uses
explained; README distinguishes standard export/core/pure lowering; full Nix
checks pass. Old frontend success is not evidence for the new standard route.

Required tests use existing ERT core/native/PDF/integration infrastructure:
- Full/subtree/region/narrowing; recursive INCLUDE/location/levels/relative links;
  SETUPFILE/macros/Babel; COMMENT/noexport/archive/options; footnotes;
  options filters and AST insertion/deletion/replacement.
- Inline STM, texmacs/equation/equation*; Org-looking markers inside STM strings;
  macro/Babel/INCLUDE-generated islands; incomplete/cross-boundary/misassociated
  islands; independent snapshots and repeatable construction.
- Basic Cite, citation placements/bibliography, managed UUIDs, dynamic bibliography
  and INFO, and explicit failure for unsupported processors/combinations.
- References/numbering, footnotes/tables/theorems/titles/captions; Chinese/Unicode/
  escaping; `.tm`/PDF; unrelated backends; independent core without exporter;
  worker failures and valid source-state/cleanup contracts.

## Read-only findings and planning gates

The guide is coherent and suitable as planning input, but not decision-complete.
No prototype or maintained test has been run for this review.

1. Org9.8.10 `org-export-as` transcodes the tree before `inner-template`; body
   filter/template, Cite finalizer and final-output filter follow. Source
   `org-export-transcoder` special-cases org-data to return its contents, so
   merely registering an org-data transcoder does not establish a root shortcut.
   `org-export-data` also normalizes contents and memoizes strings. A no-op
   traversal must not silently discard processor output or promise unrun node
   filters. Treat callback/traversal/reentrancy behavior as an A-stage gate.
2. Basic is an immediate AST-first pressure point, not only a late compatibility
   check: its author-year/numeric citation paths call `org-export-data`, and
   bibliography generation does so per paragraph and concatenates strings.
   Org Cite wraps returned strings as raw nodes. Passing formatted STM strings
   through this route then reparsing violates the core requirement. Blanket
   no-op transcoders also lose data. Compare bounded native string transcoding
   at actual output boundaries with standard structured-processor options;
   no particular route is adopted here. Bring a basic-Cite feasibility spike
   into A risk discovery, retaining full D implementation/acceptance later.
3. Existing model ownership rejects deferred nodes/opaque runtime values.
   Standard INFO contains identity-keyed caches and other runtime data, so
   blind `org-texmacs-input-create` with full INFO is not a thin adapter.
   Resolve retained structures while live, select/remap necessary consumer data,
   preserve/recompute reference semantics and honor ignore-list without treating
   original buffer offsets as authority for filter-created nodes.
4. Native and inline recognition currently use source spans and protected Org
   parsing. Test late-only recognition against Org-looking STM string content,
   synthetic/filter-modified trees and preprocessing before choosing protection.
   This is an unresolved experiment, not proof that early protection is needed.
5. PDF rendering before standard text finalization can yield a different result
   from text export. Decide how direct native rendering, supported finalizers,
   body/final filters and error propagation agree without parsing emitted `.tm`.
   Establish the `.tm` coding boundary early; do not defer both to E cleanup.
6. Standard preparation intentionally changes old bounded policies. Plan an
   explicit API/behavior matrix including source/config changes across native
   waits, error priority, bibliography file acquisition, output naming/overwrite,
   body-only/visible-only and whether async is unsupported or separately selected.
   Standard integration does not itself select async/nonblocking development.
   New hooks/Babel follow Org policy rather than promise arbitrary callback
   rollback or retain original-byte equality. Minimum Org9.8 must be assessed
   separately from9.8.10; do not inherit unproven compatibility claims.

Sources read through public GitHub file access: Org release_9.8.10 lisp/ox.el,
oc.el and oc-basic.el. GitHub returned ox.el blob
686ffee8de20c76989ca8baa8f5aced1b6c940a9. Web-cached raw ox.el line numbers differ
from the file API response; use the file response for precise source locations.
Current org-roam-organize lisp/org-roam-organize-cite.el was read from main,
blob94e3fb7f6573016d6a3e64d5aa8cdb6ad3faf7bd: around-export dynamic binding,
INFO bibliography mutation and discovery agreement remain present. This is
static source evidence, not a pinned runtime integration result. Pin a complete
extension revision/dependencies for future integration, not just this blob.

Source URLs:
- https://github.com/bzg/org-mode/blob/release_9.8.10/lisp/ox.el
- https://github.com/bzg/org-mode/blob/release_9.8.10/lisp/oc.el
- https://github.com/bzg/org-mode/blob/release_9.8.10/lisp/oc-basic.el
- https://github.com/ren-lingyu/org-roam-organize/blob/main/lisp/org-roam-organize-cite.el

Next: Plan mode should turn A-E into reviewable implementation nodes with
explicit experiment outcomes/branch points, API migration decisions, acceptance
gates, documentation updates and separately bounded runtime authority. Neither
the final callback nor processor strategy has been selected by this review.
