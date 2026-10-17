# Issue13 stage3: reviewed figure/table guidance, implementation pending

## Intake, authority and retention

User requested read-only review of updated project INBOX.md. This restricts the
ordinary project worktree; normal GAW memory continues under standing authority.
No stage3 implementation, parser/native probes, ERT/builds, dependency/network
shell action, ordinary staging/commit, version/lock/issue/release action authorized
or performed. Preserve existing flake.nix ELPA workaround. Stage2 delivered and
verified; this review used its exact committed project baseline (associated
project parent), not assumed new source implementation. INBOX's claim that remote
Issue13 is Open was not reverified; no remote issue-state conclusion added.

First-read source: ignored/untracked regular UTF-8 project INBOX.md,17294bytes,
SHA256 b160a8e6f101ac90bb460fbf80a0fe595cf8476f6181df719b54571094c8f891.
Its stated source baselines match delivered stage2 and current GAW at intake.
No raw archive selected: active guidance has no unique raw runtime/experimental
artifact. This extraction retains semantic contract, implementation routing,
test gates, evidence limits and review findings; exact wording has no remaining
independent evidentiary value. Do not assume future INBOX reads see these bytes,
or claim an original-byte archive exists. No archive/skill/config changes.

## Proposed contract from supplied guidance

Only figure/table plus experimental figure*/table* Org structural wrappers:
- figure -> (big-figure BODY CAPTION), table -> (big-table BODY CAPTION).
- starred -> big-figure*/big-table*, unnumbered, not LaTeX double-column floats.
- missing caption passes native string "" as mandatory second argument; numbered
  wrappers must remain numbered even without caption. Require actual native
  Figure N./Table N. and counter behavior, not just structural tree acceptance.
- caption uses existing supported Org long/short secondary-string semantics and
  caption-detailed structure. Distinguish absent vs explicitly empty caption by
  pinned real parser, no assumed empty-caption acceptance. Multiple CAPTION lines
  follow bounded existing Org policy. Caption belongs exclusively to outer wrapper.
- figure accepts exactly one direct inner texmacs special block, no graphics root
  whitelist. table accepts exactly one direct Org table OR texmacs special block.
  No prose, extra block, mixture, comments, hidden targets or ignored extras to
  manufacture a singleton. Only parser-identified syntactic blank spacing ignored.
- reject outer NAME and all unaccepted ATTR/parameters; reject inner body affiliated
  CAPTION/NAME/ATTR etc even if accepted on naked tables. Inner block parameters
  cannot serve as a caption DSL. No wrapper NAME/[[name]] anchors in this phase.
- no image-file auto import, float placement/htbp API, public handler API, math
  type checker, generic composite or independently numbered subfigure/subtable.
  Native TeXmacs owns numbering/layout/caption presentation; no local counters.

Native raw table normalization proposal preserves the original parsed root and
its STM provenance under only required new wrappers:
(table ...) -> (tabular (tformat ORIGINAL-TABLE)).
(tformat ... TABLE) -> (tabular ORIGINAL-TFORMAT).
(tabular (tformat ... TABLE)) -> ORIGINAL-TABULAR.
Reject other roots and malformed containers. A single terminal table with allowed
preceding formatting entries is required. Do not rewrite cwith/twith values/cell
content or add general TeXmacs math semantics. Org table body generation reuses
existing table-block rectangular/alignment/rule/cwith lowering; separate tabular
body generation from big-table caption/label wrapping. Naked no-caption tables
remain unnumbered tabular, old captioned/named-table compatibility stays intact.
Use document-pack to prefix stm-paths/file-paths; paths must target ORIGINAL raw
root, not a newly created outer tabular. Native hlink has no Org file provenance;
real supported caption file links do. Output ownership copies remain existing
contract; provenance does not imply sharing mutable input objects.

## Proposed integration and validation gates

Figure/table remain structural Org containers, never extend native-body-kind.
Inner texmacs alone is opaque/single-capture/single-request. Preserve case/raw
source/source origin/owned config/AST/filter identity and parent relationships.
Reserve all four normalized names against private handler override; built-in
controlled dispatch, never generic callback. Lower stays pure, no source reads,
worker/native session/file operations or ad hoc STM parsing.

Preparation generalizes affiliated-keyword capture and caption whitespace
capture from naked tables to supported outer wrappers; retain repeated/invalid
source keywords rather than only overwritten AST properties. Resolve must scan
outer caption secondary AST for supported links/static-label and dependency
policy; lower caption text without inheriting naked-table label/surround strategy.
Missing caption becomes document-create :body "". Check outer syntax, original
single direct body identity/parent, inner metadata and mapped-island use exactly
once. Org table branch calls existing table-block; raw figure uses original STM;
raw table uses bounded normalization. Preflight checks detectable source structure
and metadata but must not validate placeholder (concat "") as a final table root;
real table shape validates after actual native parsing. Bibliography requests may
already have occurred before body preflight failure. No custom handler receives
placeholders. Reader errors/transport/session invalidation/partial-write semantics
retain existing boundaries; no atomic publication/auto-session-repair guarantee.

Source selection tests must cover subtree/region/narrowing/INCLUDE/filter/note
restoration, partial outer/caption/inner intervals, missing/duplicated mapped inner
nodes and raw pseudo-keywords. Incomplete objects must explicitly reject rather
than silently changing object count/caption ownership. Actual parser authority:
four names/stars/case/end markers/parameters/contents bounds/post-affiliated/
caption long-short/blank spacing/direct parents/nested special blocks. If parser
cannot represent syntax, record blocker and decide supported syntax before coding;
no fake AST or textual reconstruction as evidence for a surface syntax claim.

