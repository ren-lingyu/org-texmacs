# E5/E6 serialization and standard Export evidence

Non-authoritative historical evidence. Current conclusions: memory/stm-fragment-e5.md and memory/stm-fragment-e6.md.

Capture time: 2026-11-17T15:47:11Z
Checked source and capture baseline: dd4deffcdccffb776a7e854420db70174a2a82b0 (dd4deff), v0.7.1.

Agent-authored isolated experiments on Emacs 31.1 / Org 9.8.10 / TeXmacs 2.1.5. E5 uses a temporary Scheme comparison service; E6 uses the actual org-export-as texmacs lifecycle with local advice and one explicit lowering gate change in an isolated source copy. Source main is unchanged. Selected scripts, exact source-generator outputs, reader flags, normalization signatures, final AST observations and native export bytes have independent replay/audit value. They are not maintained regression coverage. No handoff full text, personal Org data, dependency trees, caches, binary or socket is retained.

All selected sources are untracked UTF-8 text beneath the ordinary project root. Original-byte copies preserve their paths below files/. The isolated full document.el is deliberately omitted: its baseline is in project history and lowering.patch/prepare-copy.py reproduce the sole change.

| Source | Archive path | Bytes | SHA-256 |
|---|---|---:|---|
| tmp/stm-e5/support.el (untracked) | files/tmp/stm-e5/support.el | 2904 | 3a57f4c7549bad2479b3da967dd1416c40d1e99f7f6d138202dd603a07165e53 |
| tmp/stm-e5/recognition.el (untracked) | files/tmp/stm-e5/recognition.el | 957 | bc4fef07c199975e1103fe770adb7945c2061918a1b7fcea599d4869b9b0301d |
| tmp/stm-e5/e3-scope.el (untracked) | files/tmp/stm-e5/e3-scope.el | 7190 | 6f19a5fe9d28651eeb5432d5d20a6c68606bc721c52ba9c728f1f4cb5670c5eb |
| tmp/stm-e5/e4-adapter.el (untracked) | files/tmp/stm-e5/e4-adapter.el | 7669 | 1599417a343a9deb7b0ee0e9965f07bbbb842e6889bd53baaa7024a2d05beceb |
| tmp/stm-e5/writers.scm (untracked) | files/tmp/stm-e5/writers.scm | 1558 | 97cc1de20a82e892fcfa8ac10c73b40ee6a390c279ff311cb1d345009b7dea14 |
| tmp/stm-e5/experiment.el (untracked) | files/tmp/stm-e5/experiment.el | 3962 | 05fd01213c09cfedc85439056fe6d630922df638ef81fd6c708d692efd76d981 |
| tmp/stm-e5/writer-functions.el (untracked) | files/tmp/stm-e5/writer-functions.el | 2109 | 10ea9c9e3afed68114d8b24a10d98ddc331cf107624c24f4bb8bb0a8073be40a |
| tmp/stm-e5/normalization.el (untracked) | files/tmp/stm-e5/normalization.el | 3446 | 0c2bd3884ab23176b34a2d539682f7ce00eef9b7b9d4a0b06406a279846a20b0 |
| tmp/stm-e5/escape-probe.el (untracked) | files/tmp/stm-e5/escape-probe.el | 1130 | ac8bf58ed8e6a7c0b08ceb354f76ce9c128e6dafe060ca4d6006991d25693889 |
| tmp/stm-e5/writers.json (untracked) | files/tmp/stm-e5/writers.json | 18804 | 1bcbac8599c87696f00341117686991d47d1566356d4cee9b313cfb83c217ae9 |
| tmp/stm-e5/environment.json (untracked) | files/tmp/stm-e5/environment.json | 210 | 4527f5d6ea9c00cb58f02f46b93c44e9203e935f98f0f9f1d2b4ad17724d1c05 |
| tmp/stm-e5/normalization.json (untracked) | files/tmp/stm-e5/normalization.json | 40478 | ca87ddb8d0cfd600a495f370a2ffd4824ea55f56a06af65d3fb793d8a8ab365a |
| tmp/stm-e5/invalid.json (untracked) | files/tmp/stm-e5/invalid.json | 194 | 28404296910a8c3525f4dd66247c79468544cbb03ddb314f5d5b143e174dc0bf |
| tmp/stm-e5/normalization-environment.json (untracked) | files/tmp/stm-e5/normalization-environment.json | 46 | 823aadc2f93ade30006373b2362bd50ec10ded72cf23a980de10aaba19f88575 |
| tmp/stm-e5/escape-alternatives.json (untracked) | files/tmp/stm-e5/escape-alternatives.json | 380 | 8043e2c4f9c2a274b95d2b846217cedf8cf81d79c90f1443e0c8f72a51235d50 |
| tmp/stm-e5/purity.json (untracked) | files/tmp/stm-e5/purity.json | 105 | 7ed9c30ca3f6113ac08e2d2d4f8058c9e401e4b7ecc9ff1c3d2cdf62b1ecb29c |
| tmp/stm-e5/summary.json (untracked) | files/tmp/stm-e5/summary.json | 411 | 98d4c8ed2b803ab9d3ce54e2dea7f30384e1c0811e0b723f836c433dbfc5703f |
| tmp/stm-e6/support.el (untracked) | files/tmp/stm-e6/support.el | 2904 | 3a57f4c7549bad2479b3da967dd1416c40d1e99f7f6d138202dd603a07165e53 |
| tmp/stm-e6/recognition.el (untracked) | files/tmp/stm-e6/recognition.el | 957 | bc4fef07c199975e1103fe770adb7945c2061918a1b7fcea599d4869b9b0301d |
| tmp/stm-e6/e3-scope.el (untracked) | files/tmp/stm-e6/e3-scope.el | 7190 | 6f19a5fe9d28651eeb5432d5d20a6c68606bc721c52ba9c728f1f4cb5670c5eb |
| tmp/stm-e6/e4-adapter.el (untracked) | files/tmp/stm-e6/e4-adapter.el | 7669 | 1599417a343a9deb7b0ee0e9965f07bbbb842e6889bd53baaa7024a2d05beceb |
| tmp/stm-e6/experiment.el (untracked) | files/tmp/stm-e6/experiment.el | 11693 | a08c84625e60e7307eff3abeb75e06941f66b3b47371743a74e998a589842d4e |
| tmp/stm-e6/prepare-copy.py (untracked) | files/tmp/stm-e6/prepare-copy.py | 344 | 346f1d099abdb5ada890d2dc95e53adec04e7ff4892f6b0228df1dfe12cf04d9 |
| tmp/stm-e6/lowering.patch (untracked) | files/tmp/stm-e6/lowering.patch | 489 | 3dca485a894b1f1b3ab28761b97f7e29ded985d9e94639b9ea560daa49fbb2ef |
| tmp/stm-e6/results.json (untracked) | files/tmp/stm-e6/results.json | 7962 | c93bf6fc6c9700cf7fa4e586df50672b055378e914b8d4be20540d8e88790e75 |
| tmp/stm-e6/nested-and-id.json (untracked) | files/tmp/stm-e6/nested-and-id.json | 1006 | 0496845d4358e79c24e25264e9d7d4006e3ca4bd7b11d985c3248307f98a1fda |
| tmp/stm-e6/environment.json (untracked) | files/tmp/stm-e6/environment.json | 124 | 346b3f059566b6e8cb69bc3e971b138adc10b53ecef11d6c0523e3f963293b28 |
| tmp/stm-e6/summary.json (untracked) | files/tmp/stm-e6/summary.json | 183 | a97e057a371d6c7ad09ff419ab56d6045f1538e557bf6fd5bc5bb369fdf57666 |
| tmp/stm-e6/fixtures/included.org (untracked) | files/tmp/stm-e6/fixtures/included.org | 30 | 2187039b024e2eb8e695e0443ead975b8345f351d1358525ef9aeb90f22007c9 |
| tmp/stm-e6/fixtures/setup.org (untracked) | files/tmp/stm-e6/fixtures/setup.org | 31 | 4035dd78193d967ff04b6cbcaa4f6d77781e6e8bc26b127a7c4bc0c6f580edfd |
| tmp/stm-e6/fixtures/refs.bib (untracked) | files/tmp/stm-e6/fixtures/refs.bib | 169 | 2f14b92162cf75895b5ef9803f3eddb4751e3550b2064c1029eb63c7232d9af2 |
| tmp/stm-e6/fixtures/target.org (untracked) | files/tmp/stm-e6/fixtures/target.org | 49 | 64c5efd3fd3b330eb10fbce6aa7409d2b5caf5b60bd34147922fc7aff01b8359 |

