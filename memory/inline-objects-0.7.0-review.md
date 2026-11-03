# Read-only review: prerelease inline object compatibility

## Authority and retention

User supplies an in-conversation prerelease plan and explicitly requests read-only
review. This authorizes no production implementation or runtime experiment now.
The proposal describes entity/subscript/superscript support as mandatory once
adopted for execution, and CSL bibliography inline LaTeX support as conditional.
Current delivered baseline is f6aa2ae; project/index clean during static inspection.
Extracted goals, constraints, sample and review gates suffice; original guide bytes
have no independent retention need and no raw archive is selected. No tests/builds/
formatting, ordinary project writes or index changes performed for this review.

## Proposed scope and invariants

Extend pure document lowering for standard Org entity/subscript/superscript nodes,
using Org entity semantic data, correct text/math/native encoding and native rsub/
rsup where representable. Do not rescan ^/_ source. Explicitly reject unsupported
entities/contexts. Cover \alpha, \cdot, \rightarrow and ordinary text entities;
cover ^:t, ^:{}, ^:nil with real standard export, input immutability, order,
whitespace/base binding, mixed/nested scripts, native TM structures and rendering.
Model validity, Org serialization and document target support stay independent.
Do not change existing STM identities/subtrees or add a third canonical AST.

Conditional second feature first traces real .bib -> standard Org CSL processor
-> final Org AST. Minimal supplied sample is title={Properties of $A \cdot B$},
author={Someone}, year={2026}. Determine entity/latex-fragment/plain/other output,
what upstream retains/transforms/loses, and whether the first feature suffices.
Only then consider complete inline $...$/\(...\) through native TeXmacs converter,
with conversion before pure lowering. No custom LaTeX parser, preamble/package/
user-macro/full-document/display-math promise. Never reinterpret raw as LaTeX,
flatten or silently ignore unsupported data. Keep standard Cite/INFO/dynamic scope,
processor and normal acquisition; no title-field special case or extension adapter.
If recovery of lost Citeproc data, processor change or significant model/island
contract expansion is necessary, defer second feature without blocking release.
Preserve basic/raw refusal and all existing core/Cite/STM/PDF checks; synchronize
README/root summary/detailed notes if implementation is later authorized.

## Verified static findings and review amendments

1. document.el inline dispatch currently has none of the three requested branches;
   fallback is Unsupported inline node. context.el's projected keys omit
   :with-entities, :with-sub-superscripts and :with-latex; export.el owns only that
   projection. Thus this cannot safely be treated as a document.el-only change.
   Verify final AST AND live INFO for e:t/nil, ^:t/{}/nil and, if added,
   tex:t/nil/verbatim. Do not assume string-transcoding decisions have physically
   rewritten the final AST. Preserve options/AST filter and synthetic-node behavior;
   extend thin context projection where needed, not Org preparation. Pure inputs
   need fixed documented defaults; never consult ambient export/entity settings
   during lowering. Capture mutable custom entity semantics before native waits.
2. Worker encode-body distinguishes native STM syntax and ordinary literal leaves
   using path provenance and utf8->cork. A literal "<alpha>" is not interchangeable
   with a generated native symbol leaf. Entity implementation must preserve this
   distinction without marking an entire mixed paragraph native, and verify text/
   math font/layout. Do not universally emit every entity as math or as LaTeX.
3. Native rsub/rsup need base/order/whitespace proof in text, styled/title/caption
   and nested cases, including x_i^2 and x^{a_b}. Org scripts do not imply changing
   the entire paragraph to math mode; existing STM islands remain opaque.
4. Worker has native STM/BibTeX operations but no LaTeX conversion request today.
   Conditional experiment must assess capability loading, request/error protocol,
   output wrappers/math mode, Cork/Unicode round trip and exact snapshot ownership
   before worker waits. input ownership already remaps known AST nodes in context
   data; a separate node-keyed prepared conversion view may be locally feasible,
   but is a hypothesis requiring tests. Do not put arbitrary latex-fragment keys
   into the existing paragraph/footnote STM mapping or preselect a new model slot.
5. A returned valid/savable tree alone does not prove semantic preservation. Include
   malformed snippets and unknown commands in native probes; detect recovery,
   placeholders/dropped commands and mixed output, rather than assuming all importer
   failures signal. If a reliable bounded acceptance/error contract is unavailable,
   defer. Trace additional samples (e.g. alpha/scripts and a fraction) because the
   supplied cdot case can be reduced to entity/plain output without testing math
   structure. Distinguish normal CSL case conversion from lost math semantics.

## Sources and evidence limits

Current local f6aa2ae document/context/export/input/model/worker source inspected;
no actual .bib/CSL/native LaTeX experiment run. Earlier637ERT+actual4/all12checks
are baseline evidence, not support for proposed objects. Official Org docs confirm
e, ^ and tex controls:
https://orgmode.org/manual/Export-Settings.html
https://orgmode.org/org.html (Subscripts and Superscripts/LaTeX fragments).
Upstream citeproc-el documentation/source corroborates separate BibLaTeX-to-CSL
and output formatting/title-case steps; master is not the pinned runtime:
https://github.com/andras-simonyi/citeproc-el
https://raw.githubusercontent.com/andras-simonyi/citeproc-el/master/citeproc-biblatex.el
TeXmacs snippet converter exact API/result/failure behavior remains unverified.
A failed public source fetch supplies no converter evidence. Review conclusion:
plan is architecturally reasonable with these amendments; keep two features/gates
separate and await explicit execution request. No release state/tag/publication.
