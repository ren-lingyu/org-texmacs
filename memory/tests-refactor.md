# Tests migration and refactor

## Current: shared execution constructor and parallel PDF leaves accepted locally

User selects first two optimization nodes and authorizes tests/ implementation.
testSupport.mkErtCheck centralizes the five old drivers' duplicated execution,
including explicit file/helper/tool/env/Emacs args, strict tools, isolated HOME,
600s timeout, live tee+pipefail logs, names and original failure handling.
Optional integration keeps its existing required parameters and extension load
paths; its9cases are byte-preserved but runtime not rerun this task.
PDF suites.nix lists existing pdf.el27cases as render and six other files32cases
as document, plus the existing inspector. Parent tests/default.nix passes these
through mkPdfCheck to sibling discovery directories. Public ert-pdf aggregates
the two leaves without rerunning ERT, keeps ert.log/test-names.txt and adds leaf
links plus duplicate-name rejection. Existing ert aggregate unchanged. All case
bodies/helpers/production/lock remain byte-equal; no README or ancestor lookup.

User authorizes repeated exact commands for this task, each executed once:
1. timeout 600s nix build --no-link --no-write-lock-file --max-jobs 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs/tmp/tests-opt-20261025#checks.x86_64-linux.ert-pdf -L
2. timeout 600s nix flake check -L --no-write-lock-file --max-jobs 2 path:/home/lingyu/Projects/org-texmacs/tmp/tests-opt-20261025
Network/store/cache/log/products disclosed; root lock/index/result untouched.
Both exit0 on pinned x86_64-linux. PDF leaves both start09:30:45UTC2026-10-25:
document32/32 in80.958658s, render27/27 in128.667668s. Aggregate passes; full
gate reuses those same successful outputs, core176/176 in0.900527s,
native318/318 in173.494314s, patched6/6 in2.813273s, lint/strict package build
and aggregates accepted. Temporary dependency-only inventory confirms exactly
559default names, all original59PDF names, no duplicates, same ert PDF link.
81root input hashes and copied bytes match final candidate (copied flake alone
adds inventory);53non-Nix baseline inputs plus root flake.nix unchanged, all568case
bodies retained. Source manifests and copy remain tmp, not durable interfaces.
PDF execution phase~129s versus previous serial231.327348s is a single observed
comparison, not a repeatable benchmark guarantee; native can dominate full gate.
Uncommitted14Nix files only under tests/, no ordinary staging/history changes.
Further matrix profiling and local inspection reuse remain unselected.

## Previous follow-up: dependency refinement and live ERT logs

User committed the exact reviewed five-driver log patch and full drafted message.
Readonly verification confirms the expected formatting parent and clean ordinary
index/worktree. Delivery complete; no runtime rerun for identical bytes. A project
association grounds this delivery/source review, not original uncommitted testing.

Flake supplies src and the installed Emacs wrapper explicitly; tests obtain
emacsPackages from pkgs, with the current overlay guaranteeing the match. Lint
overlay passes final_.emacsPackages.package-lint directly as a test-only library;
the earlier extra alias is gone. Shared mkFlake and grouped package overlays
replace manual package composition; no-build evaluation passed. The50-file
formatting-only candidate had equal Lisp/Scheme token streams and Python AST,
not a fresh full runtime gate. Historical evidence below predates those changes.

User requested PDF cost investigation and visible logs, then separately approved
the same log change for all other ERT drivers. Five driver files now use
tee+pipefail, keeping saved ert.log, failure/timeout handling and all cases.
Package-lint already streams; aggregate does not run tests. No helper/production
change. User-authorized single command:

    timeout 600s nix build --no-link --no-write-lock-file .#checks.x86_64-linux.ert-pdf -v -L

Approved daemon escalation exits0:59/59pass in231.327348s on pinned x86_64-linux,
progress observed before completion. Other four drivers statically reviewed only.
No repeat/additional gate authority. Slowest case issue11-bare-block-and-reload-
consistency57.909601s covers23combinations/69PDFs/23independent reload processes.
Next cases:issue13-source-real-islands-and-native-statements14.020948s,
issue10-inline-and-separate11.898667s, footnote-forward-backward-and-repeats
8.775450s. Per-phase costs unmeasured. Native double print passes retain semantic
purpose; waits aren't fixed timeout sleeps. Inspection reuse/independent sharding
are potential follow-ups, not adopted optimizations. No speedup, coverage removal
or shared-worker change. Long single cases still lack internal progress. No raw
archive needed; source and these extracted results suffice.

## Earlier optimization proposal (first two nodes now completed above)

