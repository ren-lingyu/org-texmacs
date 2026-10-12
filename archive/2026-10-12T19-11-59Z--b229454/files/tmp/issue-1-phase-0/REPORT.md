# Issue #1 Phase 0 调查（2026-10-13）

结论：标准 AST filter 工具可以在 `texmacs` backend 上保留结构化 citation，并实现 key remapping；现有完整 `org-export--annotate-info` 不能直接成为安全的 preparation 替代。推荐下一节点只研究受控 AST filter 接入，完整 preprocessing 留待来源、配置隔离、selection 和外部输入合同明确后再决定。本报告是调查结果，不授权或宣称 Phase 1 已实现。

## 基线和验证范围

- 当前项目 HEAD：`b22945493102edc1823fe063f9d278ba628bdf5e`（用户提交 flake inputs 更新）。生产 Lisp 与 v0.4.0/`46ccf6e` 相同。用户未提交的 `flake.nix` USTC fetchurl overlay 保留，普通 index 为空；agent 未执行项目 staging/commit。
- 独立 flake：`tmp/issue-1-phase-0/`；`flake.lock` 与当前项目逐字节一致，SHA-256 `118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a`。nixpkgs revision `8edc0c72e3a38faf5434e40d1f19431125fe4b30`。
- 实测：Emacs 31.1 / Org 9.8.10。独立 flake 只提供 Org 环境和本次 probes，生产模块是当前项目的显式只读复制，不构建 org-texmacs 包，不启动 TeXmacs worker。
- 下载使用经用户授权的 USTC 传输地址，保留项目 Org tar 的原始固定哈希。版本和内容来自锁定包定义；不将镜像成功解释为官方 ELPA 可达。
- 精确通过命令：`timeout 120s nix build --no-link --no-write-lock-file path:/home/lingyu/Projects/org-texmacs/tmp/issue-1-phase-0#checks.x86_64-linux.probes`。最终 14/14，0 unexpected，ERT 0.124683 秒；构建退出 0。输出 `/nix/store/pzwk5775d3i9ka6xj4anb7hmm96r36w0-issue-1-org-probes`。
- 本机 emacs-twist 的 Org 9.8-pre 只用于前置定位。更新前 lock 的 Org 9.8.8 仅完成环境检查；不作为当前开发或测试依据。
- 初次 `--offline` 检查仍触发固定输出源码下载，已中断。第一次官方 ELPA 构建 120 秒超时，日志 TLS EOF；后获用户镜像授权。临时 probe 曾有括号、raw 节点遍历、递归复制、fragment tags 和 block 大小写假设错误，均在隔离脚本修正。失败不计入最终通过。
- 未运行项目全量 ERT/Nix checks；历史 312/312 与本次 14/14 不可混用。没有真实 Org-roam 包、个人数据库、原生输出/PDF 或 GUI 集成证据。

## 锁定 Org 的阶段表

下列行号针对安装的 Org 9.8.10，源码根见 `source-evidence.txt`。`ox.el` 的私有函数不是稳定 API。上游 main 的代码只能提供线索；实际版本没有 `org-export-after-includes-functions`。

