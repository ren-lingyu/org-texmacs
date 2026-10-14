# Reproduce Phase 4 evidence

Use project source inputs identified by final-inputs.json, current lock and
archived independent flake. Supply the three extensions' Elisp-only snapshots
under extensions/org-roam-{include,organize,blog}, byte-checking extension-inputs.json.
Their exact checked local commits are recorded in REPORT.md; package histories
preserve that source and no duplicate external package archive is made here.
Candidate project code is uncommitted at capture; the baseline1a254a7 alone does
not reproduce accepted cross-directory behavior. After user commit, verify all
manifest files before rebuilding. Maintained tests/integration/default.nix and
phase4.el remain primary reproduction; full focused/core gate logs regenerable.

Run120s nix build -L --no-link --no-write-lock-file path:<independent-dir>#checks.x86_64-linux.phase4-{probes,focused,integration}.
Run240s nix flake check -L --no-write-lock-file path:<independent-dir> for all checks.
All HOME/SQLite/ID/cache/source/output paths in actual runner are synthetic private
build fixtures. No personal database or package repo writes. Lock supplies Org/
Org-roam/SQLite/TeXmacs; actual library identity is in probe log.

For the six original native context probes, project1a254a7 sources suffice using
baseline-phase4-probes.el as phase4-probes.el; do not run candidate integration
against that baseline to claim acceptance. Original log probes-final.log shows
0.113537s; accepted full gate uses updated probe current-adapter acceptance.

Archive preserves native working-buffer observations and real package runtime
output, selected report and exact input/foreign revision identity. GAW memory and
maintained tests preserve implementation semantics. No immutable old snapshot changed.
