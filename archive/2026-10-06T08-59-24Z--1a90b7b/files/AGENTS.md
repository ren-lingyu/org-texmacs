```text
注意: 本文件应当被随时维护, 但不应当被 git 追踪
```

# org-texmacs

## 阅读导航与当前状态 (2026-09-21)

* 本文件包含历史设计、阶段性实测记录和后续规划，不应把早期的
  “暂不实现 inline”“只做一个文件”当成 v0.1.0 的现状。
* 当前发布基线为本地 `v0.2.1`, 其目标提交为
  `9988476b7ae98f33375d9c62ef4234890ce8b39c`.
  本地 tag 对象为 `9ac35e7dcfd7038b916a7ce648015ad32909fe28`,
  应使用 `v0.2.1^{commit}` 比较提交, 不把 tag 对象 hash 当作提交 hash.
  该版本的三个实施节点已提交, 最终五项验证通过.
  只核对本地状态, 不以此证明远端发布页面或 tag 签名已验证.
  当前开发 HEAD 为 `545df379d4641683546e622d67711fad0969a5b8`,
  已包含 v0.3.0 节点 1--8. 节点 9 的 worktree 主包与 Nix 版本已更新
  为 0.3.0 并通过发布验证, 但尚未提交或创建 v0.3.0 tag. 不应再把
  HEAD 与发布 tag 目标等同.
* 先读根目录 [GOALS.md](GOALS.md): 最终目标, AST-first, 使用目标,
  显式输入输出与副作用边界是长期严格约束. 缓存/增量性能是软目标,
  当前工作路径, 内部接口和版本拆分可按证据调整.
  本文件保存实现事实, 验证记录, 版本范围和具体计划, 不重复维护另一份
  可独立演变的最终目标. GOALS.md 与本文件均不被 Git 追踪.
* 已实现能力以仓库源码、正式测试及后文 §28–30 为准。
  后续工作见末尾「Document lowering 与 TeXmacs native tree 交接文档」，
  尤其先读其 §0（证据等级）和 §18（实施前约束）。
* 后续规划不是实现授权。测试、worker 实验和构建仍须按任务获得授权。
* PLAN-2026-09-12-02 的 v0.2.0 实现与发布整理已完成.
  后续方向见 GOALS.md 及 PLAN-2026-09-13-01 的解释与待决定事项.
  当前接口收敛计划见 PLAN-2026-09-14-01, 已完成并核对本地 tag.
  v0.2.1 主入口要求显式 source-buffer,
  另设 current-buffer 包装, 不保留 v0.2.0 零参数调用兼容性.
  完整 document model, effective configuration 及更多正文结构见新增
  PLAN-2026-09-14-02, 正式方案和前置探针已经收敛. 节点 1--8 已提交,
  节点 9 已实现并通过正式发布验证, 等待提交前审阅. v0.3.0 接口为
  prepared-input core 和显式 buffer adapter.
  不将 GOALS.md 的最终能力列表视为当前支持列表或下一版本全量承诺.
* 暂保留单文件与原章节编号，避免打断历史交接引用；新增内容的修订
  集中于后续规划，不改写旧实验记录。本文件继续不被 Git 追踪。

## 文档组织约定

本文件同时保存历史和当前状态，但二者必须明确区分。暂不批量重排旧章节；
新增内容按以下位置归档，不再直接在文件末尾随意增加同级目标章节。

| 内容 | 放置位置 | 状态要求 |
|---|---|---|
| 最终目标, 使用目标与严格架构/副作用约束 | 根目录 GOALS.md 第 1--4 节 | 与性能软目标及可调整路径区分, 不等于实现授权 |
| 当前基线、工作方向与入口 | 本文开头的「阅读导航与当前状态」 | 已确认，注明日期 |
| 新观察、疑问、外部实验报告 | 末尾「新增观察」 | 默认待审阅，列证据和限制 |
| 新目标、实现设想、取舍建议 | 末尾「计划提案」 | 默认待讨论，不是执行授权 |
| Document lowering 当前分层、边界与节点 | 交接文档 §18；同步边界见后面的专题 | 已采纳与候选分开写 |
| 本机测试命令、结果与失败记录 | 交接文档 §19，按新小节追加 | 已执行/未执行明确分开 |
| 已完成实现或历史路线 | 原阶段进度与历史章节 | 保留当时日期，注明后续替代位置 |

维护规则：

1. 新观察使用稳定 ID `OBS-日期-序号`；计划使用 `PLAN-日期-序号`。
   引用 ID 或唯一标题，不引用易随编辑变化的行号。
2. 用户可只追加标题和原始内容，缺失字段留作“待补充”；不能因没有
   复验就删除用户观察，也不能把“报告已测试”自动写成“本机已复验”。
3. 审阅结论写在同一条目下，保留原观察的要点及证据。采用后链接到
   对应设计/验证章节，不复制多份可独立演变的完整计划。
4. 新内容更晚不代表自动覆盖旧决策。与当前计划冲突时，先明确冲突、
   范围和待决定事项；确认后同步更新当前设计，并标注被替代内容。
5. “已采纳”不等于“已授权执行”，“已实现”不等于“已验证”。只有真实
   执行后才记录命令、版本、输入、输出、退出状态及通过范围。
6. 今后若拆成 `OBSERVATIONS.md`、`PLANS.md` 等，先确认目标未被追踪、
   已被忽略且不经符号链接越界；本文保留导航和通用约束，具体内容只
   保持一份，迁移时保留稳定 ID。本轮未拆分文件。
7. GOALS.md 描述目标, 本文描述现状与计划. 新目标与旧版本范围不一致时,
   区分未来方向变化与历史实现事实, 不追溯扩大已发布版本的验收范围.
   原生 API 能力, 新增映射和 consumer 行为仍须源码证据及必要实测,
   不能因为目标文档提及便标为已验证.

## 0. 目的

计划实现一个 Emacs Lisp 包，暂称：

```text
org-texmacs
```

核心目标是：

> 在 Org 文档中直接手写 TeXmacs 官方 STM/Scheme S-expression 结构化语法，用 TeXmacs 的 tree/stree 作为数学表达式的结构化表示，替代当前大量使用的线性 LaTeX 公式；Org 文件仍然是唯一源文件，不使用外部 `.tm` 文件。

当前阶段**不做 preview / export / font-lock / 编辑辅助**。优先实现一个稳定、最小的 AST integration layer。

用户明确偏好：

```text
稳定性 > 方便性
```

因此：

* 不希望自行发明一套 DSL；
* 希望手写 TeXmacs 官方 STM/Scheme serialization；
* 不接受把 TeXmacs 内容仅作为 opaque string 长期存入 Org AST；
* 不接受外部 `.tm` 文件作为 canonical source；
* 可以把 TeXmacs 作为 Emacs 包的运行时依赖；
* 可以接受 TeXmacs 语法手写较麻烦，编辑体验后续可以借 Scheme mode 等机制改进；
* 当前不要求“整个数学知识库统一 AST”这种更激进目标；
* 不应为了追求 live AST 而引入大量不必要的同步复杂度。

---

# 1. 当前最终架构判断

经过大量 Org / TeXmacs 实际运行测试，当前建议架构已经从早期的：

```text
Org live AST
└── texmacs-fragment
    └── TeXmacs pseudo subtree
```

实时维护模式，收缩为：

```text
Org source                         canonical
    │
    ▼
special-block (:type "texmacs")   Org-native representation
    │
    │ lazy derived data
    ▼
TeXmacs stree
    │
    ▼
Org-compatible pseudo subtree
```

换句话说：

> **不要实时替换 Org live element cache 中的 `special-block`。**

而应该：

> **保留 Org 原生的 `special-block`，把 TeXmacs AST 当成该 element 的按需派生缓存。**

主要公开入口预计为：

```elisp
(org-texmacs-tree BLOCK)
```

其语义：

```text
BLOCK
  ↓
验证它是 type="texmacs" 的 special-block
  ↓
查询 Org custom cache
  ├─ hit  → 返回已缓存的 TeXmacs pseudo subtree
  └─ miss
       ↓
     提取 raw STM source
       ↓
     TeXmacs worker parse
       ↓
     stree
       ↓
     stree -> Org pseudo subtree
       ↓
     存入 Org custom cache
       ↓
     返回
```

---

# 2. Source-level syntax

当前建议直接复用 Org 原生 `special-block`：

```org
#+begin_texmacs
(with "mode" "math"
  (concat "x+" (frac "1" "2")))
#+end_texmacs
```

实际验证：

```elisp
(org-element-parse-buffer)
```

会产生：

```text
special-block
:type "texmacs"
```

所以**不需要为 source syntax 新写 Org parser**。

block body 会被 Org 自己继续解析为：

```text
paragraph
└── plain-text
```

但这些 children **不能作为 TeXmacs AST source 使用**。

正确方式是读取：

```elisp
:contents-begin
:contents-end
```

然后：

```elisp
(buffer-substring-no-properties
 (org-element-property :contents-begin block)
 (org-element-property :contents-end block))
```

实际测试已经确认，这能逐字符精确取得原始 STM body，包括尾部换行。

---

# 3. TeXmacs tree / stree 边界

环境中已经可以：

```elisp
(executable-find "texmacs")
```

当前 TeXmacs：

```text
TeXmacs 2.1.5
```

TeXmacs 官方命令行支持：

```text
-H         Run TeXmacs in headless mode
-x [cmd]   Execute scheme command
-q         Shortcut for -x "(quit-TeXmacs)"
-s         Suppress information messages
```

已经实际验证以下调用链：

```text
STM/Scheme serialization
        ↓
stm-snippet->texmacs
        ↓
TeXmacs native tree
        ↓
tree->stree
        ↓
Scheme S-expression serialization
        ↓
Emacs read-from-string
        ↓
普通 Elisp tree
```

例如输入：

```scheme
(with "mode" "math"
  (concat "x+" (frac "1" "2")))
```

TeXmacs 返回：

```elisp
(with "mode" "math"
      (concat "x+" (frac "1" "2")))
```

因此：

> 不需要自己实现 TeXmacs parser。

也不需要让 Emacs 持有 TeXmacs C++/Guile native `tree` object。

跨进程边界使用：

```text
stree / Scheme serialization
```

即可。

---

# 4. TeXmacs stree 与 Org pseudo subtree

## 4.1 两种结构不完全相同

TeXmacs stree：

```elisp
(TAG CHILD1 CHILD2 ...)
```

Org syntax node：

```elisp
(TYPE PROPERTIES CONTENTS...)
```

所以 TeXmacs stree **不能直接作为 Org pseudo node**。

例如：

```elisp
(with "mode" "math" ...)
```

Org 会把：

```text
"mode"
```

误当作 property slot。

实际测试：

```elisp
(org-element-contents
 '(with "mode" "math" ...))
```

会丢掉 `"mode"`。

---

## 4.2 正确 adapter

正向：

```text
TeXmacs stree
(TAG CHILD...)
        ↓
Org pseudo tree
(TAG nil CHILD...)
```

但实际实现不应手工插 `nil`，而应该递归使用：

```elisp
org-element-create
```

原因：

* 自动生成 Org properties storage；
* 自动建立 `:parent`；
* plain-text 会得到正确的 Org text properties。

已验证的 prototype：

```elisp
(defun stree->org (node)
  (cond
   ((stringp node)
    (substring-no-properties node))
   ((consp node)
    (apply #'org-element-create
           (car node)
           nil
           (mapcar #'stree->org
                   (cdr node))))
   (t node)))
```

注意：

> 必须复制字符串。

因为 `org-element-create` / adopt 会给字符串本身添加 `:parent` text property。

如果直接复用原 stree 的字符串对象，Org 会污染原始 stree。

所以正向 adapter 必须：

```elisp
(substring-no-properties node)
```

产生新的字符串。

---

## 4.3 反向 adapter

prototype：

```elisp
(defun org->stree (node)
  (cond
   ((stringp node)
    (substring-no-properties node))
   ((and (consp node)
         (symbolp (car node)))
    (cons
     (car node)
     (mapcar #'org->stree
             (org-element-contents node))))
   (t node)))
```

也就是说：

```text
忽略 Org properties slot
递归读取 contents
清除字符串 text properties
```

---

## 4.4 round-trip 已实测通过

真实 TeXmacs parser 输出：

```elisp
(with "mode" "math"
      (concat "x+" (frac "1" "2")))
```

经过：

```text
TeXmacs stree
→ Org pseudo subtree
→ TeXmacs stree
```

得到：

```text
roundtrip exact = t
```

并确认：

```text
原 stree 字符串无 text properties
Org tree 字符串有 :parent 等 properties
反向后的 stree 再次无 properties
```

所以这套 adapter 已经基本确认。

---

# 5. Org pseudo node 兼容性测试结果

无需把：

```text
with
concat
frac
sqrt
...
```

注册成 Org 正式 element/object type。

Org 允许任意 symbol 作为 pseudo node type。

以下均已实际测试通过。

---

## 5.1 `org-element-map`

例如：

```elisp
(with nil
      "mode"
      "math"
      (concat nil
              "x+"
              (frac nil "1" "2")))
```

可以：

```elisp
(org-element-map
 tree
 '(with concat frac)
 ...)
```

得到：

```elisp
(with concat frac)
```

---

## 5.2 `TYPES=t`

generic traversal 也能进入 foreign subtree：

```text
org-data
paragraph
plain-text
texmacs-fragment
with
plain-text
plain-text
concat
plain-text
frac
plain-text
...
```

无需预注册 TeXmacs type。

---

## 5.3 可以作为 traversal boundary

使用：

```elisp
org-element-ast-map
```

配合：

```elisp
NO-RECURSION = 'texmacs-fragment
```

可以：

```text
需要统一 AST
→ 进入 foreign subtree

不想理解 TeXmacs
→ 在 texmacs-fragment 处停止
```

这是一个非常有用的性质。

---

## 5.4 `org-element-create`

可以直接创建未注册 pseudo type：

```elisp
(org-element-create 'frac nil "1" "2")
```

并自动建立 parent 链。

已经测试：

```text
texmacs-fragment
└── with
    └── concat
        └── frac
```

各层：

```elisp
(org-element-property :parent ...)
```

均正确。

---

## 5.5 `org-element-lineage`

可以从 foreign node 一路向上跨越：

```text
frac
→ concat
→ with
→ texmacs-fragment
→ paragraph
→ section
→ org-data
```

已实测：

```elisp
(concat with texmacs-fragment paragraph section org-data)
```

---

## 5.6 `org-element-copy`

```elisp
(org-element-copy tree t)
```

可以递归复制 pseudo subtree。

需要注意：

当前 Org 的 `org-element-copy ... t` 对普通 Org element 和 pseudo node 都不会完整重建所有 child `:parent`。

这是 Org 自己的通用行为，不是 pseudo node 特有问题。

---

## 5.7 `org-element-set`

可以替换 pseudo node。

重要语义：

```elisp
(org-element-set OLD NEW)
```

实际上是：

> 以 OLD 的 cons/object identity 为锚，原地把 OLD 改成 NEW 的结构。

实际测试：

```text
inserted-is-original-block     t
inserted-is-replacement        nil
child parent -> inserted root  t
```

因此 replacement root 自己不会成为最终 AST root object。

---

# 6. 为什么不再实时把 pseudo subtree 塞入 Org live cache

我们已经验证过，这件事技术上完全可行。

曾经实现/测试过：

```text
after-change
→ Org cache invalidation
→ org-element-cache-map
→ 找到 special-block
→ TeXmacs parse
→ 原地 retag 为 texmacs-fragment
```

甚至完整验证了：

```text
(frac "1" "2")
→ 用户编辑
→ (frac "3" "2")
→ TeXmacs 重新 parse
→ cached pseudo subtree 自动更新
```

也验证了：

* block 新建；
* block 删除；
* delimiter 破坏；
* delimiter 修复；
* change range 跨多个 block；
* zero-width range；
* `org-element-cache-map :restrict-elements`；
* before/after-change；
* stale cache invalidation。

但是这一路会把问题升级成：

> 自己维护第二套实时增量 AST synchronization。

工程代价包括：

* after-change hook；
* before-change hook；
* cache invalidation；
* block overlap；
* asynchronous parse；
* stale response；
* request id；
* block position movement；
* cache object identity；
* worker lifecycle。

这远超过当前需求。

因此当前正式决定：

> **不实时维护 TeXmacs foreign subtree。**

---

# 7. Org custom cache API

Org 当前提供：

```elisp
org-element-cache-store-key
org-element-cache-get-key
```

可以在 element cache 上存第三方 derived data。

已经实际测试：

```elisp
(org-element-cache-store-key
 block
 'org-texmacs-test-tree
 '(frac "1" "2"))
```

之后：

```elisp
(org-element-cache-get-key
 block
 'org-texmacs-test-tree
 'missing)
```

得到：

```elisp
(frac "1" "2")
```

如果修改 block body：

```text
(frac "1" "2")
→
(frac "1" "3")
```

重新取得 element 后：

```elisp
org-element-cache-get-key
```

得到：

```elisp
missing
```

所以：

> TeXmacs body 改变时，Org 可以替我们自动 invalidate derived AST。

---

## 7.1 custom cache 的限制

如果仅修改 block 前面的无关文本：

```org
Before

#+begin_texmacs
...
#+end_texmacs
```

变成：

```org
Before changed

#+begin_texmacs
...
#+end_texmacs
```

TeXmacs block 自身内容完全没变，只是：

```text
:begin 9
→
:begin 17
```

但是 custom cache 仍然变成：

```elisp
missing
```

即使：

```elisp
ROBUST=t
```

也仍然失效。

因此 custom key **不是稳定 block identity**。

当前决定：

> 接受这种较粗粒度 invalidation。

因为 correctness 没问题，只是下一次按需访问时多 parse 一次。

不要为了让 AST 跨 block position shift 长期存活，再引入 marker / UUID / identity tracking。

---

# 8. TeXmacs parser 的 strict/recovery 行为

`stm-snippet->texmacs` 是 recovery parser。

例如：

```scheme
(frac "1" "2"
```

少一个右括号，返回：

```scheme
(frac "1" "2")
```

甚至：

```scheme
(frac "1" "2)
```

未闭合字符串，也仍然：

```text
status 0
```

并产生 recovery tree：

```scheme
(frac "1" "\"2)")
```

因此：

> 不能用 `stm-snippet->texmacs` 是否成功，判断 source 是否是完整合法 STM serialization。

---

## 8.1 strict validation

TeXmacs 内嵌 Guile 的：

```scheme
read
```

可以作为严格层。

测试：

```scheme
(frac "1" "2)
```

Guile `read` 返回：

```text
ORG-TEXMACS-READ-ERROR
```

建议 worker 每次 request：

```text
source
 ↓
Guile read
 ↓
确保：
  - 有一个 datum
  - 后面 EOF
 ↓
stm-snippet->texmacs
```

也就是：

```text
strict Scheme syntax
→ TeXmacs semantic parse
```

当前 lazy API 中，如果 strict parse 失败：

* 可以 signal 一个明确的 Elisp error；
* 或返回一个 condition/result object。

第一版建议简单 signal error，不必立即设计复杂 recovery UI。

---

# 9. Persistent TeXmacs worker

反复执行：

```text
texmacs -H -x ...
```

仍有明显 startup overhead。

而且测试中由于每次使用全新 fake HOME，还会触发：

```text
Installation completed successfully !
```

所以 startup 测试看起来尤其重。

已经验证：

```text
-H
```

是 TeXmacs 2.1.5 的官方 headless mode。

---

## 9.1 长期 headless runtime

测试：

```scheme
(display ...)
(sleep 30)
```

确认：

```text
process-live = t
```

所以：

> headless TeXmacs runtime 可以长期存在。

---

## 9.2 stdin 不可直接作为 Guile worker channel

曾尝试：

```scheme
(read)
```

或：

```scheme
(open-input-file "/dev/stdin")
```

配合：

```elisp
process-send-string
```

失败。

因此不要再尝试 stdin worker。

---

# 10. Unix-domain socket worker 已验证

TeXmacs 内嵌 Guile 中以下均存在：

```scheme
socket
bind
listen
accept
close
close-port
force-output
AF_UNIX
PF_UNIX
SOCK_STREAM
```

已经成功启动：

```text
texmacs -H -s -x <server-loop>
```

并在临时目录创建：

```text
worker.sock
```

Emacs 使用：

```elisp
make-network-process
:family 'local
:service socket-path
```

连接成功。

---

## 10.1 单请求

输入：

```scheme
(frac "1" "2")
```

返回：

```elisp
(frac "1" "2")
```

worker 仍保持：

```text
process-live = t
```

---

## 10.2 同一 runtime 连续请求

同一个 TeXmacs worker：

请求 1：

```scheme
(frac "1" "2")
```

请求 2：

```scheme
(sqrt "x")
```

worker 中维护 counter。

返回：

```elisp
:first
(1 (frac "1" "2"))

:second
(2 (sqrt "x"))
```

确认：

```text
same-runtime-counter = t
```

也就是说：

> 两个请求确实运行在同一个 TeXmacs/Guile runtime 中。

---

## 10.3 request-local error recovery

worker 中对单请求使用：

```scheme
catch
```

测试：

请求 1：

```scheme
(frac "1" "2)
```

非法。

返回：

```elisp
(error 1)
```

然后请求 2：

```scheme
(sqrt "x")
```

返回：

```elisp
(ok 2 (sqrt "x"))
```

且：

```text
worker-live = t
```

所以：

> 单次请求失败不会杀死 persistent worker。

---

# 11. 当前建议的 worker 模型

第一版可以采用：

```text
一个 Emacs instance
        │
        │
        ▼
一个 persistent TeXmacs worker
        │
        │ Unix-domain socket
        ▼
多个 Org buffer 共用
```

暂时没有证据需要：

```text
每 buffer 一个 worker
```

worker 建议：

* lazy start；
* socket 放在 Emacs 创建的临时目录；
* TeXmacs 使用 `-H -s`；
* worker 自己循环 `accept`；
* 每个 connection 处理一个 request；
* response 后关闭该 client connection；
* server process 继续运行；
* 每个 request 用 `catch` 隔离错误。

第一版由于 `org-texmacs-tree` 是**按需调用**而不是 hot edit path，可以先使用：

```text
发送 request
→ 同步等待 response
```

不必立即设计 async request queue。

异步只在真实使用后确认 latency 有问题时再做。

---

# 12. 第一版建议模块结构

暂时只做一个文件：

```text
org-texmacs.el
```

不要一开始拆很多文件。

建议分为以下内部层。

---

## 12.1 Org source layer

### `org-texmacs--block-p`

职责：

```elisp
special-block?
&&
:type == "texmacs"
```

建议接受 Org node。

---

### `org-texmacs--block-source`

职责：

从：

```elisp
:contents-begin
:contents-end
```

读取 raw STM source。

要求：

* `buffer-substring-no-properties`；
* 不依赖 Org 对 block body 的 paragraph/plain-text parse。

---

## 12.2 TeXmacs worker layer

至少：

```elisp
org-texmacs--worker-start
org-texmacs--worker-stop
org-texmacs--worker-live-p
org-texmacs--worker-request
```

可能还需要内部变量：

```elisp
org-texmacs--worker-process
org-texmacs--worker-directory
org-texmacs--worker-socket
```

第一版可以简单设计为全局单 worker。

---

### worker start

大致：

```text
make temp directory
↓
socket-path
↓
make-process
  texmacs -H -s -x WORKER-SCHEME
↓
wait until socket file exists
```

真实配置中：

> 不要每次创建全新 fake HOME。

测试中 fake HOME 只是为了避免副作用。

正式 worker 应正常使用用户环境，除非后续明确需要 isolation。

---

### worker request

输入：

```elisp
SOURCE string
```

返回：

```elisp
TeXmacs stree
```

protocol 第一版可以保持很简单。

建议 response 使用一个 Scheme datum，例如：

```scheme
(ok REQUEST-ID TREE)
```

或：

```scheme
(error REQUEST-ID ...)
```

request 也可以是：

```scheme
(parse REQUEST-ID SOURCE)
```

但第一版如果是同步单请求连接，request-id 甚至可以暂时省掉。

---

# 13. AST layer

建议：

```elisp
org-texmacs--stree-to-org
org-texmacs--org-to-stree
```

虽然 `org->stree` 第一版的 public API 未必立即需要，但测试/后续 export 很有价值，建议保留。

必须遵守：

```text
TeXmacs stree 与 Org AST 不共享字符串对象
```

正向复制字符串；

反向：

```elisp
substring-no-properties
```

---

# 14. Public API

第一版最重要的 public function：

```elisp
org-texmacs-tree
```

建议接口：

```elisp
(org-texmacs-tree BLOCK)
```

返回：

```text
Org-compatible TeXmacs pseudo subtree
```

而不是 raw stree。

原因：

这是整个包最核心的 integration promise：

> TeXmacs structured tree 可以作为 Org-compatible foreign AST 使用。

如果某些调用者想要 raw stree，可以另设：

```elisp
org-texmacs-stree
```

但第一版也可以先只内部使用。

---

## 14.1 `org-texmacs-tree` 逻辑

伪代码：

```elisp
(defun org-texmacs-tree (block)
  (unless (org-texmacs--block-p block)
    (error ...))

  (let ((cached
         (org-element-cache-get-key
          block
          'org-texmacs-tree
          org-texmacs--cache-miss)))

    (if (not (eq cached org-texmacs--cache-miss))
        cached

      (let* ((source
              (org-texmacs--block-source block))
             (stree
              (org-texmacs--worker-request source))
             (tree
              (org-texmacs--stree-to-org stree)))

        (org-element-cache-store-key
         block
         'org-texmacs-tree
         tree)

        tree))))
```

注意：

当前测试显示 `ROBUST=t` 对“前文变化导致 block position shift”也不能保留 cache。

因此第一版建议：

```text
直接使用默认 ROBUST=nil
```

不要试图进一步优化。

---

# 15. 不应该在第一版实现的东西

明确暂缓：

```text
org-texmacs-mode
minor mode
font-lock
Scheme-mode fontification
preview
export backend
TeXmacs PDF/SVG rendering
inline formula syntax
实时 AST cache replacement
before-change-functions
after-change-functions
marker tracking
generation IDs
async worker requests
worker pool
多 worker
persistent AST database
external .tm files
custom DSL
Lean integration
统一数学知识 AST
```

这些都不应该进入最小实现。

---

# 16. 关于 inline / display math

长期需求明确包含：

> Org 文档中会有大量行内和行间公式。

目前 source prototype 只验证了：

```org
#+begin_texmacs
...
#+end_texmacs
```

也就是 block-level syntax。

**inline syntax 尚未设计。**

这应该留到 `org-texmacs-tree` 核心闭环完成之后。

不要现在为了 inline syntax 修改 Org parser。

后续可以单独研究：

* Org macro；
* link-like syntax；
* custom object；
* inline special syntax；
* 或其他对 source-level editing 影响最小的机制。

当前实现只针对 block。

---

# 17. 为什么当前方案符合“稳定 > 方便”

当前方案的稳定边界：

```text
Org source syntax
= Org 官方 special-block

TeXmacs source syntax
= 官方 Scheme/STM serialization

TeXmacs parser
= TeXmacs 自己

TeXmacs runtime
= 官方 -H headless mode

IPC
= Unix-domain socket

Org derived cache
= Org 官方 custom cache API

Org foreign AST
= 官方允许的 pseudo node
```

也就是说，基本没有发明新的持久化语法层。

唯一自己维护的是：

```text
TeXmacs stree
↔
Org pseudo subtree
```

而这个 adapter 非常机械。

这符合项目最核心的长期维护目标。

---

# 18. 已放弃 / 不应重复研究的路线

Codex 接手时请不要重新走以下路线，除非实现过程中发现新的硬性问题。

---

## 18.1 不要把 TeXmacs subtree 长期作为字符串 payload

用户明确不希望：

```elisp
(texmacs-fragment
 :source "(frac ...)")
```

成为 AST 的最终结构。

raw source 当然可以临时跨进程传输，但 derived AST 应保持真正的 tree。

---

## 18.2 不要注册所有 TeXmacs node type

不需要：

```text
frac
concat
with
sqrt
...
```

加入 Org 正式 element/object table。

pseudo node 已经验证足够。

---

## 18.3 不要实时替换 Org live cache

技术上已验证可行，但复杂度不值得。

---

## 18.4 不要自己写 STM parser

TeXmacs parser 已经可直接调用。

---

## 18.5 不要每次请求启动一个 TeXmacs

persistent headless worker 已验证。

---

## 18.6 不要使用 stdin worker

已验证不可按预想工作。

Unix socket 已验证可用。

---

## 18.7 不要默认信任 `stm-snippet->texmacs` 的成功状态

它会做 recovery。

应先严格 Guile read。

---

# 19. 建议 Codex 第一阶段具体任务

建议按以下顺序实施。

---

## Task 1：建立 `org-texmacs.el`

最小：

```elisp
;;; org-texmacs.el --- TeXmacs trees in Org -*- lexical-binding: t; -*-
```

以及：

```elisp
(require 'org-element)
(require 'cl-lib)
```

必要时再增加其他依赖。

---

## Task 2：实现纯函数 AST adapter

先实现并 ERT：

```elisp
org-texmacs--stree-to-org
org-texmacs--org-to-stree
```

测试：

```elisp
(with "mode" "math"
      (concat "x+" (frac "1" "2")))
```

round-trip。

还要验证：

```text
原 stree 不被 text properties 污染
pseudo tree parent links 正确
```

---

## Task 3：实现 Org block source API

实现：

```elisp
org-texmacs--block-p
org-texmacs--block-source
```

ERT 使用：

```org
#+begin_texmacs
(frac "1" "2")
#+end_texmacs
```

验证 raw source exact。

---

## Task 4：实现 worker

实现最小：

```elisp
org-texmacs--worker-start
org-texmacs--worker-stop
org-texmacs--worker-request
```

worker 使用：

```text
texmacs -H -s -x ...
```

Unix-domain socket。

建议 Scheme server：

```text
socket
bind
listen
loop
  accept
  read request
  catch
    strict Scheme read
    stm-snippet->texmacs
    tree->stree
  write response
  close client
```

不要立即异步。

---

## Task 5：实现 lazy public API

实现：

```elisp
org-texmacs-tree
```

逻辑：

```text
cache get
→ miss
→ block source
→ worker request
→ adapter
→ cache store
→ return
```

---

## Task 6：ERT 集成测试

至少覆盖：

1. 第一次访问 cache miss；
2. 第二次访问 cache hit，不再次 worker parse；
3. block body 修改后 cache miss；
4. TeXmacs syntax invalid 时 error；
5. 修复后下一次调用重新成功；
6. worker 一次 error 后仍然可处理下一次；
7. 多个 block 共用同一个 worker。

---

# 20. Codex 可以利用当前环境做的事情

用户希望转 Codex，正是为了可以直接调用环境中的：

```text
emacs
texmacs
```

因此实现过程中应优先实际运行：

```sh
emacs --batch ...
```

以及必要的 ERT。

不要只凭静态推理。

当前 Emacs 环境里已经确认这些 Org API 存在：

```elisp
org-element-parse-buffer
org-element-at-point
org-element-map
org-element-ast-map
org-element-lineage
org-element-create
org-element-adopt
org-element-set
org-element-set-contents
org-element-copy
org-element-cache-map
org-element-cache-store-key
org-element-cache-get-key
```

TeXmacs：

```text
TeXmacs 2.1.5
```

并支持：

```text
-H
-s
-x
```

---

# 21. 实现风格建议

优先：

```text
小 API
明确边界
少 hook
少 advice
少内部 Org API
无自定义 source DSL
无实时同步
```

第一版应尽可能是：

```text
Org element
↓
pure extraction
↓
worker request
↓
pure adapter
↓
Org custom cache
```

worker lifecycle 是唯一明显有状态的部分。

---

# 22. 当前核心设计一句话

如果需要用一句话概括当前结论：

> `org-texmacs` 应该把 Org 原生 `texmacs` special block 作为 canonical source element，把 TeXmacs 官方 STM/Scheme serialization 交给一个长期运行的 headless TeXmacs worker 解析，再把返回的 stree 机械转换成 Org-compatible pseudo subtree，并通过 Org 自己的 custom element cache 按需缓存；不实时维护 foreign AST，也不自行发明 DSL 或 parser。

---

# 23. Codex 开始工作前建议先做的事

先不要立即写完整包。

建议：

1. 查看当前 Emacs/Org 的确切版本；
2. 用源码确认 `org-element-cache-store-key/get-key` 的当前 docstring；
3. 确认 TeXmacs `-H` worker prototype 在当前 shell 环境仍能工作；
4. 建立最小 `org-texmacs.el`；
5. 从 AST adapter + ERT 开始；
6. 每加一层功能就运行 ERT；
7. 不提前实现 preview/export/inline syntax。

如果实现过程中发现当前 Org API 与以上测试行为有差异，应以**本机实际 Org 源码与运行测试**为准，再调整设计。

---

# 24. 当前最小成功标准

第一阶段完成的标准不是“Org 中已经能预览 TeXmacs”。

而是：

```elisp
(let ((block ...))
  (org-texmacs-tree block))
```

能够可靠返回：

```elisp
(frac <Org properties>
      "1"
      "2")
```

或者更复杂的：

```elisp
(with <Org properties>
      "mode"
      "math"
      (concat <Org properties>
              "x+"
              (frac <Org properties>
                    "1"
                    "2")))
```

满足：

* 来自真实 TeXmacs parser；
* TeXmacs worker 不需要重复启动；
* parent links 正确；
* source 不被修改；
* block body 修改后 cache 自动 miss；
* 第二次访问未修改 block 时 cache hit；
* invalid STM 不污染缓存；
* package 不需要任何实时 edit hook。

达到这里以后，再讨论：

```text
preview
export
inline syntax
editing UX
```

才比较合适。

# 前期验证结果汇总

本章只记录已经通过实际 Emacs / Org / TeXmacs 测试确认的事实，不讨论尚未实现的功能，也不把推测混入结论。

---

## 1. TeXmacs 命令行与 headless 模式

已经确认当前环境中的 TeXmacs 版本为：

```text
TeXmacs 2.1.5
```

命令行帮助中存在：

```text
-H         Run TeXmacs in headless mode
-s         Suppress information messages
-x [cmd]   Execute scheme command
-q         Shortcut for -x "(quit-TeXmacs)"
```

因此：

> TeXmacs 可以作为无 GUI 的后台进程运行，不需要启动编辑器窗口。

---

## 2. Emacs 可以直接调用 TeXmacs Scheme

已经测试：

```text
Emacs
→ 启动 texmacs
→ -x 执行 Scheme
→ Scheme 向 stdout 输出 marker
→ Emacs 成功取得输出
```

进程退出状态：

```text
status = 0
```

说明：

> Emacs → TeXmacs → Scheme → stdout 这一最基本调用链是可行的。

---

## 3. `stm-snippet->texmacs` 可以解析 STM/Scheme fragment

输入：

```scheme
(frac "a" "b")
```

经：

```scheme
stm-snippet->texmacs
```

得到真实 TeXmacs tree。

再通过：

```scheme
tree->stree
```

得到：

```scheme
(frac "a" "b")
```

复杂结构也已测试：

```scheme
(with "mode" "math"
  (concat "x+" (frac "1" "2")))
```

成功得到对应 stree：

```elisp
(with "mode" "math"
      (concat "x+" (frac "1" "2")))
```

因此：

> 不需要自己在 Emacs Lisp 中实现 TeXmacs STM parser。

---

## 4. TeXmacs stree 可以直接被 Emacs Lisp reader 读取

TeXmacs 的：

```scheme
tree->stree
```

输出的是普通 Scheme S-expression。

该输出已经通过：

```elisp
read-from-string
```

成功读成普通 Elisp data。

例如：

```scheme
(with "mode" "math"
  (concat "x+" (frac "1" "2")))
```

可以直接变成：

```elisp
(with "mode" "math"
      (concat "x+" (frac "1" "2")))
```

因此：

> TeXmacs 与 Emacs 之间不需要额外 JSON、XML 或自定义序列化协议。

---

## 5. `stm-snippet->texmacs` 是 recovery parser

已经实际测试过不完整输入。

例如：

```scheme
(frac "1" "2"
```

缺失右括号时，TeXmacs 仍可以恢复为：

```scheme
(frac "1" "2")
```

未闭合字符串：

```scheme
(frac "1" "2)
```

也不会简单以进程错误退出，而会生成 recovery tree。

因此：

> `stm-snippet->texmacs` 成功返回不能被视为 source 严格合法。

尤其不能把：

```text
process exit status = 0
```

解释成：

```text
STM syntax strictly valid
```

---

## 6. TeXmacs 内嵌 Guile `read` 可以做严格语法检查

同一个 TeXmacs runtime 中，Guile 的：

```scheme
read
```

已经测试可以识别未闭合字符串等真正的 Scheme reader error。

非法输入时，通过 `catch` 可以得到明确错误结果，而不是 recovery tree。

因此已经确认可以采用两阶段解析：

```text
source
  ↓
Guile read
  ↓
严格检查一个完整 Scheme datum
  ↓
stm-snippet->texmacs
  ↓
TeXmacs tree
```

也就是说：

