# Cross-file Org ID link support — Stage A implementation

## Delivery status

Stage A is human-delivered as ordinary commit
`246283110e9cdfeaad8a1d616fca46413af47510`
("feat(export): support cross-file Org ID links"), parent
`f16cc2f8131a7514754886119210099ad5fd943d`, 13 paths, 1115 insertions /
92 deletions. Every committed blob's SHA256 equals the worktree content the
agent validated (full flake check exit 0; isolated patched GoToR probe
passed), so the commit introduced no content delta beyond the validated
candidate. Ordinary worktree/index clean. No tag/version/release/publication
action. Receipt: `memory/external-id-links-inputs.json` (revision
final-committed).

## Implemented contract

Org ID links keep their object-level reference semantics. Standard Org export
uses `org-export-resolve-id-link`, which returns an internal headline or an
external filename. Internal ID targets keep the existing internal reference
resolution and label allocation. External ID targets (file-level and headline
IDs) currently lower to document-level file links; a headline ID points to its
file, not to the headline's position. This is a lowering boundary, not a
redefinition of Org ID semantics. The original `:type "id"` and `:path`
identity stays in the owned Org AST.

## Query snapshot and ownership

`org-texmacs--query-snapshot` (live preparation) adds a private
`:external-files` plist field, `((OWNED-ID-LINK-NODE . FILE-PATH) ...)`,
distinct from `:targets` (internal AST targets). External ID targets never
enter internal reference allocation. Input ownership copies/remaps the mapping
through the existing `org-texmacs--model-copy-data` node-identity mechanism;
the prepared input freezes the file target and retains no requeryable ID
database state.

`org-texmacs--document-resolve` validates the frozen mapping before use:
proper list; each key is a link node reachable in the owned AST with type
`"id"`; each value is a local file path; keys are unique; an entry must not
also map to an internal `:targets` target. Validation checks owned AST link
identity, not membership in the final rendered links, so legally retained but
unrendered structures are not wrongly rejected.

## Path base: final mechanism and review history

Org builds `:id-alist` during tree-property collection via
`(file-relative-name file)`, whose base is the export working copy's
`default-directory` at that moment. The frozen path must be interpreted
against the directory in effect when Org collected it — not the query-snapshot
or native-consumer directory.

Review history:

- First candidate treated the resolver spelling as relative to the captured
  resource base. Review found the base is actually the working copy's
  `default-directory`, and that nil-path ordinary file links and external ID
  path validation had regressed.
- Second candidate added working-copy base support, but inferred the base by
  checking which of two candidate directories contains a file with the given
  relative spelling (`file-exists-p` heuristic). That heuristic is unsound: the
  same relative path can exist in both directories, and existence cannot prove
  which file Org's resolver actually selected; a late working-copy directory
  change can make both checks mislead.
- Final revision removes the heuristic and captures the base at the correct
  lifecycle stage through existing public Org dispatch boundaries. New helper
  `org-texmacs--standard-capture-id-base` runs at the first standard dispatch
  after tree-property collection: with Cite enabled, in
  `org-texmacs--standard-cite` before Cite callbacks execute; with Cite
  disabled, in `org-texmacs--standard-data` when DATA is the collected root
  tree. The scoped transaction stores `:id-resolution-tree` (the prepared tree
  root identity, so nested exports or later transcoding cannot overwrite the
  capture) and `:id-resolution-base` (the captured
  `default-directory`, when `:id-alist` is present). No advice on Org private
  preparation, no copied Org preparation.

Final interpretation rules (`org-texmacs--query-external-id-path`):

1. Interpret a relative filename against the captured ID-resolution base.
2. When that base matches the source resource base, keep the relative spelling.
3. When they differ, freeze the correctly interpreted absolute path.
4. Absolute filenames keep absolute semantics.
5. A relative filename without a reliable base fails explicitly
   ("External ID target path base cannot be determined").

Same-file identity comparison runs on the correctly interpreted target
(`(equal absolute (expand-file-name source-file "/"))` or `file-equal-p`) and
keeps the local file identity check. The completed input owns only the
determined file target; no live transaction root or directory capture is
retained for lowering.

Distinction kept throughout: ID-resolution base (collection-time working-copy
directory), source resource base (captured buffer directory), and later
current directories (never consulted).

## Document lowering and native policies

External ID targets enter `org-texmacs-resolution-files` and reuse ordinary
file-link validation, structured description lowering, bare-link path display,
`hlink` construction and file target provenance. The structural document keeps
the original `.org` path. Native consumers apply the captured
`org-texmacs-link-org-files-as-pdf` and
`org-texmacs-pdf-file-links-as-absolute` policies through the existing
provenance adaptation. No ID-specific native rendering; no change to the
original Org AST, source/model round-trip, Org link following, user-authored
STM, or ordinary URI targets; existing `.tm`/session/PDF policies unchanged.

## Current error boundaries

Still errors: unresolved IDs (`org-link-broken` propagation); the current
source file's own file-level ID; an ID whose location is the current source
file but whose object is outside the effective exported AST (e.g. excluded
`noexport` heading); paths/contexts outside the local file-target contract;
invalid or inconsistent frozen external mappings; independent pure input
without a pre-determined external target; other unsupported Org link types.
The exporter never builds target documents or checks target PDF existence; no
self-PDF fallback and no document-root anchor are introduced.

