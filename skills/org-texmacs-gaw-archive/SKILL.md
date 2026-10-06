---
name: org-texmacs-gaw-archive
description: Create and verify immutable plain-text snapshots of org-texmacs agent documents in the GAW archive workspace, then checkpoint them with exact project-parent provenance. Do not use for active memory, release artifacts, or ordinary project history.
---

# org-texmacs GAW archive

Preserve retired or migration-sensitive agent material without treating it as
current memory or reusable instructions.

## Establish the boundary

Use the global `git-agent-workflow` skill. Confirm the deployed GAW worktree,
run `git gaw check`, and verify that `.gaw/config` declares the root `archive`
workspace. Do not initialize, deploy, repair, or rewrite GAW lifecycle state
as part of archiving.

Archive only files explicitly selected for the requested snapshot. Reject
symlinks and do not follow a source path outside the ordinary project
worktree. Inspect file type and size before reading or copying it, and follow
the active authorization and sensitive-content rules.

## Select historical evidence

Root agent documents named by the user are primary candidates. Include a
temporary probe or check script only when all of these conditions hold:

- a selected document materially refers to it;
- the script is needed to interpret or reproduce preserved evidence;
- it is a reasonably sized plain-text file;
- its repository-relative source path can be preserved under `files/`.

Use targeted searches in the selected documents and `tmp/`; do not archive the
whole temporary directory by default. Do not use tar, compression, or another
binary container. Copy selected text byte for byte instead.

## Name and lay out the snapshot

Immediately before copying, capture one UTC timestamp and the ordinary project
worktree's full `HEAD` object ID. Name the snapshot:

```text
archive/YYYY-MM-DDTHH-MM-SSZ--CCCCCCC/
├── MANIFEST.md
└── files/
```

`Z` explicitly marks UTC. `CCCCCCC` is the first seven hexadecimal characters
of the captured project commit. Under `files/`, preserve every selected path
relative to the ordinary project worktree. Never overwrite an existing
snapshot directory.

The manifest must identify the snapshot as non-authoritative historical
evidence and record:

- the capture time as `YYYY-MM-DDTHH:MM:SSZ`;
- the seven-character project commit abbreviation;
- that the project state is `HEAD` at capture time;
- the repository-relative selection rule and actual file list;
- for every archived file, source path, archive path, tracked status, byte
  count, and SHA-256 digest;
- that the GAW checkpoint is the commit containing the manifest.

Do not put the GAW checkpoint hash into its own tree. The commit graph records
that identity after the checkpoint is created.

## Verify exactness and provenance

Compare every archived file byte for byte with its selected source and verify
the manifest digests and byte counts. Re-read the ordinary project `HEAD`
before staging. If it differs from the captured full object ID, do not stage
or checkpoint the snapshot under the old identity; report the partial snapshot
and prepare a new identity only with authorization for the required cleanup or
replacement.

Inspect the entire GAW status and index. The archive checkpoint must contain
only the new snapshot directory: do not mix `.gaw/config`, skills, active
memory, or unrelated archive material into it. Stage the snapshot with an
explicit path, inspect the complete staged diff, and run `git gaw check`.

Create the checkpoint only with `git gaw commit`, passing the captured full
project object ID as its sole additional project parent. The manifest and
directory may use the seven-character abbreviation; the commit graph preserves
the full parent identity. Inspect the resulting checkpoint with `git gaw show`.

This skill does not authorize project-worktree writes, tests, network access,
ordinary Git mutations, GAW lifecycle operations, or archive creation outside
the user's requested scope.
