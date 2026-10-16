# Issue12 bibliography native ownership — read-only review

User selected bibliography as next topic and supplied Issue12 development guidance,
explicitly requesting read-only review first. No business edits, test/build/native
execution, shell networking, staging, external writes or personal-library rereads.
Development/GAW skills apply. GitHub issue12 public page fetch failed (cache miss);
search did not retrieve its body. User-pasted guidance is review input; remote
status/comments not independently verified. URL association user-supplied:
https://github.com/ren-lingyu/org-texmacs/issues/12 .
Nine reviewed source/test/README files equal current committed font-lock delivery;
only unrelated preexisting user flake mirror overlay dirty, index empty.

## Direction and preserved boundary

Guidance agrees with AST-first: native TeXmacs owns BibTeX grammar, entry/field
interpretation and plain formatting. Elisp owns source identities/snapshots,
finite usable native AST structure, unambiguous resolvable citation keys and
output label consistency. Pure lowering uses already-owned AST/formatted output,
no file/native parser calls. This adopts review scope, not implementation authority
or a claim that TeXmacs supports any particular BibLaTeX construct.
Preserve explicit text snapshots, opt-in collector/acquisition policy, input
copy/ownership, guards before/after worker waits and receipts, lifecycle/cleanup,
current citation/style/print restrictions. No new parser/type whitelist/field
semantics model or personal library rewriting.

Motivation: prior user-mode comparison established org-organize expands source
collection; Emacs whitelist rejects @online, bare month=MM also outside bounded
literal grammar. User says same files work ox-latex. Prior authorized inspection
facts are in memory/pdf-adjacent-checks.md; do not reuse its external read permission
for this task or call the library corrupt. Native support still requires probes.

## Static dependency map

org-texmacs.el:379 computes ordered type/key/field signatures via validate-source;
initializer/discovery repeats this at445. At479 deduplicates signature keys;486
constructs fake bibliography entries with empty fields, builds citation plan and
fake bib-list output, then structural lowering before any island request. At515
parses STM islands,524then native bibliography parses; actual type/key/field names
must equal raw signatures, otherwise worker is stopped. At549 rebuilds plan from
real AST and real static STM labels, formats native plain output, then constructs
owned input/consumer and final source check. Changes must rewire this order, not
simply delete the first validator call.

Three distinct placeholders: prepared STM island slots (not this repair target),
fake bibliography entry AST derived from raw signatures (replace with real native
AST), and temporary formatted bib-list for structural preflight (separate design
choice, cannot accidentally conflate it with parsed source AST). Pure lowering
print handler document.el:1418 requires prepared prefix/keys/entries/body to match
citation plan. Native AST authoritative source does not remove the prepared-output
ownership/staleness guard.

Validator in document.el:1566 contains standard type whitelist, line/header rules,
no symbolic strings/concatenation/preamble, duplicate fields. Its only bibtex helper
use is this validator; `(require 'bibtex)` at15 can go if validator removed.
Acquisition bibliography.el:142 independently invokes validator; remove/simplify
that entry too, preserving file identity/UTF8/size/alias and receipts policy.
input.el:36 copies native trees and rejects duplicate fields ignoring case, beyond
path/key/shape checks. Field-content restrictions need native-ownership review.

bibliography-plan document.el:445 rejects fields crossref/xdata/related/entryset;
455passes only cited entries to formatter. This is an additional field-semantic
restriction outside raw validation. Don't silently retain the blacklist as if
Issue12 removed all parallel field policy; also don't blindly delete it when
uncited parent/dependency ASTs may be required by native processing. Native probes
must establish whether parse resolves those relations or formatting needs owned
full context. Pass necessary already-owned context to native facilities if needed,
without inventing an Elisp field-resolution model. No relation-style expansion
or claim of full BibLaTeX support is adopted by this review.

Worker.scm:458calls parse-bibtex-snippet; empty-string result normalized to
(document), then filters every non-bib-entry child. Comment says source already
validated. Once validation removed, this filter may erase native declarations,
metadata or diagnostics. Inspect raw native result BEFORE worker filtering and
compare formatting output; do not mistake current filtered worker result for full
native parse semantics. Do not impose a replacement entry-type whitelist.

Worker.el:179 error replies produce parse-error and preserve worker; malformed
transport/stree stops it. Main copy/signature failure currently converted to
worker-error/stopped. After native ownership, distinguish invalid response/AST
from valid AST whose keys are duplicate/missing/unresolvable; normal input/domain
errors should not all be reclassified as worker corruption. Retain native error
reuse and corrupted-response cleanup tests.

## Recommended order and test adjustments (not an implementation plan adoption)

Capture source/config/dependencies and prepare/filter Org AST; perform native-
independent structural/source-identity checks; parse each owned bibliography source
once natively and immediately own/check returned AST; resolve citations against
those trees, then complete structural preflight; parse STM islands, select final
collision-free prefix using their actual labels, format native plain output;
construct owned input and pure lower. Exact decomposition still to choose.
Keep source/dependency guards around every new parser/formatter wait, including
initializer/filter/selected/named-footnote paths. Don't reread buffers/files to
recover lost bibliography data in pure lowering.

Missing key and cross-source duplicate checks cannot promise zero native parse
calls after raw scanning removed. Existing ERT source-validation, source-snapshot-
preflight, citations-preflight and invalid-native-payload assertions need semantic
migration: separate no-native-independent errors from AST-dependent key failures;
keep no unnecessary STM/format calls after the latter. Extra/normalized/omitted
fields are not invalid worker payload merely for differing from source; current
wrong-key response to uncited source no longer proves malformed AST. Cited key
missing should be a resolution failure. Keep label/prefix/key/entries prepared-
output and encoding provenance checks.

Probe @string/defined+undefined macros/#/@preamble/@online in locked native parser,
actual raw AST, worker AST and native plain formatting, then .tm/PDF where relevant.
Include same-file and cross-source/reused-worker macro scope to expose state leak;
no full BibLaTeX promise. Native parser success alone may yield empty/partial AST;
require supported reference relation/output, without rescanning raw fields to
invent completeness. Duplicate-key guarantees are over visible owned AST; if
native collapses duplicate raw entries, record that limitation rather than adding
a parallel raw parser. Test structural malformed AST, duplicate/missing keys,
valid AST but unusable reference relation, native failure/recovery, exact .tm/PDF
labels. Preserve explicit snapshots/opt-in discovery/preprocessing, source and
receipt changes during waits, ownership and final cleanup.

## Review outcome / next

Guidance is sound with explicit additions for worker filtering, dependency-field
policy/formatter context, preflight timing and error-class boundaries. Native
capability outcomes remain untested, no implementation chosen/executed this turn.
Next user may request a detailed implementation plan/native probes. Any build/test
requires fresh exact-command authorization; no system Emacs tests. No business
files or existing tests/README changed. No archive necessary: current source is
in Git and guidance/findings faithfully distilled here; no unique runtime raw
artifact or personal source capture this turn.
