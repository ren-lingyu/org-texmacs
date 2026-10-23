# Tests migration and refactor

## Adopted scope and authority

User approved the conversational migration plan after readonly investigation of
current tests and explicitly authorized ~/emarccs/tests as the reference. The
boundary forbids ../, cwd or inferred roots for external file discovery; Nix
functions receive external dependencies, Lisp may receive them via environment.
Tests must not access README even through arguments. User selected independent
checks plus an ert aggregate and permitted synchronizing existing README test
instructions. Speed is an expectation, not permission to remove regression effect.
User reports broader ignore rules; no ignore change is part of this task.

Implementation authorized tests/ plus those README instructions. No production,
lock, dependency-version, source-layout or ordinary Git mutation. User separately
authorized repeated exact command during this task:

    timeout 600s nix flake check -L --no-write-lock-file path:/home/lingyu/Projects/org-texmacs/tmp/tests-refactor

This includes snapshot preparation, existing pinned extension copies, dependency
network/store/cache/log/products. Both calls succeeded with approved daemon/cache
escalation. Root project was clean at intake. Acceptance uses an uncommitted
candidate, not an inferred HEAD project-parent association.

## Interfaces and preserved behavior

- tests/default.nix uses pkgs.callPackage, explicitly supplying project Emacs,
  source, package constructor and testSupport attributes. Generic tools are
  injected by callPackage. Root flake invocation/API stays unchanged.
- testSupport (import tests/support) exposes bootstrap/common/native/pdf/runner
  file paths. Only necessary file attributes enter each derivation, so an unused
  PDF helper is not an input to core. No suite loads another suite's cases.
- Children own default.nix+lisp; Python inspector moves byte-identically to the
  PDF check's python/. Patch stays with patched-caption check. Guile wrappers
  removed. Source lint keeps existing batch policy/head-version/main-file handling.
- Runner receives bootstrap, helper/file/tool JSON arrays and strict-tools marker
  through environment. It checks tools and absolute readable files, preserves
  worker-first loading observation, rejects helper case registration, duplicate
  names and empty suites, and runs all selected cases in its fresh process.
  It writes test-names.txt alongside ert.log in its supplied Nix output.
- Main groups: core176 (no native execution), native318 (worker/session/native
  encoding/serialization), PDF59 (actual PDF rendering/inspection). Classification
  includes helper dependencies and actual native smoke, not just name prefixes.
  Aggregate ert links their results and does not run Emacs again.
- Two former readme cases become org-texmacs-document-native-example and
  org-texmacs-session-example. Fixed original input/operations live in native
  examples.el; structure, STM paths, native encoding/readback, return and cleanup
  assertions unchanged. README parsing and freshness assertion intentionally gone.
- Mandatory Nix tools use explicit runner requirements and STRICT_TOOLS marker,
  not README presence. No README references or directory fallback remain in tests.
  Three ../ occurrences are synthetic /resources/link/../base/ normalization data,
  not external file access. Installed library location assertions remain valid.
- Worker/config/HOME/temp/error/readback/reload/cleanup isolation and all loops
  retained. No worker sharing or deleted/relaxed case for speed. Each ERT check
  has600s outer timeout plus10s kill-after; lint120s. Original operation deadlines
  unchanged. Failure codes/logs propagate. Existing six patched Org identity/parser
  cases remain; optional nine real extension/SQLite/HTML/blog cases remain optional.
- Optional integration now called with pkgs.callPackage and explicit emacs (with
  installed package/Org-roam), extensionSources and testSupport. README explains
  this interface and individual/aggregate commands. Root default deps unchanged.

## Validation and limits

Static migration baseline records553 original cases and both other suites. All
case bodies match after removing only whitespace-only/full-comment lines, applying
the two declared example name/call mappings and the strict-tools marker rename.
This preserves string literals, assertions and loop matrices. The Python inspector
is byte-identical to the source-layout baseline. All16production+flake/lock inputs
unchanged. Final65project inputs match the snapshot; only copied flake adds optional
integration and temporary acceptance checks. All11copied extension modules match
the existing tmp/issue-3-api/extensions inputs. No foreign repository read/change
or new external source selected.

First full command exits0: core176/176 in1.033395s, native318/318 in177.056561s,
PDF59/59 in209.939116s, patched6/6 in3.233255s, integration9/9 in11.286437s,
package-lint and strict package build accepted. Runtime inventory depends on actual
five suite outputs and proves all568names register once, groups disjoint, matching
baseline. Aggregate consumes same leaf derivations. Source/input manifests and
migration/inventory scripts remain temporary under tmp/tests-refactor*.

Second full command exits0 and reuses identical passed suites. New temporary
runner-contract check proves missing bootstrap, missing tool, empty file list,
duplicate names and helper registration fail, plus a normal positive fixture.
These are expected negative controls, not failing production regressions. No
candidate edits after acceptance except unrelated authorized memory maintenance.

Pinned x86_64-linux/Emacs31.1/Org9.8.10/TeXmacs2.1.5 only; Nix omits incompatible
systems. Default package/patch/runtime identities retained. Cached strict build
is valid unchanged-input evidence, not a fresh compiler execution claim. Per-group
times expose a fast core path and permit parallel native/PDF execution; compare
prior382.099933s monolithic ERT cautiously, without cross-machine or warm/cold
benchmark guarantee. GUI/other systems not newly tested. No raw archive needed:
maintained assertions/runner and these extracted boundaries preserve useful facts.

At runtime acceptance the ordinary index was empty and all edits unstaged. User
subsequently staged all48changed paths; all65staged inputs match accepted manifest
and no unstaged diff remains. Complete binary staged patch1431662bytes, SHA256
ff2b139e3f687dd7361a284fb022b1f4791d6570c1fc812f452d829f1e4e1f82.
git-maintenance review accepts one coupled refactor, no split needed (medium
difficulty). tmp/commit.md holds refactor(tests): split ERT suites and isolate
dependencies, five Chinese bullets, no issue/breaking footer. User subsequently
committed the exact candidate. Readonly delivery verification confirms one expected
Python-allowlist parent, all48changed paths, complete binary patch hash above and
all65accepted committed input hashes. Full message matches draft after normalizing
only terminal newlines. Project index/worktree clean. No new tests solely for
identical staging/committed bytes and no ordinary agent Git mutation. Current
project-parent association grounds delivered-equivalence verification, not earlier
uncommitted runtime acceptance. No issue/footer/tracking lookup needed; no new raw
archive. Implementation and delivery complete; next user selects work.
Use git-maintenance for checkpoint/message review.
