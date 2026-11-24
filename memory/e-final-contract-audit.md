# Node E final contract and release-readiness audit

## Baseline and status

The project audit began on clean main at
`040a8948aa39fab37d59fe3ec822bb5bd11c6b2d` (D2 delivered) with GAW at
`16f8e479a64ff00c34b5c4893a01033fa1b917ba`. The latest formal release is
`v0.8.0`; the 16 intervening commits and the current candidate were compared
for release coverage. The candidate is 15 modified project files, unstaged,
with full-index binary diff SHA-256
`8b17ebbe1cf482e453e99c055b23fb765d6406fee46f62cf4c1f61a53fd73ba5`.
Production HEAD, package version declarations, flake.lock and published
release notes were unchanged. The checks below apply to this working-tree
candidate as it stood before the final example review. See Delivery below.

The maintainer authorized reorganizing the single README, choosing complete
default declarations with equivalent effective behavior and retaining legal
shorthand. The next version and release are separate maintainer decisions.
The current minimum remains Emacs 31.1 and Org 9.8.10, with the explicitly
selected Org 10.0-pre snapshot
`fd6546e1a9dddedd913a4adaf2ea76eea65c7f67` in its existing compatibility
scope. Node E preserves the architecture delivered in A–D.

## Contract inventory and actions

| Surface | Source evidence and disposition |
| --- | --- |
| Runtime and installation | Checked top-level autoloads, Model module autoloads, package sources and flake outputs. Pure STM/Model work, explicit Input construction and structural lowering work without TeXmacs. The Nix package embeds its selected executable and closure. The setup command checks the full setup without startup. Loading `ox-texmacs` registers the backend and reads menu keys; source export can load the backend lazily. |
| Public configuration | Reviewed all 12 production Custom options. The README lists the 11 ordinary options and puts the obsolete bibliography switch in Upgrade notes. Settings are grouped by startup, request, backend load, Org Cite selection, initial capture and Input ownership. Style and initial remain source-guarded, unlike the other captured presentation options. |
| Cite default | The stored default is now `(texmacs-native "plain" nil)` instead of `(texmacs-native)`. The effective bibliography style remains plain and the citation style remains the native default. Active export INFO can now contain the specified "plain" style instead of relying on the native fallback. The stock and pinned Core tests verify configured preference, explicit declarations, precedence, delegation and style handoff. The native matrix proves the full declaration and shorthand deliver the same required default style. No other defaults needed normalization. |
| Independent Model and STM | Checked parser, constructor, inspection, locators/copy/replacement, codec, serializer and test coverage. The README distinguishes Model validity, reader/writer and Org-container representability, and target conversion. Newly recognized output is checked structurally without native STM parsing. Org can follow SETUPFILE with the pinned compatibility variant. Native equation authoring also uses the Lisp reader. |
| Standard source, Input and Document | Source API docstrings now identify live source buffers, legacy nil bibliography argument, selection and options, Native Cite completion, structural ownership and lowering. README distinguishes independent constructor, standard preparation and completed Document, describes C’s early errors and bibliography acquisition separately, and lists Document fields including captured output policies. The private sources attachment docstring names the D1 precondition. No callback or ownership path changed. |
| Supported structures | The README keeps the target grammar for statement captions, figures, tables, inline content, lists, footnotes, links and effective metadata. It reports both tested Org versions’ equivalent empty-short/long-only statement caption forms and the special caption-footnote limits. Link descriptions support explicit STM. Missing navigation targets fall back to visible content while genuine preparation or structural errors can propagate. |
| Formatter and callbacks | The publicly supported five arguments stay as delivered in D2. The default path retains authored STM provenance, while custom results use literal semantics even when forwarding to the default. The configuration docstring and example agree. Special-block handlers and advice examples are documented as private. Source guards detect covered mutations and cannot undo callback side effects. |
| Native output and errors | Reviewed unibyte .tm, reversible Latin-1 transport for text export, direct PDF, exclusive new-file APIs, interactive overwrite policy and session behavior. The README documents ten defined error conditions and distinguishes pure STM parse failures from native reply, protocol, transport and cancellation errors. Native diagnostics remain available privately. |
| Nix and examples | Checked package names, overlays, variant overrides, leaf test discovery, the Org 10-specific SETUPFILE check and the independent GoToR check. Both language examples now explain literal formatter output and the pure Model path. Removed an old Chinese fragment restriction. Both explain temporary absolute .tm targets and relative direct PDF targets while retaining the existing builder, profiles and tangle inputs. |
| Test precision | Separated external result ownership testing from the stale-prefix case. The latter changes only the prefix of an otherwise valid view and asserts the stale prepared-output diagnostic. Preserved shorthand checks and pinned/stock regression coverage. |
| Release coverage | The unreleased CHANGELOG records the source layout move to elisp/src, shared package definition, changed check entry points, Cite declaration and STM representation boundary. Retained the formatter migration, legacy wrappers/libraries and context removal, C ordering and historical facts from v0.8.0. The README links the development changes and the latest formal release. |

