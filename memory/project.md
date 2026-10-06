# org-texmacs current project model

## Source and representation

- Org is the sole canonical source.
- Ordinary Org syntax is parsed by Org. TeXmacs blocks and supported fragments
  preserve raw STM source and are parsed independently by TeXmacs.
- Parsed TeXmacs islands participate as structured strees; they are not kept as
  opaque payload strings and are not reparsed as Org.
- The implementation does not require physical grafting of all TeXmacs pseudo
  nodes into one live Org element cache.

## Current conversion path

```text
explicit Org source buffer
  -> private parsing and restricted Org context
  -> owned prepared input
       AST + INFO + islands + post-blank mappings + style + initial
       source-file + resource-base
       bibliography: explicit source identities + parsed BibTeX trees
  -> pure document-wide analysis
       identity-keyed link resolutions + target labels + typed file targets
  -> pure local document lowering
       body + style + initial + STM/file-target provenance
  -> source-aware native encoding
  -> TeXmacs native tree/state
  -> one persistent headless native document session
```

The body `(document ...)` is the native buffer body. It is not a complete
serialized TeXmacs file wrapper.

## Public construction interfaces

- `org-texmacs-input-create`: own and validate already prepared structures.
- `org-texmacs-document`: pure lowering from prepared input.
- `org-texmacs-prepare-buffer`: explicit source-buffer preparation adapter.
- `org-texmacs-document-from-buffer`: prepare and lower one explicit source.
- `org-texmacs-document-current-buffer`: current-buffer convenience wrapper.

The result does not retain the source buffer. Pure lowering does not read a
buffer or start a worker.

## Ownership and snapshot contract

- Prepared input owns copied AST/string structure, rebuilds parent links, and
  remaps identity-keyed INFO/island/post-blank data.
- Cyclic, multiply owned, detached, duplicate, deferred, or opaque inputs are
  rejected at the documented boundary.
- Source text and supported parser settings are captured coherently and checked
  across worker waits and after lowering.
- Output INFO and formatter selection use the conversion snapshot.
- Package behavior preserves source text, modified state, point, mark,
  narrowing, text properties, and unrelated Org callers.

## Text and provenance contract

- Structural lowering produces UTF-8 TeXmacs-shaped strees.
- Ordinary Org leaves use literal/source-code semantics. TeXmacs-looking text
  such as `<alpha>` remains literal.
- STM leaves use TeXmacs source semantics. Native notation retains native
  meaning; literal angle brackets must be represented by STM source notation.
- Body-relative STM paths retain provenance until native encoding is complete.
- style names and initial keys use identifier semantics. Structured initial
  values use TeXmacs source semantics.

## Released Org subset in v0.3.0 and v0.3.1

- Paragraphs, supported inline emphasis/literal objects, line breaks, external
  links from the finite URI protocol set, and anonymous inline footnotes.
- TeXmacs blocks and configured inline fragments.
- Restricted options and filtering for tasks, archive, select/exclude,
  comments, tags, H, num, and toc.
- Rich title/author/explicit date metadata and five relative headline levels,
  numbering, UNNUMBERED, ALT_TITLE, and low-level nested lists.
- Unordered, ordered, and description lists; quote and center containers.
- Static example, fixed-width, and source blocks without execution.
- Basic rectangular tables with structural rule borders.
- Static TOC with deterministic labels, hlink, and pageref.
- Document style, structured initial environment, body, and provenance applied
  to one native session with combined readback.

Unsupported content fails explicitly. Released non-support includes general
internal/file/ID links, named footnotes, citations, bibliography, arbitrary
references, dynamic source execution, advanced table semantics, unrestricted
export preprocessing, and arbitrary Org element coverage.

## DOC-01 committed local-link extension

The first resolution node is committed as
`a3ba241d66dc1e1a89a9eb4c4fc678fef2f5bfb4`; it is not a released capability.

- A pure analysis phase in the document layer scans the prepared AST, treating
  STM islands as opaque, and returns conversion-local identity-keyed links and
  labels. It retains no source buffer and performs no global ID lookup.
