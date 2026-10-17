# org-texmacs 私有 PDF 导出宏覆盖集成验证

结论: 在锁定的 TeXmacs2.1.5 / Org9.8.10 / Emacs31.1 / x86_64-linux,
generic/article 范围内, 可以在 org-texmacs 私有 PDF render buffer 中局部覆盖
render-footnote*, 恢复普通正文脚注的正向目标, 并通过重复/异常/共享状态隔离检查.
这是隔离副本中的候选集成验证, 尚未修改生产源码或证明任意自定义样式兼容.

## 实现位置与隔离

仅修改本目录中的 org-texmacs-worker.scm 副本; 使用 root 同一锁构建真实 Nix
org-texmacs 包和 Emacs 环境. 正式项目 HEAD/源码/lock/index 不变, 原用户 ELPA
mirror 保留. integration-worker.patch 是与 main@aa9adbc 的完整差异;
integration-worker-patch.py 从原 worker 精确生成该候选和测试仪器.
源输入/最终候选哈希分别见 source-inputs.json / integration-inputs.json.

候选在现有 render-native-pdf 第一次打印后(样式宏已初始化), 最终排版/打印前:

1. 读取当前私有 buffer 的 render-footnote*.
2. 验证唯一的 set-binding key 是原生 merge(footnote-, arg nr).
3. 在原 set-binding 前添加同 key 的 label, 用 init-env-tree 仅设置当前 buffer.
4. 保持原生 footnote tree、计数器、lowering 和序列化不变; 不硬编码编号.
5. 显式 initial 提供 render-footnote* 时不覆盖用户宏.

控制文件/事件记录/故障注入/已有 session 快照是测试仪器, 不是新公共 API 或协议.
每次失败或成功均沿用原 dynamic-wind 关闭临时 buffer、删除临时 PDF.

## 实际接口与覆盖

使用 org-texmacs-document-save-pdf、org-texmacs-export-to-pdf-file, 以及
org-texmacs-export-to-pdf 前端, 经真实共享 worker 渲染, 没有绕过 worker 直接
打印候选 PDF. 两种样式均包含匿名脚注、具名定义及重复引用、markup、跨页脚注、
无脚注文档、显式自定义 macro、覆盖后注入错误及恢复. 每个主要用例导出三次,
混合 prepared-document 与 source API; 最小用例还通过前端导出.

最终 exact600s 已授权命令:

```sh
timeout 600s nix build path:./tmp/footnote-forward-probe#checks.x86_64-linux.footnote-forward --no-link --no-write-lock-file --print-build-logs --print-out-paths
```

exit0, PRIVATE-INTEGRATION-OK44. 输出:
/nix/store/jrrfilgir89s9nx64f6bajc4a5wm1q1s-org-texmacs-private-footnote-integration
已复制至 integration-results/. Python原始注解/目标/文本/坐标在 annotations.json,
导出条件在 exports.json, native事件在 worker-events.sexp.

## 验证结果

- 44份成功导出 PDF, 包括6份关闭覆盖的对照和8份无脚注/显式宏对照.
- 30份启用覆盖且带脚注的 PDF, 共54个正文正向链接, 均有对应脚注目标.
- 关闭覆盖时: 匿名两个目标仍缺失; 具名首次目标缺失而原重复引用有效.
  启用后再关闭也复现原症状, 没有全局宏修补泄漏.
- 每个三次导出组的可见文本/文字位置与目标几何完全一致. 最小/恢复后用例与
  关闭覆盖基线的文字/位置完全一致, 具名重复用例也与未修补基线一致, 编号未变.
- 46次实际渲染尝试, 含2次覆盖后强制失败.46次 buffer-closed、file-removed、
  session-intact,38次 patched、6次 disabled、2次 explicit-macro-preserved.
- 已有 session 的 body/style/initial 和实际 macro 前后相等; 全程要求同一个
  worker 实例, 不允许靠重启掩盖泄漏. 两次失败后未发布输出文件, 随后导出恢复.
- 源 Org 文本、prepared document body 和其序列化字节在渲染前后不变.
- 明确 initial macro 保持不覆盖; 这不承诺自定义脚注宏本身的链接语义已修复.

目标定位检查要求匹配正确脚注页和正文行, 合并同一行的普通/粗体/斜体文本框.
具名脚注新增的零宽目标在该行文字末端附近(有约5px横向邻接), 因此该类允许
一行字体高度内的邻接距离, 不能声称所有目标严格落在 glyph 矩形内. 原有重复
引用目标必须与未修补基线坐标完全一致. 不仅检查 target 存在或同页.
未执行 GUI 点击. 此阶段仅验证 org-texmacs 自身原生 PDF 导出, 不承诺 PS 精确
落点、独立 GUI 重导出、caption 脚注、所有样式或自定义宏. 明确保留原生重复
named destination 警告; 没有把它当作完全无风险或全套修复验收的证据.

## 被排除的中间失败

初版测试前端设文件名却未同步 default-directory, 被既有 composition/resource
base 一致性保护拒绝. 首次回溯截断, 先改紧凑错误输出后定位并修正夹具, 没有
删除产品保护. 随后所有导出/状态检查完成, 但分析器先后因如下假设拒绝:
具名零宽目标必须在文字框内; 按上边缘 y 排序同一行不同字体上标; markup 只
取第一个文字片段. 根据未修补 baseline 和原始坐标修正为正确阅读顺序/整行范围,
并额外比较原重复目标精确坐标. 初步把横向偏移归于旧重复引用的判断已纠正:
它实际属于新增首次引用目标, 位于对应脚注行末附近. 最终全矩阵通过后才接受.

## 结论边界与材料保留

结果支持在 org-texmacs 私有 PDF 消费层实现局部兼容, 无需先 patch 系统 TeXmacs
或改变 Org AST lowering. 正式集成仍需单独选定生产改动和维护回归, 移除所有
probe 控制/日志/故障注入, 明确不匹配 macro 和用户显式 override 的处理边界.
当前没有生产修复或额外 release 完成声明.

该临时 worker 候选及真实导出/异常清理证据尚未进入项目历史/维护测试, 丢失会
影响复现和审计. 选择性保留配置/锁、worker差异及生成器、测试脚本/输入身份、
结构化输出及native事件/报告; 不归档完整源码/依赖/PDF, 先前 archive 不变.
