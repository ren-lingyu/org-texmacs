# PDF hyperlink repair: controlled native evidence and candidate

## Result and ownership

Missing PDF annotations are caused by incomplete synchronous native consumer
sequencing. The worker previously invalidated layout and printed without first
forcing the persistent editor's layout. update-current-buffer maps to invalidation;
update-forced performs immediate typesetting. The latter prepares native link
state needed during printing. Adding it before both existing print phases restores
URI/internal annotations. No Org lowering/provenance/configuration/PDF rewriting
mechanism is introduced. Existing owned buffer, source guards, two prints, file
cleanup, public-session isolation and failure recovery remain.

The3file candidate is README.org,org-texmacs-worker.scm,tests/ert/ert.el.
Readme now describes actual forced layout; two maintained ERT cover actual URI
and cross-page jumps, repeated renders, independent native .tm reload, released
source ownership and errors at each forced-layout phase. Existing reload test
helper also forces native layout. No public API/protocol or lock changes.

## Controlled matrix and reproduction

All tests run in isolated flake with locked Emacs31.1/Org9.8.10/TeXmacs2.1.5,
x86_64-linux, fresh native configuration. No system Emacs. Poppler26.09.0 and
pypdf6.19.0 inspect PDF annotation objects, URI, named internal targets and text.
The matrix contains12PDFs:2styles(generic/article) x package and native .tm reload,
plus8independent native controls (2styles x locus-on-paper change/preserve x
print-to-file/export-postscript). All contain an external URI and internal link.

Baseline: all12have0annotations; native destinations still present. Forced native
only: all8native have2annotations, unchanged4package/reload have0. Fixed package
worker and corrected independent reload: all12have2annotations; URI matches exact
fixture and internal destination occurs in parsed named destinations. Actual
Poppler anchors independently confirm click targets. Native duplicate-destination
key warnings occur in baseline and positive controls; no unsupported dictionary
rewrite or blanket claim about every native PDF path/configuration.

Reconstruct original18inputs from the checked source baseline and inputs.json;
for baseline matrix use probes-baseline.el and original maintained ERT helper
(which has no update-forced). Native-only control adds update-forced in probes.el
while retaining original package/reload helper. Final apply candidate.patch,
check25candidate-inputs.json, and use probes.el/current helper. Full original
math-heavy or user files are unnecessary: the retained fixtures reproduce this
annotation failure with small ASCII text. Source-audit.py and manifest identify
exact native source/package and8selected unmodified source text identities.

The standalone flake carries source-audit/probes/baseline/focused/integration and
project ERT/lint checks. Original source-audit/probes timeout120/240s; subsequent
baseline/focused/integration timeout120/240/120s; full flake timeout600s. All use
--no-link --no-update-lock-file --print-build-logs, nix build also --print-out-paths;
full check uses path:./tmp/pdf-links. No dependency/source patch or lock mutation.
Package compilation is strict. Only11explicit pinned extension Elisp files are
used for real integration, identified by extension-inputs.json.

## Acceptance and limits

Baseline2intentional failures,3.833453s: absent URI annotation and old worker
never invoking forced-layout error injection. Focused36/36,125.005432s, including
new link5.650425s and layout recovery3.652762s. Actual extension9/9,10.292105s.
Final600s flake check exits0:439/439core ERT279.377034s; all7applicable
checks pass (ERT,lint,source-audit,probes,baseline,focused,integration), strict
package compilation accepted. Other flake systems are explicitly omitted.

18baseline inputs match committed capture-context source;25candidate inputs
match project and isolated files,11foreign identities match pinned fixture. The
candidate is uncommitted; capture-context commit is not candidate runtime source.
No inferred additional project parent for mixed native/uncommitted work. Existing
root flake mirror remains unrelated and unstaged. No release or remote issue write.
GUI viewer clicks/all platforms/custom styles/all font/user configurations are
unverified; actual PDF destinations are verified automatically. Full gate is
package regression acceptance, not full v0.5.0 readiness. Chinese fonts postponed,
font-lock and representative release workflows remain separately selected work.

Only selected text scripts/identities/logs/annotation reports/patch are eligible
for GAW archive. PDFs, binary dependencies, source tarball, full temporary tree
and user INBOX are excluded. Corrected harness failures are extracted in
diagnostics.md; old failed logs remain tmp only.