The README follows installation/configuration, STM authoring, independent
Model work, standard export, Input/Document, supported structures, extensions,
native consumers, diagnostics, examples, development and upgrades. Audit found
no contract problem requiring a new public API, transaction change, worker
protocol change or another ownership refactor.

## Verification

Executed on x86_64-linux using the locked inputs and no network shell commands.

- `nix fmt --offline --no-write-lock-file -- <modified-files>` formatted the
  affected files. Git diff whitespace, Org block balance and heading depth,
  and 17 local README links and inbound README anchors passed. The two
  external straight.el links resolve to sections of the official repository.
- `nix flake check -L --offline --no-write-lock-file` passed. The first pass
  rebuilt the two Emacs packages and their compilation/package-lint variants,
  the package and repository ERT suites listed below, and treefmt. GoToR
  reused an existing independent result. The follow-up on the final README
  freshly ran treefmt and reused the other outputs built for the same code
  and fixtures. This was the current-system matrix.
- `nix build -L --offline --no-write-lock-file --no-link --print-out-paths
  .#org-texmacs-examples` freshly built all documents, then returned the same
  output on the final candidate:
  `/nix/store/02n5g0vc8qs6bwgy6k5mzxbylbvqm4yb-org-texmacs-examples`.
  EN index/article PDFs have 7/5 pages and ZH index/article PDFs have 6/5.
  All eight .tm/PDF outputs are nonempty. The .tm bodies verified the styles,
  native bibliographies, article-only test prefix and temporary absolute
  sibling targets. The PDF annotations emitted the relative sibling GoToR
  targets in both directions in both languages. Poppler reported embedded
  FandolSong regular/bold and FandolKai regular for both Chinese PDFs. Visual
  review covered rendered EN index page 2 and article page 5, and ZH index
  page 6 and article page 2. It included affected prose, native mathematics
  and bibliography output. No GUI-reader click-through or full page-by-page
  review was performed.
- Built the `.#emacs` wrapper offline with the same build options. Ran
  `emacs -Q --batch --load <temporary smoke script>` with isolated HOME,
  TeXmacs and XDG directories, Emacs 31.1 and Org 9.8.10. All eight named
  README examples passed on final content: independent constructor and lazy
  loading boundaries, block tree traversal/cache, replacement and normalized
  editable Org, explicit Input lowering, standard preparation, structural
  export with STM paths, real .tm serialization and real native session
  update/readback. The interactive buffer display was adapted to batch mode.
  A first smoke assertion expected naked paragraph prose; observed
  `(document (concat "Hello"))` and updated the script to check that exact
  shape. The examples themselves required no workaround. Pure paths used
  an unavailable program and rejected worker startup. Contextual command
  fragments and installer recipes were audited statically. Only these eight
  blocks were executed; the maintained compatibility checks cover pinned
  Org 10.0-pre.
- ERT evidence from the final outputs: Core 581/581 on each Org, CSL 5/5 on
  each, Org 10.0-pre SETUPFILE 5/5, Native 92/92, Organize 5/5, PDF Document
  26/26, PDF Render 23/23, issues 10/11/12/13 1/3/1/10, caption-note 6/6,
  Org parser 1/1 and native caption layout 1/1. All had zero unexpected
  results. D2’s historical runs were not counted as fresh E verification.
- No build logs, PDFs or temporary smoke harness were added to project
  sources or GAW archives. Nix outputs and this summary hold the relevant
  evidence. No extra two-version native run or compatibility extension was
  needed for the default declaration normalization.

## Delivery

The maintainer committed `chore: align user documentation and make the Cite
default explicit` directly after the audit baseline. The commit message matches
the reviewed draft byte for byte. Substituting the tested candidate's shared
example configuration blob into the committed diff reproduces the recorded
candidate SHA-256. The delivered full-index binary diff SHA-256 is
`97d35f91fba5de434cb18df92dc140887097a731d875c94328ac9177aabea13d`.

The only file-level difference after the full run is
`pkgs/org-texmacs-examples/sources/shared/configuration.org`. The compiled
candidate exposed a tangle indentation issue: a two-space docstring continuation
set the indentation of an otherwise four-space block. The delivered change
uses the baseline article block indentation and docstring, adding one comment
about literal headline output. The executable forms match the baseline
by source inspection. The committed diff passed `git diff HEAD^ HEAD --check`.
The worktree and index were clean. The prior test matrix, example build and
visual checks describe the candidate. The final example source edit received
static review and no post-edit example or treefmt run was performed.

The E changes are delivered. The next version, version-specific notes,
final release checks and publication remain maintainer decisions. Include a
fresh examples build in that release verification to observe the final tangle.
