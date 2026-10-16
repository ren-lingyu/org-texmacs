# PDF hyperlink annotation investigation

## Objective and active scope (2026-10-16)

After Issue10 delivery/remote closure verification, user selected PDF links next.
This is release-readiness INBOX item4, not an expansion of closed Issue4 (which
explicitly excludes PDF annotations). Target: attribute missing annotations and
fix actionable package defects or document tested native/configuration boundary.
Do not add independent PDF hyperlink machinery. Chinese fonts remain postponed.

## Recovered evidence and current static findings

Earlier four package/native/direct/reload PDFs lacked /Annots,/URI,/Subtype /Link;
full controls and limits: memory/release-0.5.0-investigation.md. Not proof of an
unconditional native limitation. Current worker render-native-pdf creates owned
buffer, sets style/initial/body, updates3/print/updates3/print, reads bytes and
cleans buffer/file. No serialized-.tm reparse in production.

Public upstream master read via GitHub connector (default-branch search identifies
18395608c3c207cc8abd9d719c6eae55c6192a86, not yet proven same as pinned2.1.5):
- src/Edit/Editor/edit_main.cpp: print-to-file calls print_doc(conform=false);
  export-postscript is glue name for export_ps, print_doc(conform=true). Suffix
  still chooses renderer; native pdf preference defaults on.
- src/Typeset/Concat/concat_active.cpp: build_locus collects ref/anchor within
  non-nil env->link_env; typeset_locus carries them to locus boxes.
- src/Typeset/Boxes/Modifier/change_boxes.cpp: post_display forwards href/anchor.
- src/Plugins/Pdf/pdf_hummus_renderer.cpp: href emits /Subtype /Link and URI or
  internal destination. locus-on-paper controls border appearance here, not an
  explicit annotation-disable switch.
- src/Typeset/Bridge/typesetter.cpp: print typesetting constructs a typesetter.
This gives a candidate link-context/typesetting path to audit, not a confirmed
cause. No upstream/package patch or preference change adopted. Initial guessed
public v2.1.5/path URLs failed; master results are comparative source evidence,
not a pinned-source/runtime claim. Existing tmp tm-print definitions alone do
not establish causality. Related-issue search returns Issue4 exclusion, no new
PDF-specific issue was established or created.

## Authorized isolated validation and baseline results

Safe ignored nonsymlink tmp/pdf-links contains18exact copied current project/lock/
ERT/README/LICENSE inputs plus SHA256 manifest, independent flake/harness. User
root flake mirror untouched. No business-code changes. User authorized both
commands and necessary locked dependencies/result copies this turn.
Source audit extracts only8listed text files <1MiB each from locked texmacs.src
into a build output, records native version/package/source and per-file hashes.
Public master cannot replace this exact locked-source audit.
Probe matrix12PDFs:2styles(generic/article) x package export and .tm reload, plus
8independent native controls (2styles x locus-on-paper change/preserve x
print-to-file/export-postscript). Native fixtures contain external URI/internal
label+hlink. pypdf inspects actual resolved annotations/rectangles/actions/
destinations and text; absence can be a successful diagnostic result. Source
state checked for package calls. Each native subprocess bounded20s, existing
reload helper45s. No system Emacs, interactive GUI or installed-user-config edits.

Authorized sequential repeatable commands:
1. timeout 120s nix build 'path:./tmp/pdf-links#checks.x86_64-linux.source-audit' --no-link --no-update-lock-file --print-build-logs --print-out-paths
2. timeout 240s nix build 'path:./tmp/pdf-links#checks.x86_64-linux.probes' --no-link --no-update-lock-file --print-build-logs --print-out-paths
Possible writes: task tmp/results, Nix store/cache and private build/home outputs.
May fetch locked dependencies/source/inspector; no lock changes. Copy bounded
text results to task tmp, PDFs remain tmp/build only. Diagnose before selecting
production edits/full regression. Archive selection deferred until unique probe
evidence exists; active findings extracted here, no raw archive yet.

