# Isolated STM E0–E2 probe evidence

Non-authoritative historical evidence; current conclusions live in memory.

Capture time: 2026-11-17T13:23:55Z
Capture context: project HEAD dd4deffcdccffb776a7e854420db70174a2a82b0 (dd4deff), local v0.7.1.

Provenance: agent-authored probes run during this task against unchanged v0.7.1 Lisp sources, Emacs 31.1 / Org 9.8.10 / TeXmacs 2.1.5. These are exploratory results, not maintained regression tests. Selected scripts and full AST/lexical/native outputs have independent replay and audit value for the emphasis-priority counterexample; distilled conclusions alone omit the actual span matrix. No user handoff copy is retained.

Only the listed untracked tmp files are selected. Every file is an original-byte text copy from the ordinary project root, retaining its repository-relative path under files/. No sanitization or dependency trees are included.

| Source path (untracked) | Archive path | Bytes | SHA-256 |
|---|---|---:|---|
| tmp/stm-e0-e2/probe.el | files/tmp/stm-e0-e2/probe.el | 8335 | cadcd1d7e2ff34844cb9b5b5018eb7cab12f506b1c15653b940ecb38562d7f46 |
| tmp/stm-e0-e2/native.el | files/tmp/stm-e0-e2/native.el | 1484 | e78441492401879da4056d9602bc975edafd6b0c2ed2f319b5cb669ef831e5c5 |
| tmp/stm-e0-e2/environment.json | files/tmp/stm-e0-e2/environment.json | 336 | 1745d8e773af8f98032f83b529e0d9fade02a30ed8f49528e7f670eefd331ecf |
| tmp/stm-e0-e2/e0.json | files/tmp/stm-e0-e2/e0.json | 60107 | 2302b3630769e02c6ccb0b5380dd9c7d0903f5cbca010ec396ea0255d6257949 |
| tmp/stm-e0-e2/e1.json | files/tmp/stm-e0-e2/e1.json | 1575 | 5385b35a058759a74c8e3545530c1d3d6eb98e9b49c18c1b2881610fa98d9c7b |
| tmp/stm-e0-e2/e2.json | files/tmp/stm-e0-e2/e2.json | 17819 | b0cab1fb738782c758cae321297f9b25068c268b38a738ba8a5d739cd22a32a4 |
| tmp/stm-e0-e2/native.json | files/tmp/stm-e0-e2/native.json | 598 | e754d9fe22d4476aaf51f3159092aa32be940039b2bd50a799bc345393cb26da |

Locate this snapshot’s introducing checkpoint through first-parent history of MANIFEST.md. Its additional project parent associates the source baseline actually probed, not original provenance for the user handoff.

Replay from the v0.7.1 project root: put probe.el and native.el together in an isolated directory; use the recorded Emacs/Org environment, --batch -Q -L lisp --load PATH/native.el. Set HOME, XDG_CACHE_HOME, XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_RUNTIME_DIR and TMPDIR to distinct experiment-local directories before invocation. native.el contains the exact TeXmacs executable used. Change that path only when deliberately testing a different environment. Worker startup/request limits are 15/5 seconds; outer timeout was 120 seconds. Unix socket permission is required. Outputs are written beside probe.el. The source scripts are not authorized for unrelated execution by this manifest.
