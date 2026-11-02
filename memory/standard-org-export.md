# Standard Org Export integration: follow-up design

## Status and scope
This is a source-based investigation for work after the v0.6.0 core loop.
It is not an implemented adapter or a standard-export compatibility claim.
The current `ox-texmacs` dispatcher retains its bounded preparation, selection,
citation and output contracts.  Generic `(org-export-as 'texmacs)` remains
explicitly rejected.

The target is to consume a complete mathematical-document model inside standard
Org Export, without package-specific adapters for individual extensions.
Core validity remains independent of TeXmacs document lowering and Org output
support.  Generic model context must not become an export INFO container.

## Source observations
### Org 9.8.10
The inspected `org-export-as` enters `org-export-with-buffer-copy` and uses
`org-export--annotate-info` before transcoding.  The latter runs processing
hooks, INCLUDE, comment-tree removal, macro expansion and optional Babel,
then before-parsing hooks and environment collection.  It installs Cite settings
and filters, parses with deferred properties, prunes the tree, applies parse-tree
filters, collects tree properties into INFO, and processes citations and
bibliography.  Transcoding and citation finalization happen afterward.

Consequently, preprocessing hooks, parse-tree filters, Cite processors and output
filters are distinct boundaries.  A private Org buffer alone is insufficient:
the relevant INFO and dynamic export call stack must also remain available.
`org-export-as` returns a string; it does not provide a public model-returning
preparation interface.  Its private helper is version-sensitive.

`org-cite-process-citations` replaces citation nodes with processor results.
Results may be strings, single Org objects or secondary strings; strings become
raw export objects.  Bibliography processing and finalization have additional
output responsibilities.  Arbitrary processor output cannot be assumed to be
an Org citation or a native TeXmacs tree.

Sources: [Org 9.8.10 ox.el](https://github.com/bzg/org-mode/blob/release_9.8.10/lisp/ox.el),
[Org 9.8.10 oc.el](https://github.com/bzg/org-mode/blob/release_9.8.10/lisp/oc.el).
This establishes source ordering, not a runtime proof of a future adapter.

### Current org-roam-organize
At inspected revision `56fdaac6adab06deafc23357aec63ae2a497e09b`, citation
integration uses standard parse-tree filtering and advice around
`org-export-as`.  The advice establishes per-export dynamic state.  With managed
bibliography enabled, the filter rewrites managed UUID keys, extends
`:bibliography` in INFO and exposes the same export-specific list through
ordinary bibliography discovery.  Interactive full-library discovery is separate.

Calling that filter manually outside the standard invocation loses the dynamic
boundary.  Passing read-only restricted INFO also prevents its bibliography
update.  Neither behavior should be repaired by naming the extension inside
`org-texmacs`.

Source: [org-roam-organize-cite.el at the inspected revision](https://github.com/ren-lingyu/org-roam-organize/blob/56fdaac6adab06deafc23357aec63ae2a497e09b/lisp/org-roam-organize-cite.el).
No runtime integration with this revision was performed for v0.6.0.

### Existing org-texmacs
The dispatcher selects bounded full-document preprocessing or direct
subtree/region/narrowed preparation.  Its generic export guard runs before
unsupported generic preprocessing.  The current parse-tree filter adapter
permits citation-key changes only, with restricted read-only INFO and no Cite
processors.  Bibliography acquisition and native formatting remain separate.

Existing preparation performs document preflight before parsing body STM.
Generic model construction preserves complete Org content and performs no export
selection.  Sharing ownership and island validation does not make these two
preparation strategies interchangeable.

The optional integration fixture in `tests/integration/` records older extension
revisions in README.  Its successful cases are bounded historical evidence,
not proof of compatibility with the current implementation described above.

## Candidate handoff and unresolved boundaries
The next experiment should enter the real standard `org-export-as` call so that
extension advice, hooks and dynamic bindings enclose preparation and consumption.
A consumer-local handoff after standard preparation, while the working buffer
and INFO are live, is the leading candidate.  Backend root transcoding is a
possible experiment site; it is not an approved implementation yet.

The experiment must resolve the following before choosing a public interface:

1. *STM protection and late recognition.* Preserve mathematical source through
   Org preprocessing without prematurely exposing placeholder data as a complete
   model.  INCLUDE, macros and hooks can introduce or duplicate islands; filters
   can copy, delete or move their Org keys.  Rebuild associations against the
   final owned tree and detect missing, duplicated or stale anchors.  Protection
   must not silently alter the source semantics seen by ordinary Org hooks.
2. *Resolved native Org structures.* Org's deferred properties must be resolved
   while their input context is available.  Copy the native tree, secondary
   objects and captions using common ownership mechanisms; never pass deferred
   buffer-backed values into the independent model.
3. *Cite output.* A late handoff sees processed citation/bibliography output.
   Classify supported native Org results and raw target strings explicitly.
   Do not parse serialized TeXmacs output back into a tree as routine lowering.
   Unsupported processor output is a consumer error, not an invalid core AST.
   An earlier handoff would preserve citation objects but must still honor
   processor execution, INFO mutation and standard ordering; invoking filters
   alone is insufficient.
4. *INFO and identity.* Keep consumer INFO separate from model syntax context.
   Remap any retained INFO node references when copying the final tree, and
   recompute derived export properties when necessary.  Serializing the tree
   into another Org buffer does not preserve these identities or dynamic state.
5. *Preflight and errors.* The generic parser stays independent of lowering.
   An export adapter can retain an internal incomplete preparation phase for
   preflight before body STM parsing, then expose a complete model.  Analyze
   any observable change in error priority before changing the existing route.
6. *Standard output contract.* Preserve string transcoding, Cite finalization,
   filters and file/buffer handling at their appropriate boundaries.  A custom
   model-returning API is distinct from the standard string API.  Avoid global
   advice that changes unrelated exporters.

No code in v0.6.0 removes the generic guard, calls the private preparation helper
as a substitute for standard export, or unifies the two preparation strategies.
The candidate requires a focused prototype and regression evidence before adoption.

## Follow-up acceptance cases
- Use the actual current extension through its ordinary mode and standard
  export entry; do not call its private filter or bind its private state.
- Compare explicit and managed bibliographies with the effective pruned tree,
  including uncited/unused entries, excluded headings and explicit precedence.
- Exercise native Org Cite processing, INFO mutation, nested exports, errors
  and cleanup.  Distinguish structured processor results from raw target output.
- Exercise STM introduced through INCLUDE/macros/hooks and islands copied,
  deleted or moved by filters; verify final tree ownership and associations.
- Retain full/subtree/region/narrowing and current preflight/STM error ordering,
  bibliography timing, output naming, overwrite behavior and failure cleanup.
- Confirm unrelated standard exporters and source buffers remain unaffected.
- Construct and inspect core models with lowering-unsupported Org content;
  no export adapter may turn its support whitelist into model validity rules.

These are future implementation acceptance cases, not completed v0.6.0 tests.
