# Default-on STM font-lock implementation

## Contract and change

User-authorized editor presentation, default enabled, ordinary internal
buffer-local `org-texmacs--font-lock-enabled` override; no dedicated command,
minor mode or Customize option. A nil default/local binding suppresses STM
presentation. Variable/tag changes schedule normal JIT invalidation; disabled
buffers regain Org presentation. Existing/new Org buffers are covered when the
main package loads; native Font Lock itself remains under Emacs control.

Five task paths: new `org-texmacs-font-lock.el`, one main require, one Nix fileset
entry, maintained ERT and README. `flake.nix` also has the user's preexisting
mirror overlay, which is preserved and excluded from the task-only patch.
No ordinary staging/commit, version/lock/worker/parser/export changes.

Org local element lookup supplies paragraph/block context. A private paragraph
view reuses canonical boundary/masking logic; no whole-source fragment-map per
match and no STM/native worker. Invalid editing input is softened locally to its
paragraph. Special-block bodies are independent of configured fragment roots.

Normal Org fontification runs first. Within STM islands its activation/hiding
properties are removed, then native Scheme properties copied from the Org helper
in a private view (leading newline handles point-min safely). Scheme syntax
properties are intentional: lexical string/comment/parenthesis presentation,
not native STM validation, arbitrary Scheme support or evaluation. Block delimiter
faces remain Org. An owned whole-context property plus before/after-change
markers handles deleted delimiters and old/new range invalidation. Half-open
ranges prevent adjacency chains. Bounds are clipped before accepting contexts;
major-mode cleanup restores the original callback unless another caller took
over it, and clears owned properties. No source characters/undo edits.

## Locked verification and source identity

All builds/tests use a standalone path flake with Nix path inputs, never host
Emacs or host-relative test files. User authorized repeats, locked dependency
access and result copies of:

```
timeout 120s nix build 'path:./tmp/font-lock-implementation#checks.x86_64-linux.baseline' --no-link --no-update-lock-file --print-build-logs --print-out-paths
timeout 180s nix build 'path:./tmp/font-lock-implementation#checks.x86_64-linux.focused' --no-link --no-update-lock-file --print-build-logs --print-out-paths
timeout 120s nix build 'path:./tmp/font-lock-implementation#checks.x86_64-linux.performance' --no-link --no-update-lock-file --print-build-logs --print-out-paths
timeout 600s nix flake check path:./tmp/font-lock-implementation --no-update-lock-file --print-build-logs
```

Locked x86_64-linux, Emacs31.1/Org9.8.10/TeXmacs2.1.5. Other platforms/versions
not tested. Baseline capture context b97082033663dd32a1f9960a3d54dd56a0d84800.
17 baseline source/README/license/lock files match that committed project state.
27 candidate root/snapshot identities (including all eight test-tree files) are
recorded in candidate-inputs.json. Root flake identity includes preserved overlay;
standalone flake intentionally adds explicit baseline/focused/performance checks.

Initial causal baseline8/8fail0.386417s. Final baseline11cases:10fail/1pass,
0.789412s, confirming feature is absent from the old source; header-only narrowing
is a nonfeature control that already passes. Latest focused11/11pass0.853644s,
including separate Emacs processes with existing Org buffer and t/nil pre-load
defaults. Earlier complete449/449282.370992s and strict compile/lint passed.
Final451/full gate: exit0;451/451passed283.173420s, strict compilation and package-lint passed.
Final focused11/11passed0.853644s; final baseline10expected failures/1control
pass0.789412s. Only compatible current-system checks were executed.

Coverage: unchanged text/modified flag/character tick/point/mark/undo; 11default
roots/custom tags/invalid-config soft handling; paragraph/inline-note/multiline/
mixed-case blocks/list/quote/independent note; heading/table/emphasis/code/link/
source exclusions; embedded Org hiding/link suppression and disable restoration;
quotes and block delimiter edits; buffer/default isolation, narrowing, Font Lock
and major-mode cleanup; bounded scanner-call/size guard and no worker calls.
Fresh-process tests cover loading after existing Org buffers and nil before load.

Diagnostic history: initial baseline script assumed a sibling file in Nix store;
fixed by explicit Nix path. Two extra ERT parentheses were fixed before causal
baseline. Strict compiler required Font Lock dynamic-variable declarations.
Candidate helper point-min assumption, list-first lookup and endpoint-expansion
chain fixed before green. Final restricted-header test reproduced reversed body
bounds17..16 (9/10red), then passed with clipped bounds guard. These failures are
extracted here, not hidden or misattributed to the native STM parser.

## Cost and remaining limits

Dense synthetic ASCII documents with one STM per short paragraph; single full
ensure and one mid-document letter insertion/local ensure per condition. Enabled
and disabled are otherwise matched. Final cost table: 

| Bytes | Full ensure on (s) | Insert on (ms) | Re-fontify on (ms) | Re-fontify off (ms) |
|---:|---:|---:|---:|---:|
| 4,109 | 0.0775 | 0.157 | 2.338 | 0.057 |
| 16,407 | 0.2769 | 0.485 | 6.592 | 0.057 |
| 65,547 | 1.1048 | 1.506 | 25.230 | 0.057 |
| 262,159 | 4.2821 | 7.890 | 146.804 | 0.070 |
| 1,048,581 | 17.4026 | 40.415 | 489.012 | 0.096 |

Final source revision costs recorded from
`/nix/store/xc3lzpqnxc6ywhv8q2gcvc193hzyyiy4-org-texmacs-font-lock-performance`.

Initial 4/16/64/256KiB/1MiB full ensure0.080/0.277/1.062/4.162/17.066s;
re-fontify0.00226/0.00689/0.02406/0.13681/0.47832s versus disabled0.00005–0.00015s.
Remaining enabled context/cache maintenance scales with source size, despite
bounded STM paragraph scan counts. Do not attribute it to ordinary disabled Org
or promise constant-time editing. Initial/full ensure is not a measurement of
visible-only GUI JIT rendering; large owning paragraphs/blocks remain whole
processing units. Single-run synthetic data is not a universal complexity theorem.

Batch activates registered font-lock/jit-lock hooks in named buffers under a
controlled noninteractive=nil activation; explicit ensure/flush then validates
lifecycle. It does not certify GUI idle redisplay, folding, actual sexp navigation
experience or third-party mode coexistence. Manual fixture and procedure are
`manual.org` and `MANUAL.md`; user interactive acceptance remains pending.

Optional Org-roam/extension integration was not newly run; complete core ERT
includes native STM, preprocessing, session, direct/reload PDF and export API
regressions. No new external issue or publication action.

## Reproduction/preservation

Candidate.patch contains only the five task changes, excluding the user's
preexisting flake overlay. Baseline production files/lock and unchanged tests
are recoverable from capture HEAD. Apply the task patch to a disposable copy;
restore baseline/ from the17hashes and use the standalone archived task flake
for extra check targets. The standalone flake includes the tested mirror overlay;
root/candidate flake hash therefore has a different role. Each builder input is
captured through a Nix path. Reports and scripts are unique temporary evidence;
no full production/dependency tree or binary archive is needed.
