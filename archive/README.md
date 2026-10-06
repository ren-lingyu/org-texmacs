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

The timestamp is UTC and `CCCCCCC` is the seven-character abbreviation of the
project `HEAD` captured for that snapshot.  `files/` preserves source paths
relative to the ordinary project worktree.  The manifest records the exact
selection, archive rationale, byte counts, digests, and provenance.  Preserve
plain-text artifacts as individual files; do not bundle them in tar or another
binary container merely for convenience.