- Body/headline-title links resolve same-document `CUSTOM_ID`, `ID`, explicit
  `*Headline`, or fuzzy targets. Matching uses exact raw headline titles;
  dedicated paragraph targets take precedence over same-named headings.
- Only referenced targets receive deterministic `org-texmacs-ref-N` labels,
  skipping static labels in visible STM islands. TOC labels have a separate
  namespace. Low-level headlines also receive their reference labels.
- Described links become `hlink` nodes; undescribed links become native
  `reference` nodes. Direct paragraph targets become invisible label nodes.
- The buffer adapter resolves `ID`/`CUSTOM_ID` properties before removing their
  source drawers. The existing input constructor copies these properties;
  analysis uses that owned copy and introduces no new ambient parser settings.
- Missing or ambiguous links fail during structural preflight, before STM
  worker requests. Cross-file IDs, named-element targets, text-search fallback,
  file/resources, and internal links in metadata/ALT_TITLE remain unsupported.

Maintained tests establish structural and native readback behavior, not visual
reference values or typesetting. See `memory/evidence.md` for validation gaps.

## DOC-01 committed named-footnote node

Committed as `a242eb233322a62b3f18dbf1a3ba1278e628e361`; the verified diff matches.

- Pure document resolution maps named references to one owned separate or
  labeled inline definition. Definitions may follow the first reference.
  Missing/ambiguous definitions and nested footnotes fail during preflight.
- Preparation collects definitions before headline pruning, restores only
  definitions needed by visible references into the AST, and discards unused
  separate definitions and their island requests. It never reads a fallback
  source buffer. No detached definition forest or new public input slot is used.
- First use emits `footnote` with a `surround` prefix label; later uses emit
  `rsup` with a right-shaped native `reference`. Private `org-texmacs-fn-N`
  anchors avoid static STM labels and do not assume native counter numbers.
- References remain direct paragraph children. Separate bodies support the
  existing paragraph/list/container/static-block/table subset; normal fragment
  discovery applies to their paragraphs. Inline bodies retain the inline
  subset without STM discovery. STM/file provenance composes through the body
  wrappers and is emitted once.
- The source's `org-footnote-section` joins the copied/rechecked parser settings.
  Its special headline is omitted after definitions have been collected.
- Maintained native readback covers shared labels, mixed anonymous/named notes,
  Unicode and literal encoding. Rendered numbering and style expansion are
  unverified. This node is not a released capability.

## Committed source-location snapshot node

This node is committed as `b09b4515ad0445666d666506969e441d8f5e6b89` and its diff
matches the recorded verified worktree hash.

- Owned input and document results retain optional `source-file` and
  `resource-base` strings. Source file identity never overrides the resource
  base. Pure callers provide explicit absolute strings or leave them nil.
- The buffer adapter captures the base buffer's file identity and the explicit
  source buffer's effective `default-directory`, including indirect-buffer
  overrides. It expands home abbreviations once during preparation, without
  canonicalizing symlinks or reading linked files.
- Copied original location strings join snapshot consistency checks, detecting
  changes and in-place mutation even when source text is unchanged. Pure input
  and document results own independent copies and do not expand paths or run
  file handlers.
- The following local-file node uses the captured resource base only at its
  native consumer boundary; source identity never overrides it.

This node passed 217/217 local ERT and byte compilation, then Nix
package/ERT/package-lint checks using the user's temporary, uncommitted remote
mirror-source configuration. The overlay is not part of the project change.

## Committed local file-link node

- Document results add `file-paths`, body-relative paths to raw Org file-link
  target leaves in `hlink` nodes. Raw relative names remain unchanged until a
  consumer translates them. No `file:` URI is fabricated to recover structure.
- File targets are resolved from the owned AST and captured resource context.
  Plain local body links, including implicit relative and absolute links, are
  supported. No-description links display the raw path; images are not embedded.
  File searches, application hints, tilde/remote targets/context and title or
  metadata file links fail structural preflight explicitly.
- Pack/lowering operations propagate independent file-target and STM paths.
  Native preflight rejects duplicate/invalid/out-of-bounds markers, markers
  outside hlink target roles, and overlap with STM; native source hlinks are
  not reinterpreted as Org file resources.
