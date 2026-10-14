# Issue #3 adopted export API and buffer contract

## State and provenance

This is current design knowledge, not an implementation or validation result.
The user supplied the active INBOX export API plan, then explicitly adopted
supplemental failure, ownership and loading decisions after its read-only review.
The inspected project baseline matches INBOX's stated investigation baseline:
92476aa073238d1bc38809d4300985c5a444572c. Public issue association:
https://github.com/ren-lingyu/org-texmacs/issues/3. Its remote content/state could
not be fetched and no external tracking write was performed.

The purpose is to separate normal Org interactive exports from explicit-source
Lisp adapters. This intentionally breaks old APIs without compatibility aliases.
The user subsequently selected implementation and separately authorized current
task isolated focused/integration120s and full240s Nix checks, including necessary
locked-dependency network/store/cache writes. Current execution/validation state
is in memory/current.md. No INBOX or external issue edit selected; prior unrelated
task validation grants do not carry forward.

## Public API and loading

Three standard frontend commands, defined in ox-texmacs.el:

| Name | Result |
| --- | --- |
| org-texmacs-export-as-texmacs | Managed readonly native .tm byte buffer |
| org-texmacs-export-to-texmacs | Org-named .tm output file |
| org-texmacs-export-to-pdf | Org-named PDF output file |

Each keeps (&optional async subtreep visible-only body-only ext-plist).
Non-nil async, visible-only and body-only remain explicitly rejected. Preserve
subtree, active-region, existing narrowing and restricted ext-plist behavior.
Use (interactive nil org-mode) if compatible, with targeted validation; it does
not replace runtime context/argument checks.

Five noninteractive explicit-source APIs, defined in org-texmacs.el:

| Name | Input/result |
| --- | --- |
| org-texmacs-export-texmacs-from-buffer | Explicit source to unibyte .tm string |
| org-texmacs-export-pdf-from-buffer | Explicit source to unibyte PDF string |
| org-texmacs-export-to-buffer | Explicit source to a fresh readonly byte buffer |
| org-texmacs-export-to-texmacs-file | Explicit source and destination to new .tm file |
| org-texmacs-export-to-pdf-file | Explicit source and destination to new PDF file |

Byte/buffer functions keep (source-buffer &optional bibliography-sources
subtree-position region ext-plist). Explicit file functions keep (source-buffer
file &optional bibliography-sources). Preserve return values and existing input
snapshot/consistency and exclusive-file semantics. Remove interactive declarations
from the two explicit file APIs and the explicit buffer API. Remove prompt helpers
only after confirming no remaining callers need them.

Exact renames:

| Old responsibility/name | New name |
| --- | --- |
| Frontend org-texmacs-export-to-texmacs-pdf | org-texmacs-export-to-pdf |
| org-texmacs-export-from-buffer | org-texmacs-export-texmacs-from-buffer |
| org-texmacs-export-to-file | org-texmacs-export-to-texmacs-file |
| Old explicit org-texmacs-export-to-pdf | org-texmacs-export-to-pdf-file |

Distinguish the reused PDF name by call signature/semantics, not blind replacement.
Synchronize definitions, all project callers, autoloads, docstrings, README,
dispatcher actions and tests. No defalias or obsolete-function alias. Retain
Document/Session APIs, document-current-buffer, special preprocessing and
bibliography entry points and other noninteractive functions. check-setup remains
an independent command, outside the three normal interactive export commands.

Use independent Emacs processes for main-module and frontend loading tests:
assert function ownership, signatures and commandp. Verify the reused PDF name's
new frontend definition rather than asserting absence. Three retired names have
no definitions/aliases in fresh processes. Update existing main-module ownership
assertions and interactive-only tests without dropping Lisp source/target safety.

## Output files and conversion boundaries

Frontend naming continues through org-export-output-file-name: subtree
EXPORT_FILE_NAME in subtree mode, then file EXPORT_FILE_NAME, visiting filename,
then a read-file-name prompt. Always use the selected format's suffix and resolve
relative names against the frozen source directory. Preserve private full-source
copies for metadata/naming and current source checks.

