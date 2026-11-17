# E2-prime: native-compatible STM recognition

## Scope and provenance

Executed after the user narrowed the design to native latex-fragment allowed
positions and successful compositions. Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5;
cache disabled, batch -Q, load-prefer-newer, isolated HOME/XDG/TMPDIR. Final
experiment exited 0. The additional project parent identifies the v0.7.1 source
baseline actually probed. No development Org dependency or personal Org input.
Scripts and original full outputs: archive/2026-11-17T14-33-31Z--dd4deff/files/tmp/stm-e2-prime/.
Manifest supplies digests, replay procedure and provenance. Temporary working
copies are tmp/stm-e2-prime/, not the durable recovery authority.

## Technique actually tested

A scoped advice around org-element-latex-fragment-parser recognizes only $( or
backslash-double-open starts when Org itself dispatches to that parser. It
reuses the lexical scan-sexps boundary scanner, limited by the currently narrowed
Org object context. It returns a real nonrecursive stm-fragment node, not a
renamed persistent latex-fragment. Other input delegates to the original parser.
No full-source prescan, interval masking, global object-table modification or
preparation copy is used. Native STM validation runs after AST construction,
only on sources collected from recognized nodes. This is a feasibility prototype,
not production registration or a complete source/model conversion API.

## Confirmed in sampled matrix

78 cases comprise eleven contexts times six forms plus twelve boundary cases.
Twenty ordinary valid carrier cases with complete native latex-fragment matches
preserve their value as stm-fragment; this includes native-successful emphasis.
Paragraphs, headlines, tables, inline footnotes, link descriptions and caption
secondary strings were covered. All collected stm-fragment nodes have zero
children. post-blank is retained (unknown-tag example has two spaces); ordinary
child parents point at their Org owner, while caption secondary-string parents
retain the observed native nil behavior.

Seven additional string-backslash-close cases across those contexts correctly
recognize the full STM rather than the early native LaTeX close. Unknown root
tag and (x) enter native parsing without a whitelist; ordinary $x$ and native
backslash-parenthesized non-STM math remain latex-fragment. Inner link/emphasis
spelling remains opaque inside recognized STM; surrounding bold is separate.

Twenty-six code/verbatim/src/example cases (including incomplete and #bad
payloads) make zero STM parser calls and produce no STM strictness errors.
Strictness is therefore conditioned on actual Org-owned context, not raw shape.
Eleven incomplete cases and three malformed carrier-close cases report lexical
errors rather than fallback. Blank paragraph/heading transitions cannot supply
later closes. Native-invalid #bad is recognized lexically then rejected in
phase C in all seven transparent contexts. Thirty-seven native requests yielded
thirty successes and seven expected failures. Parser errors are never LaTeX
fallback for recognized candidates.

Native emphasis-conflicting quoted-star and a-star-space cases still yield an
incomplete-tree error within the truncated Org context. They are outside the
minimum compatibility target under the user's decision; no claim is made that
registration alone repairs them or that their success must become regression
coverage. This differs from incomplete text already owned by code/verbatim,
which must not invoke STM parsing at all.

Advice removal was verified after the scoped call, and subsequent ordinary Org
parsing again returned latex-fragment. Worker stopped and socket directory was
removed. No cleanup or cache consistency guarantee beyond these observations
is inferred.

## Feasibility conclusion and next action

Confirmed for the exercised compatibility matrix: a local Org object-parser
extension meets lexical identification, strict recognized-candidate errors,
STM-string boundary handling and opaque precedence without prescanning/masking.
This supports proceeding to E3 with this path; no concrete E2-prime failure
currently requires masking. It does not prove all Org object combinations.

E3 still needs object registration versus pseudo-object behavior, interpretation,
copy/transform, cache on/off, nested contexts and reproducible source/AST
roundtrip. E4–E6 ownership, model conversion, normalization and standard Export
integration remain unverified. The advice hook used here is an experiment,
not a promised public API or final implementation. No minimum-version change
or migration policy has been selected from this one-version result.
