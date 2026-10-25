# Issue14 metadata experiments

The subsequent user-selected implementation is accepted, user-committed and
delivery-verified; Issue14 is independently confirmed completed. Current
production contract, test coverage and delivery state are in
memory/issue14-implementation.md. The experiments below retain their original
feasibility scope, not the later implementation's acceptance provenance.

## Latest: Org semantics and native hidden DESCRIPTION established

User authorizes further isolated experiments for revised Issue14, identifies
KEYWORDS as the principal useful repetition case (not new mechanisms for every
field), and suggests ox-html for DESCRIPTION. Same disclosed timeout120s flake
command/path; root source/lock/index unchanged, no font work. Four invocations:
first Org probe had a scope/paren error; second passed observational6assertions;
third passed native74assertions/6PDFs; final upgraded Org103 + native112assertions/
8PDFs passed, exit0. Earlier58/64assertion checks reused; no full regression gate.

Pinned Org9.8.10 HTML/LaTeX environments observed then asserted:
- TITLE/SUBTITLE/AUTHOR/DATE concatenate in order and parse inline objects;
  repeated AUTHOR is text, not automatically separate structured author records.
- EMAIL/LANGUAGE use last value, CREATOR first value in both tested backends.
  HTML default creator is HTML markup, not generic plain generator text.
- HTML KEYWORDS space-joins raw values, without splitting/dedup/comma insertion;
  LaTeX parses secondary content (same ordinary-text result). DESCRIPTION is
  newline-joined raw text for HTML, parsed and space-joined for tested ordinary
  LaTeX text. Backend-specific rich/plain behavior needs explicit target policy.
- All nine fields obey external<file<EXPORT_* subtree; explicit nil differs from
  absence. Visibility flags and effective values are separate. Empty repetitions
  do not uniformly clear. LaTeX missing DATE has its own dynamic-date default.
- AST preserves abstract nodes/keyword positions. Standard HTML/LaTeX keep
  abstracts and ordinary paragraphs in order but collect KEYWORDS as metadata,
  not positional body text. KEYWORDS inside abstract/quote contributes globally,
  inside src/example/comment does not. Native positional keyword rendering is
  possible but must be explicit exporter policy, never nearby-block ownership.

DESCRIPTION target is now established, superseding earlier limited-tag-search
uncertainty: ox-html emits escaped plain meta name=description, not an abstract.
TeXmacs initial global-subject serializes and becomes PDF Subject in both styles,
without changing visible title/body/abstract. Tested <tag>, &, quotes and escaped
native <less>alpha<gtr> -> literal <alpha>. Initial values have native character
notation semantics; ordinary Org text needs literal encoding. No .tm reload yet.
global-title/global-author override PDF Title/Author while visible data stays.
Email-only author-data renders without a fabricated name. PDF Creator stays
TeXmacs2.1.5 despite global-creator; global-keywords/visible keyword nodes do not
produce PDF Keywords. CREATOR mapping remains a project design choice.
Native mechanism: get_metadata reads global-<kind> before searching body; print
passes title/author/subject; PDF renderer owns Creator/Producer. Upstream sources:
- https://github.com/texmacs/texmacs/blob/svn_mirror/src/Edit/Editor/edit_main.cpp
- https://github.com/texmacs/texmacs/blob/svn_mirror/src/Plugins/Pdf/pdf_hummus_renderer.cpp
Runtime probes establish pinned-version behavior; no unsupported latest-version
assumption. Temporary ORG-NATIVE-SEMANTICS.md summarizes results. Distilled
findings suffice, no raw archive needed. Remaining design: representation and
visibility, rich/plain capture, explicit initial precedence, creator policy and
keyword placement. Production implementation remains unselected.

## Current issue scope after update

