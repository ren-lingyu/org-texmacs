# Cross-file Org ID link support — Stage A implementation

## Status

Stage A candidate implemented and validated in the ordinary worktree after
the user's review-round requirements (13 changed paths, uncommitted; the
ordinary index still holds the earlier 11-path pre-review candidate staged by
the user). Baseline ordinary `f16cc2f8131a7514754886119210099ad5fd943d`.
Full flake acceptance passes. Human review/commit gate remains; the agent
performed no ordinary staging/commit/version/tag/release action.

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

## Path base (review finding, fixed)

Org builds `:id-alist` values with `(file-relative-name file)` against the
export working copy's `default-directory`, not necessarily the captured
resource base. `org-texmacs--query-external-id-path` therefore interprets the
resolver spelling in live preparation:

- Absolute result: used as-is after a single leading `~` expansion.
- Relative result with the live working-copy base equal to the captured
  `resource-base` (expanded, trailing-slash normalized): the raw relative
  spelling is kept.
- Relative result with diverged bases: interpret against the live base and
  verify with a filesystem existence check; freeze the absolute path. If the
  captured base still identifies the file, keep the raw spelling. If neither
  base identifies the file, reject with
  "External ID target path base cannot be determined".

No path interpretation or filesystem lookup happens in pure lowering. The
same-file identity check (`file-equal-p` against the captured source-file) runs
after this interpretation. Regression coverage: non-default buffer
`default-directory`, a standard `org-export-before-processing-functions` hook
that moves the working-copy directory, direct helper rebase and unverifiable-
base rejection tests.

## Validation preservation (review finding, fixed)

`org-texmacs--document-resolve` enters the shared file-target check whenever
the link kind is `"file"` or an external association exists, so an ordinary
file link with a nil/empty path keeps its original
"Unsupported file link or resource context" failure instead of skipping
validation. Internal-path nonempty-string validation now applies to
external ID links as well, regardless of the frozen association.

## Runtime changes

- `lisp/org-texmacs-query.el`:
  - `org-texmacs--query-external-base-p`: expanded, trailing-slash-normalized
    comparison of the live working-copy `default-directory` with the captured
    `resource-base`; no filesystem lookup.
  - `org-texmacs--query-external-id-path`: `~` expansion, the three-way base
    interpretation above, and the same-file rejection.
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
  `:external-files` and `:targets` is rejected; the validation-entry fix above.
  External targets never enter `resolved`/`:targets` or label allocation.
- `lisp/org-texmacs-input.el`: docstring only — standard inputs carry frozen
  `:texmacs-org-query` including external ID file targets; the existing
  `org-texmacs--model-copy-data` ownership remaps them without a new copy path.

Layering kept: filesystem identity (`file-equal-p`, `expand-file-name`, the
existence verification) happens only in live preparation; pure lowering
consumes the frozen string. No change to model/parse/prepared core, worker
protocol, GoToR patch, native session policies or ordinary file-link semantics.

## Tests

New (all maintained):

- `tests/ert-core/lisp/standard-export.el`:
  - `org-texmacs-standard-export-resolves-external-id-links` — real Org ID
    locations over real files: file-level + headline external, structured
    description, bare link showing the resolved path, explicit file link
    coexistence, internal reference retained, five file-provenance paths whose
    target leaves are asserted directly.
  - `org-texmacs-standard-export-preserves-external-id-identity` — owned AST
    keeps `:type "id"` / original `:path` for two independent links to one
    target; both have owned external associations.
  - `org-texmacs-standard-export-rejects-same-file-id-links` — `noexport`
    same-file ID stays an error.
  - `org-texmacs-standard-export-rejects-file-level-self-id` — current-file
    file-level ID stays an error.
  - `org-texmacs-standard-export-unresolved-id-still-fails` — unresolved ID
    keeps Org's `org-link-broken` propagation.
  - `org-texmacs-standard-export-external-id-alt-default-directory` — the
    resolver path is relative to the buffer's non-default captured
    default-directory and still names the target.
  - `org-texmacs-standard-export-external-id-hook-base-change` — a standard
    before-processing hook moves the working-copy directory; the frozen target
    is a correct absolute path, not a silent wrong relative one.
  - `org-texmacs-query-external-id-path-rebases-diverged-base` and
    `...-rejects-unverifiable-base` — direct helper unit tests for the rebase
    and rejection boundaries.
  - `org-texmacs-standard-export-external-id-snapshot-frozen` — the
    association key is the final owned AST link node; after mutating the ID
    database, caller default-directory and file-link Custom values, repeated
    lowering is unchanged and never requeries the resolver/ID database or
    starts a worker.
  - `org-texmacs-standard-export-external-id-subtree` — a valid external ID in
    a subtree export.
  - `org-texmacs-standard-export-external-id-subtree-same-file` — an ID
    pointing at another headline of the same file outside the subtree stays an
    error.
  - `org-texmacs-standard-export-external-id-include` — an INCLUDE-introduced
    cross-file ID link resolves to the file target.
