# Phase 2 plan review — INBOX section 14

## Status and authority

Reviewed 2026-10-13 under the user's explicit review/GAW-update-only request.
Plan is appropriate as guidance: Phase 2a investigation → contract selection →
small independently validated Phase 2b nodes → full Phase 4 integration.
No Phase 2 investigation/prototype/build/test or production implementation was
executed or authorized by this review. A later execution request must define its
scope; prior Phase 3b test/network allowances do not automatically apply.

Review source: project INBOX.md section 14, starting line 1110 at this review;
full file SHA-256 5ed50e2c1f7f2e92c2ee08a35dcbc0822c341e23ce4b80de2fd5221cd8ee2eb1.
The line is only a locator, not a permanent identifier. Committed implementation
baseline is the opt-in bibliography discovery revision, verified against the
previous staged diff and prior validation. Phase 3b's tests remain historical
evidence, not new results of this review. memory/goals.md is normative;
memory/filter-contract.md and memory/bibliography-contract.md remain in force.

## Why the sequence is appropriate

- Source composition, STM identity and dependency provenance must be settled
  before enabling text-rewriting stages in production. Canonical source,
  captured original text and derived working document have different roles.
- Org stages must be checked against project-locked Emacs31.1/Org9.8.10. Phase 0
  found no after-includes hook and did not establish a complete native origin map.
  Earlier INCLUDE path relocation evidence is not proof of STM/file provenance.
- Avoid full annotate-info substitution, generic exporter interruption/global
  monkey patches, and treating manually invoked hooks as a full native lifecycle.
  Babel/arbitrary Lisp macros and uncontrolled external inputs remain excluded.
- Keep Phase 1 once-only key filters after valid mappings, Phase 3b opt-in owned
  bibliography/receipts, and pure lowering/native consumer boundaries.
- Full Phase 4 waits for stable composition. Optional small real
  org-roam-organize validation may happen earlier under separate scope, without
  blocking Phase 2 or closing issue #1.

## Clarifications to include in Phase 2a acceptance

1. Protect literal STM throughout preprocessing. Fake INCLUDE/SETUPFILE/BIND/
   MACRO/Babel-looking text inside inline or block islands must not acquire Org
   directive semantics. Cover authored, included, repeated, pruned and outside-
   selection islands. Compare identification/protection before and after native
   stages; do not assume Phase 3b bibliography-only masking solves composition.
2. Define identity beyond equal strings/offsets. Candidate provenance must
   distinguish source identity, inclusion occurrence, original range and working
   range, plus generated/replaced segments. Repeated identical sources and equal
   text from different sources need separate test evidence. Arbitrary hook edits
   may destroy origin knowledge: explicitly model generated/unknown origin or
   reject unsupported ambiguity, never invent file origins.
3. Separate hook and AST filter contracts. Section 14.7's "illegal return" needs
   a native-protocol definition; do not impose Phase 1's tree-return restrictions
   on before-processing/before-parsing hooks. Investigate actual return handling,
   order, backend/current-buffer state, parser refresh and exception cleanup;
   invalid resulting text/configuration is a separate validation question.
4. Specify selection/configuration semantics before a prototype is accepted:
   original subtree/region/narrowing boundaries vs rewritten positions, inserted
   material at boundaries, inclusion extent vs dependency closure, fileless/
   visiting directory origins, root/include keyword precedence and parser locals.
   Determine what to reject when mapping or effective context cannot be explained.
5. Resource provenance includes paths inside STM as well as Org file links.
   Relocating Org links alone is insufficient. Record relative-resource base per
   accepted origin and carry it to existing encoding/consumer boundaries without
   moving Org preprocessing into workers or sessions.
6. Define composition/bibliography integration as a separate explicit contract:
   original vs expanded declarations, included bibliography origin directories,
   global/advice paths, declaration view and fixed explicit text priority. Keep
   Phase 3b's original directory/receipt policy until a reviewed migration explains
   any necessary extension; do not implicitly enable general preprocessing in it.
7. Give automatic includes an explicit bounded dependency policy: admissible file
   types/encoding/size, depth/aggregate budget, cycles/repeated occurrences,
   symlink/remote/SETUPFILE options, read receipts and invalidation across hooks/
   native waits/output. These are questions to decide, not limits adopted now.
   Callback side effects remain outside a FS/DB atomicity or sandbox promise.

## Expected future investigation deliverables

Version-specific stage/input/output/side-effect table; runnable isolated
composition/provenance model; comparison of native-stage reuse vs bounded adapters;
explicit original/working/AST/STM/config/dependency/selection contract and failure
boundary; smallest Phase 2b node with testable acceptance conditions. Reuse
Phase 0 evidence instead of reproducing established facts without a new question.
Version-sensitive tests should use an independent flake with the current project
lock, not stale local Org. Distinguish controlled probes, maintained ERT, native
TeXmacs and real package/DB integration. Do not claim unrun native wait or actual
third-party behavior from a substitute. Phase 2b requires later selection after
these deliverables; issue #1 remains incomplete and closing footer is premature.
