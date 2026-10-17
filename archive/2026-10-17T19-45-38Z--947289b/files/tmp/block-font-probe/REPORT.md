# Block mapping and Chinese fonts: isolated results

## Outcome

No additional production mapping/encoding defect established.14maintained block/
native ERT passed58.636359s on final fixed inputs. Inventory and historical quote/
center correspondence: BLOCK-MAPPING.md. User recalls these two now resolved;
exact lost original source bytes are not reconstructed or claimed.

Chinese:72diagnostic PDFs from three successful24PDF matrices, pinned native
TeXmacs2.1.5/Emacs31.1/Org9.8.10/x86_64-linux. Latest matrix provides a genuine
positive control, not a mere successful build or font-list result:

-6baseline PDFs without a usable CJK font emit red literal <#...> fallback.
-18positive PDFs with full static Fandol font collection emit real Chinese,
 no literal fallback; default fallback, explicit FandolSong, explicit FandolHei;
 generic/article and package/native/reload routes.
-All8config groups have exactly equal extracted text, normalized font specs and
 text-run geometry across org-texmacs PDF, independently constructed native tree,
 and serialized tm fresh reload. Actual glyphs visually checked in generic Serif/
 Sans first-page rasters. This is not interactive GUI testing.
-Body/repeated-body/quotation use consistent within-role text sizes. Headings are
 intentionally larger/bold. FandolSong uses Song Regular/Bold and Kai for italic;
 default-font italic may get native size adjustment (XML16versus15at1.5scale).
 FandolHei italic also has a native size difference (XML13versus15). These choices
 match independent TeXmacs; do not force all roles to one font/size in exporter.

Before this, two Noto VF matrices (Fontconfig-only24, native-registration24) all
showed fallback. Fontconfig sees Noto CJK; registering the actual collections
adds Noto CJK families to native font database, but native font selection still
reports missing masters and emits no Noto CJK PDF glyphs. This establishes a
specific failed native font combination, not a general ban on variable/Noto fonts
or an exact C++ cause. Original user environment has not been inspected; user
reports inconsistency almost everywhere, native GUI comparison not performed.

## Reproducible working configuration

Test-only font dependency is pkgs.texlive.pkgs.fandol.tex from the existing lock.
Full font collection is on TEXMACS_FONT_PATH and fontconfig search path. Each
native process has fresh private TEXMACS_HOME_PATH and four Song/Hei Regular/Bold
OTF symlinks in fonts/truetype; native font-database-extend-local registers those
files. Full directory also provides FandolKai used by native italic substitution.
No user/system font/config installation. Effective initial values for Serif:

```elisp
(("font" . "FandolSong") ("language" . "chinese"))
```

Use FandolHei for tested Sans alternative. Font availability/registration is a
prerequisite; setting the initial name alone does not install or make it usable.
These are ordinary native font/environment settings, not an exporter patch.
Native import is the same API used by the pinned GUI font-import helper; official
Scheme reference documents its URL argument:
https://www.texmacs.org/tmweb/documents/manuals/texmacs-scheme.en.pdf

## Execution and provenance

User explicitly authorized repeated command plus related output/dependency reads:

```sh
timeout 600s nix build path:./tmp/block-font-probe#checks.x86_64-linux.block-font --no-link --no-write-lock-file --print-build-logs --print-out-paths
```

Current committed production source is unchanged; root-inputs.json records32root
inputs including original user flake workaround. Copied flake adds only this
check. All32root hashes rechecked unchanged after final build. No lockfile/index/
production/system/user-config mutation. Three successful outputs:

-initial Noto: /nix/store/ikablia5rjaz2w4yh2bkrypnpkkcq7hb-org-texmacs-block-font-probe
-registered Noto: /nix/store/ddby3q00p2l0szwsdm8b5bn79cscljyq-org-texmacs-block-font-probe
-final Fandol: /nix/store/hn379vmffrkncn4b0znrvzppazcd0sd1-org-texmacs-block-font-probe

Results copied to initial-results, registered-results, fandol-results. Derived
comparison.json is reproduced by analyze.py from final summary, no rerender.
No full flake/release gate repeated; these are bounded focused/native findings.

Excluded diagnostic failures: extra Noto Sans Mono collection invalidated an
initial two-file assertion; explicit selection corrected it. Fandol package
metadata is not a derivation; minimal texlive.combine then failed missing base
texmf.cnf. Locked nixpkgs definition identifies direct .pkgs.fandol.tex output;
final harness uses that, no full TeX environment needed. These attempts did not
run/accept a positive font matrix and are not product failures.

## Release implication

Historical block/regression correspondence is now documented and other supported
block mappings have bounded current native coverage; no new repair warranted.
CJK positive/native control and practical configuration now exist. Do not claim
the user's original font inconsistency fully reproduced/fixed, all font choices
supported, or release readiness. A portable/default CJK policy or end-user
configuration documentation would be a separately selected change.
