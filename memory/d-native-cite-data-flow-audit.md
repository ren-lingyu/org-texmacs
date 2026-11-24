# Node D Native Cite data flow audit

## Baseline and evidence

The local main and the supplied audit baseline both resolved to
`8f1dd58d52aad211345f57ec6c28110e30f6f7b2`. The worktree and index were clean.
This review used the deployed GAW memory, the [B/C design](bc-export-validation-design.md),
the [Native Cite N7 design](native-cite-0.7.0-plan.md), production source,
the introducing Native Cite commit `1824ac9`, the pending Input change
`54079fc`, the STM reader change `285a44b`, and the A2/B and C delivery.
Core evidence comes principally from `native-cite.el`, `native-cite-source.el`
and `model.el`. Native evidence includes the real style, recovery and nested
transaction cases in `ert-native-native-cite.el`.

The [probe archive](../archive/2026-11-24T09-28-01Z--8f1dd58/MANIFEST.md) supplies new runtime
evidence from exactly the audited project revision. The findings below
distinguish that run from source and history review. The supplied audit guide
is represented by its checked findings and scope here.

## Verification of the supplied findings

| Guide | Verdict | Confirmed source behavior and design effect |
| --- | --- | --- |
| 4.1 | Confirmed | In `org-texmacs-export.el`, `standard-input` realizes the final Org tree and exclusions, remaps Cite requests, prepares metadata and islands, freezes the Org query, projects affiliation, owns the pending Input, snapshots bibliography, completes the Model and finalizes. `standard-inner` checks known Document blockers for active Native print, fulfills, then dispatches the consumer. Retain Org's prepared selection and the C error boundary. |
| 4.2 | Confirmed | `prepared-cite-fulfill` calls `input-cite-result` twice. Both calls route through the public `input-create`, which runs ownership and finalization. Each rebuild owns mutable data, remaps graph identities, validates mappings and receives a new Model. It copies parsed bibliography at each attachment, even though both calls use the same worker-returned sources. New bibliography must still cross an explicit ownership boundary. |
| 4.3 | Confirmed with path qualification | `document-resolve` establishes semantic relations and effective nodes. `document-allocate` assigns collision-free native labels and records link destinations in a separate step. Both run on AST, islands, static labels and frozen context, with resource base consumed by resolution. Standard allocation uses frozen per-node Org references and local reservations. Independent allocation can call Org with a local reference cache. Neither takes bibliography entries or output. A saved resolver failure can prevent allocation from running. Preserve the original frozen result, including its failure case, if the standard graph is reused. |
| 4.4 | Confirmed | `cite-view` checks supplied carrier membership, request shape, citation-to-carrier agreement, print requirements, key order and files/style. It walks the effective tree, including metadata, for membership. It does not rediscover citations. Snapshot uses its files, finalization adds a prefix avoiding the static labels for the requested keys, and source attachment adds entries. Missing sources and missing/ambiguous used keys still require checks after parse. I2 formatting adds output without introducing entries or changing the source selection. |
| 4.5 | Confirmed by runtime | The success counts match the guide. Some calls have different duties. The lowering scan checks strees and supplies labels for collision avoidance and TOC allocation, and its emitted-label validation protects output. Sharing one static-label result between initial resolution and initial Cite planning is a candidate for a local intermediate value. There is no need for a persistent cache. |
| 4.6 | Confirmed | `prepared-copy` applies Org exclusions and creates the identity map from the live AST to the adapted graph. `query-snapshot` uses the original Org identities for querying and selects footnote definitions. `input-own` owns the final context and rich metadata, remaps secondary nodes, islands, query, Cite requests and post-blanks, captures presentation functions, and removes live fragment data. No narrow, proved replacement for these two boundaries emerged. |
| 4.7 | Confirmed | Independent `input-create` accepts explicit parsed bibliography and INFO declarations, as its docstring and the independent document test helper describe. `bibliography-collect` and `bibliography-plan` derive usage and entries from structural declarations, while `bibliography-native-plan` consumes a frozen request-based plan and checks its bindings. The independent and standard paths differ in input source, association and diagnostics. Their common pure concerns do not justify a combined pipeline. |
| 4.8 | Confirmed by source and fixture | A completed Input's AST and islands alias its Model fields. Pending Input owns the AST and requests before a Model with parsed islands can be built. Retain this representation. |
| 4.9 | Confirmed | Graph checks at ownership and consumption, worker transport and semantic response validation, output labels and provenance, and the source/bibliography guards each protect different boundaries. Preserve each. Bibliography fingerprint checks at separate times protect against changes between reads, native waits and public return. |
| 4.10 | Confirmed | `input.el` uses document resolution and structure helpers and the main library supplies the formatter called from preparation. No circular dependency or responsibility move requiring a separate module was found. The `prepared.el` file header and `prepared-discover` terminology predate `prepared-complete` using `org-texmacs--stm-read`. Carry the wording correction to E. |

## Ownership, failure isolation and publication

The N7 decision gave standard Cite requests a single owner graph, remapped on
copies, with no sharing between nested or repeated export transactions.
`1824ac9` introduced the general constructor-based attachment and its tests.
`org-texmacs-native-cite-requests-and-owned-result` verifies that carriers in
the new graph belong to its AST and that deliberate mutation of a prior
Input's request key does not affect the result. The latter records behavior
of the current private attachment. The Input and Model docstrings require
read-only use of all nested data. For a private completion path, the relevant
invariants are stable association keys, isolation from external data, and
separate graphs across transactions. Keep the mutation assertion if a helper
continues to promise an independent copy of an existing Input. If the helper
is replaced with transaction-local completion, move the contract coverage to
external graph and new data ownership, stable owned keys and no destructive
updates. The processor capture mutation case already protects caller-to-Input
isolation; `org-texmacs-model-and-export-share-owned-identities` establishes
that private `input-with-info` can retain Model identity.

