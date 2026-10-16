# Phase 3b bibliography discovery/acquisition contract

Selected by the user's review/execute request for INBOX section 13. Nodes A/B/C
are implemented and fully validated, with independent checkpoints.
Issue12 now replaces the old raw BibTeX grammar/pre-parse signature contract
with native AST authority;107focused/464fullERT/9fixed extension/full flake
checks pass; exact user-committed delivery verified and Issue12 closed/completed.
Current implementation/evidence: memory/issue-12-review.md.
Public wrappers are
`org-texmacs-document-from-buffer-discover-bibliography` and
`org-texmacs-export-from-buffer-discover-bibliography`, in an independent module.
Phase 1's filter contract and old explicit API defaults remain unchanged.

## Preferred strategy and unavoidable preparation change

Prefer a separate opt-in source adapter that performs one synchronous conversion
transaction. Keep existing bibliography-sources signatures/defaults stable. An
interactive frontend may adopt that adapter later under its own policy; do not
silently enable discovery in every existing source API or dispatcher action.

The existing texts parameter is insufficient for global/advice-only sources:
the original explicit API creates declaration identities from document keywords,
and the planner ignores supplied sources not selected by that view. The new adapter
must provide an explicit owned effective declaration view at preparation's context
boundary, before Phase 1 filters/owning/planning. Preserve raw document keyword
associations and add discovered dependency identities. Do not synthesize Org text,
rebind collectors, monkey-patch preparation, invoke a generic exporter, or pretend
the existing API already supports this behavior. The pure planner accepts such
explicit data already; no new input slot or pure-layer I/O is required.

## Initial admissible source/discovery context

- Local Org source, visiting or non-file. Canonical text is the live buffer snapshot,
  including unsaved edits; do not reload the Org file from disk.
- Capture text/tick/mode, source-file identity, effective resource-base, selection,
  supported parser/context settings, filter function identities, explicit texts and
  global bibliography values before user advice or acquisition. Own strings/lists;
  mutable closure/DB internals are outside the consistency promise.
- Initial scope rejects a visiting-file directory/resource-base mismatch
  rather than silently changing existing explicit identity semantics. Native Cite
  uses visiting file directory for document declarations while existing explicit
  snapshots use resource-base. Supporting the conflict needs a later deliberate
  bibliography-origin policy; linked-resource base never changes as a side effect.
- Use one private full-source discovery view with copied supported settings and
  copied org-cite-global-bibliography. Retain local source identity where admissible;
  non-file buffers use their captured base. Do not expose source aliases to callbacks.
- Native collection widens scope. Therefore mask all authored STM inline/block
  islands in the complete discovery view, even outside selected body/narrowing.
  Reuse validated discovery/mask helpers with character offsets retained; original
  STM and canonical text still feed the unchanged conversion path. This masking is
  only a bibliography view, not general source composition/preprocessing support.
- Reject real SETUPFILE/INCLUDE/BIND/MACRO/CITE_EXPORT through the existing restricted
  context before native discovery. Disable BIND before Org export copy machinery
  can collect variables. STM-looking directives remain literal and cannot cause
  package discovery reads. Do not globally replace org-collect-keywords.
- Call org-cite-list-bibliography-files exactly once per transaction, with normal
  standard advice on that interface. No options filters, preprocessing hooks,
  full annotation, generic transcoders or Cite output processors. Advice remains
  arbitrary user code, not sandboxed; real managed-package context is unverified.

## Identities and explicit-source merge

- Native order is document declarations then globals with raw-string dedup; advice
  can change order/add duplicates. Do not infer provenance for each flat returned
  path or assume discovery has already made all paths absolute.
- Own the returned path values immediately. Normalize accepted local paths once
  against captured discovery base, then deduplicate lexical absolute identities
  preserving first occurrence. Relative advice paths must follow native context's
  base convention or be absolute; no implicit DB-directory inference is possible.
- Classify remote/URL inputs before suppressing file-name handlers. Initial adapter
  rejects remote/URL/tilde/malformed/empty identities. Do not turn TRAMP syntax into
  a local pathname by disabling handlers before classification.
