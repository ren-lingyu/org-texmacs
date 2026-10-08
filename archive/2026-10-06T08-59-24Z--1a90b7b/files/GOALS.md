# GOALS.md

## 1. 项目最终目标

`org-texmacs` 的最终目标不是把 Org 文本“导出”为另一种文本格式，而是让一份完整文档——包括标题、正文、强调、链接、列表、引用、数学公式等内容——在整个处理过程中尽可能始终以可操作的结构化语法树存在。

Org 提供源文档的结构、语义和配置体系；TeXmacs 提供结构化文档、数学内容和排版所需的 native tree 模型。`org-texmacs` 负责在二者之间建立结构化语义桥。

目标关系为：

```text
Org source / semantics
        ↓
structured document AST
        ↓
TeXmacs document tree
        ↓
consumers
├── native TeXmacs session
├── serialization
├── rendering
└── future preview / synchronization
```

字符串格式只应在确有需要时用于输入、传输、持久化或外部交换，不应成为文档语义的主要内部表示。

---

## 2. AST 第一性：严格约束

以下原则属于项目的长期架构约束。

具体实现、内部 API、版本拆分和优化策略可以根据实践调整，但不得为了局部实现便利、性能优化或特定后端需求破坏这些约束。

### 2.1 AST / tree 是第一性表示

已经具有结构的信息应继续以结构化节点存在。

不应为了方便先将已有结构压平成 LaTeX、Markdown、XML、STM 或其他字符串，再依赖后续 parser 恢复结构。

特别是数学内容应作为真正的数学 subtree 存在，而不是作为公式字符串嵌入普通文本。

例如，目标是：

```text
math
└── frac
    ├── numerator
    └── denominator
```

而不是：

```text
math
└── "\\frac{...}{...}"
```

### 2.2 整个文档都属于结构化文档

数学公式不是最终架构中的特殊“字符串岛”。

当前 TeXmacs fragment/block island 是构造完整结构化文档的一种实现机制，而不是最终概念模型中的例外。

长期目标是整份文档都能够作为统一的 structured document tree 被操作。

### 2.3 Org source 是唯一 canonical source

TeXmacs native tree、session、preview、rendering result、cache 和序列化文件均属于 derived state。

它们不得反向取代 Org source，成为隐式的第二份 canonical document。

如果所有 derived state 都丢失，应能够仅根据 canonical Org source 和有效配置重新构造正确结果。

### 2.4 保留语义，不以字符串拼接代替结构转换

Org 的 headline、emphasis、metadata、link、list、table 等语义，应通过明确的 AST lowering 转换成目标结构。

TODO keyword、priority、tags 等 presentation 可以配置，但配置结果仍应生成结构化 TeXmacs tree，而不是退化为某种中间输出语言。

### 2.5 文件格式不是核心集成边界

`.tm`、`.stm`、`.tmml` 等应视为同一结构化文档的可选 serialization。

核心链不应要求：

```text
AST
→ file/string format
→ parse again
→ AST
```

如果 TeXmacs native API 可以直接接受 tree，则应优先直接传递 tree。

### 2.6 复用 Org 的语义与配置体系

`org-texmacs` 不应建立一套与 Org 平行且不兼容的文档语义。

TODO、priority、tags、`#+OPTIONS`、TOC、document metadata、subtree selection 等能力，原则上应尽量复用 Org 已有的解析、配置和 effective semantics，再将其 lowering 为 TeXmacs structure。

TeXmacs-specific customization 可以控制目标树的表示方式，但不应重新定义 Org source 本身的语义。

### 2.7 结构转换与下游 consumer 解耦

Org → TeXmacs document tree 的正确性不应依赖某一种 consumer。

native session、serialization、rendering、preview 和未来的增量同步，都应建立在同一结构化结果之上。

---

## 3. 使用目标：严格约束

以下目标约束最终用户体验。

实现路径可以调整，但不应使用户被迫偏离这些目标。

### 3.1 Org 始终是主要写作环境

用户应能够继续在 Org 中完成整篇文档的写作和组织，包括：

- headline；
- link；
- citation；
- TODO；
- metadata；
- `#+OPTIONS`；
- 其他标准 Org 文档机制。

用户不应为了使用 TeXmacs 而维护另一份平行的 canonical `.tm` 文档。

### 3.2 数学内容直接作为结构化内容使用

用户应能够书写并操作 TeXmacs 的结构化数学表达，而不是被迫把数学退化为 LaTeX 字符串。

