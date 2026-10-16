# TeXmacs block editing and indentation

## Adopted contract and status

User requests dedicated Scheme editing for texmacs special blocks and native
Scheme indentation in original Org buffers. User subsequently requests a public
Customize option for scheme-ts-mode. Implemented, verified and user-committed; exact delivery verified.
This is a bounded authoring addition, not
Babel, a new STM parser, inline-fragment editing or general Scheme execution.

org-texmacs-edit-mode defaults to bundled scheme-mode. Optional scheme-ts-mode
requires the user-provided mode and Scheme grammar. Runtime checks reject missing
support without modifying source/opening an edit buffer; no automatic install or
silent fallback. No added mandatory Package-Requires/Nix package dependency;
module explicitly requires built-in scheme. Fontification mode remains unchanged.
Existing source-edit buffers keep their initialized mode until closed.

## Implementation rationale

Pinned Org org-edit-special has no special-block dispatch; org-indent-line only
uses native language indentation for src-blocks. Thus org-src-lang-modes alone
cannot provide either requested behavior. Narrow advice recognizes native Org
TeXmacs special blocks via the existing case-insensitive predicate, then uses
org-src--edit-element. Native Org handles overlays, markers, save/exit, cancel,
reuse and windows. Empty bodies get contents bounds on a copied Org datum, without
reclassifying the live source AST. Restore literal body in initializer because
Org otherwise dedents special-block contents; preserve-indentation is set after
Org initialization to avoid whitespace rewriting at save/exit. Closing-delimiter
injection is rejected before source replacement. Initialization failure aborts
through Org. Other Org edit contexts delegate unchanged.

Source TAB hook and narrow org-indent-line/org-indent-region adapters compute
Scheme indentation in a private block-local buffer before applying source edits.
Container indentation floors code but not multiline strings. Only selected body
lines are changed atomically; delimiters/export ownership remain Org's. No-op
indentation does not change the source character tick. Non-target contexts use
original Org behavior. No worker/Babel requests required; font-lock can be off.

## Validation and limits

Isolated flake tmp/block-editing uses explicit Nix paths and locked inputs;
original user mirror overlay preserved. Baseline uses untouched source snapshot
of main bibliography delivery (8c1ac95): two expected failures confirmed for edit
and indentation. Strict compilation initially required an explicit optional-mode
function declaration; corrected without adding a dependency.

Locked x86_64-linux Emacs31.1 / Org9.8.10 / TeXmacs2.1.5. Pinned environment has
scheme-mode and Tree-sitter runtime, but neither scheme-ts-mode nor Scheme
grammar. Optional-mode tests cover availability errors and controlled dispatch
only, not actual TS grammar behavior or GUI editing. Users install optional
support independently. Scheme-mode real edit/indent behavior is tested.

Latest focused:30/30,3.062694s.14new editing cases plus existing font-lock/block
case controls cover edit roundtrip, empty blocks, exact whitespace, cancellation,
save/reuse, mixed case, quote/list, closing-line rejection, TAB/region/line indent,
read-only/partial narrowing, multiline strings, point/no-op/failure isolation,
no native/Babel calls, unrelated Org editing, optional mode failure/dispatch.
Full flake gate exits0:478/478 ERT (340.820181s), fixed real-extension
integration, strict byte/native compilation and package-lint all pass. Original
mirror overlay unchanged after removing only the new module fileset line. All28
root source/README/LICENSE/lock/flake/test inputs still equal their final hashes;
27 match isolated snapshot byte-for-byte (flake intentionally adds probe/check
drivers and fixed extension dependencies). Final focused output:
/nix/store/pyir1hxnmcpfa5d9dvbvi4q0j5bff0kd-org-texmacs-block-editing-focused.
No code edits after the green gate. Full GUI acceptance and real TS
editing remain unverified. No release gate/issue closure automatically adopted.

## Evidence retention decision

No raw archive selected: maintained ERT preserves regressions, this memory retains
pinned function behavior, results and limits, and lock/source probe driver permit
reproduction. Raw extracted functions/logs/copies are regenerable and add no
necessary unique evidence. Do not archive the whole tmp directory or build caches.

## Verified candidate file identities

SHA-256 after the green gate; uncommitted candidate, not a project-commit claim.
Root flake includes the original user overlay plus one module fileset line;
isolated driver differs intentionally. Use these identities for later delivery
verification; do not rerun tests solely to add a project parent.

