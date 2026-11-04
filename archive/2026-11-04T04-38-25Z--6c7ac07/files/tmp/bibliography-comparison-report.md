# org-texmacs 文献数据处理方案对照实验报告

## 结论

本轮选择 Note 的结论 **2: CSL 数据层可用, 但数学结构交接仍需要独立机制**. 保留当前生产路线和 v0.7.0 B 项延期结论. 自定义 getter 是可行的输入接口原型, 不是已经可合入的兼容层. TeXmacs 原生路线对本矩阵的有效 LaTeX 数学给出更直接的结构和正确排版, 但 BibLaTeX 字段映射、Unicode 排版和错误恢复仍有明显边界, 不足以直接替换默认 CSL.

关键证据:

1. 绕过现有 BibLaTeX 转换后, 直接 CSL-JSON 和 getter 都完整保留了 `\alpha_i`, 分式和乘积等数学源文本. 当前 lowerer 对最终 `latex-fragment` 的明确拒绝是独立的后续边界.
2. STM 源文本在 CSL item 中保留, 但在 `citeproc-proc--parse-csl-var-val` 中就变成弯引号: `(math "α")` → `(math “α”)`. 两种样式和 JSON 输入都如此. 所有本轮 CSL/ getter 案例的 islands 均为空, 排版只是 STM 样子的普通文字.
3. 原生 BibTeX 将 `\alpha_i`, `\frac{a}{b}` 等直接构造成 math/rsub/frac 并正确排版. 同一路线也接受未闭合数学, 产生多余 `}`; 未知命令显示占位; 原生 parser 返回合法 stree 并不是严格成功判据.
4. 原生 parser 保留 `journaltitle`, `date`, `doi`, `url`, 作者和未知字段; `plain` 样式却忽略了这些扩展字段. `journal`/`year` 对照有输出; 只有 `date` 而没有 `year` 时日期不显示. 必须区分解析保留与样式支持.

## 版本、输入与运行范围

- 项目提交: `6c7ac07ba4f4c936abe99fb15d1915df6e211deb`.
- 实验复制当前已经验收、尚未提交的 N5 工作区, 159 文件哈希在 `bibliography-comparison-1/baseline.json`. 四处未提交差异仅为文档和一个本实验不加载的 Cite 回归; Lisp 库、worker、构建配置和锁文件均与该提交一致. 不能把实验工作区称为已提交版本.
- x86_64-linux, Emacs 31.1, Org 9.8.10, TeXmacs 2.1.5, citeproc 包版本 20260113.1047 (源码头标版本 0.9.4). `flake.lock` 固定依赖图. 没有单独取得 Citeproc Git revision, 不补造提交号; 锁文件、输入哈希、Nix 输出和 derivation 日志给出复现身份.
- 30 个独立合法 BibLaTeX 条目及对应 CSL-JSON: text 4, Unicode 5, LaTeX/负例 13, STM 4, 字段对照 4. 大小写保护和转义的 JSON 使用对应数据语义, 不把 BibLaTeX 的源级花括号直接当成 JSON 的格式控制.
- A: 120 个 route/style 结果, 每个跑两次 (240 次标准 preparation). B: 60 个 fixture/style 结果, 每个跑两次, 另有独立 Citeproc、getter 协议、重复键及嵌套/后续 HTML 对照. C: 30 个条目的 parse/format 各跑两次, 加三条目排序及 Unicode/font 对照.
- 每条主矩阵导出 preparation hook 和 AST filter 均为一次, 源 buffer 不变. 内部生成标签经定义/引用一致的结构映射归一化后比较, 原始树和输出仍保留. 每个正确 native 文档只渲染一次; 重复比较转换结构和失败分类, 不承诺 PDF 字节稳定.
- 三个最终实验驱动均退出 0, 各一项 ERT. 这是实验完成的断言, 不表示所有输入都能正确导出. 这里没有重跑或增加产品完整回归, 没有改生产文件、API、finalizer、CHANGELOG、版本状态或提交草稿.

## A1: 现有 BibLaTeX 路径

观察真实 `citeproc-blt--to-csl-title`, `citeproc-create` 的 getter 返回值、`citeproc-proc--parse-csl-var-val` 返回值、`citeproc-render-citations`/`citeproc-render-bib`, 再读取标准 prepared input 的最终 AST. wrapper 调用原函数一次并作用域恢复, 不修改其返回结果.