数学公式应从一开始就是结构化文档的一部分，而不是直到排版阶段才重新从字符串恢复结构。

### 3.3 TeXmacs 是结构化文档与排版后端

理想工作流为：

```text
edit Org
   ↓
construct structured document
   ↓
update TeXmacs document
   ↓
typeset / inspect / render
```

而不是：

```text
edit Org
   ↓
export textual intermediate
   ↓
manually maintain/open another source document
```

TeXmacs 应作为同一 Org source 的 structured document instance / typesetting instance，而不是第二套需要人工同步的源文档。

### 3.4 Org 的既有语义和配置应自然延续到 TeXmacs

用户不应为了 TeXmacs 输出重新学习一套平行的文档配置语言。

例如：

```org
#+OPTIONS: toc:2 tags:nil
```

以及 TODO、priority、tags、document metadata 等，应尽可能按照 Org 本来的语义控制最终 TeXmacs 文档。

### 3.5 用户不应被迫关心中间文件格式

`.tm`、`.stm`、`.tmml` 可以作为用户明确需要时的输出、调试或交换格式。

正常的结构化编辑、排版和 native-session 流程不应依赖用户手工管理这些文件。

### 3.6 Future live session / preview 保持 Org-first

若实现实时预览、同步或交互式 TeXmacs session，应保持：

```text
Org
= editing surface
= canonical source

TeXmacs
= structured document instance
= typesetting instance
```

不建立需要用户人工维护的双源模型。

### 3.7 非目标

`org-texmacs` 的目标不是：

- 复刻 TeXmacs GUI；
- 把 Org 变成 `.tm` 文件编辑器；
- 重写 Org；
- 用一套自定义文档语言替代 Org；
- 仅仅提供一个新的文本 exporter。

它的目标是让 Org 文档语义直接落到一个真正结构化的 TeXmacs document tree 上。

---

## 4. 输入、输出与副作用：严格约束

`org-texmacs` 应尽可能被设计成具有明确输入、输出和副作用边界的结构化转换系统。

概念上的核心行为应接近：

```text
specified Org source
    +
explicit effective configuration
    +
explicit conversion context
        ↓
org-texmacs
        ↓
structured TeXmacs document result
```

而不是依赖隐式的编辑器全局状态。

### 4.1 且仅以显式指定的 Org source 为 canonical source

每次 document construction / conversion 必须有明确的 source buffer，或由该 source 得到的稳定 snapshot。

核心转换不得因为以下偶然状态而改变输入语义：

- 调用发生时的 `current-buffer`；
- 当前窗口；
- point / mark；
- 另一个 Org buffer；
- 最近一次转换结果；
- 某个 TeXmacs session 的当前内容；
- 与本次 source 无关的 editor state。

可以提供“使用当前 buffer”的便利入口，但它必须只是显式 source API 的薄封装。

例如，底层语义应接近：

```elisp
(org-texmacs-document SOURCE-BUFFER ...)
```

而交互式便利入口可以等价于：

```elisp
(org-texmacs-document (current-buffer) ...)
```

不得让整个内部实现隐式假定 `current-buffer` 就是 canonical source。

### 4.2 转换结果只由明确输入和规定的 effective semantics 决定

需要使用的：

- Org parser configuration；
- export/configuration options；
- buffer-local settings；
- backend-specific presentation configuration；

应在 source preparation 阶段明确取得，并形成一次稳定的 conversion context / snapshot。

后续 lowering 不应任意重新读取动态 editor state。

理想性质为：

```text
same source snapshot
+ same effective configuration
+ same explicit conversion context
        ↓
same structured document semantics
```

### 4.3 核心转换应尽量无破坏性副作用

除明确声明的 consumer/session 操作外，转换不得破坏 source Org buffer 的：

- 文本内容；
- modified state；
- point / mark；
- narrowing；
- text properties；
- buffer-local configuration；
- Org AST/cache 的正常可观察语义。

也不得为了完成转换而永久：

- 安装全局 advice；
- 安装无关全局 hook；
- 修改 Org 全局设置；
- 修改其他 buffer；
- 改变其他合法 Org 调用的语义。

如果某个 Org API 内部具有副作用，应尽量把影响限制在：

- 私有副本；
- temporary buffer；
- 明确动态作用域；

并确保外部可观察状态不会被意外破坏。

### 4.4 不得破坏其他合法 Org 调用的行为