User requests consideration after log delivery, not implementation or new tests.
Readonly mapping of all59captured timings to current test declarations gives:
pdf.el27cases/141.684156s; other six files32cases/89.638816s (document8.238505,
frontend23.229204, special-blocks56.555332, preprocess1.607353,
serialization0.000258, worker0.008164). Static scan finds no top-level helper
definitions in those case files; helpers already live in support. These are one
run's per-case sums, not measured parallel runtimes.

Recommended small nodes, subject to user selection and new runtime authority:
1. Extract duplicated Nix ERT execution/logging into a shared constructor with
   explicit runtime, files, tools, helpers, timeout and suite-specific arguments.
   Keep patched Org identity vars and optional extension paths; avoid passing the
   entire support directory into every derivation. This simplifies maintenance,
   not execution time by itself.
2. Split PDF execution into two independent leaf checks by the existing file
   boundary above, retaining ert-pdf as a dependency-only public aggregate.
   Pass all shared file paths from the parent function; no ../ or inferred roots.
   Leave case bodies and per-test worker/config isolation intact. Under two
   available build slots the ideal time lower bound is ~142s versus231s, not an
   achieved speedup; CPU/memory contention may reduce benefit. Full flake checks
   could then be limited by native ERT (historical~186s), not PDF alone.
3. Instrument the longest matrix's generation/reload/inspection stages before
   optimizing further. Consider explicit local reuse of text/geometry snapshots
   only while that PDF is unchanged. No global path-only cache: several tests
   rewrite the same output path. Preserve every comparison/assertion and the
   native reference/footnote print passes.

Migration acceptance must show all59actual names form the disjoint union of the
two leaf outputs, with no case lost/repeated, unchanged assertions/fixtures and
same isolation/failure/timeout semantics. Preserve existing ert/ert-pdf commands,
live leaf logs and saved name/log outputs. Compare repeated runs under matched
versions/resources before making performance claims. No permanent duplicate name
manifest, reduced coverage, shared workers or machine-specific dependency lookup.
No ordinary files changed or extra runtime commands executed for this plan.

## Earlier follow-up: personal-nixpkgs composition and checks

User introduced personal-nixpkgs, moved package construction to pkgs/ overlays
and requested using llib.tests plus restoring flake checks. Intake already had
staged/unstaged package/flake changes and two staged test parameter adaptations;
preserve those. Authorized reference ~/emarccs/tests uses mkChecks, test-overlay.nix
factories and test.nix drivers. User also authorized reading ~/nixpkgs; local HEAD
matches locked personal-nixpkgs06a8fa43a112c4b1f0f9576eceee466b6b730f38,
and read relevant library files have no working changes. mkChecks discovers
overlays, supplies args through a fixed-point callPackage scope and collects
only corresponding derivations. No copied library or new dependency/version.

tests/default.nix now calls that interface, injecting tools, installed
pkgs.emacs-with-org-texmacs, its Emacs package scope/source, separately named lint
library and testSupport. Six default check folders have test-overlay.nix and
test.nix; four main ERT/aggregate drivers moved byte-identically. Aggregate still
consumes the same leaf scope values. Patched-caption overrides org on the actual
scoped org-texmacs package rather than the removed buildPackage callback; loaded
library identity tests remain. Lint explicitly adds its injected package-lint
library path; distinct emacsPackagesPackageLint prevents check self-recursion.
integration/default.nix stays optional without an overlay. Root flake checks
invokes tests with pkgs/llib. No Lisp/Python/shared-support/production/package/
lock/README/ignore/index change by agent; no new ancestor discovery or README
test access. Three existing ../ strings remain synthetic normalization data.

User authorized repeated exact command for this task:

    timeout 600s nix flake check -L --no-write-lock-file path:/home/lingyu/Projects/org-texmacs

Explicit path includes untracked test files; potential network/store/cache/log/
products disclosed, no lock/index/result writes. First sandbox invocation cannot
connect to daemon before testing; approved escalation exits0, all checks passed.
Core176/176 in1.073053s, native318/318 in186.464979s, PDF59/59 in224.216406s,
patched6/6 in2.871502s; lint, aggregate and strict patched package byte/native
compilation accepted. Pinned Emacs31.1/Org9.8.10 and x86_64-linux only; other
systems omitted. Optional9integration cases unchanged but not rerun this task;
no new runtime inventory/negative-runner probes needed for unchanged cases.
Static whitespace and unchanged case/helper/production/lock checks pass.
Implementation complete, user review/staging next. No ordinary agent Git writes
or new raw archive. Prior evidence below is historical acceptance of the former
package construction, not a claim those broader probes reran in this gate.

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
