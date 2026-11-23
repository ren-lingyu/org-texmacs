# Export validation baseline experiments

Captured at 2026-11-23T19:29:58Z from the project worktree at
`9dfb18ed41d3404279b203abddcb1f3e3e384453` (`9dfb18e`).
This snapshot is non-authoritative historical evidence for baseline behavior.

The isolated x86_64-linux flake uses the local Git repository as a source
input fixed to the full commit above. The lock records the revision and its
transitive sources. On another machine, use a local checkout containing that
commit and adjust the local Git input locator before locking.
Both probe derivations were built in one offline invocation with Emacs 31.1
and real TeXmacs 2.1.5. The reports are byte-exact copies of the Nix output
reports, copied first into the isolation directory.

The selected files preserve the exact filter and failure fixtures and the
observed execution order and caption parse evidence after directory cleanup.
All files are original-byte text captures.

| Source path | Archive path | Git status | Bytes | SHA-256 | Evidence role |
| --- | --- | --- | ---: | --- | --- |
| `tmp/export-validation-probe-9dfb18e/flake.nix` | `files/tmp/export-validation-probe-9dfb18e/flake.nix` | Ignored, untracked | 1022 | `01c884c2a4c98fe683d6ca238c69e0e23024c9485b1bef2b7980a64315fc0cb5` | Nix definition for the two package variants. |
| `tmp/export-validation-probe-9dfb18e/flake.lock` | `files/tmp/export-validation-probe-9dfb18e/flake.lock` | Ignored, untracked | 1956 | `efd05267860be80e11f523f8a8d985d75fda1e255b57fdd179e21ad1f651ff3d` | Exact project and transitive input revisions and content hashes. |
| `tmp/export-validation-probe-9dfb18e/probe.el` | `files/tmp/export-validation-probe-9dfb18e/probe.el` | Ignored, untracked | 7114 | `bc406caafacc55aa0881783bb1fbf7099ca7d8ab336e3b29239fed36c7d2360f` | Caption fixtures, entry-point comparisons, and forwarding instrumentation. |
| `tmp/export-validation-probe-9dfb18e/stock-report.txt` | `files/tmp/export-validation-probe-9dfb18e/stock-report.txt` | Ignored, untracked | 5718 | `6343503358671fac550cef682338446bcdd9126788709e213c9c3cef02d47a18` | Original report from the Org 9.8.10 Nix build. |
| `tmp/export-validation-probe-9dfb18e/pre-report.txt` | `files/tmp/export-validation-probe-9dfb18e/pre-report.txt` | Ignored, untracked | 6837 | `b0be1ba6808d54a89cf8817788221088496383d780f600c355bbecd436402596` | Original report from the Org 10.0-pre Nix build. |

The introducing checkpoint is located by this manifest's first-parent
path history. Its project parent identifies the exact source input used
by both Nix probe builds.
