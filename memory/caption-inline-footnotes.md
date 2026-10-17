# Caption anonymous inline footnotes: supplied development guidance and review

## Intake, authority and retention

Source is user's in-conversation development guide titled Caption 内联脚注支持与测试指导,
not INBOX or a project file. It specifies main@92f782c, matching the checked
stage3 delivery baseline. Follow-up user explicitly revises patch placement:
keep each patch adjacent to the test configuration that consumes it; do not
create a central tests/patches directory. If tests/ert/default.nix consumes it,
use an adjacent org-caption-inline-footnote.patch; if an isolated integration
check directory consumes it, place the patch there. Proposed integration topology is tests/caption-inline-footnotes (not yet created).
User additionally requests native tests via an isolated directory flake; adopted
for subsequent runs at tmp/caption-inline-footnotes-native.

Initial intake was static review/memory only. User subsequently selected this
implementation before Issue13 stage4. Native-first ERT fixture is now prepared;
user authorized five exact repeated validation commands below. Independent
native gate now failed; user chose native-cause investigation before semantics.
No parser patch generation or production lowering edit; no ordinary staging.
Earlier stage3 command permissions are not permissions for new patched builds.
Ordinary project state now includes user .gitignore and original flake.nix changes;
preserve both. No version/lock/API/worker/parser-global/skill changes.
No independent raw archive selected: useful contracts, examples, exact proposed
parser change, review findings and test gates are distilled here. No unique raw
experiment artifact was supplied. Do not claim original-byte file capture or
independent reproduction of the user's experiments.

## Intended capability and strict boundaries

Org owns syntax parsing, org-texmacs owns AST conversion, TeXmacs owns layout.
Accept a legitimate anonymous inline footnote-reference AST in LONG caption,
reusing existing footnote lowering: :type inline, :label nil. Example source:
#+CAPTION: Results[fn::Additional explanation.]
Target local structure is (concat "Results" (footnote (document
(concat "Additional explanation.")))); normal one-body simplification can apply.
Applicable to legacy naked Org tables and figure/figure*/table/table* wrappers.
Existing text/markup/links, multi-line and long/short captions, native numbering,
STM/file provenance and naked table compatibility remain in force.

Reject actual standard [fn:name] references, named inline [fn:name:body], all
footnotes in SHORT captions, nested footnotes, unsupported other contexts,
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
paragraph behavior and nesting/structure checks. Validate short-part descendants
explicitly and recursively before lowering (including notes hidden under markup
or links), with a clear document-structure error. Do not rely solely on the local
caption context: markup/link recursion can change the immediate context.
This is review guidance, not a claim arbitrary footnote placement inside markup
is newly supported; preserve existing context rules outside the selected case.

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
   repeated pure lower. Reject standard/named inline/short/nested/malformed and
   unsupported context/citation/target/island inputs. Update stage3 caption-subset
   regression to discriminate legitimate anonymous notes instead of rejecting all.
2. Patched parser integration: real source #+CAPTION: test[fn::test] with a real
   table; assert actual footnote-reference/type inline/label nil/body test and
   surrounding table/caption shape. Invoke official document-from-buffer and
   related adapters THROUGH private snapshot parsing, not only parser+pure lower.
   Include wrapper variants, short-caption rejection and body-note coexistence.
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
checks did NOT test caption footnotes. If native semantics fail, stop to record
limits and obtain a semantic decision rather than invent parser workarounds.

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
No build/probe/parser/exporter/native experiment run in this review.

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
One new org-texmacs-caption-inline-footnote-native ERT in tests/ert/ert.el holds
positive acceptance assertions and currently FAILS; not xfail/skipped/accepted.
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

User was asked for post-investigation semantic direction, reply pending:
1 evaluate separate TeXmacs repair before deciding exporter;
2 defer caption-note feature and retain native reproduction;
3 AST-only compatibility with explicit unsupported default PDF semantics.
No option selected by elapsed time. Keep stage4 separately planned until user
steers this active task. Original task remains incomplete, not accepted/delivered.
