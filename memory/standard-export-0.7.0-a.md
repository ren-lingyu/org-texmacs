# v0.7.0 stage A: accepted candidate; human delivery pending

## Scope and inputs

Human CHANGELOG-only delivery440b331 is verified against the reviewed candidate:
expected v0.6.0 parent, same message and content except one removed blank after
TODO. Worktree/index clean. Snapshot tmp/standard-export-0.7.0-a/project contains
130 byte-identical tracked inputs; adjacent source-manifest.json binds SHA256
and source commit. Only added tests/standard-export-probe files change the copy.
Root sources/lock/index/result are untouched. Plan is
memory/standard-export-0.7.0-plan.md; no production implementation yet.

## Attempt 1

Disclosed scoped timeout120s nix build --no-link --no-write-lock-file --max-jobs2
--print-out-paths path:<experiment>/project#checks.x86_64-linux.standard-export-probe
-L exits1.110s internal ERT timeout. Seven probes, six pass, one fails in3.50s.
Actual texmacs backend replaces only isolated batch registration/guard; original
maintained frontend tests are not changed or run. Existing installed package and
native worker/serializer/PDF are used. Logs: attempt-1.log; exact pre-revision
probe.el/test.nix/test-overlay.nix retained under attempt-1/.

Confirmed: standard hook/filter order then ordinary transcoders then inner-template;
ordinary Org map resolves enough deferred data for the existing model owner on
these fixtures. Cite element/secondary results stay structured, string and
reentrant org-export-data results become raw; basic citation/bibliography yield
raw. Per-call catch delivery can construct a document with isolated nested model
construction. Direct native PDF succeeds; unknown effective final filter is
rejected, an explicitly known identity filter allowed; unrelated ASCII works.
These are focused probes, not production contract/regression acceptance.

Counterexample: native serializer has no final newline; standard file export
adds one. Byte-identity assertion fails126vs127bytes. Non-ASCII native output
also contains byteE9; permissive utf8 decoding/roundtrip is not sufficient proof
of a valid Unicode-text interface. Must examine text representation/coding and
native reload before choosing output contract.

Architecture concern: catch/throw out of inner-template crosses org-export-as
advice, so normal-return advice may not execute even though unwind-protect does.
Do not adopt it as successful structured delivery. Next compare scoped result
container plus normal string return/completion, with no meaningful string
postprocessing for native consumers and explicit effective-callback compatibility.
Test normal advice completion, nested isolation, exceptional cleanup and coding.

Retention assessment: initial failed byte-identity hypothesis and candidate
result-delivery alternatives have independent reproducibility value; preserve
selected text scripts/Nix inputs/logs/manifest/report after experiments stabilize.
No binary/PDF or full snapshot archive is selected. Raw archival capture and
verification/checkpoint are pending, not claimed complete.

## Attempt 2

Same scoped command exits1,9/10pass in3.44s. The probe now delivers via a dynamic
per-call result container and lets org-export-as return a string normally;
normal advice completion, unwind/error isolation and subsequent calls pass.
Latin1 transport roundtrips native bytes and standard file output equals native
bytes plus one terminal newline on the fixture. Direct PDF still uses owned
document, accepts known identity callback and rejects an unknown effective one.

The new structured-processor-to-document probe fails on CITE_EXPORT keyword,
not on the returned bold/paragraph structures: the thin prototype passes control
keywords straight to existing lowering, which rejects that keyword. Stage B/C
must classify nonrendering standard control syntax without repeating preparation.
Attempt3 moves test processor selection into ordinary Org configuration to
isolate structured-return feasibility from the known adapter gap; it does not
claim keyword adaptation implemented. The raw-boundary test is similarly refined
so an unrelated keyword error cannot masquerade as the raw output error.
Exact attempt2 inputs retained under attempt-2/ before revision.

## Attempts 3-5 and current gate

Attempt3 exits1,9/10pass in5.210878s: structured processor output reaches lowering
after ordinary processor configuration removes the unrelated CITE_EXPORT fixture
keyword. Native serialize diagnostic compared original versus parsed file trees
and failed; this does not isolate a terminal-newline effect. Attempt4 exits0,
10/10pass in5.138121s but its diagnostic file is empty, so it is not native
equivalence evidence. Both intermediate attempts are superseded, not archived.

Attempt5 exits0,12/12pass in6.667459s, with explicit native equality between
parse(serialized bytes) and parse(bytes plus terminal newline). UTF8 decoded
native byteE9 produces raw-octet Emacs characters, whereas ISO-Latin1 transport
is reversible with valid Unicode code points. Explicitly bound Latin1 file
coding preserves native bytes plus the standard terminal newline on this fixture.
Generic UTF8 file coding is not accepted by inference. Output artifact is
/nix/store/srjhvq4nfhhc51d0baya8h1nk8d6l8w6-org-texmacs-standard-export-stage-a.
Runtime Emacs/Org version strings were not separately printed; the source lock
and snapshot are retained, not a claim of a newly tested version range.

The two new passing tests intentionally prove defects of naive candidates:
throwing out of org-export-as skips normal advice completion; ignoring the
initial string result in a final-AST handoff discards a paragraph output filter's
changes. Neither is a supported behavior. Prefer normal-return scoped result
delivery. The user now explicitly adopts restriction/rejection of unsupported
node-string filters; complete node-filter support is not a0.7.0release gate.
Standard options/AST filters must retain full semantics, body/final-output filters
execute on final text. Detect unsupported effective callbacks as early as practical
before side effects, never execute and silently discard them; no STM text roundtrip
or parallel preparation for arbitrary string modifications. Next validate early
guards including callbacks installed by options/AST filters and invoked within Cite.

