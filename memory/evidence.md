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

## Interactive export / native byte-view evidence

- Adapter commit `ee225ad62ffedf529239f7a31fd4cc73e9743519` matches its verified
  four-file diff, checked on 2026-10-07. Interactive work began with only the
  unchanged user overlay dirty.
- Four new maintained cases pass in sixteen combined cases (17.02s). Native
  buffer bytes match direct export for Cafe with accent, Chinese and literal
  notation. Output buffers are readonly/unibyte, use no-conversion, own their
  contents and never overwrite a preexisting view; source state is unchanged.
- Tests suppress actual display/file UI, simulate interactive invocation, and
  inject display failure to check ownership/cleanup. They verify the original
  source survives a prompt callback switching current buffers, filename defaults,
  and invalid/non-Org/narrowed/remote-directory preflight before prompts.
- Initial tests used a nonexistent buffer-multibyte-p and assumed batch
  funcall-interactively makes called-interactively-p with interactive flag true.
  They now inspect enable-multibyte-characters and simulate noninteractive=nil
  only around the mocked UI call. No real GUI invocation is claimed.
- First Nix checking rejected newly added docstrings wider than 80 characters.
  Their text was rewrapped without changing behavior. Final Nix passes all seven
  checks including compilation/package-lint and installed ERT 265/265 (104.35s).
  No successful installed check is claimed for the rejected build.
- Initial local non-worker bucket timed out at 120s around 251/254, with no
  observed failure. Complete local coverage then passed disjoint selectors
  document 105/105 (43.83s), non-document/non-worker 149/149 (71.53s) and worker
  11/11 (11.88s), all exit 0. Keep these smaller groups instead of extending
  timeouts or rerunning the overlong bucket. Validation uses the unchanged
  temporary local-only remote USTC mirror overlay; original ELPA is unverified.
- Exact approved/staged three-file diff on baseline
  `ee225ad62ffedf529239f7a31fd4cc73e9743519` has SHA-256
  `3f3a1f61d1f0b24ad984c6723ada568ec12a5b8015a9de968200ac32e9878d51`
  for `git diff --cached -- README.org org-texmacs.el tests/ert/ert.el`.
  Full staged review and git diff --cached --check pass. No implementation is
  unstaged at that review. Commit `1ed04db7d5635d4851f78bf89c2bb72e9693312a`
  was compared with its baseline on 2026-10-07 and matches this exact diff hash.
  Current memory has been condensed to active state, boundaries and next actions;
  superseded completion records remain in project/evidence and GAW history.
- Test byte files/buffers are regenerable maintained fixtures, not unique raw
  evidence. No necessary new archive snapshot is selected; only pure text enters
  GAW. Interactive bibliography reads and generic backend/dispatcher are not adopted.

## Explicit-source export adapter evidence

- Saving commit `0ee17c4acc88664e2024af26d8ebcf08084e85a7` matches the earlier
  verified three-file diff, checked on 2026-10-07. Adapter work began with only
  the unchanged user overlay dirty.
- Existing private preparation already calls its consumer before its final
  check. Composing document lowering and native serialization there extends
  the owned source/dependency guard through the last worker wait. File writing
  is performed only after that call returns successfully, using shared native
  target/byte helpers rather than serializing the document a second time.
- Four new maintained cases pass in twelve combined serialization/save/export
  cases (14.36s). Native byte and file outputs match with literal/native notation,
  Unicode/accents, title metadata and typed file links under a distinct destination.
  Each export serializes once, preserves source buffer state and bypasses generic
  Org export hooks/processing.
- Late source text/location/heading/link/narrowing/mode/kill changes and original
  bibliography string mutation are rejected before file writing. Target identity
  is copied before preparation; existing outputs and unsupported INCLUDE/SETUPFILE
  fail preflight. Prior writer regressions remain in the focused selector.
  Full local ERT passes disjoint 250/250 + 11/11 (110.81s and 12.27s), both exit
  0. Final Nix passes all seven checks including compilation/package-lint and
  installed ERT 261/261 (97.33s), using the unchanged temporary local-only remote
  USTC mirror overlay. Original ELPA availability is not established.
  Generic backend/dispatcher behavior,
  replacement/backup and GUI rendering remain separate unverified boundaries.
- Exact approved/staged four-file diff on baseline
  `0ee17c4acc88664e2024af26d8ebcf08084e85a7` has SHA-256
  `48f06c5326ad5140f291110c7a05cabffba941c1c2c1e87cbac2aa6c0101f163`
  for `git diff --cached -- README.org org-texmacs-session.el org-texmacs.el tests/ert/ert.el`.
  Full staged review and git diff --cached --check pass. No implementation
  remained unstaged at that review. Commit `ee225ad62ffedf529239f7a31fd4cc73e9743519`
  was checked on 2026-10-07 and matches this exact diff hash; the overlay remains
  unchanged at its previously recorded hash.
- No independent necessary temporary evidence artifact was created. All generated
  output is regenerable in maintained tests and confined to isolated directories.
  Archive selection requires no new snapshot; only pure text enters GAW.

## Explicit new-file saving evidence

- Serialization commit `e7377e5767ca38411a497a635d5053f1729a2d5a` matches its
  verified five-file diff hash, checked on 2026-10-07. Saving work began with
  only the unchanged temporary mirror overlay dirty.
- GNU Emacs's Writing-to-Files reference documents write-region mustbenew=excl
  as race-safe local exclusive creation that does not follow symlinks. Format
  Conversion Overview documents annotation, format and coding stages; the save
  consumer isolates those stages while retaining exact native output bytes.
  References: https://www.gnu.org/software/emacs/manual/html_node/elisp/Writing-to-Files.html
  and https://www.gnu.org/software/emacs/manual/html_node/elisp/Format-Conversion-Overview.html.
- Four new maintained tests pass in eight combined serialization/save cases
  (9.83s). Real saved bytes equal native serialization for Cafe with accent,
  Chinese/literal notation and translated file links under a distinct save
  directory. Hostile coding/format/annotation/handler settings do not change
  output, caller buffer state remains intact, and the worker is reused.
