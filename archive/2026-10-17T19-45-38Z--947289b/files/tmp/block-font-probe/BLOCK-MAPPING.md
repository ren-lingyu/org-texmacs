# Block mapping: historical correspondence and bounded current audit

User recalls mainly quote/center export and considers both now solved; original
minimal source is unavailable. This is a scoped reconciliation, not recovery of
unpreserved original bytes. Current snapshot is the delivered footnote repair.

## Historical evidence

GAW memory/block-table-implementation.md and archive
2026-10-15T11-15-33Z--4839029 contain paired baseline-probe/report.json and
a-probe/report.json, each10native cases. Old single/multiparagraph quote emitted
visible hquotej... markers. Explicit native quotation removed them; repaired
package output matches that reference, including30pt quotation indentation.
Center short/long paragraphs and center-with-list were already positive controls
in the old report. Thus quote has a concrete red/green correspondence; center has
retained positive native coverage, without evidence it was a separate old defect.

Issue4's remaining date/tag audit is in memory/issue-4-closure.md and archive
2026-10-15T13-12-14Z--8435e5d. It covers code/verbatim/lists/tables/metadata/heading
and inline/native wrappers. The archived October14 INBOX is an older Issue1 plan,
not the missing October16 readiness source; it does not recover this original.

## Current supported block inventory

| Source family | Native output | Maintained regression refreshed here |
| --- | --- | --- |
| quote | quotation(document...) | document-quote-uniform-quotation; document-quote-and-center-containers; pdf-block-quotation-and-center-layout |
| center | center(document...) | same container/PDF test, plus archived native nested-list positive control |
| src/example/fixed-width | code with literal document/line structure | document-preformatted-native-and-provenance; pdf-preformatted-lines-and-indent |
| unordered/ordered/description lists | itemize/enumerate/description, native item markers | document-list-containers-native; pdf-list-multiparagraph-native-layout |
| ordinary Org table | tabular/tformat/table/row/cell and supported cwith | pdf-table-alignment-frontend-and-native-layout |
| statement aliases | native statement/proof tag and recursive document | issue13-source-real-islands-and-native-statements (all admitted statement tags) |
| equation/equation* | native equation root containing opaque STM | issue13-stage2-native-layout-counter-and-reload |
| figure/figure*/table/table* | native big-figure/big-table variants and caption | issue13-stage3-native-prevalidation; issue13-stage3-exporter-native-pdf-and-reload |
| single-object named supported blocks | labels in appropriate native scope | issue13-stage4-native-label-placements |

ERT names above have prefix org-texmacs-. Additional Chinese native encoding test
is included in the14-test selector. Fresh14/14passed58.475623s in the registered
Noto matrix. Tests include real native PDF/readback/reload/counter/provenance where
specified; they do not assert every platform/style or arbitrary user STM tag.

No additional production block mapping defect was established. Unsupported Org
block families are explicit support boundaries, not automatically adopted new
features. Native caption-note layout limitations and arbitrary native STM remain
separate. No production file, index, lock, root flake or system config changed.
