# 最小脚注正文正向链接隔离实验

结论: 当前锁定环境中, 正文中首次出现的两个匿名脚注标记均生成 Link 注解,
但注解指向的脚注目标不存在. org-texmacs 和独立 TeXmacs 均复现;
tree -> PostScript -> PDF 仍复现. 这不是只有整篇文档第一个脚注失效.

## 环境与范围

- 基线: main@aa9adbc6a96214803e54e1055fc2ba3b495d8c5f; 使用其生产源码快照.
- 锁定 flake: Emacs31 / Org9.8.10 / TeXmacs2.1.5, x86_64-linux, generic/article.
- 每个原生进程独立 TEXMACS_HOME_PATH; Nix sandbox 中 HOME/XDG/产物均隔离.
- 根 flake 的原有 ELPA mirror workaround 保留在隔离副本中, 根源码/lock/index 未修改.
- 31 个源/测试/Nix 输入的 SHA256: source-inputs.json; 探针配置: probe-inputs.json.
- 正式接口: org-texmacs-document-from-buffer, document-save, document-save-pdf.
- 独立原生控制直接构造 footnote tree, 不调用 Org 或 exporter.

最小输入(不是附加特殊 metadata 的改写版本):

```org
1[fn::1]
2[fn::2]
```

另测两行之间加空行的分段版本. 每个版本用 generic/article 各自导出.
Org 默认将相邻两行放在同一段落中, 这点与独立原生 concat 控制对应.

## 34 份 PDF 的结果

| 输入/路径 | PDF 数 | 每份结果 |
| --- | ---: | --- |
| Org 正式 PDF 接口 | 4 | 4 个 Link, 正文两个正向目标均缺失 |
| 保存的 Org .tm 由原生打印 PDF | 4 | 同上 |
| 独立原生 footnote 打印 PDF | 4 | 同上 |
| Org .tm / 原生 tree 经 export-postscript + ps2pdf | 8 | 同上 |
| Org .tm / 原生 tree 经 print-to-file(.ps) + ps2pdf | 8 | 同上 |
| 普通 hlink/label 正向控制, 三条原生路径 | 6 | 1 个 Link, 目标存在于预期第 2 页 |

28 份脚注 PDF 中, 每份的上方两个正文标记注解均无可解析目标, 下方两个脚注体
编号的回链目标则存在. 按页面坐标明确区分正反方向, 不仅按数量推断.
链接注解不等于有效跳转: 直接 PDF 的正文注解指向 /label0 和 /label1,
但 named destinations 不含对应目标. Poppler 也显示为空 href.

原生 PostScript 链接直接指向 #footnote-1 / #footnote-2, 却没有这两个名字的
/DEST pdfmark; #footnr-1 / #footnr-2 回链目标存在. 即目标名缺失已经发生在
Ghostscript 转换之前. postscript-destinations.txt 保留全部相关原文行及来源行号.
普通链接在 PS 路径仍有注解及目标, 所以此结果不能解释为该路径一概不支持链接.

没有做 GUI 点击; 目标存在不等于同页精确落点正确. 特别是 PostScript 路径的
回链/普通链接目标坐标未验收为正确, 不能据此宣称这两类跳转在 PS PDF 中完全正常.
本实验未追踪 native binding 到 renderer 的具体丢失位置, 未修改生产代码或采用 workaround.

## 复现与产物

```sh
timeout 600s nix build path:./tmp/footnote-forward-probe#checks.x86_64-linux.footnote-forward --no-link --no-write-lock-file --print-build-logs --print-out-paths
```

最终运行 exit0, FORWARD-MATRIX-OK 34. 输出:
/nix/store/dib56d4d3r2bqlsn9fkrsdv1msg1jw11-org-texmacs-footnote-forward-probe
结果已复制到 results/. annotations.json 包含原始 PDF 注解/目标/文本/坐标;
SUMMARY.txt 为数量摘要. 原始 PDF/.ps/.tm 与脚本日志均在 results/ 可复核.
首轮仅因检查脚本混合 Poppler stderr/XML 失败; 修正为分离输出后重跑, 不纳入结果.
正向对照原生 PDF 输出有重复 destination 定义警告, 但所测链接目标存在且指向第2页;
没有将其当作脚注目标缺失的解释.

建议打开 results/org-generic-minimal-package.pdf 与
results/native-generic-minimal-export-ps.pdf 比较正文上标. 二者均不具备可用的正向目标.

归档判断: 生产源码已在项目提交中, 不复制整份源码/依赖/PDF. 新增 PostScript 路径与
两个匿名脚注的失败证据尚无 maintained test, 需要选择性保留探针/锁/输入身份、
结构化检查输出和报告, 而非无条件归档整个 tmp 工作区.
