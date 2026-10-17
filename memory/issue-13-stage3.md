# Issue13 stage3: figure/table implementation candidate

## Intake, authority and retention

User initially requested project-read-only review, then adopted revisions1/2/3
and six acceptance additions, requested the concrete plan and authorized its
implementation. User separately authorized the exact three repeat commands below.
Source/ERT/README changes active, ordinary staging/commit not authorized. Preserve
flake.nix ELPA workaround. No worker protocol/public API/dependency/version/lock,
issue-close/tag/release actions. Static review used delivered stage2 project
baseline; current runtime uses an uncommitted candidate, not that committed tree.
Original guidance's remote Issue13 Open claim was not reverified.

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
scope. All three revisions are adopted and implemented in the candidate below.
No remaining adoption question for these revisions. Original runtime provenance
and committed delivery must remain separate at eventual user commit.

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

## Current implementation and acceptance

Native-first gate31/31 passed38.819801s before exporter changes. Final44/44focused passed54.281918s including noexport and Footnotes-section
selection/dependency cases. Final full flake check exit0 (all checks passed,
complete ERT/strict compilation/lint); final no-link default build exit0.
Final seven-input manifest verified unchanged after acceptance. Earlier42-test
candidate results are intermediate evidence only.

Five task files: source helper, context, document lowering, existing ERT, README.
No input signature/worker/protocol/dependency change. Private data-only wrapper
source-shape properties capture original direct children before context pruning.
Metadata-free leading newline paragraph is pinned Org's syntactic blank spacing;
trailing blank is inner block post-blank. Capture and scoped reparse rebinding use
kind/begin/post-affiliated/semantic-end keys. Original direct-child descriptors
include kind/parameters/ranges/affiliated keys; missing/ambiguous bindings reject
on retained wrapper, not on excluded objects. Source adapter always captures proof;
pure manual inputs validate their explicit AST. Generic input owning already
copies these ordinary data properties; filter topology protection guards them.
Preflight compares original structure even after context removes extras. Entire
outer wrapper/caption range checks precede selection reparse and body STM requests.

Built-in4type dispatch reserves normalized keys. Shared caption-text helper reuses
long/short, markup/link/file provenance, without naked-table label/surround logic
or new STM discovery. Org text that parser retains literally (including note-like
spelling) remains text; actual unsupported caption note/citation/target objects
reject. Raw figure body remains arbitrary valid stree. Org table body uses legacy
table-block. Raw table uses adopted finite grammar and document-pack only; root
paths for a lone object are table(0 0 0 0),tformat(0 0 0),tabular(0 0). Final
assertions traverse those paths and compare the original raw subtree, including
cwith/twith and raw hlink; raw hlink adds no Org file-path slot. Real caption file
links preserve their typed provenance. No user callback during built-in preflight;
placeholder native table root validation is skipped until actual parsed content.

Fifteen maintained stage3 ERT cover real4type parser, independent native controls,
source bodies/captions, original extras before prune with zero body requests,
whole-wrapper scopes/clipping, bounded table grammar/provenance, caption subset/
reserved names, bibliography distinction/native-root error recovery, INCLUDE/
restored notes/raw keyword opacity, filter evidence/body mutation rejection,
owned proof/repeated pure lowering/no source reads/no worker, excluded invalid
wrappers, integrated exporter-native PDF/readback/reload and parser boundary limit.
Prior29stage1/2 tests remain. Independent generic/article native fixtures verify
numbered1/2/3 and interleaved stars, omitted captions retaining Figure/Table labels,
rich caption, fixed-size graphics, native readback, exact expected exporter tree,
direct/reference/reload PDF word geometry1pt and graphic ink bounds1pixel. Graphic
checks require >50 non-label dark pixels, not just PDF text. Existing Poppler
pdftoppm/pdftotext tools only; no external image assets or new dependencies.

### Adopted Org boundary limitation