- Normalize provided bibliography-sources under their existing captured-base
  contract. Explicit duplicate identities remain errors, not silently repaired.
  Preserve all explicit texts, including unselected entries, in original order.
  For the same identity explicit text wins, with no filesystem read/stat required.
  Only missing discovered identities are acquired; append them in discovered order.
  No text overwrite or automatic bibliography-key winner policy is introduced.
- Every document declaration must remain resolvable in the effective view. If
  advice drops/reinterprets it or origin cannot be explained, fail explicitly rather
  than guessing. All final sources/declaration associations cross owning as data.

## Local acquisition and receipts

- Initial reader admits bounded regular local UTF-8 BibTeX text. It
  uses 1 MiB/file, rejects symlink components/physical aliases between auto-read paths,
  directories, missing/unreadable files and invalid UTF-8. BibTeX parsing/recovery
  belongs to native TeXmacs; there is no independent raw grammar validator. These
  limits are covered by maintained positive/negative tests.
- Normalize only lexical identities; do not canonicalize symlinks behind caller
  supplied identities. Physical alias detection is an acquisition observation,
  separate from bibliography source identity. Explicit text identities need not
  name an existing file and have no file receipt. Mixed explicit/auto alias conflicts
  remain explicit used-key/source validation failures, not silent text replacement.
- Read each auto source's bytes for acquisition, check file identity/size/mtime/ctime
  around the read, decode/validate UTF-8 locally, and own text plus an internal receipt
  (path, observed file attributes, byte digest). Use native parser/formatter and
  owned native ASTs for citation resolution; no global BibTeX database/processor
  discovery and no source-field signature comparison.
- Final checks reread to verify attributes/digest, never to replace captured text
  or re-run conversion. Changed/replaced dependencies invalidate the result. There
  is no watcher, automatic retry, transactional FS/DB promise, ABA-proof guarantee,
  or filesystem security sandbox. Symlink checks are observed-boundary policy,
  not an atomic no-follow open. All I/O stays in the opt-in adapter.

## Transaction and Phase 1/native handoff

- Guard source/configuration/explicit text values across the whole transaction,
  beginning before discovery, not only when existing preparation later starts.
  Compare known captured values and callback identities; do not replay discovery
  at native waits to infer an external DB transaction.
- Sequence: capture/preflight/masked discovery view → one discovery → normalize /
  merge / acquire → effective declaration context → exactly one existing Phase 1
  filter/preparation pipeline → native dependency parse/format → owning/pure lowering.
- Keep Phase 1 validation unchanged. Filter's bibliography paths must be the fixed
  final source identities; mapped keys are checked against the acquired entry forest.
  Missing/ambiguous actually used keys and unsupported citation styles still fail.
  Unused duplicate keys are retained. No dependency-field name blacklist or
  automatic uncited dependency expansion; native-generated unresolved references
  fail explicitly without implementing an Elisp field model.
- Recheck source and dependency receipts before returning a document/bytes and,
  for any later file consumer, before its write. Wrapping export-to-file and checking
  only after it returns is too late. A minimal first wrapper may return a completed
  document or bytes; file publication/frontend policy can remain separate.
- Cleanup private views on success/error; no source text/point/mark/narrowing edits,
  global registration/advice leaks. Source-independent preflight precedes native
  work; key-dependent preflight consumes actual parsed bibliography ASTs before
  STM requests/formatting. Arbitrary
  advice/filter side effects are neither rolled back nor claimed safe to replay.

## Validation and remaining integration boundary

Directory conflict, local UTF-8/size/alias limits and effective declaration shape
were reviewed and selected. Maintained tests cover the entire transaction,
including source/config/dependency mutations during discovery/acquisition/native
waits and before document/byte return. Final 17 focused/341 installed ERT and
all nine isolated checks pass; evidence.md records versions/limits. No real Org-roam
compatibility claim until independent integration fixtures establish it. Phase 2
provenance/source composition remains a separate design; issue #1 stays unfinished.
