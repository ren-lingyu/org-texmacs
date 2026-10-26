# org-texmacs current project model

## Current local INCLUDE snapshot/view repair

Accepted uncommitted candidate separates raw source/receipt capture from
interpretation views. Literal INCLUDE reads raw text and uses native escaping;
ordinary block wrapping uses actual wrapper context; native texmacs/equation/
equation* selects raw text then shields the generated block. Native branch
recursion/options differ and final AST support remains explicit. Shared block
name classification avoids parsing opaque native bodies as Org. Public signatures
and source INFO semantics remain unchanged; coding overrides/unmatched and file/
budget/configuration guards remain. Receipt checking can reread bytes despite
one captured snapshot. This supersedes earlier blanket wrapper rejection only.
Final592ERT/compile/lint/formatting/default checks pass; six corrected isolated
docs reload and PDF-text acceptance pass. Ordinary index empty, docs stashed.
Contract, provenance and limits: memory/include-view-implementation.md.

## Current flake and formatting-check state

Following the delivered Issue14 feature, user commits Lisp/Nix formatting,
enables treefmt.flakeCheck=true and refreshes nixpkgs/personal-nixpkgs direct
inputs. Current full flake checks include formatting verification; nix fmt
applies formatters and README.org stays excluded. Other input graph/follows
relationships are unchanged. Static review establishes formatting-only project
changes, not runtime acceptance at the new dependency revisions. README-only
synchronization is user-committed and exact delivery verified; project clean.
Details: memory/post-issue14-flake.md.

## Issue14 document information delivered

User-committed and delivery-verified implementation extends the restricted Org context to
nine native metadata fields and independent abstract blocks. Rich subtitle joins
existing title/author/date secondary AST ownership; email/language/keywords/
description/creator remain literal text. Visibility reuses Org options. Native
title fields, email-only author data and creator:t doc-note are supported.
Whole-document keyword nodes retain order; subtree/region uses one effective
inherited value, with EXPORT_KEYWORDS replacing file declarations.

Org LANGUAGE/DESCRIPTION override corresponding initial defaults, using explicit
language mapping and hidden global-subject. Result initial-literal-keys carries
Org provenance to native encoding; unmarked explicit initial values keep native
source semantics. Internal initial wire supports the optional org-literal tag.
Pure conversion still owns/fixes all inputs and performs no encoding or I/O.
Tests add16core/3native/1PDF cases in existing checks; isolated full gate passes
579default cases, strict compile/lint/aggregates on85unchanged input hashes.
Delivery matches the exact accepted candidate and85input hashes; Issue14 is
independently confirmed CLOSED/COMPLETED. Later formatting/input updates remain
outside this original runtime acceptance claim. Native PDF Creator/Keywords limits and font
exclusion are explicit; optional9integration cases were not rerun.
Contract and verification: memory/issue14-implementation.md.

## Shared ERT driver and parallel PDF checks

Current delivered tests/ implementation exports
testSupport.mkErtCheck from support/default.nix. Explicit runtime/file/helper/tool/
environment/Emacs args feed common timeout, isolated HOME, tee+pipefail logging
and actual case-name output. Core/native/patched-caption/optional integration and
two PDF leaves use it; optional integration keeps its public required arguments.
tests/default.nix passes PDF suite paths and inspector explicitly from suites.nix
through mkPdfCheck. Sibling ert-pdf-render27 and ert-pdf-document32 checks are
discoverable by llib.tests; ert-pdf aggregates their logs/names and rejects
duplicate names, and ert still consumes ert-pdf. Existing public checks retained;
two new leaf checks added. No case/helper/production bytes changed, parent lookup
or README dependency introduced. No workers/print passes/assertions removed.
Authorized isolated x86_64-linux gates exit0:559default cases, exact inventory,
lint/build/aggregates accepted. PDF leaves start together and pass in128.667668s
and80.958658s; native318 passes in173.494314s. Single observed PDF execution
phase~129s versus prior231s serial, dependent on available slots/resources.
Optional9integration cases not rerun. Details: memory/tests-refactor.md.
Delivery review confirms all81committed inputs equal the accepted candidate and
the exact drafted message; clean ordinary worktree/index at intake. No rerun.

## Previous live ERT build logs

User committed the reviewed five-driver change; exact patch/message/expected
parent and clean ordinary index/worktree verified. This delivery association
does not turn earlier uncommitted runtime evidence into a committed-state rerun.

All five ERT drivers (core/native/PDF/patched-caption/optional integration) now
stream combined Emacs stdout/stderr through tee to the Nix log and saved ert.log.
Explicit pipefail retains pipeline failure and timeout handling. Lint already
streams and aggregate has no ERT execution. No case/helper/production change.
User-authorized targeted PDF gate passes59/59in231.327348s; progress observed
before completion. Four other logging drivers statically checked only. Longest
case issue11-bare-block-and-reload-consistency57.909601s covers23combinations,
69PDFrenders and23independent native reload processes; no per-phase cost
breakdown, shared workers, removed passes/cases or speed claim. Potential local
inspection reuse and independent parallel sharding require further design and
measurements. Single long cases still only report their result on completion.

## Latest flake foundation API adaptation

Current user-selected migration calls personal-nixpkgs.lib.mkFlake and uses its
perSystem.nixpkgs.overlays option. Updated project pkgs/default.nix calls
packages.mkOverlays with default and legacy groups, explicit extraArgs.src, and
legacy.export=true. Flake applies the legacy group and exports pkgs.legacyPackages;
the removed library mkLegacyPackages callback is no longer referenced. Source,
testSupport, package overlay factories and tests.mkChecks parameters remain
compatible. Local library and emarccs reference inspected with explicit authority;
API matches the project lock revision. Adaptation passes authorized timeout120s
nix flake check --no-build --no-write-lock-file on the explicit project path:
named packages, six checks, devShell and formatter derivations evaluate on
x86_64-linux. That gate did not run compilation/ERT/formatting. The later targeted
PDF gate above validates59cases after the user's50-file formatting change;
other suites have no fresh runtime gate for those changes.

## personal-nixpkgs test composition migration

The user replaced inline package construction with pkgs/ overlays and an
emacs-with-org-texmacs runtime. Tests now use llib.tests.mkChecks, root tests/,
test-overlay.nix discovery and test.nix leaf drivers, matching the authorized
~/emarccs/tests reference. Flake supplies src and the installed runtime explicitly;
tests inject tools, pkgs.emacsPackages and testSupport. The current overlay
guarantees this package scope matches the runtime's base Emacs.
All six existing check names remain; the aggregate resolves its leaves through
the fixed point and does not rerun ERT. Optional integration/default.nix has no
overlay and remains caller-supplied. flake perSystem.checks invokes this entry.
Patched-caption overrides org on the actual scoped org-texmacs package; it no
longer needs the removed buildPackage callback. Lint explicitly receives
final_.emacsPackages.package-lint, avoiding self-reference with the package-lint
check and keeping lint out of the ordinary runtime wrapper.
Existing Lisp/Python/helpers/isolation unchanged. Authorized current-project
path flake check exits0: core176/native318/PDF59/patched6, lint and aggregate
accepted on x86_64-linux, with strict patched package compilation. Optional
integration was not rerun. Earlier acceptance below describes prior package
architecture and its broader inventory/runner controls.

## Source layout adaptation to lisp/

All15 production Elisp modules and org-texmacs-worker.scm now reside together
under lisp/. Worker service lookup remains relative to its own library directory.
User subsequently sets the source fileset root to lisp/ and builds directly
from source; patching, compilation and Scheme installation therefore run
inside lisp without changing the installed flat site-lisp layout. Package-lint
uses source as working/load directory. README checkout/straight paths point into
lisp. User committed the relocation; tests refactor below starts from a clean
source-layout baseline. Earlier lisp-root full check passed553/553 stock ERT
(382.099933s), strict package build/lint and patched-caption check.

## Test organization and explicit dependency boundaries

User-committed and verified refactor uses tests/default.nix callPackage composition:
ert-core176, ert-native318 and ert-pdf59; ert is a dependency-only aggregate,
not a second execution. Children receive project-specific runtime/source and
testSupport file attributes explicitly; no parent traversal or repository-root
discovery. Shared bootstrap preserves worker-only/document loading observation,
then common/native/PDF helpers register no cases. Runner rejects missing inputs,
tools, empty suites and duplicate registrations, and records actual case names.
Direct Nix->Emacs drivers replace two Guile wrappers. Default ERT uses stock Org;
caption-inline-footnotes retains the test-only Org patch and six original cases.
Optional integration retains nine real package/SQLite/HTML/blog cases, supplied
Emacs+Org-roam, pinned extensionSources and explicit testSupport; no default
extension dependency added. Tests never read/pass README; two fixed native
fixtures retain example business assertions, documentation synchronization is no
longer an automated check. Python/pypdf inspector remains test-only/PDF-local.
Existing isolation/error/cleanup semantics and assertion matrices preserved;
no shared worker or deleted case. Nix ERT limits600s, lint120s. All568cases,
inventory and five negative runner controls/positive control accepted on pinned
x86_64-linux; final65project+11extension inputs match. Other systems/GUI not new
claims. Complete48path patch/message and65committed input blobs match acceptance;
ordinary index/worktree clean, no runtime rerun solely for delivery identity.
Full interfaces, exact authority/results/limits: tests-refactor.md.

## Version/documentation candidate for0.5.0

