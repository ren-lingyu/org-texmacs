# Large byte-step no-INCLUDE measurements

User requested large byte steps after finding the first~50KiB matrix insufficient.
Independent flake, existing mathematics only, no business code changes. Four
sequential authorized600s builds finished.16measured outcomes:10successful native
exports,4expected standard frontend size rejections,2native worker errors. All16
source-state checks pass. Build success means diagnostic completion, not all
exports succeeding. No automatic timeout increase or failure-to-success claim.

## Results

Single warm-worker sample per route/format/size, seconds, not medians:

| Source bytes | Lines | Standard tm | Standard PDF | Explicit-source tm | Explicit-source PDF |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 64155 | 1811 | 1.852 | 2.822 | 1.828 | 2.172 |
| 256515 | 7241 | 7.427 | 8.689 | 6.986 | 7.998 |
| 1025955 | 28961 | reject0.018 | reject0.017 | 29.329 | 30.852 |
| 4103715 | 115841 | reject0.072 | reject0.065 | error118.046 | error115.652 |

Standard full-document commands reject at existing256KiB preprocessing budget,
even without INCLUDE, before STM requests. Explicit-source file APIs run direct
preparation under their existing contract; no production limit was changed.

Large explicit requests keep worker-request-timeout=10. At4103715bytes, both
complete1920STM parses first, waiting101.180s(tm)/98.874s(PDF), then final
wait_serialize/wait_render-pdf lasts~10.001s and returns generic
`TeXmacs worker failure: ... Worker exited or timed out`. Response wait reaches
configured deadline; no separate native-process tracing to distinguish exit and
expiry.118/116seconds are failure latencies, not successful exports. Worker restarts
outside timing before PDF after tm failure; live process does not mean warm render.

## Phase interpretation

Explicit-source STM calls grow30/120/480/1920; waits approximately1.5/6/24–25/
99–101seconds.1MiB serialize2.304s/PDF render5.120s;4MiB both final waits fail
after~10seconds. This is a final native response boundary, not a preprocessing
source-size rejection. No proven guarantee that longer request timeout would
complete successfully, and no longer-timeout measurement selected.

At~1MiB Org preparation~0.19–0.20s, native wire~0.33s, GC0.118/0.133s. At~4MiB,
Org preparation1.237/1.227s, lowering0.506/0.492s, wire1.348/1.302s, GC0.267/
0.290s(4collections each). GC overlaps those timed phases and must not be added
again. Worker-response waits dominate this workload; not pure native CPU time.
Previous small matrix's zero-GC finding must not be generalized to these sizes.
Emacs phases are seconds at large scale and still relevant to nonblocking design.

~50ms small STM request waits remain a poll/wakeup candidate. Native computation,
transport, scheduling and polling remain combined in wait metrics. At fixed math
density, growth also increases sequential request count; not independent proof
that source byte size alone causes the observed slope or that all wait removable.

## Exact environment, calls and evidence

Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux. Same17enumerated package sources,
docs/LICENSE/lock match associated committed project snapshot, frozen copies and
current files. Root flake mirror unchanged by agent; ordinary index empty.
Original tmp/realworld_test/test.org unchanged6447bytes, SHA256
73e9e8da9310fa73561633efa410e9003883e8924db708b91cd2ca3e640985bb.
Frozen TITLE retained once, body10/40/160/640repetitions. No INCLUDE or invented
math. Workload hashes are reconstructions from preserved fixture/formula, not
independent hashes acquired from removed build-input files.

Authorized exact command with LABEL=64k,256k,1m,4m, in order:

```sh
timeout 600s nix build 'path:./tmp/export-timing-large#checks.x86_64-linux.bench-LABEL' --no-link --no-update-lock-file --print-build-logs --print-out-paths
```

Authorization includes necessary pinned-dependency network/store/cache, temporary
large input read/write and result copying. No system Emacs, lock update, business
edits, ordinary staging, expanded production bound or timeout. Success logs show
actual building; rerun unchanged derivations may return existing measurements.

Each isolated scale has fresh HOME/native home; runs frontend tm,frontend PDF,
explicit-source tm,explicit-source PDF in fixed order. Calls:
org-texmacs-export-to-texmacs/org-texmacs-export-to-pdf versus
org-texmacs-export-to-texmacs-file/org-texmacs-export-to-pdf-file. Startup excluded
by ensuring worker live first; file creation/visiting, explicit pre-run GC and
post-run validations excluded. Full per-type cache warming not done, so fixed
order/native font/render caching confounds comparisons between API routes.

-Q --batch, discovery=nil, with-toc=nil, GC threshold800000/percentage1.0.
Diagnostic-only advice records inclusive/exclusive wall time, not CPU. Inclusive
nesting must not be summed. Source text/file/directory/modified/point/mark/
restriction/tick checked after success and error; success headers validated.
Frontend successful small cases also compare preprocessing source text. No full
native-content/layout equivalence test or user's actual GUI input trace. Single
sample/machine, uncontrolled external load; math/island density fixed, not pure
prose benchmark. No asymptotic complexity or universal support claim.

20necessary original-byte text artifacts selected and verified at immutable
archive/2026-10-15T08-21-16Z--4839029/MANIFEST.md: independent flake/lock,
benchmark/analysis scripts, one frozen example, manifests/verification/workload
recipe,4raw JSONs,4build logs,summary CSV/JSON and full Chinese report. Preserve
one original trailing blank in benchmark.el, documented; no whitespace-clean
snapshot claim. No generated MiB input/native binary/dependency/package dump.
Locate introducing GAW checkpoint via manifest first-parent history. Project
association represents exact measured package revision, not provenance of every
temporary script/result. Current extraction is this file; archive is evidence.

## Next boundary

User accepts this investigation as sufficient basic motivation to develop
parallel/nonblocking export. Near-linear observed total growth (roughly4x time
for4x bytes across successful sizes) does not eliminate perceptible synchronous
blocking. This is empirical fixed-composition scaling, not proof of O(n);
largest failure latency is not a successful-export complexity datapoint. No more
profiling needed merely to establish motivation. Nonblocking UI and concurrent
native conversions remain distinct possible goals; concrete route not adopted.

User-selected large-step experiment complete. Both standard256KiB budget and
explicit-source default response deadline constrain current large-document use.
No timeout-policy/limit change, parallel/async implementation or followup runtime
experiment automatically selected. Candidate next investigations: separate small
request polling/wakeup cost, study final large native request deadline with a
separately selected policy, or isolate prose size versus island count. Preserve
distinct goals of reducing total latency and allowing editing while export runs.
