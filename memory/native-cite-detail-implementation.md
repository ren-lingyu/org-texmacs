# Native single-reference citation detail — implementation record

## Status

Delivered as ordinary commit `1c0eae02187e668199a00cd58aa62cc32f46e5bb`
("feat(cite): support native single-reference citation details"), parent
`f1b132b1f545dd394b65fef8ab824f22beb40290` (Stage B delivery). 11 paths,
+244/−100. Ordinary worktree/index clean at verification. No version, tag,
release or publication action. Receipt: `memory/native-cite-detail-inputs.json`.

This is an independent feature increment; it does not reopen the Stage A/B
link-navigation work or the finalized v0.7.0 release.

## Goal and motivation

Legal Org Cite input such as

```org
[cite:@key, chapter 1]
[cite:@key p. 7]
```

previously failed at native request validation with
`Unsupported native citation reference or locator`, because the original
contract deliberately rejected any nonempty citation-reference suffix.

TeXmacs already provides a native `cite-detail` macro, so the additional
reference information is expressed with that structure instead of a custom
macro, string concatenation or a home-grown citation renderer:

```scheme
(with-bib
 "org-texmacs-bib-1"
 (cite-detail "key" "chapter 1"))
```

`with-bib` and the existing label namespace are reused unchanged.

## Adopted scope

- Single-key default-style citations with a plain-text reference suffix.
- Bounded normalization: trim surrounding whitespace, drop one optional
  leading comma (TeXmacs' `render-cite-detail` supplies citation punctuation),
  reject empty or multiline results.
- Bare single-key and bare multi-key citations keep their previous `cite`
  structure.
- Existing `plain`, `alpha`, `abbrv` bibliography-style selection unchanged.

This is a mapping from a plain-text reference suffix to native citation detail,
not full CSL locator support: no locator-term parsing, no page inference, no
localization.

## Deliberately unsupported (not unfinished acceptance items)

- Multi-key citations carrying details.
- Reference prefixes; global citation prefix/suffix.
- Rich suffixes containing Org markup or other structured objects.
- Non-default Org Cite citation styles.
- Grouping/separator/parenthesis semantics for several detailed references.
- Any modification of citation-processor behavior (CSL locator terms etc.).

Rationale for refusing multi-key detail: TeXmacs' native interface is a
single-key detail; qualifying several references in one group needs a separate
adopted grouping and layout contract, which does not exist.

## Architecture

Two citation-plan construction paths already exist; both are input
construction for one document-lowering core, not two Org export pipelines:

1. **Standard Org Export**: Org Cite calls the `texmacs-native` processor, which
   records a request against its citation carrier identity;
   `org-texmacs--cite-view` then builds usage from those requests.
2. **Independent input**: a caller supplies an owned Org AST, INFO and native
   bibliography data; `org-texmacs--bibliography-collect` collects the citation
   usage actually lowered.

This change unifies only the interpretation and validation of one citation
group; it does not reintroduce source-side citation discovery, re-run Org Cite
or copy Org export preparation.

### Shared citation-group contract

`org-texmacs--cite-group` (in `lisp/org-texmacs-cite.el`) is now the single
validator for both paths. It returns an owned plist

```elisp
(:keys ("one") :detail "chapter 1")
```

with `:detail` nil for a bare group. `org-texmacs--cite-detail` performs the
normalization above and is the only producer of detail text. The native
processor records `(append (list :kind 'citation) group)`, so the request
carries `:kind :keys :detail`; `org-texmacs--document-resolve`'s
`org-texmacs--bibliography-collect` consumes the same helper for the
independent AST, replacing its previous private key-only validation and its
local `affix-empty` helper (now `org-texmacs--cite-affix-empty-p`).

Request consistency validation now compares both keys and detail against the
carrier node, so a stale request with a mismatching `:detail` fails
(`"Stale native citation request"`), as does a request that omits the field
(`org-texmacs--cite-request-p` requires exactly `(:kind :keys :detail)`).

### Ownership and invariants

- Org owns standard preparation, processor selection and bibliography
  acquisition; the standard path only consumes supplied carriers/requests.
- The independent path uses only explicitly supplied AST and dependency data.
- Requests and plans are owned input; `:detail` strings are copied
  (`substring-no-properties`) and normalization produces fresh text, so mutating
  the caller's string cannot change an already constructed input (covered by a
  test that overwrites the request detail and re-lowers).
