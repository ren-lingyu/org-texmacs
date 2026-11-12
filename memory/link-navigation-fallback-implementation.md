# Link navigation fallback (Stage B) — implementation and validation

## Status

Stage B is human-delivered as ordinary commit
`f1b132b1f545dd394b65fef8ab824f22beb40290`
("feat(export): preserve link content when navigation is unavailable"), parent
`246283110e9cdfeaad8a1d616fca46413af47510` (Stage A delivery), 10 paths,
+685/−331. Every committed blob's SHA256 and the baseline-to-HEAD diff SHA256
(`9f39046c…6b934`) equal the validated candidate receipt values, so delivery is
byte-identical and no test was re-run. Ordinary worktree/index clean. No tag,
version, release or publication action. Receipt:
`memory/link-navigation-fallback-inputs.json`, revision `final-committed`.

## Adopted scope and principle

org-texmacs lowers Org link expression into a TeXmacs structural document; it
does not validate whether a source document's link relations resolve.

- When a supported navigation action can be constructed, keep the existing
  navigation lowering.
- When it cannot, keep the link's visible content instead of aborting.

Two implementation nodes formed one user-visible feature (not two features):

- **B1** common visible-content fallback (`link-text`).
- **B2** navigation-unavailable resolution (consumes standard query results,
  relaxes independent-input target selection).

Explicitly deferred, not adopted: relaxing native file-target character
restrictions, a full TeXmacs-URL-syntax ↔ arbitrary-filename study,
consumer-specific native navigation fallback, worker/renderer/GoToR changes,
stable cross-document anchor identity, PDF named destinations and
precise-position GoToR actions. Stage C (precise cross-document navigation)
remains a separate deferred candidate.

## Visible-content lowering (B1)

New `link-text` in `lisp/org-texmacs-document.el`:

- Description present: reuse the existing recursive inline lowering for the
  link's contents, with the enclosing whitespace state; description internals
  keep their own structure and provenance (STM paths, nested link targets).
- No description: use the Org element's `:raw-link` value through ordinary
  prose text lowering.
- The link's post-blank is preserved via the usual `blank` helper.
- The fallback emits no outer `hlink`, `reference`, `label`, or file-target
  provenance for that link.
- `:raw-link` is Org's parser value, which may already reflect abbreviation
  expansion and escaping; it is not a byte-exact reconstruction of source
  syntax and is never re-derived from `type:path`.

Constant renamed `org-texmacs--supported-link-types` →
`org-texmacs--supported-uri-link-types`, because it only enumerates link types
whose self-contained URI target this exporter can construct directly; it is
not the set of all exportable Org link types.

B1's temporary "known navigation type" restriction was removed in B2; the final
contract is not restricted to known types. Do not cite the B1 intermediate
contract as current behavior.

`org-texmacs--document-resolve` now resolves "availability" instead of
validating link relations: the internal `choose` helper returns a unique
candidate or nil (no more unresolved/ambiguous errors); a target is recorded
only when it is in the rendered `order` and is not a bare reference to an
uncaptioned table.

Inline lowering dispatches to `link-text` when the link has no usable target
and is not a directly supported URI type; file links in title/metadata also
fall back (previously an error).

## Standard Org query snapshot (B2)

`lisp/org-texmacs-query.el` adds the private field `:unavailable-links`,
holding owned link identities that standard query processing did not resolve to
a usable navigation target. It is a result set, not a pending work queue.
`:targets` and `:external-files` keep their Stage A meaning.

For `id`, `custom-id` and `fuzzy` links the resolver call is wrapped in
`(condition-case nil … (org-link-broken nil))` only: Org's explicit
broken-link signal becomes unavailable, while other errors still propagate
(no generic `error` swallowing). When `org-texmacs--query-external-id-path`
cannot supply a usable external target (unsupported path shape, unknown
relative base, same-file target) the link is recorded as unavailable rather
than failing preparation.

Ownership and identity remapping are unchanged: the new list of owned link
nodes is copied and remapped by the existing `org-texmacs--model-copy-data`
mechanism (`lisp/org-texmacs-input.el` docstring updated accordingly).

Frozen-mapping validation in `org-texmacs--document-resolve` now covers all
three lists at once: `:targets` entries must be reachable links of type
`id`/`custom-id`/`fuzzy` with a real element value; `:external-files` entries
must be reachable `id` links with a local-file path value; `:unavailable-links`
must be reachable `id`/`custom-id`/`fuzzy` links; keys must be unique across all
three lists, so conflicting or duplicate associations fail. A missing frozen
result for a resolved kind (target/external) is still an internal contract
error ("Missing frozen Org target"), not a normal unavailable result.

