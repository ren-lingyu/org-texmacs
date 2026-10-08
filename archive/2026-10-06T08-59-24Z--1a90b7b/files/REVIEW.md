# 审阅交接：模块分层与 worker 职责边界

状态：2026-09-19 经只读源码审阅维护。本文件记录审阅后认为必须以书面形式
保留的架构交接内容，与 AGENTS.md / GOALS.md 一样不被 Git 追踪，且不属于
实现授权或版本承诺。

基线：HEAD `746a798`（节点 4 之后）。工作区另有节点 5（example/fixed-width/
source 预格式化块）的未提交改动，不在本文范围。本文结论来自只读源码审阅，
未运行测试、构建或 Nix 检查。

证据等级：本文引用的 require 边、函数归属与调用关系均直接来自仓库源码，
可随时用 `git show HEAD:<file>` 复查；“后果”部分属于结构性推理，不涉及
运行时实测。

---

## 1. 核心发现：worker → document 的模块分层倒挂

### 1.1 一句话概括

`org-texmacs-worker.el`（传输/IPC 层）在模块依赖上 `require` 了
`org-texmacs-document.el`（Org→TeXmacs lowering 层），而运行时调用方向
正好相反——是 document 那套准备流程去调用 worker 解析 STM。即：

> 传输层“站在”领域层之上，基础设施依赖了领域逻辑。

### 1.2 证据

`org-texmacs-worker.el` 第 13–14 行：

```elisp
(require 'org-texmacs-core)
(require 'org-texmacs-document)   ;; ← 倒挂点
```

`org-texmacs-document.el` 第 15–19 行（注意没有 require worker）：

```elisp
(require 'org-texmacs-core)
(require 'org-texmacs-source)
(require 'org-texmacs-fragment)
(require 'org-texmacs-context)
(require 'ox)
```

因此依赖链为：

```
worker ──require──▶ document ──require──▶ {source, fragment, context, ox, core}
```

这条链会传递加载 `ox`（整套 Org export 框架）与 fragment/context 等全部
上层模块。

### 1.3 为什么是“倒挂”

两个方向相反：

| 方向 | 谁 → 谁 | 证据 |
|---|---|---|
| 运行时调用 | document 流程 → worker | `org-texmacs--prepare-buffer`（主入口）里 `dolist (request …)` 逐个调 `org-texmacs--worker-request` 解析 STM island |
| 模块 require | worker → document | worker.el 第 14 行 |

即：逻辑上 document 是 worker 的调用方（上层），但物理上 worker 把
document 拉进来当依赖（反而成了“上层”）。

### 1.4 根因

worker.el 内的 `org-texmacs--worker-document-wire` 是“把 document 结果
序列化成 worker wire 字符串”的桥接函数，被两处调用：

- `org-texmacs--worker-encode-document`（worker.el 自己的诊断编码器）
- `org-texmacs-session-set-document`（session.el）

它用到 4 个 document 层符号：

```elisp
(org-texmacs-document-p document)
(org-texmacs-document-body document)
(org-texmacs-document-stm-paths document)
(org-texmacs--document-copy-stree (org-texmacs-document-body document))
```

于是 worker.el 为这一个“序列化”职责，把整个 document 层拖进了依赖。
而 worker 的原始能力 `parse`（解析 STM snippet）根本不需要 document：
`org-texmacs-tree` / `org-texmacs-fragment-tree` 只走
`--worker-request → --worker-call → --worker-decode`，用不到任何 document 符号。

### 1.5 具体后果

1. 传递加载成本：只用 `parse` 的场景，`(require 'org-texmacs-worker)` 会
   顺带加载 `ox`、fragment、context、document 及它们所有依赖。
2. 变更耦合：`org-texmacs-document` 的 struct 布局或
   `--document-copy-stree` 语义一变，worker.el 就得跟着改；高层结果类型
   成了底层传输层的编译期契约。
3. 职责混杂：worker.el 同时含通用传输与 document 专属序列化两类职责
   （见第 2 节）。
4. 心智模型混乱：读者需要额外解释才能理解“worker 为何 import 最高层模块”。

### 1.6 定性