`org-texmacs` 应当是 composable 的 Org client，而不是通过改变 Org 本身的运行环境获得自己的语义。

启用或调用 `org-texmacs` 后，普通的：

- Org parsing；
- export；
- fontification；
- navigation；
- 其他 exporter；
- 其他合法 API caller；

原则上不应因为 `org-texmacs` 的内部实现而改变行为。

不应依赖全局 monkey patch、长期修改 Org 私有状态或改变公共 API 语义来完成转换。

### 4.5 Derived state 必须具有明确所有权

TeXmacs native tree、worker buffer、session、cache、serialization result 等均属于某次明确 source/context 派生出的状态。

derived state 不得成为解释 canonical Org source 所必需的隐藏输入。

其生命周期和 source/context 的关联必须可以明确判断。

### 4.6 异步或跨进程操作必须保持 snapshot 一致性

如果转换过程中需要等待 TeXmacs worker 或其他外部操作，应保证：

```text
source snapshot
+ effective configuration snapshot
→ one coherent result
```

若 source 或影响语义的配置在等待期间发生变化，应采用明确策略，例如：

- 拒绝该次结果；
- 重新开始转换；
- 使用已经完整冻结的 snapshot。

不得把两个不同时间点的状态混合成一棵 document tree。

### 4.7 区分纯转换和有副作用的 consumer 操作

原则上：

```text
source preparation / structural lowering
    → produce structured values

session / rendering / serialization
    → consume structured values
    → perform explicit side effects
```

调用 AST lowering 不应隐式：

- 创建窗口；
- 切换用户 buffer；
- 写文件；
- 修改 TeXmacs session；
- 触发 rendering；
- 启动未请求的 preview。

### 4.8 便利性 API 不得形成另一套语义

可以提供：

- current-buffer convenience；
- interactive command；
- live session helper；
- export command；

但它们都应建立在同一套显式输入的核心转换机制之上。

不得因为入口不同而形成不同的：

- source selection；
- parser semantics；
- configuration semantics；
- AST semantics。

---

## 5. 软目标：缓存、增量计算与长期交互性能

在不违反：

- AST 第一性；
- Org canonical source；
- 明确输入输出；
- 结构语义正确性；

的前提下，应尽量复用 TeXmacs 已有的：

- persistent document state；
- cache；
- incremental typesetting；
- subtree mutation / update mechanism。

理想情况下：

```text
Org source changes
        ↓
structured AST change
        ↓
update corresponding TeXmacs tree/document
        ↓
reuse persistent TeXmacs state where beneficial
        ↓
incremental re-typesetting / rendering
```

而不是每次修改都无条件：

```text
destroy document
→ rebuild all intermediate state
→ restart TeXmacs
→ full re-typeset
```

但该目标属于优化方向，而不是架构第一原则。

必须满足：

- 正确、稳定的 AST transformation 优先于 cache hit rate；
- 不得为了复用缓存而把 structured tree 压平成字符串；
- 不得为了增量更新而让 TeXmacs derived state 成为 canonical source；
- 不得为了性能引入难以验证的隐式双向同步；
- 是否值得实现某类增量机制，应由实际性能测试、TeXmacs native API 能力和实现复杂度决定；
- 如果整文档更新已经足够快且稳定，可以暂缓更细粒度的增量机制。

已有 persistent buffer、subtree mutation 和重新排版实验说明 TeXmacs native session 具有进一步复用持久状态的可能性，但这不等于已经证明具体 typesetter cache 会得到有效复用。

后续实现应通过实际测量判断优化价值。

---

## 6. 当前实现方向

以下内容是基于当前实践得到的工作路径。

它用于指导近期实现，但**不是长期架构的绝对约束**。

如果后续源码研究、测试或实现经验显示有更简单、更可靠的路径，应调整具体实现，只要不违反前述严格目标。

当前大致采用：

```text
explicit Org source buffer
        ↓
stable source/configuration snapshot
        ↓
Org parsing
    +
org-texmacs TeXmacs fragment/block discovery
        ↓
Org AST + parsed TeXmacs subtrees
        ↓
structural lowering
        ↓
UTF-8 TeXmacs-shaped document stree
    +
necessary source/provenance information
        ↓
TeXmacs native boundary
    ├── ordinary Org literal semantics
    └── STM / TeXmacs source semantics
        ↓
TeXmacs-valid stree
        ↓
stree->tree
        ↓
native TeXmacs document tree
```

