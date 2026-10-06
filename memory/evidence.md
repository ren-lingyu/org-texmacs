# org-texmacs durable evidence

## Evidence levels

- A source/documentation observation establishes an available API or declared
  behavior, not package integration correctness.
- A temporary probe establishes the tested input/environment only. It is not a
  maintained regression unless transferred into ERT.
- ERT establishes the maintained test cases under the recorded environment.
- Nix checks/build and installation probes establish package assembly and
  loading in their recorded paths; they do not establish GUI or visual output.
- A TeXmacs native readback establishes accepted native structure and bytes,
  not visual pagination or typesetting quality.

## Named-footnote semantic evidence

- Org 9.8-pre `ox.el` collects named inline and separate definitions before
  pruning. Its missing-definition recovery can fall back to a widened source
  buffer; this package instead restores parsed snapshot nodes into its owned AST.
  Org's footnote forms and special-section convention are documented at
  https://orgmode.org/manual/Creating-Footnotes.html and
  https://orgmode.org/worg/org-syntax.html.
- With user-authorized reads of TeXmacs 2.1.5 `packages/standard/*.ts`, the
  `std-latex-base.ts` `footnotemark*` macro establishes the repeated-mark shape
  `rsup` / right-shaped `reference`. The package uses private anchor labels
  rather than assuming physical footnote counter values.
- A fresh headless native session's environment query returned `(uninit)` for
  `footnote`, `footnote-text`, `footnotemark*`, `footnote-ref` and `next-footnote`.
  This does not establish absence of the macros or rendered numbering behavior.
  Exact runner, Scheme query and output are preserved as three UTF-8 plain-text
  files in `archive/2026-10-06T16-59-25Z--77a2888/`, archive-only checkpoint
  `548e6c3a8a6caa688b93de01d547bca204c279bb`, with sole additional project parent
  `77a28881807d1bf8dba508b1f8a07f392083dfca`. Byte copies, sizes and hashes match;
  no active memory, temporary mirror overlay or binaries entered that checkpoint.
- Nine new maintained ERT cases cover first/repeated references, forward inline
  definitions, definitions recovered from filtered trees, custom footnote
  section settings and stale settings, unused/invalid definitions, owned input
  after source disposal, STM/file provenance, native encoding, block bodies,
  local targets, private label collisions and empty definitions. Fourteen
  footnote tests passed, including the retained anonymous-note regressions.
- Initial full local and Nix suites both reached 231/232. The only failure was
  an obsolete unsupported-source fixture: line-initial `[fn:named]` is now an
  unused separate definition. The fixture was changed to `A[fn:named]`, a true
  unresolved reference, and its focused rerun passed. On 2026-10-07 the final
  full local ERT passed 232/232, exit 0, in 108.25 seconds (`emacs-twist`, Emacs
  31.1 / Org 9.8-pre / TeXmacs 2.1.5). Final Nix flake checking passed, exit 0,
  including installed-package ERT 232/232 in 84.47 seconds. Package build,
  compilation and package-lint passed in the first check and were reused by
  the final check because only the obsolete test fixture changed.
