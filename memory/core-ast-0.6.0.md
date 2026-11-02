# Independent mathematical-document AST: approved v0.6.0 development plan

## Source, status and scope

The user supplies the twelve-section "Core Mathematical-Document AST Development
Guide" in conversation on 2026-11-02, then answers planning questions and supplies
nine review clarifications. The revised plan incorporates those clarifications;
the user now requests "Implement the plan" after leaving Plan mode. It follows
the adopted project positioning in goals.md.
The feature is independent parsing, structural inspection, finite transformation
and normalized Org serialization, with existing TeXmacs export remaining usable.
Use the finalized v0.5.0 release tree as the stable baseline. Current ordinary
HEAD matches that stated baseline during the initial read-only survey.

This is the selected implementation direction and acceptance contract. The user's
implementation instruction authorizes the planned file changes, starting with the
GAW plan checkpoint and the CHANGELOG-only first ordinary project delivery.
Respect the mandatory delivery order: do not start source edits before the user
creates and the agent verifies that first project commit. Ordinary project index
changes still require explicit path-specific staging authorization; ordinary
commits remain the user's action. Runtime probes, checks, builds and formatting
require the command/risk disclosure and authorization specified by repository
rules and this plan. No runtime command has yet been authorized or executed.

v0.6.0 completes the independent core loop and preserves existing export behavior.
Standard Org Export integration is investigation and a follow-up design in this
release, not implemented support. ox-texmacs APIs remain compatible; other APIs
may be reorganized as needed, with migration documentation. Do not rename APIs
gratuitously or broaden unrelated work. Initial survey below is static and
targeted, not a complete dependency audit or runtime verification.

Retention assessment: sufficient recovery-relevant design and source findings are
distilled here and in the main memory files. The chat guide has no separately
inspected repository-file original or supported file digest. No independent
original-byte evidence need remains, so no raw archive is selected.

## Complete model contract

- Distinguish structural model validity, expressibility at an Org position under
  the current recognition syntax, and serialization round-trip support. Only the
  first is required by model-create, copy and structural transformation. The
  serializer checks the latter two. No lowering whitelist governs any core
  structural validity decision.
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
  no parser invocation or source rescan to prove recognition completeness.
  Recognition completeness belongs to parse-buffer. Source-buffer parsing is
  not the only entry point.
- Separate generic model data from export INFO, target style/initial,
  bibliography formatting and output reference allocation. Survey dependencies
  before choosing whether/how to split org-texmacs-input. Do not invent a third
  complete AST or rewrite all preparation to establish a new interface.
- STM trees own recognized mathematical content. Org keys retain block type,
  parameters, affiliation and document position; raw source/Org parsing residue
  must never override a changed tree or be duplicated by inspection/output.
- Keep read-only nested references through accessors; do not deep-copy on every
  access. Document the caller's no-mutation obligation: cl-defstruct :read-only
  does not freeze nested data. Copy/replacement owns independent mutable data,
  rebuilds parents/mappings and leaves the old snapshot and its locators valid.
  An old-model node cannot locate an island in a new model. Failure preserves
  the original; use AST paths rather than stale source coordinates for diagnosis.
- Classify fragment tags, headline/TODO/level settings, link parser settings,
  native block conventions and other evidenced parsing/round-trip settings as
  retained model context, temporary construction config or export config.
  Retain only demonstrated necessary context, not full export INFO or a generic
  configuration framework. No source buffer, worker or native session in a model.

## Public interfaces and first-version boundaries

Use a snapshot container named org-texmacs-model for native Org AST, identity-
keyed islands and necessary syntax/source context. Public operations:

- org-texmacs-model-create: own and validate supplied native structures/context,
  with no parser, worker or lowering call.
- org-texmacs-parse-buffer: capture a complete document, temporarily widen and
  restore narrowing, and parse every recognized island in private source copies.
- org-texmacs-model-inspect: readable projection including important secondary
  strings, captions and structural properties, not just normal contents.
- org-texmacs-model-display: show the projection in a new read-only buffer.
- org-texmacs-model-serialize: normalized Org string, checking expressibility and
  round-trip support; native worker permitted only for STM serialization here.
- org-texmacs-model-to-buffer: after successful serialization, create a new
  editable Org buffer, without overwriting another buffer or file.
- org-texmacs-model-copy: independent structurally equivalent snapshot.
- org-texmacs-model-island: read-only tree reference located by a node belonging
  to this snapshot.
