# Phase 4 cross-directory INCLUDE and real extension review

User requested review of INBOX section17 around1470 on 2026-10-14. Baseline
native INCLUDE parameter revision1a254a7 verified, only user mirror dirty/index
empty. Plan is suitable as the next investigation/contract sequence. Review only:
no INBOX edit, implementation, build/test/download or external issue mutation.

## Adopted direction and bounded interpretation

Allow ordinary cross-directory Org content without requiring full source maps,
occurrence IDs or completion of STM resource rendering. Native Org owns include
selection/headlines/footnotes/ordinary links; actual dependency snapshots and source
consistency remain required. Real include/organize/blog packages tested through
standard interfaces, package-specific converters only if demonstrated necessary.
STM trees/resources/rendering stay separate; PDF primitive restrictions unchanged
unless independently selected/validated. No automatic general syntax/export scope.

## Refinements required before removing checks

- Current same-base rejection occurs in parse-include and fixed capture; private
  context uses root base, while native recursion supplies included-file directory.
  Removing equality checks alone is not a complete semantic change. Probe nested
  relative include resolution, link relocation, missing/symlink/physical aliases,
  selected/excluded dependencies, STM shielding and final transaction checks with
  actual original file identities. Preserve existing file/UTF8/depth/count/budgets.
- Distinguish authored source resource directory from target document base. First
  establish the target identified by original relative path at its source, then
  express it relative to a chosen destination if that consumer supports it. Merely
  resolving original text against the output directory changes its meaning.
  Never rewrite arbitrary STM strings. Any per-island directory must be associated
  until native parsing/resource encoding completes, only when required; hooks'
  generated/moved payload needs an explicit fallback/rejection policy. No universal
  origin map demanded. Resource-free STM from different directories should not be
  rejected solely because it could hypothetically contain resource strings.
- Existing ordinary Org raw paths remain relative in structured results, but
  org-texmacs-session.el native-file-target currently resolves marked hlink targets
  to absolute system paths on an owned body copy. Section17's unified relative
  final-document policy is a consumer contract proposal, not current behavior.
  Treat any serialization/session/output-base change as a separately bounded node;
  do not bundle it into basic cross-directory INCLUDE. Source base, explicit output
  base and native session/byte-only/PDF base need independent decisions/evidence.
- Bibliography declarations are not ordinary file links. Current Phase3 collector
  and normalized explicit identities use one root resource base; actual cross-dir
  relative declaration behavior needs locked probes before acceptance. Decide root
  document versus declaration-source semantics explicitly, including equal names
  in multiple dirs, selected/pruned declarations, global/managed discovery and
  explicit text priority. Preserve only necessary declaration identity/context or
  reject the affected ambiguous case; never silently read a same-named root file.
  Arbitrary unused/resource-free cross-directory content need not be blocked.

## Real extension and database evidence

Pin actual package and dependency revisions and project Org lock in an independent
flake, with isolated Org-roam DB/BibTeX/Org files, modes and paths. No personal DB,
global installation, lock updates or shell downloads implied by plan review.
Actual package modes/hooks/advice/database queries must run; controlled substitute
callbacks only diagnose boundaries, not establish compatibility. Test individual
packages first, then their joint lifecycle and plain HTML export/publish before,
during and after TeXmacs failures/cleanup. Managed bibliography and UUID remapping
require fixture-backed actual queries and observable native citation results.

Current private preparation suppresses mode hooks, supplies finite context, bounds
AST filters to key changes and scopes native helper bindings. Real packages might
need private-buffer state/advice context or additional file/DB reads. Prove whether
those are missing standard context, unsupported semantics or package bugs before
adding adapters. Audit actual file/DB dependencies of callbacks separately from
native INCLUDE and BibTeX receipts: those receipts do not automatically cover an
Org-roam query result. A owned captured query result/version check or documented
explicit validation limit may be needed; no DB/FS atomicity/sandbox promise.

Public source lookup attempted for the three links already in INBOX via web on this
review: all GitHub opens returned cache-miss/fetch errors. No shell fetch/retry or
new independent source verification. Interface descriptions remain user-reported;
actual pinned source/runtime inspection is part of execution, not this review.

## Acceptance and issue boundary

Suggested nodes: locked cross-dir probes -> ordinary-content contract/implementation
with explicit declaration/resource exceptions -> separately selected minimum STM
resource policy if needed -> pinned include/organize fixture checks -> joint/blog
HTML/publish noninterference gate. Stable maintained regression accompanies each
implementation node; real integrations may use a separate reproducible check.

Reproducible gaps satisfy investigation deliverables, not automatic interoperability
success or closure of issue#1. Report exact package/revisions/input/expected/actual,
owning layer and remaining remedy. Do not label an issue resolved while adopted
core use cases still fail. No full STM resources/GUI/image/PDF support required
before ordinary cross-directory content and real-package tests.