Independent native prevalidation before exporter changes, locked TeXmacs with
both generic/article: real stable graphical/diagram fixture (math x is only a
structural example), Org/native tabular body alternatives, numbered figure/table
sequences and category counters, missing-caption labels, interleaved stars not
advancing counters, rich/short-long captions, native readback, saved tm and direct/
reload PDF text/geometry. If actual native contradicts requirements, report and
reconfirm scope instead of synthesizing counters/workarounds.

Nine maintained matrix areas in existing issue13 ERT: (1) real Org AST surface,
(2) singleton body/missing/mixed/extra errors, (3) metadata/caption ownership and
supported inline subset, (4) all three native table roots/invalid order/missing
body/format preservation/complex cell content, (5) original-root provenance,
Org file paths/source and input ownership/repeated pure lowering, (6) all scopes/
composition/dependency restoration/clipping, (7) no body request on detectable
errors/bibliography distinction/parse recovery, (8) generic/article native counters/
empty caption/stars/readback/direct-reload geometry with independent expected
inputs, (9) stages1/2 and Issue11/naked tables/fragments/bibliography/notes/files/
document-input regressions. Prior stage2 tests do not certify stage3.

Suggested sequence remains evidence/parser/native first, then built-in structure/
caption lowering/pure error checks, then complete normalization/provenance/scope/
PDF integration/README and full gates. Intermediate nodes must stay coherent and
buildable, Git operations remain separately authorized. Completion requires actual
focused/full ERT, strict compile/lint, flake check and no-link build, exact final
source/test/README/lock identity and committed-vs-candidate provenance. Guidance
mentions preferred commands, but this review grants no new test execution.
No close13 or release0.5.0. Stage4 owns single-object NAME/labels in counter/caption
scope and weak raw anchors; Issue9 owns named composite constituents later.

## Static review findings: recommendations, not yet user-adopted

1. Preserve original wrapper body identity BEFORE lossy context processing.
   Current context-prune extracts comment/comment-block, source keywords and
   unreferenced footnote definitions; current scoped document-prepare invokes
   context-prepare before walking, and ordinary preparation also prunes before
   lowering/preflight. Checking only final prepared child list can accept an
   originally invalid wrapper containing one table plus a removed comment/keyword/
   definition. Capture/check source singleton evidence before such removal, but
   enforce errors only for selected/reachable wrappers; do not reject invalid
   excluded objects during full-source bibliography discovery. Scope completeness
   should use original wrapper interval INCLUDING affiliated captions, excluding
   syntactic post-blank as appropriate, before region reparse can discard outer
   structure. Keep restored/INCLUDE node ownership coherent. Recommend choosing
   explicit complete-wrapper selection rather than leaving a loose 'or' fallback;
   do not broaden raw-body classification to obtain this behavior.
2. Tighten caption boundary to EXISTING supported inline subset. Guidance5.1 says
   secondary whitespace/fragment preparation, but current fragment-collect scans
   paragraphs/direct inline-note text, and pure inline permits island mappings
   only in paragraph/footnote contexts. Caption footnotes/citations/targets also
   reject under current contextual rules; existing named-table test rejects
   caption citations. Reusing caption whitespace capture does not add STM fragment
   support. Recommend remove the fragment-support implication, keep literal STM-
   looking caption text as existing text semantics and explicitly reject unsupported
   caption objects. Newly supporting caption STM/notes/citations would expand scope
   and require distinct discovery/mapping/ownership/PDF work; not inferred here.
3. Define finite native table-container validation grammar before implementation.
   'legal terminal table'/'allowed format items' is underspecified for preflight,
   final errors and tests. State exactly one terminal table, preceding cwith/twith
   tags with their arities (6/2), tabular one tformat operand, and bounded table/
   row/cell skeleton checks; decide nonempty/rectangular edge cases from pinned
   native evidence. Do not make value vocabularies, mathematical cell semantics,
   general native evaluator or arbitrary format schema an Elisp responsibility.
   Original raw root/value/provenance must survive wrappers. Keep invalid-real-
   root checks out of placeholder preflight. Official primitives supports the
   basic format-container/row/cell constraints but does not certify runtime cases.

These are implementation-contract tightenings, not discovered regressions in
current supported exporter or changes to accepted stage3 high-level design.
Stage3 code/tests/native experiments have NOT started. Next: user assesses these
recommendations, then separately requests a concrete implementation plan/actions.

## Public reference check and evidence limits

Read official manuals during review (no shell networking/download). env-float
manual section18.3.4 supports body/caption big-figure/big-table and unnumbered
variants; primitives documents top-level tabular/tformat, twith/cwith, row/cell
shape. Documentation does not prove pinned2.1.5 missing-caption/stars/counters/
rendering or Org9.8.10 AST behavior. The supplied env-base-dtd page is general
environment-definition documentation, not proof of float behavior. A guessed
HTML env-float page returned an error; use official manual section instead.
References:
- https://www.texmacs.org/tmweb/documents/manuals/texmacs-manual.en.pdf (section18.3.4).
- https://www.texmacs.org/tmweb/manual/webman-primitives.en.html (table primitives).
- https://www.texmacs.org/tmdoc/main/styles/env/env-base-dtd.en.html.
