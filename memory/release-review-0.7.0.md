# v0.7.0 final release review

User selected final release preparation and manually changed root state to NEXT.
Only that root edit existed at intake; implementation delivered21d5704, accepted
12checks/705ERT, exact167hash receipt cite-processor-triplet-0.7.0-inputs.json.
Historical comparison baseline v0.6.0 at8ae5647. This is content/candidate review,
not authorization for DONE/CLOSED/tag/publication. User will manually mark DONE
if review passes. No publication date invented.

Review version/package metadata, README/interface and code commentary against
current implementation and maintained tests; consolidate root to concise user-
visible additions, changes, breaking migrations and limitations. Move necessary
usage detail to README and complete version notes; keep internal evidence here.
Preserve historical v0.6.0-and-earlier entries, root header/ID/link and NEXT.
No new feature, compatibility expansion or deferred parser reopening. Existing
native/Cite/full validation remains if runtime inputs do not change; checks should
match actual edit scope. Full worktree diff review and candidate receipt, human
commit draft if authorized, updated memory and checkpoint finish the node.

Initial verified drift: root examples paragraph claims citeproc/local CSL instead
of current native bibliography defaults. README overview mentions only CSL even
though native processor is default; standard integration section still says initial
backend. Version headers and Nix package already consistently use0.7.0; don't bump
correct versions merely for release work. Root header matches adopted canonical
Org profile. No original-byte archive needed for distilled request and maintained
source evidence.

## Completed review