| title 数学内容 | 现有 BibLaTeX→CSL title 结果 | 直接 JSON / getter title |
| --- | --- | --- |
| `\cdot` | 删除 | 保留 |
| `$\cdot$` | 保留 | 保留 |
| `$\alpha$` | 保留 | 保留 |
| `$\alpha_i$` | `$_i$` | 完整保留 |
| `$\cdot_i$` | `$_i$` | 完整保留 |
| `$\frac{a}{b}$` | `$a<span class="nocase">b</span>$` | 完整保留 |
| `$A \cdot B$` | `$a  b$` | 完整保留 |
| `\( \alpha_i \)` | `\( _i \)` | 完整保留 |

实际函数调用表明差异不限于命令名称: 单独结束的 alpha/cdot 均保留, 带下标两者都损失. 本轮不根据正则外观给出未经执行的推断. 花括号保护 `{RNA}` 能保留大小写语义; 普通标题句式大小写变化本身是合法处理. `---` 经当前转换变成 `–-`, 反斜杠命令 `\textbackslash{}` 被删除、末尾波浪号变空白后被 trim; 这些与数学丢失分开记录. 对照 JSON 明确给出破折号、空白和文字反斜杠的数据语义.

## A2: 直接 CSL-JSON

直接 JSON 在 getter 返回的 CSL item 中, 30 个 title 与 fixture 声明的 CSL 数据值均相等, 两种样式都成立. 所测直接 Unicode 数据保留. 这已经是当前标准 `oc-csl` 支持的 bibliography 输入路径, 不需要新的 processor 或 bibliography preparation.

LaTeX 片段在后续 Citeproc 输出及最终 Org `latex-fragment` 中保留; 38/60 个 JSON route/style 结果能够 lowering, 22/60 因剩余 `latex-fragment` 明确失败. 相同数量不代表与原 BibLaTeX 路线保真等价: 原路线退化的 `$_i$`/`$ab$` 也会触发同样的拒绝.

裸 `\cdot` 到最终 AST 变成 entity, 当前已有 entity lowering 能生成局部 native math. 未闭合 `$\alpha_i` 则被 Org 解释为 `$` 文本 + entity + subscript, 不是完整 LaTeX 数学. 这属于 Org 结构解释, 不算正确的 fragment 转换或错误拒绝.

两种样式分别是仅输出 title 的最小样式和 italic 样式. 即使样式没有 italic, Citeproc 也可因 DOI 自动生成 Org link, 引用也有内部 link. 因而这里的“plain”是样式无字体装饰, 不保证输出没有 link. 引号规范化不依赖 italic, 也不依赖 BibLaTeX 输入转换.

## B: getter 原型与标准接入

`citeproc-create` 接受 getter 是库的公开协议. fixture 原型用现有 Parsebib 读取一次数据, 非目标字段继续调用当前 `citeproc-blt-entry-to-csl`; 仅对实验声明的 LaTeX/STM fixture 替换 title. 这个声明来自测试类别, 不是生产可用的数学识别算法.

所有非目标字段在替换 title 前后逐项比较相等. 非目标普通文本、Unicode 和字段 fixture 的完整 item 数据与当前 BibLaTeX getter 一致. `itemids`, 键列表、重复请求键、缺失键、无效请求、重复输入 pair 和非字符串 title 的实际返回/错误及重复比较见 getter-protocol.json. 自定义 pair 构造器拒绝重复键; 但真实 `.bib` 经 Parsebib hash 后, 重复源键已经合并为最后一个条目, 后续 getter 检查无法发现原重复. 该限制独立保留, 没有声称完整重复键验证.

保存了一个显式 `citeproc-create` + `citeproc-append-citations` + render 的独立实例, 分式源文本在正常 citation 和 bibliography 中保留. 标准 Org 接入仅临时包装 `org-cite-csl--processor(info)`, 根据 INFO backend 局部替换其 getter 构造调用. 不复制 Org preparation 或处理器实现, 不安装永久 advice. 嵌套 HTML 及作用域后的 HTML 对照仍使用原 getter, 具有原路径的 `$_i$` 结果. finalizer 未改. 每次实验后原函数身份恢复.

当前 `oc-csl` 内部直接调用 `citeproc-hash-itemgetter-from-any`, 没有本轮可用的公开 getter 注入选项. 实验可行不等于已经选择永久私有接口方案. getter 原型的错误检查也不是完整 CSL schema 或所有字段/继承规则的验证器; copy-tree 隔离 cons 结构不等于完整的可变字符串 ownership 契约.

原型还有实证缺陷: `An {RNA} Study of $A \cdot B$` 若整字段保留, `{RNA}` 留成字面花括号; 直接 JSON 的 nocase span 则正常消失为保护后的 RNA. 因此不能把“完整保留数学字符串”当成已完成 BibLaTeX→CSL 转换. 后续仍需同时保留普通文字、保护标记和数学的语义.

