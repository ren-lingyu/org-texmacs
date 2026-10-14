# Phase 2c native preprocessing investigation and selected contract

Baseline: main c52509573e5bccddeb661cf1dab1802733ac7dec, current project lock,
user USTC transport overlay. Emacs31.1/Org9.8.10. Research does not use personal DB
or native TeXmacs. Nine standalone native composition ERT probes pass; initial
flake duplicate-checks failure was corrected before successful experiment.
Logs probes-second.log and probes-protection.log, code phase2c-probes.el.

## Native findings

Location via headline/CUSTOM_ID, only-contents and lines combination, lines alone
and minlevel operate through native INCLUDE. Location+only-contents strips root
heading/properties; lines select normalized section content. Excluded nested
INCLUDE does not read missing file. Native footnote extraction restores used
outside-selection definition including STM. Root/ordinary link/resource context
stays common-base in selected profile.

Unprotected texmacs block containing fake INCLUDE attempts a missing-file read;
inline math string [fn:a] is renamed to [fn:-0-a]; headline-looking multiline raw
STM is relevelled. The latter crosses existing fragment grammar, so it is a native
hazard observation, not supported org-texmacs island evidence. Native lines can
silently discard multiline STM delimiters. Line-count-preserving opaque shielding
survives location+only-contents, lines and minlevel combinations without general
source maps. Maintained block test uses current supported special-block grammar.

Scoped org-file-contents fixed-copy experiment: four reads (two location/preparation
pairs) consume one captured file even after disk changes; production must also
reject changed receipts. Repeated full-file footnotes share native per-file prefix
and can yield duplicate definitions; target preflight remains authoritative.
Maintained test exposes native rejection of nested same-file location-only refs
with distinct headings; do not implement a separate recursion rule to accept them.

## Adopted minimum

Native INCLUDE with original file identities, private fixed reader capture, native
parse/absolute-lines/prepare helpers own parameter and transformation semantics.
Protect only discovered STM spans with opaque start/end placeholders preserving
newline count. Use native selected absolute lines against original captured spans
solely to reject partial STM. Final discovery owns working islands, no occurrence
mirror/general AST provenance/exact original source-map prerequisite.

Keep original/final working strings and fixed acquired path/text snapshots in INFO;
remove adapter-specific composition/source/island origins and node annotation.
Retain opt-in public signatures, common-base/full-root/ordinary-level policy,
64KiB local UTF8 files, depth8/count32/root+unique captured total256KiB/final256KiB,
physical/symlink/read/config checks, hooks/native identity guards and final source/
bibliography transaction. No pure I/O/new slot, generic/full lifecycle, wrappers,
cross-directory STM, Babel/macros/SETUPFILE/BIND, file publication or sandbox.

## Implementation/verification status

Production candidate edits preprocess module, README and ERT only. Six new cases
plus three further cases maintain parameter selection, native STM output, external
notes, selected nested reads, fixed-copy isolation, native cycle/error policy,
invalid parameters/UTF8/depth and scoped helper restoration. Existing transaction,
source/hook/native return and HTML/ASCII coverage retained. Origin-contract tests
now verify owned final snapshots rather than invented originals.

First accepted focused24/24,13.023997s. Final27/27 focused pass13.482343s; complete368/368 ERT209.352130s,
all five current x86_64-linux flake checks/strict compilation/package-lint pass. Early docstring warnings corrected; old origin assertions revised with
explicit documented contract change, setup/BIND early checking restored, unsupported
cross-heading multiline STM test corrected rather than broadening discovery.
