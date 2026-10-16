# Default-on STM font-lock — user-committed, exact delivery verified

User explicitly requests implementation after bounded investigation. Adopted
interface: internal defvar-local org-texmacs--font-lock-enabled defaults t,
ordinary nil default/local override, no command/Customize/public mode. STM
editor regions use Scheme properties; Org/scanner determine ownership. No new
export syntax/parser/worker behavior.

## Delivered implementation and ownership

Five task paths: new org-texmacs-font-lock.el, main require, Nix fileset entry,
maintained ERT and README. Original user flake overlay preserved; our flake
change only adds module to fileset. User manually committed the exact reviewed
feat(font-lock) delivery; five paths, expected parent/message/complete patch and
source identities verified read-only. Index empty; only original overlay unstaged.
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
User subsequently reports actual GUI font-lock feels basically usable. This is
user-observed basic presentation acceptance, not comprehensive idle/folding/
navigation/third-party/performance certification; exact GUI config not supplied.
User also reports texmacs block has no source editing environment/native code
indentation. Static source confirms current module only stages Scheme fontifier
properties; no source-edit dispatch, Scheme major-mode binding, or indentation
integration. Editing/indentation is a separate task from font-lock. User has
now authorized its bounded implementation and optional custom Scheme-mode choice;
see memory/block-editing-implementation.md. No added release gate inferred.

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

User subsequently authorized staging/message preparation and manually committed.
Read-only delivery verification confirms exactly one parent (the supplementary
PDF-test baseline), exactly5task paths, complete Git patch hash and exact commit
message bytes equal reviewed staging/draft.26committed source/test/lock hashes
match accepted candidate; root27hashes also match, with root flake hash including
the preserved user overlay. Committed flake is exact baseline plus one module
fileset entry. Ordinary index empty; only original user flake overlay unstaged.
No runtime retest:11focused/451core/full compile/lint acceptance transfers by
exact bytes, not merely a nearby timestamp or matching subject.

One coherent feature; split not necessary (difficulty low, tightly coupled load/
package/tests/docs). Prior stage/polling details are superseded by this delivered
state. Reviewed draft in tmp/commit.md matches committed message. No new archive
needed: existing immutable implementation evidence and current verification
extraction suffice. No issue association/closing footer, so no remote issue
status query/closure required or inferred. No release/publication action.

The additional project parent of this verification checkpoint grounds the exact
committed-delivery verification only; it does not retroactively establish the
original runtime/archive as committed-source execution. Original archive remains
unchanged with its original uncommitted-candidate provenance.

Full reviewed draft (no issue association/closing footer):

```text
feat(font-lock): highlight embedded STM as Scheme by default

- 默认在现有和新建 Org buffer 中为 paragraph, inline footnote 和 TeXmacs block 内的 STM 应用 Scheme 呈现.
- 复用 Org 局部上下文和 STM 扫描边界, 清理内部 Org 属性, 并管理编辑后的旧范围失效与恢复.
- 通过内部变量 `org-texmacs--font-lock-enabled` 支持全局默认和 buffer 局部禁用, 自动安排重新着色.
- 将新模块纳入 Nix 包, 补充边界, 生命周期及独立加载回归测试, 并记录 README 使用边界.
```

Next: basic GUI presentation user-accepted; detailed idle display/folding/
sexp navigation/third-party checks remain unverified. Source-edit/Scheme indentation
is separately authorized and implemented/automatically verified as an uncommitted
candidate in
memory/block-editing-implementation.md. Other release gates in
memory/release-0.5.0.md; no release action selected.