## Document resolution and target selection (B2)

- Standard export consumes Org's already-selected target and imposes no
  independent uniqueness requirement.
- Independent pure input keeps local resolution over the owned AST with fixed
  context and falls back to visible content when no single usable target
  exists.

Fallback now covers: unresolved ID/CUSTOM_ID/fuzzy links; ambiguous internal
targets in independent input; independent ID links without external resolution
context; targets outside the effective rendered structure; same-file excluded
IDs; the current file's file-level ID; external ID resolutions that yield no
usable path; unsupported file search options, application hints, remote and
tilde paths; relative file links without a resource base; title/metadata file
navigation; and bare references to uncaptioned tables. A described reference to
an uncaptioned named table keeps its existing invisible-anchor navigation (no
invented table number).

Structural validation is not weakened: repeated NAME declarations, malformed
captions, unsupported blocks and other invalid document structures still fail.

## Stage A contract preserved

Cross-file ID resolution still uses Org's standard transaction, the captured
ID-resolution base, captured source identity/resource base, relative spelling
preservation with absolute rebasing when bases differ, the owned
`:external-files` mapping, ordinary file-link lowering/provenance, and the
captured `.org`→`.pdf` and PDF relative/absolute policies. Same-file and
current-file file-level IDs no longer produce self-file navigation; they fall
back. The existence-heuristic for path bases was not reintroduced. Independent
input still never queries the ambient Org ID database; repeated lowering does
not re-run the standard resolver or start a worker to discover targets.
Successful external IDs still provide document-level navigation only.

## Org and native boundaries

Unchanged: Org parser, link type registration, Org link following, Org's
resolver implementation, other export backends, the original Org AST/model
round-trip, native file-target adaptation, and the GoToR patch. For the TeXmacs
backend, recognized broken-link resolution uses this project's visible-content
fallback regardless of `org-export-with-broken-links` (nil/t/mark); that
option's global behavior for other backends is untouched.

Native file-target character restrictions remain: the fallback covers Org →
TeXmacs structural lowering and does not guarantee that every legal file path
survives native encoding and navigation adaptation. "All Org links always
export to PDF" is not claimed.

## Changed paths (final candidate, 10)

```text
lisp/org-texmacs-document.el        +304/-…  link-text, availability resolution, mapping validation
lisp/org-texmacs-query.el           unavailable-links, org-link-broken capture, nil-able external path
lisp/org-texmacs-input.el           docstring: frozen unavailable identities
tests/ert-core/lisp/document.el     +3 tests (visible content, unavailable content, frozen mapping)
tests/ert-core/lisp/standard-export.el  new/renamed standard-export fallback tests
tests/ert-native/lisp/document.el   renames + new excluded-CUSTOM_ID/table-reference fallback
tests/ert-native/lisp/frontend.el   file-link fallback expectations, raw-link fixtures
tests/ert-native/lisp/special-blocks.el  ambiguity/dedicated-target fallback, STM opacity
README.org                          fallback contract, preserved native restrictions
CHANGELOG.org                       unreleased Added entry beside the Stage A entry
```

Total: 10 files, 685 insertions, 331 deletions (against baseline `2462831`).

## Implementation history

1. B1 established the common visible-content fallback; user-local build and
   tests passed.
2. Original B2 added navigation-unavailable resolution and updated the main
   regression tests.
3. First B2 core acceptance had one failure:
   `org-texmacs-document-pure-input-ignores-id-database` still expected an
   export error.
4. That test was revised to the visible-content contract and strengthened with
   `cl-letf` assertions that neither `org-id-find`, `org-id-find-id-file` nor
   `org-export-resolve-id-link` is called; it also asserts no hlink/reference
   and no file provenance.
5. Native acceptance then had one failure:
   `org-texmacs-document-ambiguous-and-unresolved-id-fallback`, because the
   fixture conflated a pure-input missing CUSTOM_ID with a standard-export
   excluded CUSTOM_ID.
6. The fixture was split: the pure-input case uses an AST that genuinely lacks
   the target node; the excluded CUSTOM_ID case goes through
   `org-texmacs-document-from-buffer` with `#+EXCLUDE_TAGS`
   (`org-texmacs-document-excluded-custom-id-fallback`).
7. A standalone follow-up test patch could not be applied to the user's
   worktree; a complete revised B2 based on the user's B1 diff was delivered
   with both test revisions integrated.
8. User confirmed build and tests pass after applying B1 plus the complete
   revised B2.

