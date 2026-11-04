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

Status: intake and exact N5 candidate verification complete. Prepare common fixture
matrix and A/B/C checks, inspect outputs and real rendering before conclusions.
