# Supplementary PDF derived-state checks (selected2026-10-16)

## Motivation, source and scope

User committed original PDF fix; exact committed delivery verified and recorded
in memory/pdf-links-investigation.md. User now asks for supplementary tests of
previously identified adjacent risks, and practical interactive steps where easy.
Current source is that committed fix, not original uncommitted repair candidate.
No business-code repair selected. Only tests/ert/ert.el modified; user flake
remains unrelated/unstaged. No issue association or external writes.

## Completed automated checks

One new ERT with generic/article x short/flow fixtures. Source combines TOC,
described forward/back links, undescribed numeric heading reference, first and
repeated named footnote, grouped/repeated citations, owned bibliography and
explicit native page breaks. Flow variant adds40paragraphs of plain English,
not new mathematical syntax. Derive expected target pages from unique body
markers instead of hard-coded pagination. Check TOC title destinations/page
values, citation1/2and repeated citation target pages, repeated footnote and
heading reference. Preserve source state. Existing Poppler inspector factored
to return XML tree; recursively read styled anchor text via dom-texts.

Safe ignored nonsymlink tmp/pdf-links-adjacent has25current source/lock/test
identities and independent locked flake. Probes produce12PDFs:2styles x2sizes x
direct/native .tm reload2prints/reload6prints. Independently inspect raw named
destinations/annotations with pypdf and visible links with Poppler; compare page
counts, marker pages and normalized per-page text hashes. Extra passes are a
controlled stability comparison, not an arbitrary-document convergence guarantee.
Native subprocess timeout30s. Maintained tests inspect semantic target pages;
same-page exact entry/viewport landing is additionally assigned to manual clicks.

User authorized these repeatable commands plus necessary locked dependencies/results copying:

1. timeout 240s nix build 'path:./tmp/pdf-links-adjacent#checks.x86_64-linux.probes' --no-link --no-update-lock-file --print-build-logs --print-out-paths
2. timeout 180s nix build 'path:./tmp/pdf-links-adjacent#checks.x86_64-linux.focused' --no-link --no-update-lock-file --print-build-logs --print-out-paths
3. timeout 600s nix flake check path:./tmp/pdf-links-adjacent --no-update-lock-file --print-build-logs
These may fetch locked dependencies and write private build/home/Nix store/cache
and task tmp/log/PDF results. No system Emacs, root lock edits or user config
changes. New-test baseline/current sources are committed repair plus test delta.
No extra original-defect red run needed for coverage-only changes unless a newly
reproduced defect needs an independent causal control. Failures require diagnosis,
not automatic expansion into business fixes.

## Concrete manual check plan prepared

Temporary manual.org/refs.bib use only ASCII content and no new STM math:
AlphaDestination/AlphaBodySentinel, OmegaDestination/OmegaBodySentinel,
FirstTitleSentinel/SecondTitleSentinel bibliography entries and
NamedFootnoteBodySentinel. Check ready probe PDF when generated; manual source
can also be opened in user's Emacs. Enable buffer-local
org-texmacs-export-discover-bibliography=t to read the adjacent generated refs.bib,
then standard org-texmacs-export-to-pdf. No global config change required.

Click TOC Alpha/Omega entries, ForwardToOmega and BackToAlpha; confirm headings
and page values. Click grouped citation1/2and repeated citation to respective
FirstTitleSentinel/SecondTitleSentinel entries. Click Again's repeated footnote
number to NamedFootnoteBodySentinel and AlphaNumber's reference to Alpha heading.
Automatic page checks do not by themselves prove exact same-page entry landing;
manual clicks intentionally cover that distinction. First-use footnote/backlink
features not demanded beyond existing native support. Compare optional native
.tm GUI re-export and flowing document TOC if useful. Record filename, clicked
text and actual landing; viewer behavior can leave precise viewport uncertain.
Full actionable Chinese checklist at task tmp/MANUAL.md. No GUI launched by agent.

17necessary original-byte text artifacts now archived and verified separately:
archive/2026-10-16T11-43-36Z--f4a194e/MANIFEST.md
No PDFs, full temporary workspace or duplicate native source retained. Existing PDF repair archive immutable.

## Diagnostic sequence

Initial probes generated all12PDFs but inspector stopped at missing named
destination /label6 in article-flow-direct.pdf. Poppler identifies empty href
on first-use footnote marker. This was a new observation, not a conclusion about native responsibility;
subsequent complete matrix confirmed repeated references remain valid. Original failed output
preserved in tmp/pdf-links-adjacent/initial-probe-results. Inspector was amended to record all dangling destinations instead of aborting
at the first; the same authorized command then completed matrix diagnosis. No business repair made.

## Completed matrix and focused findings

All12PDFs generated and inspected: generic/article x short4pages/flow9pages x
direct/reload2/reload6. Each has19raw annotations, exactly1missing named target
/label6 from the first footnote marker on page2. Poppler exposes an empty href
at First's marker, while repeated Again note links to page2. Extra native
reload/layout passes do not remove this observation. This separates it from
original all-links-missing defect, but does not establish whether incorrect
package tree or native footnote handling is causal. No repair in this task.

Page count, marker-page mapping and normalized per-page text agree across all
three consumers for all4fixtures. Focused6/6passes19.054185s; new ERT checks all
4direct PDFs for TOC values/links, forward/back described links, numeric heading
reference, grouped/repeated citation and repeated note target pages. First-use
note is recorded as a separate unresolved gap, not silently accepted as valid.
First focused attempt failed only because the new test omitted native TOC title
number prefixes; corrected to exact numbered title strings, retained diagnostic
log, no production modification. Full flake check subsequently passed as recorded below.

Initial probes used initial-inputs.json. Final focused/full use
candidate-inputs.json, differing only in the corrected test expectation. All
other24inputs byte-stable. Original report store output remains immutable;
results/ is a copied user-inspectable set. Manual First-versus-Again click
instructions explicitly record the new gap. No GUI launched.

## Final acceptance and handoff

Authorized600s full flake command exits0; applicable native x86_64-linux checks
pass. Core440/440 in285.609164s, focused6/6 in19.054185s; strict package
compilation and lint accepted (unchanged production package can reuse cache).
No separate9real-extension rerun in this test-only task. Other systems and
GUI clicks unverified. Final full-gate probes use corrected-test identities;
annotation/convergence reports byte-identical to copied results/ reports.
All24non-ERT inputs match committed production blobs and final25snapshot
identities rechecked. No additional project parent inferred for uncommitted
supplementary ERT runtime snapshot. Ordinary tests remain unstaged; user's
flake overlay preserved. No issue trailer/association or external state write.

User-facing next step: open tmp/pdf-links-adjacent/results/generic-short-direct.pdf
and follow MANUAL.md: TOC/headings, distinct same-page bibliography entries,
repeated note, then First-versus-Again comparison. Root cause of missing first-note
target requires a separate bounded control/investigation if selected; no native
footnote rewrite or package semantics change is authorized here. No new release
readiness or arbitrary-input convergence claim.
