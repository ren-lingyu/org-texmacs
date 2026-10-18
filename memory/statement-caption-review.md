# Statement NAME/CAPTION guidance: read-only review

## Source and authority

User requested review of updated ignored INBOX.md, not implementation/testing.
Read complete14447-byte UTF8 document: SHA256
4b1d4d81bb334919f903425408f91c95fee24874e937b072ad85d42b7570e4de.
Title Statement caption 与 label 支持完善, declared v0.5.0 design determined/
pending implementation, baseline main947289b5. Static review compares current
committed source/tests/README; no source/build/native test executed. Root user
flake overlay unchanged, index empty. User asks whether statement-local concat
rewriting could be acceptable, or surround could wrap first concat. This is a
question/proposed alternative, not authorization or final adoption of new shape.

Retention judgment on first read: no new raw archive. Relevant complete design,
explicit boundaries, review findings and pending decisions are extracted below;
original bytes do not add independent evidence beyond this operational extraction
and recorded source identity. Assume later INBOX bytes may differ. No skill update.

## Supplied design, pending review corrections

All16existing native statement tags: theorem/proposition/lemma/corollary/axiom/
definition/notation/conjecture/remark/example/note/warning/convention/exercise/
problem/proof, no new tag/config/public handler API or composite Issue9 semantics.
Three existing alias forms intended where Org permits them. Custom handlers do
not gain captions. NAME remains existing Stage4 identity; retained unused named
statement still emits one label. No extra label merely for an unnamed caption.
Org slug + Org export reference format/collision64attempt rules unchanged, same
validation-only resolver/final owned allocation/frozen resolution. Caption and
body local links share targets, ambiguity, forward/self links, static STM label
collision rules; no ID DB or second allocator. No mutable cache/source in result.

Long CAPTION -> native dueto with existing caption inline semantics: markup,
reference/hlink, file target provenance, multiple ordinary lines joined by spaces,
anonymous inline-footnote AST compatibility and existing native layout limits.
No caption STM discovery/parsing, citation/unsupported inline expansion or DSL.
Reject any explicit short caption, including empty short syntax normalized away
by Org; reject explicit empty long. No ignore mode or caption-detailed for these
statements; figure/table long/short caption behavior remains separate.

Proposed original tree rule: TAG(document...). Prefix label then dueto, omit
missing parts. First child concat: insert prefix inside it without nested concat.
Otherwise prepend prefix-only concat and retain original blocks/order. Empty body
with prefix allowed subject native validation; neither present -> original shape.
NAME-only deliberately changes current label-as-document-child placement, so
regressions must preserve native semantics while migrating intended tree shapes.

Extend affiliated validator to built-ins NAME+CAPTION, preserve custom rules and
other invalid metadata rejection. Extend private source evidence beyond keyword
names/NAME to raw caption declarations, owner/ranges/explicit-short presence and
pre-clean/scoped reparse consistency; validate only retained selected owners.
Capture on caption-only statements too, not only those with NAME. Pure lowering
must not reread source. Prepared AST can reject observable short AST, not infer
syntax erased before input construction. Respect owned evidence capability.

Extend whitespace prep and resolver secondary scan currently table/figure-only;
copy caption AST via existing general ownership code. Scan long only after short
rejection, preventing unresolved short-link errors from outranking short-caption
errors. Reuse/extract existing long inline caption conversion, never build and
throw away caption-detailed. Generalize statement prefix packing, remap STM/file
paths for body and caption, keep original STM subtree. Source/filter/worker failure
cleanup and existing lifecycle unchanged. Detect source-level errors before body
STM requests, no label allocation in preflight. Excluded invalid owners do not
block subtree/region/narrowing export; truncated owner/affiliates do reject.

Acceptance: all tags/forms and metadata combinations, multiline/empty/first-concat
and first-block bodies; unused NAME and frozen identities; self/forward/ambiguous/
missing/described links; static collisions; short incl empty and bad short links;
duplicate NAME, other metadata, scoped truncation/exclusion; original STM/file
paths/ownership/failed stages. Pinned generic/article native theorem/remark/exercise/
proof: dueto position/font/spacing/counters/references, empty and first-block
bodies, direct PDF vs tm reload. Preserve existing regression coverage, full flake
and default package gate when implementation is later selected; no test-directory
refactor, no global native-style patch or general source/Nix restructuring.

