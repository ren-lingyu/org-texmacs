# Independent mathematical-document AST: v0.6.0 development direction

## Source, status and scope

The user supplies the twelve-section "Core Mathematical-Document AST Development
Guide" in conversation on 2026-11-02 as their preferred description of the
v0.6.0 core feature. It follows the adopted project positioning in goals.md.
The feature is independent parsing, structural inspection, finite transformation
and normalized Org serialization, with existing TeXmacs export remaining usable.
Use the finalized v0.5.0 release tree as the stable baseline. Current ordinary
HEAD matches that stated baseline during the initial read-only survey.

Treat this as the preferred implementation direction and acceptance contract,
not a frozen type/API design or permission to edit ordinary project files, run
probes, tests, builds, formatters, or change ordinary Git/external state. Related
existing functionality should be reconciled with the new core boundaries; this
does not select unrelated cleanup. The exact release inventory and export
adaptation extent remain to be agreed. Initial survey below is static and
targeted, not a complete dependency audit or runtime verification.

Retention assessment: sufficient recovery-relevant design and source findings are
distilled here and in the main memory files. The chat guide has no separately
inspected repository-file original or supported file digest. No independent
original-byte evidence need remains, so no raw archive is selected.

## Complete model contract

- Own a valid native Org org-data AST, parsed native STM trees, unambiguous
  island positions/identity associations and necessary structural/source context.
- Every recognized island has a real tree; atomic STM leaves may be strings.
  No detached, duplicate or erroneous associations. Org parent links and node
  ownership must agree.
- Core construction/inspection/operations work independently of TeXmacs document
  lowering. Valid Org constructs unsupported by that consumer remain valid core
  inputs; this is not a commitment to broaden TeXmacs output support.
- Return detached snapshots independent of the original source buffer's lifetime.
  Keep the existing read-only/ownership convention where appropriate.
- Keep a constructor accepting existing Org AST and parsed STM trees; it needs
  no parser invocation. Source-buffer parsing is not the only entry point.
- Separate generic model data from export INFO, target style/initial,
  bibliography formatting and output reference allocation. Survey dependencies
  before choosing whether/how to split org-texmacs-input. Do not invent a third
  complete AST or rewrite all preparation to establish a new interface.

## Recommended implementation nodes

1. Survey existing structures and dependencies. Classify fields, constructors and
   consumers; locate lowering preflight and earlier export-specific mutations.
2. Establish independent construction from a buffer and from supplied native
   trees. Reuse source capture/protection, discovery, native parsing, ownership
   and mapping machinery where contracts fit. Preserve caller source state and
   give explicit invalid-STM/invalid-model errors. All recognized islands must
   be parsed before exposing a complete model; intermediate parsing may be deferred.
3. Add structural inspection as the first independent consumer: readable Lisp/
   S-expression projection and an Emacs display buffer. Preserve document order,
   understandable Org hierarchy and important attributes; expand actual STM at
   its associated location, distinguish text/Org/islands, avoid recursive parent
   expansion and expose anomalies explicitly. Do not mutate, reparse or lower.
   The illustrative (stm ...) boundary is view-only, not a canonical node type
   or persistence format. Plain pretty-printed text suffices initially.
4. Add pure AST -> Org string serialization, then a convenient editable Org
   buffer. First establish untransformed structural round trips and normalization
   idempotence. Investigate org-element-interpret-data, but do not apply it to the
   current masked/split AST and assume islands are restored. Correctly combine
   Org serialization and actual island trees at their positions; avoid loss,
   duplication and double escaping. Local serialization/structured replacement
   are candidates, not a required text-placeholder algorithm.
5. Add finite AST -> AST operations: read-only traversal, island access by
   position, identity transformation and limited STM subtree replacement. Prefer
   a fresh snapshot, not mutation of a previously exposed read-only object.
   Copy/rebuild parents, own replacements and explicitly retain/remove/move/remap
   islands. Invalidate or recompute affected reference/other derived data. Failure
   preserves the original model. Do not combine arbitrary destructive Org edits
   with an unchanged identity map. No general rewriting framework is required.
6. After a minimal usable core, research standard Org Export -> core AST ->
   TeXmacs lowering -> native output. Nodes 4/5 may reorder based on dependencies;
   arbitrary AST transformation support is not an export-adaptation prerequisite.

## Serialization and equivalence

Investigate native TeXmacs STM serialization; generic Emacs printing is not an
unverified substitute. Existing complete .tm file serialization is a distinct
consumer and does not establish a standalone STM serializer contract. Single-line
STM output is sufficient. Verify tags, string escaping, Unicode, special
characters and atomic leaves through the actual native parser.

Normalized Org need not preserve original whitespace, empty lines, concrete
equivalent syntax or STM indentation. It must preserve important Org hierarchy,
structure and attributes, island positions and internal trees, reference/link
relations and content not explicitly selected for deletion. Unsupported reliable
serialization must fail explicitly or have an explicit bounded support profile.
Core construction support and initial serialization support may therefore differ.

