"""Read the completed four flake outputs; no export subprocesses."""
import csv
import json
from pathlib import Path

base = Path(__file__).parent
rows = []
for label, factor in [("64k", 10), ("256k", 40), ("1m", 160), ("4m", 640)]:
    result = json.loads((base / f"results-{label}.json").read_text())
    assert result["metadata"]["factor"] == factor
    assert len(result["runs"]) == 4
    for run in result["runs"]:
        assert run["source_state_preserved"] is True
        assert run["source_bytes"] == result["metadata"]["payload_bytes"]
        assert sum(s["exclusive_s"] for s in run["stages"]) <= run["elapsed_s"] + 0.001
        stages = {s["stage"]: s for s in run["stages"]}
        row = {k: run[k] for k in ["factor", "source_bytes", "source_lines", "route", "format", "elapsed_s", "gc_count", "gc_s", "outcome", "error", "output_bytes"]}
        row.update(label=label,
                   wait_s=sum(s["exclusive_s"] for s in run["stages"] if s["stage"].startswith("wait_")),
                   wait_stm_s=stages.get("wait_stm", {}).get("exclusive_s", 0),
                   stm_calls=stages.get("wait_stm", {}).get("calls", 0),
                   native_wait_s=sum(s["exclusive_s"] for s in run["stages"] if s["stage"] in ("wait_serialize", "wait_render-pdf")),
                   org_prepare_s=stages.get("org_prepare", {}).get("exclusive_s", 0),
                   lowering_s=stages.get("lowering", {}).get("exclusive_s", 0),
                   native_wire_s=stages.get("native_wire", {}).get("exclusive_s", 0),
                   residual_s=run["elapsed_s"] - sum(s["exclusive_s"] for s in run["stages"]))
        rows.append(row)
assert len(rows) == 16
(base / "summary.json").write_text(json.dumps(rows, indent=2) + "\n")
with (base / "summary.csv").open("w", newline="") as output:
    writer = csv.DictWriter(output, fieldnames=list(rows[0]), lineterminator="\n")
    writer.writeheader()
    writer.writerows(rows)
for row in rows:
    print(f"{row['label']:4s} {row['route']:15s} {row['format']:3s} "
          f"{row['elapsed_s']:.3f}s {row['outcome']} "
          f"STM={row['stm_calls']}/{row['wait_stm_s']:.3f}s "
          f"nativewait={row['native_wait_s']:.3f}s GC={row['gc_s']:.3f}s "
          f"error={row['error']}")

def get(label, route, fmt):
    return next(r for r in rows if (r["label"], r["route"], r["format"]) == (label, route, fmt))

def display(r):
    if r["outcome"] == "success":
        return f"{r['elapsed_s']:.3f}"
    name = "超限拒绝" if r["outcome"] == "expected-size-rejection" else "转换失败"
    return f"{name}（{r['elapsed_s']:.3f}s）"

report = ["# 大步长无 INCLUDE 导出测量", "",
          "本轮使用独立 flake，保持业务代码、标准导出限额与默认 10 秒 worker 单请求超时不变。每种情况采样一次，记录成功、超限拒绝及转换失败；不是三次中位数。", "",
          "## 总耗时", "", "单位秒；worker 已启动。标准全文命令与显式源 API 分开列出。", "",
          "| 标签 | 实际字节 | 行数 | 标准 .tm | 标准 PDF | 显式源 .tm | 显式源 PDF |",
          "| --- | ---: | ---: | ---: | ---: | ---: | ---: |"]
for label in ("64k", "256k", "1m", "4m"):
    r = get(label, "explicit-source", "tm")
    values = [display(get(label, route, fmt)) for route in ("frontend", "explicit-source") for fmt in ("tm", "pdf")]
    report.append(f"| {label} | {r['source_bytes']} | {r['source_lines']} | " + " | ".join(values) + " |")
report += ["", "## 显式源 API 阶段", "",
           "exclusive 毫秒；GC 时间可能落在这些阶段内部，不可再与阶段时间直接相加。worker 等待不等于原生 CPU 时间。", "",
           "| 标签 | 格式 | STM 请求数 | STM 等待 | 序列化/渲染等待 | Org 准备 | lowering | native wire | GC 次数/毫秒 | 结果 |",
           "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |"]
for r in rows:
    if r["route"] != "explicit-source":
        continue
    values = [r[k] * 1000 for k in ("wait_stm_s", "native_wait_s", "org_prepare_s", "lowering_s", "native_wire_s")]
    report.append(f"| {r['label']} | {r['format']} | {r['stm_calls']} | " + " | ".join(f"{v:.1f}" for v in values) + f" | {r['gc_count']}/{1000*r['gc_s']:.1f} | {r['outcome']} |")