## Baseline and causal controls completed

source-audit exit0: all8requested text files from locked TeXmacs2.1.5 source
extracted/hash-recorded; source-results/manifest.json under task tmp identifies
source and installed package. First sandbox socket denial resolved using same
authorized command with daemon permission. Downloaded cached90.6MiBsource tarball.
Baseline probes exit0,12/12PDFs parsed by pypdf6.19.0: every route has0link
annotations, though named destinations exist (native1,package/reload2).
ExternalLink/InternalLink/TargetBody text retained. generic/article, change/preserve,
print-to-file/export-postscript do not resolve absence. Pypdf reports duplicate
named-destination keys from native output; no package cause inferred for those.
First temporary Lisp script lacked close parenthesis, second lacked native
with-buffer import; both failed before full acceptance, logs retained. Corrected
imports/parentheses; valid baseline harness retained as probes-baseline.el.

Further public glue_editor.cpp trace shows update-current-buffer only invokes
typeset_invalidate_all; update-forced invokes typeset_forced (actual immediate
typesetting). Current worker uses former. Candidate mechanism: persistent native
link repositories must survive until PDF boxes render. Static bridge.cpp confirms
link repository lifetime; this alone does not prove causality. Repeated authorized
probes now add update-forced before each native print only; package/reload controls
remain unchanged. Result: all8native PDFs now have2links each (exact external URI and valid
internal destination), unchanged package/reload4controls still0. Same matrix
with candidate worker and synchronous native reload: all12PDFs have2links each.
Poppler independently identifies URI annotation and internal page href. This
is a demonstrated native consumer sequencing defect, not an inherent inability
to produce PDF links or an Org lowering/provenance defect.

## Candidate implementation and remaining validation

User-selected handling now has a bounded3file candidate: worker adds capability
check and update-forced before each existing print; retains3invalidation passes,
two prints, owned temporary buffer/file and existing recovery. No new public API,
worker operation, Org lowering, serialize/reparse path or PDF-link implementation.
README corrects earlier synchronous-update description and explains native links.
Two maintained ERT prepared, not run yet: actual Poppler URI/cross-page target
checks for generic/article, repeated same-worker rendering and independent native
.tm reload with released source; and failures at each new forced-layout phase
with healthy-worker retry/public-session isolation/private-output cleanup.
Existing independent native reload helper now forces layout before printing.

Candidate matrix12PDF checks passed before final README-only wrapping. No complete
ERT/native integration/lint acceptance claim yet. tmp/pdf-links holds exact25
project/lock/test candidate inputs,18original baseline inputs and11verified pinned
foreign Elisp modules copied from previous accepted fixture snapshot. Existing
user flake is still sole unrelated unstaged change; no ordinary staging/commit.
Original matrix/source-audit commands remain authorized. Next separately request:
1. timeout 120s nix build 'path:./tmp/pdf-links#checks.x86_64-linux.baseline' --no-link --no-update-lock-file --print-build-logs --print-out-paths
2. timeout 240s nix build 'path:./tmp/pdf-links#checks.x86_64-linux.focused' --no-link --no-update-lock-file --print-build-logs --print-out-paths
3. timeout 120s nix build 'path:./tmp/pdf-links#checks.x86_64-linux.integration' --no-link --no-update-lock-file --print-build-logs --print-out-paths
4. timeout 600s nix flake check path:./tmp/pdf-links --no-update-lock-file --print-build-logs
Baseline must show2expected failures against original worker. Focused covers
new tests, existing PDF/session/Issue11 behavior; full gate includes maintained
core ERT/strict compilation/lint and all isolated checks. No system Emacs.
No inferred project parent for this mixed native/candidate investigation. Exact
input manifests retain reproduction identities. Unique controlled baseline/
forced/fixed evidence warrants selective text archive once final harness/results
stabilize; active conclusions extracted now, no PDF/binary/archive mutation.