Actual diagnostic showed no native-body block in Org AST when a footnote definition
contains a would-be nested raw block whose multiline STM string includes a
column-zero [fn:missing]. Org terminates the enclosing note before recognizing
nested figure/texmacs blocks. User explicitly adopted actual Org boundaries and
recording this source spelling as unsupported, without text reconstruction or
parser patch. A maintained parser regression pins this limitation; README records
it. Valid footnote restoration and top-level raw pseudo-INCLUDE/bibliography/note
opacity are tested separately. This is a source grammar limit, not evidence of
native parser/counter failure. Do not silently widen support in later claims.

Earlier diagnostic fixture failures: one missing raster-helper parenthesis before
test load (fixed); new docstring width strict-compilation failures (fixed); expected
one child where Org emits leading-newline paragraph (fixed by explicit blank AST
evidence); note-like caption spelling treated as object though Org keeps text
(fixed to test actual unsupported AST objects); combined footnote/raw-marker case
above (user-adopted limitation, not silently repaired). No suppressed failures or
weakened numbering/provenance grammar checks. Maintained tests encode useful raw
reproduction, so no extra immutable archive selected.

### Authorized commands and final input identity

1. timeout 300s nix develop --no-write-lock-file path:.#checks.x86_64-linux.ert --command emacs -Q --batch -L . --load tests/ert/ert.el --eval '(ert-run-tests-batch-and-exit "issue13")'
2. timeout 600s nix flake check --no-write-lock-file path:.
3. timeout 120s nix build --no-link --no-write-lock-file path:.#default

Possible network/store/cache/log/temp tm/PDF/raster writes disclosed and authorized;
no result link or lock change. Pinned x86_64-linux ERT environment with Poppler,
Emacs31.1/Org9.8.10/TeXmacs2.1.5 baseline. No other style/platform/GUI guarantee.
Candidate uncommitted, index empty; exclude original flake mirror overlay from
ordinary delivery. Eventual commit footer Refs:#13, not Closes. Final diff
whitespace check passed, index empty, five task paths plus unchanged user flake
overlay are the complete ordinary diff. Next: review, separately authorized
staging/message and user commit, then verify committed-delivery equivalence.
Stage4 NAME/counter-scope labels/weak anchors and Issue9 remain later work.

Final review correction: full-source wrapper clipping checks must honor actual
context policy, otherwise partial noexport wrappers can block exports. Moved
wrapper range checking into context preparation after effective options/subtree
selection, before region reparse. It follows the same headline/select/archive
policy and gathers referenced note labels within the region. Original dependency
definitions are checked even under a Footnotes/excluded heading when referenced;
unreferenced definitions do not trigger wrapper errors. Added noexport partial
wrapper and referenced/unreferenced note wrappers in ordinary/Footnotes positions.
Original native-body clipping policy unchanged. Earlier42candidate full flake
pass is valid intermediate evidence only, not final candidate acceptance.

### Final candidate manifest

Ordered SHA256 lines below identify the candidate used by final focused/full/build.
First five are task staging scope; flake/lock record runtime inputs only. Original
mirror workaround must remain excluded. No project parent added for uncommitted
runtime evidence. Manifest includes the trailing newline after each path line.

```text
e3542947fc5c57150b292159c4aefc8ef5a2e97ebbe660be49fa907809bb4593  README.org
69ae82b4033385c0258f1c80ebfc339fb663392e9fdf973d548e232e84155572  org-texmacs-context.el
bd486a6e9f6ccfc774be54578b862dd2fb929df31a9fc295f4bab43f09a51d36  org-texmacs-document.el
396db5ed0941ae1a1cdea2f8c7ad7c12a1c47719d691537d6a10a97c2d8dbdb5  org-texmacs-source.el
7f860282cb4e32f6d71395661cb7a08dc7230f9b0c1f2a3e00663f4e07244fee  tests/ert/ert.el
a717dcfa245b1ccaee102ed8eef3a6ae229d0c86b60f674080bab5273d093a8a  flake.nix
118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a  flake.lock
```
Manifest SHA256: 7cef14dcbcebf14390396e0c6458e2e84d2a4a131f423b326cae69b3dde9185e.
