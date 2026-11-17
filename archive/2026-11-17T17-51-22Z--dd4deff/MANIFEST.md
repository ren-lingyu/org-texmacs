# E7 minimum-version and editor compatibility probes

Non-authoritative historical evidence. Decisions and interpretation live in memory/stm-fragment-e7.md.

Capture time: 2026-11-17T17:51:22Z
Checked project source/capture baseline: dd4deffcdccffb776a7e854420db70174a2a82b0 (dd4deff), v0.7.1.

Agent-authored isolated probes. Org 9.8 release_9.8 source fixed at 89df5bf46ba214db44eea898cc7cacc0b27fd760, with only generated version metadata/autoloads; Emacs 31.1, TeXmacs 2.1.5. Editor observations use the existing main package with locked Org 9.8.10. Sources, exact module origins and outputs have independent reproduction value for the decision not to raise minimum versions and the fontification migration gap. Upstream Org source, generated autoloads, copied full document.el, caches and binaries are omitted: pin metadata and preparation scripts/diff suffice.

All selected source paths are untracked pure UTF-8 text under the ordinary project root. Original-byte copies retain paths below files/. No personal Org database/configuration or design-message transcript is captured.

| Source | Archive path | Bytes | SHA-256 |
|---|---|---:|---|
| tmp/stm-e7/prepare-org98.py (untracked) | files/tmp/stm-e7/prepare-org98.py | 505 | b694541d988ec64f5e215d7524e4724b2888b90d3b851d8a9af9595eaa4a77e0 |
| tmp/stm-e7/versions.el (untracked) | files/tmp/stm-e7/versions.el | 761 | 6fae356e5572d22dd4255de9adce5eb915f66dc72f81049820f7dd215063922b |
| tmp/stm-e7/editor.el (untracked) | files/tmp/stm-e7/editor.el | 1702 | c4ce5695aa295bfc58bbb0d2c21a8364fe044053dc2012aff7e19051fbfdcf25 |
| tmp/stm-e7/editor.json (untracked) | files/tmp/stm-e7/editor.json | 978 | c1feba4a215784b3e5f9aadf5c20544eb52a012c91ccbaa4414bd917cf1841d8 |
| tmp/stm-e7/module-origins.sexp (untracked) | files/tmp/stm-e7/module-origins.sexp | 749 | a68799fe76bfb6ba898e225820743328537ce36496dde3d87446f5a73d734378 |
| tmp/stm-e7/summary.json (untracked) | files/tmp/stm-e7/summary.json | 257 | c13acce21fb7911b054ae8dfbd2990f6cf6166d4fbfb73021fdd08894ca4934a |
| tmp/stm-e7/source98.json (untracked) | files/tmp/stm-e7/source98.json | 540 | a5ef8f8124035b38d34d9206ef0907d92bc4c86391ec00b898a6c8d13f293f71 |
| tmp/stm-e7/probe98/support.el (untracked) | files/tmp/stm-e7/probe98/support.el | 2904 | 3a57f4c7549bad2479b3da967dd1416c40d1e99f7f6d138202dd603a07165e53 |
| tmp/stm-e7/probe98/recognition.el (untracked) | files/tmp/stm-e7/probe98/recognition.el | 957 | bc4fef07c199975e1103fe770adb7945c2061918a1b7fcea599d4869b9b0301d |
| tmp/stm-e7/probe98/experiment.el (untracked) | files/tmp/stm-e7/probe98/experiment.el | 14564 | 86ac42a306f6f077c8cd3e32dfab20b8212a641b7e09439975805174b1123ecd |
| tmp/stm-e7/probe98/roundtrip.json (untracked) | files/tmp/stm-e7/probe98/roundtrip.json | 56962 | abf973dc5ac389ace6ed8e38020cfd50b98bb24d45df88e9e8ec1d3aea2f4bce |
| tmp/stm-e7/probe98/construction.json (untracked) | files/tmp/stm-e7/probe98/construction.json | 394 | a6ed9907934326b0ee8c11a579d548e59aabff9d5f1c0ad998b8921ad0f14fed |
| tmp/stm-e7/probe98/scope.json (untracked) | files/tmp/stm-e7/probe98/scope.json | 1928 | 276f7560cf495e96112e99e57af328498ce370b2910f557c9115a2ceb9b447e0 |
| tmp/stm-e7/probe98/copy-and-cache.json (untracked) | files/tmp/stm-e7/probe98/copy-and-cache.json | 1263 | 3b20722fa16ea8411f1b8ddeffd631177cc6023d28757eb1cae8bd935e5c5dc0 |
| tmp/stm-e7/probe98/live-cache.json (untracked) | files/tmp/stm-e7/probe98/live-cache.json | 101 | fecb603aba1bdb6a76ecd84ac92629c545873efdceccd8415e99e86c127fbdcd |
| tmp/stm-e7/probe98/direct-secondary.json (untracked) | files/tmp/stm-e7/probe98/direct-secondary.json | 656 | 015cc00d7f386892297bf4abb60b441bb193097398f73b5d4692def181c98511 |
| tmp/stm-e7/probe98/error-cleanup.json (untracked) | files/tmp/stm-e7/probe98/error-cleanup.json | 127 | 1aea58014e191c116a41f9d7b9f07b195b98b68f4679469d2b3d3b4727e77eaf |
| tmp/stm-e7/export98/support.el (untracked) | files/tmp/stm-e7/export98/support.el | 2904 | 3a57f4c7549bad2479b3da967dd1416c40d1e99f7f6d138202dd603a07165e53 |
| tmp/stm-e7/export98/recognition.el (untracked) | files/tmp/stm-e7/export98/recognition.el | 957 | bc4fef07c199975e1103fe770adb7945c2061918a1b7fcea599d4869b9b0301d |
| tmp/stm-e7/export98/e3-scope.el (untracked) | files/tmp/stm-e7/export98/e3-scope.el | 7190 | 6f19a5fe9d28651eeb5432d5d20a6c68606bc721c52ba9c728f1f4cb5670c5eb |
| tmp/stm-e7/export98/e4-adapter.el (untracked) | files/tmp/stm-e7/export98/e4-adapter.el | 7669 | 1599417a343a9deb7b0ee0e9965f07bbbb842e6889bd53baaa7024a2d05beceb |
| tmp/stm-e7/export98/experiment.el (untracked) | files/tmp/stm-e7/export98/experiment.el | 11693 | a08c84625e60e7307eff3abeb75e06941f66b3b47371743a74e998a589842d4e |
| tmp/stm-e7/export98/prepare-copy.py (untracked) | files/tmp/stm-e7/export98/prepare-copy.py | 344 | 346f1d099abdb5ada890d2dc95e53adec04e7ff4892f6b0228df1dfe12cf04d9 |
| tmp/stm-e7/export98/lowering.patch (untracked) | files/tmp/stm-e7/export98/lowering.patch | 489 | 3dca485a894b1f1b3ab28761b97f7e29ded985d9e94639b9ea560daa49fbb2ef |
| tmp/stm-e7/export98/results.json (untracked) | files/tmp/stm-e7/export98/results.json | 7962 | 58b45d43018aedad9f634b7da1f7ba4409d643af8fb17f03acb6ace9c495ce6c |
| tmp/stm-e7/export98/nested-and-id.json (untracked) | files/tmp/stm-e7/export98/nested-and-id.json | 1015 | c8a0c7bfb4aaad2a165e8429b7431222d33c4a48f5345d6ffee72ed62ea32910 |
| tmp/stm-e7/export98/environment.json (untracked) | files/tmp/stm-e7/export98/environment.json | 121 | 2eed9a478f2ba77fbe815aa28272655496a85c8431db16c84401ed840d997fa3 |
| tmp/stm-e7/export98/fixtures/included.org (untracked) | files/tmp/stm-e7/export98/fixtures/included.org | 30 | 2187039b024e2eb8e695e0443ead975b8345f351d1358525ef9aeb90f22007c9 |
| tmp/stm-e7/export98/fixtures/setup.org (untracked) | files/tmp/stm-e7/export98/fixtures/setup.org | 31 | 4035dd78193d967ff04b6cbcaa4f6d77781e6e8bc26b127a7c4bc0c6f580edfd |
| tmp/stm-e7/export98/fixtures/refs.bib (untracked) | files/tmp/stm-e7/export98/fixtures/refs.bib | 169 | 2f14b92162cf75895b5ef9803f3eddb4751e3550b2064c1029eb63c7232d9af2 |
| tmp/stm-e7/export98/fixtures/target.org (untracked) | files/tmp/stm-e7/export98/fixtures/target.org | 49 | 64c5efd3fd3b330eb10fbce6aa7409d2b5caf5b60bd34147922fc7aff01b8359 |

