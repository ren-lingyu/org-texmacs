# Reproduce Phase 6 menu evidence

Historical recipe, not command authorization. Prepare a new isolated directory
with25 exact project source/lock/test inputs in final-inputs.json plus archived
flake.nix/flake.lock and phase6-probes.el. Candidate uncommitted at capture;
Phase5 capture HEAD alone does not include Phase6 changes. Verify hashes first.
Root mirror rewrites transport URL, retaining locked upstream content hashes.

Probe runner loads maintained ERT helpers then native menu investigation. Baseline
probe log is before candidate production edits on5f4c9c0; same unchanged probe script
also passed candidate full gate. Tests use actual Org menu/native register/UI with
injected read-event sequences and synthetic backend registries, no personal settings.
Maintained ERT tests first-load cases in fresh locked batch Emacs, not post-require
bindings. Copying script does not authorize executing it.

Build checks.x86_64-linux.phase6-probes/phase6-focused/phase6-integration using
nix build -L --no-link --no-write-lock-file path:<isolation>#<check>,120s limit.
Full gate nix flake check -L --no-write-lock-file path:<isolation>,240s limit.
Optional integration requires Elisp-only extensions/{org-roam-include,org-roam-organize,
org-roam-blog} at exact hashes/revisions in extension-inputs.json. Source-root names
are provenance, not implicit external-read permission. Org-roam runtime from lock;
fixtures create/clean synthetic SQLite and publication dirs, no personal DB.

Store/network/cache availability can differ. Poppler/TeXmacs supplied by checks for
existing PDF semantics. Other platforms/GUI and runtime menu refresh not verified.
Archive excludes foreign source copies/full build products/DBs/PDFs and duplicate
maintained test logs; current code/history plus this environment preserve reproduction.
