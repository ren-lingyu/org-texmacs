# 脚注 binding 与导出锚点的原生干预实验

结论: 在锁定 TeXmacs2.1.5 的两个样式中, 缺失具名导出锚点的假设得到原生
干预支持. set-binding 能提供 reference 数值, 但本实验中不产生可用 named destination.
在原生 render-footnote* 的现有 set-binding 前补同名 label, 可补回脚注正向目标.
这是诊断性 native 文档局部宏对照, 尚未成为正式修复或 exporter 策略.

## 隔离与授权

同上一轮已授权的 exact600s Nix build 命令, root tmp/footnote-forward-probe flake,
同一锁, fresh per-process TEXMACS_HOME_PATH 和 sandbox HOME/XDG. 未修改生产文件,
已安装 TeXmacs 样式或系统配置. 当前只使用独立原生 tree, 不调用 Org/exporter.
此前34PDF探针及 archive 保留不动. 当前 probe.nix 改指 anchor-probe.py;
最终输入身份见 anchor-inputs.json, 生产源码仍可通过 source-inputs.json 对照.

初组6variants x2styles x2routes=24PDF完成; 追加顺序和动态宏对照后, 完整重跑
9variants x2styles x2routes=36PDF完成, ANCHOR-MATRIX-OK36, exit0.
路径为原生直接 PDF 和 export-postscript -> Ghostscript PDF.
最终输出: /nix/store/63100r4j20ilichfzwzf38l0vns6nj1r-org-texmacs-footnote-anchor-probe
已复制至 anchor-final-results/; 初组24PDF单独留在 anchor-results/.
动态宏对照还有预热 PDF, 它不是36份最终结果之一.

## 对照结果

以下结果在 generic/article 和两条输出路径中一致:

| 变体 | 结果 |
| --- | --- |
| 原生两个脚注基线 | 两个正文标记均缺少目标 |
| 脚注正文中加匹配的 footnote-1 / footnote-2 label | 两个目标出现 |
| 脚注正文中加 unrelated-1 / unrelated-2 label | 原来两个目标仍缺失 |
| 把匹配 label 放在正文 Main1/Main2 处 | 目标出现, 但指向错误的正文位置 |
| 普通跨页正文仅 set-binding | reference 显示 1, 目标缺失 |
| 普通跨页正文仅 label | 目标存在于第2页, reference 显示 ? |
| 普通正文先 label 后 set-binding | 目标存在且 reference 显示 1 |
| 普通正文先 set-binding 后 label | 目标存在, reference 被覆盖为 ? |
| render-footnote* 中动态补同名 label | 两个目标出现, 编号/文字/布局不变 |

普通正文对照区分了可显示的绑定值与具名导出锚点. 先前“浮动脚注排版时才丢失”
的说法过窄, 现在应改为脚注宏使用的绑定路径缺少有效导出锚点这一接合问题.
并不能仅凭 set-binding 普通正文实验认定这个 primitive 违反设计契约;
它可能本来就不承诺产生导出 anchor.

## 动态宏干预

保留原生 footnote tree 和计数器. 每个 native 文档中先预热, 获取已加载的
render-footnote* macro, 验证恰好只有一个 set-binding, 将它替换为:

```scheme
(concat
  (label (merge "footnote-" (arg "nr")))
  (set-binding (merge "footnote-" (arg "nr")) (value "the-label") "body"))
```

只通过 init-env-tree 覆盖当前临时文档 macro. 名称来自原有宏参数, 不硬编码1/2,
不重写用户 source tree, 不修改 TeXmacs 安装目录. 原宏和干预宏原文在
anchor-final-results/anchor-native-{generic,article}-macro-body-label.log.

匹配正文 label 和动态宏两种干预, 在两种样式的原生直接 PDF 中均验证:
Main1/Main2 的正向目标落入对应 Body1/Body2 文本矩形; 全部可见文本及矩形与
原始基线完全一致, 包括脚注编号1/2. 不是仅验证同页或目标名存在.
PS 原文从只有 #footnote-N ANN 变为含匹配 DEST 定义. PS转换后目标存在;
其坐标未验收为正确落点, 不能宣称 PS PDF 已完全正常. 未执行 GUI 点击.

## 解释边界

这些对照强烈支持 native footnote macro 的“绑定值 -> 可导出具名锚点”缺口,
且显式 label 在正确作用域内足以填补当前两例. 还未定位 C++ binding/anchor
实现、未决定应修宏还是底层导出机制, 没有测试全套样式/编号变体/目录或全局
交叉引用影响. 不是正式生产修复验收. 多处显式 label 原生 PDF 有既有重复
named destination 警告, 未忽略目标坐标; 动态宏例仍通过直接PDF目标位置检查.
本次没有失败重试或扩大运行范围, 两次均按原精确授权命令完成.

报告/脚本/结构化注解和动态宏日志具有新的因果证据价值, 适宜选择性归档;
不重复归档整份源码/依赖/PDF. 先前原始证据和 archive 不修改.