- The native bridge rewrites marked target leaves on a fresh body copy to
  absolute system paths using only the captured base. The existing TeXmacs
  literal encoder and native URL handler preserve spaces, Unicode, literal
  angle brackets and percent characters. It does not read linked files or
  query the caller's current directory. The original result remains unchanged.
- Native string navigation initially rejects `#`, `?`, `*`, `$`, `|`, backslash
  and square brackets in expanded targets. Structural results may preserve
  these paths for other future consumers; this native consumer fails explicitly.
  Actual GUI navigation/rendering remains unverified.
- The worker transport/protocol and Scheme service are unchanged. The node is
  committed as `77a2888` and passed ERT 223/223 plus Nix package/package-lint/ERT checks with
  the user's separate temporary mirror-source configuration.

## DOC-01 explicit bibliography snapshot foundation

This verified and staged foundation awaits the user's commit; it precedes
citation/bibliography output support.

- Buffer preparation and both conversion wrappers accept an optional alist of
  path-to-BibTeX-text source snapshots. Paths are identities, expanded once
  against the captured Org resource base. No bibliography file is opened.
- Text is validated with local Emacs BibTeX entry/field helpers and fixed
  standard entry types. Automatic commas and string expansion are disabled;
  high-level `bibtex-validate` and global file/string databases are not called.
  The initial grammar accepts line-start standard entries with contiguous
  `@Type` headers, percent comments,
  whitespace, and single braced/quoted or decimal field values. Reject
  malformed entries, repeated keys/fields, strings, preambles, concatenation
  and other top-level data explicitly.
- A `parse-bibliography` worker operation parses validated text with TeXmacs's
  native converter, removes non-entry comments, and normalizes empty output to
  `(document)`. It uses the existing parse response/error and worker lifecycle.
  Structured author names and native source notation remain in the field trees.
- Prepared input adds `bibliography`, a path-to-parsed-document alist. Pure
  construction copies/validates the trees and rejects duplicate paths or keys
  across sources. Original text/path/list mutations, including path aliases,
  invalidate preparation across
  worker waits. Native type/key/field signatures must match local validation;
  inconsistent payloads stop the worker as protocol failures.
- Bibliography data is not yet emitted or retained in document results.
  Citation and BIBLIOGRAPHY/PRINT_BIBLIOGRAPHY keyword lowering still fail
  explicitly. The following semantic node will bind declarations and references
  to these owned entries and use footnote-aware first-use ordering.

## Worker and session

- One persistent headless TeXmacs worker serves parsing, encoding, and native
  session operations over a local Unix-domain socket.
- One active native document session is public. Updates validate/encode all
  fields before mutation, replace style/initial/body, and verify readback.
- Preflight errors preserve the session. Native update/readback errors discard
  it; cleanup or transport failure stops the worker.
- No `.tm`, `.stm`, or `.tmml` intermediate is required in the conversion path.

## Worker and native-bridge layering

- Shared package condition types live in core.
- The worker layer does not load the document layer. It owns process and socket
  lifecycle, request framing, generic response-envelope reading, and STM parse
  response semantics.
- The session/native bridge owns document preflight and wire serialization,
  native encoding, and native/session payload contracts. It depends on both
  the worker transport and the structural document representation.
- Application-level parse, encoding, and session failures preserve a healthy
  worker. Transport, framing, or invalid operation payloads stop it. A local
  request-construction failure before transmission also preserves it.

This boundary is implemented by project commit
`ec72c89b71ffd1df27d9cdb22c4f6c8e1a4f6491` and covered by the maintained
worker, encoding, and native-session tests.

## Downstream work not yet implemented

Complete file document modeling, serialization/save/export, PDF, preview,
visual pagination, multi-document or multi-session operation, live or
incremental synchronization, and broader Org document-wide resolution remain
future consumer/document work. `memory/backlog.md` distinguishes adopted work,
deferred candidates, and unresolved design boundaries; unsupported entries in
this support matrix are not automatically implementation commitments.