Frontend overwrites existing writable regular output files without additional
confirmation, including manually chosen existing targets. Reject symlinks,
directories, invalid/unwritable targets and source-file replacement. Complete
conversion/rendering and applicable source/dependency checks before writing;
conversion/render failure preserves old files. Explicit-source file APIs require
explicit valid absolute local absent destinations and exclusive creation, without
overwrite. No new backup, atomic file publication, target-version lock or remote
file support. Existing partial-write failure limits remain.

Preserve Org canonical source, AST-first lowering, explicit source ownership,
coherent snapshots, STM provenance and native worker/session consumer boundaries.
Preserve current bounded full-document preprocessing versus direct local scopes,
bibliography policy, HTML coexistence and rejection of generic Org string exports.
No generic org-export-to-buffer pipeline substitution for managed buffer reuse.
Menu keys remain opt-in, validated and effective at first load; only the PDF action
symbol changes. Do not broaden Org/TeXmacs syntax or rendering support.

## Managed frontend buffer

Reuse only buffers managed by the frontend, never based on name alone. Default
name is *Org TeXmacs Export*. When another buffer occupies it, allocate a unique
alternative name and stably reuse the new managed buffer. Killing the managed
buffer permits recreation on next export. User rename, modification or takeover
ends eligibility for automatic overwrite: preserve that buffer and create a new
result. Explicit-source results never participate in frontend management.
Ownership detection and update mechanism remain implementation choices.

Generate all bytes and complete source/dependency checks before replacing content.
Conversion or content-commit failure preserves the previous result without a
partial update. After successful content commit, display failure does not roll
back content or destroy a reused buffer. For the first creation of a result,
display failure cleans up only that newly allocated buffer. Distinguish these
cases in maintained tests; current unconditional frontend output cleanup cannot
simply be reused.

Results remain readonly, unmodified, unibyte special-mode buffers with
no-conversion coding, no visiting file and no unrelated mode hooks.
org-export-show-temporary-export-buffer controls display. Users clean up with
kill-buffer; closing an Org source does not remove its derived result. No special
cleanup command or mass deletion interface.

## Independent explicit-source buffers

org-texmacs-export-to-buffer always returns a new buffer; prior live results are
never reused. A distinct prefix such as *Org TeXmacs Source Export* may be used.
Lisp callers own final kill-buffer. Preserve checked raw-byte/read-only semantics,
source protection and initialization failure cleanup limited to the new buffer.

## Implementation and acceptance

Suggested nodes: map symbols/callers; synchronously change API definitions,
references and interactive declarations; implement managed buffer lifecycle;
preserve file policy; update dispatcher/docs; validate focused and full behavior.
If split into project commits, every node keeps definitions and callers coherent.

Required coverage: eight normal APIs' signatures/returns and three interactive
commands; fresh module loading and ownership; menu nil/configured dispatch;
Org naming precedence and both suffixes; frontend repeat overwrite versus explicit
exclusive creation; invalid/stale source/target refusal; conversion/content/display
failure distinctions; same-result reuse versus independent explicit results;
foreign same-name conflicts, kill/recreation, rename/modification/takeover; exact
raw bytes and buffer mode/coding/state; source text/point/mark/restriction/modified
state; subtree/region/narrowing, preprocessing/discovery, HTML and native PDF
regressions; unsupported option errors. Use project ERT, strict compilation,
package lint, Nix checks and relevant integration fixtures when authorized.
Compile or old-test success does not replace lifecycle/command-boundary tests.

No font mixing, footnote layout, link annotation or pagination repair, new element
mapping, STM font-lock, native preview, async or generic exporter in this scope.
Maintain GAW as substantive findings evolve; archive only selected independently
valuable evidence. External issue updates need their own authorization and verified
implementation completion does not itself establish remote issue status.

## Archive selection

Assessed under git-agent-workflow's archive guidance and the repository archive
skill. No raw archive selected at this design/review stage: INBOX is still an
active plan, the supplemental decisions are user-supplied current constraints,
and there are no new unique probe scripts/logs or retired files whose original
bytes are necessary to interpret/reproduce a verified result. All operational
API, safety, lifecycle, loading, scope and acceptance information is extracted
here, so continuation does not depend on the temporary INBOX or chat text.
This memory is a distilled contract, not a byte-exact source capture. Reassess
archival when retiring INBOX or when later implementation produces independently
valuable evidence; do not archive a full conversation or directory by default.
