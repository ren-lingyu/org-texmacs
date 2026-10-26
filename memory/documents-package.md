# Compilable bilingual examples

## Current state after link-policy acceptance

Current candidate is pkgs/org-texmacs-examples, sources/shared+en/zh with3entries
per language (configuration, mathematics, figures-tables), include-only chapters,
package-local fileset and isolated builders. User has staged migration, replacing
old docs/ paths. Logs remain only in Nix, PDF/TM entry basenames match source.
Fandol override is confined to examples, independent font package delivered;
main Lisp keeps plain TeXmacs. New2consumer flags are accepted with597ERT/full
isolated checks, including formatting of example build.el, but example PDFs have
not been built after migration. Source feature remains unstaged. Source Custom
inventory now12including PDF path policy and uniform .org->.pdf target policy.

User proposes TWO outputs per language (generic index linked to article), not yet
implemented. Link prerequisite is now accepted, details:
memory/file-link-implementation.md. Only en/zh, no implicit bibliography or
abstract/TOC order work selected. Prior reports below are phase-specific history;
old docs package build/reload results do not validate the current package layout.

## Adopted package-local examples migration

User now authorizes reorganization: package renamed org-texmacs-examples with
sources/shared and sources/en|zh. Entry guide renamed configuration, math and
figure/table names retained. Include-only chapters under per-language chapters/.
No root docs/ or separate README, no i18n nesting. README and canonical prose/
links/build commands synchronized. .gitignore replaces docs allowance with
pkgs/org-texmacs-examples/sources/**/*.org. Build source collected by local
lib.fileset.toSource, no flake-level docs argument remains.

Runtime staging preserves chapters, explicitly puts shared configuration under
chapters/configuration-source.org and shared refs under chapters/references.org.
Config/bib tangle there; driver loads common+selected profile relative to explicit
configuration path and copies profile.el there. Chap includes remain local;
entry BIBLIOGRAPHY and math/figure includes use chapters/ paths, no ../.
Package installs named PDFs/TM plus full input entry/chapters/ tree and derived
files in sources/<language>/<topic>. Scoped Fandol override retained. Date/heading
preferences retained. No bibliography/TOC semantics changed.

File moves ordinary filesystem only, no staging; old indexed docs paths now AD,
new package untracked. Prior stash retained. No evaluation/build/tangle/formatter
run for this migration. Tracked diff --check plus bounded old-name/parent/heading
blank searches pass. Future validation needs fresh authorization and explicit
path input until new files are staged. Historical acceptance below is not a new
candidate test claim.

## Selected example scope and deferred preferences

User keeps English/Chinese only. They prefer automatic references appended at
the end and TOC before abstracts, but explicitly defer these behavior questions
for now while focusing on examples. No implicit-bibliography implementation,
ordering change, extra language cases or tests adopted. Existing explicit print
directive and current ordering stay. Earlier package-local examples naming/layout
is still a recommendation awaiting implementation selection.

## Organization and language coverage review

User considers examples rename/package-local sources and asks about i18n nesting,
other LANGUAGE codes and unnumbered bibliography sections. Recommendation only:
sources/{en,zh,shared} already expresses language ownership; i18n adds a layer
without separating translation catalogs. No move/rename adopted or executed.
Current language table29Org codes maps27native identifiers, native-registry ERT
iterates all29codes using ASCII Body; mapping/unknown-code core cases exist.
These tests do not establish each script's PDF glyphs/layout. Recommend keep
full en/zh examples and add only selected script/font probes if broader support
is adopted, not mechanically translate whole collection. PRINT_BIBLIOGRAPHY
lowers to with-bib/bib-list without its own section heading, so explicit
unnumbered References/参考文献 heading is a natural usage convention, optional
UNNUMBERED:notoc if excluding from TOC. No test/runtime/edit action selected.

## Org source presentation follow-up

User requests DATE use Org timestamps and no blank between headline and first
content. All6entry dates converted to [2026-10-26 Mon]; headline-following empty
lines removed throughout docs without changing block contents. No runtime rerun.
User asks whether native styles own abstract/TOC relative order: code currently
prepends metadata+toc before source-ordered body containing abstract-data, so
current package imposes TOC-before-abstract. Native macros own formatting, not
automatically this structural ordering. No fix selected. Bibliography citations
currently require exactly1PRINT_BIBLIOGRAPHY; current guide inherits directive
from included bibliography chapter, so it need not be repeated in each entry.

