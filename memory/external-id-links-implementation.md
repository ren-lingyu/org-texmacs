# Cross-file Org ID link support — Stage A implementation

## Status

Stage A candidate implemented and validated in the ordinary worktree (11
changed paths, uncommitted; index clean). Baseline ordinary
`f16cc2f8131a7514754886119210099ad5fd943d`, GAW
`7721c2598f9032db901f49e4c3de106362c782ef` at intake. Full flake acceptance
passes. Human review/commit gate remains; no staging, commit, version, tag or
release action performed by the agent.

## Implemented contract

External cross-file `id:` links resolve through Org's standard
`org-export-resolve-id-link` during live preparation. The frozen file target is
associated with the owned link node in the query snapshot, flows through input
ownership, and enters the ordinary file-target resolution/lowering/provenance
and native output policies. The original link identity stays `(:type "id"
:path ORIGINAL-ID)` in the owned Org AST; the link node is never rewritten to a
file link. Internal ID links keep the existing reference/hlink behavior.
External file-level and headline IDs both lower to a document-level hlink to
the target file, without anchors.

## Runtime changes

- `lisp/org-texmacs-query.el`:
  - New `org-texmacs--query-external-id-path`: expands a leading `~` once,
    rejects a target whose `file-equal-p` against the captured source-file
    succeeds (same-file/excluded/file-level self targets), returns the frozen
    spelling otherwise.
  - `org-texmacs--query-snapshot` takes captured `source-file` and
    `resource-base`; the `id:` branch accepts a filename result (which comes
    only from Org's `:id-alist`; unresolved IDs signal `org-link-broken`) and
    stores it in a new `:external-files` alist keyed by the owned link node.
- `lisp/org-texmacs-export.el`: `org-texmacs--standard-input` computes the
  captured source-file/resource-base once and passes them to the snapshot and
  to `org-texmacs--input-own`.
- `lisp/org-texmacs-document.el`: `org-texmacs--document-resolve` consumes
  `:external-files` for `"id"` links and pushes them into the resolution
  `files` list through the same `org-texmacs--document-local-file-path-p` /
  resource-base validation as ordinary file links; a link in both
  `:external-files` and `:targets` is rejected. External targets never enter
  `resolved`/`:targets` or label allocation.
- `lisp/org-texmacs-input.el`: docstring only — standard inputs carry frozen
  `:texmacs-org-query` including external ID file targets; the existing
  `org-texmacs--model-copy-data` ownership remaps them without a new copy path.

Layering kept: filesystem identity (`file-equal-p`, `expand-file-name` of `~`)
happens only in live preparation; pure lowering consumes the frozen string.
No change to model/parse/prepared core, worker protocol, GoToR patch, native
session policies or ordinary file-link semantics.

## Tests

New (all maintained):

- `tests/ert-core/lisp/standard-export.el`:
  - `org-texmacs-standard-export-resolves-external-id-links` — real Org ID
    locations (isolated `org-id-locations` over real files): file-level +
    headline external, structured description, bare link showing the resolved
    path, explicit file link coexistence, internal reference retained, five
    file-provenance paths.
  - `org-texmacs-standard-export-preserves-external-id-identity` — owned AST
    keeps `:type "id"` / original `:path` for two independent links to one
    target; both have owned external associations.
  - `org-texmacs-standard-export-rejects-same-file-id-links` — `noexport`
    same-file ID stays an error.
  - `org-texmacs-standard-export-rejects-file-level-self-id` — current-file
    file-level ID stays an error.
  - `org-texmacs-standard-export-unresolved-id-still-fails` — unresolved ID
    keeps Org's `org-link-broken` propagation.
- `tests/ert-native/lisp/standard-context.el`:
  - `org-texmacs-standard-context-external-id-native-file-policy` — real
    standard preparation; `.tm`/session consumers apply the captured
    `.org`→`.pdf` policy to the external ID target, description unchanged,
    structural body unchanged.
- `tests/ert-pdf/lisp/pdf.el`:
  - `org-texmacs-pdf-external-id-link-policies` (pdf-links) — end-to-end
    actual PDF: default policies give relative `../target/target.pdf` URI
    annotations; the target PDF is neither built nor required to exist; the
    structural document retains the `.org` target.
- `tests/support/common.el`: shared `org-texmacs-test--with-id-files` and
  `org-texmacs-test--register-id-locations` helpers (isolated ID state).
- Renamed `org-texmacs-document-rejects-ambiguous-and-external-id-links` to
  `org-texmacs-document-rejects-ambiguous-and-unresolved-id-links` in
  `tests/ert-native/lisp/document.el`; its independent-input external-ID case
  remains an error and is now described as such.

## Validation performed

Exact authorized commands:

```sh
timeout 600 nix build --no-write-lock-file --max-jobs 2 -L \
  .#checks.x86_64-linux.ert-core                          # 329/329 pass
timeout 900 nix build --no-write-lock-file --max-jobs 2 -L \
  .#checks.x86_64-linux.ert-native                        # 283/283 pass
timeout 900 nix build --no-write-lock-file --max-jobs 2 -L \
  .#checks.x86_64-linux.ert-pdf-render                    # 30/30 pass
timeout 900 nix build --no-write-lock-file --max-jobs 2 -L \
  .#checks.x86_64-linux.ert-pdf-document                  # 48/48 pass
timeout 1800 nix flake check -L --no-write-lock-file --max-jobs 2
                                                          # all checks pass
```

The full flake check covers ert-core/ert-native/ert-pdf-document/
ert-pdf-render/ert-cite/caption-inline-footnotes/package-lint/treefmt and the
maintained texmacs-with-gotor-support renderer regression. First full run
failed only on package-lint (docstring width in org-texmacs-input.el, fixed)
and treefmt (formatter applied to the nine changed Elisp files; CHANGELOG.org
gained a whitespace-only `CLOSED:` indentation fix from the formatter that
does not touch v0.7.0 content). Final run exits 0.

Environment: Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5 (baseline and patched),
Python/pypdf inspector. Unverified: other platforms, other Org/TeXmacs
versions, GUI reader click-through, symlink/`~` cases beyond the isolated
probe, subtree/INCLUDE external-ID variants (path-base mechanism identical by
the probe evidence, but not separately regression-tested).

## Isolated evidence

`memory/external-id-links-probe.md` records the resolver path-base, same-file,
symlink and `~` observations. A second isolated check
(`tmp/external-id-probe`, `external-id-gotor`) rendered the external-ID
document with the patched GoToR renderer (identical override to production,
cache-hit build) and inspected the actual PDF:

```text
/S /GoToR  /F ../target/target.pdf  /D [0 /Fit]
```

Relative target preserved, no URI action for the external target, the
internal ID link keeps its `/label0` destination, and the completed document
body is unchanged by rendering. Result
`/nix/store/n0s0n1yrnh99jk7bcp2rnbxjss1mh1ww-org-texmacs-external-id-gotor-probe`.

No raw archive selected (project convention; see probe memory).

## Ordinary state

Ordinary index clean; worktree carries the 11-path candidate only (plus
pre-existing `tmp/` ignored content). Candidate full-diff SHA256 and per-file
hashes: `memory/external-id-links-inputs.json`. No staging/commit performed.

## Next gate

Human review and ordinary commit decision. If the committed tree differs from
this candidate in runtime behavior, tests or verification inputs, re-scope
validation. Stage B and precise cross-document navigation remain separate.