- org-texmacs-model-replace-stm: island-node locator, zero-based STM child path,
  replacement tree -> independent snapshot. Empty path replaces the whole island.

The constructor/parser/model operations do not need document lowering. Whole-
document buffer parsing has no new core subtree/region selection interface.
Retain existing block, paragraph and supported inline-note recognition syntax;
headings/captions/other unrecognized STM contexts remain ordinary Org content,
with no loss or implicit reinterpretation. Recognition can later grow separately
from lowering support. Preserve comments, drawers, unused note definitions,
export-excluded headlines and other valid Org nodes. Do not execute INCLUDE,
Babel, Org Cite processors, export pruning or target preflight in core parsing.

Root-changing STM replacement is valid when the replacement is structurally
valid, even if its new root cannot be recognized at that Org position. Such a
model must fail serialization explicitly, never downgrade into ordinary text.

## Required execution and delivery order

1. First update GAW goals/model/backlog/evidence/current and this plan, inspect
   the complete candidate, run public git gaw check and create a plan checkpoint.
   This is a normal memory-loop checkpoint, with no new project association
   needed for the conversational scope decisions.
2. The first ordinary project commit changes only CHANGELOG.org. Add a new
   TODO v0.6.0 before released history, explicitly presenting planned scope:
   Changed: independent core/consumer separation and preserved ox-texmacs behavior;
   Added: buffer/preparsed construction, inspection/display, normalized Org output,
   independent copy/island access/finite replacement, and round-trip properties.
   Preserve the canonical header and all historical versions. No CLOSED, early
   detail manuscript, nonexistent detail link or version metadata update. Suggested
   subject: docs(changelog): plan v0.6.0 core AST development. Review the result,
   wait for human project delivery and verify it before source implementation.
3. Common model/ownership foundation. Complete the field/constructor/consumer
   and syntax-context dependency map; extract common copying, parent rebuilding,
   stree validation and identity remapping. Keep output settings/derived data in
   separate export context. Reuse v0.5.0 machinery where its contract fits.
4. Establish independent construction from a buffer and from supplied native
   trees. Reuse source capture/protection, discovery, native parsing, ownership
   and mapping machinery where contracts fit. Preserve caller source state and
   give explicit invalid-STM/invalid-model errors. All recognized islands must
   be parsed before exposing a complete model; intermediate parsing may be deferred.
   Integrate existing export using common ownership/mapping without unifying
   preparation strategies or moving body STM parsing before existing preflight.
5. Add structural inspection as the first independent consumer: readable Lisp/
   S-expression projection and an Emacs display buffer. Preserve document order,
   understandable Org hierarchy and important attributes; expand actual STM at
   its associated location, distinguish text/Org/islands, avoid recursive parent
   expansion and expose anomalies explicitly. Do not mutate, reparse or lower.
   The illustrative (stm ...) boundary is view-only, not a canonical node type
   or persistence format. Plain pretty-printed text suffices initially.
6. Add AST -> Org string serialization, then a convenient editable Org
   buffer. First establish untransformed structural round trips and normalization
   idempotence. Investigate org-element-interpret-data, but do not apply it to the
   current masked/split AST and assume islands are restored. Correctly combine
   Org serialization and actual island trees at their positions; avoid loss,
   duplication and double escaping. Local serialization/structured replacement
   are candidates, not a required text-placeholder algorithm.
   Before implementing the STM serializer, run an explicitly authorized native
   tree -> STM -> parse experiment covering its actual contract. No generic
   printer fallback or complete .tm serializer substitution.
7. Add finite AST -> AST operations: read-only traversal, island access by
   position, identity transformation and limited STM subtree replacement. Prefer
   a fresh snapshot, not mutation of a previously exposed read-only object.
   Copy/rebuild parents, own replacements and explicitly retain/remove/move/remap
   islands. Invalidate or recompute affected reference/other derived data. Failure
   preserves the original model. Do not combine arbitrary destructive Org edits
   with an unchanged identity map. No general rewriting framework is required.
8. Documentation, standard-export investigation and version completion. Sync
   README, APIs/migrations, examples and actual CHANGELOG scope, and produce a
   follow-up standard Org Export design. Only after functional acceptance update
   package declarations together to 0.6.0. Human version-state transitions, tags
   and publication are separate. Arbitrary AST rewriting is not required.

