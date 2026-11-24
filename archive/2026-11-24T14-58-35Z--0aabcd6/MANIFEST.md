# D2 headline formatter provenance baseline

Captured at 2026-11-24T14:58:35Z with project HEAD
`0aabcd64225dd921f9dda3ac4877abd91b5efccc` (`0aabcd6`). This is non-authoritative historical evidence.

The local Git flake input is fixed to that exact project commit. The lock
records the transitive dependency snapshots. To replay at another location,
point the local Git input at a checkout containing the same revision.

The final stock derivation was freshly built offline on x86_64-linux.
Emacs 31.1 and Org 9.8.10 exercised genuine export, lowering and native
wire generation. No TeXmacs process was used and no outputs were mocked.
An initial assertion assumed that file links in titles retain file
provenance. Baseline output and documentation confirmed that both paths
fall back to visible text. The final probe asserts that documented behavior
and tests a body file link as a positive control. Earlier failed diagnostic
output is superseded by this capture.

Commands used with the absolute experiment directory in PROBE:

```sh
timeout 120s nix flake lock --offline "path:$PROBE"
timeout 120s nix build --offline --no-write-lock-file --no-link --print-out-paths "path:$PROBE#stock"
```

Original-byte copies from the project-relative source paths follow.

| Source path | Archive path | Git status | Bytes | SHA-256 | Evidence role |
| --- | --- | --- | ---: | --- | --- |
| `tmp/d2-headline-probe-0aabcd6/flake.nix` | `files/tmp/d2-headline-probe-0aabcd6/flake.nix` | Ignored, untracked | 832 | `018140f89b148e5b019117e8cfc7d33d45921233f87f81e694869c502eac8315` | Stock probe build and pinned project input. |
| `tmp/d2-headline-probe-0aabcd6/flake.lock` | `files/tmp/d2-headline-probe-0aabcd6/flake.lock` | Ignored, untracked | 1956 | `7a7f1993308347b8935d87d3406cb023979548167d40135adf75f3bff74aedd7` | Exact project and transitive revisions. |
| `tmp/d2-headline-probe-0aabcd6/probe.el` | `files/tmp/d2-headline-probe-0aabcd6/probe.el` | Ignored, untracked | 3223 | `ec364feeac405137fda0ee81c4a7eaf21e774884a68a624fc6e475e9b140cf6e` | Real API fixtures, compared values and assertions. |
| `tmp/d2-headline-probe-0aabcd6/stock-report.txt` | `files/tmp/d2-headline-probe-0aabcd6/stock-report.txt` | Ignored, untracked | 4633 | `32cb64c752ab639f42e0ea602f9696181c6b104052b10f96333843aa9532a53b` | Original report from the final freshly built Nix output. |

Locate the introducing GAW checkpoint through this manifest's first-parent
path history. Its project parent identifies the exact revision exercised.
