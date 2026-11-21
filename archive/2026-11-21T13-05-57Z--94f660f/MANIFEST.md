# STM reader and writer isolation probes

Historical experiment evidence. The prototype is not production code.

Capture UTC `2026-11-21T13:05:57Z`. Capture-context project HEAD `94f660f7a58d927fdf01119bbbd31b3679e29ca6` (`94f660f7`).
The project association is release commit `d0f521688dac15ca1cbdf64f54f114d7ca9fbca4` from tag `v0.8.0`.
The temporary flake and Lisp probe were authored in the ordinary worktree
for this experiment. The release supplies the old writer, native runtime
and locked Nixpkgs. The capture-context commit did not supply the experimental
runtime. Locate the introducing checkpoint through the manifest's first-parent path history.

The two reports are exact copies of the corresponding Nix check outputs,
materialized as ordinary temporary text files before capture. The pure report
preserves the generic printer and lexical-guard observations used to assess
an Elisp implementation. The native report preserves the exact spellings and
decoded values that establish silent incompatibility on quotes and backslashes,
and on numeric and colon-prefixed labels. The flake, lock and common probe
reproduce those results. Early harness failures were corrected and add no
independent evidence.

The conditional two-version carrier experiment was deferred. The native
differential met the stop criterion before an output grammar was selected.
No carrier evidence was generated.

Run `checks.x86_64-linux.stm-pure` and `checks.x86_64-linux.stm-native-diff`
from the captured flake with `nix build -L --no-link --no-write-lock-file
--print-out-paths`. Each check writes `result.txt` to its store output.
Emacs is 31.1. The native check uses Org 9.8.10 and TeXmacs 2.1.5.

| Source path | Archive path | Source status | Bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| `tmp/stm-reader-experiments/flake.nix` | `files/tmp/stm-reader-experiments/flake.nix` | Untracked | 793 | `69ff0cfdf058b7e45542518385aa797e0312bfbf11cc21253f3564088d400583` |
| `tmp/stm-reader-experiments/flake.lock` | `files/tmp/stm-reader-experiments/flake.lock` | Untracked | 1897 | `d28ffc2d0c1e62477d119b60bcf58b3fb2788d434ad79843f9633ff8e8e03bde` |
| `tmp/stm-reader-experiments/probe.el` | `files/tmp/stm-reader-experiments/probe.el` | Untracked | 8188 | `005f38897b6eea72f91a2afb99dccde08b93f652f6b7ba80bf1e897321ded7e1` |
| `tmp/stm-reader-experiments/stm-pure.txt` | `files/tmp/stm-reader-experiments/stm-pure.txt` | Untracked | 2214 | `0e916cc2643a0d4d0d25d6b658f4d8ce70cfe6160bd7fccb18acca1d2f6632e7` |
| `tmp/stm-reader-experiments/stm-native-diff.txt` | `files/tmp/stm-reader-experiments/stm-native-diff.txt` | Untracked | 3528 | `7e4b341985c61001ab0eb131d07fe15373c2c1886987adfb4ad05f0fa05b7f0e` |
