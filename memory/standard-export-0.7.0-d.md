# D: standard Org Cite and actual extension

## State and authority

A-C are human-delivered. C delivery matches its expected parent,14paths,
message and147accepted input hashes. D implementation remains an uncommitted
candidate; E must wait for D acceptance and human delivery. Standing scoped Nix
authority and ordinary Git boundaries remain in the approved execution plan.

## Chosen path

Keep real org-export-as, original dynamic scope and Org-owned bibliography,
processor selection, AST filters and Cite calls. Existing CSL returns supported
Org objects/elements for this backend, including links/targets and rich text.
The adapter consumes BIBLIOGRAPHY after Org uses it. Raw is target code, not
ordinary text/STM: reject it explicitly before native parsing when discovered.
No string/native round trip, custom processor, manual key/discovery path,
extension-specific production logic or third AST is selected.

The prototype standard texmacs numeric/plain processor with native wrappers and
pending bibliography jobs worked, but CSL reuse makes it unnecessary for the
verified subset. It remains comparison evidence, not a production protocol or
future commitment. Independent core/pure/native bibliography APIs retain their
existing behavior; old source conveniences still await E.

Native structured consumers accept the known unadvised/unreplaced CSL finalizer
and its captured format-dispatch definition outside HTML/LaTeX. The locked
finalizer only changes org-latex output. Unknown callbacks, advised/replaced
definitions and effective body/final text filters reject without effect probing.
Text export runs standard finalizers and body/final filters once on final text.
Captures are compatibility checks, not an arbitrary-Elisp security sandbox.

## Evidence

Comparison8/8 and simplified CSL/actual extension6/6 pass in the task isolation
on locked Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux. Return matrix covers
element, secondary string, target string/raw, reentrant org-export-data/raw and
native wrapper; callbacks once with identical Cite INFO. The initial raw-only
walk missed paragraph objects; full org-element-map t corrected the probe.

Selected byte-exact source/runtime comparison is immutable at
archive/2026-11-02T20-32-35Z--054d6cf/MANIFEST.md:152input hashes, five-source
delta, four probe files, fixed source pin and one source/runtime log. Earlier
overwritten failed harness versions are not claimed reproducible. No PDFs,
closures, whole temporary tree or routine failed logs were retained.

Actual org-roam-organize pin:
56fdaac6adab06deafc23357aec63ae2a497e09b,
sha256-rZBPdTRUmPKrk0JWkF5ukQs9qjPzo6600Vct2P3Ac9A=.
Its normal mode requires one moc record. Real SQLite/hooks/advice rewrite managed
UUID keys and update INFO bibliography; later discovery is export-local and
excludes unused managed sources. Actual CSL document/PDF/HTML pass after valid
fixture setup. No business-logic mock or extension patch is used.

## Maintained candidate and unresolved validation

Root candidate adds export/prepared changes, core protocol tests, dedicated
ert-cite default check (citeproc only in test Emacs), pinned optional integration
runner, README/CHANGELOG.154inputs copied to tmp/standard-export-0.7.0-d/acceptance.
Scoped fmt passes10files/8changed. Focused core299/299 passes strict compilation.
The other checks reveal three distinctions before full acceptance:

- Org may extend the INFO plist after AST filters. Test propagation plus
  identical INFO between Cite callbacks, not eq with the earlier plist head.
- CSL bracket layout emits [*see* ...], which its final Org parser treats as
  literal stars; an unwrapped layout preserves bold. Consume authoritative final
  AST rather than repairing processor output. Tests separate those contracts.
- Italic CSL output includes U+200B Org delimiters. The original native PDF
  displays literal <#200B>. The isolated `(space "0em")` lowering experiment
  passes7/7: model retains Unicode and native PDF shows ab without the marker.
  This pure lowering change is now in the production candidate with model/PDF/
  word-width regressions, still pending maintained validation. PDF text also uses
  legitimate fi ligatures; normalize observations with NFKC for text matching.

Focused integration2/2 after NFKC matching does not alone prove the zero-width
fix; the new explicit marker/width checks must pass. Cite was3/5 before INFO/
affix assertion corrections. Early target-raw checks now also cover secondary
titles/captions/INFO and native block contents before body workers, with a core
regression. Second scoped fmt passes6files/6changed;154inputs refreshed exactly.
Focused-3 is running all three targets with keep-going, then full Nix gate.
Review retention for the
new causal zero-width evidence, update manifests/docs/draft, and await human D
commit before E. No release/version bump or ordinary staging/commit performed.