Four paths only: CHANGELOG.org, CHANGELOGS/v0.7.0.org, README.org and main
Commentary. Root131->50lines, preserves notable user changes/Breaking guidance,
removes checklist and contradicted example-only CSL/citeproc dependency claim.
Detailed notes add five migration pairs/argument warning/native example/runtime
preference and retained rejection scope. README fixes CSL-only overview/initial
backend wording, native quickstart/print requirement, and unconditional source-
buffer preservation claim (user callbacks may modify original; guards don't undo).
Main Commentary now reflects native default plus optional CSL; versions untouched
because already consistent0.7.0. All historical root entries/header/ID/link preserved.

Scoped authorized120s build gate exits0: strict package compilation, package-lint,
treefmt and324core. Last text-only wrapping/table polish only changes README and
detailed notes; fresh final treefmt and document checks pass, runtime derivations
unchanged. Org AST validates16local file/heading/ID links. All5migration pairs
match runtime byte-obsolete-info; Emacs read/equal proves every main Lisp form
equal delivered21d5704. Original temporary doc driver emitted a lexical-binding
cookie warning, fixed in the final driver; no production warning/failure waiver.
No full native/PDF/integration repetition: previous exact implementation705ERT
acceptance remains, and no new behavior is claimed. Minimum Org9.8 runtime/other
platforms/full fields/Unicode/math recovery remain accurately limited.

Complete four-path diff, whitespace and167canonical hashes reviewed, index empty.
No identified final release-content blocker. Root remains human NEXT with no
candidate CLOSED; user will manually choose DONE/UTC actual transition time,
commit/tag/release separately. Human DONE may intentionally change receipt root
state/time; verify that separately from reviewed text, don't demand byte equality
with NEXT for the approved state transition. No ordinary project staging/commit.
Whole-diff draft follows user's established workflow: tmp/commit.md uses
'docs(changelog): prepare v0.7.0 release notes'. Report tmp/release-review-report.md.
Exact source hashes/check outputs/log hashes/limits in release-review-0.7.0-inputs.json.
No new raw archive needed. Uncommitted candidate is not exact HEAD; memory
checkpoint has no new project parent, unlike earlier exact delivery verification.

## Integrated configuration follow-up

User asks whether README has a complete configuration, then explicitly requests
one. Added Recommended complete configuration before Block formulas, named
example-use-package-complete. One use-package declaration combines core settings,
preload native Cite preference and menu keys, explicit backend require. Assumes
installed/on-load-path package, reuses earlier checkout/straight guidance; don't
stack earlier standalone declarations. Preserve Nix executable path, optional
absolute override is commented; menu first-load/fresh-session rule and plain/
alpha/abbrv/nil choices documented. Only README delta beyond accepted review.

Fresh -Q locked Emacs reads this actual Org source block and executes it. Verified
backend/menu T with T/t/p, full INFO (texmacs-native nil nil),11fragment tags,
packaged program unchanged, no worker process. Initial temporary driver used
nonexistent org-export-backend-menu-entry and wrong menu nesting; source inspection
confirmed actual org-export-backend-menu, corrected driver passes. No production
workaround. Fresh treefmt passes and final document links now17total; same5API
migration/form comparisons pass. Strict compile/324core and prior705functional
proof remain unchanged, not rerun unnecessarily. Input receipt and whole-diff
commit draft/report updated; root NEXT/human finalization untouched. No raw archive.

User confirms follow-up refinement: only menu in :init; export-time Cite preference
in :custom, explicitly (texmacs-native "plain" nil). README explains every slot,
changing only bibliography style for alpha/abbrv and keeping native citation style
nil, whole-preference nil delegation unchanged. Fresh actual-block Emacs run
passes with INFO (texmacs-native "plain" nil), menu/Nix/no-worker guarantees;
final treefmt pass. Updated canonical receipt/message/report. No other project
file change, no new runtime source behavior or release-state action.

Final user-selected organization: one complete declaration placed first under
With use-package, before installation details. Remove old core-only block and
three minimal installation declarations; present checkout/installed/straight as
keywords to adapt inside the same full declaration. Preserve all needed installed
Scheme-service/Nix/straight opt-out/pinning guidance and user's modified comments.
Parameter details follow. Exactly one use-package org-texmacs occurrence; removed
example names have no maintained references. Fresh actual-block Emacs validation,
16local links/5API migration/form checks and final treefmt pass; no runtime source
change or repeat full suites. Source receipt/report/message refreshed, NEXT and
human finalization remain unchanged. No raw archival need.

Final tiny wording request: commented (org-texmacs-program "texmacs") and one Nix
advice line replace three verbose comments/absolute placeholder. Exact snapshot
delta is those comments only, whitespace clean, no executable/config behavior
change or repeat gate. Canonical receipt refreshed; fold memory into next
substantive checkpoint rather than checkpointing each wording adjustment.

## Last read-only audit / DONE recommendation

Current full diff four paths reviewed again, versions/release state/index checked.
Receipt comparison shows only one README comment changed since accepted candidate;
all166other hashes match, so no unchanged tests repeated. One overlooked wording
ambiguity found at README2352: grouping INCLUDE/bibliography under retired custom
file receipts obscures active native bibliography source integrity guards. Compare
README1063, prepared-cite-check at prepared.el231 and native-source-final-text-
filter-change-is-detected at tests/ert-core/lisp/native-cite-source.el173. Active
exports do recheck fingerprints/bytes and reject .bib mutations; completed owned
pure consumers don't access sources. Recommend clarify this paragraph, then DONE;
no new functional failure or development work. Prior review's no-finding conclusion
is superseded only on this documentation point. Read-only audit leaves production
files untouched, root NEXT, no staging/tag/release. Current report/receipt capture
recommendation and corrected comment hash. No raw archive need.

## Corrected and accepted after iterative review

User explicitly authorizes correction then repeat review, continuing fixes if any.
Correct README dispatcher explanation plus two related document/source-byte API
paragraphs: separate retired parallel preparation/INCLUDE/receipt behavior from
active native bibliography fingerprint checks, and from completed pure consumers.
Cross-check prepared-cite-check, its post-native/text/PDF call sites and maintained
final-text-filter-change regression. No production code behavior change needed.
No further inconsistency identified after re-review, including version/upgrade/
Cite/style/STM/output scope. Recommend human DONE after reviewing final diff.

Final actual config and Org checks pass: native/plain/nil INFO, T/T/t/p menu,
11tags, Nix program intact, no worker,16local links,5migration pairs and identical
executable main forms. Final treefmt passes. Prior strict compile/lint/324core and
exact delivered705full ERT remain validation provenance; no redundant full suite
or native math visual repetition.167canonical hashes/4paths/index stable. Snapshot,
receipt/message/report updated. Current root NEXT, no CLOSED/tag/release action.
This resolution supersedes the last audit's conditional DONE recommendation.
No new archive or extra project parent for the uncommitted candidate.

## Human DONE and staged commit readiness

User manually marks DONE and asks whether to commit. Four reviewed paths fully
staged. Exact accepted content plus only NEXT->DONE and indented CLOSED at
2026-11-04 Wed18:45; observed UTC clock18:45:46 agrees. Actual Org parser recognizes
DONE, v0.7.0 CUSTOM_ID and CLOSED correctly. All167staged files match worktree,
other166accepted hashes unchanged; no partial or unstaged changes. Complete staged
transition and whitespace checked. Suitable as one cohesive docs(changelog) commit,
no split needed/low difficulty, no new runtime checks. Draft subject now finalize
v0.7.0 release notes, body covers human DONE/CLOSED and all actual four-path effects.
Receipt now captures human DONE/staged hashes/message for exact delivery check.
Ordinary commit/tag/release remain human, no new project parent before delivery.
