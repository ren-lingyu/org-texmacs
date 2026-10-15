# Nonblocking export feasibility investigation

## Status and conclusion

User selected investigation and GAW recording only, explicitly no business-code
changes. Read-only static analysis on the user-committed Issue6 repair revision;
ordinary index empty, only pre-existing user flake.nix mirror dirty. This static
phase ran no benchmark, test, prototype or process/thread launch.
Subsequent separately authorized measurements are extracted in
memory/export-timing-results.md; they do not adopt an async implementation. External
reads were public primary documentation/source only. No implementation adopted.

Nonblocking export is feasible. A bounded prototype is comparatively small;
reliable support preserving current configuration/hooks/source guards/result
ownership is medium to high effort, not merely accepting ASYNC or changing one
wait call. Effort is qualitative architecture assessment, not a time estimate.
User later clarified "卡手" means perceptible blocking after invoking export.
The subsequent96-export batch matrix quantifies related wall time and attributes
89.8–95.8% of warm command wall time to worker waits, without isolating native versus
polling/transport costs or tracing the exact interactive session.
Nonblocking UI and parallel native conversion are distinct: initial implementation
could serialize all jobs and still return control to editing.

## Local evidence and actual boundaries

- ox-texmacs.el:34-40 explicitly rejects ASYNC; all three frontend commands
  complete conversion before returning a buffer/path. An asynchronous branch can
  reuse the existing argument position, but must define a different immediate
  return/job/error contract; keep existing synchronous Lisp APIs intact.
- org-texmacs-worker.el:78-87 waits synchronously via accept-process-output in up-to50ms
  slices; request path at202-246 and cold startup at89-140 both wait. An external
  TeXmacs process already exists, but its caller has not returned to the normal
  command loop. Waiting for output is not the same as spinning CPU, and these
  slices are not measured input latency or proof of the user's bottleneck.
- org-texmacs.el:335-566 captures source/parser/configuration, runs preprocessing,
  AST work, sequential island/BibTeX requests, native formatting, owned input,
  consumer and final check within one synchronous call. Org parsing, validation,
  tree copying/lowering and response encoding/decoding also execute in Emacs.
- org-texmacs-session.el:294-332 consumes completed documents for native serialization/PDF.
  Scheme worker at236-247 executes two groups of three updates and two prints;
  this suggests a potential native wait hotspot, not measured dominance.
- org-texmacs-worker.el:206-208 guards one request with dynamically bound --worker-busy.
  Scheme serve loop at538-563 accepts/handles/closes one client at a time. Existing
  native sessions share that worker. UI responsiveness does not require changing
  this into multiple parallel TeXmacs renderers.
- --prepare-buffer calls its final check only after CONSUMER returns (555-565).
  Returning a pending token from the consumer would end validation too early.
  Existing private buffers/unwind-protect cleanup and scoped native-helper
  substitutions cannot simply outlive their call frame accidentally.
- Source guards include live source identity/text/settings/selection/restriction;
  dependencies have captured receipts. Long-lived background work creates more
  opportunities for legitimate edits; stale result handling needs an explicit
  policy without silently weakening current fail-on-change semantics.

## Candidate approaches

| Approach | Prototype / production effort | Benefits and principal limits |
| --- | --- | --- |
| Same-process cooperative export thread | Low to medium / medium, possibly higher after callback audit | Existing synchronous stack/closures and live configuration can largely remain. Output waits yield to other threads. CPU-heavy phases still need yield/chunking or isolation; not full parallel Lisp execution. |
| Callback-based worker requests and resumable conversion job | Medium / high | Persistent native worker and actual source context retained; serial request queue can coexist with editing. Requires async startup/framing/timeout/cancellation plus continuations across preparation and native consumers; long Lisp phases remain synchronous unless separately addressed. |
| Background Emacs process, optionally through Org async helper | Low to medium for constrained demo / medium to high for current full compatibility | Isolates Lisp CPU and worker waits from the editor, reuses synchronous conversion inside child. Requires init/load-path/package/environment setup, owned context transfer, hook/filter/formatter and third-party DB semantics, source validation in parent and child cleanup. Fresh native worker startup may cost more. |

Cooperative-thread route deserves the first small feasibility probe if measurements
show native waiting dominates. This is an investigation recommendation, not an
adopted implementation choice or a promise that it fixes the observed symptom.

