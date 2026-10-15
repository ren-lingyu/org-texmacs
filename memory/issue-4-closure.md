# Issue4 remaining repair and semantic audit

Active implementation on committed quote/table baseline. Final adopted policy:
date metadata timestamps emit complete raw-value as literal text, including
angle/square delimiters and internal spaces; no formatting/normalization/analysis.
Private helper org-texmacs--document-date-timestamp-text(raw) returns string,
default identity; advice callers may customize display. Capture function once in
prepared input/internal INFO, protect input/result strings. Invalid raw/internal
structure or nonstring result error; native encoding error remains explicit.
No public formatter config or extra structured TeXmacs metadata. Precedence,
EXPORT_DATE/external date/options suppression and mixed rich text unchanged.
No generic timestamp support outside date metadata. User final plan supersedes
brief delimiter stripping and earlier structured/rejection alternatives.

## Validation and boundaries

User authorizes this round repeated sequential checks.probes120s/focused180s/
integration120s/full flake600s at path:./tmp/issue-4-closure, locked dependency
network/store/cache/tmp writes and native result/related text-definition reads/
copies. Root lock/user flake/original examples unchanged. Independent locked flake only, source
snapshot/extension hashes and root user flake preserved. Baseline413core known
from preceding task, not current task result. Planned red/green date cases,
advice ownership/snapshot/error, actual native literal date/PDF and bounded
native definitions/reference/PDF audit. Native readback alone insufficient.
#4 remains open until full acceptance and user final commit; no ordinary staging
or project commit authority. #7 performance/#9 names/native typography out of scope.

## Audit matrix (pending runtime validation)

| Group | Existing evidence to reuse | Remaining evidence |
| --- | --- | --- |
| quote/center | maintained structure + native PDF reference | rerun regression |
| code | three static forms/tab/-i/literal/native readback | native newline/indent/blank PDF geometry |
| lists | three types/nesting/markers/native readback | multiparagraph/nested/description native layout |
| tables | shape/borders/alignment/caption/reference/provenance | caption numbering/short-long/reference native semantics |
| inline | nested markup/literal/linebreak readback | native tag definitions/decoration meaning |
| metadata | title/author/date structure/readback | raw date and rendered title/author/date |
| headings/TOC | five levels/number policy/static links | actual native numbering/TOC/reference agreement |
| footnotes/links/citations | named/anonymous PDF numbering, citation PDF | reuse plus definition/label/hlink/with-bib audit |

Retain per-group actual source AST, native tree/definition, relevant test and
bounded conclusion. Fix confirmed in-scope bugs only; external native issues
record ownership and do not broaden this work. Select necessary raw text archive
at final validation; do not archive whole tmp or binary outputs.

## Implementation progress

Document/input modules implement literal raw plus private function capture in
internal INFO; copies isolate advice argument/result, invalid return rejects.
README documents raw and private-only advice contract. Five new tests replace
old complex-timestamp rejection; one extra worker-wait snapshot test added.
First probe failed loading an extra closing parenthesis in new ERT, corrected.
Second diagnostic hit existing preparation preflight rejection before recording
complex date AST; switched AST-only acquisition to Org secondary parser and
catch export failure separately. These are diagnostic attempts, no baseline
semantic acceptance yet. Old production snapshot frozen for focused red run.

Valid red focused:31tests,26pass/5newfail,18.039367s. Frozen production equals
baseline; new tests intentionally differ. Baseline probes now retrying AST-only
date recording plus six native cases. No repaired runtime acceptance yet.
