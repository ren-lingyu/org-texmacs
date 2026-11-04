# 原生 Org Cite processor 可行性实验报告

结论：**在本实验的有限范围内，架构可行，建议单独规划正式实现。** 原生样式机制、模拟 Org Cite 结构化交接先分别通过，再接入真实 bibliography。没有修改生产代码、公开 API、README、CHANGELOG、v0.7.0 发布状态或默认 processor；N4/N5 的 B 项仍延期。本结论不表示可以立即全面替代 CSL。

## 1. 版本、顺序与证据

- 项目基线 `6c7ac07ba4f4c936abe99fb15d1915df6e211deb`，x86_64-linux、Emacs 31.1、Org 9.8.10、TeXmacs 2.1.5，使用现有 `flake.lock`。原型位于 `tmp/native-cite-feasibility-1`。
- 实验复制当时的 N5 候选工作区：159 文件哈希和用户已 stage 的四个路径在 `baseline.json`。它不是一个已提交的运行版本。四项差异仅为文档和本实验不加载的 Cite 回归文件；所有运行时 Lisp、worker、构建支持与锁文件均来自该基线，唯一库修改是隔离副本中的纯 lowering prefix 接口补丁。
- I（固定原生条目）和 II（模拟原生树）分别成功后，才允许 III 读取真实 `.bib`。GAW 的 gate checkpoint 记录这一时间顺序；后续统一复验并没有取代独立门槛。
- 最终三个实验检查共 4 项 ERT，全部通过。II 包含观察性用例，不能把测试通过解释为所有候选返回值都成功。日志、原始输出、构建输出路径、资产 SHA-256 和最小重建脚本在 `tmp/native-cite-feasibility-evidence` 与原型目录。没有重跑无变化的产品完整 CI。
- 全部 159 个主工作区文件、四个已 stage blob 和 `tmp/commit.md` 在实验后保持不变；没有普通 Git 写操作。

## 2. I：TeXmacs 样式机制，独立验证成功

输入直接构造三个合法 `bib-entry`，不读取或解析 `.bib`。通过同一个 `bib-process prefix style entries` 机制，加载不同原生模块：

| 原生样式 | 实际文献表与正文结果 |
| --- | --- |
| `plain` | 完整作者名字；数字标签 `[1]`、`[3, 1]` |
| `alpha` | 完整作者名字；标签 `[Alp26]`、`[Zul25, Alp26]` |
| `abbrv` | 作者缩写 A. Alpha / Z. Zulu；数字标签 |
| `alpha` + 文档 package `cite-sort` | 文献表标签不变，正文组合引用重排为 `[Alp26, Zul25]` |

TeXmacs 实际返回九项标准目录：`tm-plain`、`tm-abbrv`、`tm-abstract`、`tm-acm`、`tm-alpha`、`tm-elsart-num`、`tm-ieeetr`、`tm-siam`、`tm-unsrt`。本实验只验证其中 plain/alpha/abbrv 的格式化与排版，不声称其余样式均可用。

原生界面的 `tm-*` 名称需要转换成对应模块/formatter 名称并加载模块。直接给底层 `bib-process` 传 `tm-alpha` 会得到 plain 风格结果；加载 `(bibtex alpha)` 后传 `alpha` 才得到字母标签。样式继承和 formatter 由 TeXmacs 提供，Elisp 没有实现单个样式。

原生 `bibitem*` 绑定文献标签，`label prefix-key` 与 `with-bib` 范围内的 `cite key` 相连；`std-automatic.ts` 的引用宏读取这个绑定并控制括号和 detail。**文献样式决定标签值与条目格式，文档宏/package 还会决定正文的展示和排序。** 样式可选不等于任意 Org Cite style 都自动有对应语义。

实际 TM/PDF 核对了单条、多条、重复、引用顺序与文献排序不同以及 `cite-detail` 页码。`nocite` 不打印正文；第三条未引用条目由测试显式交给 formatter，不能据此宣称已经实现自动 nocite 文献收集。`cite-author-year` 等原生 package 的作者/年份/正文式宏存在，但与当前标签数据及 Org 引用样式的完整映射尚未验证。

交替调用 plain/alpha/plain/abbrv/plain，逐例重复得到相同结构。`dynamic-wind` 恢复 prefix/style/default 三个相关全局值；模块加载的注册效果并没有被“卸载”，恢复后的 plain 输出仍与先前相同。