## Restored on delivered standalone font package

User delivers aa1af88 (standalone texmacs-fandol export/devShell, no Lisp injection),
then requests docs restoration/adaptation. Worktree-only selected stash restore
avoids its obsolete Lisp injection; manual flake merge retains font export and
shell while restoring explicit docs fileset/input, document output and *.org
formatter exclusion. Stash8429dcc retained; index remains empty; new docs/package
files untracked. Ordinary Lisp and font-wrapper files equal new HEAD.

Document overlay now builds a private matching Emacs package set and selects
org-texmacs.override {texmacs=final_.texmacs-fandol;}. Main Lisp/Emacs dependency
and explicit test executable choices stay unchanged. README lists4outputs and
scopes fonts to documentation override; bilingual building instructions agree.
Test prefix/output cleanup preserved. Static diff check and bounded path scans
only; no current build/formatter/evaluation or Chinese PDF acceptance rerun.
Earlier accepted result pq50... predates these changes. Next review/validation
must use current files, not stale cached evidence as a new test claim.

## Corrected font dependency boundary

User rejects carrying fonts in org-texmacs packaging. Main Lisp overlay worktree
restored by text edit to HEAD, index unchanged (old injection remains staged).
Independent texmacs-fandol stays. Future docs restoration must inject font wrapper
only for its own build and correct the stash README claim of main-package use.
Do not reintroduce font dependency into public Lisp/Emacs or default tests.

## Documentation deferred for font-package-first delivery

User explicitly selects path-specific stash push of all documentation work,
leaving the three staged Fandol package/wiring files for an independent commit.
Saved local stash named "wip: bilingual documentation package and output layout"
contains README.org, docs/, flake.nix, pkgs/default.nix and
pkgs/org-texmacs-documents/. Includes ASCII test prefix, cleaned output layout and
font build descriptions. Those paths revert to HEAD after successful push;
documentation package is absent from the current worktree. User has not yet
delivered the font commit or authorized restoring the stash. No runtime rerun.
Exact stash8429dcc0ca02cb86b21929ccba1232b07f4a26f5. Git snapshots the full staged
candidate, so stash show lists25paths including the three retained font files;
only22selected docs paths were removed. Restoration must review overlap with the
future committed font state; no blanket promise of a docs-only stash tree.

## Adopted Fandol package wiring, unvalidated candidate

User explicitly authorizes adopting the inspected downstream texmacs-fandol.
New pkgs/texmacs-fandol package/overlay reproduce its explicit font input/wrapper.
emacsPackages/org-texmacs overlay resolves outer pkgs and passes texmacs-fandol
to its package; main packaged Lisp/Emacs and documentation therefore use it.
README and en/zh build instructions synchronized (environment identifier quoted
as Org verbatim). Ordinary pkgs.texmacs, explicit test executable injection,
Lisp conversion and renderer are unchanged. No tests/build/formatter run for
these new bytes; current result still predates prefix/output/font changes.
Agent did not stage anything. Earlier no-font-work scope is superseded for this
explicit packaged dependency only, not general font/layout correctness work.

## User-confirmed downstream Chinese font resolution

User reports PDF visibly prints <#...> and confirms adding TeXmacs Chinese fonts
in the downstream caller restores normal output. Authorized read-only inspection
of ~/emarccs/pkgs/emacsPackages/org-texmacs/ shows its overlay injects
pkgs.texmacs-fandol as the texmacs parameter; postPatch embeds that executable
as org-texmacs-program. The referenced ~/emarccs/pkgs/texmacs-fandol package is
symlinkJoin of texmacs with makeWrapper prefixing TEXMACS_FONT_PATH by
${fandol}/fonts/opentype/public/fandol. Its overlay supplies
texlive.pkgs.fandol.tex. Explicit Nix font input, no encoding/Lisp repair or host
font discovery. Downstream source revision differs from the current project;
no agent runtime reproduction or project font change is claimed. This resolves
the user's reported cause, while earlier raw0x9f inspection remains a separate
native .tm representation observation. Font work remains outside adopted scope.

## Selected output cleanup, pending runtime verification

User selects type-based output grouping after requesting ASCII (Test prefix)
in the article formatter. Worktree package now installs matching entry basenames
under pdf/en|zh and texmacs/en|zh; complete canonical/derived input sets remain
under sources/<language>/<topic>, preserving each build's INCLUDE paths and
selected profile.el. Logs and pdfinfo stream to Nix build logs and are not
installed. README plus bilingual building/guide descriptions are synchronized.
No canonical-source directory migration or merging of different profiles.
Ordinary index unchanged; new edits unstaged. Existing accepted result below
is the prior layout/prefix and does not validate this follow-up. No new build,
format command or tests authorized or run; static diff --check only.

