# INCLUDE snapshot and semantic-view architecture review

## Scope and source

User stashes the documentation package, then supplies a detailed proposal for
read-only review: separate source acquisition, inclusion interpretation, native
Org expansion, restoration/validation and existing AST conversion. No project
implementation, stash application, test, evaluation or build is authorized.

Project worktree and index are clean. The current gitignore-anchoring HEAD
matches the commit cited in the supplied proposal; its parent is the previously
reviewed README delivery and its complete change is root-anchored ignore rules.
Latest stash labelled [wip] docs has21paths and is based on that HEAD. Read-only
inspection confirms docs source, explicit docs wiring and package driver remain
there, including14wrapped INCLUDE directives. Do not apply/drop/pop it implicitly.
Unrelated older stash was not inspected beyond its listing description.

Proposal is user chat, not an inspected local design file. Distilled requirements,
findings and examples below suffice; original bytes have no independent archival
need. This is review, not adoption of the entire proposal or implementation plan.

## Verified diagnosis and supported direction

In lisp/org-texmacs-preprocess.el, capture currently acquires and validates
UTF-8 bytes, then always enters an Org view, discovers/shields STM and caches
original/protected text plus source spans. The parser wrapper rejects :env and
:block before expansion. selection always validates cached STM spans against
native line ranges. Thus removing the parameter guard alone leaves a real
semantic-context mismatch for literal files, not merely missing syntax support.

The proposal correctly separates immutable raw snapshots from interpretation:
one source can supply ordinary Org and literal code without rereads or sharing
the wrong protected representation. Literal src/example/export bodies should
not trigger STM discovery. Final supported AST mapping remains separate from
input acquisition; unsupported resulting nodes may fail in lowering. Delegation
to Org does not adopt Babel, macro, SETUPFILE/BIND or full generic export.

The supplied src parse field table agrees with published Org9.8.10 source:
:env literal, :block src, :args language. Plain source blocks already have a
static target mapping; no language-specific Emacs Lisp converter is needed.
No installed/pinned Org runtime was inspected or evaluated for this review.

## Corrections required before an implementation specification

1. Native expansion branches differ. Published Org9.8.10
   org-export--blindly-expand-include has a literal branch (prepare selected
   lines, escape code, wrap), a nonliteral block branch (prepare lines, wrap),
   and a plain Org branch (location/only-contents resolution, heading/footnote/
   link processing and recursive INCLUDE). Arbitrary block wrapping does not
   itself recursively expand nested INCLUDE or apply every Org-content option.
   Mode-aware handling must preserve this difference instead of promising a
   uniform expansion feature set. An inner INCLUDE in a supported statement
   wrapper is a boundary to specify/test, not automatically supported.

2. Raw native-body inclusion needs its own view, not an ordinary Org protected
   view. Existing native-body-kind recognizes AST nodes, while INCLUDE initially
   supplies a block name; reuse the classification coherently without parsing
   raw STM as Org just to construct that classification. Protect the actual
   opaque selected body before any relevant transformation, do not run fragment/
   heading/footnote logic inside it. Preserve native block-end grammar and avoid
   turning whole-file protection into rejection of all partial line selections.

3. Parameter parsing should acquire raw data only, not generate a view before
   the include's mode is active. A dynamic wrapper around blindly-expand-include
   is a plausible boundary because it receives parsed parameters and encloses
   the native readers. Scope must nest and restore on every return/error; reader,
   location and preparation functions must agree on the selected view. Add the
   new private helper to function identity guards and restoration tests, and
   check compatibility rather than assume its API across Org versions.

4. Specify snapshot keys and budgets. Preserve normalized path identity and
   physical-alias rejection; do not deduplicate distinct hardlink/symlink paths
   into newly accepted source identities. Source-byte budgets belong to unique
   snapshots; occurrence/depth budgets belong to actual expansion, including
   repeated/mixed-mode uses. Cached view hits must not bypass limits. Views
   depending on selection/context need that context or a transient scoped view,
   not an underspecified file-only cache.

5. Encoding and residue constraints remain separate. Existing fixed UTF-8
   decoding cannot acquire arbitrary :coding-system semantics just by allowing
   the field; BOM/newline/alias behavior needs a defined contract. It is reasonable
   to retain the current encoding rejection in this refactor. Keep :unmatched
   rejection; do not bundle all valid Org header arguments into target support.

## Verification additions to the user's proposed matrix

Existing proposed cases are useful: literal src/example without execution;
STM-like text as inert source; literal partial-line selection; ordinary Org
location/only-contents/lines/minlevel controls; same-file mixed-mode reuse; raw
native-body opacity; unchanged paths/encoding/budgets/mutation/hooks/rollback;
and restored document rendering. Add explicitly:

- Same file literal-first and Org-first, repeated/interleaved reads, one raw
  acquisition, plus unchanged physical-alias rejection.
- Literal contents with nested #+INCLUDE, #+end_src/#+end_example, source commas,
  headline/footnote-like text and malformed STM; compare Org's native escaped
  result rather than demand byte equality where native whitespace rules apply.
- A wrapper branch containing another INCLUDE, to pin native recursion policy;
  unknown/export target blocks must fail at the intended target boundary.
- Native-body wrapper line selection, apparent Org directives/multiline STM
  strings and closing delimiters; no textual reconstruction of invalid grammar.
- Restoration and identity/mutation guards for the new helper on nested success
  and failure, and unchanged expansion/byte limits for mixed modes.
- Rebuild the originally failed en/figures-tables and Chinese counterpart, plus
  guides exercising nested includes and literal references.org. User's initial
  shown failing leaf was English, not Chinese. This is future verification,
  not an authorized test task. Avoid deleting maintained assertions merely to
  weaken the old negative test; migrate supported cases to meaningful positives.

## Review conclusion and provenance

Agree with the architectural direction; correct native branch semantics and
define native-body/view-cache scopes before treating it as an executable plan.
Do not patch a single src-language allowlist, automatically adopt all wrappers,
restore docs, or broaden unrelated Org features. Source locators:
lisp/org-texmacs-preprocess.el (capture/protect/selection/native wrappers),
lisp/org-texmacs-source.el (native-body-kind),
lisp/org-texmacs-document.el (preformatted mapping), tests/ert-core/lisp/preprocess.el,
tests/ert-native/lisp/preprocess.el and the user's docs stash.
Primary Org reference, release9.8.10 (static comparison, not current runtime proof):
https://github.com/bzg/org-mode/blob/release_9.8.10/lisp/ox.el
