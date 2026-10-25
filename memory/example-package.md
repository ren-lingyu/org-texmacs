# Configuration and documentation example package

## Selected objective and authority

User requests a buildable configuration/documentation example package, exposed
through flake packages, with compiled PDFs in out and preferably complete public
configuration coverage. Following the review, user explicitly authorizes writing
the package files only, including separate English/Chinese documents and multiple
mathematical/figure/table cases. No evaluation, formatting, builds, tests or
dependency resolution is authorized. Output is the Nix output directory.

User requires complete build isolation, explicitly scoped to the example package
level. Use ordinary Nix sandboxing and a builder-owned isolated environment;
do not change the generic worker behavior or introduce an isolation framework.
Accepted reproducibility criterion is equal PDF content and layout across
independent builds, not byte-for-byte identity. Non-body metadata such as PDF
creation timestamps may differ. Font repair remains outside project backlog.

## Static review and proposed composition

Reviewed the clean project source accompanying the delivered README update
(post-Issue14 formatting, enabled treefmt check and refreshed flake inputs).
No runtime acceptance at the refreshed pins is established by this review.
Existing package outputs are org-texmacs and emacs. The shared src argument is
Lisp-only, so example Org/config/bibliography inputs need their own explicit
package sources rather than assumptions that src is the entire repository.

Recommended structure: a normal package overlay and package.nix under pkgs,
with package-owned example documents, configuration and a batch driver, then an
explicit flake packages export. org-texmacs-examples is a proposed name only.
Use the matching packaged Emacs/Org/org-texmacs and pinned TeXmacs. Own all
inputs; no README extraction, test-helper dependency or ancestor discovery.
The new package is not automatically a default check, app or release gate.

Public preparation/document APIs followed by org-texmacs-document-save-pdf can
produce PDF directly without a .tm intermediary. The output must be a new
absolute local filename whose parent exists; the builder creates out first.
Preprocessed documents may demonstrate supported INCLUDE/hooks using explicit
package inputs. Core bibliography input is explicit path/text snapshots;
opt-in discovery must remain bounded to declared example inputs.
Native PDF validation rejects image/include/extern/script/action/eval/raw-data
nodes; do not promise unsupported external-resource demonstrations.

## Coverage inventory

Ten public Custom settings:

- org-texmacs-program
- org-texmacs-worker-start-timeout
- org-texmacs-worker-request-timeout
- org-texmacs-format-headline-function
- org-texmacs-document-style
- org-texmacs-document-initial
- org-texmacs-edit-mode
- org-texmacs-fragment-tags
- org-texmacs-export-discover-bibliography
- org-texmacs-export-menu-keys

Menu keys must be set before first loading ox-texmacs; changing them afterward
does not re-register the menu. Editor mode, menu and timeout settings need usable
configuration snippets/explanations, not claims that PDF appearance proves them.
Use a coverage table plus visible export variants where needed; complete coverage
does not imply every enum combination or all Org options/private internals.

Restricted export context has nine metadata keys (title, subtitle, email,
language, keywords, description, creator, date, author) and fifteen policies:
select-tags, exclude-tags, headline-levels, section-numbers,
with-archived-trees, with-author, with-date, with-email, with-creator,
with-priority, with-toc, with-tags, with-tasks, with-title, with-todo-keywords.
Cover supported global/external/file/subtree precedence, including explicit nil.
Thirteen subtree EXPORT_* properties cover TITLE, SUBTITLE, EMAIL, LANGUAGE,
KEYWORDS, DESCRIPTION, CREATOR, AUTHOR, DATE, OPTIONS, SELECT_TAGS, EXCLUDE_TAGS,
FILE_NAME. File LANGUAGE/DESCRIPTION override matching document-initial defaults.
Optional hooks/citation integration should be distinguished from public Custom
settings; private special-block handlers are not a promised stable user API.

## Package-level isolation boundary

The worker currently intentionally inherits the caller's normal environment
(lisp/org-texmacs-worker.el). Therefore the package builder supplies fresh HOME,
TEXMACS_HOME_PATH and XDG state, batch Emacs without user initialization,
explicit executables/resources, stable locale/timezone and fixed document
author/date inputs. Keep all worker state temporary inside the build sandbox.
Fonts and bibliographies must come from declared runtime/input closures, not
host discovery. This is dependency isolation, not adoption of font repair.

Rendering is an ordinary offline sandboxed derivation, not fixed-output,
__noChroot or an impure host fallback. Nix may fetch declared dependencies before
rendering. Actual sandbox policy belongs to the build environment; package code
and temporary HOME alone do not establish that it is enabled. No separate runtime
container/framework or generic worker changes are required by the user.

