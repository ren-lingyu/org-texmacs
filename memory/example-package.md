# Configuration and documentation example package review

## Selected objective and authority

User requests a buildable configuration/documentation example package, exposed
through flake packages, with compiled PDFs in out and preferably complete public
configuration coverage. Current authorization is review and GAW maintenance only:
no ordinary project edits, implementation, dependency resolution or builds.
Interpret out as the Nix output directory; exact name/layout remains proposed.

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

## Next design work

Review complete; no ordinary project files changed or commands tested. Next
implementation plan should select package name, source layout, main document
versus a small variant set, and a coverage matrix. A single package producing
a main explanatory PDF plus only necessary variant PDFs is a recommendation,
not an adopted file count. Implementation and validation need their own user
authorization. Existing release evidence retains its original input scope.
