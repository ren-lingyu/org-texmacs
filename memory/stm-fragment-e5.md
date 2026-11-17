# E5: STM generation, reader differences and Org normalization

## Baseline and methods

Actual source baseline is the additional project parent; Emacs 31.1, loaded Org
9.8.10, TeXmacs 2.1.5. Isolated batch -Q with private HOME/XDG/TMPDIR, 15/5/120s
startup/request/outer limits. Final writer, normalization and escape probes all
exited 0; separate result assertions exited 0. Worker cleanup was verified.
Evidence/replay: archive/2026-11-17T15-47-11Z--dd4deff/files/tmp/stm-e5/.
The archive manifest records executable, source adaptations and digest details.

A temporary Scheme harness separates generation from validation. It compares
actual Scheme write, native texmacs->stm and two pure Elisp generators. For each
source, it independently records Scheme read equality, actual
stm-snippet->texmacs/tree->stree equality and existing org-texmacs-parse equality.
Flags are 1 equal, 0 successfully read but unequal, -1 error. Scheme equality is
DIAGNOSTIC, not a substitute for the actual STM parser. Source bytes are captured
without trusting cross-reader printed-string escape conventions.

Existing scheme-string quotes transport strings; worker-stm-wire uses tag names
as strings and is not STM source syntax. Existing worker-serialize-stm invokes
native texmacs->stm then reparses output for validation. Generation itself does
not require that reparse. This existing helper cannot be placed invisibly into
the worker-independent model/AST conversion contract.

## Writer observations — Confirmed within finite matrix

38 structurally valid inputs: zero/one/nested compounds, unknown tags, symbol
punctuation/reader ambiguities, strings with quotes/backslashes/delimiter text,
LF/TAB/CR and other controls, Unicode, deep nesting and one atomic control.
All original input trees stay unchanged. Three invalid/cyclic/non-tree samples
are separately rejected by existing structural validation before writing.

Both native STM and existing project parser agree on the original tree for:
Scheme write 19/38, texmacs->stm 33/38, naive pure Scheme-style writer 29/38 and
the refined pure STM generator 36/38 (including the atomic control).
These are exploratory inputs, not test-suite counts or universal guarantees.

Scheme write's actual reader spellings for some symbols/control strings do not
roundtrip through STM. Conversely native STM output may have Scheme datum
inequality while still giving exactly the desired native tree; transport,
Scheme syntax and STM source syntax must remain distinct. Ordinary S-expression
appearance is not proof. The retained sources/flags are the precise evidence.

Refining the pure generator to use observed STM symbol/string escaping resolves
mixed quote/backslash failures without native generation or a full Elisp parser.
Numeric-looking and reserved-looking labels can require STM-specific escaped
forms. Unknown ordinary tags are not whitelisted. The refined writer is
structural/deterministic and the exercised output is buffer-independent.
Control characters and Unicode are tested against real native parsing, not
assumed safe because an Elisp printer accepted them.

Two valid models remain unresolved under the compared source paths: an empty
symbol and a symbol containing whitespace. The latter has a native-source form
that the direct STM parser accepts but the existing worker's Scheme-read/stree
precheck rejects. Empty-symbol output fails the tested candidates. These are
reader compatibility / candidate writer limitations, not proof of a permanent
STM grammar restriction or authorization to change model validity. No complete
writer domain has been frozen from this finite matrix.

Atomic "V" is writable as a datum but is not a compound fragment. Existing E4
proves representation failure preserves a valid, copyable model. Invalid model,
valid-but-outside-compound-syntax and unresolved writer/native compatibility
must not be collapsed into one error classification.

## Org normalization — Confirmed successes and Refuted universal output

48 model -> extended AST -> source -> independently parsed model comparisons
cover eight contexts and six payloads. 46 preserve the existing model structural
signature, exact STM trees, island sequence/positions, raw anchor whitespace,
surrounding meaningful text and idempotent normalized text. This uses the existing
model signature with raw text plus explicit anchor/post-blank comparisons, not
E3's whitespace-collapsing signature. Model->AST remains guarded against Org/STM
parsing, the old native reparsing serializer and the E3 graph copier.

Two cases fail representation in the tested contexts: a string with ]] in a link
description and a string containing | in a table cell. Org's containing structure
closes before the STM carrier. This is independent of native tree validity and
native writer acceptance. Tried escapes for |, ], hex and Unicode spellings
were rejected or changed the tree; no transparent context-safe repair is claimed.
The original model remains unchanged in both failing cases. Source output must
not silently deliver such a mismatch. It needs an explicit representation error
or a separately demonstrated encoding, while preserving native composition rules.
Do not repair Org's own nesting semantics by default.

## Recommendation and gate status

Conditional bounded feasibility is established for a pure STM generator; no
observed requirement forces worker dependence into model/AST conversion. Prefer
that route, using native generation/parsing as independent oracles. E4's original
restricted writer is not the formal grammar. Keep invalid-model rejection,
compound-fragment failure, writer-domain limitation, native-precheck compatibility
and Org-context representation failure distinct. A production writer must define
and enforce its verified domain and output error contract; these are still open
for compatibility review, not silently accepted artifacts of the prototype.

E5 is NOT a claim that every valid model tree/context serializes, nor a final
full-domain acceptance. Before scope freeze, resolve the formal domain/error
policy and decide whether native precheck behavior needs a separately reviewed
change. No worker boundary relaxation is adopted. E6's sampled lifecycle evidence
is recorded separately; E7 compatibility review follows, with this gate visible.
