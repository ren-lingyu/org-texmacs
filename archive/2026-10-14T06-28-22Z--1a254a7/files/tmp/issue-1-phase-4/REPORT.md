# Phase 4 working-buffer/context and actual package acceptance

User selected rewritten INBOX section17. Baseline main1a254a792286fe9c98a7529a6d13879ff707de24,
current project lock/unchanged USTC mirror. Preparation accepts final working Org
plus its supported normal context, not original INCLUDE provenance. Provider external
DB/read implementation is not intercepted or reimplemented.

## Native context investigation

6/6 locked Emacs31.1/Org9.8.10/Org-roam20260425.1623 probes0.113537s. Actual native
export working copy retains file identity/default-directory/local with-toc. Nested
cross-directory native INCLUDE relocates ordinary links to root-relative paths and
preserves notes. Bibliography raw relative declaration and raw STM-style resource
reference remain final text; they are not source-directory rewrites. Baseline adapter
rejects cross-directory input. Initial org-roam-version getter logging failed; fixed
by reporting library path, not package patch. baseline-phase4-probes.el and probes-final.log
retain original baseline evidence; current phase4-probes.el expects new adapter acceptance.

## Implemented contract

Remove included-directory equality checks, normalize fixed capture paths and use
each source directory for its temporary STM-discovery buffer. Keep root/final context,
local reads/UTF8/budgets/aliases/native cycles/shielding/receipts/source consistency.
Org owns lines/location/only-contents/minlevel/headlines/notes/ordinary file links.
Existing explicit preparation consumes an already completed working buffer without
preprocessing replay; no new parallel converter/public registration. Pure lowering/
worker/native encoding unchanged. Relative bibliography/STM use final document
context, not recovered INCLUDE directory. Native absolute ordinary-file encoding
unchanged; STM tree passing, path loading/rendering distinct and latter not established.
PDF explicit resource restrictions remain. No generic exporter/full annotate/Babel/
macros/SETUPFILE/BIND/region preprocessing/resource-origin map introduced.

Five core ERT: nested directory link/note/STM/native bytes and resource contexts;
final root bibliography despite same-named invalid child file; genuine STM image
block retained/context-owned and refused for PDF; prepared-working-buffer/no replay;
partial STM selection rejection.32/32 focused17.775013s then17.537532s in full gate.

## Actual extension fixtures

Pinned include ca62c8fb5c23064253877480edb2ba83a2cf2afb,
organize eaaee8e47137e4bebc65b3cce6b7c409bc5a24cd,
blog778d410f55710bca22a2d84a301a72b7b099b874. Root Elisp sources copied byte-exactly,
foreign repos clean/read-only; complete module manifests in extension-inputs.json.
Actual SQLite Org-roam sync/query/node APIs, global modes/hooks/advice enabled.
No DB/node/read replacements or package-specific production logic.7/7 fixtures
9.025827s focused,8.708412s full: include native recursion/parameters/ROAM file mounts,
cycles/missing nodes/source+helper restoration; managed node-relative bib discovery,
UUID key filter/native bibliography/missing refs before worker; joint TeXmacs bytes,
unchanged standard HTML before/after, actual blog publication and output content;
mode teardown restores standard interfaces. Initial incomplete fixture registry
missing mandatory MOC corrected without external package patch.

Maintained optional tests/integration/default.nix accepts caller-supplied Emacs with
Org-roam/main package plus pinned Elisp-only extensionSources. Fixture owns source,
SQLite/ID/cache/publication/home; cleans after cases. Default core flake dependencies
unchanged. Personal databases never accessed, third-party repos unchanged.

## Full acceptance and limits

Exact authorized240s independent flake check exits0:373/373 core ERT189.379261s,
strict compile/package-lint; all10checks logged,32focused/7integration/6nativeprobes.
23 former inputs plus2new integration files byte-match root; manifests capture exact
candidate/package inputs. Working implementation uncommitted, only user mirror in
root flake, lock unchanged, no ordinary staging/commit/issue write.

Platform x86_64-linux only; no generic-export/frontend-default switch, all registries/
all syntax/DB atomicity/full-native lifecycle/resource rendering/other platforms proof.
Latest section17 selected4a-4d deliverables complete. Broader formal frontend policy
in original INBOX proposal is not silently implemented; any remaining issue-closing
scope must distinguish implemented opt-in standard interfaces from default dispatcher.