```json
{
  "LICENSE": "3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986",
  "README.org": "8cc3856d8a56a59df797cb7e09a50517b3cdc8a4aefb669dd73d6e29dbf4f64c",
  "flake.lock": "118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a",
  "flake.nix": "a717dcfa245b1ccaee102ed8eef3a6ae229d0c86b60f674080bab5273d093a8a",
  "org-texmacs-ast.el": "f24a5e1e8773b58d7609f80adfd925a7af4f6fea7656ba170fa502dfe9453d7f",
  "org-texmacs-bibliography.el": "f5500572186ab4e9a4c546953155dca622740287edc1e86ca0b5b41a20a1b32b",
  "org-texmacs-context.el": "5ea3f161da97c3883f18b51294408dcba279bb6a0af55c89c79176833c9bc138",
  "org-texmacs-core.el": "25a470c3d69afc468160a557455f9c9dbc65beff707a2fe6c602be06663e7d22",
  "org-texmacs-document.el": "8c521baaf89448eab5534eacbfadf5add45cfa46a8d1fb107c4312bcbf8defb4",
  "org-texmacs-edit.el": "4098741fce82721ca029fa4077ed7e931cf1d13498c40359b1e6b87acb4a1e37",
  "org-texmacs-font-lock.el": "eea552c888eaa726748bb670e39790f1ed30f128c27942a34e425877c97844a2",
  "org-texmacs-fragment.el": "6e059cfc4a86359c7085f52acf5be561f4941a277684ce93eab531f7540a6e43",
  "org-texmacs-input.el": "acdba3e42a5369563d5c24d47cdfa42fd97a9052572f85122f4ea013bbb19c28",
  "org-texmacs-preprocess.el": "26b88e3a223e7797a389c15c63a34d47730f283b329c9f1129b983e8f0a10170",
  "org-texmacs-session.el": "5c8f162bcd9945aa5b8a92730e89a3783a34a8688b38b55c306d21cf834e9995",
  "org-texmacs-source.el": "18afa541de20383bf7df82ccb057d6bde63820ead9315319aa7bdd5d726dc1d9",
  "org-texmacs-worker.el": "5f286ad6c0195d6d63144f5861e6860e1b39c9609e3bc40f139542033612db62",
  "org-texmacs-worker.scm": "8d91bd9c36327aa068a8808c00f381af38f8e1aaa9ce62ea4208ba55d80b6c1c",
  "org-texmacs.el": "ed2718832c5358fd45bc8a454e36eacd2baa32322a4b8909791732de3fa46d0a",
  "ox-texmacs.el": "d3639caa37ff7e7b3a00055022278f7ae64893cd3eeee779f636b4da466e360d",
  "tests/default.nix": "e16f23109c2314622ae7cb023c0b84d135261becd99d8b47bb224035bf0a7b14",
  "tests/ert/default.nix": "9c256c93c82362090a25732eca8ee9ff4f9554168f917d751a9da8e13460c6eb",
  "tests/ert/ert.el": "8924f099891d632095b4d54253b9326ffd1ca1b422e3f1935a7e8b66bc8c9220",
  "tests/ert/run.scm": "3118733dd90ea07e0d891659680e079456a9eac1d5f0247ef1b90c086e088f08",
  "tests/integration/default.nix": "4c93816032bd67f7e46f1e3f47490ff0c7d1f943765178cc724be365e6474b7e",
  "tests/integration/phase4.el": "54d702d49752725cb7df7f3fe3b3b12c4d12625eb2a18eef5ceacb481d9c81f1",
  "tests/package-lint/default.nix": "362a7e1bae443d5377a780ce8e0edcd23563728bd2d9092d78ca7f8a87eeff1d",
  "tests/package-lint/run.scm": "b87e42fffd9aaa84e2f87858cbaab460e358aaaff2d44568a38fb519b63e30d2"
}
```

## Staging and message readiness

User authorized sequential staging/message preparation, maximum3min polling.
Exactly README.org, flake.nix, org-texmacs-edit.el, org-texmacs.el and
tests/ert/ert.el staged. Only new module fileset line staged in flake; original
user mirror remains unstaged. Full staged review/--check pass. Staged code, tests
and docs byte-equal accepted candidate. No tests rerun. One coherent feat(edit)
commit, split not necessary/low difficulty. User subsequently committed; see delivery below.

Staged binary patch SHA256:
c10531c6e48fb263860156f48beb4ee37cfb86eca9b0c961a276480197e3c797.
tmp/commit.md SHA256:
bfaf65598e462992cf9ded20ea3e6bb3c8a26a93ca242cf199987a5b4ff49a61.

```text
feat(edit): add Scheme editing and indentation for TeXmacs blocks

- 为 `texmacs` special block 接入 Org 源码编辑流程, 支持保存, 回写, 取消及复用编辑 buffer.
- 为块正文的 TAB, 行与区域缩进复用 Scheme 模式, 在私有 buffer 中计算后原子更新, 处理容器缩进与多行字符串.
- 新增 `org-texmacs-edit-mode`, 默认使用 `scheme-mode`, 允许选择用户安装的 `scheme-ts-mode` 和 Scheme grammar, 缺少可选支持时明确报错.
- 接入主模块与 Nix 打包, 补充编辑生命周期, 缩进和模式选择回归, 在 README 中说明操作方式与依赖边界.
```

## Committed delivery verification

User committed feat(edit) with one expected bibliography-delivery parent and
exactly the five approved paths. Full committed binary patch and complete message
match hashes above. All28 worktree candidate identities still identical;27
committed inputs match candidate byte-for-byte, except intentional exclusion of
user mirror overlay in committed flake. Ordinary index empty; only unchanged
original mirror overlay unstaged. Prior validation transfers by exact bytes.
No build/test/network or ordinary Git mutation for this verification.

New GAW project-parent association denotes delivery equivalence checked against
the committed snapshot, not original runtime provenance: tests ran on uncommitted
candidate. No linked issue/footer, so no issue-state query needed. No raw archive
selected; maintained ERT, distilled facts/hash identities and project history
retain necessary evidence. Actual Scheme TS mode/grammar and GUI editing remain
unverified; this does not broaden prior basic font-lock GUI acceptance.
