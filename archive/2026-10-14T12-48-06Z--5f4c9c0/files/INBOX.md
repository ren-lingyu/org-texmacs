# org-texmacs Issue #1: Org preprocessing 与 AST 集成开发指导

**性质:** 架构研究与后续实施指导, 不是直接授权的大规模重构  
**状态:** 待调查、验证和分阶段决策  
**目标 issue:** https://github.com/ren-lingyu/org-texmacs/issues/1  
**代码基线:** `main` / `v0.4.0` → `46ccf6eb7120022c734115ec7876e7d150082f9b`  
**GAW 基线:** `_agents` → `16b041d99bfd5e395a66e8f9f6d3e672a8eb904b`  
**撰写依据:** Issue #1, `_agents/memory/goals.md`, `backlog.md`, `project.md`, v0.4.0 源码, Org 上游 `ox.el` 的实现, 相关 Org-roam 包的扩展点。下文明确区分已确认的现状、建议的设计方向与尚待验证的假设。

## 1. 核心决策与范围

### 1.1 优先复用 Org 标准信息流

**首选方向是复用 Org 已有的 preprocessing、AST parsing、AST filtering 和 Org Cite 输入发现机制, 使使用标准扩展点的其他 Org package 自然参与 TeXmacs 文档生成。**

- **不建立按 package 名称注册的兼容框架。** 不要求 `org-roam-organize`、`org-roam-include` 或其他扩展单独向 `org-texmacs` 注册。
- **不复制其他包的业务逻辑。** 不在 `org-texmacs` 中重新实现 Org-roam 数据库查询、UUID-to-citekey 映射、递归 ROAM_INCLUDE 解析等已有机制。
- **显式管理跨越 owned-input 边界的数据。** 自然复用 Org 扩展点, 不等于允许纯 lowering 隐式访问 buffer、文件系统或数据库。
- **不预设完全复用 `org-export-as`。** 最终接口可能需要薄的分阶段 adapter。调用通用字符串 exporter 并从输出重新解析成 TeXmacs AST, 不符合项目目标。

本方向优先于“针对每个 package 实现一个 adapter”, 但尚未确定 Org 原生管线的哪些内部阶段能够安全、稳定地复用。不能将方向性选择当作整个实现方案已确定。

### 1.2 目标信息流

```text
canonical Org source buffer
  │ capture source/configuration/selection
  ▼
private Org working buffer
  │ Org-compatible preprocessing (scope to be determined)
  │ e.g. before-processing → native INCLUDE expansion → before-parsing
  ▼
preprocessed Org working buffer
  │ Org Element parsing → relevant AST filters
  ▼
structured Org AST + export context + dependency/provenance snapshots
  │ own and validate, including TeXmacs island associations
  ▼
org-texmacs-input
  │ pure structural resolution / lowering
  ▼
org-texmacs-document
  │
  ├─ native session
  ├─ native .tm serialization/save
  └─ native PDF rendering/export
```

图中各步骤代表**候选语义阶段**, 不是现已实现的调用序列。特别是是否调用 Org 的完整 `org-export--annotate-info`、如何控制 Babel/macros、在何处 prune AST, 都需要研究。

### 1.3 保持不变的约束

以下约束来自项目 `memory/goals.md`, 不因本 issue 而放宽:

1. Org 是唯一 canonical source; 工作 buffer、TeXmacs 文件、session、PDF 均为派生状态。
2. 以 AST/tree 为语义边界, 不通过 LaTeX、HTML、XML、STM 文本中间格式重新解析以恢复语义。用户手写 STM 的原生解析和最终 native serialization 仍允许。
3. 不修改原始 Org buffer 的文本、point、mark、narrowing、live AST 或全局 parser 设置。
4. 一次转换只使用 coherent snapshot; 解析与 worker wait 不得混用不同时刻的源码或依赖。
5. TeXmacs island 的 STM 文本、AST 对应关系和 literal/STM/file-path provenance 必须正确。
6. 外部副作用在上层 source/preparation adapter; `org-texmacs-input-create`、document-wide pure resolution 和 lowering 不获得隐式 I/O。
7. 遇到无法忠实保留的 Org 语义时显式报错, 不静默丢弃或降级为普通文本。

## 2. 当前 v0.4.0 实现及具体差距

### 2.1 当前入口与处理位置

| 文件 / 接口 | 当前职责 | 后续需检查的边界 |
| --- | --- | --- |
| `org-texmacs.el`: `org-texmacs--prepare-buffer` | 捕获源文本、selection、heading/link/configuration、显式 bibliography 文本; 在 worker waits 前后检查一致性 | 若运行预处理, 原始/工作 buffer 状态与外部依赖如何分别冻结 |
| `org-texmacs-document.el`: `org-texmacs--document-prepare-source`, `org-texmacs--document-prepare` | 构建私有 Org buffer、发现并 mask STM islands、解析 Org AST | 与 Org 标准 preprocessing 的顺序、文本 offset、mask 和 AST 身份 |
| `org-texmacs-context.el`: `org-texmacs--context-prepare` | 受限 options、selection、pruning 和依赖恢复 | 与 Org export environment/pruning 的优先级和作用域, 避免重复处理 |
| `org-texmacs-fragment.el` | 使用 `(buffer, tick, begin, end, source, tag, tags)` 表示扫描结果 | preprocessed buffer 的位置不必等于原始源位置; INCLUDE 多来源问题 |
| `org-texmacs-input.el`: `org-texmacs-input-create` | 拷贝拥有 AST、identity-keyed mappings、INFO、style/initial、source/resource、bibliography trees | 应维持纯构造, 只接收已经准备的结构化数据 |
| `ox-texmacs.el` | bounded export dispatcher; 对 TeXmacs generic preprocessing 设置早期拒绝 hook | 研究接入新前端时如何替换/缩窄拒绝路径; 在接口成立前**不要移除保护** |
| `tests/ert/ert.el` | v0.4.0 含 HTML hook/advice/filter 共存回归 | 该测试仅用受控替身扩展, 不是实际 Org-roam 联合集成测试 |

目前的 `org-texmacs--context-rejected-keywords` 明确拒绝 `INCLUDE`、`SETUPFILE`、`BIND`、`MACRO`、`CITE_EXPORT`; `org-texmacs` 不调用 Org export 的 preprocessing/parse-tree filters, 也不经 Org Cite 的 bibliography discovery。它是当前**受限实现契约**, 不应未经论证提升为永久架构禁令。

### 2.2 Org 原生流程中的关键阶段

已检查的 Org 上游 `lisp/ox.el` 逻辑表明, `org-export-as` 使用临时工作副本, 在 `org-export--annotate-info` 中依次涉及:

1. `org-export-before-processing-functions`。
2. `org-export-expand-include-keyword`, comment-tree 处理和 `org-export-after-includes-functions`。
3. 宏处理、可能的 Babel 执行、`org-export-before-parsing-functions`。
4. Export environment / options 收集和可选的 Org Cite bibliography / processor 信息准备。
5. `org-element-parse-buffer`, AST pruning、link 处理、`org-export-filter-parse-tree-functions`。
6. AST 属性收集, **随后**由 Org Cite export processor 对 citation / bibliography 做 backend-specific 替换。
7. `org-export-as` 的 transcoders、template、finalizer 和输出字符串。

**重要边界:** 需要的是第 5 步中合适的结构化 AST, 而不是第 6–7 步的 backend-specific citation 字符串输出。直接调用完整 `org-export-as` 或无条件复用 `org-export--annotate-info` **不能默认满足 AST-first**; 必须验证实际返回的 AST 是否已被 citation processor 替换。

上述顺序来自 Org 上游当前源码阅读; 项目已验证的平台使用 Emacs 31.1 / Org 9.8-pre。开发时须对照**锁定/实际安装的 Org 版本**重新验证函数、顺序及可用性, 不应把上游私有 `org-export--*` 当成长期稳定的公开 API。

## 3. 扩展兼容性的具体目标

| 扩展 | 当前依赖的 Org 扩展点 | 希望自然获得的能力 | 核心障碍 |
| --- | --- | --- | --- |
| `org-roam-include` | `org-export-before-processing-functions`, `org-export-expand-include-keyword` 的 `:around` advice | 在私有导出工作副本中展开 `ROAM_INCLUDE`, 递归沿用 Org INCLUDE 语义 | 来源/资源基准、文本位置、scope 和外部文件一致性 |
| `org-roam-organize` citation | `org-export-filter-parse-tree-functions` | 将 managed literature UUID 映射为外部 BibTeX citekey, 源文件保持不变 | 必须实际运行 filter, 提供正确的 backend/info/context, 避免后续 Org Cite 输出替换 |
| `org-roam-organize` bibliography | `org-cite-list-bibliography-files` 的 `:filter-return` advice | 发现 managed bibliography paths, 由 preparation 获取并冻结所需文本 | 相应 advice 需要 Org-derived buffer; 文件路径发现不等于获取可用 BibTeX 内容; 处理显式声明与全局列表的优先级 |
| `org-roam-blog` | `org-export-to-file 'html`, Org Publish, HTML filters | 与 `ox-texmacs` 共存, 不破坏现有 HTML 发布 | 本包不是 TeXmacs preprocessing provider; 不要求改造它的消费者架构 |

**兼容目标不是“加载扩展即保证任意文档可以导出”。** 目标是在已支持的 Org 阶段和 TeXmacs 文档语义范围内自然消费扩展结果; 超出能力仍应显式拒绝。尤其要区分“第三方包正常导出未受影响”和“该包的扩展语义已被 TeXmacs 导出继承”。

## 4. 首轮工作: 接口与行为调查, 不直接重构

### A. 建立实际处理阶段及副作用表

以项目锁定的 Org 版本为准, 逐个核对:

- Work buffer 的创建/销毁、major mode 和 buffer-local settings 如何建立, 以及 `org-export-current-backend`、export INFO 在何时可用。
- `before-processing`、`after-includes`、`before-parsing` 的时序, native INCLUDE 的递归与临时 buffer 语义。
- `org-export-filter-parse-tree-functions` 的调用时点、签名、运行上下文、过滤和 AST ownership; 是否需要 exporter 注册和具体 backend 对象。
- Org Cite 的 bibliography discovery、`:bibliography` INFO、cite-export processor 选择及 AST 替换时点。
- Org export 对 source selection、TODO/COMMENT/tag prune、file/subtree options 和 narrowing 的次序。
- 宏、Babel、SETUPFILE、全局 hooks、第三方 advice 等可能触发的 I/O 与状态变化。

**交付物:** 一份“阶段 → 输入/输出 → 修改/副作用 → Org API → 版本依赖 → 是否适合复用”的调查表, 列出每个候选复用点的失败或不可承诺条件。

### B. 最小隔离 probe

在独立、可丢弃的工作 buffer 中, 用受控扩展执行最小行为验证; 不修改生产代码为先:

1. `before-processing` hook 修改工作副本; 原始 buffer 的文本、point、mark、narrowing 保持不变。
2. Native INCLUDE advice 被真正调用, 包括至少一层递归; 观察工作副本的内容和来源信息, 不预设保留了原始文件位置。
3. AST filter 在正确上下文中修改 `citation-reference :key`, 且结果在进入 TeXmacs lowering 前仍是 Org AST, 未变成 processor 输出字符串。
4. 观察启用/禁用 bibliography discovery advice 的路径集合, 明确何时读取文本、何时归一化相对路径。
5. 通过实际 HTML export 验证 `ox-texmacs` 的 guard 对无关 backend 不起作用; 保留 v0.4.0 已有测试。

