---
name: org-texmacs-gaw-archive
description: Select, faithfully capture, describe and verify immutable org-texmacs historical documents and temporary evidence in the GAW archive workspace, with supported source provenance and project associations. Do not use for active memory, release artifacts, or ordinary project history.
---

# org-texmacs GAW archive

Preserve retired or migration-sensitive agent material and necessary temporary
evidence without treating either as current memory or reusable instructions.

## Establish the boundary

Use the global `git-agent-workflow` skill. Confirm the deployed GAW worktree,
run `git gaw check`, and verify that `.gaw/config` declares the root `archive`
workspace. Do not initialize, deploy, repair, or rewrite GAW lifecycle state
as part of archiving.

Use declared role metadata and this project's guidance to locate the archive.
All snapshot paths below are relative to the GAW worktree root; selected ordinary
project source paths are relative to its separate project worktree root. The
global `git-agent-workflow` skill is an external workflow dependency, not a
bundled resource or an adjacent installed directory.

Archive only files explicitly selected for the requested snapshot. Reject
symlinks and do not follow a source path outside the ordinary project
worktree. Inspect file type and size before reading or copying it, and follow
the active authorization and sensitive-content rules.

## Select historical evidence

Make the retention assessment on the first user-requested read/review of supplied
material, including mutable INBOX files. Assume the next read may differ or be
unavailable. If original bytes have independent retention value, capture and
verify the version actually inspected within the authorized scope then, rather
than waiting for retirement or implementation. Otherwise distill the useful
content and record why raw capture is unnecessary. An active input need not be
obsolete to justify a selected evidence snapshot. If the original version was
not preserved, state the gap; do not substitute a later file without verified
equality. Read-only review restricts the ordinary project worktree by default;
the authorized GAW loop continues unless the user expressly forbids GAW updates.
Complete accurate memory extraction takes precedence over redundant raw capture.
Archive only if losing original bytes would still impair evidence/reproduction
or interpretation after extraction; mutability or preserving every reviewed
wording alone is insufficient. Keep skill changes out of archive checkpoints.

Root agent documents named by the user are primary candidates. A temporary
file is eligible when all of these conditions hold:

- losing it would materially impair interpretation, reproduction, audit, or
  handoff of a verified result, adopted decision, diagnosed failure, or
  migration;
- its evidence role and reason for retention can be stated in the manifest;
- its repository-relative source path can be preserved under `files/`.

First check whether project history, maintained tests, current memory or an
existing snapshot already preserve the necessary content. Age, an incidental
filename or a mention alone does not justify capture. Distill sufficient content
into memory when the raw material has no independent retention value.

A material reference from a selected document is strong evidence for
inclusion, but is not required when the temporary artifact independently meets
the criteria above. Use targeted searches and explicit paths; do not archive a
whole temporary directory by default.

Only pure-text files may enter this project's GAW workspace. Preserve original
bytes when authorized; do not re-encode, normalize or format them. Do not use tar,
compression or another binary container to bundle text. Exclude non-text material
and report the limitation. General archive guidance does not relax this local rule.

Do not retain secrets to claim fidelity. When an explicitly authorized sanitized
text derivative is needed, describe its source, approved transformation and limits;
do not call it a byte-exact original. Saving a script does not authorize executing it.

## Name and lay out the snapshot

Immediately before copying, capture a UTC timestamp. When one relevant ordinary
project HEAD is inspected as capture context, record its full object ID and use:

```text
archive/YYYY-MM-DDTHH-MM-SSZ--CCCCCCC/
├── MANIFEST.md
└── files/
```

`Z` explicitly marks UTC. `CCCCCCC` is the first seven hexadecimal characters
of the checked capture-context project commit; it does not prove the original
source of every file. Without a relevant single project HEAD, use the UTC
timestamp alone and explain the missing context. Confirm that the destination
does not exist; never overwrite a snapshot directory. A single-file capture uses
the same manifest/files layout as a multi-file capture.

