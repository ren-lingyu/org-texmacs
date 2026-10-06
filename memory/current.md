# org-texmacs persistent memory

## State represented

This checkpoint reconstructs the durable project state at the v0.2.0 release
on 2026-09-13. It is grounded in project commit
`c115285639f6d40e40de378b6e2da4a79f3c1cd0`.

## Objective

Turn a private Org AST containing parsed TeXmacs islands into a structured
TeXmacs body tree, encode that tree with source-aware semantics, and install it
in a persistent native TeXmacs body session. Preserve the v0.1 parsing
foundation rather than replacing it with an intermediate file format.

## Established pipeline

```text
Org buffer
  -> private Org AST + parsed TeXmacs islands + fixed context
  -> UTF-8 TeXmacs body stree + STM provenance paths
  -> source-aware TeXmacs native encoding
  -> native TeXmacs tree
  -> one persistent native body session
```

- Structural handlers construct TeXmacs strees directly from Org nodes.
- Ordinary Org leaves use literal/source-code semantics: text such as
  `<alpha>` remains literal text.
- STM leaves use TeXmacs source semantics: native notations such as `<alpha>`
  retain their TeXmacs meaning. Literal angle brackets in STM are expressed by
  the STM source itself.
- `stm-paths` preserve source provenance until native encoding is complete.
- Unsupported Org structures fail explicitly instead of being silently
  dropped or flattened.
- The session consumes a completed representation and does not reinterpret the
  Org source. It remains a single-active-session API.

## Implemented body subset

- Paragraphs and relative headline content with fixed formatter context.
- Basic inline emphasis and literal objects, line breaks, and ordinary text.
- TeXmacs inline fragments and blocks mixed with ordinary Org content.
- External URI links for the deliberately finite supported protocol set.
- Anonymous inline footnotes.
- Headline TODO, priority, and tags through a fixed INFO snapshot.
- Persistent session open, repeated body replacement, readback, close, and
  invalidation after worker/native failures.

## Ownership and side effects

- Source preparation uses a private Org buffer and does not modify source text.
- Conversion produces a body result containing the stree and provenance; it
  does not create a serialized `.tm`, `.stm`, or `.tmml` intermediate.
- Worker and native session state are derived runtime state, not a second
  canonical document source.

## Validation boundary

The final v0.2.0 suite recorded 146/146 ERT tests passing together with local
and straight installation probes and Nix checks/build on x86_64-linux. Coverage
included ordinary versus STM encoding, mixed islands, repeated native updates,
session cleanup and failure invalidation, and source non-modification. It did
not establish GUI rendering, visual pagination, serialization, or other
systems.

## Explicitly outside this state

- A public explicit-source core; the whole-document entry still selects the
  current Org buffer implicitly.
- Complete effective Org configuration and `#+OPTIONS` semantics.
- Rich document metadata, lists, static code blocks, tables, and TOC.
- style and initial environment as first-class document result fields.
- Internal/file link resolution, citations, bibliography, and references.
- Multi-session, preview, serialization, PDF, and export integration.

## Next durable direction

Clarify the long-term AST-first document model and tighten source ownership,
snapshot consistency, and non-destructive/composable behavior before expanding
the supported document semantics.