**停止条件:** 如必须借用脆弱的 Org 私有内部状态、导致不可说明的全局副作用, 或找不到保留完整 AST 的接口, 先记录技术依据与备选方案; 不继续把试验代码并入生产流程。

## 5. 需要先解决的设计难题

### 5.1 STM islands 与工作 buffer 坐标

当前 STM fragment 通过 source `(buffer, tick, begin, end)` 和 raw source 关联, document preparation 利用 mask/span/AST node identity 建立对应关系。预处理可插入、移除和重排内容:

- 不可在修改后的工作 buffer 上直接复用原始 `(begin . end)` 或原始 source tick。
- 不可只依靠重新扫描文本来推断“这个 island 来自哪里”; 相同文本、重复 INCLUDE、过滤及移动内容都可能造成歧义。
- 应调查 Org 原生 expansion 是否有可信来源元信息。没有时, 需要**明确的来源策略**或限制受支持范围, 不能静默声称保留 origin。
- 要比较“预处理前发现/mask islands”与“预处理后发现 islands”两种时序对 Org 文档语义的影响; 两者都必须测试 block 和 inline islands。

### 5.2 多文件来源和相对资源

例如 `notes/a.org` INCLUDE `papers/b.org`, 后者含 `[[file:figure.png]]`。必须明确导出的链接相对哪个目录解释, Org native INCLUDE 是否已规范化链接, 以及 TeXmacs provenance 能否表达多源资源基准。

当前单个 `resource-base` 对整个文档有效, 不能未经验证就假定足以表示被包含的多个源。若必须扩展, 先写出语义合同和最小数据模型, 再修改 owned input; 不在 lowering 时查询源文件。

### 5.3 Selection 与选项作用域

当前 subtree、region、narrowing 与受限 `ext-plist` 有稳定测试。INCLUDE/macros 等可改变内容和标题位置。需区分:

- 用户在**原始 source** 中选择的 body/configuration;
- Org preprocessing 后的 **working document**;
- 在最终 AST 中保留的正文及脚注、bibliography 等文档依赖。

不能简单将源 offset 解释为预处理后 offset, 也不能在工作副本中丢失 subtree 的 `EXPORT_*` 配置和区域之外的引用依赖。

### 5.4 外部输入快照与时序

区分两种责任:

- **发现/获取**: Org 标准阶段或扩展可能读取 Org-roam DB、其他 Org 文件、BibTeX 文件和配置。这属于有副作用的 preparation。
- **固定/消费**: 将结构和相关依赖纳入 owned input 后, downstream 只消费已固定的快照。

研究哪些数据必须复查, 哪些可以作为一次已捕获的值稳定使用。不能声称多个互不支持事务的外部系统存在天然的原子一致视图。遇到无法维持声明的一致性范围时, 应明确报错或限制功能。现有“外部 BibTeX 文本由 caller 显式提供”的公开接口仍需保留, 不应被自动发现方式无条件取代。

### 5.5 Hooks 的边界

标准 Org hooks 是复用第三方扩展的核心, 但也可能修改 buffer、访问外部系统或依赖具体 backend。不要为获得“自然兼容”而:

- 在所有工作 buffer 上无条件执行全局 hooks;
- 假装任意 hook 都无副作用或可安全重放;
- 默认开启 Babel 或宏展开并把结果视为无条件可信;
- 用手工 `run-hook-with-args` 冒充已完成整个 Org preprocessing 生命周期;
- 删除 `ox-texmacs` 的 generic-preprocessing guard 而没有受控替代路径和回归证明。

需要描述**实际复用的 Org 处理阶段和副作用契约**, 而不是另造一个 package-specific 注册接口。

## 6. 分阶段实施建议

以下节点按依赖关系划分; 前一节点的证据不足时不应跳到下一节点。

### Phase 0: 调查与决策文档

- 完成 §4 的上游代码审查和隔离 probes。
- 形成至少两个可行架构候选, 比较复用 Org 工作副本/阶段的方式、API 稳定性、source/provenance 成本和 hook 生命周期。
- 在 Issue #1 记录依据、尚未解决的约束与候选取舍; **不直接把某种具体实现当作既定结论**。

**验收:** 有足够精确的 Org 调用时序、可复现 probe、结构化 AST 接入点; 明确不能复用的后处理阶段。

### Phase 1: 最小 AST 阶段复用

- 优先尝试让无外部文本改写的 AST filter (以 UUID citation remapping 为案例) 在受控 private AST 上运行。
- 不引入任何 `org-roam-organize` 专用调用或注册。
- 明确 filter 运行所需的 backend/INFO 上下文及 AST 归属, 保留当前 citation-plan/native bibliography 行为。

**验收:** 原始 source citation UUID 不变; owned AST 中的 key 变化可验证; 无 filter 时语义与 v0.4.0 一致; 不通过 generic transcoder。

### Phase 2: Org-compatible preprocessing 与来源语义

- 复用合适的 buffer-level preprocessing, 先实现有限、可验证的 source composition。
- 测试 INCLUDE、嵌套来源、STM span、选区及资源链接, 再决定是否扩大到多文件。
- 对未获支持的外部依赖或多源 provenance 保持显式失败。

**验收:** 结构化 AST 和 island 身份匹配; 来源相对路径语义正确; 完整 source/working-buffer 状态隔离; 已有子树/区域/narrowing 行为不退化。

### Phase 3: Org Cite bibliography discovery

- 在正确的 Org 上下文中调用公开 bibliography discovery 机制, 明确文档声明、全局配置、advice 合并及路径优先级。
- 在有副作用的准备阶段冻结需要的 BibTeX 内容, 继续交给现有 native parser/formatter 和 document-wide resolution。
- 不让 `org-texmacs-input-create` 或 pure lowering 读磁盘/数据库。

**验收:** managed path 可被发现, 转换所需的文本已经归属输入; 无误读或重复文献; 原有显式 bibliography-sources API 继续可用; 不支持的 BibTeX 结构仍按现有策略拒绝。

### Phase 4: 实际扩展组合测试与正式前端切换

- 使用独立可重复 fixture, 同时加载真实 `org-roam-include` 和 `org-roam-organize`。不依赖个人数据库或机器绝对路径; 如集成依赖太重, 可设可选的 integration check, 保持核心 checks 可重复。
- 验证不经显式注册即可触发对应标准扩展点。
- 复测 `org-roam-blog` 或普通 HTML/LaTeX 导出不受 TeXmacs backend 影响。
- 只有在受支持路径和失败边界清晰后, 再调整 `ox-texmacs` 的 guard、用户入口和 README 支持声明。

**验收:** 实际包组合的正反例、TeXmacs 输出语义、其他 backend 共存、失败恢复、Nix/ERT 测试全部有记录。

## 7. 回归测试矩阵

| 维度 | 最低覆盖 |
| --- | --- |
| 输入所有权 | source 文本/point/mark/narrowing/modified flag 不变; 工作副本独立销毁 |
| AST identity | filter 前后 node、island 映射、parent links、pruning 结果一致且没有 stale key |
| STM 处理 | inline/block、重复内容、跨 INCLUDE、部分区域、过滤后的无效 island 不产生多余 worker 请求 |
| 引用 | managed UUID→BibTeX key、普通 key 原样、缺失/歧义 key 显式失败、native bibliography 仍准确 |
| INCLUDE | 普通/递归/带参数 INCLUDE, 无法定位的源显式拒绝, 嵌套文件链接相对目录正确 |
| 范围 | whole buffer、subtree、region、narrowing 以及与配置/依赖的交互 |
| 一致性 | 源编辑、外部输入变化、用户 hook 变更、worker wait、异常中断与 cleanup |
| 兼容性 | 无第三方包时旧 API 行为保留; 真实扩展无需 TeXmacs 专用注册; HTML 导出不受影响 |
| 消费者 | native session、`.tm`、PDF 使用同一完成的 owned document, 不引入字符串转码中介 |

新增测试应逐步进入维护中的 ERT/Nix checks; 不为证明“自然兼容”引入全局测试状态泄漏。现有 312/312 ERT 和 7 项 Nix check 是 v0.4.0 的**历史验证基线**, 不是开发后新状态的自动通过结论。

## 8. 每个开发节点的交付规则

- 每个节点先写清楚 **观察事实 → 拟议接口 → 预期的语义变化 → 测试证据 → 未解决问题**。
- 原则上先 commit 可独立验证的调查/测试节点, 再做有回滚路径的小范围代码改动; 避免同时重写 preprocessing、citation、bibliography、scope 和 frontend。
- 不因启用了标准 hook 就承诺完整支持 Org 的所有扩展, 每次扩展支持面必须更新 README 与负向测试。
- 将 issue 讨论、架构决定及其证据同步到 `_agents` 的适当 memory/历史 checkpoint; 遵守仓库 GAW 流程。不要未经用户授权改写历史、移动 tag 或提交到 `main`。
- 如 Org 的可用 API 无法稳定提供所需中间 AST, 应暂停并提出证据充分的替代方案, 而不是以文本 exporter 绕开 AST-first 限制。

## 9. 本 issue 明确不要求

- 为每个第三方 package 建立专用 registration framework。
- 在第一批修改中支持所有 Org INCLUDE、宏、Babel、SETUPFILE、任意 hooks、跨文件 ID 或 BibTeX 所有特性。
- 让 `org-roam-blog` 改用 TeXmacs 导出。
- 现在补齐 generic `org-export-as` 字符串接口、发布系统、异步导出或 body-only fragment。
- 重构 native `.tm`/PDF consumers、worker IPC、session 模型、缓存或多 session。
- 将研究范围绑定到某个未决定的下个版本, 或修改已经发布的 `v0.4.0` tag。

## 10. 参考与可追溯性

**项目来源与设计约束**

