# Issue13 stage2: adopted raw-STM equation guidance

## State, source and authority

User supplied updated INBOX, requested review, then adopted all four review
corrections and requested GAW updates. This turn is memory/governance work,
not source implementation, testing or release authorization. Stage1 delivery
and its17focused/495full acceptance remain distinct; none validates stage2.
No implementation node has started. No ordinary project/INBOX/version/lock,
index, dependency, GitHub issue, tag or release changes authorized here.
Preserve/exclude existing flake.nix ELPA mirror workaround.

Source: ordinary project root INBOX.md, ignored/untracked regular UTF-8 file,
23584bytes, SHA256
71c40dd0686b702f2f87dbbc4ba9b5a1c752c3e9ff8f88be073976498a2ec85c.
First review recorded this identity; current metadata/hash matches. Source
describes stage1 project baseline and an older GAW checkpoint; recover current
memory instead of restoring the old GAW baseline. No new external lookup.

Retention decision: no original archive. This active implementation guidance
contains no unique runtime/experimental evidence; source semantics, constraints,
acceptance and adopted corrections are sufficiently extracted here and routed
through current/project/backlog/release/special-block-plan/evidence. Losing exact
wording after this extraction does not materially impair evidence or handoff.
Mutability or having reviewed the wording alone does not justify raw capture.
No archive directory/files were created. Do not assume INBOX will remain equal
on a future read, and do not claim an original-byte snapshot exists.

## Intended source and native contract

Only begin_equation and begin_equation* are added in stage2, producing exactly
(equation BODY)/(equation* BODY) as document block children. Each body is one
complete raw STM datum parsed by the existing native worker, not recursive Org
prose. String datums, including an empty string datum if accepted natively,
are structurally allowed. Do not impose a mathematical root whitelist/type
system, automatic math wrapping, counter model or Elisp STM parser. Native
equation/with/document roots are not rejected merely for their apparent meaning;
TeXmacs owns tag interpretation, math mode, layout and numbering.

Raw source retains exact whitespace and escapes; Org's actual block boundaries
remain authoritative. One block -> one island keyed by block identity -> one
body STM request. Do not discover interior fragments or interpret raw-looking
Org markup/keywords/citations/notes/nested markers as Org dependencies. No
automatic concat of multiple datums. The existing reader rejects empty input,
multiple datums and malformed STM; preparation must reject empty/whitespace
source before body requests, without rewriting it. Nonempty parameters reject;
missing/equivalent whitespace parameters follow actual pinned Org AST behavior.

Continue strict affiliated NAME/CAPTION/ATTR rejection; native label nodes are
ordinary opaque STM, not automatic Org NAME, and are not forbidden just for
existing. No new Org align/gather/eqnarray/eqsplit wrappers. Keep native texmacs
block/inline-fragment and statement/custom-handler semantics unchanged.

## Layer responsibilities and adopted review corrections

1. Keep org-texmacs--block-p and --block-source exclusively about texmacs:
   editing/cache/source callers rely on that contract. Introduce a small shared
   private native-body classifier for texmacs/equation/equation*, plus a bounded
   raw-source helper if needed. Use the same classification throughout preparation,
   fragment exclusion and scoped selection. Do not make statement opaque.
2. Extend ALL opacity boundaries, not just the guidance's document/fragment
   entries: preprocessing protect currently uses block-p, bibliography discovery
   masks block-p bodies before Org discovery, and context region reparse rebuilds
   opaque mappings with block-p. Update these paths too. Test raw-looking INCLUDE,
   keywords, citations and footnotes cannot leak into preprocessing/discovery/
   dependency restoration, while surrounding real Org still works.
3. Preparation registers original raw source once, without walking superficial
   Org children. Include native-body blocks in scoped opaque sets, paragraph
   collection exclusions and full-block region/narrowing checks. Preserve owned
   source coordinates/origins through INCLUDE, filters, restored dependencies
   and waits. No second equation buffer/island lifecycle unless actual evidence
   shows existing structures insufficient.
4. Distinguish empty raw source from native datum "": preparation owns the
   empty-source check. Pure lowering never reads source and must not infer an
   empty source from an empty parsed string. Lower checks node parameters,
   mapping identity/uniqueness and stree structure. If source-emptiness validation
   must also be represented there, carry explicit owned preparation information;
   do not invent it from parsed BODY or require coordinates on manual ASTs.
5. Pure mapped-block dispatch: texmacs emits island directly; equation/equation*
   packs exactly one environment around the island. Other full block mappings
   reject. Reuse document-pack to prefix provenance. A single equation in a
   metadata-free document has stm-paths ((0 0)); assert actual paths target the
   original native root. Raw STM hlink is not an Org file-target provenance slot.
   No new concat/document layer between equation and BODY, and no route through
   generic recursive handler(block,contents,info).
