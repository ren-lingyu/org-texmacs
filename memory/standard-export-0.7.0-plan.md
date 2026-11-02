# v0.7.0 Standard Org Export Integration: approved execution plan

## Authority and execution boundary

The user approved the revised plan with "Implement the plan" after supplying
the six-point execution revision note and confirming the planning choices.
The active session date is 2026-11-03. Baseline is local v0.6.0,
8ae564724b3919abc155df174bedd9b5078285c3. Intake ordinary main/index and GAW
worktree/index are clean; public GAW status/check pass. Existing implementation
and historical665ERT evidence remain v0.6.0, not new0.7.0 validation.

This approval authorizes the scoped implementation, documentation, isolated
experiments and validation described below. Disclose exact expanded commands,
scope, writes, network behavior and timeouts before running them. It does not
authorize ordinary project staging/commits/tags/pushes, lifecycle changes,
root lock updates or unrelated changes. The user commits each ordinary node;
verify delivery before advancing. Normal validated GAW memory maintenance,
explicit memory staging and public GAW checkpoints remain authorized.

The first two execution steps are mandatory and ordered: update memory and
create this plan checkpoint; then add the CHANGELOG-only TODO v0.7.0 entry.
Wait for its human commit and verify it before any production implementation
or stage-A experiments. Do not infer continuous development across this gate.

## Fixed architecture and decisions

- Make real `(org-export-as 'texmacs)` the standard entry. Org owns preparation,
  selection, options/INFO, hooks, INCLUDE/SETUPFILE/macros/Babel, AST filters and
  Cite. The project consumes prepared Org structures and owns mathematical
  models, native lowering and outputs. Do not copy Org preparation, recursively
  expand INCLUDE independently or add extension-specific compatibility logic.
- Standard semantics and AST-first are mandatory together. Reuse native Org AST
  plus parsed STM islands; no third AST or routine STM text round trip. Standard
  preprocessing output is the input; original STM byte equality is not required.
- Preserve independent model construction/inspection/transformation/normalized
  Org output, pure input construction/lowering and native consumers. Generic
  model context stays separate from full INFO, runtime caches and output policy.
- Source-buffer conveniences survive only as thin consumers of shared standard
  preparation. Preserve their distinct return types where feasible. Refactor,
  deprecate or remove APIs that cannot meet this constraint; supply migration
  guidance, not compatibility wrappers retaining parallel export semantics.
- Support native visible-only; reject body-only until a fragment contract exists.
  Async/nonblocking, Issue9 and general syntax expansion are outside this plan.
- Org9.8.10 is implementation/acceptance baseline. Raise minimum only if the
  selected mechanism requires it; do not duplicate export internals for9.8.
- Basic compatibility is not a release blocker if a standards-compliant TeXmacs
  Cite processor supplies the required semantics and actual extension acceptance.
  Other packages must not need backend-specific adaptations.
- Integration points, including inner-template, remain hypotheses. If evidence
  invalidates them or requires changed confirmed public contracts, report the
  counterexample and revise the plan before dependent production implementation.

## Ordered nodes

### 1. Memory plan checkpoint

Coordinate goals/project/backlog/evidence/current with this plan and the six
revision requirements. Review the full candidate and create a memory-only public
GAW checkpoint before changing ordinary project files. This checkpoint adopts
planning, not a validated callback/processor design; no new project parent is
needed merely for adopting the plan.

### 2. CHANGELOG-only first project delivery

Add `* TODO v0.7.0` with categorized unchecked feature entries: real standard
backend; prepared AST/STM adapter and shared structured results; standard
selection/options/filters/references/footnotes; Cite/real extensions; text/PDF
outputs; API migration/duplicate preparation cleanup; docs/examples/regression.
Explicitly call these planned changes. No DONE/CLOSED/frozen identity, detailed
release file, version bump, README or source edit in this first candidate.
Prepare tmp/commit.md from the full resulting diff as expressly required by
the approved node workflow, even before human staging; this task-specific
instruction selects the worktree as draft-message evidence. No agent staging.
Wait for and verify the human CHANGELOG-only commit before stage A.

### 3. A: isolated feasibility, then minimal production backend

Use an isolated flake and keep existing frontend tests intact. An independent
backend or controlled registration/guard replacement is allowed in the prototype;
repeat key paths with actual texmacs identity before accepting conclusions.
Verify INFO/backend filters/Cite selection/extension dynamic state under that
identity, not only a temporary backend name.

Investigate inner-template first, including prior org-export-data traversal,
normalization/memoization/transcoder effects and later template/body/final filters
and Cite finalization. Do not assume a root org-data transcoder bypasses traversal.
Do not default to advising/copying org-export--annotate-info. Prove plain Org can
become an owned model, use existing lowering and produce native text.

Architecture gate: within one real org-export-as transaction, deliver prepared
AST, owned model and completed native document to text/source-buffer/PDF consumers.
No repeated preparation/hooks/AST filters/processors or reparsing serialized .tm.
Investigate a scoped internal result-delivery mechanism without selecting it in
advance. Verify exceptions, resource cleanup, nested-export isolation and exactly
once processing. Distinct consumer return types must use this common mechanism.

Move Cite/output risks into A: processors returning strings, Org elements and
secondary strings; calling org-export-data internally; strings wrapped as raw.
Define raw target semantics, never assume ordinary literal text. Determine basic
support versus a standard TeXmacs processor without round-trip lowering.

Prove native .tm bytes/text reversibility, coding systems and standard file/newline
behavior. Investigate structured result delivery versus later string processing,
especially avoiding meaningless text postprocessing for native PDF. PDF directly
uses the completed native document. Its compatibility policy permits known
compatible/provably no-op/PDF-irrelevant filters/finalizers and conservatively
rejects arbitrary callbacks whose compatibility cannot be established. Do not
predict arbitrary callback effects, execute them twice for probing or reject
solely because a global filter variable is nonempty. Examine the effective
backend/processor combination and preserve applicable standard semantics.