report += ["", "## 观察", "",
           "16 个结果中有 10 次成功导出、4 次预期的标准全文超限拒绝、2 次显式源 worker 错误；全部源状态检查通过。约 1 MiB 显式源导出需要约 30 秒，约 4 MiB 两种格式均未成功。",
           "约 4 MiB 的两个调用都完成了 1920 次 STM 请求，累计等待约 99–101 秒，随后最终 serialize/render-pdf 响应等待达到约 10.001 秒，返回通用 Worker exited or timed out 错误。不能把 118/116 秒视为成功导出耗时，也未通过单独原生进程跟踪区分退出与到期原因。",
           "1 MiB 的 Org 准备约 0.2 秒，4 MiB 约 1.2 秒；4 MiB 的 lowering 约 0.5 秒、native wire 约 1.3 秒、GC 约 0.27–0.29 秒。当前数学密集样本的阻塞主要仍在顺序 STM 请求累计等待，并出现大文档最终响应的失败边界；不意味着全部等待都可通过减少轮询消除。", "",
           "## 错误与边界", ""]
for r in rows:
    if r["error"]:
        report.append(f"- {r['label']} / {r['route']} / {r['format']}：`{r['error']}`，发生前总耗时 {r['elapsed_s']:.3f}s。")
report += ["", "## 方法、来源与局限", "",
           "- 锁定 Emacs 31.1、Org 9.8.10、TeXmacs 2.1.5，x86_64-linux；使用 flake 内构建的 Emacs/包，无系统 Emacs。17 个包源码/文档/LICENSE/lock 输入与被测项目提交逐字节核对；见 project-inputs.json 和 input-verification.md。",
           "- 冻结既有 6447 字节数学/图形例子，原 TITLE 一次，正文重复 10/40/160/640 次；无新增数学表达式、无 INCLUDE 指令。workloads.json 保留重建配方及重建摘要，未冒称对已删除构建输入独立取样哈希。未归档 MiB 级展开副本。",
           "- 每个规模独立构建、新 HOME/TEXMACS_HOME_PATH；组内依次 frontend .tm、frontend PDF、explicit-source .tm、explicit-source PDF。每次确保 worker 存活，启动不计时；未预热每类字体/样式/渲染缓存。因此 fixed order 有缓存偏差，不能把路径差值解释为 API 优化收益。",
           "- 前端调用 org-texmacs-export-to-texmacs / org-texmacs-export-to-pdf；显式源调用 org-texmacs-export-to-texmacs-file / org-texmacs-export-to-pdf-file。后者按现有 API 合同不运行 preprocessing；并非修改或绕过标准命令内部限额。",
           "- -Q --batch；discovery=nil、with-toc=nil，GC 阈值 800000/percentage 1.0，worker-request-timeout=10。保留默认超时，转换错误是真实结果，不自动提高超时重跑。",
           "- 计时只含导出调用，排除文件创建/打开、显式 GC、worker 启动、源状态与产物检查。临时 advice 记录嵌套 inclusive 与非重叠 exclusive 墙钟时间，inclusive 不可累加；总时间余项见 summary.json。",
           "- 每次检查源文本/文件/目录/modified/point/mark/限制/tick，成功产物检查 .tm/PDF 头；小档 frontend 另检查 preprocessing 内容一致。错误路径同样检查源状态。本次没有完整原生语义/排版对比验收。",
           "- 16 个测量结果包含超限拒绝和可能的转换错误；构建成功表示诊断脚本记录并完成，不代表所有导出成功。成功日志包含实际 building，重复相同 nix build 可能返回旧数据。",
           "- 同一数学密度随字节一起放大，STM 请求数 30/120/480/1920；不能将其当作同字节量的纯 prose 文档性能。每种单样本、单机，系统负载未控制；没有直接跟踪用户交互式 Emacs 的按键延迟。", "",
           "## 命令", "", "按顺序运行，LABEL=64k、256k、1m、4m：", "", "```sh",
           "timeout 600s nix build 'path:./tmp/export-timing-large#checks.x86_64-linux.bench-LABEL' --no-link --no-update-lock-file --print-build-logs --print-out-paths",
           "```", "", "用户授权上述命令本轮依次重复执行、必要的锁定依赖网络、大输入临时读写及 JSON/日志结果复制。没有改业务代码、生产限额、根 lock、原始例子或普通项目 index。", "",
           "原始结果、诊断脚本和固定输入具有独立性能证据价值，按 archive skill 选择性保存文本；当前结论与下一步另行录入 GAW memory。"]
(base / "REPORT.md").write_text("\n".join(report) + "\n")
