# E3: examples and v0.7.0 release preparation accepted

## Implementation and semantic boundary

Baseline is verified human E2b c596e09. E3 updates Lisp/Nix0.7.0, README and a
complete detailed release manuscript/root navigation while keeping TODO/CLOSED/
tag/publication under human control. Independent model/pure lowering contracts
and approved source/STM/caption/Cite/filter boundaries remain unchanged.

Compiled example builder now uses standard document-from-buffer, no deprecated
provider or BibTeX text snapshots. Its isolated Emacs adds citeproc; base package
still requires only Org. Four EN/ZH generic/article sources select a local CSL
style and bibliography. Canonical shared/references.org supplies BibTeX and XML
blocks, tangled explicitly before loading standard configuration and exporting.
Same owned document saves native TM/PDF. Babel evaluation is disabled for these
illustrative listings, without changing general exporter semantics. Bilingual
configuration/bibliography/build prose matches actual standard preparation.

## Validation and provenance

Locked x86_64-linux Emacs31.1/Org9.8.10/TeXmacs2.1.5. First full check exits0:
core275/275(1.519877s), native273/273(179.549312s), Cite9/9(10.912466s),
PDFdocument45/45(100.293219s), PDFrender29/29(147.219468s), patchedcaption6/6
(2.741460s), actual Organize4/4(5.867658s); default637/all12checks, strict
compile/lint/treefmt/native gotor included. After example-style packaging and
README-only corrections, final full-2 exits0, only treefmt rebuilds; all runtime
and compiler/lint derivations are identical and reused, not silently skipped.

Executed final commands from repository root (SNAPSHOT denotes the checked
159-input tmp/standard-export-0.7.0-e3/final copy, with controlled integration overlay):
- timeout 600s nix build --no-link --no-write-lock-file --print-build-logs
  --print-out-paths --max-jobs 2 path:SNAPSHOT#org-texmacs-examples path:SNAPSHOT#org-texmacs.
- timeout 600s nix flake check --no-write-lock-file --keep-going --print-build-logs
  --max-jobs 1 path:SNAPSHOT (full-1 used max-jobs 3 before sample-only refinement).
- timeout 120s nix eval --raw --no-write-lock-file
  path:SNAPSHOT#packages.x86_64-linux.org-texmacs.version.

Final build-2 exits0 for base0.7.0 package and all four TM/PDF/preserved-source
examples. Two blocks tangle from references.org in each process; local CSL check
passes. pdfinfo accepts all four A4 PDFs: en/index6pages, en/article5, zh/index6,
zh/article4. Package version eval returns0.7.0. Output store directories:
/nix/store/21g68dsw0yb9dhj1n1g5b4j2abfy6is0-org-texmacs-examples and
/nix/store/s86ngy5zmbwdbamgx54nisi5nikhn650-emacs-org-texmacs-0.7.0.
No visual/GUI or Chinese bibliography localization claim: citeproc warns missing
zh-CN locale and uses bundled en-US fallback. Body language/Fandol fonts remain.
No additional network style/locale acquisition or native parser workaround.

All159project input hashes equal final worktree/index/isolated snapshot; two
controlled actual-integration driver hashes retained separately in E3 inputs JSON.
Complete19path diff and release notes reviewed, whitespace clean. Index changed
externally during work and now equals accepted candidate; no ordinary Git write
was invoked by agent. No unrelated flake/lock/tracking-policy mutation. Expected
human commit message is tmp/commit.md and E3 manifest. Human E3 commit pending.

## Retention and next action

Initial standalone CSL prototype was ignored by tracking rules; superseded by
canonical Org tangling without expanding .gitignore. Initial successful example
build/full-check facts remain causal evidence, not final-input proof. Maintained
source/build drivers and sufficient extracted facts/manifests make original raw
prototype/log/PDF retention unnecessary; no new archive selected. No binary/cache/
whole temporary tree copied into GAW. Source manifests are pure text.

Verify manual E3 delivery against exact E2b parent/message/19paths/all159hashes;
do not rerun unchanged checks. Then development is delivered, with human version
state/tag/publication separate. Do not claim minimum Org9.8, other platforms,
arbitrary styles or GUI layout were newly validated.
