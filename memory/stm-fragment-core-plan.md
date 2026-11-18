# v0.8.0 core interfaces and development gates

## Status and authority

Node 1 was delivered under the original freeze. This plan governs Nodes 2–6
under stm-fragment-architecture-revision.md, which partially supersedes the
original interface freeze. E0–E7 retain their original evidence. Develop in
the ordinary worktree and review actual diffs. Ordinary commits remain
human-owned. This memory revision grants no source implementation authorization.

## Model and public interface boundaries

Org-TeXmacs AST means the complete mathematical-document Model, logically one
tree and physically native Org AST + identity-keyed parsed STM islands +
explicit syntax/source context. Org is canonical authoring source. Structural
inspection, copy, replacement and other transformations operate on the Model.
Temporary unparsed recognition results help construct it.

- Delivered Node 1 APIs: org-texmacs-call-with-ast-context supplies scoped
  registration, recognition and interpretation; org-texmacs-ast-parse-buffer
  returns the complete buffer's Org recognition tree with unparsed STM
  objects and root syntax snapshot. Its preservation and strict lexical
  contracts remain delivered. Review callers, tests and README before deciding
  its public role, internalization, naming or replacement and handling :value.
- Public complete-AST basis: org-texmacs-model-create (ast &key islands context),
  model-copy, model-replace-stm, model-inspect and existing model-serialize /
  model-to-buffer. Keep direct parsed-tree construction independent of workers.
  Review org-texmacs-parse-buffer as the existing source-to-Model entry and retain
  its result type, source guards and explicit native parse boundary.
- The public ast-to-model / model-to-ast pair and standalone ast-serialize for
  an unparsed Extended Org AST are superseded requirements. Internal helpers
  may serve concrete consumers. General Model transformations need no
  projection or mathematical source roundtrip.

## Model representation

Each non-block island key is an owned nonrecursive stm-fragment Org node.
Native block keys retain their existing semantics. Every recognized island has
an associated parsed STM tree, the unique authority for its mathematical
contents. Reject string keys, including in direct model-create input, without
a compatibility branch or placeholder characters. Ordinary Org text is legal.

Strip :stm-source and :value on the owned stm-fragment only. Retain required
Org structure, including :post-blank, and rebuild identity, parent and
secondary/caption relationships with the existing model owner. Validate the
complete owned result and preserve caller inputs on success and failure. Do
not assume a generic Org copy owns arbitrary custom property values.

Atomic STM string roots have no support guarantee and no special prohibition.
Add no dedicated handling, acceptance gate or required diagnostic. Compound
STM string leaves retain their existing semantics. Model validity and output
support remain separate.

## Initial pure writer domain and error protocol

No tag whitelist. Compound structure follows existing model validation: non-nil
symbol head, proper finite child list, children strings or such compounds.
Generate from the current parsed island tree, independent of the original
carrier or an anchor string. Do not add math/concat wrappers. Native blocks
keep their own representation contracts. Atomic roots remain unspecified
under the Model policy above.

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
  with :reason (unsupported-symbol, org-container or
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

## Six implementation nodes and acceptance gates

1. **Scoped source recognition — delivered.** Reuse carrier recognition,
   local parser/object registration, interpreter, native container and opaque
   rules, source state protection, syntax capture and existing verification.
   Later interface/attribute review does not change the historical delivery.
2. **Complete Model construction — next, unimplemented.** Audit public
   Node 1 callers and review migration before source edits. Feed temporary
   fragment source to the native parser at the acquisition boundary. Reuse
   owner/constructor for parsed-tree input, object association, materializing
   syntax context and cleaning copied payload fields. Update Model validation
   and its fixtures for object keys, including explicit string-key rejection
   and continuation of native blocks. Audit serializer/lowering consumers now
   so staged work and regressions are coordinated with Nodes 3–5. Existing
   parsed-tree construction, validation, copy and replacement stay independent
   of source buffers and parsers.
3. **Pure writer and Model serialization.** Review existing model-serialize
   worker use and structural roundtrip guard. Emit the current parsed trees at
   object positions, using the E5 encoding evidence and explicit syntax
   context. Independent native roundtrip tests validate supported compound
   classes. Test representation failures, structure, references, meaningful
   whitespace, island position/order and normalization idempotence. Retain
   native blocks and default backslash carrier. No public reverse adapter gate.
4. **Standard Export and lowering.** Keep the real org-export-as texmacs
   lifecycle. Consume the final prepared/filtered AST, including newly added
   or changed fragments. Review lowering's string/context guards and handle
   object islands directly. Test object :post-blank with existing post-blanks
   before choosing a whitespace strategy; E6's separate text sibling solved
   a prototype-specific issue. Check tab/space fidelity separately where
   required. Cover selection, INCLUDE/SETUPFILE, macros/Babel, filter edits,
   Cite, ID, typed references, native blocks, nested backends and failure
   cleanup. Never restore deleted source or duplicate Org preparation.
5. **Legacy removal and editing.** Retire bare discovery and span/tag APIs
   and remove remaining string-island branches, with no legacy mode. Audit
   direct constructor examples and callers. Adapt worker-free fontification,
   preserve incomplete editing and block editing, and document breaking
   changes. Retain the distinct one-way :fragment-tags input policy above.
6. **Integrated acceptance.** Core/native, standard Export, PDF and example
   builds, package-lint/treefmt and necessary E8 cache, cleanup and bounded
   performance checks. Synchronize README and API migration documentation
   with delivered capabilities. Use Org >=9.8.10 and Emacs >=31.1. Release
   metadata, tags and publication remain separate. Evaluate OTP after core
   validation as a final nonblocking candidate.

### Required structure checks for subsequent implementation

Cover a single fragment, adjacent and equal-looking distinct fragments, old
keys failing on a copied Model, replacement identity remapping, and rejection
of detached, duplicate and overlapping mappings. Exercise paragraphs, titles,
long/short captions, link descriptions, inline footnotes and other confirmed
Org containers. Check actual object type, parent, secondary/caption references
and :post-blank. Verify owned objects have neither :stm-source nor :value,
mutation never aliases inputs or earlier Models, and serialization uses the
current island tree. Guard known-tree copy/replacement against reparsing.
Reject using plain text as an island key while still accepting it as Org
text. Add no atomic-root contract tests. Exercise compound string leaves.

## Source syntax and context

Node 1 captures :org-texmacs-syntax on the recognition root. During Model
construction, transfer owned heading/link settings into Model context, removing
the redundant root property from the owned AST. Reuse org-texmacs-syntax.el.
Where explicit context accompanies the snapshot, distinguish absent from nil,
require equality for overlapping syntax fields and report conflicts as model
errors. Preserve explicit source-file/resource-base. Pure Model operations can
work without a snapshot. Output requiring syntax uses captured context and
explicitly fails when it is insufficient; ambient state does not fill gaps.
The property need not roundtrip via a public projection.

## Minimum version maintenance decision

The user raised the v0.8.0 minimum from Org 9.8 to 9.8.10 to bound maintenance
scope. Emacs stays >=31.1. This does not refute E7's successful Org 9.8 probes
or establish incompatibility. Preserve those historical results unchanged; no
new 9.8 compatibility layer or separate 9.8 regression gate is required. Current
minimum-version acceptance uses Org 9.8.10. No Org 10.0 dependency is adopted.
