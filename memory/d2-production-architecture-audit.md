# D2 production architecture audit

## Baseline and decisions

Audited project revision `0aabcd64225dd921f9dda3ac4877abd91b5efccc`
on clean main. D1 is delivered and its findings remain applicable.
The maintainer adopted a five-argument headline formatter, removal of the old
arity without a compatibility layer, and retention of native operations with
standalone diagnostic value. The remaining proposals below are audit findings
and implementation recommendations. The prior D1 archive retains its original
meaning. No production files or maintained tests were edited in this audit.

Grounding: [D1 audit](d-native-cite-data-flow-audit.md),
[B/C design](bc-export-validation-design.md), and
[Native Cite history](native-cite-0.7.0-plan.md). Important project history
includes `8649f85` for headline formatting, `c596e09` for replacement of
parallel preparation, `285a44b` for the Elisp STM codec, and the pinned
Org compatibility patch. Source and test references below refer to the D1
delivery tree.

## Headline formatter

The initial `8649f85` API took six arguments. INFO at that time was a
conversion-local options plist. The current call in `document.el` projects
lowered title parts to strees and passes the full owned INFO. The default
identity takes a separate composition path through
`document-headline-components` and `document-pack`, keeping paths through
the copied result. A custom function's output is copied with
`document-copy-stree` and treated as literal text semantics. There is no
identity-to-path reconstruction at that boundary.

Implement the adopted `(todo todo-type priority title-parts tags)` signature
at the defcustom, default implementation and the custom funcall. Retain the
default identity path and sectioning, and keep all policy filtering in lowering.
Retain read-only input and result copy/validation. The custom integration
regression that inspects INFO should assert the five observed values instead.
Search for six-argument definitions, wrappers and funcalls, including
`pkgs/org-texmacs-examples/sources/shared/configuration.org`, which actually
tangles a six-argument custom function. The package setting that selects the
default function needs no migration. README's six-argument and old preflight
descriptions require correction. Document the call shape, explicit metadata
nil semantics, literal custom output and migration in the unreleased
CHANGELOG. Do not broaden private special-block handlers or promise a fixed
number of formatter calls.

The [stock probe](../archive/2026-11-24T14-58-35Z--0aabcd6/MANIFEST.md) used real Standard Export,
prepared Input, pure lowering and the production native-wire builder.
The direct default and a six-argument forwarding formatter yielded equal
title bodies in all controls. In an STM headline, the default retained
`((0 0 1))` and the custom result had no STM paths, reflected in the wire.
Both treated a headline file link as visible text before formatting, as
documented in README and implemented by the inline link policy. A body file
link retained `((1 0 1))` with either formatter. Its .tm wire used the absolute
target and its default PDF wire used the relative target. The TOC control
used the ALT_TITLE, with tags only in the body heading, identically in both
paths. The first probe assumed title file provenance and correctly failed
its unsuitable assertion. The revised probe retained the title control and
added the body control. Its fresh offline Nix build passed on Emacs 31.1 / Org
9.8.10. Wire evidence is sufficient to locate this difference. It is not
native readback, byte encoding or PDF rendering evidence. No version-sensitive
question arose requiring a second Org version.

## Data and validation boundaries

| Path | Ownership and validation | Disposition |
| --- | --- | --- |
| Source → independent recognition → Model → view/copy/replace/Org serialization | `syntax` captures parse settings, `parse` discovers carriers and runs the Elisp reader, and `model` owns AST, authoritative islands and context. Public copy, replacement and inspection detach data; locators are graph-local. Render uses its own snapshot and validates Org representability. | Keep the independent Model, the snapshot of the caller's Model and the copy/replace and inspection boundaries. Remove only the second whole-graph copy on the fresh output-recognized Model as described below. |
| Standard Org Export → adapted graph → Input → lowering | Org has already selected and processed the effective AST. `prepared-copy` realizes exclusions and maps original identities for live queries. `input-own` owns AST, rich INFO and mappings. Completion and finalization establish the Model and resolution. C blocks applicable native work on known Document errors. D1 attaches bibliography data without rebuilding that graph. | Keep both initial ownership stages, C ordering, D1 sharing and all bibliography guards. |
| Explicit AST/INFO/islands → independent Input → lowering | The public constructor remaps and owns external data; it can use an explicit frozen query, reference context, post-blanks and independent bibliography data. Local reference allocation applies when no query is supplied. Lowering reads snapshot data and validates consumption. | Keep the open INFO contract, pure conversion, and the independent bibliography and navigation paths. |
| Document → native wire → .tm / PDF / session / diagnostic | Session module creates wire from a body copy and captured policies. Save delegates to the actual serializer; PDF builds its own native buffer and PDF wire, without a .tm intermediate. File provenance determines which paths can be rewritten. Scheme validates received wire, while Lisp checks before native work. | Keep the shared representation and copy boundary. The same document can serve repeated consumers with distinct path policy. No alternate encoder or source reread was found. |

