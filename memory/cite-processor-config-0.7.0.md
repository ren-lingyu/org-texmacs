# v0.7.0 Cite processor configuration cleanup

User adopts one independent change against delivered N9 at22191a0. Replace value
comparison in --cite-default-processors with defcustom
org-texmacs-cite-export-processor (native default, nil delegates). Keep public
backend options expression, evaluated per export, no new alias. Non-nil prepends
(texmacs PREFERRED) unless explicit texmacs entry exists; nil returns original Org
configuration unchanged. Org chooses more-specific derived entries itself.
Document/subtree/EXT-PLIST/options-filter precedence unchanged. No global Org Cite
configuration mutation, registration change, manual dispatch, new advice, raw
acceptance, bibliography/STM ownership or math/style/field expansion.

Matrix: native +t/basic,t/csl,nil ->native; native+texmacs/csl ->csl;
preferred csl +t/basic ->csl; nil +t/basic ->basic; nil +t/csl ->csl;
nil+nil ->no processor. Cover original list identity/content preservation,
preload assignment/postload changes/repeated+nested exports, declarations/external
options/filters/subtree, derived specificity, unknown/non-export processors via
standard errors, HTML/LaTeX isolation, actual native/CSL and basic/raw refusal.
Extend existing default helper to bind preference per case; keep all prior
semantics as native-default and delegated cases rather than delete tests.

Update README minimal native/nil configuration, root existing completed item and
detailed Org Cite paragraph. Delete stale stock-value/intent inference description;
retain native styles/math/CSL/raw/ALT_TITLE limitations. Root TODO, no version/tag/
release. No extra changelog version or repeated native feature registration.

Order: GAW plan checkpoint, implementation/tests/docs, affected ERT, strict compile/
lint/fmt and necessary Nix regression. Full gate before formal freeze; no repeated
native bibliography visual experiments for this config-only change. Complete diff,
actual-diff tmp/commit.md and receipt, GAW acceptance checkpoint, human delivery.
No raw archive needed after full semantic extraction; maintained tests/history
preserve contract and prior behavior. No outstanding external issue action named.
