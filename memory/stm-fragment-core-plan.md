# v0.8.0 core interfaces and development gates

## Status and authority

The user closed the exploratory phase after E0–E7 and requested interface/scope
freeze followed immediately by node 1. This is the current implementation plan;
older open-interface and experiment-priority statements are superseded here.
The project snapshot actually audited is this checkpoint's additional project
parent (released v0.7.1). Implement directly in the ordinary project worktree. Review actual Git diffs;
tmp is only for temporary data and experiments. Ordinary commits remain human-owned.
No ordinary project staging/commit, version or release-state change is included.
No new preparatory experiment is required absent a new architectural conflict.
The handoff's decisions are distilled here; duplicating its raw text adds no
independent evidence value. E0–E7 records retain their original observations.

## Public interfaces — frozen responsibilities and signatures

- `(org-texmacs-call-with-ast-context function)`: run a zero-argument FUNCTION
  with scoped stm-fragment registration, restrictions, parser and interpreter;
  return its result. Use this for generic Org traversal/copy/interpretation of
  extended ASTs. Nested calls and exceptional exits restore the prior environment.
  The scope is synchronous; no permanent backend/parser registration or hooks.
- `(org-texmacs-ast-parse-buffer source-buffer)`: return a fresh extended Org
  org-data AST for the complete live Org buffer. Preserve text/properties, point,
  mark and narrowing. Capture effective native Org syntax in the parsing
  transaction; do not run Export preparation, file acquisition or STM worker.
  Fragment :stm-source contains exactly the compound datum text, :value the
  input carrier; native :begin/:end/:post-blank remain structural metadata.
  The returned AST is caller-owned mutable data, independent of the source.
- `(org-texmacs-ast-to-model ast &key islands context)`: pure ownership adapter.
  ISLANDS maps original AST node identities to already parsed STM trees; require
  a mapping for every stm-fragment and native body being consumed. No automatic
  parsing of missing values. Copy through the existing owner; replace fragments
  with island anchors and remove authoritative raw fragment content. Preserve
  ordinary structure, caption/secondary references and existing island checks.
  Return a read-only owned model. Extra/detached/duplicate mappings are errors.
- `(org-texmacs-model-to-ast model)`: return an independent mutable extended
  org-data AST directly from a validated model, using its known trees and the
  pure writer. No source parse or worker. Nonrepresentable inline tree fails
  without modifying MODEL. Native block semantics and affiliation are retained.
- `(org-texmacs-ast-serialize ast)`: independent extended-AST to normalized Org
  string. Use scoped interpretation and lexical/Org structural checks, without
  constructing a full model or parsing STM natively. :stm-source must satisfy
  lexical single-compound syntax; this interface does not certify native STM
  validity. Output is deterministic and idempotent within its supported domain.
- Existing `(org-texmacs-parse-buffer source-buffer)` keeps its model result,
  snapshot/source guards and explicit native STM parsing role. It orchestrates
  the new source AST entry, native parsing requests and ownership adapter.
- Existing `(org-texmacs-model-create ast &key islands context)` remains the
  low-level pure direct constructor for ordinary Org AST anchors and known STM
  trees. It does not implicitly interpret unparsed stm-fragment objects.
  Existing model-copy/island/replacement retain their validity/ownership rules.
- Existing model-serialize and model-to-buffer keep their signatures/results.
  They compose reverse conversion and normalized source output; new paths are
  worker-independent. No redundant public single-tree model constructor: supply
  a tree in ISLANDS or consume it directly in a future preview consumer.

Parsing buffer source, generic Org copy, and model ownership are distinct:
Org's copy is not a replacement for the model owner. A caller-built extended AST
is accepted without source scanning; source spans are not authorities for it.
No live buffer is required after AST/model construction. Direct AST/model input
never triggers Export preparation or source-file lookup.

## Initial pure writer domain and error protocol

No tag whitelist. Compound structure follows existing model validation: non-nil
symbol head, proper finite child list, children strings or such compounds.
Atomic strings remain valid model trees; inline compound carriers cannot express
an atomic island and do not add math/concat wrappers. Native blocks keep their
existing representation contracts rather than inheriting inline-only rejection.

Initial label encoding accepts nonempty printable ASCII symbol names without
whitespace or DEL/control characters. Backslash and parentheses are escaped with
a backslash; numeric/reserved initial characters [0-9:#] receive the E5-tested
STM reader disambiguator (backslash followed by apostrophe). Other characters
are emitted literally. Labels containing quote, apostrophe, backtick, comma,
semicolon or vertical bar are initially rejected pending maintained encoding
coverage; this is an output implementation boundary, not a recognition whitelist
or invalid-model rule. Empty, whitespace-bearing and non-ASCII labels likewise
fail explicitly in the initial writer; no claim they are permanently impossible.
Maintained native roundtrip tests gate the chosen lexical classes at node 3;
implementation evidence may extend this domain without weakening model validity.

Strings use E5's STM encoding, not prin1 or Scheme write: protect backslashes
and double quotes for STM and Scheme-read transport, emit LF/CR/TAB as textual
escapes, retain tested Unicode and other control characters losslessly. Verify
actual native STM equality independently; Scheme read alone is insufficient.
The production writer must not call a worker or reparse known trees to generate
text. Reject unsupported encodings before partial output escapes the interface.

Errors keep existing condition families and human-readable first data item:
- Invalid AST/model/mapping/context: org-texmacs-model-error.
- Recognized malformed source carrier, or native STM rejection:
  org-texmacs-parse-error; transport retains org-texmacs-worker-error.
- Valid model but unavailable source representation:
  org-texmacs-model-serialization-error. Add a diagnostic plist after the message
  with :reason (atomic-fragment, unsupported-symbol, org-container or
  unsupported-context), :path (snapshot-local structural path when available)
  and :tag (symbol when relevant). No live source identity is required.

All failures leave inputs unchanged and return no partial result. Output checks
compare exact STM trees, meaningful text/whitespace, island order/location and
Org structure, and require a second normalization to equal the first. Org
container conflicts (notably table | and description ]]) fail explicitly;
no automatic escaping that changes the tree or repair of native Org nesting.
A safe native-compatible combination is the baseline, not universal composition.