- Tests also cover local-path preflight, existing files/directories/dangling
  symlinks, destination string mutation during a wait, actual exclusive-open
  races with a new file/directory/symlink, no output on serialization/encoding
  failure, and the documented partial-new-file boundary on injected write error.
  Full local ERT passes disjoint 246/246 + 11/11 (106.47s and 11.91s), both
  exit 0. Nix passes all seven checks including compilation/package-lint and
  installed ERT 257/257 (94.49s), with the unchanged temporary local-only remote
  USTC mirror overlay. Original ELPA availability is unverified. No arbitrary destination outside
  isolated test directories was written by the agent.
- Exact approved/staged three-file diff on baseline
  `e7377e5767ca38411a497a635d5053f1729a2d5a` has SHA-256
  `866da9c3b5a8a874950bf0b27a762f3f34e7b09339e1f9b9c02e13080cf2cce4`
  for `git diff --cached -- README.org org-texmacs-session.el tests/ert/ert.el`.
  Full staged review and git diff --cached --check pass. No implementation is
  unstaged at that review. Commit `0ee17c4acc88664e2024af26d8ebcf08084e85a7`
  was checked on 2026-10-07 and matches this exact diff hash. The overlay remains
  unchanged at its previously recorded hash.
- Test outputs are regenerable temporary fixtures with maintained inputs/assertions.
  No independent necessary raw artifact requires a new archive; only pure text
  enters GAW. The temporary mirror overlay stays excluded from commits/pushes.

## Complete native serialization evidence

- Named-table commit `544e2463878d5658119f6beb9b8a6a8275e1739c` matches the
  preceding verified five-file diff, checked on 2026-10-07. Consumer work began
  with only the unchanged user overlay dirty.
- Authorized TeXmacs 2.1.5 tm-file-system.scm (309 and 320) constructs document,
  TeXmacs/runtime version, style tuple and body directly. Its SHA-256 is
  `b5975e0c32e55afe3862290c418bdd74263e64be077e52d4ec8e1ca03cb6dd17`.
  The official Scheme API documents serialize-texmacs/parse-texmacs as native
  tree/string bindings; texmacs->stm is Scheme serialization, a distinct format.
  References: https://www.texmacs.org/tmweb/documents/manuals/texmacs-scheme.en.pdf
  and https://www.texmacs.org/tmweb/manual/webman-format.en.html.
- Four focused maintained tests pass. A test-local serializer wrapper compares
  the entire constructed native file tree with parse-texmacs of its output,
  covering repeated explicit style names, structured initial values, Cafe with
  accent, Chinese, literal/native alpha and translated file targets. Serialization
  before/after establishing a different live session is byte-identical and
  session readback is unchanged. Another test consumes completed named table,
  footnote and citation/bibliography output after source disposal. Protocol tests
  preserve high bytes/NUL without UTF-8 conversion and distinguish bad payloads
  from domain failures; actual injected native serializer/encoding errors retain
  a healthy worker. Empty document/no-initial behavior is in the final full run.
- Initial test development caught a surplus test parenthesis, a bibliography
  print unintentionally inside a footnote definition, and a nonexistent fixture
  default-directory during worker startup; these fixtures were corrected.
  The first Nix run rejected obsolete string-as-unibyte under warnings-as-errors.
  The bridge now directly allocates its zero-filled unibyte result. Full local ERT
  covered the pre-adjustment code in disjoint 242/242 + 11/11 (109.71s and 11.88s);
  final focused 4/4 covers the obsolete-helper replacement (6.88s). Final Nix passed all
  seven checks, including compilation, package-lint and installed ERT 253/253
  (96.29s), covering the exact final code. No successful check is claimed for
  the rejected build. Environment remains Emacs 31.1 / Org 9.8-pre / TeXmacs 2.1.5
  with the unchanged temporary local-only remote USTC mirror overlay; original
  ELPA availability is not established.
