# D Cite comparison evidence (non-authoritative historical archive)

Capture UTC: 2026-11-02T20:32:35Z. Checked project capture context: `054d6cff1324b4c56b526868af681c99a66c6977` (`054d6cf`).

These task-authored isolated inputs are derived from the byte-identical147file
C snapshot, with exact complete candidate digests in prototype-inputs.json.
The source patch represents all five changed/new Lisp files against that C
commit; restore its147tracked inputs, apply the patch and add the four captured
probe files at their relative paths to reproduce the experiment. The fixed
Org-roam-organize rev/hash is in test.nix and organize-pin.json; no extension
history is imported. Original project files are recoverable from Git and are
not duplicated here. The experiment is not a production feature acceptance.

Retain this bounded comparison because the working prototype will be replaced:
standard TeXmacs Cite native-wrapper/jobs versus existing CSL Org-return path.
The single log preserves locked Org processor/format/finalizer source and8/8
actual runtime results, including native document/text/PDF, real extension UUID/
bibliography/native PDF/HTML and CSL text/document/PDF. It demonstrates why
CSL reuse is viable before adding a custom processor. The probe also records
all return shapes/raw/reentrant calls; raw-only traversal's earlier erroneous
count is corrected in the final source. Earlier failed harness versions are
not retained; this capture makes no claim to reproduce those exact versions.

Selection is eight reviewed UTF-8 text files only. No PDF, store closure,
credentials, full temporary tree or routine failed build logs are retained.
The patch and complete digest manifest were generated from the current exact
prototype; all captured files are original-byte copies of those selected paths.
The source fetch is explicitly authorized in this task. Test fixture UUIDs,
bibliographies and temporary HOME paths are synthetic. Larger feature boundaries
and retention conclusions belong in current memory, not this archive.

Replay command (authorized separately when used):
`timeout 120s nix build --no-link --no-write-lock-file --max-jobs 2 --print-out-paths path:REPLAY#checks.x86_64-linux.standard-cite-probe -L`.
Environment: x86_64-linux, locked Emacs31.1/Org9.8.10/TeXmacs2.1.5; citeproc and
Org-roam selected from the same root lock. No other platform/version claim.

All files below are ignored/untracked task files in the ordinary worktree.

| Source path | Archive path | Source status | Bytes | SHA-256 |
|---|---|---|---:|---|
| `tmp/standard-export-0.7.0-d/native-prototype.patch` | `files/tmp/standard-export-0.7.0-d/native-prototype.patch` | ignored/untracked | 14486 | `2a6b26abb6055dc3e76697f8af4d1b3dcdcef8e85779263d4de639e9932116e4` |
| `tmp/standard-export-0.7.0-d/prototype-inputs.json` | `files/tmp/standard-export-0.7.0-d/prototype-inputs.json` | ignored/untracked | 16796 | `989ed641be5e081c41601d6b15617274652c217f7b55a365188286e006656558` |
| `tmp/standard-export-0.7.0-d/attempt14.log` | `files/tmp/standard-export-0.7.0-d/attempt14.log` | ignored/untracked | 71184 | `0068e6c056857c6825750566479efc12aa89d95ee4b906839358aaf63555f359` |
| `tmp/standard-export-0.7.0-d/organize-pin.json` | `files/tmp/standard-export-0.7.0-d/organize-pin.json` | ignored/untracked | 112 | `ed964459db31b03acb6d4347d3deb2e93a505dbdcb28b348df299e7e06b6aa31` |
| `tmp/standard-export-0.7.0-d/project/tests/standard-cite-probe/probe.el` | `files/tmp/standard-export-0.7.0-d/project/tests/standard-cite-probe/probe.el` | ignored/untracked | 9980 | `c94b0cf98285214e91a42075344bf340004eae8931a276c55a37ce9062d4dade` |
| `tmp/standard-export-0.7.0-d/project/tests/standard-cite-probe/organize.el` | `files/tmp/standard-export-0.7.0-d/project/tests/standard-cite-probe/organize.el` | ignored/untracked | 3067 | `15809e9c7e723757deb365e80baeb730301fe6955c52fd2643e4cd34e49625c7` |
| `tmp/standard-export-0.7.0-d/project/tests/standard-cite-probe/test.nix` | `files/tmp/standard-export-0.7.0-d/project/tests/standard-cite-probe/test.nix` | ignored/untracked | 845 | `8bc1216559c49b84ddabe7ab908aca70b475a2f838a04b04ae21ccf4340cfeee` |
| `tmp/standard-export-0.7.0-d/project/tests/standard-cite-probe/test-overlay.nix` | `files/tmp/standard-export-0.7.0-d/project/tests/standard-cite-probe/test-overlay.nix` | ignored/untracked | 81 | `bc3d3173f4c41132e3f4778831edc712ad45754fcaa1c4dc3cee4e299ade440a` |

Every copy was byte-compared against its source and checked for text/size/type.
The introducing GAW checkpoint is located via this manifest's first-parent path
history. An associated C project parent records the exact replay baseline and
capture context; it does not assert these modified prototype files were part
of that commit. No other project parent or external history is needed.
