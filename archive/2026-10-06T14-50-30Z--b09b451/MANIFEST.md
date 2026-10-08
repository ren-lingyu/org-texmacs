# Native file URL probe snapshot

This is non-authoritative historical evidence, not active project memory.

- Capture time: 2026-10-06T14:50:30Z.
- Project commit: b09b451 (full object ID: b09b4515ad0445666d666506969e441d8f5e6b89).
- Project state: HEAD at capture time. The resource-node worktree and temporary overlay were uncommitted; neither is included here.
- Selection rule: only the three named plain-text probes whose native URL/encoding observations support the adopted file-target boundary.
- Runtime: installed TeXmacs 2.1.5 with isolated test configuration. No resource files were opened and no hyperlinks were followed.
- The loaded worker Scheme source matches the captured project baseline.
- The GAW checkpoint is the commit containing this manifest, with captured HEAD as its sole additional project parent.

## Selected artifacts

| Source path | Archive path | Tracked status | Bytes | SHA-256 | Evidence role |
| --- | --- | --- | ---: | --- | --- |
| tmp/doc-01-file-url-probe.el | files/tmp/doc-01-file-url-probe.el | untracked, ignored under tmp/ | 617 | 1e393407888126af3450ecb5dfd1bd56f5c3742e3324a1a0c52b86688e2f2807 | Isolated Emacs/TeXmacs runner reproducing the native URL probe without opening linked files. |
| tmp/doc-01-file-url-probe.scm | files/tmp/doc-01-file-url-probe.scm | untracked, ignored under tmp/ | 1177 | f6ff41abf891bec94d6af12f5014f93658a728928f5be877ad79b2b8f201a058 | Exact native URL and Cork/UTF-8 expressions informing the resource/native target boundary. |
| tmp/doc-01-file-url-probe.txt | files/tmp/doc-01-file-url-probe.txt | untracked, ignored under tmp/ | 1040 | 96210febfa64288b90128f3db1813096094b7eb1e6a748cd4eb58431a1d2bfe0 | Successful native output covering spaces, Unicode, angle brackets and retained query/anchor characters. |