- Exact approved/staged five-file diff on baseline
  `544e2463878d5658119f6beb9b8a6a8275e1739c` has SHA-256
  `d7449b539a743bd447d9eefac0d3e92e5091c87b6809099619552d453c9195d7`
  for `git diff --cached -- README.org org-texmacs-core.el org-texmacs-session.el org-texmacs-worker.scm tests/ert/ert.el`.
  Full staged review and git diff --cached --check passed. No implementation
  remained unstaged at that review. Commit
  `e7377e5767ca38411a497a635d5053f1729a2d5a` was compared with its baseline on
  2026-10-07 and matches that diff hash exactly. The overlay hash remains
  `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
- No independent necessary temporary evidence file was created. The generated
  test scripts are fully maintained in ERT and disposable; native observations
  are recorded here. Archive selection needs no new snapshot, and only pure text
  enters GAW. Output file saving and GUI/layout verification are outside this node.

## Named-table/caption semantic evidence

- User-authorized TeXmacs 2.1.5 source reads establish env-float's new-figure
  table definition, env-base's big-table native counter and caption binding,
  and caption-detailed/caption-summarized long/short argument semantics.
  The reference label is placed in the caption argument, after that binding.
- Installed source SHA-256: env-base.ts
  `9607eb103d3cf2aaa3ecc43ad2d028c29eb5da4fbb49b3a7591d0a3fa4882223`,
  env-float.ts
  `3fe7c48b9a07281860069110204a7a66d0dd1fd9f862ba2c6cb517ae095ed8ce`,
  std-counter.ts
  `401d98ab3e1c2f8b4ebd2c9935f2963ec27b9b359d354398a3d18eca717412cf`,
  under the installed TeXmacs root recorded in earlier evidence.
- Org 9.8-pre ox.el org-export-get-caption joins long/short caption lines;
  org-export-resolve-fuzzy-link places names/targets ahead of headline titles.
  The package retains exact matching and explicit ambiguity instead of an
  ambient exporter cache. A synthetic parser observation confirms captions
  are pairs of secondary strings, outside secondary-value-alist. Footnote-like
  text is literal under Org caption restrictions; citation objects are parsed
  and are explicitly rejected by this node.
- Five new maintained ERT cases pass, including ownership after source disposal,
  long/short captions and local links, uncaptioned described-only anchors,
  target ambiguity/filtering, metadata preflight, native Unicode/literal/file
  provenance readback and static STM label avoidance. Initial full local/Nix
  runs each found eight existing footnote/citation failures caused by treating
  intrinsic footnote :label as affiliated metadata. The guard was restricted
  to table keys; all eighteen combined citation/footnote/table focused cases
  then passed. Final local complete coverage passes disjoint 238/238 + 11/11
  selectors (98.61s and 12.20s, both exit 0); final Nix checks pass all seven
  checks, including compilation, package-lint and installed ERT 249/249
  (87.27s). Environment remains Emacs 31.1 / Org 9.8-pre / TeXmacs 2.1.5.
- Exact reviewed and approved staged five-file diff on baseline
  `fe6c435bda7948989f758cea6c9d4146c0d0a5cb` has SHA-256
  `52de57a9928f1afc4001bb9d902ed56eef40ac8206a33006a0b7fd0893e68c45`
  for `git diff --cached -- README.org org-texmacs-context.el org-texmacs-document.el org-texmacs-input.el tests/ert/ert.el`.
  `git diff --cached --check` passes; no implementation remains unstaged.
  The overlay stays unstaged and unchanged at the hash recorded below.
  Project commit `544e2463878d5658119f6beb9b8a6a8275e1739c` was checked on
  2026-10-07 and matches that diff hash exactly;
  displayed numbers, caption layout and pagination are unverified.
- No necessary new raw temporary artifact was created. Source observations are
  recorded here, and adopted semantics have maintained ERT. The previous commit
  draft duplicated the now-committed citation message; its replacement is a
  regenerable draft from the reviewed staged diff. Archive selection requires no new
  snapshot. No binary, overlay or installed-source copy is added to GAW.

## Default citation/plain bibliography node evidence

- Foundation commit `8e1abf743d37792c43184c84f62dd2f1dceab348` exactly matches
  the recorded seven-file SHA-256, checked on 2026-10-07.
- Four new maintained cases cover preflight rejection; footnote-aware ordering;
  stale prefix/key/entry views; formatting waits, bad payloads and domain-error
  worker preservation; multiple keys/static STM label conflicts; prepared input
  after source disposal; and Cafe-with-accent, Chinese and literal-angle native
  output/readback. Twelve citation/bibliography focused tests passed.
- The first complete local ERT hit timeout 120s around test 230/244, with no
  observed failed tests. Disjoint selectors `(not "^org-texmacs-test-worker-")`
  and `"^org-texmacs-test-worker-"` passed 233/233 (117.17s) and 11/11 (13.21s),
  both exit 0, covering all 244 local cases without longer command timeouts.
- Final Nix checking passed, exit 0, including compilation, package-lint and
  installed ERT 244/244 in 101.89s. Environment: local emacs-twist Emacs 31.1 /
  Org 9.8-pre and TeXmacs 2.1.5; Nix package verification uses the declared inputs.
  The temporary, local-only remote USTC mirror overlay remains unchanged at
  `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
  Original GNU ELPA availability is not established.
- Native integration initially rejected a use-modules form inside a function:
  TeXmacs requires it at top level. Bib utility import is now top-level; the
  plain style is provided lazily and its dynamic prefix/style/default state is
  restored. The temporary debug worker copy was regenerable and its diagnosis
  is fully represented here and in maintained coverage; no new necessary raw
  artifact qualified for archiving. Only that task-created copy was removed.
- Exact approved staged eight-file diff on the foundation baseline has SHA-256
  `8dd996137ed791117e83d683d404950f3dc475218381df0441291b388e768bee` for
  `git diff HEAD -- README.org org-texmacs-context.el org-texmacs-document.el org-texmacs-input.el org-texmacs-source.el org-texmacs-worker.scm org-texmacs.el tests/ert/ert.el`.
  Complete staged review and git diff --check passed. No implementation changes
  remained unstaged at citation review; its former tmp/commit.md was the reviewed
  message. Project commit
  `fe6c435bda7948989f758cea6c9d4146c0d0a5cb` was checked on 2026-10-07 and
  matches this exact diff hash. GUI bibliography/citation values and typesetting
  are unverified.

## Bibliography snapshot foundation evidence

- The user selected explicit path-to-BibTeX-text snapshots for the first
  citations/bibliography dependency node. No user bibliography data was read.
  Authorized installed-source reads covered `oc.el`, `oc-basic.el`, relevant
  TeXmacs citation/bibliography Scheme and .ts fragments, and local Emacs
  `bibtex.el` parser/dialect/validation fragments.
- Org `oc.el` combines document/global bibliography declarations; its citation
  collection follows footnote bodies at first use. `oc-basic.el`'s high-level
  parser uses file metadata, global caches and file reads. Emacs 31.1's
  `bibtex-validate` can also initialize global file lists. The foundation uses
  only local entry/field parsers with fixed types/settings; automatic commas,
  string expansion and the imenu settings changed by dialect setup are bound.
- TeXmacs 2.1.5's `std-automatic.ts` provides `with-bib`, grouped `cite`,
  `cite-detail`, `bibitem-with-key` and `bib-list`. Its native in-memory parser
  and plain formatter accepted synthetic text and emitted typed entry trees
  plus labelled `bib-list` data. The malformed input `@book{broken, title={Missing`
  was recovered silently, establishing the need for strict pre-validation.
  Unicode/native markup emerged as source notation (`<#4E2D>`, `<less>...`).
- The original synthetic probe first timed out in the command sandbox (124,
  no result). An explicitly approved outside-sandbox run of the same command
  passed (exit 0). This does not establish a bibliography parser defect from
  the original timeout. The three exact pure-text probe files are preserved in
  `archive/2026-10-06T17-35-50Z--a242eb2/`, archive-only checkpoint
  `84be873e30943d2c37b4bfe612d1e81f0effd9b6`, with sole additional project parent
  `a242eb233322a62b3f18dbf1a3ba1278e628e361`. Bytes/digests and unchanged HEAD
  were verified. No active memory, overlay or binaries entered the archive.
