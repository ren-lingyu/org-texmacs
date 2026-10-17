# Caption anonymous inline footnotes: implemented AST compatibility, native limits

## Current adopted semantic decision

User's final development decision supersedes the initial PDF correctness gate and
short-caption ban below. This task accepts correct supported Org AST to native
footnote(document...) conversion with content retained. Native caption layout,
body visibility, counters/directory/page placement are documented TeXmacs limits,
not failures of structural conversion. Long AND short captions follow the same
AST principle. No note-ref/note-footnote auto split, special anchors/counters,
caption-only parser/lower/type, layout prediction or graph rewriting. Existing
nesting/ownership/other-context rules remain. First-version anonymous-inline
boundary remains (:type inline,label nil); no named-caption restoration added.
Org patch remains test-only, no upstream Org proposal now. Implementation is
accepted before stage4, now staged under explicit user authorization; awaiting user commit.

User reports independent TeXmacs2.1.5 GUI experiments: direct caption footnote
shows marker but no body/edit position and extra counts; split note-ref plus
note-footnote displays both but anchoring note-footnote on page2 moves body there
without moving caption reference. This is user-attributed GUI evidence only.
The native diagnostic archive supports agent text/geometry conclusions separately.
No raw archive for final in-conversation decision needed after sufficient semantic
extraction; new GUI report is distilled, not an original-byte experiment artifact.

## Intake, authority and retention

Source is user's in-conversation development guide titled Caption 内联脚注支持与测试指导,
not INBOX or a project file. It specifies main@92f782c, matching the checked
stage3 delivery baseline. Follow-up user explicitly revises patch placement:
keep each patch adjacent to the test configuration that consumes it; do not
create a central tests/patches directory. If tests/ert/default.nix consumes it,
use an adjacent org-caption-inline-footnote.patch; if an isolated integration
check directory consumes it, place the patch there. Final integration topology is tests/caption-inline-footnotes, implemented below.
User additionally requests native tests via an isolated directory flake; adopted
for subsequent runs at tmp/caption-inline-footnotes-native.

Initial intake was static review/memory only. User subsequently selected this
implementation before Issue13 stage4. Native-first ERT fixture is now prepared;
user authorized five exact repeated validation commands below. Independent
native gate now failed; user chose native-cause investigation before semantics.
At that investigation phase no parser patch or production lower edit existed.
Current implementation follows the final decision above; current staging handoff is below.
Earlier stage3 command permissions are not permissions for new patched builds.
Ordinary project state now includes user .gitignore and original flake.nix changes;
preserve both. No version/lock/API/worker/parser-global/skill changes.
No independent raw archive selected: useful contracts, examples, exact proposed
parser change, review findings and test gates are distilled here. No unique raw
experiment artifact was supplied. Do not claim original-byte file capture or
independent reproduction of the user's experiments.

## Intended capability and strict boundaries

Org owns syntax parsing, org-texmacs owns AST conversion, TeXmacs owns layout.
Accept a legitimate anonymous inline footnote-reference AST in LONG or SHORT caption,
reusing existing footnote lowering: :type inline, :label nil. Example source:
#+CAPTION: Results[fn::Additional explanation.]
Target local structure is (concat "Results" (footnote (document
(concat "Additional explanation.")))); normal one-body simplification can apply.
Applicable to legacy naked Org tables and figure/figure*/table/table* wrappers.
Existing text/markup/links, multi-line and long/short captions, native numbering,
STM/file provenance and naked table compatibility remain in force.

Reject actual standard [fn:name] references, named inline [fn:name:body],
nested footnotes and unsupported other contexts,
citation/target and other unsupported caption objects. Retain paragraph rules.
Do not enable notes in all secondary ASTs, introduce caption STM fragments,
footnote numbering policy, float semantics, worker operation, public API or new
Org/TeXmacs DSL. Literal note-like spelling under stock Org stays literal.

Production must not mutate org-element-object-restrictions, advise Org parsing,
parse caption strings for note syntax, or branch lowering on patched-Org detection.
Lower only structured AST independently of parser identity/version. Anonymous
notes need no external definitions; do not extend named-caption dependency
restoration in this change. The context walker currently omits caption secondary
AST for named reference collection; supporting named captions remains separate.

## Existing source review and required changes

At committed stage3 baseline, document-resolve scans both caption parts for
naked tables and four wrappers; detects nested notes and gathers note references.
Input owner copies both parts and their complete descendants/parents. Lowering
inline footnote branch currently requires paragraph context and retains existing
shape/type/nesting/identity checks and native footnote(document...) construction.
Caption-text sends both long and short parts through caption context.