Production callers of `input-cite-result` are the two sites inside
`prepared-cite-fulfill`. Other callers found are test helpers and targeted
tests. The first owned complete Input and the source-attached intermediate
are local values. The standard transaction and request result slots receive
the resulting Input only after fulfillment and any requested Document
lowering. These slots are assigned before some final guards, while the
public consumer returns only after the applicable checks. A thrown error or
quit before fulfillment completes prevents even those assignments. The
source and bibliography guards continue after the inner stage, at the outer
export and consumer boundaries. A patch must preserve those windows.

At the parse boundary the worker sees snapshot text encoded in a fresh
request. At format the formatter encodes prefix, entries and style into
wire text. The transport waits on its local client and validates response
framing and request identity. Formatting checks the response stree, labels
and reference binding, owns its body, and returns prefix, keys and entries
from the existing plan along with that body. It does not mutate the plan.
There is no supported callback receiving the in-progress Input at these
wait points. Later lowering callbacks consume read-only inputs; reentrant
exports still enter their own preparation. This is a source-level statement
about normal interfaces. Arbitrary advice on private functions or mutation
of their captured objects is outside that claim.

Own and validate newly parsed sources at the source boundary. The existing
copy validates path uniqueness, the source tree and entry/field shapes.
Select entries from those owned sources. At output attachment, distinguish
the owned plan references in the formatter view from the worker-derived body.
Preserve copy/validation for externally supplied mutable source and output
data, and establish explicit ownership for any body carried forward.
Keep the independent output association checks in lowering, including the
prefix, key order, used entries and output labels/references. Changes to
INFO and plan should use fresh update cells so preceding private Input
values stay valid even on failure. Reuse the frozen query, presentation
bindings and resolution with the exact graph they reference. Do not use
structural equality as a substitute for their identity relationship.

## Runtime probe

The final isolated Nix derivation was freshly built offline with Emacs 31.1,
Org 9.8.10 and TeXmacs 2.1.5. It forwarded all observed functions and used
a real bibliography parse and format. The Document fixture had a named
figure, a resolved internal link, two references to one footnote and a
static island label colliding with the first bibliography prefix.

| Observed calls | Document with print | Prepared Input with resolution failure | Document without print |
| --- | ---: | ---: | ---: |
| prepared-copy | 1 | 1 | 1 |
| input-own and input-finalize, each | 3 | 3 | 1 |
| document-resolve | 3 | 3 | 1 |
| document-allocate | 3 | 0 | 1 |
| input-cite-plan | 3 | 3 | 1 |
| cite-view | 4 | 4 | 2 |
| document-static-labels | 7 | 6 | 3 |
| bibliography-copy | 3 | 3 | 1 |
| Native bibliography parse and format, each | 1 | 1 | 0 |
| Document lowering in the recorded standard call | 1 | 0 | 1 |

The bibliography-copy count includes the invocation on the initially empty
slot. The copies with actual sources occur at I1 and I2. I0 to I1 and I1 to
I2 each changed Model, AST, islands, INFO, query, request view and resolution
identity. Across those stages, structural paths, island values, reference
and footnote associations, generated labels, citation usage and prefix
were equal within each call. The two named footnote references led to the
same definition, first-reference node and static anchor. The three captured
presentation function bindings were identical. I1 adds owned sources and
entries, I2 adds output, and I3 removes snapshot text while retaining its
identity state and digest. I2 and I3 share the graph, resolution, parsed
sources and plan, with a fresh INFO plist. With no print, fulfillment returns
I0 without either attachment.

The Prepared Input case saved an invalid-target failure. Each attachment
recomputed and reallocated the failure payload object while retaining the
same diagnostic values. The case never reached label allocation. A separate
independent lowering re-signaled the exact error and added no worker
requests. The source fixture's text, edit tick and point were preserved.

This probe compares selected observable structural fields and counts function
entries for the fixture. It does not test arbitrary dynamic advice, measure
performance, or establish stability of generated label text across separate
exports. No version-dependent Org question was found, so there was no
10.0-pre run. Existing Core mutation, ownership, malformed-result and
worker-error/quit tests and the real native recovery cases provide coverage
for the existing boundaries. No separate mutation/failure probe was needed
to decide the candidate scope. Snapshot mutation remains conditional on a
design that moves a guard or changes the wait/publication window. The probe
was not a production regression suite run.

## Candidate and remaining decision

The audited paths support keeping I0 as the private read-only structural
basis for the same Standard Export transaction. A small candidate should
preserve the initial ownership and finalization, own parsed sources and
select requested entries once, pass the enriched plan to native formatting,
and attach the validated output without rebuilding frozen document structure.
This keeps the exact resolution checked at C's Document boundary and the
failure that the Prepared Input path may retain. Continue using the existing
snapshot timings, public constructors and independent lowering.

The first candidate can share one local static-label result within initial
finalization. Reusing the snapshot's Cite usage view is viable if it stays
bound to the owned AST and requests through pending completion. It is a
separable follow-up if propagation costs more than the duplicate scan.
Either choice keeps public request validation and the lowering scan. No
initial-copy merge, module split, shared independent bibliography pipeline
or API change is justified by this audit. Do not carry forward a target
number of calls as a product requirement.

The maintenance decision is whether to implement this private completion
path. If approved, review the exact update API and its tests as part of the
implementation, with explicit assertions for old INFO/plan preservation
after failed source or output attachment, external mutation isolation,
stable I0 identities, frozen failure behavior and unchanged guard timing.
No production source or regression test was changed in this audit.
