# PDF hyperlink forced-layout investigation and accepted candidate

Historical evidence only; current project knowledge remains in memory/. No archived script is an instruction to execute it.

Capture UTC: 2026-10-16T11:13:53Z
Checked capture-context project HEAD: `847845cddd449e96e9f763f3ed5b65388110ab89` (`847845c`).

Ordinary source root: `/home/lingyu/Projects/org-texmacs`; all source paths below are relative to it. Destination files preserve the complete source-relative path under this snapshot files/.

The original18baseline inputs were independently verified byte-identical to this committed HEAD. Candidate code was uncommitted during runtime validation: final25input and11foreign identities are explicit in the retained manifests; candidate.patch is the exact3file diff. The source-audit manifest separately identifies locked TeXmacs2.1.5source/package, not a modified native binary. Capture context does not turn the candidate into committed runtime provenance.

Selection preserves unique baseline/native-only forced/candidate annotation controls, small reproduction scripts, locked harness/identities, accepted regression logs and exact candidate patch. Maintained tests and current memory retain the operational result. No PDFs, binaries, source tarball, dependency trees, full tmp capture, INBOX or failed intermediate logs selected; relevant diagnostics are extracted.

Every selected file is an original-byte UTF-8 text copy, untracked and ignored in the ordinary worktree. No encoding/format/line-ending normalization or sanitization applied. Copy/source/digest stability is verified before staging.

The introducing GAW checkpoint is found through this MANIFEST.md first-parent path history. No additional project parent is inferred for mixed native controls and the uncommitted accepted candidate; the checked context and exact baseline/candidate roles are explained here and in REPORT.md.