In `serialize-check-output`, recognition and carrier matching check count,
path, kind and source text, then reuse already verified STM trees.
`model-own` creates all parent associations, owns secondary strings,
rebuilds structural property references and validates mappings on the result.
The fresh Model is local to the operation. `model-snapshot` immediately
copies it and compares its existing parents to those established by the
same copier. That extra parent check matters for externally reachable Models,
whose source associations could already be inconsistent. The initial
serialization snapshot still performs it. The fresh owned graph already
satisfies it, and `serialize-signature` only needs the graph and a path index
built against the same identities. Recommendation: use that graph directly
at this one site, retain its ownership constructor, compute its paths there,
and leave both signatures and recognition untouched. Keep carrier, caption,
explicit-root, invalid-Model and SETUPFILE coverage and verify no native STM
worker in serialization. The source invariants and existing test suite
cover the boundary without a separate baseline probe.

## Source guards and retained context

`standard-source-state` creates nine compared values and a tenth presentation
plist. Only `standard-input` reads the tenth value, through the state from the
advised `standard-call`. The explicit API wrapper, the interactive frontend's
captured selection, `standard-inner`'s prepared state and each recheck only need
the nine comparison values. `standard-call` creates the initial capture before
invoking standard Org preparation. Capture of a formatter's resolved function
definition happens later in `input-own`, as does registry ownership. Keep both
timings. Recommendation: retain a nine-field guard function and capture the
presentation plist separately at that initial transaction site; pass it
explicitly to the prepared Input bridge without moving the Org hooks,
source/narrowing comparisons or after-format and publication checks. Keep
style and initial copying/validation in guard state. Preserve the different
narrowing baselines for selection and prepared state. Existing source state,
formatter-snapshot, final-filter and bibliography tests cover the order;
no extra baseline trace was needed. For the change, add a focused assertion
that guard-only reads no longer invoke presentation capture.

| Data | Producer / owner | Consumer and disposition |
| --- | --- | --- |
| Rich `:title :subtitle :author :date`; literal metadata `:email :language :keywords :description :creator` | Final Org INFO or explicit caller. Input owns rich secondary AST and copies literal data. | Keep metadata, leading doc-data and initial/native literal policy. Preserve absence versus an explicitly empty value and the separation of positional KEYWORDS from effective metadata. |
| `:select-tags :exclude-tags :with-archived-trees :with-tasks` | Live Org Export and currently the standard projection. | Org applies selection before projection. No downstream production reads of these projected keys were found. README promises the selection effect, not retention as formatter context. The private block handler docstring promises no stable API, and no concrete handler reliance was found. Remove these four only from projected INFO after the five-argument change; keep the early external options copy and forwarding and test effective task/archive/tag selection. |
| Other projected Org options | Final Org INFO or explicit caller, owned in the Input. | Headline depth, numbering, TOC, TODO, priority and tags drive sectioning/presentation; with-title/author/date/email/creator and entity/subsuperscript policies remain rendering inputs. Keep them. |
| `:texmacs-metadata-present :texmacs-keywords-positional` | `c596e09` removed their former context and scoped-source producers. No current producer or documented independent override was found. | Retire the override branches. Use `plist-member` for explicit metadata and the effective AST for positional KEYWORDS as the existing fallback already does. The metadata-name helper is then unreferenced. Preserve tests of metadata clear, selection fallback and pure INFO keywords. |
| `:texmacs-tab-width`, headline/date/reference functions, special handlers, typed refs, two file-link policies | Standard capture or Input defaults/explicit caller; Input owns data and captures function definitions. | Lowering consumes these directly. File-link policies enter the result; native wire applies them. Do not prune based on the formatter no longer receiving INFO. |
| `:texmacs-org-query` | Prepared query snapshot, owned and remapped by Input. | Targets/files/unavailable and footnotes feed resolution; references feed allocation. Headlines and table-alignments also feed lowering. Some query consumers use its presence to distinguish standard semantics. The constructor documents explicit frozen query support. Keep the full query in D2 to preserve reconstruction and the D1 graph identity. |
| Resolution links, labels, files, footnotes, targets, nodes, failure | Initial Input finalization. | Lowering consumes links/files/labels/footnotes and reference targets, independent bibliography uses the effective nodes, and C uses nodes and failure. Preserve access and failure payload. |
| Cite requests, plan, snapshots, output, independent declarations | Owned in the standard bridge, D1 completion or explicit independent Input. | Membership, semantic planning, native work, provenance and filesystem guards are distinct. Keep snapshot fingerprints after publication, discard text as today, and retain the independent declarations. |
| Result token, affiliation and explicit native source | Token belongs to the standard transaction; affiliation and `:texmacs-source` are AST properties, not retained INFO options. | Keep scoped request routing, projected affiliation, and documented parse-tree-filter source override. |

