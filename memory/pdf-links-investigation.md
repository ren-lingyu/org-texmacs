# PDF hyperlink repair: locally accepted, awaiting user delivery

## Objective and result (2026-10-16)

User selected PDF links after Issues10/11. This implements release-readiness
INBOX item4; closed Issue4 explicitly excluded PDF annotations, and no new
PDF-specific issue was established or created. No external issue/release write.

Confirmed package consumer sequencing defect: update-current-buffer invalidates
layout without performing it. Before each native print, update-forced must
synchronously typeset the owned buffer so its native link state is available
when PDF boxes render. No Org AST/lowering/provenance or user configuration
change is needed. No independent PDF link implementation or .tm reparse fix.

## Accepted implementation

Exactly three task files: org-texmacs-worker.scm, tests/ert/ert.el, README.org.
Worker checks update-forced capability and calls it before each existing print.
Three invalidation passes, two prints, temporary buffer/file ownership, source
consistency checks, cleanup and public-session isolation remain. Errors during
either forced-layout phase propagate through existing rendering-error recovery.
No public API/worker operation/lock/version/INBOX change; user flake untouched.

README corrects the old claim that invalidation itself performs synchronous
updates and explains native URI/internal annotations. Two maintained ERT added:
- Actual Poppler annotations for generic/article styles, exact URI and explicit
  cross-page internal target, repeated same-worker rendering and independent
  native .tm reload after source destruction. Source state remains unchanged.
- Failure at each forced-layout phase, private-output cleanup, healthy same-worker
  retry and unchanged existing public session.
The existing native .tm reload helper also forces layout before printing.

## Causal evidence and validation

Locked x86_64-linux: Emacs31.1, Org9.8.10, TeXmacs2.1.5, Poppler26.09.0;
independent temporary inspector pypdf6.19.0. No system Emacs or user-config edits.
Source audit extracts eight bounded original text files from the locked native
source archive and records exact source/package/file identities. Public upstream
master supplied a hypothesis, not a substitute for locked native execution.

Matrix: generic/article package output and .tm reload (four PDFs), plus eight
independent native controls from style x locus-on-paper change/preserve x
print-to-file/export-postscript. Baseline12/12 have zero annotations, with named
destinations/text still present. Adding update-forced only to native controls
gives two annotations in each of eight controls; unchanged package/reload remain
zero. Final worker+reload gives two annotations in each of12PDFs, exact fixture
URI and valid named internal destination. Poppler independently confirms URI
annotation and internal page target. No byte/pixel equality requirement.

New regressions against original worker: two intended failures,3.833453s (absent
URI; forced-layout error injection never reached). Corrected baseline target
exits0 only when exactly those two test failures occur. Candidate focused36/36
pass125.005432s, including link5.650425s and layout recovery3.652762s. Real
extension9/9 pass10.292105s. Final600s flake check exits0, core439/439 pass
279.377034s, strict compilation/lint and all seven applicable checks pass. Other
platforms, GUI viewer clicks, arbitrary custom styles/font/user configs untested.
This package acceptance does not establish full v0.5.0 release readiness.

Authorized repeated commands, all under tmp/pdf-links:
- timeout120s nix build #checks.x86_64-linux.source-audit
- timeout240s nix build #checks.x86_64-linux.probes
- timeout120s nix build #checks.x86_64-linux.baseline
- timeout240s nix build #checks.x86_64-linux.focused
- timeout120s nix build #checks.x86_64-linux.integration
Each uses path:./tmp/pdf-links as flake root, --no-link --no-update-lock-file
--print-build-logs --print-out-paths. Full command:
`timeout 600s nix flake check path:./tmp/pdf-links --no-update-lock-file --print-build-logs`.
Authorization includes necessary locked dependency/source access and result
reading/copying. No dependency updates. No further checks needed without changes.

## Evidence, provenance and handoff

All18original baseline inputs match committed main source, all25final candidate
inputs match project/isolated copies before and after final gate, all11foreign
Elisp hashes match fixed extension manifests. Exact three-file patch remains
identical to project diff; ordinary index empty, unrelated user flake unstaged.
User review/staging/message/commit are pending, not authorized by test approval.
No inferred project parent for the uncommitted accepted candidate.

Twenty necessary original-byte text artifacts captured and byte/digest/source-
stability/index verified separately, with immutable manifest:
archive/2026-10-16T11-13-53Z--847845c/MANIFEST.md.
Contains controlled matrix/repro scripts, lock/manifests, exact candidate patch
and baseline/focused/integration/full evidence. No PDF/binary/dependency/source
tarball/full tmp/INBOX capture. Original baseline/patch/log trailing whitespace
and final blank lines retained and classified in manifest; product diff is clean.

Initial sandbox daemon denial, malformed temporary Lisp and missing native module
import were corrected, not counted as accepted results; diagnostics extracted.
Pypdf warns about duplicate native destination keys in baseline and successful
controls; unrelated native dictionary rewrite is outside scope. Existing archive
records remain immutable. Working tmp is reproducible evidence, not current
workflow authority. Next: user review/delivery; fonts postponed, font-lock and
representative/full release-readiness work remain separate.

## Read-only adjacent-risk review after acceptance

User asks whether similar causes may affect other behavior. Targeted production
search finds update-current-buffer/print-to-file only in the PDF consumer;
serialization constructs and serializes a file tree directly, session readback
checks installed style/initial/body. Neither claims completed layout, so absence
of forced typesetting there is not itself a defect. No additional runtime check,
project edit or newly reproduced defect from this review.

Potential verification gaps: TOC/page-reference/citation/repeated-footnote
clickable annotations share native link machinery; existing ERT generally
checks their values/text/layout, while new annotation ERT directly covers an
external hlink and described same-document jump. The common fix may cover those
annotations too, but text/reference success alone does not prove each target.
Historical unresolved citation markers already motivated the two-print fix, a
similar derived-state sequencing issue rather than a newly found regression.
Complex pagination/page references may need more convergence than fixed passes;
no remaining failing example demonstrated. Repeated invalidation calls are not
multiple actual layout rounds and must not be counted as convergence evidence.
Any further work should use targeted annotation/target or long-document
reference controls, not indiscriminate forced layout in pure/session/serializer
APIs. These are bounded review findings, not adopted implementation backlog.
No new raw archive needed: necessary distinctions extracted here, code/tests
and existing immutable evidence retain the basis.
