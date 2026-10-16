# STM font-lock investigation — completed 2026-10-16

Initial bounded pre0.5.0 investigation completed without production changes.
User subsequently adopted default-on/internal-variable contract and explicitly
requested implementation, now implemented/automatically accepted/user-committed;
exact delivery verified. Current source/validation/limits: memory/font-lock-implementation.md.
This file retains investigation evidence and the reasoning behind the contract.

## Adopted interface direction after investigation

User now selects font-lock as default-enabled functionality. No user-facing
configuration item or dedicated command. Follow-up clarification explicitly
requires an internal variable, not a command. Implemented internal spelling:
`org-texmacs--font-lock-enabled`, default t, ordinary defvar-local rather than
defcustom. nil forces Org-only behavior in that buffer; default binding can
suppress automatic use globally. Refresh/cleanup lifecycle is now implemented
and regression-tested as described in memory/font-lock-implementation.md;
disabling restores Org rather than leaving old Scheme properties. No public
minor-mode command or Customize option selected.

User questioned earlier face-only recommendation. Corrected interpretation:
Scheme syntax properties inside STM are acceptable and potentially useful for
parenthesis matching/sexp motion, not intrinsically a defect. Treat identified
STM ranges as embedded Scheme for editor presentation. Existing Org links,
emphasis and hiding inside STM string data must be suppressed within those
ranges and restored through normal Org fontification when ownership ends.
Use Org/scanner for boundaries, Scheme for presentation, native STM parser for
export validity; Scheme editing does not expand accepted STM syntax or execute
code. Do not require face-only transfer as a design constraint.

Existing helper supplies lexical colors in paragraph fragments, inline notes
and mixed-case texmacs special blocks; language mapping alone works only for
source blocks. Tested whole-snapshot prototype remains unshipped and unsuitable.
User explicitly authorized production implementation. Delivered implementation is in
org-texmacs-font-lock.el with main/Nix/ERT/README wiring; final11focused/full451/
strict compile/lint pass. Default-on internal variable and Scheme-property
contract above now implemented/user-committed with exact delivery verified.
Manual GUI acceptance remains pending. Full source, final evidence and next action:
memory/font-lock-implementation.md.

Keep presentation separate from AST-first export/discovery/lowering semantics,
STM opacity and source ownership. No worker/parser for font-lock. Reuse Org and
canonical fragment boundaries, without putting full strict export discovery on
every edit. No new public config/mode or generic editor framework selected.

## Environment, authorization and exactness

User authorized repeat120s sources/240s probes standalone flake commands,
necessary locked dependency access, targeted library source reading (including
large original library files), result read/copy. Exact command shape:
`timeout 120s nix build 'path:./tmp/font-lock-investigation#checks.x86_64-linux.sources' --no-link --no-update-lock-file --print-build-logs --print-out-paths`;
second changes timeout240s and target probes. Both completed exit0.
Locked x86_64-linux,Emacs31.1,Org9.8.10.17production/README/license/lock
identities equal task copy/current root/committed project bytes. Task flake and
prototype are synthetic uncommitted presentation inputs; not a tested production
feature at HEAD. Exact hashes in inputs.json/harness-identities.json.
Final source output ibadhvi7jdfy2w2vc3152cw030j0wdl1-org-texmacs-font-lock-sources;
final probe output acz620w1wwaw4zmwhsgqq98wcgi3kih3-org-texmacs-font-lock-probes
under /nix/store. Task REPORT.md extracts rationale and limitations.

## Source and lifecycle findings

Org helper copies syntax-table/fontified/multiline properties and org-block face;
not suitable for direct face-only inline adaptation. Native Org special-block
fontifier handles src/export/example, not texmacs. Org unfontifier also manages
syntax/display/link properties. Batch normally refuses font-lock activation;
harness binds noninteractive=nil only during named-buffer activation, verifies
font-lock/jit-lock modes and after-change hook registration, then explicit
ensure/flush. Real GUI redisplay/idle/folding/third-party modes untested.

Face-only staging prototype avoids importing Scheme syntax properties but leaves
existing Org keymaps/mouse-face/invisible link delimiters/emphasis inside STM
strings. Needs local opaque-property suppression/restoration, not just face copy.
Deleting block end leaves stale color under local ensure until full flush.
Catching malformed inline note around full discovery loses unrelated valid
fragment colors; error recovery must be local/soft without weakening export.
Changing tag config without character edit needs explicit refontification;
cache keys alone don't refresh already fontified regions.

Final12/12expected,0unexpected,9.531266s. Includes11default/custom roots,
inline note, object exclusions, quotes/parentheses, multiline/block edits,
config-only control, buffers/narrowing/disable/major-mode cleanup and source
text/modified/chars tick/point/mark/undo assertions. Tests deliberately observe
prototype defects; all-green is investigation acceptance, not feature acceptance.
First read-syntax harness defect fixed; two early8/10failures were case-folded
marker lookup (NOTE matched prose Note,CUSTOM root custom), not package bugs.
Case-sensitive markers resolve both. Final probes/results preserve real evidence.

## Performance and implementation guidance

Dense ASCII independent STM paragraphs, single cold scan/cache lookup per size:
4114bytes/132fragments scan0.03788s,fontify0.08184s;
16402/516 scan0.52811s,fontify0.67887s;
65550/2020 scan8.01484s,fontify skipped (>2s scan);
256KiB skipped (>4s preceding scan guard). Earlier64KiB scans7.88/7.76s.
Cache hits6-8microseconds; character changes force whole rebuild. Strongly
superlinear observed dense-fixture growth, not a universal complexity proof.
A single narrowed plain paragraph averages0.260-0.276ms over3scans, absolute
geometry checked against full scan. This supports bounded recognition as a
direction, not a complete context-safe incremental algorithm. Avoid global
copy/parse per edit. Cache alone doesn't solve invalidation cost.

For implementation: recognize owning paragraph/block locally, track old/new dirty
contexts, soften incomplete editing locally, define tag/narrowing refresh and
owned Org-property restoration. Preserve source state and object exclusions.
Need maintained boundary/lifecycle tests, bounded cost checks and manual
interactive typing/undo/folding/disable acceptance before shipping. No production
full-suite/PDF regression was needed/run for unchanged business source.

## Preservation

15 necessary original-byte pure-text artifacts selected/verified and archived
in a separate archive-only checkpoint: archive/2026-10-16T13-42-01Z--b970820/MANIFEST.md.
Includes synthetic harness,17input identities, selected bounded Org/Emacs source
excerpts, final observations/log and REPORT. Source/lock production copies already
in Git, binaries/cache/whole libraries and redundant early logs excluded.
Original log trailing blank line retained. Zero additional project parents:
mixed synthetic prototype/runtime evidence is not a committed production feature;
verified project library bytes and capture context are recorded in manifest.
Locate introducing checkpoint through manifest first-parent path history.
Active conclusions stay in memory; snapshots immutable. Original archived report
records the earlier undecided state. Later default-on/internal-variable and
Scheme-property decisions above supersede that proposal, not the raw evidence.