- Eight new maintained cases cover pure ownership/invalid data, local syntax
  and global-state isolation, preflight, text/path/list/alias mutations across
  STM and bibliography waits, invalid native payloads, native Unicode/comments/
  empty data, worker reuse, source disposal and retained citation rejection.
  Full local ERT passed 240/240 (exit 0, 114.57 seconds, Emacs 31.1 / Org
  9.8-pre / TeXmacs 2.1.5) before the final dependency declaration and raw-path
  consistency fixes. Final focused bibliography/package-load ERT passed 9/9.
  A header-whitespace native regression produced a type/key/field signature
  disagreement for `@ Book`. The current subset explicitly requires contiguous
  `@Type` headers and rejects that form before worker requests; its cause is
  not broadened into a claim about all native bibliography parsing.
- The first Nix check failed compilation because compile-only BibTeX dependency
  declaration did not assure runtime parser availability. The library became
  an explicit `require`; its Nix check then passed. A further Nix check of raw
  path alias checks passed, including 240/240 installed ERT in 87.62 seconds.
  The exploratory header-whitespace Nix snapshot reached 239/240 with the same
  signature mismatch; it is not the final source state. Final Nix checking
  passed (exit 0), including compilation, package-lint and installed ERT
  240/240 in 86.61 seconds, with contiguous-header preflight. The only subsequent
  ordinary edit clarified the private worker docstring's `SOURCE` as text data
  instead of STM-only data; it changed no executable behavior.