Under `files/`, preserve every selected ordinary project path relative to its
worktree root. For explicitly authorized external, cross-project or previously
archived sources, state each source root and any necessary path mapping. Do not
silently flatten or rename collisions.

The manifest must identify the snapshot as non-authoritative historical
evidence and record:

- the capture time as `YYYY-MM-DDTHH:MM:SSZ`;
- the checked capture-context project HEAD and abbreviation when applicable,
  or why no single relevant project state was established;
- the original source provenance that is actually supported, separately from
  capture context, with uncertainty and gaps stated explicitly;
- the selection rule, source roots and actual file list;
- the evidence role or archive rationale for selected temporary artifacts;
- for every archived file, source path, archive path, tracked status, byte
  count, and SHA-256 digest;
- whether each file is an original-byte copy or an authorized sanitized derivative;
- that the introducing GAW checkpoint is located through the manifest's
  first-parent path history, and what its supported project associations mean.

Keep byte counts, SHA-256 and source status as this project's manifest convention.
The manifest is human-readable evidence, not a CLI schema; no parser, validator or
new tool is required. Neither a manifest nor Git proves source statements true or
the selection complete. HEAD inspected during capture does not establish the
original provenance of old, untracked or modified content.

Do not put the GAW checkpoint hash into its own tree. The commit graph records
that identity after the checkpoint is created.

When referring to a preserved snapshot from memory or evidence, use its archive
path and manifest. Locate the introducing GAW checkpoint through that manifest's
first-parent path history; do not copy its OID into durable prose as the primary
locator. Supported additional project-parent edges record their explicitly
described snapshot associations, not inferred original sources.
Necessary project OIDs and file SHA-256 digests may remain in the manifest.
This reference convention does not authorize rewriting historical manifests,
archived diagnostic OIDs, file bytes or existing GAW commits, or adding logical IDs.

## Verify exactness and provenance

Compare every original-byte capture with its selected source and verify the
manifest's digests and byte counts. For an authorized sanitized derivative,
verify the approved transformation and describe the resulting fidelity limit.
Check that every selected source has its expected copy and that no unrelated
file entered the snapshot. When stable capture matters, compare source content
before and after capture; names, sizes and timestamps alone do not prove equality.

Re-read a checked capture-context project HEAD before staging. If source content
or that state changed, stop before checkpointing, report partial output and
resolve the discrepancy before claiming a successful snapshot. Copy, verification
or description failure also stops checkpointing. Do not silently change selection,
overwrite a snapshot or clean up partial output without the required authorization.

Inspect the entire GAW status and index. The archive checkpoint must contain
only the new snapshot directory: do not mix `.gaw/config`, skills, active
memory, or unrelated archive material into it. Stage the snapshot with an
explicit path, inspect the complete staged diff, and run `git gaw check`.

Create the checkpoint only with `git gaw commit`. Choose zero, one or several
project parents from exact supported evidence under the global skill. A checked
capture-context HEAD may justify one association, but neither the directory name
nor capture alone establishes every file's original source. Describe distinct
associations in the manifest without assigning business roles by parent position.
Missing provenance does not justify invented parents. Inspect the resulting
checkpoint with `git gaw show`.

Once committed, keep snapshot files and manifests unchanged: do not append,
delete, reformat or backfill fields. New material or replacement descriptions
belong in a fresh snapshot with a stable path reference to the earlier one when
useful. A corrected current conclusion can instead go into memory. Older snapshots
retain their own naming, manifest and parent conventions; do not migrate them
retrospectively. The workspace README is current management guidance, not raw
snapshot material, and may evolve. This immutability is a workflow rule, not an
additional CLI protection mechanism.

This skill does not authorize project-worktree writes, tests, network access,
ordinary Git mutations, GAW lifecycle operations, or archive creation outside
the user's requested scope.
