# 大步长无 INCLUDE 导出测量

本轮使用独立 flake，保持业务代码、标准导出限额与默认 10 秒 worker 单请求超时不变。每种情况采样一次，记录成功、超限拒绝及转换失败；不是三次中位数。

## 总耗时

单位秒；worker 已启动。标准全文命令与显式源 API 分开列出。

| 标签 | 实际字节 | 行数 | 标准 .tm | 标准 PDF | 显式源 .tm | 显式源 PDF |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 64k | 64155 | 1811 | 1.852 | 2.822 | 1.828 | 2.172 |
| 256k | 256515 | 7241 | 7.427 | 8.689 | 6.986 | 7.998 |
| 1m | 1025955 | 28961 | 超限拒绝（0.018s） | 超限拒绝（0.017s） | 29.329 | 30.852 |
| 4m | 4103715 | 115841 | 超限拒绝（0.072s） | 超限拒绝（0.065s） | 转换失败（118.046s） | 转换失败（115.652s） |

## 显式源 API 阶段

exclusive 毫秒；GC 时间可能落在这些阶段内部，不可再与阶段时间直接相加。worker 等待不等于原生 CPU 时间。

| 标签 | 格式 | STM 请求数 | STM 等待 | 序列化/渲染等待 | Org 准备 | lowering | native wire | GC 次数/毫秒 | 结果 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 64k | tm | 30 | 1554.5 | 200.6 | 11.3 | 2.9 | 30.3 | 0/0.0 | success |
| 64k | pdf | 30 | 1504.7 | 602.1 | 11.7 | 2.1 | 28.0 | 0/0.0 | success |
| 256k | tm | 120 | 6015.8 | 601.2 | 42.0 | 18.9 | 126.3 | 1/24.4 | success |
| 256k | pdf | 120 | 6224.8 | 1453.9 | 42.2 | 16.1 | 93.2 | 1/29.0 | success |
| 1m | tm | 480 | 25385.8 | 2303.8 | 197.3 | 46.6 | 337.9 | 2/118.0 | success |
| 1m | pdf | 480 | 24229.1 | 5120.5 | 192.1 | 44.8 | 328.7 | 2/133.4 | success |
| 4m | tm | 1920 | 101180.4 | 10000.9 | 1236.8 | 505.8 | 1347.7 | 4/267.2 | conversion-error |
| 4m | pdf | 1920 | 98874.1 | 10001.0 | 1227.1 | 491.8 | 1302.2 | 4/290.3 | conversion-error |

## 观察

16 个结果中有 10 次成功导出、4 次预期的标准全文超限拒绝、2 次显式源 worker 错误；全部源状态检查通过。约 1 MiB 显式源导出需要约 30 秒，约 4 MiB 两种格式均未成功。
约 4 MiB 的两个调用都完成了 1920 次 STM 请求，累计等待约 99–101 秒，随后最终 serialize/render-pdf 响应等待达到约 10.001 秒，返回通用 Worker exited or timed out 错误。不能把 118/116 秒视为成功导出耗时，也未通过单独原生进程跟踪区分退出与到期原因。
1 MiB 的 Org 准备约 0.2 秒，4 MiB 约 1.2 秒；4 MiB 的 lowering 约 0.5 秒、native wire 约 1.3 秒、GC 约 0.27–0.29 秒。当前数学密集样本的阻塞主要仍在顺序 STM 请求累计等待，并出现大文档最终响应的失败边界；不意味着全部等待都可通过减少轮询消除。

## 错误与边界

- 1m / frontend / tm：`Org TeXmacs document conversion failed: "Source exceeds 256 KiB"`，发生前总耗时 0.018s。
- 1m / frontend / pdf：`Org TeXmacs document conversion failed: "Source exceeds 256 KiB"`，发生前总耗时 0.017s。
- 4m / frontend / tm：`Org TeXmacs document conversion failed: "Source exceeds 256 KiB"`，发生前总耗时 0.072s。
- 4m / frontend / pdf：`Org TeXmacs document conversion failed: "Source exceeds 256 KiB"`，发生前总耗时 0.065s。
- 4m / explicit-source / tm：`TeXmacs worker failure: "TeXmacs worker failure: \"Worker exited or timed out\""`，发生前总耗时 118.046s。
- 4m / explicit-source / pdf：`TeXmacs worker failure: "TeXmacs worker failure: \"Worker exited or timed out\""`，发生前总耗时 115.652s。

## 方法、来源与局限

- 锁定 Emacs 31.1、Org 9.8.10、TeXmacs 2.1.5，x86_64-linux；使用 flake 内构建的 Emacs/包，无系统 Emacs。17 个包源码/文档/LICENSE/lock 输入与被测项目提交逐字节核对；见 project-inputs.json 和 input-verification.md。
- 冻结既有 6447 字节数学/图形例子，原 TITLE 一次，正文重复 10/40/160/640 次；无新增数学表达式、无 INCLUDE 指令。workloads.json 保留重建配方及重建摘要，未冒称对已删除构建输入独立取样哈希。未归档 MiB 级展开副本。
- 每个规模独立构建、新 HOME/TEXMACS_HOME_PATH；组内依次 frontend .tm、frontend PDF、explicit-source .tm、explicit-source PDF。每次确保 worker 存活，启动不计时；未预热每类字体/样式/渲染缓存。因此 fixed order 有缓存偏差，不能把路径差值解释为 API 优化收益。
- 前端调用 org-texmacs-export-to-texmacs / org-texmacs-export-to-pdf；显式源调用 org-texmacs-export-to-texmacs-file / org-texmacs-export-to-pdf-file。后者按现有 API 合同不运行 preprocessing；并非修改或绕过标准命令内部限额。
- -Q --batch；discovery=nil、with-toc=nil，GC 阈值 800000/percentage 1.0，worker-request-timeout=10。保留默认超时，转换错误是真实结果，不自动提高超时重跑。
- 计时只含导出调用，排除文件创建/打开、显式 GC、worker 启动、源状态与产物检查。临时 advice 记录嵌套 inclusive 与非重叠 exclusive 墙钟时间，inclusive 不可累加；总时间余项见 summary.json。
- 每次检查源文本/文件/目录/modified/point/mark/限制/tick，成功产物检查 .tm/PDF 头；小档 frontend 另检查 preprocessing 内容一致。错误路径同样检查源状态。本次没有完整原生语义/排版对比验收。
- 16 个测量结果包含超限拒绝和可能的转换错误；构建成功表示诊断脚本记录并完成，不代表所有导出成功。成功日志包含实际 building，重复相同 nix build 可能返回旧数据。
- 同一数学密度随字节一起放大，STM 请求数 30/120/480/1920；不能将其当作同字节量的纯 prose 文档性能。每种单样本、单机，系统负载未控制；没有直接跟踪用户交互式 Emacs 的按键延迟。

## 命令

按顺序运行，LABEL=64k、256k、1m、4m：

```sh
timeout 600s nix build 'path:./tmp/export-timing-large#checks.x86_64-linux.bench-LABEL' --no-link --no-update-lock-file --print-build-logs --print-out-paths
```

用户授权上述命令本轮依次重复执行、必要的锁定依赖网络、大输入临时读写及 JSON/日志结果复制。没有改业务代码、生产限额、根 lock、原始例子或普通项目 index。

原始结果、诊断脚本和固定输入具有独立性能证据价值，按 archive skill 选择性保存文本；当前结论与下一步另行录入 GAW memory。