当前实现原则包括：

- 普通 Org 结构由 Org parser 提供；
- TeXmacs fragment/block 使用 `org-texmacs` parser 得到结构化 subtree；
- 不要求把 TeXmacs pseudo nodes 物理 graft 回一棵完整 Org live AST；
- document lowering 负责 Org semantic structure → TeXmacs structure；
- native encoding 和 TeXmacs worker/session 操作位于 lowering 之后；
- Org literal text 与 STM native notation 在完成 native encoding 前可能需要保留来源差异；
- native session、serialization 和 rendering 均视为 document tree 的下游 consumer；
- 当前实现应优先采用 snapshot / private copy，而不是为了转换修改 canonical Org buffer。

这些具体机制均可根据后续实践调整。

---

## 7. 当前简要实现路径

近期开发优先补齐完整 structured document 所需的语义链，而不是优先增加 presentation/UI 功能。

当前建议方向如下。

### 7.1 完善 Org semantic preparation

包括但不限于：

- 显式 source-buffer API；
- 稳定 source snapshot；
- 有效 parser configuration；
- 标准 Org export/configuration semantics；
- `#+OPTIONS` 等 effective options；
- document metadata；
- 必要的 subtree/document policy。

目标是让 downstream lowering 接收到已经明确、稳定的 Org document semantics，而不是自行从动态 editor state 猜测语义。

### 7.2 完善 document lowering

逐步支持：

- headline；
- paragraph；
- inline structure；
- lists；
- links；
- tables；
- blocks；
- footnotes；
- document metadata；
- TOC；
- 其他必要 Org structures。

TeXmacs islands 继续以 structured subtree 直接参与整份文档的组合。

Presentation-specific behavior 可以提供固定输入/输出的 customization function，但仍应返回 TeXmacs tree，而不是字符串格式。

### 7.3 稳定 native TeXmacs boundary

继续明确：

- ordinary Org literal text 的语义；
- STM / native TeXmacs notation 的语义；
- source/provenance 在何时可以安全丢弃；
- native tree construction；
- worker request validation；
- failure semantics；
- session 生命周期。

### 7.4 在稳定 document AST 上扩展 consumers

包括：

- persistent native session；
- `.tm` serialization；
- `.stm` serialization；
- `.tmml` serialization；
- rendering；
- multi-session；
- preview；
- live synchronization。

这些 consumer 不应反向决定 document lowering 的结构语义。

### 7.5 根据实际收益评估增量能力

在完整 document AST 和 persistent session 稳定后，再评估：

- persistent document reuse；
- subtree-level update；
- TeXmacs cache reuse；
- incremental typesetting reuse；
- preview update granularity。

优化粒度根据实际测量决定，而不是预先作为架构硬要求。

---

## 8. 实现路径的可调整性

本文件中的：

- 最终目标；
- AST 第一性；
- Org canonical source；
- 使用目标；
- 输入输出与副作用约束；

属于长期严格约束。

而以下内容属于当前工作假设，可以随实践调整：

- 内部模块划分；
- helper/function 名称；
- 是否需要额外内部 IR；
- fragment masking 的具体机制；
- provenance 的具体表示；
- worker protocol；
- session representation；
- serialization API；
- 版本拆分；
- Org element 的实现顺序；
- 增量更新粒度。

发现更合适的实现方案时，应优先调整这些实现细节，而不是为了维护旧实现而削弱核心目标。

---

## 9. 设计判断准则

遇到新的实现方案时，按以下优先级判断。

### 第一：结构

> 它是否让完整文档继续保持结构化？

如果已有结构被不必要地压平成字符串，应首先重新审视方案。

### 第二：语义

> 它是否保持 Org 和 TeXmacs 两侧应有的语义，而不是依赖偶然的文本表现？

### 第三：source of truth

> 它是否仍然让且仅让显式指定的 Org source 成为 canonical source？

### 第四：接口纯度与可组合性

> 它是否具有明确输入输出，并避免破坏 source buffer、Org 全局状态和其他合法调用？

### 第五：consumer independence

> 它是否让同一 document AST 可以独立服务于 session、serialization、rendering 等不同 consumer？

### 第六：性能

> 在前述条件成立以后，它是否能够更好地复用 TeXmacs cache、persistent state 或增量排版能力？

如果性能优化与前五项发生冲突，应优先保持结构、语义、source-of-truth 和接口正确性，再寻找其他优化方法。
