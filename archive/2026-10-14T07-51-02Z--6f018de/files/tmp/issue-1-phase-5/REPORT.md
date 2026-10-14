# Phase 5 accepted frontend/preprocessing implementation

Historical result, not agent instructions. Selected INBOX section18 implemented on
Phase4 commit6f018de; candidate is uncommitted. Current root lock selects Emacs31.1,
Org9.8.10, TeXmacs2.1.5; real runtime Org-roam20260425.1623. x86_64-linux only.
User authorized isolated120s probes/focused/integration and repeated240s full check
with necessary network/store/cache. Host Org was not used; root lock unchanged.

Full unselected unnarrowed frontend uses existing bounded preprocessing provider;
local subtree/region/narrowing uses direct preparation. Independent buffer-local
org-texmacs-export-discover-bibliography defaults nil and applies to both routes.
One owned prepared input per invocation; pure document lowering and serialization/
PDF rendering inside original source/config/hook/dependency transaction. No fallback,
origin recovery, DB adapter, duplicate conversion, generic lifecycle or menu change.
Provider limits now constrain full frontend. Unresolved ROAM_INCLUDE keyword and
selected-root mount explicitly reject; mounted metadata is not silently discarded.
Existing direct APIs, explicit-text priority, native resource/PDF restrictions,
readonly unibyte view and naming/overwrite/write-error boundaries documented.

Four preimplementation baseline probes pass3.144554s: loaded frontend guard/hook,
actual PDF transaction and changed dependency, scoped discovery and full/direct
odd-level policy. Initial harness missing worker.scm, Nix script relative loading,
and let closure errors corrected; these were harness failures, not production bugs.
Final candidate full-check rerun4/4 passes3.585992s.

Eight new maintained core tests: three full consumers/hooks/filter once; failed
conversion preserves existing targets/no view; full profile limits; local discovery
three scopes x three outputs; unresolved directives/mounts; discovery off/invalid;
source/include/bibliography/option changes during both consumers; option capture
before prompt. Relevant legacy failure injection moved to native consumer/helper
seams, direct APIs' own tests retained.79focused54.728771s, final gate57.349582s.

Two new real fixtures plus joint HTML/blog retarget: actual modes/SQLite/queries,
include+organize discovery false failure/true native .tm view/file equality/PDF
content, missing node preserves outputs, direct mount refusal, HTML before-after
and actual blog publication.9/9 standalone10.629183s/final11.487037s. Initial8/9
failure was PDF fi ligature text comparison; NFKC semantic comparison fixes that
assertion. Package logic/read/query interfaces not mocked or patched.

Exact240s nix flake check exits0, all10logged checks/strictcompile/package-lint pass;
381/381 core ERT178.555109s.25 project source/lock/test inputs byte-match candidate
and isolated tree, manifest SHA256740964a9c69fa8707461aa32dc48dc3d5aa306314840646a500c2960cff122ad.
11 foreign Elisp modules match copied Phase4 source manifest; its revisions/individual
SHA256s retained. Parent/source histories plus maintained project tests preserve code;
no foreign repo modification/personal database. Root mirror overlay remains uncommitted.

Selected issue#1 architecture/frontend goals in local INBOX are complete subject to
user review/commit. Live GitHub issue page lookup failed, no current remote status
or content claim. No external tracking write. Generic exporter/full Org lifecycle,
original selection mappings/native resource enhancements/keys/all syntax/GUI or all
package registries are separate, not closing prerequisites. Output write can leave
partial file on write failure; receipts are not FS/DB atomicity, ABA or sandbox.
