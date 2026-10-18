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

## Follow-up selected: user's bundled-font override

User reports their TeXmacs test binary comes from ~/emarccs/flake.nix override,
requests same method without requiring its locked nixpkgs revision. Authorized
relevant external source reads; flake11378bytes SHA256
f0bdd26bb23af4bdab5b044d2f0018007d2e5b1d8cbbc13e392cd1c61fbb82c7
contains no texmacs literal; relevant import is pkgs/org-texmacs/override.nix,
282bytes SHA25677996aca172435858af4c50f68b820d74d7ab2a4f6499e100e168bd866ef21ec.
Its scope.executablePackages uses pkgs.texmacs.override with extraFonts=true,
chineseFonts=true,japaneseFonts=true,koreanFonts=true. No other font configuration
read or inferred. Retention judgment at first read: sufficient exact method,
wiring/source identity extracted; no independent raw-original value after this
extraction, so don't archive whole foreign source. Foreign files may change later.

New isolated tmp/font-override-probe32input snapshot on statement-caption delivered
baseline; root production/flake/lock unchanged, copied flake only adds probe check.
Both programs explicit in environment and org-texmacs-program binding; same current
package for both, independent native hand-built matching tree and tm reload.
Two styles x two language modes x two binaries x three routes=24PDFs. Inspect
text, normalized font assignments/full font names/geometry, native initial/font
database and selected package env; preview4override PDFs. No Fandol font import,
manual native DB registration or host-font configuration to mask override effect.
FONTCONFIG_FILE is an empty isolated fontconfig, native bundled fonts remain.

User authorized repeat command plus related locked TeXmacs/derivation/font reads
and output reading/copying:
```
timeout 1200s nix build path:./tmp/font-override-probe#checks.x86_64-linux.font-override --no-link --no-write-lock-file --print-build-logs --print-out-paths
```
May download font assets/rebuild native, write store/cache/isolated HOME/logs/tm/
PDF/XML/PNG;20min cap. No foreign files/root code/lock/index writes. Execution
completed with findings below. Previous72PDF results remain earlier baseline,
not evidence for this newly specified override environment.

### Follow-up result: matching symptom reproduced

Authorized build exit0,24PDFs/8groups, source output
/nix/store/bp90n93w3bschsa90jlqs8bhwhr0q88x-org-texmacs-font-override-probe;
actual program paths plain5ri673m... vs overridden dgg3ahc... (both2.1.5), distinct
verified via native derivation. Project-pinned nixpkgs supports extraFonts=true
by default and CJK flags=false; override unpacks Chinese/Japanese/Korean bundles.
Native fonts include fireflysung and unbatang. No Fandol/manual DB registration.
Default and language=chinese initial modes tested, readback roman/rm10pt confirmed.

12override PDFs have actual Chinese,12plain PDFs show literal missing-glyph
fallback. All8three-route groups exactly match text, normalized font assignments/
geometry and complete emitted face names after only subset-prefix normalization.
Within same unstyled body phrase 中文测试, 中文=UnBatang (Korean), 测试=AR-PL-New-Sung;
XML size13 vs14 at1.5scale, top differs1XMLunit. Repeat/body/quote same split;
heading 标题 uses NewSung and 中文 UnBatang; strong mixes UnBatang-Bold/NewSung
synthetic repeats; italic also mixed. Both styles and both language modes reproduce.
Thus real within-word font inconsistency, not just intended role-specific bold/
size. Independent native input and tm reload reproduce identically: current evidence
points to native CJK font selection/fallback with overlapping glyph coverage,
not exporter changes. Exact fallback selection priority/root implementation cause
not yet traced. Two override previews viewed generic/default and article/chinese.
No GUI/exact user's lock/cache/host-font reproduction claim. This supersedes prior
font baseline conclusion of not-yet-reproduced with user's now-supplied method.

All32root runtime input hashes unchanged,31non-flake snapshot files equal root,
copy flake only adds check; root workaround/lock unchanged, index empty. User goal
of attempted reproduction handled, no production/font policy/worker/parser patch.
No full package release gate rerun necessary for diagnostic scope. REPORT.md,
analysis.json and native result copies under tmp/font-override-probe. Necessary12raw pure-text originals preserved separately at
archive/2026-10-18T13-47-27Z--75762b0/MANIFEST.md. Harness and Emacs fixture verified
against actual native derivation, selected result copies match immutable store,
archive source/copy/index hashes verified. No binaries or raw foreign originals.
No additional project parent inferred for configured untracked experiment. No reason
to capture full foreign originals after
accurate method/source identity extraction. Next native fallback configuration
investigation or mitigation requires user selection.
