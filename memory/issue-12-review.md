# Issue12: native bibliography ownership

## Motivation, authority and delivery state

https://github.com/ren-lingyu/org-texmacs/issues/12 delegates BibTeX contents to
native TeXmacs instead of an independent Emacs whitelist/signature model. GitHub
connector successfully read body and all comments: open, zero comments, no
milestone at review. Public web cache fetch failed; use dedicated connector.
User adopted implementation plan and explicitly selected used-key-only ambiguity
checks and no automatic uncited dependency expansion. Implementation authorized;
this task's exact probes/baseline/focused/integration/full flake suite plus locked
dependency access and result reading/copying subsequently authorized. No personal
bibliography files reread, external writes or ordinary staging/commits.

The motivating user report was org-organize adding three bibliography sources;
prior authorized inspection identified @online and bare month=MM outside the old
whitelist/literal grammar. User reports those files work with ox-latex; do not
label them corrupt or claim this task tested the personal library. Prior source
inspection facts remain in memory/pdf-adjacent-checks.md.

Current uncommitted implementation and README/tests prepared. First105focused pass,
final107focused pass (170.676069s),9fixed real extension tests pass (12.313207s),
strict package compilation and package lint pass. Full464/464ERT pass in
339.558582s, complete authorized600s flake check exits0. Root diff-check passes;
ordinary index was empty at validation. User subsequently authorized sequential
staging/message:8task paths staged, exact validated patch/blobs verified; original
flake overlay remains unstaged. Implementation complete, manual user commit pending.
Root user flake mirror overlay unchanged;19candidate inputs match isolation hash
manifest. Runtime isolation is tmp/issue-12-bibliography; no system Emacs used.

## Adopted implementation

- Public signatures, default discovery policy, input slots and worker request
  format unchanged. Preparation snapshots/initializes/selects/filters/owns once,
  performs source-independent citation/declaration/link/footnote checks, parses
  each owned bibliography text once with native parser and immediately copies
  its full AST, resolves used keys and runs lowering preflight, parses STM
  islands, then chooses final prefix and native-formats output. No fake entry
  AST or raw type/key/field signatures. Temporary formatted preflight bib-list
  never escapes in input, even when there is no print.
- Raw validator and bibtex require removed, including acquisition validator.
  Acquisition retains explicit text priority, opt-in collector once,1MiB UTF8
  local regular-file/symlink/alias restrictions and receipts. Existing source/
  configuration/dependency guards surround native waits and final consumer.
- Worker preserves full native document, including opaque metadata. Input copy
  checks finite safe stree/document, unique absolute source paths and shape of
  consumed top-level bib-entry/bib-field nodes. No field-name/value whitelist,
  repeated-field or unused-key rejection. Metadata stays opaque, not rendered
  or reinterpreted. Effective declared source entries form a key multimap;
  actual used keys must match exactly one candidate. Never choose a duplicate
  winner. Unused duplicate keys remain owned; unselected source identities do
  not make an otherwise unique used key ambiguous.
- Remove crossref/xdata/related/entryset field blacklist. Only actually cited
  entries are sent to native plain formatter; no parent expansion or invented
  Elisp field semantics. Native bibliography output receives captured with-bib
  context, and bib-list subtree STM provenance moves under that wrapper.
  Check native cite/reference/pageref targets against actual generated labels;
  dangling/dynamic unsupported references fail explicitly. Native ignored fields
  do not independently fail. Prefix/keys/entries/prepared-output matching remains;
  generated labels must match exactly, retaining duplicates during validation.
- Native parse errors and format domain errors preserve worker. Missing/ambiguous
  used key or valid formatted AST with unresolved native reference is a document
  error, not worker corruption. Malformed protocol/native AST or invalid expected
  formatted-label response stops worker. Pure input/lowering never parses, reads
  source buffers/files or invokes native work.

## Verified pinned native behavior

Raw16controls and final rerun report Emacs31.1/Org9.8.10/TeXmacs2.1.5,
x86_64-linux. @string substitution and # concatenation work. @preamble is omitted
from returned document; not emitted. @online/unknown types survive parser and
plain fallback formats title; online URL was retained as slink in field AST but
omitted from tested plain output. Undefined variables remain literal, including
following a defining request on the same worker (no demonstrated cross-request
leak); each source snapshot is parsed separately, no cross-source macro model.
Duplicate keys/fields remain in native AST; formatter uses first duplicate field.
Incomplete braced input recovers into an entry; garbage can become metadata with
no entries. Do not promise raw syntax-error completeness or full BibLaTeX/Biber.
Crossref yields native cite to parent; when only child is used it fails output
reference check, and when parent is also cited it exports. Tested xdata/related/
entryset fields ignored by plain do not cause field-name rejection.

## Verification and remaining action

Three new tests were created against owned old module/worker snapshot before
implementation, and all three fail for expected old restrictions: construct
whitelist, opaque metadata/repeated fields, unused duplicate keys. Initial and
final baseline runs confirm expected failures; baseline check exit0 means the
negative control behaved correctly, not that old implementation passes.
Maintained coverage adds native construct/field behavior, source authority,
used-key-only ambiguity and effective identities, metadata owning before later
wait, native parse failure/reuse, input/schema errors, duplicate labels/native
reference integrity, discovered inputs, .tm/PDF and independent reload parity.
Existing filter/selection/footnotes/INCLUDE/mutation/pure ownership checks pass in
focused suite. Native PDF crossref and unknown entry fallback agree after reload;
no PDF-byte identity assertion. Personal libraries, GUI and other versions not
certified.14necessary original-byte text files independently archived/verified:
archive/2026-10-16T16-37-01Z--1ee3de5/MANIFEST.md. Logs preserve original whitespace;
no PDF/binary/personal sources or redundant committed source copies captured.
Current memory/model/acquisition contract coordinated. Eight task paths now staged;
next user review/optional manual.org interaction after loading fresh package,
with org-organize enabled and buffer-local discovery t. User-authorized staging/
message complete: tmp/commit.md subject fix(bibliography): delegate BibTeX
interpretation to native TeXmacs, footer Closes: #12. Exact draft SHA256:
f9780248b442723802b13cf5aaf7eda6dbc649c7708045de94636c72eb2f4989.
Split not necessary/low: one coupled native ownership fix. Ordinary commit manual. After user commit verify exact delivery and
Issue12 state; no automatic GitHub close/comment.

## Executed isolated validation commands

Working directory: ordinary project root. Every build uses --no-link,
--no-update-lock-file, --print-build-logs, --print-out-paths:
- timeout 120s nix build path:./tmp/issue-12-bibliography#checks.x86_64-linux.probes
- timeout 120s same target baseline; asserts three expected old-code failures.
- timeout 240s same target focused; initial105pass, final107pass through full check.
- timeout 120s same target integration; fixed preexisting extension fixtures.
- timeout 600s nix flake check path:./tmp/issue-12-bibliography
  --no-update-lock-file --print-build-logs; final107focused/baseline/native controls,
  464coreERT, strict compilation and lint all pass.
Necessary result metadata/log reading and copying were included in user authority.
A metadata query initially could not connect to Nix daemon in sandbox, then
succeeded under already-authorized result-read scope; no broader test/dep action.
No timeout or failed positive test; no lock update or root flake mutation.