6. Reserve normalized equation/equation* registry names against custom override.
   Future NAME labels belong within formula counter scope; stage2 neither adds
   labels nor an exterior surround workaround.
7. Preflight rejects detectable source/parameter/metadata/identity errors before
   BODY STM requests, with no mathematical inspection of placeholders. Prior
   bibliography requests are allowed; malformed/multiple datums require actual
   body reader requests. Built-in equations do not call custom handlers. No
   placeholder escapes final input/encoding, and bibliography order is unchanged.
8. Narrow failure promises to established boundaries: structural/parse failures
   before file writing preserve existing output; source/caller state preservation
   follows existing guards. Transport/cancellation still stops worker and can
   invalidate session handles. File-write failures retain documented partial-write
   behavior. Do not add atomic output publication or session recovery obligations.
   Preserve document/parse/transport error distinctions and valid parse retry.
9. Update GAW during first review and development, not only after ordinary commit.
   At acceptance/delivery reconcile facts and record exact candidate-vs-commit
   equivalence. Do not modify skills merely for stage progress, rewrite old
   evidence or infer original runtime provenance from a later commit.

These incorporate the user's four accepted review tightenings: complete opacity
coverage, empty-source versus datum distinction, bounded failure guarantees and
timely memory updates. The classifier/helper API details remain for the separately
authorized implementation plan; no runtime/native design claim has been verified.

## Investigation and maintained acceptance

- Locked Org parser: equation/equation*, case/whitespace, missing/mismatched end,
  parameters and contents bounds, empty bodies, raw Org-looking text, and actual
  statement/quote/center/list contexts. Do not patch parser or invent nesting
  syntax if a form is not supported. In particular starred names need real proof.
- Structural/pure tests: one raw capture/island/request per block, exact wrapper
  and raw string/stree provenance, string/frac/sqrt/concat/multiline STM, direct
  texmacs unchanged, owned AST/islands unchanged under repeated lowering, reserved
  registry/snapshot checks, strict metadata/parameters/mapping errors, scoped
  clipping/filter/INCLUDE/restored-note/source-change and cleanup paths.
- Opacity/preflight tests: default-tag math inside equations produces no fragment,
  surrounding paragraph fragments still discovered; no-bibliography detectable
  failures have zero requests; bibliography case allows earlier bibliography
  only, no body requests after rejection; actual reader rejects multiple datums.
  Cover both built-ins, no custom callback and no escaped placeholders.
- Native evidence: independent matched style/initial fixtures for numbered and
  unnumbered string expressions, representative fractions/display layout,
  consecutive numbered equations plus a starred equation, native counter behavior,
  Unicode/native-source encoding, valid parse after malformed STM, and supported
  statement nesting. Compare direct PDF, saved tm/native readback and reload PDF
  using existing Issue11/stage1 geometry helpers. Text alone is insufficient for
  positioning/numbering claims; do not hide direct errors behind reload repair.
- All stage1 statements, Issue11 display/concat, raw texmacs/inline fragments,
  naked tables, input/encoding, bibliography/restrictions and failure recovery
  remain required regressions. Add targeted tests to existing ERT, no new framework.
- Update README to exact implemented contract and limits. Fresh focused/full ERT,
  strict compile/lint, applicable flake and no-link package build required before
  completion; prior495 tests do not certify stage2. Record exact commands/results,
  versions/limits and final input identities. Existing ERT derivation environment
  includes Poppler; ordinary devShell lacked it during stage1. Do not alter flake
  just to compensate or silently change lock/config/dependencies. Future command
  authorization must state exact commands, writes/network/cost/timeouts; stage1
  grants do not authorize new stage2 runs in this memory-only task.

## Sequence and next action

Logical steps: A parser evidence/classifier/raw capture/fragment exclusion;
B full preparation/context/preflight/reserved names/lowering/provenance;
C native tm/PDF/direct-reload verification, docs and final checks/delivery review.
These are not mandated separate commits; any intermediate committed state must
be coherent/recoverable. Source implementation, staging and checks await separate
authorization. Ordinary commit remains the user's action; eventual footer Refs:#13,
not Closes. No issue/version/release action. Skill updates use separate checkpoints
from memory/archive; archive captures, if independently warranted, remain separate.

Next after stage2: stage3 figure/table plus experimental starred wrappers;
stage4 single-object NAME/[[name]]. Independently named composite formula rows
remain Issue9 after0.5.0/before0.6.0. This sequencing does not expand this phase.