Committed package header and Nix package now declare0.5.0. README adds release
overview/since0.4.0 API migration and reconciles support/options/native limits;
relevant source commentary/docstrings corrected without runtime logic changes.
Six-path candidate passes isolated full flake:553stock/6patched ERT, strict compile/
lint and default build;32inputs match root. User committed exact candidate; parent/patch/message/all32inputs verified.
Project index/worktree clean; not tagged/published. Full scope,
commands/results and final optional representative-doc decision: release-0.5.0.md.

## Chinese font follow-up: reproduced using user's bundled-font override

User's ~/emarccs actual override sets extraFonts/chineseFonts/japaneseFonts/
koreanFonts all true; project lock allowed. Isolated24PDF comparison,8groups:
12override real Chinese vs12plain fallback; generic/article, default/chinese
language, org-texmacs/native/saved-tm reload exactly match text/font faces/layout.
Same unstyled 中文测试 splits 中文=UnBatang, 测试=AR-PL-New-Sung with size/baseline
differences, also headings/bold/italic/quote. Native reproduces, no exporter fault
shown; language=chinese alone insufficient. No host font/manual Fandol setup,
GUI/exact user's lock claim, default-font policy or production changes.32root inputs
unchanged, index empty. Supersedes earlier not-yet-reproduced conclusion under the
newly specified override. Full source/authority/evidence/next action:
block-font-investigation.md. User now classifies this observed native issue as
outside org-texmacs responsibility, removes it from backlog/pre0.5.0 blockers.
No font fix/configuration/docs/default-policy work remains. Native behavior is
not repaired and no general font/release-readiness claim follows.

## Statement long caption completion: committed and verified

Six-path candidate adds long statement CAPTION->dueto for all16tags, preserving
existing inline/NAME/frozen references and literal example parser exception.
Source evidence captures explicit short incl erased [] and empty declarations
before prune, scoped range rebind and retained-only validation. Shared pure
validator runs before caption links; no caption STM discovery or custom-handler
caption support. First concat uses surround(label/dueto prefix,empty,original),
opaque STM roots indivisible; nonconcat/empty separate prefix. Paths remap;
same-prepared consumers reuse IDs. Native generic/article36cases/direct control/
readback/PDF/reload passed before production; legacy NAME-only paragraph break
removed, target coords and numbers retained.75focused/6patched/553stock/full
flake/compile/lint/default build pass. User committed exact six paths; complete
parent/diff/blobs/message verification passes, ordinary index empty. Root
workaround/lock unchanged. Remote issue13 freshly confirmed CLOSED/COMPLETED through public HTML.
Contract: statement-caption-implementation.md.

## Block mapping / CJK bounded investigation completed

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
Next user may select persistent font/config documentation or remaining release
readiness work; do not claim global font correctness or0.5.0 readiness.

## PDF footnote destination repair: delivered and verified

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
layout guarantee. User adopts PS->PDF as completed diagnostic only,
not a feature/fallback/maintained acceptance path/release condition. No PS task
or added Ghostscript runtime dependency; preserve historical evidence only. See
footnote-forward-probe.md for disposition. Full contract/commands/identities: footnote-pdf-fix.md. Earlier
causal evidence and archived originals: footnote-forward-probe.md and
footnote-private-integration.md. Read-only verification confirms the exact single expected Issue13 stage4 parent,
seven paths/blobs, full binary patch and approved message; index empty, original
flake workaround alone unstaged, lock unchanged. No runtime rerun solely for
commit verification. Project-parent association grounds delivery equivalence,
not the original uncommitted runtime acceptance. Remaining release gates are
separate; next user selects readiness work. No agent ordinary commit or external
tracking action.

## Source and representation

- Org is the sole canonical source.
- Ordinary Org syntax is parsed by Org. TeXmacs blocks and supported fragments
  preserve raw STM source and are parsed independently by TeXmacs.
- Parsed TeXmacs islands participate as structured strees; they are not kept as
  opaque payload strings and are not reparsed as Org.
- Accepted user-committed issue5 revision recognizes Org TeXmacs special-block names
  without case, retaining original AST :type/source/body spelling. A shared
  source predicate also excludes block descendants from inline fragment discovery;
  preprocessing/bibliography shielding and pure island checks use that predicate.
  Native STM/inline fragment tags remain case-sensitive. Five new ERT cover162
  marker/name/ambient-case combinations and native output/shielding.401core/
  114focused/9real/complete Nix strict compilation/lint acceptance passes in
  locked x86_64-linux isolation. Committed blobs/diff equal accepted candidate;
  exact evidence/limits
  and issue association in memory/evidence.md/current.md.
- The implementation does not require physical grafting of all TeXmacs pseudo
  nodes into one live Org element cache.

## Stage4 delivered and verified

Single-object NAME/reference implementation accepted on fixed isolated inputs:
57focused/539fullERT/patched5/strict compile/lint/full flake/default build pass.
Private ownership/validation/final allocation split freezes Org-native identities;
strict semantic candidate view, original NAME evidence/scopes and type-specific
labels preserve STM/file provenance. All newly named blocks label even unused,
bare table referenced-only behavior retained. Native generic/article links and
readback/reload accepted, no reference-text interpretation or global ID lookup.
Seven-file user delivery exactly verified, user overlay excluded; full contract/identity:
issue-13-stage4.md. Issue13 independently confirmed closed/completed; no release claim; original caption native
footnote layout limits remain unchanged. Below older stage descriptions retain
baseline semantics where superseded by this candidate.

## Issue13: accepted stage1 and remaining adopted target

Stage3 figure/table implementation accepted, user-committed and delivery verified.
Source proof survives pruning and scoped reparse; generic/article native gates
and strengthened focused tests, full flake and default build pass.
Current capability, limits, user-adopted Org footnote boundary and evidence:
memory/issue-13-stage3.md. Stage4 NAME candidate is accepted above; user delivery pending.

Stage1 is implemented/accepted/user-committed, exact delivery verified: ordinary
special-block recursion, captured private handler dispatch with ownership,
preflight/identity/provenance checks, all16formal statement types. Canonical
statement TYPE, statement_TYPE and direct TYPE aliases; Org example-block stays
literal. Native generic title/counter/PDF comparisons and theorem/proof reload
pass;17focused/495fullERT/strict package compile/lint/full flake/build accepted.
Other styles/GUI/platforms unverified. Contract/input identities:
memory/issue-13-stage1.md. Stage1 rejected NAME/CAPTION/ATTR; Stage4 adds NAME,
and current statement candidate adds long-only CAPTION as described above.
No stable public handler API or new dependency/protocol.

Issue13 is required for v0.5.0: ordinary recursive preparation/lowering with a
minimal private handler dispatch, native formal statements, raw single-expression
equation/equation*, explicit figure/table wrappers and bounded single-object
NAME/[[name]]. Handler returns structured stree; core owns snapshots, STM/file
provenance and preflight/real-island boundaries. Opaque texmacs STM retains its
separate interpretation. Explicit table wrapper becomes preferred; current naked
Org table numbering/caption/reference behavior remains compatibility input.
Label scope is type-specific and native counters stay authoritative. New stage4
guidance, implementation and acceptance: issue-13-stage4.md. Stage3
empty-caption numbering and starred wrappers now have generic/article evidence
above. NAME and weak external surround for plain named STM are accepted in the
uncommitted stage4 candidate above.
Stage4 guidance supersedes provisional referenced-only activation for new blocks
and deterministic IDs with all-named activation/Org allocation. User supplement
adopts review corrections: validate without IDs, allocate/freeze after effective
AST/static labels known, remap on ownership copies. Candidate native/full
acceptance passed; user delivery pending. No float-placement policy/API is added.
Stage2 equation delivery is described below.

Stage2 raw-STM equation/equation* implemented/accepted/user-committed, delivery verified:
one original source capture/request, native parser authority (no math whitelist),
single environment wrapper via pack, provenance intact. Classifier must cover
preprocessing protection, bibliography discovery and region reparse/footnote
recovery as well as fragment/document paths, without widening texmacs-specific
block/edit APIs. Pure lower distinguishes structure validation from source-empty
checks. Failure promises retain existing transport/session and partial-write
limits. Focused29/29, generic/article native counter/PDF/readback/reload checks
and no-link package build pass. Full flake check including ERT/strict compilation/
lint exited0; exact committed delivery matches accepted patch/message/blobs.
Review decisions/full contract: memory/issue-13-stage2.md.

Issue9 is later multi-object-to-one-composite identity/composition work, initially
independently numbered/referenced aligned rows. It is not a prerequisite for13's
single-object references, and13 does not complete9. Existing implementation and
released-subset records below retain their historical scope. Complete adopted
source semantics, unknowns and evidence requirements: memory/special-block-plan.md.

## Delivered caption anonymous inline-footnote compatibility

User selected AST compatibility after native diagnosis; local context predicate
and unprepared-citation guard delivered; exact user commit verified. Anonymous inline notes in long and
short captions reuse existing native footnote lowering. Stock Org literal source
behavior unchanged, patched parser isolated to tests. No short-caption ban,
parser/advice/global mutation, separate note anchors, layout/counter workaround.
Native caption table suppresses note bodies and list-caption affects counters;
user accepts documenting these limitations without PDF correctness guarantee.
Focused4/patched5/full flake/default build pass on fixed isolated inputs equal
worktree. Detailed contract/identity/limits: memory/caption-inline-footnotes.md.

## Committed block/table extension

