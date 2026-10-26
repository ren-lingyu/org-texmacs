# Native GoToR probe and delivered packages

Delivered follow-up3ccf195, explicitly requested by user: whole-renderer
before/after hash guards replaced with reviewed href action-dispatch check plus
patch --batch --forward --fuzz=0, retaining version2.1.5. Shared generated guard
and exact patch supplied through passthru to maintained tests. Unrelated renderer
edits allowed; changed dispatch/missing href/double patch rejected. Default
tests/texmacs-with-gotor-support regression directly compares base/patched runtime,
without Org/font wrappers. Focused build passes; output/limits in current.md.
This supersedes full-file hash policy below, which describes original experiment
and first delivery. Patch C++ bytes unchanged. No full ERT/flake rerun.

Latest user correction: switching Zathura to pdf-poppler makes previous links
work. Supplied version output: Zathura2026.10.4, girara2026.07.18,
pdf-poppler2026.07.18. Prior failure used pdf-mupdf. Thus generic Zathura
incompatibility is superseded; backend-specific behavior observed, exact cause
not established. User subsequently confirms no further viewing issues.

Current production names, selected and renamed per user:
pkgs/texmacs-with-gotor-support and pkgs/texmacs-fandol-with-gotor-support.
Flake outputs/devShell/overlays agree. The font variant calls
texmacs-fandol.override { texmacs = texmacs-with-gotor-support; }.
Both named flake outputs are delivered; devShell and examples use final wrapper.
Renderer guard runs after upstream patches/postPatch, asserting version2.1.5
and original action dispatch before zero-fuzz patch application. Patch is byte-
identical to accepted experiment, including probe helper names. Formal package
build later succeeds through examples; see documents-package.md/evidence.md.

User selects standalone flake experiment, explicitly retaining existing Chinese
font method. Both baseline and patched2.1.5 use unchanged copied texmacs-fandol
package. Probe consumes native STM directly, no org-texmacs runtime or PDF
postprocessor. Root lock copied unchanged. Official source archive SHA256
b3a127bdba8e79010b239291415cbe3431333521e24477a814b586e1b4027360
matches actual locked source derivation. Detailed source audit is in evidence.md;
STM already expresses external file/label, unpatched native PDF maps them to URI.

User authorizes repeated exact command:
`timeout 1200s nix build --no-link --no-write-lock-file --max-jobs 2 --cores 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs/tmp/texmacs-gotor-probe#checks.x86_64-linux.gotor -L`.
Default daemon denial resolved through same-command escalation. Two native
compiles348s each; subsequent check-only changes reuse compiled output.

Patch selects bare scheme-free .pdf paths case-insensitively, retains path form,
emits GoToR page0/Fit. Filespec F contains UTF8 bytes, UF native PDF text, both
hex encoded. Query/anchor/network/scheme/nonPDF targets keep original behavior.
First run exposes Cork <#...> being mistaken for #anchor; classify decoded UTF8.
Second run exposes inspector comparing URI-encoded reader names; decode them.
No production source changes or existing font method changes from these fixes.

Final check passes: baseline/candidate27annotations each, candidate18GoToR for
9path forms (bare,./,../,subdir,space,Unicode,parentheses,uppercase,absolute),
8unchanged URI controls and1internal destination. MuPDF identifies all file
targets/page0. Extracted text identical with Chinese substring, both embed
FandolSong-Regular. Relocated actions/reader data unchanged, relative targets
all exist. Absolute control preserves build path, not a portable click target.
Strict guard check verifies original renderer, rejects synthetic source drift,
applies patch --fuzz=0, verifies exact result, rejects already-patched input.
Original SHA256310dc4526ecc7688683a69672f7004bb514bca6d8c4c55fad11540ea45db67ba;
patched SHA256ab2ee98e69c20ac3fb744e4771a20d523edb61b6dee338192d5f3e9c22f0cbc0.

Latest output /nix/store/q5dyka224dz4mhbyf6p0lyp9c7bywp1b-texmacs-gotor-probe
has visible TARGET DOCUMENT/filename markers in destination PDFs. Earlier
sy6g358kb0vfz503a79006cxcdqdic4m has same checks with blank targets.
Probe/manifest/report/strict package draft retained in tmp/texmacs-gotor-probe.
No raw archive selected; distilled hashes/contract/provenance sufficient.

PyMuPDF binding1.28.2, MuPDF1.28.5; original Zathura pdf-mupdf also links1.28.5.
Baseline raw link file://article.pdf becomes file:article.pdf#page=1&view=Fit.
Parser success alone does not prove GUI dispatch/open. User's successful other
reader failed with baseline URI and succeeded with GoToR, supporting adoption.
Original Zathura backend failure and later pdf-poppler success are distinguished
above; exact GUI dispatch cause unproven. Do not promise every backend works.

User requested experiment checkpoint before packaging; sequence honored. Original
texmacs-fandol implementation unchanged. Examples restored/adapted/delivered,
stash cleanup performed by user; latest stash list empty. No standalone package
README tracked; README and compiled example build chapters document composition.
External named destinations were not added; maintained behavior check now exists
as described above. Isolated experiment evidence remains distinct from later formal examples
build acceptance and from final prose/navigation changes not rebuilt.