## STM: 数据保留不等于可传递的数学对象

三个要求的 STM 以及一个合法单参数 rsub 对照都进入矩阵. 在 Bib/JSON/getter CSL item 中均保留含 ASCII 引号的 STM 源字符串. `citeproc-proc--parse-csl-var-val` 已将双引号换成弯引号, 早于最终 Org 输出. 最终 AST 的 title 位于 link 或 link+italic 中; 当前 discovery 不会把这些 title 变成 islands. 本轮所有相关 islands 为空.

原生路线则把 `(math ...)` 当文献标题的字面文字, 不执行 STM 解析; Unicode 字符可先变成 native 字符编码. 所测 STM 没有一条形成预期 frac/rsub 数学树. PDF 也明确显示源码样子的文字. 原始 `(rsub "α" "i")` 的目标标签用法本身不能当作正确排版保证; 加入正确的一参数 rsub 控制后仍不能通行, 所以失败不是只由该例子的 arity 引起.

## C: 原生 BibTeX 路线

只使用现有 `parse-bibliography` 和 `format-bibliography` 请求及结构化 document/TM/PDF consumers. 每条 BibTeX 数据直接传给 native parser, 不经过旧版 preparation、citation AST 遍历或独立 bibliography discovery. 没有再调用 N4 的独立 LaTeX snippet API.

- 有效 `$\cdot$`, `$\alpha$`, `$\alpha_i$`, `$\cdot_i$`, 分式、乘积和括号定界数学均形成原生 math 结构. 完整两页原生文献 PDF 已逐页查看, 数学、作者和条目文字对应结构. 混合 RNA 保护与数学乘积也正确排版.
- 非数学模式的裸 `\cdot` 成为 native symbol, 不把整个标题变成 math. 不能用 math 节点计数代替 glyph 或模式验证.
- 未闭合数学也被接受, math 树含额外 `}` 并显示出来. 未知命令形成同名 native 节点并显示彩色占位. 自定义宏样例形成 assign/macro 并显示 x. 这些接受结果均不能算作可靠的错误拒绝或任意宏支持.
- 三作者含 corporate name 保留; `plain` 排版已有正常作者序列. 扩展字段及未知字段留在 parsed stree; `plain` 的字段选择不等于 parser 丢失. 传统 `journal` 有刊名, `journaltitle` 没有; 仅 date 没有 year 时没有日期. DOI/URL/自定义字段同样未在 plain 中显示.
- 三条目排序输入 z,a,m, 文献表输出 a,m,z, 引用显示 [3,1,2]. 标签和编号一致; 没有认证全部高级引用变体、消歧、locators、多文献表或 PDF 注释交互.

## Unicode 与排版边界

数据层中直接希腊字母、中文、重音、组合字符及数学 Unicode 均有保留证据. 原生 stree 的 `<alpha>`、`<#...>` 等是字符编码表示, 不能因不同于原 Unicode 字节就判为数据丢失.

实际原生 PDF 中希腊字母、预组合重音及所测数学 Unicode 显示正常; 中文和组合 U+0301 显示为红色 `<#...>` 占位. CSL→lowering 的中文对照也出现同样现象. 用项目 Fandol wrapper 与 chinese language 再做直接 Unicode + bibliography 控制, 仍出现占位. 因此只能定位到后续 native 编码/字体/排版边界, 尚未定位根因, 不能将其归因于某个 bibliography parser 或宣布已解决. 本轮没有展开字体修复, 也没有由此断言所有项目环境/示例中文导出都失败.

CSL 支持的 PDF 子集有实际产物; 已查看 JSON plain/italic STM 分式图, 它们只是带弯引号的文字, 不是数学. 对仍然是 latex-fragment 的案例没有绕过 lowerer 去生成“成功 PDF”.

## 两条方案对照

