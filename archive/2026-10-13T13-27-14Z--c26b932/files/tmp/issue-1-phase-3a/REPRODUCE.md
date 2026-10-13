# Reproduce Phase 3a component investigation

Copy archived files/tmp/issue-1-phase-3a into a fresh disposable writable directory.
Do not run in or modify the immutable archive. The standalone flake/lock selects
project-locked Emacs 31.1 and Org 9.8.10, with transport-only USTC URLs and original
source hashes. No personal database or native TeXmacs process is used.

Materialize these eleven files from ordinary project commit
`c26b932a8376c610603eaeb0f9ed8af98c1f6476` into a local `project/` directory:

```
org-texmacs.el
org-texmacs-core.el
org-texmacs-ast.el
org-texmacs-source.el
org-texmacs-fragment.el
org-texmacs-worker.el
org-texmacs-context.el
org-texmacs-document.el
org-texmacs-input.el
org-texmacs-session.el
ox-texmacs.el
```

Use read-only `git show COMMIT:FILENAME`, writing each result only into the
disposable project directory. Their exact bytes/hashes are in project-source.txt.
These existing committed sources are explicit external dependencies of the
isolated flake, omitted from the archive to avoid redundant source history.

Run in that disposable directory, only with appropriate build/network authority:

```
timeout 120s nix build --no-link --no-write-lock-file .#checks.x86_64-linux.discovery
```

The build may fetch missing locked dependencies and writes Nix store/cache.
Expected result: 25/25 under Emacs 31.1 / Org 9.8.10; output contains environment.txt,
ert.log, summary.txt, observations.sexp. Timing and store/work paths may differ.
All BibTeX/SETUP files are fixtures. Tests create fresh mutable files, a symlink
and hardlink only in Nix's disposable work directory for identity/failure probes.
Remote SETUPFILE, inaccessible files and native operations use controlled stubs.
Standard advice is removed with unwind-protect; arbitrary package callbacks and
real database integration are not tested. The acquisition/private-discovery
functions in probes.el are research models, not installed production APIs.