Do not claim A architecture accepted merely from12/12: result-delivery/coding/Cite
fixtures establish feasibility and counterexamples, not every A gate or actual
extension compatibility. Production minimal backend, broader supported filter/
finalizer policy, control-keyword/ignore-list adaptation and version verification
remain pending. No root source/docs/tests/index/lock/result changes.

## Verified selected archive

archive/2026-11-02T16-54-11Z--440b331/MANIFEST.md captures12original-byte text
files: complete report,130-input manifest, copied flake/lock, final probe/Nix
files, attempt1/2 probe scripts and logs, and final attempt5 log. The report
explains replay/selection/limits. All selected types/sizes/UTF8/byte comparisons/
hashes and unchanged capture-context HEAD are verified. Associated project
snapshot is the exact440b331baseline used; task-authored tmp files are not falsely
attributed to committed production source. No full snapshot or binary closure
retention. Archive-only public GAW checkpoint is complete, with the exact project
snapshot association; locate its introduction through manifest path history.
Raw-log trailing spaces are deliberately preserved for byte fidelity, not formatted.

## Adopted filter boundary and attempt 6

The user confirms node-string-filter completeness is not a0.7.0release gate.
Full options/AST semantics remain required; body/final-output filters execute on
final text. Reject unsupported node callbacks early before side effects, never
run then discard or emulate via STM roundtrips/parallel preparation.

Attempt6 same disclosed command exits0,18/18pass in8.603494s; runtime prints
Emacs31.1/Org9.8.10. Added guard fixtures verify initial, options-installed and
AST-installed effective node callbacks are rejected before invocation (counter0),
including before Cite processor execution after AST mutation. Normal options/AST
modification and final body/output filters still run; ASCII node filters remain
unaffected. Guards use backend options/tree callbacks for early checks, plus
backend-narrowed public org-export-data and org-cite-process-citations advice to
catch later installations/reentrant transcodes; no annotate-info advice/copy.
The extra public guards are needed because developer filters run before user
filters, so one early options/tree check alone cannot see later INFO changes.
Artifact: /nix/store/rcr4mcpvjb8aw9mpy197k9x6rlmgqcpf-org-texmacs-standard-export-stage-a.

Adopt normal-return scoped results and this guard boundary for minimal A
production implementation. Native text uses reversible ISO-Latin1 byte transport;
standard file callers must bind the matching coding, and native byte APIs remain
distinct. Basic/raw and standard control-keyword adaptation are explicit pending
B/C/D boundaries, not silently coerced. A minimal backend must reject unsupported
target structures rather than claim full v0.7.0 support. Broader adapter/command
migration is B-E, not part of the minimal node. Migrate proven probe properties
to maintained tests and run the ordinary full gate before declaring A delivered.
Attempt6 scripts/log remain in tmp; core prior counterexamples are archived.
Additional raw retention will be assessed against the maintained guard regressions
at node completion, not automatically duplicate the previous archive.


## Final maintained implementation and acceptance

The adopted inner-template handoff is implemented under the real texmacs identity.
Public narrow guards reject effective node-string callbacks before execution,
including late INFO installs and Cite reentrancy; standard final text filters
remain active. Structured consumers conservatively reject incompatible effective
text tails/finalizers without replay. Native Latin1 text transport is reversible;
PDF uses the completed native document directly. Legacy conveniences stay old
until E; STM/raw/ignore-list adaptation remains an explicit error boundary.

Production refinements fixed request plist ownership, source file/directory
string aliasing, request leakage during native waits and outer advice/nested
exports. The final request token is single-use and stripped before preparation
and INFO; its dynamic binding ends before native consumption. Maintained tests
cover these regressions, normal return/error handling and source mutation checks.
Earlier full attempts exposed formatting/stale generic-rejection expectations,
then passed675/676/677ERT as ownership/isolation cases were added; these are
superseded by the final accepted snapshot, not unresolved failures.

Focused core269/269 and final full-attempt-6 pass; the full gate reuses that exact
core result and freshly passes native341/PDF-document33/PDF-render29/patched6:
678ERT, zero unexpected, all12flake checks including strict compilation/lint/fmt.
Command: timeout 600s nix flake check -L --no-write-lock-file --max-jobs 2
--keep-going path:/home/lingyu/Projects/org-texmacs/tmp/standard-export-0.7.0-a-production/project
Runtime: Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux. No other-platform,
minimum9.8behavior, real extension or additional examples-build acceptance.
Active accepted manifest: memory/standard-export-0.7.0-a-inputs.json (133inputs),
byte-identical to the isolated source-manifest.json and ordinary root inputs.
Final log: tmp/standard-export-0.7.0-a-production/full-attempt-6.log.

Additional guard prototype evidence was selectively archived and checkpointed:
archive/2026-11-02T17-28-52Z--440b331/MANIFEST.md, preserving original REPORT/probe/
log bytes with hashes and referring to the first snapshot for replay baseline.
No new raw production-log archive is needed after maintained regressions and
accepted input identity. No binaries or whole production copy archived.

README/CHANGELOG and worktree-based tmp/commit.md now describe the11-path minimal
candidate, subject feat(export): add standard Org export handoff. Ordinary index
is empty and HEAD440b331 unchanged. A is validated, not human-delivered; await
human commit and compare parent/paths/message/all133hashes before B. No version
bump or TODO release transition. B-E remain pending.
