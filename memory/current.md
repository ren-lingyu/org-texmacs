# org-texmacs current memory

## Current: targeted GoToR guard and maintained regression delivered

User committed3ccf195116a929d994556ae8cfea96f86b6f5f03 with reviewed fix message;
7intended paths,297additions/5deletions, commit whitespace check passes. Ordinary
index empty; only user-authored public-overlay edits remain unstaged in
flake.nix and pkgs/default.nix. Do not stage/include those implicitly.

Full renderer SHA256 guards replaced with original href action-dispatch check
(leading indentation normalized) after upstream postPatch, then
patch --batch --forward --fuzz=0. Version2.1.5 restriction retained; C++ patch
unchanged. Unrelated source changes accepted; changed dispatch, missing href or
already patched input rejected. Guard/patch supplied through passthru to tests.
Maintained tests/texmacs-with-gotor-support auto-discovers through mkChecks;
explicit texmacsWithGotorSupport argument avoids test-scope name recursion.
Native baseline/patched test requires neither Org nor Fandol; README updated.

Exact authorized focused build exits0:
timeout 1200s nix build --no-link --no-write-lock-file --max-jobs 2 --cores 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs#checks.x86_64-linux.texmacs-with-gotor-support -L.
Output /nix/store/f0b0y0acxzwl5qgidfj3ffm7zwj8svin-texmacs-gotor-regression.
Formal package recompiled. Nine path forms produce18GoToR/14URI/2internal versus
32URI/2internal baseline. Page0/Fit, relative/absolute form, Unicode, URI/query/
anchor/scheme/nonPDF controls, exact internal list preservation, text equality,
MuPDF interpretation and relocation pass. Unrelated-source comment/zero-fuzz
relocation and rejected guard mutations pass. Six-file authorized formatter and
static diff checks pass. First run corrected a test assumption of single internal
annotation (actual duplicate identical annotations); baseline URI backslash
escaping is outside tested nine-path contract and no fix selected. No full
flake/ERT rerun, GUI/Fandol test or post-commit test. Original build was before
commit with public-overlay worktree edits present; internal check uses legacy
scope, not public default overlay.

## Pending: user-authored public default overlay

Worktree exports lpkgs.overlays.default and excludes emacs-with-org-texmacs,
org-texmacs-examples, texmacs-fandol and texmacs-fandol-with-gotor-support.
Retained additions are emacsPackages.org-texmacs and texmacs-with-gotor-support;
both rely on ordinary nixpkgs plus captured Lisp src. Static review appropriate,
previous dependency gap was fixed by user. Independent downstream default-overlay
application not evaluated. These two ordinary files remain unstaged/uncommitted;
no further implementation/staging authorized. Prefer explicit include list if
future public API stability becomes a selected change. Do not restore the old
wrapper-exposing selection. Main perSystem still uses full legacy overlay.

## Current: native GoToR packages and bilingual examples delivered

Examples delivery baseline is0559700e78b2b30e54a7c8ca7a268f6b32926027,
following native GoToR package delivery ecbe6cb53cfcca203ba3e12e41e52266d897fee8.
Examples commit contains24intended paths and reviewed feat message. Ordinary
worktree/index clean, commit whitespace checks pass. Latest read-only inspection
finds no stashes; user performed stash deletions, agent did not delete them.
Review found old documentation stash's useful material retained or deliberately
superseded, including rejection of main-package font injection.

Delivered packages: texmacs-with-gotor-support and
texmacs-fandol-with-gotor-support, latter composed through
texmacs-fandol.override { texmacs = texmacs-with-gotor-support; }.
Original Fandol method stays independent; ordinary org-texmacs keeps plain
TeXmacs. Current targeted source-guard policy is described above. Both named
outputs and final wrapper in devShell.
Native probe contract/hashes/guards: memory/texmacs-gotor-probe.md.

Examples are package-local sources/shared+en/zh, two entries per language:
generic index and article-profile article with include-only math/figure chapters.
Org-derived config/BibTeX, explicit build driver paths, isolated per-document
HOME/TeXmacs/XDG state, private final-wrapper dependency. Outputs grouped into
pdf/, texmacs/ and sources/. Index has explicit standalone companion link;
PDF targets remain relative and terminal .org maps to .pdf. Active timestamps
with timezone retained, e.g. <2026-10-27 Tue +0800>. README/allowlists agree.
Only en/zh; implicit references and TOC/abstract reordering explicitly deferred.
Details: memory/documents-package.md.

Exact authorized build completed successfully:
timeout 1200s nix build --no-link --no-write-lock-file --max-jobs 2 --cores 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs#org-texmacs-examples -L.
Output /nix/store/gzghcxhjgmc4r8d5vdhs9j5c9bg20z3a-org-texmacs-examples.
Compiled formal renderer/Fandol/private Emacs and all4documents. Raw PDF
inspection verifies relative GoToR sibling targets, destination files and embedded
FandolKai/FandolSong regular+bold in both Chinese PDFs (index5pages/article4pages).
Native .tm/config snapshots exist. Latest navigation headings and reader prose
postdate this build and have static review only. No post-commit build, full
flake check or formatter run for final candidate. No result symlink/lock update.

User reports navigation fails with Zathura pdf-mupdf but works after switching
to pdf-poppler, then confirms no further viewing issues. Supplied versions:
Zathura2026.10.4, girara2026.07.18, pdf-poppler2026.07.18. Do not generalize
failure to all Zathura or claim exact internal cause established. Separate
reader comparison also found baseline URI failed where GoToR succeeded.

No implementation remains selected. Future validation must use applicable
command authority; do not run tests, mutate ordinary Git or restore obsolete
layouts by habit. File-link feature delivered in32643f81c424c9a8265eb73525d35e4be03f4f6e;
9runtime/test blobs match earlier597ERT/full isolated acceptance. Historical
pre-delivery descriptions below are superseded by this current state.

## Current: file-link consumer policies accepted locally

User explicitly authorizes source implementation and finalizes exactly2Customs:
org-texmacs-pdf-file-links-as-absolute=nil (PDF-only), and
org-texmacs-link-org-files-as-pdf=t (uniform PDF/.tm/native-memory consumers).
No as-texmacs variable. Session set-document consumes completed structured output
AFTER combined Org/TeXmacs AST construction and pure lowering; open only creates
an empty buffer. Preparation captures typed booleans; pure input defaults fixed.
Native consumers rewrite marked file-target leaves on copied trees. PDF retains
relative form unless requested absolute; other consumers still resolve captured
source base. Final .org->.pdf is case-insensitive; labels/URI/STM/other suffixes
unchanged. No target reads, existence checks or implicit builds.

Implementation:2Lisp files, README and regressions/inspector. Added3core+1native+
1PDF tests. User permits repeated exact7file nix fmt120s and metadata-free
108file tmp/file-link-implementation full flake check600s this round. Separately
permits ONE nix fmt for examples/build.el (prior reorganization formatting);
that one-use command completed. No ordinary index/lock/history changes by agent.

Final authorized isolated flake check exits0, all checks pass.597ERT outputs:
206core,324native,33PDF-document,28PDF-render,6patched. Strict compile, package-lint,
treefmt and aggregates pass; unchanged passing outputs reuse cache. Final PDF
render28/28runs148.143938s; new policy test4.687840s checks4combinations plus
fresh native reload. Inspector reads exact URI actions, with links-only pypdf
mode avoiding Poppler's invalid XML for Unicode URI. Shared helper captures stderr
separately, preserving successful JSON and failure diagnostics. Final fixture uses
ordinary Org concat paragraphs; target/count assertions remain exact.

After gate all108inputs equal root/copy and manifest. inputs.json SHA256:
563dec3a7d450717613c1ab89e7f2b81de570832965ca3e39303923b8a1a6f1d.
Complete candidate diff against font-package HEAD SHA256:
e5de0f806c038e4ed318a06d3d4d3dd281004c40f51edbd8bc0d35db0c3bb057.
No agent index/lock/history/result changes. Eleven unstaged paths include main
feature/tests/README plus separately authorized example-driver formatting;
existing example candidate remains user-staged. Full authority/provenance/limits:
memory/file-link-implementation.md and tmp/file-link-implementation/REPORT.org.

Separate example candidate is user-staged, still3entries per language:
configuration(generic), mathematics/figures-tables(article). Package-local
sources/shared and en/zh+chapters, pdf/texmacs/sources output layout and scoped
Fandol override. User proposes TWO compiled entries per language (generic index
linked to article), NOT implemented yet. Automatic final bibliography/TOC order
changes deferred; only en/zh. Independent font package delivered as aa1af88,
main Lisp retains plain texmacs. Stash8429dcc retained but superseded by current
reorganized candidate. No package build acceptance for reorganized example files.

Next user reviews/stages source feature separately or selects next example work.
Do not silently implement2entry examples or repeat tests without a new reason.
Earlier native relative-link spike: memory/relative-link-probes.md. No project
commit/optional extension suite/example package build or GUI-click acceptance.

## Previous: font package delivered; documentation restored with local override

Latest scope steering: user explicitly keeps only en/zh examples. Personal
preference is automatic references at document end and TOC before abstract;
user explicitly defers both behavior topics while focusing on examples. Current
explicit PRINT_BIBLIOGRAPHY and existing metadata->TOC->body ordering remain.
Do not infer authorization for automatic bibliography, TOC/abstract restructuring,
additional languages or new tests. Package-local examples rename/layout remains
the preceding recommendation, not an executed or explicitly adopted migration.
No ordinary project file or Git-state change in this steering turn.

Follow-up user selects Org timestamps and no blank after headlines in docs.
All6DATE entries now [2026-10-26 Mon], blank lines directly following headings
removed throughout docs; bounded search confirms no remaining heading blanks.
Static diff --check passes, no runtime/formatter run. User also asks abstract/TOC
ownership and bibliography print necessity. Static lowering explicitly appends
metadata then toc then body (document.el around3104); abstract-data remains in
body source order, so current TOC precedes abstract, not purely style-controlled.
Presentation uses native macros, structural order currently belongs to package.
Bibliography collector requires exactly1print if citations exist, no implicit
insertion; zero citations/prints allowed. Included print directive suffices (as
current guide bibliography chapter), not necessarily handwriting per entry file.
These are review findings, no renderer/order/bibliography feature change adopted.

User commits aa1af88c70a45c30feeb415784ca480e173cfa72 with the drafted
feat(texmacs-fandol) message. Read-only complete commit/staged-context comparison
confirms3paths: standalone wrapper/overlay plus flake export/devShell. Intake
clean. User explicitly requests docs restoration and adaptation. Stash8429dcc
also carries rejected main-Lisp injection, so agent uses authorized worktree-only
selective restore of README, docs, pkgs/default and document package, then merges
flake docs input/export/Org formatter exclusions by patch. New HEAD font export
and devShell retained, main Lisp/font wrapper files remain equal HEAD. Stash is
retained, ordinary index unchanged/empty, restored new files untracked.

Document overlay constructs Emacs via (emacsPackagesFor emacs).withPackages and
selects org-texmacs.override {texmacs=texmacs-fandol;}. Only documentation selects
this dependency; ordinary Lisp/Emacs/tests unchanged. README lists4package outputs
and describes local override; bilingual building chapters match. Earlier ASCII
test prefix, pdf/texmacs/sources output layout and Nix-only logs preserved.
Static tracked diff --check passes, bounded source search finds no parent/host
hardcoding. No formatter/evaluation/build/test authorized or run for this restored
candidate, existing result remains older layout/font version. Next: user review,
optional explicitly authorized format/build validation and staging/commit draft.

## Previous: Fandol packaging adopted, runtime verification pending

Latest commit-readiness intake: user has synchronized the index, removed main
Lisp font injection entirely, and staged a flake package export plus devShell
switch to texmacs-fandol. Exactly3staged paths: flake.nix and two font package
files, no unstaged changes. Complete staged diff reviewed; --check passes.
Suitable single feature commit; tmp/commit.md now feat(texmacs-fandol): provide
TeXmacs with Chinese fonts, Chinese body covers explicit font wrapper/export/shell.
No fresh build/evaluation/formatter and no ordinary Git writes by agent. Docs
still in stash8429dcc; font commit not yet reported delivered. Earlier MM warning
below is superseded by this newly inspected staged candidate.

User corrects dependency scope: org-texmacs packaging must NOT carry Fandol.
Agent removes its outer-pkgs/font injection from the ordinary overlay file,
whose worktree bytes now equal HEAD. Index untouched, so overlay remains MM:
staged font injection plus unstaged reversal. User must update that index path
before the font-only commit. Keep independent pkgs/texmacs-fandol package;
when docs is restored, scope its font executable to document build only and
correct stashed README claim that the main package uses Fandol. Do not propagate
fonts to main Lisp/Emacs or tests. No stash restore/build/index write performed.
This correction supersedes the main-package default adoption below.

Latest user selects font-package-first delivery and explicitly asks for docs-only
stash push. Intake all25candidate paths staged. Authorized path-specific stash
push saves README.org, docs/, flake.nix, pkgs/default.nix and
pkgs/org-texmacs-documents/ as "wip: bilingual documentation package and output
layout", restores those paths to HEAD. Leaves only three staged font-package
paths: pkgs/texmacs-fandol/{overlay,package}.nix and
pkgs/emacsPackages/org-texmacs/overlay.nix. No ordinary commit/build/formatter.
README font description was in the compiled-docs section and travels with docs.
Next user may prepare/deliver the standalone font package, then separately
authorize reapplying the selected stash; do not automatically restore it.
Stash object8429dcc0ca02cb86b21929ccba1232b07f4a26f5. Important native Git detail:
stash snapshot also includes the three preexisting staged font paths (25total
diff paths), although the pathspec restores only22docs paths. Font files stay
staged in the ordinary worktree. Inspect full stash and delivered font bytes
before restoration; don't misdescribe the stash tree as excluding font content.

User explicitly adopts downstream texmacs-fandol packaging after citing retained
experiments and downstream successful Chinese output. New pkgs/texmacs-fandol/
package.nix and overlay.nix faithfully use symlinkJoin/makeWrapper with explicit
texlive.pkgs.fandol.tex and TEXMACS_FONT_PATH. emacsPackages/org-texmacs overlay
injects outer pkgs.texmacs-fandol exactly as downstream; ordinary packaged Emacs
and documentation inherit it. This adopts a packaged default, beyond earlier
documentation-only recommendation. README and en/zh build chapters explain fonts.
Bare pkgs.texmacs and tests' explicit executable inputs remain unchanged; no
generic renderer/font-discovery change. New files untracked, modified existing
files unstaged; agent leaves ordinary index untouched. Static diff --check passes.
No evaluation, build, formatter or fresh PDF verification is authorized/run;
historical Fandol/native evidence and user downstream confirmation support design,
not a claim of a current candidate runtime gate. Existing result remains old.
General native font policy/typography repair stays outside scope; the explicit
Fandol package adoption supersedes earlier no-font-packaging decision only.

## Previous: documentation section marker inspected read-only

Latest: user confirms Chinese PDF literally printed <#...>, and independently
confirms adding downstream TeXmacs Chinese font support fixes it. Authorized
read-only downstream inspection finds ~/emarccs/pkgs/emacsPackages/org-texmacs/
overlay passes pkgs.texmacs-fandol into its Lisp package. Referenced
~/emarccs/pkgs/texmacs-fandol wraps texmacs with TEXMACS_FONT_PATH prefixed by
texlive.pkgs.fandol.tex/fonts/opentype/public/fandol, via symlinkJoin/makeWrapper.
No parser/encoder patch or reliance on host fonts in that packaging. This is
user-reported causal rendering evidence plus independently inspected packaging,
not an agent reproduction or verified equality to current project runtime.
No font implementation/backlog adoption; project remains unchanged by inspection.

User subsequently explicitly selects output cleanup. package.nix now installs
pdf/<language>/<entry>.pdf, texmacs/<language>/<entry>.tm and complete retained
input/config sets under sources/<language>/<entry>/. Driver still receives an
explicit output basename, now in the writable build source directory. Build/PDF
inspection diagnostics stream directly to Nix logs; no build.log/pdf-info.txt
is installed. README, bilingual building chapters and guide footnotes describe
this worktree layout. Canonical INCLUDE layout and six independent builds stay.
No build/formatter authorized for this follow-up; existing result is old. Ordinary
index remains unchanged and latest edits are unstaged. Static diff checks only.

Follow-up: user explicitly requests replacing the test prefix. Only
docs/configuration.org is edited: formatter now prepends "(Test prefix) " and
its docstring says test prefix. Ordinary index untouched; change is unstaged
above staged docs candidate. Bounded diff --check passes; no build authorized or
rerun and existing result still contains §. User also asks for cleaner package
outputs, matching entry/artifact basenames, and considers includes under a
subdirectory or one combined document. Read-only package review confirms every
leaf copies all language Org inputs plus all tangled profiles into its output,
with generic document.tm/pdf names. Layout redesign remains a proposal, not an
authorized project edit. Recommend keeping separate profile-specific documents,
putting PDFs/TM under language directories with matching basenames, and retained
source/config/logs under distinct subdirectories; avoid merging profiles without
an explicit document-wide style/formatter decision.

User now has all22documentation/package/README/wiring paths staged and asks why
figure/table output shows octal237/replacement glyphs. Existing result points to
the accepted real package output pq50lvs8p0bcvq7405qybvx01612gd3c. The derived
article.el retains the explicit Unicode section marker in docs/configuration.org
line60: formatter prepends "§ " to every headline; TOC uses the same formatter.
The en figure/table .tm byte dump confirms raw0x9f (octal237) at the prefix,
not UTF-8 U+FFFD bytes. Worker utf8->cork followed by native serialize-texmacs
explains native byte output; the serialized file API explicitly preserves those
bytes. UTF-8 text viewers can display replacement glyphs for these bytes.
Included profile code has the same character representation. This is not evidence
of figure/table lowering damage or a font defect. PDF glyph correctness remains
unverified in this turn: pdftotext is unavailable on PATH. No build, production
edit or index change performed. Prior PDF text-equality evidence was not a visual
or glyph-level acceptance. Next: explain intended marker versus native encoding;
if unwanted, user may select a configuration edit. No new repair adopted.

## Previous: documentation package cleanup accepted; staging remained stale