> 严格 source validation 与 TeXmacs recovery parser 可以明确分层。

---

# Org source 与 AST

## 7. `#+begin_texmacs` 可以直接复用 Org 原生 `special-block`

输入：

```org
#+begin_texmacs
(frac "1" "2")
#+end_texmacs
```

使用：

```elisp
org-element-parse-buffer
```

可以取得：

```elisp
:type special-block
```

并且：

```elisp
(org-element-property :type block)
```

为：

```elisp
"texmacs"
```

因此：

> source-level block syntax 不需要自定义 Org parser。

---

## 8. Org 会继续把 special block body 当作普通 Org 内容解析

在上述 block 中，Org 的 AST 大致仍然包含：

```text
special-block
└── paragraph
    └── plain-text
```

也就是说：

> Org 并不会自动把 STM body 当成 TeXmacs tree。

因此这些 Org children 不应该作为 TeXmacs source 的 canonical representation。

---

## 9. `:contents-begin` / `:contents-end` 可以精确恢复原始 STM body

已经测试：

```elisp
(buffer-substring-no-properties
 (org-element-property :contents-begin block)
 (org-element-property :contents-end block))
```

可以得到原始：

```text
(with "mode" "math" (frac "1" "2"))
```

包括真实 source 中的换行。

因此：

> TeXmacs parser 的输入应该直接来自 buffer raw slice，而不是 Org 已解析后的 child nodes。

---

# TeXmacs stree 与 Org pseudo tree

## 10. 原始 TeXmacs stree 不能直接当 Org element tree 使用

TeXmacs stree 结构为：

```elisp
(TAG CHILD1 CHILD2 ...)
```

Org element node 结构为：

```elisp
(TYPE PROPERTIES CONTENTS...)
```

已经测试：

```elisp
(with "mode" "math" ...)
```

如果直接交给：

```elisp
org-element-contents
```

Org 会把：

```elisp
"mode"
```

当作 properties slot，从而 contents 从：

```elisp
"math"
```

开始。

因此：

> raw TeXmacs stree 与 Org pseudo syntax tree 之间必须有一层机械 adapter。

---

## 11. 未注册 pseudo node 可以被 Org traversal 正常访问

已经构造：

```elisp
(with nil
  "mode"
  "math"
  (concat nil
    "x+"
    (frac nil "1" "2")))
```

即使：

```text
with
concat
frac
```

都没有注册为正式 Org element/object type，

```elisp
org-element-map
```

仍然能够遍历它们。

实际得到过：

```elisp
(with concat frac)
```

因此：

> 不需要为全部 TeXmacs tag 修改 Org element type system。

---

## 12. `org-element-map` 使用 `TYPES=t` 时也会进入 pseudo subtree

已经测试包含：

```text
org-data
paragraph
texmacs-fragment
with
concat
frac
```

的混合 tree。

generic traversal 可以依次看到：

```text
org-data
paragraph
plain-text
texmacs-fragment
with
...
concat
...
frac
...
```

因此：

> TeXmacs pseudo nodes 可以自然参与 Org 的通用 AST traversal。

---

## 13. foreign subtree 也可以被当作 opaque boundary

通过：

```elisp
org-element-ast-map
```

配合：

```elisp
NO-RECURSION = 'texmacs-fragment
```

已经测试可以让 traversal：

```text
看到 texmacs-fragment
但不进入内部 with / concat / frac
```

因此：

> 调用者可以按需要选择“理解 TeXmacs 内部结构”或“只把它当 foreign fragment”。

---

## 14. `org-element-create` 可以创建未注册 pseudo node

已经实际测试：

```elisp
(org-element-create 'frac nil "1" "2")
```

以及多层递归：

```text
texmacs-fragment
└── with
    └── concat
        └── frac
```

都可以成功构造。

而且：

```elisp
:parent
```

关系正确建立。

因此：

> `org-element-create` 可以作为 stree → Org pseudo tree adapter 的基础构造 API。

---

## 15. `org-element-adopt` 只保证直接 child 的 parent

测试表明：

如果将一个已经具有多层内部结构的 raw tree 一次：

```elisp
org-element-adopt
```

到某个 root，

它会正确处理直接 child：

```text
with -> root
```

但不会递归自动修复：

```text
concat -> with
frac -> concat
```

因此：

> 不应该依赖 `org-element-adopt` 从顶层一次性建立完整 foreign subtree。

正确方案仍然是：

> 使用 `org-element-create` 自底向上递归构造。

---

## 16. `org-element-lineage` 可以跨越 native / foreign AST 边界

已经测试从：

```text
frac
```

向上调用：

```elisp
org-element-lineage
```

得到：

```elisp
(concat with texmacs-fragment paragraph section org-data)
```

因此：

> pseudo node 一旦正确建立 parent links，就可以自然接入 Org lineage 体系。

---

## 17. stree → Org adapter 必须复制字符串

最初测试发现，如果直接把 TeXmacs stree 中原有字符串传给：

```elisp
org-element-create
```

Org 会给这些字符串添加 text properties，例如：

```elisp
:parent
```

由于字符串对象是共享的，这会反过来污染原始 TeXmacs stree。

因此正向 adapter 必须使用：

```elisp
substring-no-properties
```

复制字符串。

这是已实际观察到的问题，不是理论推测。

---

## 18. Org pseudo tree → stree 也必须清除字符串 properties

反向 adapter 中已经测试使用：

```elisp
substring-no-properties
```

可以去掉 Org 加入的：

```text
:parent
以及其他 text properties
```

从而恢复干净 TeXmacs stree。

---

## 19. stree ↔ Org pseudo tree exact round-trip 已通过

真实 TeXmacs parser 返回：

```elisp
(with "mode" "math"
      (concat "x+" (frac "1" "2")))
```

经过：

```text
stree
→ Org pseudo tree
→ stree
```

结果：

```text
roundtrip-exact = t
```

同时确认：

```text
原始 stree 不被 Org properties 污染
反向结果也没有 Org properties
```

因此：

> 当前机械 adapter 已在真实 TeXmacs 输出上验证成立。

---

# Org tree manipulation

## 20. `org-element-copy TREE t` 可以深复制 pseudo subtree

已经验证：

```elisp
(org-element-copy tree t)
```

会复制：

```text
texmacs-fragment
with
concat
frac
```

而不是共享同一个 child object。

---

## 21. `org-element-copy` 不会自动重建全部 `:parent`

测试 native Org nodes 与 pseudo nodes 后都发现：

> copy 后 child 的 `:parent` 不保证被完整重建。

这是 Org 自己的普遍语义，不是 pseudo tree 的特殊缺陷。

---

## 22. `org-element-set-contents` 是低层 replacement API

测试表明：

```elisp
org-element-set-contents
```

会替换 contents，

但不会自动：

```text
修正新 child 的 :parent
清除旧 child 的 stale :parent
```

因此：

> 它不应该被误认为完整的 AST ownership/reparent API。

---

## 23. `org-element-set` 会原地修改 OLD node

已经测试：

```elisp
(org-element-set old replacement)
```

之后：

```text
最终插入树中的对象
=
原 old object
```

而不是 replacement object 本身。

实际结果：

```text
inserted-is-original-block       t
inserted-is-replacement-fragment nil
```

因此：

> `org-element-set` 的核心语义是以 OLD object identity 为锚进行原地替换。

---

## 24. `org-element-set` 可以正确重设新 child 的 parent

虽然 replacement root 本身不会成为最终对象，

但是 replacement 中的新 child 会被正确 reparent 到原 OLD root。

这已经在：

```text
special-block → texmacs-fragment
```

测试中确认。

---

## 25. detached old child 会留下 stale parent

无论 native Org tree 还是 pseudo tree，

被 replacement 移除的旧 child：

```text
仍可能保留指向旧 parent 的 :parent
```

因此：

> detached node 不应被继续当作 canonical AST 使用。

这同样不是 TeXmacs 特有问题。

---

# 实时 live cache 实验

## 26. `org-element-parse-buffer` 返回的是 snapshot tree

已经测试：

对：

```elisp
(org-element-parse-buffer)
```

返回的 tree 做 mutation，

并不会影响之后：

```elisp
org-element-at-point
```

看到的 live source/cache element。

因此：

> full parsed AST 与 Org live element cache 是两套不同对象。

---

## 27. `org-element-at-point` 返回的是 live cached element

连续两次：

```elisp
org-element-at-point
```

在未失效时可以返回同一 cached object。

对这个 object 原地 retag：

```text
special-block
→ texmacs-fragment
```

之后再次：

```elisp
org-element-at-point
```

可以看到：

```text
texmacs-fragment
```

因此：

> live element cache 确实可以被第三方原地修改。

---

## 28. source 编辑会让 pseudo-mutated cached node 被重新解析

已经测试：

先把 live cached：

```text
special-block
```

改成：

```text
texmacs-fragment
```

然后真实修改 block source。

下一次：

```elisp
org-element-at-point
```

看到的重新变成：

```text
special-block
```

而且不再是同一 object。

说明：

> Org source 始终是 canonical truth；cache invalidation 后会重新从 source 构造 element。

---

## 29. after-change hook 可以在 Org cache invalidation 之后重新转换

已经测试 buffer-local：

```elisp
after-change-functions
```

在真实编辑后运行时，

可以看到新解析出来的：

```text
special-block
```

并再次把它变成：

```text
texmacs-fragment
```

多次连续编辑也能工作。

因此：

> 实时 foreign AST synchronization 技术上是可行的。

---

## 30. 在 block body 内编辑时 `org-element-at-point` 返回 paragraph

当 point 位于：

```scheme
(frac "1" "2")
```

内部时：

```elisp
org-element-at-point
```

通常返回：

```text
paragraph
```

而不是 outer：

```text
special-block
```

但：

```elisp
org-element-lineage
```

可以向上找到：

```text
special-block :type "texmacs"
```

因此：

> 如果走实时 hook 路线，不能只看 at-point node 本身。

---

## 31. delimiter line 上可以直接看到 special-block

如果 point 位于：

```org
#+begin_texmacs
```

或：

```org
#+end_texmacs
```

delimiter line，

```elisp
org-element-at-point
```

可以返回对应：

```text
special-block
```

---

## 32. 破坏 begin delimiter 会使整个 block 消失

例如修改：

```org
#+begin_texmacs
```

使其不再合法，

after-change 后：

```elisp
org-element-at-point
```

只能看到普通：

```text
paragraph
```

lineage 中也找不到：

```text
special-block
```

因此：

> 实时同步若依赖 after-change，仅检查“现在存在的 block”不足以表示 block deletion/breakage。

---

## 33. before-change 可以看到修改前存在的 block

对应 delimiter break 测试中：

```text
before-change
→ 能找到旧 texmacs block

after-change
→ 已经找不到
```

因此：

> before/after 两阶段可以覆盖 block destruction。

---

## 34. 修复 delimiter 后 block 可以重新出现

从非法 delimiter 修复为：

```org
#+begin_texmacs
```

之后：

```elisp
org-element-at-point
```

再次能够找到：

```text
special-block
```

说明：

> block lifecycle 可以由 Org parser 自己恢复。

---

## 35. change range 不能只检查两个 endpoint

已经测试一种修改范围：

```text
beg 在普通文本
end 在 TeXmacs block
```

另一个测试更极端：

```text
beg 普通文本
end 普通文本
```

但整个 range 中间完整覆盖两个 TeXmacs blocks。

因此：

> 实时更新不能只通过 change range 两端判断受影响 block。

必须做真正 interval overlap。

---

# `org-element-cache-map` 实验

## 36. `org-element-cache-map` 可以看到 pseudo-mutated cached node

live cached special-block 被修改为：

```text
texmacs-fragment
```

以后：

```elisp
org-element-cache-map
```

能够返回这个：

```text
texmacs-fragment
```

因此：

> cache-map 读取的是当前 live element cache，而不是重新 parse source AST。

---

## 37. query range 完全位于 fragment 内部时仍能返回 enclosing fragment

测试：

```text
query-start > block-begin
query-end   < block-end
```

`org-element-cache-map` 仍会返回包围该区域的：

```text
texmacs-fragment
```

因此：

> cache-map 可以用于“找所有与 change interval 相交的 outer element”。

---

## 38. query range 跨多个 TeXmacs blocks 可以返回多个 fragment

已经测试：

```text
query 从第一个 fragment 内部
到第二个 fragment 内部
```

返回两个 fragment。

---

## 39. 即使 query 两端都是普通 paragraph，也可以找到中间两个 fragment

已经测试：

```text
beg-node = paragraph
end-node = paragraph
```

但 range 中覆盖两个 TeXmacs blocks。

`org-element-cache-map` 仍返回两个 fragment。

因此：

> cache-map 比 endpoint lineage 更适合 interval-based 实时更新。

---

## 40. zero-width query 也可以找到 enclosing fragment

测试：

```text
[POS, POS]
```

其中 POS 位于 TeXmacs fragment 内，

仍然能够返回：

```text
texmacs-fragment
```

---

## 41. 新插入的 special-block 可以通过 cache-map 被发现

在 after-change 中，新 source 刚刚形成：

```org
#+begin_texmacs
...
#+end_texmacs
```

不需要事先显式：

```elisp
org-element-at-point
```

`org-element-cache-map` 就可以触发/取得新的：

```text
special-block
```

---

## 42. cache-map callback 中可以直接把新 block 转换为 pseudo fragment

已经测试：

```text
after-change
→ cache-map
→ callback 找到 special-block
→ 原地转成 texmacs-fragment
```

之后：

```elisp
org-element-at-point
```

可以看到：

```text
texmacs-fragment
```

---

## 43. `:restrict-elements` 对 cache-map 很重要

没有指定：

```elisp
:restrict-elements
```

时，

block body 编辑后曾出现：

```text
旧 pseudo fragment 被 invalidated
新 outer special-block 没有被 transform
```

加入：

```elisp
:restrict-elements
'(special-block texmacs-fragment)
```

之后重复编辑成功。

因此：

> 如果未来重新考虑实时方案，cache-map 应显式限制目标 outer element type。

---

## 44. 同一套 restricted cache-map 也能处理 delimiter break

begin delimiter 被破坏后：

```text
before → 能 map 到 texmacs-fragment
after  → map 结果为空
```

说明：

> cache-map 足以统一描述 block 存在/消失等生命周期变化。

---

# 实时 TeXmacs parser 集成

## 45. real TeXmacs parse 已经接入 after-change prototype

已经做过完整测试：

source 初始：

```scheme
(frac "1" "2")
```

编辑为：

```scheme
(frac "3" "2")
```

实际流程：

```text
Org edit
→ cache invalidation
→ after-change
→ 找 special-block
→ 取 raw body
→ 调真实 TeXmacs parser
→ stree
→ pseudo subtree
→ live cache replacement
```

结果：

```text
parse-count = 2
before = (frac "1" "2")
after  = (frac "3" "2")
updated = t
final-type = texmacs-fragment
```

因此：

> “实时保持真实 TeXmacs AST 驻留在 Org live cache”这条路线不是理论构想，而是已经做通过的 prototype。

---

# Persistent worker

## 46. 每次启动新 TeXmacs 的 startup 测试包含额外 setup 成本

早期测试为了隔离环境，每次都创建新的 fake HOME。

TeXmacs 因此会输出：

```text
Installation completed successfully !
I will now start up the editor
```

这意味着：

> 早期观察到的启动成本被 fresh HOME setup 明显放大。

但即使如此，避免每次请求重新启动完整 TeXmacs 仍然是合理方向。

---

## 47. headless TeXmacs 可以长期存活

测试使用：

```scheme
sleep
```

让：

```text
texmacs -H
```

保持运行。

Emacs 检查：

```text
process-live = t
process-status = run
```

因此：

> 可以建立 persistent TeXmacs runtime。

---

## 48. TeXmacs `-x` 环境中的 stdin 不适合作为当前 IPC

尝试：

```scheme
read
```

以及：

```scheme
open-input-file "/dev/stdin"
```

配合 Emacs：

```elisp
process-send-string
```

没有成功完成 request/response。

因此：

> 当前方案不应再以 TeXmacs stdin 作为 worker IPC。

---

## 49. TeXmacs 内嵌 Guile 有 Unix socket 所需 API

已经实际查询：

```scheme
socket
bind
listen
accept
close
close-port
force-output
AF_UNIX
PF_UNIX
SOCK_STREAM
```

全部可用。

因此：

> 不需要额外 Scheme networking library。

---

## 50. Emacs 可以连接 TeXmacs 创建的 Unix-domain socket

TeXmacs worker：

```text
bind
listen
accept
```

创建 local socket。

Emacs 使用：

```elisp
make-network-process
:family 'local
```

成功连接。

---

## 51. Unix socket 单请求已成功

Emacs 发送：

```scheme
(frac "1" "2")
```

TeXmacs worker 解析并返回：

```elisp
(frac "1" "2")
```

client connection 关闭后：

```text
worker 仍然存活
```

Emacs 可能看到：

```text
connection broken by remote peer
```

这是 server 正常关闭该 client socket 的表现，不代表 worker crash。

---

## 52. 同一个 worker 可以连续处理多个请求

TeXmacs worker 内维护一个 Scheme counter。

第一次请求返回：

```elisp
(1 (frac "1" "2"))
```

第二次请求返回：

```elisp
(2 (sqrt "x"))
```

且：

```text
worker-live = t
```

因此已经证明：

> 请求 1 和请求 2 确实由同一个长期运行的 TeXmacs/Guile runtime 处理。

---

## 53. 单请求错误不会杀死 worker

worker 每个 request 外层使用：

```scheme
catch
```

测试：

第一个 malformed request 返回：

```elisp
(error 1)
```

第二个合法 request 随后返回：

```elisp
(ok 2 (sqrt "x"))
```

并且：

```text
worker-live = t
```

因此：

> worker 可以做 request-local error isolation。

---

# Org custom derived cache

## 54. `org-element-cache-store-key` / `get-key` 可以存 TeXmacs derived AST

已经测试：

```elisp
(org-element-cache-store-key
 block
 'org-texmacs-test-tree
 '(frac "1" "2"))
```

然后：

```elisp
(org-element-cache-get-key
 block
 'org-texmacs-test-tree
 'missing)
```

返回：

```elisp
(frac "1" "2")
```

因此：

> Org custom element cache 足以保存 derived TeXmacs tree。

---

## 55. block body 修改后 custom cache 自动失效

初始：

```scheme
(frac "1" "2")
```

缓存：

```elisp
(frac "1" "2")
```

然后 source 修改为：

```scheme
(frac "1" "3")
```

重新取得当前 block 后：

```elisp
org-element-cache-get-key
```

返回：

```elisp
missing
```

因此：

> TeXmacs block 自身内容变化时，不需要我们自己通过 after-change 去 invalidate derived cache。

---

## 56. 修改 block 前方普通文本，也会让默认 custom cache 丢失

测试：

```text
Before
```

改为：

```text
Before changed
```

TeXmacs block body 完全没变。

block 位置：

```text
old-begin = 9
new-begin = 17
```

但：

```elisp
:after missing
```

因此：

> 默认 custom cache invalidation 比“仅当 block body 改变才失效”更粗。

---

## 57. `ROBUST=t` 也没有保留这个 cache

同样的“只修改 block 前方文字”测试中：

```elisp
(org-element-cache-store-key
 block
 key
 value
 t)
```

仍然得到：

```text
after = missing
preserved = nil
```

因此当前环境中已经确认：

> `ROBUST=t` 不能提供一个随逻辑 block 位置移动而持续存在的稳定 identity/cache。

---

## 58. custom cache 应被视为 best-effort lazy cache

根据上述测试，目前能依赖的行为是：

```text
未发生导致 element cache replacement 的变化
→ custom derived data 可复用

相关 source/cache 被 Org 判定失效
→ custom key 可能消失
```

因此：

> 不应把 custom cache 当作 TeXmacs block 的稳定身份系统。

---

# 当前由验证结果导出的实现结论

## 59. 实时 live foreign AST 方案已经证明“可行”，但不建议作为第一版

前面的实验已经证明：

```text
技术上完全可以
```

但需要同时承担：

```text
before-change
after-change
change range overlap
cache-map
cache invalidation
pseudo node replacement
position tracking
异步 stale response
worker lifecycle
```

因此当前判断是：

> 这不是可行性问题，而是工程复杂度与收益不匹配。

---

## 60. lazy derived AST 模型已经得到关键验证

当前最有价值的已验证闭环是：

```text
Org native special-block
        ↓
raw STM source
        ↓
真实 TeXmacs parser
        ↓
stree
        ↓
Org-compatible pseudo tree
        ↓
Org custom derived cache
```

其中每一条边都已经单独经过实际测试。

因此下一步不需要继续证明总体可行性，而可以开始把已有 prototype 整理成正式实现。

---

## 61. 当前还没有验证或实现的内容

以下不能写成“已经完成”：

```text
正式 org-texmacs.el package
完整 ERT suite
production worker lifecycle
worker restart
Emacs 退出时 cleanup
stale socket cleanup
多 buffer 并发
async requests
inline syntax
preview
export
font-lock
Scheme editing UX
TeXmacs rendering
```

这些属于后续实现工作。

---

## 62. 当前最重要的总体结论

前期实验已经确认：

1. Org 原生 special block 足以作为 source boundary；
2. raw STM body 可以精确取得；
3. TeXmacs 自己可以可靠生成真实 tree/stree；
4. Scheme serialization 可以直接跨 Emacs/TeXmacs 进程边界；
5. stree 可以机械转换成 Org-compatible pseudo subtree；
6. pseudo subtree 可以被 Org traversal 与 lineage 正常处理；
7. 不需要注册全部 TeXmacs node type；
8. persistent headless TeXmacs worker 可行；
9. Unix-domain socket IPC 已经真实打通；
10. request error isolation 已经真实打通；
11. Org custom cache 可以保存 derived TeXmacs AST；
12. block body 修改时 cache 可以由 Org 自动失效；
13. custom cache 的失效粒度较粗，因此只能视为 best-effort cache；
14. 实时 foreign AST synchronization 已证明可行，但第一版没有必要承担这套复杂度；
15. 当前已经具备开始编写正式 `org-texmacs.el` 的充分基础。

---

## 63. 正式实现进度与新增验证（2026-09-11）

本节更新前述 prototype 阶段的状态；先前实验记录仍保留。

已经实现并通过 Nix ERT/package-lint 的模块：

* `org-texmacs-core.el`：错误类型、能力检查和 TeXmacs 程序配置。
* `org-texmacs-ast.el`：stree 与 Org pseudo tree 双向转换。
* `org-texmacs-source.el`：识别 TeXmacs special block，按内容范围提取 source。
* `org-texmacs-worker.el` / `org-texmacs-worker.scm`：共享的 lazy headless worker，
  Unix socket、同步单请求连接、递增请求编号、严格单 datum 校验及错误隔离。

worker 测试确认：多个 buffer 顺序访问复用进程；非法 STM 后同一进程仍可处理
下一次请求；进程退出后可以重启；启动和请求超时会清理进程与 socket 目录；
重复 stop 安全。重入请求被拒绝，尚不支持并发队列。退出清理使用
`kill-emacs-hook`；未增加 Org 实时编辑 hook。

### Scheme / Elisp 字符串边界的新事实

前期“Scheme write 输出可直接交给 Emacs read”的验证仅覆盖了普通公式字符串。
新增控制字符测试发现 Guile 的十六进制转义与 Emacs reader 的终止规则不同，
可能将后续十六进制字符一起读入，改变字符串内容。

正式服务端因此使用 `org-texmacs-write-elisp` 输出响应：字符串保留字面字符，
转义双引号和反斜杠；symbol 字符也做 Elisp reader 转义。仍然传输结构化
S-expression，STM 解析仍由严格 Guile read 和 TeXmacs 官方 parser 完成。
换行、tab、控制字符、Unicode、引号和反斜杠的往返测试已通过。

### Nix 运行依赖

`packages.default` 在构建时将 `org-texmacs-program` 默认值替换为
`pkgs.texmacs` 的绝对可执行路径，并安装 Scheme 服务文件。ERT 已验证安装后
即使 Emacs 的 `exec-path` 为空，worker 也能启动和解析。非 Nix 源码默认仍用
`texmacs`，允许用户设置 `org-texmacs-program`。

真实 worker 测试在 Nix checks 和终端沙箱外的 `emacs-twist` 中通过。
本会话终端沙箱内的直接 socket 测试曾等待超时；不要据此重复否定已验证的 IPC。
测试隔离 HOME 和 TEXMACS_HOME_PATH；正式 worker 继续使用用户环境。

## 64. Lazy public API 闭环（2026-09-11）

`org-texmacs-tree` 已实现：验证 block，查询 Org custom cache；miss 时提取
raw source、调用共享 worker、转换成 Org pseudo tree，再存入默认非 robust
cache。返回的根节点不接入 block 的 children；block 保持原生 special-block。
调用方应把返回的缓存对象视为只读，并在编辑后重新取得当前 buffer 的 block。

新增真实 worker 集成 ERT 已确认：

* 首次访问解析，第二次访问返回同一缓存对象且不再请求 worker。
* body 编辑后 cache miss，并返回新公式的 pseudo tree。
* 非法 STM 连续访问均报错且不写入缓存，修复后原 worker 可以继续解析。
* 多个 block 共用一个 worker，并各自保持缓存。
* pseudo tree 可以使用 Org traversal，children 的 parent links 正确。
* 解析不修改 buffer 文本、字符修改计数或 point；block 类型保持不变。
* 前文插入导致位置变化后，重新取得 block 仍可得到正确结果。

同步等待进程期间也可能运行编辑 buffer 的 timer。因此一次 cache miss 会记录
字符修改计数，worker 返回后确认原 buffer 仍存活且文本未变化，才转换并缓存。
若检查失败则 signal `org-texmacs-error`。这是单次同步调用的结果校验，不是
跨请求 block identity 或实时同步机制；相应拒绝旧结果的测试已通过。

当前 Nix 完整 checks（29 个 ERT、package-lint）通过，验证平台为 x86_64-linux。
第 24 节的最小 AST integration 闭环已达成。
preview、export、inline syntax 和编辑辅助仍未实现。

## 65. README 使用文档（2026-09-11）

README 已补齐源码加载、Nix 环境与运行依赖、Org block 语法、公开 API、
缓存对象约定、worker 生命周期、错误类型与开发检查命令。
其中命名为 `example-tree` 的示例已从 README 提取并在隔离的真实 TeXmacs
环境中使用 `emacs-twist` 执行，返回 `((with concat frac) t)`。
文档节点的 Nix 完整 checks 和独立包构建均通过。

此前规划的七个实现节点均已完成；继续新增功能前应另行确定范围。




# 行内 TeXmacs 公式设计交接文档

## 0. 目的

当前 `org-texmacs` 已经实现 block-level TeXmacs source，例如：

```org
#+begin_texmacs
(frac "1" "2")
#+end_texmacs
```

下一步需要考虑段落内部的 TeXmacs 数学内容，也就是类似传统 Org / LaTeX 中：

```org
$x^2$
```

这种 inline math。

本节只讨论：

> **如何在 Org source 中识别行内 TeXmacs 公式。**

暂时不讨论：

* preview；
* export；
* fontification；
* 编辑辅助；
* 光标行为；
* inline AST 缓存；
* 实时重解析。

---

# 1. 当前建议的 source syntax

当前最推荐的方案是：

```org
这是一个行内公式 (math (frac "1" "2"))。
```

即：

> **直接使用 TeXmacs 自己的 `(math ...)` tree 作为行内公式 source。**

不另外增加：

```text
$...$
$$...$$
@@texmacs:...@@
```

之类的 delimiter。

---

# 2. 为什么不建议使用 `$...$` / `$$...$$`

Org 已经把：

```org
$x$
```

以及：

```org
$$x$$
```

等形式纳入 LaTeX fragment 语法。

如果重新规定：

```org
$ (math ...) $
```

或：

```org
$$ (frac "1" "2") $$
```

表示 TeXmacs，会产生两个问题。

第一：

> 与 Org 原生 LaTeX syntax namespace 冲突。

第二：

> 外层 delimiter 没有提供新的结构信息。

因为：

```scheme
(math ...)
```

本身已经是一个完整、self-delimiting 的 S-expression。

所以：

```text
$$ (math ...) $$
```

实际上重复表达了同一个边界。

---

# 3. 为什么选择 `(math ...)`

采用：

```scheme
(math ...)
```

有几个重要优点。

---

## 3.1 source 保持 TeXmacs-native

整个项目当前的重要设计原则之一是：

> Org 文件中保存的 TeXmacs source 应尽量直接使用 TeXmacs 官方 serialization，而不是另造一套 DSL。

block 中目前就是直接保存 STM/Scheme：

```org
#+begin_texmacs
(with "mode" "math" ...)
#+end_texmacs
```

inline 使用：

```scheme
(math ...)
```

延续了同一个原则。

---

## 3.2 namespace 明确

如果规定段落中的任意 S-expression 都可能是 TeXmacs：

```org
这里有一个 Lisp 例子 (foo bar)。
```

会产生明显歧义。

但如果只识别：

```scheme
(math ...)
```

那么：

```text
(math ...)
```

本身就是明确的 TeXmacs inline namespace。

因此第一版只应识别：

```scheme
math
```

不要尝试识别所有：

```scheme
(frac ...)
(sqrt ...)
(concat ...)
...
```

---

## 3.3 TeXmacs 自己已经表达了“这是数学”

在 tree 层：

```scheme
(math ...)
```

已经携带：

```text
regular text
→ math mode
```

的语义。

因此 Org 不需要额外再维护一个：

```text
inline-math = true
```

之类的平行标记。

---

# 4. 关键问题不是 TeXmacs parser，而是 source boundary

当前底层实际上已经可以处理任意 TeXmacs source string：

```text
source string
    ↓
persistent TeXmacs worker
    ↓
strict Scheme validation
    ↓
stm-snippet->texmacs
    ↓
stree
    ↓
Org pseudo subtree
```

因此 inline 的主要新问题只有：

> **如何从一个普通 Org paragraph 中找出 `(math ...)` 的起点和终点。**

例如：

```org
由 (math (frac "1" (concat "x+" (sqrt "y")))) 可以得到……
```

我们希望得到逻辑结构：

```text
paragraph
├── plain-text
│   "由 "
├── texmacs-inline
│   source = (math ...)
└── plain-text
    " 可以得到……"
```

---

# 5. 不应该用 regexp 匹配整个表达式

例如不能设计成：

```regexp
(math .*?)
```

或类似模式。

原因是 TeXmacs STM 是嵌套 S-expression。

例如：

```scheme
(math
 (concat
  "x+"
  (frac
   "1"
   (concat
    "y+"
    (sqrt "z")))))
```

单纯 regexp 很难正确处理任意层数嵌套。

字符串内部还可能包含括号：

```scheme
(math
 (concat
  "f(x)"
  "="
  ...))
```

因此：

> regexp 只能用于识别候选起点，不能承担完整 boundary parsing。

---

# 6. 推荐的两阶段识别

当前建议：

```text
阶段 1：轻量 lexical dispatch
阶段 2：S-expression structural scan
```

---

## 6.1 第一阶段：寻找 `(math`

首先在 paragraph 中寻找：

```text
(math
```

候选起点。

这一层可以使用：

* literal search；
* 简单 regexp；
* Org object parser 自己的 trigger regexp。

例如只需确认当前位置是：

```text
(
m
a
t
h
```

并且 `math` 后面是合法 token boundary：

```text
space
newline
)
```

等。

这里的目标仅仅是：

> “这里可能开始一个 TeXmacs inline math object。”

---

## 6.2 第二阶段：结构化找到匹配右括号

候选起点之后，不应该继续用 regexp。

而应该使用 Emacs 已有的 sexp scanning 机制，例如：

```elisp
scan-sexps
```

从开头的：

```text
(
```

寻找整个 balanced S-expression 的终点。

例如：

```scheme
(math
 (frac
  "1"
  (concat "x+" (sqrt "y"))))
```

`scan-sexps` 应找到最后一个：

```text
)
```

而不是内部 `frac` / `concat` / `sqrt` 的右括号。

---

# 7. regexp 在这里的准确角色

因此整个识别机制可以概括为：

```text
regexp / literal matching
        ↓
识别 candidate start

scan-sexps
        ↓
识别 balanced source span

TeXmacs worker
        ↓
判断 source 是否真正是合法 TeXmacs STM
```

即：

> **regexp 是 dispatcher，不是 parser。**

---

# 8. 不建议用 Elisp `read-from-string` 定义合法性

早期曾考虑：

```elisp
read-from-string
```

因为它可以同时：

* parse；
* 返回 datum；
* 返回 consumed length。

这在 prototype 中可能很方便。

但正式设计中不建议让它决定 TeXmacs source 是否合法。

原因是：

> canonical syntax 是 TeXmacs / Guile Scheme，而不是 Emacs Lisp。

如果用：

```elisp
read-from-string
```

作为正式 syntax validator，就会隐式增加一个要求：

```text
inline TeXmacs source
必须同时是合法 Emacs Lisp reader input
```

这没有必要。

当前更合理的职责划分是：

```text
Emacs:
只负责 structural boundary

TeXmacs / Guile:
负责真正 syntax validity
```

---

# 9. `scan-sexps` 的职责也必须保持有限

`scan-sexps` 应只回答：

> “从这个左括号开始，balanced expression 在哪里结束？”

不应该把：

```text
scan-sexps 成功
```

解释为：

```text
这是合法 TeXmacs
```

例如：

```scheme
(foo (bar baz))
```

可能是 perfectly balanced S-expression，但并不是我们允许的 inline TeXmacs math。

因此还要继续验证：

```text
root tag == math
```

以及让 worker 进行真正 Scheme / TeXmacs parse。

---

# 10. 建议的完整 inline 识别流程

例如 source：

```org
这里有 (math (frac "1" "2")) 一个公式。
```

解析逻辑建议为：

```text
扫描 paragraph
    ↓
发现 "(math"
    ↓
检查 math token boundary
    ↓
从 "(" 调用 scan-sexps
    ↓
取得完整 span
    ↓
raw source =
(math (frac "1" "2"))
    ↓
交给现有 worker
    ↓
strict Guile read
    ↓
stm-snippet->texmacs
    ↓
tree->stree
    ↓
Org-compatible pseudo subtree
```

---

# 11. 第一版只认 root `(math ...)`

第一版建议严格限制：

```scheme
(math ...)
```

才是 inline TeXmacs。

以下不要识别：

```scheme
(frac "1" "2")
```

```scheme
(sqrt "x")
```

```scheme
(with "mode" "math" ...)
```

哪怕这些从 TeXmacs 角度可以产生数学内容。

原因是：

> source-level namespace 应该明确，而不是猜测表达式是否“看起来像数学”。

所以推荐：

```text
block:
允许任意 TeXmacs tree

inline:
只允许 root tag = math
```

---

# 12. block 与 inline 的职责分工

建议最终形成：

```org
普通正文里的数学用 (math ...)。

复杂独立结构使用：

#+begin_texmacs
(...)
#+end_texmacs
```

因此：

```text
inline
→ math-specific

block
→ generic TeXmacs container
```

这是一个很清晰的分工。

---

# 13. inline object 的逻辑 AST

如果以后真正接入 Org parser，建议逻辑上形成：

```text
paragraph
├── plain-text
├── texmacs-inline
└── plain-text
```

而：

```text
texmacs-inline
```

内部真正的 TeXmacs tree仍然可以继续是 derived data。

也就是说不要立即变成：

```text
paragraph
├── plain-text
├── math
│   └── frac
└── plain-text
```

并实时维护。

更符合当前整体架构的仍然是：

```text
texmacs-inline source object
        │
        │ lazy
        ▼
derived TeXmacs pseudo subtree
```

---

# 14. 不要重新引入实时 AST 同步

inline 支持不应成为重新走回：

```text
after-change
→ 立即 TeXmacs parse
→ 实时重建所有 inline AST
```

路线的理由。

第一版仍然应该遵循：

```text
Org source
= canonical

TeXmacs tree
= lazy derived data
```

也就是说：

> 先让 Org 正确识别 inline source span；真正 TeXmacs parse 继续按需进行。

---

# 15. 第一版 parser 应只解决 boundary

因此 inline parser 第一阶段的目标应该非常窄：

输入：

```org
A (math (frac "1" "2")) B
```

输出逻辑结构：

```text
plain-text: "A "

texmacs-inline:
  begin = ...
  end = ...
  raw-source = "(math (frac \"1\" \"2\"))"

plain-text: " B"
```

做到这里就已经成功。

暂时不用在 parser 内：

* 启动 worker；
* 取得 TeXmacs stree；
* preview；
* rendering。

---

# 16. 需要特别测试的 lexical cases

正式实现前应至少测试以下情况。

---

## 16.1 普通情况

```org
A (math "x") B
```

应识别一个 inline object。

---

## 16.2 嵌套 expression

```org
A (math (frac "1" (sqrt "x"))) B
```

必须识别完整 expression，而不是停在第一个 `)`。

---

## 16.3 字符串中包含括号

```org
A (math (concat "f(x)" "=" "1")) B
```

括号字符串不应破坏 boundary detection。

---

## 16.4 多个公式

```org
A (math "x") B (math "y") C
```

应识别两个独立 inline objects。

---