Each functional delivery includes relevant tests/docs. Stage ordinary project
paths only with explicit path-specific authorization, prepare messages from the
complete staged candidate, and wait for human commit/delivery verification before
the next node. Keep memory current and checkpoint consequential phase boundaries,
not every edit. No unrelated build/test/repository refactor is selected.

## Serialization and equivalence

Verify native TeXmacs STM serialization at runtime before implementation; generic Emacs printing is not an
unverified substitute. Existing complete .tm file serialization is a distinct
consumer and does not establish a standalone STM serializer contract. Single-line
STM output is sufficient. Verify tags, string escaping, Unicode, special
characters and atomic leaves through the actual native parser.
No document lowering, native document sessions or rendering may enter this
serializer. Core inspection, validation and transformation remain worker-free.

Normalized Org need not preserve original whitespace, empty lines, concrete
equivalent syntax or STM indentation. It must preserve important Org hierarchy,
structure and attributes, island positions and internal trees, reference/link
relations and content not explicitly selected for deletion. Unsupported reliable
serialization must fail explicitly or have an explicit bounded support profile.
Core construction support and initial serialization support may therefore differ.

Serialize on an independent Org copy, restore authoritative islands structurally
at the right locations, then reuse org-element-interpret-data. No global string-
placeholder substitution. Prevalidate supported node types/interpreters rather
than relying on Org's unknown-node content-flattening fallback. Initial support:
headlines/sections, paragraphs/common inline objects, lists/notes, keywords,
property drawers/comments, normal containers/special blocks, static code and
ordinary tables, including recognized islands therein. Other structures fail
explicitly with type and AST-path diagnostics without invalidating the model.
Failure returns no partial result and allocates no output buffer.

Let P parse Org into the complete model, S serialize the model to Org text, and
T be a supported structural transformation. Acceptance properties are:

- P(S(A)) is structurally equivalent to A for supported valid models.
- S(P(S(P(B)))) = S(P(B)) for supported source documents.
- P(S(T(P(B)))) is structurally equivalent to T(P(B)).

All equations apply only where the operations are defined, using the same
captured syntax context. A valid model or valid transformed result outside the
serialization domain is an expected explicit error, not a model-validity defect.

Equivalence is not Lisp identity; compare important Org semantics/structure and
island placement/tree content, ignoring source coordinates and nonsemantic
spacing. Define that comparison explicitly rather than treating raw object
equality or the human inspection projection as the semantic oracle.
Use a separate test equivalence helper; preserve valid attributes, document
order, exact STM structure and meaningful text/code/STM-string whitespace.

## Tests and compatibility

Reuse existing Nix/ERT infrastructure and core/native suite separation according
to native parser requirements. Do not refactor the test framework as part of
this feature. Cover legal Org beyond lowering support, block/inline islands,
STM non-ASCII and special characters, copying/association validity, source
preservation and disposed-source lifetime, malformed STM/model errors, identity
and finite replacement transforms, independent inspection without TM/PDF, and
AST transformations without text intermediates. Keep existing TeXmacs export
regressions and supported behavior working. No validation command has yet been
authorized for execution; disclose exact commands, writes/network/timeouts and
obtain required authority before running them. Focused gates per node and full
flake checks at integration/version completion; do not rerun unchanged passed
inputs merely for staging or delivery confirmation.

Targeted regressions must additionally cover pruning-deleted Org content,
lowering-unsupported but inspectable models, block replacement never restoring
old source, inline root changes round-tripping or failing explicitly, secondary
strings/captions/important attributes in inspection, invalidated coordinates and
AST-path errors, old/new snapshot locator isolation, and preflight/STM error
priority plus bibliography timing and cleanup compatibility.

## Later export integration and exclusions

Existing export must share the common model contract and ownership/mapping
machinery but preserve its preparation sequence: target lowering preflight
precedes body STM worker parsing. Preserve bibliography preparation/reference
resolution timing, full/subtree/region/narrowing, public export APIs/settings,
file/buffer management, cleanup and error propagation. Do not replace it with
parse-all-STM-then-preflight. If changing order becomes necessary, first analyze
observable differences and add targeted regressions; ask only when a concrete
external behavior or scope change is required. ox-texmacs compatibility remains
mandatory; other APIs may be reorganized where needed with documented migration.

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

Next: follow the required GAW plan checkpoint -> CHANGELOG-only human delivery
boundary above, then complete the field/constructor/consumer/context dependency
map as the first implementation node. No native probe or third-party/API
compatibility verification has been run.