| 维度 | CSL + fixture getter / JSON | TeXmacs 原生 BibTeX |
| --- | --- | --- |
| 普通文字 | 保留数据; 合法引号/大小写规范化; 原型混合标题保护仍有缺陷 | 常见文字/大小写保护/标点有 native 结果 |
| Unicode | 数据保留; native 中文/组合字排版未通过 | 数据保留; 同样有 native 排版限制 |
| LaTeX 数学源 | 绕过当前转换后可保留 | 已解释成原生数学, 不以原拼写为目标 |
| 有效数学结构与排版 | 最终 fragment 仍明确拒绝 | 本矩阵有效例结构和排版更直接、正确 |
| STM | item 文本保留, 内部引号改写, 无 islands | 作为标题文字, 无 STM 数学解析 |
| BibLaTeX 字段 | 非目标字段复用现有 Citeproc 语义; 未重写完整转换器 | parser 保留, plain 对扩展字段消费不足 |
| 样式能力 | 继续使用 Citeproc 样式引擎, 本轮验证两种样式 | 本轮只验证 plain, 不能承诺 CSL 样式等价 |
| 标准 Org Cite 接入 | 当前 JSON 可直接用; getter 需解决公开注入接口 | 未来必须设计标准 processor, 本轮未实现 |
| 私有接口成本 | 实验依赖 oc-csl--processor, 不选永久 advice | 复用内部 worker, 仍需 processor/字段/样式契约 |
| AST-first / 纯 lowering | 保留; 完整 fragment 与 STM 交接仍待设计 | 可在 lowering 前准备原生树; 所有权协议仍待设计 |
| 错误与重复性 | 查询/构造错误可识别且重复; 上游重复键已合并 | 重复稳定但错误数学被恢复/占位, 不满足严格拒绝 |

## 独立后续计划建议, 未授权实施

1. 首先单独明确文献输入契约. 若可采用标准 CSL-JSON, 不必增加 getter 兼容层. 若必须直接使用 BibLaTeX, 再设计复用 Parsebib 的有限转换适配, 为混合文本/nocase/数学及重复键建立验收; 取得稳定的 Org 注入接口后才评估生产接入.
2. 数学交接作为独立节点: 验证 Citeproc 内部富文本及输出接口是否能携带明确的数学对象, 保持节点身份与 ownership. 不以静默恢复弯引号、占位符字符串替换或 .bib 回读修补作为默认方案. 只有建立支持及拒绝契约才考虑新的功能版本; 不重开 v0.7.0 B.
3. 若主要需求是原生数学文献, 独立规划 TeXmacs Org Cite processor 的可行性节点: 原生有效数学子集、错误恢复政策、journaltitle/date 等必要字段映射及样式选择, 然后设计结构化结果交付. 不恢复旧 preparation, 不预设完整 BibLaTeX 或 CSL 等价.
4. 中文/组合字的 native 输出边界单独调查, 先用无文献的直接 Unicode 控制定位编码与字体. 这是未解决问题, 不是已批准的修复任务.

## 复现与证据

实验目录 `tmp/bibliography-comparison-1`, 文本证据和逐案例矩阵在 `tmp/bibliography-comparison-evidence`. metadata.json 记录原始成功输出路径、驱动/fixture 哈希和所有 TM/PDF/PNG 的大小及哈希. csl/getter JSON 保存真实调用的输入 title、完整 item、内部 title、格式化结果、最终 AST、islands、lowering/错误及重复结果; native JSON 保存每条 source、parsed/formatted stree 和重复结果. 逐案例详见 case-matrix.md 和 classifications.json.

从完整当前实验目录运行:

```sh
timeout 120s nix build --no-link --no-write-lock-file --print-build-logs --print-out-paths \
  path:./tmp/bibliography-comparison-1#checks.x86_64-linux.bib-compare-csl \
  path:./tmp/bibliography-comparison-1#checks.x86_64-linux.bib-compare-getter \
  path:./tmp/bibliography-comparison-1#checks.x86_64-linux.bib-compare-native
```

归档恢复时, 用 `git archive 6c7ac07` 在新的隔离目录恢复已提交项目, 放回归档的实验 flake、六个驱动/生成器、cases.json 和两个样式. 运行 `python3 generate-fixtures.py` 重建逐条 .bib/JSON 及无关历史 aggregate. baseline.json 的 N5 文档/未使用 Cite 测试四文件差异不影响这些实验运行时; 比较时明确这个差异, 不声称还原了未提交工作区的全部字节. 可将恢复后的目录命名为 tmp/bibliography-comparison-1, 使用上述命令; 若另命名则替换 path URI.

这里最小可复现输入只需两个样式加 cases.json、七个实验配置/驱动/生成器和提交中的库/lock. 不需要完整临时构建树、缓存、用户 init、数据库或 bibliography 私有数据. 二进制 PDF/PNG 不进入 GAW 文本归档; 已记录来源和哈希, 需重新构建审阅图像.

实验记录过的失败均是驱动问题: 初始 JSON 将 plist 列表编码为重复键对象、直接比较随机生成的目标标识、重复渲染触发排他创建保护. 已修正并重新运行. 一次额外 Nix eval 从 legacyPackages 查 citeproc 属性失败, 没有改变测试结果或用于伪造依赖 revision. 最终三个检查成功, 所有生产候选文件仍按159输入哈希与 N5 验收一致. 这些失败不构成产品回归, 也没有被当作数学能力结论.
