# STM E2-prime native compatibility probes

Non-authoritative historical evidence; current interpretation lives in memory/stm-fragment-e2-prime.md.

Capture time: 2026-11-17T14:33:31Z
Checked capture context and actual source baseline: dd4deffcdccffb776a7e854420db70174a2a82b0 (dd4deff), v0.7.1.

Agent-authored isolated batch probes: Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5; native-compatible contract adopted before execution. No full-source scan/masking, formal source edits or maintained regression tests. Selected files retain the exact context/call/AST matrix and replayable implementation behind the architecture conclusion; this independent evidence value warrants preservation. No input handoff copy, caches, user configuration or binaries are selected.

Original-byte UTF-8 text copies; all source paths were untracked under the ordinary project root. Archive paths retain source paths below files/.

| Source | Archive path | Bytes | SHA-256 |
|---|---|---:|---|
| tmp/stm-e2-prime/support.el (untracked) | files/tmp/stm-e2-prime/support.el | 2904 | 3a57f4c7549bad2479b3da967dd1416c40d1e99f7f6d138202dd603a07165e53 |
| tmp/stm-e2-prime/experiment.el (untracked) | files/tmp/stm-e2-prime/experiment.el | 6341 | 8085607a60cd98c28e25b7d6cc7ccd68563416154dff5afbc96f7c7a74142e0b |
| tmp/stm-e2-prime/environment.json (untracked) | files/tmp/stm-e2-prime/environment.json | 1168 | ac46c79ddd2486f542d799b0933e0e27ea9e2957276a3a78752ec1ba7c83438e |
| tmp/stm-e2-prime/results.json (untracked) | files/tmp/stm-e2-prime/results.json | 136448 | 9390153e944b2bb2955ca728bddc21e422a216e534fee9364e4ebb073e873a76 |
| tmp/stm-e2-prime/summary.json (untracked) | files/tmp/stm-e2-prime/summary.json | 167 | 748dccda7932ef8443cb3b60e4d2cc8c794d7fb711895410821386b600acabe0 |

Introducing GAW checkpoint is located through first-parent history of this manifest. Its additional project parent associates the exact read-only baseline probed; it does not merge that source tree.

Replay from v0.7.1 root using the recorded Emacs/Org environment: --batch -Q -L lisp --load PATH/experiment.el with support.el adjacent. Assign HOME, all relevant XDG directories and TMPDIR to distinct experiment-local directories first. Native executable is recorded in experiment.el; startup/request timeouts 15/5 seconds, outer timeout 120 seconds. Unix socket permission is necessary. JSON is written beside scripts. The scripts are exploratory artifacts, not instructions for unapproved execution. A result-collection plist bug was corrected before the final successful run retained here.
