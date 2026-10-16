# Default-on STM font-lock — implemented, automated acceptance complete

User explicitly requests implementation after bounded investigation. Adopted
interface: internal defvar-local org-texmacs--font-lock-enabled defaults t,
ordinary nil default/local override, no command/Customize/public mode. STM
editor regions use Scheme properties; Org/scanner determine ownership. No new
export syntax/parser/worker behavior.

## Candidate and ownership

Five task paths: new org-texmacs-font-lock.el, main require, Nix fileset entry,
maintained ERT and README. Original user flake overlay preserved; our flake
change only adds module to fileset. Ordinary index untouched, no project commit.
Install local original-fontifier wrapper via org-mode-hook and existing-buffer
load pass. Respect normal Font Lock and org-src-fontify-natively. Use current
Org local element context, scan only owning paragraph's private copy through
existing masking/boundary function. Blocks own their body regardless of tags.
Do not call full fragment-map per match or change its export semantics.

Org fontification runs normally; within recognized islands, clear Org activation/
hiding/syntax then stage the Org Scheme helper in a private view with leading
newline. Transfer generated presentation properties including Scheme syntax;
no source character edits. Whole owning context property includes block
boundaries, enabling old/new range extension. Before/after-change markers retain
old affected ranges; half-open endpoints avoid cascading over neighboring
paragraphs. No context may have empty/reversed clipped body bounds. Changing
internal override/tags schedules full invalidation (infrequent config), preserving
narrowing; per-edit invalidation stays local. Disabling restores Org through its
normal unfontifier. Major-mode change clears ownership/syntax; preserve later
fontifier takeover when restoring original callback.

## Authorization and current validation

User authorizes repeat120s baseline,180s focused,120s performance,600s full:
`nix build path:./tmp/font-lock-implementation#checks.x86_64-linux.<target> --no-link --no-update-lock-file --print-build-logs --print-out-paths`;
full is `timeout 600s nix flake check path:./tmp/font-lock-implementation --no-update-lock-file --print-build-logs`.
Necessary locked dependency access/result reads/copies included. User explicitly
reinforces Nix path references for test inputs; builders use Nix-captured sources,
not host-relative siblings. All tests run flake Emacs, not system Emacs.

Locked Emacs31.1/Org9.8.10/TeXmacs2.1.5,x86_64-linux. Initial causal baseline
8/8fail (0.386417s); final feature test count now11. Latest installed focused
11/11pass0.853644s including independent Emacs processes with existing Org
buffer and t/nil pre-load defaults. Previous complete gate449/449282.370992s
passed. Final same-input gate now
exit0:451/451283.173420s, strict compilation/package-lint/all applicable flake
checks pass. Final causal11case baseline10expected feature failures/1control
pass0.789412s; header-only restriction is the nonfeature positive control.
27root/snapshot identities recorded (task flake intentionally has extra checks).

Regression boundary: source text/modified/char tick/point/mark/undo preserved;
11default/custom roots and invalid config soft handling; Org object exclusions,
inline notes/multiline, mixed-case blocks, quote/block edits, local soft failure,
owned Org props suppression/disable restore, buffer/default/narrowing/Font Lock
and major-mode cleanup; local scanner call/size guard and no worker. GUI idle
redisplay/folding/third-party interaction are not certified by batch JIT hooks.
Manual fixture/procedure under task manual.org/MANUAL.md.

Initial harness path and ERT brackets corrected before causal baseline. Strict
compile required dynamic Font Lock range declarations. Initial implementation
had Org helper point-min assumption, list-first lookup and endpoint expansion
chain, fixed before green. Added restricted-block-header test exposed reversed
clipped contents17..16 under font-lock-dont-widen; causal red9/10 followed by
11/11green after bound guard and fresh-load additions. No hidden failures.

## Performance boundary

Final measurements use dense independent STM paragraphs with matched disabled
controls, separating insertion and re-fontification.
Thus remaining enabled context/cache work genuinely scales with document size;
do not attribute it to ordinary disabled Org cost or promise constant-time typing.
Local scanner guard proves no full STM paragraph rescan, not no global Org cache
maintenance. These are synthetic full ensure and single-edit batch measurements,
not GUI visible-region timings or a universal complexity theorem. Large owning
paragraphs/blocks remain their whole recognition/fontification unit.
Final same-source enabled4/16/64/256KiB/1MiB full ensure0.07752/0.27688/
1.10476/4.28210/17.40262s; insertion0.000157/0.000485/0.001506/0.007890/
0.040415s; re-fontify0.002338/0.006592/0.025230/0.146804/0.489012s.
Disabled re-fontify0.000057/0.000057/0.000057/0.000070/0.000096s.
These costs are transparent limits, not constant-time or real-GUI claims.

## Preservation, status and next

13necessary original-byte pure-text artifacts selected/verified, archive-only
checkpoint: archive/2026-10-16T14-21-15Z--b970820/MANIFEST.md.
Contains task-only5path patch, exact Nix harness,17baseline/27candidate identities,
final11focused/full451log/causalred10and performance controls/manual fixture.
Unchanged production/lock/test files recoverable from exact baseline project
history; full dependencies/binaries/duplicate diagnostics omitted. Original log/
patch/report whitespace retained and explained. Zero additional project parents
for uncommitted mixed candidate; capture HEAD establishes baseline/context only.
Locate introducing checkpoint through manifest first-parent path history.

Final source identity recheck27/27root/task matches;17/17baseline equals committed
capture context. Git parsed patch as exactly5task paths; preexisting mirror
excluded from patch/preserved in root. Ordinary index empty. No project commit,
external issue/PR/release actions. Final full gate accepted on current platform;
GUI manual experience/third-party modes and actual sexp navigation still pending.
Next: user manual.org/MANUAL.md check; any future staging/message preparation
requires explicit authorization, commit remains user's. Do not retest unchanged
source merely for handoff/commit timestamp. No new business repair inferred.
