# Phase 6 accepted explicit dispatcher menu

Historical result, not instructions. Candidate on Phase5 commit5f4c9c0; not yet
ordinary committed. Selected user INBOX Phase6/issue2 independent of issue1.
Environment current project lock: Emacs31.1 Org9.8.10 TeXmacs2.1.5,
Org-roam20260425.1623 only in optional isolated extension runtime. x86_64-linux.

Five baseline probes pass1.021877s. Native Org nil-menu backend is accessible,
same name registration replaces, shared prefix combines actions, duplicate action
first-wins and hides other target, Unicode keys work. Native dispatch-action reads
read-event; q/?/#/& control actions intercept keys, P prefix publishes; navigation
keys differ in nonexpert mode. Production supports graphic Unicode, rejects
whitespace/control/modifier/surrogate events and reserved keys (P only prefix).
Wrong-signature initial harness and one120s timeout/exit124 were corrected by
source-only investigation then actual read-event injection, not production fixes.
Probe log retains locked source excerpt needed to explain native action precedence.

Global org-texmacs-export-menu-keys nil-default; one complete explicit four-field
plist :prefix/:buffer/:file/:pdf, no suggested implicit key. Validate before native
backend/guard registration and build owned menu. Allow disjoint shared submenu
prefixes; refuse collisions/direct-function prefix. Exclude own named backend from
foreign collision scan. First require applies option; later setq/Custom/require
inert for menu, no refresh/watch/advice/parallel registry. Backend/three public
commands/generic guard always available, Phase5 conversion transactions unchanged.

Changes only ox-texmacs.el, tests/ert/ert.el, README.org. Five new ERT: fresh
batch default/repeated require; preconfigured actual dispatcher three actions and
menu/config detachment; invalid load preserves existing backend/hook/registry;
complete fields/key domains/Unicode/cycles/reserved; actual shared-prefix routing
and collisions. Legacy fixed menu assertion now expects nil. Real existing nine
include/organize/SQLite/.tm/PDF/HTML/blog cases still pass without menu. README
explains default change, explicit pre-load recipe, direct M-x and lifecycle limits.
Removing default C-c C-e T is an incompatible documented user entry; commands and
keys are independent. Future release notes must explain migration; no release now.

84focused54.313479s, final56.135881s;5native final1.021619s,9real10.962176s.
Exact240s nix flake check exits0/all10logged checks/strictcompile/package-lint;
386core ERT175.465056s.25source/lock/test inputs byte-equal worktree/isolated tree
before/after gate; final manifest SHA2564de96b5514e3b5045fcab6f5da4d6e5b682e5b1e37a48abbc1eaed12563d711c.
11foreign Elisp modules copied from verified Phase5 isolation, match original
Phase4 pinned commit/module manifest. Root lock and USTC mirror overlay unchanged.
No foreign source/DB writes or personal data. Root mirror excluded from project work.

Native probes/environment/manifests/reproduction selected for independent retention;
maintained ERT/source preserve implementation, so duplicate test/build logs, caches,
DB/PDF/binary products not selected. Current capture HEAD identifies context, not
original provenance of candidate runs. No inferred project parent or issue write.
Selected issue2 goal complete pending user review/commit; remote current issue status
not verified. No live reload, later backend collision monitoring, all-platform or GUI
compatibility claim. Dynamic menu lifecycle and release evaluation remain separate.
