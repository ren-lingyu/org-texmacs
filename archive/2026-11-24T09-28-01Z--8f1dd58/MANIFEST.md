# Node D Native Cite data flow probe

Captured at 2026-11-24T09:28:01Z with project HEAD
`8f1dd58d52aad211345f57ec6c28110e30f6f7b2` (`8f1dd58`). This snapshot is non-authoritative historical evidence.

The capture context is the local project worktree. The experiment source
is the exact local Git flake input pinned by rev in the lock. The selected
original-byte files are the final probe source, its dependency lock, and
the report produced by the final derivation. The earlier development report
is superseded. Source paths are relative to the project worktree.

Commands used from the project or experiment directory, where PROBE is the
absolute directory contained under files/tmp in this snapshot:

```sh
timeout 120s nix flake lock --offline "path:$PROBE"
timeout 120s nix build --offline --no-write-lock-file --no-link --print-out-paths "path:$PROBE#stock"
```

The final derivation was freshly built offline on x86_64-linux (exit 0) and
reports passing assertions with Emacs 31.1, Org 9.8.10 and TeXmacs 2.1.5.
The report was copied verbatim from the Nix output. The probe forwards to
production Lisp and the real native worker with no replacement results.
The manifest does not record a second Org version or a performance claim.

| Source path | Archive path | Git status | Bytes | SHA-256 | Evidence role |
| --- | --- | --- | ---: | --- | --- |
| `tmp/d-native-cite-probe-8f1dd58/flake.nix` | `files/tmp/d-native-cite-probe-8f1dd58/flake.nix` | Ignored, untracked | 845 | `64d13d47a9a0e7c1373a5913e8a9c3061bf04ecbd2c98c9c9e7219740d29f80d` | Isolated stock build and fixed project Git input. |
| `tmp/d-native-cite-probe-8f1dd58/flake.lock` | `files/tmp/d-native-cite-probe-8f1dd58/flake.lock` | Ignored, untracked | 1956 | `dd34d6ffb2946ef679b7849d13512c8dc3d9196f699db6cb4c14c3ded2f72d3d` | Exact project and transitive dependency revisions and hashes. |
| `tmp/d-native-cite-probe-8f1dd58/probe.el` | `files/tmp/d-native-cite-probe-8f1dd58/probe.el` | Ignored, untracked | 13398 | `d49bd226b4b770586171ee8d792002dc47514c966c6d7c7b6f94865555509c65` | Fixtures, assertions and forwarding instrumentation. |
| `tmp/d-native-cite-probe-8f1dd58/final-stock-report.txt` | `files/tmp/d-native-cite-probe-8f1dd58/final-stock-report.txt` | Ignored, untracked | 5575 | `dc6eed615e0672a9e85d881e256a4328a9b0a117565edb448b5fa7a6fe7d19be` | Original report from the final freshly built derivation. |

Locate the introducing GAW checkpoint through this manifest's first-parent
path history. Its project parent identifies the exact source used by the probe.
