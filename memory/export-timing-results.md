# Synchronous export timing results

User selected multiple document scales × INCLUDE/no-INCLUDE, using existing
tmp/realworld_test math only, independent flake, no system Emacs or business-code
changes. User clarifies "卡手" means perceptible blocking after invoking export.
Command wall time is relevant; this is not a measured per-keystroke latency claim.

## Verified result

96/96 actual standard frontend tm/PDF exports succeed. Three samples per cell;
values below are medians in seconds. Expanded sizes are6447/12859/25683/51331bytes.

| Body repetitions | Expanded KiB | Warm tm direct | Warm tm INCLUDE | Warm PDF direct | Warm PDF INCLUDE |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | 6.3 | 0.217 | 0.225 | 0.476 | 0.480 |
| 2 | 12.6 | 0.440 | 0.439 | 0.642 | 0.653 |
| 4 | 25.1 | 0.770 | 0.777 | 1.070 | 1.138 |
| 8 | 50.1 | 1.521 | 1.552 | 1.830 | 1.822 |

Cold direct tm medians1.222/1.450/1.786/2.486s, PDF2.047/2.242/2.697/3.414s.
Cold INCLUDE tm1.203/1.423/1.757/2.514s, PDF2.001/2.243/2.671/3.505s.
Direct worker-start inclusive median~0.93–1.01s. Cold PDF also includes first
native-render costs; do not equate entire cold/warm difference with startup.

Warm group median wait fractions89.8–95.8%; all96 measured intervals have0GC.
STM parse requests grow3/6/12/24. Warm direct tm cumulative STM waits
151/303/606/1201ms; serialize waits50/102/102/200ms. Warm direct PDF render waits
305/306/408/501ms, in addition to its similar STM waits. Thus worker waiting is
the dominant observed path, while preprocessing/Org/lowering are smaller here.
INCLUDE preprocessing group medians never exceed~20.2ms. Single INCLUDE overhead
does not explain most observed blocking; not a many/deep-INCLUDE conclusion.

org-texmacs-worker.el:78-87 accepts output from worker in up-to50ms slices;
worker-call:229-234 checks EOF on a separate socket client. ~50ms/request plus
different wait target supports investigating polling/wakeup granularity first.
No controlled alternative was measured: not proven50ms removable overhead, nor
native CPU timing. Wait includes native computation, IPC and scheduling.

## Reproducibility and limits

Independent tmp/export-timing flake uses pinned Emacs31.1/Org9.8.10/TeXmacs2.1.5,
x86_64-linux.17 enumerated package/document/license/lock inputs match inspected
project commit and frozen copies byte-for-byte. Root flake mirror edit excluded;
ordinary index empty. Actual measured package revision is the associated project
parent; diagnostic harness is generated untracked input, not committed product.

Sequential authorized commands, N=1,2,4,8:

```sh
timeout 240s nix build 'path:./tmp/export-timing#checks.x86_64-linux.bench-N' --no-link --no-update-lock-file --print-build-logs --print-out-paths
```

Each successful log has actual building and24 exports. Three repetitions happen
inside each build; rerunning unchanged Nix inputs may return cached measurements.
User authorized repeats, necessary locked-dependency networking and output copies.
No dependency/lock update. Failed initial harness loading (unclosed progn) and
overstrict non-nil worker liveness assertion were fixed before full sampling;
not product failures, unsuccessful partial runs excluded, raw failure logs lost.

One original TITLE, repeated original body without invented math. Frozen direct
and INCLUDE-expanded contents checked after every export (outer trim only), as
are source text/file/directory/modified/point/mark/restriction/tick and output
headers. Original test.org6447bytes SHA256
73e9e8da9310fa73561633efa410e9003883e8924db708b91cd2ca3e640985bb.
Frozen INCLUDE22bytes SHA256
cf802a0cc4da13622c21546d9fbd4c847c8e1d020c5360024cda66c0f337dbc6.
During measurement current original INCLUDE gained one trailing newline (23bytes,
SHA256 a2c797e42ed2e0a29242c5512b4a010bcfefc313367f4a242f8c6f07416b8ca4).
Agent did not modify originals; all scales consistently use frozen22byte input.

Timing excludes source visiting, explicit pre-run GC and worker stop. Cold means
new native process, not flushed OS/font caches; each scale has fresh home dirs,
reused within group. Warm immediately follows cold. Repeat2 reverses format/route
order. Advice is private to diagnostic process, records inclusive and exclusive
wall times; inclusive nested totals must not be summed. Uncovered frontend work
is residual; independent stage medians need not sum exactly to total median.

-Q --batch; discovery=nil, source-local with-toc=nil; no third-party extensions.
Recorded GC threshold800000/percentage1.0 may differ from interactive settings.
Three samples, one machine, uncontrolled external load. Repeating fixed content
also increases island/math/request count: no isolation of pure prose size effect.
No direct tracing of user's interactive setup, key latency, CPU time, bibliography
discovery or deep INCLUDE. Durations quantify this workload's perceptible command
blocking, not a guaranteed user-session reproduction or statistically proven speed.

## Evidence and next decision

Selective20-text-file immutable archive:
archive/2026-10-15T07-59-37Z--4839029/MANIFEST.md. Contains flake/lock/script,
fixed fixtures, provenance manifests,96 raw results,4 build logs, summary/CSV,
analysis script and full Chinese REPORT.md. Exact bytes verified before checkpoint;
CSV's33CRLF lines and verification note's trailing blank retained/documented.
Duplicate run.log/native products/dependencies/package copies excluded. Original
evidence has independent nondeterministic measurement/reproduction value; current
decisions are extracted here, not delegated to archive. Locate introducing GAW
checkpoint through manifest first-parent history, not a semantic checkpoint OID.

Current recommendation: investigate small-request polling/wakeup vs native work
before selecting optimization. Reducing synchronous latency and allowing editing
during export are distinct options; waits dominating supports exploring earlier
nonblocking candidates, not yet choosing one. No business-code optimization,
async/prototype/test expansion, staging or implementation selected. See
memory/nonblocking-export-investigation.md and deferred candidate in backlog.md.
