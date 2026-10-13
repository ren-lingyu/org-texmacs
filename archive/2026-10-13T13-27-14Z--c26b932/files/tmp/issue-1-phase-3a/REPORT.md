# Issue #1 Phase 3a bibliography discovery 合同调查

## 对新增计划的审阅

INBOX §12 的方向恰当：在已完成的 Phase 1 上，先区分 bibliography declaration、规范化 source identity 和 owned text，再研究标准 discovery 与 acquisition。先做 Phase 3a、保留显式 API、避免纯 lowering I/O 和真实个人数据库依赖，符合现有约束。建议采纳这一调查顺序。

需要补充的关键条件是：**仅通过上层 adapter 构造现有 bibliography-sources 参数，不能接通 global/managed-only 来源**。当前 preparation 仍从文档 BIBLIOGRAPHY keyword 构建 declaration view；未被选中的文本不会用于 key resolution。应区分“保持旧 public API 与纯 core 不变”和“完全不改 preparation”：前者可作为目标，后者已被反例否定。

本轮只实施研究，没有 Phase 3b/Phase 2 生产修改，也没有远端 issue 写入。§12 引用的远端进展评论本轮公开读取失败，未独立核对；本地代码/GAW 状态与完成记录吻合。

## 基线与实验

- 业务代码：main `c26b932a8376c610603eaeb0f9ed8af98c1f6476`，Phase 1 已提交。项目 worktree 仅有用户原来的 flake.nix USTC overlay，未被 agent 修改或暂存。
- 独立 flake：tmp/issue-1-phase-3a，lock 为当前项目的逐字节副本，SHA-256 `118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a`。Emacs 31.1 / Org 9.8.10；源获取使用原固定哈希的 USTC 传输配置。依赖已缓存，本轮只构建研究 derivation。
- 测试只涉及受控 Org buffers、advice、隔离 fixtures 和 acquisition 模型。原生 worker/parser/formatter 在 pipeline 对照实验中使用受控替身，**没有新的 TeXmacs native 执行或真实 Org-roam DB 联测**。项目 TeXmacs 2.1.5 的生产验证来自已记录的 Phase 1，不是本次新增结果。
- 精确命令：`timeout 120s nix build --no-link --no-write-lock-file path:/home/lingyu/Projects/org-texmacs/tmp/issue-1-phase-3a#checks.x86_64-linux.discovery`。
- 最终结果见 ert.log / summary.txt / environment.txt：25/25，0 unexpected，ERT 0.207506 秒，构建退出 0。不是完整项目回归；生产无变更，因此没有重跑历史 324/324 或整个 package gate。
- 早期脚本括号/局部变量、remote classification 和 STM opacity 的假设在隔离研究中纠正。最终证据保留 corrected probes 和结果，失败不计为通过。Remote 判别必须在关闭 file-name handlers 前；否则 file-remote-p 可能把 TRAMP syntax 当成 local。

## 实际 API、输入输出、副作用和失败边界