## Section-marker read-only diagnosis

After cleanup user stages all22candidate paths and asks about octal237/replacement
glyphs in figure/table output. result is the actual pq50lvs8p0bcvq7405qybvx01612gd3c
package below. docs/configuration.org:60 explicitly prepends Unicode § plus space
in the article headline formatter. Derived article.el preserves that source.
The saved en figure/table .tm contains raw0x9f at heading/TOC prefixes, confirmed
by bounded od byte dump; this is not an encoded Unicode replacement character.
Worker applies utf8->cork then serialize-texmacs; native output bytes are preserved
by the public serializer/save contract, so UTF-8-only text inspection displays a
replacement. Included article code also contains the marker. No evidence of a
figure/table-specific lowering failure. Actual PDF glyph appearance is not
verified by this diagnosis (pdftotext unavailable on PATH), and previous normalized
PDF equality did not establish glyph/layout correctness. No new build or ordinary
file/index changes. Marker removal or alteration is not yet requested.

## Restored documentation cleanup and acceptance

After INCLUDE repair delivery, user reapplies all21draft paths, then explicitly
requests workspace cleanup and authorizes exact formatter/full-check/docs-build
commands. Metadata tables use verbatim EXPORT_TITLE, matrix STM is closed,
guide EOF blanks and Chinese metadata punctuation corrected. Bilingual build
instructions describe result paths and the entire Emacs build timeout. README
lists three package outputs, explicit docs input and compiled guide links.
Only package.nix/build.el change under the five-file formatter invocation.

Actual root package build exits0: all six en/zh guide/math/figure-table leaves
produce .tm/PDF/pdf-info and logs. This uses the real package driver, without
temporary diagnostic/reload additions. Output:
/nix/store/pq50lvs8p0bcvq7405qybvx01612gd3c-org-texmacs-documents.
Saved reload/PDF-text equality was verified in the preceding isolated draft
phase, not rerun by the production cleanup package. No visual/glyph/byte-identity
or cross-platform acceptance is claimed.

Root explicit path full check imports Git metadata and treefmt's temporary Git
operation cannot find git-gaw for the copied hook. No bypass or governance edit.
A separately authorized metadata-free106file copy passes full flake check with
ERT/lint/package outputs cached and treefmt executed. Initial Org missing-formatter
failure is fixed by *.org exclusion; narrower docs/**/*.org did not match the
root-level Org files. All106current inputs remain equal after the gate.
Manifest SHA256: b734db81dda08abd7865d91b645981a2efdb16d975812c6ae1938b6429ca25fb.
Complete current worktree diff against delivered INCLUDE HEAD SHA256:
356444f0dd8f09bfa77ccf094113dc75de13571448a47094d3b9b067263f34c6.
Manifest/verification are under tmp/documents-cleanup. No project-parent
association is needed for this uncommitted candidate's test state.

Combined diff --check passes; no parent traversal/host hardcoding found. Ordinary
index is untouched:19staged blobs still equal the restored original stash and
contain old mistakes. User must review/restage corrections, wiring and README
before commit preparation. No new default check/app/CI or font work. Original
stash unchanged. Fresh test/formatter authorizations apply only this cleanup round.
Earlier isolated evidence: memory/include-view-implementation.md.

## Objective, decisions and authority

User selects a buildable org-texmacs-documents package rather than a standalone
example collection. Canonical documentation belongs in docs/, with separate
English and Chinese guides, mathematical notebooks and figure/table documents.
The docs are both useful project documentation and real package inputs, covering
representative features and configuration instead of mechanically setting every
option. No separate package README is wanted. The guides own the build/output
instructions formerly kept in that README.

Original implementation authorization was files-only. At that phase no agent
Nix evaluation, tangle, build, formatter, test or dependency resolution had run.
The later user-run failed build and read-only diagnosis are recorded below.
Do not treat written drivers or output checks as execution evidence.
No agent ordinary project staging/history writes; source files remain candidates.

User requires complete isolation at package level, using ordinary Nix sandboxing
and builder-owned HOME/TeXmacs/XDG state, without generic worker changes or an
additional isolation framework. Equal PDF content and layout suffice for
reproducibility; CreationDate/other non-body metadata may differ and byte identity
is not required. Font repair remains excluded. No default check/app/CI workflow
or release gate is implicitly adopted.

