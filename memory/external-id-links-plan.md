# Cross-file Org ID link support — Stage A intake plan

## Baseline

Verified at intake (read-only review):

- Ordinary project main HEAD: `f16cc2f8131a7514754886119210099ad5fd943d`
  ("docs(changelog): finalize v0.7.0 release notes").
- GAW `_agents` HEAD: `ece428baed1539ce3d568783fd2a09c794b2dc48`.
- Ordinary branch `main`, index clean. Worktree has one uncommitted change:
  `CHANGELOG.org` adds `* TODO *unreleased*` immediately above the already
  DONE/CLOSED `v0.7.0` node. This matches the guide's unreleased-node convention
  and is not a v0.7.0 rewrite.
- GAW worktree `git gaw check` passes; selector `refs/heads/_agents`.

Re-check all of the above before implementation if the session continues from
fresh state.

## Adopted scope

User selects Stage A only: consume the file target that Org's standard export
resolution (`org-export-resolve-id-link`) returns for a cross-file `id:` link,
lower it to a document-level file link, and reuse existing file resolution,
file provenance and native file-link policies. Stage B (unsupported-link text
fallback) and Stage C / precise cross-document ID navigation are separate and
are not adopted here.

Org ID links keep their object-level identity. Stage A only adds the current
document-level lowering boundary:

```text
Org link AST            => still an id link (:type "id", :path original ID)
Prepared resolution     => original source-file target (frozen string)
Structural document     => hlink to the original source-file target
Native output           => consumer-specific file target (.org/.pdf, rel/abs)
```

The original ID must remain in the owned Org link AST; the link node must not
be rewritten to type `"file"` or have its `:path` replaced by the resolved path.
No target/anchor structure (`:file`/`:anchor`/`:target-kind`) is introduced now.

## Verified current-code contract (read-only review)

Reviewed the relevant runtime paths against the guide. Key facts:

1. `lisp/org-texmacs-query.el` `org-texmacs--query-snapshot`: the `'link` case
   (lines ~143-165) already calls `org-export-resolve-id-link` for `"id"` and
   `"custom-id"` and only accepts a result that maps through `identities` to a
   reachable AST node; otherwise `org-texmacs--prepared-fail`. This is exactly
   the internal-only branch the guide describes. It returns
   `:targets/:footnotes/:headlines/:table-alignments/:references`; a new
   `:external-files` field must be added here, keyed by the owned link node,
   value a copied string.

2. `lisp/org-texmacs-export.el` `org-texmacs--standard-input` builds the query
   snapshot and passes it through `:texmacs-org-query` in the projected INFO.
   It does not currently pass `source-file`/`resource-base` to the snapshot;
   both are available in the captured `state` (indices 5 and 6). Minimal
   captured source state must be threaded in for same-file detection and path
   interpretation.

3. `lisp/org-texmacs-input.el` `org-texmacs--input-own`: the whole
   `:texmacs-org-query` plist flows through `org-texmacs--model-copy-data`,
   which remaps known AST node identities via the owner node table. A new
   `:external-files` alist of `(owned-link . "path")` is therefore owned and
   remapped by the existing mechanism; no dedicated copy path is required.

4. `lisp/org-texmacs-document.el` `org-texmacs--document-resolve`: the link
   dispatch (around lines 842-905) consumes `query :targets` for `"id"` and
   fails "Missing frozen Org target" otherwise. The external branch must
   consume `query :external-files` and push into the `files` list using the
   same `org-texmacs--document-local-file-path-p` / resource-base validation as
   `"file"` links. External targets must not enter `resolved`/`:targets`.

5. Inline lowering (`org-texmacs--document-lower` link case, around lines
   2216-2293) already keys off `(assq node (org-texmacs-resolution-files ...))`
   and produces `(hlink body file)` plus `file-paths` provenance. An external
   ID target that lands in `files` will reuse this unchanged; the link-admission
   guard `(or reference file (member type org-texmacs--supported-link-types))`
   already passes once `file` is non-nil. No ID-specific lowering branch is
   needed.

6. Native output (`lisp/org-texmacs-session.el` `org-texmacs--native-file-target`
   / `org-texmacs--native-document-wire`) consumes `file-paths` provenance only,
   so external ID targets flow through the existing `.org`→`.pdf` and
   relative/absolute policies without change.

7. `org-texmacs--supported-link-types` is a self-contained URI set; `"id"` must
   not be added (it is a reference requiring resolution, not a self-contained
   URI). No rename in Stage A.

## Org 9.8.10 resolver facts (path base — critical)

Inspected the pinned Org source
(`/nix/store/.../emacs-org-9.8.10/share/emacs/site-lisp/elpa/org-9.8.10`):