这是**分层味道，不是正确性 bug**：不构成环（document 不依赖 worker），
运行时也能正常工作。修复属于可维护性优化，不是缺陷修复。

### 1.7 修复方向（不改变行为，只搬位置）

- 方案 A（最小）：把 `--worker-document-wire` 与 `--worker-encode-document`
  移到 `session.el`（已 require worker 且消费 document 结果），或新建
  `org-texmacs-encode.el` 桥接模块；删除 worker.el 对 document 的 require。
- 方案 B：把通用的 `--document-copy-stree`（stree 校验/深拷贝）下沉到
  `org-texmacs-ast.el` 或 core，因其本质是 stree 工具而非 document 专属。
- 方案 C：让 `--worker-document-wire` 接收已解包的 `(body paths)` 普通值
  而非 struct，从而完全不认识 `org-texmacs-document`。

---

## 2. worker.el 的传输/通讯职责清单

本节明确 worker.el 真正承担的职责，便于后续判断“什么该留下、什么该搬走”。

### 2.1 传输机制

- Unix-domain socket，一次请求一个连接；服务端在
  `org-texmacs-worker.scm` 的 `org-texmacs-serve`。
- 客户端在 `--worker-call`，用 `make-network-process :family 'local` 建临时连接。
- 帧定界靠“连接关闭（EOF）”，非长度前缀或分隔符；等待条件为
  `(not (process-live-p client))`。
- 编码统一 `utf-8-unix`（进程与 socket 一致）。

### 2.2 进程生命周期

| 职责 | 函数 |
|---|---|
| 存活判断 | `--worker-live-p` |
| 懒启动 + 就绪等待 | `--worker-start`（等 stdout 的 `ORG-TEXMACS-READY\n`）、`--worker-wait` |
| 退出清理 | `--worker-stop`（清状态→杀进程→杀 buffer→删 socket 目录→摘 hook） |
| 哨兵 | `--worker-sentinel` |

### 2.3 请求构造与编码（Elisp → Scheme wire）

| 职责 | 函数 |
|---|---|
| Scheme 字符串转义 | `--scheme-string` |
| parse 请求 | `--worker-request` → `(parse ID SOURCE)` |
| encode 请求 | `--worker-encode-document` → `(encode ID WIRE)` |
| document → wire | `--worker-document-wire`（★ 唯一越界职责） |
| 统一发请求 | `--worker-call` |

### 2.4 响应读取与校验（Scheme → Elisp datum）

| 职责 | 函数 |
|---|---|
| 读 datum + 信封/ID 校验 | `--worker-decode` |
| 状态分派 | `--worker-decode` 的 `pcase`（ok/session-error/encoding-error/error） |
| stree 形状校验 | `--stree-p`（parse 响应）、`--hex-stree-p`（encode/session-read 响应） |
| session 响应契约校验 | `--worker-decode` |

### 2.5 并发与超时

单请求互斥（`--worker-busy`）、递增请求 ID（`--worker-request-id`）、
启动/请求超时（`org-texmacs-worker-start-timeout` / `-request-timeout`）、
失败降级（parse/encode/session 类错误保活 worker，传输失败则 `--worker-stop`）。

### 2.6 错误分类

`org-texmacs-worker-error` / `-parse-error` / `-encoding-error` /
`-session-error` 均在此文件定义，供全包使用。

### 2.7 越界项

第 2.3 节标 ★ 的 `--worker-document-wire`（及其包装 `--worker-encode-document`）
是 worker.el 中唯一非传输职责，也是第 1 节倒挂的全部来源。

---

## 3. 模块 require DAG（参考）

```
core ──▶ (cl-lib, org-element)
ast ──▶ core
source ──▶ core
fragment ──▶ core, org
context ──▶ core, ox
document ──▶ core, source, fragment, context, ox
worker ──▶ core, document   ← 倒挂
input ──▶ document
session ──▶ worker
org-texmacs.el（主入口）──▶ 以上全部
```

无模块环，但 worker 处于 document 之上（见第 1 节）。

---

## 4. 后续

- 若采纳第 1.7 节任一方案，应同步更新本文件与 AGENTS.md 的当前状态，
  并记录实际提交。
- 本文件仅作书面交接，不授权任何代码修改；实施前按任务另行取得授权。