User now explicitly requests worktree cleanup, including whitespace, formatting
and outdated descriptions. Four known metadata/matrix corrections are applied
to ordinary docs, en/zh guide EOF blanks removed, Chinese metadata punctuation
fixed. Bilingual build instructions now describe result paths and the whole Emacs
build's600second timeout. README's two-package statement becomes three outputs
with compiled-docs build/source links. No ordinary index writes; original partial
staging remains. User authorizes repeated exact five-file nix fmt, root explicit-
path full flake check and root documents build commands for this cleanup round,
timeouts120/600/600seconds. Five-file formatting completes, two files change.
Actual root documents build exits0, all six native/PDF outputs succeed without
the temporary diagnostic/reload driver. Root path flake check encounters copied
Git metadata invoking git-gaw hook unavailable inside builder; no hooks bypassed
or governance changed. Separately authorized metadata-free tmp/documents-cleanup
full check passes, all106inputs equal root. ERT/lint/build outputs reuse accepted
cache; treefmt newly runs. New Org files have no configured formatter, so flake
excludes *.org (superseding README-only exclusion); README explains this.
Combined worktree diff --check passes, ASCII punctuation and explicit paths
checked. Exact original19staged blobs remain unchanged, including old draft
errors. Next: user reviews/restages updated docs/package/wiring/README before
requesting a commit draft. No font work, new default package check or promotion
of temporary reload verification. Details: memory/documents-package.md.

## Previous: documentation stash restored; read-only review complete

User reapplies documentation stash and asks to inspect the worktree, not modify
files or run builds. All21restored paths byte-match the reviewed docs stash.
19new docs/package paths are staged; flake.nix and pkgs/default.nix wiring remain
unstaged. Current source is the delivered INCLUDE repair, so its former wrapper
refusal is resolved; unchanged docs still contain both previously reproduced
draft failures: bare EXPORT_TITLE in the two metadata tables and an unclosed
matrix expression in the two mathematics files. The isolated four-file patch
remains available; it is not applied to this worktree. Staged diff --check also
reports trailing blank lines in en/zh guide files. No parent traversal or host
path hardcoding found in docs/package source. No new runtime verification.

This restoration review precedes the selected cleanup and acceptance above.
Earlier corrected-copy six-document acceptance remains scoped to that copy.

## Previous: INCLUDE snapshot/view repair delivered and verified

User adopts and requests unified repair. Five ordinary paths now separate raw
snapshots from mode-specific views, admit literal and ordinary/native wrappers,
add11core/2native regressions and explain the new contract in README. Public
signatures, pure lowering, path/encoding/budget/receipt checks remain unchanged.
Host focused26/26passes. Final isolated locked full check exits0:203core,
323native,27PDF-render,33PDF-document and6patched=592ERT, strict compile/lint/
formatting/aggregates pass. All85tracked runtime/build/test inputs match root
and check copy after acceptance; final documentation Lisp inputs also match.

All six corrected isolated en/zh guide/math/figure-table documents build,
independently reload saved .tm and retain equal normalized PDF text plus expected
included configuration. Raw stash has two unrelated draft mistakes: unmarked
EXPORT_TITLE in metadata tables and a missing matrix closing parenthesis.
Four temporary Org corrections are in tmp/include-view-documents/draft-fixes.patch.
Temporary driver logging/reload verification is not a production package change.
No font or visual-layout acceptance, optional extension-suite rerun or release.

User commits the exact five-file repair with the drafted feat(preprocess) message.
Expected single parent, complete binary diff and85committed inputs match the
accepted candidate. Ordinary worktree/index clean; no agent project Git writes
or runtime rerun for identical bytes. Lock/stashes unchanged. Delivery association
grounds this verification, not a test run against the new commit. No issue footer
or external tracking change. Next: handle docs corrections only when separately
selected. Details, hashes and validation limits: memory/include-view-implementation.md.

## Previous: isolated INCLUDE semantics probes complete

User authorizes isolated experiments and repeated execution of the exact
timeout120s run.sh command for this round. Final49probes have zero unexpected
failures on host Emacs31.1/Org9.8.7, using copied sources, isolated HOME/XDG/tmp
and fresh fixtures. No network, Nix/store operation, worker or PDF rendering.
All16production source hashes remain unchanged; project/index clean, docs and
older stash unchanged. This does not authorize production implementation.

Three guard-only counterexamples confirm mode-specific views are necessary:
literal malformed STM rejected, literal line selection falsely treated as STM
truncation, and restored native text bypasses Org source escaping so #+end_src
ends code early. Native wrapper/plain branch differences are experimentally
confirmed. Dynamic include-mode dispatch nests/restores and reaches readers in
a limited spike, not a complete protected-view transaction. One captured source
snapshot does not mean one physical read: existing receipt verification causes
12byte reads for two uses in the measured fixture. Preserve those checks.

At this investigation phase no implementation or stash restoration was performed.
The subsequently selected repair is described in the Current section above.
Details: memory/include-view-probes.md.

## Previous: INCLUDE snapshot/view proposal reviewed; docs stashed

User stashes21documentation/package paths in latest [wip] docs, based on the
current gitignore-anchoring HEAD. Worktree/index clean; stash inspected read-only,
not applied. Current source matches the HEAD cited in the supplied architecture
proposal. Active request is review, not implementation or testing.

Proposal correctly identifies capture's coupling of byte acquisition, Org parsing/
STM protection and line-selection checks. Support direction: immutable source
snapshots with mode-specific views and native Org expansion, existing final AST
mapping retained. It needs corrections before implementation: Org literal/block/
plain branches do not share recursion or location/heading/footnote behavior;
native-body wrappers need genuinely opaque selected views; dynamic mode must
start before any semantic view generation; snapshot keys/budgets and helper
restoration/compatibility must remain explicit. Review covers published Org9.8.10
source statically, not the installed/pinned runtime. Mixed-mode ordering, code
escaping/terminators, nested wrappers and original en/zh/guide outputs need
future validation. No broader feature adoption, stash action or test authority.
Details: memory/include-view-review.md.

## Previous: literate bilingual documentation package written, not validated

User selects review of a new example package exposed through flake packages,
with PDF in out and preferably full public configuration coverage. Complete
isolation is required at package level: ordinary sandboxed Nix builder with
explicit dependencies and fresh runtime state, no generic worker change or
additional isolation framework. Reproducibility means equal PDF content/layout;
timestamp metadata may differ, byte identity is not required.

User authorizes files-only implementation, then selects org-texmacs-documents
as real documentation rather than a separate example package. docs/ holds
bilingual guide/math/figure-table Org sources and composable guide chapters.
Configuration .el and bibliography .bib derive from canonical Org by tangling;
only explicit build configuration is loaded, interactive snippets stay inert.
Driver stays in pkgs/org-texmacs-documents, not docs. No package README; build
instructions live in the guides. User explicitly selects docs argument through
flake fileset -> pkgs extraArgs -> overlay -> package. No parent traversal or
source-location inference; driver receives paths/work directory explicitly.

Six isolated leaf builds retain one public completed document for both .tm/PDF;
outputs/Org inputs/derived files/logs go under out/<language>/<topic>. Bibliography
includes previously supported string concatenation, @online fallback and explicit
crossref parent; native limitations are documented. Existing source ignore rules
suffice; all newly added exemptions removed. User prefers ASCII punctuation in
all new prose, Chinese enumeration commas become commas; documents converted.

User stages candidate paths and reports first package build exits1. Logs confirm
three config blocks and one bibliography block tangled in en/figures-tables;
preparation then rejects Unsupported INCLUDE parameters. Other leaf/render results
unconfirmed. Requested read-only diagnosis establishes valid Org src INCLUDE is
explicitly outside org-texmacs's current contract and is a maintained negative
test. New docs wrongly assumed this support, not a regression in plain INCLUDE.
Fourteen wrapped directives affect all six documents. Removing src would lose
literal code presentation. Recommend a bounded source-INCLUDE extension, not
generic wrapper permission; implementation remains unselected.

No agent evaluation/tangle/build/format/tests or dependency resolution. No project
files/index/history changed during diagnosis. Rendering, Chinese glyphs, layout
and formatting unverified. No default checks/apps/CI changes or font repair.
No raw archive need. Next: user selects how to address the support gap.
Details: memory/documents-package.md.

## Previous: post-Issue14 HEAD reviewed and README delivery verified

User commits formatting, enables treefmt.flakeCheck=true and refreshes the two
existing direct flake inputs nixpkgs/personal-nixpkgs. Intake project/index clean.
Read-only8Lisp token comparisons preserve code/string tokens;7Nix diffs show
formatting only. Full manifest/lock read confirms follows/transitive graph stays.
No runtime/evaluation/formatting check performed at these new inputs;579-case
Issue14 acceptance remains scoped to its original fixed candidate.

Authorized README-only change corrects the disabled treefmt-check statement and
describes prior runtime versions as recorded regressions rather than new-pin
acceptance. README remains excluded from formatting. Two-hunk diff/claims checked
against the input-refresh HEAD; whitespace clean. User stages README and requests
git-maintenance draft plus HEAD polling. Poll detects the documentation commit;
expected single parent, complete patch, approved message and README blob all
match. Project index/worktree clean. Delivery association grounds this review,
not runtime acceptance at the refreshed inputs. No tests/dependency resolution
or agent ordinary index/history writes. Polling objective complete; user selects
further work, no automatic test task.
Details and provenance: memory/post-issue14-flake.md.

## Previous: Issue14 delivered and independently confirmed closed

User commits the exact reviewed15path Issue14 candidate. Read-only verification
matches the expected single parent, complete binary patch, approved feat(document)
message/Closes:#14 and all85accepted committed input hashes. The delivery
association grounds this equivalence, not original uncommitted runtime provenance.
GitHub connector confirms Issue14 CLOSED/COMPLETED at2026-10-25T17:29:52Z.
No agent external write or runtime rerun for identical committed bytes.

Implemented nine-field context/ownership, rich subtitle, independent email,
explicit language mapping, hidden DESCRIPTION/global-subject, creator:t note and
ordered independent abstracts/keywords. Org file/subtree declarations override
initial defaults; partial exports use one effective inherited/overridden keyword
value. Org literal initial provenance survives to native encoding. Full isolated
gate passes573stock+6patched=579default cases, strict compile/lint/aggregates,
including two-style .tm reload/PDF inspection. Optional9integration cases not
rerun; native PDF Creator/Keywords and font exclusions remain explicit.

At that delivery review the project index contained15additional staged paths,
excluded from the delivered acceptance claim. User subsequently commits those
as formatting, reviewed in memory/post-issue14-flake.md. Issue14 contract and
original runtime evidence remain in memory/issue14-implementation.md.

## Previous: README synchronization committed and verified

After the read-only structure/release review, user explicitly authorizes updating
README only to reflect HEAD, with no extra release-plan narrative. Implementation
baseline remains main baff8f7; clean at intake. README-only candidate now updates
named package outputs/build commands, direct Emacs drivers, package/test composition,
parallel PDF leaves/aggregates, streamed logs/names/error boundaries and treefmt.
Accurate existing lisp checkout/straight paths and feature contracts retained.
Complete diff and changed claims reviewed against source/manifests/lock/check
entrypoints; diff whitespace clean. No tests/builds/formatting/network or ordinary
staging; previous runtime evidence retains its actual baseline/attribution.
User committed exactly the reviewed README-only candidate. Read-only verification
matches the expected refactor baseline parent, full binary patch and complete
approved message. Project worktree/index clean; no runtime rerun for delivery
verification. No extra release-plan narrative or source changes. README sync is
complete; optional representative-document decision and explicit release actions
remain user choices. Issue14 remains tentatively nonblocking, revisable.
Current local source is lisp/ (15Elisp modules plus adjacent Scheme worker),
pkgs/ supplies melpaBuild and the Emacs wrapper through explicit overlays, and
flake uses personal-nixpkgs.lib.mkFlake with explicit source arguments. Named
package outputs are org-texmacs and emacs; packages.default no longer exists.
Version header, package version and melpaVersion remain0.5.0.

Tests retain core176/native318/PDF59 plus6patched default cases; PDF is split
27render+32document under dependency-only ert-pdf, itself under ert. Shared driver
streams logs with tee/pipefail and records actual names; optional9extension cases
remain separately supplied. Existing release feature regressions (inline notes,
bare display, quote/center, Issue13 and PDF footnote links/cleanup) remain in the
split suites. Latest recorded full optimization gate passes559default cases;
subsequent mark-notification-only change has user-reported validation. This review
is structural reconciliation, not fresh runtime acceptance or a complete code audit.