- `org-export-resolve-id-link` returns, in order: an internal headline in the
  current parse tree, then `(cdr (assoc id (plist-get info :id-alist)))`, then
  `(org-id-find-id-file id)`.
- `:id-alist` is built in `org-export--collect-tree-properties` as
  `(cons id (file-relative-name (car (org-id-find id))))`, i.e. **relative to
  `default-directory`** of the buffer running the export.
- The final fallback `org-id-find-id-file` returns the stored location value,
  which `org-id-update-id-locations` produces as `(abbreviate-file-name file)`
  over `file-truename` results: **absolute, possibly `~`-abbreviated, and with
  symlinks resolved** (truename).
- org-texmacs captures `resource-base` as the source buffer's `default-directory`
  (`org-texmacs--standard-source-state` index 6), i.e. the same base
  `file-relative-name` uses in the normal flow. So in the common case the
  resolver's relative path is relative to captured resource-base.

Consequences the implementation must handle, and which still need a runtime
probe before being treated as proven:

- The resolver can return a **relative** path (from `:id-alist`) or an
  **absolute** path (fallback). Both forms must be accepted.
- A `~`-prefixed absolute path is rejected by
  `org-texmacs--document-local-file-path-p`; live preparation must expand a
  leading `~` once (as `org-texmacs--source-capture-path` already does) before
  freezing, without changing the spelling of ordinary relative/absolute paths.
- The `file-relative-name` base assumption must be confirmed empirically across
  at least: a normal visiting Org buffer, non-default `default-directory`, an
  explicit source-buffer API call from another buffer, subtree export, an
  INCLUDE-introduced link, and the fact that `org-export-with-buffer-copy`
  (via `org-element-copy-buffer`) preserves `default-directory` in the copy.
- Same-file comparison must use a consistent absolute base. The captured
  `source-file` is `buffer-file-name` (not a truename), while the ID location
  stores a truename, so symlink/alias identity needs `file-truename` or
  `file-equal-p` in live preparation. Comparison-only normalization must not
  rewrite the frozen target spelling.

## Conservative error boundaries

- Current-source-file targets that are not in the effective exported AST
  (`noexport`, subtree/region/narrowing exclusion) must remain errors, not
  become self-file links. Current-file file-level ID is also unsupported
  (no document-root anchor contract).
- Unresolved IDs remain errors; never fall back to description/raw-ID/`id:` URI
  or scan the user knowledge base.
- Only `"id"` links accept a filename result; `"fuzzy"`/`"custom-id"` keep their
  existing internal-only behavior.
- Independent pure input (`org-texmacs-input-create`) must not discover external
  ID locations; a private frozen `:external-files` mapping may be tested for
  ownership/consumption but is not a public API.

## Ownership and validation invariants

- One ID link never maps to both an internal target and an external file.
- `:external-files` keys are valid owned link nodes; values are copied strings.
- External targets do not participate in `org-export-get-reference` / label
  allocation.
- Repeated lowering never re-queries Org, the ID database, a source buffer, or
  a worker.
- Existing file-target validation (`org-texmacs--document-local-file-path-p`,
  resource-base requirement, title/metadata restriction, provenance) is reused,
  not bypassed.

## Exclusions (not adopted)

Unsupported-link fallback; URI whitelist renaming; new ID-specific Custom
variables; cross-document stable STM label protocol; native `.tm` anchor
navigation; stable PDF named destinations; GoToR remote named destinations;
current-file file-level root anchor; automatic ID database creation/scan/repair;
automatic target-document export or dependency graph; org-roam-specific logic;
ordinary file-link refactor; native session/file-link policy redesign; worker
protocol change; GoToR patch extension; `.org.gpg` suffix extension; general
output relocation/path policy redesign; next version number / freeze / tag /
publication decisions.

## Pending verification before implementation (A1)

1. Runtime probe of the resolver path base across the scenarios above; confirm
   relative-vs-absolute forms and the `default-directory`/resource-base equality.
2. Same-file detection under symlink alias and truename differences.
3. `~`-abbreviation behavior of the fallback path.
4. Existing `org-texmacs-document-rejects-ambiguous-and-external-id-links` is
   driven by `org-texmacs-parse-buffer` (independent model), so its external-ID
   case is the independent pure-input rejection; keep/rename it, do not delete,
   and cover true standard-resolution success in a new integration test.

## Notes

- `tests/ert-native/lisp/document.el:746`
  `org-texmacs-document-rejects-ambiguous-and-external-id-links` mixes
  ambiguous fuzzy, independent external ID, and excluded CUSTOM_ID; split or
  rename so the independent-input "missing frozen external target" contract
  stays covered without claiming standard external IDs are rejected.