Extend only caption footnote acceptance to anonymous inline while preserving
paragraph behavior and nesting/structure checks. Both caption parts use caption
context and the same existing footnote lower. Do not add a short-caption refusal
merely to avoid native directory effects. Other nested markup/link contexts keep
their existing restrictions; this is not general secondary-AST footnote support.

Preparation whitespace walker already descends caption objects and invokes
paragraph preparation for inline note bodies. Verify true parser coordinates,
whitespace/post-blank, ownership, independent copy, repeated pure lower, original
nodes/source unchanged. Fragment discovery currently scans parsed body paragraphs;
caption introduction must not silently widen it. Explicitly test STM-looking
text in BOTH the caption and its footnote body yields no extra native requests;
keep current supported body inline lowering without adding caption discovery.
Combine caption anonymous notes with ordinary anonymous/named paragraph notes
and test resolution, order, provenance, scoped export, filters and excluded nodes.
Pure lowering never rereads source or invokes a worker.

## Test-only Org patch and Nix isolation

Proposed Org9.8.10 change in org-element-object-restrictions:
  (keyword ,@(remq 'footnote-reference standard-set))
becomes:
  (keyword ,@standard-set)
Generate actual context diff against locked derivation source; assert intended
version and expected source/context so upgrades fail explicitly rather than
silently applying to another parser. The patch broadens all keyword restrictions,
not only CAPTION or anonymous notes; exporter must enforce its narrower contract.
Keep the patch beside its consuming test configuration per user's correction.

Patch locked Org derivation, never installed Nix store files. Default package,
normal installation, standard ERT, lint and formal packageRequires keep stock Org.
Create a small isolated patched check and matching org-texmacs build/dependency
closure with patched Org. Assert actual loaded Org version, library location and
parser behavior in the test Emacs; exclude a second stock/bundled Org on load-path.
First validate independent patched build/load before exporter integration.
Production fileset currently explicitly includes package sources/README/LICENSE,
not tests: preserve this property so patch/test source never ships in package.
No broad Nix package refactor. Preserve unrelated ELPA mirror overlay when editing
future flake wiring; never stage that workaround with feature changes.

Existing tests/default.nix receives pkgs/source/emacs; ERT/default.nix wraps a
runCommand with Emacs/Guile/TeXmacs/Poppler. Existing emacs derives from the default
package. Patched check must therefore provide a consistently rebuilt package+
Emacs closure, not merely append patched Org beside default package's stock Org.
Exact override/wiring requires inspection of the locked Org derivation at
implementation time; it was not independently inspected/generated in this review.

## Three maintained test layers

1. Default AST tests, unconditional and no parser patch: org-element-create
   anonymous inline note in caption for naked table and all four wrappers;
   text/body markup, long with short, repeated/multiline captions, paragraph
   anonymous/named note coexistence, copied ownership, unchanged original AST,
   repeated pure lower. Reject standard/named inline/nested/malformed and
   unsupported context/citation/target/island inputs. Update stage3 caption-subset
   regression to discriminate legitimate anonymous notes instead of rejecting all.
2. Patched parser integration: real source #+CAPTION: test[fn::test] with a real
   table; assert actual footnote-reference/type inline/label nil/body test and
   surrounding table/caption shape. Invoke official document-from-buffer and
   related adapters THROUGH private snapshot parsing, not only parser+pure lower.
   Include wrapper variants, short-caption acceptance and body-note coexistence.
   Keep these cases in isolated patched suite; do not pass by skip/xfail or remove
   standard-literal expectations merely to accommodate patched parser behavior.
3. Stock parser regressions: same note-looking source remains ordinary text;
   no private interpretation/rejection, no new parse requests. Keep legacy paragraph
   named/anonymous notes, captions/links/numbered tables/figures/scopes unchanged.
   Verify global parser restrictions unchanged after success/error.

## Independent native gate, exporters and acceptance

Before modifying exporter, test manually constructed native big-table with
(tabular (tformat (table (row (cell "A")))) and caption
(concat "Results" (footnote (document "Additional explanation."))).
Also big-figure and representative stars, both generic/article, with adjacent
ordinary notes and numbered objects. Separately record exact native readback,
PDF generation, visible caption note marker, body text actually in PDF, no
loss/duplication, marker/body position and counter interaction. Text presence or
STM equality alone does not prove intended page-footnote layout. Use layout/
geometry/rendered evidence adequate to locate marker/body. Existing stage3 native
checks did NOT test caption footnotes. Native failure was investigated and user adopted AST-only acceptance above;
record limitations without blocking this compatibility implementation.

User reports runtime restriction relaxation lets ox-latex output
\caption{test\footnote{test}}. This is user-supplied experimental evidence only;
not independently reproduced, not proof of LaTeX or TeXmacs PDF placement.
Use same input to check ox-html marker/body collection/links/numbering/duplicates;
result unknown. Optional ox-odt comparison; no fixes to other backends required.
Architecture comparisons do not define TeXmacs layout semantics.

Acceptance requires stock Org environment unchanged; patched actual parsing;
correct native footnote structure; unsupported cases rejected; old footnote/
caption/table/figure/scope tests pass; explicit native PDF behavior record;
README distinguishes default syntax from extended parser AST input and actual
native limits; production package excludes patch/dependency. Full flake must
exercise default checks and isolated patched check when implementation is selected.
Order: native gate, default synthetic AST tests, narrow lowering/preparation edit,
minimal parser patch and isolated build/load, real snapshot integration, stock+
full checks, README. All side-effecting commands require this task's own precise
permission. Subsequent user instruction selects implementation before stage4; no additional
mandatory v0.5.0 release gate inferred. Stage4 NAME remains a separate requirement.

## Reference review and evidence limits

Official live Org Syntax states parsed/affiliated keyword values exclude footnote
references, and Org Export Reference documents secondary strings and long/short
caption selection. These corroborate architecture, not the exact locked9.8.10
line/patch application or any exporter/native runtime. Public pages read only:
- https://orgmode.org/worg/org-syntax.html (keywords, affiliated keywords, footnotes).
- https://orgmode.org/manual/Captions.html.
- https://orgmode.org/worg/dev/org-export-reference.html (org-export-get-caption).
No runtime experiments occurred during that initial reference review; subsequent
native investigation and implementation validation are recorded below.

## Authorized commands and native investigation state

User authorized repeated current-task commands1-5:
1. timeout 300s nix develop --no-write-lock-file path:.#checks.x86_64-linux.ert --command emacs -Q --batch -L . --load tests/ert/ert.el --eval '(ert-run-tests-batch-and-exit "caption-inline-footnote")'
2. timeout 600s nix build --no-link --no-write-lock-file path:.#checks.x86_64-linux.caption-inline-footnotes
3. timeout 600s nix flake check --no-write-lock-file path:.
4. timeout 120s nix build --no-link --no-write-lock-file path:.#default
5. timeout 60s nix eval --no-write-lock-file --raw path:.#packages.x86_64-linux.default.packageRequires --apply 'xs: (builtins.head xs).src.outPath'
Network/store/cache/log/temp tm/PDF/raster/build writes disclosed; no lock/result.
Command5 exit0 identifies /nix/store/41g0k913cg4zr0lbhaqfs1r2dqnwspma-org-9.8.10.tar.
Archive metadata shows org-element.el371675bytes; no extraction/patch yet.

First native fixture runs from project root, focused command exit1: initial generic
only3.218021s; second aggregates both styles9.479397s (9.541650s suite). Exact native
readback, tm save, direct PDF, reloaded PDF text/geometry equality pass for both.
Four big-table/big-figure/star captions have CapA/B/C/D and superscript3/5/7/9,
NoteA/B/C/D bodies absent from PDF text and word-coordinate output. BodyNoteOne/
BodyNoteTwo present once with markers1/10. This does not meet intended native
caption-note semantics. No raster/GUI inspection yet; do not claim broader visual
proof than extracted text/geometry. No native engine patch/exporter workaround.
The initial org-texmacs-caption-inline-footnote-native ERT held positive layout
assertions and failed at this investigation phase. Final user decision later
replaced it with native-layout-limit regression; no xfail/skip.
After run only indentation adjusted, no behavior change; final file SHA256
b7d893e5f93bdd64bb5de188835119cc765dc9694beffc9a9e8c5d57d18962b1;
patch SHA2562bf8b3b3045f3699be62793941d1135f6a42285494077092470d1cce5d21946f.

User explicitly chose investigate native causes before deciding support semantics.
Then adopted isolated flake for TeXmacs tests. tmp boundary verified ignored,
no tracked files/symlink, target within root. Fixed copies of package source,
README/LICENSE, ERT/lint Nix drivers and lock at tmp/caption-inline-footnotes-native;
source-inputs.json records hashes. Exact same command1 runs FROM that directory.
It retains original failing acceptance fixture and appends independent native
controls, with native-evidence/*.tm/*.pdf/reports.el for inspection. Production
package sources in snapshot remain unchanged. Do not conflate isolated test edits
with root candidate or stage3 accepted baseline.

Native store package identified through generated ERT driver derivation:
/nix/store/5ri673m8kksap2p2r7gwgqjfwh410sls-texmacs-2.1.5.
Read only relevant packages/environment/env-float.ts/env-base.ts and standard
counter definitions. env-float render-big-figure places body and caption inside
three-row tabular*; caption cell has cell-hyphen=t. render-caption includes
list-caption(type,cap) in surround plus actual cap display. list-caption invokes
write with cap; footnote expands next-footnote+render-footnote, whose body uses a
float of type footnote. Initially these were hypotheses; completed paired controls below distinguish
table-cell note-body suppression from list-caption extra counter consumption.
Do not claim confirmed C++ cause or patch TeXmacs based on style inspection alone.
Controls compare plain/cell/cell-hyphen, standalone render-caption with/without
list-caption, big-table default/short-caption/no-list, and diagnostic unboxed
render-big-figure with/without list write, generic/article. These are diagnostic
style overrides only, not adopted export policy. Isolated run completed; full results and limits below.

## Isolated native controls: completed findings and semantic gate

Exact command1 FROM isolated flake exits1, suite17.503438s: original positive
acceptance fixture fails9.364730s; separate diagnostic controls pass8.092252s.
20native cases,10each generic/article. Both styles have the SAME outcomes:

| Control | Note body count | Caption marker / after-body marker |
|---|---:|---|
| plain paragraph | 1 | 2 / 3 |
| single table cell | 0 | 2 / 3 |
| single cell with cell-hyphen=t | 0 | 2 / 3 |
| standalone render-caption | 1 | 3 / 4 |
| render-caption, list-caption overridden empty | 1 | 2 / 3 |
| big-table default | 0 | 3 / 4 |
| big-table, list-caption empty | 0 | 2 / 3 |
| big-table, caption-detailed with literal Short | 0 | 2 / 3 |
| big-table, diagnostic unboxed render-big-figure | 1 | 3 / 4 |
| unboxed plus empty list-caption | 1 | 2 / 3 |

Every document has Before footnote1, one experimental note and After footnote;
ordinary before/after bodies appear exactly once in all20cases. Plain expected
2/3 baseline is independently asserted. Native render-big-figure's outer table
is sufficient to reproduce body suppression: removing it restores body, while
single-cell note fails even without caption/list operations. cell-hyphen is not
the deciding difference. These establish a native table/float boundary, not an
identified C++ line or a generally proven engine repair.
Separately, render-caption without any table reproduces extra count; disabling
list-caption removes it. caption-detailed's literal short caption avoids note
evaluation during list write, restoring count but not body in big-table. Thus
short-caption restriction alone cannot solve the missing-footnote problem.
Unboxed/no-list is ONLY a diagnostic: it changes layout and removes native list
writing, violating the unchanged figure/table semantics goal. Do not ship it as
an unrequested exporter/style workaround or call native gate passed.

Root production source unchanged. Only root ERT has the positive failing fixture;
no default/patched Org integration/lowering/README/package work yet. No full checks
or package builds run after gate failure. First root-run gate predates user's
isolation guidance; subsequent native command uses fixed isolated flake as asked.
Raw PDFs available under tmp/caption-inline-footnotes-native/native-evidence for
user inspection; no raster/GUI claim. Text/geometry establishes the reported
absence and counter behavior, not complete visual fidelity across pages/styles.

Archive selection after diagnosis: unlike guide wording, raw original control
inputs and report have independent reproduction/audit value not yet covered by
maintained passing tests. Twenty generated standalone native .tm inputs encode
all controls, raw reports.el includes actual text/word boxes, isolated flake/lock
and copied source hash map establish environment.24original-byte text artifacts
plus manifest copied and verified before separate archive-only checkpoint:
archive/2026-10-17T15-01-35Z--92f782c/MANIFEST.md.
No PDF/binary/cache archived. Full executed ERT code not duplicated: standalone
.tm inputs retain controls; harness digest and pre-append vs executed-test input
identity distinction documented in manifest. Capture project HEAD is context,
not original runtime-tree provenance; zero new project parents.

Post-investigation user supplied explicit final AST-compatibility decision above,
including short-caption acceptance and no default split-note strategy. No semantic
question remains pending. Implementation now accepted by final automated gates below; not yet user-committed.

## Implementation candidate and current validation

Production changes are the inline footnote context predicate and a generic
unprepared-citation check: paragraph rules
unchanged; caption accepts anonymous inline:type inline,label nil. Both caption
parts already use caption context; no caption-specific lower, AST type, worker,
anchor, splitter or Org-global mutation. No preparation/input/context changes
needed after real parser tests. Citation lower now requires its identity in the
computed plan, preventing silent empty(cite) output when a caption note contains
an unsupported citation; no caption bibliography traversal/support added. Existing stage3 rejection fixture remains named
standard note/citation/target and comment now distinguishes anonymous coverage.

Eight task paths: README.org, org-texmacs-document.el, flake.nix, tests/default.nix,
tests/ert/ert.el, tests/caption-inline-footnotes/{default.nix,ert.el,
org-caption-inline-footnote.patch}. User .gitignore patch allowlist preserved;
flake ELPA workaround byte-equal original overlay and must be excluded from
feature staging. Shared buildPackage takes Org dependency to avoid mixing closures;
formal default still emacsPackages.org. Tests/patch never enter package fileset.
Org version asserted9.8.10; unified diff generated from locked tar org-element.el
line438. Test source tar rebuilt deterministically after patch --batch --fuzz=0;
actual org-mode/org-element-parse-buffer/org-export-as paths and package path
asserted inside patched Emacs. No default package dependency override.

Four default focused tests: all5targets pure long+short+multiline notes, body rich
markup/filelink and ordinary anonymous/named note coexistence; independent copy,
source unchanged/repeated pure lower/no worker/source reads, provenance; invalid
standard/named/nested/type/other-context rejection; stock literal source for both
caption parts/alltargets; independent native generic/article readback/PDF/reload
records pinned missing-body limit. No xfail/skip or promised native layout repair.
Five isolated patched tests: exact loaded versions/paths, actual parser AST shape,
private snapshot prepare+document-from-buffer for alltargets and long/short/
multiline rich notes/body-note coexisting; no extra STM requests from caption or
note-body STM-looking text; file provenance and expected native resolved path;
exact native readback including footnote bodies, no note-ref/note-footnote added;
full/subtree/region/narrow and excluded invalid nodes; unsupported note variants.
README distinguishes stock syntax, prepared/extended-parser AST acceptance and
known native GUI/PDF visibility/number/directory/page limits; no default patch.

Intermediate corrections: derivation has no override, so minimal shared package
construction used. ELPA dontUnpack means patchPhase cannot find source; test-only
patched tar fed to original Org derivation instead of patching installed store.
One extra parenthesis in new test helper fixed. Mutable quoted Org property lists
and source strings polluted repeated fixture iterations; fixed by fresh per-case
lists/strings, no ownership validation weakened. Native readback expectation now
accounts for existing relative file-link resolution to captured absolute base.
No suppressed errors or broadened production semantic rules for these fixes.

Final focused4/4passed10.027854s and patched integration5/5passed, including
caption-note citation rejection. Earlier full/build pass predates this guard and
is intermediate evidence only.
Final no-link default package build exit0; final full flake check exit0 (all checks
passed: complete stock ERT/strict package compilation/lint and isolated patched Org
integration). After all gates,29input
hashes and isolated/root bytes unchanged, whitespace check clean, index empty and
lock unchanged. Only pinned x86_64-linux validated; other systems omitted by Nix. All from isolated implementation flake
tmp/caption-inline-footnotes-implementation per user's native invocation preference.
29snapshot input bytes equal current root, no source edits during final checks.
Original runtime uncommitted; zero new project parents for implementation evidence.

### Final current candidate input identity

Ordered29-input SHA256 manifest (each `digest  path` line with trailing newline):
4573d1cc22bd8955baf12ac14025720535367959540c933e10b84e4a562398ec.
source-inputs.json SHA256:
cebb4b4580716b19983e03ea4a0f1db108b81ca77be877c2d1d89b1924e157f9.
Hashes below identify task/runtime inputs; flake includes preserved mirror overlay,
.gitignore is user change. Neither whole-file staging is automatically authorized.

```text
212fb71cec5bebdbedfebfa57516894a85e85f7ea132940dd37bb8fa04dfc8c1  README.org
54effce5b08cfe75c4a32de982ce81f31ed07afd77c7a944598175ca88538cb7  flake.nix
6f1dff0d015d313660de98cf8cdca743452d9c90a1d108ae666d6c9406dd528b  org-texmacs-document.el
decf713b8aaf88fde0e322db16b5a219df3071f7f3499a9a85ab9b775e5b1794  tests/default.nix
f02ef1986bf52d61c5bde0dc71d107f3259fea49a2e9aefa60453100bd71f131  tests/ert/ert.el
643c242a5ea32758071fe1f714989b31f47919bfc073eb9b55862897ed8278e4  tests/caption-inline-footnotes/default.nix
e90bfd7c96b544fe34d8a26140c23ee4aaf053566bc6a1b6a9d767d59dede9e8  tests/caption-inline-footnotes/ert.el
b19cc830d4436c423b33ae1a4f25b7807daeac1045a62772427a70ec3cdb7a8c  tests/caption-inline-footnotes/org-caption-inline-footnote.patch
118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a  flake.lock
94c2c01decd65462d606952a518764a3205071bbf361d366ea7ea42d8a7a4ab3  .gitignore
```

Final review additionally found a newly reachable unsupported composition:
caption anonymous note -> citation. Bibliography collection omits caption secondary
AST, yet inline citation previously could emit (cite) without captured keys.
A new default negative test in separate isolated citation flake reproduced this
(3/4pass10.135043s). Generic citation lowering now explicitly rejects missing
identity mapping. Default synthetic long/short note-citation and patched real
long/short source regressions pass; no bibliography semantics broadened. First
full pass before this guard is intermediate; final checks rerun and passed on corrected candidate.

## Acceptance and handoff

Final AST-compatibility implementation accepted; user authorized both requested
staging actions. Nine paths staged: eight task paths plus user's .gitignore patch
allowance. Split not necessary, low difficulty: implementation, test dependency,
acceptance and documentation share one capability boundary. Original ELPA overlay
and its system parameter were excluded by reviewed feature-only index patch;
worktree flake unchanged and remains sole unstaged path. All nine staged blobs
match accepted identities above except intentionally mirror-free feature flake:
SHA256 5818e92e02888f8375529d8bdeb524626b8a6033a3d2170784dda8ac89223043.
Full staged diff reviewed, whitespace clean, 386 additions/26 deletions. No new
build/test execution for staging. Runtime acceptance used mirror-bearing isolated
flake; staged flake differs only by excluded fetch workaround, not feature wiring.

Final reviewed tmp/commit.md message (SHA256
7bed9e04cf0b94f0b2935e2ddc54d4100152e583e504ff2ec58dc297828c55f8):

```text
feat(document): accept anonymous inline footnotes in captions

- 接纳长短 caption 中匿名内联 `footnote-reference` AST, 复用原有 `(footnote (document ...))` 转换路径.
- 拒绝缺少 preparation 映射的 citation, 避免 caption 脚注中的引用被转换为空 `cite`.
- 添加直接 AST, 标准 Org 文本行为, ownership, scoped export 和原生 readback/PDF 限制回归.
- 提取可指定 Org 依赖的私有 Nix 构建函数, 添加独立 patched Org 集成检查, 将最小 parser patch 与消费它的测试并置并纳入 Git 跟踪.
- 在 README 中区分标准 Org 语法和 AST 兼容范围, 记录 TeXmacs 2.1.5 浮动 caption 脚注的原生排版限制.

Refs: #13
```

Staged git diff --cached --binary SHA256:
dbccf04de9c98f9517025ae7cc5a68c3c510421b34105dc3d0deeaf61ef3c2bc.
Next: user commit then exact delivery comparison against stage3 baseline,
paths/patch/message and accepted blobs. No Closes:#13, NAME/stage4 remains.
No GUI/physical-page support assertion, automatic split note, engine fix or release.

Native pre-decision diagnostics remain historical failures; current native-layout-
limit regression deliberately documents pinned PDF body loss while asserting
complete STM readback/reload. No hidden skip/xfail, no claim typesetting repaired.
Maintained tests now reproduce implementation acceptance, so no new raw archive
for final build logs needed. Prior native-control archive remains immutable.
Final runtime was uncommitted isolated bytes equal worktree, zero new project
parents; later exact committed-delivery comparison must be recorded separately.
