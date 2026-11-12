# External Org ID link resolution — isolated behavior probe

## Authority and provenance

User requests isolated flake experiments to confirm the resolver path base and
same-file behavior before Stage A implementation. One authorized command:

```sh
timeout 900 nix build --no-write-lock-file --max-jobs 2 -L \
  -o tmp/external-id-probe/result \
  path:/home/lingyu/Projects/org-texmacs/tmp/external-id-probe#checks.x86_64-linux.external-id
```

Standalone flake under `tmp/external-id-probe` with current production
`flake.lock` (nixpkgs/personal-nixpkgs, Org 9.8.10). `probe.nix` supplies
`emacsPackagesFor emacs` + `p.org` and the copied `lisp/` tree; no TeXmacs,
worker, rendering or GUI. `probe.py` runs eight isolated scenarios, each a fresh
`emacs -Q --batch` with a disposable `HOME`/XDG/TMPDIR. `probe.el` wraps
`org-export-resolve-id-link` to record, per `id:` link, the resolver result, its
`default-directory` at resolve time, and the `:id-alist` entry, then calls
`org-texmacs-prepare-buffer` and captures the expected
`org-texmacs-document-error`. ID locations are installed the way
`org-id-update-id-locations` stores them (`abbreviate-file-name` of
`file-truename`).

Build exits 0; result at
`/nix/store/7phlw1nhgpj7yjkljknkniwkknfzsns5-org-texmacs-external-id-probe`.
26 runtime lisp blobs + probe.el hashed into `inputs.json`; source equality
asserted by `probe.py` at the end.

## Verified observations

| scenario           | resolver result             | resolve-time default-directory | expanded target                     |
|--------------------|-----------------------------|--------------------------------|-------------------------------------|
| normal-file        | `../target/target.org`      | source dir                     | `notes/target/target.org`           |
| normal-headline    | `../target/target.org`      | source dir                     | `notes/target/target.org`           |
| alt-base           | `../notes/target/target.org`| `other/` (≠ source dir)        | `notes/target/target.org`           |
| source-api         | `../target/target.org`      | source-buffer dir (not caller) | `notes/target/target.org`           |
| same-file-excluded | `source.org`                | source dir                     | == source-file                      |
| same-file-filelevel | `source.org`               | source dir                     | == source-file                      |
| symlink            | `../real/source.org`        | symlink dir                    | == file-truename, ≠ source-file     |
| tilde              | `../notes/target.org`       | source dir                     | `notes/target.org`                  |

Established facts:

1. The `:id-alist` path is `(file-relative-name file)` and is relative to the
   export buffer's `default-directory`.
2. `default-directory` at resolve time equals captured `resource-base` in every
   scenario, including when `default-directory` differs from the source-file
   directory and when the source-buffer API is called from another buffer.
   `org-export-with-buffer-copy` preserves `default-directory`.
3. Both external file-level and external headline IDs return the target file
   path with no anchor; the two resolve to the same relative string for one
   target file.
4. A `noexport` same-file ID and a current-file file-level ID both resolve to a
   path that `expand-file-name` maps back to the source file. These are the
   same-file cases that Stage A must reject (not lower to self-file links).
5. Symlink alias: `buffer-file-name` keeps the symlink spelling while the ID
   location stores `file-truename`; `expand-file-name` of the resolver result
   equals the truename, not `buffer-file-name`. Same-file comparison needs
   `file-truename`/`file-equal-p` on the source-file side in live preparation.
6. `~` abbreviation: the `:id-alist` value never contains `~` (already
   normalized by `file-relative-name`); the raw `org-id-find-id-file` fallback
   keeps `~/...`. Expand a leading `~` once in live preparation to keep the
   file-target validation conservative, even though the fallback is rare.

## Implications for Stage A

- The external filename from the resolver is safe to consume relative to the
  captured `resource-base` (which is already `default-directory`).
- Live preparation must still accept both the relative `:id-alist` form and the
  absolute fallback form, expanding a leading `~`.
- Same-file detection is a live-preparation comparison using truename identity
  on both sides, separate from the frozen target spelling that is kept for
  rendering.
- Comparison-only normalization must not rewrite the frozen target spelling.

## Limits and archive decision

Emacs-only observation; no document lowering, native serialization, session,
PDF or GoToR. Subtree/INCLUDE variants not executed here (their base is the same
`default-directory` mechanism; covered later by maintained A-C7 tests). Org
9.8.10 only; the `:id-alist` construction is identical in the inspected
Org 10.0-pre source but was not executed.

Consistent with `relative-link-probes.md` and `texmacs-gotor-probe.md`, no raw
archive snapshot is selected. The facts and method above are sufficient for
interpretation, reproduction and handoff; the scripts and raw JSON remain under
`tmp/external-id-probe` and the maintained tests will encode the same contract.