- `tests/ert-core/lisp/model-serialization.el`:
  - `org-texmacs-model-serialize-preserves-external-id-link` — the independent
    model round-trips the original `id:` link without file-path or suffix
    invention, and neither parse nor serialize queries the ID database.
- `tests/ert-core/lisp/document.el`:
  - `org-texmacs-document-pure-input-ignores-id-database` — independent pure
    input does not discover an ambient ID location and keeps the error.
- `tests/ert-native/lisp/standard-context.el`:
  - `org-texmacs-standard-context-external-id-native-file-policy` — real
    standard preparation; `.tm`/session consumers apply the captured
    `.org`→`.pdf` policy to the external ID target, description unchanged,
    structural body unchanged.
- `tests/ert-pdf/lisp/pdf.el`:
  - `org-texmacs-pdf-external-id-link-policies` (pdf-links) — end-to-end
    actual PDF with the output file saved next to the source Org file:
    default policies give relative `../target/target.pdf` URI annotations; the
    target PDF is neither built nor required to exist; the structural document
    retains the `.org` target.
- `tests/support/common.el`: shared `org-texmacs-test--with-id-files` and
  `org-texmacs-test--register-id-locations` helpers. The fixture isolates
  `org-id-locations`, `org-id-locations-file`, `org-id-files`,
  `org-id-track-globally` (t, so the unresolved fallback scan runs against
  private inputs only), `org-id--locations-checksum`, `org-id-extra-files`,
  `org-agenda-files` and `org-export-use-babel`; fixtures never touch a user
  knowledge base, and temp files/buffers are cleaned up.
- Renamed `org-texmacs-document-rejects-ambiguous-and-external-id-links` to
  `org-texmacs-document-rejects-ambiguous-and-unresolved-id-links` in
  `tests/ert-native/lisp/document.el`; its independent-input external-ID case
  remains an error and is now described as such.

## Validation performed

Exact authorized commands:

```sh
timeout 600 nix build --no-write-lock-file --max-jobs 2 -L \
  .#checks.x86_64-linux.ert-core                          # 339/339 pass
timeout 900 nix build --no-write-lock-file --max-jobs 2 -L \
  .#checks.x86_64-linux.ert-native                        # 283/283 pass
timeout 900 nix build --no-write-lock-file --max-jobs 2 -L \
  .#checks.x86_64-linux.ert-pdf-document                  # 48/48 pass
timeout 900 nix build --no-write-lock-file --max-jobs 2 -L \
  .#checks.x86_64-linux.ert-pdf-render                    # 30/30 pass
timeout 1800 nix flake check -L --no-write-lock-file --max-jobs 2
                                                          # all checks pass
```

The full flake check covers ert-core/ert-native/ert-pdf-document/
ert-pdf-render/ert-cite/caption-inline-footnotes/package-lint/treefmt and the
maintained texmacs-with-gotor-support renderer regression. During the review
round, one core failure was diagnosed and fixed: binding
`org-id-track-globally` to nil made Org's unresolved-ID fallback error early
instead of scanning; the fixture now allows the scan with fully private
inputs, restoring the `org-link-broken` contract.

Environment: Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5 (baseline and patched),
Python/pypdf inspector. Unverified: other platforms, other Org/TeXmacs
versions, GUI reader click-through, and any hook that changes the working-copy
directory after Org collects `:id-alist` (the pathological mid-export case is
covered by the rejection boundary, not by a realistic hook regression).

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
body is unchanged by rendering. Re-verified with the review-round lisp; result
`/nix/store/j5sdm11v95jy3kcidysp1xmvpmv7x3lq-org-texmacs-external-id-gotor-probe`.
The baseline-renderer PDF annotation test
(`org-texmacs-pdf-external-id-link-policies`) remains in the ordinary suite.

No raw archive selected (project convention; see probe memory).

## Ordinary state

The ordinary index contains the earlier 11-path pre-review candidate (staged
outside the agent's actions); the worktree carries the 13-path review-round
candidate on top. Candidate full-diff SHA256 and per-file hashes:
`memory/external-id-links-inputs.json`. No agent staging/commit performed.

## Next gate

Human review and ordinary commit decision (including how to reconcile the
index state). If the committed tree differs from this candidate in runtime
behavior, tests or verification inputs, re-scope validation. Stage B and
precise cross-document navigation remain separate.
