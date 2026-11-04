# N4 isolated CSL trace and native converter evidence

Non-authoritative historical evidence, not active project instructions.
Capture UTC: 2026-11-04T02:45:07Z.
Capture-context project HEAD: `6c7ac07ba4f4c936abe99fb15d1915df6e211deb` (`6c7ac07`).

Sources: ordinary project root `/home/lingyu/Projects/org-texmacs`; all selected
paths preserve that relative layout under files/. Original drivers are agent-
authored isolated fixtures against this verified committed baseline. Selected
result files were copied byte-for-byte from the successful locked Nix outputs
recorded in REVIEW.md/reproduction.json; those copies do not change their run
provenance. Both copied project inputs are compared against baseline at capture,
not merely presumed from timestamps. Capture context does not retrospectively
attribute earlier failed harnesses or uncommitted runtime to a committed state.

Selection: these small text drivers, original outputs and explicit reconstruction
record are independently necessary to reproduce/audit the conditional B deferral,
locate upstream math loss and distinguish parser repair from valid conversion.
Maintained product history does not contain these isolated negative controls.
See REVIEW.md for detailed classification, omissions and binary-layout limits.
All files are original-byte copies of the selected project-relative source;
no normalization, sanitization, packaging or binary archive is used.

| Source path | Archive path | Source status | Bytes | SHA-256 |
| --- | --- | --- | --- | --- |
| `tmp/inline-objects-0.7.0/n4-csl-flow-1/flow.el` | `files/tmp/inline-objects-0.7.0/n4-csl-flow-1/flow.el` | ignored, untracked | 8333 | `9f70b4551f8e60067a2b3a8c32d5d8c5ffb66848c708d6067883ab2ce24fcb70` |
| `tmp/inline-objects-0.7.0/n4-csl-flow-1/flow.nix` | `files/tmp/inline-objects-0.7.0/n4-csl-flow-1/flow.nix` | ignored, untracked | 811 | `98782c393f7f853d8a6bea8c0782be48cf8a0a5a3bb54eeaa96e7ea9d3efbd32` |
| `tmp/inline-objects-0.7.0/n4-csl-flow-1/flake.nix` | `files/tmp/inline-objects-0.7.0/n4-csl-flow-1/flake.nix` | ignored, untracked | 2943 | `eec692b82df68d8a6af6ec75081adc916976e3d4d6690fca2f2fdde93c0c8e86` |
| `tmp/inline-objects-0.7.0/n4-native-latex-1/probe.el` | `files/tmp/inline-objects-0.7.0/n4-native-latex-1/probe.el` | ignored, untracked | 3753 | `672f7e4c73c8c6733e56a3d5cd6275c63094b3dc610b0d5334043e6be6bf83aa` |
| `tmp/inline-objects-0.7.0/n4-native-latex-1/probe.scm` | `files/tmp/inline-objects-0.7.0/n4-native-latex-1/probe.scm` | ignored, untracked | 1853 | `124694963459595251ee2ebaf38a94f16e8262a08e3d95a053c7a51c3a40ca4d` |
| `tmp/inline-objects-0.7.0/n4-native-latex-1/probe.nix` | `files/tmp/inline-objects-0.7.0/n4-native-latex-1/probe.nix` | ignored, untracked | 634 | `5698b921646cd31549c0039b2db0d7495a41540f44b840fdce0e16d985dba741` |
| `tmp/inline-objects-0.7.0/n4-native-latex-1/flake.nix` | `files/tmp/inline-objects-0.7.0/n4-native-latex-1/flake.nix` | ignored, untracked | 2947 | `aebd936d3cf96e537696aaec41946e4ff773ce02888f1fb3e7c55034c73ffd4a` |
| `tmp/inline-objects-0.7.0/n4-evidence/fraction.bib` | `files/tmp/inline-objects-0.7.0/n4-evidence/fraction.bib` | ignored, untracked | 88 | `8d57d284b1d97c02378dd7530dbb21260eb8b68d59cdced0f8454585ccd054a0` |
| `tmp/inline-objects-0.7.0/n4-evidence/init-latex.scm` | `files/tmp/inline-objects-0.7.0/n4-evidence/init-latex.scm` | ignored, untracked | 4530 | `92a976f38ceec66d48c4e98085cabf857ef4cd8dd48d843e0226b9736184d4e3` |
| `tmp/inline-objects-0.7.0/n4-evidence/symbol.bib` | `files/tmp/inline-objects-0.7.0/n4-evidence/symbol.bib` | ignored, untracked | 82 | `ee791a35e23cbeb14640111688dfbe2fb3851e14287108b0c2b151df697dffa8` |
| `tmp/inline-objects-0.7.0/n4-evidence/reproduction.json` | `files/tmp/inline-objects-0.7.0/n4-evidence/reproduction.json` | ignored, untracked | 78472 | `6199a5fb801f7d7872c8d5b593fbe80a13a81ca43dde77201b483826f81e3044` |
| `tmp/inline-objects-0.7.0/n4-evidence/flow-evidence.sexp` | `files/tmp/inline-objects-0.7.0/n4-evidence/flow-evidence.sexp` | ignored, untracked | 9947 | `ade72199fcab053bc2e28f84b283be79a214784b459ab126ee6b269e54a7c234` |
| `tmp/inline-objects-0.7.0/n4-evidence/flow.csl` | `files/tmp/inline-objects-0.7.0/n4-evidence/flow.csl` | ignored, untracked | 412 | `77565232c2b14ba23d877b8973976d4be824667b41ac7335e563523a49d288f6` |
| `tmp/inline-objects-0.7.0/n4-evidence/entity.bib` | `files/tmp/inline-objects-0.7.0/n4-evidence/entity.bib` | ignored, untracked | 80 | `541fe36360eb421831675401f318303ed0e0f6771483e9b6c71529af145c29d4` |
| `tmp/inline-objects-0.7.0/n4-evidence/REVIEW.md` | `files/tmp/inline-objects-0.7.0/n4-evidence/REVIEW.md` | ignored, untracked | 5361 | `ad160c8b2122b617965abe0d58f79e88ec756ca7cbe64fbebdf4377ee0286218` |
| `tmp/inline-objects-0.7.0/n4-evidence/native-converter-output.txt` | `files/tmp/inline-objects-0.7.0/n4-evidence/native-converter-output.txt` | ignored, untracked | 1068 | `de003d5a44746ce2794ebd91a5c4085796c7804f704522fd4475b1c88dd34e83` |
| `tmp/inline-objects-0.7.0/n4-evidence/greek.bib` | `files/tmp/inline-objects-0.7.0/n4-evidence/greek.bib` | ignored, untracked | 85 | `d37f67bf5a23f180a6be0637778ff4eeecef71153273ca52023d5fcd308f6f1c` |
| `tmp/inline-objects-0.7.0/n4-evidence/native-converted.sexp` | `files/tmp/inline-objects-0.7.0/n4-evidence/native-converted.sexp` | ignored, untracked | 4058 | `74fc8fefba4df311630978522115b3f3ff77388d8b06c01982da588c056f9d44` |
| `tmp/inline-objects-0.7.0/n4-evidence/native-ert.log` | `files/tmp/inline-objects-0.7.0/n4-evidence/native-ert.log` | ignored, untracked | 6576 | `791c4e829af2c08b601ff5d3a4db1155589b1f4ab95a9ea9fa83e26364e80128` |

Introducing GAW checkpoint is found through this manifest's first-parent path
history. No source-history association is inferred from a directory name;
any project association must mean the separately verified baseline used for
these experiments, not a future production implementation or release approval.
