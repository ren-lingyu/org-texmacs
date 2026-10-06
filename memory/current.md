# org-texmacs persistent memory

## State represented

This checkpoint reconstructs the v0.3.0 implementation state after node 4 and
the associated architecture review. It is grounded in project commit
`746a79820a3acc854499fed82d80b117dcfa61ec`.

## Implemented v0.3 nodes

1. `b7cdefd`: prepared input, pure document core, and explicit buffer adapter.
2. `1ed6e49`: restricted Org document context, supported options, and filtering.
3. `4559482`: Org lists and quote/center container lowering.
4. `746a798`: rich metadata, relative headline sectioning, and first-class
   style/initial result fields.

## Current document contract

- The prepared-input constructor owns copied AST, INFO, islands, and post-blank
  mappings; parent and identity mappings are rebuilt and invalid ownership is
  rejected.
- Pure document lowering does not read a source buffer or start a worker.
- The buffer adapter captures supported Org source/configuration semantics and
  preserves the v0.2.1 source-consistency checks.
- Restricted context supports selected option merging and filtering while
  refusing external reads, exporter hooks, code execution, ID lookup, and
  buffer fallback outside the declared subset.
- Lists and quote/center containers preserve recursive body structure and STM
  provenance while rejecting checkboxes and explicit counters.
- Metadata remains rich Org structure and lowers to TeXmacs doc-data tags.
- Headline tags are selected from relative depth, numbering, H, and UNNUMBERED;
  headings below H become nested lists instead of disappearing.
- Document results now contain body, style, initial, and body-relative STM
  paths, although the native session does not yet consume all fields.

## Validation state

The node-4 implementation recorded 190/190 ERT tests passing, seven Nix flake
checks passing, and the package build passing on x86_64-linux. These results do
not cover the still-unimplemented nodes 5 through 9.

## Architecture observation

The architecture review at this snapshot found a dependency inversion:

```text
low-level worker/transport
  -> high-level document module
```

The worker requires document code in order to validate and encode the document
wire representation. This couples transport/protocol concerns to Org document
semantics and makes the worker depend on higher-level document/Org facilities.

The observation is an architecture and ownership issue, not an observed
runtime-correctness failure. The adopted response is:

- do not block the v0.3.0 semantic implementation and release on this refactor;
- preserve the public API, wire protocol, session lifecycle, and failure
  behavior;
- after the release, move document validation/wire construction and related
  diagnostic encoding to the session/native-bridge side;
- keep process startup, socket transport, framing, and protocol-envelope
  validation in the worker layer.

The exact final module boundary remains subject to the completed node-8 wire
shape and a post-release re-review.

## Remaining v0.3 nodes

5. Static example, fixed-width, and source blocks.
6. Basic Org tables.
7. Static TOC and generated labels.
8. Complete style/initial/body/provenance native document consumption.
9. Documentation, installation probes, version metadata, and release checks.

## Explicitly deferred beyond v0.3

Serialization, PDF, preview, visual pagination, multi-session, general internal
references, citations, bibliography, file-link resolution, and complete Org
export preprocessing remain outside the release.

## Next action

Continue node 5 without broadening the review issue into an unrelated refactor.
Keep the issue recorded so the completed v0.3 session/document wire can be
reviewed and separated after release.