**错误边界：**未知 formatter 名称会静默回退；无检查地 `module-provide` 不存在的模块可能导致 C++ 退出 6，Scheme `catch` 不能可靠保护。最终驱动使用 TeXmacs 自身返回的目录在加载前拒绝未知名称，没有手写样式白名单。这个明确拒绝属于适配层策略，不是对原生 API 的错误保证。原始崩溃驱动与输出保留为反例。

## 3. II：标准 Org Cite 返回值和 ownership，独立验证成功

本阶段没有真实 bibliography 文件，也没有 native worker 协议调用。使用真实标准 `org-export-as 'texmacs` 事务，由正常 Org Cite 选择临时 processor；不存在覆盖 Org preparation 或 Cite 调度私有函数的做法。

### 载体选择

- citation 回调返回一个合法的 citation 副本，保持其引用语义，清除源坐标后仍可交接。
- bibliography 回调返回包含 `PRINT_BIBLIOGRAPHY` keyword 的**单元素列表**，保留其文献表请求语义和位置。
- INFO 存储 `(node . request)` 关联，区分 citation / bibliography，保存 Org 传入的 keys、files、style 等。没有新 Org 节点、raw STM 通道、伪造链接或源码往返。

实测 citation 返回节点保持身份。bibliography 若直接返回单个节点，Org 的替换操作不会保留返回节点根身份；返回单元素列表则保留。这是采用列表的具体依据，不依赖源位置猜测。

另一个探索分支使用 bold/special-block，其测试 fixture 复用了带 parent 元数据的字符串，造成无效共享图。它不是本次采用的协议，**不能据其失败推断所有其他合法载体都不可用**。

### ownership 路径

```text
标准 Org Cite 回调建立请求
  -> Org 替换节点，形成最终 AST
  -> prepared-copy 的 identity map：回调节点 → prepared 节点
  -> 既有 input ownership：prepared 节点 → owned 节点
  -> 原生结果附加时再次构造 owned input
  -> 纯 TeXmacs lowering
```

第一步映射必须显式加入薄 adapter：既有 input copier 只认识它收到的 prepared AST，不能替前一次复制猜测原节点。去掉这一步会明确失败；悬空请求也会明确拒绝。现有通用 model、STM islands 和 input 图复制机制无需新建 AST 或修改其契约。

验证覆盖默认 processor、文档声明覆盖默认值、不同临时 processor、整树复制 / 删除 / 修改 key 的标准 AST filters、强调内及多段引用、重复/多条引用、文献表位置、post-blank、subtree、visible-only。被排除的缺失键引用不会进入 native 请求。每次导出 preprocessing hook 和 AST filter 均为一次，源 buffer 不变。

输入、请求和 native 数据发生后续可变修改时，owned 结果不变；多次结果具有独立 AST。缺失键、不支持 `/t` style、故障、quit、关闭首次身份映射和悬空请求均有错误记录，随后正常导出成功。真实嵌套标准导出中，外层 one 与内层 two 的请求和文献树不混淆。

## 4. III：真实 bibliography 端到端成功

只有前两个独立门槛通过后，才把 mock fulfillment 替换为现有 `parse-bibliography` / `format-bibliography`。两个 book 条目标题分别含 `$\alpha_i$` 和 `$\frac{a}{b}$`，作者/年份为 Ada Alpha 2026、Zoe Zulu 2025。

处理顺序为：Org Cite 提供有效文件声明与 keys → owned 请求图 → 在 native 等待前读取一次文件文本快照 → 原生解析和格式化 → 再次固定所有权 → pure lowering。没有第二次 Org preparation、独立 citation 收集遍历或 bibliography discovery。lowerer 内已有的 citation/native 输出一致性检查属于纯目标结构验证，不是 preparation 的来源。

为传递样式，本阶段只生成临时 worker 实现副本，参数化原有模块加载与 `bib-process` 的样式值，**没有修改生产 worker 或现有 wire request/reply 的名字、参数个数和返回结构**。正式实现仍需设计经过校验的样式参数接口。临时 worker 在处理结束或异常时退出并恢复原配置；它不是长期全局 advice。

plain 和 alpha 均实际走直接 `org-export-as 'texmacs` 文本返回路径。捕获同一事务完成的 owned input，再用其纯 lowering 得到 document；该 document 的原生序列化与标准返回文本可逆编码一致。正文 `.tm` 与 PDF 来自已完成 document，不重新解析 `.tm` 或重新准备 Org。对 lowering 的 worker 调用设置失败保护，验证纯转换边界。

两套 TM/PDF 视觉核对结果：