## Removing fragment-tags without changing model ownership

Remove org-texmacs-fragment-tags, old discovery/span APIs, tag watchers/root
regexes, tag snapshots/staleness guards and tag-based source/serializer checks.
Do not retain a disabled legacy mode or repurpose tags as a filter. Bare inline
STM becomes ordinary Org; native blocks remain recognized.

Do not store :fragment-tags in new model contexts. At the public model-create
boundary, recognize a single obsolete :fragment-tags input key only to discard
it before storage, after the same ownership-safe data validation as other input;
duplicate/invalid context remains an error. This one-way normalization preserves
previously valid explicit constructor data without an inert stored compatibility
field or old discovery behavior. Copy/snapshot/replacement normalize old models
through the same constructor path; never mutate the source context. Remove the
key from newly captured contexts, recorded-syntax requirements, source-buffer
checks and serialize/fontification initialization. Keep heading-settings,
link-settings, source-file and resource-base: each still has independent syntax
or resource meaning. Their validation, graph copying and identity remapping stay.

## Frozen core nodes and acceptance gates

1. Scoped object integration. New dedicated fragment-object module (do not
   overload the existing stree/pseudo-tree ast module), core parse-error and
   Org interfaces. Deliver call-with-ast-context and ast-parse-buffer, local
   registry/restrictions, nonrecursive parser/interpreter and worker-free lexical
   scanner. Gate: unknown roots/both carriers, native successful containers,
   title/caption/link-description, opaque precedence, strict incomplete errors,
   no cross-structure scan, nested/exception/backend restoration, cache isolation,
   source-state preservation and traversal/copy. Native STM validation is node 2.
2. Existing-owner adapters. model/parse/source modules; implement ast-to-model
   and model-to-ast ownership integration. Depends on 1; reverse writer portion
   completes with 3. Gate: independent known-tree construction/copy/replacement,
   no double authority, secondary/caption identity, no parse/worker on pure paths,
   adjacent anchor/post-blank stability, failure does not change valid models.
3. Writer and normalization. serialize plus the fragment interpreter, dependent
   on 1/2. Implement pure encoding, ast-serialize, model source output, structured
   diagnostics and context-safe output checks. Gate: maintained actual native
   roundtrip across accepted encoding classes, explicit rejection classes,
   atomic/source distinction, exact whitespace/tree/structure/idempotence and
   no hidden worker. Native validation is an acceptance test, not implementation.
4. Standard Export. export/ox/document/input/Cite paths, dependent on 1–3.
   Consume final prepared/filtered AST, register transcoder and reuse existing
   ownership/discovery. Include E6's lowering-context and separated post-blank
   fixes. Gate: real org-export-as texmacs selection/INCLUDE/macros/Babel/filter
   add/change/delete, Cite/ID/typed references/blocks, nested backends and cleanup;
   never restore original source or duplicate Org preparation.
5. Legacy removal and fontification. fragment/main/font-lock/parse/serialize/
   tests; dependent on 1–4 before integrated acceptance. Remove old bare/span
   public contracts and tag context paths, connect worker-free new recognition
   to Scheme highlighting, tolerate incomplete editing and retain block editing.
   Gate: no accidental bare discovery, opaque regions intact, source/tick stable,
   no worker in fontification, documented breaking API migration.
6. Integrated acceptance. tests/README/examples/build definitions as needed,
   dependent on 1–5. Synchronize implemented behavior and migration documentation;
   core/native/PDF/example/format checks plus necessary E8 cache, cleanup and
   bounded performance checks. Require Org >=9.8.10 and Emacs >=31.1; no package-wide Org10-pre. Do not advance release state,
   version or tag under this plan. Review each node as its own valid candidate.

After core stability/validation, evaluate OTP last as a nonblocking independent
consumer; separate review before any MVP. Defer to the v0.9.0 priority candidate
if bounded implementation is unsuitable. See evolution topic for its conditions.

## Source syntax snapshot clarification

The extended org-data root carries :org-texmacs-syntax, an independently owned
plist of :heading-settings and :link-settings using existing context shapes.
It is conversion metadata, excluded from document semantics. Capture it before
scoped registry changes. AST-to-model merges with explicit context: overlapping
syntax fields must be equal or signal model-error. The owned model AST drops
this metadata; model context is authoritative. Model-to-AST copies it back when
complete. Missing metadata never prevents pure AST/model operations; source
serialization requiring it fails explicitly rather than reading ambient syntax.
Shared pure capture helpers belong in a syntax module; no parallel graph copier.

Each node uses actual worktree diffs and its own tests. Do not archive ordinary
source patches already represented by project history. The old tmp patch is an
optional starting point, not a mandatory delivery workflow.

## Minimum version maintenance decision

The user raised the v0.8.0 minimum from Org 9.8 to 9.8.10 to bound maintenance
scope. Emacs stays >=31.1. This does not refute E7's successful Org 9.8 probes
or establish incompatibility. Preserve those historical results unchanged; no
new 9.8 compatibility layer or separate 9.8 regression gate is required. Current
minimum-version acceptance uses Org 9.8.10. No Org 10.0 dependency is adopted.