## Findings and pending recommendations

1. Critical provenance edge in original section5: first concat may be an opaque
original STM root, e.g. statement starts with raw texmacs block whose root is
(concat...). Cannot merge generated label/dueto into it and still claim entire
original subtree/STM root paths remain intact. Statement location alone does not
prove rewrites safe. Either only merge into a known Org-generated non-STM concat,
or wrap original root. Add named/captioned raw-concat and nested/file STM tests,
assert original-root identity within the owned lowering result and exact paths.

User suggests surround. Recommended candidate:
TAG(document(surround PREFIX "" ORIGINAL-FIRST-CONCAT) REST...), PREFIX contains
label then dueto. Original first concat preserved intact; with child indexing,
old first-root path(0) becomes(0 2), body descendants follow that prefix; caption
provenance separately packed into PREFIX. Same wrapper can serve Org-generated
and STM first concat, avoiding provenance-dependent flattening. This changes the
supplied section5 target tree and needs explicit adoption/native validation;
no claim current native layout/counter behavior already proved. Non-concat/empty
prefix-only branch remains original proposal. No prefix -> no new wrapper.

2. Existing parser exception: begin_example is Org example-block/literal code,
not formal example. Formal example supports statement example/statement_example,
not direct alias. README748 and ERT issue13-source-syntax-and-recursion already
assert this. Correct section2/8.1 to all16tags with applicable existing forms;
never turn literal example into statement or mistakenly expect16x3source cases.

3. Section8.2 repeated-export wording conflicts with4.1 random reference boundary:
same prepared input's repeated pure lowering/serialize/PDF must reuse frozen IDs;
a new source preparation/export may allocate exactly once again and receive new
Org references. Specify both, not a cross-export no-allocation/stable-ID promise.

Two precision notes: ordinary repeated CAPTION lines are intentionally accepted,
so section7 duplicate declarations must mean duplicate NAME/invalid structures,
not all repeated CAPTION. Body-STM-before-error guarantee must retain Stage1
bibliography exception: native bibliography may already run, body STM not
submitted; do not turn section8.3 into zero-native-request assertion with bib.

## Adopted user supplement after review

Source is the user's next conversation message headed Statement caption 开发计划
补充修订, not a later read/claimed replacement of INBOX bytes. It adopts the
following corrections and ordering; no implementation/test execution requested.
No raw archive needed: full operative supplement and unresolved boundary extracted.

Independent native gate MUST precede production implementation: compare direct
prefix-in-concat with surround(PREFIX,"",ORIGINAL-FIRST-CONCAT), including native
readback, PDF and saved-tm reload. Validate dueto after native statement title and
before body; whitespace/newlines/font; label counter binding; internal references
and actual PDF destination positions; generic/article; first paragraph containing
STM/math and multi-paragraph bodies. Prefer surround if equivalent; proposed
fallback is original direct concat insertion if native semantics/layout differ.
First non-concat/empty body retains separate prefix-only concat unless native
evidence supports unification. Always remap both STM/file path prefixes; no
runtime selector between two implementations. Native behavior still unverified.

Example exception now adopted: all16tags share NAME/CAPTION semantics, but formal
example only statement example/statement_example; Org literal begin_example
unchanged. No16x3syntax assertion. Identity correction adopted: same prepared input
reuses frozen IDs across repeated lowering/consumers; fresh preparation may
allocate new references once and produce different bytes, preserve internal
identity relationships; slug/label format/collision64/unused NAME/post-freeze
integrity unchanged. Tests compare relationships, not random IDs across exports.

Adopted implementation order: native comparison -> select one structure -> extend
caption evidence/strict-short rejection/inline prep -> extend resolver/reuse frozen
allocator -> prefix lowering/provenance -> ERT/native/PDF/full build gates.
All other original design semantics retained; no immediate production/test action
or new runtime config authorized by the supplement alone.

Remaining review recommendation: fallback cannot automatically rewrite an opaque
original STM concat root while the original guidance still requires preserving
that subtree. Direct insertion into an Org-generated non-STM concat is compatible;
for original STM roots retain a structure-preserving alternative or stop and
resolve native evidence/contract, rather than silently weakening provenance.
This fallback qualification has not yet been explicitly adopted by user.
Multiline CAPTION acceptance and bibliography/body-STM preflight precision remain
original review clarifications, not asserted new user changes.