- plain 为 `[1]` / `[2]`，alpha 为 `[Alp26]` / `[Zul25]`，重复及多条引用均对应文献标签。
- α 的下标 i 和 a/b 分式均为原生数学结构，标题和文献条目位置正确。
- 强调内引用维持上下文，文献表后的正文保留。
- JSON 保存 `math` / `rsub` / `frac` 原生树。PDF 文字抽取会丢失或重排数学字形，所以没有用抽取文本代替视觉验证。

## 5. 正式实现建议与未解决边界

建议下一轮单独制定最小实现计划，不在本实验中实现或切换默认值：

1. 用标准 Org Cite 注册 processor，首先仅支持默认 bare citation、一个文献表和经过验证的样式。明确拒绝尚未映射的 Org style、affix、locator 和 bibliography properties；未来可以另行映射原生 cite-detail，但本次没有完成 Org locator 映射。
2. 在 `org-texmacs-export.el` 的 `--standard-input` / prepared-copy 接入点投影事务请求并完成首次身份迁移。继续复用 `org-texmacs-input.el` 的拥有权，不改变 STM islands。
3. 在 owned input 准备阶段读取 Org Cite 声明的 bibliography 快照并执行原生处理；pure lowering 不读文件、不启动 worker、不选样式。
4. 为 worker 设计统一样式参数，基于原生机制查验可加载名称并处理 tm-* 名称、依赖、状态隔离和失败；不建立 Elisp 样式引擎或手写白名单。
5. 显式传递原生文献标签 prefix，保留 STM 静态标签碰撞检查。原型唯一库补丁位于 `org-texmacs-document.el` 的纯 bibliography-plan：允许 owned `:x-native-prefix`，不再为了预先生成 prefix 而调用旧 preparation 收集路径。正式字段命名、prefix 分配、碰撞回归及不支持组合需审阅。

现有证据不足以保证：全部 native 样式 / 作者—年份引用等价性、多个文献表、完整 nocite 规则、不同 worker 的重入中断、任意第三方 processor 协议、严格拒绝所有错误数学、全部 BibLaTeX 字段及 Unicode 排版。

前一轮已定位的 `journaltitle/date/doi/url` 样式遗漏、中文/组合字形显示和原生 LaTeX 宽松恢复仍然有效，本次没有重复扩大修复。两个有效数学标题的成功不意味着支持任意宏或输入。不同方案的原始证据不能混为“原生 BibTeX 已完整替代 BibLaTeX”。

## 6. 最小复现与保存范围

原型中保存 `flake.nix`、`experiment.nix`、公共 helper、Scheme 样式驱动、mock adapter、I/II/III 测试和 `replay.py`；证据目录保存 prefix 补丁、原始 JSON/sexp、真实 fixture、构建日志、未知模块崩溃输出及资产元数据。不复制整个构建树、依赖源码或 PDF/PNG 到 GAW。

从项目根使用 `replay.py --git <git绝对路径> tmp/<全新目录>`，它只读指定基线提交并在 tmp 中重建运行源，复制最小驱动、应用唯一插入补丁。四项已 stage 的 N5 文档/不加载测试不进入重建版，故完整 159 文件清单与最初候选不完全相同；运行时输入一致；重建版复验得到完全相同的三个 Nix 输出路径，直接复用了相同 derivation 结果。恢复归档时保持 `files/tmp/` 下两个相邻目录的相对位置。

原始及重建原型均可用以下命令运行；重建版替换路径即可：

```sh
# 首先分别验证；成功后才运行最后一条真实文件集成。
timeout 120s nix build --no-link --no-write-lock-file --print-build-logs --print-out-paths path:./tmp/native-cite-feasibility-1#checks.x86_64-linux.native-cite-styles
timeout 120s nix build --no-link --no-write-lock-file --print-build-logs --print-out-paths path:./tmp/native-cite-feasibility-1#checks.x86_64-linux.native-cite-handoff
timeout 120s nix build --no-link --no-write-lock-file --print-build-logs --print-out-paths path:./tmp/native-cite-feasibility-1#checks.x86_64-linux.native-cite-end-to-end
```

这些命令会写日志、Nix 缓存和原生构建资产，可能获取锁定依赖，禁止更新 lockfile。未知模块崩溃的独立复现需在另一个隔离副本中把 `styles.scm` 替换为保留的 `styles-unsafe-original.scm` 后运行 I；预期该运行失败，不把它当正常样式能力测试。资产具体路径、哈希和已查看图片的等同性证据在 metadata.json；文本归档需重建后才能重新进行视觉审阅。