| 阶段 | 输入 → 输出 | 修改 / 副作用 | 实际 API / 源码 | 复用判断、失败边界 |
| --- | --- | --- | --- | --- |
| 原始选区 / subtree | source point、region、narrowing → 导出可见范围 | 在 save-excursion/restriction 内暂时 narrow；region 优先，subtree 仍参与配置 | `org-export-as`，ox:2988 | 原生语义可参考，不能把源整数 offset 用于改写后的 buffer。现有 package 会保留全源依赖，不能无条件替换 |
| 初始属性 | backend + source 属性 → 初始 INFO，动态 backend name | 源 buffer 上收集属性；INFO 此时不是最终环境 | ox:3036 附近，`org-export--get-export-attributes` / `--get-buffer-attributes` | 私有、版本敏感。buffer 属性需要源上下文；不在 lowering 重建 |
| 工作副本 | source → Org mode copy，带局部变量、file identity、restriction、folding | 创建/销毁 buffer，初始化 parser；可能共享可变局部配置，不能保证任意 hook 的配置隔离 | `org-export-with-buffer-copy` ox:2666，`org-element-with-buffer-copy` / `copy-buffer` element:643/679 | 有可复用隔离机制，但必须处理 mutable locals 和 file identity；不再调用 major mode 破坏写保护。成功/异常 cleanup 已验证 |
| BIND | 源 / SETUPFILE → 副本局部变量 | collect keywords 可读外部文件；改变局部配置 | `org-export--list-bound-variables` ox:1658，copy 和 get-environment 都涉及 | 当前 probe 禁用；后续默认继续明确拒绝，不假定全管线纯净 |
| before-processing | 工作副本 + backend name → 改写副本 | 任意 hook/advice 可 I/O 或改写其他状态 | `run-hook-with-args`，annotate-info ox:3103 | 只有真实阶段 adapter 及副作用合同成立后复用；单独 run-hook 不等于标准生命周期 |
| INCLUDE | 工作 Org text → 展开文本 | 读文件/可能 URL；递归临时 Org buffer；重写 file links、标题级别、脚注 | `org-export-expand-include-keyword` ox:3318，`--blindly-expand-include`，`--prepare-file-contents` ox:3638 | 可复用 source composition；必须约束依赖读取、递归、来源、工作 buffer 设置，不能声称已有完整 origin map |
| comment trees | text → 删除 COMMENT 树 | 删除文本，改变坐标；宽化作用域 | `org-export--delete-comment-trees` | 阶段与最终 AST prune 不同；必须明确 source scope，而不是重放现有 prune 两次 |
| macros | 工作 text → 展开 text | macro template 和替换修改文本；用户 Lisp macro 可有任意副作用 | `org-macro-initialize-templates` / `replace-all`，ox:3109 | 用控制变量禁用不会自动解决其他 preprocessing。probe 只验证普通 macro 时序，无任意 Lisp macro 安全承诺 |
| parser refresh | 改写文本 → 更新 regexps/options/radio targets | 修改工作 buffer 配置与 parser 派生状态 | `org-set-regexps-and-options` / `org-update-radio-target-regexp` | 必须保持受控 parser 状态，避免与 package 的冻结设置矛盾 |
| Babel | 工作 text → 执行/替换 results | 可能执行代码、进程、I/O，进一步改变坐标 | `org-export-use-babel` / `org-babel-exp-process-buffer`，ox:3120 | probe 用替身观察调用点，未执行任何 Babel 代码。第一批能力不应默认开启 |
| before-parsing | 工作副本 + backend name → 最终待解析文本 | 任意 hook 副作用；变化触发 parser refresh | annotate-info ox:3131 | 在 macros/Babel 后、get-environment 前，不能传递未建立的“最终 INFO” |
| environment | globals/ext/file/subtree → INFO | BIND、SETUPFILE、用户配置可能 I/O；metadata secondary parse | `org-export-get-environment` ox:1416 | 优先级 globals < external < file < subtree；subset 合同需继续校验。subtree EXPORT_TITLE 和 region 同时使用已验证 |
| Cite 输入环境 | Org buffer → bibliography paths、processor | discovery 可经 SETUPFILE 读配置；advice 可 DB/I/O；选择 processor 可加载其代码 | `org-cite-store-bibliography` oc:1278，`list-bibliography-files` oc:607，`store-export-processor` oc:1287 | 路径列表不是 BibTeX 文本快照。直接文档相对路径保留，SETUPFILE 相对路径按其目录重定位；文档+global 原生去重先于返回 advice |
| filters 安装 / options filters | backend、global/INFO filters → filter lists / INFO | 用户 options filter 可以更改 INFO，包括安全开关 | `org-export-install-filters` ox:2581 | backend developer filters 前置，随后 INFO 与用户 filters。不能只靠外部 plist 关闭 processors 就认定任意 options filter 无法重新启用 |
| Org parse | 工作 text → Org AST（可含 deferred 数据） | 源位置与工作 buffer 绑定，缓存/解析行为需控制 | `org-element-parse-buffer ... 'defer`，ox:3166 | AST 必须 materialize/own；返回前复制列表不等于消除 buffer/deferred 依赖 |
| prune / 链接 | AST + INFO → 可导出 AST | 删/变节点；expand-links 可替换环境变量；改变映射 identity | `org-export--prune-tree`、`--remove-uninterpreted-data`、`--expand-links` | 不能与现有 context 无条件叠加，STM span/post-blank/island mappings 必须保留或重建并校验 |
| parse-tree filters | AST + backend symbol + INFO → 原树或替换树 | 任意用户 filter，可更改/移除/复制对象，甚至返回非 AST | `org-export-filter-apply-functions` ox:2558 / 调用 ox:3186 | 适合第一节点。实测原生调用时 `INFO :parse-tree` 尚为 nil；不能依赖它已经指向参数 tree。结果需校验 |
| tree properties | filtered AST → INFO `:parse-tree`、编号、ID alist | **调用 `org-id-find`，可能访问全局 ID 数据库** | `org-export--collect-tree-properties` ox:1672，ID lookup ox:1721 | 是完整 annotate 的额外 I/O 边界。即使关闭 Cite processors 仍存在；当前仅替身验证调用，没有读真实 DB |
| Cite 输出替换 | AST → backend-specific `raw` 或其他输出节点 | 原 citations / PRINT_BIBLIOGRAPHY 被抽取/替换；processor 可 I/O | `org-cite-process-citations` oc:1386 / bibliography oc:1428，ox:3196 | **不适合本项目结构化输入**。关闭整个 `:with-cite-processors` 同时跳过 discovery，后者需单独在 adapter 恢复 |
| transcoders/template/finalizer | AST → output string | 各 exporter 及输出 filters 的副作用 | `org-export-data`，`org-export-as` 后半 | 不作为 TeXmacs AST 接入点，不从导出字符串重新解析结构 |

