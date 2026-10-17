# PDF footnote destination repair

## Motivation and selected behavior

After native binding/anchor diagnosis and accepted isolated integration, user
requested production repair and maintained ERT for anonymous/named/repeated notes,
both directions, cross-page behavior, failure cleanup and shared-worker isolation.
Issue13 is already delivered/closed; this is separate pre-0.5.0 export stability
work, with no new external issue action. Native reference value bindings alone do
not provide exported PDF destinations. Add the same-key label before binding;
reverse order can reset displayed reference values. See footnote-forward-probe.md
and footnote-private-integration.md for causal controls and archived raw evidence.

Worker owns the compatibility fix, only in its disposable native PDF buffer after
existing first print initializes style macros. Recognize macro(sym,nr,body), a
footnote float and exactly one native set-binding of merge(footnote-,arg nr), with
no matching label already present. Copy structure, preserve original binding and
native numbering. Unknown/already-fixed shapes remain native; explicit initial
footnote/render-footnote/render-footnote* values are preserved. No Org/STM body
rewrite, global style/config change, new API/protocol, or independent saved-tm
GUI-export guarantee. Caption-note layout defects remain documented limitations.

## Maintained validation

Five new ERTs: forward/backward/repeats; macro recognition/copy/idempotence and
no-note/explicit-init guards; private-state/error-cleanup; cleanup-fatal shutdown;
explicit macros preserved. First group covers generic/article and anonymous,
named-repeat across explicit page break, markup; three repeats across document
save, explicit-source and frontend paths; actual target pages/line geometry,
source/prepared/serialization unchanged. Guard session snapshots include native
body/style/all inits/actual macro. Inject failure after installing override,
verify no published/private PDF, recovery on same worker; bypass later installer
reproduces missing targets, proving no global leak. Separate native close failure
stops worker and removes its directory. Other existing footnote text/numbering
regression remains unchanged.

Test-only tests/ert/pdf-links.py uses pypdf for annotations/destinations and Poppler
XML text runs with explicit1.5scale conversion; stderr is separate from XML/JSON.
Destinations may adjoin the correct text line within one line height (native
zero-width anchor), not necessarily lie inside one glyph run. No fixed page count,
PDF bytes or pixel snapshot. Python dependency stays in ERT derivation; official
package fileset/default Org and root flake remain unchanged.

## Commands, provenance and status

User authorized repeated exact commands below, cwd root tmp/footnote-fix:

```sh
timeout 300s nix develop --no-write-lock-file path:.#checks.x86_64-linux.ert --command emacs -Q --batch -L . --load tests/ert/ert.el --eval '(ert-run-tests-batch-and-exit "pdf-footnote")'
timeout 600s nix flake check --no-write-lock-file path:.
timeout 120s nix build --no-link --no-write-lock-file path:.#default
```

May access locked dependency downloads/Nix store/cache/logs and test temporary
native/PDF files; no lockfile/index modification.32runtime inputs copied from root
to valid ignored nonsymlink tmp, source-inputs.json binds their SHA256. Root/copy
identity rechecked after focused gate. Pinned x86_64-linux, Emacs31.1/Org9.8.10/
TeXmacs2.1.5, generic/article. Focused6/6 passed29.555130s, default build exit0;
full flake exit0 (all checks passed: stock ERT, patched Org, strict compilation/lint).
Final32inputs unchanged and root=snapshot after all gates. Candidate uncommitted/unstaged; no project-parent association
for runtime against modified candidate. Root flake SHA256 remains54effce5b08cfe75c4a32de982ce81f31ed07afd77c7a944598175ca88538cb7,
lock118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a.

No new archive selected: maintained tests retain reproduction and memory retains
new verified conclusions; causal original artifacts were already selectively
archived. No new unique raw material needs unconditional capture. No skill change.

## Accepted task-file identities

SHA256 (seven task paths; excludes unchanged user workaround):

```text
0ef612b1935ed750acde1f74c818c46df633c2a2c713476e5a56ed25842fdc20  .gitignore
0eab00c9430c84f52f74d58cd65d72b259eb70449984153d034d881fed895b6a  README.org
3ef8f0861ad3e122e8f4c6974a75248dda7a8414af07466bd82bf5f39d2dd316  org-texmacs-worker.scm
2219d56805f210867804ac7b3d84e39cabe5c337f500aeb16c99202d93f3fc2f  tests/ert/default.nix
d28e01be0745f283be51dbd955d9abfe123ac60ae06f901a12a8e4597aafe5ac  tests/ert/ert.el
fc1cf94bcdecc007f682276848e43fc4942bf3b0e8d0481823eedc16e4292c68  tests/ert/run.scm
83dc3af77e39f48012ed02570388e634ec46134560a48ffaa815bfd8e3d011d3  tests/ert/pdf-links.py
```

Runtime32input manifest SHA256: 1376d2801614af9616c48017ea253245f8bedffef4fb95b4f96dca991cdcd9fe.
No new raw archive: maintained tests plus this extraction suffice. Next delivery review
and any explicit staging authorization are separate; no ordinary commit executed.