Locate the introducing checkpoint through first-parent path history of MANIFEST.md. Its additional project parent supplies the exact baseline actually probed; archived patches/advice define the experimental deviations and are not source commits.

Replay from the v0.7.1 project root with emacs --batch -Q -L lisp --load PATH/SCRIPT. Executable used: /nix/store/hgxynx6q814yvi1kym1vmccfrr3xicdm-emacs-with-packages-31.1/bin/emacs. Loaded Org path is in stm-e5/environment.json and is shared by E6 using this same executable. Native binary is recorded in e4-adapter.el; E6 output identifies runtime 2.1.5. Set HOME, XDG_CACHE_HOME, XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_RUNTIME_DIR and TMPDIR to distinct experiment-local directories. Startup/request/outer timeouts: 15/5/120 seconds; allow local Unix sockets. Outputs are written beside scripts.

E5: run experiment.el, then normalization.el and escape-probe.el in its own directory. writers.scm loads the baseline worker from the recorded project path; adjust that path deliberately when relocating. Scheme source outputs travel as integer byte lists, decoded as UTF-8 for the captured final JSON. Flags mean 1=equal, 0=read but unequal, -1=error. Native generation is performed before independent validation; the comparison harness is not a production parser.

E6: first run prepare-copy.py from project root to reproduce the isolated lowering file next to experiment.el (review lowering.patch). Keep fixtures adjacent under fixtures/. Then run experiment.el in the same kind of isolated environment. All transient backend/object registrations are scoped. The script runs actual org-export-as, not a mock preparation pipeline. Initial backend-copy typo, a non-Org visible-only hiding fixture, the discovered gate rejection and post-blank loss were corrected before the final retained run. Expected filter/native errors remain in final results. These scripts are evidence, not authority for unrelated execution.