Current public upstream PDF renderer sets CreationDate to current time. This
does not block the accepted content/layout criterion; no timestamp normalization
or byte-determinism patch is selected. That upstream observation is not a fresh
audit of the locked TeXmacs build.

Sources: pkgs/default.nix, flake.nix, pkgs/emacs-with-org-texmacs,
pkgs/emacsPackages/org-texmacs, lisp/org-texmacs-core.el,
lisp/org-texmacs-document.el, lisp/org-texmacs-session.el,
lisp/org-texmacs-worker.el, lisp/ox-texmacs.el
and their export/preprocess collaborators; existing README option tables.
Public references:
https://nix.dev/manual/nix/2.34/command-ref/conf-file.html#conf-sandbox
https://github.com/texmacs/texmacs/blob/svn_mirror/src/Plugins/Pdf/pdf_hummus_renderer.cpp

## Files-only implementation, not runtime accepted

User clarifies that the requested graphical functionality means figure/table
wrappers. Added pkgs/org-texmacs-examples and the explicit flake packages export.
Added narrowly scoped .gitignore allowances for its Org/BibTeX/README inputs;
the existing whitelist otherwise hides them from ordinary staging/flake source.
User requests the package-local explanation use README.org rather than README.md;
converted the file to Org syntax and updated its installation/ignore paths.
The overlay uses the matching emacs-with-org-texmacs wrapper. Six independent
runCommand leaves cover en/zh crossed with guide/mathematics/figures-tables;
one aggregate copies artifacts under out/<language>/<topic>.
Each leaf owns fresh HOME/TeXmacs/XDG state and uses packaged executables with
batch Emacs, no user initialization or default-check/CI wiring. No host font
import or generic worker changes. Actual sandbox enforcement remains the Nix
build environment's responsibility.

common.el fixes page settings and extends the request timeout. The guide retains
generic defaults; article.el changes style, supplies a section-marker headline
formatter and selects math-only paragraph roots. Both actual configuration
files are displayed through literal INCLUDE in each document. Build driver
uses the public preprocessed document provider with explicit BibTeX snapshots,
then saves .tm and PDF from that same completed document. Each leaf streams
progress/errors with tee/pipefail and a600second timeout, requires nonempty
artifacts, and runs pdfinfo during a future authorized build. Inputs/logs/PDF
metadata inspection are installed beside both artifacts. No such build has run.

Guides cover rich metadata, two ordered abstracts/keywords, citations/footnotes,
configuration precedence, subtree property illustration, interactive config
shown without execution and scope limitations. Mathematical notebooks cover
fractions/radicals/powers/indices/Greek symbols, sums/products/integrals/limits,
matrices/multiline equations and named definition/theorem/proof/lemma/remark/
exercise. Figure/table documents cover actual native vector graphics, numbered
and starred wrappers, Org versus native tables, mathematical native cells,
captions/references and subsequent counters. Ordinary Org cells intentionally
contain numbers, since paragraph STM discovery does not enter those cells.

Only source inspection and Git diff/whitespace review performed. Nix/Elisp/native
syntax, PDF output, Chinese glyphs, typesetting and formatter acceptance remain
unverified. No generated artifacts, lockfile/index/history changes or changes to
existing tests/production Lisp. Next: user review of files, then separately
authorized evaluation/build and visual inspection. Existing release evidence
retains its original input scope.

## Review of supplied guidance, preceding files-only implementation

User supplies a draft naming org-texmacs-examples and nix build as the sole
entrypoint (no nix run). Draft requests retained source/config inputs and
generated .tm/PDF artifacts, no generated artifacts committed; multiple practical
configuration examples instead of mechanically setting all options or overriding
package defaults; actual build configuration displayed in the document with
minimal duplication; non-build mechanisms explained but not executed; readable
representative mathematics/statements/references/metadata/abstracts; same local
and CI package entrypoint, limited supplementary integration acceptance and
useful failure output. It excludes a generic configuration framework, export API
refactor and mixing example logic into production package builds.

The supplied draft alone was not implementation authorization or acceptance of
every proposed clause; the later user request explicitly authorizes writing
files as recorded above. It narrows the earlier exhaustive-coverage
aspiration to useful representative configuration coverage. Suggested clarifications:
restore explicit package-level isolation/content-layout reproducibility; define
out installation layout; derive .tm and PDF from the same completed document
snapshot without imposing .tm reload as the PDF route; distinguish automated
artifact checks from visual review and package availability from CI integration.
Configuration snippets can show the real config file as literal source rather
than maintain a second copy or execute documentation code blocks.

Source is the user's supplied chat draft, not an inspected repository file.
Distillation preserves the requirements and review issues; original-byte archival
has no independent reproduction/evidence value and is unnecessary. No project
edits, builds or tests performed for this review.
