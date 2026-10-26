# Native GoToR probe and conditional package adoption

User selects standalone flake experiment, explicitly retaining existing Chinese
font method. Both baseline and patched2.1.5 use unchanged copied texmacs-fandol
package. Probe consumes native STM directly, no org-texmacs runtime or PDF
postprocessor. Root lock copied unchanged. Official source archive SHA256
b3a127bdba8e79010b239291415cbe3431333521e24477a814b586e1b4027360
matches actual locked source derivation. Detailed source audit is in current
memory; STM already expresses external file/label, native PDF maps them to URI.

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

PyMuPDF binding1.28.2, MuPDF1.28.5; local Zathura plugin also links1.28.5.
Baseline raw link file://article.pdf becomes file:article.pdf#page=1&view=Fit.
Parser success does not prove GUI dispatch/open. After visible markers were
added, user initially reports success, then explicitly corrects: navigation
failed in Zathura but succeeded in other readers (names not supplied). Latest
correction is authoritative; Zathura acceptance fails despite native action and
MuPDF parsing success. Reader dispatch is a plausible remaining cause, not yet
proven against the exact installed GUI execution path.
User additionally confirms the successful reader failed on the baseline URI
links and accepts the GoToR result as successful. This within-reader contrast
supports adoption; Zathura remains a documented compatibility limitation rather
than an adoption gate. Do not claim its exact cause has been established.

User stashes examples as [wip] example, ordinary worktree/index clean at intake.
Do not restore stash automatically. Conditional adoption if feasible and
maintenance acceptable: sibling pkgs/texmacs-gotor and texmacs-gotor-fandol,
latter explicitly via texmacs-fandol.override {texmacs=texmacs-gotor;}, then
examples/devShell use final wrapper. Original Fandol implementation unchanged.
Strict source/version/result-hash and no-fuzz package draft ready, not promoted.
Reader acceptance is sufficient per user; proceed with conditional packaging.
External named-destination
support, production packages/check wiring and full org regressions not done.