- [Issue #1](https://github.com/ren-lingyu/org-texmacs/issues/1)
- [`org-texmacs` v0.4.0 源码](https://github.com/ren-lingyu/org-texmacs/tree/v0.4.0)
- `_agents/memory/goals.md`, `_agents/memory/backlog.md`, `_agents/memory/project.md` (当前 GAW 历史/活跃记忆; 以仓库中版本为准)

**现有 Org 扩展的实证接口**

- [`org-roam-organize-cite.el`](https://github.com/ren-lingyu/org-roam-organize/blob/main/org-roam-organize-cite.el)
- [`org-roam-include.el`](https://github.com/ren-lingyu/org-roam-include/blob/main/org-roam-include.el)
- [`org-roam-blog.el`](https://github.com/ren-lingyu/org-roam-blog/blob/main/org-roam-blog.el)
- [Org 上游 `lisp/ox.el`](https://github.com/bzg/org-mode/blob/main/lisp/ox.el) (研究线索; 具体开发必须对照锁定版本)

**最终原则:** 标准 Org 生态负责已经定义好的 preprocessing 与 AST 扩展语义; `org-texmacs` 负责将其结果转换为拥有明确来源、配置及依赖的结构化输入, 再构造 TeXmacs 文档。**自然兼容**与**受控的输入所有权**应当同时成立。





## 11. Phase 0 调查结果与开发计划修订（2026-10-13）

**性质：** 对前述开发指导的增量修订。

**依据：** Issue #1 Phase 0 的源码调查、14 项隔离实验及 GAW 归档。

**状态：** Phase 0 已完成；Phase 1 的实现合同尚待确定。

### 11.1 基线与证据

本次调查使用以下项目状态：

| 项目 | 状态 |
|---|---|
| `main` | `b22945493102edc1823fe063f9d278ba628bdf5e` |
| `_agents` | `1f8f6ff2488b22a95464907a76f2d93aeceae5ef` |
| Emacs | 31.1 |
| Org | 9.8.10 |
| Phase 0 隔离 ERT | 14/14 通过 |
| 生产代码 | 未修改 |

完整调查报告与可复现实验保存在：

- `_agents/archive/2026-10-12T19-11-59Z--b229454/MANIFEST.md`
- `files/tmp/issue-1-phase-0/REPORT.md`
- `files/tmp/issue-1-phase-0/REPRODUCE.md`
- `files/tmp/issue-1-phase-0/probes.el`

归档路径以 `MANIFEST.md` 为入口。

本次测试使用项目更新后的 flake lock。此前的 Org 9.8-pre、9.8.8 观察不再作为当前开发基线。

本次 14/14 是独立调查验证，不代表完整项目回归测试。`v0.4.0` 的 312/312 ERT 和七项 Nix checks 属于历史发布证据。

### 11.2 对原指导文件的修正

以下结论优先于原文中与其冲突的描述。

**A. 锁定 Org 版本不存在 after-includes hook**

原文 §2.2、§4 等位置提到了 `org-export-after-includes-functions`。

Phase 0 确认，项目当前锁定的 Org 9.8.10 没有这一 hook。

开发应以实际安装版本的 `ox.el` 为依据，不根据上游其他修订或一般流程说明推断某个 hook 一定存在。

**B. 原生 AST filter 可以独立于 generic exporter 复用**

Phase 0 已验证：

- 可以使用真正的 `texmacs` backend。
- 可以通过标准 filter 安装与调用工具执行 citation key remapping。
- Filter 结果可以继续保持结构化 Org AST。
- 不需要调用 generic string transcoder。
- 不需要引入第三方 package 专用 registration。

因此，Phase 1 可以先在现有 preparation 上实现受控的 AST filter 集成，而不必以完整 preprocessing 为前置条件。

**C. 不应直接复用完整的 `org-export--annotate-info`**

调查确认：

- 即使关闭 Org Cite export processors，完整 annotation 仍可能调用 `org-id-find`。
- 工作 buffer 的复制不保证可变 buffer-local 配置对象被深度复制。
- Org export 的 environment 收集及相关处理可能读取 SETUPFILE。
- 禁用 Cite processors 也会跳过相应的 bibliography discovery。
- 完整 annotation 产生的 AST 和 INFO 不自动满足 `org-texmacs` 的 ownership 与 provenance 合同。

因此，完整原生 annotation 只能保留为研究候选，不能直接替换当前生产 preparation。

**D. INFO 与 AST 的时序必须明确**

原生 parse-tree filters 执行时，INFO 的 `:parse-tree` 尚未完成最终收集。

Adapter 必须使用 filter 收到的 AST 参数，而不能假定 INFO 已经持有最终 AST。

此外，filter 可以返回替换后的整棵 AST。既有 STM island 和 post-blank 映射依赖节点身份，不能在 AST replacement 后未经校验继续使用。

**E. INCLUDE 的来源信息仍不充分**

受控实验确认原生递归 INCLUDE 能够重定位嵌套文件链接。

但实验没有获得可满足当前 STM provenance 要求的完整 origin map。

因此，正确的文件链接重定位不等价于完整的跨文件来源追踪。不能仅凭前者宣布多来源 STM islands 已受支持。

### 11.3 修订后的实施顺序

保留原文 §6 的总体阶段结构，但将 Phase 1 明确拆分。

| 阶段 | 目标 | 状态 |
|---|---|---|
| Phase 0 | Org 信息流、副作用与结构化接入点调查 | 已完成 |
| Phase 1a | 定义受控 AST filter 接入合同 | 下一步 |
| Phase 1b | 在现有 preparation 中实现最小 AST filter 集成 | 待合同确定 |
| Phase 2 | 研究受控 preprocessing、INCLUDE 与多源 provenance | 独立设计 |
| Phase 3 | 接入 Org Cite bibliography discovery 和外部输入快照 | 独立设计 |
| Phase 4 | 真实第三方扩展组合测试与前端集成 | 后续 |

Phase 2 与 Phase 3 的具体实施先后可以根据依赖关系调整，不必在当前阶段锁定。

### 11.4 Phase 1a：确定最小 AST filter 合同

本阶段首先研究和确定以下接口语义，不直接进行广泛的生产重构。

**1. Filter 来源与调用方式**

优先复用：

- `org-export-install-filters`
- `org-export-filter-apply-functions`
- `org-export-filter-parse-tree-functions`

明确 backend identity、INFO 构造与过滤器运行上下文。

不得要求第三方 package 向 `org-texmacs` 显式注册。

也不得为了调用 filters 而执行完整 `org-export-as`。

**2. 第一批允许的 AST 修改**

建议最初仅允许：

- 保持 Org AST 的节点集合及父子关系。
- 保持既有节点身份。
- 仅修改 `citation-reference` 的 `:key`。
- 不改变 STM island 的源文本、身份或归属。
- 不引入新的外部依赖或未支持节点。

其他修改必须显式拒绝，不能静默忽略。

这是 Phase 1 的最小支持合同，而不是对标准 Org AST filters 能力的永久限制。

**3. AST ownership 与验证**

Filter 可能原地修改 AST，也可能返回另一棵 AST。

开发必须明确如何验证：

- 输入与输出的结构和身份一致性。
- 除允许字段之外的语义数据未被修改。
- `islands`、`post-blanks` 等 identity-keyed mappings 仍有效。
- `:parent` 关系保持正确。
- Filter 没有将 citation 转换成 backend-specific `raw` 输出。

仅检查根节点是否相同并不足以证明 AST 安全。

如果现有映射不再有效，应当拒绝转换，而不是继续使用 stale mappings。

**4. INFO 与执行上下文**

定义第一批支持的 INFO 字段及其来源。

需要明确：

- 过滤器接收到的 backend 名称与对象。
- 执行时的私有 Org buffer。
- 哪些配置来自源快照。
- 哪些 INFO 字段尚未建立。
- 哪些标准过滤器行为无法在这个受限阶段复现。

不得将不完整 INFO 伪装成已经完成的通用 Org export environment。

任意用户 filter 的外部副作用不能被视为已沙箱化。

**5. 与现有 preparation 的衔接**

AST filter 应在 owning 和后续 document-wide semantic resolution 之前完成。

需要明确它与以下既有阶段的精确先后关系：

- STM fragment discovery 和 mask。
- `org-element-parse-buffer`。
- `org-texmacs--context-prepare` 中的 pruning、selection 和依赖恢复。
- Island/post-blank 映射构造。
- `org-texmacs--document-resolve`。
- `org-texmacs--bibliography-plan`。
- `org-texmacs-input-create`。

不得在 bibliography plan 已建立后仅临时更改 citation key，从而留下不一致的依赖或解析结果。

### 11.5 Phase 1b：最小实现与验收

Phase 1a 合同确定之后，再实现一个独立、可审阅的生产修改节点。

**首个正向案例：**

1. Org 文档包含一个以内部 UUID 表示的 citation。
2. 调用方仍显式提供 BibTeX 文本快照，其 entry key 为外部 citekey。
3. 标准 AST filter 将 citation key 从 UUID 转为外部 citekey。
4. 当前 document-wide resolution 和 native bibliography 路径使用转换后的 key。
5. 原始 Org buffer 保持不变。

这一节点应覆盖：

- 不安装 filter 时，原有 v0.4.0 文档语义不变。
- 安装受控 filter 后，owned AST 包含转换后的 citation key。
- 原始源文本与原始 citation UUID 不变。
- Native bibliography 与 citation resolution 使用一致的 key。
- Filter 引用不存在的 bibliography entry 时显式报错。
- Filter 返回替换 AST、破坏节点身份、修改 STM 映射或引入不支持节点时显式拒绝。
- Filter 抛出异常后，不污染源 buffer、全局 hooks、其他 backend 或 worker 状态。
- Source/configuration 在 worker wait 期间变化时，沿用现有一致性拒绝策略。
- 现有 HTML backend 与 generic TeXmacs export guard 不退化。

这些测试应进入项目维护的 ERT/Nix checks，而不仅保存在临时 probe 中。

第一批使用受控 filter fixture 即可。真实 `org-roam-organize` 集成应在接口稳定后验证，不能把模拟测试称为真实包兼容性测试。

### 11.6 Phase 2 与 Phase 3 的新增前置条件

**Phase 2：Org-compatible preprocessing**

在开始生产集成前，必须分别确定：

1. 原始 source selection 与预处理后 working document 的映射。
2. STM island 应在 preprocessing 前还是后发现与 mask。
3. 多文件 INCLUDE 的来源追踪策略。
4. 包含文件的相对资源路径与 root `resource-base` 的关系。
5. 工作 buffer 配置对象如何与源 buffer 隔离。
6. 外部文件读取、递归范围和状态变化如何进入 snapshot 合同。
7. 哪些 Org 原生阶段可以作为受控单元复用。

禁止通过全局 advice、monkey patch 或中途截断通用 exporter 等脆弱手段，绕过尚未解决的输入边界。

如果不能安全分离完整原生 annotation，应优先使用受控的分阶段 adapter，而不是直接接受其全部副作用。

**Phase 3：Bibliography discovery**

需独立解决：

- Org Cite document/global/managed bibliography path 的合并。
- 路径保持相对形式时的语义和归一化时机。
- SETUPFILE 对路径发现及外部读取的影响。
- 第三方 advice 查询数据库时的副作用与一致性范围。
- 发现的路径如何变成显式 BibTeX 文本快照。
- 与原有 `bibliography-sources` 参数的兼容关系。

不得因为关闭 Org Cite 输出处理，就误以为 bibliography discovery 已正常执行。

多系统外部输入也不能被无依据地声明为原子一致快照。

### 11.7 设计选择与停止条件

Phase 0 比较了两个候选：

**候选 A：现有 preparation + 标准 AST filters**

作为 Phase 1 的首选。

优点是保留既有源快照、selection、STM provenance 和 lowering，只新增一个范围明确的 Org 标准扩展阶段。

其代价是暂时不提供完整 Org export lifecycle，也不能保证所有第三方 filters 立即兼容。

**候选 B：原生 working buffer + 完整 annotation**

继续保留为后续研究方向，不直接进入生产实现。

当前证据表明它存在额外的 I/O、配置别名、ID 查询、AST 身份和 selection/provenance 风险。

如果候选 A 无法满足第一批受控 citation key filter 合同，应暂停并记录原因，而不是自动退回候选 B。

以下情况同样属于停止条件：

- 必须放弃 AST-first 才能完成接入。
- 无法确认 filtered AST 与 island mappings 的对应关系。
- 必须在纯 lowering 中增加隐式外部文件或数据库查询。
- 必须移除当前 generic export guard 才能运行最小 filter。
- 需要通过不可解释的全局状态覆盖保证单次转换结果。
- 无法在失败时维持已承诺的 source ownership 与一致性边界。

### 11.8 对 Issue #1 方向的最终确认

Phase 0 并未否定最初的信息流目标。

继续采用以下原则：

> 复用 Org 既有的标准扩展机制，使兼容这些机制的第三方 package 尽可能自然参与 TeXmacs 文档生成，而不是建立按 package 名称区分的注册框架。

但这属于**总体架构原则**，不意味着必须一次性接入整个 Org exporter。

当前最佳推进方式是：

1. 在既有 preparation 上完成标准 AST filter 的最小、受控复用。
2. 保持纯结构化转换和 native consumers 不变。
3. 分别研究 preprocessing 与 bibliography discovery 的外部依赖合同。
4. 最终再将这些已验证的阶段组织成一致的 Org-to-TeXmacs 信息流。

本补充不要求重新发布 `v0.4.0`，也不要求立即修改 Issue #1 的总体目标。

**下一开发节点：Phase 1a — 定义 citation-key AST filter 接入合同。**

Phase 1b 的生产实现应以该合同和对应负向测试为前提，不得将 Phase 0 的工具级可行性实验直接视为生产接口已完成。







## 12. Phase 1 完成后的开发指导更新（2026-10-13）

**性质：** 对既有开发指导的增量更新，优先于前文已过时的阶段状态与下一步安排。

**依据：** `main@c26b932`、`_agents@fef0eb1`、`memory/filter-contract.md`、`memory/current.md`、Phase 0 调查归档和 Issue #1 进展评论。

**状态：** Phase 0、Phase 1a 和 Phase 1b 已完成；Phase 2–4 尚未形成完整实施合同。

### 12.1 已完成工作的确认

Phase 1 已通过提交 `c26b932a8376c610603eaeb0f9ed8af98c1f6476` 合入 `main`。

新增功能通过标准 Org AST filter 接口实现受限的 citation-key remapping，不要求其他 package 显式注册到 `org-texmacs`。

当前生产合同如下：

- 通过 `org-export-install-filters` 获取标准 parse-tree filters，通过 `org-export-filter-apply-functions` 执行。
- 使用真正的 `texmacs` backend；不要求安装完整导出菜单。
- 在 private preparation 中运行，位于 selection、pruning、dependency restoration、STM mapping 之后，document-wide resolution、bibliography planning 和 native operations 之前。
- 仅允许修改已有 `citation-reference` 的 `:key`，且新值必须为非空字符串。
- 对每个 filter 的输出进行 AST 拓扑、节点身份、父子关系、其他字段、INFO、STM 映射和工作 buffer 状态检查。
- Filter 完成后重新拥有 AST 与依赖映射，避免 filter 保留的引用影响后续 native waits。
- 保留现有 generic export guard；不执行完整 Org preprocessing、Org Cite output processors 或自动 bibliography discovery。

详细接口合同以 `_agents/memory/filter-contract.md` 为准，不在本指导中复制其全部约束。

Phase 1 验证结果：

| 验证项目 | 结果 |
|---|---|
| Focused ERT | 12/12 |
| Installed ERT | 324/324 |
| Independent flake checks | 8/8 |
| 编译与 package-lint | 通过 |
| Native bibliography 与 session readback | 通过 |
| 真实 Org-roam 联合测试 | 未进行 |

验证环境为 Emacs 31.1、Org 9.8.10、TeXmacs 2.1.5，使用项目锁定依赖与授权的镜像传输环境。

这些结果不构成其他平台、官方 ELPA 下载可用性或任意第三方 AST filter 兼容性的证明。

**Phase 1 不再属于待实现工作。**

### 12.2 下一阶段的选择

Issue #1 后续仍有两条相对独立的主线：

- **Phase 2：Source composition / preprocessing / provenance**。研究标准 Org INCLUDE、buffer-level preprocessing、原始 selection 与处理后 AST 的对应关系，以及多文件 STM/resource 来源。
- **Phase 3：Bibliography discovery / owned dependency acquisition**。研究 Org Cite 的标准 bibliography discovery 如何衔接已有显式 BibTeX text snapshot 与 native bibliography。

建议优先进行 **Phase 3 的合同研究**，理由是 Phase 1 已经提供 citation-key remapping，而 bibliography discovery 是形成完整 managed citation 使用链路的下一处主要缺口。

这只是推荐顺序，不代表 Phase 2 必须等待 Phase 3 完成。二者原则上应分别设计和验证。

下一节点建议命名为：

**Phase 3a — Org Cite bibliography discovery contract investigation**

本节点首先调查和确定接口语义，不直接改变生产代码。

### 12.3 Phase 3a：Bibliography discovery 合同调查

首要目标是区分三种数据：

1. Org 文档声明及标准 Org Cite 扩展接口发现的 bibliography identities。
2. 经过来源解析与路径归一化得到的 bibliography source identities。
3. 已读取、验证并拥有的 BibTeX text snapshots。

不得将这三类数据混为一谈。

建议的信息流为：

```text
Org source + selected configuration
    |
    v
Org Cite bibliography discovery
    |
    v
Bibliography path identities
    |
    v
Owned acquisition / validation adapter
    |
    v
Explicit BibTeX text snapshots
    |
    v
Existing native bibliography preparation
    |
    v
Prepared input / TeXmacs document
```

其中 discovery 与 acquisition 都属于有副作用的 adapter 层；纯 lowering 不读取文件或查询数据库。

#### A. 标准接口复用

调查以下 Org Cite 接口的实际合同与调用上下文：

- `org-cite-list-bibliography-files`
- `org-cite-store-bibliography`
- 与 bibliography environment 相关的 Org export 选项收集

优先采用标准 Org Cite 接口，而不是直接调用 `org-roam-organize` 的专用函数。

需要分别验证文档内声明、全局变量、第三方 advice 的合并行为、优先级与去重语义。

注意：Phase 0 已确认 bibliography discovery 可以通过 SETUPFILE 读取额外配置，不得将该接口无条件认定为纯函数。

#### B. 路径及来源语义

确定 bibliography path 在以下场景中的解释方式：

- 普通 visiting Org 文件。
- Non-file Org buffer。
- 显式 `resource-base`。
- 相对路径与绝对路径。
- SETUPFILE 引入的 bibliography 声明。
- 由第三方 advice 提供的路径。
- 重复或同一文件的不同路径表示。

特别需要检查返回路径是否已归一化，还是仍然依赖其声明来源。

任何归一化规则都应由实际锁定 Org 版本的源码和实验支持。

不能因为某个函数的文档将路径称为 absolute，就直接假定实际返回的每条路径都是绝对路径。

#### C. 外部输入所有权

建议将外部文件读取放在独立 acquisition 阶段。

必须明确：

- 何时读取 bibliography text。
- 如何检查文件身份与内容是否发生变化。
- 如何处理不存在、不可读和非法的 BibTeX source。
- 如何与调用方原有的显式 `bibliography-sources` 参数组合。
- 同一 source identity 出现多次时如何处理。
- 当第三方 discovery 查询 Org-roam 数据库时，能够承诺什么程度的一致性。

文件、数据库及 Org buffer 不天然共享一个原子事务。不能在缺乏机制支持的情况下宣称多来源 snapshot 具有严格事务一致性。

#### D. 显式输入 API 的兼容性

现有的 `bibliography-sources` 参数应继续是稳定的显式数据入口。

自动发现不能静默覆盖调用方提供的 source text。

研究阶段需要比较以下方案：

- 自动 discovery 仅作为交互式 frontend 的可选策略。
- 显式 source API 提供独立的 opt-in discovery 策略。
- 一个独立 adapter 负责 discovery/acquisition，并调用现有 prepared-input API。

优先评估能否保持 core API 不变，通过上层 adapter 构造已有的显式参数。

不预先规定必须增加新的 public option 或 `org-texmacs-input` slot。

#### E. 与 Phase 1 的衔接

Phase 1 AST filter 现在可能将 citation UUID 转换为 BibTeX entry key。

Phase 3 必须保证：

- Discovery 和文本读取不会使已有 citation-key filter 重复执行。
- Filter 后 citation key 与最终 owned bibliography entry keys 一致。
- 现有 `org-texmacs--bibliography-plan` 能继续完成引用校验。
- 未解析的 key、重复 key 和无效 BibTeX 继续显式报错。
- Native bibliography 处理不依赖 Org-roam 数据库或原始 source buffer。

不得通过启用完整 Org Cite output processor 解决 bibliography discovery，因为那可能把 citation AST 转换成 backend-specific raw 输出。

### 12.4 Phase 3a 的实验要求

研究应优先使用受控、可复现的临时数据，而非真实个人文献数据库。

至少验证：

1. 文档内 `#+bibliography:` 与全局 bibliography 的合并。
2. 标准接口上可观察的模拟第三方 advice。
3. 相对路径、重复来源及路径归一化。
4. SETUPFILE 对路径发现和实际文件读取的影响。
5. Core discovery 与 BibTeX text acquisition 的区别。
6. 在受控条件下，source/configuration 变化是否影响 discovery 结果。
7. 与 Phase 1 citation-key filter 的阶段关系。
8. 不启动 generic string exporter 或 Org Cite output processor。

针对可能导致外部读取或数据库查询的操作，应使用隔离临时文件、受控替身或明确授权的测试依赖。

研究结果应记录 API、输入/输出、副作用、环境依赖和失败边界，而不只是测试是否成功得到 bibliography 列表。

### 12.5 Phase 3b 的实施条件

只有 Phase 3a 明确接口合同后，才进入生产实现。

推荐将 Phase 3b 限定为一个可审阅的最小节点：

- 使用标准 Org Cite discovery 获取 source identities。
- 在可控 adapter 中冻结并验证所需文本。
- 复用现有显式 bibliography snapshot 处理。
- 保持 Phase 1 AST filter 合同不变。
- 不将隐式 I/O 引入纯构造器或 lowering。
- 不因自动 discovery 而改变既有显式输入调用的默认语义，除非另有明确设计决定。

需要保留完整的失败隔离、源一致性和 native bibliography 回归。

如无法建立合理的一致性合同，应停止并记录限制，而不是依赖当前文件系统状态在多个不同阶段反复读取。

### 12.6 Phase 2 的保留工作

Phase 2 仍然是 Issue #1 中的重要架构任务，不因优先推进 bibliography discovery 而取消。

其主要未决问题保持不变：

- Preprocessing 前后的 source coordinate 映射。
- STM island discovery 与 masking 的时序。
- INCLUDE 多来源文本的 origin/provenance。
- 多文件相对 resource paths 与 root resource-base。
- Subtree、region、narrowing 的 selection/configuration 语义。
- Mutable buffer-local 设置的独立所有权。
- Hooks、macros、Babel 和其他 preprocessing 操作的副作用界限。

Phase 0 已发现完整 `org-export--annotate-info` 存在额外的 ID lookup、配置别名和输出转换风险。

不得在缺乏新证据的情况下，将完整 native annotation 直接作为现有 preparation 的替代。

Phase 2 应继续研究受控 source-composition adapter，并与 Phase 1/3 的已验证接口衔接。

### 12.7 真实第三方兼容性验证

Phase 1 的受控测试证明了标准 AST filter 集成的可行性，但还不能宣称已经实现真实 `org-roam-organize` 兼容。

在 Phase 3 的接口具备后，应单独安排联测：

- `org-roam-organize` 的 managed bibliography discovery 与 UUID-to-citekey 转换。
- 现有 Org Cite bibliography declarations 与显式 BibTeX snapshots。
- 原始 Org source 不变与 owned result 一致性。
- 原有 HTML export 及其他 backend 的非干扰性。

`org-roam-include` 的真实兼容性应等待 Phase 2 的来源与输入合同明确后再验证。

`org-roam-blog` 的 HTML publishing 不属于 TeXmacs consumer 实现目标，其测试重点仍是共存和非干扰。

真实外部包联测必须与受控模拟夹具的结果分开记录。

### 12.8 开发与 GAW 交接要求

- 以当前 `main@c26b932` 为业务代码起点，不重新实施已经完成的 Phase 1。
- 将 `_agents/memory/filter-contract.md` 视为 Phase 1 的现行合同。
- Phase 0 调查归档保持不变，不因后续方案调整改写历史证据。
- Phase 3a 先产出调查结果、方案比较与拟定合同；生产改动由后续节点承担。
- 验证使用项目 flake 锁定的 Emacs、Org 和 TeXmacs 版本，记录测试环境及镜像/缓存限制。
- 必要的可复现实验证据按 GAW archive 工作流保存，避免将临时二进制、缓存或可再生构建产物放入 archive。
- 不在没有明确需求时扩大到完整 generic `org-export-as`、自动 Babel 执行、多 session 或增量同步。

### 12.9 当前开发决策

**已完成：** Phase 0、Phase 1a、Phase 1b。

**建议下一节点：** Phase 3a — 调查并定义 Org Cite bibliography discovery 与 owned text acquisition 合同。

**随后：** 在合同可验证的情况下实施 Phase 3b；Phase 2 可独立进行，不要求固定顺序。

**长期方向不变：** 复用 Org 标准信息流与扩展点，实现自然兼容，同时保持 Org canonical source、AST-first、coherent owned inputs、STM provenance 与纯 lowering。

Issue #1 在 preprocessing、bibliography discovery 和真实第三方兼容性验证完成前继续保持开放。

本补充不构成 Phase 3b 或 Phase 2 生产实现的自动授权。











## 13. Phase 3a 完成后的开发计划（2026-10-13）

**性质：** 对原开发指导文件的增量更新。本文优先于此前章节中已经过时的 Phase 3 状态及实现假设。

**当前基线：**

- `main`: `c26b932a8376c610603eaeb0f9ed8af98c1f6476`
- `_agents`: `933191c8fed8e8a0bbcfee454cc4b67d80107e7f`
- Emacs 31.1 / Org 9.8.10
- Phase 3a: 25/25 隔离探针通过
- Phase 1: 324/324 installed ERT、8/8 flake checks 通过

**主要依据：**

- `_agents/memory/bibliography-contract.md`
- `_agents/archive/2026-10-13T13-27-14Z--c26b932/MANIFEST.md`
- 归档内的 `REPORT.md`、`CONTRACT.md` 和 `REPRODUCE.md`
- [Issue #1 Phase 3a 进展评论](https://github.com/ren-lingyu/org-texmacs/issues/1#issuecomment-6147441547)

Phase 3a 已完成，但没有修改生产代码。以下计划是对 Phase 3b 的建议，尚不代表其生产接口已经获准实施。

### 13.1 阶段目标

Phase 3b 的目标是通过标准 Org Cite bibliography discovery 获得有效文献来源，再将其转换为 `org-texmacs` 已有的 owned bibliography 数据。

首个实现节点应当建立：

```text
Explicit Org source
       |
       v
Owned source/configuration capture
       |
       v
Private STM-masked bibliography discovery
       |
       v
Source identity normalization and merging
       |
       v
Owned BibTeX text acquisition
       |
       v
Effective bibliography declaration context
       |
       v
Existing Phase 1 preparation and AST filters
       |
       v
Existing bibliography planning / native consumers
```

保持以下原则：

- 复用标准 Org Cite 扩展接口，不要求第三方 package 显式注册。
- 保持原有显式 source APIs 的默认行为。
- 将外部文件读取和状态检查限制在有明确所有权的 adapter 层。
- 不在 pure lowering、input constructor 或 bibliography planner 中引入隐式 I/O。
- 不通过修改原始 Org 文本、添加伪造的 BIBLIOGRAPHY keyword 或替换全局 collector 来传递发现结果。
- 保持 Phase 1 的 AST filter 合同与执行次数不变。

### 13.2 需要首先审定的设计选择

在正式实现之前，先审阅并确认以下决策。

**A. Adapter 位置与公开接口**

推荐独立的 opt-in adapter，而不是默认修改现有全部 buffer/document/export APIs。

现有 `bibliography-sources` 参数继续代表调用方显式提供的文本快照。

新增 adapter 负责发现、获取与验证，并调用共享 preparation。

首个公开入口建议优先提供完成的 document 或 native bytes；文件保存、重复导出和交互式菜单策略可以后续独立接入。

公开函数命名及内部参数名称可由实现阶段选择，但不能因此改变既有 API 的默认副作用边界。

**B. Effective declaration view**

Phase 3a 已证明，只有 BibTeX texts 并不足以支持 global/advice-only bibliography 来源。

因此，需要在 preparation 的 context 边界引入一个显式且已拥有的 effective declaration view。

该结构至少要能够表达：

- 原始文档声明及其路径对应关系。
- 经过 discovery 得到的有效来源 identity。
- 最终参与 citation resolution 的来源集合及顺序。
- 原始声明与新来源的区别。

纯 planner 已能消费相应的显式数据；优先复用现有语义，不增加新的 `org-texmacs-input` slot。

不得把这个内部上下文接口误写成第三方 database lookup API。

**C. Bibliography 来源目录**

Phase 3a 发现，visiting file 的目录与源 buffer 的有效 `resource-base` 不一定一致。

推荐首版在二者不一致时显式拒绝自动 discovery，而不是自行选择一个目录并静默更改原有路径语义。

此限制只针对首版自动获取策略，不改变文件链接的 resource-base，也不规定未来必须永久拒绝这种情况。

**D. 自动读取限制**

首版建议仅支持：

- 本地常规文件。
- UTF-8 BibTeX 文本。
- 每文件最多 1 MiB，作为初始实现上限。
- 不自动读取 symlink、remote/URL、tilde 或存在物理别名冲突的来源。
- 不执行真实 SETUPFILE、INCLUDE、BIND、宏或 Babel preprocessing。

这些是待审的初始支持限制，不是 Org Cite 本身的永久语义。

尤其应区分 lexical source identity、physical file identity 和调用方提供的纯文本 identity。

### 13.3 建议拆分的实现节点

Phase 3b 不必强制一次完成所有代码。推荐保留以下逻辑边界。

**Node A：Effective declaration context**

先增加并测试 preparation 接收 owned effective declaration view 的内部接口。

该节点应使用显式结构化数据验证：

- 文档原有 bibliography 声明仍然正确。
- Global-only bibliography 可以进入现有 citation resolution。
- 未参与选择的显式文本继续保持独立。
- 无效或歧义声明显式失败。
- Phase 1 citation-key remapping 只执行一次。
- Pure planner 不读取外部文件。

此节点可以先不实现磁盘 discovery/acquisition，但不应推出尚未支持的自动发现公开接口。

**Node B：Discovery 与 acquisition adapter**

在 Node A 的数据边界稳定后，建立独立 opt-in adapter。

需要完成：

1. 在 discovery 前捕获源文本、selection、配置和已有显式 bibliography texts。
2. 创建完整私有 Org discovery view，屏蔽全部已发现 STM islands，包括当前正文范围之外的内容。
3. 在适当阶段禁用 BIND，并拒绝未支持的真正 preprocessing 指令。
4. 使用标准 `org-cite-list-bibliography-files`，保证每次转换只执行一次 discovery。
5. 立即复制返回的路径，进行路径分类、归一化与去重。
6. 保留显式文本的优先权，只读取缺失的已发现来源。
7. 将 effective declaration view 与 owned BibTeX 文本一起交给共享 preparation。

不得将标准 discovery 的结果假定为绝对路径，也不得假定原生去重能去掉第三方 advice 随后引入的重复项。

**Node C：完整事务与输出前验证**

统一现有 source consistency checks、acquisition receipts 和 native operation 生命周期。

需要确保：

- Discovery 开始前的源状态是整个事务的基准。
- Filter、source configuration、显式 bibliography texts 在相关等待期间的变化仍受到检查。
- 自动读取内容固定为 owned text，后续检查只验证依赖是否失效，不重新读取内容用于替换结果。
- 依赖变化时拒绝返回不一致的 document 或 bytes。
- 对文件 consumer，必须在真正写入之前完成依赖验证。
- 不因为检测到变化就自动重试 discovery 或执行第二次 AST filter。

如果首个公开入口只返回 document/bytes，可以将文件发布策略留给后续节点，但不能宣称尚未实现的 file-output 检查已经覆盖。

### 13.4 测试与验收要求

Phase 3a 的 25/25 探针只验证调查组件，不能代替 Phase 3b 的完整事务测试。

正式实现至少覆盖以下方面：

| 类别 | 必须验证的行为 |
|---|---|
| 默认兼容性 | 旧 API 无 discovery、无额外文件读取 |
| 标准扩展点 | Org Cite discovery 及受控 advice 正常参与 |
| STM 隔离 | 内联、block、被选区排除的 STM 均不被误判为 bibliography 声明 |
| 来源路径 | Visiting/non-file buffer、相对路径、目录冲突、重复 identity |
| 显式优先 | 显式 texts 不被磁盘内容覆盖，也不因路径不存在而被拒绝 |
| 自动获取 | 正常 UTF-8 BibTeX、大小限制、非法文本、缺失文件及不支持来源 |
| 一致性 | 发现、读取、native wait 和输出前的源/依赖变化 |
| Phase 1 组合 | UUID-to-citekey remapping、有效 declaration、native bibliography 一致 |
| 异常处理 | Cleanup、worker 生命周期、无泄漏的临时状态 |
| 其他 backend | HTML/ASCII 隔离和 generic TeXmacs export guard 不退化 |

测试使用项目锁定的 Emacs、Org 和 TeXmacs 版本，并分别记录受控替身、真实文件访问与 native consumer 的验证范围。

必须明确：文件属性与内容哈希验证只是被观察到的依赖一致性机制，不是数据库与文件系统的原子事务，也不能保证防止所有 ABA 变化或竞态。

### 13.5 不属于 Phase 3b 首版的工作

以下工作保持独立：

- 完整 Org preprocessing 和 INCLUDE 展开。
- 多来源 STM origin/provenance。
- 真实 SETUPFILE 依赖追踪。
- 远程 bibliography 与 URL 获取。
- 任意 Org Cite export processor 或扩展 citation styles。
- 任意第三方 advice 的沙箱执行及数据库事务一致性。
- Generic `org-export-as` 的完整兼容。
- 对所有既有交互式 export actions 默认启用自动 bibliography discovery。

这些内容不因 Phase 3b 支持标准 bibliography discovery 而自动成为已实现功能。

### 13.6 与 Phase 2、Phase 4 的关系

**Phase 2** 仍负责 source composition、preprocessing 和多来源 provenance。

Phase 3b 的完整 STM-masked discovery view 是专用于 bibliography 发现的受控视图，不应被直接视为通用 Org preprocessing framework。

**Phase 4** 负责真实第三方包的联合验证。

在 Phase 3b 完成后，优先验证 `org-roam-organize` 的 managed bibliography discovery 和 citation UUID remapping，而不是仅以受控 advice 模拟结果证明真实兼容。

`org-roam-include` 的真实联测应等待 Phase 2 有明确来源合同之后进行。

### 13.7 下一步执行要求

建议开发 agent 按以下顺序推进：

1. 审阅 `_agents/memory/bibliography-contract.md`，确定首版目录冲突、文件范围、别名策略与 opt-in 接口。
2. 优先实现 Node A 的 effective declaration context 数据边界及纯结构化测试。
3. 在该接口验证后实现 Node B 的 discovery/acquisition。
4. 通过 Node C 的完整一致性测试后，再将 opt-in adapter 视为可用功能。
5. 每个节点独立记录验证与 GAW checkpoint，避免将未通过完整测试的阶段标记为已完成。

只有 Node A/B/C 的衔接及完整 source-to-native 验证成立，才能宣称 Phase 3b 完成。

### 13.8 当前工作状态

- **Phase 0：** 完成。
- **Phase 1a/1b：** 实现、验证并提交。
- **Phase 3a：** 调查完成，25/25 隔离探针通过。
- **Phase 3b：** 合同待审，生产实现未开始。
- **Phase 2：** 独立设计，尚未实施。
- **Phase 4：** 真实第三方联合验证，尚未开展。

**推荐下一正式节点：审定 Phase 3b 合同，并从 Node A 的 effective declaration context 开始实施。**

继续保持 Org 标准扩展点自然兼容、Org canonical source、AST-first、显式 owned inputs、STM provenance 和 pure lowering 的总体设计原则。

本补充是实施指导，不自动授权扩大到 Phase 2、完整 Org export pipeline 或未审定的外部读取行为。








## 14. Phase 3b 完成后的 Phase 2 开发计划（2026-10-13）

**性质：** 增量开发指导，优先于此前章节中关于后续阶段顺序的建议。

**业务代码基线：** `main@049a5a00bdd52d83e1f03823accc9324f4bcee0c`

**GAW 基线：** `_agents@a8574d94db1e4af5f67c3feda1c2effe22240381`

**当前状态：** Phase 0、Phase 1、Phase 3a/3b 已完成。Phase 2 尚未实施，Phase 4 的真实第三方组合验证仍未进行。

### 14.1 目标与阶段顺序

优先推进 Phase 2，再进行完整 Phase 4。

Phase 2 旨在复用 Org 的标准 preprocessing 和 source-composition 机制，使标准 Org 扩展点提供的文档语义能够进入 TeXmacs structural lowering，同时保留：

- Org canonical source。
- AST-first conversion。
- Coherent owned input。
- STM island identity 与 source provenance。
- External dependency ownership。
- 纯 lowering 与 native consumer 分离。
- 对其他 Org backend 的非干扰性。

推荐顺序：

1. Phase 2a：信息流、source composition 和 provenance 合同调查。
2. Phase 2b：按照 Phase 2a 的合同实施受控 preprocessing。
3. Phase 4：真实第三方 package 联合验证。

不要求 Phase 2 一次实现所有 Org export preprocessing 功能，也不将完整 `org-export-as` 兼容作为 Phase 2 的前置目标。

### 14.2 Phase 2a：首先确定信息流合同

以项目锁定的 Emacs 31.1 / Org 9.8.10 为准，调查实际 export preparation 的各个阶段。

重点研究：

- `org-export-before-processing-functions`。
- `org-export-expand-include-keyword`。
- `org-export-before-parsing-functions`。
- Org parser 及相关配置刷新。
- AST pruning、parse-tree filters 与 effective environment。
- Subtree、region、narrowing 对 preprocessing 的影响。

注意，Phase 0 已确认锁定的 Org 版本不存在 `org-export-after-includes-functions`。

必须区分可以独立复用的原生处理阶段与依赖完整 exporter 内部状态的阶段。

不得通过完整 `org-export--annotate-info` 直接替换当前 preparation，也不得将标准 Org hook 的简单手工调用等同于完整原生生命周期。

### 14.3 核心设计问题：原始来源与工作文档

Phase 2 首先需要明确三个不同层次：

```text
Canonical Org source
        |
        v
Owned original-source snapshot
        |
        v
Preprocessed Org working document
        |
        v
Owned parsed Org AST + provenance
        |
        v
Existing structural preparation
        |
        v
TeXmacs document / native consumers
```

原始 source snapshot 与 preprocessed working document 不得混同。

特别需要研究：

1. 原始文本经过插入、删除、宏展开或 INCLUDE 后，原始 source positions 如何对应工作文档位置。
2. STM island 应在 preprocessing 前还是之后识别。
3. 原始 STM 与经预处理插入的 STM 如何建立身份和来源。
4. AST 节点、STM stree 及资源路径是否需要附加 provenance 信息。
5. Preprocessing 后的 AST 如何进入现有 island/post-blank identity mappings。
6. 无法恢复来源时是否应显式拒绝，而不是猜测或静默降级。

不能仅依赖文本内容相等或 source span 数值相等来判断 STM identity。

### 14.4 INCLUDE 与跨文件 provenance

Phase 0 已验证原生 INCLUDE 能对某些嵌套文件链接进行正确的相对路径重定位，但没有证明原生流程提供了完整的 origin map。

因此，Phase 2a 必须调查：

- 原生 INCLUDE 如何读取、展开和归一化嵌套内容。
- 各级包含文件的 source identity、directory 与资源路径。
- INCLUDE 前后文本、AST 节点和 STM islands 的来源对应。
- 相同内容从不同文件多次 INCLUDE 时如何区分。
- INCLUDE 中断、循环、缺失文件和非法嵌套如何处理。
- 文件在准备或 native wait 期间发生变化时如何失效。
- 文档 selection 对完整依赖闭包的影响。

不能将路径重定位正确等同于完整 provenance 正确。

Phase 2b 首批可以选择受控本地 INCLUDE，而不必立即支持远程文件、任意递归机制或所有 Org INCLUDE 参数。

### 14.5 现有 preparation 的衔接要求

Phase 2 不应推翻已经实现的 Phase 1 和 Phase 3b。

需要特别维持以下接口关系：

**Phase 1：AST filters**

- 过滤器只执行一次。
- 保留 citation-key-only 的现行 mutation contract。
- Filter 运行前必须已经建立可校验的 AST/STM identity mappings。
- Preprocessing 不得使 Phase 1 使用失效的 source offsets 或 stale AST keys。

**Phase 3b：Bibliography discovery**

- 保留独立 opt-in adapter 和显式文本优先权。
- 不自动将 general preprocessing 扩展到 bibliography discovery。
- 预处理后的 bibliography 声明如何与原始文档声明、全局来源和 owned text 对应，需要明确约定。
- 不得因 INCLUDE 支持而绕过现有 acquisition/receipt checks。

**Native consumers**

- 继续消费完成的结构化文档。
- 不重新解析 LaTeX、Markdown 或完整 STM 文本来恢复 Org 语义。
- 不在 worker/session 层增加 Org preprocessing 逻辑。

如果 Phase 2 需要修改 prepared-input 的内部表示，应先证明现有结构不足，并明确迁移及兼容性影响，而不是预先增加通用 provenance 字段。

### 14.6 副作用与输入所有权

Preprocessing hooks、INCLUDE、宏、Babel 等机制可能访问外部状态或执行任意用户代码。

必须明确：

- 哪些操作属于受控 adapter。
- 哪些标准阶段在首版启用。
- 哪些阶段仍拒绝。
- 外部依赖如何记录、读取和重新检查。
- 用户 hook 改变源 buffer、全局变量或外部文件时如何处理。
- 工作 buffer 的 mutable local configuration 如何与原始 source 隔离。
- 异常或中断后如何清理私有 buffer 和临时状态。

第一版不应默认启用 Babel 或任意用户 Lisp 宏执行。

不要求对任意用户回调实现沙箱，但不能隐瞒其副作用与当前一致性保证的范围。

### 14.7 Phase 2a 的验证与交付

Phase 2a 应先使用隔离的 Org 文件和受控 hooks，不依赖真实个人 Org-roam 数据库。

建议至少覆盖：

- Preprocessing 前后位置偏移。
- Inline 和 block STM。
- 多文件嵌套 INCLUDE。
- 重复 INCLUDE 同一来源。
- 不同来源包含相同文本。
- 跨文件相对资源路径。
- Subtree、region、narrowing。
- 预处理期间与 native wait 期间的依赖变化。
- Hook 异常、非法返回、源配置修改。
- 与 Phase 1 AST filters 和 Phase 3b bibliography 的组合边界。

Phase 2a 结束时必须交付：

1. 锁定 Org 版本的实际阶段与副作用表。
2. 至少一个可运行的 source-composition/provenance 原型。
3. 对可能实现方案的比较。
4. 明确的输入、身份、依赖和失效合同。
5. 可审阅的 Phase 2b 最小实施节点及验收条件。

所有验证应区分 isolated probes、maintained ERT、native TeXmacs 和真实第三方 package integration，不能混用结论。

### 14.8 Phase 2b 的实施原则

Phase 2a 完成并选定合同后，再实施 Phase 2b。

优先采用可以独立验证的节点，而不是一次性重构整个 preparation。

首版至少应明确支持：

- 哪些 Org preprocessing 阶段。
- 哪类本地 INCLUDE。
- 哪种 STM 来源映射。
- 哪些跨文件资源路径。
- 哪些 selection/configuration 组合。
- 哪些外部依赖失效检查。

不支持的情况继续显式拒绝。

如果无法安全复用完整原生生命周期，应选择分阶段、受控的 adapter，并准确记录它与 Org 原生 export pipeline 的差异。

不应使用全局 monkey patch、中途截断通用 exporter 或未解释的状态覆盖绕过接口问题。

### 14.9 Phase 4 的安排

Phase 4 在 Phase 2 的基础结构稳定后进行。

主要验证：

- `org-roam-include` 的真实 preprocessing/INCLUDE 行为。
- `org-roam-organize` 的 bibliography discovery 和 citation UUID remapping。
- 两种扩展共同存在时的文档来源与依赖一致性。
- `org-roam-blog` 和普通 HTML export 不受到 TeXmacs backend 的干扰。

允许在此之前单独进行 Phase 1/3b 的小范围真实 `org-roam-organize` 验证，但不作为 Phase 2 的阻断条件，也不因此宣称完整 Issue #1 已完成。

### 14.10 当前下一步

**下一正式开发节点：Phase 2a — Org preprocessing/source composition/provenance 合同调查。**

建议首先调查标准 Org INCLUDE 展开和可追踪的 STM 来源表示之间的关系。

Phase 2a 完成前，不直接修改现有生产 preparation 以启用完整 preprocessing。

保留 Phase 1/3b 已验证的合同，Issue #1 继续开放。

本节属于下一阶段的开发指导，不自动授权 Phase 2b 的生产实现或扩大未审定的外部文件访问范围。







## 15（已被第 16 节取代）. Phase 2c：扩展 Org INCLUDE 参数支持

本节保留为早期方案记录。第 16 节是当前执行计划；本节的参数列表作为实验用例，不要求继续扩展 protected mirror 或建立完整原始坐标映射。

**基线：** `main@c525095`，Phase 2b 已实现受控整文件 INCLUDE。

**目标：** 在现有 source snapshot、STM protection、occurrence identity 和 provenance 机制上，支持 Org INCLUDE 的常用参数，使其能够复用文档中的指定章节、行范围和正文内容。

### 实施范围

优先研究并支持：

- `::location`：通过标题、`CUSTOM_ID` 等定位包含内容。
- `:only-contents`：按照 Org 原生语义选择目标内容。
- `:minlevel`：调整包含内容的标题层级。
- `:lines`：选择指定行范围，并正确处理与 location 的组合。

暂缓 `src`、`example`、`export` 等包装模式，以及跨目录资源路径支持。

### 关键约束

1. **复用 Org 原生语义。** 调查锁定的 Org 9.8.10 中 `org-export-parse-include-value`、`org-export--inclusion-absolute-lines` 和 `org-export--prepare-file-contents`，避免重新实现独立的 INCLUDE 解析与选择规则。
2. **保护原始坐标。** 当前临时 mirror 包含额外的 provenance markers 和 STM tokens，不能直接将原始 `:lines` 参数应用于改写后的文件。必须建立选择范围与受保护工作文本之间的正确对应。
3. **维护 STM identity。** 禁止静默截断 STM；重复包含相同片段仍具有独立 occurrence identity。原始范围、工作范围及 generated context 必须明确。
4. **保持文档语义。** 标题层级、脚注、链接及 selection 后的依赖闭包应与受支持的 Org 原生行为一致。
5. **保持既有合同。** 不改变 canonical source、owned dependencies、Phase 1 filters、Phase 3 bibliography 和 pure lowering 的既有边界。

### 开发步骤

1. **Phase 2c-a：** 使用项目锁定的 Org 版本进行隔离实验，确定各参数的原生语义，以及与 protected mirrors、STM 和 provenance 的冲突。
2. **Phase 2c-b：** 确定参数选择和来源映射合同，分阶段实现上述参数。
3. **Phase 2c-c：** 增加维护回归，覆盖参数组合、重复 INCLUDE、截断 STM、标题与脚注、原始位置、依赖变化及 native output。

不支持或无法可靠映射的情况必须显式拒绝。

**验收条件：** 常用参数能够正确选择并组合 Org 内容，且 STM 来源、owned snapshots 和现有 native consumers 保持一致。

Phase 2c 完成后，再优先进行 Phase 4 的真实第三方 package 联合验证。跨目录 STM resource provenance 作为独立后续设计，不作为本阶段的必要交付。




## 16. Phase 2c：简化 Org preprocessing 集成（当前执行计划）

本节取代第 15 节的实现方向。先完成隔离实验和最小合同选择，再依据证据进行重构；现有 Phase 2b 行为在新合同验证前继续作为基线。

**基线：** `main@c525095`，Phase 2b 已实现受限的 preprocessing 与 INCLUDE composition。

**目标：** 重新评估 Phase 2b 的实现路径，优先采用更自然的 Org preprocessing → Org AST → TeXmacs 转换流程，减少 `org-texmacs` 对 INCLUDE 参数、文本变换和 source provenance 的额外适配。

### 16.1 首选架构

建议将 preprocessing 视为独立的输入准备阶段：

```text
Canonical Org source
        ↓
Owned source snapshot
        ↓
Org native preprocessing
        ↓
Preprocessed Org working document
        ↓
Existing org-texmacs preparation
        ↓
Org AST → TeXmacs
```

由 Org 负责 INCLUDE 展开及 `::location`、`:only-contents`、`:lines`、`:minlevel` 等标准语义。

`org-texmacs` 原则上只解析预处理完成的 Org 文档，不重新实现 INCLUDE 的选择、标题变换或脚注处理逻辑。

不要求调用完整的 `org-export-as` 或执行 backend transcoding。

### 16.2 重新评估 STM protection

STM 内容原则上由 `org-texmacs` 解析，其他预处理阶段不应意外修改其语义。

但不能预先假定所有 Org preprocessing 都会错误处理 STM。

需要分别验证：

- Org 原生 INCLUDE 对 STM 内容的实际行为。
- 标准 preprocessing hooks 对 STM 的影响。
- 预处理后的 STM 能否直接由现有 fragment discovery 识别。
- 哪些具体处理阶段确实需要额外保护。

仅针对已经证实的问题引入必要保护，避免为了维护保护标记而重新实现 Org 的选择与变换规则。

### 16.3 最小来源与所有权合同

**正确转换最终 Org 文档，不以完整 source provenance 为前提。**

首先只保留当前功能真正需要的信息：

- 原始 source snapshot 与最终 working document。
- 预处理实际读取的外部依赖及一致性检查。
- 无法从最终工作文档恢复、但当前资源处理确实需要的来源信息。

精确原始行号、逐字符 source map 和通用 AST provenance 不作为本阶段的必要条件。

跨目录 STM 相对资源可能需要保留来源目录，但不必因此要求所有节点具有精确原始位置。相关需求可以独立设计。

### 16.4 实施步骤

1. **隔离实验：** 在项目锁定的 Org 9.8.10 上，直接使用原生 preprocessing 生成 working Org document，验证 INCLUDE 参数、STM、标题、脚注和链接的实际行为。
2. **方案比较：** 对比现有 protected mirror 方案与直接消费预处理结果的方案，明确哪些保护、来源记录和外部依赖检查仍然必要。
3. **最小重构：** 若实验支持，在保留 source ownership 和一致性合同的前提下，简化现有 Phase 2b；尽量不增加平行的 INCLUDE 处理逻辑。
4. **完整回归：** 验证 Phase 1 AST filters、Phase 3 bibliography、native consumers、source isolation 及 HTML backend 非干扰性。

应优先测试实际 INCLUDE 参数组合，而不是仅验证整文件 INCLUDE。

### 16.5 设计约束

- Org canonical source 不变，所有预处理在私有工作环境完成。
- 保留可验证的外部依赖一致性和失败清理。
- 继续区分 Org preprocessing 与 TeXmacs structural lowering。
- 不预先要求完整 provenance，也不为了简化实现而静默丢失当前必需的资源来源语义。
- 不直接扩大到 Babel、任意宏执行或完整 Org export lifecycle。
- 不兼容的阶段应通过实验证明并明确限制，不能假定整个原生流程天然安全。
- 原生递归读取必须使用可验证的固定依赖文本；仅在完成后记录文件名或检查属性不足以建立 owned snapshot 合同。
- 若简化已有 original-range、occurrence 等 INFO 数据，明确更新其合同、文档和测试；不保留已失真的来源声明。
- 每个重构节点同步维护回归，最终再执行完整验收。

**验收目标：** 常用 Org INCLUDE 参数由 Org 原生机制处理，`org-texmacs` 能直接转换预处理结果；额外适配仅用于必要的 STM 语义保护、输入所有权和依赖一致性。

Phase 2c 完成后再推进 Phase 4 的真实第三方 package 联合验证。



## 17. Phase 4：Org 原生工作文档语义与真实扩展互操作

**基线：** `main@1a254a7`，Phase 2c 已完成原生 INCLUDE 参数支持及 preprocessing 架构简化。

**目标：** 以 Org 的一般处理流程为依据，明确 preprocessing 与 `org-texmacs` preparation 的职责边界，解除不必要的跨目录 INCLUDE 限制，并验证真实 Org 扩展的互操作能力。

### 17.1 核心架构原则

采用以下信息流：

```text
Canonical Org buffer
        ↓
Org preprocessing
        ↓
Preprocessed Org working buffer
        + standard Org context
        ↓
Org AST / STM AST preparation
        ↓
Structured TeXmacs document
        ↓
Native consumers
```

**`org-texmacs` 应接收经过 Org 标准预处理的工作 buffer 及其正常上下文，再进行结构化转换。**

这里的输入不限定为纯文本。Org 一般处理流程实际使用的文件身份、默认目录、buffer-local 配置、有效导出信息及其他必要上下文，应按其原有语义传递或捕获。

具体要求：

- Org 负责 INCLUDE 展开、内容选择、标题调整、脚注处理及普通 Org 链接的重定位。
- `org-texmacs` 消费最终工作文档，不重新实现这些 Org 语义。
- 不为 `org-texmacs` 另行建立一套与 Org 不同的文件路径或上下文解释规则。
- 不要求追踪最终内容来自哪个 INCLUDE 文件、原始位置或 occurrence。
- 保留 source ownership、coherent snapshot 和 pure lowering 的既有要求，但不得将它们等同于完整 source provenance。

现有 `source-file`、`resource-base` 等字段可以继续作为有效上下文的固定快照，但应检查其语义是否与 Org 一般流程一致，避免成为独立的路径政策。

### 17.2 跨目录 INCLUDE

**不同目录的 Org 文件可以参与同一文档的 INCLUDE，不应仅因目录不同而拒绝。**

对已经由 Org 正确预处理的普通内容，`org-texmacs` 不需要知道其原始来源。

重点验证：

- 跨目录及嵌套 INCLUDE。
- `::location`、`:lines`、`:only-contents`、`:minlevel`。
- 普通 Org 文件链接的重定位。
- 标题、脚注及相关 Org 语义。
- STM 内容在预处理期间的完整性。
- 外部文件快照与依赖一致性。

移除同目录限制时，仍应保留必要的本地文件验证、依赖读取预算、循环检查与失败清理。

不得为了支持跨目录 INCLUDE 而重新引入通用 AST provenance、原始 source map 或 occurrence mapping。

### 17.3 STM 原生资源节点政策

`org-texmacs` 不禁止 STM 使用 TeXmacs 原生资源节点，也应提供相应支持。

但这种写法绕过了 Org 对相关资源的语义表达与处理机制，因此**不推荐作为常规用法**。对于 Org 已能表达的资源，应优先使用 Org 原生语法。

该政策不意味着降低已声明支持功能的正确性要求。

STM 原生资源引用遵循以下原则：

1. 采用最终工作文档的正常上下文解释相对路径，不默认追溯 STM 所在的原始 INCLUDE 文件。
2. 不为了还原原始文件目录而引入专门的 provenance 机制。
3. 优先在输出中保留相对路径语义，避免不必要地写入机器相关的绝对路径。
4. 必要的资源路径转换应在明确的结构化资源节点或 native consumer 边界完成，不修改任意 STM 字符串。
5. 资源解析、结构化传递和实际渲染是不同能力，应分别验证。

如果同一 STM 在独立转换与被其他文档 INCLUDE 后具有不同的有效资源基准，则应遵循各自最终文档的上下文，不要求自动保持原始文件目录语义。

对于不同 native consumers，应调查 Org/TeXmacs 已有的文档位置与相对路径处理机制；只有确有必要时才增加明确的上下文传递。

**STM 原生资源支持不得成为跨目录 INCLUDE 或工作 buffer 架构的前置条件。**

### 17.4 Preprocessing 与上下文合同调查

在修改生产代码前，先调查项目锁定的 Org 版本及当前 adapter：

- Org 标准 preprocessing 如何创建、使用和传递工作 buffer。
- `default-directory`、`buffer-file-name`、buffer-local Org 配置及 export info 的实际职责。
- 原生 INCLUDE 对普通链接、脚注、标题及相关文件语义的处理。
- 当前 `org-texmacs` 的上下文快照在哪些方面沿用了 Org，哪些方面额外引入了限制。
- STM shielding 是否仍能保持为单纯的数据保护机制。
- bibliography discovery 对最终文档上下文和相对路径的具体要求。

不得仅因为 Org 最终生成了有效文本，就假定相关路径和配置上下文已经自动保持正确。

对于需要额外信息的情形，首先判断 Org 是否已经通过标准 buffer/context 提供该信息；只有不存在适用的标准机制时，才考虑增加最小的显式接口。

### 17.5 真实扩展互操作

在稳定上述接口边界后，进行分阶段联测。

**Phase 4a：原生上下文与跨目录 INCLUDE**

完成隔离调查，验证跨目录普通 Org 内容能够正确转换，明确尚未支持的特殊资源语义。

**Phase 4b：`org-roam-include`**

使用真实 mode、hooks、advice 和隔离 Org-roam fixture，验证节点 INCLUDE、递归展开、参数处理及跨目录行为。

**Phase 4c：`org-roam-organize`**

验证真实 managed bibliography discovery、citation-key AST filters 和必要的 Org-roam 数据库依赖。

**Phase 4d：共存回归**

验证相关扩展同时加载时，TeXmacs 转换与 `org-roam-blog` 的标准 HTML export / publish 均保持正确，且临时上下文、函数绑定与 hooks 不泄漏到无关流程。

### 17.6 实施约束

- 优先复用 Org 标准 preprocessing 与上下文机制。
- 保持 canonical source 不变，所有处理发生在私有工作环境。
- 保留 coherent snapshot、已捕获依赖的一致性检查及失败清理。
- 不将普通 Org INCLUDE 的兼容性与 STM 原生资源支持捆绑。
- 不为具体第三方 package 默认增加专用转换器。
- 不为了未来可能需要的资源语义提前恢复完整 provenance。
- 不在没有实际证据的情况下扩展 callback sandbox、FS/DB 原子事务或整个 generic export lifecycle。
- 已支持的功能应正确处理；尚未支持的语义应明确界定，避免静默产生错误输出。

### 17.7 验收条件

完成本阶段后，应能够确认：

1. `org-texmacs` 的 preparation 以预处理后的 Org 工作文档及正常上下文为输入。
2. 常规跨目录 INCLUDE 无需额外来源追踪即可正确转换。
3. 普通 Org 文件链接与其他来源相关语义遵循 Org 的既有处理方式。
4. STM 原生资源节点不会反过来要求核心 preprocessing 保存原始来源。
5. 真实 Org 扩展可经由标准接口协同工作，或具有明确、可复现的兼容性缺口。
6. 既有 source ownership、AST-first、native consumers 及非干扰性回归仍然成立。

**实施优先级：** 首先验证 Org 工作 buffer 与上下文合同，其次解除跨目录 INCLUDE 限制并进行真实扩展联测。STM 原生资源路径增强可独立推进，不得阻塞前述工作。


## 18. Phase 5：正式 Org export frontend 与 preprocessing 整合

**基线：** `main@6f018de`，Phase 4 已完成跨目录 INCLUDE、最终工作 buffer 上下文及真实 Org 扩展互操作验证。

**状态：** 待实施。

**目标：** 将已经验证的 Org preprocessing → working buffer → structural preparation 流程接入 `ox-texmacs` 的正式导出入口，使普通 Org 导出操作能够使用现有 INCLUDE、AST filters 和可选 bibliography discovery 能力，而不引入第二套转换器。

### 18.1 架构原则

保持以下结构：

```text
Org source buffer
       │
       ├── Org preprocessing（可选上游阶段）
       │          │
       │          ▼
       │    Org working buffer
       │          │
       └──────────┤
                  ▼
       Unified preparation
                  │
                  ▼
          TeXmacs document
                  │
          ┌───────┴───────┐
          ▼               ▼
     Serialization    PDF rendering
```

具体要求：

- `org-texmacs-prepare-buffer` 及相关直接转换 API 继续作为核心接口，允许调用者提供已经预处理完成的 Org buffer。
- Org preprocessing 是可组合的上游 provider，不是另一种 document preparation。
- 正式 frontend 应复用现有 preprocessing provider，不复制 INCLUDE、STM shielding、bibliography discovery 或 AST filter 逻辑。
- 不因为 preprocessing 失败而自动回退到未预处理的原始文档。
- 不引入通用 source provenance、STM 来源映射或额外的资源路径解释体系。
- 保留 source ownership、coherent snapshot、pure lowering 和独立 native consumers。

**直接转换与经过 preprocessing 的转换是两种明确的输入路径，不是失败时相互替代的实现。**

### 18.2 调查当前 frontend 与 preprocessing 的组合边界

在修改生产代码前，调查以下内容。

**A. 输入与选择语义**

核对当前 `ox-texmacs` 支持的：

- 完整 buffer 导出。
- `subtreep`。
- 活动 region。
- narrowing。
- restricted `ext-plist`。

重点确认源位置在 preprocessing 后失效时，哪些选择仍能通过 Org 原生机制表达。

不得仅为保留源位置而恢复原始字符映射。

**B. 三种输出 consumer**

调查现有：

- `org-texmacs-export-as-texmacs`。
- `org-texmacs-export-to-texmacs`。
- `org-texmacs-export-to-texmacs-pdf`。

确认如何让三者消费同一份经过验证的 prepared input，并保留各自的输出、错误及清理合同。

当前 preprocessing adapter 已支持 `.tm` 序列化，但尚无对应的公开预处理 PDF adapter。应优先通过现有 consumer 组合补足，而非复制 preprocessing 实现。

**C. Org export dispatcher**

核对 `org-export-define-backend`、before-processing guard、菜单操作和当前 export commands 的调用关系。

必须继续区分：

1. 由 `ox-texmacs` 明确管理的结构化导出。
2. Org generic string-transcoder/export pipeline。

本阶段不要求支持第二种路径。

### 18.3 正式 frontend 的输入策略

推荐采取逐步整合，而不是一次修改所有输入形式。

| 输入情形 | 本阶段建议 |
|---|---|
| 完整、未 narrowing 的 Org buffer | 正式入口采用已验证的 preprocessing 路径 |
| 已完成预处理的 Org working buffer | 直接交给现有 preparation API，不再次预处理 |
| Subtree / region / narrowing | 暂时保留已有直接转换语义，另行调查与 preprocessing 组合的方式 |
| Unsupported Org preprocessing 输入 | 明确失败，不自动降级 |
| Generic `org-export-as` 等调用 | 继续维持现有显式拒绝策略 |

Subtree、region、narrowing 的直接转换是明确保留的选择语义，而不是 preprocessing 出错后的 fallback。

本阶段不得为了切换完整文档的默认路径而删除已有局部导出能力。

如果局部选择中含有需要 preprocessing 的输入，应维持明确的 unsupported error；不得把跳过 preprocessing 的结果描述为等价导出。

最终应在文档中清楚区分完整文档与局部选择各自采用的处理流程。

### 18.4 Bibliography discovery 策略

预处理入口目前将 `discover-bibliography` 作为独立的显式布尔参数。

正式 frontend 整合时应保留这一独立性：

- 不将 bibliography discovery 与 preprocessing 是否启用绑定为同一个开关。
- 不为了普通无引用文档而默认引入不必要的外部文件读取或数据库访问。
- 明确决定 frontend 如何提供 discovery 的显式启用方式；在该策略确定前，不擅自改变现有默认行为。
- 继续复用标准 `org-cite-list-bibliography-files` 与现有 AST citation-key filters。
- 不增加 `org-roam-organize` 专属适配或数据库读取代码。
- 保持显式 bibliography 文本快照的优先级及既有依赖一致性检查。

使用真实扩展 fixture 验证启用与未启用 discovery 的行为，尤其检查缺失 bibliography 时是否产生明确错误。

### 18.5 Frontend consumer 整合

优先设计一个最薄的 frontend 调度层：

1. 捕获源 buffer、选择范围、有效配置和必要的输出命名上下文。
2. 根据已确定的输入策略选择 preprocessing provider 或直接 preparation。
3. 获得同一类型的 prepared input。
4. 交由现有 document、serialization 或 PDF consumer。
5. 在现有一致性检查完成后提交输出。

不得为了菜单导出重新实现 prepared input、document construction 或 serialization。

对三个输出形式分别要求：

**TeXmacs buffer**

沿用现有只读、unibyte、`no-conversion` 的输出 buffer 合同。导出失败时不遗留半成品 buffer。

**`.tm` 文件**

继续使用 `org-export-output-file-name` 及现有输出目录、文件覆盖和源文件保护规则。

输出命名与源选择不得因中间工作 buffer 的临时文件身份而发生非预期变化。

**PDF 文件**

在同一受检转换事务中完成 preprocessing、document construction 与 native PDF rendering。

继续保留 PDF consumer 的资源节点限制及错误恢复机制。不为接入 frontend 而扩展图片、外部脚本或其他 TeXmacs 原生资源的渲染范围。

### 18.6 实施阶段

**Phase 5a：接口调查与最小验证**

- 建立完整文档、局部选择、文件输出、PDF 输出的行为矩阵。
- 验证当前 preprocessing adapter 能否在加载 `ox-texmacs` 后正常执行。
- 检查 before-processing guard 与显式 preprocessing hooks 的隔离。
- 确定 consumer 复用方式以及 bibliography discovery 的 frontend 入口。
- 记录哪些行为可以直接复用，哪些需要新增最薄的适配。

此阶段先形成明确的接口合同，不修改 production path。

**Phase 5b：完整文档 frontend 整合**

- 让完整、未 narrowing 的文档导出使用 preprocessing。
- 保留现有三种输出形式。
- 保持明确的错误与失败清理语义。
- 避免重复执行 hooks、AST filters、bibliography discovery 和 native preparation。
- 保留直接转换公开 API，不引入自动 fallback。

**Phase 5c：局部选择兼容性**

- 验证 subtree、region、narrowing 的既有行为没有回归。
- 明确其当前直接转换的输入边界。
- 调查 Org 原生机制是否允许在不恢复 provenance 的情况下支持局部选择与 preprocessing 组合。
- 若缺少足够的原生支持，则明确延后，不在本阶段自建位置映射。

**Phase 5d：真实扩展与输出回归**

使用既有可选集成 runner，覆盖：

- 跨目录及嵌套 INCLUDE。
- `org-roam-include` 的实际 hooks/advice。
- `org-roam-organize` 的 AST citation-key filters 与可选 bibliography discovery。
- 标准 HTML export、`org-roam-blog` publish 共存。
- `.tm` buffer、`.tm` 文件、PDF 三种输出。
- preprocessing 失败、无效 STM、外部依赖变更、native consumer 失败。
- 输入 buffer、临时状态、hooks、输出文件的隔离与清理。

保留全部既有核心 ERT、Nix checks、严格编译和 package-lint 验证。

### 18.7 非目标

本阶段明确不实施：

- Generic Org string-transcoder/export pipeline。
- 完整 Babel、macro、SETUPFILE/BIND 等 Org export 生命周期。
- 跨 preprocessing 的通用 subtree/region 原始位置映射。
- STM 原生资源来源恢复、相对输出路径增强及额外 PDF 资源渲染。
- 新的 incremental update、multi-session 或 live preview。
- 针对第三方 Org 扩展的专用转换器。
- 未经明确选择的其他语法覆盖范围扩张。

**快捷键配置单独延后。**

未来计划将 TeXmacs export 菜单快捷键改为需要显式配置、不提供默认键值、仅在文档中给出推荐或示意值的机制。

本阶段不修改现有 `C-c C-e T` 菜单注册、快捷键值或配置方式；仅调整其导出命令内部的处理路径。

### 18.8 验收标准

1. 正式 frontend 的完整文档导出能够使用已经验证的 Org preprocessing 流程。
2. Org AST 与 STM AST 仍由唯一的 preparation/lowering 路径处理。
3. 已预处理工作 buffer 可以直接转换，无需再次运行 preprocessing。
4. Subtree、region、narrowing 的现有直接导出行为得到保留，且其支持边界明确。
5. Preprocessing 失败不会触发直接转换 fallback，也不会静默生成语义不完整的结果。
6. `.tm` buffer、`.tm` 文件和 PDF 的输出合同保持一致。
7. Bibliography discovery 的启用方式明确，真实 Org 扩展接口仍然可用。
8. 普通 Org HTML export / publish 与 TeXmacs frontend 互不干扰。
9. 不新增通用 provenance 或第二套结构化转换实现。
10. 现有测试及新增 frontend 联测全部通过。

### 18.9 完成后的处理

实现完成后更新 README、相关 API docstrings 和 GAW 记录，并重新审查 Issue #1。

Issue #1 的关闭应以选定的 preprocessing/frontend 架构目标是否完成为准，不要求一并实现 generic Org exporter 或所有未来的资源语义。

**执行优先级：** 先完成 Phase 5a 的接口调查，再推进完整文档的正式 frontend 整合。对局部选择和其他尚未明确的行为，优先保留已验证的现有能力，而不是为了统一入口扩张 preprocessing 架构。

