# 行内 TeXmacs 环境验证（2026-09-11）

使用 `emacs-twist`，Emacs 31.1、Org 9.8-pre、TeXmacs 2.1.5。
仅创建 tmp 下的探测文件；包源码、用户 Org/TeXmacs 配置未修改。
TeXmacs 测试使用独立 HOME/TEXMACS_HOME_PATH 和 socket 目录，结束后清理。
Org lexer 的原型替换仅存在于 batch Emacs 的动态作用域内。

## 1. TeXmacs 根标签

真实 worker 返回：

| Source | stree |
|---|---|
| `(math "x")` | `(math "x")` |
| `(math (frac "1" "2"))` | `(math (frac "1" "2"))` |
| `(math (concat "x+" (sqrt "y")))` | 保留完整 math 根树 |
| `(math)` | `(math)` |
| `(mathjax "x")` | `(mathjax "x")` |
| `(math(frac "1" "2"))` | `(math (frac "1" "2"))` |
| `(math"x")` | 根 symbol 为 `math"x"`，不是 `math` |

安装包 `share/TeXmacs/packages/standard/std-markup.ts:120` 明确定义：
`<assign|math|<macro|body|<with|mode|math|<arg|body>>>>`。
因此 math 是标准数学模式宏；这不是仅凭任意 tag 能被 parser 接受而推断的。
未验证排版或预览。TeXmacs 接受 mathjax，说明 inline namespace 必须由 source
层自行限定。不能把任意 Scheme token delimiter 当成 STM 等价写法；尤其不应
仅因双引号紧邻 math 就把 `(math"x")` 当作目标语法。

## 2. scan-sexps

Org 默认 syntax table 对反斜杠的分类为 `_`（symbol constituent），不是 escape。
默认扫描可以处理普通嵌套、字符串括号、同段内换行，但在含转义引号的样例
`(math (concat "a)\"b" "c\\d"))` 上失败。

临时专用 table 明确设置括号、双引号和反斜杠后，上述样例均扫描成功。
未闭合括号/字符串返回失败。将扫描范围限制在 paragraph 内后，不会借用下一
段的右括号完成匹配。

注释样例 `(math ;; ) comment\n "x")` 中，默认 Org table 和不识别注释的
专用 table 都错误截断为 `(math ;; )`。单独换成 Scheme table 也会截断；
Scheme table 配合 `parse-sexp-ignore-comments=t` 后，该行注释样例扫描正确。
这不代表完整 Scheme reader syntax 已获支持；`#;`、块注释等未验证。
第一版若不支持注释，应明确拒绝/排除，而不能将错误截断当成合法 source span。

## 3. Org parser 接入

当前 Org 没有 `org-element-object-parser-alist` 或
`org-element-object-successor-alist`。源码说明 object 扩展涉及内部 lexer、
trigger regexp、all-objects 与 container restrictions。

探测采用临时包裹 `org-element--object-lex`，在原生 object 与 math 候选之间
选择更早开始者；动态增加 all-objects 和 paragraph restriction。
该路径不需要改动 trigger regexp，但依赖内部 API，尚不是生产实现承诺。

已获得 `paragraph -> plain-text / texmacs-inline / plain-text`，raw source
精确，parent 指向 paragraph，`org-element-map` 与 `org-element-context` 可用。
同段多个公式均识别，mathjax/foo 不识别；不完整表达式留作普通文本。

原生 Org 会把 math 字符串里的 `*bold*`、`[[file:x]]` 解析为 Org objects。
原型将完整 math span 作为不可递归的 source object 后，这些内容保持原样。
code/verbatim、source block 内没有误识别。原型只开放 paragraph restriction，
所以 link description、bold 内部和 headline 不识别；这是本次原型范围，
不代表已经确定正式产品的 container 策略。

## 4. Source 重建

无专用 interpreter 时，`org-element-interpret-data` 将示例重建为 `A  B\n`，
公式丢失。临时提供 `org-element-texmacs-inline-interpreter` 返回 raw source 后，
得到完整 `A (math (frac "1" "2")) B\n`。
正式接入需覆盖重建语义，不能只有 source-span parser。

## 5. Inline custom cache

`org-element-context` 得到 texmacs-inline；将其传给 `org-element-at-point`
也得到 texmacs-inline。store/get 同一对象可命中；不编辑 buffer、重新调用
`org-element-context` 得到对象后，get 已经 miss。编辑后同样 miss。
因此不能直接假设 block 的缓存复用行为适用于 inline objects。
尚未设计或实现 inline derived cache，也未修改 `org-texmacs-tree`。

## 探测文件

- `tmp/inline-probe-20260911.el`：扫描、临时 Org 接入、cache、真实 TeXmacs。
- `tmp/inline-followup-20260911.el`：syntax table/注释选项、source 重建。

范围有限：没有进行性能、大文档、完整 Org 语法或完整 Scheme reader 验证。