- Final reviewed/staged seven-file diff on base
  `a242eb233322a62b3f18dbf1a3ba1278e628e361` has SHA-256
  `b73fbe99d75bc77291be7ab6b71b519db164e2b293ce64d686c7eb0d7d0e55fc` for
  `git diff HEAD -- README.org org-texmacs-document.el org-texmacs-input.el org-texmacs-worker.el org-texmacs-worker.scm org-texmacs.el tests/ert/ert.el`.
  Exact-path staging was approved; no implementation changes remain unstaged.
  `git diff --check` passed. The unchanged remote USTC mirror overlay remains
  local and excluded, with hash
  `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
  GNU ELPA availability is still unverified. Commit `8e1abf743d37792c43184c84f62dd2f1dceab348` was compared with its baseline and matches the seven-file hash exactly.
- Semantic references: https://orgmode.org/manual/Citations.html,
  https://orgmode.org/manual/Bibliography-printing.html, and
  https://www.texmacs.org/tmdoc/main/styles/std/std-automatic-bib.en.html.
  In-memory parser/formatter probes are not maintained formatting regressions
  or visual citation/bibliography evidence.

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
  The later project commit `a242eb233322a62b3f18dbf1a3ba1278e628e361` was
  compared with the baseline on 2026-10-07 and matches the verified hash exactly.

## Release provenance

- v0.1.0 target: `6fd48944c238e0b627e3bc2d47e224ebf8e2892b`.
- v0.2.0 target: `c115285639f6d40e40de378b6e2da4a79f3c1cd0`.
- v0.2.1 target: `9988476b7ae98f33375d9c62ef4234890ce8b39c`.
- v0.3.0 target: `8c157d06b7a8793b0bd312e8f0c41612a3640388`.
- Local v0.3.1 annotated tag target:
  `880d4e00667907ef66985387b4865ec8d795d48d`.
- Current main HEAD observed on 2026-10-07:
  `1ed04db7d5635d4851f78bf89c2bb72e9693312a`.

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

## Native PDF node evidence (2026-10-08)

- Baseline is interactive commit 1ed04db7d5635d4851f78bf89c2bb72e9693312a;
  PDF commit db33c148dbbc4c26c6aae300c063883b06e893e6 was verified against the
  seven-file diff hash below on 2026-10-08. Installed TeXmacs is 2.1.5 in
  /nix/store/fbmq6la2pwcapsgmqp3zy6d4dbrn270a-texmacs-2.1.5/share/TeXmacs.
- User authorized targeted tm-print.scm, tm-files.scm and document-edit.scm
  reads. Native print-to-file supports direct PDF. update-document "all" uses
  delayed generation of auxiliary data; this node instead calls synchronous
  update-current-buffer three times to avoid that broader file-reading path.
- Maintained tests generate PDF from directly installed structured fields,
  preserve a public session, reject stale source exports before file writes,
  recover after injected printer errors and dispose the worker after injected
  cleanup errors. Temporary rendering files are in the private worker directory.
- Intermediate Nix checks passed with Poppler pdfinfo/pdftotext inspection:
  positive page count, literal <alpha>/Café, Heading/Table caption and resolved
  "Section 1"/"Table 1" text. Final revision passes local disjoint groups
  105/105 (47.67s), 155/155 (88.28s), 11/11 (12.81s), including all six PDF cases.
  Final Nix hit 120s at installed ERT 268/271 without observed failures; an
  explicitly authorized retry passed all seven checks, including installed
  ERT 271/271 (116.48s) and mandatory Poppler inspection. Initial cold build timed out
  at 120s; it was not counted as passing. The temporary mirror remains excluded.
- ERT runners and fixtures contain the complete reproduction, so no independent
  necessary raw probe is archived. No PDF or other binary enters GAW. Native
  font/style resources remain environmental dependencies; arbitrary custom
  styles are not sandboxed. Visual layout/general reference convergence is
  unverified, and fixed three-pass behavior is explicitly bounded.
- Reviewed seven-file diff SHA-256 on baseline 1ed04db:
  00164bbb3491e4addd74c75a0c53ab86cd8397855e659c25a572a5ae84044464, computed by
  git diff HEAD over README.org, org-texmacs-core.el, org-texmacs-session.el,
  org-texmacs-worker.scm, org-texmacs.el, tests/ert/default.nix and tests/ert/ert.el.
  Full staged diff review and diff --check pass; seven files were staged with
  explicit approval. tmp/commit.md is the reviewed message. Unchanged flake.nix overlay is
  excluded. The inspected final ERT derivation is
  /nix/store/hdwfqgf62hhqxk5y7lkk396ydxxxgiy4-org-texmacs-ert.drv.

## Committed PDF semantic regression node (2026-10-08)

- User requires only stable reproducible checks in tests. New cases extract
  Poppler text and normalize whitespace; they do not assert PDF bytes, pixels,
  coordinates or fixed pagination. Inspectors are mandatory in installed Nix
  ERT; local tests skip semantic inspection when Poppler is unavailable.
- On baseline db33c148dbbc4c26c6aae300c063883b06e893e6, first focused run with
  explicit cached Poppler exec-path passed 7/8 in 18.27s. Named/repeated and
  anonymous footnote markers/bodies pass. Citation regression fails: actual
  "Group [?, ?]. Repeat [?]." versus expected resolved [1, 2]/[1], while the
  bibliography has [1]/[2] and both selected titles. This is a reproducible
  native reference defect; retain the failing test, not question-mark expectations.
- Focused ERT 120s and Nix 180s checks are authorized for this node.
  Authorized std-automatic.ts/bib-utils.scm/plain.scm fragments confirm
  cite-arg references prefix + "-" + key and bib-label generates the same key.
  The prefix mapping was correct; no change to bibliography lowering is justified.
- A diagnostic wrapper in the maintained citation test performs native printing,
  three low-level updates, and a second print on the same owned file. Focused
  8/8 passed in 18.00s; unmodified production failed without the wrapper. This establishes
  a bounded print/update/final-print solution for this fixture, not arbitrary
  pagination convergence. User authorized worker Scheme/README repair; the
  wrapper is removed. Real production focused 8/8 passes (21.27s) after extending
  failure/recovery injection to both print phases. After tightening marker word
  boundaries, final focused 8/8 passes in 19.27s. Intermediate Nix passes all
  seven checks with installed ERT 273/273 (121.42s). Final tightened-test Nix
  passes all seven checks and installed ERT 273/273 (122.88s); all eight PDF
  cases pass with mandatory Poppler inspection. Initial sandbox daemon denial
  was resolved by approved
  execution of the same 180s command outside sandbox.
- The diagnostic wrapper was maintained inside ERT during investigation and
  then removed; the final regression and native implementation reproduce the
  finding. No independent raw artifact needs archiving; no binary enters GAW.
- Three files (README.org, org-texmacs-worker.scm, tests/ert/ert.el) were staged
  with approval; complete staged review and diff --check pass. Staged diff
  SHA-256 against db33c148dbbc4c26c6aae300c063883b06e893e6 is
  78e76d17e30ef0361e94c3b3de3717808afbb0a3bc7aced7498682f1563afbbc.
  Commit b5100a90e1f3891bf6def7ec29d7ae9aa04cea12 was compared with baseline
  db33c14 on 2026-10-08 and matches this exact three-file hash; the index is empty.
  tmp/commit.md is reviewed; only the unchanged flake.nix overlay is unstaged.
  Final ERT derivation: /nix/store/r639c3h0hx26cdkkwv9xgjg5bq8j34nj-org-texmacs-ert.drv.

## Committed bounded ox-texmacs frontend (2026-10-08)

- User adopted standard dispatcher integration after rejecting a standalone PDF
  preview command. Implementation is on b5100a90e1f3891bf6def7ec29d7ae9aa04cea12.
- Authorized Org 9.8-pre reads use the previously recorded immutable source root.
  ox.el org-export-define-backend (1235) defines menu actions with four flags;
  org-export-dispatch (7783) passes async/subtree/visible/body. annotate-info
  runs before-processing hooks before INCLUDE/macros/Babel. ox-latex/html
  entry points establish the five optional-argument convention.
- Optional ox-texmacs registers menu actions that call the owned pipeline directly.
  Non-nil standard flags/ext-plist and active regions/narrowing fail early.
  Generic string export for texmacs/derivatives is rejected through a conditional
  early hook; real ASCII export still passes. No new bibliography reader or
  publisher is introduced. Display/prompt callbacks are simulated in ERT.
- Initial focused load found a missing test parenthesis; after correction, all
  seven focused cases pass (2.63s). Final Nix passes all seven checks, native
  compilation/package-lint and installed ERT 280/280 (123.36s), including actual
  native .tm/PDF outputs, prompt context switches, stale-source rejection,
  unsupported dispatcher options and failed-view cleanup.
- Six approved staged files: .gitignore, README.org, flake.nix, org-texmacs.el,
  ox-texmacs.el, tests/ert/ert.el. Complete staged review/diff --check pass.
  SHA-256 of git diff --cached on the baseline above:
  d41f05a26d1718ec2e453019f1b3604c2bc7e8d01241a8205ef0d170694ee5ab.
  Commit be284dd292cfb0a88ae51f0e6b692f94516f0bb1 was compared with baseline
  b5100a9 on 2026-10-08: complete six-file stat and diff hash match exactly.
  Index is empty; only the unchanged raw mirror overlay remains unstaged.
  tmp/commit.md is reviewed. Nix ERT derivation is
  /nix/store/phx84ryfkmn39x16ml4n92rh7qk0vg1w-org-texmacs-ert.drv.
- flake staging contains only ./ox-texmacs.el in fileset. Its staged bytes minus
  that line equal HEAD exactly. Current raw unstaged mirror diff hash is
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc. Restoring
  the pre-fileset blob IDs and hunk positions reproduces original overlay hash
  1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54 exactly;
  the overlay content is unchanged and excluded. Checks used that temporary mirror.
- No necessary unique raw probe exists. tmp/ox-texmacs-fileset.patch is a
  regenerable staging aid; no archive snapshot is needed. Only pure text enters
  GAW. Generic publishing/export preprocessing, scoped selection, overrides and
  async behavior remain outside this node; actual GUI layout is unverified.

## Committed Org output naming/reexport node (2026-10-08)

- User adopted ox-latex's ordinary naming/overwrite convention and narrowed the
  earlier proposed atomic/backup/concurrency design scope. No new confirmation,
  backup, atomicity or target-version locking is required by this node.
- Baseline is be284dd292cfb0a88ae51f0e6b692f94516f0bb1. Authorized local Org
  9.8-pre ox.el definitions (org-export-to-file at 7495, output-file-name at
  7569) and ox-latex entry points confirm helper-based naming and ordinary
  write-region replacement after conversion. The source root is the previously
  recorded immutable bdfdqx9... site-lisp path. Generic writer adds a final text
  newline; native .tm/PDF output deliberately uses the raw byte writer instead.
- Frontend honors EXPORT_FILE_NAME/visiting stem/non-file prompt and fixed
  suffixes. Source/directory/path identities are captured before conversion;
  preparation removes output metadata from the body. Local writable regular or
  absent targets are checked twice; symlinks/directories/source aliases fail.
  A source with an unsaved visiting output suffix receives a distinct name.
- Only frontend enables the private writer's optional overwrite flag. Existing
  document-save/save-pdf and explicit-source new-file APIs still omit it; their
  exclusive/collision tests pass in the full suite. No output encoding, newline
  insertion, formatting annotations or file handlers are introduced.
- Focused ERT passes 11/11 (5.32s). Final Nix passes all seven checks, native
  compilation/package-lint and installed ERT 284/284 (125.71s), using unchanged
  temporary mirror diff dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
  ERT derivation: /nix/store/807vw3y07rkphazjlcpma0fayy4v623q-org-texmacs-ert.drv.
- Four new focused cases plus updated original cases cover real .tm/PDF repeats,
  keyword priority/body removal, exact unibyte output with coding/annotations
  configured, prompt buffer switching, source/target preflight, old-output
  preservation on renderer/stale-source errors and a deterministic partial-write
  error. Filesystem failure can leave partial overwritten output; no stronger
  guarantee is claimed. Tests use owned isolated temporary directories.
- Five approved staged files: README.org, org-texmacs-context.el,
  org-texmacs-session.el, ox-texmacs.el and tests/ert/ert.el. Full staged review
  and diff --check pass. git diff --cached SHA-256 against the baseline above:
  846a14267176678abb8ebda9c7097c12076e55563a8235ec0beb323d574de410.
  Commit b4ee215224578577a3235f8954020baf74e585af was compared with be284dd
  on 2026-10-08: complete five-file stat and diff hash match exactly. The project
  index is empty; only the temporary mirror overlay remains unstaged.
  tmp/commit.md is reviewed; only the unchanged mirror overlay remains unstaged.
- No independent necessary raw temporary evidence qualifies for archive:
  fixtures/reproduction live in ERT, and no binary output enters GAW.

## Subtree export node (2026-10-08, committed)

- User selected synchronous subtree export/configuration/dependencies while
  postponing generic Org API adaptation. Implementation/verification baseline
  is b4ee215224578577a3235f8954020baf74e585af. Commit
  ee3e028fb829d508333fda40c705d811f4b2583e has exactly the six reviewed files;
  its complete diff matches the SHA-256 below. Index was empty at that
  verification, before region implementation/staging.
- Authorized local Org 9.8-pre reads: ox.el subtree-options/get-environment/
  footnote dependency logic and ox-latex entry points; org.el heading and property
  helpers including >1MiB-file targeted fragments. Subtree option priority is
  global < file < EXPORT_*, with root title fallback and selective inheritance.
  org-end-of-meta-data advances beyond root heading/planning/drawer, so the
  structured implementation omits them while retaining child body/headlines.
- Source/preparation APIs gain optional third integer subtree-position; original
  source stays unnarrowed. The complete owned AST supplies configuration and
  used footnote/bibliography data, then emits selected body plus required notes.
  Plain target resolution is limited to emitted AST; no external ID database.
- Masking/discovery remains source-based; clipping occurs before structural
  validation/native parsing so unrelated body/islands do not trigger worker calls.
  Earlier source-position dependencies must be reordered to AST traversal and
  restricted to their paragraph bounds; that regression failed before the fix.
  Synthetic paragraphs for restored inline definitions carry already parsed data.
- Initial focused run passed 4/6; failures were span-order handling and a citation
  fixture starting with [fn:r], which Org correctly interpreted as a definition.
  After fixes/fixture correction and a date/filter case, final subtree 7/7 passes
  (9.53s). Existing backend 11/11 passes (4.65s). CITE_EXPORT is explicitly rejected
  as unsupported processor configuration, including outside selected body.
- Final Nix passes all seven checks, native compilation/package-lint and installed
  ERT 291/291 (132.40s), using the unchanged temporary mirror overlay:
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
  ERT derivation: /nix/store/7i3b2rvh0rz1ls6wqnjnfxp7hhpqv0i4-org-texmacs-ert.drv.
- Maintained tests cover title/author/date/options/filter priority, selective
  inheritance, immutable prepared input, point/marker preservation, external
  notes/STM order, invalid scope/links, explicit bibliography/resource base,
  menu .tm/PDF/byte buffer and selection/property-setting waits. Prompt/display
  are simulated; native consumers are real. No pixel or pagination goldens.
- Six approved staged files: README.org, org-texmacs-context.el,
  org-texmacs-document.el, org-texmacs.el, ox-texmacs.el and tests/ert/ert.el.
  Full staged review (split by path to avoid truncated output) and diff --check
  pass. SHA-256 of git diff --cached against baseline above:
  3be6de01e224286021f2b3361f14098efae89208ad72db0660fad81a73e73090.
  tmp/commit.md is reviewed; only the unchanged mirror overlay remains unstaged.
- No independent necessary temporary evidence qualifies for archive. Tests
  retain complete reproduction; binary PDFs/bytecode remain outside GAW.

## Region export node (2026-10-08, committed)

- Baseline ee3e028fb829d508333fda40c705d811f4b2583e is verified against the
  subtree six-file SHA-256 3be6de01... above. User requested continuing.
  Commit 7e6b4e001603a223933277d2704018877b86bada has exactly the six reviewed
  files; its full diff matches 22765b0b... below. Index is empty at verification.
  Per-node targeted local ox.el/org.el reads and repeated region/subtree/backend
  focused 120s / Nix 180s checks were authorized.
- Org 9.8-pre ox.el org-export-as (3594) narrows to region before subtree;
  annotate-info still receives subtreep and environment applies subtree options.
  Frontend captures both before prompts and keeps subtree naming. Third integer
  subtree argument stays compatible; optional fourth REGION is validated/copied.
- Full snapshot AST supplies global options/declarations/definitions. Private
  narrowed parse supplies exact body; selected definitions replace full-AST
  identities to avoid duplicate imports. Only emitted body/dependency STM runs;
  truncated intersecting islands fail before workers. Source edits still reject.
- First six focused cases passed four; fixtures needed headings to terminate
  separate footnotes before selected paragraphs. Final region 7/7 (14.17s),
  subtree 7/7 (10.79s) and backend 11/11 (5.47s) pass. Cases cover partial text,
  global context, selected/external notes, complete blocks/headings/scoped links,
  explicit bibliography/resource base, invalid ranges/islands, native menu outputs
  and frozen selection/source state. No pagination/pixel/coordinate goldens.
- Nix first failed sandbox-daemon access; same command was escalated. Compilation
  rejected a new 82-column docstring; after wrapping, final same 180s command
  passes all seven checks, compilation/package-lint and installed ERT 298/298
  (162.693114s). ERT derivation:
  /nix/store/lv55dh5b2pkdv9nzcq8rad9kk676ad9y-org-texmacs-ert.drv.
  Remote mirror overlay remains excluded/unchanged at raw diff SHA-256
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
- Six approved staged files: README.org, org-texmacs-context.el,
  org-texmacs-document.el, org-texmacs.el, ox-texmacs.el and tests/ert/ert.el.
  Complete staged review split by path and diff --check pass. Entire staged
  diff SHA-256 on ee3e028:
  22765b0bf802059c2edb49fb3f8a549751b1240c17b43cd8bae419eb4827da58.
  No implementation remains unstaged; tmp/commit.md is reviewed. Ordinary commit
  remains user's action. Generic API/visibility/async/extra overrides stay deferred.
- No unique temporary evidence requires archive: maintained ERT retains complete
  reproduction; draft is regenerable. PDFs/bytecode never enter GAW. Actual GUI
  and visual pagination remain unverified.

## Restricted external configuration (2026-10-08, committed)

- Implementation baseline is 7e6b4e001603a223933277d2704018877b86bada; its
  region diff was verified against 22765b0b... on ee3e028. User chose restricted
  ext-plist after reviewing body-only's distinct fragment/consumer boundary.
  Commit d71204d204a03b30491d5cdb2bd05d59dacd71a3 has exactly the five reviewed
  files; full diff matches 145a3237... below. Index is empty at verification;
  only the user's temporary mirror overlay is unstaged. No new tests were run.
- Authorized targeted Org option-helper reads confirm get-environment priority
  global < external < file < subtree. ox.el get-inbuffer-options (1591) parses
  metadata with keyword object grammar, as does get-global-options (1696).
  This adapter accepts only raw string/nil metadata, typed existing context
  policies and unique supported keys; prepared AST metadata is not an external
  option value. No output paths/styles/hooks/parser/bibliography fields are added.
- Five explicit source adapters add optional fifth EXT-PLIST. Frontend retains
  its standard fifth argument and captures a copy before prompts. Private
  context parses/merges owned values before source/subtree options; metadata
  presence is retained without file keywords. Pure lowering reads only INFO.
  Input mutation across prompts/native waits affects only later conversions.
- Final overrides focused 6/6 (7.328611s), backend 11/11 (5.344581s), subtree
  7/7 (10.066498s), region 7/7 (12.449187s) pass. Cases cover priority, rich/nil
  metadata, invalid/duplicate/cyclic values before prompts/workers, dependency
  filtering, real native menu consumers, region state and mutable caller data.
  Only maintained reproducible structure/text/byte/contracts are asserted.
- Focused 120s groups and repeated Nix 240s checks were authorized for this node.
  Initial Nix compilation rejected two 81-column docstrings; wrapped them.
  Nix then passed all seven checks and ERT 304/304 (169.005840s). One mutable
  quoted test list was replaced with fresh allocation for safe same-process
  reruns. Final focused 6/6 and final Nix pass: two changed checks rerun, five
  previous passing checks reused; installed ERT 304/304 (169.374465s).
  Final ERT derivation:
  /nix/store/rbzwkg1d4ks7zx0rwm686mrbpiv10kiq-org-texmacs-ert.drv.
- Five approved staged files: README.org, org-texmacs-context.el,
  org-texmacs.el, ox-texmacs.el and tests/ert/ert.el. Complete staged review split
  by path and diff --check pass. Entire staged diff SHA-256 on baseline 7e6b4e0:
  145a3237df23501289289bbfe84554353dfc8d0147d7d2787ff090bb953b83a6.
  No implementation is unstaged. tmp/commit.md is reviewed; ordinary commit is
  user's action. Mirror overlay is unchanged/excluded at raw SHA-256
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
- No unique necessary temporary artifact needs archive. Tests retain complete
  reproduction; draft is regenerable. Only pure text enters GAW, never PDFs or
  bytecode. GUI/visual pagination remain unverified; no fragment support is claimed.

## Narrowed source export (2026-10-08, committed)

- Baseline d71204d204a03b30491d5cdb2bd05d59dacd71a3 matches prior verified
  five-file hash 145a3237...; user explicitly selected narrowing. Targeted local
  Org selection/config/naming/heading reads and repeated focused 120s groups /
  Nix 240s checks were authorized for this node.
  Commit 82552db77d2b01fa832fc06948f57e1cc5e80d81 has exactly the six reviewed
  files and matches fdeb09f1... below. Index is empty at commit verification;
  only the user's local/uncommitted remote mirror configuration remains dirty.
- Org ox.el (3627) starts within save-restriction and applies region before subtree;
  get-inbuffer-options ignores narrowing for configuration. Output naming helper
  (7569) scans accessible keywords and subtree property. org-back-to-heading
  (20591) respects current accessible context. Adapter uses full private copies
  so hidden source configuration/headings remain available without live parsing.
- Captured narrowing is outer body bound; region must fit and wins, otherwise
  subtree body intersection applies. Brief synchronous full-text read restores
  source restriction before parsing/waits. Core checks initial bounds after native
  waits and consumer. Empty narrowing works; explicit region remains nonempty.
- Private full heading/naming copy inherits captured heading/property/location
  context. Filename is bound only during lookup, not retained as visiting identity
  at disposal. Naming's read-file prompt is deferred to original source outside
  private bindings. Prompt changes are rejected without undoing another caller.
- Final focused narrowing 7/7 (10.092574s); backend 11/11 (5.509993s),
  serialization 16/16 (17.769029s), subtree 7/7 (9.890787s), region 7/7
  (12.379803s), overrides 6/6 (7.497417s) pass. Maintained cases cover source
  properties/point/mark/restriction, full metadata and owned note/bibliography/STM
  dependencies, scope intersections/priority, empty scope/preflight, hidden naming,
  native output, original prompt context and changed bounds/hidden text before write.
- First Nix full ERT was 310/311 (177.183238s): replacing old rejection with
  a success assertion missed the existing normalized trailing newline space/concat.
  Corrected expected body to (document (concat "irst Second ")). Final Nix on
  final private filename binding passes all seven checks, compilation/package-lint
  and installed ERT 311/311 (176.947172s). Final ERT derivation:
  /nix/store/2wpkb8m4zz6g4zb4ph5qjk7mp9n45c3x-org-texmacs-ert.drv.
- Six approved staged files: README.org, org-texmacs-context.el,
  org-texmacs-document.el, org-texmacs.el, ox-texmacs.el and tests/ert/ert.el.
  Complete staged review split by path and diff --check pass. Entire staged
  diff SHA-256 on baseline d71204d:
  fdeb09f1bd80199c367eb7c605c2d68ec5383dad1c0bdf616fe9b3ccbd05c39d.
  tmp/commit.md is reviewed. No implementation is unstaged; remote mirror overlay
  remains excluded/unchanged at raw SHA-256
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
- No unique temporary evidence needs archive; ERT retains complete reproduction
  and draft is regenerable. Only pure text enters GAW; PDFs/bytecode do not.
  Native visual layout/pagination and GUI remain unverified. Visible-only,
  body-only/async/generic APIs remain separate or deferred.

## v0.4.0 release preparation (2026-10-08, verified/staged)

- Baseline 82552db77d2b01fa832fc06948f57e1cc5e80d81 is verified against the
  narrowing six-file SHA-256 fdeb09f1... on d71204d. User explicitly selected
  v0.4.0 release preparation with current bounded document/native export scope.
  Nineteen feature/fix commits follow the local v0.3.1 tag. Ordinary commit/tag/
  publication remain pending; this record is preparation evidence, not release.
- Changed package header and Nix version 0.3.1 to 0.4.0, corrected source-buffer
  Commentary and added necessary README overview/version/compatibility wording.
  Runtime feature code, dependencies and lockfile are unchanged.
- Authorized exact repeated timeout 240s nix flake check --no-write-lock-file
  path:/home/lingyu/Projects/org-texmacs passes all seven checks, package build,
  compilation/package-lint and installed ERT 311/311 (155.043573s), with README
  loading/install examples. ERT derivation:
  /nix/store/cwq33avp24xmac508mz7gkb8gmjhfw8y-org-texmacs-ert.drv.
  Package derivation:
  /nix/store/hjcwyjblf5r0jrfyqjpjalqhhzpz6g66-emacs-org-texmacs-0.4.0.drv.
- Three approved staged files: README.org, org-texmacs.el, flake.nix (version-only
  patch applied to index with approval). Staged flake equals baseline bytes with
  just that line replaced. Complete staged review/diff --check pass. Entire
  staged diff SHA-256 on 82552db:
  84b212a7b1b9c74e1309067a10d0a932ed70b93b0f3b541fba40f83ff906ce33.
  No release work remains unstaged. Current raw unstaged mirror diff SHA-256:
  2af6574fe8302fa7a5e64d3e93e8955cf7c36f0a4c6c2f135a2edffe8b65032a.
  Restoring pre-release version context and index blob IDs reconstructs old raw
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc exactly.
  Thus mirror content is unchanged and excluded despite the new raw diff hash.
- tmp/commit.md, tmp/release-v0.4.0.md and tmp/release-version.patch are reviewed
  regenerable preparation artifacts; no unique archive evidence is needed.
  They are not ordinary staged release files or binary GAW data. Draft explicitly
  records overwrite/new-file API policy, explicit bibliography snapshots and
  deferred generic/visibility/fragment/async/preprocessing scope.
- Validation is conditional on local remote-mirror config/cached dependencies;
  it does not prove original GNU ELPA recovery or other platform/GUI/pagination
  support. Native TeXmacs file version remains independent of package version.

## Body-only assessment after region commit (2026-10-08)

- User authorized targeted installed ox.el/ox-latex.el/ox-html.el template reads.
  ox.el (3658-3683) always applies inner-template and skips outer template when
  body-only. ox-latex.el org-latex-template (2225) owns metadata/title/TOC and
  document wrapper; ox-html.el inner-template (2284) owns TOC/footnotes, while
  template (2297) owns HTML wrapper/title. Thus TOC retention is backend-specific.
- Project document lowering (1404) prepends metadata and TOC to native body;
  worker file-document (163) adds TeXmacs version/style/body/initial wrapper.
  Current complete serializer/PDF contracts define no standalone fragment.
  Body-only therefore needs explicit format/consumer semantics, not a blind
  title-suppression flag. User selected restricted ext-plist as the next node.

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
