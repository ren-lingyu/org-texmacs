# Issue10 inline footnote STM acceptance evidence

Source root: /home/lingyu/Projects/org-texmacs. All paths below are relative
to this ordinary project worktree. This report describes an uncommitted candidate,
not a release or remote issue closure. User authorized implementation and separately
repeated sequential locked flake commands/network dependency access/results.

## Source identity and reconstruction

Committed baseline c31d3b19b531e541a530764da92a1f70f11bf8d7 is the verified Issue11
delivery and exact old code for the red control, not accepted Issue10 code.
baseline-inputs.json identifies25committed source files, each compared with Git
HEAD bytes. candidate-inputs.json identifies25final isolated files, each compared
with ordinary worktree bytes. candidate.patch covers exactly README.org,
org-texmacs-fragment.el,org-texmacs-document.el,org-texmacs-context.el,tests/ert/ert.el;
independent unified-hunk reconstruction from baseline must reproduce all5exactly.
Root lock unchanged. Root user flake mirror never edited/staged; isolated flake
preserves prior mirror solely for locked dependency availability and adds checks.
11extension input hashes identify fixed Elisp fixtures copied from prior isolated
Issue11 harness, originally pinned real-extension fixtures. No fresh external
source download or revision inference. The extension bodies are dependencies,
not archived; reproduction needs those exact11files or matching fixed fixture.

## Contract and implementation

Only Org-recognized inline footnote direct text is newly admitted; registered root
configuration/case behavior remains shared with public discovery. Note body bounds
limit balanced scanning; malformed configured candidates explicitly fail consistently
in public APIs/export. Existing ordinary paragraph stop behavior unchanged. Real
adjacent Org objects cannot lend closing delimiters. Context has no parsed children:
resolve actual children from same private masked Org snapshot. Markup originating
inside STM quoted strings remains opaque/masked, with dedicated boundary syntax.
No worker during discovery. Shared preparation splits/registers note body strings;
restored named inline definitions carry original snapshot body interval in synthetic
paragraph. No buffer fallback or reparsing STM. Shared pure lowering promotes one
island+ASCII whitespace bare bodies, rejects known direct display mixtures, and
preserves empty concat string, native footnote/ref mechanism and STM/file paths.

## Maintained verification

7new issue10 ERT plus old inline-note exclusion migrated to positive support:
- anonymous/named public map/at-point/source state/no worker;
- all11default roots/custom/atomic pure bare behavior;
-6valid bracket/newline/markup/literal/link boundary cases, public/export parity,
  custom/disabled tags,5invalid reader/unclosed/cross-note/cross-object cases;
-5full/selected/subtree/region/narrowed modes, required hidden named definition,
  exact request order, unused request filtering, dead source/double pure lowering,
  file and STM provenance;
-10known display roots mixed with body text reject;
-4native anonymous/named/forward/bare inline-versus-separate footnotes: PDF text/
  word geometry<=1pt and independent .tm load/export. No PDF byte/pixel equality.
Existing empty-note, repeated/forward, source ownership, region/subtree and Issue11
regressions retained. Native case geometry uses existing valid formula fixtures.

## Results and limits

Initial pre-edit baseline:2intended assertion failures0.295610s, empty discovery
and pure island-context rejection; baseline derivation succeeds only for exactly2
unexpected results. Later full gate repeats this red control; expected old-code
failures are not candidate failures. Earlier standalone46/46focused91.253374s,
9/9real10.096890s,437/437core265.210481s/full checks passed before final README
support wording audit. Only README changed in that audit; final24other hashes
stable, synchronized final snapshot revalidated below.

Final same-input acceptance: focused46/46 in93.714702s (within final full gate),
real extension9/9 in10.217289s, core437/437 in267.394606s. Final full600s command
exit0; strict compilation, package-lint and all applicable checks pass. Final
baseline repeats exactly2expected failures0.313889s. All25baseline/25candidate/
11extension identities verified after completion; final patch independently
reconstructs all5task files exactly. Ordinary index empty, user flake unchanged.
Raw final evidence: integration-final.log,check-final.log; baseline.log preserves
initial causal red control before implementation. focused-6.log preserves bounded
Org shallow-context versus full-object AST diagnostic, not accepted candidate.

Locked x86_64-linux only; no other-platform or interactive GUI claim. No version,
lock, INBOX, examples, ordinary index/history or remote writes. Diagnostics.md
extracts initial strict docstring width, empty-note slot and shallow-context guard
failures; intermediate logs are diagnostic, not final accepted inputs. Losing
intermediate snapshots does not invalidate final reconstruction/provenance.

## Exact reproduction commands

Use locked flake/harness and assemble baseline/candidate from identified Git source
and patch; fixed extensions must match their manifest. No lock update/system Emacs.

```sh
timeout 120s nix build 'path:./tmp/issue-10-inline#checks.x86_64-linux.baseline' --no-link --no-update-lock-file --print-build-logs --print-out-paths
timeout 240s nix build 'path:./tmp/issue-10-inline#checks.x86_64-linux.focused' --no-link --no-update-lock-file --print-build-logs --print-out-paths
timeout 120s nix build 'path:./tmp/issue-10-inline#checks.x86_64-linux.integration' --no-link --no-update-lock-file --print-build-logs --print-out-paths
timeout 600s nix flake check path:./tmp/issue-10-inline --no-update-lock-file --print-build-logs
```

Only necessary original text harness/lock/manifests/patch/baseline and final gate
logs plus diagnosis are selected for immutable archive. No PDF/binary/full tmp or
dependency tree. Current operational conclusions belong in GAW memory separately.
