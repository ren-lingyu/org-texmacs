# E4: reuse of island-model authority and ownership

## Scope and execution

Additional project parent is the v0.7.1 source actually exercised. Isolated batch
-Q on Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5; exact paths and replay are captured
in archive/2026-11-17T15-06-44Z--dd4deff/.
Working files were tmp/stm-e4/. Final experiment and result assertions exited 0.
Twenty-four native parse requests validate initial fragments and independent
source roundtrip results; no parse occurs in reverse conversion, model-copy,
replacement or explicit parsed-tree construction. Worker process/socket cleanup
and advice removal were verified. First execution needed an explicit ox load
for the package capability check, not Export preparation. This is exploratory
feasibility, not maintained regression coverage or a new public API.

## Extended Org AST -> model: one authority

The adapter prepares identity-keyed native trees, then calls existing
org-texmacs-model-create. A scoped prototype hook around the existing private
org-texmacs--model-copy-node changes only stm-fragment copying into string-leaf
anchor creation in that SAME owner transaction. Existing mapping copy remaps
fragment keys to owned anchors; existing STM copying, caption/secondary handling,
parent rebuilding, context copying and overlap validation are reused.
No parallel AST copier or persistent mapping registry is introduced.

The tested nonempty anchor is U+FFFC plus post-blank spaces. Equal-content adjacent
anchors are distinct identities. This is a prototype convention, not a final
external syntax or mandatory representation choice. It carries no raw STM payload.
Completed model AST has no stm-fragment or fragment :stm-source; island trees
alone carry mathematical content. Existing wrapper source residue (for example
headline raw-value) may remain as ordinary non-authoritative metadata and is not
used by reverse conversion. No stronger universal source-byte removal claim is
made.

## Model -> extended Org AST without reparsing

Existing model-copy first validates and detaches a snapshot. The same owner
transaction, with a reverse node hook, reconstructs stm-fragment from each
string-keyed island and remaps structural references. The prototype reuses the
model constructor as copying machinery and extracts its AST/context result;
that temporary holder is not a second authoritative mathematical model.

For guard runs org-element-parse-buffer, worker-request, the existing native
reparsing serializer and E3 graph-copy are rebound to errors. Reverse conversion
still succeeds, as do model-copy/replacement and explicit parsed-tree input.
The completed model's known trees therefore do not travel through Org source
or a native parse to recover extended AST structure.

A conservative tree-to-source GENERATOR supplies the fragment source, with no
parser. It handles the tested symbol grammar, strings/escapes and nested
compound trees; unknown tags are not whitelisted. Controls and unusual symbol
spellings outside its exercised subset are explicitly unsupported here. The
existing worker-serialize-stm helper is not used because its native serializer
reparses to validate output (worker.scm org-texmacs-serialize-stm-reply). A complete
non-reparsing writer/representation policy remains E5 work. This limitation must
not be hidden as a promise that all valid STM trees already serialize.

## Ownership, identity and transformations

Nine fixtures cover paragraph whitespace, adjacent fragments, headline title,
long/short caption, link description, inline note, table cells, bold and an
unknown tag with delimiter-like string content. The existing serialize-signature
on validated model snapshots is equal after extended-AST -> model -> extended-AST
-> source -> independently reparsed model. That final source reparsing is ONLY
an acceptance check; it is not the reverse AST algorithm. Model-copy keys differ,
old keys are rejected against the copy, and original input/model signatures stay
unchanged. Root replacements own their caller-supplied input.

Pure directly constructed AST and explicit parsed tree work with all parsers
forbidden. Deliberately stale source on the incoming fragment does not override
an explicitly supplied authoritative tree; subsequent caller AST/string mutation
cannot alter the model. AST peer and vector-peer references are remapped to the
new anchors, copied anchors and reconstructed fragments by existing owner data
copying. Model-copy separates tree/context data; modifying its leaf string does
not change the original. Nested STM child replacement updates only the new
model and remaps structural references; invalid child paths leave the original
unchanged. Explicit parsed-tree input is trusted structural input, not a claim
that arbitrary source/tree mismatches should pass source-native validation.

## Caption parents, post-blank and representation failures

Native parser caption fragments can have nil parents. Existing model-create
normalizes the corresponding anchors to their owning table for both long/short
caption branches. Model-copy and reverse conversion keep that ownership.
Reparsing source returns native caption parent shape, and rebuilding a model
normalizes it again; model signatures remain equal. Deliberately clearing a
caption anchor parent on a disposable copy is rejected by existing model-copy's
snapshot guard, while the original remains unchanged.

The placeholder anchor carries the fragment's post-blank count; reverse objects
recover it. Two trailing spaces, single-space contexts, zero-space adjacent
fragments, surrounding ordinary text and table-cell boundaries were exercised.
This is not a full arbitrary whitespace/control-character guarantee.

A directly supplied atomic tree "V" is accepted by model-create and model-copy.
Reverse compound-fragment representation fails explicitly, leaves the signature
unchanged, removes its scoped hook and permits another successful model-copy.
Root replacement can also produce a valid atomic island. Model validity is not
collapsed into fragment-source expressibility; no wrapper is added to change it.

## Conclusion and next action

Confirmed for the exercised domain: current owner/island/copy/replacement
mechanisms suffice for the new AST adapter. E3's graph copier is unnecessary as
a parallel model-management subsystem. Prototype hooks are private and scoped;
formal interface shape and anchor convention remain implementation choices.
No existing model validity rule or direct-constructor capability was changed.

Proceed to E5 normalized serialization/representability: expand writer coverage,
exact whitespace and difficult escaping cases, idempotence and known-tree
signatures without reparse in conversion. E6 standard Export lifecycle remains
unverified. Existing native block islands and legacy serializer integration were
not redesigned or claimed covered by the new string-anchor adapter; preserve
those contracts in subsequent compatibility work. No formal source change,
migration policy or minimum-version increase follows from this probe alone.
