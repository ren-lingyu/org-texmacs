# 逐案例数据与结构对照

所有 title 都有共同前缀 `Properties of `, 表内保留实际完整 CSL title. 原始字段拼写与 CSL-JSON 语义值分别见 cases.json 的 title/csl. 以下取 plain 样式; italic 的完整记录另存 JSON. 数学节点数量不构成保真成功判据.

| Case | Bib→CSL title | 直接 JSON title | getter title | 当前 CSL lowering | native math 数量(解析/格式化) |
| --- | --- | --- | --- | --- | --- |
| `plain` | `Properties of english abc 123, punctuation: yes!` | `Properties of English ABC 123, punctuation: yes!` | `Properties of english abc 123, punctuation: yes!` | 可 lowering; 不代表数学保真 | 0/0 |
| `case` | `Properties of an <span class="nocase">RNA</span> study of <span class="nocase">NASA</span>` | `Properties of An <span class="nocase">RNA</span> Study of <span class="nocase">NASA</span>` | `Properties of an <span class="nocase">RNA</span> study of <span class="nocase">NASA</span>` | 可 lowering; 不代表数学保真 | 0/0 |
| `punctuation` | `Properties of quotes "hello", hyphen -, en –, em –-, tilde` | `Properties of Quotes "Hello", hyphen -, en –, em —, tilde  ` | `Properties of quotes "hello", hyphen -, en –, em –-, tilde` | 可 lowering; 不代表数学保真 | 0/0 |
| `escapes` | `Properties of braces {x}, dollar \$, backslash` | `Properties of Braces {x}, dollar $, backslash \` | `Properties of braces {x}, dollar \$, backslash` | 可 lowering; 不代表数学保真 | 0/0 |
| `greek-unicode` | `Properties of α β γ` | `Properties of α β γ` | `Properties of α β γ` | 可 lowering; 不代表数学保真 | 0/0 |
| `chinese` | `Properties of 中文数学标题` | `Properties of 中文数学标题` | `Properties of 中文数学标题` | 可 lowering; 不代表数学保真 | 0/0 |
| `accent` | `Properties of émile naïve ångström` | `Properties of Émile naïve Ångström` | `Properties of émile naïve ångström` | 可 lowering; 不代表数学保真 | 0/0 |
| `combining` | `Properties of é and é` | `Properties of é and é` | `Properties of é and é` | 可 lowering; 不代表数学保真 | 0/0 |
| `math-unicode` | `Properties of ∀x ∈ ℝ: x ≤ ∞` | `Properties of ∀x ∈ ℝ: x ≤ ∞` | `Properties of ∀x ∈ ℝ: x ≤ ∞` | 可 lowering; 不代表数学保真 | 0/0 |
| `bare-cdot` | `Properties of` | `Properties of \cdot` | `Properties of \cdot` | 可 lowering; 不代表数学保真 | 0/0 |
| `math-cdot` | `Properties of $\cdot$` | `Properties of $\cdot$` | `Properties of $\cdot$` | 明确拒绝 latex-fragment | 1/1 |
| `math-alpha` | `Properties of $\alpha$` | `Properties of $\alpha$` | `Properties of $\alpha$` | 明确拒绝 latex-fragment | 1/1 |
| `math-alpha-sub` | `Properties of $_i$` | `Properties of $\alpha_i$` | `Properties of $\alpha_i$` | 明确拒绝 latex-fragment | 1/1 |
| `math-cdot-sub` | `Properties of $_i$` | `Properties of $\cdot_i$` | `Properties of $\cdot_i$` | 明确拒绝 latex-fragment | 1/1 |
| `math-frac` | `Properties of $a<span class="nocase">b</span>$` | `Properties of $\frac{a}{b}$` | `Properties of $\frac{a}{b}$` | 明确拒绝 latex-fragment | 1/1 |
| `math-product` | `Properties of $a  b$` | `Properties of $A \cdot B$` | `Properties of $A \cdot B$` | 明确拒绝 latex-fragment | 1/1 |
| `math-parens` | `Properties of \( _i \)` | `Properties of \( \alpha_i \)` | `Properties of \( \alpha_i \)` | 明确拒绝 latex-fragment | 1/1 |
| `math-escaped` | `Properties of $a+\$+b$` | `Properties of $a+\$+b$` | `Properties of $a+\$+b$` | 明确拒绝 latex-fragment | 1/1 |
| `math-open` | `Properties of $_i` | `Properties of $\alpha_i` | `Properties of $\alpha_i` | 可 lowering; 不代表数学保真 | 1/1 |
| `math-unknown` | `Properties of $a$` | `Properties of $\orgtexmacsunknown{a}$` | `Properties of $\orgtexmacsunknown{a}$` | 明确拒绝 latex-fragment | 1/1 |
| `math-macro` | `Properties of $x\myop$` | `Properties of $\newcommand{\myop}{x}\myop$` | `Properties of $\newcommand{\myop}{x}\myop$` | 明确拒绝 latex-fragment | 1/1 |
| `stm-alpha` | `Properties of (math "α")` | `Properties of (math "α")` | `Properties of (math "α")` | 可 lowering; 不代表数学保真 | 0/0 |
| `stm-rsub` | `Properties of (math (rsub "α" "i"))` | `Properties of (math (rsub "α" "i"))` | `Properties of (math (rsub "α" "i"))` | 可 lowering; 不代表数学保真 | 0/0 |
| `stm-frac` | `Properties of (math (frac "a" "b"))` | `Properties of (math (frac "a" "b"))` | `Properties of (math (frac "a" "b"))` | 可 lowering; 不代表数学保真 | 0/0 |
| `stm-rsub-control` | `Properties of (math (concat "α" (rsub "i")))` | `Properties of (math (concat "α" (rsub "i")))` | `Properties of (math (concat "α" (rsub "i")))` | 可 lowering; 不代表数学保真 | 0/0 |
| `fields-extended` | `Properties of field sentinel` | `Properties of Field Sentinel` | `Properties of field sentinel` | 可 lowering; 不代表数学保真 | 0/0 |
| `fields-traditional` | `Properties of field sentinel` | `Properties of Field Sentinel` | `Properties of field sentinel` | 可 lowering; 不代表数学保真 | 0/0 |
| `fields-date` | `Properties of field sentinel` | `Properties of Field Sentinel` | `Properties of field sentinel` | 可 lowering; 不代表数学保真 | 0/0 |
| `fields-unknown` | `Properties of field sentinel` | `Properties of Field Sentinel` | `Properties of field sentinel` | 可 lowering; 不代表数学保真 | 0/0 |
| `math-case-protected` | `Properties of an <span class="nocase">RNA</span> study of $a  b$` | `Properties of An <span class="nocase">RNA</span> Study of $A \cdot B$` | `Properties of An {RNA} Study of $A \cdot B$` | 明确拒绝 latex-fragment | 1/1 |
