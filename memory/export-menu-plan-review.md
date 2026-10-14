# Phase 6 explicit dispatcher menu configuration review

User supplied new9100byte INBOX after prior issue1 guidance was archived/cleared,
and requested review only. Baseline verified Phase5 frontend commit; ordinary
index empty/only mirror dirty. New plan associates issue2 (remote state/content not
independently verified). No production/INBOX edits, builds/tests, network/ordinary
Git writes or issue closure selected by review. GAW normal memory loop authorized.

## Conclusion

Suitable independent next proposal, consistent with prior deferred explicit-key
policy. Separate named backend/optional menu/public export commands. Load registers
texmacs backend and preserves generic guard; menu absent by default, present only
for complete explicit key configuration. One nil-or-four-field option, fixed
existing command/action labels; no fallback keys, menu DSL, dispatcher patch,
automatic reconfiguration or change to C-c C-e binding/export transaction.
No change to selected Phase5 full preprocessing/local scope/discovery/PDF policies.
No reopening issue1 for independent issue2 menu work.

Proceed only on explicit execution selection:6a locked native mechanism probes,
chosen config/conflict/loading contract;6b minimal frontend registration edit;
6c actual dispatcher/native regression and6d README/docs migration. Version-sensitive
tests isolated independent flake using current project lock, not host Org.
Phase5 test/network permissions do not authorize new Phase6 task commands.

## Clarifications for 6a

1. Menu levels and key domain: proposed prefix and buffer may both be T because
   they operate at different levels; only three action keys must be pairwise
   distinct. Determine reserved control keys for each actual Org menu level from
   locked source/native UI behavior, not an assumed global exclusion list.
   Check supported character domain/control/modifier/quit keys and raw type errors.
   Shared prefix with existing other backends is not automatically invalid; honor
   actual unambiguous native grouping. Refuse demonstrated inaccessible/colliding
   actions at registration, without modifying another backend or installing future
   collision watchers. Name-only duplicate backend registration separate from key
   collision; explicit production load-vs-require contract needed.

2. Validate/own before registration: reject missing/duplicate/unknown keys, improper
   or cyclic plist, non-character keys and actual conflicts before replacing
   backend or adding guard. Build fresh menu tree, no reference sharing with mutable
   user config. Invalid load should not remove/alter prior backend/menu/hook state.
   Default nil requires no configured menu but same named backend/transcoders/guard.

3. Loading tests must be genuine: tests/ert/ert.el currently requires ox-texmacs
   at line17, and registration test hardcodes T/T/t/p. Merely binding option after
   that require does not test configure-before-first-load. Use isolated fresh batch
   cases or equally complete state isolation for nil/preconfigured/invalid/repeated
   require/import-order. Registry bindings alone might share backend objects;
   restore identities/hooks/feature state or avoid global in-process mutation.
   Test actual dispatcher choices/command calls, not only generated plist.

4. Custom lifecycle: defcustom may describe the load-time setting but must not
   install a setter/watch that implies live backend refresh. Default nil, including
   Custom representations, must not silently supply recommended keys. Recommend
   explicit setq before require example and docstring stating a new session/first
   load applies changed values, while already loaded menus are unaffected. Whether
   defcustom or another declaration fits these semantics remains6a selection.

5. Migration: removing existing default menu is an incompatible documented user
   entry contract even though command signatures/behavior stay. README intro and
   dispatcher recipe/table plus hardcoded-menu ERT must agree with new default.
   Future commit footer/release notes should describe explicit pre-load config,
   direct M-x alternatives and loading limits. Associate/close issue2 only on
   implementation acceptance; this review is not completion or external write.

## Local evidence

ox-texmacs.el currently calls org-export-define-backend with fixed T/T/t/p
:menu-entry then adds the conditional generic before-processing guard. Public
commands use Phase5 owned-input transactions, independent of menu dispatch.
tests/ert/ert.el top-level require and registration-and-installation test inspected;
README contains default C-c C-e T recipe. Core filter backend helper supplies named
backend locally without global menu installation. Current goals/contracts preserve
that separation. Native nil menu/conflict behavior deliberately not asserted here:
planned6a probes required before production implementation. No new runtime evidence.
