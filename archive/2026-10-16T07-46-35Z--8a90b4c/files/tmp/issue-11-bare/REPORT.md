# Issue11 implementation and acceptance

Candidate on committed baseline8a90b4c0f832204ffe6beab00cbea122bcf9de5e;
not yet staged/committed/released. Three task paths: document module, ERT, README.
User flake mirror untouched; root lock unchanged.25baseline/25final and11foreign
extension input identities verified. Final and first-gate patches independently
reconstruct all3task files byte-exactly from baseline. No candidate project commit
exists; capture HEAD is not the accepted candidate source identity.

## Adopted behavior

Exactly one registered string island plus only other unregistered ASCII
space/tab/CR/LF-only direct children and no Org objects is bare. Identity check
precedes whitespace filtering, including atomic/empty native string results.
Return full copied lowered island; existing parent pack prefixes provenance.
No global concat removal, internal STM rewrite, serialize/reparse conversion,
new public setting/API/protocol or discovery expansion.
Known direct display roots equation/eqnarray/align/gather/eqsplit and each *
fail in mixed concat contexts; no auto splitting. Leading list paragraph stays
marked concat and refuses display roots. Other body/quote/center/separate notes/
later-list paragraphs permit bare promotion. Inline-note STM remains Issue10.
Mixed math/custom wrapper semantics retained, native nested STM not classified.

## Acceptance

Locked independent flake: Emacs31.1,Org9.8.10,TeXmacs2.1.5,x86_64-linux.
Final7new maintained ERT,7related migrated assertions; core count423->430.
Structural55same-root context pairs cover11default roots x5contexts; custom roots,
atomic islands, blank identities/ASCII/NBSP, other Org objects/unused target,
multiple islands and source/provenance/error guards covered separately.
Native23same-context fixtures: all11roots in body, equation/equation*/align in
quote/center/separate-footnote/later-list. Bare versus special-block PDF text and
word geometry <=1pt; independent native .tm reload also compared. Original issue
formula article/A4/12.7mm checks both starts/numbers aligned and number near right
margin. Different native environments are never compared as if identical.

Final full check:430/430core296.145612s,all checks passed,strictcompile/lint pass.
Final focused14/14:79.974344s. Final real pinned extension9/9:12.125815s.
Final full baseline target deliberately runs final two regressions against baseline
modules:2assertion failures2.374614s, extra concat and80.16pt mismatch. Wrapper
expects both failures, so successful baseline derivation is a causal red control,
not a claim old implementation passes. Full check includes this final red target.
Other incompatible systems omitted, not validated. No user GUI/all-style claim.

First full430test run:423pass/7stale concat/path expectations297.201308s.
Seven named expected trees/paths migrated; metadata/snapshot/encoding/source and
session guarantees retained. New target-object assertion initially omitted the
existing empty text slot; corrected to retain concat("",math), path(0,1).
No production changes after first7/7focused pass. Earlier missing Lisp parenthesis
and shared empty-string fixture failures are not causal evidence; diagnostics.md
extracts them. Emacs canonical empty strings are not required to have distinct
copy identity. Original logs/patch whitespace left unchanged.

## Reproduction and limits

Each command runs from ordinary root, with task harness in tmp/issue-11-bare:
1. timeout 120s nix build path:./tmp/issue-11-bare#checks.x86_64-linux.baseline
2. timeout 180s nix build path:./tmp/issue-11-bare#checks.x86_64-linux.focused
3. timeout 120s nix build path:./tmp/issue-11-bare#checks.x86_64-linux.integration
All build commands use --no-link --no-update-lock-file --print-build-logs
--print-out-paths. Final: timeout 600s nix flake check path:./tmp/issue-11-bare
--no-update-lock-file --print-build-logs. User separately authorized repeats,
locked dependency network/store/cache and result access. No system Emacs.
Restore25baseline inputs from the recorded Git baseline, put them in baseline/
and initial harness root, apply candidate.patch to root, and use retained flake/
lock. Supply exact11foreign extension modules matching extension-inputs.json
(existing fixed fixtures from prior interoperability task); dependency trees are
not archived. Copy final tests to harness root. Initial first-gate state can be
reconstructed independently via first-gate.patch/first-gate-inputs.json.

Native fixture inputs/helper/word extraction/reload are maintained in ERT and
candidate.patch, not hidden ad hoc probes. Temporary native outputs self-clean;
no PDFs/binaries archived. Retain only necessary text evidence/harness/manifests/
paired first/final logs. Main source/INBOX/version/lock and user fixture changes
outside the3task paths were not made. No ordinary staging/commit or issue write;
local implementation accepted, remote Issue11 closure/publication unverified.