Re-fetched2026-10-25, updated_at2026-10-25T15:31:47Z, open/no comments.
Title now "Map Org document-level semantics to native TeXmacs structures".
Scope expands from seven metadata fields to native document-level semantics:
TITLE/SUBTITLE/AUTHOR/EMAIL/DATE/LANGUAGE/KEYWORDS/DESCRIPTION/CREATOR and semantic
blocks including abstract, with repetitions where Org permits. Multiple abstract
blocks must remain independent/in source order. Repeated metadata, specifically
KEYWORDS, needs explicit consistent semantics, no position-based block ownership.
DESCRIPTION is distinct from abstract. Acceptance includes documented/tested
observable export behavior and native target limitations. General special-block
and math environments remain Issue13. Initial update request authorized reread
only; user subsequently selected the experiments recorded in Latest above.
Earlier native taxonomy/interleaving probes support feasibility, not automatic
decisions about Org repeated-keyword aggregation or field placement. Latest
experiments above now establish repetition rules and email/description behavior;
CREATOR rendering and remaining target policy still need design.
Keep prior source/ownership/precedence constraints and font exclusion. Distilled
updated scope and locator suffice; no independent raw issue archive needed.

## Earlier authorized experiments

Issue: https://github.com/ren-lingyu/org-texmacs/issues/14. User authorizes isolated
flake experiments, without a special framework. Font problems explicitly remain
outside project backlog. No production implementation or remote writes selected.

tmp/issue14-metadata-probe contains23tracked source/package/flake/lock inputs.
Root hashes unchanged, copied inputs byte-equal except copied flake replaces
default checks with a diagnostic runCommand. Command: timeout 120s nix flake
check -L --no-write-lock-file
path:/home/lingyu/Projects/org-texmacs/tmp/issue14-metadata-probe.
Network/store/cache/log/products disclosed, root source/lock/index untouched.
Four invocations: first failed because probe disabled author while asserting it;
second disproved probe's assumption that unknown metadata is silently ignored;
third passed52assertions/6PDFs; fourth covered two additional boundaries and
passed72assertions/10PDFs, exit0. Pinned x86_64-linux, Emacs31.1/Org9.8.10/
TeXmacs2.1.5. No complete maintained-suite rerun or .tm disk reload test.

Findings:
- TITLE/AUTHOR/DATE work. Title probe confirms file overrides external, subtree
  overrides file/external. SUBTITLE/DESCRIPTION/KEYWORDS/LANGUAGE file keywords
  explicitly fail Unsupported or unprepared block/keyword; external keys also
  rejected. Existing explicit article style/french initial retained on source
  without LANGUAGE. New-field precedence/conflicts are not implemented/tested.
- packages/header/title-base.ts defines doc-subtitle and abstract-keywords.
  Native session setting/readback, serialization and PDF text in generic/article
  confirm doc-data(doc-subtitle "SubtitleSentinel") works with/without main title.
- Direct document(abstract-keywords "KeywordOneSentinel" "KeywordTwoSentinel")
  renders keywords without Abstract heading in both styles. Wrapping that same
  node in abstract-data adds Abstract even without abstract content. Do not
  fabricate an empty abstract for KEYWORDS. Org keyword splitting semantics and
  a policy for genuine abstract integration remain design work.
- Initial language english/american/british/chinese/taiwanese/zh-CN/
  unknown-sentinel all survive native sessions/serialization. Persistence is not
  validity. progs/kernel/texmacs/tm-modes.scm supported-languages lists english,
  british, chinese, taiwanese; in-american is language=english. Do not pass ISO/
  BCP identifiers straight through or use american as a native language name.
  Full language mapping/case/region/unknown-value policy remains unimplemented.
- Limited header/HTML converter search found no suitable DESCRIPTION target;
  description hits include description lists. Not proof of native absence; do
  not equate description with abstract/doc-note or invent doc-description.

These are baseline/candidate native semantics, not new Org support acceptance.
Earlier next step was seven-field mapping design, superseded by revised scope
and Latest findings above. Design still must handle precedence, explicit nil,
style/initial conflict and subtree behavior, within existing owned snapshot /
pure lowering. Context allowlists, external validation, INFO ownership and
lowering all matter. Implementation remains unselected. No font policy/fix work.
Distilled shapes/results/native locators suffice; no independent raw/PDF archive
needed. Temporary scripts/report are convenience, not durable dependencies.

