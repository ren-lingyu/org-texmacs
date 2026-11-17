# E6: actual standard Org Export lifecycle

## Baseline and actual path

Additional project parent is the v0.7.1 source baseline; isolated Emacs 31.1,
Org 9.8.10, TeXmacs 2.1.5, batch -Q without minor mode. The same loaded Org and
native executable as E5 were used. Final command and semantic assertions exited
0. Evidence/fixtures/replay:
archive/2026-11-17T15-47-11Z--dd4deff/files/tmp/stm-e6/.
No personal Org files or ID database were read. INCLUDE, SETUPFILE, Babel and
BibTeX files and the ID target/hash were created in the experiment directory.
Worker termination/socket-directory removal and object/parser restoration pass.

Every core case calls actual org-export-as 'texmacs. Scoped advice wraps that
transaction with E3 registration/recognition and a copied backend containing a
stm-fragment transcoder. Non-TeXmacs calls explicitly suspend extension context.
The final prepared-discover hook adapts stm-fragment from the owned FINAL AST
into requests/anchors, then uses existing native request/input ownership and
lowering. It does not replay preparation, reimplement recursive INCLUDE or read
old source spans. Existing Cite identity remapping and native block discovery
stay in their normal path. This is a temporary integration prototype, not a
production implementation or promise to retain the private advice interfaces.

## Concrete integration changes found

Existing lowering rejects string islands outside paragraph/footnote contexts.
A single isolated document.el gate change allows string islands at existing
inline-lowering call sites. Its exact diff and preparation script are archived;
the full copied baseline source is not redundantly archived. No ordinary project
source was modified. It is not evidence that all arbitrary target structures
support islands; the exercised caption/table/wrapper contexts are the
supported observation.

Post-blank encoded only inside an opaque anchor disappears during lowering.
The initial real export exposed missing space after math. The prepared adapter
now emits a separate owned ordinary text node for trailing blanks and uses an
opaque anchor without hidden spaces. The resulting Before/math/after output
passes an explicit spacing assertion. E4's prototype anchor convention is not
a final rule that prepared consumers must interpret implicitly.

## Confirmed sampled lifecycle behavior

21 direct Export cases: 19 expected successes and two expected errors (explicit
filter exception and a filter-supplied native-invalid STM source). Subsequent
exports recover after both errors. Each case observes one options filter and
parse-tree filter; each case reaching handoff observes one standard-input call.
No duplicate preparation transaction is introduced by fragment adaptation.

Parse-tree filters modify, delete, add fragments and delete/replace whole parent
structures. Final captured payloads and actual native output match the edited
AST only; removed/original fragments are not resurrected. Newly supplied source
is natively validated; invalid #bad fails rather than falling back or recovering
an original valid span. Successful original source buffers remain unchanged.

INCLUDE/SETUPFILE, macro expansion and controlled emacs-lisp Babel raw results
supply fragments through real preparation. Subtree excludes the other subtree;
visible-only with an actual Org fold excludes hidden body content. The initial
plain invisible-property fixture was inadequate and is not counted as success.
An options filter disables sub/superscripts, and output retains literal x_i.

Native Cite emits cite-detail, bibliography binding and the selected entry;
an unused fixture entry is absent. Inline fragments coexist with the native
requests and labels, demonstrating retained identity mapping along this path.
External Org ID produces the expected document-level target.pdf link under a
private ID hash/database context. Existing typed equation, theorem, figure and
table references remain native macros. Statement/equation/figure/table wrappers,
caption and table-cell fragments and old native texmacs block islands coexist.
The observed lowering gate change is necessary for the expanded inline contexts.

TeXmacs containing ASCII export, ASCII containing TeXmacs export and sequential
ASCII export preserve the respective parser behavior/output. Scoped registration
and backend copies restore normally and after filter/native failures. Body-only
TeXmacs export still fails under the existing contract. No asynchronous or PDF
rendering support is newly asserted by these text-export observations.

## Conclusion and remaining scope

Confirmed sampled feasibility: real standard Export can retain final-AST
selection/preprocessing/filter/Cite authority with local object integration,
without copying preparation or restoring original source. The two observed
internal integration issues have demonstrated minimal adaptations in isolation.
No unresolved lifecycle contradiction was found in this matrix.

This is not exhaustive backend/filter/Org-version compatibility or maintained
regression coverage. Production source guards, nested context routing, consumer
island boundaries and whitespace need formal tests in the implementation node.
Keep E5's unresolved source-domain/error-policy gate visible before scope freeze.
Next E7 reviews bare syntax, discovery API, coexistence, errors, editing and
fontification; minimum versions and final APIs remain undecided. No version,
release metadata, main-source or ordinary index mutation follows from this work.
