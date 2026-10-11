# Historical archive

This directory contains immutable snapshots of historical source material.
Archived files are evidence, not current instructions or active agent memory.
Read them only when investigating historical decisions, original wording, or
migration omissions.  Current state belongs in `../memory/` and reusable
procedures belong in `../skills/`.

Each snapshot uses this layout:

```text
YYYY-MM-DDTHH-MM-SSZ--CCCCCCC/
├── MANIFEST.md
└── files/
```

The timestamp is UTC and `CCCCCCC`, when relevant, abbreviates the project HEAD
inspected as capture context. Without one relevant project HEAD, the timestamp
alone names the snapshot. A name does not prove the original source of its files.
`files/` preserves paths relative to the stated source root, normally the ordinary
project worktree. The manifest records selection, rationale, source roots/status,
byte counts, SHA-256, fidelity and supported original provenance separately from
checked capture context. Describe gaps and approved sanitized derivatives explicitly.

Use `org-texmacs-gaw-archive` for the complete project procedure. Only pure-text
files enter GAW; archive-only checkpoints remain a local requirement. Choose project
parents from supported evidence rather than the name or an automatic HEAD rule.
Use stable snapshot paths and manifest history to locate introduction. Preserve
committed snapshot files/manifests unchanged; replacement material/descriptions
belong in fresh snapshots. Older snapshots retain their historical conventions.
This README is current management guidance and can evolve separately from them.