Produce source/runtime evidence, counterexamples, selected callback/result/output
contracts and retention assessment. Only after all gates pass implement/deliver
the minimal production backend. If they fail, revise the plan first.

### 4. B: STM and prepared AST adapter

Resolve retained deferred properties while live. Own/copy/remap Org parents,
secondary objects/captions, islands, references and necessary consumer data;
do not blindly copy full INFO/runtime caches into model or pure input. Consume
Org ignore-list and existing interpretation decisions without re-pruning or
recomputing option precedence.

Try late one-pass recognition first for inline/native/math-environment STM and
preprocessing-generated content. Add minimal earlier protection only on proven
counterexamples; Org still owns INCLUDE recursion. Final AST is authoritative.
Distinguish buffer-backed original/preprocessed nodes from filter-created or
replaced nodes lacking reliable begin/end/source mapping. Missing positions alone
do not reject legal insert/delete/move/replace transformations. Promise automatic
synthetic islands only when valid structure/properties supply complete STM input.
Verify existing mappings support positionless keys; extend the thin structured
adapter input protocol if necessary without a third AST. Fail malformed,
cross-boundary or unidentifiable islands explicitly; never guess repairs or
reparse the whole buffer in place of the final AST.

### 5. C: standard semantics, references and footnotes

Use Org options/backend declarations, SETUPFILE/macros/Babel/hooks, full/subtree/
region/narrowing/visible-only, options filters and legal arbitrary AST filters.
Retire custom merging/selection/pruning/key-only-filter preparation from the
standard route. Document changed policies/error priorities and maintain valid
source/configuration snapshot and worker failure contracts.

Org supplies target recognition, numbering rules, footnote definitions and
queries; preparation does not promise complete format-independent output.
Lowering may call standard Org reference/number/footnote APIs and must generate
native labels/references/notes, check STM static labels/target conflicts and
retain native numbering/typesetting structure. Do not delete these target-format
responsibilities as duplicate preparation.

### 6. D: standard Cite and actual extension acceptance

Use ordinary bibliography acquisition, processor selection, filters, citation/
bibliography processing and applicable finalization once. Maintain the complete
A return-value/raw matrix. Define supported basic behavior from evidence; where
needed use an ordinary Org Cite TeXmacs processor returning structured results
with native island associations, not serialized STM awaiting reparsing. Reuse
effective bibliography/keys/INFO, not extension-specific discovery/key handling.
Pin complete actual org-roam-organize/dependency revisions and use normal mode,
real isolated database and standard entry. Verify managed UUIDs, bibliography,
INFO, nested exports and errors. Investigate csl/other combinations and publish
an evidence-based support table with explicit unsupported errors.

### 7. E: consumers, API migration and cleanup

Standard entry returns text; native serializer/PDF retain byte contracts. Text
runs supported standard string filters/finalizers. PDF follows the A compatibility
contract using the shared completed document, without .tm reconstruction.
Migrate three interactive commands and feasible source-buffer conveniences to
the shared preparation/result delivery. Preserve useful naming/overwrite/result
buffer/failure cleanup contracts. Merge/deprecate/remove preprocessed/discover
variants and old discovery flag; unmappable arguments fail with migration advice.
Delete old code only after callers migrate and no independent use remains.
Complete README/examples/version metadata0.7.0 and detailed release manuscript.
Human controls TODO transitions, CLOSED, tags and publication.

## Experiments, validation, retention and delivery

Use root tmp only after ignore/tracked-path/symlink/realpath checks. Isolated
flakes use fixed source snapshots/lock and fresh HOME/runtime state; no Git/agent
metadata/unrelated cache copying or root lock updates. Reuse existing core,
native, PDF and integration test systems. Focused experiments default120s;
complete checks plan600s. Expand/disclose exact commands, purpose, scope, writes,
possible dependency network and timeout before execution; no broader silent
retry. Run focused checks first, full checks at node completion and package/
example builds when relevant; do not repeat unchanged passed gates needlessly.

After every experiment assess retention promptly. Persist conclusions, input
identity, environment, failures and limits in memory. Archive only independently
useful text flake/scripts/fixtures/diffs/reports/necessary logs, with provenance,
byte counts/SHA256 and exact verification through the archive skill; no directory
dumps, binaries, databases or caches. Archive checkpoints stay separate from
memory. A sufficient maintained regression plus memory can eliminate raw capture.

Acceptance covers real identity/shared results/exact invocation counts/nesting/
cleanup; all standard selection/preparation/filter/reference/footnote cases;
original/generated/synthetic STM/Org-looking strings/association failures/ownership;
Cite return/raw matrix/real extensions; text encoding/reload/native PDF and
compatible/rejected effective filters/finalizers; existing document structures,
independent core, unrelated backends, source preservation and worker/output errors.
Old frontend success is not new standard-entry evidence. Update changed-contract
tests and migration docs rather than preserve obsolete implementation assertions.

Before each production node report overall progress. At node end sync README/
CHANGELOG, review complete diff, prepare tmp/commit.md and wait for human delivery
verification. Maintain GAW promptly and checkpoint consequential decisions/phases.
Complete release requires genuine standard entry, one Org preparation pipeline,
AST-first/shared lowering, standard Cite plus actual extension acceptance, valid
structured delivery/text/PDF contracts, explained API migration/no unreported
regressions and full Nix checks. Neither standard semantics nor AST-first may be
weakened to preserve a candidate design or stage schedule.
