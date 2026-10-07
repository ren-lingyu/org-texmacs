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
  -> independent complete-document serialization / native document session
```

The result body `(document ...)` is the native buffer body. The independent
consumer constructs a complete file wrapper only after native encoding.

## Public construction interfaces

- `org-texmacs-input-create`: own and validate already prepared structures.
- `org-texmacs-document`: pure lowering from prepared input.
- `org-texmacs-prepare-buffer`: explicit source-buffer preparation adapter.
- `org-texmacs-document-from-buffer`: prepare and lower one explicit source.
- `org-texmacs-document-current-buffer`: current-buffer convenience wrapper.
- `org-texmacs-document-serialize`: independent native .tm byte-string consumer
  of a completed document result.
- `org-texmacs-document-save`: explicit absolute local new-file saving consumer
  of a completed document result.
- `org-texmacs-export-from-buffer` / `org-texmacs-export-to-file`: explicit source
  byte/file export adapters.
- `org-texmacs-export-to-buffer`: readonly native byte view; it and file export
  also provide M-x commands (committed node below).
- `org-texmacs-document-pdf` / `org-texmacs-document-save-pdf`: native PDF bytes
  and new-file consumers; `org-texmacs-export-pdf-from-buffer` /
  `org-texmacs-export-to-pdf`: checked explicit-source adapters, with M-x file
  export (committed PDF node below).

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
- Body-relative source-semantic paths retain authored STM and generated native
  bibliography provenance until encoding is complete.
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

Foundation commit `8e1abf743d37792c43184c84f62dd2f1dceab348` matches the verified diff.
Its default citation/bibliography consumer is committed below.

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
- Original dependency trees remain in prepared input; document results hold
  the native formatted output rather than the original entry forest.
  The following implemented node consumes it for citations and bibliography output.

## DOC-01 default citations and native plain bibliography node

Committed as `fe6c435bda7948989f758cea6c9d4146c0d0a5cb`, matching the verified
eight-file diff. This is not a release claim.

- Preparation captures explicit document BIBLIOGRAPHY identities before pruning,
  using the fixed source resource base and provided text snapshots. No global
  bibliography/export processor or file/database lookup is invoked.
- Pure planning resolves bare default ASCII-key groups; missing/unavailable
  dependencies and unsupported semantics fail before worker calls. Footnote
  bodies are visited at first reference; repeated notes do not duplicate entries.
- One option-free PRINT_BIBLIOGRAPHY is required for citations. Native plain
  formatting occurs during preparation. The owned INFO view contains prefix,
  key order, selected entry trees and the source-semantic bib-list body. Pure
  lowering validates that view and its label set, emitting with-bib/cite groups
  and the prepared list without workers. Private prefixes avoid static STM labels.
- Generated bibliography roots join source-semantic provenance in stm-paths.
  Native Cork text is converted to UTF-8 while ASCII source notation is retained.
  Native prefix/style/default-style values are restored on success/error.
  Formatting domain errors preserve the worker; invalid payloads stop it.
- Styles, nonempty affixes, entry dependency fields (crossref/xdata/related/
  entryset), print options/multiple locations, and non-paragraph/inline-footnote
  citation contexts remain unsupported. No automatic heading or source-order
  numbering is assigned. Native readback is not GUI/typesetting verification.
- Source identity/text copying now resides in the source layer, so context
  preparation does not depend on document lowering for declaration capture.

## DOC-01 committed named/captioned basic tables

Commit `544e2463878d5658119f6beb9b8a6a8275e1739c` matches the verified five-file diff.

- Fuzzy resolution includes visible basic table NAME targets before headline
  titles. Referenced name/target collisions remain explicit ambiguities.
- Preparation records affiliated keyword names from the private source snapshot;
  only table NAME/CAPTION are admitted. Repeated names, empty captions and
  other affiliated keywords fail before island requests.
- Caption long/short pairs are copied as owned secondary Org nodes, with parent
  links rebuilt and mappings retained through filtering. Pure lowering reads
  neither source buffers nor installed styles.
- Captioned tables use native big-table and optional caption-detailed. Private
  reference labels sit inside the caption after native counter binding.
  Uncaptioned named tables permit described hlinks only, with an invisible
  surround anchor; unused names do not change the table tree.
- Rich captions support the existing inline text/markup and links, without STM
  discovery. Citations and parsed footnote objects are unsupported there; Org's
  caption grammar leaves footnote-looking text as literal text. Generated
  caption leaves retain ordinary encoding and compose typed file paths.
- Five focused tests plus the eighteen-case citation/footnote/table regression
  selector pass. Full local ERT passes 238/238 + 11/11; Nix compilation,
  package-lint and installed ERT 249/249 pass with the unchanged temporary
  mirror configuration. The verified node is committed as stated above.
  Displayed numbers, caption layout and pagination remain unverified;
  figures, other named elements and
  advanced table semantics are outside this node.

## CONSUMER-01 committed native file-document serialization

Commit `e7377e5767ca38411a497a635d5053f1729a2d5a` matches the verified five-file diff.

- Public org-texmacs-document-serialize consumes a completed document result.
  The existing native bridge validates/owns its wire, resolves typed file
  targets against the captured source base and encodes body/initial once.
- A native worker helper directly builds document/TeXmacs/version, style tuple,
  body and optional initial/collection/associate structure from encoded fields.
  The version is the running TeXmacs's version, not the package version.
  Native serialize-texmacs returns exact output bytes; ASCII hex transports them
  and the bridge returns an unibyte string, without a UTF-8 decode step.
- No session, output file, Org exporter, resource read, live reference table,
  attachment, auxiliary state, typesetting or PDF/preview is introduced.
  Source-side link meaning remains independent of an eventual save directory.
- Preflight/encoding/serialization errors preserve healthy transport. The new
  shared serialization-error condition is operation-specific; malformed hex,
  version/header or operation payloads stop the worker.
- Four focused cases pass, including native serialize/parse tree roundtrip,
  Unicode/literal/STM/initial semantics, exact byte transport, disposed-source
  document features, error recovery and unchanged live-session readback.
  Nix first found an obsolete string-as-unibyte compile warning; the bridge now
  creates a zero-filled unibyte string directly. Full local 242/242 + 11/11
  passed before that adjustment; final focused 4/4 and Nix compilation,
  package-lint and installed ERT 253/253 pass. The verified node is committed;
  the temporary overlay remains unchanged and excluded. GUI/layout remains
  unverified; new-file saving is covered by the bounded consumer below.

## CONSUMER-01 committed explicit new-file saving

Commit `0ee17c4acc88664e2024af26d8ebcf08084e85a7` matches the verified three-file diff.

- Public org-texmacs-document-save consumes a completed document and an explicit
  absolute local destination. It copies that path before waits, rejects existing
  files/directories/symlinks and requires an existing parent directory.
- Native serialization completes before file creation. A private unibyte buffer
  writes exact bytes with no-conversion and write-region mustbenew=excl.
  Exclusive open rejects files, directories and symlinks created during waits.
  Native/source resource semantics do not depend on the save directory.
- Destination filesystem operations suppress file-name handlers; byte writing
  suppresses format conversion, annotations and modification hooks. Caller
  text, point, mark, narrowing, modified state and file identity remain intact.
- Encoding/serialization failures create no output; standard filesystem errors
  propagate. A write failure can leave a partial new file, explicitly documented
  and covered by maintained failure injection. No speculative cleanup, directory
  creation, overwrite, backup or atomic publication is provided.
- Four new maintained cases pass in the combined eight-case serialization/save
  selector. Full local 246/246 + 11/11 and Nix compilation/package-lint/installed
  ERT 257/257 pass with the unchanged temporary mirror overlay. Three explicit
  files were approved/staged and then committed. The Scheme service and
  serializer protocol are unchanged; only the explicit saving API writes files.

## CONSUMER-01 committed explicit-source export adapters

Commit `ee225ad62ffedf529239f7a31fd4cc73e9743519` matches the verified four-file diff.

- Public org-texmacs-export-from-buffer takes an explicit source buffer and
  optional BibTeX text snapshots, returning native .tm bytes. It composes pure
  lowering/native serialization inside preparation's final consistency check.
- Public org-texmacs-export-to-file validates/owns an absolute local destination
  before preparation, obtains checked bytes with that adapter and writes them
  once afterward. No second source parse/lower/native encoding is introduced.
- Destination validation and byte writing are shared private native helpers,
  also consumed by document-save. Exclusive creation, byte/annotation/handler
  isolation and the partial-new-file error boundary are preserved.
- Source text/location/parser/narrowing/mode/lifetime and bibliography changes
  across native waits reject exports before any file output. Source snapshots
  and destination identities have distinct ownership and lifetimes.
- Four new maintained cases pass in twelve combined focused cases: native byte/
  file equality, caller/source base separation, single serialization per export,
  source and dependency waits, target mutation, preflight and generic hook/pipeline
  isolation. Full local 250/250 + 11/11 and Nix compilation/package-lint/installed
  ERT 261/261 pass with the unchanged temporary mirror overlay. Four approved
  files were staged and then committed. No Org backend/dispatcher, output
  buffer preview, overwrite or unrestricted preprocessing is added.

## CONSUMER-01 committed interactive exports and readonly byte views

Commit `1ed04db7d5635d4851f78bf89c2bb72e9693312a` matches the verified three-file diff.

- Public org-texmacs-export-to-buffer exports an explicit source, then creates
  a fresh unibyte readonly special-mode buffer with no-conversion coding, no
  visiting file, no file format and no save offer. It is a derived native source
  view, not rendered TeXmacs output; no source pointer/synchronization is retained.
- Lisp calls return the buffer without display; M-x calls capture the current
  unnarrowed Org source and display the result. Source failure creates no buffer;
  initialization/display failure removes only the newly allocated buffer.
  Mode hooks and mode-change callbacks are isolated while initializing the view.
- Existing export-to-file is now interactive: capture source/directory before
  the file prompt, suggest the source file stem or export.tm, then reuse the
  explicit source/new-file adapter and report the copied output path.
- Invalid/non-Org/narrowed sources fail before prompts; remote working directories
  are outside this interactive file chooser's subset. Interactive calls pass nil
  bibliography snapshots; Lisp callers still pass explicit texts. No bibliography
  file reader, Org backend/dispatcher or overwrite policy is added.
- Four new cases pass in sixteen combined focused tests. Complete local ERT
  passes disjoint 105/105 + 149/149 + 11/11, after the old 254-case bucket timed
  out at 120s. Nix compilation/package-lint and installed ERT 265/265 pass.
  The verified node is committed; the temporary mirror overlay stays excluded.
  Display and prompts are simulated; actual GUI layout is unverified.

## CONSUMER-01 committed native PDF consumer

Commit db33c148dbbc4c26c6aae300c063883b06e893e6 matches the verified seven-file diff.

- document-pdf returns unibyte native PDF bytes; document-save-pdf uses the
  exclusive new-file writer. export-pdf-from-buffer and export-to-pdf keep
  native rendering inside the source/dependency consistency check; the latter
  also supports M-x with a captured source and a .pdf destination suggestion.
- The native bridge encodes owned fields once; headless Scheme installs them
  directly in a temporary native buffer, runs three synchronous low-level
  updates and print-to-file. The working-tree semantic fix then updates three
  times and prints again to resolve typeset bibliography references.
  It does not reparse serialized .tm or run deferred
  generate-all-aux/bibliography generation. Existing public sessions are isolated.
- Temporary files are in the worker's private directory. Buffer/file cleanup
  runs on success and rendering errors; cleanup failure or malformed PDF output
  stops the worker. Font caches have normal TeXmacs lifetime.
- Explicit resource/executable trees image/include/extern/script/action/eval/
  raw-data are rejected. Native installed styles/fonts remain dependencies;
  custom styles are not sandboxed. Fixed update passes have bounded reference
  evidence, not a general convergence guarantee. GUI/visual preview is absent.
- Installed ERT uses test-only Poppler inspectors for PDF structure/text and
  heading/table reference values. PDF binaries are never GAW artifacts.
- New semantic regression exposed unresolved citation markers [?, ?]/[?] despite
  populated numbered bibliography. The authorized working-tree two-print fix
  resolves these markers; eight focused cases pass, including footnote bodies/
  markers and each print phase's failure/recovery. Final installed ERT 273/273
  (122.88s) and all Nix checks pass. Three files are approved/staged, awaiting
  the user's commit. Normalized text assertions have no byte/pixel/coordinate
  or fixed-pagination dependencies; inspectors are mandatory in installed ERT.
- Six PDF cases, full local 271/271 and final Nix compilation/package-lint /
  installed ERT 271/271 pass. The verified node is committed;
  the temporary mirror overlay is excluded.

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

Broader file metadata (attachments/reference tables/auxiliary), replacement/backup
policy, generic Org export backend/dispatcher, preview,
visual pagination, multi-document or multi-session operation, live or
incremental synchronization, and broader Org document-wide resolution remain
future consumer/document work. `memory/backlog.md` distinguishes adopted work,
deferred candidates, and unresolved design boundaries; unsupported entries in
this support matrix are not automatically implementation commitments.
