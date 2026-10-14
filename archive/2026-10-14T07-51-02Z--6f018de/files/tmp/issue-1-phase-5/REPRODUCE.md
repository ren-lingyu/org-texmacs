# Reproduce Phase 5 evidence

Historical recipe, not execution authorization. Use explicit authorization and
appropriate120s/240s limits, same project lock and source inputs. Candidate source
bytes are specified by final-inputs.json; capture HEAD6f018de alone does not contain
this uncommitted implementation. After user commit use exact manifest-matching files.

Create a new isolated project directory with25 source/lock/test inputs and archived
flake.nix/flake.lock. Add archived phase5-probes.el; runner explicitly loads maintained
core ERT helpers first. Compare each SHA256 before running. Root flake mirror rewrite
is a transport substitution with locked upstream content hashes, not new lock state.

For optional integration add Elisp-only directories under extensions/{org-roam-include,
org-roam-organize,org-roam-blog} with exact commits/module hashes in extension-inputs.json.
Original local source roots are provenance locations, not implicit read authorization.
Org-roam comes from same locked emacsPackages runtime in isolated flake. No personal
DB/registry; synthetic fixture creates/cleans its own SQLite/files/publication roots.

Run with --no-write-lock-file and --no-link for individual nix build checks:
checks.x86_64-linux.phase5-probes, phase5-focused, phase5-integration, then
nix flake check -L --no-write-lock-file path:<isolated-root>.
Full source/tests and README needed for package compile/lint/default checks; sources
alone cannot reproduce real fixtures without exact third-party inputs. PDF semantic
inspection requires Poppler provided by focused/integration/core runners. GUI/all
configs/all platforms not covered. Store/cache availability/network may differ.

Baseline accepted probe log was on6f018de before production changes; same probe
script re-ran against candidate during full gate. Actual integration log corresponds
to final candidate (README-only wrapping/support prose changed after standalone log,
then all integration/core gates reran successfully). The manifests define final source.
No build products, PDFs, DBs or foreign code are retained in this archive.
