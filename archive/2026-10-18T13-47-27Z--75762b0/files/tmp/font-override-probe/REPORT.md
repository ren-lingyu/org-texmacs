# User-style TeXmacs bundled-font override: reproduction

## Result

Reproduced within-word Chinese font mixing under the user's override method.
Plain vs override TeXmacs2.1.5, pinned project nixpkgs (user explicitly permits
a different lock), generic/article, default/chinese language, three routes each.
24PDFs:12plain missing-font literal fallback;12override contain actual Chinese.
All8configuration groups have identical text, normalized font assignment/layout
and full embedded font-face names across org-texmacs PDF, independent manually
constructed native input, and saved-tm fresh reload. Two override PNG previews
visually inspected (generic/default and article/chinese); no GUI test.

In each override PDF, ordinary same-run Chinese splits by character:
- 中文: UnBatang (Korean family), XML size13 at1.5scale.
- 测试: AR-PL-New-Sung, XML size14, top1XMLunit lower in ordinary body.
The same split recurs in repeated body and quotation. Headings use NewSung for
标题 and UnBatang for 中文. Strong uses UnBatang-Bold for 中文 and repeated
NewSung glyph drawing for simplified characters; italic has mixed families too.
Thus this is not just intended heading/bold font differentiation: unstyled
adjacent Chinese characters already use different families/sizes/baselines.
Language=chinese alone did not remove it. Native output exactly reproduces it;
no exporter-specific font corruption or production repair justified by evidence.
Likely native smart-font fallback/overlapping CJK glyph coverage; exact algorithmic
priority/root implementation cause not yet traced. This reproduces a matching
symptom under supplied method, not every setting/cache/font of user's GUI host.

## Method/source provenance

User requested reading ~/emarccs/flake.nix and applying its override method.
Foreign flake imports packages; actual override at
/home/lingyu/emarccs/pkgs/org-texmacs/override.nix uses scope.executablePackages:
texmacs.override {extraFonts=true;chineseFonts=true;japaneseFonts=true;koreanFonts=true;}.
No foreign edits, lock reuse or broad host configuration reads. Flake11378bytes
SHA256f0bdd26bb23af4bdab5b044d2f0018007d2e5b1d8cbbc13e392cd1c61fbb82c7;
override282bytes SHA25677996aca172435858af4c50f68b820d74d7ab2a4f6499e100e168bd866ef21ec.
First-read retention judgment: exact four flags/wiring/hashes sufficiently captured,
no independent need to archive entire foreign original; later files may differ.

Experiment directly reuses four flags in probe.nix with project-pinned pkgs.
Default package extraFonts already true,CJK flags false; CJK toggles unpack native
Chinese/Japanese/Korean font archives during postPatch. Override bundle contains
fireflysung/ipa/unbatang plus ordinary fonts. Locked recipe:
/nix/store/cdqajhw7dpw5ddff4g8mxf1i69v0g93d-source/pkgs/by-name/te/texmacs/package.nix.
No manual font import/registration, Fandol, external host font directory, or native
style patch. Empty private fontconfig/private HOME/TEXMACS_HOME_PATH for isolation;
TeXmacs bundled fonts used normally. Both program paths explicit in Scheme launch
and org-texmacs-program binding, keeping same org-texmacs package for both.
Native body readback/initial state and database families recorded; font remains
roman/rm10pt, chinese mode confirmed by native env readback. Relative non-CJK
styling comes from native generic/article; fixed Org source and corresponding
native tree include heading/body/repeat/strong/italic/math/quotation.

Plain program /nix/store/5ri673m8kksap2p2r7gwgqjfwh410sls-texmacs-2.1.5/bin/texmacs.
Override /nix/store/dgg3ahcaizvbpxi5v85djzlkg1pbyy2j-texmacs-2.1.5/bin/texmacs.
Successful output /nix/store/bp90n93w3bschsa90jlqs8bhwhr0q88x-org-texmacs-font-override-probe;
derivation /nix/store/cylh4vpajy4jr97mkk44x4labm0c2m1n-org-texmacs-font-override-probe.drv.
Copies in results/ match store outputs; no claim bytes are part of project HEAD.

## Authorization and boundaries

User authorizes repeating timeout1200s nix build
path:./tmp/font-override-probe#checks.x86_64-linux.font-override --no-link
--no-write-lock-file --print-build-logs --print-out-paths,
plus related locked font/derivation reads/output copies. Command exit0,24PDFs.
No full ERT/flake/default-build acceptance needed for diagnostic-only scope.
32root input hashes unchanged,31non-flake copies equal root; copied flake adds only
probe check. Root flake workaround/lock/production unchanged, ordinary index empty.
No font fix, default-font policy or project code/tests/docs change selected.
