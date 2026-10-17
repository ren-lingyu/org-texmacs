# Block mapping / Chinese font readiness investigation

## User scope and authority

User selected isolated tests for two backlog items, then clarified: historical
blocks likely quote/center, both now solved, original source difficult to supply;
inspect memory/archive and other currently supported native blocks. Chinese font
inconsistency reportedly almost everywhere, native TeXmacs not compared. No host
font/user-config reads or production edits selected. Exact task-authorized repeated
command (plus related locked implementation/output reads and result copying):

```sh
timeout 600s nix build path:./tmp/block-font-probe#checks.x86_64-linux.block-font --no-link --no-write-lock-file --print-build-logs --print-out-paths
```

May download locked test fonts/dependencies and write Nix store/cache/private
HOME/font cache/logs/native/PDF/rasters,600s cap. No lock/index/production/system
configuration writes. All32root input hashes unchanged through final acceptance;
copied production/test source matches delivered baseline, copied flake adds probe
and retains original ELPA workaround. User environment remains uninspected.

## Historical correspondence and supported block audit

Existing memory/block-table-implementation.md and archive
2026-10-15T11-15-33Z--4839029 paired baseline/a-probe reports each10cases prove old
quote output displayed literal tag markers; quotation removes them and adds30pt
indent, matching native reference. Current quote-uniform/container/PDF tests retain
that exact defect class. Old center/center-list controls already pass, including
short/long centered paragraphs; current container/PDF regressions retain coverage.
Do not invent a distinct original center bug or claim recovery of lost source.
User's new recollection permits scoped reconciliation of the historical gate;
no need leave all block work pending solely for unavailable exact old source.

Issue4 closure's bounded emitted-tag audit remains in memory/issue-4-closure.md
and archive2026-10-15T13-12-14Z--8435e5d. Fresh14/14maintained tests passed58.636359s:
quote/center, literal source/example/fixed-width code, native list nesting/paragraphs,
Org table alignment, all admitted statement tags/proof, equation/equation*, four
figure/table variants, NAME native label scopes, STM/file provenance, counters,
real PDF/readback/reload and Chinese encoding. Inventory and exact ERT names in
captured BLOCK-MAPPING.md. No additional mapping defect established, no new code
or tests warranted by this audit. Unsupported block syntax is not automatically
new scope; arbitrary native STM and known caption-note layout remain separate.

## Native Chinese-font results

72PDFs from three successful24PDF matrices, TeXmacs2.1.5/Org9.8.10/Emacs31.1,
x86_64-linux, generic/article. Same source roles: heading/body/repeated-body,
bold/italic/inline math/quotation, Latin controls. Compare org-texmacs PDF,
independent manually specified native tree, saved-tm fresh reload under matched
style/initial/font environment. Source text/tick/point and serialized bytes stable.

Initial Noto CJK variable TTC fontconfig-only matrix24allfallback; native import
matrix24alsoallfallback. Fontconfig lists fonts, native import registers families,
but native lookup still warns missing master and emits no Chinese glyphs. Thus
font-list presence != native rendering capability. Exact C++ cause/general Noto
or variable-font support not established. This is an environment/native-font
combination result, not proof of the user's original mismatch or package encoding
fault. Native import API verified in pinned GUI font-import helper and official
Scheme reference; attempted public raw-source lookup missed cache.

Final Fandol24PDF matrix:6missing-font baseline fallback,18positive real-Chinese
PDFs with no literal fallback. Two styles x default-CJK/explicit Song/explicit Hei
x three routes. All8configuration groups have exact text, normalized font specs
and text-run geometry equality across routes; full pdffonts names including
weight/style also agree (strip only six-letter subset prefixes). Analysis removes only PDF font
subset prefixes and normalizes font IDs. Two generic Serif/Sans first-page rasters
visually checked, no missing glyphs; not interactive GUI testing.

Working isolated config uses full pkgs.texlive.pkgs.fandol.tex output, exposed in
TEXMACS_FONT_PATH and fontconfig; private fonts/truetype Song/Hei Regular/Bold OTF
symlinks, native font-database-extend-local registration. Full set provides Kai
used by native italic substitution. Explicit initial: (("font" . "FandolSong")
("language" . "chinese")), tested alternative FandolHei. Setting the name alone is
insufficient without usable native font environment. Default Latin ComputerModern
plus CJK fallback works too. Heading larger/bold, Song Regular/Bold and Kai italic
are native selections; native italic font scaling (e.g.XML16vs15 default/Kai and
13vs15Hei at1.5scale) also matches all routes. Do not force every role to identical
family/size in exporter. Body and repeated-body consistent within role.

## Diagnostics, retention and next action

Excluded harness failures: Noto package has additional Mono collection, invalid
initial two-file assertion; corrected explicit selection. Fandol top attribute is
metadata, not derivation; minimal deprecated texlive.combine failed missing base
texmf.cnf. Reading locked nixpkgs identifies direct font .pkgs.fandol.tex output;
final harness uses this without unrelated TeX environment. None were product
failures/positive-control acceptance. Registered Noto14tests also passed58.475623s.

Task report/results root tmp/block-font-probe. Necessary23pure-text originals,
actual successful output copies and final script/derivation identity verified:
archive/2026-10-17T19-45-38Z--947289b/MANIFEST.md. No PDFs/rasters/fonts/binaries/
dependencies/full tmp; old quote evidence not duplicated. Archive-only checkpoint
separate from memory; no skill changes. No inferred project parent for configured
untracked harness results. Captured final lock/input hashes bind reproduction.

Bounded block correspondence/audit and CJK positive/native-control investigation
are complete. No additional exporter repair justified. User's actual font mismatch
not fully reproduced/fixed, GUI/other styles/platforms/general font guarantee
unverified. A practical font prerequisite/configuration is available; persistent
README/config guidance or a font default policy would need separate selection.
Do not mark whole0.5.0 release ready; representative documents/final gate/version/
release documentation remain separate. No full flake or default-build repeated
for this bounded investigation, no ordinary staging/commit/external action.