User explicitly prefers ASCII punctuation in authored prose, including Chinese;
use commas instead of ideographic enumeration commas. Converted all newly added
Chinese documentation accordingly. Do not rewrite historical evidence for style.

## Composition and paths

flake.nix collects docs with lib.fileset.toSource rooted at ./docs, separately
from the existing Lisp src. Explicit docs argument flows through pkgs/default.nix
extraArgs and the package overlay into pkgs/org-texmacs-documents/package.nix.
Package does not locate docs by parent traversal or infer the repository root.
This shared docs source supersedes earlier per-case source collection; changes
to it can invalidate multiple documents. No build-speed improvement is claimed.

The matching emacs-with-org-texmacs wrapper supplies the packaged executable and
Org libraries. Build driver remains pkgs/org-texmacs-documents/build.el, explicitly
loaded by its package; it is neither in docs nor derived from Org. User selects
configuration .el and bibliography .bib derivation from Org instead:

- docs/configuration.org has three explicit tangle targets: common.el,
  generic.el, article.el. Only common.el and the selected profile are loaded.
- docs/references.org has a BibTeX block targeting references.bib.
- Org Babel tangling is a build step copying declared blocks, not block
  evaluation. Interactive examples elsewhere have no tangle target and are
  neither tangled nor loaded. Export runs no Babel evaluation.

Six independent runCommand leaves cover en/zh crossed with guide/mathematics/
figures-tables. Each stages one language's Org files plus shared configuration
and references into a writable directory. All driver paths, including the work
directory, arrive explicitly through ORG_TEXMACS_DOCUMENT_* environment variables.
Generated file names are within that explicit input directory; no ../, source
location inference or host source lookup remains in the package/driver/docs.

Guides compose adjacent configuration-guide.org, metadata.org, bibliography.org
and building.org through ordinary INCLUDE. Configuration chapters further include
the generated common.el/profile.el literally. Bibliography chapters include the
canonical references.org as literal Org source, keeping tangle headers inert
during rendering. Mathematical and figure/table documents include their actual
configuration too. This exercises nested real documentation composition without
custom export hooks or a general configuration framework.

Driver uses public org-texmacs-document-from-buffer-preprocessed with explicit
BibTeX snapshots and no global discovery. It saves .tm and PDF from the same
completed document via public consumers; saved .tm is not a PDF intermediary.
Each leaf has streamed tee/pipefail diagnostics and a 600-second timeout, checks
nonempty artifacts and invokes pdfinfo during a future authorized build. An
aggregate exposes packages.org-texmacs-documents and copies each leaf under
out/<language>/<topic>, including document.tm/document.pdf, canonical Org inputs,
derived .el/.bib, build.log and pdf-info.txt. Failed builds publish no output
directory; diagnostics remain in the Nix log. No generated artifacts committed.

Old org-texmacs-examples paths/export, package README and standalone source .el/
.bib were removed. Newly added .gitignore exemptions were all withdrawn: existing
docs/**/*.org covers canonical input and pkgs/**/*.el covers the driver. No net
.gitignore change remains. Lisp/runtime/tests/lockfile are unchanged.

## Content and public support boundaries

Guides cover rich metadata, two independent ordered abstracts/keyword declarations,
citations and repeated/inline footnotes, supported option precedence and subtree
properties, and interactive settings shown without execution. Mathematical docs
cover fractions/radicals/indices/powers/Greek symbols, sums/products/integrals/
limits, matrices/multiline formulas, and definition/theorem/proof/lemma/remark/
exercise environments with named references. Figure/table documents use actual
native graphics, numbered/starred wrappers, Org/native tables, mathematical native
cells, captions/references and subsequent counters. User confirms the requested
graphical feature means figure/table. Ordinary Org table cells contain numbers:
paragraph STM fragment discovery does not scan those cells.

Bibliography adds native string declaration/concatenation, @online fallback and
crossref with its parent explicitly cited. These shapes are grounded in the
existing Issue12 regression in tests/ert-pdf/lisp/pdf.el; they are not newly
executed evidence. Illustrative records are labelled as demonstrations rather
than real publications. Documentation states native plain style may ignore fields
such as online URL, does not imply BibLaTeX/Biber parity, and does not automatically
add uncited crossref parents.