Selected Issue4 subset uniformly maps Org quote blocks to native quotation with
body document, including named footnotes and nested supported content. Center,
static code and list mappings retain their existing native constructs. Issue8
adds at most one complete plain<l>/<c>/<r> format row anywhere, applying column
cell-halign while omitting it from data and border numbering. Duplicate/partial/
mixed/width rows reject; special columns/formulas/groups remain unsupported.
Filtered special-column checking uses an independent AST copy and linear row
identity exclusion. Zero-format output, source ownership, caption/reference,
STM and typed-file provenance are preserved. README and seven maintained tests
updated;23focused/413core/9real/native10/strict compilation/lint pass under locked
x86_64-linux. A quotation repair is user-committed with exact accepted blobs
verified. B table alignment is now user-committed, parent=A and all25accepted
input blobs verified against final manifest; no release claim. Issue8 is confirmed
closed/completed; #4 excludes its feature from remaining scope. Scope, tracking
and raw evidence: current.md and
block-table-implementation.md. Date/metadata and remaining Issue4 work unchanged.

## Committed Issue4 date/audit extension

Date metadata timestamps now emit complete raw-value literal strings, with Org
brackets/spaces/time/range/repeater/warning/diary content intact and unevaluated.
Private date text helper is string->string, default identity; prepared input owns
and fixes its opaque function definition in internal INFO. Copied arguments/
results isolate advice mutation; malformed raw/structure and nonstring results
reject. Existing metadata policy and rich inline treatment unchanged. No public
formatter option or additional native structured metadata introduced.

Bounded package-tag audit confirms existing block/list/table/caption/inline/
metadata/headline/TOC/footnote/link/citation wrappers in pinned native environment.
Generic paragraph/subparagraph hide displayed numbers by native default while
logical counters/TOC/refs agree; documented, no native style override. Eleven
new regressions replace one (+10net):423core/37focused/9real/native9dates6cases/
full strict compilation/lint pass. Both date/audit deliveries user-committed and
verified by parent/path sets/all25accepted blobs/messages; no new release claim.
Full audit/evidence/limits
and separate delivery status in memory/issue-4-closure.md/current.md.

## v0.5.0 readiness and accepted candidates

