# E4 island model integration probes

Non-authoritative historical evidence; current interpretation is memory/stm-fragment-e4.md.

Capture time: 2026-11-17T15:06:44Z
Capture context and actual project source baseline: dd4deffcdccffb776a7e854420db70174a2a82b0 (dd4deff), v0.7.1.

Agent-authored probes on Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5. Selected scripts/full result data have independent replay and audit value for ownership, identity remapping, parent normalization and representation failures. Existing maintained tests do not cover this new adapter. No ordinary source, user configuration, dependency tree, socket or binary is captured. This is exploratory evidence, not a regression suite.

Original-byte UTF-8 text copies. All source paths are untracked under the ordinary project root; archive paths preserve them below files/.

| Source | Archive path | Bytes | SHA-256 |
|---|---|---:|---|
| tmp/stm-e4/support.el (untracked) | files/tmp/stm-e4/support.el | 2904 | 3a57f4c7549bad2479b3da967dd1416c40d1e99f7f6d138202dd603a07165e53 |
| tmp/stm-e4/recognition.el (untracked) | files/tmp/stm-e4/recognition.el | 957 | bc4fef07c199975e1103fe770adb7945c2061918a1b7fcea599d4869b9b0301d |
| tmp/stm-e4/e3-scope.el (untracked) | files/tmp/stm-e4/e3-scope.el | 7190 | 6f19a5fe9d28651eeb5432d5d20a6c68606bc721c52ba9c728f1f4cb5670c5eb |
| tmp/stm-e4/experiment.el (untracked) | files/tmp/stm-e4/experiment.el | 15234 | 37a690f1f9cecebcc6fd25b8c6e16e64ea243cc2df15a0aac024bcc6ffe4fd82 |
| tmp/stm-e4/results.json (untracked) | files/tmp/stm-e4/results.json | 9855 | 8d8763c49440356588bae188288803ec5e1b177dc8cb089b1e2ac0c230f57910 |
| tmp/stm-e4/environment.json (untracked) | files/tmp/stm-e4/environment.json | 257 | e6c7f454cd14c1870a3abda0a570c6397b20620f9a02d478c8c84325f1359b59 |
| tmp/stm-e4/direct-and-ownership.json (untracked) | files/tmp/stm-e4/direct-and-ownership.json | 518 | 905fa9db09db376608f02747059d5f66a47446e29549224942bc46020e657376 |
| tmp/stm-e4/atomic-and-failure.json (untracked) | files/tmp/stm-e4/atomic-and-failure.json | 236 | ffaea0d13abe01411775c61235ce783222aa963167414cff533edbc9ad0a4ddf |
| tmp/stm-e4/caption-parent-guard.json (untracked) | files/tmp/stm-e4/caption-parent-guard.json | 87 | e3550e1b47c4861fa1eb6b69940043b389fe191105c67132d72d09014c6756b8 |
| tmp/stm-e4/summary.json (untracked) | files/tmp/stm-e4/summary.json | 323 | 7265959d599f6b1d1dc99a1e54cf85677a0ab7645d6a731ee87e0b144da1504f |

Introducing checkpoint is located through first-parent history of this manifest. Its additional project parent associates the exact read-only source actually exercised, not a source-tree merge.

Replay from v0.7.1 project root: emacs --batch -Q -L lisp --load PATH/experiment.el; all four .el files must be adjacent. Executable used: /nix/store/hgxynx6q814yvi1kym1vmccfrr3xicdm-emacs-with-packages-31.1/bin/emacs. Org loaded path is recorded in environment.json. Native executable is recorded in experiment.el. Set HOME, XDG_CACHE_HOME, XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_RUNTIME_DIR and TMPDIR to distinct experiment-local directories. Socket permission is required. Startup/request/outer timeouts: 15/5/120 seconds. Worker is stopped before pure direct-input/failure probes. No source restoration, document lowering or Export preparation is performed. Initial missing ox load and a caption-guard binding mistake were corrected before the retained successful final run. E3 graph-copy is defined as inherited support but explicitly forbidden during conversion; it is not the ownership implementation used here.