For threads, --worker-busy's dynamic let is thread-local and therefore insufficient
as a cross-thread lock. All existing synchronous and prospective asynchronous
worker users need one shared serialization mechanism; locking only new async jobs
would leave synchronous session/export races. Audit shared process state and
temporary symbol-function rebindings in preprocessing/context, especially where
callbacks or waits can yield. Current-buffer is thread-specific, but buffers,
symbol functions, process state and much user state are shared. New threads do
not inherit the caller's dynamic let environment. These are risks requiring
validation, not demonstrated current races in this single-threaded program.

Callback route requires persistent owned job state instead of relying on dynamic
extent: captured input/context/checks, process incarnation/request ID, timeout,
completion/cancel/error handling, result publication and disposal. Sequential
STM/BibTeX/native operations must resume in order. Existing EOF framing can remain;
no inherent need to change wire protocol or Scheme parser for serial async jobs.

For child processes, Org's org-export-async-start is a lower-level process helper
and may evaluate a direct package call; generic org-export-as remains intentionally
unsupported. Org's generic to-file/to-buffer helper is not a drop-in route here.
Text/configuration/functions with closures, live database state and mode/advice
setup cannot be assumed portable to another Emacs. Printing a structured Lisp
snapshot for IPC is compatible with AST-first design; converting the AST to a
target-language intermediary and reparsing it is not required or recommended.

Moving only final PDF rendering/serialization out of the main thread/process is
a smaller partial milestone, but preparation still performs synchronous native
island/BibTeX requests and Lisp work. Do not advertise it as complete nonblocking
export unless those remaining stalls are measured and acceptable by an adopted
support contract. Timers merely postpone synchronous work; they do not by
themselves make it nonblocking. Simply replacing accept-process-output with a
different blocking wait does not solve the caller's synchronous lifetime.

## Decisions needed before a production implementation

1. Capture source, scope, naming, effective options and callback identities at
   invocation, before returning control; specify transfer/initialization limits.
2. Distinguish nonblocking single-job execution from parallel export. Start with
   one shared worker owner/serial queue or explicit busy rejection; selection is
   not made in this investigation.
3. Define completion/cancel/error reporting and immediate return value. Preserve
   byte/buffer/path return contracts for existing synchronous calls.
4. Keep stale source/dependency checks through final completion and publication.
   Default assessment assumes existing rejection on source changes; accepting
   stale snapshots would require a separate explicit design decision.
5. Keep file naming/overwrite and managed buffer ownership/failure contracts.
   Delayed output must recheck the destination and user takeover, prevent older
   jobs from replacing newer results, and define cancellation's session impact:
   current transport cancellation stops the shared worker and invalidates session
   handles; suppressing publication while draining a request or isolating jobs may
   be needed if preserving a live session is required. Publication stays in the parent for child jobs
   if preserving parent-side last-moment guards.

## Recommended next investigation if authorized

Measure warm/cold actual tm/PDF exports, including realworld INCLUDE input,
with timestamps for source capture, native composition/Org parsing, island parse,
lowering, native rendering/serialization and publication. Measure actual command
return/input responsiveness as well as total elapsed time; prior ERT/probe runtimes
do not establish UI latency. Do not run those commands under this read-only task.

Then compare a small cooperative-thread probe (including another sync worker
caller, source edits and cancellation) with a constrained background-process probe
if Lisp CPU or unsafe callback state dominates. Validate actual user's modes/hooks/
DB configuration rather than only clean -Q fixtures. Proof needs an interactive
editor remaining usable during work, consistent output, unchanged source,
stale-result rejection, no races/leaks on errors/cancel, and preserved native session.

## Primary references and limits

- Org dispatcher manual documents external Emacs process async export, async init
  file and result stack: https://orgmode.org/manual/The-Export-Dispatcher.html.
- Official Org main ox.el org-export-async-start at6408-6496 recreates a source
  copy, launches a batch Emacs and consumes results in its sentinel:
  https://raw.githubusercontent.com/bzg/org-mode/main/lisp/ox.el.
  This is current upstream reference, not verified locked Org9.8.10 API behavior;
  exact Emacs31.1 bundled ox.el web fetch failed. Any adoption requires checking
  actual locked/minimum version and package-specific native resource cleanup.
- Emacs31.1 thread manual documents cooperative switching, output-wait yield,
  thread-local dynamic bindings/current buffer and new thread initialization:
  https://raw.githubusercontent.com/emacs-mirror/emacs/emacs-31.1/doc/lispref/threads.texi.
  It does not prove this project's hooks or transport are thread-safe.
- GNU HTML thread/output-wait pages timed out; no runtime probe was substituted.

No unique original-byte experiment or retired source to archive. Public references,
local code anchors, limits and decision boundaries are distilled here; project
history supplies the examined source snapshot. No new external issue created.
