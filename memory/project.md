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
  -> pure document lowering
       body + style + initial + STM provenance
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

## Supported Org subset in v0.3.0

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

Unsupported content fails explicitly. Current non-support includes general
internal/file/ID links, named footnotes, citations, bibliography, arbitrary
references, dynamic source execution, advanced table semantics, unrestricted
export preprocessing, and arbitrary Org element coverage.

## Worker and session

- One persistent headless TeXmacs worker serves parsing, encoding, and native
  session operations over a local Unix-domain socket.
- One active native document session is public. Updates validate/encode all
  fields before mutation, replace style/initial/body, and verify readback.
- Preflight errors preserve the session. Native update/readback errors discard
  it; cleanup or transport failure stops the worker.
- No `.tm`, `.stm`, or `.tmml` intermediate is required in the conversion path.

## Known architecture issue

The worker layer still depends on the high-level document module for parts of
document wire validation/encoding. The intended behavior-preserving direction
is to move document representation responsibilities to the session/native
bridge while retaining process, socket, framing, and protocol-envelope duties
in the worker. This is a post-v0.3 refactor, not an established correctness bug.

## Downstream work not yet implemented

Complete file document modeling, serialization/save/export, PDF, preview,
visual pagination, multi-document or multi-session operation, live or
incremental synchronization, and broader Org document-wide resolution remain
future consumer/document work. `memory/backlog.md` distinguishes adopted work,
deferred candidates, and unresolved design boundaries; unsupported entries in
this support matrix are not automatically implementation commitments.
