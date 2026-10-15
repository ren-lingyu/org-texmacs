# Export timing evidence snapshot

Non-authoritative historical evidence. Current conclusions and decisions belong to memory.

Capture time: 2026-10-15T07:59:37Z
Checked capture-context project HEAD: 48390293147c9840052fcefa4c1410bcce27e185 (4839029).

## Provenance and selection

Source root: ordinary org-texmacs project worktree. All selected sources are ignored, untracked task-generated text under tmp/export-timing; each is captured with original bytes, without normalization or sanitization. None is a secret derivative. The package source and pinned lock used for measurement were compared byte-for-byte against the inspected project commit (17 inputs; project-inputs.json). This commit association means measured package revision, not that the temporary harness or results originated in project Git history. The independently constructed flake is a diagnostic wrapper, not the root flake with the user mirror edit.

The two frozen fixtures were copied earlier from user-provided tmp/realworld_test. Body hash still matches; current original INCLUDE gained one additional trailing newline after sampling. Frozen 22-byte INCLUDE was used for all measurements. Original source timing and author provenance beyond user workspace are not asserted. input-verification.md records the supported drift.

All four final successful Nix build logs contain actual building messages and output store paths. results-N.json and logs were copied from those build outputs with user permission. 96 actual exports passed script assertions. Initial harness-only parse/state-assertion failures preceded complete sampling and were overwritten; their raw logs are not retained and cannot be reconstructed from this snapshot.

Selection: losing the fixed harness/input/raw samples would impair reproduction or interpretation of nondeterministic timing conclusions. Retain flake/lock and benchmark.el for environment/protocol; summarize.py for derivation; fixtures and manifests for exact workload and source identities; input-verification for drift; raw JSON and successful build logs for samples/commands/output identity; summary and report for interpretation and limits. Exclude duplicate run.log copies (included verbatim in build logs), package source copies recoverable from inspected project commit, native products, dependencies, binaries and unrelated tmp files. This is an explicit 20-file selection, not a directory dump.

## Exact original-byte copies

| Source path | Archive path | Tracked status | Bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| tmp/export-timing/flake.nix | files/tmp/export-timing/flake.nix | untracked, ignored | 3482 | 7a10bf628311b226074458761b040e2ef66bfc2c30752b254017f83c4ce669bd |
| tmp/export-timing/flake.lock | files/tmp/export-timing/flake.lock | untracked, ignored | 1752 | 118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a |
| tmp/export-timing/benchmark.el | files/tmp/export-timing/benchmark.el | untracked, ignored | 9552 | fb22c1081154c5b474fadcdf3249fc56e5f7561fd366043bab47badebd00d4b6 |
| tmp/export-timing/summarize.py | files/tmp/export-timing/summarize.py | untracked, ignored | 3057 | 8c1f0b23e47f7b6fa8effbee2ae39ab1365dd67fc4c0ea26eea95916de6c58c5 |
| tmp/export-timing/fixtures/test.org | files/tmp/export-timing/fixtures/test.org | untracked, ignored | 6447 | 73e9e8da9310fa73561633efa410e9003883e8924db708b91cd2ca3e640985bb |
| tmp/export-timing/fixtures/test_include.org | files/tmp/export-timing/fixtures/test_include.org | untracked, ignored | 22 | cf802a0cc4da13622c21546d9fbd4c847c8e1d020c5360024cda66c0f337dbc6 |
| tmp/export-timing/project-inputs.json | files/tmp/export-timing/project-inputs.json | untracked, ignored | 1578 | 6ab578a5da6c3b32b0b2878c043a6805192967806309f7e0357437508c75199f |
| tmp/export-timing/fixture-inputs.json | files/tmp/export-timing/fixture-inputs.json | untracked, ignored | 175 | 5dc4920c5958293d85e2735898f47902cfa35f517a082c63b8c64d398c622fa4 |
| tmp/export-timing/input-verification.md | files/tmp/export-timing/input-verification.md | untracked, ignored | 920 | d80e2c735b012d0a52c6d53fad0e2b824415cc766bbd38f34f027c3ddfa6077d |
| tmp/export-timing/REPORT.md | files/tmp/export-timing/REPORT.md | untracked, ignored | 7021 | 93d21c401b94fa743b9295e4f7bbe609e1942d0df4ef8e5e5d2db35a652775b2 |
| tmp/export-timing/summary.json | files/tmp/export-timing/summary.json | untracked, ignored | 69247 | 9b535c0a3f4f97b80eb0321b330ebb22c30b3c46bd3e2c7b2d4c789f8910c896 |
| tmp/export-timing/summary.csv | files/tmp/export-timing/summary.csv | untracked, ignored | 4779 | 4c3e655a18c810143d1cb90765a8cfc3dcbbdbc5fe2a57aba530edd082a034ec |
| tmp/export-timing/results-1.json | files/tmp/export-timing/results-1.json | untracked, ignored | 37016 | 509c3835355a86e515ffc4efc5f91142df38a8f52f3fbf207b26dc83da8ba8aa |
| tmp/export-timing/bench-1.log | files/tmp/export-timing/bench-1.log | untracked, ignored | 3253 | 488da8b563bdb40818644ed17639d9eec947b869d36631e663647a45bac0f434 |
| tmp/export-timing/results-2.json | files/tmp/export-timing/results-2.json | untracked, ignored | 37006 | 66020ad8fd02c28f23ef3a00860cd5a0a144bb40980f4d8671621636fd356a3f |
| tmp/export-timing/bench-2.log | files/tmp/export-timing/bench-2.log | untracked, ignored | 3253 | 44b266f8075f5b127892262cdae2d87aa7a05195a6b46bf79605f246b76d8d59 |
| tmp/export-timing/results-4.json | files/tmp/export-timing/results-4.json | untracked, ignored | 36938 | 3867074216771922c41c8dae8a01d4057c2f8b90e0fabfc7f932880f11f5b5ba |
| tmp/export-timing/bench-4.log | files/tmp/export-timing/bench-4.log | untracked, ignored | 3253 | 3c3e5cc6ade122905355c794585744cfbc013c040d622c63ab673bda1c310483 |
| tmp/export-timing/results-8.json | files/tmp/export-timing/results-8.json | untracked, ignored | 36890 | a58eb9e0b7e3c7df5641e9fb8808ef9e04fb7053a40713e5cb9b119e11c93d07 |
| tmp/export-timing/bench-8.log | files/tmp/export-timing/bench-8.log | untracked, ignored | 3253 | 44f785f246230491f5af916cc26f8937f2f6d75ad13189532cbfe8f7b3ee6516 |

## Verification and checkpoint lookup

The staged whitespace check reports the original CSV's 33 CRLF line endings and
one extra final blank line in input-verification.md. These are reviewed original
text bytes, deliberately retained for exact capture; no unrelated whitespace
finding is accepted. This is not a whitespace-clean snapshot claim.

Every copy was compared byte-for-byte and checked against its listed source size/SHA-256; selection completeness and source stability were checked before staging. Re-read project HEAD before staging. Any failure stops checkpointing; snapshot paths are never overwritten. The introducing GAW checkpoint is located through this manifest path’s first-parent history. Its additional project parent associates the exact measured package revision; it does not assert original provenance of generated diagnostics, the user fixture, or every archived byte.

Once introduced, this manifest and all snapshot bytes are immutable; corrections belong in current memory or a new snapshot.