## Follow-up: upstream document information taxonomy

User requests upstream documentation plus isolated investigation of available
native information tags. Official older HTML title pages list doc-author-data,
author-address, doc-keywords, doc-AMS-class; official PDF manual still lists
doc-keywords/doc-msc. They are not fully synchronized with pinned2.1.5 definitions.
Primary locators:
- https://www.texmacs.org/tmdoc/main/styles/header/header-title-export.en.html
- https://www.texmacs.org/tmdoc/devel/style/customize/customize-title.en.html
- https://www.texmacs.org/tmweb/documents/manuals/texmacs-manual.en.pdf (18.4)
- https://github.com/texmacs/texmacs/blob/svn_mirror/TeXmacs/progs/text/text-drd.scm
- https://github.com/texmacs/texmacs/blob/svn_mirror/TeXmacs/packages/header/title-base.ts
- https://github.com/texmacs/texmacs/blob/svn_mirror/TeXmacs/progs/database/title-markup.scm
Fetched upstream default-branch excerpts agree with inspected installed tag groups
and processing; do not infer every old-file upgrader's behavior from this survey.

Standard taxonomy verified from installed declarations/menus/processing:
- doc-data: doc-title, doc-subtitle, doc-author, doc-date, doc-misc, doc-note,
  doc-running-title, doc-running-author; doc-title-options is presentation control.
- Repeated doc-author(author-data ...): author-name, author-affiliation,
  author-email, author-homepage, author-misc, author-note.
- abstract-data: abstract (potentially multiparagraph document), abstract-keywords,
  abstract-acm, abstract-arxiv, abstract-pacs, abstract-msc. Container and content
  tags are distinct; current Org abstract blocks are unsupported by default.
- doc-inactive, author-name-affiliation and *-note variants are auxiliary/render
  structures; doc-data-main/hidden and render-* are processing, not metadata keys.
  Running fields use header-title/header-author callbacks and are not title text.
  Language belongs to initial; .tm style/body/project/references/auxiliary are file
  attributes, a different layer. No suitable standard DESCRIPTION tag established.

Same disclosed timeout120s flake command/path, now inventory.nix + tags.nix simple
checks. Inventory gate passed, final behavior gate58assertions/4PDFs passed exit0
under generic/article: exact session readback, native serialization, two authors
with all six ordinary author fields, title/date/misc/doc and author footnotes,
plus multiparagraph abstract/keywords/all four classification schemes. Initial
probe failed on ffi ligature extraction, fixed with NFKC text normalization; next
ran all content checks then failed on an extra closing paren; final script fixed.
No font investigation/repair, root source/lock/index untouched. No saved-file
reload, multi-page running-header visual checks or derived-control coverage.
Temporary DOCUMENT-TAGS.md has a human-readable inventory. Results do not expand
Org support or select metadata/abstract implementation.

## Interleaving: order without abstract/keyword binding

User clarifies they do not expect strict binding of a KEYWORDS declaration to an
abstract, only preservation of source order, and explicitly requests testing the
interleaved native structure. Same disclosed timeout120s flake command/path runs
once, exit0; inventory and58-assertion behavior check reused, new check passes
64assertions/4PDFs in generic/article. Two cases per style: adjacent abstractA /
keywordsA / abstractB / keywordsB, and that sequence with ordinary before/between/
after paragraphs. Each abstract is a separate abstract-data(abstract(document
...)); each keyword node is independent abstract-keywords at document level.
Exact native readback preserves tree; serialized bytes and NFKC PDF text show
strict expected order, each sentinel exactly once, exactly two Abstract headings.
No binding/collection/merging required at native level. These are native probes,
not implemented Org block/keyword lowering or full regression acceptance. No font
work or root production/lock/index changes. User preference is positional order;
do not reintroduce an unnecessary strict binding requirement in future design.
