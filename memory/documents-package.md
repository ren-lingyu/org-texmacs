# Compilable bilingual examples

## Delivered package and scope

org-texmacs-examples is delivered as project0559700. It is a separate Linux Nix
package, exposed through packages, with no nix run entry or default check/CI
requirement. Canonical sources live under pkgs/org-texmacs-examples/sources/;
README is the ordinary project guide, no separate example README/i18n layer.
Only English and Chinese are selected. Each language has generic index.org
(configuration/metadata/bibliography/build guide) and article.org (mathematics,
statements, native figures/tables), with include-only chapters below chapters/.
Each index has a dedicated companion headline and standalone article.org link,
with article.pdf shown explicitly. Article links back to index.org.

Goal is readable compilable configuration/feature examples, not exhaustive option
combinations or replacement of maintained ERT. User requires package-level Nix
sandboxing plus builder-owned writable state. Content/layout reproducibility
suffices; PDF creation timestamps and bytes may differ. No extra isolation
framework, export-interface redesign or production-package font injection.

## Inputs, paths and build

package.nix collects ./sources with lib.fileset.toSource. No root docs/ parameter
or parent-directory inference. Four independent runCommand leaves cross en/zh
with index/article; every leaf has fresh HOME, TEXMACS_HOME_PATH and XDG state,
no display/session-bus environment and Emacs -Q --batch. A600second inner timeout
covers tangling, preparation, native save and PDF render. Progress/errors/pdfinfo
stream into Nix logs; no log files installed. Failed builds publish no output.

Each build stages one language's entries/chapters, copies shared/configuration.org
to chapters/configuration-source.org and shared/references.org to
chapters/references.org. Configuration tangles common.el/generic.el/article.el;
load common plus selected profile and copy selected profile to profile.el.
References tangle references.bib. Babel tangling copies declared blocks without
executing them; interactive snippets elsewhere are neither tangled nor loaded.
Build driver build.el stays a separate package file, not derived from Org.
Explicit ORG_TEXMACS_DOCUMENT_* paths supply directory/source/output/config/profile/
bibliography; generated filenames are based only on these explicit directories.
Literal source INCLUDE displays the actual loaded config and canonical BibTeX.

Private matching Emacs package set overrides only its org-texmacs dependency to
texmacs-fandol-with-gotor-support. Main Lisp/Emacs packaging keeps plain TeXmacs.
Fandol is an explicit Nix input through TEXMACS_FONT_PATH, not host-font lookup.
Renderer/composition details: memory/texmacs-gotor-probe.md.

Public document-from-buffer-preprocessed receives explicit BibTeX snapshots,
with global discovery disabled. Public .tm and PDF consumers use the same
completed document; saved .tm is not the direct PDF's intermediary.
Aggregate output: pdf/<language>/{index,article}.pdf,
texmacs/<language>/{index,article}.tm, sources/<language>/<entry>/ with canonical
Org and derived .el/.bib. Artifact basenames match entry names. Shared PDF-relative
and Org-to-PDF flags keep sibling PDF links relocatable. Native .tm/session
consumers still resolve source-based absolute file links; saved native links do
not acquire PDF output-relative semantics.

## Content and user preferences

Sources demonstrate metadata and ordered independent abstracts/keywords, citations,
repeated/inline footnotes, option precedence and subtree properties. Mathematics
covers radicals/fractions/indices/powers/Greek notation, sums/products/integrals/
limits, matrices/multiline formulas, definition/theorem/proof/lemma/remark/exercise
and named references. Figures/tables cover native graphics, numbered/starred
wrappers, Org/native tables, native math cells, captions and counter behavior.
Original chapter bodies retained through reorganization. Normal Org table cells
are not paragraph STM discovery contexts. ASCII '(Test prefix)' visibly labels
article headline customization; it replaces the confusing section-sign marker.

Bibliography demonstrates native string declarations/concatenation, @online
fallback and explicitly cited crossref parent. Illustrative records identified
as demonstrations. No BibLaTeX/Biber parity, guaranteed online URL display or
automatic uncited parent inclusion. Explicit unnumbered References/参考文献
heading contains PRINT_BIBLIOGRAPHY. Automatic bibliography at end and TOC before
abstracts are user preferences deferred for separate design. Native macros own
formatting, but current structural document assembly determines their order;
do not claim styles alone choose abstract/TOC ordering.

Keep active Org timestamps with timezone, e.g. <2026-10-27 Tue +0800>
(zh/index retains Oct26). No blank line between a headline and first content.
Chinese authored prose uses ASCII punctuation and commas rather than enumeration
commas. Interactive editing/menu/discovery options are shown without execution;
private extensions are not promised as stable API. Preserve packaged necessary
defaults rather than mechanically setting every public option.

## Evidence and current state

Exact authorized package build and artifact path in current.md; exits0, all four
entries built. Formal GoToR renderer/Fandol/private Emacs also built. Every PDF
has expected relative GoToR Filespec target and existing sibling; Chinese PDFs
embed FandolKai-Regular and FandolSong regular/bold. Native/source/derived inputs
present. Final navigation headings and reader explanation postdate that build:
static review only, no fresh full flake/formatter/post-commit build.

User confirms Zathura pdf-poppler navigation and no further viewing issues;
pdf-mupdf previously failed. Backend difference observed, exact cause unresolved.
Ordinary worktree/index clean at delivery/checkpoint review, stash list now empty.
User removed stashes after comparison found useful content migrated or superseded.
No agent drop. Old docs/three-entry layouts and rejected main-package Fandol
injection are historical, not tasks to restore. No implementation remains selected.
Earlier cleanup/six-document evidence is retained in GAW first-parent history;
it is not acceptance of the latest source bytes.
