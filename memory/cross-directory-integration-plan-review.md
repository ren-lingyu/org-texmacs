# Revised Phase 4 working-buffer/context plan review

User rewrote INBOX section17 around1470 and requested review on2026-10-14.
Committed baseline is native INCLUDE parameter revision1a254a7; only user mirror
unstaged/index empty. Review only, no INBOX/project edits, new probes/tests/load,
downloads or external issue writes. Previous version of this review is in GAW
first-parent history; current text supersedes original-directory/resource-origin
and third-party-read interception prerequisites.

## Decision and interpretation

Revised plan is appropriate. User explicitly prioritizes preparation consuming
preprocessed working buffer plus effective standard Org context over support for
STM-native resources. Input is not plain text alone: own/capture file identity,
default directory, supported buffer-local parser/export configuration and necessary
INFO under an explicit preparation boundary. AST-first/pure lowering/canonical source
stay; this does not automatically require full generic export lifecycle/annotation.

Org owns include selection/recursion/headline/footnote/ordinary-link relocation.
Preparation consumes final working document; no original source/occurrence/AST
origin reconstruction. Standard final context governs relative bibliography and STM
resources unless an existing explicit standard interface provides a different
meaning. Managed bibliography paths already expanded by organize at node file are
explicit discovery results, not justification for inventing declaration provenance.

STM relative resources intentionally use each final document's base; standalone
versus included content may therefore resolve differently. This is the selected
semantic policy, not lost original-directory provenance that preparation must
repair. Resources expressible with final context may be handled at structured/native
boundaries. No source-origin table or package-specific registration required to
recover earlier directories. Do not reinterpret arbitrary STM strings.

## Clarifications for Phase 4a investigation

- Establish actual locked Org working-buffer lifecycle, file identity/default-dir,
  supported local parser/options and export INFO; compare finite current adapter.
  Final buffer plus normal context must be demonstrably sufficient for supported
  conversions, not inferred from valid text alone. Capture owned input before
  preparation/native waits, recheck original supplied input as documented, detach
  AST/INFO before consumers. No hidden ambient current-buffer dependency.
- Distinguish guarantees by boundary. Existing adapter's own native reads and
  acquired BibTeX have fixed snapshots/receipts. Those remain accurately described
  while supported. An external provider's files/DB queries are its preprocessing
  implementation; final working input ownership does not require interception,
  complete dependency enumeration or an atomic external-state snapshot. Actual
  wrong output or explicit stronger adopted guarantee can justify further work,
  but internal use of insert-file-contents/DB alone is not a prerequisite defect.
- Review any change to current public guard/result/context contract explicitly;
  don't remove current native-read validation merely as a side effect of new APIs.
  Clarify whether a future entry receives a completed working buffer or invokes
  preprocessing itself, who owns lifetime/context and when snapshot begins.
  Native pipelines/read adapters can remain providers above the same preparation
  boundary; investigation chooses the minimum suitable interface.
- Remove unnecessary same-directory exclusions based on locked native link and
  include evidence, retaining local file validation/UTF8/alias/budgets/native
  cycles/cleanup. Relative declared bibliography uses final effective context;
  missing files or unsupported syntax fail honestly, without guessing old origin.
  Native ordinary-link relocation must retain the target Org actually established.
- Structured raw Org file links currently remain relative, while native-file-target
  resolves marked hlinks to absolute system paths on owned body copy. Desired
  relative final representation is a consumer-policy investigation, not permission
  to silently alter existing serialization/session/PDF contracts. Source/final
  document position and destination-dependent native semantics must be measured.
- STM resource statement is direction, not a blanket claim that all image/include/
  executable primitives are already supported. Existing discovery grammar and PDF
  restrictions retain correctness; paths/tree transfer/rendering separately tested.
  Complete native resources/GUI rendering do not block plain cross-directory work.

## Real packages and acceptance

Local source review is complete for user-authorized clean repositories:
include ca62c8f, organize eaaee8e, blog778d410 (exact hashes in evidence.md).
Include global before-processing marker/native around-advice/physical line-search;
organize global Cite discovery and key-only AST filter; blog standard HTML export
with scoped filters all independently source-verified, not runtime-verified.
Include's direct saved-file reads and live DB lookup are facts for fixture design,
not requirements that org-texmacs replace them. Organize's live registry/DB queries
likewise belong to the provider; use actual synthetic DB fixture in integration.

Follow4a context+cross-dir probes/contract/maintained implementation ->4b real
include mode/hooks/advice/fixture ->4c real organize managed paths/UUID filters ->4d
joint TeXmacs and blog HTML/export/publish state-restoration regression. Pin package
and dependency revisions to project Org environment; personal databases/global
configuration not used. No loading/downloading/testing authorized by this review.
Controlled substitute callbacks diagnose interfaces but don't establish real
compatibility. Test provider output first, then final preparation/native results.

Reproducible gaps count as investigation output; do not call adopted failed cases
supported or close#1 simply because a gap is documented. Core capability unsupported
input and extension defects remain distinct. Minimal resource enhancement is
separate future scope; no generic export, DB/FS atomicity or callback sandbox claim.
