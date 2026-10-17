# Private PDF footnote macro compatibility: isolated integration acceptance

## Motivation and authority

User clarified only org-texmacs own stable exports are required, not independently
opening/re-exporting saved tm in GUI. Then explicitly requested isolated testing
of safe/stable document-local native macro override in actual exporter path.
Same previously authorized exact command, repeated for this investigation:

```sh
timeout 600s nix build path:./tmp/footnote-forward-probe#checks.x86_64-linux.footnote-forward --no-link --no-write-lock-file --print-build-logs --print-out-paths
```

User also authorized related dependency/output reads/copying. Root tmp boundary
verified ignored/untracked/nonsymlink.31root input hashes remain stage4-accepted;
copy differs only probe flake and org-texmacs-worker.scm. Production/root lock/
index unchanged, original user flake workaround preserved. No ordinary staging,
commit, installed native style/system config change. No production fix authorized
or implemented; prototype compiled into isolated package by existing Nix builder.

## Candidate and test instrumentation

Only copied worker changed. Read active render-footnote* after existing first PDF
print initializes style; require exactly one native set-binding whose key equals
merge(footnote-, arg nr); prepend label with same dynamic key, preserve original
binding, install with init-env-tree in private render buffer before final layout/
print. No Org AST/footnote-number prediction/worker protocol addition. Explicit
initial render-footnote* override skipped/preserved. Unsupported native macro
shape errors in probe; formal policy not decided for other styles.

Test-only mode file enables/disables/injects after-override error. Native event
log verifies private buffer closure, private file removal (url no longer exists),
guard session unchanged after success/failure. Persistent session has custom
render-footnote* sentinel; compare body/style/all initial plus actual macro before/
after private rendering, and Elisp public readback, same worker object throughout.
This detects global changes/session mutations/restarts, not only process exit.
No instrumentation should become public API or production code by default.

## Final outcome

Pinned Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux, generic/article. Final gate
exit0 PRIVATE-INTEGRATION-OK44, successful output:
/nix/store/jrrfilgir89s9nx64f6bajc4a5wm1q1s-org-texmacs-private-footnote-integration
Copied root tmp/footnote-forward-probe/integration-results. Formal public
org-texmacs-document-save-pdf and org-texmacs-export-to-pdf-file exercised; minimal
third repeat also uses org-texmacs-export-to-pdf frontend. Package uses copied
candidate worker, no standalone native bypass or system Emacs.

44PDFs:6disabled baselines,8no-note/explicit-custom-macro controls,30patched note
exports.54main-text forward links all have correct body targets. Cases: minimal
anonymous2notes, named definition/repeat, bold/italic note content, cross-page notes,
no-note, explicit macro, error after override and recovery. Each main group3repeats
has exact visible-text/layout/target-geometry equality. Minimal/after-failure/
disabled-after layout and numbering equal original baseline; named-repeat visible
layout equals disabled named-note baseline. Existing repeated-reference target
coordinates equal unpatched original exactly. Source text, prepared document body
and serialized bytes unchanged around each export.

46attempts including2injected rendering errors:38patched,6disabled,2explicit-macro-
preserved;46buffer-closed,46file-removed,46session-intact events. Both error cases
produce no public output file, preserve worker/session, subsequent repeated exports
recover. Disabled after patched exports again misses native first-use destinations,
so patch not globally persistent. Explicit user initial macro not overwritten;
this is not a promise that arbitrary custom macros' note links are repaired.

## Target-coordinate semantics and harness corrections

Correct footnote page/body line is required, all markup runs on that line merged.
Named first-use zero-width anchor lies near line end, about5pixels beyond glyph
run in observed case; bounded x adjacency <=one line-height accepted, not arbitrary
page position. Existing repeat target exact baseline; other new targets strict
line bounds. Not all targets claimed inside glyph rectangles. GUI clicks and PS
exact landing unverified. Native duplicate destination warnings retained, not
asserted universally harmless or removed by this prototype. Caption footnote
layout, arbitrary styles/versions/custom macros not certified.

Rejected intermediate harness outcomes: frontend file-name/default-directory
mismatch correctly rejected by existing composition/resource guard; first error
backtrace output truncated, then compact condition identified it. After corrected
fixture all rendering/state checks completed, inspector failed strict named x
word-box assumption; disabled named baseline added. Raw y sorting swapped same-line
different-font markers; group line then sort x. Earlier attribution to repeat anchor
was too early: new first-use anchor near line end, original repeat target stable.
Markup font splits then showed first-run text-box assumption invalid; merge all
font runs on correct body line. Final full gate passes without dropping source/
session checks or treating mere destination presence as sufficient. Five rejected
intermediate builds not acceptance; two deliberate final errors are safety controls.

## Artifacts, provenance and next action

Root task INTEGRATION-REPORT.md explains exact command, counts, interpretation;
integration-inputs.json pins candidate/harness, integration-worker.patch and its
generator reproduce modifications against delivered baseline. Full31source identity
manifest and prior native archives remain unchanged. Runtime is uncommitted
candidate worker plus test-only hooks, no project parent inferred. Fourteen necessary text artifacts byte-verified and archived separately:
archive/2026-10-17T18-51-51Z--aa9adbc/MANIFEST.md.
Archive-only checkpoint; prior archives immutable, no whole PDF/dependency/source capture.

This supports internal private-export compatibility candidate. User should select
formal production implementation/maintained regression before shipping, strip
probe controls/guard prints/fault hooks, decide missing/foreign macro policy and
avoid silent global overwrite. No extra release gate inferred or GUI prerequisite.
