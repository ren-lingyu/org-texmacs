# PDF 相邻行为的交互式检查

隔离验证完成后, 优先打开 `results/generic-short-direct.pdf`. 英文样例用于避开中文字体配置干扰. 自动测试核对链接目标页与目录页码; 同一页内的具体条目/脚注定位由下面的点击检查补充.

1. 点击目录中的 AlphaDestination 和 OmegaDestination. 应到达相应标题; 目录显示的页码应与实际页码一致.
2. 点击正文 ForwardToOmega 和 BackToAlpha. 应分别跳到 OmegaDestination 和 AlphaDestination.
3. 在 Alpha 页点击 Group 中的引用数字 1 和 2. 应分别定位到含 FirstTitleSentinel 和 SecondTitleSentinel 的文献条目, 不是只打开文献所在页的任意位置.
4. 在 Omega 页点击 Repeat 后的引用数字. 应仍定位到 FirstTitleSentinel 的同一条目.
5. 在 Omega 页点击 Again 后的重复脚注数字. 应定位到 NamedFootnoteBodySentinel 的脚注正文. 这里只要求已支持的重复引用, 不要求原生首次脚注标记或回跳具备额外功能.
6. 点击 AlphaNumber 后的数字引用. 应跳回 AlphaDestination, 不能与旁边脚注或文献引用混淆.

如果 PDF 阅读器只滚动到目标页但不明显定位同页条目, 查看其跳转后的视口位置; 无法判断时记录为阅读器表现待确认, 不据此认定导出缺陷. 保留测试文件名、点击的文字、实际落点即可反馈.

验证本机导出时, 在 Emacs 打开 `manual.org`, 执行:

```elisp
(setq-local org-texmacs-export-discover-bibliography t)
```

然后 `M-x org-texmacs-export-to-pdf`, 在生成的 manual.pdf 重复上述点击. 如需原生对照, 再运行 `M-x org-texmacs-export-to-texmacs`, 用 TeXmacs 打开 manual.tm 后导出另一份 PDF, 比较两者的页码和点击落点. 不需要在源文件中改写 STM 或安装新字体.

对自然分页的补充检查可打开 `results/generic-flow-direct.pdf`, 对照目录页码和 Alpha/Omega 标题. 自动报告也会比较 direct、原生重载两次打印、六次打印的页面和正文是否稳定; 本检查不承诺任意文档都能在固定轮数收敛.

本轮自动检查另发现: 所有 12 份 PDF 的 First 后首次脚注标记均有悬空目标; Again 后重复标记的目标页有效. 额外点击 First 后的上标 1, 记录是否能到脚注正文, 并与 Again 后的 1 对比. 这是待处理的新发现, 本轮没有修改业务代码. 原生重载并增加到六次打印也保留该现象, 尚未据此断言具体根因.