Read-only INBOX review adopts release readiness priorities in
memory/release-0.5.0.md. Issue10 is now user-committed and verified:
anonymous/named inline-note direct text shares configured discovery, owned body
splitting/registration and pure bare/mixed lowering with paragraph. Strict
malformed/cross-object errors, snapshot-coordinate recovery for hidden named
definitions, request filtering and first-use/provenance boundaries verified.
7new maintained ERT plus migrated exclusion; final46focused/9real/437core/strict
compile/lint/full checks pass. All25final inputs match worktree,5file patch
reconstructs exactly. Delivery parent=Issue11 baseline,5changed paths/all25committed
hashes/full approved message verified; capability now on local main. Index empty,
only user flake unstaged. Remote#10 verified closed/completed on2026-10-16;
publication refs not checked. Contract/evidence: memory/issue-10-plan.md.
The initial review required evidence for the equation
block/paragraph PDF discrepancy (#11), PDF annotations and Chinese fonts; the
previous bounded native tag audit alone did not establish these cases.
Isolated probes now reproduce #10 and identify #11 wrapper-sensitive native
rendering/serialization reload difference. User-committed Issue11 repair
implements bare identity-based paragraph lifting and known direct display-root
mixed rejection; list-first marker route retained, no automatic splitting.
Final14focused/9real/430core/full compile/lint pass; source/encoding/provenance
boundaries and matched-context native layout verified. Delivery parent/path set/
all25input hashes/full approved message verified; repair now on local main.
Remote#11 verified closed/completed on2026-10-16; publication refs not checked. Contract/evidence:
memory/issue-11-implementation.md. The subsequent PDF-link sequencing repair
is accepted below; CJK native/configuration evidence remains incomplete.
STM font-lock bounded investigation complete: Org Scheme lexical colors feasible,
but naive wrapper has property/invalidation/soft-error gaps and64KiB scan~8s.
Default-on font-lock now implemented/automatically accepted/user-committed in
org-texmacs-font-lock.el with main load/Nix fileset/ERT/README wiring. Internal
nil default/local override, no dedicated command/Customize; Scheme properties
inside locally recognized paragraph/block regions with Org activation suppression
and owned old/new cleanup. Export semantics/source chars unchanged. Final11focused/
451core/full compile/lint pass; dense1MiB local re-fontify~0.489s remains a limit.
Exact parent/5paths/patch/message and26committed source hashes verified; index
empty, only preexisting user flake overlay unstaged at that delivery. GUI basic usability
now user-accepted; detailed interactions remain unverified.
See memory/font-lock-implementation.md. #9 post0.5.0/pre0.6.0; #7 deferred.
Code metadata remains0.4.0; Issue11 acceptance does not establish complete
v0.5.0 readiness and no release publication was performed.

TeXmacs special-block editing/indentation separately adopted: candidate
org-texmacs-edit.el reuses native Org source-edit lifecycle and selected Scheme
indentation, keeping special-block AST/export semantics. Public
org-texmacs-edit-mode defaults to bundled scheme-mode; optional scheme-ts-mode
and grammar require user installation. No mandatory dependency added.30focused/478fullERT, fixed extension integration,
strict compile/lint/full flake pass; user-committed; exact delivery verified. Actual TS/GUI editing
unverified. Details:
memory/block-editing-implementation.md.

## Current conversion path

```text
explicit Org source buffer
  -> private parsing and restricted Org context
  -> bounded standard citation-key AST filters when configured
  -> detached structures before native dependency preparation
  -> owned prepared input
       AST + INFO + islands + post-blank mappings + style + initial
       source-file + resource-base
       bibliography: explicit source identities + parsed BibTeX trees
  -> pure document-wide analysis
       identity-keyed link resolutions + target labels + typed file targets
  -> pure local document lowering
       body + style + initial + STM/file-target provenance
  -> source-aware native encoding
  -> TeXmacs native tree/state
  -> independent complete-document serialization / native document session
```

The result body `(document ...)` is the native buffer body. The independent
consumer constructs a complete file wrapper only after native encoding.

## Public construction interfaces

- `org-texmacs-input-create`: own and validate already prepared structures.
- `org-texmacs-document`: pure lowering from prepared input.
- `org-texmacs-prepare-buffer`: explicit source-buffer preparation adapter.
- `org-texmacs-document-from-buffer`: prepare and lower one explicit source.
- `org-texmacs-document-current-buffer`: current-buffer convenience wrapper.
- `org-texmacs-document-serialize`: independent native .tm byte-string consumer
  of a completed document result.
- `org-texmacs-document-save`: explicit absolute local new-file saving consumer
  of a completed document result.
- `org-texmacs-export-texmacs-from-buffer` / `org-texmacs-export-to-texmacs-file`: explicit source
  byte/file export adapters.
- `org-texmacs-export-to-buffer`: fresh readonly native byte view, noninteractive,
  caller-owned; explicit-source file/byte adapters are also noninteractive.
- `org-texmacs-document-pdf` / `org-texmacs-document-save-pdf`: native PDF bytes
  and new-file consumers; `org-texmacs-export-pdf-from-buffer` /
  `org-texmacs-export-to-pdf-file`: checked noninteractive explicit-source adapters.
- Optional ox-texmacs defines three interactive commands: export-as-texmacs,
  export-to-texmacs and export-to-pdf with the org-texmacs prefix and standard
  five optional Org arguments. The buffer command manages one untouched derived
  result by identity/state; user takeover yields a new result. See issue3 below.

These API names and lifecycle are the accepted, user-committed issue3 export API
and managed-result revision, not a new release. Exact five-file committed diff
and blobs match the staged/validated candidate; see evidence/current.
The final main commit has BREAKING-CHANGE and Closes: #3 trailers; user explicitly
judged selected scope sufficient for closure. Ordinary index empty, only user
flake.nix dirty. Scoped README/docstring/comment audit finds issue3 synchronized.
No new release or runtime claim; remote issue status remains unverified.
Historical node descriptions below retain
their original names/interactive contracts. The adopted current design is
memory/export-api-contract.md; live validation/acceptance is in current.md.

Managed frontend results are tracked by buffer identity, local ownership token,
original actual name, modification tick and native-view attributes. Name collision
allocates a unique result; killed/renamed/edited/repurposed results are not overwritten.
Checked bytes precede atomic-change-group content commit. Failure restores old
content/point/unmodified state and disabled undo; the post-rollback tick permits
later reuse. Display errors preserve committed reused content and remove only
new allocations. Explicit source buffers use a distinct fresh prefix and no display.
No extra cleanup command, source reference or source-lifetime coupling introduced.
Independent compiled loading verifies module ownership, signatures, commandp and
Org mode metadata.396core/110focused/9real/complete Nix compile/lint acceptance
passes on pinned x86_64-linux; current evidence retains limits and exact hashes.

The result does not retain the source buffer. Pure lowering does not read a
buffer or start a worker.

## Ownership and snapshot contract

- Issue6 user-committed repair retires file identity at final exit for owned root
  composition, INCLUDE capture and bibliography discovery buffers. Object-captured
  unwind-protect preserves processing context and error propagation even after
  callback current-buffer switches. Four actual kill-entry/native regressions
  fail before and pass after repair. Interactive INCLUDE feedback exposed an
  ambient-buffer configuration guard bug; bibliography transaction checks now
  explicitly inspect the captured source. Five maintained tests plus eight actual
  exact-fixture tm/PDF exports pass; revised406core/9real/full Nix compile/lint
  pass. User reports revised interactive INCLUDE retry meets expectations;
  committed blobs/diff/message match accepted candidate and reviewed draft.
  Exact evidence and acceptance status in memory/current.md/evidence.md.
- Prepared input owns copied AST/string structure, rebuilds parent links, and
  remaps identity-keyed INFO/island/post-blank data.
- Cyclic, multiply owned, detached, duplicate, deferred, or opaque inputs are
  rejected at the documented boundary.
- Source text and supported parser settings are captured coherently and checked
  across worker waits and after lowering.
- Output INFO and formatter selection use the conversion snapshot.
- Package behavior preserves source text, modified state, point, mark,
  narrowing, text properties, and unrelated Org callers.

## Text and provenance contract

- Structural lowering produces UTF-8 TeXmacs-shaped strees.
- Ordinary Org leaves use literal/source-code semantics. TeXmacs-looking text
  such as `<alpha>` remains literal.
- STM leaves use TeXmacs source semantics. Native notation retains native
  meaning; literal angle brackets must be represented by STM source notation.
- Body-relative source-semantic paths retain authored STM and generated native
  bibliography provenance until encoding is complete.
- Style names and initial keys use identifier semantics. Explicit native initial
  values use TeXmacs source semantics; Org-derived entries have literal provenance
  in the document's initial-literal-keys until native encoding.

## Original released subset in v0.3.0 and v0.3.1

- Paragraphs, supported inline emphasis/literal objects, line breaks, external
  links from the finite URI protocol set, and anonymous inline footnotes.
- TeXmacs blocks and configured inline fragments.
- Restricted options and filtering for tasks, archive, select/exclude,
  comments, tags, H, num, and toc.
- Rich title/author/explicit date metadata and five relative headline levels,
  numbering, UNNUMBERED, ALT_TITLE, and low-level nested lists.
- Unordered, ordered, and description lists; quote and center containers.
- Static example, fixed-width, and source blocks without execution.
- Basic rectangular tables with structural rule borders.
- Static TOC with deterministic labels, hlink, and pageref.
- Document style, structured initial environment, body, and provenance applied
  to one native session with combined readback.

Unsupported content fails explicitly. Released non-support includes general
internal/file/ID links, named footnotes, citations, bibliography, arbitrary
references, dynamic source execution, advanced table semantics, unrestricted
export preprocessing, and arbitrary Org element coverage.

## DOC-01 committed local-link extension

The first resolution node is committed as
the local-link resolution revision; this extension is included in v0.4.0.

- A pure analysis phase in the document layer scans the prepared AST, treating
  STM islands as opaque, and returns conversion-local identity-keyed links and
  labels. It retains no source buffer and performs no global ID lookup.
- Body/headline-title links resolve same-document `CUSTOM_ID`, `ID`, explicit
  `*Headline`, or fuzzy targets. Matching uses exact raw headline titles;
  dedicated paragraph targets take precedence over same-named headings.
- Only referenced targets receive deterministic `org-texmacs-ref-N` labels,
  skipping static labels in visible STM islands. TOC labels have a separate
  namespace. Low-level headlines also receive their reference labels.
- Described links become `hlink` nodes; undescribed links become native
  `reference` nodes. Direct paragraph targets become invisible label nodes.
- The buffer adapter resolves `ID`/`CUSTOM_ID` properties before removing their
  source drawers. The existing input constructor copies these properties;
  analysis uses that owned copy and introduces no new ambient parser settings.
- Missing or ambiguous links fail during structural preflight, before STM
  worker requests. Cross-file IDs, named-element targets, text-search fallback,
  file/resources, and internal links in metadata/ALT_TITLE remain unsupported.

Maintained tests establish structural and native readback behavior, not visual
reference values or typesetting. See `memory/evidence.md` for validation gaps.

## DOC-01 committed named-footnote node

Committed as the named-footnote revision; the verified diff matches.

- Pure document resolution maps named references to one owned separate or
  labeled inline definition. Definitions may follow the first reference.
  Missing/ambiguous definitions and nested footnotes fail during preflight.
- Preparation collects definitions before headline pruning, restores only
  definitions needed by visible references into the AST, and discards unused
  separate definitions and their island requests. It never reads a fallback
  source buffer. No detached definition forest or new public input slot is used.
- First use emits `footnote` with a `surround` prefix label; later uses emit
  `rsup` with a right-shaped native `reference`. Private `org-texmacs-fn-N`
  anchors avoid static STM labels and do not assume native counter numbers.
- References remain direct paragraph children. Separate bodies support the
  existing paragraph/list/container/static-block/table subset; normal fragment
  discovery applies to their paragraphs. At that original node, inline bodies retained
  the inline subset without STM discovery; the current Issue10 delivery above
  extends that boundary. STM/file provenance composes through the body
  wrappers and is emitted once.
- The source's `org-footnote-section` joins the copied/rechecked parser settings.
  Its special headline is omitted after definitions have been collected.
- Maintained native readback covers shared labels, mixed anonymous/named notes,
  Unicode and literal encoding. Rendered numbering and style expansion are
  unverified at that node; this capability is included in v0.4.0. Subsequent
  PDF semantic evidence is recorded in the consumer section below.

## Committed source-location snapshot node

This node is committed as the source-location snapshot revision and its diff
matches the recorded verified worktree hash.

- Owned input and document results retain optional `source-file` and
  `resource-base` strings. Source file identity never overrides the resource
  base. Pure callers provide explicit absolute strings or leave them nil.
- The buffer adapter captures the base buffer's file identity and the explicit
  source buffer's effective `default-directory`, including indirect-buffer
  overrides. It expands home abbreviations once during preparation, without
  canonicalizing symlinks or reading linked files.
- Copied original location strings join snapshot consistency checks, detecting
  changes and in-place mutation even when source text is unchanged. Pure input
  and document results own independent copies and do not expand paths or run
  file handlers.
- The following local-file node uses the captured resource base only at its
  native consumer boundary; source identity never overrides it.

This node passed 217/217 local ERT and byte compilation, then Nix
package/ERT/package-lint checks using the user's temporary, uncommitted remote
mirror-source configuration. The overlay is not part of the project change.

## Committed local file-link node

- Document results add `file-paths`, body-relative paths to raw Org file-link
  target leaves in `hlink` nodes. Raw relative names remain unchanged until a
  consumer translates them. No `file:` URI is fabricated to recover structure.
- File targets are resolved from the owned AST and captured resource context.
  Plain local body links, including implicit relative and absolute links, are
  supported. No-description links display the raw path; images are not embedded.
  File searches, application hints, tilde/remote targets/context and title or
  metadata file links fail structural preflight explicitly.
- Pack/lowering operations propagate independent file-target and STM paths.
  Native preflight rejects duplicate/invalid/out-of-bounds markers, markers
  outside hlink target roles, and overlap with STM; native source hlinks are
  not reinterpreted as Org file resources.
- The native bridge rewrites marked target leaves on a fresh body copy to
  absolute system paths using only the captured base. The existing TeXmacs
  literal encoder and native URL handler preserve spaces, Unicode, literal
  angle brackets and percent characters. It does not read linked files or
  query the caller's current directory. The original result remains unchanged.
- Native string navigation initially rejects `#`, `?`, `*`, `$`, `|`, backslash
  and square brackets in expanded targets. Structural results may preserve
  these paths for other future consumers; this native consumer fails explicitly.
  Actual GUI navigation/rendering remains unverified.
- The worker transport/protocol and Scheme service are unchanged. The node is
  committed as the local file-link semantics revision and passed ERT 223/223 plus Nix package/package-lint/ERT checks with
  the user's separate temporary mirror-source configuration.

## DOC-01 explicit bibliography snapshot foundation

The owned bibliography foundation revision matches the verified diff.
Its default citation/bibliography consumer is committed below.

- Buffer preparation and both conversion wrappers accept an optional alist of
  path-to-BibTeX-text source snapshots. Paths are identities, expanded once
  against the captured Org resource base. No bibliography file is opened.
- Delivered Issue12 fix delegates BibTeX grammar and field interpretation to native
  TeXmacs. No Emacs BibTeX helpers, entry-type/value whitelist or raw type/key/field
  signature equality remains. Parser recovery and unused-field omissions are native
  behavior, not independently rejected.107focused/464fullERT/9real extension
  integration and full flake/strict compile/lint verified. User-committed delivery
  matches exact validated patch/19input hashes; remote Issue12 closed/completed. Detailed contract: memory/issue-12-review.md.
- Existing parse-bibliography request returns the full native document (including
  opaque metadata), normalizing empty output to (document). Source notation and
  structured fields remain owned. Copy checks finite stree/document and consumed
  entry/field shape, not duplicate fields/unused keys; duplicate paths still fail.
- Preparation snapshots and guards sources/config/dependencies, runs source-only
  citation checks, parses each owned bibliography text once, owns native ASTs,
  resolves actual used keys and structurally preflights, then parses STM islands
  and formats final collision-free native output. No fake entry AST/signatures.
  A temporary formatted bib-list is preflight-only and never escapes in input.
  Text/path/list/alias mutations still invalidate the transaction around waits.
- Original dependency trees remain in prepared input; document results hold
  the native formatted output rather than the original entry forest.
  The following implemented node consumes it for citations and bibliography output.

## DOC-01 default citations and native plain bibliography node

Committed as the citation and plain bibliography revision, matching the verified
eight-file diff. This bounded capability is included in v0.4.0.

- Preparation captures explicit document BIBLIOGRAPHY identities before pruning,
  using the fixed source resource base and provided text snapshots. No global
  bibliography/export processor or file/database lookup is invoked.
- Pure planning resolves bare default ASCII-key groups only against effective
  declared native AST entries. Used missing/ambiguous keys fail after bibliography
  parsing, before STM/format requests; unused duplicate keys remain owned.
  Unavailable source identities/unsupported citation syntax fail before native work.
  Footnote bodies are visited at first use; repeats do not duplicate entries.
- One option-free PRINT_BIBLIOGRAPHY is required for citations. Native plain
  formatting occurs during preparation. The owned INFO view contains prefix,
  key order, selected entry trees and the source-semantic bib-list body. Pure
  lowering validates that view, every generated label (including duplicates)
  and native cite/reference/pageref targets. Both Org cite groups and bibliography
  output use native with-bib prefix context; the bib-list subtree retains STM
  provenance. Private prefixes avoid authored static STM labels. No worker in
  pure lowering; no automatic uncited dependency expansion.
- Generated bibliography roots join source-semantic provenance in stm-paths.
  Native Cork text is converted to UTF-8 while ASCII source notation is retained.
  Native prefix/style/default-style values are restored on success/error.
  Formatting domain errors preserve the worker; invalid payloads stop it.
- Styles, nonempty affixes, print options/multiple locations, and non-paragraph/
  inline-footnote citation contexts remain unsupported. No dependency-field name
  blacklist: native style owns interpretation/omission. Native dangling references
  fail as document errors while valid existing selected references may export. No automatic heading or source-order
  numbering is assigned. Native readback is not GUI/typesetting verification.
- Source identity/text copying now resides in the source layer, so context
  preparation does not depend on document lowering for declaration capture.

## DOC-01 committed named/captioned basic tables

the named-table and caption revision matches the verified five-file diff.

- Fuzzy resolution includes visible basic table NAME targets before headline
  titles. Referenced name/target collisions remain explicit ambiguities.
- Preparation records affiliated keyword names from the private source snapshot;
  only table NAME/CAPTION are admitted. Repeated names, empty captions and
  other affiliated keywords fail before island requests.
- Caption long/short pairs are copied as owned secondary Org nodes, with parent
  links rebuilt and mappings retained through filtering. Pure lowering reads
  neither source buffers nor installed styles.
- Captioned tables use native big-table and optional caption-detailed. Private
  reference labels sit inside the caption after native counter binding.
  Uncaptioned named tables permit described hlinks only, with an invisible
  surround anchor; unused names do not change the table tree.
- Rich captions support the existing inline text/markup and links, without STM
  discovery. Citations and parsed footnote objects are unsupported there; Org's
  caption grammar leaves footnote-looking text as literal text. Generated
  caption leaves retain ordinary encoding and compose typed file paths.
- Five focused tests plus the eighteen-case citation/footnote/table regression
  selector pass. Full local ERT passes 238/238 + 11/11; Nix compilation,
  package-lint and installed ERT 249/249 pass with the unchanged temporary
  mirror configuration. The verified node is committed as stated above.
  Displayed numbers, caption layout and pagination remain unverified;
  figures, other named elements and
  advanced table semantics are outside this node.

## CONSUMER-01 committed native file-document serialization

the native serialization revision matches the verified five-file diff.

- Public org-texmacs-document-serialize consumes a completed document result.
  The existing native bridge validates/owns its wire, resolves typed file
  targets against the captured source base and encodes body/initial once.
- A native worker helper directly builds document/TeXmacs/version, style tuple,
  body and optional initial/collection/associate structure from encoded fields.
  The version is the running TeXmacs's version, not the package version.
  Native serialize-texmacs returns exact output bytes; ASCII hex transports them
  and the bridge returns an unibyte string, without a UTF-8 decode step.
- No session, output file, Org exporter, resource read, live reference table,
  attachment, auxiliary state, typesetting or PDF/preview is introduced.
  Source-side link meaning remains independent of an eventual save directory.
- Preflight/encoding/serialization errors preserve healthy transport. The new
  shared serialization-error condition is operation-specific; malformed hex,
  version/header or operation payloads stop the worker.
- Four focused cases pass, including native serialize/parse tree roundtrip,
  Unicode/literal/STM/initial semantics, exact byte transport, disposed-source
  document features, error recovery and unchanged live-session readback.
  Nix first found an obsolete string-as-unibyte compile warning; the bridge now
  creates a zero-filled unibyte string directly. Full local 242/242 + 11/11
  passed before that adjustment; final focused 4/4 and Nix compilation,
  package-lint and installed ERT 253/253 pass. The verified node is committed;
  the temporary overlay remains unchanged and excluded. GUI/layout remains
  unverified; new-file saving is covered by the bounded consumer below.

## CONSUMER-01 committed explicit new-file saving

the explicit new-file saving revision matches the verified three-file diff.

- Public org-texmacs-document-save consumes a completed document and an explicit
  absolute local destination. It copies that path before waits, rejects existing
  files/directories/symlinks and requires an existing parent directory.
- Native serialization completes before file creation. A private unibyte buffer
  writes exact bytes with no-conversion and write-region mustbenew=excl.
  Exclusive open rejects files, directories and symlinks created during waits.
  Native/source resource semantics do not depend on the save directory.
- Destination filesystem operations suppress file-name handlers; byte writing
  suppresses format conversion, annotations and modification hooks. Caller
  text, point, mark, narrowing, modified state and file identity remain intact.
- Encoding/serialization failures create no output; standard filesystem errors
  propagate. A write failure can leave a partial new file, explicitly documented
  and covered by maintained failure injection. No speculative cleanup, directory
  creation, overwrite, backup or atomic publication is provided.
- Four new maintained cases pass in the combined eight-case serialization/save
  selector. Full local 246/246 + 11/11 and Nix compilation/package-lint/installed
  ERT 257/257 pass with the unchanged temporary mirror overlay. Three explicit
  files were approved/staged and then committed. The Scheme service and
  serializer protocol are unchanged; only the explicit saving API writes files.

## CONSUMER-01 committed explicit-source export adapters

the explicit-source export adapter revision matches the verified four-file diff.

- Public org-texmacs-export-from-buffer takes an explicit source buffer and
  optional BibTeX text snapshots, returning native .tm bytes. It composes pure
  lowering/native serialization inside preparation's final consistency check.
- Public org-texmacs-export-to-file validates/owns an absolute local destination
  before preparation, obtains checked bytes with that adapter and writes them
  once afterward. No second source parse/lower/native encoding is introduced.
- Destination validation and byte writing are shared private native helpers,
  also consumed by document-save. Exclusive creation, byte/annotation/handler
  isolation and the partial-new-file error boundary are preserved.
- Source text/location/parser/narrowing/mode/lifetime and bibliography changes
  across native waits reject exports before any file output. Source snapshots
  and destination identities have distinct ownership and lifetimes.
- Four new maintained cases pass in twelve combined focused cases: native byte/
  file equality, caller/source base separation, single serialization per export,
  source and dependency waits, target mutation, preflight and generic hook/pipeline
  isolation. Full local 250/250 + 11/11 and Nix compilation/package-lint/installed
  ERT 261/261 pass with the unchanged temporary mirror overlay. Four approved
  files were staged and then committed. No Org backend/dispatcher, output
  buffer preview, overwrite or unrestricted preprocessing is added.

## CONSUMER-01 committed interactive exports and readonly byte views

the interactive export revision matches the verified three-file diff.

- Public org-texmacs-export-to-buffer exports an explicit source, then creates
  a fresh unibyte readonly special-mode buffer with no-conversion coding, no
  visiting file, no file format and no save offer. It is a derived native source
  view, not rendered TeXmacs output; no source pointer/synchronization is retained.
- Lisp calls return the buffer without display; M-x calls capture the current
  unnarrowed Org source and display the result. Source failure creates no buffer;
  initialization/display failure removes only the newly allocated buffer.
  Mode hooks and mode-change callbacks are isolated while initializing the view.
- Existing export-to-file is now interactive: capture source/directory before
  the file prompt, suggest the source file stem or export.tm, then reuse the
  explicit source/new-file adapter and report the copied output path.
- Invalid/non-Org/narrowed sources fail before prompts; remote working directories
  are outside this interactive file chooser's subset. Interactive calls pass nil
  bibliography snapshots; Lisp callers still pass explicit texts. No bibliography
  file reader, Org backend/dispatcher or overwrite policy is added.
- Four new cases pass in sixteen combined focused tests. Complete local ERT
  passes disjoint 105/105 + 149/149 + 11/11, after the old 254-case bucket timed
  out at 120s. Nix compilation/package-lint and installed ERT 265/265 pass.
  The verified node is committed; the temporary mirror overlay stays excluded.
  Display and prompts are simulated; actual GUI layout is unverified.

## CONSUMER-01 committed native PDF consumer

the native PDF consumer revision matches the verified seven-file diff.

- document-pdf returns unibyte native PDF bytes; document-save-pdf uses the
  exclusive new-file writer. export-pdf-from-buffer and export-to-pdf keep
  native rendering inside the source/dependency consistency check; the latter
  also supports M-x with a captured source and a .pdf destination suggestion.
- The native bridge encodes owned fields once; headless Scheme installs them
  directly in a temporary native buffer, originally invalidated layout three
  times before print-to-file. The accepted PDF-link repair below adds forced
  synchronous layout before each print. The earlier citation repair adds another
  three invalidations and final print to resolve typeset bibliography references.
  It does not reparse serialized .tm or run deferred
  generate-all-aux/bibliography generation. Existing public sessions are isolated.
- Temporary files are in the worker's private directory. Buffer/file cleanup
  runs on success and rendering errors; cleanup failure or malformed PDF output
  stops the worker. Font caches have normal TeXmacs lifetime.
- Explicit resource/executable trees image/include/extern/script/action/eval/
  raw-data are rejected. Native installed styles/fonts remain dependencies;
  custom styles are not sandboxed. Fixed update passes have bounded reference
  evidence, not a general convergence guarantee. GUI/visual preview is absent.
- Installed ERT uses test-only Poppler inspectors for PDF structure/text and
  heading/table reference values. PDF binaries are never GAW artifacts.
- New semantic regression exposed unresolved citation markers [?, ?]/[?] despite
  populated numbered bibliography. The committed two-print fix the PDF semantic regression and citation repair revision
  resolves these markers; eight focused cases pass, including footnote bodies/
  markers and each print phase's failure/recovery. Final installed ERT 273/273
  (122.88s) and all Nix checks pass. The PDF semantic regression and citation repair revision
  matches the verified three-file hash. Normalized text assertions have no byte/pixel/coordinate
  or fixed-pagination dependencies; inspectors are mandatory in installed ERT.
- Six PDF cases, full local 271/271 and final Nix compilation/package-lint /
  installed ERT 271/271 pass. The verified node is committed;
  the temporary mirror overlay is excluded.

Supplementary derived-state probes on the committed PDF-link repair use2styles
and short/flow documents across direct/reload2/reload6. All12retain correct
checked TOC/heading/citation/repeated-note target pages; pagination and normalized
text stable for these fixtures. Exactly1dangling first-use footnote destination
per PDF subsequently reproduced in20native-only controls, even bare footnote;
package wrapper not necessary. Literal native forward/body prefix agrees, but
runtime binding/PDF destination loss/mismatch untraced. Do not claim all footnote
links valid or a generic convergence guarantee. User later supplied independent
native interactive reproduction and agent verified its PDF missing first target;
no package worker necessary. Other versions/configurations remain unverified. See memory/pdf-adjacent-checks.md.

## CONSUMER-01 committed bounded ox-texmacs frontend

the bounded ox-texmacs frontend revision matches the verified six-file diff.

- Optional ox-texmacs.el registers texmacs, menu key T with T/t/p actions for a
  fresh readonly native byte buffer, prompted new .tm and prompted new PDF.
  It requires org-texmacs; loading the core alone does not register this menu.
- Frontend commands accept Org's five optional arguments but reject every
  non-nil value, active regions and narrowing before prompts/conversion. Only
  synchronous complete-buffer export is implemented; bibliography snapshots
  are still supplied through the existing explicit-source Lisp adapters.
- Menu actions call the owned-input/native consumers directly. A conditional
  early Org before-processing hook rejects generic org-export-as/to-buffer/
  to-file for texmacs and derived backends before INCLUDE/macros/Babel. It is
  inert for unrelated backends. Generic string-transcoding/publishing is absent.
- Buffer display follows org-export-show-temporary-export-buffer; a display
  failure removes only the new view. File prompts capture source identity and
  reuse exclusive new-file writing. Frontend tests exercise actual dispatcher
  argument flow, .tm/PDF bytes, prompt context switches and source waits.
- Module allowlist, Nix fileset and straight README recipe include the file.
  Only the module fileset hunk may be staged in flake.nix; mirror changes stay
  unstaged. Seven focused cases pass 7/7 (2.63s); final Nix passes all seven
  checks, compilation/package-lint and installed ERT 280/280 (123.36s).
  That initial frontend used new-file prompts. Its naming/overwrite policy is
  superseded by the verified extension below; atomic publication remains absent.

## Committed Org output convention extension

the Org output naming and repeat-export revision matches the verified five-file diff.

- ox-texmacs file actions now use org-export-output-file-name for .tm/PDF.
  EXPORT_FILE_NAME takes precedence over visiting file stem; non-file unnamed
  buffers prompt. Source/context/destination identities are captured before waits.
- Preparation consumes EXPORT_FILE_NAME as inert output metadata; no native
  text transcoder, generic preprocessing, bibliography reader or new input slot.
- Frontend target preflight/recheck permits a local writable regular or absent
  file in an existing parent. Known symlinks, directories and source aliases fail.
  Unsaved visiting sources with an output suffix also receive a distinct name.
- Native bytes finish under source consistency checks before ordinary write.
  Shared private writer's optional overwrite flag is used only by this frontend;
  all public new-file save/export APIs omit it and remain exclusive. No encoding
  conversion, newline insertion or write annotations. Write failures can leave
  partial output; no backup/atomic replacement/version-lock guarantee is adopted.
- Eleven focused cases pass (5.32s), covering naming/reexports, exact raw bytes,
  non-file prompt context, stale sources, renderer failure and partial-write errors.
  Final Nix passes all seven checks, compilation/package-lint and installed
  ERT 284/284 (125.71s). The verified output-convention node is committed;
  the uncommitted mirror overlay stays unchanged/excluded.

## Committed subtree selection/configuration/dependencies

the subtree export revision matches the verified six-file diff.

- Existing prepare-buffer, document-from-buffer, .tm/PDF byte adapters and
  readonly byte-buffer export accept optional third subtree-position after
  bibliography sources. Nil remains full-buffer; a validated source integer
  selects its containing heading in a complete private snapshot.
- Restricted Org subtree helper overrides file/global title/author/date/options/
  select/exclude tags. Output file names use Org subtree property conventions.
  Property inheritance/separators/global property tables are copied and rechecked
  across waits, with private inheritance marker and live point restoration.
- Root heading/planning/drawer become configuration and are absent from body;
  child headlines use remaining relative minimum level. Known EXPORT properties
  are inert in whole-buffer lowering; unsupported root fields/options and
  CITE_EXPORT fail. No source narrowing or selected-text reconstruction occurs.
- Used separate/inline footnote definitions are restored from the full parsed
  snapshot. Only emitted body/dependency STM requests run. Paragraph span mapping
  follows clipped AST traversal when restored definitions have earlier positions.
  Unsupported out-of-scope body trees are ignored; global preprocessing directives
  remain rejected. Internal targets must exist in emitted AST; omitted root and
  excluded/outside targets fail before worker calls.
- Full-source bibliography identities are retained with explicit text sources;
  selected citations require a bibliography print inside selected body. Existing
  source-file/resource-base and native provenance survive scope selection.
- Dispatcher subtreep now supports readonly buffer/.tm/PDF consumers, using
  captured selection and unchanged new-file/overwrite contracts. Region/visible/
  body-only/async/extra external overrides remain unsupported. Generic API
  adaptation remains deferred; the separate Phase 3b opt-in reader is below.
- Final subtree 7/7, backend 11/11 and Nix compilation/package-lint/installed
  ERT 291/291 (132.40s) pass. Six files are committed; index was empty at
  subtree commit verification, before region work.
  Mirror overlay stays excluded; binary/generated artifacts do not enter GAW.

## Committed region selection

the region export revision matches the verified six-file diff.

- Five source preparation/document/byte/buffer adapters accept optional fourth
  REGION after subtree-position. It is an owned nonempty integer (BEGIN . END)
  pair. Existing nil/integer subtree calls keep their contract.
- Org 9.8-pre region body selection takes precedence over subtree narrowing;
  subtreep still feeds get-environment and output naming. Frontend captures both
  before prompts. Region with subtree keeps root EXPORT configuration but does
  not remove a heading included in region body.
- Full snapshot AST supplies file/global metadata, declarations and footnotes.
  A private narrowed Org parse of the same masked source supplies exact body,
  including partial ordinary text; there is no selected-source reconstruction.
  Matching selected footnote definitions replace their full-AST identities to
  avoid duplicate imports. Only retained body/dependency native requests run.
- Truncated discovered STM fragments/native blocks fail before worker calls;
  block trailing blank lines need not be selected. Supported filtering and link
  resolution operate on emitted AST, preserving source/resource provenance.
- Region pair/point/mark changes across waits cannot redirect captured selection.
  Source/configuration edits still reject results. Stable tests cover selection,
  complete islands, dependencies, scoped targets, native outputs and source state.
- Focused region 7/7, subtree 7/7 and backend 11/11 pass. Final Nix passes all
  seven checks, compilation/package-lint and installed ERT 298/298 (162.69s),
  after correcting one docstring-width failure. Six files are committed on
  the subtree export revision; index is empty at verification. Mirror overlay is excluded.

## Committed restricted external configuration

the external configuration override revision matches the verified five-file diff.

- User deferred body-only fragment semantics and selected bounded ext-plist.
  Five source preparation/document/byte/buffer adapters add optional fifth
  EXT-PLIST; dispatcher uses its existing fifth argument. No new owned-input
  slot, worker operation, file reader or generic preprocessing is introduced.
- Only context-option-alist keys are accepted. Metadata values are raw Org
  strings/nil parsed in private keyword grammar; policy values use existing
  typed constraints. Plist must be proper and unique; invalid keys/types reject
  before frontend prompts/workers, even if higher-priority settings override them.
- Owned copies of plist/strings/tag lists merge global < external < file <
  subtree. Metadata presence is retained when no file keyword exists. Caller
  mutation during prompts/native waits affects only later calls. Pure lowering
  consumes prepared INFO. Output paths/hooks/style/initial/parser/bibliography
  are excluded from external options.
- Final six override cases pass; backend 11/11, subtree 7/7 and region 7/7 pass.
  Compilation/package-lint and final installed ERT 304/304 (169.37s) pass, with
  all Nix checks successful. Two 81-column docstrings were wrapped; mutable test
  lists now allocate afresh. Five files are committed on the baseline region export revision;
  index is empty at verification. No visual/layout goldens or binary GAW artifacts.

## Committed narrowed source selection

the narrowed-source export revision matches the verified six-file diff.

- Existing narrowing is outer body scope. Region must fit and takes precedence;
  otherwise intersect subtree body with accessible range. Empty narrowing is
  valid, while explicit region stays nonempty. Public signatures are unchanged.
- Core captures initial integer bounds and checks them across waits/consumption.
  Complete text is copied with a brief saved restriction, restored before any
  parsing/callback/wait; actual Org parsing uses private full/scoped buffers.
  Configuration and needed footnote/bibliography trees remain from one snapshot.
- Private heading/naming copy can resolve hidden root EXPORT properties and
  file naming keywords. A frontend subtree position captures accessible point,
  not an inaccessible heading. Source filename metadata is bound only during
  private lookup, without creating a visiting buffer. Deferred file prompts run
  in original source restriction outside private property bindings.
- Changed restriction at prompts/waits rejects output; external changes are not
  rolled back. Existing text/settings checks and truncated-island/link preflight
  remain. Stable tests cover complete source state, dependencies, intersection/
  region priority, empty scopes, private naming and stale output preservation.
- Final narrowing 7/7, backend 11/11, serialization 16/16, subtree 7/7,
  region 7/7 and overrides 6/6 pass. Final Nix passes all seven checks,
  compilation/package-lint and installed ERT 311/311 (176.95s). First full run
  310/311 exposed a wrong updated legacy expected body (normalized trailing
  space/concat); assertion corrected. Six files are committed on the external configuration override revision;
  index is empty at verification. No binary GAW evidence, GUI or layout goldens.

## Released v0.4.0 scope and provenance

- Release target the final HTML coexistence regression revision includes metadata
  the v0.4.0 release preparation revision and the final controlled HTML regression; both verified by exact diff
  hashes. Annotated tag object feaf8c4ef501d50aa595090a0fa312c855071527 is the
  same locally and in GitHub and points to this commit.
- GitHub release https://github.com/ren-lingyu/org-texmacs/releases/tag/v0.4.0
  is published, draft=false/prerelease=false, at 2026-10-08T17:27:12Z.
  User completed release operations; agent made read-only identity checks.
- v0.4.0 adds current bounded local-link/file-context/named-footnote/citation/
  bibliography/named-table semantics to the earlier document subset. Independent
  native .tm serialization/save/PDF and readonly byte buffers, optional Org
  dispatcher, naming/reexports, subtree/region/narrowing and restricted ext-plist
  are released. Detailed support/error/ownership contracts above still apply.
- Final focused backend 12/12 and no-overlay Nix installed ERT 312/312/all checks
  passed before commit/tag, with cache reuse. Controlled HTML hook/advice/AST
  filter coexistence is verified; actual external-package/database integration
  is not. No general preprocessing/generic exporter, GUI preview or pagination
  convergence claim is introduced. ELPA HEAD probes timed out in agent environment.
- Local tag contains a PGP signature block; cryptographic verification was not
  performed. Source archives/assets were not downloaded. Prior tmp release notes
  are preparation drafts; published notes are the publication record.

## Worker and session

- One persistent headless TeXmacs worker serves parsing, encoding, and native
  session operations over a local Unix-domain socket.
- One active native document session is public. Updates validate/encode all
  fields before mutation, replace style/initial/body, and verify readback.
- Preflight errors preserve the session. Native update/readback errors discard
  it; cleanup or transport failure stops the worker.
- No `.tm`, `.stm`, or `.tmml` intermediate is required in the conversion path.

## Worker and native-bridge layering

- Shared package condition types live in core.
- The worker layer does not load the document layer. It owns process and socket
  lifecycle, request framing, generic response-envelope reading, and STM parse
  response semantics.
- The session/native bridge owns document preflight and wire serialization,
  native encoding, and native/session payload contracts. It depends on both
  the worker transport and the structural document representation.
- Application-level parse, encoding, and session failures preserve a healthy
  worker. Transport, framing, or invalid operation payloads stop it. A local
  request-construction failure before transmission also preserves it.

This boundary is implemented by project commit
the ARCH-01 layering refactor revision and covered by the maintained
worker, encoding, and native-session tests.

## Phase 1 committed bounded citation-key AST filters

Committed as the citation-key AST filter revision, with five-file diff on the
updated-lock baseline matching the validated candidate hash. Source adapter
captures effective source-local/global and backend
developer AST filters, resolves function identities and rechecks them across waits.
Run with actual named texmacs backend, locally available without installing menu
for core-only APIs, in the private complete masked Org snapshot after selection,
pruning/restored dependencies and STM mappings. No options-filter/buffer-hook or
generic exporter phase is introduced. Detailed contract: memory/filter-contract.md.

INFO is restricted/read-only: supported context options, backend object, explicit
input file/resource base, supplied bibliography path identities, processors nil;
final parse-tree/input-buffer/export caches are absent. Validate each callback's
same root, original graph topology/value/text properties, parentage, mappings,
INFO and private buffer/configuration. Only existing nonempty citation key values
may differ; citation collection enforces Org syntax/context, then native AST
planning resolves used keys and output-reference integration invariants.
After filters, reuse pure owning to detach AST/INFO/mappings and remap worker
requests before native waits; final input owning still copies parsed dependencies.

Focused 12/12 and full installed ERT 324/324, compilation/package-lint/all 8
independent-flake checks pass on Emacs 31.1 / Org 9.8.10. Native bibliography/key
semantics and session readback are verified; 21 source/lock/test inputs match
the ordinary worktree. Source/native consumers' earlier regression remains covered.
No real Org-roam integration, broader AST replacement or user callback sandboxing
is claimed. No public API signature, worker protocol or native consumer is changed.

## Phase 3b opt-in bibliography discovery/acquisition

Committed by the user as the opt-in bibliography discovery revision on the Phase 1
baseline; full committed diff matches validated staged bytes (evidence.md).
Independent org-texmacs-bibliography module, lazy autoloads from main and flake
fileset inclusion. Public document/byte wrappers end in
`-from-buffer-discover-bibliography`, preserving optional text/selection/options
arguments. Existing explicit APIs/menu/pure constructors retain defaults.

Private preparation accepts owned effective bibliography view with original raw
keyword associations and ordered discovered IDs. It validates actual declarations,
adds active identities as data, and preserves document/new-source distinction in
INFO; no synthetic keyword text, planner I/O or new input slot. Discovery uses
shared private parser/context helpers with fixed headings/links and masks every
inline/block STM, including pruned/out-of-selection content. Unsupported genuine
preprocessing fails before standard Cite collector, which runs once with normal
advice and copied global bibliography. Captured source-file/base directory must
agree for visiting buffers; non-file buffers use captured local base.

Own/classify/normalize/dedup paths. Explicit texts retain priority without stat/read
and unselected data remains owned. Append missing discovered local regular UTF-8
BibTeX <=1 MiB; reject symlink components, auto physical aliases, remote/URL/tilde/
control paths. Native parsing and safe consumed AST checks replace the old raw
text grammar in Issue12; file acquisition constraints stay fixed. Receipts observe
size/mtime/ctime/inode/device + byte SHA-256; verify around acquisition/native waits
and final document/byte return, never replacing text or replaying discovery/filters.
Whole source/config/filter/provided-text baseline precedes discovery; opt-in global
bibliography/collector/options/style/initial checks join existing source guards.
No FS/DB atomicity, ABA-proof, arbitrary callback sandbox, file publication or real
managed-package compatibility claim. Contract: memory/bibliography-contract.md.

Final 17/17 focused (7.708077s), 341/341 installed ERT (171.422224s) and all nine
isolated checks (eight project + focused) pass on locked Emacs31.1/Org9.8.10/
TeXmacs2.1.5. Maintained actual file acquisition/native parse/format/session readback/
bytes tests and controlled changes across discovery/acquisition/native/output.
HTML/ASCII/generic guard regressions remain covered. Twenty-two copied inputs
match project bytes; evidence includes hashes and preserved mirror overlay proof.
Phase 3a component evidence remains immutable at
archive/2026-10-13T13-27-14Z--c26b932/MANIFEST.md. Broader Phase2 composition
policies, Phase4 and file/menu policy
remain downstream work; issue #1 is not entirely closed by this node.

## Phase 4 accepted working-context and actual extension interoperability

User committed accepted Phase4 on native parameter revision; complete diff/message
and five committed blobs match reviewed/validated candidate. Preparation's existing
explicit buffer APIs consume completed working Org and supported normal context;
provider history not reconstructed. Cross-directory native INCLUDE now accepted,
private captured parser uses its own file directory, final root context retained.
No per-island original directory, general provenance or third-party read/DB adapters.
Relative BIBLIOGRAPHY/STM interpreted at final context; managed discovery supplies
its own normalized paths. Ordinary Org links natively relocated then existing typed
absolute native encoding unchanged. STM resource trees can pass, actual loading/
rendering not newly verified; existing PDF primitive restrictions retained.
Contract memory/working-buffer-context-contract.md. README states provider versus
final ownership guarantees; optional native provider receipts remain bounded.

Five new core ERT,32focused,7actual fixtures; full373core ERT189.379261s/all10logged
checks/strictcompile/package-lint pass. Real include/organize/blog modes, SQLite DB,
hooks/advice/query, selected recursion/parameters/mount/error paths, managed paths/
UUID filters/native bibliography, HTML and actual blog publication verified with
pinned source, no business-logic mock or external package patch. Optional maintained
Nix integration runner takes explicit runtime/extension sources; no default package
dependency additions, lock/mirror preserved. Other platforms/GUI/all configs/full
resource support/generic exporter/default frontend switch not claimed. Project
commit identity verified; immutable evidence archive in evidence/current memory.
Section18 formal frontend integration is now accepted as described below;
original review memory/frontend-preprocessing-plan-review.md remains historical.

## Phase 5 accepted formal frontend/preprocessing integration

User committed accepted Phase5 on verified Phase4 revision; seven-file diff/blobs
match tested candidate and full message matches user-edited draft. Optional ox-texmacs retains
backend/menu/keys and generic guard but full unselected unnarrowed commands now
use existing bounded preprocessing provider, with native parameters and current
ordinary-level/local/path/alias/UTF8/budget constraints. Subtree/region/narrowing
remain direct; unresolved ROAM_INCLUDE keyword/selected-root mount fail explicitly.
One preparation/document per invocation, serialize/PDF inside original provider/
source/config/hook/dependency checks. No fallback/second converter/general provenance.
Independent buffer-local boolean org-texmacs-export-discover-bibliography default
nil applies full/local; true reuses standard Cite discovery/fixed acquisition.
Capture route/options before naming/prompts, check discovery before/after consumers
and final return. False skips acquisition/collector but not external hook/filter DB
effects. Direct explicit APIs and explicit-text priority unchanged.
Shared readonly unibyte view initialization; original source naming/overwrite/target
protection/byte writer/display cleanup retained, write failure can leave partial
output. No new public preprocessed PDF adapter needed or native protocol change.
Contract memory/frontend-preprocessing-contract.md. README/API docs updated.

Eight new core ERT,79focused57.349582s,9real fixtures11.487037s,381core178.555109s,
all10logged isolated flake checks/strict compile/lint accepted. Actual include/
organize+SQLite three frontend outputs/discovery false-true/PDF normalized text,
missing nodes/local mount refusal, HTML before-after and actual blog publish;
existing selection/options/source/dependency/native failure regressions maintained.
25project+11foreign modules match manifests. Only x86_64-linux/pinned fixtures,
not all registries/GUI/general resource rendering/whole generic lifecycle.
Selected local issue#1 architecture/frontend complete and committed;
remote page failed to fetch, no external issue state/content claim/write.

## Phase 6 accepted and committed explicit dispatcher menu

Minimum Org API audit subsequently checks actual release_9.8 (locked source) on
Emacs31.1:54 direct-call interfaces/41 function references/87 declared capabilities
present with no direct arity conflicts,13 production modules strict-compile pass.
No API/signature reason to raise declared9.8 demonstrated. Full behavior regression
baseline remains9.8.10;9.8 full ERT/native behavior not verified. Raw evidence:
archive/2026-10-14T14-04-21Z--611cb70/MANIFEST.md.

Supersedes Phase5 fixed T/T/t/p menu policy only. Global option
org-texmacs-export-menu-keys defaults nil; named backend, generic guard and three
commands always registered. Complete explicit :prefix/:buffer/:file/:pdf character
plist configured before first require generates native menu after validation.
Graphic Unicode allowed, whitespace/control/modifier/surrogate/reserved keys refused;
three actions distinct, prefix may equal action. Existing disjoint same-prefix
submenus allowed; colliding actions/direct-function prefixes reject before registry
or guard changes. Owned generated menu; no live setter/watcher/refresh/fallback or
monitor of later backend registrations. Conversion/consumer transactions unchanged.
README explains default-menu removal, explicit pre-load example and direct M-x.
Contract memory/export-menu-contract.md; only frontend/README/core ERT changed.
386core/84focused/9real/5native/all10checks/strictcompile/package-lint pass in pinned
x86_64-linux isolation. Eight necessary raw text artifacts archived at
archive/2026-10-14T13-19-02Z--5f4c9c0/MANIFEST.md. Selected issue2 goal accepted,
user committed, exact paths/blobs/message verified against accepted inputs/draft.
Index empty, only user mirror dirty; remote issue state unverified, no issue write.

## Phase 2c accepted native preprocessing simplification

User selected new INBOX section16, superseding parameter-mirror extension plan.
Candidate on committed Phase2b/bibliography baseline uses actual native INCLUDE
with transaction-local fixed org-file-contents reader, actual path identities and
line-count-preserving protection of existing supported STM spans. Native location,
only-contents, lines, minlevel/headline/footnote/link operations retained; original
selected line interval checked only for partial STM, not generic coordinate mapping.
No occurrence mirrors or node origin annotations; original/final text and captured
path/text snapshots owned in INFO. Existing signatures/pure/input/native boundaries
unchanged. Contract memory/preprocessing-contract.md; README explicitly updates
removed origin fields. Common-base/full-root/ordinary-level profile retained.

Nine isolated native probes establish fixed reads/parameter semantics, STM literal
INCLUDE read, footnote renaming and raw headline-like text mutation hazards; scoped
line-preserving shielding comparison passes.27/27 maintained focused pass13.482343s,
complete368/368 installed ERT209.352130s, all five current flake checks pass.
Native output/footnotes/bib/filter/transactions tested;
no real package/GUI proof. Original Phase2b committed profile passed35 focused,
359 installed ERT/complete isolated check; its exact-origin/occurrence support is
replaced explicitly, not claimed for new candidate. User mirror remains unchanged,
lock unchanged and ordinary index empty. User committed accepted candidate;
complete commit diff/message verified against reviewed staged bytes.
Phase2a research archive remains immutable:
archive/2026-10-13T16-45-34Z--049a5a0/MANIFEST.md.

Issue #1 Phase 0 provides investigation evidence, not new production support:
14/14 isolated probes on the updated project lock's Emacs 31.1 / Org 9.8.10.
Public filter tools work with texmacs backend and preserve citation AST when
processors are disabled; full annotation also performs ambient ID lookup, and
native buffer copy aliases mutable locals. Source-coordinate and AST identity
mapping remain explicit integration boundaries. Locked Org has no after-includes
hook; latest-upstream ordering cannot substitute for version-specific evidence.
At Phase 0 the baseline included the user's committed lock update and uncommitted
mirror transport, with v0.4.0 Lisp. Phase 1 now adds the candidate above. See
evidence/backlog and
archive/2026-10-12T19-11-59Z--b229454/MANIFEST.md. This investigation does not
extend support claims, allow pure lowering I/O, or remove the guard.

Current direct source preparation supports bounded citation-key parse-tree filters
through standard Org install/apply tools. It does not run buffer-level export
preprocessing by default; protected composition and Cite discovery are opt-in above.
Standard key-only AST filters
can participate; other ecosystem extension semantics are not automatically
consumed by TeXmacs. Backend guard admits unrelated backends; maintained
isolation includes ASCII and the released controlled HTML composition
case below and now the selected real package/SQLite/frontend/HTML/blog fixtures above;
other package/database configurations remain unverified.
Selected information-flow design and frontend work is tracked in issue #1:
https://github.com/ren-lingyu/org-texmacs/issues/1. It preserves canonical source,
AST-first/ownership/provenance and is not a v0.4.0 release blocker.
Temporary org-collect-keywords rebinding is scoped to private restricted option
collection, not a permanent standard-interface replacement. Broader preprocessing reuse
needs contracts beyond the bounded adapter above; pure lowering/native bibliography
need not acquire implicit database/file dependencies. UUID syntax is accepted by
the current key grammar; absent matching entry/remapping causes unresolved-key
failure. Keep these distinctions in support claims.

HTML composition regression is committed as the final HTML coexistence regression revision and released in v0.4.0: controlled
preprocessing hook, include advice and AST filter run through actual HTML export,
with observable output transformations, original source state and advice cleanup.
No production/README change or real external-package integration is introduced.
Backend focused 12/12 and all no-overlay Nix checks pass; installed ERT 312/312
(157.82s). Its one-file diff on the v0.4.0 release preparation revision matches the verified hash. Direct authorized
HEAD probes timed out; source configuration now needs no overlay for this cached
validation, but endpoint availability is not independently confirmed.

Broader file metadata (attachments/reference tables/auxiliary), backup/atomic
publication, generic Org export/publishing beyond the bounded dispatcher, preview,
visual pagination, multi-document or multi-session operation, live or
incremental synchronization, and broader Org document-wide resolution remain
future consumer/document work. `memory/backlog.md` distinguishes adopted work,
deferred candidates, and unresolved design boundaries; unsupported entries in
this support matrix are not automatically implementation commitments.

## User delivery tracking preference

After verifying a user commit that references or closes an issue, also read the
corresponding remote issue state and compare it with the last verified state.
A closing footer alone does not prove closure. Update GAW selectively when the
verified tracking state, unresolved follow-up or next action changes; an unchanged
state does not require a checkpoint. If lookup fails, retain explicit uncertainty.
Read-only verification does not authorize external issue writes. User requested
this recurring delivery check on2026-10-16.

## Accepted local PDF hyperlink consumer repair

User selected release-readiness PDF links. Original12native/package/reload PDFs
had0annotations; forcing native layout restored them in8native causal controls,
then final package/native/reload12/12had URI/internal destination annotations.
Worker calls update-forced before each existing print, preserving two-print
reference handling, owned buffers/files and errors. Pure AST/encoding unchanged.
Two maintained ERT verify actual URI/cross-page targets/repeated renders/reload/
released-source ownership and both forced-layout errors/session isolation/retry.
README/reload helper synchronized. Baseline2intended failures,36focused/9real/
439core/full strict compile/lint/all7checks pass in locked x86_64-linux.
Three-file delivery user-committed; exact parent/paths/all25committed input
hashes/full patch/full reviewed fix(pdf) message verified. Index empty, only
user flake unstaged. Broader release remains
incomplete. Contract/commands/provenance/immutable archive:
memory/pdf-links-investigation.md.
