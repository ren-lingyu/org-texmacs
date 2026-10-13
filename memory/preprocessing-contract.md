# Selected initial Phase 2b composition contract

User requested Phase 2a and 2b execution on 2026-10-14. Research first; bounded
implementation follows this selected profile. This is a target contract until
maintained production/native tests pass, not a current support claim.

## Scope and native-reuse boundary

Separate opt-in prepare/document/.tm-byte APIs, full unnarrowed source only.
Existing explicit source/dispatcher/bibliography APIs retain their defaults.
Initial native heading policy requires ordinary levels (odd-levels-only disabled
both for the source and native defaults); otherwise independent native temp parser
level normalization can disagree with the final captured parser. Reject explicitly.
Source buffer, original text/config/locations/explicit BibTeX are captured before
callbacks; original canonical text differs from owned composed working text.
Subtree/region/narrowing are rejected by the new adapter pending a real position
and dependency-closure policy. No generic org-export-as/publishing adaptation.

Run captured before-processing hooks, native INCLUDE over owned protected mirrors,
captured before-parsing hooks, existing private parse/context, once-only Phase 1
key filters, owning and native consumers. Standard hook utility ignores returns;
bad resulting text/configuration is separately invalid. Use private copied hook
lists excluding only the repository generic-export guard; leave original hook
variables/guard intact, including nested generic exporter calls. This is a bounded
stage adapter, not full Org annotation. No comment-tree/macros/Babel/Cite-processor
lifecycle claim. Unsupported genuine SETUPFILE/BIND/MACRO/CITE_EXPORT directives
remain rejected; no Babel or arbitrary Lisp macro invocation. Mode hooks are
suppressed throughout private/native mirror work.

Private hooks may change ordinary text and create generated STM, using the fixed
root parser/options/resource policy. They cannot change mode, location, narrowing,
supported parser/options/style/initial configuration, protected STM markers or
reserved provenance. Supported effective file keywords in composed text flow
through existing restricted context; precedence remains global < external < file.
Mutable closure/DB internals and arbitrary callback I/O are not sandboxed.

## Files and identity

Bare quoted full-file local Org INCLUDE only, column zero, same lexical resource
directory as the root. Reject INCLUDE parameters/locations/lines/env, directory
conflict, URL/remote/tilde/control paths, symlink components, cycles and physical
alias ambiguity. Visiting directory must agree with resource-base; fileless roots
need a local base. Read UTF-8 regular files <=64 KiB each, <=8 nesting levels,
<=32 source occurrences and <=256 KiB aggregate source/working bytes. No file-local
variable evaluation. Whole-file included footnotes are natively renamed within
their occurrence and use the existing supported grammar. Partial-file footnote
extraction is out of scope along with lines/location parameters. Other unsupported
cases fail.

Capture each file once as owned text, receipt (size/mtime/ctime/inode/device/digest),
reuse its fixed text for repeated inclusions; each insertion has a new occurrence
identity. Equal content or numeric positions alone never identify an island.
Read projected snapshots with the actual native INCLUDE helper, not a cloned
INCLUDE algorithm or globally replaced reader. Projected filenames are visible to
INCLUDE advice; real package equivalence is unverified. Snapshot markers may affect
native whitespace trimming; no byte-identical native working-text claim. Mirrors
exist only during composition, are checked against owned content, then cleaned.

## Provenance and structured handoff

Opaque STM tokens protect authored/included payload against preprocessing-looking
content. Validate exact marker multiplicity; never reconstruct lost/duplicated
identity by comparing raw strings. Identify newly inserted STM as generated data
with no claimed original file/range. Preserve originals' source identity, occurrence
and original range alongside final working range. Hook replacement text has an
explicit generated/derived origin, not an invented source span.

Ordinary origin intervals identify source/derivation context and working bounds,
not exact original character correspondence after Org transformations. AST/node-
keyed origin associations are installed before Phase 1 callbacks and owned/remapped
by existing input copying. Inline island requests currently lack original numeric
bounds: minimally retain their working bounds during private registration instead
of matching equal raw STM values. No new generic prepared-input slot is justified
for this common-base profile; INFO can hold owned original/source snapshots and
node-keyed origins. Pure lowering and native workers never read source files.

The common-directory restriction follows actual evidence: native Org relocates
ordinary file links but leaves STM resource strings unchanged. Every accepted
origin shares root resource-base, so original STM paths keep a defined base.
Cross-directory STM encoding requires a separate provenance/encoding policy.

## Bibliography and transaction

Bibliography discovery is a separate explicit option of the new preprocessing
adapter; existing Phase 3b discovery does not silently preprocess. Discover once
over the composed full STM-masked text, normalize declarations with shared root
base, preserve owned declaration/source context, global/advice discovery and
explicit text priority; reuse the existing reader/receipt checks. Includes cannot
bypass bibliography checks. Original vs derived declarations are distinguishable
through original/source snapshots and origin data. Phase 1 filters run once after
all mappings, regardless of composition or bibliography choice.

Check original source/config/hooks/function identities/explicit data and include/
bibliography receipts before/after callbacks, acquisition, native waits and final
document/byte return. No automatic retry, rediscovery/filter replay or replacement
of fixed dependency texts. No output-file API in the first profile. These are
observed dependency guards, not an atomic FS/DB transaction, no-follow sandbox or
ABA guarantee. Worker transport error/healthy-domain-error policy stays unchanged.

## Required node validation

Node A: owned original/derived/context data + private request ranges/annotations,
pure owning/remapping and once-only filters; old APIs unaffected.
Node B: protected native composition, repeated/nested equal-text origins, generated
STM, actual bounded file access, failure cleanup, configuration and dependency
checks; no public capability before the whole transaction is validated.
Node C: opt-in prepare/document/bytes, explicit bibliography combination and UUID
mapping, native parse/format/readback/serialization, mutations throughout lifetime,
selection/directory rejection, HTML/ASCII/generic guard regression. Separate
research probe evidence from maintained ERT and actual native/runtime checks.
