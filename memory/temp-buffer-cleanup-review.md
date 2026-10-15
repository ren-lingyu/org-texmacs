# Issue #6 temporary-buffer cleanup proposal review

## Status and source

User requested review only, not implementation or tests. Read at the accepted
case-insensitive wrapper project revision, matching INBOX's stated main baseline.
Ordinary index empty; only existing user flake.nix mirror dirty. INBOX.md is an
ignored active proposal,8020bytes, SHA256
f3836590fae58be2d2f81ba2c79b3b651b51cdc311ffdce390db8d5feb30b72e.
Tracking supplied by proposal: https://github.com/ren-lingyu/org-texmacs/issues/6;
related preprocessing/API history #1/#3, separate mapping work #4. Remote issue
contents/state not independently verified, no external write.

## Proposal extracted independently of INBOX

Reported full frontend .tm/PDF exports show a modified *temp* kill confirmation.
Expected: internal owned working buffers disposed without confirmation on success
or error; source/user buffers and original errors/results preserved. Exact target
and stack need runtime tracing; static suspicion is not proof of observed origin.

Full unselected unnarrowed frontend route: export-to-texmacs/export-to-pdf ->
--export-byte-consumer -> --preprocess-convert -> --preprocess-compose. Its
--preprocess-context assigns original file context, then text/hook/include changes
leave private buffers modified. Bibliography discovery separately assigns file
identity in the private --document-prepare-source/filter preparation lifetime.

Investigation: use real visiting-file Org source and both file commands; observe
publication timing, compare non-file/local scopes and discovery false/true. Trace
actual kill target/name/file/modified/mode/stack in test/diagnostic scope. Check
errors after insertion, hooks, INCLUDE and parsing; preserve actual source text,
identity/modified flag/point/mark/restriction and unrelated user buffers.

Proposed repair belongs to owned temporary lifetimes only: retain file/directory
context until processing/callbacks finish, use unwind-protect to remove own visiting
identity or clear own modified flag immediately before with-temp-buffer cleanup.
Capture actual buffer object, test live and use with-current-buffer if callbacks
switch current buffers. Keep cleanup from replacing original failures. No global
confirmation/kill overrides, source flag edits, private save or fallback bypass.
Keep API/overwrite/AST/snapshot/native rendering/mappings unchanged.

Regression plan: actual frontend .tm/PDF success, no leaked working buffers;
controlled failure after modification, original error/no new output, existing
output unchanged; full source-state assertions including initially modified source;
discovery and local/direct paths. Stub only native output consumer when useful,
never preprocessing or buffer destruction. Confirmation interception must be local
to scenarios where no prompt is expected. A regression must fail before repair.
Then authorized focused ERT, native/integration and regular complete Nix gate;
proposal suggests nix flake check --no-write-lock-file, but no command is presently
authorized. Record actual cause/paths/evidence and close #6 through fixing commit/PR
only after acceptance. No release or unrelated mapping redesign selected.

## Findings

1. High-priority test gap (INBOX lines69-78,86): current tests/ert/run.scm invokes
   Emacs -Q --batch. Fkill_buffer tests INTERACTIVE && modified; INTERACTIVE means
   keyboard input environment (not batch and not executing keyboard macro), not
   whether kill-buffer itself was invoked as a command. Replacing yes-or-no-p in
   an ordinary batch test can pass before the repair. Specify how the test enters
   this environment-sensitive branch (a narrowly scoped noninteractive=nil binding
   with safe confirmation interception is a candidate) and a positive baseline
   control proving it catches the pre-fix path. No runtime verification performed.
2. Medium-priority coverage gap: --preprocess-compose capture at line245 has an
   independent with-temp-buffer that calls context(file), inserts and protects
   included text. Root working buffer at line272 is separate. A non-file root
   still creates a visiting INCLUDE capture. Add success and post-modification
   error coverage for that lifetime; root-only repair is insufficient. The line252
   selection helper does not assign file identity and is not automatically affected.
3. Repair boundary is compatible with canonical source/owned snapshots and full
   versus local routing. Bibliography callback at line54 assigns file identity in
   --document-prepare's inner buffer; verify actual runtime paths before choosing
   shared abstraction or changing every temporary-buffer site.

## Primary source and limits

GNU manual initially timed out. Official Emacs31.1 manual source buffers.texi
lines1042-1046 explicitly describes confirmation even for noninteractive Lisp
calls. Emacs31.1 buffer.c lines1826-1835 contains INTERACTIVE && modified. Official
master commands.h defines INTERACTIVE as
(NILP(Vexecuting_kbd_macro) && !noninteractive); exact31.1 header fetch failed.
These source references support the batch-mode gap; they are not a runtime trace:
https://raw.githubusercontent.com/emacs-mirror/emacs/emacs-31.1/doc/lispref/buffers.texi
https://raw.githubusercontent.com/emacs-mirror/emacs/emacs-31.1/src/buffer.c
https://raw.githubusercontent.com/emacs-mirror/emacs/master/src/commands.h
An initial commentary misread INTERACTIVE as command invocation, then explicitly
corrected after checking its definition/manual. No contrary claim is adopted.

No raw archive selected under global/project archive skills: active plan, no
retired source or unique probe/log; operational plan, findings and limits distilled
here. INBOX and production files left unchanged, no test/build/probe run.