Old mandatory functionality and version work have no newly identified unfinished
item. README had fallen behind package/test interfaces (packages.default/#default);
user subsequently selected the current HEAD-only sync described above. No extra
release-plan text added. Representative documents remain a
final optional whether/format decision. No separate release-only complete-check
gate; Chinese fonts and PS intermediary stay removed. Issues9/7 keep later/deferred
scope. User now explicitly TENTATIVELY excludes Issue14 from0.5.0 blockers; keep
this revisable, not a permanent deferral or implementation approval. Its independent
Org/native experiments remain complete and production design/implementation pending.
Next user may decide optional documents or
select explicit release actions. No new raw archive: current source/history and distilled scope
suffice; no skill changes.

## Previous: revised Issue14 Org/native behavior established; design pending

Issue https://github.com/ren-lingyu/org-texmacs/issues/14 now covers native Org
document-level semantics: TITLE/SUBTITLE/AUTHOR/EMAIL/DATE/LANGUAGE/KEYWORDS/
DESCRIPTION/CREATOR, independent ordered abstract blocks, permitted repeated
declarations and explicit target limitations. Title: "Map Org document-level
semantics to native TeXmacs structures"; open/no comments when reread, updated
2026-10-25T15:31:47Z. Do not infer keyword ownership from nearby abstracts.
User mainly needs KEYWORDS repetition and positional presentation, not new
repetition mechanisms for every field. DESCRIPTION must not become an abstract.

Authorized work is isolated experiments without a special framework; production
implementation remains unselected. No font work/backlog. Existing context/INFO
ownership/pure lowering, explicit-source and configuration precedence constraints
remain. Current metadata implementation still supports only title/author/date;
native feasibility probes do not add Org support.

tmp/issue14-metadata-probe copies23tracked source/package/flake/lock inputs;
root hashes unchanged, copy byte-equal except copied flake diagnostic checks.
Disclosed command: timeout 120s nix flake check -L --no-write-lock-file
path:/home/lingyu/Projects/org-texmacs/tmp/issue14-metadata-probe.
Potential dependency network/store/cache/log/products, no root lock/index edits.
Earlier accepted gates:72assertions/10PDFs metadata baseline/candidates,
58assertions/4PDFs native taxonomy and64assertions/4PDFs interleaving.
Latest gate:Org103 + native112assertions/8PDFs, exit0 on pinned x86_64-linux
Emacs31.1/Org9.8.10/TeXmacs2.1.5; earlier checks reused, not rerun regressions.

Key findings: native independent abstract containers/keyword nodes preserve order.
Standard Org HTML/LaTeX collect KEYWORDS as metadata while preserving abstract
body order; source positions do not imply binding. Field repeat rules differ,
including HTML raw/newline DESCRIPTION vs parsed LaTeX values. Nine fields tested
for external<file<subtree, nil/absent distinction and separate visibility flags.
DESCRIPTION target now confirmed: initial global-subject -> PDF Subject, serialized
and hidden from body/abstract. Ordinary description text needs literal encoding of
native angle-character notation. global-title/global-author override PDF fields
without changing visible title/author. Email-only author-data renders. Native PDF
Creator stays TeXmacs despite global-creator; no automatic PDF Keywords from
global-keywords or visible keyword nodes. Full language mapping, rich/plain
capture, explicit initial precedence and CREATOR rendering policy remain design.

Evidence, upstream locators, probe fixes and limits: memory/issue14-metadata.md.
Human-readable temporary report: tmp/issue14-metadata-probe/ORG-NATIVE-SEMANTICS.md.
No .tm disk reload or full maintained-suite gate, production edits or remote
writes. Results distilled; no raw archive needed. Next action is explicit design
for revised Issue14, subject to user selection.

## Previous: test optimization and quieter mark notifications delivered

User selects implementation of the first two proposed nodes: shared Nix ERT
execution constructor and two PDF leaves under the existing ert-pdf aggregate.
Ordinary project clean at intake. Authorized tests/ implementation; no production,
lock/index/history/README changes. Runtime checks separately authorized below. Preserve all case
bodies and per-test worker/config isolation; source/file dependencies enter by
explicit function args, no parent traversal or README. Optional integration
call interface remains compatible. Concrete changes and static verification
precede a separately scoped runtime authorization request. Prior planning and
delivery evidence below remain historical context, not this candidate's gate.

Implemented shared testSupport.mkErtCheck constructor, preserving optional
integration's existing required arguments. PDF inputs live in suites.nix and are
explicitly passed from tests/default.nix to sibling render/document checks;
existing ert-pdf now aggregates their names/logs and rejects cross-leaf duplicate
names. Original ert aggregate still consumes the same public ert-pdf entry.
Static baseline:53non-Nix inputs plus root flake.nix byte-equal; PDF disjoint27+32=59,
all568existing case bodies remain unchanged, no new README/parent lookup.
Prepared tmp/tests-opt-20261025 from81source inputs; only copied flake adds a
dependency-only559default-name/59PDF-name inventory check. Optional integration
runtime is not part of that gate. Source baseline/snapshot manifests remain tmp.

User authorized this task's repeated exact commands against that isolated copy:
1. timeout 600s nix build --no-link --no-write-lock-file --max-jobs 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs/tmp/tests-opt-20261025#checks.x86_64-linux.ert-pdf -L
2. timeout 600s nix flake check -L --no-write-lock-file --max-jobs 2 path:/home/lingyu/Projects/org-texmacs/tmp/tests-opt-20261025
Potential dependency network/store/cache/log/products disclosed, no root lock/
index/result writes; copy refresh authorized for same-scope fixes.
Both commands completed once with exit0 on x86_64-linux. PDF leaves started
together: render27/27 in128.667668s, document32/32 in80.958658s; aggregate passed.
Full default gate passes core176/176 in0.900527s, native318/318 in173.494314s,
patched6/6 in2.813273s, lint/strict package build and both aggregates. Temporary
inventory verifies exactly559default names and original59PDF names, no repeats.
Final81root input hashes match the accepted snapshot; copied inputs byte-equal
except intentionally instrumented flake. No ordinary staging/history changes.
PDF execution phase observed~129s versus prior serial231.327348s; single runs,
different resource contention, not a general speed guarantee. Native remains a
full-gate bottleneck. Optional9integration cases preserved but not run this task.
User committed the exact14Nix-path candidate and drafted message. All81committed
input hashes match the accepted manifest, ordinary worktree/index clean at
delivery review. Delivery association grounds this exact-source verification,
not a retrospective committed-state runtime rerun. Optimization delivered.
User now authorizes the previously deferred follow-up: set push-mark NOMSG to t
at four frontend test calls (two native, two PDF), leaving activation and region
semantics unchanged. Limit changes to these two Lisp files; no new runtime test
authority. This suppresses ordinary "Mark set" notifications, not diagnostics.
Implemented exactly four nil-to-t NOMSG substitutions in the two frontend files.
Readonly diff/whitespace review passes; third argument remains t, assertions and
all other bytes unchanged. User reports a prior manual nix flake check passed for this
change and no "Mark set" messages appeared. Supplied subsequent command exits0
in1.4771s with "running 0 flake checks" and "all checks passed": consistent with
already realized outputs, not a fresh execution of ERT in that invocation.
User's manual validation is accepted as reported evidence; agent did not rerun.
User committed the exact two-file/four-substitution patch and drafted message as
test: silence mark notifications in frontend tests. Readonly delivery review
confirms clean ordinary worktree/index. Follow-up delivered; no further work or
output suppression selected, no agent runtime rerun. Retain manual validation
as user-reported evidence rather than an agent-observed fresh ERT execution.

## Previous: live-log delivery and optimization planning

User reports the log change committed and requests GAW update, then tests/
optimization proposals. Readonly verification confirms the exact five-path patch
and complete drafted test: stream ERT logs during Nix checks message, expected
formatting parent and clean ordinary index/worktree. Delivery complete; no rerun
for identical bytes. A delivery association may ground this verification and
current source review, not retroactively ground original uncommitted runtime
acceptance. User authorizes planning, no new implementation/build/test. Use
git-maintenance for checkpoint messages; chore(memory), not docs by format.

All five ERT drivers (core/native/PDF/patched-caption/optional integration) now
stream combined stdout/stderr through tee and retain ert.log. Explicit pipefail
preserves pipeline failure/timeout handling; deferred cat removed. Lint already
streams, aggregate does not execute ERT. Only five Nix drivers changed (10 lines
added/removed); cases, helpers, production code and isolation unchanged. No speed
optimization implemented. Individual long cases still report only on completion.

User authorized applying the PDF driver patch and running once:

    timeout 600s nix build --no-link --no-write-lock-file .#checks.x86_64-linux.ert-pdf -v -L

Dependency network/store/cache/log/products were disclosed; no lock/index/result
writes. Approved daemon escalation exits0:59/59pass in231.327348s, all59timing
records captured and streaming observed before completion. User separately
authorized the other four driver edits, without additional runtime validation.
All-five static diff/whitespace/pattern checks pass; other suites not rerun.
No remaining test-run authority; do not repeat gates for staging/checkpointing.

Slowest cases:
- org-texmacs-pdf-issue11-bare-block-and-reload-consistency:57.909601s (~25%).
- org-texmacs-issue13-source-real-islands-and-native-statements:14.020948s.
- org-texmacs-pdf-issue10-inline-and-separate:11.898667s.
- org-texmacs-pdf-footnote-forward-backward-and-repeats:8.775450s.

Issue11 covers23combinations/69PDF generations/23independent reload processes.
Native double print passes serve reference/footnote semantics; waits poll early,
not fixed sleeps. Per-stage profiling, local reuse of unchanged PDF inspections
and independent sharding remain candidates, not adopted implementation. No
measured speedup or permission to remove coverage, print passes or isolation/
share workers. No raw archive needed: source and extracted evidence suffice.

## Recent infrastructure and formatting state

Current wiring uses personal-nixpkgs.lib.mkFlake, perSystem.nixpkgs.overlays and
packages.mkOverlays groups.default/legacy, with legacy.export=true providing
pkgs.legacyPackages. Removed mkLegacyPackages callback no longer referenced.
Source enters through explicit extraArgs.src. Authorized local library/emarccs
inspection matches locked personal-nixpkgs81ec8b6ea5cad6d3d9456daae714ffacf3a612a0.
Authorized timeout120s no-build flake check on the explicit project path exits0:
named packages, six checks, devShell and formatter evaluate on x86_64-linux;
that gate did not run compilation or ERT.

Flake supplies src and installed emacs; tests use pkgs.emacsPackages. The current
overlay guarantees the match; do not raise hypothetical alternate-Emacs callers
as a current design concern. Lint directly receives emacsPackages.package-lint,
test-only and without recursion. Named org-texmacs/emacs outputs were correctly
classified feat and their five-line delivery/message verified. Later package API
migration and formatting subjects appear in ordinary history; no complete
delivery-equivalence audit for those later commits. Formatting's50-file candidate
had49equal Lisp/Scheme token streams (whitespace/comments ignored, strings kept)
and an equal Python PDF-inspector AST excluding positions. This was static,
not runtime acceptance; the fresh PDF gate above is the latest runtime evidence.

Keep explicit external function-argument dependencies, no ancestor discovery or
test README access, all553main+6patched+9optional cases and worker/error/cleanup
isolation. Earlier full composition gate and distinct validation scopes:
memory/tests-refactor.md. Optional integration remains caller-supplied.
README references to removed packages.default/#default were previously reported;
documentation synchronization remains unselected.

The following proposal describes the earlier planning phase; its first two nodes
are now implemented and accepted above. Further profiling/reuse is unselected.

Planning result: shared Nix ERT constructor for maintenance, then two PDF leaves
by existing file ownership (pdf.el27cases141.684156s, six other files32cases
89.638816s), with ert-pdf retained as a non-running aggregate. Existing case
files contain no top-level helper definitions. The two-slot ideal lower bound
is~142s versus231s, not a measured speedup; full flake may still be limited by
native ERT's historical~186s. Further matrix stage timing should precede local
reuse of unchanged inspections; no global path-only cache or reduced print
passes/coverage/isolation. Acceptance requires disjoint actual59-case union and
unchanged semantics. Detailed proposal: memory/tests-refactor.md optimization
section. This earlier estimate is superseded by the observed candidate gate above.

## Previous baseline: tests migration/refactor committed and delivery verified

User approved the conversational plan and now requests implementation. Changes
authorized in tests/ plus existing README test instructions; no production code,
lock/dependency-version/ignore/index/history changes. No parent-directory lookup
or inferred repository root; external files enter Nix functions as arguments,
then may reach Lisp through environment. Tests must never access/pass README.
Use callPackage, common helper files without ERT registration, explicit bootstrap
ordering, native fixtures replacing two README cases, direct Nix->Emacs drivers,
three disjoint ert-core/native/pdf derivations plus a non-running ert aggregate.
Preserve all553 main cases (two example-name mappings),6patched/9optional real
integration cases, assertions/matrices/isolation/failure behavior. No shared worker
or deleted coverage for speed. Optional integration stays outside default checks.
User authorized repeated exact command for this task: timeout 600s nix flake check
-L --no-write-lock-file path:/home/lingyu/Projects/org-texmacs/tmp/tests-refactor,
including isolated preparation, existing pinned extension copies, dependency
network/store/cache/log/products. Project clean at intake; implemented direct
drivers/support/bootstrap and split cases into176core,
318native,59PDF. Static normalized case-body comparison passes for all553
(only two example-call/name substitutions and strict-tools marker replacement),
patched6/integration9 unchanged. Shared helper files register no tests; runtime
runner rejects empty/duplicate cases and writes actual names. Removed two Guile
wrappers and all test README access; Python inspector moved byte-identically.
Prepared tmp/tests-refactor with byte-equal project inputs except copied flake
adds optional integration (existing11extension modules) and a dependency-only
568-name inventory check; root flake/lock/production/index untouched. Both exact
authorized full checks exit0. First:176core/318native/59PDF/6patched/9integration,
package-lint, strict package build and inventory all accepted. Second reuses
identical successful suites and adds five deliberate runner failure probes plus
a positive fixture, all accepted. Final65project+11extension input equality and
normalized case-body preservation verified; whitespace clean, ordinary index
empty at runtime acceptance. Core1.033395s/native177.056561s/PDF209.939116s;
no general speed guarantee.
Complete interfaces, command/evidence boundaries and results: tests-refactor.md.
README test instructions synchronized; tests have no README reference/access,
no parent lookup (only three synthetic normalization strings retain ../), and no
Guile wrapper. User subsequently staged all48changed paths. Commit-message review
confirms all65staged inputs equal accepted manifest, no unstaged changes and clean
staged whitespace. Complete binary patch1431662bytes, SHA256
ff2b139e3f687dd7361a284fb022b1f4791d6570c1fc812f452d829f1e4e1f82.
git-maintenance reviewed as one coupled refactor; tmp/commit.md now contains
refactor(tests): split ERT suites and isolate dependencies, five Chinese bullets,
no issue/breaking footer. No rerun solely for matching staged bytes and no ordinary
agent Git write/commit/external write. User committed the exact reviewed candidate.
Readonly verification confirms the expected single Python-allowlist parent,
48changed paths, complete binary patch hash above, all65accepted committed input
blobs and full drafted message (normalizing only terminal newlines). Ordinary
project index/worktree clean. This project association grounds committed-delivery
equivalence, not the original uncommitted runtime acceptance. No issue footer or
linked external tracking; no remote lookup/write needed.
No raw archive needed: maintained cases/runner plus extracted evidence suffice.
Tests migration and delivery complete; next user selects work. Do not rerun passed suites absent new changes
or unresolved concern. GAW checkpoint messages must use git-maintenance.

## Completed: adapt checks to user's lisp-root source

After the initial layout gate below, user changed flake source root to ./lisp
and buildPackage src back to source, and staged the relocation/adaptations.
User requests minimal test adaptation preserving original semantics; broader
test cleanup is explicitly deferred. README examples and the existing mandatory
tool checks remain; do not remove READMEs or replace examples with fixtures now.
Two one-line corrections: package-lint uses @source@ directly instead
of @source@/lisp; patched-caption driver supplies root ../../README.org directly
instead of ${source}/README.org. No assertion/runtime/source/flake changes.
User authorized one timeout600s nix flake check -L --no-write-lock-file from root,
including locked-dependency network and store/cache/log/products. Initial sandbox
attempt failed opening the Nix fetcher-cache SQLite database, before testing;
approved escalation completed exit0, all flake checks passed. Stock553/553 ERT
(382.099933s), including both README examples and package-load/worker colocation,
strict compilation/installation, package-lint and patched-caption check accepted.
Pinned x86_64-linux only; incompatible systems omitted. No weaker assertion,
removed/renamed case or new fixture; only two test-path lines changed. No runtime,
README, flake, lock or ordinary index mutation by agent. Earlier gate below
validates the preceding source-root configuration only.
User also requires git-maintenance for future GAW checkpoint messages; do not
rewrite existing history. Ordinary project staging/commit remains unselected.
Test-path adaptation is complete. Initially unstaged, both fixes are now staged
by the user during validation; final readonly inspection finds no unstaged diff.
Agent did not stage any ordinary project path. Broader test cleanup,
README fixture extraction and explicit test-environment flag are deferred, not
part of this completed node. No new archive needed; existing tests and extracted
gate result are sufficient. Next: user delivery or separately select cleanup.

## Completed: initial lisp/ relocation adaptation implemented and validated

User moved all 15 Elisp modules and the Scheme worker from root into lisp/ and
requested corresponding adaptations. At intake root deletions and flake fileset
change to ./lisp were already staged; lisp/ was ignored by the root allowlist.
Preserve that index; no ordinary staging or commit authorized.
Selected adaptations: allow lisp sources in .gitignore, build the package from
${source}/lisp, run package-lint with that source/load directory, and update README
checkout/use-package/straight paths. Worker uses its own library directory and
needs no runtime change. Existing package-load ERT checks worker colocation.
User authorized one isolated command: timeout 120s nix flake check -L
--no-write-lock-file path:/home/lingyu/Projects/org-texmacs/tmp/lisp-layout-check,
including snapshot preparation, locked-dependency network/store/cache/log writes.
First command timed out (exit124) after strict package compilation/installation,
patched Org6/6 and stock228/553 passed with no observed failures. User separately
authorized the same command once with timeout600s. Initial sandbox invocation
could not access daemon socket; approved escalation then completed exit0:
553/553 stock ERT (402.301644s), all flake checks passed, reusing successful strict
compilation/default+patched installation/package-lint/patched Org6/6 outputs.
Pinned x86_64-linux only; incompatible systems omitted by Nix, no straight runtime
installation or GUI test. Straight's official recipe docs confirm plain globs
flatten matching lisp files into the package build directory:
https://github.com/radian-software/straight.el#the-recipe-format.
Final verification: all16 moved sources still match prior root HEAD bytes, all32
isolated inputs match current project, whitespace clean, staged path/status set
unchanged. Four ordinary adaptation paths (.gitignore, flake.nix, README.org,
tests/package-lint/run.scm) remain unstaged; lisp/ is untracked rather than ignored.
No runtime edits/new tests/lock/version/index/history/external writes. No raw
archive needed: maintained source/tests and extracted results suffice. User can
review/stage the relocation and adaptation; no further implementation/check
remains. Check snapshot retained under tmp/lisp-layout-check, not durable authority.

## Completed: v0.5.0 version/documentation delivery committed and verified

User narrows current release work to version metadata and documentation/comments.
Full nix flake check already accompanies each commit; do not list a separate
release-only complete-check gate or demand another run merely for publication.
Normal change-specific/commit validation continues under its applicable authority.
Representative documents are a final optional decision: whether to do them and
format/entrypoint (e.g.nix flake check or nix run) remain undecided. Do not treat
them as a mandatory prerequisite or preselect new fixtures/Nix interfaces.

User selected version/docs implementation against clean main75762b0. Six ordinary
files now contain0.5.0 package/Nix declarations, README overview/migration/support
corrections and relevant commentary/docstring updates. No runtime logic/API/lock/
test changes. Full isolated flake check exit0:553stock ERT(379.866632s),6patched
Org(2.836266s), strict compilation/lint; default no-link package build exit0.
32root/copy input hashes match before/after acceptance; diff whitespace clean.
First check found an84-column added docstring, rewrapped before final acceptance.
Exact commands/authority and scope: release-0.5.0.md top. User committed the
reviewed candidate; single expected parent, full six-path binary patch, complete
message and all32accepted input blobs match. Project index/worktree clean.
No runtime rerun for identical committed bytes. Current project association
grounds delivery verification, not original uncommitted runtime acceptance.
No tag/publication. Version/documentation work is complete; next user may choose
final optional representative-document work or explicit release actions. No new archive/skill change:
ordinary Git preserves docs and existing evidence suffices. Completed feature work,
Chinese fonts and PS scope remain unchanged; no new release-only test blocker.

## Completed: release scope narrowed; PS route is completed diagnostics

User adopts recommendation to stop pursuing tree->PostScript->PDF as a feature,
workaround, maintained acceptance route or release condition. Original goal was
footnote/link export gaps. Independent native PS controls also lacked footnote
DEST anchors, so PS did not solve it; direct PDF repair is delivered with maintained
anonymous/named/repeat/forward-back/cross-page/cleanup/worker isolation ERT.
Keep historical PS evidence/temporary probes and immutable archives; do not add
Ghostscript/runtime backend dependencies or a second public export path. No
outstanding PS investigation or release gate. Reconsider only if user later
selects a concrete unmet need. Full decision/evidence: footnote-forward-probe.md
and footnote-pdf-fix.md. Chinese font issue also removed from backlog/blockers
by prior user decision. Other release work unchanged; next user selects work.
This turn is memory-only, no ordinary code/index/archive/skill changes or runtime reruns.

## Completed: Chinese font issue closed as external; no project blocker

User supplied ~/emarccs TeXmacs override method (same lock not required). Actual
pkgs/org-texmacs/override.nix sets extraFonts/chineseFonts/japaneseFonts/koreanFonts
all true. Exact scoped source identity/method extracted, no raw foreign archive.
Isolated tmp/font-override-probe completed exit0:24PDFs,8groups, generic/article,
default/chinese language x plain/override x package/native/tm reload. All routes
match exactly in text, normalized fonts/layout and full font-face names. Override
12PDFs real Chinese, plain12fallback. No manual fonts/host config/native font import.

Matching symptom reproduced: even ordinary 中文测试 splits 中文 into UnBatang
and 测试 into AR-PL-New-Sung, with size/baseline differences; heading/strong/italic/
quotation also mixed. Chinese language alone does not fix. Native identical, no
exporter-specific font repair justified. Two previews visually inspected. Exact
native fallback priority not yet traced; not user's exact GUI/config/lock. Current
conclusion supersedes earlier inability to reproduce without supplied override.
32root input hashes unchanged; root production/workaround/lock/index untouched.
Detailed sources/command authority/results/limits: block-font-investigation.md;
report/results: tmp/font-override-probe. Necessary12text originals archived at
archive/2026-10-18T13-47-27Z--75762b0/MANIFEST.md, separately from memory.
User accepts this issue is outside org-texmacs responsibility and explicitly
removes it from active backlog/pre0.5.0 blockers. No native-font fix/mitigation,
font configuration/docs or default-font policy task remains. Evidence retained;
this does not assert native fonts are fixed. Next user selects other release work.
Ordinary project files/index unchanged; no new runtime checks needed.

## Completed: statement caption completion committed; delivery verified

User-selected statement NAME/CAPTION completion is implemented in six project
paths, verified on isolated copied inputs: focused75/75(114.762178s), patched Org
6/6(2.922588s), stock553/553(430.785335s), full flake all7checks/strict compile/lint
and default build exit0. Root/copy32input hashes verified,31non-flake bytes equal;
copied flake only adds independent native gate. Root ELPA workaround/lock unchanged,
User committed the exact six-path candidate; parent, full binary diff, all six
validated blobs and complete drafted message verified. Index empty; only original
root flake remains unstaged. No agent ordinary commit/external write/release action.

All16statement types gain long caption->dueto with existing inline/ref ownership,
strict reject explicit short incl erased []/empty long before caption link scan,
pre-prune source evidence and validated scoped rebind; excluded owners do not fail.
Use label then dueto prefix; first concat surrounded without changing original STM
root or internals, nonconcat/empty separate prefix, no metadata no body change.
Preserve STM/file paths and same-prepared frozen IDs. Native gate passed BEFORE
production: generic/article36cases/style/direct vs surround/readback/saved tm
reload/text/counters/fonts/layout/actual PDF targets. Legacy NAME-only separate
body paragraph disappears; text/counters/target coordinates unchanged. Corrected
legacy body-line assertion does not establish broken old references. Duplicate
native destination-key diagnostics recorded, actual target checks pass.

Full implementation/authorization/results/initial test mistakes/limits:
statement-caption-implementation.md. Adopted design/INBOX first-read identity and
no redundant raw capture: statement-caption-review.md. Necessary independent
native evidence only: archive/2026-10-18T02-10-34Z--947289b/MANIFEST.md. Archive and
memory checkpoints separate; skill files unchanged. Split unnecessary: implementation,
regressions and README form one coherent capability. tmp/commit.md ready with
feat(document): support captions on formal statements; Refs:#13, no Closes.
Delivery verification complete, without runtime rerun of unchanged bytes.
User authorized another remote read. Public issue13 HTML now confirms
state CLOSED, stateReason COMPLETED, agreeing with earlier verified status.
Next user selects remaining release
work; this does not establish0.5.0 readiness. GUI/other styles/platforms not newly tested.

## Completed: block mapping / CJK bounded investigation

User recalls original fixed blocks primarily quote/center; archive red/green
quote reports and retained center positive controls now map to current regressions.
Fresh14/14block/native ERT58.636359s cover other current supported blocks too;
no further mapping defect established. Exact lost original source not recovered.
72font diagnostic PDFs:two Noto variable TTC matrices total48cases still
fallback (families listed but missing native masters); final24Fandol gives18real-
Chinese positives and6missing-font baselines. All8final configurations match text,
font specs/full names and geometry exactly across package/native/saved-tm reload. Full native
Fandol font setup plus FandolSong/chinese or FandolHei is a practical tested config;
font availability/registration required, native bold/italic/size differences remain.
User original environment/symptom not fully reproduced, no exporter patch justified.
No production/index/lock/user-flake change, no full release gate. Detailed scope,
authorization/diagnostics/limits and23text archive: block-font-investigation.md.
Later native override reproduction is complete; user removes font issue from
project backlog/blockers. No font follow-up pending. Other release work remains.

## Completed: PDF footnote destination repair delivered and verified

User-selected production repair is accepted on fixed isolated inputs. Worker
installs a same-key label before the original recognized render-footnote* binding
only in its disposable PDF buffer after first print. Native numbering is retained;
explicit footnote/render-footnote/render-footnote* inits and incompatible/already-
labelled macros are preserved. Source/prepared/serialized trees and sessions stay
unchanged. No API, protocol, global style/config or Org dependency change.

Focused pdf-footnote6/6 passed29.555130s, including five new maintained regressions.
Full nix flake check exit0 (all checks passed: full stock ERT, patched Org, strict
compilation and lint); no-link default build exit0.32runtime inputs equal root and
isolated tmp/footnote-fix before/after all gates; original ELPA workaround and lock
unchanged. User committed all seven approved task paths; exact delivery verified. Coverage: generic/article,
anonymous/named-repeat/markup/cross-page, actual forward/back targets, repeated
exports, explicit macros, error cleanup/recovery, shared session/worker isolation
and cleanup-fatal shutdown. No GUI, PS exact landing, arbitrary-style or caption
layout guarantee. Full contract/commands/identities: footnote-pdf-fix.md. Earlier
causal evidence and archived originals: footnote-forward-probe.md and
footnote-private-integration.md. Read-only verification confirms the exact single expected Issue13 stage4 parent,
seven paths/blobs, full binary patch and approved message; index empty, original
flake workaround alone unstaged, lock unchanged. No runtime rerun solely for
commit verification. Project-parent association grounds delivery equivalence,
not the original uncommitted runtime acceptance. Remaining release gates are
separate; next user selects readiness work. No agent ordinary commit or external
tracking action.

## Completed: Issue13 delivered, verified and closed

User authorized implementing the reviewed NAME/reference plan plus adopted
line550 supplement and repeated isolated-flake focused/full/default-build gates.
All fourth-stage changes now accepted on fixed inputs:57/57focused84.812325s;
539/539fullERT402.926507s, patched Org5/5, strict compilation/lint/full flake exit0,
no-link default build exit0. Only pinned x86_64-linux/Org9.8.10/TeXmacs2.1.5,
generic/article validated. Native GUI/other styles/platforms unverified.

Private validation-only resolver uses bounded Org search-cell index, strict
identity ambiguity, raw opacity, reachable notes/caption/title links. After real
STM and ownership copying, Org allocates once, ASCII slug formats IDs, frozen
resolution drives repeated pure lower. Up to64pre-freeze collision attempts;
post-freeze conflicts error. Intermediate filter copies never allocate; constructor
invalid semantic errors remain deferred to document. NAME source count/ownership
proof survives scoped reparse, all named block kinds get labels even unused;
naked tables retain referenced-only behavior. Native label placements, original
STM/file provenance and metadata/excluded-region boundaries accepted. README
updated. Full contract/evidence/commands/final identities: issue-13-stage4.md.

User committed the approved seven-path fourth-stage candidate. Read-only delivery
verification passes: exactly one expected caption-task parent; exact seven paths,
full binary patch76907fc1..., approved message c82f96b7... with Closes:#13 and all
accepted blobs match. Lock unchanged; index empty; only original ELPA flake overlay
remains unstaged, unchanged. All31runtime inputs previously matched isolated flake;
no tests repeated solely for commit verification. Runtime was uncommitted; current
project-parent association grounds delivered-equivalence verification only.
GitHub Issue13 is closed/completed, closed_at2026-10-17T18:01:20Z, independently read through the connector; no external write by agent.
All four stages of bounded Issue13 are delivered/accepted. No new archive or skill
update needed. Next: user selects remaining v0.5.0 readiness work; existing release
gates and native limitations remain, Issue9 composite scope remains later. No
release-ready, tag or publication claim.

## Completed delivery: caption footnote AST compatibility delivered and verified

User's final decision accepts correct native AST/content conversion without
caption-footnote GUI/PDF visibility, counter/directory or page-layout guarantees.
Both long and short captions use the same anonymous inline boundary (:type inline,
:label nil). Prior short ban/PDF blocker superseded. No automatic note-ref split,
style/layout/counter/anchor workaround; no general secondary-AST note expansion.
User's split-note GUI/page-anchor evidence is attributed, not agent GUI testing.

Production changes are a local footnote context predicate plus generic rejection
of citations missing their captured resolution mapping. The latter prevents a
newly reachable caption-note citation from silently emitting empty(cite), without
adding caption bibliography support. Copy/preparation/context paths unchanged.
Native regression records exact readback/reload and known PDF body loss, not a
layout repair. README distinguishes stock syntax from structured compatibility.

Default focused4/4passed10.027854s; isolated patched parser integration5/5passed.
Final full flake (stock ERT, strict package compile/lint, patched check) and no-link
default package build exit0. Final29inputs unchanged/equal root and isolated
snapshot; whitespace clean; index was empty at runtime acceptance, lock/version unchanged.
Nix shared buildPackage takes Org; default still stock Org. Neighboring test patch
is generated against locked9.8.10 and applied fuzz0 to deterministic test-only tar
before ELPA install. Actual loaded Org/package paths verified. Native-related
runs use isolated flake, all five task commands authorized.

User committed approved nine-path candidate after explicit staging authorization.
Exact delivery verification passed: single stage3 parent, full binary patch and
complete approved message, nine changed blobs plus unchanged lock all match.
Index empty; original ELPA overlay/system parameter remains sole unstaged change.
Feature flake excludes mirror only; runtime acceptance used mirror-bearing isolated
flake. No tests repeated for commit verification. Current GAW project association
grounds exact delivery verification, not original uncommitted runtime acceptance.
Full contract/identities/limits: caption-inline-footnotes.md.
Next: separately select/plan Issue13 stage4 NAME and links. Whole13 and release
remain unfinished; no stage4 implementation or release action authorized here.

## Completed delivery: Issue13 stage3 delivered and verified

User authorized implementing reviewed plan plus adopted revisions1/2/3 and six
acceptance additions. Independent parser/native gate31/31 passed before exporter
edits. Candidate now covers4figure/table wrappers, private pre-prune owned source
proof, range-rebound scoped AST, legacy caption subset and finite raw-table
normalization with original-root STM/file provenance. User committed exact five
task paths; delivery verified, index empty, only original flake overlay dirty. No protocol/API/version/
lock/skill/archive/release change. Detailed contract/evidence/commands:
memory/issue-13-stage3.md. Final44/44focused passed54.281918s including context selection/dependency
completeness correction. Final full flake check and no-link default build exit0 on the fixed candidate.
Final input manifest unchanged after all acceptance commands.

User adopted actual Org boundary limit: column-zero [fn:...] in a would-be raw
multiline string inside a note can terminate the note and erase nested blocks
from AST. Unsupported spelling documented/tested, no textual reconstruction;
legal note restoration and top-level raw directives remain separately tested.
Generic/article native counters, missing-caption numbers, stars, real graphics,
readback/direct-reference-reload PDFs/geometry passed. Locked x86_64-linux only.
Read-only verification confirms single expected stage2 parent, exact five paths,
full patch/message and all accepted task/lock blobs. Runtime originally used an
uncommitted candidate; project association now grounds delivery verification.
No tests repeated solely for commit. Next: separately plan stage4 NAME/links. Whole13/release and stage4 NAME unfinished.

## Completed delivery: Issue13 stage2

User authorized the reviewed stage2 plan and repeated focused/full/build commands.
Raw-STM equation/equation* wrappers implemented; twelve new maintained ERT added.
Final focused29/29 passed29.580234s; full flake check (complete ERT, strict package
compilation and lint) exit0; no-link default package build exit0. Native generic/
article numbering1/2 with interleaved star and theorem-nested star, independent
readback, Unicode/fraction PDFs and saved tm reload geometry pass. Input manifest
unchanged after acceptance. Full commands, source hashes and limits:
memory/issue-13-stage2.md. Pinned x86_64-linux only; other systems not certified.

Native-body classifier shields preprocessing/bibliography/context/dependency and
fragment paths without broadening texmacs-only editing/block APIs. Pure lower
packs exactly one wrapper and preserves STM paths; source emptiness is checked
on final selected requests, distinct from a valid empty-string datum. No math
whitelist, recursive Org formula body, extra concat/document, custom callback,
NAME or protocol addition. Transport/session and partial-write limits unchanged.

User committed the exact reviewed nine-path candidate. Read-only verification
confirms the expected single stage1 parent, complete task paths/patch/blobs and
exact message equality. Index empty; only preserved flake.nix mirror overlay
remains unstaged. Refs:#13, no closure or release action. No tests repeated solely
for commit verification. Original runtime used the uncommitted candidate; current
project association grounds exact committed-delivery verification instead.
Detailed patch/message identities: memory/issue-13-stage2.md.
Next: separately select/plan stage3 figure/table wrappers; stage4 NAME and Issue9
composite-row identity remain later. Whole Issue13 and release gates are incomplete.
No source/skill/archive changes in this delivery verification.

Stage2 intake source INBOX (superseded):23584bytes,SHA256
71c40dd0686b702f2f87dbbc4ba9b5a1c752c3e9ff8f88be073976498a2ec85c,
matched its first review then; current source is stage3 above. Retention was: no raw archive, since adequate current
memory captures relevant guidance/corrections and no independent raw evidence
remains. No archive files created. Do not assume future INBOX bytes remain equal.
User clarified read-only defaults to ordinary project worktree; normal GAW loop
continues unless expressly forbidden. Skill changes were checkpointed separately;
do not mix skills with memory/archive. No .gaw/protocol/bootstrap/history rewrite.

## Completed delivery: Issue13 stage 1

User clarified material intake: first requested read/review must assess original
archive need and distill relevant memory then, assuming the file may change or
disappear before the next read. This reusable procedure is now in development,
governance and archive skills. Stage1 INBOX's first review did not synchronously
record a raw-retention decision/digest; later adopted implementation memory is
not contemporaneous original capture. Its useful guidance/review decisions are
distilled in issue-13-stage1.md; no verified first-read raw snapshot claimed.
Current INBOX was not reread/substituted to conceal this gap. No source/archive/
bootstrap/history rewrite is part of this governance clarification.

User-selected recursive ordinary special-block foundation and formal statements
implemented, automatically accepted and user-committed. Five task
paths: document/input/source adapter, ERT and README. Original flake.nix mirror
workaround preserved/excluded; lock/version/INBOX unchanged. Agent did not execute
ordinary commit or external writes. Final focused17/17 (19.993503s), full495/495 (326.837943s), full
flake including strict package compilation/lint, and no-link package build exit0.
Final input hashes unchanged after acceptance. All16statement candidates have
real generic-style native title/counter/PDF evidence; theorem/proof tm reload
also passes. Other styles/GUI/platforms are not certified by this gate.

Private captured handlers retain contents exactly once, unchanged; reject all
external descendant cons/string sharing before output copy. Deep-rebuilt semantic
duplication remains a callback contract, not a complete runtime check. Preflight
rejects detectable source errors before BODY STM requests; bibliography requests
may precede it, custom handlers never receive placeholders. Scoped requests,
ownership/symbol snapshots, pure interfaces, file/STM provenance, source guards,
final error/recovery and legacy regressions pass. No public handler API added.
Full contract, exact authorized commands, intermediate fixture diagnostics and
candidate identities: memory/issue-13-stage1.md. No raw archive needed; maintained
fixtures retain sufficient native/structural reproduction. Original runtime used
an uncommitted candidate; current project association grounds later exact
committed-delivery verification, not retroactive runtime provenance.

Read-only delivery verification confirms expected single parent, exactly five
paths, complete patch and exact commit message match reviewed staged candidate.
Committed task/lock inputs equal accepted worktree bytes; original flake overlay
unchanged and unstaged. Index empty. Refs:#13, no closing footer or issue-close
action; no remote issue-state lookup required for this bounded delivery.
Exact patch/message hashes: memory/issue-13-stage1.md. No tests rerun just for
commit verification. No further stage1
implementation/testing remains. Whole13 and v0.5.0 are not complete;
figure/table/NAME and weak anchors remain separately selected later work. Issue9
remains post0.5.0. Stage2 is delivered/verified above.

## Adopted full scope: v0.5.0 Issue13 and Issue9 refocus

The preceding INBOX scope reconciliation was memory-only.
Issue13 is now required v0.5.0 usable special-block subset: private recursive
handler boundary, statement/type aliases, raw-expression equation/equation*,
explicit numbered figure/table wrappers (empty caption still numbered),
experimental starred unnumbered wrappers, and identity-based single-object
NAME/[[name]] with native per-category label placement. Opaque texmacs STM stays
unchanged internally; naked Org tables retain legacy compatibility behavior.
No public handler API/parameter DSL or selected float strategy. Weak surround
anchors and referenced-only label enablement remain candidates needing evidence.
Complete design/limits: memory/special-block-plan.md.

Issue9 remains post0.5.0/pre0.6.0, now multiple independently named constituents
assembled into one composite native AST, initially separately numbered/referenced
rows of an aligned formula. It no longer owns all general NAME/block references.
Issue bodies last verified open/consistent during the preceding reconciliation
(updated2026-10-17 08:11:44Z/08:11:46Z for13/9). No external writes. Other release
gates remain open as recorded; stage1 evidence above does not validate later13
nodes or constitute full release acceptance. Stage2 guidance now adopted above.

GAW goals/current/backlog/project/release synchronized with concentrated plan;
older implementation/experimental evidence preserved as historical context.
No skills/config/archive changes needed; active plan fully distilled, no unique
raw experiment to archive. Zero added project parents for this planning update.

## Completed: TeXmacs block editing and indentation delivered

User committed the exact reviewed feat(edit) candidate. Read-only verification
confirms single expected bibliography-delivery parent, exactly five task paths,
full binary patch and complete commit message hashes match approved staging.
All28 tested worktree identities unchanged;27 committed source/test/README/lock
inputs byte-equal tested candidate, with root flake intentionally excluding the
original user mirror overlay. Index empty; only that unchanged overlay unstaged.
No tests rerun just for delivery. The new project-parent association records exact
committed equivalence checked now, not retroactive original runtime provenance.

Native Org source-edit/save/exit/abort/reuse and Scheme TAB/line/region indentation
are delivered for complete TeXmacs special blocks. Public org-texmacs-edit-mode
defaults to bundled scheme-mode; optional user-installed scheme-ts-mode/grammar
checked explicitly. No added mandatory dependency, Babel/parser/export change or
inline editing. Fontification remains independent. Prior30focused/478fullERT
(340.820181s), fixed extension integration, strict byte/native compile/lint/full
flake acceptance transfers by exact bytes; actual TS/GUI editing unverified.

Contract, rationale, candidate identities and delivery evidence:
memory/block-editing-implementation.md. No raw archive needed: tests and distilled
memory retain necessary evidence. No linked external issue or closing footer for
this feature, so no issue-status check required. No release action/milestone added.
Next project choice follows memory/release-0.5.0.md. Optional fresh-package GUI
editing acceptance may be collected; do not infer it from earlier font-lock
basic GUI feedback. No implementation/staging action remains for this task.

## Completed: Issue12 bibliography delivered and closed

User committed the exact reviewed native bibliography ownership fix, including
expected parent/eight changed paths/exact patch and commit message with Closes:
#12.19committed and worktree source/test/README/lock hashes equal the tested
candidate; ordinary index empty, only original unchanged user flake overlay dirty.
Original runtime tested an uncommitted candidate; this subsequent delivery check
establishes exact committed equivalence, not retroactive runtime provenance.
GitHub connector confirms Issue12 closed/completed, closed_at2026-10-16T16:45:06Z,
zero comments/no milestone. No agent GitHub write or ordinary commit performed.
Native AST authority, used-key-only ambiguity, no automatic uncited dependency
expansion, output reference/label/with-bib/provenance checks delivered. Source/
configuration/dependency guards, acquisition policy, ownership and lifecycle
preserved. README/comments/tests synchronized. Locked x86_64-linux
Emacs31.1/Org9.8.10/TeXmacs2.1.5:16native controls,3expected baseline failures,
107focused/464fullERT/9fixed real extension tests/full flake/strict compile/lint
passed. Details and limits: memory/issue-12-review.md.14necessary original-byte
text artifacts: archive/2026-10-16T16-37-01Z--1ee3de5/MANIFEST.md.
No personal-library rereads, GUI/other-platform/full BibLaTeX acceptance.
No implementation/tracking action remains for #12. Optional fresh-version manual.org
check with org-organize/discovery enabled remains unperformed, not a closure gate.
Next project choice follows existing v0.5.0 readiness; no new scope/milestone adopted.

## Completed: supplementary PDF derived-state checks

User-requested supplementary tests/manual plan complete and ERT user-committed.
Exact delivery verified: one test file, reviewed message/patch/all25input hashes.
Only ERT changed; no business code changed. User's flake overlay preserved.
Focused6/6 (19.054185s), full440/440 (285.609164s), authorized600s full flake
exit0 including strict compilation/lint and final12PDF probes on x86_64-linux.
All12PDFs: TOC/heading/citation/repeated-note checked target pages correct;
4style/size groups have stable pagination/marker pages/normalized text across
direct/reload2/reload6. Same-page exact landing remains a manual click check.
Separate confirmed gap: first-use footnote annotation has dangling /label6 in
all12PDFs; repeated note valid. More passes/native reload do not remove it;
exact root cause/release impact not established; native-path reproduction below. No repair
adopted. Concrete manual PDF and First-versus-Again procedure available under
tmp/pdf-links-adjacent/results and MANUAL.md. User subsequently reports clicking
First's superscript1has no observable effect; other checks broadly meet
expectations. User did not identify viewer/exact PDF or certify every precise
landing. This agrees with automated dangling target evidence, not causal proof.
User additionally reports clicking the number before footnote body returns to
First1. Thus body-to-first-reference backlink works in this manual observation;
first-reference-to-body forward jump has no observable effect. Distinct links
must be diagnosed separately. No agent GUI clicks claimed.
All24non-ERT runtime snapshot inputs match then-committed production source;
supplementary ERT was uncommitted during runtime, now exactly user-committed.
Initial/final manifests and exact patch explicit.17necessary
original-byte text artifacts archived/verified separately, no PDF/binaries:
archive/2026-10-16T11-43-36Z--f4a194e/MANIFEST.md.
Scope, exact commands, findings and limitations: memory/pdf-adjacent-checks.md.
Subsequent user-selected native causal controls complete:20conditions,
atom/document/document-label/surround-label/existing package .tm x2styles x2/6
forced-print passes. All20have1missing first-use forward target; backlinks
resolve into first-marker rectangles, explicit labelled repeats resolve.
Even bare native footnote reproduces; package wrapper not a necessary cause.
No org-texmacs module/Emacs executed in native-only experiment. Post-layout
macros show forward reference footnote-<nr>, body set-binding with same literal
prefix, separate footnr-<nr> backlink. Runtime key identity/PDF callbacks not
traced, so exact loss/mismatch cause still unresolved. User native interactive
reproduction subsequently supplied below; no general version claim, business
repair or workaround selected. Final exact240s flake
command exits0, sampling additions leave annotation report byte-identical.
Two early harness initialization/focus failures rejected by guards; diagnostic
limits extracted.13necessary original-byte text artifacts archived separately:
archive/2026-10-16T12-12-14Z--f4a194e/MANIFEST.md
Full extraction: memory/pdf-adjacent-checks.md and task tmp/footnote-targets/REPORT.md.
User committed the supplementary test(pdf) delivery; read-only verification
confirms parent=PDF repair, only tests/ert/ert.el, exact reviewed message/patch
and all25accepted input hashes. Index empty, only original user flake unstaged.
Prior6focused/440core/full acceptance transfers by exact bytes; no retest needed.
No issue footer/association, so no related remote issue state lookup required.
Current project parent grounds this committed-delivery verification, not original
uncommitted runtime or synthetic native-control provenance. Full draft and
verification: memory/pdf-adjacent-checks.md. No new archive needed; existing
immutable evidence retained. Native first-note gap remains unresolved/unrepaired.
User now reports independent native interactive reproduction from nix develop;
provided tmp/realworld_test/test_footnote.tm/PDF. Agent verified minimal native
footnote, .tm footnote-1/footnr-1 saved references and PDF catalog missing first
annotation /label0 while backlink /label1 valid. No worker necessary; exact
native binding/PDF cause unresolved. GUI creation/export user-reported, not
agent-witnessed.2text artifacts archived separately, PDF excluded:
archive/2026-10-16T12-55-42Z--b970820/MANIFEST.md
Manual bibliography triage: user reports org-organize-mode off succeeds with
collector only refs.bib; on adds3literature .bib files and validation fails.
Authorized read-only inspection found @online in second external file, outside
fixed standard-type grammar; third template month=MM also outside literal-only
values. No external files changed or copied, no new Emacs/test execution.
User says same files work in ox-latex: record support-boundary mismatch and
all-collected-entry preflight/weak diagnostics, not corrupt bibliography or
proven parser conflict. Full file identities/scope/findings:
memory/pdf-adjacent-checks.md. No personal-source archive justified.
Default-on STM font-lock implemented, automatically accepted and user-committed;
exact delivery verified read-only. Five task paths/main+module+Nix+ERT+README,
expected parent/complete patch/exact reviewed message match.26committed source/
test hashes match accepted candidate;27root hashes include preserved user flake
overlay. Committed flake only module entry. Index empty, only user mirror unstaged.
11focused/451core/full compile/lint acceptance transfers by exact bytes; no retest.
Internal nil default/local override, no dedicated command/Customize; Scheme
properties, local Org/scanner bounds and old/new owned restoration. Dense1MiB
full ensure17.4s/local re-fontify0.489s remains explicit cost. GUI/folding/navigation/
third-party checks pending at tmp/font-lock-implementation/manual.org/MANUAL.md.
Full contract/delivery/evidence: memory/font-lock-implementation.md;13text originals
retained in archive/2026-10-16T14-21-15Z--b970820/MANIFEST.md unchanged.
New project association grounds later committed-delivery verification only,
not original uncommitted runtime provenance. No issue footer, so no remote
state lookup/closure inferred. No new archive or release action needed.
Current plan reconciliation: memory/release-0.5.0.md. Other release gates unchanged.

## Completed local repair: PDF hyperlink annotations

User-selected PDF link repair is implemented, automatically accepted and
user-committed; exact delivery verified. Worker now forces synchronous native layout before each
existing print; invalidation alone had omitted link annotations. Pure AST and
encoding unchanged. Three task files: worker, ERT, README; two new regressions.
Controlled baseline12PDFs all0annotations, native-only force8/8restores URI and
internal destination, final package/native/reload12/12have both. Original worker
fails both maintained regressions as intended. Focused36/36 (125.005432s), real
extension9/9 (10.292105s), core439/439 (279.377034s), complete600s flake exit0,
strict compilation/lint/all seven applicable checks pass on locked x86_64-linux.
18baseline/25candidate/11foreign identities verified; root lock/source stable.
User committed the exact reviewed fix(pdf) message and three-file delivery.
Parent is verified Issue10 baseline, all25committed input hashes and complete
patch match acceptance. Index empty; only user flake unstaged. Prior validation
transfers by byte identity. No issue trailer/association, so no related remote
status lookup needed. Project association grounds this delivery verification,
not original uncommitted runtime provenance.

Contract, exact commands, provenance and remaining validation limits:
memory/pdf-links-investigation.md. Twenty necessary original-byte text artifacts
archived separately and verified: archive/2026-10-16T11-13-53Z--847845c/MANIFEST.md.
No PDFs/binaries/full tmp/INBOX archive. Original whitespace retained/explained;
no candidate project parent inferred. No further test needed without changes.
Supplementary tests and manual plan now completed above.
Chinese fonts were then postponed; later native reproduction led user to remove
them from backlog/blockers. No font work or release action selected.

## Completed committed delivery: Issue10 inline footnote STM

Final user-selected contract implemented/automatically accepted/user-committed.
One coherent feat(document) delivery with Closes:#10; exact parent is committed
Issue11 baseline, exactly5task paths changed. All25committed input hashes equal
accepted manifest; complete message equals tmp draft and GAW-preserved full draft.
Index empty, only original user flake mirror unstaged. Previous46focused/9real/
437core acceptance transfers by exact bytes, no new tests needed. Full contract/implementation/
diagnostics: memory/issue-10-plan.md.
Anonymous/named inline definitions admit configured direct-text fragments; shared
Issue11 bare eligibility promotes complete copied island, other bodies retain
concat and reject known direct display roots. Empty inline note keeps concat("").
Strict malformed/cross-note/cross-object discovery errors consistent with public
API/export; ordinary paragraph stop behavior unchanged. Org governs delimiters,
no repair/general secondary support/new config/protocol/worker parsing changes.
Context recovery retains actual source-body interval for synthetic paragraph;
shared preparation and existing scope/reachability filtering preserve identities,
order, first-use/repeated refs and STM/file provenance. No source fallback; pure
lowering does not read source buffers or start a worker. Existing user flake excluded.

Final same-input focused46/46:93.714702s (inside full gate),real9/9:10.217289s,
core437/437:267.394606s; full600s command exit0,strictcompile/lint/all applicable
flake checks pass. Locked x86_64-linux only, other platforms not tested.7new ERT,
old exclusion migrated positive; all existing empty-note/Issue11/scopes preserved.
Initial causal red2expected failures0.295610s; final gate red2expected0.313889s,
not candidate failures. Empty-slot/context-shallow/docstring-width diagnostics
extracted. Final24other input hashes stable after README-only support audit and
final complete gate rerun.25baseline/25final/11extension identities checked;
independent patch reconstructs all5task files byte-exactly, source/root lock stable.

12necessary original-byte text artifacts archived/verified separately:
archive/2026-10-16T10-29-35Z--c31d3b1/MANIFEST.md.
No PDFs/binaries/dependency tree/full tmp/INBOX capture. Original acceptance and
archive had no inferred project parent because candidate was then uncommitted;
recorded baseline is exact red source/capture context. Current checkpoint grounds
actual committed delivery verification, not original runtime-test provenance.
Local Issue10 implementation/validation/user delivery complete. No version/lock/
INBOX/example/external writes. Remote#10 verified closed/completed on2026-10-16;
closure timestamp/source recorded in memory/evidence.md. Subsequent PDF link
repair is accepted above; fonts postponed,font-lock later.
v0.5.0 remains planned, not release-ready. No other implementation selected.

## Completed committed delivery: Issue11 bare STM paragraph repair

User-selected final revised plan implemented and locally accepted; contract,
context matrix, diagnostics and full evidence in memory/issue-11-implementation.md.
User committed one coherent fix(document): preserve native layout of standalone
STM fragments, Closes:#11. Parent is inspected Issue4 baseline; exactly document/
ERT/README changed. All25committed input hashes match final accepted manifest,
complete message equals approved tmp/commit.md draft. Index empty; user flake
mirror remains unstaged. Previous14focused/9real/430core acceptance transfers by
exact byte identity; no rerun needed. Association records this delivery verification,
not original runtime-test provenance. Remote#11 subsequently verified
closed/completed on2026-10-16; publication refs not checked.
Bare one registered
string island plus only other ordinary ASCII whitespace children/no Org objects
emits complete copied island. Mixed known direct display roots explicitly reject;
no automatic splitting. Leading list paragraph retains marker/concat and refuses
display roots. Body/quote/center/separate-note/later-list contexts verified.
Pure ownership/provenance, source state and unrelated mixed math maintained.

Final14/14focused79.974344s,9/9real12.125815s,430/430core296.145612s; full600s
flake exit0,strict compile/lint/all applicable checks pass. Locked x86_64-linux
Emacs31.1/Org9.8.10/TeXmacs2.1.5, other platforms omitted. Seven new ERT,7old bare
concat/path expectations migrated without relaxing original semantic assertions.
Structural55route pairs/native23same-root context fixtures and original issue
PDF/.tm-reload geometry compare; no cross-environment equality claim.
Final red2expected assertions2.374614s confirm old concat and80.16pt layout gap.
First full423/430seven stale expectations and intermediate fixture mistakes fully
extracted, not counted as accepted results. No production changes after first
focused7/7; final source/lock stable,25baseline/25final/11foreign hashes verified.

14necessary raw text artifacts separately captured/byte-verified:
archive/2026-10-16T07-46-35Z--8a90b4c/MANIFEST.md. No PDF/binary/dependency/full tmp.
Original acceptance/archive checkpoint had no inferred project parent because
candidate was then uncommitted; baseline identifies exact red-control source.
Current delivery verification grounds the newly inspected committed snapshot.
No INBOX/version/lock/example edits or external writes. Local Issue11 delivery is
complete; remote#11 verified closed/completed, as is#10.
Subsequent PDF link repair is accepted above; Chinese fonts later removed by user
as an external native issue. No new font work or release operation selected.

## Earlier v0.5.0 readiness investigation context

Historical initial scope below; current scope additionally requires Issue13 and
uses the revised Issue9 boundary in memory/special-block-plan.md.

User selected INBOX review/GAW extraction, then explicitly requested retrying
issue reads and local isolated investigation tests on2026-10-16. That initial
review/investigation phase made no business project-file edits; later Issue11
implementation was separately selected and completed above. Adopted readiness
scope: memory/release-0.5.0.md; broader release remains planned, not release-ready.
Initial baseline main@8a90b4c had empty index/only user flake.nix dirty.
P0: #10 anonymous/named inline-note STM with structural+native PDF regression;
#11 standalone block/paragraph equation discrepancy diagnosis/resolution with
mixed paragraphs and direct-PDF versus native .tm reload comparison; regression
of prior block mapping, exact original failure identity still to confirm.
Original P1 included PDF annotations, Chinese font consistency and bounded STM
font-lock; Chinese font gate is now explicitly removed by user after native
reproduction. Other fixes/configuration/deferral depend on their own evidence.
P2: representative combined real mathematical documents, locked-flake complete
ERT/native/PDF/strict compile/lint gate,0.5.0 version/docs/notes and migration.
#9 scheduled after0.5.0 before0.6.0; #7 stays deferred/nonblocking. Native footnote
placement/page breaks not blockers absent an actionable package regression.
Issue11 implementation now selected above; original isolated investigation is in
memory/release-0.5.0-investigation.md. Connector verifies#10/#11/#9/#7 open,
#4 closed/completed; all3scope comments read, no external writes. #10 reproduced:
inline note variants0islands/literal STM versus separate definition1/native math;
three discovery/preparation/lowering boundaries need coordinated repair.
#11 reproduced, native wrapper-only controls isolate concat effect independent
of trailing space; .tm reload removes wrapper and restores centered display/
right-margin numbering. No serialize/reparse production workaround selected.
Links absent in all4package/native/direct/reload PDF annotation controls; native
headless/config limitation needs further attribution. Chinese missing-font fallback
matches native control, not faithful reproduction of user's font inconsistency.
Org Scheme fontification applies to STM spans with text/tick unchanged; editing/
cleanup/performance integration unverified. Eight footnote boundary probes and
3structural/native ERT+1quotation/center PDF pass under locked offline flake.
At that initial investigation checkpoint,18source inputs equaled committed baseline,
root lock/source/INBOX were unchanged and only user flake mirror was dirty.
No full release gate was run in that phase. Native reload harness failures
corrected and explicitly excluded from acceptance. No ordinary staging/release/
external writes. 37necessary original-byte text artifacts archived and verified separately at
archive/2026-10-16T06-29-51Z--8a90b4c/MANIFEST.md; PDFs/binaries excluded.
Issue11 and Issue10 repairs are now implemented/validated/user-committed above;
subsequent PDF link consumer repair is locally accepted above;
P1 font/export configuration/edit-lifecycle gaps remain before release acceptance.

## Completed committed delivery: Issue4 remaining date repair and semantic audit

Final user-approved plan implemented and locally accepted. Four task files changed:
README.org, document/input modules, maintained ERT. Date timestamps preserve full
raw-value including delimiters/internal whitespace as literal text. Private helper
org-texmacs--document-date-timestamp-text(raw)->string defaults identity; captured
function per prepared input/conversion, owned arguments/results, invalid return/
malformed data error. No public formatter option, timestamp interpretation,
extra structured metadata or generic extension framework. Precedence/overrides/
suppression/rich text and other timestamp contexts unchanged.

Bounded audit of package-emitted tags complete, per-tag matrix and source/native
meaning/test links in memory/issue-4-closure.md. No additional production mapping
change justified. Added code/list/caption PDF native references and5level heading/
TOC/native-ref regression. Generic4/5number visibility intentionally false in native
style, counters/references correct; documented boundary. Fonts/footer placement/
PDF link annotations/pagination/#7/#9 remain excluded. Earlier quote repair and
closed #8 not redone. Dual storage and delimiter stripping were rejected/deferred
in favor of default raw and private caller advice.

Final locked x86_64-linux acceptance:423/423core229.047228s,37/37focused27.676927s,
9/9real12.003782s,native9date/6cases,strict compilation/lint/full flake exit0.
Eleven new maintained ERT replace one old rejection (+10net). Corrected red36:
27pass/9date-related failures23.868628s. Initial diagnostic/fixture failures and
limitations extracted in closure record; no fabricated unsafe-NUL failure claim.
25baseline/25candidate/11extension identities checked; candidate source/root lock
stable, user flake mirror untouched. User authorized sequential A/B staging and
messages, polling at most3minutes between deliveries. User committed A during
that wait; verified parent is quote/table baseline, exactly four changed paths,
all25date-input blobs and full Refs:#4 message match approved A draft.
B now user-committed and verified: parent=A, exactly README.org/tests/ert/ert.el,
all25committed input blobs match final accepted candidate identities, full
approved test(document)/Closes:#4 message unchanged. Ordinary index empty; only
user flake.nix remains unstaged. tmp/commit.md is historical B draft. Prior
423core/37focused/9real/full flake acceptance transfers by exact byte identity;
no new tests or ordinary agent commits; date-only subset has no separate fullgate.
Local implementation, review and both committed deliveries complete. Subsequent
connector read now confirms Issue4 closed/completed; publication refs not checked.
No external writes. Independent A/B patches reconstruct final candidate exactly.
No new archive needed: ordinary commits plus extracted memory and existing
immutable evidence suffice. Project association identifies exact inspected B
commit verification, not original uncommitted combined runtime-test provenance.

Selected34necessary original pure-text artifacts byte/digest/source-stability
verified in separate archive-only checkpoint:
archive/2026-10-15T13-12-14Z--8435e5d/MANIFEST.md.
No PDFs/binaries/whole tmp/dependency tree archive; seven specifically relevant
small pinned native definitions retained as semantic evidence. Remaining useful
facts extracted into current/project/evidence/backlog. No inferred external parent
for this uncommitted implementation/acceptance checkpoint.

## Completed implementation: Issue4 block subset + Issue8 table alignment

User-selected A+B implementation, documentation and validation complete, both
user-committed separately. A quote repair parent/three a-inputs blobs/Refs:#4
message verified; B parent=A, exactly three changed paths, all25final-inputs
blobs and Closes:#8 message equal approved draft verified. Ordinary index empty;
only existing user flake.nix mirror remains unstaged. No new source/test changes.
Current tmp/commit.md is historical B draft, not a new pending staged message.

At the earlier quote/table checkpoint GitHub confirmed Issue8 closed/completed
and Issue4 open; current Issue4 closure is verified above. Scope comment:
https://github.com/ren-lingyu/org-texmacs/issues/4#issuecomment-6191090701
supersedes earlier table-alignment proposal: completed #8 must not be implemented
or counted again under #4. Existing table/caption semantics remain auditable;
dates/other supported tag audit and deferred NAME boundary unchanged. Comment
previously mentioned quote mismatch as outstanding, but user authorized a followup
comment clarifying A already fixes it. Posted and re-fetched verified comment:
https://github.com/ren-lingyu/org-texmacs/issues/4#issuecomment-6191193468
Quote and #8 alignment are complete; date/remaining native audit stays open.

Quote uniformly lowers to native quotation(document...), including named footnotes;
center/code/list mappings retained after bounded native comparison. Tables permit
zero or ONE complete plain<l>/<c>/<r> row anywhere; reject duplicates/partial/mixed/
width declarations, preserve existing special-column/formula/group restrictions.
Remove format before data/border numbering. Linear identity exclusion constructs
an independent filtered AST view; prepared AST/source/provenance remain unchanged.
No public API, metadata/date, NAME or file policy change. Seven new maintained tests.

Final locked Emacs31.1/Org9.8.10/TeXmacs2.1.5 x86_64-linux flake acceptance:
23/23focused13.694420s;413/413core212.650622s;9/9real11.469430s; native10records;
strict compilation and lint; fullcheck exits0. Other systems explicitly omitted.
PDF layout checks compare native references within1pt; no arbitrary-style/GUI claim.
Initial full412/413 exposed one stale named-footnote quote expectation, corrected
as part of A; final focused/full validate this and the linear filtering revision.
25baseline/25final/11extension identities verified; root lock and sources stable.

Contract/method/diagnostic limits: memory/block-table-implementation.md. Necessary
23raw text artifacts byte-verified in separate archive-only GAW checkpoint:
archive/2026-10-15T11-15-33Z--4839029/MANIFEST.md.
No binary PDFs/dependencies/full tmp archived. Remaining useful material extracted
into current/project/evidence/backlog; no archive of INBOX needed. Original
combined validation candidate was uncommitted; archive has no inferred
project parent. The preceding commit-verification checkpoint associates verified B,
whose25accepted input blobs now match combined tested candidate. This is commit
verification, not a new runtime test or retrospective source-provenance claim.
Next: if user selects further #4 work,
plan date metadata and bounded native emitted-tag audit without duplicating #8
or completed quotation repair. That earlier tracking phase selected no further implementation; active work above
now supersedes it.
No new archive: public issue/comment history and extracted memory suffice for
tracking-only update; existing immutable raw validation archive stays unchanged.


## Current state: large byte-step no-INCLUDE measurement complete

User now considers investigation sufficient and explicitly accepts the observed
blocking as a basic motivation for developing parallel/nonblocking export. This
adopts the motivation, not a specific implementation or immediate code work.
Near-linear observed scaling does not remove long command blocking. Nonblocking
editing and concurrent native conversions remain separate design goals; neither
parallel worker count nor threads/callbacks/child-process route chosen. No further
measurement required merely to establish the accepted motivation.

User requested a conventional GitHub issue. Created and verified open Issue #7,
"Support nonblocking Org-to-TeXmacs exports":
https://github.com/ren-lingyu/org-texmacs/issues/7.
English proposal follows recent repository issue style; prior issues1–6 inspected,
no duplicate found in those results. Includes measured motivation with standard/
explicit API and failure distinctions, optional frontend nonblocking behavior,
snapshot/stale-result/ownership/worker coordination, cancellation and regression
criteria, relates1/3/6. Parallel worker degree and implementation route unresolved;
size/timeout increases outside initial scope. Issue text is a feature proposal,
not a finalized implementation contract or instruction to start business edits.
No further raw archive needed: public issue plus extracted current tracking state
and existing measurement archive preserve useful evidence. Local tmp draft is not
authoritative tracking. No new benchmark or project/index edit for issue creation.

User selected larger bytes after finding prior~50KiB matrix insufficient. Four
sequential authorized600s independent flake builds complete, no system Emacs or
business edits.16outcomes:10native successes/4standard budget rejections/2native
worker errors; every source-state check passes. One live-worker sample per cell,
not medians. Source64155/256515/1025955/4103715bytes,1811/7241/28961/115841lines.
Explicit tm/PDF1.828/2.172s,6.986/7.998s,29.329/30.852s,then fail118.046/115.652s.
Last pair completes1920STM requests (~101/99s wait), final serialize/render waits
reach~10.001s before generic worker exited-or-timed-out error. Default10s timeout
unchanged; no separate native exit/deadline tracing or longer-timeout rerun.
Standard full frontend succeeds first two sizes and rejects larger at256KiB budget.
Worker waits dominate but Emacs phases grow to seconds; GC now present,~0.27–0.29s
at largest. Same math density grows request count; not pure text-size causation.

Full extraction/method/commands/limits: memory/large-document-timing.md.20unique
text artifacts byte-verified in separate archive checkpoint at
archive/2026-10-15T08-21-16Z--4839029/MANIFEST.md. Single source-script trailing
blank retained/documented.17package/lock inputs equal associated project revision;
original6447byte example unchanged. Root flake mirror untouched, ordinary index
empty. Fixed frontend-then-explicit order and render caches confound API speed
comparison. No successful4MiB export claim or all-exports-pass claim.

Selected measurement task complete; no timeout/production limit change, async
implementation or followup test selected. Next if user selects development:
define job/return/cancellation/stale-result/ownership/serialization contracts and
choose route, using existing feasibility and timing evidence. Further poll/wakeup,
large-response or prose/island profiling is optional targeted work, not a required
prerequisite for accepted motivation. Earlier small matrix remains scoped below.

## Completed smaller export timing matrix

User selected multiple sizes x INCLUDE/no-INCLUDE, existing realworld math only,
independent flake and no business-code changes.96/96 real native exports pass in
four sequential authorized targets (3samples per cell, cold/warm, tm/PDF).
User clarifies "卡手" means perceptible blocking after invoking export. Warm direct
medians tm0.217/0.440/0.770/1.521s, PDF0.476/0.642/1.070/1.830s at1/2/4/8x.
Single INCLUDE adds little; warm wait paths account89.8–95.8%, no measured GC.
3/6/12/24STM requests at~50ms each and separate worker/client wait target suggest
investigating poll/wakeup granularity before choosing optimization. Not proven
removable overhead or native CPU time. Cold worker startup~0.93–1.01s plus initial
PDF render costs. Batch wall time quantifies command blocking; no direct key/input
latency trace or precise reproduction of user's interactive configuration.

Full operational extraction: memory/export-timing-results.md.20necessary unique
text artifacts archived and byte-verified separately at
archive/2026-10-15T07-59-37Z--4839029/MANIFEST.md. Original CSV CRLF and one final
blank retained/documented. Package17inputs match actual associated project commit;
user root flake mirror untouched/index empty. Original math unchanged; current
INCLUDE gained extra final newline during measurements, all groups consistently
use frozen22byte original. No agent writes to original examples.

No business-code/async prototype or implementation selected. Next if user selects:
isolate small-request wakeup/transport/native cost, then decide reducing synchronous
latency versus allowing editing during export. Existing static feasibility options
remain unadopted. Existing matrix is complete but user now questions insufficient
scale: max~50KiB/~1450lines does not cover10k-line or MiB documents. Verified
standard full-document frontend always uses bounded preprocessing, even without
INCLUDE: root/captured/final256KiB; each included file64KiB (README1456–1461,
preprocess compose171). MiB standard full export currently rejects before native
conversion. Larger INCLUDE matched cases must split inputs below64KiB and stay
within total256KiB. Direct explicit-source API measurement could study conversion
core beyond that boundary but cannot represent standard INCLUDE/frontend behavior.
This initial coverage observation did not itself select new bounds or commands.
User subsequently selected and separately authorized large no-INCLUDE measurements
above, distinguishing standard rejections from explicit-API conversion. No bounds
or default request timeout were changed.

## Completed static nonblocking export investigation

User selected read-only feasibility investigation of nonblocking export and GAW
recording, explicitly no business-code changes. Static investigation complete:
memory/nonblocking-export-investigation.md. Feasible; prototype relatively small,
production compatibility medium to high effort. Existing external native worker
is called synchronously; CPU parsing/lowering also stays in Emacs. Cooperative
thread could preserve much stack/configuration for I/O-dominated work, but dynamic
worker-busy is thread-local and shared worker serialization/callback audit needed.
Callback jobs require resumable transaction state; child Emacs isolates CPU but
needs explicit context/function/environment portability and parent-side guards.
Static phase selected no route or prototype and needed no raw archive. Subsequent
separately authorized batch measurements above supersede its no-profiling state;
see memory/export-timing-results.md. Only user flake mirror dirty, index empty.
Editor input tracing remains unperformed; user clarified primary symptom is
perceptible synchronous command blocking, quantified by this batch matrix.

## Completed Issue #6

Issue6 implementation, automated and user interactive acceptance complete,
user committed. Read-only verification confirms the three committed blobs and
complete binary diff equal the accepted staged/tested candidate and archive patch.
User selected lifetime-only repair and continuous GAW maintenance; authorized
repeated120s focused build/240s full check under tmp/issue-6-cleanup with necessary
locked-dependency network/store/cache/logs, no root lock edits. Exactly the two
production modules and maintained ERT were staged with approval and committed by
user. No INBOX/version/external issue write selected. User flake mirror untouched.

Three private lifetimes (root composition, INCLUDE capture, bibliography discovery)
now use object-captured unwind-protect to retire only own file identity at final
exit. Four maintained kill-entry regressions fail before/pass after repair; preserve
processing file/directory context, original errors, source/user buffers and output
failure policy even when callbacks switch current buffers. Error matrix12cases.

Interactive user confirms no-INCLUDE no-popup, but reported INCLUDE configuration
error; supplied two realworld Org files with large native snake-lemma STM graphics.
Exact clean preparation passed, then source-local with-toc=nil reproduced the same
error. Bibliography configuration guard read current native INCLUDE private buffer,
not captured source. Guard now source-anchored without removing conditions; fifth
maintained regression proves true source config mutation still rejects even from
an unchanged private context. Actual user's precise locals remain uninspected.

Revised focused6/6 pass8.088419s:5maintained plus realworld native probe. Two exact
user files x discovery nil/t x tm/PDF =8native outputs, preserved source, probe
5.279271s. Revised exact240s full gate exits0:406/406core ERT207.962999s,
9/9actual pinned extension fixtures11.519498s, strict byte/native compile/lint and
all checks pass.25project+11foreign inputs byte-match before/after; root lock and
original user fixtures unchanged. Locked Emacs31.1/Org9.8.10/TeXmacs2.1.5/
x86_64-linux only; user now confirms revised interactive retry meets expectations.
This is user-reported acceptance, not an independently traced GUI result.
Prior405core gate describes previous candidate only.

Nine necessary text artifacts selectively archived/verified at
archive/2026-10-15T07-24-27Z--55a9921/MANIFEST.md: exact inputs/native probe/log,
harness/lock/manifests/candidate patch. No candidate project parent inferred.
Original patch/log whitespace retained; archive verification control-flow mistake
and supplemental successful byte verification documented in evidence.md. Archive
immutable; operational findings/commands/hashes/limits extracted to memory.

Three committed blobs and complete binary diff equal accepted snapshot and archived
candidate; full staged review/whitespace check passed. Complete committed message
matches reviewed tmp/commit.md, with
fix(export) subject, three Chinese bullets and parsed Closes: #6; one coherent
commit, no breaking API change. No new tests solely for unchanged-byte staging.
This checkpoint associates the actual inspected committed revision; no new tests
solely for unchanged-byte commit verification. Ordinary index empty, only existing
flake mirror unstaged; no source fixture edits or tmp cleanup. No further Issue6
implementation selected. Remote publication/issue state unverified. Completed
tmp/commit.md is preparation only, not current commit authority.

After Issue6 staging/message preparation, separately recorded user's slight
"卡手" feeling during "非并行导出" as a deferred responsiveness observation in
memory/backlog.md. No measured regression/cause or async/parallel remedy adopted;
no performance investigation/code/test authorization. It does not block accepted
Issue6 fix or enter its committed diff/message. It remains separately deferred;
recording the observation did not select performance implementation.

## Earlier Issue #6 review (superseded by implementation selection above)

User requested read-only review of updated INBOX Issue6 temporary-buffer prompts,
on the accepted case-insensitive wrapper revision. No implementation, INBOX edits,
runtime probes/tests or external writes selected. INBOX is8020bytes; source SHA256
and complete operational extraction/review in memory/temp-buffer-cleanup-review.md.
Main/index unchanged, only existing flake.nix mirror dirty. Review accepts narrow
owned-buffer lifetime repair, preserving file context through callbacks and error
semantics, but requires batch-aware regression design: C INTERACTIVE is an
environment condition, not called-interactively-p. --batch skips this confirmation,
so stubbing yes-or-no-p alone is insufficient. Require a positive pre-fix control
and scoped confirmation-path exercise. Also cover INCLUDE capture's independent
file-bearing temp buffer even for a non-file root, plus bibliography callback.
Exact runtime target/stack still untraced; no reproduced-failure claim. No raw
archive: active proposal without unique experiments, sufficient content distilled.
Next: present review findings; implementation/testing require user selection.
Host GAW binding changed to0.7.0 during review; public status and check at the
actual .agents worktree pass. Completed Issue5 state follows.

## Completed Issue #5

User selected implementing case-insensitive Org TeXmacs wrapper names and GAW
updates, associated issue5: https://github.com/ren-lingyu/org-texmacs/issues/5.
Public page fetch failed; no remote issue content/state claim or external write.
Separately authorized repeated120s focused Nix build and240s complete flake check
under tmp/block-case, necessary locked-dependency network/store/cache/logs, no
root lock edit. Four task files changed: source predicate validates string then
downcases only its comparison; fragment ancestor exclusion reuses it with explicit
source-module require; README explains wrapper versus native/fragment tag case;
five new maintained ERT plus malformed-type rejection cases. Coverage includes
162 BEGIN/END/name/ambient-case combinations, original AST/body preservation,
nested fragment exclusion, native bytes, root/included preprocessing protection
and bibliography masking. Focused114/114 passes48.641846s; actual locked Org9.8.10
confirms preserved original :type and case-insensitive opening/closing markers.
Latest real extension fixtures9/9 pass11.781628s. Exact240s full gate exits0:
401/401core ERT204.454363s, all6logged checks/strict compilation/package-lint pass.
Selected request implementation/acceptance complete and user committed, no failures.
25project+11unchanged pinned fixture modules isolated; user flake mirror untouched.
Final25project+11foreign inputs byte-match isolated snapshot before/after gate;
four committed task blobs equal the accepted manifest/worktree. Complete committed
diff equals the reviewed staged candidate; ordinary index empty, only existing
user flake mirror remains unstaged.
No root lock/INBOX/version change. Validation is locked Emacs31.1/Org9.8.10/
TeXmacs2.1.5/x86_64-linux, not other systems or full minimum9.8 behavior.
Archive assessment: maintained regression tests preserve all new reproduction,
no ad hoc probe/retired source/unique raw evidence; no raw archive selected.
Results/commands/hashes/limits extracted in memory/evidence.md, model/backlog
synchronized. User authorized staging and commit-message preparation; full staged
review and whitespace check pass. tmp/commit.md now describes this fix with
fix(source) subject, Chinese body and Closes: #5. User explicitly clarified
closure intent for the accepted fix; this does not establish remote issue state.
User commit and its full message now verified; this checkpoint associates the
actual inspected project revision. Existing acceptance transfers by byte identity,
no new tests solely for commit verification. No further implementation selected;
remote push/issue state unverified and no external write performed. Completed
tmp/commit.md is preparation only, not current commit authority. Earlier diagnosis follows.

Initial read-only report: begin_texmacs and BEGIN_texmacs work while
begin_TEXMACS/BEGIN_TEXMACS reportedly fail. Static inspection
finds exact :type comparison to "texmacs" in org-texmacs--block-p
(org-texmacs-source.el) and separate fragment ancestor exclusion
(org-texmacs-fragment.el). Shared predicate also controls source extraction,
pure island validation, selected-region/dependency discovery, preprocessing STM
shielding and bibliography masking; these need consistent recognition. Org's
published Emacs31.1 special-block parser binds case-fold-search t, captures raw
type spelling and stores it unchanged in :type. Official source:
https://raw.githubusercontent.com/emacs-mirror/emacs/emacs-31.1/lisp/org/org-element.el.
Direct release_9.8 source fetch failed; initial diagnosis had no runtime probe.
Conclusion: lowercase-only wrapper name is a local recognition restriction, not
a necessary worker/AST-first/TeXmacs constraint. A bounded change can compare
wrapper type case-insensitively (validate string before downcase) and synchronize
ancestor exclusion; do not modify original Org AST/body/source or native tag case.
Inline STM fragment tag names remain intentionally literal/case-sensitive.
If centralizing ancestor test on the shared predicate, make the fragment module's
source-module dependency explicit rather than relying on main load order.
The diagnosis is now selected for implementation/testing as described above.
No unique raw evidence to archive; necessary findings are extracted here. Previous issue3
implementation/acceptance below remains complete and committed.

## Completed Issue #3

User now selected implementation of issue3 against memory/export-api-contract.md.
Authorized project API/lifecycle/documentation/maintained-test edits. Separately
authorized repeated120s isolated focused/integration Nix builds and240s complete
flake checks under tmp/issue-3-api, necessary locked-dependency network/store/cache
writes, no root lock changes. Existing user flake mirror was untouched during
implementation; current ordinary index is empty with only user flake.nix dirty.
Selected implementation/acceptance complete and user committed:
three standard Org interactive frontend commands, five explicit noninteractive
source APIs, exact renames without aliases, original file/conversion/menu policy.
Managed result has identity token/name/tick/state checks; user takeover creates
new result. Atomic change group rolls back content failure; explicit undo reset
and refreshed tick preserve reuse after rollback. Display failure keeps committed
reused results but cleans new allocations; explicit buffers remain fresh/caller-owned.
README and ERT/actual integration call sites synchronized;10new maintained tests.
Corrected focused110/110 passes83.751063s. Exact240s isolated complete gate exits0:
396core ERT199.315532s,9real fixtures11.658110s, all6logged flake checks and
strict module compilation/package-lint pass.25project+11foreign inputs verified
byte-identical before/after gate. Initial sandbox socket/compiler/test failures
and fixes are distilled in evidence; no pending failure. Locked Emacs31.1/
Org9.8.10/TeXmacs2.1.5/x86_64-linux only; other systems/GUI/current9.8 full
behavior unverified. No raw archive selected: maintained reproduction tests and
extracted evidence suffice, no unique transient probe or retired document.
User committed exactly README.org/org-texmacs.el/ox-texmacs.el/
tests/ert/ert.el/tests/integration/phase4.el as the export API and managed-result
revision on the verified investigation baseline. Current main's complete committed
binary diff matches reviewed staged SHA256
756b192be25990ffdc68edcee2816cabe2fa47c3ff25dbbe0561ebbd653fe0b4;
five committed blobs match accepted manifest/worktree. Complete message has
feat(export)! subject, four Chinese bullets, BREAKING-CHANGE and Closes: #3
trailers, parser verified. User reviewed the selected scope as sufficient to close
issue3 and explicitly intends closure. No remote push/issue-status lookup or
external write performed. This checkpoint's project parent is the actual main
revision inspected; prior acceptance transfers by byte identity, no new tests
solely for commit verification. Root lock/INBOX/version unchanged.
Ordinary index empty; only user flake.nix modification present. No ordinary
project state changed by this memory work. No further implementation/release/
test work selected. Completed tmp/commit.md is preparation only, not current
commit authority; preserve it without regeneration.

User also asked whether documents/comments are synchronized. Scoped read-only
audit against committed HEAD checked README API/use/migration/lifecycle/
file-policy sections, main/frontend public docstrings and related module stale
symbol references. No affected stale description found; old names remain in
explicit migration guidance, special entry names intentionally unchanged.
No product edits/tests or raw archive needed for this verification.

Earlier user requested GAW recovery then read-only review of the newly supplied INBOX
issue3 export API/lifecycle plan. GAW status/check pass, memory worktree clean
at recovery. Project HEAD exactly matches the plan's investigation baseline
92476aa073238d1bc38809d4300985c5a444572c; ordinary index empty, only flake.nix
has the existing user modification. INBOX is now9457bytes, superseding the
Phase6 working proposal; completed Phase6 contracts remain current capability.
That review did not select implementation, INBOX edits, tests or external writes.

Review finds the proposed three frontend/five explicit-source APIs compatible
with AST-first ownership and existing direct/full-preprocessing routes. Preserve
explicit file signatures/new-file creation, frontend naming/overwrite policy,
special bibliography/preprocessing entry points, menu opt-in and generic guard.
User subsequently adopted explicit issue3 implementation contracts, resolving
the review's lifecycle/conflict/module questions. These decisions govern future
implementation without choosing its mechanism or authorizing code/test work:
- Fully generate/check new bytes before replacing a managed frontend result.
  Conversion or content-commit failure preserves the previous result without
  partial updates. After successful content commit, display failure does not
  roll back content or destroy a reused buffer. On first creation, display
  failure cleans up only the newly allocated result.
- Reuse only frontend-owned buffers, never ownership inferred from names.
  Default name is *Org TeXmacs Export*; if occupied by another buffer, allocate
  a unique alternative and stably reuse it. After kill, recreate on next export.
  User rename, modification or takeover relinquishes automatic overwrite;
  preserve that buffer and create a new result next time. Explicit-source
  results never enter frontend management and remain caller-owned. No dedicated
  cleanup command. Ownership detection and transactional update mechanism are
  implementation choices, constrained by these observable outcomes.
- org-texmacs-export-to-pdf-file is a noninteractive explicit-source function
  defined in org-texmacs.el; org-texmacs-export-to-pdf is an interactive standard
  command defined in ox-texmacs.el. Use independent Emacs processes to verify
  main-module and frontend loading, function ownership, signatures and commandp.
  For reused old names verify new semantics rather than symbol absence; update
  existing module-ownership assertions and provide no compatibility aliases.
  Three retired names should have no definitions/aliases in a fresh process;
  preserved special entry names remain valid. Other API/file/conversion policy
  from INBOX remains unchanged.

Complete current design extraction is in memory/export-api-contract.md: original
INBOX API/signatures/mapping/file/conversion/scope/acceptance plus user supplemental
contracts. User explicitly requested skill-based archive selection and sufficient
extraction when not archiving. Applied global archive guidance and project archive
skill: no raw capture warranted for this active plan/design exchange without unique
experimental evidence or retiring source. Operational information is retained in
the contract, independently of INBOX/chat. Reassess at retirement or upon new
independently valuable evidence. No byte-exact original capture is claimed.

Prior review's unconditional frontend cleanup, main-module PDF ownership and
interactive-only test concerns are addressed in the accepted candidate above.
Initial public issue3/manual/Org fetches failed. Later GNU Emacs Command Modes
documentation supports the mode declaration; actual fresh compiled processes
verify interactive nil plus command-modes(org-mode), signatures and ownership.
Remote issue3 state and upstream Org comparison remain unverified.
Implementation and fresh task-specific tests are now selected as above; the
prior design-only authority limit is superseded by those user authorizations.
No INBOX edits or external issue update requested or performed.

## Previous completed work

User replaced cleared INBOX with new Phase6 explicit Org dispatcher menu plan
associated issue2, reviewed then user now requested execution. Task authorized120s
isolated probes/focused/integration and repeated240s full checks/network/store/cache
under tmp/issue-2-phase-6, no root lock edits.6a five native probes pass1.021877s;
selected contract memory/export-menu-contract.md.6b minimal menu option/validation
and registration implemented,6c five maintained ERT/fresh batch loading plus
native dispatcher,6d README migration updated. Final240s gate exits0:386core
ERT175.465056s,84focused56.135881s,9real extension fixtures10.962176s,
5native probes1.021619s, all10checks/strict compilation/package-lint pass.
25project inputs+11copied foreign modules match isolated snapshot before/after gate.
Reviewed suitable on committed Phase5
baseline; findings memory/export-menu-plan-review.md. Proposal separates backend,
optional nil-default complete key config and unchanged export commands/guard.
6a established per-level conflicts/native nil menus and genuine first-load
tests. Validate/own configuration before registration; Custom
must not imply live refresh. Config global nil-default complete four-field plist;
disjoint shared-prefix/Unicode actions supported, reserved/colliding keys refused.
No runtime refresh/consumer changes. Selected6a-6d acceptance complete and user
committed. Three committed paths README.org/ox-texmacs.el/tests/ert/ert.el and
blobs match accepted manifest/worktree/isolation; parent is verified Phase5 baseline.
Full message matches tmp/commit.md: feat(export)! subject, adjacent BREAKING-CHANGE:
and Closes: #2 trailers. Index empty, only user mirror remains unstaged/root lock
unchanged. Prior gates transfer by byte identity, no new tests solely for commit
verification. No further implementation selected or external issue write performed.
Remote issue2 status unverified. Preserve completed draft/user wording.
User requested audit then authorized documentation/comment/dependency corrections.
README five stale descriptions corrected: locked Org9.8.10 baseline, seven core
plus two frontend options, actual pinned Org-roam/extension fixtures and independent
existing file/export consumers. Cross-links retain bounded fixture claims. Requirements
now distinguish declared minimum, locked development baseline and optional test deps.
Frontend/main module commentary clarifies nil-default/pre-load menu and dependency
scope. Package-Requires Emacs31.1/Org9.8 and flake runtime wiring retained: no new
runtime dependency or proven need to bump minimum; full minimum-version behavior
untested, API/signature checks passed as detailed below.
Version0.4.0 unchanged, release not selected. Exactly README.org/org-texmacs.el/
ox-texmacs.el doc/comment corrections user committed; user flake mirror untouched. Diff whitespace and
heading link targets inspected; no executable changes. Subsequent authorized
minimum-version checks are recorded below.
User committed documentation revision. Exact three-file committed binary diff
matches reviewed staged SHA2562db2062b...; blobs match worktree, parent verified
Phase6 commit. Complete message equals tmp/commit.md: docs(package) subject and
Refs: #1, #2 trailer, no new breaking/closing footer. Index empty, only user mirror
dirty. No new tests solely for commit verification or further work selected.
User questioned minimum Org API compatibility; historical setup commit81e06ca
raised9.5 to9.8 for cache/store/get/create checks. Earlier retention conclusion
was insufficiently evidenced. User requested isolated independent-flake audit and
authorized necessary network/checks. Completed tmp/org-minimum-api, copied pinned
nixpkgs node and13 project modules; Org release_9.8 locked to
89df5bf46ba214db44eea898cc7cacc0b27fd760. Static54 direct-call signatures have0
arity conflicts/4 generated unresolved; actual Emacs31.1+Org9.8 resolves all54,
checks41 function references and87 declared capabilities, missing/conflicts nil.
All interfaces/reference definitions come from isolated9.8 source;13 production
modules strict-compile pass. Final120s runtime98 build exits0/no warnings. Only
Org version/autoload metadata generated, upstream Lisp unchanged. Earlier quote
and autoload-loader harness problems corrected, not production incompatibilities.
No API existence/signature evidence demands minimum above9.8; full9.8 behavioral
compatibility still unverified, full ERT/native baseline remains9.8.10. Dependency
values unchanged. Root project/lock/mirror untouched by checks; docs/comment edits
from prior authorized task now committed. No new full regression selected.
Nine necessary original-byte artifacts archived and verified separately:
archive/2026-10-14T14-04-21Z--611cb70/MANIFEST.md. Archived patch retains four
blank context spaces reported by diff --check. Auto-review rejected adding that
note to captured manifest; explanation recorded here, archive left unchanged.
Under prior authorized doc corrections, README/main commentary now distinguish
successful9.8 API/signature/compile check from unperformed9.8 full behavior
regression. Post-audit prose only; archived manifest preserves exact tested earlier
comment bytes. No code or declared dependency values changed.
User asked whether temporary-test archival was assessed. Selection confirmed:
native menu/registry/shared-prefix/control-key probes have independent value,
Eight original-byte artifacts archived and verified in an archive-only checkpoint:
archive/2026-10-14T13-19-02Z--5f4c9c0/MANIFEST.md. Probe script/log, reports,
isolated flake/lock and two input manifests retained. Duplicate maintained ERT
logs/build products/caches/DB/PDF/full foreign checkouts not selected.
Ordinary INBOX now9100bytes; prior archived issue1 original remains immutable.

User authorized retiring current INBOX after coverage audit: original90229byte
sections1-18 captured byte-exactly and archive-only checkpoint verified at
archive/2026-10-14T12-48-06Z--5f4c9c0/MANIFEST.md, original SHA25683b74498... in
evidence. After successful checkpoint, original/source checked against committed
archive again and ordinary ignored INBOX.md truncated to0bytes, file retained.
Archived bytes unchanged. Operational goals/contracts/decisions/validation/commits
remain current memory/history authority. Explicit configuration/no default menu
keys/documentation examples policy is in backlog. No further work selected.
Archived older pending/current labels and superseded origins do not override
implemented contracts; captured current document cannot recover overwritten drafts.

User now requested execution of INBOX section18 Phase5 on committed Phase4 baseline.
User authorized120s isolated probes/focused/integration and repeated240s full check
under tmp/issue-1-phase-5, necessary network/store/cache/logs; no lock edits.
Initial isolated evaluation failed missing copied worker.scm, repaired input list
and reran same authorized probe command; no production edits before5a acceptance.
Reviewed suitable, with transaction lifetime,
existing guard coverage, changed full-buffer provider support profile and independent
discovery entry/scope clarified in memory/frontend-preprocessing-plan-review.md.
5a four locked probes pass3.144554s; contract selected in
memory/frontend-preprocessing-contract.md.5b/5c minimum frontend routing implemented:
shared byte-buffer helper, independent discovery option, original consumer callback
transaction. Eight new core ERT;79focused54.728771s pass, includes all local
discovery byte/file/PDF+overrides.5d nine actual extension fixtures10.629183s pass:
two new frontend cases and joint HTML/blog retarget, PDF NFKC semantic inspection.
No provider weakening. Exact240s full gate exits0:381core ERT178.555109s,
all10checks/strictcompile/package-lint;79focused57.349582s,9real11.487037s and
4probes3.585992s in full rerun pass.25project inputs and11copied foreign modules
match manifests;740964a9... final project manifest. Lock/mirror unchanged.
Selected5a-5d accepted. Necessary9text evidence archived immutably:
archive/2026-10-14T07-51-02Z--6f018de/MANIFEST.md; no inferred candidate project parent.
Context additionally rejects unresolved ROAM_INCLUDE keyword and subtree mount;
prevents dropped selected-root mount metadata without special converter or DB query.
No INBOX edits selected. Explicit source-buffer-local frontend discovery boolean
org-texmacs-export-discover-bibliography defaults nil, applies full and local.
PDF/native serialization remain inside provider transaction; no fallback/guard
removal. Seven project files changed: README.org, ox-texmacs.el, org-texmacs.el,
org-texmacs-context.el, tests/ert/ert.el and both tests/integration files.
User committed Phase5 as the full frontend preprocessing revision. Complete binary
committed diff equals staged SHA25668f76e19...; all seven committed blobs match
accepted final-inputs.json. Full message matches current user-edited tmp/commit.md:
feat(export)! subject, halfwidth punctuation, BREAKING CHANGE footer, blank line
then Closes: #1 trailer. Git trailer parser recognizes Closes: #1. Preserve user's
message edits; no commit rewrite or message regeneration. Prior gates transfer by
byte identity; no new tests solely for commit verification. Index empty, only user
mirror dirty. Selected local INBOX#1 architecture/frontend acceptance complete;
not generic export/resource parity. Live issue page lookup failed; no current remote
state/content claim or external tracking write.

Rewritten INBOX section17 Phase4a-4d implemented, accepted and user committed
on native parameter baseline1a254a7. User prioritizes completed working buffer +
effective supported Org context, not source-origin recovery or third-party read/DB
interception. Existing explicit preparation already consumes completed working Org;
optional native preprocessing remains provider with own fixed reads/receipts.
Contract: memory/working-buffer-context-contract.md. Local source interfaces now
actually exercised: include ca62c8f, organize eaaee8e, blog778d410, pinned Org-roam
20260425.1623/Emacs31.1/Org9.8.10/TeXmacs2.1.5, x86_64-linux only.

Six native probes pass0.113537s (final0.120499s): actual copy retains file/default-dir/
local with-toc; nested link/notes relocation, final raw bibliography/STM semantics.
Production drops two included-directory checks and uses each captured file directory
for its private parser, preserving root final resource context. Root file/default-dir
agreement, full-root/ordinary levels, local UTF8/aliases/budgets/cycles/STM shielding/
partial rejection/source/helper/hook/native-return and receipts preserved. No full
native lifecycle/macros/Babel/generic exporter/pure I/O or resource-origin map.

Five new core cases and32/32 focused17.537532s pass; actual completed working buffer
context/ownership/no replay, nested link/note/native bytes, root bib declaration and
STM image block/context+existing PDF refusal. Relative STM/bibliography use final
context, standalone/INCLUDE may intentionally differ; actual resource loading/
rendering and relative native-output consumer policy remain separate.

Seven actual extension fixtures pass8.708412s: real SQLite sync/node/queries/global
modes/hooks/advice, include recursion/parameter forwarding/file mount/cycle/missing
node and cleanup; organize managed paths/UUID:key/native bibliography/missing refs;
joint TeXmacs/standard HTML before-after and actual blog publication/content, mode
teardown/interface restoration. No package-specific converter/query/node/read mocks.
Optional tests/integration runner supplied explicit pinned Elisp/runtime sources;
default core dependencies unchanged, no personal DB/foreign repo edits.

Final exact240s isolated flake check passes373/373 core ERT189.379261s, all10 logged
checks/strict compilation/package-lint. User authorized task120s probes/focused/
integration and repeated240s full checks in tmp/issue-1-phase-4, network/store/cache/
logs, no lock edits.25project and11foreign-module inputs byte-match snapshots;
manifest hashes/provenance in evidence. Immutable necessary9text archive:
archive/2026-10-14T06-28-22Z--1a254a7/MANIFEST.md. No inferred project parent.

Five project changes README.org/preprocess module/ERT/optional integration runner
and fixtures user committed as the cross-directory INCLUDE/real extension coverage
revision. Complete committed diff equals reviewed staged SHA2566eb3e3d0...;
all five committed blobs match accepted final-inputs manifest. Full commit message
matches tmp/commit.md, feat(document) subject, Refs #1, no new breaking footer.
Index empty; user mirror remains the only dirty path, lock unchanged. Prior gates
transfer by byte identity; no new test or external tracking write.
Phase5 is now implemented and accepted as above. Latest section17 selected
acceptance complete; original proposal's formal frontend/default dispatcher policy
was not selected here and remains separate. Do not automatically close#1/external
tracking based solely on historical Phase4 state: Phase5 now completes selected
formal frontend switching. No resource work selected.

Phase2c native preprocessing simplification implemented, accepted and user-committed
on Phase2b baseline; exact commit diff/message verified on 2026-10-14.
User requested INBOX correction,
GAW and execution; old15 explicitly superseded, new16 current. Nine locked native
probes selected scoped fixed reads and line-preserving STM shielding; Org owns
location/only-contents/lines/minlevel and headline/footnote/link transformations.
No general original-coordinate or occurrence-map prerequisite.27/27 focused
13.482343s; complete368/368 installed ERT209.352130s; all five current x86_64-linux
flake checks, strict compilation/package-lint pass. Other platforms/GUI/real
packages unverified. User authorized120s probes/focused and repeated240s full check
under tmp/issue-1-phase-2c, necessary network/store/cache/logs, no lock edits.

Updated production files: org-texmacs-preprocess.el, tests/ert/ert.el, README.org.
Public prepare/document/.tm-byte signatures unchanged; optional explicit Cite
boolean retained. Native helper bindings scoped/unwound, actual source paths and
fixed copy-returning reads, lazy selected dependencies, native recursion/error
policy. Partial existing supported STM rejects; source/config/hooks/helper identities/
receipt checks through acquisition, hooks, native operations and final return.
Full-root/ordinary-level/common-base,64KiB files/depth8/32 expansions/256KiB captured
original+final budgets. Native SETUPFILE/BIND/macros/Babel/full annotation/generic
export/wrappers remain absent; no callback sandbox/atomic FS/DB/ABA claim.

INFO owns original/final text and captured path/texts; adapter no longer promises
exact original ranges, occurrence IDs, generic AST/node/island origin annotations.
README/API docs/maintained assertions updated explicitly. Existing pure input slot,
worker/native consumer and Phase1/Phase3 transaction contracts retained. New9 ERT
cover parameters, retained/partial STM, external note STM, selected dependencies,
reader copies, native cycle policy, errors/depth/UTF8/restoration; older mutation,
HTML/ASCII/PDF/native regressions pass. Contract: memory/preprocessing-contract.md.

Final23 copied inputs byte-equal project, final-inputs.json SHA b0d0ef3f... in evidence.
Root flake remains only unchanged user USTC overlay; lock unchanged. User committed
README.org, org-texmacs-preprocess.el, tests/ert/ert.el. Complete committed diff
matches staged SHA972ca91a... in evidence; full message matches tmp/commit.md with
feat(document)! subject, BREAKING CHANGE for removed INFO origins and Refs #1.
Index empty; only mirror remains dirty. Previous gates transfer by exact candidate
byte identity; no new tests solely for commit verification or external issue write.
Phase4 selected integration now accepted as described above;
Refs #1 remains appropriate pending separate overall issue/frontend scope review.

Necessary native comparison/reproduction artifacts (seven texts plus manifest)
archived immutably at archive/2026-10-14T00-59-44Z--c525095/MANIFEST.md. Capture
context is Phase2b commit, not original provenance of uncommitted candidate tests.
Nine native probes rely on pinned Org, not candidate preprocessing; reproduction
limits explicit. Old Phase2a archive remains unchanged. Selected implementation
needs maintained candidate sources, not just capture-context commit.

Phase2a/2b earlier complete and user committed as bounded preprocessing revision
on bibliography revision049a5a0. Exact reviewed seven-path diff/message verified,
SHA bbb18e19330b81634f407d7ccf8efec3658a19e645c815c9edfe14a31b71f2bc, Refs #1;
index empty/only mirror at verification. Earlier Phase2b validation was35focused/
359ERT and full checks, now superseded by Phase2c gates above. Initial research12
locked probes/contract archived at archive/2026-10-13T16-45-34Z--049a5a0/MANIFEST.md.

Phase 3b A/B/C is complete and committed by user as the opt-in Org Cite discovery
revision, main 049a5a0 on c26b932. Seven-file committed diff exactly matches
reviewed staged SHA-256 810024f4...; subject/body/footer match tmp/commit.md.
At that commit verification index was empty and only mirror was dirty;
Phase2b is now separately committed as described above. Prior validation applies
by byte identity: 17/17 focused, 341/341 installed ERT, all nine checks.
No new regression was run solely for commit identity or plan review.

Scope: independent org-texmacs-bibliography module exposes
org-texmacs-document-from-buffer-discover-bibliography and
org-texmacs-export-from-buffer-discover-bibliography. Old explicit APIs/menu
unchanged. Full-source private STM-masked standard Cite discovery once; owned
raw-document declarations + ordered effective IDs; explicit texts win without
stat/read, missing local regular UTF-8 <=1 MiB files appended. Reject visiting
file directory/base mismatch, remote/URL/tilde/control paths, symlink components
and physical aliases among automatic reads. No preprocessing, pure-layer I/O or
new input slot. Source baseline predates discovery. Fixed-text receipts plus
source/config/filter/collector/explicit-text checks through native waits and final
document/byte return. No file-output policy/FS-DB atomicity/ABA/sandbox claim.
Phase 2 source composition and Phase 4 real org-roam-organize integration separate.

Node A: three focused, 327/327 installed ERT 163.753805s, all nine checks.
Node B: seven focused, 331/331 installed ERT 164.625142s, all nine checks.
Nine includes eight existing + focused. Final C logs
tmp/issue-1-phase-3b/node-c-{focused,check}-final.log; 22 inputs
byte-equal current project, manifest hash 9937e1c2... in evidence.
Isolated copied flake uses current project lock, user USTC overlay, locked
Emacs31.1/Org9.8.10/TeXmacs2.1.5. During Phase 3b the user authorized repeated
exact240s isolated flake checks. flake.lock unchanged; stale local Org is not baseline.


## Relevant established baseline

Phase 1 c26b932: user-committed key-only AST filters on b229454 lock update,
historical 12 focused/324 installed ERT/all eight checks. Filter graph/INFO/buffer
validation, selected function identity checks and callback-reference detachment
remain unchanged. Contract: memory/filter-contract.md.
Phase 3a 25/25 research probes (0.207506s), exact c26b932 source/lock: raw Cite
enters STM text, mutates global list tails, widens scope, follows SETUPFILE and
uses visiting directory. These findings motivate the adapter. Immutable archive:
archive/2026-10-13T13-27-14Z--c26b932/MANIFEST.md with report/contract/reproduction
under files/tmp/issue-1-phase-3a. Phase 0 fourteen-probe archive:
archive/2026-10-12T19-11-59Z--b229454/MANIFEST.md. Both unchanged. Active contract
memory/bibliography-contract.md is now selected for Phase 3b, not an unselected
production proposal. Issue #1 still has separate Phase 2/4 work.

v0.4.0 is released. User committed final HTML regression as
the final HTML coexistence regression revision, created tag and published GitHub release.
One-file test diff on the v0.4.0 release preparation revision matches verified SHA-256
4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
Local annotated tag v0.4.0 object feaf8c4ef501d50aa595090a0fa312c855071527
peels to that commit. GitHub tag ref matches the same object. Release API confirms
https://github.com/ren-lingyu/org-texmacs/releases/tag/v0.4.0,
draft=false, prerelease=false, published_at=2026-10-08T17:27:12Z
(2026-10-09 01:27:12 Asia/Shanghai). Project and memory candidate are coherent;
no new source edits or tests are needed for this identity/state verification.
The user's review/publication hold has ended through their completed release.
No new implementation or post-release checks are authorized by this notification.
The user adopted the rebuilt GAW history and restored its branch name to
`_agents`. Local status/check confirm that `_agents` is the sole local GAW branch,
selected/deployed at `.agents`, with the verified reconstruction handoff at its
tip before this adoption record. The user reports backing up the old GAW branch
remotely; the remote ref name and backup contents were not independently checked.
Do not assume the old history is still available through a local branch or mutate
backup/branch/remote state without explicit direction.

Project procedures now reflect the available global GAW skill and compatible
public CLI. The maintenance motivation is coherent recovery and faithful
archive interpretation: checked capture HEAD is distinct from original provenance,
and project parents require supported evidence. Archive/development/governance
skills, management README and bootstrap template are coordinated; pure-text-only
capture, archive-only snapshots, SHA-256 and config-only checkpoints remain local
requirements. Historical snapshots/configs are unchanged. Existing OID/provenance
work remains in evidence/history; issue #1 concerns later project architecture,
not this maintenance. No external tracking change or project implementation is
selected. Resource/name/data-root review and public GAW readiness checks pass;
no project tests or network calls were needed. Machine-specific executable
bindings are supplied by host/session instructions, not project bootstrap or
current memory. The bootstrap is synchronized from the reviewed template to the
ordinary project's ignored, untracked AGENTS.md. The user permits this routine
generated-file sync within authorized GAW governance maintenance without separate
confirmation; preserve unrelated edits and verify exactness through the helper.

Reconstruction results and validation limits remain in evidence.md and
`archive/2026-10-08T18-49-17Z--46ccf6e/`. Its diagnostic journal records historical
branch names/OIDs, not active identities; archived files/manifests remain unchanged.
Future information flow remains unresolved in issue #1:
https://github.com/ren-lingyu/org-texmacs/issues/1. Do not automatically implement
preprocessing reuse/generic export or broaden citation/resource semantics.
Release scope includes bounded DOC-01 resolution, native .tm/PDF consumers and
synchronous dispatcher/naming/scopes/configuration. HTML composition regression
is controlled hook/advice/filter coexistence, not real three-package/database
integration. Production code/README/version remained unchanged in final test node.
Final no-overlay Nix gate passes 312/312 with cache reuse; original endpoint
recovery is not independently established (two HEAD attempts timed out). Earlier
mirror-backed checks remain historical facts. Ordinary release operations were
performed by user; agent only read local Git and remote release/tag metadata.
Scope guidance: ox-latex is a reference for shared Org export conventions,
not a feature inventory to copy wholesale. Current ox-texmacs is a bounded
dispatcher frontend, not a complete generic exporter: org-export-as and related
generic entry points still reject texmacs. Common selection/configuration/API
compatibility needs staged design under AST-first/owned-input constraints;
LaTeX-only compilation, templates and package controls are not project duties.
User places generic org-export-as API compatibility relatively late: treat it
as nonblocking later adaptation, not a prerequisite for subtree/configuration
work. Existing dispatcher and explicit source APIs provide the working path;
retain explicit rejection of unsupported generic calls until adaptation exists.
Unsupported syntax and deferred multi-session/incremental/editor conveniences
must not be presented as mandatory remaining work.
Frontend uses org-export-output-file-name and ordinary overwrite after checked
native bytes are complete. Public new-file-only APIs stay exclusive. Atomic
replacement, backups and target-version locking are not adopted prerequisites.
User rejected a standalone PDF preview command; no such command is adopted.
The frontend supports synchronous buffer/subtree/region/narrowing actions.
Generic string export/publishing and visible-only selection remain unsupported.
Full dispatcher preprocessing is now accepted as described in Phase5 above;
direct source APIs and local scopes retain direct preparation.

## Baseline and staging

- Current main is verified Issue4 final date/audit delivery8a90b4c at the
  v0.5.0 readiness review; lock selects Org9.8.10.
  Phase4/5 committed diffs
  verified. Index empty; unchanged user mirror remains unstaged.
  Committed Phase2c diff/message matches reviewed candidate.
  Phase 3b committed diff matches staged/validated candidate SHA-256 in evidence.
  Release-era observations below describe their historical baseline.
- Main HEAD observed on 2026-10-09:
  the final HTML coexistence regression revision.
  Its one-file HTML regression diff against the v0.4.0 release preparation revision matches the verified hash.
- Metadata paths README.org, org-texmacs.el and flake.nix version line are
  committed. HTML regression is committed; ordinary worktree/index are clean.
  Prior staged review/diff --check passed. SHA-256 on the v0.4.0 release preparation revision:
  4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
- User temporarily removed the uncommitted USTC overlay on 2026-10-09. flake.nix
  matches HEAD; do not reintroduce or stage workaround automatically. Previous
  mirror-backed validation/exclusion proof stays in evidence as historical state.
- Local v0.3.1 annotated tag resolves to the v0.3.1 release revision.
  v0.4.0 is published at the verified tag/commit above. Tag includes a PGP
  signature block; cryptographic signature verification was not performed.
  Release/tag identity evidence and remaining limits are in evidence.md.

## Released HTML review evidence (historical)

- New ERT uses actual HTML exporter and controlled temporary preprocessing hook,
  around-advice on include expansion, and parse-tree filter. Their output effects
  are asserted. No user database/include dependency is loaded. Source state is
  unchanged, no TeXmacs worker request is allowed, and advice is always removed;
  after cleanup, baseline HTML output returns. No production/doc edits needed.
- Focused backend 12/12 (5.353570s), including new case (0.005854s), pass.
  Exact Nix 240s check without overlay passes, with installed ERT 312/312
  (157.819934s) and all check results successful; two changed checks run and the
  other results are cached. Per-node repeated focused/Nix checks were authorized.
- User also authorized two one-shot HEAD probes for ELPA index/org-9.8.8.tar.
  Both failed curl exit 28 after 20s connection timeout, no HTTP response; no
  retry. No credentials/body downloads/files were used. This confirms neither
  endpoint recovery nor a global outage and does not contradict user's own
  observation. Cached Nix success alone is not fresh-download proof.
- Working INBOX/issue findings are now consolidated into this substantive
  validation checkpoint. INBOX was left untouched; no raw archive needed because
  relevant facts are distilled and maintained test retains full reproduction.
  Only pure text enters GAW. Test/metadata commit and release identities were
  later verified; no new tests were run solely for publication verification.

## Existing consumer boundaries

- Complete native .tm bytes/save, PDF bytes/save and readonly byte views already
  consume owned documents. Native encoding retains literal/STM/file provenance.
  Org remains canonical; no textual target intermediary is reparsed.
- Frontend writes use ordinary overwrite after source checking; write failure
  may leave partial output. Explicit new-file APIs retain exclusive creation.
- PDF uses owned temporary native buffer/file, bounded print/update/final-print
  phases and native font/style resources. Existing sessions are isolated; worker
  cleanup failure stops transport. Explicit resource/executable primitives are
  outside the PDF subset, and custom installed styles are not sandboxed.
- Earlier validation/progress details belong in project.md, evidence.md and GAW
  history. Release regression was 312/312; current Phase 1 candidate is 324/324.
  GUI layout/general
  pagination convergence are unverified. Use maintained structural/text checks.

## Persistent workflow and knowledge

- `.gaw/config` now explicitly declares version 1 with archive, skills and memory
  role groups for the same three existing directories. Use a v1-compatible GAW CLI;
  role metadata changes discovery, not the flattened workspace/protection boundary.
  Historical config states remain unchanged.
- This workflow review and public status/check were performed with GAW 0.6.0,
  which accepts this v1 workspace. This is verification context, not a requirement
  to find that same installed version. Interpret
  historical snapshots under their own conventions; no historical migration is
  needed to resume with updated skills. The global workflow is an external
  available dependency, not included among this project's bundled resources.
- GAW `_agents` now contains the adopted rebuilt history and is valid/deployed at
  `.agents`. Old-history remote backup is user-reported, not independently checked.
  Use public GAW interfaces, never lifecycle mutation without direction.
- `goals.md` is authoritative constraints; `project.md` is current architecture/
  support; `evidence.md` holds provenance and verification limits; `backlog.md`
  holds adopted/deferred/unresolved scope. Superseded progress stays in GAW history.
- Root AGENTS.md is an ignored generated bootstrap, reproducible through the
  namespaced governance skill. Retired GOALS.md/REVIEW.md and eligible historical
  probes are in the archive, not normal recovery inputs. INBOX.md remains ignored,
  was cleared after verified issue1 original-byte archival, and now contains the
  v0.5.0 readiness plan extracted in memory/release-0.5.0.md. Prior adopted plans remain current knowledge;
  archived original is historical only.
- Only pure-text files may enter GAW memory, skills or archive. Archive necessary
  unique temporary evidence selectively via the archive skill; never bytecode,
  images, binary containers or regenerable caches.
- After each completed node, request exact-path project git add approval directly,
  then draft tmp/commit.md from the approved staged diff. Ordinary commits/pushes/
  tags/history changes remain the user's action. Preserve unrelated changes.
- Existing DOC-01 covers the critical cross-node architecture, enough for active
  CONSUMER-01. Broader unsupported Org syntax is not an automatic commitment.
  Keep pure lowering, owned snapshots, native encoding and consumers separate.

## Blockers and next actions

- No Phase 2b code blocker. Current full validation uses the user mirror overlay.
  Release-era no-overlay results/HEAD timeouts below are historical, not fresh
  network availability evidence. No extra upstream fetch probe is needed.

1. The native PDF consumer revision is verified against the seven-file SHA-256 on the baseline interactive export revision:
   00164bbb3491e4addd74c75a0c53ab86cd8397855e659c25a572a5ae84044464.
   The PDF semantic regression and citation repair revision is now verified by its three-file diff SHA-256
   against the baseline native PDF consumer revision. The bounded ox-texmacs frontend revision is now verified against
   d41f05a2... as recorded in evidence. The Org output naming and repeat-export revision is verified
   against its five-file hash recorded in evidence. The subtree export revision is
   verified against the six-file diff hash 3be6de01... above. Region is
   committed as the region export revision and verified against six-file hash 22765b0b... above.
   The external configuration override revision is verified against five-file diff 145a3237... above.
   The narrowed-source export revision is verified against six-file diff fdeb09f1... in
   evidence. The v0.4.0 release preparation revision is verified against three-file
   diff 84b212a7... in evidence. The final HTML coexistence regression revision matches 4461f4ad... above;
   local/remote v0.4.0 tag and published release are verified. Release phase is
   complete. User has selected issue #1 investigation as described above. Body-only
   fragment/generic API remain deferred by user choice.
   At release closure the overlay was removed and the no-overlay check passed.
   Two release-era HEAD attempts timed out. Current lock/mirror state and the
   completed issue #1 nodes are recorded above.
   Published release notes are now authoritative for publication scope. Old tmp
   drafts are regenerable preparation artifacts, not remaining release tasks.
2. Keep dispatcher policy and replacement/backup/atomic-publication boundaries
   separate from the selected PDF work. Do not silently
   enable full Org preprocessing or general bibliography/resource reads.
3. Fresh-context recovery drill remains a nonblocking startup check: the prior
   session recovered valid GAW without archive, but user supplied AGENTS.md.
   When a fresh session discovers bootstrap/skills unaided and recovers current
   memory, mark that remaining check complete. Continue project work meanwhile.