| Source path | Archived path | Bytes | SHA-256 | Evidence role |
| --- | --- | ---: | --- | --- |
| `tmp/pdf-links/flake.nix` | `files/tmp/pdf-links/flake.nix` | 5383 | `5f344d56cf5ddf3d4323a092a494e4769ae5f97be34e3cd190c4a3b8ea7cf473` | Final standalone locked flake with source audit, 12-PDF matrix, red baseline, focused/full/native integration gates. |
| `tmp/pdf-links/flake.lock` | `files/tmp/pdf-links/flake.lock` | 1752 | `118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a` | Exact locked dependencies for reproducing all isolated checks. |
| `tmp/pdf-links/inputs.json` | `files/tmp/pdf-links/inputs.json` | 1668 | `3962f59d18a2326ae392f7cfbcc7ad5226c8b788ce57a76ddbcca773df1e886d` | Original18input SHA256 identities; all independently matched committed HEAD. |
| `tmp/pdf-links/candidate-inputs.json` | `files/tmp/pdf-links/candidate-inputs.json` | 2353 | `3e8c20f610e94a87a5beffd831060a28d1446602d812122d731a035c6cb8f8f7` | Final25project/lock/test SHA256 identities accepted by final gates. |
| `tmp/pdf-links/extension-inputs.json` | `files/tmp/pdf-links/extension-inputs.json` | 1412 | `f4ff7bb5ba39869e2e636b7233f1d129f858c09d01e1e70b42e395a2a9e1cb64` | 11pinned extension Elisp identities for real integration. |
| `tmp/pdf-links/source-audit.py` | `files/tmp/pdf-links/source-audit.py` | 1406 | `de1fc8bcbc579f85303c57d644c8173551e5d1d31999dd6726ee0e1d0df45fa8` | Bounded extraction of8relevant native source text files and identity reporting. |
| `tmp/pdf-links/source-results/manifest.json` | `files/tmp/pdf-links/source-results/manifest.json` | 1463 | `30ea7d1c85fce7c56a6e1ff0eb5e182aa4a6be49dc738c6c44d6463c0edca539` | Locked TeXmacs2.1.5source/package and extracted file identities. |
| `tmp/pdf-links/probes-baseline.el` | `files/tmp/pdf-links/probes-baseline.el` | 3316 | `f463fe2a1a374971c11863e93cb8af3529671424cc6ed08813c58dce94a53c2a` | Original12PDF diagnostic fixtures without forced layout. |
| `tmp/pdf-links/probes.el` | `files/tmp/pdf-links/probes.el` | 3348 | `8bccf5937b13ee202eec0c5ebe2f3df7d057ecbfabd60d27a805a2544b994bc5` | Same native fixtures with forced layout and current package/reload consumers. |
| `tmp/pdf-links/inspect.py` | `files/tmp/pdf-links/inspect.py` | 1188 | `1fdd7571220406a112dfd9610f986d8c31e7ea11947f4d2e2604e117d18878a5` | Independent pypdf/Poppler annotation and target inspection of all12PDFs. |
| `tmp/pdf-links/probe-results/annotations.json` | `files/tmp/pdf-links/probe-results/annotations.json` | 2379 | `bffe46849d92f251aa985f8b1dba84a94c8b25b372c4fa95788e832cda0dee95` | Original corrected baseline12PDFs, all0link annotations. |
| `tmp/pdf-links/forced-native-results/annotations.json` | `files/tmp/pdf-links/forced-native-results/annotations.json` | 5923 | `b620e76d40c80c5b5e624cba1e0bdcfa49cdb1c39d922e2589b2ff4aba6d9bd3` | Causal native-only force control:8native2links,4unchanged0links. |
| `tmp/pdf-links/final-matrix-results/annotations.json` | `files/tmp/pdf-links/final-matrix-results/annotations.json` | 7699 | `01c017cb4b0b7bf03d8a7f002e1c578f23e7c9e6feb6a5e438df8b6ac71d6d25` | Final same-input matrix with fixed worker/reload: all12have2links. |
| `tmp/pdf-links/baseline.log` | `files/tmp/pdf-links/baseline.log` | 12672 | `f3382ed09cdca8e94574b6702b777aaadf16181cc4fa785480ecc8e2502a9b36` | Two maintained regressions fail with intended assertions on old worker. |
| `tmp/pdf-links/focused.log` | `files/tmp/pdf-links/focused.log` | 3155 | `d28f6c89c47b23e536f80fdf3e4a5b5102717e201f507083ac590185b1120339` | 36/36focused PDF/session/Issue11 regression acceptance. |
| `tmp/pdf-links/integration.log` | `files/tmp/pdf-links/integration.log` | 2895 | `ca0a286ef35ce26de42062b1e29714d95e50f94fca8274b7be22ac6e87d7ca21` | 9/9fixed-version actual extension regression acceptance. |
| `tmp/pdf-links/full.log` | `files/tmp/pdf-links/full.log` | 51477 | `05071e594a5d42b9204e560ccb9a60688190fc0d5f970fabf5e5112ff4604b0b` | Complete isolated gate output and strict compilation/lint/core ERT outcomes. |
| `tmp/pdf-links/candidate.patch` | `files/tmp/pdf-links/candidate.patch` | 10589 | `76b50adc8fe9a8f9bb9c1c00c0c6356e6622d00ddb8445275cf6ed7302c07f71` | Exact3file candidate against checked capture-context main HEAD. |
| `tmp/pdf-links/REPORT.md` | `files/tmp/pdf-links/REPORT.md` | 4865 | `db97062f093f793a859fb24e526e6dc6470966a1a87f8cab4ec2c226ea9d4c36` | Extracted reproduction, outcome, ownership and validation limits. |
| `tmp/pdf-links/diagnostics.md` | `files/tmp/pdf-links/diagnostics.md` | 2359 | `b2de88e982a417ac79ef0354bb6cdeb8782e392b27d119968d37a5ba74d40890` | Extracted rejected harness failures and native inspection warnings. |

Staged whitespace diagnostics are retained original text: baseline.log lines11/45/56 have trailing spaces and line87 is a final blank; candidate.patch lines7/74/103 are blank unified-diff context lines; focused.log line40 is a final blank; full.log lines529/531 have native log-prefix trailing spaces. These are not capture corruption and were not normalized. The ordinary three-file candidate itself passes git diff --check.
