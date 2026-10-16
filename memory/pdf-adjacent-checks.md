# Supplementary PDF derived-state checks (selected2026-10-16)

## Motivation, source and scope

User committed original PDF fix; exact committed delivery verified and recorded
in memory/pdf-links-investigation.md. User now asks for supplementary tests of
previously identified adjacent risks, and practical interactive steps where easy.
Current source is that committed fix, not original uncommitted repair candidate.
No business-code repair selected. Only tests/ert/ert.el modified; user flake
remains unrelated/unstaged. No issue association or external writes.

## Prepared automated checks, pending exact command authorization

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

Pending commands, no new tests/builds run yet:
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

No raw archive yet: no unique runtime evidence; plan/procedure content extracted
here. Reassess after probes/new failures. Existing PDF repair archive immutable.