## 16.5 普通 Lisp expression

```org
这里提到 (foo bar)。
```

不能识别为 TeXmacs。

---

## 16.6 类似前缀

```org
(mathjax ...)
```

不能误识别为：

```scheme
(math ...)
```

必须检查 symbol boundary。

---

## 16.7 不完整表达式

```org
A (math (frac "1" "2") B
```

不能把后续整个 paragraph 吞掉。

当前可以：

```text
scan-sexps failure
→ 作为普通 text
```

或产生 parser-level incomplete object。

第一版更推荐保守地：

> 识别失败就继续当普通文本。

---

## 16.8 非法但 balanced TeXmacs source

例如：

```org
A (math (not-a-valid-texmacs-form ...)) B
```

Org boundary 层仍然可以成功识别。

是否合法由：

```text
worker
```

决定。

---

# 17. syntax table 风险

`scan-sexps` 依赖当前 buffer 的 syntax table。

因此需要实测：

* `"` string；
* `\"` escape；
* `\\`；
* newline；
* Scheme comments；
* TeXmacs STM 中可能出现的其他 reader syntax。

不要直接假设：

```text
Emacs Lisp syntax table
==
Guile Scheme reader syntax
```

两者完全一致。

当前设计只需要它们在：

```text
balanced parentheses + quoted strings
```

这部分足够一致即可。

如果发现 TeXmacs 实际 STM syntax 超出了 `scan-sexps` 能可靠覆盖的范围，再考虑更专门的 scanner。

---

# 18. 不建议一开始支持 Scheme comment

如果 inline source 中出现：

```scheme
(math
 ;; comment
 (frac "1" "2"))
```

是否应支持，需要另行验证 Org mode syntax table 与 Scheme reader 对 comment 的差异。

第一版没有必要以 comment support 为目标。

如果：

```text
scan-sexps
```

对实际需要的 TeXmacs STM 已足够，就保持简单。

---

# 19. 不应自己实现完整括号 parser

如果 `scan-sexps` 可用，就不要自己写：

```text
paren-depth++
paren-depth--
inside-string
escaped
...
```

这样的 scanner。

原因是：

* 容易产生 escape bugs；
* 容易遗漏 syntax-table edge cases；
* Emacs 已经提供成熟的 sexp scanning infrastructure。

只有在实测证明 `scan-sexps` 与 TeXmacs STM syntax 不兼容时，才考虑替代方案。

---

# 20. 当前推荐实现边界

未来代码可以大致分成：

```text
org-texmacs-inline.el
```

或先放入现有 source layer。

可能需要的内部功能：

```elisp
org-texmacs--inline-looking-at-p
org-texmacs--inline-end
org-texmacs--inline-source
```

其中：

```text
--inline-looking-at-p
```

只负责：

```text
(math token boundary
```

```text
--inline-end
```

只负责：

```text
scan-sexps
```

```text
--inline-source
```

只负责：

```text
buffer-substring-no-properties
```

真正：

```text
source → TeXmacs tree
```

仍然复用现有 worker 和 AST adapter。

---

# 21. 不要复制 block implementation

inline 与 block 的 source boundary 不同，但后半段处理应该共享。

推荐最终结构：

```text
BLOCK
 special-block
      ↓
 raw source
      ┐
      │
      ├→ common parse pipeline
      │      ↓
      │    worker
      │      ↓
      │    stree
      │      ↓
      │    Org pseudo tree
      │
INLINE
 texmacs-inline
      ↓
 raw source
      ┘
```

不要分别实现：

```text
block TeXmacs parser
inline TeXmacs parser
```

---

# 22. inline cache 暂时不要先设计

block 当前使用：

```elisp
org-element-cache-store-key
org-element-cache-get-key
```

inline object 是否可以使用同样机制，需要等真正接入 Org object parser 后再测试。

不要因为 cache API 尚未明确，就改变 source syntax。

第一阶段：

> 先让 `(math ...)` 成为可靠的 Org inline source object。

第二阶段再决定 derived tree 缓存方式。

---

# 23. 与当前 public API 的关系

现在已有：

```elisp
(org-texmacs-tree BLOCK)
```

未来可以考虑抽象成：

```elisp
(org-texmacs-tree ELEMENT)
```

其中 ELEMENT 允许：

```text
texmacs special-block
or
texmacs-inline object
```

但不要现在提前修改 public API。

先实现 inline source object，再看两者是否确实可以共享同一个稳定契约。

---

# 24. 当前最小成功标准

inline 第一阶段完成的标准不是：

```text
公式已经预览出来
```

而是：

给定：

```org
Before (math (frac "1" "2")) after.
```

Org 层能够稳定得到：

```text
paragraph
├── plain-text
├── texmacs-inline
└── plain-text
```

并且：

```text
texmacs-inline raw source
==
(math (frac "1" "2"))
```

同时：

* nested parentheses 正确；
* quoted strings 正确；
* 非 `(math ...)` S-expression 不误识别；
* 不完整 `(math ...)` 不吞噬后文。

做到这里以后，再把它接入现有 worker。

---

# 25. 当前总体设计结论

关于 inline TeXmacs，目前推荐的设计可以压缩成一句话：

> **在 Org paragraph 中直接使用 TeXmacs 官方 `(math ...)` 作为 inline math source；用极轻量的 `(math` 前缀识别寻找候选起点，再用 Emacs 的 S-expression scanning 机制确定 balanced boundary；Org 只负责识别 source span，不负责理解 TeXmacs grammar，真正的合法性与 AST 构造仍交给现有 TeXmacs worker。**

更加抽象地说：

```text
Org
负责：
where is the foreign syntax?

TeXmacs
负责：
what does the foreign syntax mean?
```

这与当前 block-level `org-texmacs` 架构保持一致。


# 行内 TeXmacs 与 Org Object Parser 的接入策略

本章取代前一章中“第一阶段让 Org 原生 AST 返回 `texmacs-inline` object”的目标。
当前第一阶段只要求独立识别 source span；临时 lexer 接入结果保留为历史验证，
不代表生产实现。以下 API 名称仍是示意。2026-09-11 的补测与剩余边界见本章 §27。

## 0. 背景

当前 `org-texmacs` 已经确定行内 TeXmacs 数学 source 采用：

```org
A (math (frac "1" "2")) B
```

并且已经通过实际验证确认：

* `(math ...)` 是 TeXmacs 2.1.5 中标准的数学模式宏；
* 已测试 `math` 内部嵌套 `concat`、`frac`、`sqrt` 的样例，未穷举 TeXmacs tree；
* 专用 syntax table + `scan-sexps` 能找到已测括号、字符串和转义样例的完整 span，不能据此宣称支持所有 Scheme reader syntax；
* 临时 lexer prototype 可以把一个完整 `(math ...)` span 当作不可递归的 source object；独立 scanner 则只返回派生 span，不改变 Org 原生解析；
* 临时修改 Org object lexer 后，能够得到：

  ```text
  paragraph
  ├── plain-text
  ├── texmacs-inline
  └── plain-text
  ```
* `org-element-map`、`org-element-context`、parent links 等在 prototype 中可以正常工作；
* 但当前 Org 9.8-pre 没有公开的第三方 object parser 注册接口；
* prototype 需要包裹内部：

  ```elisp
  org-element--object-lex
  ```

  并动态修改 object type / restriction 信息；
* inline object 的 custom cache 行为也没有 block 那么稳定：即使 buffer 未编辑，重新通过 `org-element-context` 取得对象后，之前存入的 custom key 也可能 miss。

因此现在需要决定：

> 是否应该让 `texmacs-inline` 正式成为 Org 原生 object parser 的一部分。

---

# 1. 当前建议

当前建议是：

> **第一版不要直接扩展 Org object lexer。**

保留：

```org
(math ...)
```

作为 canonical inline TeXmacs source syntax，

但把对这些 source span 的识别放在：

```text
org-texmacs 自己的 derived parsing layer
```

中，而不是修改 Org 原生 object parser。

也就是说：

```text
Org canonical source
────────────────────────────
A (math (frac "1" "2")) B
```

Org 仍然按自己的原生语法处理。

当某个 TeXmacs-aware 功能需要理解 inline TeXmacs 时，再通过 `org-texmacs` 自己的 API 得到：

```text
plain span
texmacs-inline span
plain span
```

甚至进一步得到：

```text
plain
texmacs-inline
  └── TeXmacs pseudo subtree
plain
```

---

# 2. 为什么不建议直接接入 `org-element--object-lex`

当前 Org object parser 没有类似：

```elisp
org-element-object-parser-alist
```

这样的稳定第三方注册接口。

prototype 能工作，是因为临时介入了：

```elisp
org-element--object-lex
```

并且还需要同步考虑：

```text
object trigger regexp
all-objects
container restrictions
native object precedence
```

这意味着：

> 正式接入需要依赖 Org parser internals，而不是一个明确支持的 public extension point。

这种依赖不是绝对不能接受，但第一版没有足够收益来证明这种维护成本是必要的。

---

# 3. 这里的核心问题不是“能不能做”

前期验证已经证明：

```text
能做
```

不是问题。

临时 prototype 已经成功做到：

```text
paragraph
├── plain-text
├── texmacs-inline
└── plain-text
```

而且：

```text
org-element-map
org-element-context
parent links
```

都能够使用。

所以当前决策不是：

> “技术上做不到，所以放弃”。

而是：

> “既然没有稳定 public extension API，就不应该仅为了 AST 形式漂亮而过早绑定 Org internals。”

---

# 4. 推荐的新分层

建议把 inline TeXmacs 分成三层。

---

## 4.1 第一层：canonical source

Org 文件本身仍然保存：

```org
A (math (frac "1" "2")) B
```

这是唯一 canonical source。

不增加：

```text
$...$
$$...$$
@@texmacs:...@@
```

等第二套 syntax。

---

## 4.2 第二层：inline source scanner

`org-texmacs` 自己提供一个非常薄的 source scanner。

它只负责识别：

```scheme
(math ...)
```

的 source span。

例如：

```org
A (math (frac "1" "2")) B
```

scanner 返回逻辑信息：

```text
begin
end
raw-source
container
```

或者更抽象：

```text
plain: "A "

texmacs-inline:
  begin = ...
  end = ...
  source = "(math (frac \"1\" \"2\"))"

plain: " B"
```

这一层不需要修改 Org AST。

---

## 4.3 第三层：derived / augmented AST

只有真正需要结构化处理时，才构造：

```text
paragraph
├── plain-text
├── texmacs-inline
│   └── derived TeXmacs tree
└── plain-text
```

这棵树是：

```text
org-texmacs derived representation
```

而不是：

```text
Org live parser canonical AST
```

---

# 5. 推荐提供的基础 API

第一阶段建议优先考虑几个很小的 API。

例如：

```elisp
org-texmacs-inline-at-point
```

职责：

> 如果 point 位于一个完整 `(math ...)` source span 中，返回该 inline span 的描述；否则 nil。

---

可以有：

```elisp
org-texmacs-inline-map
```

职责：

> 在给定 region / Org container 中遍历所有 inline `(math ...)` source span。

例如：

```elisp
(org-texmacs-inline-map
 BEGIN END
 FUNCTION)
```

---

还可以有内部函数：

```elisp
org-texmacs--inline-next
org-texmacs--inline-end
org-texmacs--inline-source
```

分别负责：

