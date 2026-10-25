# Literate documentation package

## Objective, decisions and authority

User selects a buildable org-texmacs-documents package rather than a standalone
example collection. Canonical documentation belongs in docs/, with separate
English and Chinese guides, mathematical notebooks and figure/table documents.
The docs are both useful project documentation and real package inputs, covering
representative features and configuration instead of mechanically setting every
option. No separate package README is wanted. The guides own the build/output
instructions formerly kept in that README.

Current authorization is files-only implementation. No Nix evaluation, tangle,
build, formatter, test or dependency resolution has run or been authorized.
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

Only bounded source reads, file writes/moves and Git diff/static searches.
Static searches find no old package identifiers, parent traversal or source-root
inference in the candidate package/docs, and no Chinese fullwidth punctuation in
the new prose. No actual syntax/API/tangle/rendering/Chinese-font/format acceptance
is established. Next: review written files, then separately authorized evaluation,
build and visual inspection. Source remains untracked until user stages it.
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