行号与字节指纹以 source-evidence.txt 中锁定的 Org 9.8.10 源码为准。上游 [Org citation manual](https://orgmode.org/manual/Citation-handling.html) 提供声明/processor 的背景；具体源码和实验决定这里的行为，不能用上游版本的描述替代。

| 阶段 / API | 输入 → 输出 | 实测副作用与语义 | 适用边界 |
| --- | --- | --- | --- |
| org-cite-list-bibliography-files | current Org buffer、global paths → flat path list | document order 后接 globals；对原始字符串 delete-dups；保留相对路径 | 不是 text acquisition，也不保证绝对 identity 或完整来源 |
| 返回 advice | native list → altered list | 可 prepend/append/remove，native 去重之后再次引入 duplicates；返回字符串可与外部配置共享 | 返回即 own；不能假设 native 曾去重就没有 aliases |
| 全局 bibliography | effective org-cite-global-bibliography → list tail | append 共享最后的 global tail，delete-dups 可以修改原列表 | private discovery 必须 deep-copy 已支持配置，不能只复制 buffer |
| org-collect-keywords | complete source / SETUPFILE → values with declaration directories | org-with-point-at 会 widen；递归读 SETUPFILE，可能 URL | discovery 范围不同于输出 body；拒绝/约束 setup 需发生在调用前 |
| 普通 visiting buffer | keyword relative path + filename/default-directory → relative result | 文件目录与 default-directory 相同时原样；不同时先按访问文件目录定位，再相对 default-directory 重写 | 与现有 resource-base 参数语义可能不一致；不可静默选一个 |
| non-file buffer | keyword/global relative path + default-directory → raw relative result | 无访问文件目录覆盖；quoted filename 去引号，绝对路径保持 | normalize against captured base once，不能从临时 buffer 偶然选目录 |
| SETUPFILE | declaration → extra Org config/path values | nested setup bibliography 分别重定位为 config/library.bib、config/nested/deeper.bib；missing setup 可静默忽略；URL 可能被请求 | 本次 URL 使用替身，未访问网络；第一生产节点宜保留当前拒绝边界 |
| TeXmacs text | raw special-block payload → native keyword scan | 原生 discovery 把 island.bib 与 STM 内 SETUPFILE 当 Org 输入，确实调用读取 | **不能直接对 raw source 调用 discovery**。STM opaque view 是独立必要边界 |
| org-export-get-environment | globals/external/file/subtree → INFO | ext :bibliography 可保留在 INFO，普通 option 收集可 SETUPFILE/BIND；不自动等同 discovery | 不为 bibliography 获取复用完整 environment/annotation |
| org-cite-store-bibliography | INFO + current buffer → :bibliography | 无条件用 list-bibliography-files 替换已有 :bibliography；没有 processor 执行；实际结果仍可相对 | 不把它当显式优先权合并器，也不据 docstring 假定 absolute |
| identity normalization model | owned returned strings + captured base → lexical absolute IDs | refs / ./refs / config/../refs 合并；不跟随 symlink；reject remote/URL/tilde/control/empty | 原始字符串相等、lexical identity 和 physical file 是不同层次 |
| acquisition model | IDs + explicit texts → owned sources + receipts | 明确文本优先、不 stat/read 同 identity；preserve explicit extras；自动补缺项；UTF-8/BibTeX validation | 显式参数仍可标识不存在的文件；无文件 receipt，不把磁盘状态当其真值 |
| file receipts | auto-read bytes + attributes → fixed text + proof data | size/mtime/ctime/inode/device + digest；读取期间改写、之后内容修改、same-bytes 文件替换被拒绝 | 只验证观测边界，非事务/ABA-proof；检查读不替换固定 text |
| source API / bibliography plan | provided texts + document declarations → selected entries/keys | 无 Doc 声明时 global 已发现路径+文本仍 unresolved；有声明+Phase 1 remap 可成功，filter 一次 | 需要显式 effective declaration view，而不是二次 key filter 或文本合成 |
| pure owned declaration view | owned AST/INFO/source trees → citation plan | 原现有 planner 可选择 managed source并解析 external-key，无 worker/file read/new input slot | 实验是 explicit structured data，不是现有 buffer API 已支持 managed auto discovery |

## 反例和具体结果

1. visiting filename 为 fixtures/visit/source.org，default-directory 为 fixtures/base/ 时，native 返回 ../visit/refs.bib；现有显式 sources 的 refs.bib 定位到 base/refs.bib。二者并非同一个 source identity。
2. globals 为 a,b,a 时，native collection 可以把原配置变成 a,b；复制 globals 后执行，则原列表保持 a,b,a。用户 advice 的任意外部状态无法据此声明被 sandbox。
3. narrowing 到 Text 后 native discovery 仍找到全源 refs.bib 和其他标题下 other.bib。若沿用 narrowed copy 只 mask 可见 STM，稍后 native widen 会重新暴露隐藏 STM 声明；private model 因而使用 drop-narrowing 的完整 view。
4. raw TeXmacs block 内 island.bib / SETUPFILE 被 native collector 识别并读取。private model先用现有 context 检查真实 preprocessing 指令，再 mask inline/block STM；同一 standard return advice 仍正常触发一次，source/global config保持不变，STM 不再触发文件读取。
5. 复制之前必须禁用 BIND。否则 Org export copy machinery可能在完成 STM mask 之前自行收集 BIND/SETUPFILE。模型验证启用外部 BIND 设置时，STM 内的 BIND也不能影响 bibliography或触发 SETUPFILE读取。
6. org-cite-store-bibliography覆盖原 INFO :bibliography external.bib，结果是 refs.bib/global.bib；它没有显式文本优先权概念。该优先权必须在 acquisition merge 中定义。
7. acquisition 模型只读自动缺失项；caller text在原字符串被修改后仍独立，提供不存在文件也不引起磁盘访问；未选中的 explicit sources仍保留。显式重复 identity沿用错误，而不是静默去重。
8. 自动源的 invalid BibTeX、目录、missing、不可读替身、symlink、hardlink duplicate、读取中改写、最终内容改写、same-bytes file replacement及invalid UTF-8均被模型拒绝；中文/Café text保持原样。不是新的公开支持合同或完整安全 sandbox。
9. 用现有 source API仅传 global text失败；加原文Doc声明后 remap与bibliography plan成功且filter一次。相反，直接给 pure owned INFO一个 effective declaration view可成功。这证明最小可行方向是 adapter context/data扩展，不需要改pure lowering。
10. discovery本身没有调用 AST filter、generic exporter、output processor；转换filter由现有 preparation运行一次。整套transaction尚未实现，原型组件成功不能代替其源一致性及输出时点验证。

## 三种接入方案比较

| 方案 | 默认语义 / I/O 边界 | 主要价值 | 限制与取舍 |
| --- | --- | --- | --- |
| 仅 interactive frontend 可选 | 菜单显式动作开启；旧 Lisp API保持原样 | 可解决菜单目前没有bibliography文本入口的问题 | 若只把 acquired texts传旧接口，managed/global-only链路仍失败；前端也需完整source+receipt transaction，不能各写一套读取逻辑 |
| 在 existing source API增加 opt-in policy | 默认关闭；显式参数启用读取 | 全部调用方能沿用selection/consumers | 会扩展多个公开signature/policy、重复等待/写入检查；ext-plist目前拒绝hooks/bibliography，不应挤入无类型字段或默认auto |
| 独立 opt-in adapter（推荐） | 一次capture→discovery→acquisition→共享preparation；旧入口默认不变 | 将I/O和receipt/source consistency放在清楚上层；可后续由frontend复用 | 仍需要最小internal effective-declaration injection和before-publication依赖校验。不是完全不改preparation；公开wrapper名称及最终policy尚未实现 |

推荐第三种作为 Phase 3b 的待审合同。它可保留旧 public API和pure input model，明确 new preparation data boundary。第一版建议：local UTF-8 bounded files；copied global config；完整STM-masked view；真实 SETUPFILE/INCLUDE/BIND等继续拒绝；visiting-resource目录冲突先报错，不引入未论证的新相对路径政策。CONTRACT.md细化其建议限制、合并与transaction顺序；这些是proposal，不是已经采用的生产接口。

## Phase 3b 前必须完成的工作

- 审阅目录冲突/size/encoding/alias边界与新wrapper的明确opt-in方式。不能把private Org-derived context直接称为真实managed package兼容。
- 在实际共享preparation中传入owned effective declaration view，保留Doc raw keyword匹配；advice删除或改变声明时显式失败。不要给原始source添加假BIBLIOGRAPHY字符串，也不要动态替换context函数来绕过数据入口。
- 将source/config/filter/explicit-text检查从discovery前延伸到最终native输出；检查receipt时只验证固定快照，不重新发现/转换。相同字节不证明没有外部ABA变化；DB与文件不共享事务。
- 确保only-one filter execution，phase1readonlyINFO正确，未解析/重复keys及invalid BibTeX仍在worker前按已有策略拒绝。
- 在任何file output写入前做依赖检查；调用旧export-to-file后才检查已经太晚。首个wrapper返回completed document/bytes可先保持file发布政策独立。
- 维护测试需覆盖完整lifecycle和失败恢复，而非只保留这些临时组件probes。本轮无生产修改，所以不新增项目ERT，也不重跑其全量结果。
- 真实org-roam-organize/advice数据库一致性边界留到独立fixtures联测；Phase 2 origins/source composition保持独立，issue #1不能因本次调查宣称完成。

## 交接与来源

代码/lock上下文由project-source.txt验证，必要上游摘录和SHA-256在source-evidence.txt。
本报告、CONTRACT.md、独立flake/probes/fixtures/最终输出作为必要文本归档；它们是研究证据，不是自动执行生产代码的授权。当前GAW memory只保存结论与拟定合同，Phase 0 archive不变。