```text
找到下一个 `(math`
找到 balanced expression 结束位置
取得 raw source
```

---

# 6. inline scanner 的推荐实现

仍然采用已经验证的两阶段模型：

```text
候选起点识别
    ↓
structural scan
```

---

## 6.1 候选起点

只寻找：

```text
(math
```

并检查 `math` 后面的 token boundary。

不能把：

```scheme
(mathjax ...)
```

识别为目标 syntax。

也不能把：

```scheme
(math"x")
```

当作：

```scheme
(math "x")
```

的等价 source。

前期 TeXmacs 实测已经确认：

```scheme
(math"x")
```

会被读成根 symbol：

```scheme
math"x"
```

而不是：

```scheme
math
```

因此 source scanner 必须自己限定 namespace。

---

## 6.2 structural scan

候选起点之后，使用专用 syntax table +：

```elisp
scan-sexps
```

确定 balanced expression 的终点。

专用 table 至少需要正确处理：

```text
(
)
"
\
```

因为默认 Org syntax table 中：

```text
\
```

不是 Scheme/Elisp 字符串 escape 语义，

已经实测会导致：

```scheme
(math (concat "a)\"b" "c\\d"))
```

扫描失败。

---

# 7. 第一版 comment policy

第一版建议明确：

> **inline STM 不支持 Scheme comments。**

例如：

```scheme
(math
 ;; comment
 (frac "1" "2"))
```

第一版应明确拒绝这类候选，保留原始文本，而不是返回被注释内括号截断的 span。
字符串中的 `;`、`#;`、`#|` 等字符不应因此被拒绝。

原因是：

* 默认 Org syntax table 会错误截断；
* 简单专用 syntax table也会错误截断；
* Scheme table + `parse-sexp-ignore-comments=t` 虽然可以处理 `;;` 这一例；
* 但：

  ```text
  #;
  block comments
  其他 Guile reader syntax
  ```

  尚未验证其完整读取语义。本轮小样例只验证了 scanner 对字符串外的
  `;`、`#;`、`#| ... |#` 保守拒绝，并不构成对这些语法的支持。

因此第一版不应暗示：

```text
full Scheme reader syntax supported
```

更稳妥的契约是：

> inline source 只保证支持当前实际需要的 TeXmacs STM tree serialization，不保证任意 Scheme comment/read syntax。

补测 prototype 遇到不支持的注释或未闭合候选时，停止识别当前 paragraph 的剩余
部分，以避免将坏候选内部的 `(math ...)` 误作新公式；下一 paragraph 不受此策略限制。
这是已测的保守恢复策略，不是已实现的公共 API 契约。更细粒度恢复仍待设计和验证。

---

# 8. scanner 不负责合法性

即使：

```elisp
scan-sexps
```

成功，

也只能说明：

```text
括号 / string boundary 在当前 scanner 规则下是完整的
```

不能说明：

```text
这是合法 TeXmacs tree
```

现有 worker 负责严格读取一个 datum、检查 stree 数据形状，并交给 TeXmacs 转换：

```text
raw source
    ↓
Guile strict read
    ↓
exactly one datum + stree shape check
    ↓
stm-snippet->texmacs
    ↓
tree->stree
```

所以职责划分仍然是：

```text
Emacs:
where is the foreign syntax?

TeXmacs:
what does the foreign syntax mean?
```

这里不承诺完整的标签语义或参数数量校验。本机 worker 原样返回了未知标签
`(math (not-a-valid-texmacs-form "x"))`、`(math)`，以及分别带一个和三个参数的
`frac`。因此 worker 成功只能证明通过当前读取、形状检查与转换流程，不能证明
数学含义正确或能够正确排版。本轮没有进行排版验证。

---

# 9. 为什么 derived scanner 比 Org lexer integration 更稳

如果直接修改 Org object parser，

需要依赖：

```text
Org object lexer internals
object precedence
trigger regexp
container restrictions
parser implementation details
```

独立 scanner 可以避免直接依赖 lexer 内部接口，但实际仍须处理：

```text
buffer positions
Org container positions
plain source text
Org object context / precedence
container exclusions
```

所以“更稳”是减少内部 API 耦合的设计判断，不是升级兼容性的实测保证。
仅有 paragraph 边界不足以排除 code、link description、emphasis 等嵌套 object。
直接查询原始 buffer 的 Org context 还可能受到公式内部 Org 标记的跨 span 影响。

本轮 prototype 使用公开 Org API，在临时副本中遮蔽已经识别的公式，再判断后续
候选的 context，通过了有限样例；原始 buffer 不变。该方法尚未验证大文档性能、
所有 Org object 优先级或不同 Org 版本，不应提前固定为生产算法。

---

# 10. block 与 inline 的不同处理方式

当前 block 使用：

```org
#+begin_texmacs
...
#+end_texmacs
```

Org 已经原生提供：

```text
special-block
```

作为稳定 container。

因此 block 应继续直接利用 Org element AST。

---

inline 则没有对应的稳定 public object extension API。

所以推荐：

```text
block:
使用 Org native AST boundary

inline:
使用 org-texmacs derived source boundary
```

这不是不一致，而是：

> 分别复用 Org 已经稳定提供的最合适抽象。

---

# 11. block 与 inline 后半段必须共享

虽然 source boundary 不同：

```text
BLOCK
special-block

INLINE
derived source span
```

但 raw source 取得以后必须汇入同一条 pipeline：

```text
raw TeXmacs source
       ↓
persistent worker
       ↓
strict read
       ↓
stm-snippet->texmacs
       ↓
stree
       ↓
Org-compatible pseudo tree
```

不要为 inline 再做第二套：

```text
inline parser
inline worker
inline AST adapter
```

---

# 12. 不建议现在修改 `org-texmacs-tree`

当前 public API：

```elisp
(org-texmacs-tree BLOCK)
```

接受当前 buffer 中的 TeXmacs `special-block`。

现在不建议立即把它改成：

```elisp
(org-texmacs-tree ELEMENT)
```

并同时支持 block / inline。

原因是：

> inline source representation 还没有稳定。

先建立：

```text
inline source scanner
```

然后再观察 block / inline 是否确实适合共享同一个 public API。

---

# 13. inline derived cache 暂不设计

前期测试已经确认：

对于临时接入 Org parser 的：

```text
texmacs-inline object
```

执行：

```elisp
org-element-cache-store-key
```

后，

即使 buffer 没有编辑，

重新：

```elisp
org-element-context
```

取得 object，

之前的 cache key 也可能：

```text
miss
```

因此：

> 不能直接照搬 block 的 custom element cache 模型。

第一版不要为了 inline cache 又引入：

```text
marker
stable ID
buffer modification hooks
global hash tables
```

等复杂机制。

先允许：

```text
需要时重新 parse
```

等真实使用证明有性能问题后，再设计 cache。

---

# 14. augmented AST 的可能形式

未来如果某个功能需要真正统一遍历 Org + TeXmacs，

可以提供：

```elisp
org-texmacs-parse-buffer
```

或类似 API。

其返回值可以是一个：

```text
derived augmented AST
```

例如：

```text
org-data
└── section
    └── paragraph
        ├── plain-text
        │   "A "
        ├── texmacs-inline
        │   └── math
        │       └── frac
        │           ├── "1"
        │           └── "2"
        └── plain-text
            " B"
```

这里的：

```text
texmacs-inline
```

和内部：

```text
math / frac / ...
```

可以继续采用已经验证过的 Org-compatible pseudo nodes。

---

# 15. augmented AST 不应成为 live AST

即使未来实现：

```elisp
org-texmacs-parse-buffer
```

也应该理解为：

```text
snapshot / derived tree
```

而不是：

```text
持续驻留并随每个 keystroke 更新的 second live AST
```

不要重新引入早期已经放弃的实时同步复杂度。

---

# 16. source reconstruction 的处理

临时 Org lexer prototype 已经验证：

如果 `texmacs-inline` 真正进入 Org AST，

但没有专用 interpreter：

```elisp
org-element-interpret-data
```

会把 inline source 丢掉。

加入：

```elisp
org-element-texmacs-inline-interpreter
```

后，该 prototype 的示例可以逐字符重建；这不是对任意 Org 文档的无损保证。

---

采用当前推荐的 derived scanner 方案后，

这一问题变得更简单：

> 原始 buffer 始终是 canonical source，scanner 从中精确提取 raw slice，不需要借助 Org interpreter 恢复公式。

原生 Org AST 不被修改，不等于 `org-element-parse-buffer` 与
`org-element-interpret-data` 对所有文本逐字符 round-trip。本轮输入
`A (math "x") B`（没有末尾换行），重建后多出末尾换行。

只有 augmented AST 自己需要定义：

```text
texmacs-inline → raw source
```

的 interpreter / serializer。

这样可以避免对 Org 原生 interpreter 增加新的全局 object type。

---

# 17. 派生表示应将 `(math ...)` 内部视为 TeXmacs source

前期 prototype 已经发现：

如果 `(math ...)` 内部继续交给 Org object parser，

例如：

```scheme
(math (concat "*bold*" "[[file:x]]"))
```

其中：

```text
*bold*
[[file:x]]
```

会被 Org 解释为：

```text
bold
link
```

这不符合 TeXmacs-aware 消费者所需的解释，但仍是未扩展的 Org 原生行为。

因此在 org-texmacs 的 scanner 和未来 augmented AST 中，

一个完整：

```scheme
(math ...)
```

span 都必须是：

> **opaque TeXmacs source region**

派生表示不应把其中的 Org markup 当作外层 Org objects；取得 raw source 后仍交给
TeXmacs 解析成真正的 tree，不是长期把 AST 存为 opaque string。

独立 scanner **不会阻止原生 Org 递归解析这些内容**。本轮已验证扫描后再次调用
`org-element-parse-buffer`，仍能得到公式字符串中的 `bold` 和 `link`。
因此使用原生 Org AST 的其他消费者不会自动获得 TeXmacs 边界语义。
若未来要求所有 Org 消费者都将公式视为不可递归 object，就必须重新评估接入方式；
当前独立 scanner 方案不满足这一更强目标。

---

# 18. container policy 暂时保持窄

早期 lexer prototype 与本轮独立 scanner prototype 都将候选限制在：

```text
paragraph
```

中识别 `(math ...)`。

因此：

```text
paragraph body
```

可以识别，

但：

```text
headline
link description
bold contents
code/verbatim
source block
```

等位置不识别。

上述排除行为已在本轮独立 scanner 的有限样例中复测，不能仅由“遍历 paragraph”
推导出来，仍需要 object context 判断。table cell 样例也被排除；list item 内的
paragraph 样例可以识别。本轮还显式排除了 `texmacs` special-block 内的 paragraph，
避免把 block body 重复识别为 inline；这项附加规则是 prototype 的选择。

当前建议第一版继续保持：

> **只在 paragraph text 中支持 inline TeXmacs。**

不要一开始扩大到：

```text
headline
emphasis contents
link description
table cells
...
```

等所有可能 container。

后续根据真实使用需求再逐个开放。

---

# 19. 第一版最小实现目标

第一阶段只需要做到：

给定：

```org
A (math (frac "1" "2")) B
```

调用：

```elisp
org-texmacs-inline-map
```

可以稳定得到：

```text
one texmacs inline span

source:
(math (frac "1" "2"))

begin:
...

end:
...
```

并正确处理：

* nested expressions；
* quoted parentheses；
* escaped quotes；
* backslashes；
* multiline expression；
* same paragraph multiple expressions；
* `(mathjax ...)` 不识别；
* `(foo ...)` 不识别；
* incomplete expression 不吞噬下一段；
* code/verbatim/source block 中不误识别。

---

# 20. 第二阶段目标

第一层 scanner 稳定以后，

再增加：

```text
inline span
   ↓
existing TeXmacs worker
   ↓
stree
   ↓
pseudo tree
```

也就是能够：

```elisp
(org-texmacs-inline-tree INLINE)
```

返回类似：

```elisp
(math <properties>
      (frac <properties>
            "1"
            "2"))
```

这里的 API 名称只是示意，不要求提前固定。

---

# 21. 第三阶段再决定 augmented AST

只有在：

```text
preview
export
AST transformation
structural editing
```

等真正消费者出现后，

再决定是否需要：

```elisp
org-texmacs-parse-buffer
```

这样的 unified snapshot tree。

不要为了形式统一提前实现整棵 augmented AST。

---

# 22. 什么时候才值得重新考虑 Org lexer integration

只有当真实消费者证明必须依赖：

```elisp
org-element-map
org-element-context
Org export machinery
generic Org object restrictions
```

直接看到：

```text
texmacs-inline
```

时，

才重新评估：

```text
org-element--object-lex integration
```

那时它应当被理解成：

> 一个明确的 Org-version compatibility layer。

而不是整个 `org-texmacs` 架构的核心。

最好把内部 API 依赖集中到一个非常小的文件 / 模块中。

---

# 23. 当前不采用的方案

第一版明确不采用：

```text
直接 advice / 包裹 org-element--object-lex
```

作为生产主路线。

也不采用：

```text
修改 org-element-all-objects
修改全局 object regexp
强行让 Org 原生 parser 永久认识 texmacs-inline
```

作为基础要求。

这并不表示这些方案永久禁止，

只是当前没有足够收益来承担维护成本。

---

# 24. 当前架构图

最终推荐：

```text
                         Org source
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
      #+begin_texmacs                 (math ...)
              │                             │
              ▼                             ▼
     Org native special-block      org-texmacs scanner
              │                             │
              └──────────────┬──────────────┘
                             │
                             ▼
                    raw TeXmacs source
                             │
                             ▼
                 persistent TeXmacs worker
                             │
                             ▼
                           stree
                             │
                             ▼
                Org-compatible pseudo tree
```

区别只存在于：

```text
source boundary discovery
```

后面的 TeXmacs processing pipeline 完全共享。

---

# 25. 当前设计原则

这项决策延续 `org-texmacs` 当前最重要的几个原则：

```text
source is canonical

derived AST is lazy

use Org public abstractions where available

do not depend on Org internals without a demonstrated need

do not duplicate TeXmacs parser semantics

do not maintain unnecessary live synchronization

stability > convenience
```

---

# 26. 最终结论

当前推荐正式表述为：

> **行内 TeXmacs 继续直接使用 `(math ...)` 作为 canonical source syntax，但第一版不把 `texmacs-inline` 注册进 Org 的原生 object lexer。`org-texmacs` 自己通过专用轻量 scanner 识别 paragraph 中完整的 `(math ...)` source span，并按需交给现有 TeXmacs worker 构造 derived tree。只有在后续真实消费者证明必须让 Org generic machinery 原生看到 `texmacs-inline` 时，才重新考虑基于 Org 内部 lexer 的 compatibility layer。**

这意味着当前下一步应优先实现并测试：

```text
inline source scanner
```

而不是：

```text
Org object parser integration
```

---

# 27. 独立 scanner 本机补测与剩余边界（2026-09-11）

本节记录临时 prototype 的测试结果，不表示包已经提供 inline API。
环境为此前确认的 Emacs 31.1、Org 9.8-pre、TeXmacs 2.1.5，调用入口为
`emacs-twist`。本轮没有改动包源码、正式 ERT 或 Nix 配置。

## 27.1 可复查的探针与输出

* 脚本：`tmp/inline-derived-probe-20260911.el`。
* 完整输出：`tmp/inline-derived-results-20260911.log`。
* 较早的 lexer、syntax table、cache 验证记录：`tmp/inline-validation-20260911.md`。

本轮执行：

```sh
timeout 60s emacs-twist --batch -L . --load tmp/inline-derived-probe-20260911.el --eval '(ert-run-tests-batch-and-exit "^derived-probe-")'
```

结果为 6 个 ERT 测试通过，0 unexpected，ERT 计时约 2.97 秒。
其中 source-cases 含 24 个输入样例；interpretation 与 worker-validation-limits
测试主要记录实际返回值，不能将它们的 ERT 通过解释为“全部无损”或“语义校验通过”。
真实 worker 测试采用隔离的临时 HOME / TEXMACS_HOME_PATH，并在结束时清理。

## 27.2 已验证的 scanner 范围

临时 scanner 使用 `org-element-parse-buffer 'element` 获取 paragraph，
结合临时副本中的 `org-element-context` 排除原生 object 内的候选。
它不包裹 Org 内部 lexer，也不注册 `texmacs-inline` object。
返回值仅为 `(begin end raw-source)` 列表，不是 Org AST node。

样例覆盖：嵌套、字符串括号、转义引号、反斜杠、同段内换行、同段多个公式，
以及 `(math(frac ...))` 的紧邻左括号写法；排除 `(mathjax ...)`、`(foo ...)`
和 `(math"x")`。不完整表达式不能借用下一段的右括号结束。
未支持注释的拒绝策略、container 排除范围及附加规则见本章 §7、§18。

source-cases 断言原始 buffer 文本、point 和字符修改计数保持不变；另一个测试
验证 narrowed buffer 中的识别及 narrowing 边界保持不变。
这些结果不等于证明所有原生 Org cache 内部状态都不发生变化。

## 27.3 不能只过滤原始 Org object 范围

实测输入：

```org
A (math (concat "~foo" "bar")) after (math "y") end~ Z
```

Org 原生 code 标记可从第一个公式字符串内的 `~` 延伸到第二个公式之后的 `~`。
只依据原始文本的 Org context 过滤候选，结果只得到第一个公式。
在临时副本中将已接受公式替换为等长空白、保留换行，再查询后续候选 context，
该样例得到两个公式。遮蔽没有修改原始 buffer。

这说明 object precedence / overlap 是独立 scanner 也必须处理的问题。
此样例验证了一种局部处理办法，但没有证明遮蔽算法对所有 Org 语法都正确，
也没有验证复制与重复解析在大文档中的成本。

## 27.4 原生 Org 与 worker 的实际边界

* 扫描后原生 Org 仍把公式字符串中的 `*bold*`、`[[file:x]]` 识别为
  `bold`、`link`；独立 span 只服务 TeXmacs-aware 消费者，不改变原生 Org 语义。
* 四个原生 parse/interpret 样例中三个逐字符相等；没有末尾换行的样例被补了
  换行。因此精确保留 source 应依赖原始 buffer / raw slice，而非通用 interpreter。
* 同一真实 worker 连续返回了未知标签、空 `math`、一个参数的 `frac`、三个参数
  的 `frac`，均未报错。严格读取和 stree 形状检查不能替代标签语义或排版校验。

## 27.5 仍未验证或仍需设计

* 完整 Scheme reader syntax；包括注释读取语义、字符字面量及其他 reader 扩展。
  当前只是对少量不支持语法作保守拒绝，不是完整 Scheme lexer。
* 更细粒度错误恢复、全部 Org object overlap / precedence、复杂容器及 region
  从公式中间开始或结束时的公共 API 行为。
* 大文档性能、跨 Org 版本兼容性、inline cache、augmented AST、preview/export。

这些事项继续明确标为未验证；不能因小样例通过而升级为普遍保证。
当前取舍仍是先做独立 source-span 层、复用现有 worker、暂缓内部 lexer 接入，
但实现前必须明确其只影响派生消费者，并为容器边界和错误恢复建立正式测试。

---

# 28. Inline 分节点实现进度（2026-09-11）

* 节点 1 已提交：`370689f feat(inline): add source span boundary primitives`。
  定义只读 span 槽位、区分大小写的候选搜索及受限结构扫描。
* 节点 2 已提交：`7cca427 feat(inline): discover source spans in Org paragraphs`。新增
  `org-texmacs-inline-at-point` 与 `org-texmacs-inline-map`，返回 source span，
  不返回 TeXmacs tree，也不启动 worker。
* 扫描在独立临时 buffer 中进行，不运行 Org mode hooks，不复制 source text
  properties。使用公开 Org API 获取 paragraph 和 object context，顺序遮蔽
  已接受 span，避免公式内部标记影响后续候选；不修改原始 Org parser 或 AST。
  审阅发现全空格遮蔽会让紧邻公式的 `*`、`~` 等变成原本不存在的 Org 标记，
  从而漏检后续公式。当前遮蔽保留最外层括号和内部空白，仅将其他内部字符替换
  为普通字母；已加入五种相邻标记及合法原生 object 仍被排除的对照测试。
* span 保存来源 buffer、字符修改计数、begin/end 和 raw source；编辑后应重新取得。
  位置采用 `[begin, end)`，region 仅选取完整包含的 span。当前 narrowing 作为
  文档边界，不自动 widen。边界中间截断原有容器时，不承诺保留 narrowing 外的上下文。
* 未闭合或不支持的候选停止本段剩余识别，下一段继续。TeXmacs special-block
  body 不重复识别；list item 和 quote block 内的 paragraph 样例可以识别。
* map 回调在来源 buffer 执行，每次恢复 point/narrowing；检测到 source 被编辑、
  buffer 关闭或切换等情况时停止并 signal error，不回滚已经发生的回调副作用。
* 节点 2 验证：`emacs-twist` 全量 ERT 46/46、Nix flake check（含 package-lint
  与 ERT）、默认包 build 均通过；平台仍限本机 x86_64-linux。
* 节点 3 已提交：`770b665 feat(inline): derive TeXmacs trees from source spans`。
  `org-texmacs-inline-tree` 接受当前
  buffer 的 inline span，复用现有 worker 和 adapter，返回以 `math` 为根的独立
  pseudo tree。根不挂接到 span 或 paragraph，内部 parent links 正确。
* 调用前检查 span 类型、来源 buffer、字符修改计数、可访问范围及 raw source
  一致性；worker 返回后再次检查。字符编辑（包括公式外编辑及修改后恢复原文）
  会使旧 span 失效，单独改变 text properties 不会。等待期间的变化保护通过
  模拟 worker 调用期间编辑、关闭/切换 buffer、改变 narrowing 等动作验证。
* 真实 worker 测试确认 block 与多个 buffer 的 inline 调用共用进程；inline
  重复调用重新解析，block 缓存仍工作。非法 stree 数据失败后 worker 保持存活，
  修复 source 并重新取得 span 后成功。没有增加标签参数数量或排版语义校验。
* 节点 3 验证：`emacs-twist` 全量 ERT 56/56、Nix flake check（含 package-lint
  与 ERT）、默认包 build 均通过；平台仍限本机 x86_64-linux。
* 节点 4 已提交：`adda8bb docs(readme): document inline source and tree APIs`。
  文档区分 block 缓存与 inline 按需解析，说明三个 inline API、span 生命周期、
  narrowing、识别限制和 worker 校验边界；没有改动包源码、正式测试或 Nix 配置。
* 节点 4 验证：`emacs-twist` 全量 ERT 56/56、Nix flake check（含 package-lint
  与 ERT）、默认包 build 及 `git diff --check` 均通过。
  临时探针 `tmp/inline-readme-check.el` 直接读取 README 的三个命名示例，
  源码加载和 Nix 安装产物加载时均得到文档所示结果；安装产物中的三个 inline
  API 定义位置、Scheme 服务文件及默认 TeXmacs 绝对可执行路径也通过检查。
  探针最初因保存了含 `~` 的目录而受隔离 HOME 影响，提前展开绝对路径后通过；
  该失败属于临时探针路径问题，不是包或 README 示例失败。
* 验证平台仍限本机 x86_64-linux；四个节点不包含 inline cache、augmented AST、
  preview/export 或内部 lexer 接入，也不构成大文档性能或跨版本兼容性保证。

---

# 29. Fragment 泛化计划与分节点进度（2026-09-11）

本节记录用户在 inline 阶段完成后确认的新计划。前文 inline 命名及仅限 math
的设计是历史阶段约束；是否已经放宽识别以本节各节点的实际完成状态为准。

## 29.1 已确认的目标与边界

* 公共接口改为 `org-texmacs-fragment-at-point`、`org-texmacs-fragment-map`、
  `org-texmacs-fragment-tree`，类型改为 `org-texmacs-fragment-span`，模块改为
  `org-texmacs-fragment.el`；不提供旧 inline 名称的兼容入口。
* 节点 2 新增 `org-texmacs-fragment-tags`，使用字符串列表，默认完整包含：
  `"math"`、`"equation"`、`"equation*"`、`"eqnarray"`、`"eqnarray*"`、
  `"align"`、`"align*"`、`"gather"`、`"gather*"`、`"eqsplit"`、`"eqsplit*"`。
  不增加 `math*`，11 个入口必须逐项通过真实 TeXmacs AST 测试。
* 配置只是正文 fragment 的入口名单，不是数学标签分类或 TeXmacs 合法性表；
  不限制内部节点，也不限制 `#+begin_texmacs` 的根和内容。
* 保持单个 Org paragraph 边界、段内换行、narrowing、原生 object 排除、遮蔽
  和坏候选停止本段规则，不要求公式独占段落。表格、图片、代码不新增默认正文
  入口，独立复杂内容继续使用 TeXmacs block。
* TeXmacs block 优先：scanner 跳过其后代 paragraph，不拆分其 body；block API
  与现有 Org custom cache 不读取 fragment 配置。只共享 worker 和 adapter。
* 配置支持动态绑定及显式 buffer-local 设置；空列表关闭正文识别，重复项不
  产生重复结果。必须为 proper list of nonempty strings；入口名首字符为 ASCII
  字母，后续允许 ASCII 字母、数字及 `- _ . * + ? ! : / < > =`。非法配置报
  `org-texmacs-error`，不启动 worker，不自动授予文件局部变量安全性。
* discovery 复制配置列表及其字符串，每次生成字面匹配规则，不增加缓存。
  span 增加只读 tag 字符串与 tags 快照；tree 请求前后、map 回调前后检查
  当前配置与快照 `equal`。只比较值，不追踪修改后又恢复相同值的历史。
  返回 stree 根的 `symbol-name` 必须匹配 span 标签名，不对配置调用 `intern`。
* AST 支持不等于编号、样式、排版或 preview/export 支持。公式组测试使用真实
  多行 `tformat` / `table` / `row` / `cell` 结构，不以空节点替代代表性覆盖。

## 29.2 当前进度

* 节点 1 已提交：`4ebe93a refactor(fragment): rename inline APIs and source module`。
  只完成 inline → fragment 命名迁移，包含源码、模块 feature、测试、Nix 源码
  集合及 README 迁移说明。该提交尚未改变识别逻辑，只识别 `math`。
* 节点 1 验证：`emacs-twist` 全量 ERT 56/56、Nix flake check（含编译、
  package-lint 与安装产物 ERT）、默认包 build 均通过。已检查 diff 空白错误，
  包含未追踪的新模块；旧 inline 名称在当前源码、测试与打包配置中无残留，
  README 仅在迁移说明中保留旧名。验证平台限本机 x86_64-linux。
* 节点 2 已提交：`9565fde feat(fragment): recognize configurable TeXmacs root tags`。
  实现配置驱动的多标签识别、
  11 个默认标签、深复制的配置快照、tree 请求前后与 map 回调前后的配置检查，
  以及 raw source 标签和 worker 返回根的一致性检查。未改 worker、adapter
  或 block API，未增加缓存、标签专用转换或数学语义分支。
* 节点 2 验证：`emacs-twist` 全量 ERT 70/70、Nix flake check（编译、
  package-lint 与安装产物 ERT）、默认包 build 和 `git diff --check` 均通过。
  测试逐项覆盖 11 个入口的单行/段内多行源码、半开范围、原生 Org 对象及
  TeXmacs block 内排除、真实 AST 往返和 parent links；公式组使用至少两行的
  `tformat/table/row/cell` 样例。每种源码连续解析两次，44 次请求共用 worker。
  空字符串 leaf 无可承载 text properties 的字符，parent 断言跳过该叶子，
  其 cell 节点及其他非空子节点仍验证 parent links。
* 附加测试覆盖自定义含标点入口、大小写和前缀碰撞、空/非法/重复配置、
  buffer-local 隔离、配置列表及字符串原地修改、相等值恢复、请求/回调期间
  变化拒绝、未知自定义标签的真实错误修复，以及配置不干扰 block 缓存。
  默认标签名称的两种形式均保留为 AST 根，不宣称产生或校验了编号和排版。
* 本机 TeXmacs 2.1.5 的 `share/TeXmacs/packages/environment/env-math.ts`
  已定向读取，确认 equation、eqnarray、align、gather、eqsplit 及星号变体定义。
  临时探针 `tmp/fragment-tags-probe.el` 在正常 ERT 调用方式下也通过 11 个样例。
  首次在脚本加载过程中直接执行 worker 请求时，已有 math 样例出现
  `Invalid read syntax: "#7="`；切换为加载结束后的 ERT 调用并记录原始响应后
  未复现。该加载阶段异常尚未确定根因，不能声称已修复；本节点未扩大修改 worker。
  正式测试编写期间的 ert-info 参数及括号遗漏已修正，最终结果以上述 70/70 为准。
* 节点 3 已提交：`76b4cc2 docs(readme): document fragment tag configuration and examples`。
  文档补充多标签及段内多行示例、math-only 配置迁移、动态及
  buffer-local 配置、空列表关闭识别、自定义入口的语义限制及 block 共存。
  只修改 README，未修改包实现、正式测试或 Nix 配置。
* 节点 3 源码验证：`tmp/fragment-readme-check.el` 通过 `emacs-twist` 在隔离
  TeXmacs 配置中运行，2/2 ERT 通过，覆盖 5 个指定 README 命名示例的预期值
  及源码 API/Scheme 文件加载位置。仅执行已审阅的指定示例，不调用 Babel，
  不向 README 写入结果。源码发现示例另禁止调用 worker request。
* 节点 3 的 Nix flake check（含编译、package-lint 与安装产物 ERT）、默认包
  build 及 diff 空白检查均通过；验证平台仍限本机 x86_64-linux。
  默认包输出为 `/nix/store/c379j72x5kzgbqadc16lknqy8mgqh7dn-emacs-org-texmacs-0.0.1`。
* 节点 3 安装产物验证已获授权并完成：通过 `emacs-twist` 显式加载上述包的
  `share/emacs/site-lisp`，同一组 README 示例及加载位置检查 2/2 ERT 通过。
  5 个指定示例的结果均符合预期；block/fragment API 与 Scheme 服务文件均
  来自安装目录，默认 TeXmacs 路径为绝对路径且可执行。测试使用隔离配置，
  未修改安装产物或 README，未执行 Babel。此结果独立于 Nix 安装产物 ERT。
* 本轮 fragment 泛化计划的三个节点均已完成并由用户整理提交；节点 3 的
  Git-tracked 改动仅为 README。提交后已只读确认工作区干净；AGENTS.md
  和定向示例探针保持忽略且未追踪。本次进度维护未重新运行测试或构建，
  上述验证结果来自各节点实际执行，不代表新增验证。
* 本轮没有剩余实现节点，不自动扩展后续任务。加载阶段的 `#7=` 异常仍为
  未确定根因、后续未复现的观察，不视为已修复；preview/export、编号排版、
  大文档性能及跨平台验证不属于本轮已完成范围。
* 不自动 staging 或提交；用户要求提交信息时按 git-maintenance 从 staged diff
  拟定，节点 1 明确记录公开 API 改名的不兼容变更。

---

# 30. v0.1.0 发布整理计划与进度

本节是 fragment 泛化完成后的发布准备，不扩展 AST 功能或兼容范围。

## 30.1 已确认的发布范围

* 保留 Emacs 31.1 / Org 9.8 依赖声明，明确实际验证环境为 Emacs 31.1、
  Org 9.8-pre、TeXmacs 2.1.5、x86_64-linux，不宣称完整兼容矩阵。
* 发布源码标签与说明，不新增 package.el 安装归档或 CI 发布流水线。
  提交、tag、推送与发布页面由用户手动处理；agent 不代执行。
* 按节点实施、验证、停止，由用户审阅和整理提交；不一次推进全部节点。
* TeXmacs 可执行文件存在性已由 setup 与 worker 启动路径检查，不重复实现。
  根目录 Scheme 服务由 TeXmacs 内嵌环境执行，不新增独立 Guile 运行依赖。

## 30.2 实施节点

1. README 增加本地/已安装包及 straight.el 的 use-package 配置；显式包含
   Lisp 与 Scheme 服务文件。使用隔离目录和真实 straight 构建流程验证
   文件布局、加载位置及 block/fragment 解析，不操作用户已有 straight 环境。
2. 主文件与 Nix 版本同步为 0.1.0；摘要和 flake 描述统一为
   `TeXmacs AST integration for Org`；关键词为 `outlines, tex`。
   capability check 描述去掉 runtime 修饰，保留 Nix runtime closure 术语；
   不改 API、默认标签、协议、依赖下限、lockfile 或 lint HEAD 覆盖设置。
3. 最终验收：emacs-twist 全量 ERT、Nix checks/build、源码/Nix/straight
   产物加载与 README 示例、版本元数据及发行文件集合。准备英文发布说明
   草稿并记录验证结果，不把未经测试的远程安装视为已通过。

## 30.3 当前进度与验证限制

* 节点 1 已提交：`f9a19c8 docs(readme): add use-package and straight installation examples`。
  README 已补充并完成本节点安装验收。
  新增本地、已安装及 straight
  命名配置示例，说明 `:ensure nil`、`:demand t`、可选 `:custom`、straight
  接管边界、版本锁定及 TeXmacs/Scheme 依赖；本次 diff 空白检查通过。
* 经授权定位：emacs-twist 可找到内置 use-package，不能直接找到 straight；
  用户授权只读查看 ~/.emacs.d/，定向找到并检查了
  `~/.emacs.d/straight/repos/straight.el/straight.el`，没有加载用户 init/bootstrap。
* `tmp/release-install-check.el` 的 local 与 straight 两项验证均已授权执行，
  各以独立 emacs-twist batch 进程运行，timeout 120s，均 exit 0。
  测试环境为 Emacs 31.1 / Org 9.8-pre；每项仅创建本次临时源码副本、
  配置及产物，TeXmacs 配置隔离，结束后清理自己的 fixture；未联网下载。
* local 验证 README 本地 use-package 配置、已有 load-path 配置及可选
  math-only `:custom`。设置全局 always-ensure/always-defer 后，显式
  `:ensure nil` 与 `:demand t` 仍生效；加载和 setup 检查不启动 worker，
  discovery 不解析，首次 tree 请求完成真实解析。
* straight 验证只读加载上述现有源码，在隔离 base-dir 中使用真正的
  straight 构建流程；保留 README 的 :files，替换源码获取为本次副本
  （:type nil / :local-repo），并使用 emacs-twist 已有的 Org 依赖。
  禁止克隆与网络获取，关闭异步 native compile；验证全部包 Lisp 的 .elc、
  autoload 文件、构建目录加载位置与相邻 Scheme 服务文件。真实 fragment
  和 block 解析、共享 worker、block cache hit 均通过；也验证了全局
  straight 默认接管时，已有安装配置的 `:straight nil` 不触发 straight。
* 上述 straight 验证覆盖本地获取后的真实构建与加载，不等同于远程 Git
  克隆、自动获取 Org 依赖或发布 tag 安装验证。加载现有 straight 源码时
  出现 if-let/when-let 弃用警告，未导致失败，不是本包编译错误。
* 节点 1 未修改包实现或正式测试，未重新运行全量 ERT/Nix checks/build。
* 用户确认节点 1 提交后继续，节点 2 的版本与描述修改已完成并通过本节点验证：
  主文件 Version 与 Nix package version 均为 0.1.0，摘要及 flake 描述为
  `TeXmacs AST integration for Org`，关键词为 `outlines, tex`；同步 Commentary
  与 README 的功能边界，capability check 的文档及报告标题去掉 runtime。
  不改 API、解析逻辑、依赖下限、默认标签、协议、lockfile 或 lint HEAD 覆盖。
* 节点 2 经授权重新执行 emacs-twist 全量 ERT，70/70 通过（32.19 秒）；
  Nix flake check（含编译、package-lint 与安装产物 ERT）和默认包 build
  均通过，diff 空白检查通过。Nix 验证仅限 x86_64-linux。
* 节点 2 输出为 `/nix/store/jv9gn8z6azad645a9wgljdmgygzpc67p-emacs-org-texmacs-0.1.0`。
  已只读核对安装主文件 Version 为 0.1.0、Keywords 为 outlines, tex，
  对应 derivation 的结构化属性 version 为 0.1.0、name 为
  emacs-org-texmacs-0.1.0。当前 trivialBuild 不生成单独的 org-texmacs-pkg.el，
  不把该不存在的文件作为已验证元数据，也不为本节点新增打包文件。
  derivation 声明的 Org 构建依赖为 emacs-org-9.8.8；不要将它混同于此前
  emacs-twist 实测的 Org 9.8-pre，具体加载版本留待最终环境核对。
* 节点 2 已提交：`476a96e build(release): prepare version 0.1.0 metadata`。
  后续完整配置示例及示例转义整理也已提交；2026-09-12 本地 `v0.1.0`
  指向 `6fd4894`，与 HEAD 一致。用户确认已整理为 0.1.0。
  节点 3 在本记录中仍没有完整执行凭据；发布已完成不等同于补齐验收记录。
* 此前 `tmp/worker-load-repro.el` 的一次有界实测中，加载期间和加载结束后
  各 3 次独立隔离 worker 请求均成功，原始响应没有 `#7=` 标记。此结果不能
  证明原异常已修复，也不能确定原异常根因；发布验收若重现应暂停并定位。

# org-texmacs：Document lowering 与 TeXmacs native tree 交接文档

基线：`v0.1.0`
用户提供的发布地址：https://github.com/ren-lingyu/org-texmacs/releases/tag/v0.1.0

## 0. 证据等级与本次审阅范围（2026-09-12）

本章是 v0.1.0 之后的设计交接，不是已经合入的功能说明。

* **仓库可核对**：现有 block/fragment API、adapter、仅支持 `parse` 的
  worker 协议，以及本地 tag/HEAD。本轮已只读核对相关实现。
* **用户提供的实验结论**：下文所述 scratch lowering、编码往返、native
  buffer/view、多 session、PDF、INCLUDE 与 segfault。保留这些有价值的
  观察，但本轮未取得对应脚本、原始输出及完整调用上下文，也未重新实测。
  下文的“已验证”均指这些交接实验，不表示正式 ERT 已覆盖或本轮复验。
* **官方文档可核对**：Emacs 内部文本与外部编码的区别，以及 TeXmacs
  universal encoding / 文件文档结构。对应链接见 §8 和 §18。
* **尚待决定或验证**：任意 native 字符记法的编码语义、未知 Org 节点策略、
  session 生命周期等。不能由几个成功的 tree round-trip 推出普遍正确。

初次静态审阅未运行测试、未启动 TeXmacs，也未修改包实现、README 或正式测试。
随后经授权进行的前置探针及失败记录见 §19；不要将两次工作的验证范围混同。
进入实现前应按需补齐实验脚本位置、版本、精确命令、输入、输出和退出状态；
没有凭据的结论可保留为后续测试依据，不应升级为已完成的产品保证。

## 1. 本次变更目标

在 `v0.1.0` 已有的 TeXmacs block / fragment 解析基础上，增加 **受支持的 Org document → TeXmacs document body tree** 的能力，并将生成的 tree 直接交给 persistent TeXmacs worker。

本阶段的 `(document ...)` 表示正文，交给 `buffer-set-body`；不是包含
`TeXmacs` 版本、`body`、style 等字段的完整文件文档。完整文件封装与
样式/元数据仍在范围外。后文“完整 target stree”仅指本次转换的完整正文。

目标主链为：

```text
Org buffer
    ↓
Org parsing + org-texmacs TeXmacs islands
    ↓
Org AST with embedded TeXmacs AST
    ↓
structural lowering
    ↓
UTF-8 TeXmacs stree
    ↓
统一 encoding normalization
    ↓
TeXmacs-encoded stree
    ↓
stree->tree
    ↓
native TeXmacs tree
    ↓
TeXmacs buffer/session
```

`.tm`、`.stm`、`.tmml` **不作为这条主链的中间格式**。以后可以作为同一棵 TeXmacs tree 的可选 serialization/export backend。

---

## 2. `v0.1.0` 基线

`v0.1.0` 已经提供：

```elisp
(org-texmacs-tree BLOCK)

(org-texmacs-fragment-at-point &optional POSITION)
(org-texmacs-fragment-map BEGIN END FUNCTION)
(org-texmacs-fragment-tree SPAN)

(org-texmacs-check-setup)
```

现有职责：

```text
TeXmacs special block
    → raw STM
    → persistent TeXmacs worker
    → TeXmacs stree
    → Org-compatible pseudo tree

paragraph-level TeXmacs fragment
    → source span
    → persistent TeXmacs worker
    → TeXmacs stree
    → Org-compatible pseudo tree
```

`org-texmacs-ast.el` 当前只提供：

```elisp
org-texmacs--stree-to-org
org-texmacs--org-to-stree
```

即 TeXmacs stree 与 Org-compatible pseudo tree 的适配。

`v0.1.0` 尚未提供：

* document-level Org → TeXmacs conversion；
* preview / export；
* persistent TeXmacs document session；
* combined live Org/TeXmacs document AST。

本次变更应建立在现有 source discovery / parser / AST adapter / worker 之上，而不是重写它们。

---

## 3. “org-texmacs AST”的含义

这里不要引入新的自定义 AST vocabulary。

预期的逻辑模型仍然是：

```text
Org AST
  +
embedded TeXmacs AST islands
```

例如普通 Org 内容仍然是：

```text
headline
section
paragraph
bold
plain text
...
```

其中 TeXmacs fragment/block 被解析成：

```text
math
frac
concat
equation*
...
```

这样的 TeXmacs subtree。

不要重新发明：

```text
(heading ...)
(paragraph ...)
(texmacs ...)
```

之类的中间语言。

### 3.1 不要求物理构造完整 mixed Org AST

此前尝试把 TeXmacs pseudo nodes 真正 graft 回完整 Org AST 时，遇到了：

* `:parent`；
* secondary properties；
* `org-element-adopt`；
* duplicated structure；

等问题。

因此无需要求先构造一棵完整、Org-valid 的 mixed AST。

允许实现为：

```text
Org AST
+
独立记录的 TeXmacs fragment/block trees
```

在 lowering 时统一消费。

---

## 4. 已验证的 fragment integration 方法

对于 paragraph 中的 native TeXmacs fragment，应在 lowering 消费 Org inline
objects 前确立其边界和语义隔离；这不意味着在所有 Org parsing 之前扫描。
v0.1.0 先用 Org element parsing 找 paragraph，再用 context 与 shadow masking
处理候选。复用时必须保留原生对象优先级、paragraph 范围和 block 排除规则。

已经验证过：

```org
Before *ordinary* (math (concat "*not-org*" "[[file:x]]" (frac "1" "2"))) after.
```

可以正确产生：

```scheme
(concat
  "Before "
  (strong "ordinary")
  (math
    (concat
      "*not-org*"
      "[[file:x]]"
      (frac "1" "2")))
  " after.")
```

因此 native TeXmacs fragment 内部的：

```text
*not-org*
[[file:x]]
```

不会被 Org 再解释成 emphasis / link。

目前原型采用：

```text
scan TeXmacs fragments
→ parse fragment trees
→ temporarily mask/replace fragment source
→ org-element parse
→ lowering 时把 placeholder 换回 TeXmacs subtree
```

生产实现可以调整 placeholder/masking 细节，但必须保持这个语义隔离。

---

## 5. 已验证的 structural lowering 规则

目前 scratch tests 已确认以下基本映射。

### 5.1 Root

Org：

```text
org-data
```

目标：

```scheme
(document ...)
```

### 5.2 Org internal `section`

Org 的 internal `section` 不对应 TeXmacs tag。

规则：

```text
section
→ recursively lower children
→ splice
```

已验证两个 paragraph：

```text
section
├── paragraph 1
└── paragraph 2
```

得到：

```scheme
(concat ...)
(concat ...)
```

而不是：

```scheme
(section ...)
```

### 5.3 Paragraph

规则：

```text
paragraph
→ exactly one (concat ...)
```

例如：

```org
First *paragraph* (math (frac "1" "2")).
```

得到：

```scheme
(concat
  "First "
  (strong "paragraph")
  (math (frac "1" "2"))
  ".\n")
```

Org 保留下来的 paragraph 尾随换行可以继续保留；目前不需要提前 canonicalize。

### 5.4 Bold

```text
Org bold
→ TeXmacs strong
```

例如：

```org
*ordinary*
```

得到：

```scheme
(strong "ordinary")
```

### 5.5 Headline

目前采用：

```text
level 1 → section
level 2 → subsection
level 3 → subsubsection
```

Org hierarchy：

```text
headline First
├── section
│   └── paragraph
└── headline Second
    └── section
        └── paragraph
```

lower 为线性的 TeXmacs document body：

```scheme
(section "First")
(concat ...)
(subsection "Second")
(concat ...)
```

已经验证：

```org
* First
Intro (math (frac "1" "2")).

** Second
Child paragraph.
```

得到：

```scheme
(document
  (section "First")
  (concat
    "Intro "
    (math (frac "1" "2"))
    ".\n")
  (subsection "Second")
  (concat "Child paragraph."))
```

注意：当前仅证明这种 stree 能正确通过 `stree->tree` round-trip；TeXmacs sectioning tag 的所有语义、level 范围和 rendering 尚未全面验证。

### 5.6 Headline rich title

TeXmacs sectioning node 应只有一个 title tree。

因此：

```org
* A *bold* title
```

应 lower 为：

```scheme
(section
  (concat
    "A "
    (strong "bold")
    " "
    "title"))
```

而不是：

```scheme
(section
  "A "
  (strong "bold")
  "title")
```

title lowering 规则：

```text
1 target child
    → child

2+ target children
    → (concat ...)
```

空标题行为尚未专门决定。

---

## 6. Org inline object 的 `:post-blank` 必须保留

已经确认 Org inline object 后的空白可能不在相邻字符串中，而存储为：

```elisp
:post-blank
```

例如：

```org
* A *bold* title
```

Org title 近似为：

```elisp
("A "
 (bold :post-blank 1 "bold")
 "title")
```

因此简单地转换 `org-element-contents` 会错误得到：

```scheme
(concat
  "A "
  (strong "bold")
  "title")
```

正确 lowering 必须统一保留 `:post-blank`：

```scheme
(concat
  "A "
  (strong "bold")
  " "
  "title")
```

应将它实现为 inline lowering 的统一语义，而不是分别写进 `bold`、`italic`、`link` 等 translator。

这里限定为 inline object 的尾随空白；不要把 element 的 `:post-blank`
（空行）当作同一种单位补空格。还需测试多空格、tab、嵌套对象、行末
和 masked fragment 后的空白，确保不丢失也不重复；若目标是精确保留原始
空白字符，仅有计数不够，应核对 source slice 后再决定策略。

暂时不需要把：

```scheme
" " "title"
```

canonicalize 成：

```scheme
" title"
```

相邻字符串合并属于后续 normalization，不影响正确性。

---

## 7. TeXmacs special block

对于：

```org
#+begin_texmacs
(equation* (frac "1" "2"))
#+end_texmacs
```

现有：

```elisp
(org-texmacs-tree block)
```

返回的 TeXmacs pseudo tree 可以转换回 plain stree 后直接 splice 到 document body。

已验证结果：

```scheme
(document
  (section "First")
  (concat "Before block.\n")
  (equation* (frac "1" "2"))
  (concat "After block."))
```

不要额外生成：

```scheme
(special-block ...)
```

也不要强制包进：

```scheme
(concat ...)
```

---

## 8. Encoding invariant

将编码集中在 native boundary 是合理方向，但“对所有叶子统一转换且完全
无损”的结论尚不能固定。下列编码实验只覆盖交接中列出的输入；特别是
TeXmacs 原生字符记法与普通文本的关系，必须先完成 §18.2 的验证。

### 8.1 Emacs 侧保留文本字符串，IPC 使用 UTF-8

在 structural lowering 完成以前，以及完整 target stree 构造完成以后，
string leaf 保持普通 Emacs 文本字符串，不提前转成外部编码字节串：

```scheme
(document
  (section "中文标题")
  (concat
    "普通的中文 "
    (strong "加粗")
    (math "数学中的中文")))
```

不要在 fragment parser 入口提前 encoding。

“UTF-8 stree”是对传输形式的简称，不是 Elisp 字符串内部表示的承诺。
现有 worker 进程与 socket 使用 `utf-8-unix` coding system。
参见 [Emacs Text Representations](https://www.gnu.org/s/emacs/manual/html_node/elisp/Text-Representations.html)。

### 8.2 TeXmacs STM parser 不自动转换 UTF-8

已经根据 TeXmacs 2.1.5 源码确认：

```text
stm-snippet->texmacs
→ scheme_to_tree
→ string_to_scheme_tree
→ scheme_tree_to_tree
→ scm_unquote
→ atomic tree leaf
```

其中没有：

```cpp
utf8_to_cork
```

`scm_unquote` 只处理 Scheme quoting / escaping，不做字符编码转换。

因此当前：

```scheme
(math "中文")
```

经过 `stm-snippet->texmacs → tree->stree` 后，其中字符串仍保持原始 UTF-8 字节。

这支持给普通 Org Unicode 文本与此类 islands 使用同一文本传输约定；
但不能据此认定任何 TeXmacs 原生字符记法都不需要区分语义来源，见 §18.2。

### 8.3 拟议规则：在 native boundary 编码一次

完整 UTF-8 target stree 构造完成后，在 TeXmacs worker/native-tree boundary 统一递归：

```scheme
(string? x)
→ (utf8->cork x)
```

结构节点保持不变。

然后：

```scheme
stree->tree
```

得到 native TeXmacs tree。

已验证：

```text
UTF-8 stree
→ recursive utf8->cork
→ stree->tree
→ tree->stree
→ recursive cork->utf8
→ original UTF-8 stree
```

结果：

```text
encoded-roundtrip-same = true
decoded-same = true
```

测试同时覆盖：

* ASCII；
* 中文；
* punctuation；
* nested `strong`；
* nested `math/frac`。

### 8.4 混合来源也已验证

输入：

```org
* 中文标题
普通的中文 *加粗* (math "数学中的中文").
```

structural lowering 后得到 UTF-8：

```scheme
(document
  (section "中文标题")
  (concat
    "普通的中文 "
    (strong "加粗")
    (math "数学中的中文")
    "."))
```

统一 encoding 后：

```scheme
(section "<#4E2D><#6587>...")
```

在该中文实验中，普通 Org 中文和 TeXmacs fragment 中文都只被编码一次。

因此不要：

* 在 `org-texmacs-tree` 中提前 encoding；
* 在 `org-texmacs-fragment-tree` 中提前 encoding；
* 在未验证字符记法语义前随意增加来源分支，或反过来断言来源永远不重要。

---

## 9. TeXmacs native tree / worker 方向

`v0.1.0` 的 worker 当前主要提供：

```text
(parse ID SOURCE)
```

即：

```text
STM source
→ TeXmacs parser
→ stree
```

本次后续需要新增另一类能力：

```text
complete UTF-8 stree
→ encode leaves
→ stree->tree
→ native TeXmacs tree
```

然后可用于：

```scheme
buffer-set-body
```

不需要先经过：

```text
.tm
.stm
.tmml
```

### 9.1 已通过独立 scratch 实验验证的 TeXmacs 能力

TeXmacs 2.1.5 headless worker 中已经验证：

```scheme
buffer-new
buffer-set-body
buffer-get-body
tree->buffer
tree-set!
view-new
buffer-focus
update-all-buffers
buffer-export
```

以及：

```text
persistent buffer
→ mutate subtree
→ re-typeset/export
```

能够正常工作。

一个 worker 也可以同时持有多个独立 buffer/view session；释放一个 session 不影响其他 session。

因此长期架构可以是：

```text
Emacs
├── Org buffer A ↔ TeXmacs session A
├── Org buffer B ↔ TeXmacs session B
└── ...
                 ↓
          one persistent worker
```

但不要把“已经证明 native buffer 可以持久存在”表述成“已经证明 TeXmacs incremental typesetter cache 一定得到复用”；后者尚未做性能验证。

### 9.2 已知 headless 限制

不要在 headless worker 中调用：

```scheme
get-page-count
```

交接报告中的相关实验触发过 TeXmacs 2.1.5 C++ segfault；尚缺调用上下文与
可复现输入，不能扩大为该函数在所有 headless 环境必然崩溃。当前路径不
需要它，先排除；如需复现应单独授权、隔离进程，不能依赖 Scheme catch
恢复 C++ 进程崩溃。

这不代表 typesetting 不可用：`buffer-export` 已验证可以正常产生 PDF。

---

## 10. 文件 serialization 的定位

已经验证合法完整 TeXmacs document 可以：

```text
stree->tree
→ serialize-texmacs
→ string-save
→ string-load
→ parse-texmacs
→ tree->stree
```

并保持完全相同。

但是本次功能不要采用：

```text
Org
→ TeXmacs AST
→ .tm/.stm/.tmml
→ parse
→ TeXmacs tree
```

这种绕路。

正确主路径：

```text
Org
→ complete stree
→ encoding
→ stree->tree
→ live TeXmacs
```

未来可另行提供：

```text
same AST
├── .tm
├── .stm
└── .tmml
```

作为 serialization/export backend。

目前无需决定三种格式的最终用户 API。

---

## 11. INCLUDE / Org export preprocessing

已经在真实：

```elisp
org-export-before-parsing-functions
```

temporary export buffer 中测试过 recursive `#+INCLUDE`。

Org 会先完成 INCLUDE expansion，之后：

```elisp
org-texmacs-fragment-map
org-texmacs-fragment-tree
org-texmacs-tree
```

仍可直接工作。

因此不要在 `org-texmacs` 内重新实现 INCLUDE resolution。

如果 document lowering 后续工作在 Org export temporary buffer 中，应直接消费 preprocessing 后的 buffer。

---

## 12. 当前还没有解决的内容

不要把以下内容误认为已经完成：

* italic；
* code/verbatim；
* links；
* lists；
* tables；
* source/example blocks；
* footnotes；
* citations；
* properties/drawers；
* TODO/priority/tags；
* arbitrary headline levels；
* TeXmacs fragments in headline titles；
* equation numbering；
* references；
* TeXmacs styles/packages；
* full document metadata；
* preview UI；
* `.tm/.stm/.tmml` user-facing export commands。

特别注意：`v0.1.0` 的 fragment discovery 明确只针对 paragraph text，并排除 headline/table/source block 等上下文。因此目前不能假定：

```org
* Title (math ...)
```

已经可作为 native TeXmacs fragment 处理。

---

## 13. 推荐的实现分层

建议不要把所有逻辑继续堆进 `org-texmacs.el`。

概念上分三层：

```text
source/discovery
    existing v0.1.0 machinery

document lowering
    Org structure + TeXmacs islands
    → complete UTF-8 TeXmacs stree

native bridge
    UTF-8 stree
    → utf8->cork
    → stree->tree
    → TeXmacs buffer/session
```

具体文件名/API 名称可以在实现时决定，不必预先锁定。

可能的内部职责例如：

```text
org-texmacs-document.el
    Org document structural lowering

org-texmacs-worker.el / worker.scm
    encoding + native document/session operations
```

编码算法不要在 Elisp 中重新实现；使用 TeXmacs 原生：

```scheme
utf8->cork
```

---

## 14. Lowering API 应满足的性质

document lowering 本身应尽量是纯转换：

```text
input:
    Org parsing result
    + parsed TeXmacs islands

output:
    UTF-8 TeXmacs stree
```

它不应该：

* 自己启动 TeXmacs；
* 自己做 Cork encoding；
* 写 `.tm/.stm/.tmml`；
* 承担 rendering；
* 修改 source Org buffer。

这样 structural lowering 可以独立 ERT 测试。

---

## 15. 下一步实现顺序

以下为功能依赖顺序，不应把 Phase A 的实现和 Phase B 的测试拆成无测试
的两个提交。每个节点必须同时包含对应测试，能独立加载、check/build，
通过后停止供用户整理提交。具体节点与前置条件见 §18。

### Phase A：正式化 structural lowering

把目前 scratch 中已经验证的：

```text
org-data
section
headline
paragraph
plain text
bold
:post-blank
TeXmacs fragment
TeXmacs special block
```

整理成正式内部实现。

不要立即扩 italic/list/link/table。

### Phase B：补 ERT

把目前 scratch tests 固化为 regression tests，至少覆盖：

```text
paragraph + bold
paragraph + TeXmacs fragment
section transparency
nested headlines
TeXmacs special block
rich headline title
inline :post-blank
Chinese ordinary Org + Chinese TeXmacs fragment
```

structural tests 尽量不启动 TeXmacs；只有需要真正 parse native TeXmacs islands 时使用现有 real-worker fixture。

### Phase C：增加 worker native-tree operation

在 worker 侧加入：

```text
UTF-8 stree
→ recursive utf8->cork
→ stree->tree
```

并验证：

```text
buffer-set-body
→ buffer-get-body
→ tree->stree
→ cork->utf8
```

可恢复 lowering 输出。

### Phase D：首次完整端到端测试

目标：

```text
Org buffer
→ document lowering
→ UTF-8 TeXmacs stree
→ worker
→ encoding
→ native tree
→ real TeXmacs buffer
→ read back
→ decode
```

最终 semantic tree 与 lowering 输出一致。

全程不产生临时 `.tm/.stm/.tmml` 文件。

### Phase E：之后才继续扩 Org mapping

在核心链稳定后逐项添加：

```text
italic
code/verbatim
links
lists
tables
...
```

每增加一个 Org element，只增加对应 lowering rule 和 tests，不再改变总体架构。

---

## 16. 建议固定的核心 invariant

实现和 review 时应始终保持以下四条：

### Invariant 1

```text
Org buffer remains the canonical source.
```

TeXmacs session、native tree、preview、serialized files 全部是 derived state。

### Invariant 2

```text
org-texmacs / Emacs side strings remain text;
IPC uses UTF-8.
```

不要让 Cork/universal TeXmacs encoding 泄漏进 source discovery 或 structural lowering。

### Invariant 3

```text
encoding happens exactly once,
at the native TeXmacs boundary.
```

编码位置集中；具体字符语义以 §18.2 验证为准，尚不能断言全部输入共享
同一无条件转换。不得改动 v0.1.0 parse API 的返回语义来适配新操作。

### Invariant 4

```text
AST is the integration boundary;
file formats are optional serialization.
```

不要通过 `.tm/.stm/.tmml` 才把内容交给 TeXmacs。

---

## 17. 本轮完成标准

这次功能可以认为完成，当且仅当能够稳定通过这样一个端到端 case：

```org
* 中文标题

普通的中文 *加粗* (math (frac "一" "2")).

#+begin_texmacs
(equation* (frac "3" "4"))
#+end_texmacs

** Second

Final paragraph.
```

它能够：

```text
1. 由 Org + org-texmacs 正确识别结构；
2. lower 为完整 UTF-8 TeXmacs document stree；
3. 保证 native TeXmacs island 不被 Org 二次解析；
4. 保留 Org inline :post-blank；
5. 在 worker 中统一 utf8->cork；
6. stree->tree；
7. 写入真实 persistent TeXmacs buffer；
8. buffer-get-body / tree->stree / decode 后恢复同一语义树；
9. 整个过程不依赖任何临时 .tm/.stm/.tmml 文件。
```

达到这一点以后，才开始扩展更多 Org elements 或 preview/export 层。

## 18. 审阅后的实施约束与分节点建议（2026-09-12）

### 18.1 正文、文件与无损承诺

* 官方 [TeXmacs format](https://www.texmacs.org/tmweb/manual/webman-format.en.html)
  区分一般 tree 与包含版本和 body 字段的文件文档。本轮只构造正文，
  serialization 实验不等于 `buffer-set-body` 输入与文件树可以互换。
* 支持范围先限于本章列出的映射。建议遇到未支持节点或会被忽略的语义
  属性时明确报错并提供类型/位置，不默认扁平化或丢弃。对 keyword、drawer、
  TODO/priority/tags、空标题、超过三级 headline、跳级和 subtree/narrowing
  的处理须逐项明确；允许忽略的内容必须列举并测试。
* headline rich title 取 secondary `:title`，不能只递归普通 contents。
  零个 title child 尚未决定；不可生成未验证的零参数 section tag。
* 一个 special block 的 stree 作为一个正文 child 插入，不是无条件拼接其
  `cdr`。原子字符串和根为 `document` 的 block 需单独测试并明确策略。
* 结构 round-trip 不证明 tag arity、样式依赖、编号或最终排版正确。
  本轮不能声称所有 Org 文档都可转换或 source 字节级 round-trip。

### 18.2 编码是 native bridge 的前置验证项

官方格式文档说明 `<alpha>` 等是 TeXmacs universal encoding 的字符记法，
不只是普通 ASCII 文本。因此“parser 没有 utf8_to_cork”只能说明解析流程，
不能证明字符串没有已经具有 native 意义的内容。

在固定无条件递归 `utf8->cork` 之前，至少比较：

* Org 普通文本中的字面 `<alpha>`、`<#4E2D>`、`<`、`>`；
* STM island 中原生 `<alpha>`、`<less>`、Unicode `α`、中文及二者混合；
* Unicode 无对应 native 名称或 native 字符无 Unicode 对应时的行为；
* `with` 等属性字符串，以及后续若支持路径/原始数据时的转换边界。

分别检查编码树、回读树与解码文本。`cork->utf8` 可能规范化不同表示，
所以逐字相等与语义相等必须分别定义，不能把一种成功当成另一种成功。
后续 §19.8 已验证反例：无条件 `utf8->cork` 会将原生 `<alpha>` 变成字面
文本，不能对全部官方 STM 输入宣称语义正确。普通 Unicode 的核心案例可先推进；原生记法策略未确认前，
native bridge 不应宣称通用无损。无需在 Elisp 重写 TeXmacs 编码算法。

### 18.3 snapshot 与 masking 契约

* source preparation 可调用既有 worker；纯 lowering 只消费准备好的 AST
  与 islands。不要让“纯 lowering”隐式调用 tree API 启动进程。
* 所有 spans、block nodes、AST 必须来自同一 buffer snapshot。等待 worker
  期间若 source 或标签配置变化，拒绝本次结果；不能拼接跨版本数据。
* placeholder 不能与用户文本碰撞，不能改变 Org delimiter/段落边界；
  位置映射、相邻多个 fragments、内部伪 Org 标记、尾随空白必须回归测试。
  在临时副本中 mask，不改 source，也不对缓存 pseudo tree 原地改写。
* INCLUDE 留给 Org preprocessing，但原始 buffer lowering 不承诺自动展开。
  必须区分 raw-buffer 与已预处理输入；不能把 export hook 的单例实验扩大为
  完整 export pipeline 支持，也不能隐式执行 Babel 或读取外部 INCLUDE 文件。

### 18.4 worker 新操作的最小边界

* 保留现有 `(parse ID SOURCE)` 和既有响应，不对已有客户端作隐式破坏。
  新 operation 只接收验证后的数据；检查 stree 结构、根、请求 ID，绝不 eval。
* 继续对实际调用 API 做显式存在性检查。文档列出的所有 native 函数不等于
  都要成为依赖，只检查当前节点用到的函数；存在性不替代真实调用测试。
* 先验证一个 body 的创建、设置、回读与释放，再决定是否暴露 session API。
  对重复关闭、无效句柄、worker 死亡/重启、失败清理制定测试；旧句柄不能
  在重启后误指向新对象。多个 session、view、局部 mutation 暂不自动纳入。
* 同步显式调用即可，不加实时 edit hook、live AST graft 或自动同步。
  不依赖 focused view 等全局状态，除非探针确认必要并有隔离设计。

### 18.5 已确认的实现节点及各自验收

当前进度（2026-09-12）：节点 1–5、6a、6b 均已实现、验证并提交。
下文保留分阶段验证历史，不将其中旧阶段的“尚未实施”视为当前状态。
下一项已列入规划但尚未实施的工作是标准 Org export environment/文件内
选项接入，见 PLAN-2026-09-12-01 的“后续工作边界”。

前置探针见 §19；以下是前置验证之后的实现节点，不沿用早期探针节点编号。

1. **纯 structural lowering + ERT**：正文、section 透明展开、paragraph、
   bold、title、post-blank 和显式不支持错误；使用预解析 islands fixture，
   不启动 worker。同步接入文件集合、加载与 capability checks。
2. **source preparation + islands 集成测试**：复用 discovery 和真实 parser，
   验证 masking、block 排除、snapshot、配置变化与 source 不变；纯层不增副作用。
3. **编码与受约束 native bridge**：保留来源直到编码完成，使用固定内部请求；
   验证字符语义与错误隔离，旧 parse API 保持通过；不提前公开 session API。
4. **persistent session**：公开创建、整体设置正文与关闭接口，测试生命周期、
   正文写入/回读/释放及错误后的后续请求。
5. **端到端与文档**：本章中文案例、失败输入和 worker 生命周期；明确支持
   子集和编码限制。核对打包产物及新增文件，主链不使用 `.tm/.stm/.tmml`。
6. **标题元数据与 Org 解析配置**：闭环完成后单独实施。参考 Org LaTeX
   后端分开处理标题正文、TODO、优先级与标签，但直接生成 TeXmacs 结构。
   先验证并传递必要的有效解析配置，再明确显示/省略策略；不能仅放开
   TODO 拒绝而保留错误识别。测试自定义 TODO/DONE、优先级、标签、rich
   title 及等待期间配置变化。COMMENT、归档、任务筛选可能影响整个 subtree，
   另定策略，不顺带引入 export preprocessing 或 Babel。当前严格拒绝策略
   保留至相应支持验证通过；现已完成 6a/6b，不属于节点 3 的范围。

   节点 6 分成两个可独立验收的小提交：
   - **6a 有效解析配置传递**：复制 TODO 正则、DONE 列表、odd-level policy
     与 priority 正则，供私有 parser 使用；保持等待期间快照检查。
     先验证自定义标题的识别正确性，仍拒绝被识别出的标题元数据。
   - **6b 标题元数据输出策略**：已完成 TODO、priority、tags 的标准输出
     policy、formatter 和原生树表示，增加相应 ERT；提交与验证记录见下。
     COMMENT/archive 与任务筛选继续独立，不从标题显示策略推导过滤行为。

每个实现节点同步增加其 ERT，并在授权后执行 emacs-twist 测试与 Nix
checks/build；不把“先写完全部功能、最后统一补测试”作为提交策略。
节点 1 已提交：`23610a9 feat(document): add pure structural lowering with STM provenance`。
验证：83/83 ERT、当前 x86_64-linux 的 Nix checks 与独立构建通过。
直接 ERT 首次因沙箱禁止 Unix socket bind 而失败并超时；经授权在沙箱外
重跑后通过（34.29 秒），不作为代码回归记录。

节点 2 实施中：新增 `org-texmacs-document` 全 buffer 入口及私有 source
preparation。先在等长 masking 副本上准备 AST、island 身份映射和尾随空白，
用占位 stree 预检支持范围，再按源顺序请求共享 worker，最终调用纯 lowering。
block body 不递归准备 fragments，解析结果仍作为一个完整 child。
请求前后检查原 buffer、字符修改 tick、Org mode、标签配置及 narrowing。
不读取 INCLUDE、不执行 Babel、不运行 export hook，不引入 cache/live AST 修改。
首次验证：直接 ERT 与 Nix ERT 均为 85/92 通过，7 项新增测试失败；独立
构建通过。段落重建误将 children 列表作为单个 child 传给
`org-element-set-contents`。已获授权改用 `apply` 展开 children；同时修正
循环测试为真正的自引用 child，避免错误结构造成假通过。修复后验证通过：
沙箱外 `emacs-twist` 全量 ERT 92/92（37.13 秒），当前 x86_64-linux 的
Nix checks 全部通过，独立构建通过。节点 2 已完成实现与上述验证，待提交前
审阅及用户整理提交。节点 3–5 尚未实施。

节点 2 提交前审阅发现配置边界缺口，已本机复现：用临时
`org-todo-keywords` 配置启用源 Org buffer 后，原生 AST 的 `:todo-keyword`
为 `"WAIT"`，旧 document 入口却输出 `(document (section "WAIT Task"))`。
探针：`tmp/document-config-check.el`。不能用先设置局部
`org-todo-keywords` 再调用 `org-set-regexps-and-options` 的旧探针作证据，
该初始化会读取默认值，未真正创建所需自定义 TODO 场景。

当前采用保守拒绝策略：比较源与私有 parser 的有效 `org-todo-regexp`、
`org-done-keywords`、`org-odd-levels-only`，不一致则在 worker 请求前报错；
等待期间再次检查此快照。快照复制列表和字符串，不共享可变配置对象。
不自动复制整套 Org buffer 状态，不宣称任意 Org parser 定制都得到支持。
新增上述配置的存在性检查，以及 TODO、标题层级、等待期间变更三项回归
测试；针对性 ERT 3/3 已通过。修复后完整验证：沙箱外 `emacs-twist`
95/95 ERT 通过（36.86 秒），当前 x86_64-linux 的 Nix checks 与独立构建
通过。节点 2 已提交：`6c3586d feat(document): convert Org source snapshots with TeXmacs islands`。

节点 3 已提交：`eded25c feat(worker): encode document trees with STM provenance`。
验证：沙箱外全量 ERT 100/100（41 秒），当前 x86_64-linux 的 Nix checks
及独立构建通过。增加固定 `encode` worker 操作，输入正文文本 stree 与
非重叠 `stm-paths`，在 worker 内按来源编码并做 native tree round-trip。
新路径拒绝 raw-data，旧 parse 不变；不导入私有 LaTeX helper，不使用 TMML。
诊断返回树的叶子采用十六进制字节串，避免 Cork 字节被 UTF-8 IPC 损坏；
它不是原文或公开 document 结果。节点 3 不创建持久 buffer/session。

节点 4 已提交：`5d96975 feat(session): manage a persistent native TeXmacs body buffer`。
验证：沙箱外 `emacs-twist` 全量 ERT 107/107（53.66 秒），当前 x86_64-linux
的 Nix checks 及独立构建通过。新增 `org-texmacs-session-open`、
`org-texmacs-session-set-document`、`org-texmacs-session-close`。先限一个
活动 session，重复打开拒绝而不替换现有 buffer；重复关闭和关闭旧 worker
句柄为本地 no-op。句柄同时绑定 worker 进程身份与服务端 key，重启不复活。
设置完整正文之前编码并验证 native tree；编码失败保留原正文，native 更新/
回读失败废弃 session，关闭失败作为致命响应停止 worker。只开放固定数据
操作，不 eval 请求。私有 readback 仍采用 hex 叶子用于测试，不增加渲染、
view、外部文档文件、增量更新或样式映射。模块已接入加载及 Nix 文件集合。
生命周期、旧句柄、编码失败及 native 失败注入测试包含在上述验证中。

节点 5 已提交：`dfa488d test(document): cover native body conversion and documented sessions`。
补充本章 §17 中文案例的真实端到端测试，native 预期独立
构造，不以生产 encoder 的输出作为预期；同时测试失败输入保留旧正文、
修复后同 worker 更新，以及同一文本结果重复设置不发生双重编码。
README 新增 document/session 接口、支持子集、来源编码与生命周期限制，
明确区分 0.1.0 发布和当前 checkout。两个命名示例加入 ERT，Nix driver
显式传入 README 路径并使用已安装包；加载测试核对全部八个模块及相邻
Scheme 文件。未新增 Org mapping、未修改版本号、未实施节点 6。
验证：沙箱外 `emacs-twist` 全量 ERT 111/111（63.17 秒）；当前
x86_64-linux 的 7 项 Nix checks、独立构建及 staged diff 检查全部通过。
其他平台未验证。节点 5 已完成，接下来按节点 6 先处理有效解析配置，
再处理标题元数据的显示/省略策略，不引入 COMMENT/archive 子树筛选。

节点 6a 已提交：`fbe3fd8 feat(document): preserve effective Org heading parser settings`。
私有 parser 初始化后安装源 buffer 的上述四项有效值，
字符串及 DONE 列表逐层复制，不与源值或等待期间快照共享可变字符串。
快照检查扩至 priority 正则；不重跑源 buffer 的配置初始化，不从
`org-todo-keywords` 声明或文件关键字重新推导。补充基本类型检查及
`org-priority-regexp` 存在性检查。自定义 TODO 配置中未定义的 `TODO`
按普通标题文本处理；被正确识别的 WAIT/FINISHED 等仍因元数据未支持而
拒绝，错误不再只是“私有配置不同”。标题层级沿用 Org 的有效解析级别：
odd-level policy 启用时三星标题对应 level 2；仍限有效层级 1–3。

源码依据（只读核对，不等于本轮运行验证）：本机 Org 9.8-pre 的
`org-element--headline-parse-title` 直接读取 `org-todo-regexp`、
`org-done-keywords`、`org-priority-regexp`，并通过 `org-reduced-level`
应用 `org-odd-levels-only`；`org-priority-to-value` 不依赖优先级上下限。
`ox-latex` 分别提取 title、TODO、todo-type、priority、tags，再交给标题
formatter；本轮只参考这种分层，不加载 exporter、不生成 LaTeX。
新增/调整 ERT 覆盖 parser 属性对照、配置隔离、无效值、等待期间原地
修改、元数据拒绝及自定义配置的 native 闭环。README 同步说明配置边界。
验证：沙箱外 `emacs-twist` 全量 ERT 117/117（64.70 秒），当前
x86_64-linux 的 7 项 Nix checks、独立构建及 staged diff 检查全部通过。
提交前审阅未发现阻塞问题，其他平台未验证。6a 已完成；当时尚未实施的
6b 已在后续提交完成，见以下记录。

节点 6b 已提交：`8649f85 feat(document): format headline metadata with Org output policies`。
验证：沙箱外 `emacs-twist` 全量 ERT 125/125（67.37 秒），当前
x86_64-linux 的 7 项 Nix checks、独立构建和 staged diff 检查全部通过。
提交前审阅未发现阻塞问题。新增 8 项 headline 测试涵盖 policy 组合、
formatter、复制隔离、快照、显式标签、keyword 边界及 native literal 编码。
节点 6a/6b 已完成；不等于完整 Org 导出环境、子树筛选或 exporter 已完成。

节点 6b 旧提案（已被 PLAN-2026-09-12-01 的确认决策替代，不得据此实现）：
- 分别提供 `org-texmacs-document-with-todo-keywords`、
  `org-texmacs-document-with-priority`、`org-texmacs-document-with-tags`
  三个布尔选项，建议默认全部为 t，避免默认悄然丢弃已识别的元数据。
- 顺序为 TODO/DONE、优先级、标题正文、标签；TODO/DONE 使用 `strong`，
  优先级使用字面 `[#A]` 或 `[#12]`，标签使用字面 `:tag1:tag2:`。
  与原标题 contents 一同组成 `concat`，无元数据时保持现有 title 结构。
  不引入新 TeXmacs 宏、颜色或排版依赖，所有新增文本按 Org literal 来源编码。
- nil 只省略对应元数据的显示，不过滤标题或正文；只使用标题自身的显式
  tags，不引入继承标签。COMMENT/archive/任务筛选继续维持原有拒绝边界。
- 配置在 document 入口取快照、传入纯 lowering，等待 worker 时复查。
  不读取 `org-export-with-*`、不解析 `#+OPTIONS`，不隐式加载 exporter。
- 验证全部开关组合、自定义 TODO/DONE、字母/数字优先级、多个标签、rich
  title、元数据 literal 编码、输入不变性及等待期间选项变化；原有明确
  不支持的节点和 affiliated metadata 仍应拒绝。
以上默认显示策略与选项范围需用户确认，再实施正式代码及 ERT。

节点 1 输入是准备后的 Org AST 与按对象身份匹配的 island 映射；输出为
`org-texmacs-document` 结果，其 `body` 是文本 stree，`stm-paths` 是以零为起点、
不计 tag 的子节点索引路径。block island 的原子或 document 根都作为一个
完整子节点，不展开。标题只支持 Org 解析层级 1–3（6a 起沿用源 buffer
的 odd-level policy），正文 paragraph 固定生成 concat。
结果及其嵌套内容按只读约定使用；不保留输入字符串或 Org properties。
普通 Org 的 inline `:post-blank` 缺省恢复为空格；准备层必须为需要精确保留
的 tab/空格提供显式文本，不能把计数恢复说成逐字符无损。

编码契约（节点 3）：普通 Org 叶子按 literal/source-code semantics 转为
TeXmacs universal encoding；字面 `<` / `>` 必须保持字面语义，`<alpha>`
不得成为 TeXmacs alpha 记号。优先使用已验证满足该语义的原生转换接口。
STM 叶子按 TeXmacs source semantics 转换：Unicode 文本转换为 universal
encoding，`<alpha>` 等原生记法保持原生语义；字面尖括号由 STM source 自身
使用 `<less>` / `<gtr>` 表示。两类来源通过 `stm-paths` 区分，直到编码完成
后才可丢弃 provenance；不得按叶子内容猜测来源，也不引入 TMML 中间层。

## 19. 前置探针执行记录（2026-09-12）

### 19.1 范围与可复查产物

本轮只新增临时探针、执行经授权的测试并维护本文件，未修改正式代码、
README 或正式 ERT。最终 TeXmacs 正文 tree 仍定位为新增下游能力；现有
Org AST + 按需 TeXmacs subtrees 不变，不要求先构造完整 mixed AST。

* 探针：`tmp/document-boundary-probe.el`。
* 固定 Scheme 实验：`tmp/document-boundary-native.scm`，不提供任意 eval 服务。
* Org 结果：`tmp/document-boundary-org.log`。
* Native 部分结果：`tmp/document-boundary-native.log`，仅有环境信息，不能
  单凭这个文件判断成功；错误及退出状态记录在本节和本次命令输出中。
* 两组使用 Emacs 31.1、实际加载 Org 9.8-pre；Org 库位于
  `/nix/store/5sbsczj8jzgqlwl7j1rn14xs3gkvm6pp-emacs-pgtk-31-1-org-9.8-pre/share/emacs/site-lisp/org.elc`。
  TeXmacs 路径为
  `/nix/store/52iz92ini64qhnrsfwyxaid74rwcsb5r-texmacs-2.1.5/bin/texmacs`，
  首次启动输出确认 TeXmacs 2.1.5。不要沿用旧 store 路径作为本次环境。

已只读检查该安装中的 `progs/texmacs/texmacs/tm-print.scm` 与 `tm-files.scm`，
发现原生代码使用 `buffer-new`、`buffer-close buf`、`buffer-set-body`。
这是接口用法的源码依据，不是本次 native 操作已成功的证明。

执行命令（各自 timeout 120 秒）：

```sh
timeout 120s emacs-twist --batch -L . --load tmp/document-boundary-probe.el --eval '(org-texmacs-probe-run (quote org))'
timeout 120s emacs-twist --batch -L . --load tmp/document-boundary-probe.el --eval '(org-texmacs-probe-run (quote native))'
```

### 19.2 Org 组：exit 0

* `First *bold*  after` 中 bold 的 `:post-blank` 为 2。
* `* A *bold* title` 的 secondary title 中 bold 的 `:post-blank` 为 1。
* 空标题被识别为 headline，`:raw-value` 为 `""`；1、2、3、5 级标题的
  `:level` 分别保留其值。如何映射仍是 lowering 契约，不由这些观察自动决定。
* 含 `*not-org*`、`[[file:x]]` 的 fragment 与后续另一个 fragment 均被发现。
  原始 Org AST 仍能包含前者内部的 bold；discovery 成功不等于已有完整
  augmented AST。lowering 仍需消费 spans 并隔离 island 内部解释。
* TeXmacs block 的根为 `document` 或原子字符串时，discovery 均不产生
  block 内 fragment。这里只验证排除行为，没有验证这两种 block 的真实解析。
* 所有样例前后 source 内容和字符修改 tick 均保持不变。

限制：本探针是结构观察加 source 不变断言，并非完整转换回归测试。
样例包含 tab，但 tab 位于普通文本中；不能据此宣称 object 后 tab 的
`:post-blank` 已验证。也未测得完整的 masking 后 lowering 或空白重建结果。

### 19.3 Native 组：两次尝试均未完成

1. 沙箱内执行：Unix-domain socket `bind` 返回 `Operation not permitted`，
   worker 等待启动失败，Emacs exit 255。属于环境限制，不是编码反例。
2. 经工具审批在沙箱外执行同一命令：首次 parse 请求即发生
   `org-texmacs-worker-error ("Invalid read syntax: \"#7=\"")`，Emacs exit 255。
   首个输入为 `(with "mode" "math" (math (frac "ASCII" "2")))`。

第二次复现了历史记录中的同类错误消息；不能据此确认根因相同。请求从
加载结束后的 `--eval` 调用，因此不能再把“仅发生在加载期间”作为解释。
没有捕获原始响应，无法确定 `#7=` 是否真的存在于 wire data，也不能判定
是 TeXmacs 返回错误、Emacs reader/advice 行为或其他原因。不得通过放开
`read-circle` 来绕过诊断。

由于失败发生在第一个 parse 的结果记录之前，以下均未执行完成：字符串
保持矩阵、两类 block parse、独立 Scheme 编码实验、buffer 创建/写入/回读/
释放、Scheme 错误后继续处理。原先交接中的成功实验继续保留，不被本次
失败否定，也不升级为本轮复验通过。探针按 unwind-protect 清理本次进程和
fixture；未执行全量 ERT、Nix checks/build 或任何导出。

### 19.4 下一步（须另行授权）

先在临时探针中补充第一请求的原始响应捕获、完整错误阶段、实际 reader
函数来源及相关运行状态，再做一次有界复现；不得修改生产 decoder 或扩大
reader 接受范围。原始响应与异常需持久写入独立报告，避免仅记录环境。
必要时将现有 parse 路径与独立 native 实验拆成单独命令，防止前者阻塞后者，
但不得把隔离实验成功解释成正式 worker 协议已支持 native 操作。
上述错误未定位前，不声称前置验证已完成，不推进正式 native bridge 实现。

### 19.5 `#7=` 定向诊断的新增证据（2026-09-12）

经用户要求尝试处理错误，新增临时 `tmp/reader-boundary-repro.el`，未改正式
decoder。经工具审批执行一次隔离 worker 请求，输出保存在
`tmp/reader-boundary-repro.log`。命令为：

```sh
timeout 120s emacs-twist --batch -L . --load tmp/reader-boundary-repro.el --eval '(org-texmacs-reader-probe-run)'
```

* 请求为 `(with "mode" "math" (math (frac "ASCII" "2")))`。
* 已捕获原始响应：正常的 `ok` envelope，tag 使用既有逐字符反斜杠转义，
  没有 `#7=` 标记。
* 原 decoder 首次仍抛出 `(invalid-read-syntax "#7=")`。
* 同一响应离线直接以 `read-circle=nil` 调用 `read-from-string` 成功，
  返回完整 datum，结束位置为 67。
* 同进程再次调用原 decoder 出现 `(setting-constant nil)`。
* reader 为内置 subr，无 Lisp `symbol-file`；外层 `read-circle=t`、
  `load-in-progress=nil`。探针捕获异常后退出 0，不表示解析测试通过。

因此可以排除“本次捕获的 wire response 含 #7=”这一解释；尚不能据此
确定具体触发函数。生产 decoder 的 `read-circle=nil` 动态绑定覆盖整个
函数，不仅覆盖 `read-from-string`。它是否影响后续宏展开/延迟加载，是
下一步应验证的假设，不能直接写成已经确认的根因。

随后经工具审批执行了一次固定响应的无 worker 诊断：

```sh
timeout 120s emacs-twist --batch -L . --load tmp/reader-boundary-repro.el --eval '(org-texmacs-reader-probe-offline)'
```

该探针在 debugger 中调用 `backtrace-to-string`，Emacs 进程 exit 139，
输出 C backtrace，包含 native `backtrace` / `cl-print` 加载路径。未获得
预期的离线报告，不能把这次诊断自身的崩溃视为原 decoder 必然崩溃，亦
不能据此断定 Emacs 根因。停止重试，不清理或扫描潜在 core dump。

后续建议仅在临时函数中比较“整函数绑定”和“只在 read-from-string
周围绑定 read-circle=nil”，使用固定正常/恶意响应，不调用 debugger
或 backtrace printer；验证循环 reader 语法仍被拒绝。得到证据后再决定
是否修改正式 decoder，并补充冷启动回归。当前没有应用正式修复。

### 19.6 动态绑定范围对照（2026-09-12）

用户授权继续测试后，新增 `tmp/decoder-scope-probe.el`。两个独立冷启动
emacs-twist 进程分别运行 `org-texmacs-scope-run` 的 `original` 与 `narrow`
分支；未启动 TeXmacs、未调用 debugger、未修改正式函数。每条命令 timeout
120 秒，进程均 exit 0，分别输出 `tmp/decoder-scope-original.log` 和
`tmp/decoder-scope-narrow.log`。脚本捕获各项异常，exit 0 不表示全部通过。

临时 decoder 唯一功能差异：把 `read-circle=nil` 从整个函数缩小为仅包围
`read-from-string` 调用。合法的转义 tag/中文响应在原版触发 `#7=`，窄绑定
版本返回 `(math "中文")`；错误序列后的合法响应在原版触发
`setting-constant nil`，窄绑定版本返回 `(sqrt "x")`。

两版都正确拒绝循环引用 `#1=...#1#`、共享引用、尾随 datum、错误请求 ID、
非法 stree 和未知 envelope；远端 error envelope 仍为 parse-error。
窄绑定版本通过这 9 项有效案例，表明修复方向无需放开 reader 安全限制。

测试缺陷：首个标为 normal 的固定响应多写了一个右括号，两版均正确拒绝，
但脚本错误地期待成功；所以两个报告的 all-pass 均为 nil。该项不作为产品
缺陷，也不计为通过。保留原脚本和报告以供复查；尚未修正并重新运行。
由于第一项在 envelope 校验就退出，合法转义响应仍是首次进入 pcase 分支。

结论：绑定范围对当前环境的失败有直接对照证据，建议正式修复仅将
`read-circle=nil` 限定于响应 reader。尚未确定触发错误的具体延迟加载函数，
不将此提升为 Emacs 内部根因已查明。正式修改前需修正探针输入，并在
授权后执行冷启动对照、真实 worker 及安全回归；当前仍未修改正式代码。

### 19.7 最小修复已应用并通过验证（2026-09-12）

用户授权最小修改及补充内容后，正式 decoder 已将 `read-circle=nil` 的
动态作用范围缩小为 `read-from-string` 调用。后续 envelope/stree 校验和
错误分派保持调用方设置；协议、返回值与循环引用拒绝策略不变。

新增三项 ERT：reader 内外的绑定范围（调用方为 t/nil 两种情况）、循环/
共享 reader 引用拒绝及错误后恢复、转义 tag/中文和远端错误后的恢复。
现有畸形响应 ERT 保留。临时 scope 探针的 normal 输入多余右括号已修正。
`original` 分支仍指向生产函数，因此此后运行它将测试修复后的生产版本，
不是重放旧实现。本次验证已更新 `tmp/decoder-scope-original.log` 与
`tmp/reader-boundary-repro.log` 为修复后的结果；旧失败事实保留在 §19.5–19.6
及此前命令输出中，不要用当前日志反推修改前行为。

用户授权后执行以下命令，均 exit 0，单条 timeout 120 秒：

```sh
timeout 120s emacs-twist --batch -L . --load tmp/decoder-scope-probe.el --eval '(org-texmacs-scope-run (quote original))'
timeout 120s emacs-twist --batch -L . --load tmp/reader-boundary-repro.el --eval '(org-texmacs-reader-probe-run)'
timeout 120s emacs-twist --batch -L . --load tests/ert/ert.el --eval '(ert-run-tests-batch-and-exit)'
timeout 120s nix flake check --no-write-lock-file path:/home/lingyu/Projects/org-texmacs
timeout 120s nix build --no-link --no-write-lock-file path:/home/lingyu/Projects/org-texmacs#default
```

* 冷启动生产 decoder 探针 10/10，通过正常/转义响应、恶意 reader 引用、
  envelope/stree 校验及错误后恢复，报告 `all-pass=t`。
* 独立真实 worker 首个请求成功，原始响应、reader-only 与 decode-replay
  一致；未再出现 `#7=` 或 `setting-constant nil`。该项不是仅看 exit 0，
  已核对报告中的 result 和 replay，均无异常记录。
* emacs-twist 全量 ERT 73/73，通过时间 33.58 秒（14:24:15–14:24:49 +0800），
  包含本次新增的三项回归。环境仍为 Emacs 31.1 / Org 9.8-pre。
* Nix flake check 与 default build 通过；检查仅限当前 x86_64-linux，
  未验证其他平台。未更新 lockfile、未建立 result 链接。
* `git diff --check` 通过；正式改动仅为 worker decoder 与 ERT，未暂存或提交。

这支持本次最小修复能消除已复现的失败，且保持 reader 安全约束；不宣称
Emacs 内部具体根因已完全定位。document native/编码前置验证仍待续跑，
不能因本次 decoder 验收通过而标为完成。

### 19.8 恢复 document 前置验证：native 成功与编码反例（2026-09-12）

用户确认提交后继续，已核对 HEAD 为
`1bb3abb fix(worker): limit read-circle binding to response reading`，工作区
干净。本阶段不新增正式功能，继续执行 §19.1 的 native 命令。

首次恢复运行：9 个字符串 parse 案例全部通过，两种 block 也解析成功；
后续独立 Scheme 脚本加载失败。原因是探针将未展开的 `default-directory`
保存在常量中，隔离 HOME 后再展开路径，导致路径错误地落到新 HOME 下。
内部等待达到 80 秒后清理进程，Emacs exit 255。这是临时探针问题，不是
TeXmacs native API 失败。仅将 `org-texmacs-probe-root` 改为在初始环境中
`(expand-file-name default-directory)`，经工具再次审批重跑同一命令成功。

最新 `tmp/document-boundary-native.log` 保存成功结果，覆盖此前同名报告；
TeXmacs 和 Emacs 均 exit 0，存在 `BOUNDARY complete #t`。实际版本与 §19.1
相同。未运行 export、PDF、view 或 `get-page-count`，未改正式代码。

**当前 parse 路径保持文本：**

* 9 个嵌套 `with/math/frac` 案例经真实 parser → adapter → stree 后 exact equal：
  ASCII、中文、α、`<alpha>`、`<#4E2D>`、`<less>`、`<gtr>`、Unicode/原生
  记法混合，以及引号/反斜杠。此结论限定于所测输入，不证明渲染语义。
* 原子字符串 block 返回 `"atomic"`；`document` 根 block 返回
  `(document (math "x"))`。发现与解析层无需禁止这些根；document lowering
  如何嵌入它们仍须明确，不能无条件 splice 根的 children。

**native 正文链：**

* 显式构造中文标题、段落、strong、math/frac、with 的正文 stree，递归
  `utf8->cork` → `stree->tree` → `buffer-set-body` → `buffer-get-body`
  → `tree->stree`，编码树 exact equal；递归解码后也与输入 exact equal。
* 同一 buffer 改写为 `(document "second")` 后回读一致。
* 故意向 `utf8->cork` 传入列表触发可捕获的 Scheme 错误，随后写入/回读
  仍成功；`buffer-close` 返回，记录 `closed #t`。未测试无效 buffer 句柄，
  未验证关闭后的资源枚举或多 session 隔离。
* 此正文存取案例不需要显式设置 style 或创建 view，不代表排版不需要样式。
  是独立 TeXmacs 进程内的固定 Scheme 实验，不是正式 socket 协议已有新操作。
* 全程没有 `.tm/.stm/.tmml` 中间文件。正文是手工构造的 target stree，
  不等于从 Org 自动 lowering 的完整端到端已经实现。

**编码反例与取舍：**

| 输入 | `utf8->cork` 结果 | `cork->utf8` 直接解释原生输入 |
|---|---|---|
| `α` | `<alpha>` | 原始 UTF-8 字节不能直接当 Cork 解码 |
| `<alpha>` | `<less>alpha<gtr>` | `α` |
| `<#4E2D>` | `<less>#4E2D<gtr>` | `中` |
| `<less>` | `<less>less<gtr>` | `<` |
| `<gtr>` | `<less>gtr<gtr>` | `>` |

普通 Unicode/ASCII 字符串的 11 项 encode/decode 文本往返均相等，但这
不能保证原生 STM 字符记法的语义。例如 `<alpha>` 编码再解码恢复相同
字面字符串，却不再代表原生 alpha 字符。这确认了 §18.2 的风险。
Guile `write` 对部分非 ASCII 字节混用直接输出和转义，报告外观不宜直接
交给 Elisp reader；相等断言在 Scheme 内计算，未使用输出文本重读来判断。

保留原流程的优点：现有 API 不提前转码、无需文件中转、编码仍集中于
native boundary。但不得再把“编码位置统一”写成“全部叶子无条件使用
同一转换函数”。普通 Org 文本需要字面语义，STM island 的原生记法需要
保留其语义；island 内还可能混有 Unicode，仅按来源选择整棵树跳过编码
也不足以解决问题。具体策略尚未授权决定，不修改现有 parser/返回约定。

**下一步建议：**先确定 Unicode 与原生记法共存的转换契约，优先只读寻找
TeXmacs 已有的相应转换接口，再以最小混合样例验证；不要在 Elisp 自写
完整编码器。可继续独立设计纯 lowering，但在这个契约固定前，不把
通用 native bridge 当成可直接落地的功能。Org object 后 tab 等 §19.2
未覆盖边界仍需补测，整体前置测试不标为全部完成。

### 19.9 TMML 与候选编码辅助函数测试（2026-09-12）

临时探针为 `tmp/encoding-api-probe.el` 与 `tmp/encoding-api-probe.scm`，结果
为 `tmp/encoding-api-results.log`。经审批执行：

```sh
timeout 120s emacs-twist --batch -L . --load tmp/encoding-api-probe.el --eval '(org-texmacs-encoding-probe-run)'
```

一个隔离 TeXmacs 2.1.5 进程，导入 `(convert tmml tmmltm)`，不联网、不写
文档中间文件。Emacs 31.1 / Org 9.8-pre；临时配置与本次进程已清理。
进程 exit 0 且 complete #t 仅表示遍历结束：每个案例 catch 异常，因此
不能当成整组成功。实际结果如下。

**TMML 直接转换：5 项匹配预期且 native tree 往返一致。**

* 普通字符串 `"<alpha>"` → `"<less>alpha<gtr>"`。
* `(tm-sym "alpha")` → `"<alpha>"`。
* `(tm-sym "#4E2D")` → `"<#4E2D>"`。
* `(tm-sym "unknown-symbol")` 原样形成 `"<unknown-symbol>"`；通过 tree
  往返不证明该符号有定义或可以渲染。
* `(!concat "中文 α " (tm-sym "alpha") " <alpha>")` 正确形成一个同时
  含中文编码、Unicode alpha、原生 alpha 和字面 `<alpha>` 的 native 字符串。

**XML → TMML stree → TeXmacs stree：6 项正常返回且 native tree 往返一致。**

* `<math>α</math>` 与 `<math><tm-sym>alpha</tm-sym></math>` 都得到
  `(math "<alpha>")`。
* `<math>&lt;alpha&gt;</math>` 得到 `(math "<less>alpha<gtr>")`，保持字面语义。
* Unicode、`tm-sym` 和转义字面尖括号可在同一个 math 内共存。
* `xml:space="preserve"` 保留测试中的前后空格和连续双空格；未指定时
  测得去除边缘空白并合并连续空格。因此引入 XML parser 会引入空白规则。
* 本实验使用 `parse-tmml`、`tmml->texmacs`、`stree->tree`；也可从结构化
  TMML stree 直接调用，无需落盘。TMML 不是任意 TeXmacs stree 的同义表示。

**`unescape-angles` 组合：未完成运行验证，且不应当作通用公开 API。**

导入 TMML 模块后的当前环境中 `(defined? 'unescape-angles)` 为 #f，16 个
叶子案例均记录 unbound-variable，没有取得候选组合结果。未自动重跑。
随后只读定位到 `progs/convert/latex/tmtex.scm:2253`：该函数用普通 `define`
定义在 LaTeX 转换模块内，对字符串依次将 `<less>` 替换为 `<`、`<gtr>`
替换为 `>`，对列表递归。不是此次环境已暴露的通用字符转换接口。
此前仅从调用处推测其作用并不充分，此处修正。

这个实现会取消全部尖括号转义，而不是识别/验证字符名。即便导入后可用，
也不能无条件用于普通 Org 文本；不能借此绕过字面文本/原生记法的语义选择。
本轮未复制其实现、未引入 LaTeX 模块依赖、未修改正式编码流程。

**设计意义：**TMML 已验证提供显式区分文本和符号的机制，可作为 native
bridge 的候选结构化转换边界或对照工具，不强制要求 XML 文件中转。但
现有 STM 字符串如何分解为普通文本与 `tm-sym` 仍未解决；不能说调用
`tmml->texmacs` 就会自动推断混合 STM 字符串的意图。需要先决定输入契约，
再判断采用 TMML 的额外映射是否值得。尚未验证 raw-data、属性编码、完整
文件文档和排版，不能把本次成功扩展为完整 exporter 的保证。

### 19.10 直接 STM 叶子转换候选验证（2026-09-12）

主链保持 Org AST + TeXmacs subtrees → lowering → TeXmacs 正文 stree → native
tree；本次不使用 XML/TMML 转换、不生成中间文档文件、不改正式实现。
探针 `tmp/stm-leaf-probe.el` / `tmp/stm-leaf-probe.scm`，结果保存在
`tmp/stm-leaf-results.log`。执行命令：

```sh
timeout 120s emacs-twist --batch -L . --load tmp/stm-leaf-probe.el --eval '(org-texmacs-leaf-run)'
```

首次导入 `(convert latex tmtex)` 后，`unescape-angles` 仍未公开可见，
Emacs exit 255，未进入转换案例。只读核对模块机制后，经再次工具审批，
探针用 `(module-ref (resolve-module '(convert latex tmtex)) 'unescape-angles)`
取得实际私有函数，未复制它的实现。第二次运行两端 exit 0，18 项断言
通过，failures=0、complete=#t。报告现为第二次结果，第一次失败在此留档。
版本与 §19.8 相同，隔离配置和本次进程已清理；没有进行排版或全量构建。

所测候选为 `unescape-angles(utf8->cork(s))`：

* 6 项 Unicode/ASCII（含中文、α、é、换行/tab、引号/反斜杠）得到与
  `utf8->cork` 相同的结果。
* 7 项原生记法保持原字符串：`<alpha>`、`<#4E2D>`、`<less>`、`<gtr>`、
  `<less>alpha<gtr>`、未知符号和多层显式尖括号转义。
* 混合 `中文 α <alpha> é <less>alpha<gtr>` 与独立构造的 native 预期一致。
* STM `<alpha>` 解码为 α；STM `<less>alpha<gtr>` 解码为字面 `<alpha>`；
  普通 Org `<alpha>` 只经 `utf8->cork` 后解码仍为字面 `<alpha>`。
* 两种来源组合为正文 tree，`stree->tree` → buffer 设置/回读保持 exact equal，
  最后关闭本次 buffer。这是手工构造的 target tree，不是完整 Org lowering。

补充观察：裸 `<`、`>`、`a<b>c`、未闭合 `<unfinished` 和未知符号均被机械
保留；不能视为合法字符记法或可渲染结果。对 é 的重复转换观察返回相等，
仅是一项数据，不证明普遍幂等，也不取消 native boundary 仅转换一次的约束。

日志注意：writer 直接输出 Cork 字节，而进程输出按 UTF-8 解码，é 等字节
在日志中显示替代字符。因此报告内 raw Cork 文本不是可无损重读的证据；
18 项相等判断在 Scheme 内完成。后续正式协议/探针若需要传回 native 字节，
应使用明确的字节安全表示；本次没有修改现有仅传输文本的 parse 协议。

结论：对“Org 普通文本保持字面语义，STM 文本保留原生记法、字面尖括号
使用 `<less>/<gtr>`”这一候选契约，直接转换已获得成功样例支持，无需
TMML 中转。尚未将该契约定为正式用户规则，尚未覆盖全部 tag/属性/raw-data。
私有 LaTeX helper 不应未经决策直接变成生产依赖；其转换行为与公共 API
的稳定性是两件事。纯 lowering 保留来源信息后，可在 native boundary
选择对应处理，不需改变现有 parse/subtree API 的返回值。

# TeXmacs Buffer 状态与同步边界

状态：2026-09-12 经审阅维护。正文和派生状态的归属作为当前设计边界；
局部增量同步仅为后续候选，不是当前实现节点的要求。

Org → TeXmacs 的主要转换目标是 `body` tree。完整文档/buffer 相关状态还
涉及 `style`、initial environment、`references`、`auxiliary` 及排版内部状态；
不要将这些都视为必须由 Org AST 转换并在一次请求中传入的节点。

其中：

- `body`：由 Org AST 与已有 TeXmacs subtrees 经新增 lowering 得到。
- `style` / initial environment：本阶段不做完整 Org 配置映射，但 native
  buffer 必需的初始化仍在范围内，须按实际接口需求验证。
- `references` / `auxiliary`：本阶段交给 TeXmacs 生成和维护，不由 Org
  lowering 直接重建。它们可能需要后续处理才能更新，不承诺正文设置后
  立即就绪，也不把正文回读成功视为引用、目录或分页更新完成。
- runtime typesetting state：TeXmacs 为增量排版维护的内部状态，不属于普通文档 tree。

因此，本阶段 Emacs → TeXmacs 的正文更新请求不必携带完整文件文档或
重建 `references` / `auxiliary`。这不是永久禁止相关 IPC：未来配置环境、
读取引用结果或保存完整文档时，可以另行设计相应操作。

证据边界：官方 [TeXmacs 格式说明](https://www.texmacs.org/tmweb/manual/webman-format.en.html)
说明 references 可能需要多次处理，auxiliary 通常可以重新计算。
本机 §19.8、§19.10 仅验证正文存取，不验证这些派生状态完成更新。

需要区分两种同步方式：

```text
整体同步：
Org AST
  → complete body tree
  → buffer-set-body

增量同步：
Org source / derived tree change
  → tree modification
  → existing active tree
```

反复整体替换 `body` 可能影响节点身份及部分增量排版状态的复用；局部
tree modification 是值得后续评估的方案。但目前没有整树替换与局部
修改的对照性能测试，也未证明具体哪些缓存会丢失、性能差异有多大。
不得从 persistent buffer 或局部修改可用，推出增量 typesetter 缓存必然复用。

当前阶段采用显式整正文更新，保持本次 session 的 buffer 存活：

```text
initial sync:
  complete body tree

subsequent sync:
  complete body tree → buffer-set-body
```

不引入实时 edit hook、Org live AST 替换或自动增量同步。整体更新的正确性
先独立验收；保留后续优化余地，不为尚未证明的性能收益增加同步协议。

局部更新若进入后续计划，需要单独验证：source 变化到目标 tree 的映射、
插入/删除后的路径有效性、过期结果拒绝、失败后的全量恢复，以及实际
工作负载下的正确性和性能收益。局部修改失败不得使源文件或 session
悄然失去一致性；具体恢复协议留待该阶段设计。

TeXmacs 侧负责管理下列状态，但它们的更新时间和可读取时机仍需按使用
场景验证，不能将“负责管理”解释为立即同步完成：

```text
body active tree
references
auxiliary
runtime typesetting state
```

# 新增观察

用途：把新的事实、疑问、外部实验放在此节，先保留，再审阅。
已审阅的 buffer 状态观察已整理到上面的专题，后续关联观察引用该标题。
以下为可复制模板，不代表已有待办：

```markdown
## OBS-YYYY-MM-DD-01：观察标题

- 状态：待审阅 / 已审阅 / 已纳入设计 / 已被替代。
- 原始观察：……
- 来源与证据：本机测试 / 外部报告 / 源码或文档 / 推测；路径或链接。
- 环境与复现：版本、命令、输入和输出；未提供的注明待补充。
- 已知限制：哪些情况尚未验证。
- 希望讨论的问题：……
- 审阅结论及去向：待补充；采纳后链接设计/测试章节或计划 ID。
```

# 计划提案

用途：把新增目标或实现方案放在此节；已确认的 document lowering 节点
仍以交接文档 §18 为入口，不在此重复整份计划。
以下为可复制模板，不代表实现授权：

```markdown
## PLAN-YYYY-MM-DD-01：计划标题

- 状态：待讨论 / 已采纳待授权 / 实施中 / 已完成 / 暂缓 / 已被替代。
- 目标与不做的内容：……
- 依据：关联观察 ID、已验证事实或用户需求。
- 对现有设计的影响：兼容 / 扩展 / 替代；列出相关章节。
- 分节点方案：每个节点包含实现与对应测试，可独立验收和整理提交。
- 成功标准与风险：……
- 待决定事项：……
- 授权与进度：仅记录实际获得的操作范围，不从采纳推导授权。
- 结果及去向：实现提交、测试记录或替代计划；未完成则明确说明。
```

## PLAN-2026-09-12-01：Headline metadata 表示与 Org 导出配置接入

- 状态：6b 已完成并提交；完整 export environment 接入尚未实施。

### 确认决策（优先于下方讨论稿中的待决定事项）

- 参考本机 `ox-latex` 的 policy/presentation 分离、六参数 formatter、INFO
  通道与多次调用语义；不复制字符串 transcoder、完整导出预处理或子树筛选。
- formatter 签名为 `(todo todo-type priority title-parts tags info)`，返回
  一个文本 title stree。lowering 先应用 policy，被省略字段传 nil；TODO
  关闭时 todo-type 也为 nil。固定 sectioning 结构不交给 formatter 决定。
- 包内默认 formatter 必须无副作用；推荐用户 formatter 同样如此，但不
  对自定义 Lisp 函数防破坏或检测副作用。不保证调用次数，预检和最终转换
  均可能调用。正常校验并复制返回 stree，维持结果不共享可变源数据的契约。
- 6b 从标准 `org-export-with-todo-keywords`、`org-export-with-priority`、
  `org-export-with-tags` 读取当前值，默认值沿用 Org（t、nil、t）。
  `not-in-toc` 在当前正文标题中显示 tags；没有 TOC，不提供其输出。
  INFO 使用对应标准键及 `:texmacs-format-headline-function`，不新增平行变量。
- 输出 policy 和选定 formatter 固定为本次转换快照，随后配置改变只影响
  下次转换；源文本与有效解析配置继续变化检测并拒绝过期结果。
- priority 复用 `org-priority-to-string`，显式 tags 复用
  `org-make-tag-string`。不继承 tags；所有标题新增文本按 Org literal 编码。
- 后续独立节点再接 `org-export-get-environment`、`#+OPTIONS`、优先级、
  BIND/SETUPFILE 边界及 keyword 消费规则。6b 加载 ox 以取得标准配置，
  但不调用导出环境获取或导出流水线，不承诺已支持文件内导出选项。
- 原三个 `org-texmacs-document-with-*` 变量提案已被替代。
- 6b 实施及三条验证命令均已分别获授权并完成，结果见下方记录。
  本次只维护完成状态，不据此推导后续节点的实施或运行授权。

- 目标与不做的内容：
  - 在已完成的 6a“有效标题解析配置传递”基础上，实现 headline 中已识别的 TODO keyword、priority、显式 tags 的 TeXmacs 表示。
  - 区分“是否输出某项 metadata”的 Org export policy 与“输出后如何表示”为 TeXmacs tree 的 presentation policy。
  - 为 headline presentation 提供可替换 formatter，默认 formatter 直接返回 UTF-8 TeXmacs title stree。
  - 不在本节点实现 COMMENT、archive、task filtering、TOC、文档 title、Babel、INCLUDE preprocessing 或其他会改变 subtree 选择/文档整体结构的 export 行为。
  - 不新增一套与 Org 平行的 `org-texmacs-document-with-*` 配置体系。
  - 不让 formatter 决定 headline 对应 `section` / `subsection` / `subsubsection`；该 structural lowering 规则保持固定。

- 依据：
  - 6a 已确认并传递 `org-todo-regexp`、`org-done-keywords`、`org-priority-regexp`、`org-odd-levels-only` 的有效值，私有 parser 可以正确识别自定义 TODO/DONE、priority 和有效标题层级。
  - 当前 `org-texmacs-document-*` 的职责是将 Org AST + TeXmacs islands lower 为 TeXmacs-shaped stree，而非直接承担文件导出。
  - TODO keyword、priority、tags 在 lowering 之后不再具有 Org metadata 语义，因此其 TeXmacs 表示必须在 document lowering 层完成。
  - 用户要求 `org-texmacs` 不游离于 Org 之外；后续 `#+OPTIONS`、`org-export-with-*`、`with-toc` 等标准 Org export policy 应能够控制最终 TeXmacs 输出。
  - `ox-latex` 可借鉴的边界是：standard export options 决定“是否输出”，backend formatter 决定“如何表示”；不借鉴其字符串式 transcoder 输出。
  - 已验证 rich title 应作为 sectioning tag 的唯一 title child；多个 inline parts 最终只包一层 `concat`。
  - 已验证 inline `:post-blank` 属于 Org 语义，必须由 lowering 保留。

- 对现有设计的影响：
  - 扩展。
  - 保持 6a parser snapshot、document result、STM provenance、native encoding/session 分层不变。
  - 扩展 document lowering，使 headline metadata 可以根据显式 options snapshot 参与 title construction。
  - 新增 headline presentation customization point，但不改变既有 block/fragment API、session API 或 native encoding contract。
  - 后续 Org export-option integration 应复用同一 options/info 通道，不另建平行配置。

- 分节点方案：

  1. 定义 headline presentation formatter 契约

  - 实现：
    - 新增可配置 formatter，例如：
      ```elisp
      org-texmacs-format-headline-function
      ```
    - 提供默认实现：
      ```elisp
      org-texmacs-format-headline-default-function
      ```
    - formatter 固定接收 headline 已解析 metadata、已完成 inline lowering 的 title parts，以及一次转换使用的 options/info snapshot。
    - formatter 返回一个 UTF-8 TeXmacs stree，作为 `section` / `subsection` / `subsubsection` 的唯一 title child。
    - formatter 不执行 source parsing、不读取 live buffer 状态、不调用 worker、不做 native encoding。
  - 测试：
    - plain title、rich title、空 metadata。
    - 自定义 TODO/DONE keyword。
    - TODO type 为 todo/done 时默认 formatter 不引入不同颜色或额外结构。
    - formatter 输入与返回值不共享可修改字符串。
    - 自定义 formatter 可替换默认实现，并保持 sectioning structure 不变。

  2. 实现默认 headline metadata 表示

  - 实现：
    - 默认 formatter 将参与显示的 metadata 与 title parts 组成一个扁平 title-parts 序列。
    - 已识别 TODO keyword 默认表示为：
      ```scheme
      (strong "KEYWORD")
      ```
    - priority 使用 Org 已解析结果形成字面表示，例如：
      ```text
      [#A]
      [#12]
      ```
    - tags 仅使用 headline 自身显式 tags，保持原顺序，形成字面：
      ```text
      :tag1:tag2:
      ```
    - metadata 与 title 之间使用明确空白分隔。
    - 最终：
      - 1 个 part：直接返回；
      - 2 个及以上 parts：只包一层 `(concat ...)`。
    - 不做相邻字符串 canonicalization。
    - 所有新增字面文本继续按普通 Org literal 来源进入后续编码阶段。
  - 测试：
    - TODO + priority + rich title + 多 tags 的组合。
    - 单独 TODO、单独 priority、单独 tags。
    - 字母和数字 priority。
    - 自定义 TODO/DONE keyword。
    - rich title 不产生嵌套 `concat`。
    - metadata 前后空白与原 title `:post-blank` 语义正确。
    - explicit tags 不发生 inheritance。
    - 输入 AST/document snapshot 不被修改。

  3. 接入显式 export-policy snapshot

  - 实现：
    - document lowering 不直接读取动态全局变量，而从一次转换固定的 options/info snapshot 中读取：
      ```elisp
      :with-todo-keywords
      :with-priority
      :with-tags
      ```
    - `nil` 仅表示不显示对应 metadata，不过滤 headline 或正文。
    - formatter 仍获得 metadata 本身及 INFO；是否将某项 metadata 传入默认 presentation 由 effective policy 决定。
    - 为后续 `:with-toc`、`:with-title`、task filtering 等保留同一 options/info 通道。
  - 测试：
    - 三项 policy 的全部组合。
    - policy 关闭时只省略相应 metadata，不影响 title/body。
    - 转换开始后配置变化不影响当前 snapshot；现有等待期间一致性检查继续生效。
    - 自定义 formatter 与 policy 组合行为明确：包传入的参数中，被 policy
      省略的 metadata 为 nil；不控制用户函数主动读取 live 配置的行为。

- 成功标准与风险：
  - 成功标准：
    - 6a 能正确识别的 TODO/DONE、priority、显式 tags 均能在不破坏 rich title 的情况下 lower 为稳定 TeXmacs title stree。
    - headline structural mapping 与 presentation customization 相互独立。
    - metadata 显示策略通过显式 options/info snapshot 控制，不形成 `org-texmacs-document-with-*` 平行配置体系。
    - 默认 formatter 可替换，且 custom formatter 不需要了解 Org parser 或 TeXmacs worker/session。
    - 既有严格 unsupported-node 行为保持不变。
  - 风险：
    - 当前 document API 尚不是完整 Org export backend；本节点只建立可接入标准 Org export policy 的接口，不等同于已经支持 `#+OPTIONS` 或所有 `org-export-with-*` 来源。
    - TODO/tags/priority 的 presentation 与 subtree filtering 必须继续保持分离，避免后续实现 task/archive/COMMENT 时复用错误语义。
    - formatter API 一旦公开，参数和返回值契约需要尽量稳定。

- 已决定事项：
  - formatter 签名、INFO 键、Org helper 与副作用约定均按上方确认决策实现。
  - 6b 已读取三个标准 `org-export-with-*` 变量；文件内选项及完整 export
    environment 获取留到后续独立节点，不把“读取标准变量”说成完全未接入 Org。

- 授权与进度：
  - 6a 已完成并提交：`fbe3fd8 feat(document): preserve effective Org heading parser settings`。
  - 6b 已提交：`8649f85 feat(document): format headline metadata with Org output policies`。
    已新增默认 formatter、可替换函数选项和标准
    Org 输出选项快照，并接入预检与最终 lowering。未调用 export environment。
  - 调整既有 TODO/priority 拒绝测试，新增 policy 组合、formatter 返回值与
    复制、输出快照、显式 tags、keyword 边界和 native literal 编码测试。
  - README 更新配置示例及接口说明；`git diff --check` 通过。
  - 授权验证全部通过：`emacs-twist` 125/125 ERT（67.37 秒），当前
    x86_64-linux 的 7 项 Nix checks 与独立构建通过。其他平台未验证。
  - 提交前审阅未发现阻塞问题；提交由用户完成。

- 结果及去向：
  - 6b 完成；formatter API、默认 presentation 与 options snapshot 已记录在
    README 和确认决策中，验证见上。
  - COMMENT、archive、task filtering、TOC 及完整 Org export environment integration 若未在本计划中实施，应继续作为独立后续计划处理。

### 后续工作边界

6b 已完成，不把后续 effective configuration 接入作为欠账。
此前将标准 Org export environment/文件内选项接入列为 v0.2.0 下一项的
安排，已由用户确认的下列 PLAN-2026-09-12-02 修订版替代。

v0.3.0 再研究 `org-export-get-environment`、`#+OPTIONS`、BIND、
SETUPFILE、subtree properties、metadata/style/initial/references 等文档
语义；需明确副作用与支持边界，不自行重写 Org 选项 parser。
v0.4.0 再接入 Org export pipeline、serialization、文件导出及 PDF。
以上为版本方向，不是各版本全部功能的已验证承诺或直接执行授权。

## PLAN-2026-09-12-02：v0.2.0 Document AST 与 Native Session 收尾

- 状态: 节点 0--5 已完成, 用户已提交并创建本地 v0.2.0 tag.
  本计划保留为已完成版本的范围与验收记录, 不作为后续功能的自动授权.
- 基线：`8649f85 feat(document): format headline metadata with Org output policies`。
  已有基线记录为 125/125 ERT、当前 x86_64-linux 的 7 项 Nix checks
  与独立构建通过，不作为本计划新增行为的验收。
- 主包与 Nix 版本为 0.2.0. 最终验证及 tag 核对结果见本计划末尾.

### 固定目标与边界

主链保持：

```text
Org buffer
→ 私有 Org AST + TeXmacs islands + 固定转换上下文
→ UTF-8 body stree + stm-paths
→ native encoding
→ TeXmacs native body/session
```

- 新增 italic、underline、strike-through、code、verbatim、line-break，
  五种自包含 URI 链接，以及匿名行内脚注。
- 公开 `org-texmacs-document` 仍从当前 Org buffer 构造正文；不新增
  公开 combined AST 或 `(AST, INFO)` API，不修改 Org live AST。
- 内部 lower 的输入继续包含 AST、island 映射、精确 post-blank 和固定
  INFO；document result 仅保存 body/stm-paths，不保存 INFO 或源 buffer。
- INFO 保留 6b 的四个键及现有变量来源；本轮不接入 `#+OPTIONS`。
  输出选项和 formatter 后续变化只影响下一次调用；source/有效解析配置
  在等待期间变化仍按过期输入保护处理。
- 保持单 worker、单 active session，不扩大 STM discovery 的上下文。
- 普通 Org 叶子保持 literal semantics，STM 叶子保持 source semantics；
  provenance 在 native encoding 完成之前不得丢弃。
- 不生成 `.tm/.stm/.tmml` 中间文档；不等于禁止 socket 或临时配置。
- 未支持节点明确报错，不静默忽略或退化成文本。

本轮不新增 lists/tables/images/src-block/其他 block lowering；相应内容可
继续由用户手写 TeXmacs block。完整文档模型、effective configuration、
metadata、style/initial、references/citations 留到 v0.3.0 另行设计，
Org export integration、serialization、文件导出/PDF 留到 v0.4.0。

**文件链接取舍：**本轮不支持 `file`。自包含 URI 可以局部映射为 hlink，
文件链接却涉及文档位置、相对路径基准、导出位置和资源定位语义。因此不
引入 `default-directory` snapshot、路径展开、远程文件区别或目标检查。
Org 自身已经识别隐式文件链接；本包按 `:type "file"` 拒绝，不重新识别。
后续 document/export model 再确定语义，不提前承诺绝对化策略。

### 分节点实施与验收

0. **维护规划与必要探测（已完成）**
   - 用本机 Org/TeXmacs 源码核对候选映射、实际 AST 属性、空白和上下文。
   - 经授权用 `emacs-twist` 分开进行 Org 与 native 探测；记录命令、
     输入、输出、失败和未覆盖范围。候选标签被 stree->tree 接受本身
     不证明语义正确，须结合原生定义/转换器/菜单证据。
   - 覆盖五种 link 的 type/path、Unicode、百分号和查询参数，核对私有
     解析 buffer 与源 buffer 的结果及必要的解析配置传递。
   - 固定映射表和回归样例之后才进入实现；无法确认的映射停止报告，
     不自行换成有损表示。

1. **基础 inline lowering**
   - 先处理下文「AST-first 空白语义修订」：普通正文不以源字符逐个往返
     为验收标准，空白语义由 Org lowering 决定，不由 encoder 猜测。
   - italic/underline/strike-through 递归处理子内容；code/verbatim 从
     `:value` 读取普通 Org 字面文本，不扫描内部 STM。
   - 显式 line-break 使用验证后的原生节点，不混同普通 source 换行或
     段落边界；标题中的显式换行本轮拒绝。
   - 统一扩展精确 post-blank 收集与输出，保留 spaces/tabs；不让每个
     handler 各自补空格。保留复制、循环检测、provenance 及输入不变性。
   - 对新增调用 API 显式检查基本存在性，不增加泛化兼容框架。
   - 纯 ERT、源文本集成和 native 回读通过，原 bold/headline/islands
     行为不变。

2. **自包含 URI 链接**
   - 内部常量 `org-texmacs--supported-link-types` 保存字符串列表
     `'("http" "https" "mailto" "ftp" "ftps")`；不新增 defcustom，
     不从全部 Org 已注册类型自动扩充。
   - 按 Org link 的 `:type` 准入，用 `:type`/`:path` 构造 URI；
     不重新解析源字符串或 `:raw-link` 猜类型，不重复转义。
   - 有描述则递归转换描述，无描述则显示 URI；目标与显示内容分离，
     使用实测确认的 hlink 参数结构。
   - 不调用 export 协议回调、下载/打开目标或自动嵌入图片。file、
     内部引用及其他类型明确拒绝；不新增文件路径上下文。
   - 每种类型单独测试，覆盖描述/无描述、富文本描述、Unicode、
     百分号、查询参数及显式/隐式 file 拒绝分支。

3. **匿名行内脚注**
   - 仅接受 `:type 'inline` 且 `:label nil`，作为 paragraph 的直接
     子对象。正文支持本轮普通 inline 子集，不扩大 STM discovery。
   - 命名/重复引用、独立定义、嵌套脚注，以及标题/强调/link 描述中的
     脚注明确拒绝；不自行生成文档级编号或照搬 LaTeX 延迟输出。
   - 使用实测原生表示，保留空白；相邻脚注不套用 LaTeX 分隔符。
   - 测试连续脚注、中文、强调、code、link 和非法上下文。body 回读
     成功不宣称完整排版/编号验收。

4. **端到端与安装闭环**
   - 复验 ASCII/中文、Org literal 与 STM native `<alpha>`、多 islands、
     block/fragment 混合、新增 inline、repeated set-document、open/close、
     worker 异常/重启、旧句柄失效、request-local 恢复和输入不变性。
   - 使用独立 native 预期和实际回读，不仅比较两次生产 encoder 输出。
   - 冷启动为全新 batch Emacs、无已有 worker、隔离临时 TeXmacs 配置，
     不清空用户配置，不拿热 worker 结果作冷启动证据。
   - 扩展现有安装探针，验证八个 Lisp 模块及相邻 Scheme 文件，加载
     安装产物而非 checkout。覆盖既有本地/use-package、straight、Nix；
     不新增 package.el 分发归档或发布渠道。
   - 本节点通过前保持版本号 0.1.0。

5. **发布收尾**
   - 按 git-maintenance 保守更新 README，保持现有语言/结构，列明
     支持子集、链接/脚注限制、INFO、body/full document 区别、encoding/
     provenance 和 session lifecycle；内部常量不是用户配置项。
   - 同步示例与测试；逻辑和安装通过后再将主包/Nix 版本改为 0.2.0，
     核对描述和安装清单，并在最终状态重跑发布验证。
   - 审阅无阻塞后建议发布；用户完成 commit/tag/push/发布，agent 不代执行。

### 验证与提交节奏

每个实现节点包含实现、正式测试和必要 API 文档，独立通过 ERT 与 Nix
checks/build 后审阅；用户整理提交后再继续下一节点。提交信息根据实际
staged diff，按 git-maintenance 拟定，不预先生成或把临时探针当正式覆盖。

发布验证命令（运行前逐轮申请授权）：

```sh
timeout 120s emacs-twist --batch -L . -l tests/ert/ert.el -f ert-run-tests-batch-and-exit
timeout 120s emacs-twist --batch --load tmp/release-install-check.el --eval '(org-texmacs-install-test-run (quote local))'
timeout 120s emacs-twist --batch --load tmp/release-install-check.el --eval '(org-texmacs-install-test-run (quote straight))'
timeout 120s nix flake check --no-write-lock-file path:/home/lingyu/Projects/org-texmacs
timeout 120s nix build --no-link --no-write-lock-file path:/home/lingyu/Projects/org-texmacs#default
```

测试可能启动 worker、创建 socket、日志和临时配置；安装检查写构建产物；
Nix 可能联网和写缓存/store。不访问链接目标、不更新 lockfile；超时报告，
不自动重试或放宽 timeout。运行授权不从此前任务继承。

### 实现原则与完成标准

参考 ox-latex 的 Org 语义分层、递归内容/字面内容区分、目标/描述分离、
上下文处理和统一 INFO；不引入 LaTeX escaping、完整 exporter 或静默降级。
包内部 formatter 必须无副作用，推荐用户同样如此，但不隔离或检查用户函数。

v0.2.0 完成意味着有限 Org 正文子集稳定转换为带 provenance 的 TeXmacs
body AST，并通过既有 native session 使用；不是完整 exporter，也不提前
决定文档位置与资源解析语义。

### 节点 0 当前记录（2026-09-12）

- 已完成：计划维护；只读确认 HEAD 与干净 worktree；核对 Org link
  parser 以 `:type`/`:path` 表示 URI，并分离 file 的 application/search。
- 源码候选（不是本轮运行结果）：TeXmacs 2.1.5 的 std-markup.ts 定义
  em、underline、strike-through、verbatim；format-menu.scm 区分
  next-line（New line）与 new-line（New paragraph）；htmltm.scm
  使用 `(hlink BODY TARGET)` 并将 HTML br 转为 next-line。
- 本轮已获授权并各执行一次 Org/native 探测，命令与结果见下；未执行
  正式 ERT 或 Nix 构建，失败后未重跑。
- 已执行的探针：`tmp/v020-inline-probe.el` 与
  `tmp/v020-inline-probe.scm`。Org 探针记录实际 AST 和局部链接缩写的
  私有解析差异；native 探针仅检查候选正文的编码/存取，不激活链接，
  不启动 socket 服务，不将这些观察当作完整排版验证。
- 未修改：正式包实现、正式 ERT、README、版本号和 Git index。

#### 首轮探测结果（2026-09-12）

环境：Emacs 31.1、Org 9.8-pre；native 进程为
`/nix/store/52iz92ini64qhnrsfwyxaid74rwcsb5r-texmacs-2.1.5/bin/texmacs`，
启动输出确认 TeXmacs 2.1.5。下列命令均获本轮授权并执行一次：

```sh
timeout 120s emacs-twist --batch -L . --load tmp/v020-inline-probe.el --eval '(org-texmacs-v020-probe-org)'
timeout 120s emacs-twist --batch -L . --load tmp/v020-inline-probe.el --eval '(org-texmacs-v020-probe-native)'
```

Org 探测退出 0，输出 `ORG observations complete`。这是观察矩阵完成，
不是所有候选都符合预期或已有正式实现：

- italic/underline/strike-through 有递归 contents；code/verbatim 内容来自
  `:value`。对象后的 space/tab 计入 `:post-blank`，仍须从原 source
  slice 恢复精确字符，不能用空格计数代替。
- 显式双反斜杠行末产生 line-break；普通换行保留为 plain-text。
- 匿名脚注是 `footnote-reference`、`:type inline`、`:label nil`，
  正文在 contents；命名 inline/standard 和独立 definition 可区分。
  嵌套脚注及强调内脚注确实可生成对应节点；`[fn::]` 生成空 contents。
- 此次 link description 中的 `[fn::note]` 样例并未生成脚注对象，而是
  文本和残余右括号。拒绝非法上下文针对实际 AST 对象，不自行扫描
  描述中的字面文本寻找脚注语法；source fixture 与手工 AST 测试须分开。
- http/https/mailto/ftp 在本次 bracket、angle、plain 样例中识别为
  各自 `:type`。但 ftps bracket 是 `fuzzy`，angle/plain 留作文本。
  因此当前默认环境不能凭类型允许列表实现 ftps；不能重新解析 raw-link
  绕过 Org，也不能把 native hlink 存取通过当作 Org ftps 支持。
- `[[HTTPS://example.org]]` 保留 `:type "HTTPS"`；大小写准入策略尚须
  在链接节点确定，不假设 Org 自动转换成小写。
- 已测 https 的 `%20`、`%26`、`&`、中文及 `#part` 保留在 `:path`。
  file 显式、隐式及 application/search 均由 Org 分离属性，继续不支持。
- 合成 buffer-local 链接缩写在源 buffer 中展开为 https；未复制设置时
  私有 buffer 得到 fuzzy，复制 `org-link-abbrev-alist-local` 后紧凑 AST
  相等。该测试未覆盖其他 parser 配置或用户回调，不等于配置传递已完整。

Native 探测：TeXmacs 子进程退出 0，12 项均完成，无 case-error；但输出
`V020 complete #f`，外层 Emacs 按设计退出 255，不能记为整体验证通过。

- 全部 12 项编码树经 `stree->tree → buffer-set-body → buffer-get-body →
  tree->stree` exact equal。包含 em、underline、strike-through、verbatim、
  next-line、五种 URI 的 hlink、rich footnote 和相邻 footnotes。
- 其中 11 项递归 `cork->utf8` 后与 UTF-8 输入相等。
- 唯一反例是 `(verbatim "a  b\t<alpha> *literal* 中文")`：编码树回读相等，
  但解码后的 tab 显示为 `¯`，其余字符保持。当前只能断言这条普通 Org
  编码/存取/解码链不满足该输入的文本 round-trip；不能据此定位为 session
  改树、verbatim 标签缺陷或仅 decoder 问题，也不能声称视觉 tab 语义正确。
- 测试未激活链接、未联网读取目标、未导出文档；不证明链接跟随、脚注
  编号或排版。隔离配置位于本次新建 tmp 子目录，进程正常退出，脚本已
  清理该次目录；未清空用户配置或其他 tmp 文件。

下一步必要补测（尚未执行、需新授权）：

1. 通过 Org 原生类型注册/正则生成 API 验证 ftps 的受限解析环境，比较
   source 与 private buffer，并检查是否污染全局或改变 fragment discovery。
   源码确认 `org-link-set-parameters` 新增类型会调用 `org-link-make-regexps`
   和 `org-element-update-syntax`，不能未经隔离验证就直接在包加载时注册。
2. 对普通叶子与 verbatim 分别检查 tab 的 UTF-8→native 字节、解码结果，
   并比较原生 literal/source-code 转换接口及标准表示；不在未定位前
   修改正式 encoder 或用替换空格掩盖反例。

节点 0 尚未完成；五种链接范围未擅自缩减，映射也未升级为已实现承诺。

#### 第二轮补测准备与结果

- 用户要求继续定位；本轮只读核对并准备
  `tmp/v020-boundary-probe.el`、`tmp/v020-tab-probe.scm`，没有修改正式实现。
  既有临时 native 启动函数新增可选 Scheme 文件参数，默认仍运行原探针。
- Org 源码进一步确认 `org-element-update-syntax` 调用
  `org-element-cache-reset 'all`。补测动态隔离 link parameters、链接正则
  和 element 正则，用原生 `org-link-set-parameters` 注册 ftps，记录真实
  cache-reset 调用，并比较 source/private AST、fragment discovery 和
  离开作用域后的状态。即使绑定恢复，也不能据此否认 cache reset 副作用；
  该实验不等于批准包加载时修改全局注册。
- TeXmacs `progs/convert/rewrite/init-rewrite.scm` 定义
  `code-snippet->texmacs`，通过 `SourceCode` encoding 调用原生 verbatim
  snippet 转换。补测比较 utf8->cork、code-snippet 与 UTF-8 verbatim
  转换，记录叶子字节、解码文本、普通 concat/verbatim 的 native 回读。
  同时检查 native 字节 9/10/32 的直接解码，以定位 tab 反例发生的层次。
- 所有输入固定，不读取目标链接或导出文件。此次仅准备脚本；下列两条
  命令需获得新授权后各运行一次，不沿用上一轮已用完的运行授权：

```sh
timeout 120s emacs-twist --batch -L . --load tmp/v020-boundary-probe.el --eval '(org-texmacs-v020-probe-links)'
timeout 120s emacs-twist --batch -L . --load tmp/v020-boundary-probe.el --eval '(org-texmacs-v020-probe-tabs)'
```

以上两条命令随后获用户明确授权，各执行一次；均退出 0，无超时或重跑。
环境仍为 Emacs 31.1 / Org 9.8-pre / TeXmacs 2.1.5。

**ftps：**

- 注册前两个 bracket 对象是 fuzzy；注册后 bracket/angle/plain 和带描述
  的 bracket 共四个对象均为 `:type "ftps"`，`:path "//example.org/a"`。
- source/private 观察结果相同，fragment discovery 在本次样例中始终
  只返回 `(math "visible")`，未进入 link description。
- 退出动态绑定后 syntax state、源文本及解析结果均恢复，三个检查为 t。
- 真实记录 `resets=((all))`：变量隔离不能阻止原生注册函数的全局 cache
  reset。因此该探针证明可识别，不证明可直接用于无全局副作用的转换层。
  后续仍需确定受限私有解析环境的构造方式；不采用包加载时全局注册。

**tab / native 字节碰撞：**

- `utf8->cork("\t")` 是字节 9，直接 `cork->utf8` 得到 `¯`；
  `utf8->cork("¯")` 同样是字节 9。因此不能只把 decoder 的字节 9 改回
  tab：编码后已经不能区分两种来源。普通 concat 和 verbatim 均复现，
  native 写入/回读保持相同字节，排除本次 session 存取改树导致的解释。
- 换行也需处理：`utf8->cork("a\nb")` 保留字节 10，直接解码为
  `a˙b`；native 字节 10 的直接解码为 `˙`。本轮没有运行 Unicode `˙`
  的正向碰撞测试，不将其记为已测。
- 原生 `code-snippet->texmacs` 将 tab 展开为空格：单 tab 为 8 个空格，
  `a\tb` 为 a + 7 个空格 + b；`中文\t<alpha>` 为中文 + 2 个空格 +
  字面 `<alpha>`。这些只是本次列位置样例，不保证符合 Org 的 tab 语义。
- 该 SourceCode 接口也把字面 `¯` 转为 8 个空格，不能直接取代普通 Org
  叶子编码；它将 `a\nb` 转为 `(document "a" "b")`，还改变树结构。
  不能在现有 leaf encoder 中直接使用而忽略 paragraph 和 provenance 路径。
- 显式 UTF-8 verbatim 接口对所测中文保留 UTF-8 字节，按 Cork 解码得到
  不同文本；字面 `¯` 也未得到预期 Cork 表示，不作为 universal encoding
  的替代接口。本次观察不宣称该接口自身错误，只说明不符合此处输出契约。
- 普通双空格和字面 `<alpha>` 的对照通过。所有记录的 native 回读保持
  输入的 native 树一致。`V020 complete #t` 表示观察全部完成，无 API
  异常，不表示所有候选转换满足语义或 node 0 验收完成。
- 个别日志 key 使用 Scheme `write` 输出 UTF-8/control 字节时显示不完整；
  字节列表与专用 writer 输出的 source/decoded 字段可核对，不能将日志
  key 显示问题解释为 native tree 改动。

**对实现计划的影响：**新增一个节点 1 前的控制字符语义决策点。必须在
编码前仍保有来源时，明确普通 Org 换行/tab 的目标表示；不能在编码后恢复，
不能把所有 raw tab 无条件替换为空格或直接调用 SourceCode 转换掩盖碰撞。
现有正文也可能包含换行/tab，因此问题不限于新增 code/verbatim；需要作为
v0.2.0 native boundary 的前置修正另行拟定最小方案与回归，不扩大到文件
序列化或排版实现。本轮未修改正式 encoder、未新增拒绝规则或更改原计划
的空白语义，也未运行正式 ERT/Nix。隔离进程已退出，本次临时配置已清理。

#### AST-first 空白语义修订与节点 0 收尾

用户提出参考 LaTeX 对普通空白的处理，并明确要求继续保持 AST 为第一性。
据此收敛以下方向，不再以普通正文 source 空白逐字符 round-trip 作为目标：

- 借鉴 ox-latex 的语义分层，不生成 LaTeX，也不调用完整 Org exporter、
  HTML/TMML 转换或文件序列化。主链仍为 Org AST → TeXmacs body AST。
- 普通正文、标题、强调及 link 描述中的普通 space/tab/软换行，在 Org
  lowering 中按正文语义归一；连续普通空白作为一个词间空格处理，paragraph
  结构表达段落边界，显式 line-break 表达 next-line。不以 native decoder
  恢复源文件格式，也不因源文件排版不同而生成重音字符。
- 必须根据 AST 上下文处理，不能对 raw Org source、所有 leaf 或整棵
  TeXmacs stree 无条件正则替换。URI target、STM subtree、特殊空白字符
  不套用普通正文规则；code/verbatim 的空白契约单独确定，不凭名称等同
  完整预格式化块。
- 归一化须保留跨普通 inline 对象的词间分隔，不能逐叶子 trim 导致
  `a *b* c` 连接成无空格文本；不能穿过 STM 根改变 foreign AST。
- 准备层可继续保留精确 source/post-blank 作为输入证据；目标 body 不必
  复制原字符数量。已有“保留 paragraph 换行”和精确目标 tab 的断言应在
  实现该节点时同步修订，不修改源 buffer 或 source extraction 契约。
- native encoding 只处理 lowering 确定后的文本；provenance 保留至编码
  完成，target AST 结构变化必须通过 pack/path 逻辑同步更新路径。
- 这是一项语义修正，不把此前字节碰撞说成无关问题；普通 raw 控制字符
  不再被错误当作普通 native 字形。真实 `¯`/`˙` 字符仍应按字符编码。

节点 0 剩余两个定向探针已准备，尚未执行：

1. `org-texmacs-v020-probe-private-links`：复制并动态绑定 parser 状态，
   只调用 `org-link-make-regexps` 和 `org-element--set-regexps`，不调用
   全局注册/update-syntax；检查 reset 调用为空、ftps 三种写法、私有
   buffer 一致性、fragment exclusion、状态恢复。后一个函数是内部 API，
   若采用须集中封装并显式检查，不重新手写 Org link parser。
2. `org-texmacs-v020-probe-leaf-apis`：比较 `sourcecode->cork`、
   `cork->sourcecode` 与 UTF-8/Cork 接口，只记录 leaf 结果，不调用会展开
   tab 或生成 document 的 snippet 转换。包含真实 `¯`、`˙`、tab、软换行、
   中文和 `<alpha>`；这用于结束接口核对，不再要求普通源空白无损往返。

```sh
timeout 120s emacs-twist --batch -L . --load tmp/v020-boundary-probe.el --eval '(org-texmacs-v020-probe-private-links)'
timeout 120s emacs-twist --batch -L . --load tmp/v020-boundary-probe.el --eval '(org-texmacs-v020-probe-leaf-apis)'
```

本轮仅维护忽略文档和临时探针，未修改正式代码/ERT/版本号，未执行上述
新命令或构建；需要新的具体运行授权，不沿用已执行完毕的前两轮授权。

#### 第三轮收尾探测结果

用户随后明确授权上述 private-links / leaf-apis 两条命令，各执行一次，
均退出 0，无超时、无重跑。环境为 Emacs 31.1 / Org 9.8-pre / TeXmacs
2.1.5，native 子进程退出 0；本次隔离配置已清理。未运行正式 ERT/Nix，
未修改正式代码、README、版本号或 Git index。

- 私有正则构造：四个 ftps 对象均得到正确 `:type`/`:path`，覆盖
  bracket/angle/plain 和带描述 bracket；构造阶段记录 `resets=nil`。
  source/private 观察相同，fragment discovery 仍仅返回 visible island，
  离开绑定后 syntax state、source 文本和原解析结果恢复检查均为 t。
  此证据覆盖本探针和成功退出，不泛化为所有异常/缓存场景已验证；正式
  实现仍须补异常恢复和无源 cache 副作用的回归。
- 四个 leaf API 均存在。`sourcecode->cork` 与 `utf8->cork` 在七项输入
  上逐字节一致：tab、换行、双空格、`¯`、`˙`、`<alpha>`、中文/α/字面
  `<alpha>` 混合输入；native leaf tree round-trip 全部相同。
- `cork->sourcecode` 与 `cork->utf8` 在这些样例中解码一致，不提供 raw
  控制字符恢复。tab 和 `¯` 均编码为 9；换行和真实 `˙` 均编码为 10，
  本轮补齐了真实 `˙` 的正向碰撞证据。
- 双空格、`¯`、`˙`、字面 `<alpha>`、中文/α 混合文本按预期解码。
  观察完成不等于 raw tab/换行已具有正文语义；不再更换等效编码 API
  试图解决属于 lowering 的空白决策。

收尾结论：可以结束这两个问题的接口探索，回到 AST-first 实现。
节点 1 先落实普通 Org prose 空白语义，再扩展基础 inline；节点 2 使用
受限私有语法环境和 Org 生成的 `:type`，不重新解析 URI 协议；worker
不因本轮结果替换 encoder。code/verbatim 空白边界与所有新行为需在各
实现节点明确并形成正式 ERT，不把临时观察当作功能已完成。

#### 节点 1 实现草案（尚待本轮验证）

- 本轮按用户继续实施请求修改 document lowering、API docstring、capability
  检查及正式 ERT。保持原 worker encoder、STM parse/discovery 和 session
  接口不变；未实施链接/脚注节点，版本号仍为 0.1.0。
- Org inline traversal 使用同一 paragraph/title 的局部空白状态，递归
  emphasis 共享状态；普通 space/tab/CR/LF 连续段归一为空格，抑制开头及
  显式 break 后的空白，不逐叶子 trim 或归一 STM subtree。尾部空白保留
  一个 space；不合并或移除文本槽，重复空白槽可变为空字符串。
- 新增 italic→em、underline、strike-through；code/verbatim 从 :value
  取字面内容，采用行内 prose 空白规则，不承诺预格式化布局，也不再递归
  识别内容。参照 ox-latex 默认 texttt 的方向，不调用 ox-latex translator。
- 显式 line-break→next-line，paragraph 包括 headline 下正文可用；标题
  （含嵌套 emphasis）拒绝。island 当作不透明边界，pack 继续计算 provenance。
- 正式 ERT 新增跨节点空白、nested markup/cycle、literal inline、break
  上下文、NBSP/STM 边界及真实 native 控制字符/字形区分测试；调整原
  document 预期的源换行/tab 为 prose 表示，不修改原 encoder 原始字节测试。
- README 按 git-maintenance 保持原语言/结构，仅同步支持子集与空白规则。
- 当前只是已写入的实现与测试草案；全量 ERT、Nix checks/build 尚未运行，
  不记作节点完成或适合提交。下一轮需精确命令授权；不 stage/commit。

#### 节点 1 首轮验证与定向修复（2026-09-13）

用户授权以下三条命令各运行一次：

```sh
timeout 120s emacs-twist --batch -L . -l tests/ert/ert.el -f ert-run-tests-batch-and-exit
timeout 120s nix flake check --no-write-lock-file path:/home/lingyu/Projects/org-texmacs
timeout 120s nix build --no-link --no-write-lock-file path:/home/lingyu/Projects/org-texmacs#default
```

- ERT 命令退出 255，在 tests/ert/ert.el 的 whitespace-island-boundary
  测试结尾读取到多余右括号；文件未加载完成，测试尚未开始运行。
- Nix checks 与独立构建均退出 1，包编译报主文件 docstring 超过 80 字符。
  定位为 org-texmacs-document docstring 中 81 字符的一行，不能将 checks
  已求值或包构建启动记为验证通过。
- 用户随后授权修复：仅删除该多余右括号并重排该 docstring 两行；本记录
  同步维护。未修改功能行为、未 stage/commit，版本仍为 0.1.0。
- 修复后仅只读核对差异；未重跑三条命令，修复不等于通过验证。
  节点 1 仍待重跑和审阅，不能标为完成或适合提交。

#### 节点 1 修复后验证（2026-09-13）

用户授权重跑上述三条验证命令，各运行一次；未修改正式实现。

- 沙箱内直接 ERT 成功加载并开始 132 项测试，但首个 native session
  测试启动 worker 时，Unix socket bind 返回 `Operation not permitted`。
  最终命令到达 120 秒上限，退出 124；不将此轮记为通过，也不当作
  lowering 结果不匹配。未放宽 timeout。
- 因明确的沙箱限制，另经工具审批在沙箱外运行同一条 ERT 命令：退出 0，
  132/132 通过、0 unexpected，耗时 75.419049 秒（00:28:47–00:30:02
  Asia/Shanghai）。覆盖本节点新增 inline/prose whitespace/native 字形测试
  及既有 document/session/fragment/worker 测试；未增加新的测试范围。
- `nix flake check --no-write-lock-file path:/home/lingyu/Projects/org-texmacs`
  退出 0，输出 `all checks passed!`，当前 x86_64-linux 7 项 checks 通过。
  工具提示省略不兼容系统；不宣称其他平台通过。
- `nix build --no-link --no-write-lock-file path:/home/lingyu/Projects/org-texmacs#default`
  退出 0，独立包构建通过；未更新版本号、lockfile 或建立 result 链接。
- `git diff --cached --check` 退出 0。运行过程中用户将 5 个修改文件
  暂存；agent 未操作 index，未 commit。后续审阅以实际 staged diff 为准。

上述版本通过验证，随后仍须提交前审阅；不继续叠加节点 2。
本轮没有执行发布冷启动/straight 安装验收，不等于 v0.2.0 发布验收完成。

#### 节点 1 提交前审阅与强调节点修复（2026-09-13）

- 审阅发现递归 emphasis 将多个子节点直接作为 native markup 的多个参数。
  TeXmacs 的 strong、em、underline、strike-through 接受单个 body；例如
  `(strong "b " (em "i"))` 应为 `(strong (concat "b " (em "i")))`。
  既有 nested ERT 使用了错误预期；native stree 写入/读回也不等于已验证
  macro 参数数量或渲染语义，之前 132 项通过不能排除此问题。
- 用户授权修复：零子节点使用空字符串，单子节点保持原结构，多子节点
  先通过既有 pack 组成 concat，再作为 markup 的唯一 body 参数。
  保持空白状态共享、STM 边界和 provenance 计算机制不变。
- 修正 nested ERT 预期，新增四类 markup 的零/单/多子节点参数数量检查，
  以及真实 Org 嵌套强调 source → body → native session 写入/读回测试。
  后者检查结构与源文本不变，不宣称完成排版或渲染验证。
- 当前修复尚未重跑 ERT、Nix checks/build；之前的通过记录仅属于修复前
  版本。节点 1 状态为待重新验证及审阅，暂不记为适合提交。
  agent 未修改 index、未 commit；本轮修复留在工作区等待用户整理。

#### 节点 1 验收与提交，节点 2 实现草案（2026-09-13）

- 节点 1 修复后，经授权重跑三条命令：沙箱外 emacs-twist ERT
  134/134 通过，0 unexpected，71.968841 秒；当前 x86_64-linux
  7 项 Nix checks 与独立包构建均退出 0。未执行发布安装验收。
- 用户已提交节点 1，随后仅修改提交信息。最新 HEAD 为
  `2e50fd16284e793914f9571592417c0e7ac3ef7e`；与原 `986288e` 的
  tree hash 同为 `14459ffb0a354ec62dd576aa87ef36f2ad8f4d2a`，内容未变。
- 用户要求继续，当前仅实现节点 2，不叠加匿名脚注或版本更新。
  内部字符串常量保存五种 URI 类型；按 Org 的 :type 大小写不敏感
  准入，保留原 type/path 拼写构造 URI，不猜 raw-link、不重复转义。
- hlink 的第一个参数为单个显示 body（多节点先 concat），第二个为
  URI。描述按普通 inline 递归及空白规则处理；无描述显示 URI，目标
  不套用 prose 空白规则。file/内部引用/其他协议继续报 unsupported。
- 准备边界复制 link 注册及全局/局部 abbreviation 设置，动态绑定
  Org syntax 变量，仅调用已探测的 org-link-make-regexps 与内部
  org-element--set-regexps；不调用全局注册/update-syntax。新增 API
  基本存在性检查；worker 等待后重新比较 source link settings。
- 正式 ERT 草案覆盖五协议三种写法及描述、富文本、Unicode/百分号/
  查询参数、按 type 而非 raw-link 判定、隐式/显式 file 拒绝、语法状态
  成功/错误恢复、缩写、过期设置、链接描述 STM 排除及 native 混合树。
  README 按 git-maintenance 保守同步范围，不承诺网络跟随/渲染验收。
- 本轮只完成实现草案和只读 diff 核对；尚未运行新增 ERT 或 Nix
  checks/build。节点 2 未验证、未暂存、未提交，不记为完成。

#### 节点 2 验收与提交, 节点 3 实现草案 (2026-09-13)

- 节点 2 经授权运行全量 emacs-twist ERT, 140/140 通过,
  0 unexpected, 74.494954 秒. 当前 x86_64-linux 的 7 项 Nix checks
  与独立构建均退出 0. 没有重跑或执行发布安装验收.
- 用户已提交 `a1dc011 feat(document): lower URI links with private Org syntax`.
  本轮开始时工作区干净, 用户要求继续实施节点 3.
- 匿名脚注仅接受 paragraph 直接子对象, :type 为 inline 且 :label
  为 nil. 输出 `(footnote (document (concat ...)))`, 空正文使用空字符串槽.
  正文独立维护 prose 空白状态, 外层 reference 视为可见对象, 相邻脚注
  不插入额外分隔符. post-blank 继续由统一准备层收集并归一.
- 脚注正文复用普通 inline lowering, 支持强调, code/verbatim, URI 和
  显式换行. 不新增 STM discovery 上下文. 命名引用, 独立定义, 嵌套脚注,
  标题/强调/link 描述中的脚注 AST 明确拒绝, 不生成文档级编号.
- 新增 5 项正式 ERT 草案, 覆盖相邻脚注, 空正文, 独立空白状态,
  非法上下文, STM 排除和 provenance, 中文/富文本/URI native 回读.
  没有新增 API 调用或依赖, README 按 git-maintenance 保守同步边界.
- 当前仅写入实现和测试并只读核对 diff. 尚未运行本节点 ERT 或 Nix
  checks/build, 不记为已验证或适合提交. 版本仍为 0.1.0, 未暂存或提交.

#### 节点 3 验收与提交, 节点 4 验证准备 (2026-09-13)

- 节点 3 经授权运行全量 emacs-twist ERT, 145/145 通过,
  0 unexpected, 75.934597 秒. 当前 x86_64-linux 7 项 Nix checks
  和独立构建均退出 0. 用户已提交
  `b4ba750 feat(document): lower anonymous inline footnotes`.
- 节点 4 新增正式组合 ERT, 覆盖中文, 强调, 匿名脚注, URI, 多 inline
  islands 与 STM block, 校验独立 native 预期与 provenance, 重复写入,
  close/reopen 和旧句柄拒绝, worker 复用及源文本/tick/point 不变.
  既有异常, 重启, request-local 恢复测试继续保留, 不重复设计公开 API.
- 扩展 `tmp/release-install-check.el` 的清单为八个 Lisp 模块和 Scheme
  文件, 核对已加载模块及 document/session API 来自安装目录.
  local 与 straight 在真实 parse/cache 检查之前先做冷 worker 的
  document/session 组合验证, 包括独立 native 十六进制预期和重复写入.
  然后停止该 worker, 再运行既有 lazy parse/cache 验证.
- 安装探针仍使用新 batch Emacs 与本次新建的隔离 fixture, 只复制本包
  源码并读取本机 straight.el, 不加载用户 init 或 bootstrap, 禁止克隆和
  下载依赖. straight 会在 fixture 中字节编译并生成 autoloads.
  Nix ERT 的环境加载构建后的包, 而不是 checkout 的 Lisp 实现.
- 本轮仅准备代码与记录, 尚未运行上述新增测试或安装验证. 后续需按
  本计划的五条精确命令逐项授权. 版本仍为 0.1.0, 未进入发布收尾.

#### 节点 4 验收与提交, 节点 5 发布收尾草案 (2026-09-13)

- 经授权各执行一次五条验证命令. 全量 emacs-twist ERT 146/146
  通过, 0 unexpected, 78.671024 秒. local 与 straight 安装检查均
  退出 0, 覆盖八模块/Scheme 加载, 冷启动 body/session, 重复写入和
  parse/cache. straight 字节编译与 autoload 生成通过.
- 本机 straight.el 输出 if-let/when-let 弃用警告, 未导致验证失败,
  不修改第三方源码. Nix flake check 退出 0, 输出 all checks passed,
  本轮输出 running 2 flake checks, 不沿用旧轮次的 7 项运行数量.
  独立包构建退出 0. 未超时或重跑.
- 用户已提交正式组合测试:
  `51674f7 test(document): cover mixed inline bodies across native sessions`.
  安装探针和本文保持忽略状态, 不在该提交内.
- 用户要求继续节点 5. 主包与 Nix 版本更新为 0.2.0, 描述同步为
  TeXmacs trees and body sessions for Org. README 按 git-maintenance
  保留现有结构, 移除 checkout-only 说明, 明确 0.2.0 的有限 body AST
  与 native session 范围. 不修改功能, 依赖, lockfile 或安装清单.
- 此轮修改后的五项发布验证尚未运行. 前述结果属于更新元数据之前,
  不记为最终发布验证通过, 也不创建 commit/tag 或声称已发布.

#### v0.2.0 最终验证与本地 tag 核对 (补记于 2026-09-14)

- 2026-09-13 元数据更新后, 五条最终验证命令各执行一次并全部退出 0.
  emacs-twist ERT 146/146, 0 unexpected, 78.105285 秒.
  local/straight 安装验证通过, 当前平台 Nix 7 项 checks 和 0.2.0
  独立构建通过. straight 的第三方旧宏弃用警告未导致失败.
- 用户提交 `1b6553d build(release): prepare version 0.2.0 metadata`,
  随后提交 `c115285 style(readme): align Org table columns` 并打 tag.
  已只读核对 v0.2.0 与 HEAD 相同, 表格调整仅改变填充与分隔线宽度,
  单元格内容未变. 没有在对齐表格之后再次运行上述五条命令.
- 安装探针位于忽略的 tmp/, 不包含在 tag 中; 正式 ERT 已被追踪.
  未核验远端发布页面或 tag 的密码学签名. 本轮仅补记已有结果,
  不宣称重新执行验证.

## PLAN-2026-09-13-01：AST 第一性的 org-texmacs 包设计

- 状态: 架构方向已采纳, 后续具体实施待规划和授权.
- 与 GOALS.md 的关系: 以下内容保留为架构解释与阶段性路径.
  长期目标及严格原则以 GOALS.md 为依据; 具体 representation, 分层接口,
  consumer 组织及版本划分不因列入本计划就成为不可调整的架构约束.
  第 4 节新增的显式 source 与非干扰性要求是后续接口设计约束,
  不应只用 AST-first 的结构要求替代它们. 更新评估见本条目末尾.

- 目标与不做的内容：
  - Org 文件始终是 canonical source。
  - 核心转换保持：

    ```text
    Org source
      → Org AST + TeXmacs AST islands
      → TeXmacs AST / document state
      → TeXmacs native runtime
    ```

  - AST/tree 是 Org 与 TeXmacs 之间的主要语义接口；字符串只用于 leaf、源语法、IPC 或最终 serialization。
  - `.tm/.stm/.tmml`、PDF 等是最终输出，不作为 Org→TeXmacs 的中间真值来源。
  - AST-first 允许：

    ```text
    lower(AST, INFO) → target AST
    ```

    INFO、provenance、style、initial 等可作为独立结构化上下文，不要求全部塞进 AST。

  - 不自行实现 TeXmacs 已有的文件 serializer、PDF 排版器或格式转换器。
  - 不通过 LaTeX/XML/HTML 等中间格式完成 Org→TeXmacs。
  - 不要求把 Org AST 与 TeXmacs pseudo nodes 强制 graft 成一棵完全合法的 Org AST。

- 依据：
  - TeXmacs stree 本身适合作为 Org AST 的直接 lowering 目标。
  - TeXmacs fragment/block 应由 TeXmacs parser 解释；其中类似 Org 的语法不得再次由 Org 解析。
  - 物理 graft pseudo nodes 会引入 `:parent`、cache、secondary properties 等不必要复杂度，因此采用：

    ```text
    Org AST + associated TeXmacs islands
      → structural lowering
    ```

  - `v0.2.0` 已建立：

    ```text
    Org buffer
      → private Org AST + TeXmacs islands + fixed context
      → UTF-8 body stree + stm-paths
      → source-aware native encoding
      → stree->tree
      → persistent TeXmacs buffer
    ```

  - STM 与普通 Org 文本在 native encoding 上可能具有不同语义，因此 provenance 必须保留到 encoding 完成。
  - TeXmacs runtime 将 body、style、initial 等作为不同状态管理；live session 不要求先构造完整 `.tm` 文件。
  - Org 已有 options、references、citations 等语义机制；复用这些机制并作为 lowering context 不违背 AST-first。

- 对现有设计的影响：
  - Source：
    - Org buffer/file 是唯一 source of truth。
    - TeXmacs runtime buffer 和导出文件都不是第二份 canonical source。
  - Parsing：
    - 普通内容由 Org parser 生成 Org AST。
    - TeXmacs islands 独立解析成 TeXmacs stree。
  - Lowering：
    - 输入概念上为：

      ```text
      Org AST + TeXmacs islands + fixed INFO/context
      ```

    - element/object handler 直接构造 TeXmacs tree，不先生成 TeXmacs source string 再解析。
    - recursive content、literal content、native TeXmacs islands 必须区分处理。
    - unsupported 内容明确报错，不静默丢弃或退化成普通文本。
  - INFO：
    - lowering 消费固定 snapshot，不在转换过程中任意重新读取动态环境。
    - INFO 是配置上下文，不替代 AST。
  - Provenance：
    - 只要 encoding/native interpretation 仍依赖来源，就保留相应 provenance。
    - 当前 `stm-paths` 属于该层。
  - Encoding：
    - UTF-8 structural lowering 与 TeXmacs native encoding 分层。
    - encoding 集中完成，不分散到各 handler。
  - Session：
    - session 只消费已经构造好的 TeXmacs representation，不重新解释 Org。
    - persistent buffer 是 runtime state，不是 source。
  - 完整 document model 后续应概念上包含：

    ```text
    org-texmacs document
    ├── body
    ├── provenance
    ├── style
    ├── initial
    └── metadata / document-wide semantic state
    ```

  - 最终输出优先委托 TeXmacs：

    ```text
    complete TeXmacs document state
      → TeXmacs save/export
      → .tm/.stm/.tmml/PDF/其他稳定支持格式
    ```

- 分节点方案：
  1. 新增 body-level 功能时，优先定义直接的 `Org node → TeXmacs node` lowering，并验证 recursive/literal/native 三类内容边界。
  2. 需要 document-wide semantics 的 options、metadata、references、citations、resource paths 等放入 document/context 层，不下沉到局部 handler。
  3. `v0.3.0` 在现有 body/session 基础上建立 effective configuration、style、initial、metadata 和完整 document model。
  4. 完整 native document state 稳定后，再建立 Org export frontend。
  5. serialization/typesetting 尽量调用 TeXmacs 自身 save/export API，而不是在 Elisp 中重复实现。

- 成功标准与风险：
  - 成功标准：
    - Org 始终是唯一 canonical source。
    - Org→TeXmacs 的主要语义转换始终是结构化 tree→tree lowering。
    - islands 解析后直接以 TeXmacs tree 参与转换。
    - INFO、provenance、style、initial 等职责明确。
    - structural lowering 与 native encoding 分离。
    - runtime/session 不成为第二份文档源。
    - 最终 serialization 和 typesetting 优先委托 TeXmacs。
  - 风险：
    - AST-first 不等于禁止字符串；应避免的是把临时文本输出重新作为下一阶段的主要语义输入。
    - references、citations、resource paths 等不可因追求“局部 lowering”而错误地下沉。
    - 不应过早公开尚未稳定的通用 INFO 或完整 document struct。
    - TeXmacs 能接受某个 stree tag 不代表其具有预期语义；新增映射必须有 native semantic evidence。

- 待决定事项：
  - `v0.3.0` 是扩展现有 `org-texmacs-document` struct，还是另设 complete document representation。
  - INFO 是 construction-time context，还是完整 document result 的一部分。
  - style、initial、metadata 的 Elisp-side structured representation。
  - references/citations 的 document-resolution 阶段。
  - 文件资源和相对路径应依据 source、document state 还是最终 export destination 解析。
  - `ox-texmacs` 与现有 `org-texmacs-document` 的最终关系。

- 授权与进度：
  - `v0.1.0` 已完成 TeXmacs block/fragment 与 AST island 基础。
  - `v0.2.0` 已发布，完成有限 Org body lowering、STM provenance、native encoding 与 persistent native session。
  - AST-first 原则已在现有实现中实际采用。
  - 本计划对 `v0.3.0` 及以后仅规定设计方向，不构成代码修改、测试、提交、tag 或发布授权。

- 结果及去向：
  - 本计划解释 GOALS.md 的长期约束, 不将全部实现细节提升为严格原则.
  - `v0.3.0` 以 document model/configuration 为现有规划方向,
    具体范围需结合完整语义链及新增正文结构的依赖重新确定.
  - 完整 Org export integration 与最终输出 frontend 在 document model 稳定后单独规划；具体格式输出原则上交由 TeXmacs 完成。

### GOALS.md 初版阅读评估与执行解释 (2026-09-14)

以下记录针对初版 GOALS.md; 新增严格输入/副作用约束的差距见后续更新评估.
结论: 初版与已采纳的 AST-first 原则及 v0.2.0 的实现相容. GOALS.md 将
完整结构化文档与 consumer 解耦明确为长期目标, 同时允许工作路径依据
证据调整, 比将某一种内部 struct 或版本顺序固定为原则更准确.
用户本轮授权仅为阅读评估和维护 AGENTS.md, GOALS.md 原文未改动.

1. 完整文档是最终覆盖目标, 不是 v0.2.0 已支持任意 Org element 的声明.
   当前 document 结果仍是 body stree + stm-paths, 不是包含 style,
   initial 和完整 metadata 的 TeXmacs 文件文档. 新增列表, 表格和其他
   block 应逐项定义语义, 失败边界和测试, 不为追求全覆盖静默降级.
2. GOALS.md 的当前方向图同时包含现有机制和拟补齐阶段.
   v0.2.0 已复制部分有效 parser 设置并固定 headline 输出上下文,
   尚未接入完整 #+OPTIONS/effective configuration, TOC 或文档级引用.
   persistent session 已存在, 其在 consumer 路线中出现表示继续复用和
   完善, 不表示尚未实现. serialization/rendering 等仍是后续能力.
3. TeXmacs-valid stree 在此应理解为完成所需 native encoding 和结构边界
   处理的树, 不自动保证任意标签的 arity, style 依赖, 引用, 数学含义或
   排版正确. 原生接受/回读只是一类证据, 新映射还需要语义证据.
4. 禁止的是把已有 AST 降为中间输出语言, 再依靠 parser 重建语义.
   用户手写 STM 的首次解析, 字符串叶子, 来源区分后的文本编码, socket
   上保留树结构的序列化/读取和最终保存均不因此被禁止. 跨进程传 stree
   不等于必须在同一进程中传递 TeXmacs C++/Guile tree 对象.
5. structured document AST 是概念上的语义表示, 不预先要求另造公开 IR,
   物理 graft Org live AST, 或把 INFO/style/initial 全塞进单棵树.
   可采用关联树与结构化上下文, 但必须定义身份, 所有权, provenance 和
   snapshot 生命周期, 使消费者不必重新解释 Org source.
6. consumer 解耦不意味着消除 TeXmacs 依赖. 原生 parser, 编码和树构造
   可以共享必要的 native boundary, 但不应让结构转换的语义依赖某个
   session handle, 文件保存路径或 preview 是否启用.
7. 复用 Org 的语义/configuration 不等于直接执行完整 exporter 流水线.
   后续需识别哪些原生机制可提供结构化配置与 resolution, 明确副作用和
   snapshot 边界, 避免复用会先产出 LaTeX/HTML 字符串的 translator.
8. 文件资源路径可能具有不同角色: source-relative 解析与 export-relative
   输出不能预先混为一个基准. references/citations/资源语义应由文档级
   阶段决定, 局部 handler 消费结果, 不重复猜测或扫描原始字符串.
9. multi-session, preview/live synchronization 和 incremental update 是
   未来 consumer 方向, 不是本轮授权或 v0.3.0 自动必选项. 单 worker,
   单 active session 和手动全 body 更新仍是当前契约; 调整时另行设计.

后续计划应先列出语义覆盖矩阵与依赖, 再划分可独立验证的节点及版本.
保留本计划的待决定事项, 本轮不据目标文档直接选择完整 document struct,
公开 INFO API 或新增 export frontend, 也不重新打开已经完成的 v0.2.0.

### GOALS.md 更新评估: 显式输入, 可组合性与性能分级 (2026-09-14)

已完整阅读更新后的九节 GOALS.md. 本次新增第 3 节使用目标, 第 4 节
输入输出与副作用严格约束, 第 5 节性能软目标, 并细化实现路径与判断顺序.
评估: 方向合理, 补齐了仅以 tree-to-tree 描述架构时容易遗漏的接口契约.
本轮仅据此维护本文, 未修改 GOALS.md 或代码, 未运行新测试.

#### 现状与新约束的差距

- v0.2.0 的公开 `org-texmacs-document` 无 source 参数, 在入口捕获
  current-buffer, 文本, 部分 parser 设置与输出选项, 再使用私有副本.
  这符合当时的公开 API 契约, 但尚未提供第 4.1/4.8 节要求的显式 source
  核心及其便利封装. 不能把内部保存 buffer 变量记为此目标已完成.
- 内部 `org-texmacs--document-lower` 已接受 AST/islands/post-blanks/INFO,
  不直接读取 buffer 或启动 worker. 公开 construction 仍可能为 islands
  启动 parser worker. 后续应明确纯 lowering 与有 I/O 的 preparation,
  不误称完整 public construction 已是纯函数, 也不为纯度自行重写 STM parser.
- 已有快照, 过期输入拒绝和源文本/point 等回归是基础, 不代表已覆盖
  显式 source 与调用 buffer 不同, 所有 mark/text-property/cache 状态,
  或所有失败/跨进程等待场景. 本次仅核对源码, 未新增复现结论.
- 当前 document 结果仅保存 body/stm-paths, session 句柄关联 worker.
  新的所有权要求应落实为可解释的构造输入, 结果和生命周期契约,
  不预先要求结果永久持有源 buffer, marker 或完整可变配置对象.

#### 后续实施应遵守的解释

1. 显式 source 指向明确的 buffer 或稳定 snapshot. current-buffer 便利
   入口必须转交同一核心实现. API 名称, 参数形式及旧零参数入口的兼容
   方式另行设计; 本文不直接决定破坏 v0.2.0 的调用接口.
2. 同一显式 source 的准备与过期检查应在该 source 的规定语境中进行,
   不能在等待回来后误用另一个 current-buffer 的 local 设置. 在私有
   buffer 中处理 AST 是实现手段, 不等于把私有 buffer 变为 canonical source.
3. 快照冻结和过期拒绝都是允许策略, 应按字段写明. 现有固定输出 INFO
   的后续更改只影响下一次调用, source/parser 设置变化则拒绝本次结果,
   不必为了统一形式无条件重试. 未来重试须有边界, 不隐式无限循环.
4. 不破坏其他 Org caller 是严格要求, 不只检查函数退出后全局值恢复.
   若动态语法绑定跨越回调或等待, 还应评估期间其他合法调用看到的环境.
   优先缩小作用域并在私有副本执行, 不能用临时 monkey patch 绕开语义问题.
5. 相同输入得到相同语义的前提包括规定的 Org/TeXmacs 运行环境和未来
   style/资源等有效依赖. 可重建意味着不依赖旧 session/cache 的隐藏状态,
   不意味着无需已声明的工具或外部资源. 需明确依赖, 不默认扫描或冻结全环境.
6. 内部 formatter 必须无副作用, 用户 formatter 推荐同样遵守固定输入输出.
   延续既有决定, 不引入通用沙箱去控制用户函数. 这不免除包自身维持
   source, 配置, Org 可观察行为和 consumer 边界的责任.
7. Org-first 的交互目标不授权双源编辑或反向同步. 如果未来允许 native
   编辑, 必须另行决定它如何与 canonical Org 协调, 不能默认 session 内容
   会参与下一次 source 解释. 序列化输出也不能成为隐式恢复真值.
8. 字符串叶子和文本 presentation 合法, formatter 应返回结构化目标表示,
   不能把整段 LaTeX/STM 等输出语言伪装为普通叶子以规避 AST-first.
9. persistent worker/buffer 的存在不证明 typesetter cache 有效复用.
   先稳定全量转换与失败策略, 再依据实际测量评估 subtree mutation,
   增量排版和缓存收益. 不把 multi-session/preview/增量更新提升为发布硬门槛.

#### 下一份实施计划的优先输入与验收候选

先设计显式 source 核心, 同一语义的便利入口, preparation context 与
所有权/副作用契约, 再据依赖划分 configuration/document model 和正文扩展.
以下是待授权的测试设计要求, 不是已经执行或通过的测试:

- 从 buffer B 调用指定 source A, 改变 B 的配置/point/window 不改变 A 的结果.
- 显式入口与便利入口在同一 source/context 上语义一致, 无需结果对象 identity 相同.
- A 的有效 local 配置进入 snapshot; source 失效, 被删除, narrowed 和等待
  期间变化均按已选策略处理, 不意外切换输入或拼接不同时间点的状态.
- 成功与错误路径均检查 source 文本, modified flag, point/mark, narrowing,
  text properties, local 配置以及可观察的 Org cache/API 行为.
- 对照其他 buffer 的 Org parsing 等调用在转换前后及相关回调边界的结果,
  不只验证全局变量的最终值, 也不要求 cache 的内部对象 identity 永久不变.
- 清除本次 derived state 后可重建相同结构语义; session 操作只消费给定
  representation, 不反向读取当前 Org buffer 或旧 native body 来猜文档语义.

具体版本拆分及 API 仍待规划. 新约束作为后续设计依据, 不追溯声称
v0.2.0 已实现显式 source API, 也不在此次文档维护中修改已发布代码.

## PLAN-2026-09-14-01：v0.2.1 接口语义收敛

**状态: 三个节点均已验证并提交, 本地 v0.2.1 tag 与 HEAD 一致.**

以下验收要求不等同于实测事实. 实施进度与运行结果分开记录.
基线为本地 v0.2.0 / `c115285`, 不修改该 tag 或既有提交.

### 目标

使 v0.2.x 已有的 whole-document conversion 符合 `GOALS.md` 中新确立的严格接口约束，而不扩展新的文档语义或导出能力。

v0.2.1 主要作为 architecture/interface hardening release：

- document conversion 以且仅以显式指定的 Org source buffer 为输入；
- 隐式选择 canonical source 只允许发生在 convenience wrapper;
  内部可在显式指定 source 或私有副本的作用域中使用 buffer API.
- source/configuration 在转换开始时形成稳定 snapshot；
- 保持现有转换过程对 source buffer 和其他 Org 调用非破坏、可组合；
- 为上述约束增加明确的 regression tests。

### 依据

v0.2.0 已经建立：

- whole-document structural lowering；
- private source preparation；
- TeXmacs provenance-aware encoding；
- native session lifecycle；
- 基本的 source/configuration consistency checks。

但其 whole-document API 仍以当前 Org buffer 作为隐式输入，这与当前确立的：

`explicit source → stable snapshot → structured result`

接口模型不完全一致。

因此 v0.2.1 只修正现有能力的输入边界和不变量，不承担 v0.3.0 的 feature expansion。

### 实现范围

#### 1. 显式 source API

为 whole-document conversion 建立显式 source-buffer 入口。

要求：

- 核心实现不依赖调用时的 `current-buffer`；
- source text、buffer-local Org configuration 和 consistency checks 均绑定同一显式 source；
- 用户明确选择不保留旧零参数调用的兼容分支. 主入口为
  `(org-texmacs-document SOURCE-BUFFER)`, 参数必填.
- 新增 `(org-texmacs-document-current-buffer)` 作为调用主入口的薄包装.
  返回结构和 session 接口不变.

使用同一条转换流水线, 不维护可选参数或零参数兼容路径.
显式入口接受存活的 Org buffer 对象, 非 Org/dead/narrowed source
沿用既有错误边界, 不隐式 widen, 不增加路径输入或自动访问文件.
未提供参数的便利调用与传入无效 source 应有明确区分.

上述公开命名已在规划中确定. 旧调用应传入 buffer 或改用新包装函数.

#### 2. Snapshot 边界收敛

在开始转换时，从指定 source 捕获本次转换需要的 source/configuration state。

后续 preparation/lowering 不应重新从偶然的 editor state 获取语义。

冻结范围限于本次转换已支持的 source 文本, fragment tags, heading/link
parser 设置及输出 INFO/formatter, 不借此引入完整 export environment.
source-buffer 只作本次构造和一致性检查的身份锚点, 不必永久写入结果.
document 结果继续只保存 body/stm-paths, parser/worker/session 边界不变.

固定现有两类策略, 不要求所有配置采用同一种失效规则:

- source 文本, mode, narrowing 及已检查的 tags/heading/link 设置发生
  可检测的变化时拒绝本次结果, 不自动重试或接受混合状态.
- 输出 INFO 和选定 formatter 使用开始时的 snapshot, 后续变量重新绑定
  仅影响下一次转换. 不声称冻结任意用户 closure 内部状态.
- 每次 source 检查均明确指向同一 buffer. 仅 current-buffer 切换不应
  令有效 source 被误判过期, 也不应让检查读取调用 buffer 的配置.

保持现有原则：

- source preparation 使用私有副本；
- source buffer 不因转换而被修改；
- worker 等待期间若 source 或相关配置变化，则不得生成混合状态结果。

#### 3. 不变量测试

至少覆盖：

- 当前 buffer 为 A、显式 source 为 B 时，只转换 B；
- A 的 point、narrowing、buffer-local Org state 不影响 B 的转换；
- 转换不改变 B 的文本、modified state、point、mark 和 narrowing；
- 转换不修改无关 Org buffer；
- 不永久修改 Org 全局 parser/export 行为；
- worker request 前后切换 current buffer 不改变 source ownership；
- source/configuration 在等待期间变化时仍执行既定 consistency policy；
- 新 convenience API 与显式 source API 在相同 source 上产生相同 document semantics.

补充验收边界:

- 同时覆盖成功, unsupported 输入, 非法 STM, worker 失败和 source 被杀死.
  函数退出后恢复调用者的 buffer 语境, 不显示或切换用户窗口.
- 覆盖 source 的 text properties, mark-active 和相关 local 设置, 以及
  无关 buffer 的可观察状态. 不为恢复状态而撤销用户/回调在等待期间
  合法做出的修改; 非破坏性约束针对包自身造成的改变.
- INFO 后续变化影响下一次调用与 parser 设置变化导致拒绝应分别测试.
- 其他合法 Org 调用不仅在退出后, 也在相关回调边界具有原本语义.
  测试 cache 的正常可观察行为, 不要求缓存内部 cons identity 永久不变.
- 纯 lower 不读 source 或启动 worker; public construction 可以继续为
  STM 解析启动 worker, 但不创建 session, view, 输出文件或 rendering.

### 非目标

v0.2.1 不实现：

- `#+OPTIONS` / 完整 Org export environment；
- document title / author / date；
- TOC；
- 新的 list/table/block lowering；
- COMMENT/archive/task filtering；
- `.tm` / `.stm` / `.tmml` export；
- multi-session；
- preview / live synchronization；
- subtree-level incremental update；
- TeXmacs cache / incremental typesetting optimization。

这些属于 v0.3.0 及后续版本的能力扩展。

### 完成标准

v0.2.1 完成时应满足：

- existing v0.2.x document/session semantics 不发生非必要变化；
- whole-document conversion 的 canonical source 可以由调用者明确指定；
- current-buffer 不再是核心转换的隐藏输入；
- source ownership、snapshot consistency 和 non-destructive behavior 有直接测试覆盖；
- 原有 ERT / Nix checks 全部通过。

不将第 4 节严格目标理解为需要冻结全部 Emacs 环境或隔离任意用户函数.
包内部 formatter 必须无副作用, 用户 formatter 推荐同样遵守契约,
不增加通用沙箱. 公开 API 文档必须列明本版支持的配置范围和失效策略.

### 风险

主要风险是 source-buffer 显式化过程中遗漏现有 helper 对动态 `current-buffer` 或 buffer-local state 的隐式依赖。

实现时应优先消除隐式 source 选择, 而不是单纯给原实现外套一层绑定后
就宣称完成. `with-current-buffer SOURCE` 是合法的明确语境切换手段,
不属于被禁止的隐藏输入; 应集中使用, 并保证等待后的重新检查仍锚定 SOURCE.

节点 1 实施前的源码审阅确认, 当时 document 的 check 闭包调用
`org-texmacs--fragment-check-source`, 后者同时检查 buffer 存活与
`(eq (current-buffer) buffer)`. 这是明确的 document 改造位置,
不是本轮新运行复现. 不应为了 document 新语义直接放宽 standalone
fragment 的 current-buffer 契约; 可使用 document 专属检查边界或明确语境调用.
私有 link regexp 作用域也需检查, 不因最终值恢复就假定回调期间无泄漏.

### 建议实施节点与验证节奏

1. 固定必填 source 的主入口和零参数包装, 实现 source 捕获与身份检查,
   同步迁移现有测试和 README 示例, 添加 A/B buffer 与入口等价测试.
2. 审核 preparation 和等待前后的配置读取, 完善成功/失败/回调路径的
   非破坏性与可组合性测试, 仅修复本范围内已定位的问题.
   不因新增测试扩大 Org 语义支持, 不改 block/fragment 公共契约.
3. 在功能与测试闭环后同步 README, 安装示例及必要 capability 检查,
   再更新主包/Nix 为 0.2.1, 核对包产物并运行最终验证.

每个代码节点包含对应文档和回归, 按授权运行全量 emacs-twist ERT,
Nix checks 与独立构建, 审阅后由用户整理提交, 再继续下一节点.
最终安装验证复用现有 local/straight/Nix 路径, 同时验证包装入口和显式
入口来自安装产物, 不加载 checkout 以掩盖缺失模块或 autoload.
命令及副作用在执行前逐轮列出并申请授权, 不沿用 v0.2.0 的运行授权.

v0.2.1 包含用户明确接受的主入口签名破坏性变更, 不以 patch 版本名称
暗示向后兼容. README 和提交说明必须记录迁移方法. 其他非必要公开
行为变化不在授权范围内. 版本号仍在最后发布节点更新.

### 节点 1 实施记录 (2026-09-14, 已验证并提交)

- 主入口要求 live Org buffer 对象, 拒绝名称, nil, dead/non-Org/narrowed
  source; 新包装传入 current-buffer. 两个入口均有 autoload 标记.
- document 检查显式重新定位 source, 检查初始 mode, text tick 和已有
  parser 设置, 不修改 standalone fragment 的检查契约.
- 最终 lowering 后增加 source 检查, 返回结果不持有 source buffer.
- 迁移正式 ERT 与 README 调用, 添加入口等价, A/B buffer, 无效参数,
  worker 切换 buffer 及最终 lowering 后检查的回归.
- 私有 link parser 作用域中的预检调用尚未调整, 留待节点 2.
- 首次 ERT 因沙箱禁止 Unix socket bind 失败, 最终 exit 124.
  经授权在沙箱外重跑, 150/150 通过, 0 unexpected, 85.888073s.
  结束时间为 2026-09-14 02:34:08 +0800.
- Nix flake checks 和独立 default build 均 exit 0. 未扩大到其他系统.
- 用户已提交为 `8ea4b0dee98207e82ec9b298b2cc69414a1104a1`.

### 节点 2 实施记录 (2026-09-14, 已验证并提交)

- preparation 仅返回结构, 不再携带 INFO 或调用 lowering/formatter.
- 将预检移到私有 parser 和临时 buffer 作用域退出之后, 仍先于首次
  STM 请求; 预检后及最终 lowering 后均检查显式 source.
- 新增 formatter 回调内其他 Org buffer 的解析对照, source/caller
  状态保持, source 变更与销毁, INFO snapshot, source cache 可观察
  行为和纯 lowering 无 source 读取的回归.
- 不增加用户函数沙箱, 不承诺 formatter 调用次数为公共 API 契约.
- 沙箱外 ERT 156/156 通过, 0 unexpected, 78.561426s,
  结束于 2026-09-14 02:46:01 +0800. Nix checks 与独立 build 均 exit 0.
- 用户已提交为 `f47e1e24aa80e0fe2c82574476956bcab5f2dbab`.

### 节点 3 发布整理 (2026-09-14, 已验证并提交)

- README 明确 0.2.1 的破坏性 API 迁移, snapshot/失效策略,
  source/result 生命周期, formatter 与私有 parser 的隔离边界.
- 主包和 Nix 元数据已改为 0.2.1. agent 未创建提交或 tag;
  用户整理后已只读核对本地 v0.2.1 tag.
- local/straight 安装探针迁移到显式入口, 从无关 buffer 构造 document,
  对照包装入口结果, 检查两个入口加载路径及 straight autoload 条目.
- 正式 ERT 的公共 API 加载检查增加函数定义目录核对, 使 Nix ERT
  同时验证入口来自安装产物. 安装探针仍在忽略的 tmp/ 下.
- 最终沙箱外 ERT 156/156 通过, 0 unexpected, 78.734000s,
  运行于 2026-09-14 02:52:36--02:53:55 +0800.
- Nix flake checks 和独立 default build 均 exit 0, 未验证其他系统.
- local/straight 安装验证均 exit 0, 包含入口来源检查, cold-start
  document/session 闭环, 重复 native update 和 fragment/block 缓存检查.
  straight 的 byte compilation/autoload 检查通过; 本地 straight 源码
  有 obsolete if-let/when-let 警告, 非本包失败, 未修改第三方源码.
- 上述五项均为节点 3 的独立验证, 不是沿用节点 2 的结果.
- 用户提交为 `9988476b7ae98f33375d9c62ef4234890ce8b39c`.
  本轮只读核对提交 diff 与已审阅/验证内容一致, 工作区干净,
  `v0.2.1^{commit}` 等于 HEAD. 未联网核对远端发布或验证 tag 签名.
  AGENTS.md 仍被忽略且不被 Git 追踪. 本次文档维护未重跑测试.

### 后续

v0.2.1 已完成, 以其作为已明确收敛 source/context 接口并通过本计划
验收的新基线, 再规划 v0.3.0 的 structured document semantic expansion.
不因此宣称 GOALS.md 的全部最终使用目标, 任意 Org 配置或未来 consumer
行为均已实现并验证.

## PLAN-2026-09-14-02: v0.3.0 结构化文档语义补全

### 状态和证据等级 (2026-09-21)

- 正式方案已收敛, 用户已授权逐节点实现. 节点 1--8 已提交, 当前开发
  HEAD 为 `545df37`. 节点 9 已完成 release metadata、文档、安装探针
  和正式发布验证, 等待提交前审阅. 尚未创建 commit 或 v0.3.0 tag.
- 发布基线仍是 v0.2.1 / `9988476`, 历史最终 156 项 ERT 和五项验证
  通过. 节点 1--8 的实现和验证记录另见本计划的实施记录, 不能用发布
  基线的历史结果证明这些开发能力.
- 下列前置探针已经通过本机 Org/TeXmacs 验证, 不再列为待决定事项.
  探针不是正式测试套件, 各节点仍须把相关行为固化为回归测试.
- GOALS.md 是长期约束. 本计划描述本版的有限实现, 不承诺完整 Org
  feature coverage, 不把正文树等同于完整 TeXmacs 文件 serialization.

### 固定的接口和数据边界

核心路径:

```text
Org AST + parsed TeXmacs islands + fixed INFO
  -> org-texmacs-input
  -> org-texmacs-document
  -> body + style + initial + provenance
  -> single native session
```

- `org-texmacs-input-create AST INFO :islands ... :post-blanks ...
  :style ... :initial ...` 是
  prepared-input 构造器. 只复制已经解析的结构, 不读 buffer, 不解析
  deferred Org 属性或 STM, 不调用 formatter/lowering.
- `org-texmacs-document INPUT` 是纯结构转换入口. 不接受 buffer, 不按
  参数类型猜测兼容旧入口, 不重新捕获动态配置或启动 worker.
- `org-texmacs-prepare-buffer SOURCE-BUFFER` 是可选适配器, 返回 input.
  `org-texmacs-document-from-buffer SOURCE-BUFFER` 组合准备与 lowering.
  `org-texmacs-document-current-buffer` 只包装后一入口.
- AST, INFO, islands 和 post-blanks 形成同一个只读 snapshot. 复制时
  重建 parent links, 同步重映射身份键, 不共享调用者的可变树/字符串,
  不保留 source buffer. 拒绝循环或多重所有权 AST, detached/重复映射.
  formatter 是显式的 opaque 函数例外, 不冻结用户 closure 捕获的状态.
- buffer 组合入口保留现有 source/mode/narrowing/parser-setting 检查,
  包括最终 lowering 后的检查. 输出配置固定于 snapshot.
- 节点 1 只建立现有子集所需的 AST/INFO/islands/post-blanks 契约.
  style/initial 输入字段到节点 4 才加入, 不提前暴露被忽略的参数.
- 最终 result 独立承载 body, style, initial 和 STM provenance.
  body 的 `(document ...)` 仍交给 buffer-set-body, 不是完整文件外壳.
  metadata 以正文中的 doc-data 表示. STM paths 始终相对于 body.
- 节点 4 增加 `org-texmacs-document-style` 和
  `org-texmacs-document-initial` Custom 默认来源, 默认 style 为
  `("generic")`, initial 为空. 不新增 TEXMACS_* source keyword.
  initial 值采用 TeXmacs source semantics; style 名称和 environment
  key 是标识符, 不能机械套用 ordinary body text 编码.

### v0.3.0 必选范围

1. 受限 Org semantic adapter.
   - 复用 Org options 合并, title/author/date, todo/pri/tags/not-in-toc,
     tasks/archive/select/exclude/comment, toc/H/num, UNNUMBERED/ALT_TITLE.
   - 参考 ox-latex 的 policy 和结构选择, 不复制其字符串 transcoder.
   - discovery/masking 先于 pruning, pruning 时隔离 foreign subtree,
     移除被过滤节点的 mapping, 只对保留结构 preflight 和解析 STM.
   - 不自动读取 SETUPFILE/INCLUDE, 不执行 BIND/Babel/macros/export hooks.
     未预处理的有关 source directives 明确拒绝. 外部已经准备好的 AST
     不必由本包重新解析. 不进行 ID 查询或缺失 footnote 的 buffer fallback.
   - 明确支持的选项才可影响结果, 不因收集 INFO 就宣称全部 Org 配置生效.

2. 常用局部结构.
   - 无序/有序/描述列表及嵌套, quote/center 多段容器, 与既有 islands 混合.
     checkbox 和显式 counter 暂不支持.
   - example/fixed-width/src 只作为静态 preformatted 内容. 复用 Org
     dedent/escape 语义, 按 snapshot 的 tab-width 展开 tab, 换行形成
     document 子项, 保留空格和空行. 不执行 Babel/noweb/coderef/highlighting.
   - 基本矩形表格, 分隔线/header 和既有 inline 子集. 用 Org AST API
     解释表格, 拒绝 alignment/width cookies, formula, 控制行列, 合并及不齐行.
   - 不在 metadata, description tag, table 或 code 中新增 STM discovery.
     已有 anonymous inline footnote 的位置边界不扩大.
     file/internal link, named footnote, citation/bibliography 不纳入.

3. Metadata 与 headline.
   - title/author/date 保持 rich Org objects, 不先压平为 source string.
   - 使用 doc-data/doc-title/doc-author/author-data/author-name/doc-date.
     不启发式拆分 author, 缺失 DATE 不自动变为今天.
   - H 支持 0--5, Org 默认 3; relative level 1--5 映射
     section/subsection/subsubsection/paragraph/subparagraph 及 starred 版本.
     超过 H 的 headline 形成嵌套列表, 不丢弃正文.
   - 内部 formatter 必须无副作用, 也推荐用户如此编写; 不提供用户函数沙箱.

4. TOC 是本版必选.
   - 在相同 filtered Org context 中选标题, 使用静态 toc-* 结构,
     确定性的 generated labels, hlink 和 pageref.
   - 生成 label 避开可见静态 STM label, 不引入通用内部链接解析器.
   - 页码依赖 consumer 排版. 纯 AST 不预计算页码, 不以 readback 冒充
     实际分页/视觉验证.

5. Native document consumer.
   - 更新前验证并编码全部字段, 再应用 style, 清空旧 explicit initial,
     设置新 initial/body, 最后 readback. initial 按无序键值映射比较.
   - 接受 TeXmacs 对 style 的已知规范化. 允许 headless 内部 view,
     不启动 GUI; 这修订旧阶段的绝对无 view 限制.
   - mutation 前错误保留旧 session. native 更新或 readback 错误丢弃
     该 session; cleanup 或 transport 失败停止 worker. 不承诺事务回滚.
   - 保留单 active session. serialization, PDF, preview, 多文档/多 session
     和完整实用输出闭环留给后续 consumer-focused 版本.

### 正式实施节点与验收

| 节点 | 实现范围 | 主要验收 |
| --- | --- | --- |
| 0 | 固定范围, 记录探针及接口决策 | 当前计划不再含有与实测矛盾的待决定项 |
| 1 | prepared-input, 纯 core 和 buffer 入口迁移 | 所有权/parent/mapping, 无隐式读取, source consistency, 旧功能回归 |
| 2 | 受限 Org context, options, filtering | 优先级, caller 隔离, filtered invalid STM, 无外部读取/执行 |
| 3 | 三类列表, quote/center | 精确树, 嵌套/混合 islands, 拒绝 checkbox/counter |
| 4 | result style/initial, metadata, headline | rich metadata, options, 相对层级/低层列表, 编码边界 |
| 5 | example/fixed/src | dedent/escape/tab, 空格/空行/Unicode, 不执行代码 |
| 6 | 基本表格 | 规则线/header/矩形, inline, 明确拒绝高级语义 |
| 7 | TOC/label/hlink/pageref | 过滤后标题选择, 编号/UNNUMBERED/ALT_TITLE, label 冲突 |
| 8 | native 完整字段消费 | 重复替换/清空 initial, style normalization, readback 与失败失效 |
| 9 | 文档/安装/发布整理 | 全量 ERT, cold-start, Nix checks/build, local/straight 安装 |

每个节点必须独立可 check/build, 完成相应 ERT 和必要的 native 回归后,
审阅并由用户整理提交, 再进入下一节点. 版本号只在节点 9 发布逻辑闭环后
更新. 新增支持后同步修改旧 unsupported 测试, 不机械保留过时拒绝断言.

### 前置验证记录 (2026-09-14 至 2026-09-15)

本节保存当前方案的证据, 不改写历史实验结论. 环境为 emacs-twist,
Emacs 31.1, Org 9.8-pre, TeXmacs 2.1.5. 探针经用户逐轮授权执行.
Org 内存探针使用 timeout 30s 的 batch eval; native 探针以 Emacs
call-process 调用 TeXmacs -H -s -x, 子进程 timeout 80s, 外层 100s.
使用独立 /tmp/org-texmacs-v030-* 下的 TEXMACS_HOME_PATH, 未重设 HOME.
无源文件修改, 无文件序列化中间层, 没有执行排版输出或完整新 worker 协议.
脚本为当时的 inline eval, 尚未固化为仓库 ERT; 临时目录未批量清理.

Org 实测:
- get-environment 和 collect-tree-properties 本身不 prune. 执行 pruning 后
  COMMENT/未完成 task 被排除, tasks:done 的 TOC 只保留 Finished.
  archive:headline 保留 heading 而删除内容. select/exclude 筛选按 Org 生效.
- H:2/num:1/toc:3 的原始 level 2/3/4 得到 relative 1/2/3,
  Top 编号为 (1), TOC 保留 Top/Child, Deep 正文仍保留.
  UNNUMBERED notoc 不删除正文, 但不进入 TOC.
- TITLE 为 bold/text objects, AUTHOR 为 italic, DATE 为 timestamp,
  明确日期格式化为 2026-09-14, 缺失 DATE 为 nil.
- 文件 OPTIONS tags:nil 覆盖 ext-plist tags:t 和 buffer-local t.
  stub file reader 证明 SETUPFILE 会尝试读取并影响 options, 未读取真实文件.
  stub org-id-find 证明完整 tree-properties 收集会尝试一次 ID 查询.
  BIND disabled 时不改变原 tags 设置. 缺失 named footnote 会尝试 buffer
  lookup, 无定义则失败. 因此不得无条件复用整个 exporter 收集流程.
- foreign subtree 中名为 comment 的节点确被 Org pruning 删除.
  empty placeholder + 外部 mapping 隔离后 payload 保留.
  按特定 pseudo type 的 org-element-map 在 pruning 前也可能返回 nil,
  不能把它当作 payload 丢失证据; generic traversal/direct contents 可确认.
  被排除的非法 STM block 无须先解析.
- 原生 Org 区分三种列表; 混合 bullet 可被解析成由首项决定类型的同一列表.
  不由本包重新判定列表语法.
- example unravel 处理公共缩进和最终换行, src protection comma 已由 Org
  处理, tab 仍需明确展开. fixed-width :value 已去掉标记前缀.
  Org AST 可容纳不齐表格, 所以仍需矩形校验; table API 可识别 cookie/
  special column, formula 保存在 :tblfm.
- tab-width 4 的展开保留其他双空格/空行. 字面字符 ¯ 和 ˙ 是测试内容,
  不代表排版生成的重音; 不应在预格式化转换中丢失或替换.

TeXmacs 实测:
- with-buffer 非初始可用, 加载 (utils library cursor),
  (generic document-style), (generic document-edit) 后,
  buffer-new/view-new/with-buffer/set/get/close 在 headless 下可用.
- 同一 buffer 可从 article + par-first 2fn + 第一份正文替换为 generic
  和第二份正文. 单键清理成功; 进一步枚举所有 inits 并 init-default-one
  后得到空 collection, 包括移除自动产生的 page-medium paper.
  新增 par-first 3fn 后仅保留新键.
- 结构化 initial tuple 含 Unicode/字面文本, 经 init-env-tree/get-init-tree
  精确 readback. initial 值不能被限制成纯字符串.
- 早期 get-env-tree 返回 uninit 不证明标签不存在; get-init-tree 已确认
  metadata, toc1--5, 列表, quote/center, verbatim/code/tabular 和五层
  section/starred 定义为 macro/xmacro.
- metadata/TOC/list/quote/center/verbatim/code/table 组合正文 exact readback.
  doc-author 直接 author-name 不足以保留 doc-data-hidden 后的 running author;
  author-data 包装后保留, 因而使用规范包装.
- atomic/rich Unicode title 的 native encoded metadata 与输入匹配,
  cork->utf8 正确; preformatted document 子项包含空行, 中文, ¯/˙,
  literal <alpha> 的 readback 精确.
- style/initial 更新后注入 Scheme 错误, close buffer 成功且 buffer 不存在,
  随后新 buffer 正常工作. 这是失败失效策略的可行性证据, 不是原子回滚证明.
- 本机官方文档确认 label/hlink #target/pageref 用途, 页引用依赖分页.
  未调用历史上出错的 get-page-count, 未宣称视觉排版或实际页码已通过.

探针中的失败与修正:
- 嵌套 begin 内 define 被 Guile 拒绝, 改用 let/lambda.
- 未加载模块时 with-buffer unbound; 加载后通过.
- 诊断命令曾因括号错误/未完成退出超时, 没有自动认定为包缺陷.
- get-env-tree 的 uninit 断言失败后, 改用正确的 initial 查询和实际 native
  readback 验证, 不能保留早期的宏缺失结论.
- 所有以上解决仅针对探针路径. 实施中若出现新的失败, 按实际证据调整,
  不将前置探针解释为尚未实现功能的全量通过记录.

### 本轮实施记录

- 节点 0: 正式计划和前置证据已维护.
- 节点 1: 已写入 org-texmacs-input 模块, 纯 core/buffer 入口迁移,
  capability 检查, Nix fileset, README 迁移说明和 8 项新 ERT.
  原有 buffer 调用测试及 tmp/release-install-check.el 已同步迁移.
  input 构造器复制 AST/secondary properties, 重建 parent, 重映射 INFO
  中的 AST 引用及 island/post-blank 键, 拒绝 deferred/opaque/cyclic 输入.
  164 项 ERT, 7 项 flake checks 和 package derivation build 已通过.
  用户已提交为 `b7cdefd` (`feat(document): add prepared input boundary`).
- 节点 2: 已提交为 `1ed6e49` (`feat(document): apply restricted Org
  document context`). 实现 restricted context adapter, supported #+OPTIONS/metadata
  snapshot, task/archive/select/exclude/comment filtering, tag-group snapshot,
  island boundary 和过滤后的 mapping/request 清理. Org 标准 COMMENT 和
  ARCHIVE marker 由原生 parser 识别, 不虚构可配置 marker. 新增 12 项 ERT,
  首次完整 ERT 为 173/176, 新增 12 项通过. 三项失败为旧 COMMENT/archive/
  OPTIONS 拒绝断言, 已经授权更新: 用 unsupported list 保留 session 错误
  保护测试, 移除纯 lowering 的 archive 拒绝样例, 验证 file OPTIONS 生效且
  不调用完整 export environment. 两处加载括号错误亦已修复.
  本轮重跑 emacs-twist ERT 176/176 通过, 耗时 85.43 秒; 当前
  x86_64-linux 的 7 项 Nix flake checks 全部通过, 独立 package build
  退出 0. 其他系统未验证.
- 节点 3: 已实现并通过验证. 目标树固定为 itemize/enumerate/description 包含 body
  document, item/item* 位于每个 item 的首个正文段开头; quote/center 包含
  body document. 保持多段和嵌套 block 结构及 STM provenance, description
  term 不扩展 STM discovery. checkbox 和显式 counter 明确拒绝. 已增加
  三类 source list, untagged description item, nested island path,
  quote/center 多段及嵌套 list, preflight rejection 和 native session
  readback 共 5 项 ERT. 首次 Nix ERT 为 178/181; 三项失败均因旧夹具仍把
  普通 list 当作 unsupported source, 已统一改用仍不支持的 file link.
  重跑 emacs-twist ERT 181/181 通过, 0 unexpected, 88.216050 秒;
  当前 x86_64-linux 的 7 项 Nix flake checks 全部通过, 独立 package build
  退出 0. 其他系统未验证. 用户已提交为 `4559482`
  (`feat(document): lower Org lists and container blocks`).
- 节点 4: 已完成并通过验证. input/result 新增独立 style/initial slots;
  explicit input 使用关键字参数和结构默认值, buffer adapter 快照同名 Custom,
  STM paths 仍只相对于 body. style 为非空标识符列表, initial 为唯一环境键到
  source-semantic stree 的 alist; native session 在节点 8 前仍只消费 body.
  metadata 使用 doc-data/doc-title/doc-author/author-data/author-name/doc-date,
  保留 rich Org objects, date-only timestamp 格式化为 YYYY-MM-DD, 不扫描 STM,
  不以缺失 DATE 生成今天. 没有显式 metadata keyword 时不因默认 author 单独
  生成 doc-data. H 限定 0--5, headline 层级相对于过滤后最浅层, num 和
  UNNUMBERED 选择五层 section/starred tags, 超过 H 的相邻标题组合为嵌套
  itemize 且保留正文; ALT_TITLE 留在 snapshot 供节点 7 使用. 其他 drawer key
  仍拒绝. 已新增 input ownership/invalid settings, buffer snapshot, metadata
  options/provenance/native encoding, 五层 headline, H:0/低层嵌套 list,
  UNNUMBERED/ALT_TITLE 及复杂 timestamp 拒绝测试. 首次完整 ERT 因两处
  docstring 引号边界统一失败; 修正后为 184/190. 余下问题分别是 metadata
  secondary nodes 的普通属性在复制流程中过早结算, headline 最浅层预遍历
  缺少 cycle guard, 以及两项测试对 ALT_TITLE/raw string 和多字节字符串
  原地修改的错误假设. 修正并定向验证后, emacs-twist ERT 190/190 通过,
  0 unexpected, 89.646846 秒; 当前 x86_64-linux 的 7 项 Nix flake checks
  全部通过, 独立 package build 退出 0. 其他系统未验证.
  用户已提交为 `746a798` (`feat(document): add metadata and relative
  sectioning`).
- 节点 5: 已实现并通过验证. Org `example-block`, `fixed-width` 和
  `src-block` 作为静态 preformatted 内容 lowering 为
  `(code (document LINE...))`. 公共缩进使用 `org-remove-indentation`,
  example/src 的单独 `-i` 保留缩进; buffer adapter 把 `tab-width` 固定到
  prepared-input snapshot, lowering 按显示列展开 tab. 保留内部空行、普通
  空格、Unicode 和字面尖括号, 去除 Org block value 的一个语法性末尾换行.
  不在内容中解析 Org inline 或发现 STM, 不增加 STM provenance.
  不调用 Babel、noweb、coderef 或 highlighting; 除单独 `-i` 外的 switches
  和所有 src parameters 在 worker 前明确拒绝. 新增 4 项 ERT, 覆盖三种
  source form、缩进/tab snapshot、动态语义拒绝及真实 native 编码/readback.
  第一次全量 ERT 为 193/194, 唯一失败是旧 preflight fixture 仍把普通
  src block 当作 unsupported; 改为带 `-n` 的动态语义 fixture 后通过.
  第一次 Nix check 在字节编译时发现 lexical 参数遮蔽动态 `tab-width`;
  快照局部变量和 helper 参数改名, 仅在调用 Org 缩进 API 的最小作用域
  动态绑定 `tab-width`. 最终 emacs-twist ERT 194/194 通过,
  0 unexpected, 96.834632 秒; 当前 x86_64-linux 的 7 项 Nix flake checks
  全部通过, 其中 default package derivation 已构建. 未另行执行独立
  `nix build`; 其他系统未验证. 用户已提交为 `d76c908`
  (`feat(document): lower static preformatted blocks`).
- 节点 6: 已实现并通过验证. 基本 Org 表格按 AST 结构 lowering 为
  `(tabular (tformat ... (table (row (cell ...)) ...)))`; cell 复用既有
  inline 子集, 保留空 cell、Unicode 和普通 Org 字面文本, 不在 cell
  中发现或解析 STM. 规则行不生成伪内容 row: leading rule 转为首个
  data row 的 `cell-tborder`, 中间和 trailing rule 转为前一个 data row
  的 `cell-bborder`, 边框值为 `1ln`; header 分界因此保留结构, 但不隐式
  加粗. lowering 要求 Org table、至少一个含 cell 的 data row 和统一列数,
  并在 worker 前拒绝 `TBLFM`、alignment/width cookie、special/control
  row/column、连续 rule、不齐行、非 Org table 及当前 table context 不支持
  的对象. 没有引入 file/internal link 或 document-wide table semantics.
  本轮读取本机 Org 9.8 源码并用临时探针确认 special row/column API、
  `:tblfm`、不齐行 cell 计数及 leading/middle/trailing/consecutive rule AST;
  读取 TeXmacs 2.1.5 本机源码/文档确认 tabular/tformat/table/row/cell 和
  `cell-tborder`/`cell-bborder` 的原生结构. 临时探针已经删除.
  首次定向加载发现 table helper 多一个右括号, 修复后定向表格 ERT 4/4
  通过. 最终 emacs-twist ERT 198/198 通过, 0 unexpected,
  92.331580 秒; 当前 x86_64-linux 的 7 项 Nix flake checks 全部通过,
  其中 default package derivation 已构建. 未另行执行独立 `nix build`;
  其他系统未验证. 用户已提交为 `3a3e40e`
  (`feat(document): lower basic Org tables`).
- 节点 7: 已实现并通过验证. buffer adapter 把 `org-export-with-toc`
  合并到固定 INFO snapshot; lowering 只遍历同一份过滤后的 prepared AST,
  不重新读取 buffer 或运行 exporter. 非 nil `toc` 在存在 eligible headline
  时生成 `(table-of-contents "org-texmacs-toc" (document ...))`, entry 使用
  `toc-1`--`toc-5`, 内部 `hlink` 和 `pageref`; TOC 位于 `doc-data` 之后、
  正文之前. 深度受 `toc` 和 `H` 共同约束. 编号由过滤后 headline tree、
  `num` 和继承的 UNNUMBERED 计算; `UNNUMBERED: notoc` 只排除 TOC entry,
  其他 unnumbered heading 仍保留. `tags:not-in-toc` 仅从 TOC formatter
  输入中移除 tags, 不改变正文 heading.
  `ALT_TITLE` 在 private parser buffer 存活时用 Org headline object
  restriction 解析为 owned secondary AST, 只替代 TOC title; 不在其中新增
  STM discovery. 正文和 TOC 共用已固定的 headline formatter 与 title
  lowering 结果, 避免重复消费 post-blank identity mapping. 每个 entry
  对应正文 heading 后的确定性 `org-texmacs-toc-N` label. 分配器扫描可见
  STM islands 中静态可知的 `(label STRING)`, 避免名称冲突; 不尝试推断
  动态 label body, 也未引入通用 internal/file/ID link resolver.
  本轮定向读取本机 Org 9.8-pre 的 `org-export-with-toc`,
  `org-export-collect-headlines`, `org-export-excluded-from-toc-p`,
  `org-export-get-alt-title` 和 numbering 实现, 并读取 TeXmacs 2.1.5
  本机 package/documentation, 确认 `table-of-contents`, `toc-1`--`toc-5`,
  `label`, `hlink`/`#target` 与 `pageref` 的结构和 arity. 临时最小转换探针
  确认 `toc:2`, `num:1`, `tags:not-in-toc` 和 rich ALT_TITLE 的预期树;
  新增真实 worker/session ERT 确认 TOC tree 被 native TeXmacs 接受,
  ordinary/STM encoding 及 provenance 精确, 并覆盖静态 STM label 冲突.
  首次完整 ERT 为 173/201; 28 项失败均是与 TOC 无关的旧夹具依赖 Org
  默认 `toc:t`, 输出因新增 TOC/label 按预期改变. 这些夹具显式加入
  `#+OPTIONS: toc:nil`, 使其继续隔离测试原目标; 新增 3 项 TOC ERT
  独立覆盖结构、过滤/编号策略和 native 路径. 最终 emacs-twist ERT
  201/201 通过, 0 unexpected, 101.529549 秒; `git diff --check` 通过;
  当前 x86_64-linux 的 7 项 Nix flake checks 全部通过, 其中 default
  package derivation 已构建. 未另行执行独立 `nix build`; 其他系统、
  实际分页和视觉页码解析未验证. 纯 AST 仅保留结构化 `pageref`.
  用户已提交为 `6fb9fae`
  (`feat(document): lower static Org tables of contents`).
- 节点 8: 已实现并通过验证. document/session wire 从 body + stm-paths
  扩展为 style + initial + body + stm-paths. Elisp 在启动 worker 前复制并
  验证全部字段, Scheme 在任何 native mutation 前完成 body provenance
  encoding 和所有 initial value 的 TeXmacs source-semantic encoding;
  style 名和 initial key 保持 identifier 语义, 不套用 ordinary text
  encoding. 内部 document 构造器的 style 默认值同步为 `("generic")`,
  与公开 lowering result 的不变量一致.
  native session open 为 TeXmacs document API 创建 internal headless view,
  但不打开 GUI window 或外部文件. 每次 set 依次应用 style, 枚举并清除
  旧 explicit initial, 设置新的 structured initial, 设置 body, 再联合
  readback. initial 按无序唯一 key/value mapping 精确比较; style 读取并
  接受 TeXmacs 的 package normalization. 新 diagnostic response 为
  `native-document`, style/key 保持字符串, initial value/body 叶子用 hex
  表示 native bytes; 既有 `org-texmacs--session-read` 继续只返回 body,
  新内部 helper 用于完整 readback 测试, 未扩大 public API.
  首次定向 ERT 为 12/14: 一处把 expected native initial tree 与 readback
  stree 直接比较; 另一处显示 TeXmacs `with-buffer` 在 body 内抛错时不会
  自动恢复原 focus, 造成 worker 仍 live 但下一 session 读到 EOF. 实现改为
  在 session buffer 内捕获错误, 正常退出 `with-buffer` 恢复 focus 后再抛出,
  并统一 initial 比较表示. 第二次为 13/14, 唯一失败是测试用普通 `assoc`
  查找 `(associate KEY VALUE)` diagnostic entry 的错误假设, 修正为按 cadr
  查找. 最终定向 encoding/session ERT 14/14 通过, 0 unexpected.
  新增完整 native document ERT 覆盖 duplicate style normalization,
  Unicode/STM notation structured initial, repeated replacement, 删除旧 key,
  empty initial, body compatibility readback, malformed full response,
  全字段 preflight 保留旧 session, native update 失败后的 session discard
  与同一 worker 新 session recovery. 全量 emacs-twist ERT 202/202 通过,
  0 unexpected, 111.047789 秒; `git diff --check` 通过; 当前
  x86_64-linux 的 7 项 Nix flake checks 全部通过, 其中 default package
  derivation 已构建. 未另行执行独立 `nix build`; 其他系统、GUI/视觉排版、
  serialization/PDF 未验证.
  用户已提交为 `545df37` (`feat(session): apply complete native document
  state`).
- 节点 9: 已实现并通过验证, 等待提交前审阅. README 将 prepared-input、
  restricted Org context、structured body lowering 及完整 style/initial/body
  native session 收敛为 v0.3.0 当前契约, 不再称为 development API;
  保留 v0.2.1 入口迁移说明和明确的有限支持/非目标. 主包与 Nix package
  version 已同步为 0.3.0, flake description 从 body session 更新为 document
  session. 未改变依赖下限、lockfile、公开 API 或转换逻辑.
  忽略的 `tmp/release-install-check.el` 增加安装主文件 version 检查, 并用
  metadata/TOC/list/table/code/STM 的 prepared-input + buffer adapter 文档
  验证完整 style/initial/body session 重复替换. 首次 local 探针在 worker
  启动前因错误地向本机单参数 `lm-header` 传入第二参数而 exit 255; 改为
  临时 buffer 读取安装文件后重跑通过, 不属于包或安装产物失败.
  local 与 straight 安装探针最终均 exit 0, 覆盖全部 10 个 Lisp 模块、
  相邻 Scheme 文件、0.3.0 header、setup lazy worker、prepared/core/buffer
  等价、完整 native document 重复更新、source 不变性、block/fragment
  解析及 worker/cache 复用. straight 真实 byte compilation/autoload 通过;
  `if-let`/`when-let` obsolete warning 来自本机第三方 straight.el.
  全量 emacs-twist ERT 202/202 通过, 0 unexpected, 98.028210 秒. 当前
  x86_64-linux 的 7 项 Nix flake checks 全部通过; 独立
  `nix build --no-link` exit 0. 默认产物为
  `/nix/store/kkqnzx3ili9pjqccpxpg74qxj8krpwa3-emacs-org-texmacs-0.3.0`,
  已只读核对全部 `.el`/`.elc`/native 编译模块、相邻 worker Scheme、
  `Version: 0.3.0` 及 TeXmacs 2.1.5 绝对默认路径. 其他系统被 Nix 作为
  incompatible 省略, 未验证 GUI/视觉排版、serialization/PDF. 本节点
  不改变 Git history/tag; commit/tag/push 仍由用户处理.
