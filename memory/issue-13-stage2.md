# Issue13 stage2: accepted raw-STM equation candidate

## State, source and authority

User authorized implementation of the reviewed stage2 plan and repeated focused
300s ERT-derivation shell, 600s flake check, 120s no-link default build commands.
Implementation and all three acceptance commands completed successfully. Ordinary staging and
commit are not authorized. Preserve/exclude flake.nix ELPA workaround.

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
timely memory updates. Implemented private helpers are native-body-kind,
native-body-blocks, native-body-source and native-body-check, with
document-check-native-requests called after final selected preparation.
Runtime evidence is recorded below.

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
  grants alone did not authorize stage2; user has now explicitly authorized the
  three stage2 commands below.

## Sequence and next action

Logical steps: A parser evidence/classifier/raw capture/fragment exclusion;
B full preparation/context/preflight/reserved names/lowering/provenance;
C native tm/PDF/direct-reload verification, docs and final checks/delivery review.
These are not mandated separate commits; any intermediate committed state must
be coherent/recoverable. Source implementation and checks are authorized and complete; ordinary staging
requires a later explicit path-specific authorization. Ordinary commit remains the user's action; eventual footer Refs:#13,
not Closes. No issue/version/release action. Skill updates use separate checkpoints
from memory/archive; archive captures, if independently warranted, remain separate.

Next after stage2: stage3 figure/table plus experimental starred wrappers;
stage4 single-object NAME/[[name]]. Independently named composite formula rows
remain Issue9 after0.5.0/before0.6.0. This sequencing does not expand this phase.

## Implemented behavior and maintained evidence

Source changes now introduce native-body classification and outermost collection,
shared bounded raw capture (legacy texmacs block/edit contract retained), opaque
fragment/preprocess/bibliography/context paths, selected-request empty-source
checks in the adapter, pure built-in wrapping and reserved handler names.
No Scheme/protocol/lock/version/flake change. README describes exact support.
Raw-source checks run only after actual scope/filter preparation, not during the
full-source bibliography discovery callback; otherwise excluded malformed blocks
would spuriously reject selected exports. Pure lowering never reads source.

Maintained twelve new stage2 tests cover pure strings/strees/provenance/repeated
ownership, reserved/missing/duplicate mappings, parameters/metadata/preflight,
real parser stars/case/nesting/list/bounds/mismatched ends, outermost capture,
opaque Org-looking content, scoped clipping and omitted invalid equations,
restored-note equations, filter raw-citation rejection and source wait guards.
Native generic/article fixtures compare an independent exact target body/PDF,
numbered1/2 with interleaved star and nested theorem star, Unicode/fraction,
saved tm reload geometry (Issue11 tolerance1pt), strings including empty datum,
escapes and parser recovery. Final strengthened focused29/29 passed29.580234s, including actual preprocessing
entry and native session readback with independently specified native alpha token.
Earlier failed fixtures used a style string instead of required list, selected
headline 'Kept' instead of body 'kept' for clipping, and expected Unicode
transcoding at parse instead of consumption; corrected tests, no weakened policy.
No-link default build and full flake check exited0. Full check includes all ERT,
strict compilation and package lint; only current x86_64-linux evaluated, other
incompatible systems omitted by Nix. Full ERT transcript/count/timing was not
separately extracted from the successful Nix build log. Native evidence scoped to pinned x86_64-linux stack;
no arbitrary-style/GUI/platform or new failure-atomicity claim. No unique raw
artifact archive needed: maintained tests encode independent reproduction.

## Acceptance command and candidate identity

User authorized repeated execution in this task:
1. timeout 300s nix develop --no-write-lock-file path:.#checks.x86_64-linux.ert --command emacs -Q --batch -L . --load tests/ert/ert.el --eval '(ert-run-tests-batch-and-exit "issue13")'
2. timeout 600s nix flake check --no-write-lock-file path:.
3. timeout 120s nix build --no-link --no-write-lock-file path:.#default

Focused exit0:29/29,29.580234s. Full check exit0 (all checks passed); build exit0.
Final manifest recheck after acceptance matches exactly; no task source edits
after final focused run or during full check.
Nix may access network and write store/cache/logs; ERT fixtures create and retire
temporary tm/PDF/native homes. No result link or lockfile change. Environment is
existing locked x86_64-linux ERT derivation with Poppler (Emacs31.1/Org9.8.10/
TeXmacs2.1.5 baseline), not default devShell. No arbitrary native-style coverage.

Accepted runtime candidate is uncommitted atop the delivered stage1 baseline,
not the ordinary committed HEAD tree. No new project-parent edge is warranted
for runtime claims. Ordinary staging/commit remain unexecuted; future delivery
review must compare exact task blobs/diff against this candidate. Nine task paths
are listed below; flake overlay/lock hashes record test inputs, not staging scope.
Manifest SHA256 is computed over these ordered lines (including trailing newline):

```text
7a47c8404026db363a9929e1898d4239457a5ba0dc72196156243f4348a36d67  README.org
9799943545eb4f32719606a6358645ee3533261e3b883e2f94480dda517a1de0  org-texmacs-bibliography.el
3e854783c4ccdd5f3640ea5a3b8ffd489ebfdb5c731adc31a7943deef320ce56  org-texmacs-context.el
564a36d4fef04afefb5c924c9ba5e9b94305df41e367625ef83310599c283503  org-texmacs-document.el
ee817ea45d6eb1747ceed9a5a07dfedf763f10351834c9f6f9b488fdf88ed216  org-texmacs-fragment.el
82470132a46317e3e1bd12f6dd43b79fcfe60e07bbe4ea9a9260bb95d577a6f8  org-texmacs-preprocess.el
7e7ca8b10be0a68ce06c412a99b73747e7e1ec7afe080f22ecc71a698ab25de5  org-texmacs-source.el
67d0a4eb4176879092ed5775fae2cbed1f0d36947851d6ef306047030591aa30  org-texmacs.el
591d5a95204c23ec3e2a30fa0c6e0a51ef4624cc82e4c9068e80adfba9455a49  tests/ert/ert.el
a717dcfa245b1ccaee102ed8eef3a6ae229d0c86b60f674080bab5273d093a8a  flake.nix
118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a  flake.lock
```
Manifest SHA256: ff5d5e825705f600ec94039f63e02de15228664e84a5157c6c718628a92e8368.
