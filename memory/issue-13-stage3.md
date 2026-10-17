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

## Adopted revisions from user's follow-up (normative stage3 contract)

The user supplied concrete revisions1/2/3 and six acceptance additions after the
review. These supersede the earlier pending recommendations, without authorizing
implementation or new test execution. Source is the user's message, not a claimed
new INBOX byte version; first-read INBOX identity above remains intake provenance.
No raw message/file archive needed: all operative detail is distilled here.

1. Original structure and scope completeness:
   - Capture direct-child structure evidence for figure/table wrappers during
     preparation BEFORE context-prune or any equivalent lossy cleanup.
   - Removed comments, keywords or unreferenced footnote definitions must not
     turn an originally non-singleton wrapper into a valid one.
   - Apply this evidence only to wrappers finally selected and retained; malformed
     excluded wrappers must not prevent unrelated exports (including discovery).
   - Region/subtree reparse can create new node identities. Do not rely solely on
     eq across ASTs: where needed use verified source intervals and owned mappings
     to associate original evidence with final nodes. Preserve snapshot/origin and
     parent/identity constraints across ownership, INCLUDE and restored notes.
   - Region completeness covers the ENTIRE outer wrapper, including affiliated
     CAPTION/metadata, not merely its inner native island. Detect truncation before
     body STM requests. Keep structural wrappers out of native-body-kind.
   - Pure lowering consumes owned saved structural information, never rereads the
     source buffer or reconstructs missing Org AST from text.
   Static motivation: current context-prune removes comment/comment-block and
   source keywords; note recovery removes unreferenced definitions. Scoped
   document-prepare invokes context processing before walk, and ordinary
   preparation also prunes before final lowering. Final child-list-only checks
   would lose the evidence required by the strict original singleton contract.
2. Caption subset (no syntax expansion):
   - Reuse copying of existing :caption secondary AST, whitespace preparation and
     inline lowering, plus outer caption preparation/reference resolution with
     current structural ownership and STM/file provenance constraints.
   - Do NOT extend fragment discovery into caption or issue new native STM parsing
     requests for caption text.
   - Continue rejecting unsupported caption footnote/citation/target objects.
   - STM-looking plain text such as (math "x") stays ordinary Org text. Do not
     auto-detect it as STM and do not reject it merely for that literal spelling.
   - Reuse existing long/short caption, markup and link subset; no new DSL.
   Static motivation: fragment-collect scans paragraph/direct inline-note text;
   pure inline island mappings allow paragraph/footnote contexts only. Existing
   table caption rejection tests already reject citation objects. Shared caption
   whitespace preparation is not authorization for new caption fragment semantics.
3. Finite native table-container grammar:
   - Allowed original roots remain table, tformat ending in table, or tabular with
     the full tformat/table shape. Normalize to a single tabular root; never wrap
     an already complete tabular again.
   - tabular has exactly one child, a tformat node.
   - tformat has zero or more preceding twith/cwith nodes and exactly one terminal
     table. twith has exactly2 arguments, cwith exactly6.
   - table has a NONEMPTY sequence of row nodes; each row a NONEMPTY sequence of
     cell nodes; each cell exactly one body argument. Require necessary rectangular
     row/column shape. These edge policies are now adopted, not unresolved options.
   - Do not reinterpret cell bodies, validate formatting-variable values, or create
     a TeXmacs mathematical/layout semantics checker.
   - Preserve original STM subtree and its stm-paths through structural wrapping;
     no serialize/reparse or arbitrary internal rewrites to normalize it.
   - Real parsed-table checks belong after STM parsing, not on preflight placeholder.
     Native empty-caption/numbered/starred/counter behavior still requires actual
     locked-native proof; grammar validation alone cannot establish rendering.

Additional required maintained acceptance:
1. Original direct Org table+comment, Org table+keyword and Org table+footnote-
   definition (and equivalent extra nodes) cannot become valid after cleanup.
2. Invalid wrappers in finally unselected regions cause no unrelated rejection.
3. Region truncating outer wrapper or affiliated caption rejects before body STM.
4. Supported caption markup/links lower normally; STM-looking text creates no extra
   native parse; unsupported footnote/citation/target explicitly reject.
5. Three legal native roots normalize correctly; malformed tabular/tformat/twith/
   cwith/table/row/cell structures explicitly reject, including empty/nonrectangular
   shapes under the adopted finite grammar.
6. Original-root STM provenance remains correct, prepared inputs remain unchanged,
   and naked Org table compatibility behavior remains unchanged.

These tighten implementation correctness within the adopted high-level stage3
scope. No stage3 source implementation/parser/native/tests started. Next: prepare
an implementation plan when requested, then act within explicit task/test/Git
permissions. No remaining adoption question for these three revisions.

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
