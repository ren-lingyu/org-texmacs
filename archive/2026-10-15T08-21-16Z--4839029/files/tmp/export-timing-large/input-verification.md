# Input verification

Checked measured project HEAD: 48390293147c9840052fcefa4c1410bcce27e185

All 17 enumerated package/document/license/lock inputs match current project files, committed HEAD and frozen independent flake copies byte-for-byte. Root flake.nix is deliberately excluded (pre-existing user mirror edit); independent diagnostic wrapper uses unchanged project lock.

Original tmp/realworld_test/test.org and frozen fixture remain identical: 6447 bytes, SHA256 73e9e8da9310fa73561633efa410e9003883e8924db708b91cd2ca3e640985bb. No INCLUDE input is used. Expanded workload digests in workloads.json are reconstructed recipes, not independently acquired build-file hashes.

Original example untouched by agent. Source payloads are constructed inside Nix build temporary directories; only small original fixture and reconstruction recipe selected for evidence, not MiB-scale generated source/native products.

Ordinary worktree status:
 M flake.nix

Ordinary staged paths:
(none)