- Bibliography entry selection stays key-based; `:detail` never participates in
  deduplication, entry selection or label allocation.
- Lowering does not read source files, run native formatting or start a worker.

### Native lowering

In `lisp/org-texmacs-document.el` the citation branch of lowering now reads the
per-node group from the plan:

- `:detail` nil → `(with-bib PREFIX (cite KEY...))`, unchanged structure.
- `:detail` non-nil → `(with-bib PREFIX (cite-detail KEY DETAIL))`.

Native bibliography reference validation gained a `cite-detail` case: its label
argument must exist in the generated label set at the current prefix, mirroring
the `cite` case, so an unresolved detailed reference is rejected rather than
producing a dangling native link.

## Validation

Agent-executed on the delivered content (worktree == commit, clean):

```sh
nix flake check -L --no-write-lock-file --max-jobs 2    # exit 0, all checks passed
```

| Check | Result |
|---|---|
| `ert-core` | 347/347 (was 346) |
| `ert-native` | 285/285 |
| `ert-pdf-document` | 48/48 |
| `ert-pdf-render` | **31/31** (was 30; +1 detail/reload test) |
| `ert-cite` | 11/11 |
| `caption-inline-footnotes` | 6/6 |
| `package-lint` | pass |
| `treefmt` | pass |
| `texmacs-with-gotor-support` | maintained GoToR regression pass |
| `org-texmacs-examples` | builds; both `en/index.pdf` and `zh/index.pdf` contain the new "chapter 1" detail text |

Environment: Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5 (baseline and patched).
The user separately reported that applying the patch passed their local tests;
the numbers above are the agent's own run.

## Maintained regression coverage

- `tests/ert-core/lisp/native-cite.el`
  - `org-texmacs-native-cite-single-reference-detail`: `[cite:@one, chapter 1]`
    and `[cite:@one p. 7]` yield `cite-detail` with the normalized detail,
    bare `[cite:@two; @one]` stays `cite`, two bibliography labels remain, and
    mutating the request's detail string does not change a re-lowered body.
  - `org-texmacs-native-cite-unsupported-requests`: nonempty prefix, citation
    style, rich (`/chapter/`) suffix, multi-key details on either side, a
    non-reference group member, and a bare trailing comma all still fail.
  - `org-texmacs-native-cite-carrier-errors`: added the `stale-detail` fault.
- `tests/ert-core/lisp/bibliography.el`: an unresolved `cite-detail` label is
  rejected alongside `cite`/`reference` during native bibliography validation.
- `tests/ert-native/lisp/native-cite.el`: real native styles (`plain`, `alpha`,
  `abbrv`, `tm-alpha`) lower `cite-detail`, keeping existing math/label checks.
- `tests/ert-pdf/lisp/pdf.el`
  - existing native-group test now also asserts the rendered
    `[1, chapter 1]` detail;
  - new `org-texmacs-pdf-native-citation-detail-and-reload` covers all three
    styles: the bare and detailed citations share one bibliography label, both
    link to the entry page, the saved `.tm` reload produces identical PDF text,
    and no `[?]`/`[cite:` leakage appears.
- Unchanged coverage continues to assert bare single/multi-key citations,
  bibliography label allocation and `with-bib` structure.

## Examples and docs

`README.org` gains the detail contract (native `cite-detail`, normalization,
explicit unsupported list) and updates the support table plus
"bare default citation" wording elsewhere. `CHANGELOG.org` adds an unreleased
`Added` entry beside the Stage A/B entries. Both EN and ZH example bibliography
chapters add one detailed citation, verified by the examples build.

## Limits

- No CSL locator semantics; the detail is opaque plain text for TeXmacs.
- Only one qualifying reference per group, only the default citation style.
- Other platforms, other Org/TeXmacs versions and non-default styles remain
  unverified as before.
