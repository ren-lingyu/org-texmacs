# Phase 5 frontend/preprocessing plan review

User requested review only of INBOX section18 (starts around line1610) on the
committed Phase4 cross-directory INCLUDE/real extension coverage baseline.
No production/INBOX modification, test/build, staging or external tracking action
is authorized by this review. GAW normal memory loop remains authorized.

## Conclusion and sequence

Plan is coherent with completed working buffer + effective supported Org context,
one structural preparation/lowering path and independent native consumers. Full
unrestricted frontend calls may select the bounded preprocessing provider; explicit
direct APIs remain available for already completed working inputs. Subtree/region/
narrowing keep their documented direct selection contracts, with explicit refusal
of unsupported preprocessing semantics. No fallback from failed preprocessing.
Generic string export, full lifecycle, origin maps, native resource enhancements
and menu/key changes remain out of scope. Issue#1 closure should follow selected
architecture/frontend acceptance, not generic exporter or all future resources.

Suitable sequence:5a contracts/probes,5b full frontend,5c direct local-selection
regressions/unsupported boundaries,5d real extensions and three output consumers.
This review does not select implementation. Future version-sensitive probes must
use isolated independent flake/current project lock, not host Org. Phase4 build
permissions do not automatically authorize new Phase5 tests.

## Source-grounded points to clarify before 5b

1. Consumer transaction lifetime: org-texmacs--preprocess-convert already accepts
   a consumer inside original source/hook/composition/bibliography checks.
   PDF should lower and call org-texmacs-document-pdf there, as existing direct
   PDF adapter does inside org-texmacs--prepare-buffer. Returning prepared input
   then rendering outside the callback would not extend original dependency
   validation through PDF waits. A thin PDF byte adapter/shared internal dispatch
   can reuse this transaction; adding new public adapter is a choice, not needed
   solely to avoid duplicated provider logic. Each export prepares once; separate
   export invocations need not reuse one persistent input or transaction.

2. Guard coexistence already has evidence: tests/ert/ert.el loads ox-texmacs before
   preprocessing tests. org-texmacs--preprocess-stage excludes captured frontend
   guard by name from its stage hook list, while private generic calls still fail.
   Maintained component guard/isolation test and actual Phase4 fixtures ran in this
   environment.5a should verify frontend routing/no duplicate hooks/nested generic
   refusal rather than assuming guard removal or globally unbinding the hook.

3. Full-buffer default changes support profile: bounded provider requires full,
   unnarrowed ordinary headline levels, local source/base agreement and current
   path/alias/UTF8/64KiB-per-include/depth8/count32/256KiB budget constraints, even
   when the root has no INCLUDE. Existing direct API has different bounds.
   README/docstrings and negative cases must expose this consequence; do not
   bypass failed provider checks or silently loosen budgets to mimic old defaults.
   Already-preprocessed inputs use direct APIs, not heuristic auto-detection in
   frontend. Capture chosen route, options and original naming context before
   waits/prompts; transient buffer names must not choose destination.

4. Discovery remains explicit independent boolean, default nil recommended.
   Suggested source-buffer-local frontend option captured/validated for all three
   commands; final naming and source consistency follow existing contracts.
   This is a recommendation, not an adopted new public variable/name/ext-plist key.
   Decide whether it applies also to direct local-selection calls in5a; existing
   discovery transaction accepts subtree/region/options, so either enable reuse
   there or clearly state unsupported combination, rather than silently ignore
   an enabled option. Never infer discovery from cite syntax/preprocessing failure.
   False cases should assert no collector/acquisition invocation; true cases real
   organize discovery/key filters and missing refs. External hooks may themselves
   access DB regardless of this boolean: do not promise globally zero external
   reads merely because discovery is disabled. Provider responsibility unchanged.

## Verification matrix for future execution

Cross whole/subtree/region/narrowing with buffer/.tm/PDF, restricted ext-plist and
discovery off/on; represent active-region precedence and narrowed+subtree cases.
Check native bytes/PDF content, original source/naming, hooks/filters/discovery once,
source and dependency changes during serialization/rendering, no output creation or
existing-target overwrite on conversion failure, and temporary view/native cleanup.
Ordinary output write can still leave partial file on write failure; existing
overwrite policy is not atomic publication or rollback. Preserve this boundary.
Local selection unsupported preprocessing cases include known native directives
and real include mount/keyword fixtures; reject semantically incomplete output
without interpreting third-party DB internals or restoring origin maps.
Existing optional runner can exercise actual include/organize/blog with pinned
sources, synthetic SQLite and publication roots; no personal data/package patch.

Read-only evidence: ox-texmacs.el frontend option/selection/output functions and
guard; org-texmacs-preprocess.el stage/convert/public adapters;
org-texmacs-bibliography.el transaction/discovery flag;
org-texmacs.el PDF/readonly view adapters; tests/ert/ert.el load ordering and guard
case; current goals/project/backlog plus committed Phase4 acceptance. No new runtime
claim, native probe or public-web dependency was needed for this review.