- Validation used the user's unchanged local-only remote USTC mirror overlay;
  it does not establish original GNU ELPA availability. The overlay diff hash
  remains `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
- Verified and approved staged diff on base
  `77a28881807d1bf8dba508b1f8a07f392083dfca`: SHA-256
  `82c13615c352889dbedede08505518eacb09db78fa1b739c5105448db0da0cd5` for
  `git diff HEAD -- README.org org-texmacs-context.el org-texmacs-document.el tests/ert/ert.el`.
  The complete staged diff matches that hash exactly; `git diff --check` passed.
  Project commit remains pending; `tmp/commit.md` is the reviewed message.

## Release provenance

- v0.1.0 target: `6fd48944c238e0b627e3bc2d47e224ebf8e2892b`.
- v0.2.0 target: `c115285639f6d40e40de378b6e2da4a79f3c1cd0`.
- v0.2.1 target: `9988476b7ae98f33375d9c62ef4234890ce8b39c`.
- v0.3.0 target: `8c157d06b7a8793b0bd312e8f0c41612a3640388`.
- Local v0.3.1 annotated tag target:
  `880d4e00667907ef66985387b4865ec8d795d48d`.
- Current main HEAD observed on 2026-10-07:
  `77a28881807d1bf8dba508b1f8a07f392083dfca`.

These are local Git facts. They do not prove remote release state or tag
signatures.

The v0.3.1 metadata commit changes the package and Nix versions and README
release wording. `git diff --check` passed before that commit. No build or test
was run specifically for the metadata change; the ARCH-01 code refactor had
already passed 203/203 ERT and the Nix checks recorded in `memory/current.md`.

## Environment represented by formal release evidence

- x86_64-linux.
- Emacs 31.1.
- Org 9.8-pre.
- TeXmacs 2.1.5.

Other systems were not established by the recorded validations.

## Final v0.3.0 verification

- 202/202 ERT tests passed with zero unexpected results.
- Seven Nix flake checks passed.
- Independent default package build passed.
- Local and straight installed-package probes passed.
- Installed artifacts included all ten Lisp modules, compiled outputs, the
  adjacent worker Scheme source, version 0.3.0 metadata, and the TeXmacs 2.1.5
  executable path.
- Cold-start and repeated complete native document updates covered metadata,
  TOC, lists, tables, code, STM, style, initial, body, parsing, and cache/worker
  reuse while preserving source state.

## Durable Org facts

- Org special blocks expose exact content spans suitable for raw STM source.
- Arbitrary pseudo-node types can be created and traversed without registering
  every TeXmacs tag, provided the Org property slot is represented correctly.
- Org custom element cache entries invalidate safely but coarsely when element
  positions shift; they are not stable block identities.
- Relevant Org pruning can remove foreign-looking node types unless TeXmacs
  islands are masked and mapped externally during context construction.
- Full exporter environment collection may read SETUPFILE, query IDs, or fall
  back to buffers for footnotes, so the package uses a restricted adapter.
- The Org manual describes `file:` links with relative paths and shows that
  HTML export/publishing can transform file-link paths. This supports keeping
  source-relative meaning distinct from consumer output paths, but does not
  establish the exact base-directory rule for this package's buffer adapter.
  Verify that rule and suitable `ox-*` helpers against the supported Org version
  before implementing DOC-01 file/resource references. Sources:
  https://orgmode.org/manual/External-Links.html and
  https://orgmode.org/manual/Publishing-links.html.
- Org table ASTs can represent irregular and advanced structures; explicit
  validation is required for the supported rectangular subset.

## DOC-01 first-node worktree verification

- On 2026-10-06, full ERT passed 210/210, exit 0, in 105.71 seconds using
  `emacs-twist`. All ten package modules also byte-compiled without warnings,
  exit 0, under Emacs 31.1 and Org 9.8-pre. Compilation output is disposable
  local `tmp/doc-01-byte-compile-lRJoQd/` and is not a recovery dependency.
- Seven new maintained cases cover local headline/ID resolution after disposal
  of the source buffer, dedicated targets, missing/ambiguous/filtered targets,
  static STM label conflicts, low-level headline labels and target precedence,
  preflight before island requests, and native label/reference readback.
- Verification used the uncommitted five-file worktree diff on base
  `880d4e00667907ef66985387b4865ec8d795d48d`. SHA-256 of
  `git diff HEAD -- README.org org-texmacs-context.el org-texmacs-document.el org-texmacs.el tests/ert/ert.el`
  was `07656ff6745c9c00d106faf48689e233fc183d13e5bb4f2036cafd16fc340555`.
  The later project commit `a3ba241d66dc1e1a89a9eb4c4fc678fef2f5bfb4` was
  checked on 2026-10-06: its diff from that base matches this hash exactly.
- Nix flake checking timed out twice at 120 seconds, inside and outside the
  host sandbox, while downloading Org 9.8.8 from ELPA with a TLS unexpected-EOF
  error. It did not reach package building or the declared project checks.
  A local package-lint attempt could not load the absent `package-lint`
  library (exit 255). These are validation gaps, not established code defects.
- On 2026-10-06 the user independently reported being unable to access
  `elpa.gnu.org` from multiple devices and network environments. This is
  user-reported evidence corroborating an availability problem beyond the
  agent sandbox; it does not establish a global outage or its root cause.
  Keep the failed dependency download marked separately from project checks.
- One earlier 30-second focused native run timed out; its cause is unknown.
  Its 120-second rerun and the final full suite passed. GUI rendering and actual
  displayed reference numbers remain unverified.
- Semantic references consulted: Org's internal-link conventions at
  https://orgmode.org/manual/Internal-Links.html and TeXmacs linking primitives
  at https://www.texmacs.org/tmdoc/devel/format/regular/prim-link.en.html.
  These documentation observations do not substitute for native/visual tests.

## Source/resource context decisions and verification

The user authorized reading five installed Org source files for this task.
The inspected Org 9.8-pre source root was:

`/nix/store/bdfdqx9nhkzz1crr5lnk10dyissdn59p-emacs-pgtk-31-1-org-9.8-pre/share/emacs/site-lisp/`

- `ox.el`, `org-export--get-buffer-attributes` (1691), takes file identity from
  the base buffer. It does not establish a resource-directory override.
- `ol.el`, `org-link--normalize-filename` (2682), uses the effective directory;
  `ox-html.el`, `org-html-link` (3432), and `ox-latex.el`, `org-latex-link`
  (3339), retain relative file paths through applicable helpers.
- `ox-publish.el`, `org-publish-file-relative-name` (1204), explicitly leaves
  relative names unchanged and applies publishing policy to eligible absolute
  paths. That policy belongs to consumers, not source-side local handlers.
- A focused helper probe used file identity
  `/tmp/org-resource-context/source/notes.org` and effective directory
  `/tmp/org-resource-context/override/`. `org-export--get-buffer-attributes`
  retained the former; `org-link--normalize-filename` with `noabbrev` resolved
  `figures/a.pdf` to the latter directory. `org-export-file-uri` and
  `org-publish-file-relative-name` (with a different publishing base) both
  retained `figures/a.pdf`. No export pipeline or resource files were read.
- Snapshot locations may legitimately use `~/...`; preparation expands this
  once, while pure constructors require explicit absolute strings. The first
  full run exposed rejection of the host's normal abbreviated directory, which
  was corrected and transferred into maintained ERT.
- A prototype field named `source-directory` produced input/result aliasing;
  `special-variable-p` confirmed it is an Emacs dynamic variable. The field
  was renamed `resource-base`, and ownership/in-place-mutation regressions pass.
- Source inspection also showed LaTeX's undescribed unnumbered-headline link
  title fallback. Native reference presentation remains a separate review
  boundary; native readback does not verify equivalent displayed text.

SHA-256 of the inspected files, respectively:

| Source | SHA-256 |
| --- | --- |
| ox.el | 76bb6cab98fe51c14313055b364af707f1b6fd98165a00074e055609841b73c5 |
| ox-html.el | 09a7ef0ba6bf40a1fa0b5bdf1db2647fdcc4f2ee264aaa951c3e28f742b1dc9a |
| ox-latex.el | 4cd4f7beb6da9ce4965cb94db522f5455c98b5f89b3e82946e1bceb41d56960d |
| ox-publish.el | e7d91ad3f5527aea7f54f621610ae96def9d4e362a1a0990552da7ec51ae2951 |
| ol.el | aad28b1fe9eea70943d26d46f95a4129b614d04d539b0e7fb22954b89a6ee18f |

On 2026-10-06 the final local full ERT passed 217/217 (exit 0, 106.36 seconds)
under `emacs-twist`, and all ten modules byte-compiled without warnings (exit
0). Seven new maintained cases cover pure ownership, explicit/omitted paths,
source-vs-caller directories, visiting/non-file/indirect buffers, preparation
home expansion, location changes/in-place mutation across worker waits, and
post-preflight checks.

The verified six-file diff on baseline `a3ba241d66dc1e1a89a9eb4c4fc678fef2f5bfb4`
had SHA-256 `3661d1b73013c08f1353f2cf29336486021210211eaa70cbbf5fcd87d2e0c768`
using `git diff HEAD -- README.org org-texmacs-document.el org-texmacs-input.el org-texmacs-source.el org-texmacs.el tests/ert/ert.el`.
The later project commit `b09b4515ad0445666d666506969e441d8f5e6b89` was checked:
its six-file diff from that baseline matches this hash exactly.

After local implementation/validation finished, `timeout 120s nix flake check
-L --no-write-lock-file` passed (exit 0), including package building,
package-lint, and installed-package ERT 217/217 (82.34 seconds). This used the
user's temporary overlay rewriting `https://elpa.gnu.org/packages/` to the
remote `https://mirrors.ustc.edu.cn/elpa/gnu/` mirror while retaining fetchurl
hash verification. The configuration is only retained locally and must not be
committed or pushed. Its diff hash was
`1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`; it is
excluded from the six-file implementation diff. This does not establish
availability of GNU ELPA. The installed package was
`/nix/store/fxri3nk51fwihvr995h50widajllizgn-emacs-org-texmacs-0.3.1/`.

