# Caption anonymous inline footnotes: supplied development guidance and review

## Intake, authority and retention

Source is user's in-conversation development guide titled Caption 内联脚注支持与测试指导,
not INBOX or a project file. It specifies main@92f782c, matching the checked
stage3 delivery baseline. Follow-up user explicitly revises patch placement:
keep each patch adjacent to the test configuration that consumes it; do not
create a central tests/patches directory. If tests/ert/default.nix consumes it,
use an adjacent org-caption-inline-footnote.patch; if an isolated integration
check directory consumes it, place the patch there. Final topology is not chosen.

Initial intake was static review/memory only. User subsequently selected this
implementation before Issue13 stage4. Native-first ERT fixture is now prepared;
no runtime/build/patch generation or production lowering edit yet. New exact
validation command authorization requested and pending; no ordinary staging.
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
