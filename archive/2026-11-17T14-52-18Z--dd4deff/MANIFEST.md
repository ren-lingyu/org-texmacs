# STM E3 extended Org AST evidence

Non-authoritative historical evidence. Current interpretation is memory/stm-fragment-e3.md.

Capture time: 2026-11-17T14:52:18Z
Capture context and tested source baseline: dd4deffcdccffb776a7e854420db70174a2a82b0 (dd4deff), v0.7.1.

Agent-authored isolated batch experiment: Emacs 31.1, Org 9.8.10. No TeXmacs process or complete STM model was used. Exact AST registration, copying and secondary-string observations have independent reproduction value; selected scripts/results retain evidence beyond prose conclusions. This is not maintained regression coverage. No user design handoff, cache, dependency tree or binary is selected.

All selected sources were untracked pure UTF-8 text under the ordinary project root. Copies preserve original bytes and repository-relative paths below files/.

| Source | Archive path | Bytes | SHA-256 |
|---|---|---:|---|
| tmp/stm-e3/support.el (untracked) | files/tmp/stm-e3/support.el | 2904 | 3a57f4c7549bad2479b3da967dd1416c40d1e99f7f6d138202dd603a07165e53 |
| tmp/stm-e3/recognition.el (untracked) | files/tmp/stm-e3/recognition.el | 957 | bc4fef07c199975e1103fe770adb7945c2061918a1b7fcea599d4869b9b0301d |
| tmp/stm-e3/experiment.el (untracked) | files/tmp/stm-e3/experiment.el | 14564 | 86ac42a306f6f077c8cd3e32dfab20b8212a641b7e09439975805174b1123ecd |
| tmp/stm-e3/roundtrip.json (untracked) | files/tmp/stm-e3/roundtrip.json | 56962 | abf973dc5ac389ace6ed8e38020cfd50b98bb24d45df88e9e8ec1d3aea2f4bce |
| tmp/stm-e3/construction.json (untracked) | files/tmp/stm-e3/construction.json | 394 | a6ed9907934326b0ee8c11a579d548e59aabff9d5f1c0ad998b8921ad0f14fed |
| tmp/stm-e3/scope.json (untracked) | files/tmp/stm-e3/scope.json | 1983 | 72e44c3221cb76136a51c40bf7b18321559c2061e6854800ec9661c1164f0566 |
| tmp/stm-e3/copy-and-cache.json (untracked) | files/tmp/stm-e3/copy-and-cache.json | 1263 | 3b20722fa16ea8411f1b8ddeffd631177cc6023d28757eb1cae8bd935e5c5dc0 |
| tmp/stm-e3/live-cache.json (untracked) | files/tmp/stm-e3/live-cache.json | 101 | fecb603aba1bdb6a76ecd84ac92629c545873efdceccd8415e99e86c127fbdcd |
| tmp/stm-e3/direct-secondary.json (untracked) | files/tmp/stm-e3/direct-secondary.json | 656 | 015cc00d7f386892297bf4abb60b441bb193097398f73b5d4692def181c98511 |
| tmp/stm-e3/error-cleanup.json (untracked) | files/tmp/stm-e3/error-cleanup.json | 127 | 1aea58014e191c116a41f9d7b9f07b195b98b68f4679469d2b3d3b4727e77eaf |
| tmp/stm-e3/summary.json (untracked) | files/tmp/stm-e3/summary.json | 271 | 8c0215e088eb5e388688e0ddcc932039892d8e6b648df2bfcb1036eadb21ab86 |

Locate the introducing checkpoint through first-parent history of this manifest. Its additional project parent associates the actual read-only source baseline, not a source merge.

Replay from v0.7.1 project root with the recorded Org environment: emacs --batch -Q -L lisp --load PATH/experiment.el; keep support.el and recognition.el adjacent. Exact executable used: /nix/store/hgxynx6q814yvi1kym1vmccfrr3xicdm-emacs-with-packages-31.1/bin/emacs. Set HOME, XDG_CACHE_HOME, XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_RUNTIME_DIR and TMPDIR to distinct experiment-local directories first. Outer timeout: 120 seconds. Outputs are written beside scripts. Runtime Org loaded path is recorded in scope.json. No sockets/worker are needed. Temporary extraction/parenthesis mistakes were fixed before the retained final run. summary.json distinguishes 22 real unregistered traversal misses from two deliberately opaque cases. Scripts are evidence, not authorization for unrelated execution.