Source-location archive selection found no necessary independent temporary artifact: bytecode
directories are regenerable cache, the probe inputs/results/provenance are
fully distilled here, and maintained ERT covers adopted snapshot semantics.
`tmp/commit.md` duplicates the committed first-node message. No raw overlay
snapshot is committed. No archive checkpoint was needed for that source-location node.

## Plain local file-link worktree verification

- With explicit read permission, the installed TeXmacs 2.1.5 Scheme source
  `progs/link/link-navigate.scm` showed `go-to-vertex` (576) calling
  `cork->utf8` before URL handling, `go-to-url` (525) using `system->url`, and
  `process-url` (423) separating `#`/`?` post-navigation syntax. Its SHA-256 was
  `9b075c37048032592779f9ae623e8b2f74e89c30ad4512c3fd843a64fef28563`, under
  `/nix/store/fbmq6la2pwcapsgmqp3zy6d4dbrn270a-texmacs-2.1.5/share/TeXmacs/`.
- A native probe established that system URL/string conversion retains raw
  absolute paths, including spaces, Unicode and literal angle brackets.
  Restoring UTF-8 after ordinary native Cork encoding recovered the exact path.
  `#`/`?` remain unescaped by that conversion and are therefore outside the
  first native file-target subset. Other URL expression characters are also
  explicitly restricted rather than silently interpreted.