## Probe 证据与具体含义

1. before-processing → before-parsing → AST filter 的顺序、backend/current-backend、工作 buffer Org mode 正确。工作副本销毁，原 source text/point/mark/narrowing/modified flag/file identity/directory 在受控 hooks 下不变；异常路径同样清理。
2. 原生 INCLUDE 的 around advice 实际触发 3 次，覆盖 root→b→c。嵌套相对链接成为 `parts/b.png` 和 `parts/deeper/c.png`，以 base includer filename 为重定位目标。仅在提供 visiting filename 的 fixture 下建立此结论；未验证非文件源/显式 directory override 的等价行为。
3. 展开文本中的属性是链接描述的 `:parent`，不是完整 source-file/span origin map。重复 STM block 保留相同文本，没有据此可推断的唯一 origin。有限观察和源码检查不证明所有 INCLUDE 场景完全没有来源信息。
4. `:with-cite-processors nil` 时，filter 后 citation key 是 `external-key`，PRINT_BIBLIOGRAPHY 保持 Org keyword。启用处理器后原 citation key 消失，生成 `raw` 内的 PROCESSOR-STRING / BIBLIOGRAPHY-STRING。Org map 对未知 raw object 的递归行为不适合直接用于验证所有替换节点，probe 使用结构遍历。
5. discovery 的受控 return advice 在 Org buffer 被调用；集合是 `local.bib`、`global.bib`、`managed.bib`。无 SETUPFILE 时 probe 未读 bibliography 文本；有 SETUPFILE 时实际读取 setup.org，并得到 `config/library.bib`。因此 discovery 不是无条件只读内存操作，`store-bibliography` 的“absolute names”文档不能代替实际路径归一化。
6. 公共 filter 安装/执行工具以真实 `texmacs` backend remap 私有 AST，原解析树 key 不变，未调用 generic exporter/worker；只证明工具级接入可行，不是已完成 production lowering 或真实扩展支持。
7. 工作文本前插 7 字符时 inline STM begin 从 6 变 13。替换为递归复制的 AST 后，两个既有 island identity keys 均不在新树。预处理前 source offset 和 filter 前 mappings 不能直接复用。
8. subtree 配置保持 SUBTREE-TITLE，root 不输出，Child 输出；active region 可在 subtree 配置下仅输出 alpha。此测试不解决 preprocessing 后原始范围映射。
9. 宏位于 before-processing 与 before-parsing 之间；Babel 调用阶段也在中间。Babel 是替身，没有执行语言代码。
10. 完整 annotate 的 ID lookup 被捕获，证明 full reuse 比当前 document-wide 本地 ID resolution 更宽。
11. 原生 copy 共享 `org-cite-global-bibliography` 列表，副本 setcar 影响 source 设置。文本隔离不等于配置值所有权；hook 任意副作用不可 sandbox。`org-element-copy` 不带递归参数也不能提供子树所有权。

