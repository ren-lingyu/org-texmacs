# Reproduce Phase 0

The evidence is text only. Copy the archived `tmp/issue-1-phase-0/` files into
a fresh writable directory; never run in or mutate the immutable archive.
The isolated flake lock is the project lock from commit
`b22945493102edc1823fe063f9d278ba628bdf5e`. USTC URLs only change fetch transport,
retaining the locked Org source hash. No project flake overlay is required.

Create `project/` in that disposable directory and materialize these exact
project files from that commit (ordinary Git history is the external dependency):

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

For each explicit filename, use `git show COMMIT:FILENAME` from the project
repository and save to the disposable `project/FILENAME`. Do not use worktree
restore/checkout and do not overwrite production files. `project-source.txt`
records their hashes and the byte comparison performed at capture. These source
files are omitted from the archive because the supported Git commit preserves
them exactly. No Scheme service is needed: no worker is started.

Then, from the disposable directory, run:

```
timeout 120s nix build --no-link --no-write-lock-file .#checks.x86_64-linux.probes
```

This command may download missing Nix/Org dependencies and writes Nix store and
caches; use only with appropriate execution/network authorization. Version checks
are part of the derivation and record actual Emacs/Org library locations. Successful
output contains environment.txt, ert.log, observations.sexp and summary.txt.
The expected result is 14 tests / 0 unexpected under Emacs 31.1 / Org 9.8.10.
Timing, store locations and working-directory paths need not match.

The probes manipulate only controlled temporary Org buffers. INCLUDE/SETUPFILE
read the supplied fixtures. Babel execution and ID database access are replaced
with controlled spies. Bibliography discovery advice, include advice and shared
local-setting mutations are scoped to temporary buffers/a fresh batch Emacs.
This is not production integration or a promise to sandbox arbitrary extensions.