Let P parse Org into the complete model, S serialize the model to Org text, and
T be a supported structural transformation. Acceptance properties are:

- P(S(A)) is structurally equivalent to A for supported valid models.
- S(P(S(P(B)))) = S(P(B)) for supported source documents.
- P(S(T(P(B)))) is structurally equivalent to T(P(B)).

Equivalence is not Lisp identity; compare important Org semantics/structure and
island placement/tree content, ignoring source coordinates and nonsemantic
spacing. Define that comparison explicitly rather than treating raw object
equality or the human inspection projection as the semantic oracle.

## Tests and compatibility

Reuse existing Nix/ERT infrastructure and core/native suite separation according
to native parser requirements. Do not refactor the test framework as part of
this feature. Cover legal Org beyond lowering support, block/inline islands,
STM non-ASCII and special characters, copying/association validity, source
preservation and disposed-source lifetime, malformed STM/model errors, identity
and finite replacement transforms, independent inspection without TM/PDF, and
AST transformations without text intermediates. Keep existing TeXmacs export
regressions and supported behavior working. No validation command is currently
authorized by this guide intake.

## Later export integration and exclusions

Investigate real standard preparation/private working buffer, AST construction
and filters, export INFO, Org Cite processors, hooks/extension dynamic scope,
STM protection and island identity mapping separately. Org AST -> buffer -> AST
may be experimentally useful, but does not by itself retain INFO or dynamic
context and does not establish standard org-export-as support. The user's
current org-roam-organize standard Org Cite integration is an important future
acceptance case; avoid dedicated org-texmacs compatibility logic for that package.
Actual current extension behavior has not been inspected in this intake.

Exclude knowledge-base/cross-document transforms, a third complete AST, formal
math/OpenMath conversion, live incremental synchronization, complex STM
formatting, a general rewriting framework, per-extension compatibility layers,
and unrelated build/test/repository architecture changes.

## Initial code survey: observed facts and implications

The following observations come from targeted reads of the unchanged v0.5.0
baseline, not an implemented candidate or runtime experiment.

- lisp/org-texmacs-input.el defines AST, INFO, ISLANDS, POST-BLANKS, STYLE,
  INITIAL, SOURCE-FILE, RESOURCE-BASE, BIBLIOGRAPHY and RESOLUTION slots.
  org-texmacs--input-own copies strings/lists/vectors, rebuilds parents and
  secondary ASTs, and remaps identity associations, rejecting detached/duplicate
  keys, cyclic/multiply-owned nodes and deferred/opaque values. It also captures
  presentation functions/defaults and validates target-specific settings, and
  imports the document module. It is reusable machinery, not an already generic
  model constructor or proof of complete island semantic validity.
- org-texmacs-input-create calls --input-finalize: document resolve/allocation
  freezes export references, retaining document-domain failures for later
  lowering. It does not itself run document lowering or native parsing. Removing
  only a lowering call would not remove these dependencies.
- lisp/org-texmacs.el --prepare-buffer captures source/configuration, constructs
  prepared data, applies configured citation-key filters, collects/parses/plans
  bibliography, invokes --document-lower with special-block-preflight enabled,
  then parses island requests and constructs/finalizes the input. It signals a
  stored resolution failure and can format bibliography before returning the
  selected consumer's result. Thus prepare-buffer's identity consumer is still
  export-oriented preparation.
- lisp/org-texmacs-document.el --document-prepare masks inline spans, parses Org,
  registers block keys or split inline string keys with temporary placeholder
  strees and native requests, records post-blank data and applies restricted
  context preparation. The walk recognizes selected native block/container/
  caption contexts; do not assume universal core island coverage from it.
- lisp/org-texmacs-context.el --context-prune removes comments, supported captured
  metadata keywords and property drawers, rejects unsupported property drawers,
  and applies export headline/tag/archive selection. --context-prepare also
  selects/restores needed footnotes and filters reachable mappings/requests.
  These are observable source-content selection steps before lowering, not
  general full-document parsing. A separate core path must preserve source
  semantics/content rather than inherit that pruning by default.
- lisp/org-texmacs-fragment.el discovers configured paragraph/inline-footnote
  fragments in private source copies, with masking, fixed tags/source guards and
  original source-span identities. These transient span objects retain a buffer;
  they cannot be exposed unchanged as the detached final model.
- lisp/org-texmacs-ast.el provides STM/Org-compatible pseudo-tree adapters;
  org-texmacs-worker.scm parses one STM datum with native stm-snippet->texmacs
  and returns a stree. Existing serialize operation builds a complete native
  .tm document. Standalone STM serialization remains an investigation item;
  response-wire printing is not evidence of STM output round-trip correctness.

Next: complete a field/constructor/consumer dependency map and a bounded core
contract proposal, including full-source preservation, island identity and
serialization support. Do not freeze names/layout or start source edits merely
from this survey. No native probes or third-party/API compatibility verification
has been run.