`observations.sexp` 是原始打印诊断，保留循环文本属性和 killed-buffer 描述，不是可 `read`/执行的数据输入。阅读时结合报告和 probe 源码。

## 两个接入候选与取舍

| 候选 | 接入方式 | 已证据支持的部分 | 代价 / 停止条件 |
| --- | --- | --- | --- |
| A：现有 preparation + 标准 AST filters | 沿用现有 explicit snapshot、private parse/context，在 owning 之前用 `org-export-install-filters` / `org-export-filter-apply-functions`；不执行文本 preprocessing | texmacs backend filter 参数与 key remapping 可工作；source 与私有树可隔离；不会自动进入 citation 输出替换 | 必须定义 INFO 子集与 buffer context；对 filter 更换 AST、修改 STM leaf/span、引入未支持对象显式失败。需要避免重新对替换树使用旧 identity mappings；不是完整 Org export 生命周期或任意 package 兼容 |
| B：原生 copy + annotate 的结构化路径 | 在受控 copy 调用版本固定的 annotate、禁止宏/Babel/BIND 等首批未支持语义、关闭 Cite 输出处理，单独发现/捕获 bibliography | 受控 ASCII probe 返回过滤后的 citation AST，并保留原生 INCLUDE/filter 时序；路径重定位可成立 | 私有 API、强耦合 INFO、隐式 ID lookup、SETUPFILE、共享局部值、hook I/O、selection/STM/provenance。现有 texmacs guard 会在入口拒绝；必须先设计局部授权路径，不直接移除 guard。当前**不能批准直接接入生产** |

A 是最小可独立 review 的 Phase 1 方向：限定无文本改写的 citation key filter，使用标准扩展点而非 package 名称注册。B 仅是证明“可返回 AST”的研究候选；如果去除不允许的后阶段需要全局 advice、函数 monkey patch、捕获/中断通用 exporter，或依赖无法解释的私有状态，应停止，改为小型分阶段 adapter，复用公开 copy/include/filter/discovery helpers，并如实声明自己的有限生命周期。该备选不能用手工 run-hook 冒充完整 Org export。

两者都不复用 generic 字符串 transcoders，都不让 input-create / pure lowering 读文件/数据库。暂不选定完整 preprocessing 实现。

## 下一节点的拟议合同（尚未实现）

Phase 1 的 owning layer 是 preparation adapter，输出仍为 owned `org-texmacs-input`。先写明允许的 INFO 字段、private Org context、filter 列表快照和 mutation contract；限定 citation-reference key remapping，不修改文本/源配置、不允许 STM identity 变化。复用标准过滤工具与真正 texmacs backend，保持 generic guard。过滤之后重做必要语义 preflight、dependency planning 和 owning；不能只在 native lowering 前临时改 key。

维护回归需覆盖：无 filter 时 v0.4.0 一致；源 UUID 不变、owned key 改变、现有 native bibliography 正确；缺失条目显式失败；替换 AST/stale island keys/不支持节点拒绝；filter 异常和源/配置变更在 worker wait 后拒绝；cleanup 不污染 HTML/backend/global filters。通用 AST replacement、Babel/macros、INCLUDE、SETUPFILE、多源资源、自动 bibliography 读取留给独立后续节点。

Phase 2 前必须分别决定：原 source selection/configuration 与工作 document 的映射；preprocess-before-mask vs preprocess-after-mask；包含 STM 源来源的明确策略；root visiting identity 与 captured resource-base 冲突；外部依赖获取/重查范围；source 值和工作值的复制策略。读取多个独立外部系统不建立事务性原子快照。

## 未验证与 tracking

- 本次没有真实 org-roam 包联测，且公开源页面/Raw 读取返回 cache miss；INBOX 中的第三方扩展点仍是指导文档声明，不能升级为本轮独立验证结论。
- 没有 native .tm/PDF 或全量 package checks；14 probes 是调查证据，尚未进入维护测试。
- 尚未修改 GitHub issue。INBOX 建议在 issue #1 记录 Phase 0 依据，但外部写入需要单独授权；本地报告可直接供 review/发布。
- 后续源码改变/lock 更新必须重验版本敏感行为，尤其私有 annotate 次序和中间 INFO。archive 保留本轮准确版本、输入、输出与限制；active memory 只保存结论和下一动作。
