# Issue #1 Phase 0 isolated Org pipeline evidence

Non-authoritative historical evidence; not current agent instructions.
Capture time: 2026-10-12T19:11:59Z.
Checked capture-context project HEAD: `b22945493102edc1823fe063f9d278ba628bdf5e` (`b229454`).

The user requested Phase 0 investigation, isolated version-sensitive testing,
and necessary GAW archiving. These 17 pure-text files preserve the independently
reproducible probes, locked environment, final observations, exact source/API
excerpts and analysis. Maintained project tests do not yet preserve this research.
No whole temporary directory, binary, Org tar, caches, failed intermediate script,
or redundant project-source copy is included.

Source root: `/home/lingyu/Projects/org-texmacs`. All selected paths are ordinary-project-relative under
ignored `tmp/issue-1-phase-0/`, authored or captured by this agent during this
investigation. Every archived file is an original-byte copy of its selected
temporary source, not a sanitized derivative. source-evidence.txt itself is an
identified excerpt derivative of installed Org 9.8.10 source, and
project-mirror.patch is an identified Git diff of the user's uncommitted overlay;
neither is described as an original full upstream/project source file.

Original provenance is separate from capture context: final probes executed
against the current lock's Emacs 31.1 / Org 9.8.10 plus eleven explicitly copied
project Lisp files. project-source.txt verifies each copied file against both
the ordinary worktree and `b22945493102edc1823fe063f9d278ba628bdf5e`'s committed bytes. The isolated lock matches
the committed project lock byte-for-byte. USTC URLs retain original fixed hashes;
mirror success does not prove official ELPA reachability. Earlier 9.8-pre/9.8.8
environment observations are not the final test baseline. Files are research
artifacts, not files originally committed on main. Native consumers and real
Org-roam integration were not tested; external package source lookup failed.

Final Nix probe build exited 0: 14/14, no unexpected results. Exact command and
output identity are in REPORT.md; reproduction in REPRODUCE.md. observations.sexp
retains raw cyclic text-property and killed-buffer representations and is a
diagnostic print, not a reloadable Lisp data file. The isolated flake depends
on materializing the eleven sources from the identified project commit; those
external references are explicit and their bytes are already preserved in Git.
The project flake.nix overlay remains unstaged and must not be mistaken for
committed project state. The independent flake's mirror transport is recorded
in its own source; it does not require the project overlay to reproduce.

| Source path | Archive path | Source Git status | Bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| `tmp/issue-1-phase-0/REPORT.md` | `files/tmp/issue-1-phase-0/REPORT.md` | ignored, untracked | 16203 | `1125298fb1eaa3779d3d1305ab22c0dd9f96225e315df4ec0759ee79b8e9204f` |
| `tmp/issue-1-phase-0/REPRODUCE.md` | `files/tmp/issue-1-phase-0/REPRODUCE.md` | ignored, untracked | 2242 | `8d83cc838d06c95dc3e49b8d494cefa6547fb83190740757d8e2f8cd3373bc78` |
| `tmp/issue-1-phase-0/flake.nix` | `files/tmp/issue-1-phase-0/flake.nix` | ignored, untracked | 1693 | `be1f9fb939e639d82d4cf3575243659d633a238c33330c47f82e9ddb1c7034f7` |
| `tmp/issue-1-phase-0/flake.lock` | `files/tmp/issue-1-phase-0/flake.lock` | ignored, untracked | 1752 | `118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a` |
| `tmp/issue-1-phase-0/probes.el` | `files/tmp/issue-1-phase-0/probes.el` | ignored, untracked | 18996 | `444465d270814a0165a473ba9161016938a532657da158839ecf3f7ef1033379` |
| `tmp/issue-1-phase-0/environment.el` | `files/tmp/issue-1-phase-0/environment.el` | ignored, untracked | 810 | `86c4591408cb4fac3580786996a8162b250ccd9c2cb4019830c1ae1d30011113` |
| `tmp/issue-1-phase-0/fixtures/root.org` | `files/tmp/issue-1-phase-0/fixtures/root.org` | ignored, untracked | 25 | `1293b325d2bac0cdba4d47ec41880b4d328809088288c3b04408ce6664fe8226` |
| `tmp/issue-1-phase-0/fixtures/parts/b.org` | `files/tmp/issue-1-phase-0/fixtures/parts/b.org` | ignored, untracked | 107 | `54cb6812661bd73aedb8e70a71027cde374626596584f509e27e3333d28fabf3` |
| `tmp/issue-1-phase-0/fixtures/parts/deeper/c.org` | `files/tmp/issue-1-phase-0/fixtures/parts/deeper/c.org` | ignored, untracked | 85 | `e0051ebf510585ac6d6e4bbda163cbb5a83ec954cce1e55fd4427fa6934608ba` |
| `tmp/issue-1-phase-0/fixtures/config/setup.org` | `files/tmp/issue-1-phase-0/fixtures/config/setup.org` | ignored, untracked | 28 | `7b71f18e0d8474eb6a7ee39934fbdbfb7df72dbbba16decc05926cd1da34bb27` |
| `tmp/issue-1-phase-0/environment.txt` | `files/tmp/issue-1-phase-0/environment.txt` | ignored, untracked | 878 | `ef004528397e9601da4a9310601aea452fb1074e66569490bd0fdd9bf6af811f` |
| `tmp/issue-1-phase-0/summary.txt` | `files/tmp/issue-1-phase-0/summary.txt` | ignored, untracked | 48 | `3ea445c5102ab742d2a7d708c70f7c973acebf0b0805a1322c1fe58495d660a1` |
| `tmp/issue-1-phase-0/observations.sexp` | `files/tmp/issue-1-phase-0/observations.sexp` | ignored, untracked | 4754 | `6f8f895b7fa52c355d4328afa065df69cda76d2d4792cdfe90e04a6fc4196464` |
| `tmp/issue-1-phase-0/ert.log` | `files/tmp/issue-1-phase-0/ert.log` | ignored, untracked | 1126 | `8d98656cc6d375b4b16947211750853031118a305337f8c0e2735433532e9b18` |
| `tmp/issue-1-phase-0/project-source.txt` | `files/tmp/issue-1-phase-0/project-source.txt` | ignored, untracked | 1325 | `9d19f8c32a5316ec856fa4cfb742084f09b586279069b6923948f9070537b8a0` |
| `tmp/issue-1-phase-0/source-evidence.txt` | `files/tmp/issue-1-phase-0/source-evidence.txt` | ignored, untracked | 53470 | `657f5eb94b340520ab88ea69c5b36e91241d6bbc33c859d1418b199692d9d8d7` |
| `tmp/issue-1-phase-0/project-mirror.patch` | `files/tmp/issue-1-phase-0/project-mirror.patch` | ignored, untracked | 1154 | `2af6574fe8302fa7a5e64d3e93e8955cf7c36f0a4c6c2f135a2edffe8b65032a` |

The introducing GAW checkpoint is located through this manifest's first-parent
path history. Its project-parent association identifies the inspected and
byte-verified project code/lock snapshot used by this research, not an assertion
that the temporary files or uncommitted mirror overlay originated in that commit.
Archive checkpoint contains this snapshot only; active-memory findings are
checkpointed separately. Once committed, this snapshot remains immutable.

Git diff --check reports original ERT log's blank EOF and patch context lines
containing a single space. These are retained for original-byte fidelity, not
normalized. All archive copies and declared digests were verified; GAW check
passes. This whitespace result does not apply to authored active-memory edits.