## Maintained regression coverage

New or updated tests (final committed source):

- `tests/ert-core/lisp/standard-export.el`:
  `org-texmacs-standard-export-resolves-external-id-links` (file-level +
  headline external, structured description, bare display, file-link
  coexistence, internal reference, provenance target leaves),
  `...-preserves-external-id-identity`,
  `...-rejects-same-file-id-links`,
  `...-rejects-file-level-self-id`,
  `...-unresolved-id-still-fails`,
  `...-external-id-alt-default-directory`,
  `...-external-id-hook-base-change` (Cite-disabled early base change),
  `...-external-id-late-base-change` (Cite-enabled; colliding same-spelling
  decoy; nested standard export inside a Cite callback; return-to-resource
  and move-away modes),
  `org-texmacs-query-external-id-path-rebases-diverged-base` (known base
  needs no existence heuristic; the target file does not even exist),
  `org-texmacs-query-external-id-path-rejects-unverifiable-base` (existence
  does not establish the collection base),
  `...-external-id-snapshot-frozen` (owned key identity, no resolver/ID
  database/worker requery, captured native policy assertions, repeated
  lowering),
  `...-external-id-subtree`, `...-external-id-subtree-same-file`,
  `...-external-id-include`.
- `tests/ert-core/lisp/document.el`:
  `org-texmacs-document-pure-input-ignores-id-database`,
  `org-texmacs-document-validates-frozen-external-id-mapping` (duplicate
  keys, nil/empty values, wrong link type, detached key, internal/external
  conflict).
- `tests/ert-core/lisp/model-serialization.el`:
  `org-texmacs-model-serialize-preserves-external-id-link` (round-trip keeps
  the `id:` link, no path/suffix invention, no ID database query).
- `tests/ert-native/lisp/standard-context.el`:
  `org-texmacs-standard-context-external-id-native-file-policy` (`.tm`/session
  suffix policy on the external target, description and body unchanged).
- `tests/ert-pdf/lisp/pdf.el`:
  `org-texmacs-pdf-external-id-link-policies` (pdf-links; baseline renderer
  `/URI` annotations `../target/target.pdf`, output PDF next to the source
  Org file, target PDF not built).
- `tests/support/common.el`: isolated ID fixture helpers covering
  `org-id-locations`, `org-id-locations-file`, `org-id-files`,
  `org-id-track-globally`, `org-id--locations-checksum`,
  `org-id-extra-files`, `org-agenda-files`, `org-export-use-babel`; no user
  knowledge base is touched.
- Renamed `org-texmacs-document-rejects-ambiguous-and-unresolved-id-links`
  (`tests/ert-native/lisp/document.el`) clarifies the independent-input
  contract.

## Validation evidence

Agent-executed against the same source as the committed blobs:

```sh
nix flake check -L --no-write-lock-file --max-jobs 2   # exit 0
```

ERT counts: core 341/341, native 283/283, pdf-document 48/48, pdf-render
30/30, cite 11/11, caption-inline-footnotes 6/6; package-lint, treefmt and the
maintained texmacs-with-gotor-support renderer regression pass. Environment:
Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5.

PDF evidence distinction: the ordinary PDF integration suite uses the baseline
renderer; `org-texmacs-pdf-external-id-link-policies` verifies `/URI` file
annotations, which are the correct baseline evidence and are not GoToR. The
combined end-to-end evidence (Org external ID -> standard resolution ->
org-texmacs lowering -> patched TeXmacs -> actual GoToR annotation) comes from
the isolated probe `tmp/external-id-probe` (`external-id-gotor` check):
`/S /GoToR`, `/F ../target/target.pdf`, `/D [0 /Fit]`, relative preserved, no
URI action for the external target, internal link keeps `/label0`, rendered
body unchanged. Result
`/nix/store/3xgmgvqxgzxwdpdncad5r8a3lrjvgigd-org-texmacs-external-id-gotor-probe`
(run against the final lisp; patch override identical to the production
texmacs-with-gotor-support derivation, cache-hit).

Validation boundaries: other platforms, other Org/TeXmacs versions, GUI PDF
reader click-through, arbitrary user callback mutations and any hook that
moves the working copy between `:id-alist` collection and the capture dispatch
remain unverified (the final capture design closes the realistic Cite and
root-transcoding windows; such mid-window mutation is not covered by a
realistic hook regression). User-reported success of the final revision patch
is additionally recorded; the agent runs above independently confirm the same
source.

## Retention assessment

User-supplied review materials (`tmp/2026-11-12T14:25:14+08:00.diff`,
`tmp/2026-11-12T17:01:47+08:00.diff`,
`org-texmacs-stage-a-path-base-revision.patch`) are historical candidates:
the effective implementation is fully preserved by the ordinary commit,
maintained tests, this memory and the final receipt. The substantive issues,
counter-examples and the final fix are recorded above. No raw archive is
selected; the patch file itself is not present in the repository anymore and
no byte-exact capture claim is made for it.

## Next

Stage A delivery verification is complete. Stage B (unsupported Org link
fallback) and the precise cross-document ID navigation candidate remain
separate and are not adopted. No release-state, version, tag, push or
publication action follows automatically.