Introducing checkpoint is located through first-parent history of this manifest. The additional project parent associates the actual v0.7.1 project source inspected/executed; the upstream Org pin is separately identified in source98.json, not guessed from current project HEAD.

Replay from project root. Resolve the pinned Org source identified by source98.json, run prepare-org98.py SOURCE_ROOT, then generate org-loaddefs.el using the recorded Emacs: --batch -Q --eval `(progn (require (quote cl-lib)) (require (quote jka-compr)) (require (quote loaddefs-gen)) (loaddefs-generate "ABS_PATH/org98" "ABS_PATH/org98/org-loaddefs.el"))`. Generated org-version.el labels match the fixed release source, not a substituted runtime package.

Run emacs --batch -Q -L tmp/stm-e7/org98 -L lisp --load tmp/stm-e7/versions.el --load tmp/stm-e7/probe98/experiment.el. For export98, first run its prepare-copy.py from project root, then run the same command with --load tmp/stm-e7/export98/experiment.el. Give each run private HOME, XDG_CACHE_HOME, XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_RUNTIME_DIR and TMPDIR beneath the experiment root. Allow Unix sockets for Export only; timeouts are 15/5/120 seconds for worker startup/request/outer command. Run editor.el without -L org98 to reproduce the 9.8.10 current-editor baseline. No formal source is modified.

The earlier Org source preparation derivation had been collected; resolving its old path failed. The fixed upstream source was still cached. Local preparation copied its Lisp unchanged and generated metadata/autoloads. Version-origin assertions verified eight key functions before accepting results. Editor token-position sampling was corrected before the retained final run. Raw probe numbers are not maintained regression-suite counts.