- The initial sandbox run failed on Unix socket bind with Operation not
  permitted. The same isolated probe outside that sandbox passed. No target
  files were opened and no hyperlinks were followed.
- The three exact plain-text probe artifacts were copied byte for byte and
  digest/size verified in `archive/2026-10-06T14-50-30Z--b09b451/`. Independent
  archive-only checkpoint `9d8d351e63bad079087301aaf3b410d29307a824` has sole
  additional project parent `b09b4515ad0445666d666506969e441d8f5e6b89`. Its
  manifest records each role, source path, byte count and digest. Active memory,
  binary artifacts and the temporary overlay were excluded from that checkpoint.
- The implementation adds raw file-target path provenance; it rewrites only
  marked hlink target leaves in the native bridge, on a body copy with an
  explicit captured base. The native Scheme wire and service are unchanged.
- On 2026-10-06 final local full ERT passed 223/223, exit 0, in 102.71 seconds.
  Six new maintained tests cover source/caller directory independence, raw
  path/result ownership, container/STM provenance, explicit context and rejected
  resource semantics, marker validation, reserved native syntax, Unicode/literal
  native readback, and preflight preserving a healthy worker/session.
- Nix flake checks then passed (exit 0), covering the installed package,
  native compilation, package-lint and ERT 223/223 (84.71 seconds). This used
  the user's temporary, uncommitted/unpushed USTC mirror-source configuration;
  the unchanged overlay diff hash is recorded in the preceding section.
  The installed package was
  `/nix/store/0dmslh2v6d0yklwg900apn1g0cjcsd48-emacs-org-texmacs-0.3.1/`.
- The verified five-file worktree diff on baseline
  `b09b4515ad0445666d666506969e441d8f5e6b89` has SHA-256
  `9a4808d6615612c728ba1b249929c2ff1db2e5c3cbf9aa5dccc844733ab0f913` using
  `git diff HEAD -- README.org org-texmacs-document.el org-texmacs-session.el org-texmacs.el tests/ert/ert.el`.
  The later commit `77a28881807d1bf8dba508b1f8a07f392083dfca` was compared with
  that baseline and its five-file diff matches this hash exactly.
  GUI navigation, file search/remote/tilde targets and broader
  filename escaping remain unverified or explicitly unsupported.

## Durable TeXmacs facts

- `stm-snippet->texmacs` is a recovery parser and cannot alone prove strict STM
  syntax; strict Scheme datum/EOF validation is required first.
- A long-lived headless TeXmacs process can serve multiple socket requests and
  recover after request-local parse errors.
- Direct stdin was not a usable worker channel in the tested design; a local
  Unix-domain socket works.
- Native body trees can be passed directly through TeXmacs tree/stree APIs; no
  file serialization intermediate is required.
- Ordinary literal text and STM source notation require different native
  encoding semantics, which is why provenance survives structural lowering.
- Headless native document operations can apply style, enumerate/clear/set
  structured initial state, replace body, and read back the combined state.
- TeXmacs may normalize document style packages. Initial environment comparison
  is order-independent.

## Important failure interpretation

- Probe failures caused by malformed Scheme commands, missing TeXmacs module
  loads, incorrect test assumptions, or sandbox socket restrictions were not
  treated as package defects once their causes were established.
- A historical worker response containing circular read notation motivated
  explicit `read-circle` handling. The original anomaly's root cause was not
  reliably reproduced; do not claim more than the regression establishes.
- Native mutation failures are not transactionally rolled back. The supported
  policy is to discard the damaged session and allow a new session on the same
  healthy worker when possible.

## Unverified boundaries

GUI behavior, visual typesetting, actual pagination/page-number correctness,
file serialization, PDF/export, remote release publication, tag signatures,
multi-session behavior, and systems other than the recorded x86_64-linux
environment remain unverified unless later memory records new evidence.
