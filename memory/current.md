# org-texmacs persistent memory

## State represented

This checkpoint reconstructs the durable project state at the v0.1.0 release
on 2026-09-11. It is grounded in project commit
`6fd48944c238e0b627e3bc2d47e224ebf8e2892b`.

## Objective

Provide a stable parsing and AST-island foundation for embedding TeXmacs STM
inside an Org source document. Org remains the sole canonical source; parsed
TeXmacs trees are derived data.

## Established design

- Reuse Org-native `texmacs` special blocks and supported inline fragment
  spans instead of defining a separate persistent source language.
- Send raw STM source to TeXmacs itself. Do not implement an STM parser in
  Emacs Lisp.
- Keep one persistent headless TeXmacs worker and communicate over a local
  Unix-domain socket instead of starting TeXmacs for every request.
- Convert TeXmacs strees mechanically to Org-compatible pseudo trees and back.
  Do not register every TeXmacs tag as an Org element type.
- Copy string leaves at the Org adapter boundary so Org parent properties do
  not mutate the original stree.
- Parse TeXmacs islands lazily and use Org's custom element cache. Accept
  coarse cache invalidation rather than introducing stable block identities or
  real-time AST synchronization.
- Reject invalid strict Scheme input before using TeXmacs' recovery parser.

## Implemented capability

- Block and configurable inline-fragment source discovery.
- Exact raw source extraction from Org buffers without modifying the source.
- Persistent worker parsing through TeXmacs 2.1.5.
- stree to Org pseudo-tree adapters with parent-link and round-trip coverage.
- Lazy public tree APIs and cache reuse/invalidation.
- Package setup and use-package/straight documentation.

## Validation boundary

The v0.1.0 release was validated on x86_64-linux with Emacs 31.1, Org 9.8-pre,
and TeXmacs 2.1.5. The recorded release checks included the then-current ERT
suite and Nix checks/build. These results establish the parsing foundation;
they do not establish later document-lowering or native-session behavior.

## Explicitly outside this state

- Whole-document Org AST lowering.
- Source-aware native TeXmacs encoding.
- Persistent native document/body sessions.
- Effective Org document configuration and metadata.
- Serialization, export, PDF, preview, and live synchronization.

## Next durable direction

Build a finite, structured Org body lowering pipeline that consumes parsed
TeXmacs islands without flattening them back into an intermediate text format,
then prove that the resulting body can be installed in a persistent native
TeXmacs session.
