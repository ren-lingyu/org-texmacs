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

## Prepared isolated validation, pending authorization

Safe ignored nonsymlink tmp/pdf-links contains18exact copied current project/lock/
ERT/README/LICENSE inputs plus SHA256 manifest, independent flake/harness. User
root flake mirror untouched. No business-code changes/tests/builds performed.
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

Pending sequential repeatable commands under separate user test authorization:
1. timeout 120s nix build 'path:./tmp/pdf-links#checks.x86_64-linux.source-audit' --no-link --no-update-lock-file --print-build-logs --print-out-paths
2. timeout 240s nix build 'path:./tmp/pdf-links#checks.x86_64-linux.probes' --no-link --no-update-lock-file --print-build-logs --print-out-paths
Possible writes: task tmp/results, Nix store/cache and private build/home outputs.
May fetch locked dependencies/source/inspector; no lock changes. Copy bounded
text results to task tmp, PDFs remain tmp/build only. Diagnose before selecting
production edits/full regression. Archive selection deferred until unique probe
evidence exists; active findings extracted here, no raw archive yet.
