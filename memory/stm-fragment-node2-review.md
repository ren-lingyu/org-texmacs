# Node 2 source review after Node 1 delivery

**Historical review under the former freeze.** The subsequent architecture
revision supersedes this review's string-anchor, public adapter and reverse
conversion recommendations, including the atomic-root acceptance suggestion.
The observations about the existing owner remain useful. Follow
stm-fragment-architecture-revision.md and stm-fragment-core-plan.md for current
Model integration and acceptance.

Reviewed clean delivered main and existing model, syntax, parse and serialize
modules. This is a source-backed implementation recommendation, not delivered
adapter behavior. No new E-series experiment or source patch is needed.

## Existing owner reuse

model-copy-node already registers old/new identities, owns ordinary contents,
secondary values and long/short captions, and defers other property copying.
model-finish-owner then remaps references in lists/vectors through the same
owner-nodes table. copy-mapping rejects detached/duplicate keys and copies known
STM trees. check-islands enforces overlap; snapshot additionally validates
existing model parent identities before copying/replacement.

Recommended formal extension: a private per-owner node conversion facility,
defaulting to existing behavior, with transformed nodes registered in that same
owner. Do not retain production scoped advice from E4 or add a parallel copier.
Forward adapters require explicit known-tree mappings for consumed fragments;
no parsing of :stm-source and no source/tree agreement inferred from stale source.
Original fragment identity maps to the owned anchor, including peer references.
Strip root syntax metadata and raw fragment fields in the owned model; retain
native wrapper semantics. Caption parents normalize through existing owner rules.
Reject missing/duplicate/detached/overlapping mappings and malformed ASTs before
return; caller AST, mappings and trees remain unchanged on failure.

Anchor/post-blank representation needs explicit maintained tests. A nonempty
string anchor with retained post-blank, as tested in E4, fits current copying;
it remains private, not a public sentinel syntax. Do not lose blanks in ordinary
contents or secondary/caption sequences. Prepared Export's independent ordinary
blank nodes remain Node 4 work; do not conflate that lowering adaptation with
model validity. Keep adjacent equal-looking anchor identities distinct.

## Syntax merge

Validate unique known keys and owned resolved data before merging; use plist
membership to distinguish absent from explicitly nil. Root metadata supports
heading-settings/link-settings only; context additionally supports source-file
and resource-base (legacy tag migration remains its frozen staged work).
For each shared syntax field: both present must be structurally equal; one
present supplies the value; neither present remains absent. A mismatch signals
model-error, never silent precedence or ambient capture. Missing snapshots do
not invalidate pure model construction. Model context becomes sole authority;
reverse conversion copies complete syntax metadata back without retaining source
identities. Incomplete context must not trigger ambient fallback or invention of
missing fields. Generic Org copy is not adequate for metadata ownership.

## Reverse boundary and acceptance

Start with model-snapshot/model-copy to validate and detach the model. Convert
known island trees to extended nodes inside the same ownership/remapping process,
including caption/secondary references. No source parse or worker can recover
known trees. Existing serialize-render calls worker-serialize-stm, so it cannot
implement this pure path. The current fragment object schema requires source;
therefore complete public model-to-ast acceptance depends on Node 3's writer.
Do not publish an empty public stub, hide a worker fallback or add a second
:stm-tree payload to the public fragment schema to avoid this dependency.
Node 2 can maintain private reverse structural reconstruction with a private
source-generation boundary and verify fixture generation explicitly; that does
not constitute a delivered production writer or full public reverse interface.
Freeze its exact intermediate API during the detailed Node 2 plan.

Tests must cover caption normalization, parent corruption, structural peer and
vector remapping, adjacent anchors/blanks, direct ASTs, detached mapping failures,
context absent/nil/conflict, metadata independence, model-copy/replacement and
valid atomic islands. For atomic inline trees, source representation fails with
model-serialization-error without changing model validity. Native block output
semantics remain separate. Rebind Org/STM parsing, worker requests and native
serialization to failure on pure adapter paths. Minimum is Org 9.8.10.