Ten public Customs remain the useful configuration inventory: program,
worker-start-timeout, worker-request-timeout, format-headline-function,
document-style, document-initial, edit-mode, fragment-tags and optional ox
export-discover-bibliography/export-menu-keys (all org-texmacs prefixed).
Menu configuration is load-time before first ox-texmacs require. Interactive
settings cannot be validated through PDF appearance. Retain packaged defaults
unless a meaningful document-specific override is needed. Private handlers are
not a stable user API. Existing restricted context supports nine metadata keys,
fifteen policy keys and thirteen EXPORT_* subtree properties; earlier source
inventory did not adopt exhaustive combinations as a documentation requirement.

## Evidence and next action

User subsequently saves all21candidate paths in the [wip] docs stash, based on
the gitignore-anchoring HEAD. Ordinary project worktree/index clean; package/docs
are no longer present as candidate worktree files. Stash read only, not applied.
Active follow-up is a snapshot/view architecture proposal review, not a docs
restoration or implementation task. Findings: memory/include-view-review.md.

User now stages the candidate paths and reports the first nix build of
org-texmacs-documents exits1. In the en/figures-tables leaf, logs show three
configuration blocks and one bibliography block tangled successfully, followed
by preparation failure: Unsupported INCLUDE parameters. This is user-reported
runtime evidence, not an agent rerun; other parallel leaf outcomes and rendering
remain unconfirmed. User requests read-only diagnosis only; no project edits or
validation command is authorized by this report.

Static diagnosis: fourteen src-wrapped INCLUDE directives across all six
documents exceed the current contract. lisp/org-texmacs-preprocess.el checks
:env/:block are absent before acquisition, explicitly rejecting wrapped INCLUDE.
tests/ert-core/lisp/preprocess.el's fixed-read/parameter-error test explicitly
expects failure for an included file with src emacs-lisp. README already states
unsupported wrappers fail. This is not a regression in existing supported plain
Org INCLUDE. Standard Org syntax permits these wrappers:
https://orgmode.org/manual/Include-Files.html

Authoring the new docs assumed support that does not exist. Merely removing src
would parse displayed configuration as Org and can expose the bibliography's
tangle headers, so it is not a correct presentation fix. Recommended next design
is a bounded extension for literal source inclusion, preserving native Org code
escaping, fixed input reads/budgets, STM shielding and no evaluation. Plain source
block lowering already exists; unrestricted INCLUDE wrappers/export environments
are not thereby adopted. No implementation choice or production fix is authorized
yet. No project file was changed during this diagnosis.

User asks about related extension candidates. Review recommendation only, not
adoption: first support literal src LANG and example INCLUDE wrappers, including
their interaction with existing :lines selection and inert nested Org/STM/code
text. Other supported structural wrappers (quote/center/formal statements) and
native texmacs/equation bodies are possible later candidates needing separate
recursive versus native-body classification. Arbitrary export wrappers, unknown
blocks, non-UTF8 acquisition and Babel evaluation are not bundled into this
recommendation. Existing location/only-contents/lines/minlevel support is not new.

At the files-only handoff: bounded source reads, file writes/moves and static searches.
Static searches find no old package identifiers, parent traversal or source-root
inference in the candidate package/docs, and no Chinese fullwidth punctuation in
the new prose. No actual syntax/API/tangle/rendering/Chinese-font/format acceptance
was established at that handoff. User has since staged the paths and attempted
a build as recorded above; no full candidate byte-equivalence review is claimed.
Existing Issue14 acceptance remains scoped to its old fixed inputs, not the
current refreshed lock or this package.

The generic worker intentionally inherits its caller environment, so isolation
is owned by this builder (lisp/org-texmacs-worker.el). Native PDF rejects explicit
image/include/extern/script/action/eval/raw-data nodes; no external image import
is promised. Actual sandbox enforcement belongs to the Nix environment.
Public upstream renderer's current-time CreationDate is compatible with the
accepted content/layout criterion; it is not a fresh locked-runtime audit:
https://github.com/texmacs/texmacs/blob/svn_mirror/src/Plugins/Pdf/pdf_hummus_renderer.cpp
Sandbox reference:
https://nix.dev/manual/nix/2.34/command-ref/conf-file.html#conf-sandbox

The user's supplied development guidance was distilled on first review. Its
useful constraints survive here; original chat bytes have no independent
reproduction/evidence value requiring an archive. Earlier proposals and the
example-package naming remain available through first-parent GAW history.
