# Native Cite N9: accepted default and complete integration

## Candidate and behavior

Accepted26path worktree candidate against human-delivered N8. Exact parent,
paths/message/all167canonical hashes in accompanying -inputs.json. No additional
project parent for this uncommitted runtime state; prior checkpoint grounds exact
N8 delivery verification only. Ordinary index untouched, root TODO, no release
state/CLOSED/tag/publication. tmp/commit.md prepared from authorized complete diff.

The public backend options-alist :cite-export default expression is evaluated by
Org before EXT-PLIST/file/subtree precedence and standard Cite selection. Only
stock ((t basic)) is substituted with ((t texmacs-native)); custom alists/nil keep
standard semantics, including disabled no-matching-backend/fallback result.
Identical assignment history cannot be inferred; explicit basic uses CITE_EXPORT
or (texmacs basic). No global configuration mutation/private dispatch advice.
Options filters and explicit CSL retain standard handling; HTML/LaTeX and nested
exports are isolated. Backend load registers native processor; core/model loading
remains independent, base package does not gain citeproc.

All four EN/ZH generic/article examples now use native default plain/explicit
alpha, shared valid Greek-subscript/fraction BibTeX title and same-document TM/PDF.
Example package drops citeproc; canonical Org tangle and optional explicit CSL
fixture stay. Existing CSL/basic/raw/fragment tests retained, with old stock-default
basic refusal test changed to an explicit backend entry to test the same refusal.
README/root/detail describe actual default, precedence and native limits.

## Inactive ALT_TITLE correction

First full check passed all12checks but example build failed on Unused native
citation request associations. Narrow isolated diagnostic found ALT_TITLE citations
outside actual TOC (off or below depth); active ALT_TITLE/short captions succeeded.
This was our lifecycle guard defect, not native parser/Unicode/math recovery.
Pure lowering now follows only supplied owned request parent links: direct owner
field must be ALT_TITLE and owner absent from actual toc-labels. Such requests are
explicitly accounted without visible output, while Org-provided bibliography keys
remain. All other unused/detached associations still fail. No extra AST traversal
for citation discovery, source positions, callback replay, worker/file access or
third AST. Core regression covers off/visible/below-depth states, repeated pure
lowering and retained bibliography labels. First new assertion counted unrelated
TOC labels; corrected to bibliography-prefixed labels, not weaker node ownership.

## Verification

Focused core316/native7/CSL11/actualOrganize5 passed before subtree and ALT_TITLE
regressions; corrected focused core318 then passes. Initial new integration PDF
assertion failed on native fi ligature; existing Unicode NFKC normalization fixes
fixture. New CSL user-default test expected capitals instead of normal sentence
case; corrected expected title. No production workaround or removed assertion.

Final accepted snapshot tmp/native-cite-n9-final-2 contains167canonical inputs.
Its flake.nix alone adds explicit actual-native-cite check and native formatting;
production flake unchanged. Exact overlay hash and all output derivations in receipt.
Commands, both explicitly authorized single600s runs:
- timeout600s nix flake check --no-write-lock-file --print-build-logs path:./tmp/native-cite-n9-final-2
- timeout600s nix build --no-link --no-write-lock-file --print-build-logs --print-out-paths path:./tmp/native-cite-n9-final-2#org-texmacs-examples

Both exit0. All12named checks pass,694unique defaultERT (318core/282native/11CSL/
48document/29render/6caption) plus actual integration5 =699, zero unexpected.
Core318 exact focused output reused. Strict compilation/package-lint/treefmt and
aggregates pass. Native282 takes200.367772s, PDF-document48 takes120.602414s,
render29 takes154.488143s, real extension5 takes11.212351s. Locked x86_64-linux,
Emacs31.1/Org9.8.10/TeXmacs2.1.5 only. Real extension test retains existing four
CSL cases and adds native default UUID rewrite/dynamic bibliography/same live INFO/
exactly one prep+callback/PDF and subsequent HTML/global restoration.

Four example builds/pdfinfo succeed. Native TM serialized with-bib, math mode,
alpha symbol escape, rsub and frac verified in all four. Bibliography PNG pages
all inspected: plain numeric vs alpha labels and correct alpha_i/fraction; Chinese
Fandol example text visible. Product and8TM/PDF+4PNG hashes in receipt. Preview
artifact check is an isolated120s Nix derivation; first harness omitted derivation
context (sandbox invisible), next expected internal <alpha> instead of serialized
\<alpha\>; corrected harness passes. Neither issue changed production artifacts.
Isolated formatter initially used conflicting tree-root flags; corrected -C only.

## Boundaries and handoff

All26changed/new paths reviewed, diff whitespace passes and167canonical hashes
match final accepted inputs. No ordinary staging/commit. One coupled feature commit,
split unnecessary (medium review complexity: default plus required lifecycle fix,
examples/tests/docs). Human commit then exact receipt verification, then propose
human TODO->NEXT freeze. No auto freeze/finalization/release, no further node.

Generic final-AST latex-fragment conversion remains deferred; native BibTeX math
is a separate existing parser capability. Advanced citation styles, full fields,
Unicode/fonts and strict math-recovery detection remain excluded. No minimum Org,
other-platform/all-style or arbitrary GUI layout certification. Additional raw
archive not needed: maintained minimal ALT_TITLE regression plus N8 history,
existing loader archive and distilled causal evidence preserve reproduction;
do not archive whole build directories or binary products. Four total600s grants
(initial and corrected pairs) consumed, not blanket future authority.

## Human delivery verified

Human22191a0ddcea08aca1e1620a54ed698a6d2c5608 matches exact9d923e7 parent,
26paths/full approved message/all167committed and worktree hashes. Ordinary
worktree/index clean; root TODO and no tag points at this HEAD. No unchanged
runtime gate repeated. Public GAW project association grounds this exact read-only
delivery inspection, not retrospective uncommitted test provenance. Approved
N6-N9 development is complete; only separate human freeze/finalization/publication
choices remain. Remote publication state not queried or changed.