Neither test revision changed the production fallback contract.

## Validation evidence

Agent-executed against the exact candidate content (index == worktree):

```sh
nix flake check -L --no-write-lock-file --max-jobs 2     # exit 0, all checks passed
```

| Check | Result |
|---|---|
| `ert-core` | 346/346 |
| `ert-native` | 285/285 |
| `ert-pdf-document` | 48/48 |
| `ert-pdf-render` | 30/30 |
| `ert-cite` | 11/11 |
| `caption-inline-footnotes` | 6/6 |
| `package-lint` | built/pass |
| `treefmt` | built/pass |
| `texmacs-with-gotor-support` | maintained GoToR renderer regression pass |

Environment: Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5 (baseline and patched),
Python/pypdf inspector. Core grew 341→346 and native 283→285, consistent with
the new tests (+3 core in `document.el`, +2 core in `standard-export.el`,
+2 native).

Stage B does not touch the renderer or native target adaptation, so no new
GoToR/named-destination experiment was required; the maintained renderer
regression passing inside the full flake check is the applicable evidence.
Stage A's isolated patched external-ID GoToR probe remains valid evidence for
the unchanged ID path and was not re-run for Stage B.

## Maintained regression coverage

Core (`tests/ert-core`):

- `org-texmacs-document-unsupported-link-visible-content`
- `org-texmacs-document-unavailable-link-content`
- `org-texmacs-document-validates-frozen-unavailable-links`
- `org-texmacs-document-pure-input-ignores-id-database` (revised)
- `org-texmacs-standard-export-unsupported-link-visible-content`
- `org-texmacs-standard-export-unavailable-internal-links`
- `org-texmacs-standard-export-unresolved-id-fallback` (renamed)
- `org-texmacs-standard-export-same-file-id-fallback` (renamed)
- `org-texmacs-standard-export-file-level-self-id-fallback` (renamed)
- `org-texmacs-query-external-id-path-unavailable-base` (renamed)
- Stage A suites otherwise unchanged: external file/headline resolution,
  identity preservation, frozen snapshot, subtree/INCLUDE, alt/hook/late base
  change, model round-trip.

Native (`tests/ert-native`):

- `org-texmacs-document-ambiguous-and-unresolved-id-fallback` (revised fixture)
- `org-texmacs-document-excluded-custom-id-fallback` (new, standard export)
- `org-texmacs-document-unavailable-reference-with-island` (renamed; island
  still lowered, no hlink)
- `org-texmacs-document-unavailable-table-reference-fallback` (new)
- `org-texmacs-document-named-table-rejects-before-worker` (now only
  structurally illegal fixtures)
- `tests/ert-native/lisp/frontend.el`: missing-resource-base and
  title-link cases now assert fallback text and empty file provenance.
- `tests/ert-native/lisp/special-blocks.el`: ambiguous/dedicated-target
  fixtures assert fallback text, no reference/hlink, unchanged labels, and STM
  opacity.

Existing internal/URI/file navigation, session readback, buffer-state
restoration and worker lifecycle tests keep their original expectations.

## Verification boundaries

- Unverified: other platforms, other Org/TeXmacs versions, GUI reader
  behavior, and native encoding of file paths containing restricted
  characters (still explicitly unsupported).
- The fallback preserves `:raw-link` as parsed; Org parser normalization is not
  replicated or reversed.
- User-reported local success is recorded; the agent's own full flake run
  above independently confirms the same content.

## Retention assessment

User-supplied review material for this round: one B1 diff
(`tmp/2026-11-12T23:36:26+08:00.diff`, 5 paths: CHANGELOG.org, README.org,
`lisp/org-texmacs-document.el`, `tests/ert-core/lisp/document.el`,
`tests/ert-core/lisp/standard-export.el`). The B2 patch and the standalone
follow-up test patch are not present in the worktree, so no byte-exact
capture is claimed for them.

Retention decision: no archive snapshot. The effective B1 content and the
revised B2 content are fully preserved by the staged ordinary candidate (whose
content hashes are in `memory/link-navigation-fallback-inputs.json`), by the
maintained tests that express the regressions, and by this record, which keeps
the design reasons, the discarded alternatives and the two test revisions.
Losing the historical diffs would not impair interpretation, reproduction or
handoff. The B1 diff remains an ignored `tmp/` artifact; no byte-exactness
claim is made for material not read in full.

## Next

Stage B delivery verification is complete. Stage C (precise cross-document
ID navigation) and the deferred native file-target character work remain
separate and unadopted; no release-state, version, tag, push or publication
action follows automatically.
