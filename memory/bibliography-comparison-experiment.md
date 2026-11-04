# Bibliography input architecture comparison: isolated experiment contract

User supplies and authorizes the comparison Note after accepted N5 candidate.
Do not alter production/API/N5 candidate or reopen v0.7.0 B. Original user note
is fully distilled here; no raw conversation capture needed. Future implementation
is proposal-only. Current HEAD6c7ac07 plus exact accepted four-path N5 worktree;
159input manifest remains inline-objects-0.7.0-n5-inputs.json. Worktree is not a
committed runtime state. Keep all experiments/report under ignored project tmp.

Questions: isolate existing BibLaTeX->CSL conversion from CSL formatting; test
standard CSL-JSON and a fixture-limited custom getter; compare native BibTeX
parse/format without restoring old Org preparation. Same semantic matrix across
routes: ordinary punctuation/case/braces/escapes, Greek/Chinese/accents/combining/
math Unicode, eight LaTeX forms plus escaped delimiters/unclosed/unknown/macros,
and three requested STM forms (plus valid one-child rsub control if needed).
Separate source spelling, intended field semantics, data preservation, actual
structured math, native layout and standard Org interoperability.

A1 real BibLaTeX functions + standard source transaction; trace raw parsed title,
CSL title, Citeproc formatted result and final Org AST. A2 equivalent direct
CSL-JSON, plain and italic styles. No regex-only inference. B fixture-only getter
uses existing parsebib and ordinary conversion of non-target fields, controlled
title replacement; itemids/list requests/errors/duplicates/copy/repeat behavior.
Independent processor construction and scoped oc-csl getter-constructor replacement
only, no persistent advice or finalizer change; verify HTML isolation/cleanup.
Record lack of public oc-csl getter injection. No full new parser or broad mapping.
C existing parse-bibliography/format-bibliography and native TM/PDF only; inspect
keys/type/fields, loss versus plain-style omission versus render failure. Include
journaltitle/date/doi/url/author and traditional journal/year controls, sorting,
labels and recovery. Future native integration must use standard Org Cite.
No repeat of N4 snippet converter unless new evidence requires it.

Deliver reproducible minimal drivers/fixtures/versions/commands, two-route report
with per-category findings, failure stages/classifications/repeats, recommended
direction and unresolved gaps. Prefer selective immutable text evidence after
review, never whole tmp trees or binaries. No production implementation commitment,
CSL title-field-specific long-term hook or new math AST. Preserve existing B
DEFERRED and human N5 commit/release controls. User standing Nix variants authority
applies to these bounded isolated comparisons; disclose commands/effects/timeouts.

## Completed evidence and decision

A120route/style records (30fixtures x Bib/JSON x plain/italic), B60getter/style
records and C30native records complete. Every principal case runs twice with
stable semantic structures/failure classes; generated Org labels are normalized
by definition/reference identity, original trees retained. Three final ERT checks
exit0, not a declaration that allcases succeed. Fresh accepted A9.760805s,
B10.306674s, C11.415187s. Exact N5 all159hashes/message/index rechecked unchanged.
No production modification, full-product regression rerun or B reopening.

Report: tmp/bibliography-comparison-report.md; per-case table/classifications and
original result JSON/protocol/HTML/sort/font controls in
 tmp/bibliography-comparison-evidence/. These are useful local locations, not the
sole durable evidence. Selected immutable28text sources plus manifest are at
archive/2026-11-04T04-38-25Z--6c7ac07/MANIFEST.md, preserving project-relative paths.
Seven minimal drivers/config/generator, cases.json and two styles reproduce all
individual bib/JSON inputs byte-exactly in a separate tested replay directory.
Do not copy entire temporary trees, N5 release artifacts or binary assets.
Metadata binds6actually viewed images to accepted final asset hashes and records
all native TM/PDF/PNG sources/hashes. Full dependency sources are omitted as
recoverable from lock/build inputs. No invented Citeproc Git revision; library
header0.9.4/package20260113.1047, project baseline and Nix outputs are recorded.

1. JSON route delivers every30title's declared CSL value unchanged to the getter
boundary in bothstyles. B preserves raw math/STM title and all non-target fields
via existing Parsebib + citeproc-blt-entry-to-csl, with explicit equality checks.
Standard oc-csl reads JSON already; no new processor needed for that input form.
2. Existing Bib conversion preserves dollar-alpha/cdot but loses both before
underscore, removes frac structure, changes uppercase math product to lowercase
and removes command. Actual function calls confirm this; no regex-only inference.
3. citeproc-proc--parse-csl-var-val changes STM ASCII doublequotes to curly quotes
before rendered Org, including JSON. Final titles are link/link+italic; all tested
islands empty. Native BibTeX also keeps STM as literal title text. No structural
STM-through-CSL success is established. LaTeX fragments from JSON/getter survive
but current pure lowerer rejects them; 22/60 route/style cases reject explicitly,
38lower without implying mathematical fidelity. Bare cdot from JSON/getter works
as existing entity; unclosed math becomes ordinary Org text/entity/script, not
valid fragment success.
4. Getter itemids/list/duplicates/missing/invalid-type outcomes and repeats are
saved. It rejects duplicate explicit pairs; Parsebib coalesces duplicate source
keys before getter checking (last entry wins). Independent citeproc-create/render
works. Scoped org-cite-csl--processor wrapper switches getter only by INFO backend;
actual nested/after-scope HTML uses original getter, function identities restored,
finalizer unchanged. No public oc-csl getter option found. This is an experimental
private-interface dependency, not adoption of permanent advice. Whole-title raw
replacement leaks {RNA} braces in mixed math title, so it is not a complete mapper.
copy-tree fixture graph isolation is not full mutable-string ownership proof.
5. Native parse/format produce correct inspected math for valid examples including
fraction, alpha_i, product and protected RNA+math. Unknown/unclosed math/macros
are accepted with placeholder/repair/assign structures, not explicit rejection.
All requested fields and unknown fields survive parsing; plain omits journaltitle,
date,doi,url/customfield; journal/year control works. Sorting z/a/m yields a/m/z
and [3,1,2] with matching labels. Advanced citation/locator/style equivalence is
not certified. No old source preparation or citation traversal is restored.
6. Unicode values survive as Unicode/native encoding. Native Greek/precomposed
accent/math glyphs look correct; CJK/U+0301 show placeholders. Direct Unicode
and Fandol+chinese control also fail, so do not assign the issue to bibliography
parsing alone or claim all project Chinese output fails. Native encoding/font/
layout cause remains unresolved and is not an authorized production fix.

Choose user Note conclusion2: CSL data usable, mathematical handoff still needs
its own contract. Retain production status; do not install long-term getter
compatibility yet. Native route is evidence-backed future alternative for math,
not a demonstrated full BibLaTeX replacement. Proposed future gates only: decide
JSON versus limited Bib adapter/public injection; explicit math handoff/ownership
and rejection; separately native Cite processor field/style/error feasibility;
independent native Unicode diagnosis. None is selected for implementation.

Driver-only failures fixed/revalidated: JSON plist-array encoding, random-label
comparison, exclusive file overwrite in repeated rendering. Extra dependency
metadata eval failed because legacyPackages lacked that citeproc attribute; it
supplies no source-revision evidence. All final drivers and original output bytes
are preserved, no failed gate is silently counted as acceptance. GAW valid; no
ordinary Git writes. Next: user reviews report, pending N5 human commit remains.