## Helpers, capabilities and module responsibilities

- Delete `context-plain-metadata` and `context-metadata-keys` together.
  The former only feeds the latter and the latter has no current consumer.
  Keep the live `context-rich-metadata` list.
- `document-link-settings` and its recursive copier are used by the Core and
  repository test-support families only. Move full snapshot behavior to the
  test side when a local placement preserves both support boundaries. It
  must copy strings and retain registration handler identities, global and
  local abbreviations. `parse-links` is deliberately weaker and is not a
  substitute. The reverse pseudo-tree adapter is used only by source tests.
  It projects type and contents for round-trip checks; it adds no separate
  runtime validation of Org parent links. Move it to the owning source test
  file, retaining the real `stree-to-org` and parent/ownership assertions.
- Remove `parse-copy` as a forwarding alias and point its parse and serializer
  callers at `syntax-copy`. Update changed source context in the pinned
  Org patch, including both parse initialization hunks if affected.
  The patch already adjusts core's local abbreviation capability and changes
  SETUPFILE parsing behavior; retain those differences.
- Move the two heading-settings helpers to the existing syntax layer if
  keeping their current positional representation and validation. Their
  production consumers are the private source copy in the main frontend.
  They transfer effective parser values for heading/property lookup, a
  different task from full Model context. Update both test support consumers.
  Syntax legitimately reuses Model's strict copier. No measured issue or
  cycle justifies splitting that copier or introducing another module.
- Audited the 87 registry entries against production Lisp, dynamic/advice
  locations, standard feature loading, worker paths and the Org patch. Clean
  stale requirements for `org-export--get-global-options`,
  `org-export--get-inbuffer-options`, `org-export--skip-p`,
  `org-export-options-alist`, `org-tag-groups-alist`,
  `org-tag-groups-alist-for-agenda`, `org-collect-keywords`,
  `org-tags-expand`, `member-ignore-case`,
  `org-element-parse-secondary-string`, `parse-partial-sexp`, and the
  three `org-export-with-*` headline variables in the registry. These have
  no direct or dispatch dependency in current project code; Org may still
  consume them internally. Replace the unused `org-element-extract` name with
  `org-element-extract-element`, which prepared/query actually call. Keep
  explicit checked syntax/cache/runtime capabilities and the TeXmacs executable
  check. The registry also gates worker startup on the worker-only load path.
  Avoid adding ox/oc capabilities that require the frontend to be preloaded.
  Verify worker-only loading and both Org variants after the edits.
- Registration and menu dispatch remain in `ox-texmacs`, with `export`
  coordinating the lifetime and the main library exposing consumers.
  `prepared/query` bridge live Org identities and the owned graph, `cite-native`
  registers the processor, and `cite` owns request checks. `input` depends
  on `document` for structural resolution. The reverse module dependency would
  introduce a cycle. `document-lower` has one production caller, which supplies
  the frozen resolution. No extra dependency or fragment type is justified.
  Local `document` values use body and path slots for composition; only the
  assembled result needs full style, initial and source settings. The existing
  private handler relocation checks protect against outside graph mutation.
  Keep these distinctions, especially output provenance and the failure check.
- `worker` provides independent transport and native STM parse/serialize;
  `session` owns document wire conversion and native consumers. Preserve
  the diagnostic encoder and worker protocol validation, including the native
  interoperability tests. No source-side caller count is needed to justify them.
  The obsolete public discovery setting still provides explicit migration
  errors at the frontend, so it is not a dead private helper.

## Implementation handoff

Apply the five-argument change with public migration notes and the example
config, then the local ownership, guard-state and registry/legacy cleanup
supported above. Preserve the four primary flows and the D1 and C contracts.
Keep default/custom provenance separate. Keep the full frozen query, existing
fragment representation, syntax copier, and both initial AST ownership
boundaries. Larger API or type changes require a separate decision.

Use existing maintained tests as the regression matrix. Add localized
assertions for the formatter provenance and five values, retained metadata
and selection, and guard-only presentation capture as the production changes
land. Exercise model serialization and compatibility tests for both Org
variants and the existing Native/PDF, CSL, SETUPFILE, integration, lint and
treefmt checks through full flake check. Build the four examples separately.
Only the isolated stock probe was executed in this audit. No candidate,
second Org probe, full flake check or example build is implied by this record.
