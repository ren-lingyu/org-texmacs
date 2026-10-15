# Input verification
Project HEAD: 48390293147c9840052fcefa4c1410bcce27e185

All 17 enumerated package/document/license/lock inputs match both current project files and committed HEAD, and their frozen flake copies. Root flake.nix is deliberately excluded (existing user mirror edit); independent benchmark flake uses unchanged pinned lock.

- test.org: frozen=6447 bytes SHA256 73e9e8da9310fa73561633efa410e9003883e8924db708b91cd2ca3e640985bb; current=6447 bytes SHA256 73e9e8da9310fa73561633efa410e9003883e8924db708b91cd2ca3e640985bb
- test_include.org: frozen=22 bytes SHA256 cf802a0cc4da13622c21546d9fbd4c847c8e1d020c5360024cda66c0f337dbc6; current=23 bytes SHA256 a2c797e42ed2e0a29242c5512b4a010bcfefc313367f4a242f8c6f07416b8ca4
  Current original has one additional trailing newline; retained frozen sample consistently for every scale. No agent write to original.

Ordinary worktree status:
 M flake.nix

Index:

