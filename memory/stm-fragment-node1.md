# Node 1 implementation candidate

Node 1 is human-committed. All eight changed files are byte-identical to the
final tested Nix source snapshot; ordinary worktree and index are clean. The
user authorized a GAW delivery checkpoint. Exact project provenance is this
checkpoint's additional project parent, not an uncommitted candidate. Earlier
candidate/awaiting-commit wording below describes verification before delivery.
No ordinary Git history was modified by the agent.

The fragment-object module provides scoped registry/restrictions/advice and
interpretation, plus the independent full-buffer AST parser. It respects native
Org dispatch and opacity, strict carrier boundaries and post-blank. The syntax
module shares existing settings/link capture with the old parse module; it uses
the existing pure ownership copier without constructing a full model. Root
:org-texmacs-syntax stores independent heading/link syntax metadata, outside
Org document semantics. Node 2 must merge/validate explicit context and transfer
metadata as specified in the core plan. Node 3 must not use ambient syntax.
Existing discovery, native model parsing and Export paths are not migrated yet.
README adds only the new independent APIs and these boundaries.

Agent verification: Emacs 31.1, actual Org module origins checked. Nineteen
Node 1 ERT tests pass on both locked Org 9.8.10 and the previously pinned Org
9.8 source. Local full core passes 369/369 after assigning the existing TeXmacs
executable to the setup-capability check. That check initially failed because
bare texmacs was absent from PATH; it is not a worker dependency in AST parsing.

Final normal Git-flake Nix build exits zero for ert-core, package-lint,
org-texmacs package (warnings treated as errors), and treefmt. Formatting was
applied and restaged before the final run. Staged whitespace check passes.
No full nix flake check, native/PDF/example suites or complete release acceptance
is claimed. Logs for local runs remain temporary, not duplicate source archives.

Earlier path-flake treefmt attempt inherited Git hook configuration and failed
because git-gaw was absent in its sandbox. Correct flow is explicit staging and
normal Git flake input, not bypassing hooks. The initial failed sandbox staging
was followed by an inadmissible incomplete-input format run; that run is excluded
from final evidence. Final staged input includes all new files and passes.

Caption parent testing compares actual native secondary-list parenting, not an
assumption of nil/ordinary-child parent. Native Org copying remains separate
from model ownership. No parallel AST graph copier was introduced.

## Node 1 refinement acceptance

Reviewed the actual Org 9.8 parser chain and added a scanner instrumentation
regression comparing LIMIT with org-element--parse-objects END. That native
function narrows to BEG/END before lexing, including secondary strings. Actual
matching closes beyond headline, closed src/quote blocks, table row/cell, title,
caption and link-description boundaries all signal parse-error without creating
a fragment. Preserve this scoped dispatch; no headline regex, full-source scan
or masking is needed. Legal multiline STM remains covered.

Native org-element-copy retains the root metadata value by reference: mutating
the copied snapshot changes the original snapshot. This is a native custom
property shallow-copy boundary, not a new ownership promise. Source-to-AST
snapshot capture remains independent of source mutable heading/link values and
survives source destruction. Node 2 must use the existing model owner for strict
copying; do not patch Org generic copying. Traversal/interpretation retain the
metadata. The old parse-copy now delegates to syntax-copy.

Final agent-run acceptance: normal staged Git-flake Nix build of ert-core,
package-lint, package and treefmt exits 0; native log reports 374/374 core ERT.
Actual Org 9.8 source module-origin assertions and 24/24 object ERT pass after
the final test changes. Tests cover inner exception recovery, actual registry/
function/cache restoration, independent snapshots, source state on success/error,
external read/worker/Export sentinels, and complete lexical/Org roundtrips.
No native STM validation or complete native/PDF/example suite is claimed here.
The implementation is staged and uncommitted. Stop expanding Node 1; human
commit and subsequent Node 2 planning remain next, with no history writes by
the agent. No duplicate code patch archive is needed.

## Updated minimum compatibility baseline

The user adopted Org >=9.8.10 for the candidate v0.8.0 maintenance scope;
Emacs stays >=31.1. Package metadata, Nix version assertion, README and relevant
parser commentary now agree. No Org 9.8 compatibility layer or Org 10 dependency
is introduced. The existing functional and scope restoration tests remain.
E7's successful 9.8 experiments and prior Node 1 9.8 checks are historical
evidence, not current acceptance requirements or evidence of incompatibility.
Final normal Git-flake Nix core/lint/package/treefmt checks after these edits
exit 0. No full native/PDF/example acceptance is claimed by this update.

## Delivery verification

Read the final successful treefmt derivation to identify its immutable Nix source
snapshot; compared every changed file in the actual project commit against that
snapshot, all eight equal. This transfers the existing core/lint/package/format
evidence to the delivered content without rerunning unchanged tests. Next is
Node 2 planning; keep pending adapters, source writer and Export integration
separate from delivered Node 1. No source patch archive was created.

## Subsequent architecture revision

Node 1 delivered the independent Extended Org AST parsing entry under the
original freeze. Its scoped parser and registration, native location rules,
exception recovery, source state protection and syntax capture remain
delivered. Reuse those recognition mechanisms. The complete Model is the
long-term mathematical-document AST. The public role of the delivered
entry and the treatment of :value require a later implementation review.
Historical Node 1 validation covers the delivered code. The revised object
island contract is pending implementation. See stm-fragment-architecture-revision.md
and stm-fragment-core-plan.md.
