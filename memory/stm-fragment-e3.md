# E3: independently usable extended Org AST

## Baseline and execution

Additional project parent identifies read-only v0.7.1 actually used. Batch -Q,
Emacs 31.1, Org 9.8.10 (exact loaded path in captured scope.json), isolated
HOME/XDG/TMPDIR, load-prefer-newer. Final experiment exited 0; result assertions
also exited 0. No complete STM model, native parsing, worker or source preparation
was invoked. Phase-C native validation remains separate; E2-prime supplies its
previous evidence. This experiment is feasibility evidence, not formal tests.

Replayable scripts and full observations:
archive/2026-11-17T14-52-18Z--dd4deff/files/tmp/stm-e3/.
Manifest records digests and replay. Temporary working copies: tmp/stm-e3/.

## Registration and interpretation — Confirmed for sampled calls

Compare pseudo-object-only with local registration: bind org-element-all-objects
to a fresh list containing stm-fragment; derive corresponding restriction entries
from latex-fragment membership without modifying original list tails. Keep
stm-fragment nonrecursive. Reuse scoped E2-prime parser dispatch; temporarily
bind org-element-stm-fragment-interpreter to emit backslash-parenthesized
compound source. The object is genuinely stm-fragment, not latex-fragment.

The pseudo-object can be interpreted using the temporary interpreter, but
org-element-map with stm-fragment alone misses it in 22 fragment-containing
comparisons (two opaque cases correctly contain none). Passing other known
object types simultaneously can conceal this failure. Org's map uses its object
registry to decide whether to descend into object containers and secondary values.
Do not infer correct traversal merely from successful serialization.

Local registration makes single-type traversal work and classifies standalone
objects correctly. Entries and function bindings are restored after normal
return and intentional error; parser advice is removed. Nested ordinary Org
parsing with explicit extension-context suspension returns native latex-fragment;
outer extension parsing resumes afterward. This demonstrates scoped feasibility,
not automatic backend routing: E6 still must arrange the appropriate context for
nested exports. No permanent global parser environment change is needed by this
prototype.

## Secondary structure and copying — findings and adaptation

Title fragments have headline parents and :title secondary identity. Link
descriptions are recursive link contents, not equivalent to headline property
storage. Long/short captions remain dual affiliated secondary strings; their
fragment parent is nil in these native samples. Traverse captions explicitly
with WITH-AFFILIATED. Parent alone is insufficient to discover their owner.
No experiment rewrites caption parentage to resemble ordinary children.

Native org-element-copy with KEEP-CONTENTS serializes identically but clears
ordinary child parent pointers and shares caption fragment nodes in this sample.
A native latex-fragment control reproduces both behaviors, so this is not a
new-object-specific failure. Title secondary nodes are copied/reparented by the
native API. Thus native copy success is insufficient for an owned snapshot.

A minimal memoized graph copy of explicit cons/vector/string data remaps parent
references (including text properties) and duplicates caption nodes and source
strings. Buffers/other opaque runtime values are retained as references; no claim
of complete context ownership is made. Across registered cases, copied fragment
and payload identities differ, parent links remap, original caption nil parents
remain nil, and serialization stays equal. A five-fragment copy containing title,
long/short caption, table cell and link description was modified independently:
all five changed payloads roundtrip while original output remains unchanged.
This is a tested candidate copy adapter, not a final model ownership implementation.

## Independent construction and roundtrip — Confirmed within matrix

48 comparisons cover twelve source fixtures times pseudo/registered modes and
cache off/on. All 24 registered comparisons preserve exact STM source strings,
selected structural signatures, copied output and input AST semantics; normalized
output is idempotent. Fixtures cover adjacent fragments, surrounding whitespace,
emphasis, headings, long/short captions, links, inline notes, table cells, strings
containing backslash-close, unknown tags and opaque code/verbatim.

The signature includes nested Org types, relevant properties/secondary strings
and contents, removes source positions/carrier spelling and collapses ordinary
layout whitespace. STM source itself is compared exactly. This is not a full
STM-tree semantic signature or proof of every whitespace boundary; E4/E5 retain
those duties. Normalization here changes carrier spelling to backslash form,
without parsing/reformatting its inner tree. Invalid direct AST payload schema
validation is not established merely by the valid construction examples.

Directly constructed paragraph and title/caption/link ASTs serialize and reparse
without any full model or source parsing as a construction intermediary. Title,
caption and link payloads survive, and the second output is identical. Known
extended AST data can therefore independently drive source reconstruction.

## Cache, remaining scope and next action

The fixture matrix toggles org-element-use-cache. A live-buffer context probe
also observes native latex-fragment before scope, stm-fragment during scope and
native latex-fragment afterward; after editing x to y it reads the new payload.
This is a focused cache/isolation observation, not exhaustive incremental-cache
coverage. Interpreter/table/advice cleanup passes after an intentional exception.

E3's prioritized feasibility questions are supported: scoped registration,
secondary-string preservation with explicit copy adaptation, and independent
extended-AST/source roundtrip. Proceed to E4 with these constraints: derive owners
from structure rather than only parent, test anchor/whitespace/identity on copied
ASTs, preserve direct parsed-tree constructors, and reject unrepresentable models
without changing their trees. No E4 conversion, E5 full normalization, E6 standard
Export integration, version-minimum increase or legacy-syntax policy is delivered.
