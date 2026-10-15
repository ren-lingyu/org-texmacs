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

- The explicit-source export adapter revision matches its verified
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
  the explicit-source export adapter revision has SHA-256
  `3f3a1f61d1f0b24ad984c6723ada568ec12a5b8015a9de968200ac32e9878d51`
  for `git diff --cached -- README.org org-texmacs.el tests/ert/ert.el`.
  Full staged review and git diff --cached --check pass. No implementation is
  unstaged at that review. The interactive export revision
  was compared with its baseline on 2026-10-07 and matches this exact diff hash.
  Current memory has been condensed to active state, boundaries and next actions;
  superseded completion records remain in project/evidence and GAW history.
- Test byte files/buffers are regenerable maintained fixtures, not unique raw
  evidence. No necessary new archive snapshot is selected; only pure text enters
  GAW. Interactive bibliography reads and generic backend/dispatcher are not adopted.

## Explicit-source export adapter evidence

- The explicit new-file saving revision matches the earlier
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
  the explicit new-file saving revision has SHA-256
  `48f06c5326ad5140f291110c7a05cabffba941c1c2c1e87cbac2aa6c0101f163`
  for `git diff --cached -- README.org org-texmacs-session.el org-texmacs.el tests/ert/ert.el`.
  Full staged review and git diff --cached --check pass. No implementation
  remained unstaged at that review. The explicit-source export adapter revision
  was checked on 2026-10-07 and matches this exact diff hash; the overlay remains
  unchanged at its previously recorded hash.
- No independent necessary temporary evidence artifact was created. All generated
  output is regenerable in maintained tests and confined to isolated directories.
  Archive selection requires no new snapshot; only pure text enters GAW.

## Explicit new-file saving evidence

- The native serialization revision matches its
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
  the native serialization revision has SHA-256
  `866da9c3b5a8a874950bf0b27a762f3f34e7b09339e1f9b9c02e13080cf2cce4`
  for `git diff --cached -- README.org org-texmacs-session.el tests/ert/ert.el`.
  Full staged review and git diff --cached --check pass. No implementation is
  unstaged at that review. The explicit new-file saving revision
  was checked on 2026-10-07 and matches this exact diff hash. The overlay remains
  unchanged at its previously recorded hash.
- Test outputs are regenerable temporary fixtures with maintained inputs/assertions.
  No independent necessary raw artifact requires a new archive; only pure text
  enters GAW. The temporary mirror overlay stays excluded from commits/pushes.

## Complete native serialization evidence

- The named-table and caption revision matches the
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
  the named-table and caption revision has SHA-256
  `d7449b539a743bd447d9eefac0d3e92e5091c87b6809099619552d453c9195d7`
  for `git diff --cached -- README.org org-texmacs-core.el org-texmacs-session.el org-texmacs-worker.scm tests/ert/ert.el`.
  Full staged review and git diff --cached --check passed. No implementation
  remained unstaged at that review. Commit
  the native serialization revision was compared with its baseline on
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
  the citation and plain bibliography revision has SHA-256
  `52de57a9928f1afc4001bb9d902ed56eef40ac8206a33006a0b7fd0893e68c45`
  for `git diff --cached -- README.org org-texmacs-context.el org-texmacs-document.el org-texmacs-input.el tests/ert/ert.el`.
  `git diff --cached --check` passes; no implementation remains unstaged.
  The overlay stays unstaged and unchanged at the hash recorded below.
  The named-table and caption revision was checked on
  2026-10-07 and matches that diff hash exactly;
  displayed numbers, caption layout and pagination are unverified.
- No necessary new raw temporary artifact was created. Source observations are
  recorded here, and adopted semantics have maintained ERT. The previous commit
  draft duplicated the now-committed citation message; its replacement is a
  regenerable draft from the reviewed staged diff. Archive selection requires no new
  snapshot. No binary, overlay or installed-source copy is added to GAW.

## Default citation/plain bibliography node evidence

- The owned bibliography foundation revision exactly matches
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
  the citation and plain bibliography revision was checked on 2026-10-07 and
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
  `archive/2026-10-06T17-35-50Z--a242eb2/`. Its manifest path history locates the
  archive-only GAW checkpoint introducing the snapshot, with sole additional
  project parent
  the named-footnote revision. Bytes/digests and unchanged HEAD
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
  the named-footnote revision has SHA-256
  `b73fbe99d75bc77291be7ab6b71b519db164e2b293ce64d686c7eb0d7d0e55fc` for
  `git diff HEAD -- README.org org-texmacs-document.el org-texmacs-input.el org-texmacs-worker.el org-texmacs-worker.scm org-texmacs.el tests/ert/ert.el`.
  Exact-path staging was approved; no implementation changes remain unstaged.
  `git diff --check` passed. The unchanged remote USTC mirror overlay remains
  local and excluded, with hash
  `1a5aa529470c6f02f3137da2a5213dc73855b9df1eada87c195563a689bb5d54`.
  GNU ELPA availability is still unverified. The owned bibliography foundation revision was compared with its baseline and matches the seven-file hash exactly.
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
  files in `archive/2026-10-06T16-59-25Z--77a2888/`. The archive-only checkpoint
  introducing its manifest records the captured state through its sole additional
  project parent
  the local file-link semantics revision. Byte copies, sizes and hashes match;
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
  the local file-link semantics revision: SHA-256
  `82c13615c352889dbedede08505518eacb09db78fa1b739c5105448db0da0cd5` for
  `git diff HEAD -- README.org org-texmacs-context.el org-texmacs-document.el tests/ert/ert.el`.
  The complete staged diff matches that hash exactly; `git diff --check` passed.
  The later named-footnote revision was
  compared with the baseline on 2026-10-07 and matches the verified hash exactly.

## Release provenance

- v0.1.0 target: the v0.1.0 parsing foundation revision.
- v0.2.0 target: the v0.2.0 body and session revision.
- v0.2.1 target: the v0.2.1 interface hardening revision.
- v0.3.0 target: the v0.3.0 structured-document release revision.
- Local v0.3.1 annotated tag target:
  the v0.3.1 release revision.
- Current main HEAD observed on 2026-10-07:
  the interactive export revision.

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
  the v0.3.1 release revision. SHA-256 of
  `git diff HEAD -- README.org org-texmacs-context.el org-texmacs-document.el org-texmacs.el tests/ert/ert.el`
  was `07656ff6745c9c00d106faf48689e233fc183d13e5bb4f2036cafd16fc340555`.
  The later local-link resolution revision was
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
The inspected installation supplied Emacs 31.1 and Org 9.8-pre. Source-relative
filenames, definitions and content hashes below identify the observations.

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

The verified six-file diff on the baseline local-link resolution revision
had SHA-256 `3661d1b73013c08f1353f2cf29336486021210211eaa70cbbf5fcd87d2e0c768`
using `git diff HEAD -- README.org org-texmacs-document.el org-texmacs-input.el org-texmacs-source.el org-texmacs.el tests/ert/ert.el`.
The later source-location snapshot revision was checked:
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
availability of GNU ELPA. The installed package version was org-texmacs 0.3.1.

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
  `9b075c37048032592779f9ae623e8b2f74e89c30ad4512c3fd843a64fef28563`, from
  that installed TeXmacs source tree.
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
  archive-only checkpoint introducing the snapshot is located through its manifest
  path history. Its sole additional project parent is
  the source-location snapshot revision. Its
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
  The installed package version was org-texmacs 0.3.1.
- The verified five-file worktree diff on baseline
  the source-location snapshot revision has SHA-256
  `9a4808d6615612c728ba1b249929c2ff1db2e5c3cbf9aa5dccc844733ab0f913` using
  `git diff HEAD -- README.org org-texmacs-document.el org-texmacs-session.el org-texmacs.el tests/ert/ert.el`.
  The later local file-link semantics revision was compared with
  that baseline and its five-file diff matches this hash exactly.
  GUI navigation, file search/remote/tilde targets and broader
  filename escaping remain unverified or explicitly unsupported.

## Native PDF node evidence (2026-10-08)

- Baseline is the interactive export revision;
  The native PDF consumer revision was verified against the
  seven-file diff hash below on 2026-10-08. Installed TeXmacs was 2.1.5.
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
- Reviewed seven-file diff SHA-256 on the baseline interactive export revision:
  00164bbb3491e4addd74c75a0c53ab86cd8397855e659c25a572a5ae84044464, computed by
  git diff HEAD over README.org, org-texmacs-core.el, org-texmacs-session.el,
  org-texmacs-worker.scm, org-texmacs.el, tests/ert/default.nix and tests/ert/ert.el.
  Full staged diff review and diff --check pass; seven files were staged with
  explicit approval. tmp/commit.md is the reviewed message. Unchanged flake.nix overlay is
  excluded.

## Committed PDF semantic regression node (2026-10-08)

- User requires only stable reproducible checks in tests. New cases extract
  Poppler text and normalize whitespace; they do not assert PDF bytes, pixels,
  coordinates or fixed pagination. Inspectors are mandatory in installed Nix
  ERT; local tests skip semantic inspection when Poppler is unavailable.
- On the baseline native PDF consumer revision, first focused run with
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
  SHA-256 against the native PDF consumer revision is
  78e76d17e30ef0361e94c3b3de3717808afbb0a3bc7aced7498682f1563afbbc.
  the PDF semantic regression and citation repair revision was compared with baseline
  the native PDF consumer revision on 2026-10-08 and matches this exact three-file hash; the index is empty.
  tmp/commit.md is reviewed; only the unchanged flake.nix overlay is unstaged.

## Committed bounded ox-texmacs frontend (2026-10-08)

- User adopted standard dispatcher integration after rejecting a standalone PDF
  preview command. Implementation is on the PDF semantic regression and citation repair revision.
- Authorized reads used the Org 9.8-pre installation described in the
  source/resource context evidence above.
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
  the bounded ox-texmacs frontend revision was compared with baseline
  the PDF semantic regression and citation repair revision on 2026-10-08: complete six-file stat and diff hash match exactly.
  Index is empty; only the unchanged raw mirror overlay remains unstaged.
  tmp/commit.md is reviewed.
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
- Baseline is the bounded ox-texmacs frontend revision. Authorized local Org
  9.8-pre ox.el definitions (org-export-to-file at 7495, output-file-name at
  7569) and ox-latex entry points confirm helper-based naming and ordinary
  write-region replacement after conversion. These observations use that same
  recorded Org installation. Generic writer adds a final text
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
  the Org output naming and repeat-export revision was compared with the bounded ox-texmacs frontend revision
  on 2026-10-08: complete five-file stat and diff hash match exactly. The project
  index is empty; only the temporary mirror overlay remains unstaged.
  tmp/commit.md is reviewed; only the unchanged mirror overlay remains unstaged.
- No independent necessary raw temporary evidence qualifies for archive:
  fixtures/reproduction live in ERT, and no binary output enters GAW.

## Subtree export node (2026-10-08, committed)

- User selected synchronous subtree export/configuration/dependencies while
  postponing generic Org API adaptation. Implementation/verification baseline
  is the Org output naming and repeat-export revision. Commit
  the subtree export revision has exactly the six reviewed files;
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

- Baseline the subtree export revision is verified against the
  subtree six-file SHA-256 3be6de01... above. User requested continuing.
  the region export revision has exactly the six reviewed
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
  (162.693114s).
  Remote mirror overlay remains excluded/unchanged at raw diff SHA-256
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
- Six approved staged files: README.org, org-texmacs-context.el,
  org-texmacs-document.el, org-texmacs.el, ox-texmacs.el and tests/ert/ert.el.
  Complete staged review split by path and diff --check pass. Entire staged
  diff SHA-256 on the subtree export revision:
  22765b0bf802059c2edb49fb3f8a549751b1240c17b43cd8bae419eb4827da58.
  No implementation remains unstaged; tmp/commit.md is reviewed. Ordinary commit
  remains user's action. Generic API/visibility/async/extra overrides stay deferred.
- No unique temporary evidence requires archive: maintained ERT retains complete
  reproduction; draft is regenerable. PDFs/bytecode never enter GAW. Actual GUI
  and visual pagination remain unverified.

## Restricted external configuration (2026-10-08, committed)

- Implementation baseline is the region export revision; its
  region diff was verified against 22765b0b... on the subtree export revision. User chose restricted
  ext-plist after reviewing body-only's distinct fragment/consumer boundary.
  the external configuration override revision has exactly the five reviewed
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
- Five approved staged files: README.org, org-texmacs-context.el,
  org-texmacs.el, ox-texmacs.el and tests/ert/ert.el. Complete staged review split
  by path and diff --check pass. Entire staged diff SHA-256 on the baseline region export revision:
  145a3237df23501289289bbfe84554353dfc8d0147d7d2787ff090bb953b83a6.
  No implementation is unstaged. tmp/commit.md is reviewed; ordinary commit is
  user's action. Mirror overlay is unchanged/excluded at raw SHA-256
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
- No unique necessary temporary artifact needs archive. Tests retain complete
  reproduction; draft is regenerable. Only pure text enters GAW, never PDFs or
  bytecode. GUI/visual pagination remain unverified; no fragment support is claimed.

## Narrowed source export (2026-10-08, committed)

- Baseline the external configuration override revision matches prior verified
  five-file hash 145a3237...; user explicitly selected narrowing. Targeted local
  Org selection/config/naming/heading reads and repeated focused 120s groups /
  Nix 240s checks were authorized for this node.
  the narrowed-source export revision has exactly the six reviewed
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
  and installed ERT 311/311 (176.947172s).
- Six approved staged files: README.org, org-texmacs-context.el,
  org-texmacs-document.el, org-texmacs.el, ox-texmacs.el and tests/ert/ert.el.
  Complete staged review split by path and diff --check pass. Entire staged
  diff SHA-256 on the baseline external configuration override revision:
  fdeb09f1bd80199c367eb7c605c2d68ec5383dad1c0bdf616fe9b3ccbd05c39d.
  tmp/commit.md is reviewed. No implementation is unstaged; remote mirror overlay
  remains excluded/unchanged at raw SHA-256
  dc388c27960a4421ab4211f207ee3542e5e4642c9f4cdf85a4bbdace30f66bdc.
- No unique temporary evidence needs archive; ERT retains complete reproduction
  and draft is regenerable. Only pure text enters GAW; PDFs/bytecode do not.
  Native visual layout/pagination and GUI remain unverified. Visible-only,
  body-only/async/generic APIs remain separate or deferred.

## v0.4.0 release preparation (2026-10-08, committed; user review pending)

- Baseline the narrowed-source export revision is verified against the
  narrowing six-file SHA-256 fdeb09f1... on the external configuration override revision. User explicitly selected
  v0.4.0 release preparation with current bounded document/native export scope.
  Nineteen feature/fix commits follow the local v0.3.1 tag. Preparation commit
  the v0.4.0 release preparation revision has exactly the three reviewed files
  and matches 84b212a7... below. Index is empty; only the mirror overlay is dirty.
  Exact local `git tag --list v0.4.0` returned no tag. User explicitly holds
  tag/publication for their review. No new tests or external publication lookup
  were run. This is preparation/commit evidence, not a released-version claim.
- Changed package header and Nix version 0.3.1 to 0.4.0, corrected source-buffer
  Commentary and added necessary README overview/version/compatibility wording.
  Runtime feature code, dependencies and lockfile are unchanged.
- Authorized exact repeated timeout 240s nix flake check --no-write-lock-file
  path:/home/lingyu/Projects/org-texmacs passes all seven checks, package build,
  compilation/package-lint and installed ERT 311/311 (155.043573s), with README
  loading/install examples. The checked package version was org-texmacs 0.4.0.
- Three approved staged files: README.org, org-texmacs.el, flake.nix (version-only
  patch applied to index with approval). Staged flake equals baseline bytes with
  just that line replaced. Complete staged review/diff --check pass. Entire
  staged diff SHA-256 on the narrowed-source export revision:
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

## INBOX v0.4.0 ecosystem review assessment (2026-10-09, read-only)

- User note distinguishes interface isolation from consumption of extensions,
  retains explicit BibTeX text snapshots/native formatting, and defers broad
  preprocessing architecture until after bounded release. The third-party
  repositories named in the note were not read (outside project authorization),
  and no tests/builds/joint run were requested or executed in this assessment.
  Reviewed INBOX.md SHA-256:
  be6bda83516009702d18722e2d680a48876e55ff22eac5e54518e6a893eb95ed.
- User supplied https://github.com/ren-lingyu/org-texmacs/issues/1. GitHub
  connector fetched the full issue after public browser/API fetches failed.
  Title: design: reconsider Org preprocessing and export integration boundaries.
  It was open, with zero comments, created/updated 2026-10-08T16:37:25Z.
  Body targets the v0.4.0 release preparation revision and explicitly distinguishes static review from
  joint integration testing, makes this nonblocking for v0.4.0, and selects no
  mandatory full exporter/independent preparation approach. No remote writes
  were performed. The issue is the design discussion reference, not test proof.
- Local ox-texmacs.el guard (190) rejects only texmacs-derived generic calls.
  Maintained ERT generic-preprocessing-guard case verifies rejection before
  INCLUDE/Babel and an unrelated ASCII export; it does not prove HTML with all
  three extensions loaded. Third-party API behavior remains attributed to user
  note, not independently validated or a universal compatibility guarantee.
- README's document/source and dispatcher sections already state no hooks/
  filters, INCLUDE expansion or global bibliography lookup. Bibliography source
  snapshot copies explicit texts; private preparation calls restricted Org parser.
  context-merge-options temporarily rebinds org-collect-keywords only within that
  call. No persistent override of standard export functions was found in scope.
- Bibliography-plan accepts ASCII letters/digits/hyphen in keys and checks exact
  entries, raising Unresolved citation key when missing. UUID is not inherently
  invalid syntax; lack of UUID-to-BibTeX-key filter consumption is the stated gap.
- AST-first permits investigation of private source preprocessing and AST filters
  while preserving ownership/provenance. This is later unresolved design, not a
  release refactor authorization. Optional stable HTML hook/advice smoke test is
  a proposal only. Preserve release review hold and tentative ELPA observation.
- Note content has been distilled into active memory; raw INBOX is untouched and
  no extra archive copy is needed. Initially these were working-memory updates
  only; the subsequent authorized HTML test/environment node now checkpoints
  this assessment together with its verified results.

## HTML composition supplement and ELPA checks (2026-10-09, committed/released)

- Baseline the v0.4.0 release preparation revision is unchanged. Commit
  the final HTML coexistence regression revision has exactly the one reviewed test
  file and matches 4461f4ad... below. It is the verified v0.4.0 release target. User
  authorized the finite HTML composition test, repeated exact backend focused
  timeout 120s and no-overlay Nix timeout 240s checks. Production code/README/
  version are unchanged; only one 61-line ERT case is added.
- Case uses real HTML exporter with controlled private-copy preprocessing hook,
  around-advice on org-export-expand-include-keyword and parse-tree filter.
  All three execution markers and hook/filter output effects are asserted,
  with source-state preservation,
  no native worker request, unconditional advice cleanup and restored baseline
  output. It is not actual joint loading/testing of the named external packages.
- Focused backend passes 12/12 (5.353570s); new test 0.005854s. Nix passes all
  checks without overlay: two changed checks run, five prior results reused;
  installed ERT 312/312 (157.819934s), package/compilation/package-lint successful.
  The checked package version was org-texmacs 0.4.0.
  No fresh upstream dependency download is established by cache-backed success.
- User reported temporary removal of local-only remote mirror overlay and apparent
  ELPA recovery. flake.nix matches HEAD; workaround is absent. Earlier mirrored
  validation remains historical evidence. User separately authorized exactly two
  HEAD probes: timeout 30s curl -q --head --fail --location --max-time 20
  --proto '=https' --proto-redir '=https', against
  https://elpa.gnu.org/packages/ and https://elpa.gnu.org/packages/org-9.8.8.tar.
  Both exited 28 with Connection timed out after 20000 milliseconds, no response
  headers/status. Run outside host sandbox; no credentials, body download or file
  writes. No retries. Endpoint recovery remains unconfirmed from agent environment;
  this does not prove a global outage or disprove user's observation.
- Exact-path staging of tests/ert/ert.el was approved. Complete staged review and
  diff --check pass. Entire one-file staged diff SHA-256 on the v0.4.0 release preparation revision:
  4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
  No ordinary project changes are unstaged. tmp/commit.md is reviewed; user makes
  ordinary commit and initially continued review. Later user commit/tag/release
  completion ended that hold, as verified below.
- Earlier release-note draft was a preparation artifact; published release
  notes now supersede it. Updating that old draft is not a remaining release task.
  No raw archive is needed: maintained test and these compact records retain
  complete reproduction/results. INBOX unchanged; only pure text enters GAW.

## v0.4.0 publication verification (2026-10-09)

- User reported final commit/tag/GitHub publication. Read-only Git shows HEAD
  the final HTML coexistence regression revision, one 61-line tests/ert/ert.el addition;
  full one-file diff on the v0.4.0 release preparation revision exactly matches previously verified SHA-256
  4461f4ad5b984ebf83b714b3f5fd0241f09571fb7a4cf50723af1efb3cff42b5.
  Ordinary worktree/index are clean. No new tests were run for identity checks.
- Local v0.4.0 is annotated tag object
  feaf8c4ef501d50aa595090a0fa312c855071527; peel resolves to HEAD above.
  GitHub GET git/ref/tags/v0.4.0 returns the same object/type=tag, establishing
  exact local/remote tag identity. Local tag message contains a PGP signature
  block; cryptographic verification was not attempted and is not claimed.
- GitHub connector GET releases/tags/v0.4.0 confirms release ID 407092424,
  name/tag v0.4.0, draft=false, prerelease=false, immutable=false,
  published_at/updated_at 2026-10-08T17:27:12Z (2026-10-09 01:27:12 +08).
  URL https://github.com/ren-lingyu/org-texmacs/releases/tag/v0.4.0.
  target_commitish=main was not used as sole commit proof; exact tag object was
  separately matched. Public browser fetch failed; connector API reads succeeded.
- Published notes describe current bounded document semantics, native .tm/PDF
  consumers, Org frontend/scopes/configuration, controlled HTML coexistence and
  312 ERT/seven Nix results with current support limits. No uploaded assets are
  listed; automatic source archive links exist but were not downloaded. No binary
  or release-note raw copy is placed in GAW archive; these facts are distilled.
- User performed ordinary commit/tag/publication. Agent did not mutate remote
  release, refs, comments or assets, and did not run fetch/push/tag commands.
  Release/review hold is complete; subsequent work needs user selection. Issue
  #1 remains unresolved nonblocking later architecture design. Earlier validation
  limits (cache-backed checks, ELPA HEAD timeouts, no real package joint test,
  unverified GUI/general pagination/other platforms) remain unchanged.

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
## Candidate GAW reconstruction verification

The user authorized candidate reconstruction after choosing a separate branch.
During reconstruction, the original `_agents` branch remained unchanged and
`_agents_rebuild` was selected at `.agents` pending review. The rebuilt suffix contains 53 corresponding original
states plus two explicitly named reference-cleanup states before archive-only
boundaries. These cleanup states describe current curation, not invented past work.

Each checkpoint passed public `git gaw check` and exact candidate-tree/parent
comparison. Independent post-replay inspection matched all planned states,
subjects, original project-parent associations and historical configuration.
Original archive blobs/modes/manifests and SHA-256 records are unchanged at every
matched state. The standalone v0.3 interim review directly declares all four
summarized project nodes. The first bibliography-foundation record directly
declares that foundation, and explicit migration/file-link/footnote/bibliography
baselines are associated when recorded. No verification claim was expanded.

Rewritten memory/skills contain no GAW OID locator. Retained literal project
commit references have direct non-first parents and adjacent declarations; later
states use descriptive feature/release names. This audit covers the rebuilt suffix,
not the untouched earlier prefix. Annotated tag identity remains unchanged.
Original project history, release tags and ordinary worktree/index are unchanged.
No project tests or network calls were run. Created commits use reconstruction-time
timestamps, while supported event dates remain in their source text.

Necessary pure-text temporary evidence is preserved byte for byte under
`archive/2026-10-08T18-49-17Z--46ccf6e/`: guarded replay procedure, diagnostic mapping
journal and independent audit report. The manifest records source paths, roles,
sizes, SHA-256 and captured project HEAD; its introducing archive-only checkpoint
has that captured project state as its sole additional parent. Archived GAW OIDs
are diagnostic mapping data, not semantic memory identities. Original archive
whitespace was preserved; changed memory/skills passed whitespace checks.
The duplicate planning-state copies are regenerable and were not archived.
At candidate handoff, the original branch was retained pending a separate
retention/lifecycle decision; text OIDs alone do not guarantee object reachability.

### Adoption after user branch maintenance

The user subsequently restored the rebuilt branch's name to `_agents` and reports
backing up the old GAW branch remotely. Local public status/check confirm a single
valid `_agents` branch selected/deployed at `.agents`; its tip before recording
adoption was the verified reconstruction handoff. The worktree/index were clean.
No local `_agents_rebuild` or separate old GAW branch remains. Remote backup ref
name/content and remote reachability were not independently checked; no fetch,
push, branch/ref mutation or network lookup was performed by the agent. The
archived diagnostic names describe reconstruction-time state and remain unchanged.

## Issue #1 Phase 0 isolated investigation (2026-10-13)

- User selected Phase 0, isolated testing/necessary archive; versions must follow
  project flake rather than local Emacs. User then committed updated inputs and
  reapplied an uncommitted USTC fetchurl overlay. Current code/lock snapshot is
  b22945493102edc1823fe063f9d278ba628bdf5e; agent changed no production paths/index.
- Independent lock equals committed project lock SHA-256
  118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a;
  actual environment Emacs 31.1 / Org 9.8.10. Eleven copied Lisp sources compare
  byte-exactly with current worktree and that commit. USTC transport preserves
  original Org fixed hash. Local Org 9.8-pre and old-lock 9.8.8 are superseded
  environment observations, not final test provenance.
- Final exact command: timeout 120s nix build --no-link --no-write-lock-file
  path:/home/lingyu/Projects/org-texmacs/tmp/issue-1-phase-0#checks.x86_64-linux.probes.
  Exit 0, ERT 14/14, 0 unexpected, 0.124683s. No worker/native output/full project
  checks or real Org-roam integration ran. Macro/Babel phase and ID lookup were
  observed with controlled substitutes; no Babel execution or real ID DB reads.
- Confirmed stage order and INFO timing: no after-includes hook; native filters
  see backend name and pre-collection INFO (:parse-tree nil in probe). Cite output
  processing changes citation/print nodes into raw strings; disabling processors
  preserves AST but skips native discovery. Public install/apply tools remap a
  citation key using actual texmacs backend without generic exporter/lowering.
- Full annotation still queries org-id-find. Copy aliases mutable local lists;
  recursive AST copying/ownership cannot be assumed from default org-element-copy.
  Prepending 7 chars shifts inline STM begin 6 to 13; replacement AST invalidates
  existing inline/block island identity keys. These are adapter design hazards,
  not defects fixed in production this turn.
- Recursive INCLUDE advice runs three times; nested file links relocate to
  parts/b.png and parts/deeper/c.png for a visiting root fixture. Observed text
  properties do not supply a complete origin map. Bibliography paths stay relative;
  a SETUPFILE causes actual configuration-file read and directory relocation,
  while no bibliography text is read by the tested core discovery itself.
- HTML hooks/filter effects, guard rejection of texmacs generic export, copied
  source text/point/mark/restriction/modified state, error cleanup, and subtree
  configuration with region-priority body selection pass controlled checks.
- Recommended candidate A is constrained standard AST-filter reuse at preparation;
  candidate B native copy/annotate is conditional and not safe for direct adoption.
  Neither introduces textual target reparsing or implicit I/O in pure lowering.
  Full origin, multi-source resources, selection, external-input and hook contracts
  remain unresolved; no real-extension compatibility claim follows.
- Necessary 17 text artifacts plus manifest are byte/digest verified under
  archive/2026-10-12T19-11-59Z--b229454/MANIFEST.md. Archive-only checkpoint's project
  association identifies the verified code/lock snapshot, not origin of temporary
  artifacts or uncommitted overlay. Find introduction through manifest path history.
  REPORT.md has complete stage table/two candidates; REPRODUCE.md explains external
  Git-source dependency. No binaries/caches/redundant code copies are archived.
- Capture audit: diff --check warns about original log EOF and patch context spaces;
  original bytes were deliberately retained. A review helper initially counted
  nested patch diff markers as an extra file; orchestration continued to commit
  instead of stopping after the assertion failure. Corrected post-commit audit
  verified all 18 additions and every stored byte/hash, with no unrelated/protocol
  paths. Archive is immutable; no history rewrite was performed. Full archive
  first-parent diff SHA-256 e84c33fa4473d3424e2efff4f50270cdc75af625f8d86645a224af72313b80eb.
- Earlier offline attempt started fixed-output fetchers and was interrupted.
  An automatic review rejected a derivation-show escalation based on preceding
  unauthorized networking; it did not run. Subsequent explicit user network/mirror
  authorization allowed scoped builds. Official Org 9.8.8 fetch timed out 120s
  with TLS EOF; mirror success does not establish official endpoint availability.
  Temporary probe assumption failures were corrected before the final 14/14 run.
- Third-party public source lookups returned cache miss; package extension claims
  stay attributed to INBOX. No remote issue write was made. Phase 1 contract and
  scoped implementation remain the next decision, not completed work.

## Issue #1 plan revision after Phase 0 (2026-10-13)

User added INBOX section 11, confirming Phase 0 findings and selecting Phase 1a
contract design before Phase 1b implementation. Candidate A is preferred:
standard AST filters on existing preparation, no package-specific registration
or generic string exporter. The planned first envelope preserves node set,
identity, parentage, STM source/ownership and identity-keyed mappings; only
citation-reference :key may change. Replaced trees/raw output/other semantic
changes require explicit rejection, not only a root-identity check. INFO fields,
snapshot/filter ownership, private Org context, actual backend and placement
before resolution/bibliography planning/input-create must be specified first.
If A cannot satisfy that envelope, pause with evidence, not automatic fallback
to full annotation. Phases 2/3 remain separate external-input designs and may
change order; Phase 4 real integration is later. This is an adopted plan update,
not completed interface design or authorization to change production paths.
No new tests/source changes/remote issue writes were made for this review.
Phase 0 archive remains immutable; the revision's necessary content is distilled
here and in current/backlog, so no duplicate raw INBOX archive is needed.

## Issue #1 Phase 1a/1b verified candidate (2026-10-13)

- User explicitly requested implementing revised INBOX plan; Phase 1a contract
  is memory/filter-contract.md. Ordinary code paths changed: org-texmacs.el,
  org-texmacs-context.el, org-texmacs-document.el, tests/ert/ert.el and README.org.
  No worker/session/native consumer, public signature or source directive policy
  changes. Standard AST filters are a bounded new preparation capability.
- Exact independent gate authorized for repeated use: timeout 240s nix flake
  check -L --no-write-lock-file path:/home/lingyu/Projects/org-texmacs/tmp/issue-1-phase-1.
  Final exit 0/all 8 checks pass, focused 12/12 (7.266296s), full installed ERT
  324/324 (164.341759s), warning-as-error package compilation and package-lint.
  Host x86_64-linux, Emacs 31.1 / Org 9.8.10 / native TeXmacs 2.1.5. Other systems
  omitted by Nix; no GUI/actual Org-roam integration verification was performed.
- Isolated flake copies the project lock and user's mirror overlay, adding only
  focused check wiring. Twenty-one package/source/README/lock/test/driver files
  compare byte-exactly with ordinary worktree. Lock remains the committed b229454
  snapshot. Root flake.nix overlay diff SHA-256 remains
  2af6574fe8302fa7a5e64d3e93e8955cf7c36f0a4c6c2f135a2edffe8b65032a;
  agent did not modify/stage it. No lock writes occurred. Mirrors retain fixed
  source hashes; these results do not establish official ELPA availability.
- Exact five-file uncommitted candidate diff against b229454 SHA-256:
  e4e15c8ff1eae7892cd39f02a2bee4e0386fe5f707da2627d8f157fedff84bd7.
  This hash identifies checked worktree bytes, not a committed implementation.
  Main still identifies the dependency baseline. No resultant project-parent
  association is invented for the uncommitted tree.
- Native ERT compares UUID-remapped document with original external-key source
  output, verifies original source state and owned key, bibliography contents
  and session native readback. Positive nil remapping, selected/restored notes,
  backend/global order, restricted INFO/location, local core-only registry and
  no-filter legacy behavior are covered. Full gate retains previous HTML guard,
  subtree/region/narrowing/overrides, pure-input, worker and .tm/PDF regressions.
- Negative cases include root/subtree replacement, parent/position/affix/type/
  text/STM metadata/INFO/work-config changes, cyclic topology, key empty, buffer
  text properties, callback returning in wrong current buffer, missing remapped
  entries and exceptions. Validate nil-returning callbacks individually, so a
  later filter cannot repair prohibited intermediate return state. No worker
  request/stop is allowed on these failures. Functions/config changes at native
  waits invalidate output; function identity uses eq rather than structural equal.
- Final review added current-buffer validation and detached owning after filters
  because callbacks can retain private AST references. A real-worker regression
  mutates escaped keys during native waits and confirms the completed input keeps
  the correct remapped key and valid STM/bibliography request mapping. Temporary
  owning uses separate mapping/INFO shells before native results are filled.
- Intermediate focused iterations found backend records absent from a copying
  branch, a fixture assuming nonexistent special-block :value, and a test rebinding
  a compiler-deduplicated identical function. These were corrected. Earlier full
  322/322 (162.398472s) passed before the last two regressions/ownership fix; final
  324/324 above supersedes that candidate and no post-gate source edits occurred.
- User callback external I/O/edits and closure hidden state are not sandboxed or
  rolled back. No full annotation/discovery/generic exporter integration and no
  actual Org-roam compatibility claim. GitHub issue was not modified. Maintained
  tests now preserve reproduction, so no new raw archive is necessary; Phase 0
  archive stays immutable. Current memory carries stage/commit handoff status.

User subsequently authorized exact-path staging and commit-message generation.
Only the five implementation/test/README paths were staged. Full staged diff
SHA-256 matches e4e15c8f... above; diff --check passes. The reviewed staged change
is one coherent feature node. tmp/commit.md contains the Conventional Commit
subject "feat(document): consume Org AST filters for citation keys", Chinese
change bullets and Refs #1. flake.nix remains unstaged; no ordinary commit was
executed and no new tests were needed for this unchanged-byte staging step.

The user has now committed the citation-key AST filter revision. Read-only Git
inspection verifies its sole project parent is the flake-input update baseline,
subject "feat(document): consume Org AST filters for citation keys", and the
complete changed-path set is precisely the five approved files. Complete diff
SHA-256 matches e4e15c8ff1eae7892cd39f02a2bee4e0386fe5f707da2627d8f157fedff84bd7,
so the committed code/tests/README are the checked candidate bytes. Ordinary
index is empty and only the user's flake.nix mirror overlay is dirty, retaining
its recorded 2af6574f... diff hash. No new build/test or external lookup was run.
This checkpoint's project association identifies that byte-verified resultant
code/lock snapshot; earlier validation used the recorded isolated/mirror context,
not an independently tested unmirrored or other-platform environment.

## Phase 3a bibliography discovery/acquisition investigation (2026-10-13)

- User supplied INBOX section 12 and requested review/conditional execution with
  ongoing GAW updates. Its investigation-first scope is appropriate; Phase 3a
  executed, Phase 3b/Phase 2 production implementation explicitly not authorized.
  Code baseline is the committed citation-key filter revision; main and ordinary
  index remain unchanged, only the existing user USTC overlay is dirty.
- Exact final command: timeout 120s nix build --no-link --no-write-lock-file
  path:/home/lingyu/Projects/org-texmacs/tmp/issue-1-phase-3a#checks.x86_64-linux.discovery.
  Exit 0, 25/25, 0 unexpected, ERT 0.207506s. Actual Emacs 31.1 / Org 9.8.10,
  x86_64-linux; independent lock equals project/committed lock. Eleven code copies
  compare with committed c26b932 snapshot and ordinary bytes. Org fixed hash is
  unchanged with USTC URL transport; dependencies were cached. No new native
  TeXmacs execution or entire project check was performed. Pipeline native stages,
  remote URL reads and inaccessible-file cases use controlled substitutes.
- Native list-bibliography-files appends globals after document declarations and
  delete-dups raw strings before advice; the shared global tail can be mutated.
  Advice can reintroduce duplicates; immediately copy returned path strings.
  store-bibliography overwrites existing INFO paths and can retain relative names;
  get-environment does not make discovery/acquisition equivalent or enforce
  explicit text priority. No output processor/generic exporter/filter executes
  during tested discovery itself.
- Native collect-keywords widens narrowing and follows nested SETUPFILE, rebasing
  each declared bibliography path. Missing SETUPFILE can be silently omitted;
  URL setup is passed to org-file-contents (stubbed here). Raw TeXmacs block text
  is treated as Org keywords, returning island.bib and triggering its SETUPFILE
  read. This is an adapter interoperability boundary, not a production fix here.
- For visiting file in visit/ with default-directory base/, native discovery
  returns ../visit/refs.bib; existing explicit source snapshot refs.bib points
  to base/refs.bib. Non-file relative paths use effective directory, absolute and
  quoted names remain declared identities. Cannot silently normalize away that
  difference or use linked-resource base to infer a new bibliography policy.
- Private model first checks current restricted context, then uses full source
  copy with own global bibliography, no BIND variable processing, and all authored
  inline/block STM masked. Standard return advice still runs once; source and
  global values/restriction stay unchanged in controlled fixtures. Hidden/out-of-
  body STM must also be masked since native discovery later widens. Real SETUPFILE
  is rejected before discovery/read; visiting/base conflict is rejected explicitly.
- Acquisition model normalizes lexical local IDs once, classifies remote names
  before suppressing file handlers (initial prototype failed that distinction),
  preserves all explicit sources and gives their text priority without stat/read,
  then fills missing discovered sources. Explicit duplicate identities fail.
  Local UTF-8 owned text survives external mutation; invalid UTF-8/BibTeX, missing,
  directory/unreadable/symlink/physical hardlink aliases, changes during/after read
  and same-byte file replacements are controlled negative evidence. Receipts
  contain observed inode/device/size/mtime/ctime plus byte digest; checks verify
  fixed text rather than replacing it. No ABA-proof/transaction/security promise.
- Existing source API provided with global bibliography texts but no document
  BIBLIOGRAPHY declaration fails unresolved-key planning. With declaration and
  Phase 1 remap it succeeds once. Pure owned explicit effective declaration view
  resolves the key without I/O or new input slot. Standalone text acquisition
  alone is insufficient; future preparation needs a trusted owned declaration
  data boundary, not synthetic Org text or collector monkey patches.
- Three strategies compared: frontend opt-in, existing API policy opt-in, separate
  opt-in adapter. Prefer the last with whole-operation guards and declaration view.
  Draft memory/bibliography-contract.md records proposed local/UTF-8/size/alias/
  directory/preprocessing limits and before-publication receipt/source checks.
  Components are verified; integrated source/config/native wait/failure transaction
  still needs maintained tests and Phase 3b scope approval. Real Org-roam context
  and external database semantics were not established.
- Necessary seventeen pure-text files plus manifest archived at
  archive/2026-10-13T13-27-14Z--c26b932/MANIFEST.md: report, draft, reproduction,
  exact flake/lock/probes/fixtures/output and source byte proof/excerpts. Every
  copy/digest and full staged candidate verified; project association identifies
  the exact code/lock used by component research, not uncommitted mirror history.
  Introduced via manifest first-parent path history; archive-only checkpoint
  separate from active memory. Original ERT blank EOF is retained for fidelity.
  Full archive first-parent diff SHA-256:
  29a812b08d51d9de236fbabbaaacf978886f647c5160e72b04692e6a8e2dcf0b.
- Phase 0 archive and Phase 1 contract remain unchanged. No new production
  tests/README/package files, ordinary Git state or remote issue writes. Public
  issue/comment fetch failed; local INBOX's remote-reference claim is not
  independently verified. Upstream manual is background; locked source/probes
  supply behavior evidence. Transient research syntax/binding/STM assumptions
  were corrected before the final result, not counted as passed checks.
# Phase 3b Node A validation (2026-10-13)

INBOX section 13 selected by user conditional implementation request. New owned
effective declaration view validated by three maintained ERT tests: ownership and
invalid/ambiguous view rejection, global-only resolution through Phase 1 remapping
with unselected explicit data retained, and document disagreement before native
requests. Pure lowering remains unchanged. Isolated current flake/lock plus user
mirror configuration: 327/327 installed ERT in 163.753805s and all nine checks
(eight project checks plus focused); node-a-check.log under tmp/issue-1-phase-3b.
This validates uncommitted Node A changes, not committed c26b932 alone; no project
parent is attached to this checkpoint. No automatic discovery public API yet.

# Phase 3b Node B validation (2026-10-13)

Independent adapter module and flake fileset inclusion; helper-only API at this
node. Seven focused tests (0.153534s), 331/331 installed ERT (164.625142s), all
nine isolated checks passed. Logs node-b-focused.log/node-b-check.log under
tmp/issue-1-phase-3b. Maintained real local UTF-8 acquisition and receipts tests;
explicit absent identity/unused sources preserved, lexical duplicate collapse,
missing/directory/symlink/hardlink/non-UTF-8/oversize errors. Standard collector
with controlled advice runs once, masks fake STM SETUPFILE/bibliography, preserves
original source/global list. No actual DB lookup/native adapter end-to-end claim
yet; source-to-native transaction/public APIs are Node C. Changes uncommitted;
no project parent used. Initial reader rejects symlink ancestors as well as leaf.

# Phase 3b Node C/final validation (2026-10-13)

User selected INBOX section 13; A/B/C complete, code remains uncommitted on
c26b932. New independent bibliography adapter exposes document/.tm byte opt-in
APIs only. Existing explicit defaults, pure planner/input slots and Phase 1
per-callback restriction/once-only execution remain unchanged. Shared transaction
guard installed before discovery; acquired texts fixed and receipts validate
through native operations/final return. Separate source/config/global Cite/
collector/explicit-source checks. Final audit reuses the existing private parser
for full discovery view with captured links/headings; fresh full-text parse masks
blocks even when context prunes their AST nodes. Standard collector is not replaced.

Final isolated current-lock/mirror gate: 17/17 focused ERT (7.708077s), 341/341
installed ERT (171.422224s), all nine checks (eight project checks + focused),
warning-as-error package compilation and package-lint. Emacs31.1/Org9.8.10/
TeXmacs2.1.5, x86_64-linux only. Logs node-c-focused-final.log and
node-c-check-final.log under tmp/issue-1-phase-3b. Intermediate C complete gate
before link-context reuse also passed, but final counts/bytes govern this claim.
Early docstring width error and hex-leaf readback assertion were corrected,
not counted as successful tests. No full-regression timeout or remaining failure.

Maintained coverage: old API no discovery/read; standard advice/global/document
sources, lexical dedup, explicit absent text priority/unselected ownership;
inline/block/out-of-restriction STM and source-local link config; remote/URL/tilde/
control/missing/directory/symlink/hardlink/invalid-UTF-8/size errors. Actual UTF-8
files plus native bibliography parse/format, UUID mapping once, session readback
and serialized bytes. Controlled source/global/filter/collector/option/explicit
text mutations during discovery, source/file changes during acquisition, changes
at STM wait, bibliography parse/format, document consumer and serialization return.
Private buffers/advice cleaned on errors; callbacks are not sandboxed. Existing
HTML/ASCII/generic guard/native/PDF regressions remain part of full gate. No real
Org-roam package/DB lookup, atomic FS-DB/ABA, file publication or Phase 2 claim.

All 22 copied source/lock/test files byte-equal working tree. Exact ordered JSON
byte/length/SHA-256 manifest tmp/issue-1-phase-3b/final-inputs.json SHA-256:
9937e1c2f460d9bd46dcecd41931e74ed6bacaa9b02f21e1ba33bbcf498902ae.
Root/isolated flake differ only in the additional focused derivation; root's new
module fileset entry is present in both. Removing that sole new root entry and
reconstructing its mirror-only diff gives the unchanged user overlay SHA-256:
2af6574fe8302fa7a5e64d3e93e8955cf7c36f0a4c6c2f135a2edffe8b65032a.
flake.lock remains 118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a.
Seven changed working-tree paths and final content SHA-256 (flake includes mirror):

- README.org: 774edd309c907a6893bed0113a67ef1402927ac83c19526477919bd3fd613b39
- flake.nix: e5da300802c400f722350d83f7389e76ae3e921a390bafb08aafe4f17380d1c4
- org-texmacs-bibliography.el: b310104e9670cc9e477a7fdb9065ba31dfe5716fab89de8411a6c3a57cc60e7f
- org-texmacs-context.el: 3d47a4600ff8c1043da1868c51eba8ac601b8bdb0474794a187098a1f4cd4c7b
- org-texmacs-source.el: 084a8f02f70d0da067382403b80b7b16173c1e14dceeb2b27d28fff5dc95e108
- org-texmacs.el: 2111d48307baf807500e9e6d1c06a4bc97b649145b8f7549919a23bced697163
- tests/ert/ert.el: 1a9a6e869509027a75e8db05adbba185d93d5e261d5f1c765c9dfce289d02f40

Ordinary index remains empty; no project commit or issue write performed. No
project parent attaches to this checkpoint because tested implementation is an
uncommitted candidate, not c26b932 alone. Maintained tests/docs are primary future
reproduction; temporary logs/manifest are regenerable, no new archive needed.
Phase 0/3a immutable archives unchanged. Next ordinary staging needs separate
approval, including partial flake staging to exclude user mirror hunk.

# Phase 3b staged candidate/message (2026-10-13)

User expressly authorized staging and commit-message generation. Seven staged
paths: README.org, flake.nix (new module fileset hunk only),
org-texmacs-bibliography.el, org-texmacs-context.el, org-texmacs-source.el,
org-texmacs.el, tests/ert/ert.el. All six full-file staged contents match final
validated byte hashes above. Staged flake contains no user USTC overlay; only
that unchanged mirror patch remains unstaged. Complete staged candidate reviewed,
git diff --cached --check passes. No new tests necessary for staging verification.
Complete staged diff SHA-256:
810024f4aeb543142ec9d5413e024c0232bb836a6fe252ddba0c6faf3da06ad5.
tmp/commit.md contains reviewed Conventional Commit message:
feat(document): add opt-in Org Cite bibliography discovery; Chinese body describes
the adapter, declaration ownership, bounded acquisition/receipts, tests/docs/build
fileset. Refs #1, not Closes: Phase 2/4 remain independent. Suitable as one coherent
commit, split not necessary; separating coupled preparation/acquisition/guard
and tests requires hunk reconstruction (medium difficulty). No native project
commit, source edit, lock update or remote write. Current memory now awaits user's
commit and subsequent identity verification; no project parent attached to this
staging checkpoint because implementation remains an uncommitted candidate.

# Phase 3b commit identity and Phase 2 plan review (2026-10-13)

Read-only verification finds user-committed main
049a5a00bdd52d83e1f03823accc9324f4bcee0c, parent c26b932. Seven-file complete
committed diff SHA-256 equals the approved staged candidate:
810024f4aeb543142ec9d5413e024c0232bb836a6fe252ddba0c6faf3da06ad5.
Subject/body/Refs footer match reviewed tmp/commit.md. Index empty; only user
mirror overlay remains dirty. Root flake content SHA-256 remains e5da3008... as
in final tested inputs; lock remains 118fef56... . Remaining mirror diff on new
fileset-containing baseline SHA-256:
7a8827365304ff14f47a66f8282bbae968ba33f042261073f5e924bff48cb697.
This differs from the original mirror-only diff due to index/hunk baseline, not
overlay content. Prior 17 focused/341 ERT/all-nine gate is transferred by exact
candidate byte identity, not by rerunning tests. Project parent associates this
verified implementation/review baseline, not new Phase 2 runtime evidence.

User explicitly requested INBOX section 14 review and GAW maintenance, no plan
execution. Declared ordinary/starting-GAW baselines match local observations.
Review source section starts line1110, full INBOX SHA-256:
5ed50e2c1f7f2e92c2ee08a35dcbc0822c341e23ce4b80de2fd5221cd8ee2eb1.
Reviewed complete section: Phase 2a investigation before contract-selected bounded
Phase 2b; full Phase 4 follows stable composition, optional earlier small managed
bibliography integration separate. Plan appropriate and consistent with goals and
Phase 0 limitations (no after-includes hook/full-origin proof; simple hook invocation
does not establish full lifecycle). memory/preprocessing-plan-review.md records
review status, provenance, reasons, acceptance clarifications and deliverables.

Clarifications are future questions, not new verified capabilities: protect STM
literal directives across preprocessing; origin identity includes inclusion
occurrence/generated or unknown segments; hook-return protocol separate from AST
filter return rules; original/working selection/config precedence; STM resource
origins beyond relocated Org links; composition/bibliography origin and receipt
contract; bounded include dependency and invalidation policy. No origin model,
input slot extension, numerical include limits or lifecycle strategy selected yet.
No Phase 2 probe/prototype/native/test/build/network command, ordinary file edit,
index mutation or external issue write this turn. Only GAW memory maintenance.
Future investigation and Phase 2b implementation require subsequent execution
scope; prior Phase 3b test authorization does not expand to this new plan.

# Phase 2a locked investigation (2026-10-14 Asia/Shanghai)

User requested Phase 2a/2b execution and authorized isolated current-lock builds,
necessary network and repeated exact240s checks under tmp/issue-1-phase-2.
Twelve isolated ERT probes pass (0.144719s), Emacs31.1/Org9.8.10 asserted at runtime,
committed 049a5a0 source/lock byte-verified; mirror unchanged. No production edit,
actual TeXmacs worker or real third-party/DB operation in research. Actual Org ASCII
pipeline ignores numeric/arbitrary hook returns and orders before/after/filter;
native INCLUDE relocates ordinary links but leaves STM image strings unchanged.
Original selection offsets shift. Protected owned native-mirror model distinguishes
repeat/equal-text occurrences, masks fake STM directives, rejects marker loss and
cycles/unsupported paths/parameters, checks file receipts and distinguishes final
derived/source vs generated hook text ranges without guessing original offsets.
Full-file footnotes are renamed within occurrence; an initial false expectation
of extraction failed and was corrected against ox.el (only outside LINES definitions
are extracted). Final twelve results supersede that failed assertion.

Selected strategy: protected snapshots + actual native INCLUDE and staged hooks,
not full annotate-info and not reimplemented INCLUDE. Explicit first support is
common-directory complete-document/whole-file composition with finite local budgets;
source/STM occurrence ownership, generated policy, final node-keyed provenance and
full source/config/include/bib guards must be implemented/tested in Phase 2b.
Input's one resource-base proves cross-directory STM needs a later encoding policy;
no generic provenance slot yet justified. Research model lacks full public/native
transaction enforcement; no production claim follows. Contract target and node
acceptance: memory/preprocessing-contract.md. Exact report, reproduction, prototype,
probe, flake/lock, output and byte/source proof (8 text files) archived, verified:
archive/2026-10-13T16-45-34Z--049a5a0/MANIFEST.md. Archive-only checkpoint precedes
current-memory adoption; additional project parent denotes the research baseline.

# Phase 2b Node A verified (2026-10-14 Asia/Shanghai)

Private initializer can return a separately owned working source and structured
context, while original source guards remain baseline before initialization. A
pre-filter annotator can install identity-keyed origins. Private STM registration
retains working ranges when composition context exists; legacy request tuples stay
unchanged. Pure input INFO owns/remaps annotated node references; no public slot or
I/O added. Three focused ERT (0.122164s) cover original vs derived ownership,
distinct equal-text islands with exact node/range remapping before one filter,
and original source mutation rejection before working parse. Complete isolated
gate 344/344 ERT (173.063596s), all ten checks (eight existing + twelve research
probes + focused derivation). Logs tmp/issue-1-phase-2/node-a-{focused,check}.log.
Production main/document/tests uncommitted; no project parent attaches to this
candidate checkpoint. Protected native composition/public end-to-end still pending.

# Phase 2b Node B verified (2026-10-14 Asia/Shanghai)

Independent helper-only org-texmacs-preprocess module and fileset, owned protected
mirror graph invoking actual native INCLUDE. Fixed file texts reused for repeated
occurrences, source boundaries and exact STM tokens tracked separately from
generated hook insertions. Copies supported context, delays mode hooks, keeps
generic guard intact with a private guard for nested calls. Standard hook utility
uses owned lists/resolved functions without rebinding original hook variables.
Native INCLUDE function/default odd-level identity monitored; ordinary headline
policy required until temp-parser normalization supports other policies.
Eight focused tests (0.148219s), 349/349 ERT (172.609625s), all ten checks pass.
Logs tmp/issue-1-phase-2/node-b-{focused,check}.log. Corrected an unused column
predicate warning and parsed-author/string type mismatch before pass, not counted
as success. tab-width copied and adjacent-token range marker insertion fixed.
No public new adapter yet; complete source/hook/include/bib/native/output transaction
and native origin remapping still require Node C. Candidate uncommitted, no project
parent attached. Original immutable research archive remains unchanged.

# Phase 2b Node C/final acceptance (2026-10-14 Asia/Shanghai)

Selected bounded initial composition profile complete on uncommitted candidate,
main baseline049a5a0. Independent lazy optional preprocess module exposes owned
prepare/document/.tm byte APIs. Before-processing/parsing stages +actual native
INCLUDE over fixed protected mirrors; original canonical snapshot/config baseline
precedes callbacks. Node-keyed origins attached before once-only Phase1 callbacks,
working ranges captured explicitly during registration and remapped by pure owning.
No new public input slot/pure I/O/worker operation. Explicit new boolean separately
requests composed Cite discovery with existing priority/read receipts; old APIs/menu
defaults and original Phase3b wrappers unchanged. Shared transaction preprocessor
initializer prevents guard capture after preprocessing or late checks after output.

Final focused35/35 (16.023371s:18 new Phase2 ERT +17 Phase3b), installed359/359
(180.303530s), all ten isolated checks (eight originals +research/focused), strict
compilation/package-lint pass. Twelve locked research probes also pass in full gate,
but remain distinct evidence. Emacs31.1/Org9.8.10/TeXmacs2.1.5, x86_64-linux only.
Logs tmp/issue-1-phase-2/node-c-focused-final.log/node-c-check-final.log. Full check
authorized240s; no timeout/remaining failure. Source mutation/read-time file changes,
markers/config changes, missing/cycle/parameters/directories, size/occurrence budget,
observed-root hardlink alias and temporary cleanup tests; actual UTF8/local file
composition/nested repeats, six equal STM origin keys, private mode/nested generic
guards, generated STM and full-file native footnotes. UUID/bib/filter/discovery
once, actual native bib parse/format, session readback and bytes; include changes
at native parse/format/serialization reject result. Old HTML/ASCII/PDF/selection and
worker/domain-error behavior remain covered. Tests/prototype substitutions are not
actual Org-roam/database integration or GUI/STM resource rendering evidence.

Scope is deliberately full unnarrowed/ordinary-headline/common-directory/bare-file:
64KiB/file, depth8,32 occurrences incl root,256KiB aggregate. Existing visiting
identity must be regular or absent; physical root aliases rejected. Cross-directory
STM and original selection maps, include options/partial extraction, broader
parser/config lifetime and real packages remain separate. Tokens validate original
STM identity; generated STM has no guessed file/range. Ordinary intervals are
derived contexts (before-processing text rewrites), after-parsing changes have
generated contexts, not exact original char correspondences. No macro/Babel/BIND/
SETUPFILE/Cite processor/full annotation, FS/DB atomicity/ABA/callback sandbox/file
publication claim. Generic guard retained, projected names visible to INCLUDE advice.

Final23 copied code/lock/test inputs exactly equal root. Ordered final-inputs.json
under tmp/issue-1-phase-2 SHA-256:
c88fc8983442c9e49110da947db20bf38ca754e76eb6c13e2aee1161b8d60da5.
Root/isolated flake differ only by probe/focused definitions; sole production
fileset addition is org-texmacs-preprocess.el. Removing that line reproduces
unchanged user mirror-only diff SHA-256:
7a8827365304ff14f47a66f8282bbae968ba33f042261073f5e924bff48cb697.
flake.lock remains118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a.
Seven current changed paths and content SHA-256 (flake includes mirror):

- README.org: 9830164710ee9eec5eaa744fcda3a4b1fb78ff80d2d971ea059974763b52c4a1
- flake.nix: 57bac69941349d236cdc257eb11fd587ad2bc860e27858b3fe210432f818d62f
- org-texmacs-preprocess.el: 28df0be7b6f5b8c2e53228bd15d4091948c90dd0e717d48aa8a79d2711bcf83c
- org-texmacs-bibliography.el: 00ab1e3780fd8032e1f40f26a080a0e004053bc46f3032f1ffb603116e6fc132
- org-texmacs-document.el: 5a7dc7e85ff4e679dbd88bb3f21470a4ac6e0880813f420c1a1033fcfe5f3ba8
- org-texmacs.el: 728b660921f54c06708fcfc14c9ea70f34a2758c265c06ce864034fa74035499
- tests/ert/ert.el: 0c32929f78b642cd2e8c2f27b9a7242a2842e084764654a29ab1c1620ff8cd43

No ordinary staging/commit/lock/issue mutation. Current production tests/docs
retain reproducible implementation evidence; no duplicate source-code archive.
Original eight-file research archive remains immutable. Early syntax/width errors,
column predicate warning, parsed-author/string copy error and footnote research
assumption corrected before final gates. Candidate is uncommitted, so final GAW
memory checkpoint has no project parent; archive research baseline parent remains
separate. Next ordinary review/staging must exclude user mirror; Phase4 requires
separate scope. Issue #1 still incomplete beyond the selected first contract.

## Phase 2 staging and commit-message review (2026-10-14)

User explicitly authorized staging and message generation. Seven paths staged:
README.org, flake.nix, org-texmacs-preprocess.el, org-texmacs-bibliography.el,
org-texmacs-document.el, org-texmacs.el, tests/ert/ert.el. Partial flake candidate
contains only new module fileset entry; all USTC overlay edits remain unstaged.
Complete staged diff (966 insertions,28 deletions) reviewed, diff --check clean.
tmp/issue-1-phase-2/staged.diff SHA-256:
bbb18e19330b81634f407d7ccf8efec3658a19e645c815c9edfe14a31b71f2bc.
Six whole-file staged inputs equal final validated hashes above and working tree.
Earlier 35/35 focused,359/359 ERT and ten checks remain applicable with documented
mirror transport difference; no new tests solely for staging. tmp/commit.md regenerated
from staged evidence with English feat(document) subject, Chinese body, Refs #1.
One coherent capability including supporting transaction/provenance/tests/docs/
fileset wiring; split not necessary, medium difficulty for coupled intermediate
changes. No ordinary commit, lockfile edit or issue write; no project parent for
this uncommitted candidate checkpoint. User commit verification is next.

## Phase 2 user commit verification (2026-10-14)

User reported completion; read-only inspection verified bounded preprocessing
commit c52509573e5bccddeb661cf1dab1802733ac7dec on bibliography discovery
049a5a00bdd52d83e1f03823accc9324f4bcee0c. Complete HEAD-parent binary diff
byte-equals reviewed tmp/issue-1-phase-2/staged.diff, SHA-256 bbb18e19330b81634f407d7ccf8efec3658a19e645c815c9edfe14a31b71f2bc.
All subject/body/footer text matches tmp/commit.md, including Refs #1.
Index empty, only flake.nix USTC overlay remains unstaged and excluded from commit.
Earlier 35 focused/359 installed ERT/ten checks apply by verified candidate byte
identity with documented mirror transport; no new test/network operation was run.
This checkpoint associates the exact commit inspected, not the historical tests
retroactively. Phase2 first profile complete; Phase4/broader contracts remain
separate, no external issue change or closure claim.

## Phase 2c native investigation and contract selection (2026-10-14)

User requested INBOX correction/GAW/execution. Old15 marked superseded, new16
current; authorized120s probes/focused and repeated240s isolated flake check under
tmp/issue-1-phase-2c with necessary network/store/cache, no lock edits.
9/9 locked Emacs31.1/Org9.8.10 native probes pass. Parameter matrix/headline+
CUSTOM_ID/only-contents/lines/minlevel, ignored excluded nested reads, extracted
outside-selection footnote STM and fixed-copy reader across four native calls.
Unprotected texmacs block fake INCLUDE attempts absent-file read; footnote-like
STM renamed; multiline raw star text relevelled, but the latter exceeds existing
fragment paragraph grammar and is not supported-island proof. Native partial lines
can silently remove delimiters. Line-preserving shielding survives tested native
selections. Logs probes-second.log/probes-protection.log, script phase2c-probes.el
and REPORT.md under task tmp. Research has no TeXmacs/database/package joint proof.

Selected minimal candidate: real-path fixed native reads, no occurrence mirrors/
generic original maps; original/final/captured file texts owned in INFO. Partial
supported STM checked against native selected lines. Native same-file location
nesting rejection retained; sibling sections reuse one snapshot. Native helpers/
source/config/hooks/receipts guarded, limits/alias/UTF8 checks retained; common-base,
full-root, ordinary-level, no pure I/O or changed public signatures. README/API
docs explicitly remove adapter origins.27/27 focused pass13.482343s with9 new cases
and revised original-origin expectations, actual STM/notes/bib/native output and
source/dependency mutation covered. Full368 gate running, acceptance pending.
Initial duplicate flake checks/docstring widths and stale origin/cycle/multiline
grammar expectations corrected. No ordinary staging/commit/lock/issue write.
Candidate uncommitted, no project association for this implementation checkpoint.

## Phase 2c accepted candidate and preserved evidence (2026-10-14)

Final27/27 focused13.482343s,368/368 installed ERT209.352130s; exact240s full
isolated flake check exits0/all checks passed. Log reports five current x86_64-linux
flake checks; package-lint and warning-as-error compilation pass, native9 probes
also rerun0.141351s. No omitted-platform/GUI/real-package claim. Older count summaries
are not this gate: prior Phase2 log says running9 and Phase3b says running4;
earlier memory ten/nine summaries overcounted, preserved history is not a new gate.

23 source/lock/test files copied into isolated tree byte-equal root. Ordered JSON
final-inputs.json SHA-256 b0d0ef3febb8cddfcca283747dceae67b2c4d337c9417bddf1196a1d18edad9a.
Final preprocess module52e4a4f87084681bcdeb6b6281253de3c0331be0df59023c3d6595735717fcc4;
lock remains118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a.
Root flake diff still exactly user USTC overlay, no production flake change. Index
empty, only three production files README/module/ERT plus user mirror changed;
ignored INBOX modified as explicitly authorized. Source/lock unchanged since gate.

Seven necessary pure-text native comparison artifacts and manifest captured and
byte-verified at archive/2026-10-14T00-59-44Z--c525095/MANIFEST.md, archive-only
checkpoint with no inferred project parent. Source and capture-context provenance
separated, reproduction limitations explicit; no source/worker binaries/database.
Primary candidate validation retained by maintained ERT/source and current memory,
not redundant production archive. Existing immutable snapshots untouched.
Phase2c scope complete; user ordinary review/staging/commit next, Phase4 separately
selected. No issue closure, ordinary staging/commit/network publication. Final
memory checkpoint has no project parent for uncommitted accepted implementation.

## Phase 2c staged candidate/message review (2026-10-14)

User authorized staging/message generation. Exactly three whole files staged:
README.org, org-texmacs-preprocess.el, tests/ert/ert.el. Full diff reviewed,
412 insertions/387 deletions, git diff --cached --check clean. Each staged file
byte-equals working tree and accepted final-inputs manifest hash. Staged binary
diff SHA-256972ca91a5076520ba0fbe0f5a17ccb63f47952c82d858e55de3025270c3a1c09.
Only user flake.nix mirror remains unstaged; lock/index scope unchanged otherwise.
tmp/commit.md regenerated as feat(document)!: support native INCLUDE parameters
with fixed snapshots. Chinese body, BREAKING CHANGE for clearly removed documented
INFO original/occurrence/AST origin contract, Refs #1 because Phase4 still unverified.
Public function signatures unchanged but documented result data changes require
callers using old INFO fields to adapt. Suitable as one coherent capability;
split not necessary, medium difficulty for coupled fixed reads/shielding/contract/
parameter and regression changes.27focused/368ERT/all5checks apply by exact staged
byte identity; no new tests solely for staging. No ordinary commit/issue write,
no project parent for uncommitted candidate. Next verify user's resulting commit.

## Phase 2c user commit verification (2026-10-14)

Read-only inspection verifies user commit1a254a792286fe9c98a7529a6d13879ff707de24
on c52509573e5bccddeb661cf1dab1802733ac7dec. Complete parent-to-HEAD binary diff
SHA-256972ca91a5076520ba0fbe0f5a17ccb63f47952c82d858e55de3025270c3a1c09
exactly matches reviewed staged candidate. Entire subject/body/BREAKING CHANGE/
Refs #1 message matches tmp/commit.md. Index empty, only original flake.nix USTC
overlay remains unstaged and excluded.27focused/368ERT/all5checks remain applicable
by verified candidate identity with documented mirror transport; no new runtime
test/network action solely to associate commit. This checkpoint's project parent
is the actual snapshot inspected, not retrospective original test provenance.
Phase2c complete, Phase4 real package integration separately selected; no issue write.

## Local third-party source review (2026-10-14)

User authorized read-only inspection of three package repositories under
/home/lingyu/Projects after public-source web cache misses. All three native Git
status reports clean; no dependency/generated/DB directories scanned, no packages
loaded, no modes/queries/build/test/download run. Reviewed relevant Elisp entry
points and support helpers, not entire dependency trees. Exact observed HEADs and
primary module SHA256:

- org-roam-include: ca62c8fb5c23064253877480edb2ba83a2cf2afb;
  org-roam-include.el996fb667f1dac805e5f6ebca5f82f30ae70a3fafbf430d742a9fd20b4be41043.
- org-roam-organize: eaaee8e47137e4bebc65b3cce6b7c409bc5a24cd;
  org-roam-organize-cite.el5b71f2ad4b534f7b951628f8f2adfb3c745c9f865698b3de6d48d81e3adf23f7.
- org-roam-blog: 778d410f55710bca22a2d84a301a72b7b099b874;
  org-roam-blog.elc62c33de73773d4762f7e1117aa50274eed9c6c1a5900f0a7c342772b2d3a1cb.

Include623-814/994-1130: global mode installs buffer-marker before-processing hook,
native INCLUDE around-advice with recursive dynamic context/custom file-search
handler. Node identity comes from org-roam-node-from-id; saved location preparation
653+ uses direct insert-file-contents into hook-suppressed Org buffer, bypassing
our fixed org-file-contents reader. Physical line search derives from DB point.
This is a concrete extra dependency boundary to test, not a proven runtime failure.
Organize cite28-145/429-594: managed bibliography DB paths expanded at each node
file, appended after standard Cite results under Org-derived/global-mode guard;
AST filter ignores backend/info, changes only matching citation-reference :key
and returns original tree. Global setup/teardown verified in organize.el52-113.
Registry/tag/node/ref queries remain live state; file receipts do not cover DB.
Blog535-566/1043-1095: HTML org-export-to-file under dynamic body filters, saved
source buffer file/directory and Org mode; publish/index/attachment paths have
separate effects. Existing interface descriptions now source-verified. No claim
of fixture-backed package/native/HTML runtime compatibility, DB atomicity or #1
completion. Review updated at memory/cross-directory-integration-plan-review.md.
External OIDs identify inspected source only; no foreign project-parent attachment.

## Revised working-buffer/context priority (2026-10-14)

User explicitly prioritizes final preprocessed buffer -> AST over native STM resource
support and rewrote INBOX section17 accordingly. Complete new section reviewed:
appropriate4a standard Org context/cross-dir investigation ->4b include ->4c organize
->4d joint/blog HTML/publish. Input includes normal effective context, not only text;
canonical source/owned snapshots/pure lowering retained, full generic lifecycle not
automatically selected. STM relative paths intentionally use final document base,
not original included file directory; standalone/include may resolve differently.
No original directory/source map/occurrence machinery required to recover history.
Native resources separate optional follow-up, existing PDF restrictions retained.

Previous review overconstrained third-party reads/DB as potential prerequisite to
intercept/close all dependency paths. Their direct-read/live-query facts remain
source-verified, but internal provider details alone do not demonstrate a defect
or require org-texmacs to own their implementation. Existing adapter own-read
receipts, external provider guarantee limits and final input coherent snapshot
must be distinguished. Further adaptation needs actual wrong output or explicitly
adopted stronger guarantee. Existing native absolute hlink translation is unchanged;
relative final output is a separate consumer contract question. Updated current
review/backlog record supersedes earlier source-origin/dependency prerequisites.
No runtime evidence/code/INBOX edits/tests/network action in this review; next is
Phase4a investigation on explicit execution request. Issue#1 still incomplete.

## Phase 4a and actual extension focused evidence (2026-10-14)

User requested revised section17 execution;120s isolated probes/focused/integration
and repeated240s full gate authorized under tmp/issue-1-phase-4, current lock/mirror,
necessary dependency networking/store/cache, no personal DB/third-party repo edits.
Six context probes0.113537s pass onEmacs31.1/Org9.8.10/Org-roam20260425.1623 with
native SQLite. Initial environment log org-roam-version getter raises search-failed;
removed getter, version assertions/sqlite/library path kept. Actual native copy
retains file/default-directory/local with-toc; nested links relocated to source-root
relative parts/sub/asset.txt, footnotes preserved; relative BIBLIOGRAPHY refs.bib
and STM asset.png unchanged final text. Baseline cross-dir rejection observed.

Production removes two included-directory equality checks, normalizes capture paths
and gives each private include parser its file directory; root/final context remains.
Five maintained ERT add native cross-dir link/note/.tm and owned contexts, final root
bib declaration semantics, STM block/PDF restriction, completed working input without
preprocessing replay, partial block refusal.32focused pass17.775013s. First docstring
width corrected; initial resource test used unconfigured inline image and therefore
ordinary text, corrected to genuine texmacs block before final pass.

Real extension source copies under isolated extensions dirs match clean local
repositories previously inspected; modes/hooks/advice and org-roam-db-sync/queries
run against synthetic SQLite/source/BibTeX/publication fixtures. No query/node/read
mock or package-specific converter. Include ca62c8f, organize eaaee8e, blog778d410.
Initial3fixture gate include passed, organize refused incomplete registry (missing
exactly-one MOC). Corrected fixture registry, no package patch.3then6fixtures passed;
final7/7 pass9.025827s using maintained optional Nix runner. Actual node/headline/
recursive cross-dir/parameters/whole-file property mount, cycles/missing node with
helper/search/hook/source restoration; actual managed node-relative bibliography,
UUID key filter/native bibliography, missing refs before worker; joint HTML before/
after .tm conversion and actual blog publication with nested content/reference text;
mode teardown restores standard interfaces. Package-specific DB internals remain
provider responsibility, no stronger atomicity or complete dependency claims.

Contract memory/working-buffer-context-contract.md. Current production files README,
preprocess module,ERT and optional integration runner/fixtures; default flake/lock
unchanged apart from user mirror. Full gate running, candidate uncommitted/not yet
accepted globally; no ordinary staging/commit/issue write. Source-specific resource
recovery/relative native output/generic exporter remain outside selected work.

## Phase 4 accepted final gate and reproducibility (2026-10-14)

Exact authorized240s isolated flake check exits0/all checks passed.373/373 core
ERT189.379261s,32focused17.537532s,7actualintegration8.708412s,6nativeprobes0.120499s;
log reports running10checks with strictcompile/package-lint successful. x86_64-linux
only, omitted platforms remain unverified. Core and real fixture checks include
native document/STM/bibliography/bytes, actual modes/SQLite/HTML/blog publication,
negative inputs/cleanup and original supported consumer/configuration regressions.

25source/lock/test inputs byte-equal root, ordered final-inputs.json SHA256
38e25bfe901041823d2a368237d43f4e7b7d87a19ce7889f16550536c8172761.
11foreign Elisp modules match clean original repository sources at recorded exact
commits; extension-inputs.json SHA256
f7c7b8d398364515e0497789bfbcacc2d425f33a9937ee28fb0a63c4b74448b5.
Org-roam library version20260425.1623 from pinned Emacs environment; root lock
118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a unchanged.
Root flake remains57bac69941349d236cdc257eb11fd587ad2bc860e27858b3fe210432f818d62f,
only user USTC overlay difference. No default third-party package dependencies.

Necessary nine original-byte pure-text artifacts plus manifest captured/verified
at archive/2026-10-14T06-28-22Z--1a254a7/MANIFEST.md. Archived native script/log
are baseline context observations; accepted fixture/candidate manifest explicitly
separate from capture HEAD. Foreign ordinary histories preserve actual package
source; no duplicated foreign checkout/DB/binary archive, no inferred project parent.
Maintained optional integration runner/fixtures and core ERT preserve regeneration.

Five project files changed: README.org, org-texmacs-preprocess.el, tests/ert/ert.el,
tests/integration/default.nix, tests/integration/phase4.el. Index empty, no ordinary
staging/commit/external issue write. Current latest section17 selected4a-4d complete.
Generic exporter/default dispatcher switch, original source selection mapping and
STM actual resources/relative native-output consumers are separate/unselected here;
full source/DB atomicity not claimed. Old original Phase4 proposal mentioned formal
frontend switching; do not conflate tested opt-in standard interfaces with changing
default menu behavior when judging overall#1 closure. No blanket real-package/all
registry/GUI/all-platform compatibility claim. Next user project review/staging/
commit then exact identity verification; candidate checkpoint no project parent.

## Phase 4 staged candidate review (2026-10-14)

User explicitly authorized staging and commit-message generation. Five expected
paths only staged: README.org, org-texmacs-preprocess.el, tests/ert/ert.el,
tests/integration/default.nix and tests/integration/phase4.el. Complete staged diff
reviewed:391 insertions/14 deletions; cached --check passes. Every staged blob equals
both current worktree bytes and its accepted final-inputs.json entry; preceding
373core/32focused/7actual integration gates transfer by byte identity, no new test.
Binary staged diff SHA256:
6eb3e3d01832957691b01869099a95e5203588959e8fdf523bb898b3cd322a78.
Only unstaged path flake.nix (user mirror); root lock untouched.

tmp/commit.md generated solely from staged changes: feat(document): support
cross-directory INCLUDE with real extension coverage; Chinese body, Refs #1,
additive capability/no new breaking footer. Split assessment not necessary,
difficulty medium: implementation, input contract and native/real fixture coverage
serve one coupled cross-directory interoperability change. Default frontend switch
not selected in this commit; overall issue closure remains separate. No ordinary
commit or external tracking write. Candidate still uncommitted, no project parent.

## Phase 4 user commit identity verification (2026-10-14)

User reports commit completed. Read-only verification observes project HEAD
6f018decef3907ab20ef68700751912799dc8432, parent native parameter baseline
1a254a792286fe9c98a7529a6d13879ff707de24. Complete binary committed diff SHA256
6eb3e3d01832957691b01869099a95e5203588959e8fdf523bb898b3cd322a78
equals reviewed staged candidate. All five committed blobs equal accepted final
input manifest entries; full message matches tmp/commit.md, including Refs #1.
Index empty and only flake.nix user mirror dirty. Prior 373core/32focused/7real
integration gates apply by verified byte identity; no new tests merely for commit
verification. No external issue closure or further phase selected. This observation
supports associating the committed snapshot with this verification checkpoint;
it does not retrospectively establish original uncommitted-run commit provenance.

## Phase 5 selected frontend acceptance (2026-10-14)

User selected INBOX section18 execution on verified6f018de Phase4 baseline,
authorized120s isolated probes/focused/integration and repeated exact240s full
check/network/store/cache/logs under tmp/issue-1-phase-5. No root lock edits.
Four baseline probes pass3.144554s: loaded ox guard/hooks/nested generic rejection,
actual callback PDF/changed native dependency, scoped discovery, full/direct profile.
Initial isolated copy/load/let harness errors repaired; no production defect inferred.

Frontend full route uses existing --preprocess-convert; scoped direct with/without
discovery uses existing bibliography/prepare callback transactions. Default-nil
buffer-local org-texmacs-export-discover-bibliography explicit for all consumers/
scopes; captured before prompts/checks through final byte return. Shared byte-view
initializer, no public signature/protocol/pure I/O change. Native serialize/PDF
within original transaction; global generic guard/menu/keys unchanged. Full provider
profile now constrains defaults, documented. Context refuses unresolved ROAM_INCLUDE
keyword and selected-root mount before discarded metadata. No package converter/DB
adapter or source-origin recovery. Public direct APIs/explicit text priority retained.

Eight new core ERT plus existing legacy consumer failure seams updated;79focused
54.728771s, final full rerun57.349582s. Two new actual frontend cases and joint
HTML/blog retarget;9real10.629183s, final11.487037s. Actual modes/SQLite/queries/
hooks/advice, false discovery explicit failure/true .tm view/file equality/native
PDF text, missing-node preserve existing .tm/PDF, local mount refusal and HTML/blog
publication/source/teardown restoration. Initial8/9 was PDF fi ligature assertion;
NFKC semantic comparison corrects that test, no package/render changes.

Exact240s full flake check exits0, all checks passed/logged10,381/381 core ERT
178.555109s; strict compilation/package-lint and4candidateprobes3.585992s pass.
Other platforms omitted, no GUI/all-registry/native resource/full lifecycle claim.
25root source/lock/test inputs byte-equal isolated final snapshot before/after gate;
final-inputs.json SHA256740964a9c69fa8707461aa32dc48dc3d5aa306314840646a500c2960cff122ad.
11copied foreign modules match Phase4 source manifest exactly, same pinned revisions;
extension manifest SHA256f7c7b8d398364515e0497789bfbcacc2d425f33a9937ee28fb0a63c4b74448b5.
Root lock118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a and
mirror57bac69941349d236cdc257eb11fd587ad2bc860e27858b3fe210432f818d62f unchanged.

Nine necessary original-byte pure-text artifacts verified and archived immutably:
archive/2026-10-14T07-51-02Z--6f018de/MANIFEST.md. Capture HEAD is context,
baseline probe provenance separate from uncommitted candidate/actual fixture log;
archive-only checkpoint has no inferred project parent. Maintained ordinary tests
and foreign source histories preserve code, no personal DB/PDF/binary/checkout copy.

Seven project files changed: README.org, ox-texmacs.el, org-texmacs.el,
org-texmacs-context.el, tests/ert/ert.el, tests/integration/default.nix and phase4.el.
Index empty, no ordinary staging/commit/issue write; root mirror other dirty path.
Selected INBOX#1 architecture and formal frontend goals complete, closing footer
appropriate after user review/commit. Live GitHub issue page fetch failed/cache miss
and search provided no relevant page; no current remote-content/status claim.
Generic lifecycle, full native resources/selection origins/menu keys remain separate
nonblocking scope. Provider guarantees and ordinary partial-write error boundary
unchanged. No new verification solely for project-parent association.

## Phase 5 staged review and footer preparation (2026-10-14)

User explicitly authorized staging/message and asked for skill-compliant footer.
Only seven expected Phase5 paths staged,376 insertions/43 deletions; complete staged
diff reviewed and --check clean. Each staged blob matches worktree and accepted
final-inputs.json SHA256 entry. Staged binary diff SHA256:
68f76e19edefa2afda14e1b373ea7e010731b78093e413b029c8603a46928054.
Only flake.nix user mirror unstaged; no lock changes or new tests for staging.
Prior381core/79focused/9real/all10checks apply by exact byte identity.

tmp/commit.md regenerated from staged diff; feat(export)! subject, Chinese body,
BREAKING CHANGE footer explains full frontend default preprocessing/hooks and
provider constraints versus direct APIs. Blank line separates Closes #1 footer:
selected local INBOX architecture/frontend acceptance achieved, live remote issue
still unavailable/no external mutation. Suitable one coupled frontend/transaction/
discovery/coverage commit; split not necessary, difficulty medium. No ordinary
commit; next user commit then committed identity verification, no candidate parent.

## Phase 5 user commit verification (2026-10-14)

User reports commit completed. Project HEAD5f4c9c0d921617a7a53a030d1127b82ff8640eeb,
parent6f018decef3907ab20ef68700751912799dc8432. Complete binary committed diff
SHA25668f76e19edefa2afda14e1b373ea7e010731b78093e413b029c8603a46928054
equals reviewed staged candidate. Every one of seven committed blobs equals
accepted final-inputs.json hash. Prior381core/79focused/9real/all10checks apply by
byte identity; no new tests. Index empty, only flake.nix user mirror dirty.

Full message matches current user-edited tmp/commit.md: same feat(export)! subject,
body/footer punctuation changed to halfwidth and closing footer now Closes: #1.
BREAKING CHANGE and blank separator retained; native Git trailer parser recognizes
Closes: #1. Initial verification asserted older no-colon spelling and failed only
that expectation; subsequent exact-message/blob verification passes. Preserve user
edits, no project commit/message rewrite or external issue write. Selected local
INBOX architecture/frontend complete, current remote issue state not verified.
This committed snapshot is actually checked and supports a project parent for this
verification checkpoint, not retrospective provenance of original candidate runs.

## INBOX persistence coverage audit (2026-10-14)

Current ignored INBOX.md is90229bytes with sections1-18. Stage mappings checked:
initial goals/Phase0/selected Phase1 in goals/filter contract/evidence and probe
archive; sections12-13 in bibliography contract/history/reviews/evidence;
sections14-16 in preprocessing review/contract/history with explicit supersession
and removal of origin-map contract; rewritten17 in working context/real extension
review/contract/archive;18 in frontend review/contract/accepted code+verified user
commit/closing trailer evidence. Operational recovery is sufficient without raw
INBOX. This is semantic coverage, not a verbatim or every-paragraph equivalence claim.

Specific18.7 future menu-key mechanism was only generically deferred in memory;
explicit configuration, no default key values, documentation recommendations/examples
now added to backlog, implementation not selected. Existing archives preserve
selected evidence/reproduction artifacts; no tracked original INBOX file found.
Current original has independent historical value as user's evolving plan wording
and superseded alternatives. Recommend one original-byte immutable archive with
current capture context/size/SHA256 and non-authoritative status clearly described;
not mandatory for resuming implementation. No original-file archive or deletion
performed in this audit, no production/test/Git-history change. Current file cannot
recover previously overwritten drafts; stale raw statuses must not become authority.

## INBOX original-byte archive and clearing (2026-10-14)

User explicitly authorized archiving then clearing ordinary INBOX.md. Before
capture file regular/not symlink, ignored/untracked,90229bytes UTF8 pure text,
SHA25683b744987f3db9ba15a797b2f0cfe08143bc38956ddad828f6e16148186f288a.
Checked project HEAD5f4c9c0 is capture context, not original source of every plan.
Original creation/revision dates and overwritten drafts not independently recovered.

Fresh immutable archive:
archive/2026-10-14T12-48-06Z--5f4c9c0/MANIFEST.md and files/INBOX.md.
Complete staged change exactly two pure additions, source/archive/index bytes
identical,1838original lines. GAW check and archive-only public commit pass, no
additional project parent. Public show confirms original file and manifest only.
Before clearing, committed archive blob rechecked against same unchanged source
and expected SHA256; project HEAD unchanged. Original file opened without following
symlinks and truncated to0bytes, retained; archive and committed bytes remain intact.
Current memory/backlog authority remains the distilled implemented/deferred state.
Raw pending/current labels and superseded alternatives historical, not instructions.
No production code/test/lock/index/history/remote operations; user mirror unchanged.

## New Phase 6 menu configuration plan review (2026-10-14)

After original issue1 INBOX archival/clearing user supplied new9100byte Phase6 plan
associated issue2, review only. Full new text read; current ox fixed menu registration,
guard, test top-level loading/hardcoded structure and README recipes inspected.
Suitable independent nil-default explicit config proposal, fixed existing commands/
named backend and Phase5 transactions unchanged. Review/distilled decisions in
memory/export-menu-plan-review.md, backlog/current coordinated.
Native key-domain/control/shared-prefix/duplicate-backend semantics await6a
locked independent-flake probes; no runtime compatibility claim from this review.
Key layers independent (prefix may equal action key), actual inaccessible conflict
must reject before registry mutation, copy menu data and test real first load.
Default-menu removal is documented-entry compatibility change; Custom should not
promise live refresh. No production/INBOX edit/build/test/issue write performed,
no execution selected or prior task-build authorization transferred. Prior archive
immutable; latest INBOX no longer empty, and does not replace current contracts.

## Phase 6 native contract and focused node (2026-10-14)

User selected execution, explicitly authorized120s isolated probes/focused/integration
and repeated240s full checks/network/store/cache. Current project lock mirrored in
independent tmp/issue-2-phase-6, host Org not used.5native probes pass1.021877s,
Emacs31.1/Org9.8.10: nil menu backend exists, same-name replaces, shared prefix
combines disjoint actions, duplicate action first-wins, Unicode routing, reserved
control/help/publishing behavior. Source read-event interface confirmed. Initial
wrong UI signature and one120s/exit124 read-input timeout were harness failures;
source-only investigation then read-event injection corrected, no production defect.

Global nil-default org-texmacs-export-menu-keys four-field complete plist selected;
graphic Unicode/control/modifier/surrogate/reserved validation and duplicate fields/
actions reject. Independent generated menu, conflict scan current other backends,
disjoint sharing allowed/direct prefix collision refused. Native registration after
validation, generic guard/commands unchanged. Custom load-time only, no live setter/
watch/refresh/fallback; migration/default visibility documented. Contract in memory.
Five new core cases include three genuine fresh locked subprocess scenarios and
native dispatch plus config domains/collisions. Existing fixed-menu assertion now
expects nil; menu-independent three native outputs/Phase5 fixtures retained.
84focused54.313479s pass, package strict compile success. Full240s check running,
not accepted globally yet.25project and11foreign inputs byte-match isolation;
user mirror/root lock unchanged, production only ox-texmacs.el/README.org/ERT changed.
User queried temporary evidence archival: selected native probes/environment/input
manifests/reproduction for after final gate; no caches/products/duplicate ERT capture.
No ordinary staging/commit or external tracking mutation.

## Phase 6 final acceptance and selective archive (2026-10-14)

Exact authorized240s isolated flake check exits0:386/386 core ERT175.465056s,
84/84 focused56.135881s,9/9 actual extensions10.962176s,5/5 native probes1.021619s;
all10logged checks, strict compilation and package-lint pass. Selected6a-6d accepted.
25project inputs match isolation before/after gate; final-inputs.json SHA256
4de96b5514e3b5045fcab6f5da4d6e5b682e5b1e37a48abbc1eaed12563d711c.
11copied foreign modules match extension-inputs.json SHA256
f7c7b8d398364515e0497789bfbcacc2d425f33a9937ee28fb0a63c4b74448b5.
Root lock/user USTC overlay unchanged, no foreign repo/personal DB writes.
Only README.org/ox-texmacs.el/tests/ert/ert.el are task project changes, unstaged.

User asked whether temporary tests were considered for archival. Selection completed:
eight original-byte pure-text artifacts captured, SHA256/size/source copies verified,
complete archive-only staged transition reviewed, GAW check/checkpoint successful.
Manifest: archive/2026-10-14T13-19-02Z--5f4c9c0/MANIFEST.md. Retained reports,
native probe script/log with necessary pinned source excerpt, independent flake/lock,
project/foreign input manifests. Duplicate maintained ERT/build logs, caches, DB/PDF,
binary products and full foreign checkouts excluded; harness-failure facts distilled
in memory. Archive immutable. Capture HEAD is context, candidate manifest defines
uncommitted tested inputs; no inferred additional project parent. x86_64-linux only,
no GUI/runtime refresh/later registry monitoring or current remote issue status claim.

## Phase 6 staging and trailer review (2026-10-14)

User authorized staging and commit message. Exactly README.org/ox-texmacs.el/
tests/ert/ert.el staged; complete staged diff reviewed, diff --check clean and
all three staged blobs byte-match accepted final-inputs.json and current worktree.
Prior gates transfer by byte identity; no additional build needed. User flake.nix
mirror remains unstaged, root lock unchanged. One coherent feature/migration/test
commit, split not necessary (difficulty low). tmp/commit.md replaced prior completed
Phase5 draft with feat(export)! subject, Chinese body/ASCII punctuation, adjacent
BREAKING-CHANGE: and Closes: #2 trailers; git interpret-trailers recognizes both.
Breaking effect is removal of implicit dispatcher menu, explicit pre-load config
required. Selected issue2 acceptance complete; remote closure/status not asserted.
No ordinary commit or issue write; user reviews and commits manually.

## Phase 6 user commit verification (2026-10-14)

User reported committed. Read-only verification establishes exact three changed
paths README.org/ox-texmacs.el/tests/ert/ert.el and Phase5 baseline parent.
All three committed blobs match accepted final-inputs.json, isolation and worktree.
Complete committed binary diff SHA256
df6612dcf8809547294d7e5725c44967372a3dc5f483763227844e803cca3a37.
Full message equals tmp/commit.md, feat(export)! subject and adjacent
BREAKING-CHANGE:/Closes: #2 trailers. Index empty, only user USTC mirror unstaged.
Prior gates transfer by byte identity; no additional tests merely for provenance.
Selected Phase6/issue2 local acceptance complete and committed; remote issue status
not verified, no external tracking write. This checkpoint associates the exact
project commit whose paths/blobs/message were actually inspected, not a guessed
original parent of archived candidate tests. Archive remains immutable.

## Post-Phase6 documentation and dependency audit (2026-10-14)

Baseline committed Phase6, worktree differs only user flake mirror. Read-only
targeted inspection of README install/configuration/filter/discovery/preprocessing/
integration/dispatcher/session/check sections, module commentary/docstrings,
Package-Requires, committed flake/source fileset, lock and core/optional test wiring.
Latest menu default/migration/key validation/load lifecycle documented accurately.
No new external runtime dependency in Phase6; Org required by header/flake and
all production modules in fileset, Org-roam/extensions optional integration only.
Header/flake version0.4.0 consistent, future release not selected.
README stale findings: line36 tested Org9.8-pre vs current9.8.10;147 seven variables
package-wide vs seven core plus two frontend;871 real Org-roam unverified and973
real third-party integration separate future work vs actual pinned fixtures;1691
file saving/export future work vs existing separate consumers. Recommend precise
replacement/cross-links without widening fixture support claims. Minimum Org9.8
is declaration, current tested9.8.10 not proof of minimum or other revisions;
no minimum-boundary experiment/new dependency bump justified by this audit.
Frontend commentary could clarify optional menu but does not assert default keys;
new option docstring already states nil/default and load-only behavior. No project
write or build performed. Audit is bounded to changed contracts/related descriptions,
not a new exhaustive all-API/all-version verification.

## Authorized documentation corrections (2026-10-14)

User requested modifications to relevant documentation/comments/dependency statements.
Only README.org/org-texmacs.el/ox-texmacs.el edited. Five audited stale descriptions
corrected and cross-linked to real extension/dispatcher sections; seven core and two
frontend options distinguished, tested locked Org9.8.10 stated. Main/frontend module
commentary clarifies explicit pre-load menu, declared minimum vs tested lock, optional
Org-roam/extensions and external TeXmacs runtime. Actual Package-Requires and Nix
runtime dependency list retained because no new dependency or minimum-bump evidence.
README heading targets and complete diff inspected, diff --check clean. Lisp code,
metadata versions/dependency values, flake/lock untouched; user mirror preserved.
No executable tests/builds run for prose/comment-only changes; no staging/message
or project commit performed. Prior gates validate implementation, not rerun on new
comment/document bytes. Raw evidence archive unchanged, no new probes to archive.

## Minimum Org dependency clarification (2026-10-14)

User recalled API existence concern. Earlier "no bump needed" inference was too
strong: current locked success does not establish9.8 minimum compatibility.
Read-only project history setup commit81e06ca explicitly raised declared Org9.5
to9.8 when introducing org-element-cache-store-key/get-key/create checks.
Official https://raw.githubusercontent.com/bzg/org-mode/release_9.8/lisp/org-element-ast.el
contains create/property-raw/properties-mapc; selected export options helpers also
appear in release_9.8 ox.el. These spot observations are not complete current API
or signature/behavior validation. Browser could not fetch release_9.8 org-element.el
(cache/internal error); no shell download or new test authorization inferred.
Conclusion: remembered API boundary exists and drove historical9.8 requirement;
need for a higher current minimum remains unresolved. Tested9.8.10 can be chosen
as conservative support policy, without claiming it is earliest API-compatible
version. Existing prose edits remain unstaged, dependency values unchanged.

## Isolated Org 9.8 signatures and compilation (2026-10-14)

User authorized task necessary networking/isolated signature checks. Independent
tmp/org-minimum-api reuses pinned nixpkgs node; source-only Org release_9.8 input
locked89df5bf46ba214db44eea898cc7cacc0b27fd760, narHash
sha256-+B/jG8uHl7oXrvMJO12PI6RL6FKoEphxzUw7p+SEAUQ=. Actual Emacs31.1/Org9.8
source load (no personal Org), compared to pinned runtime9.8.10. Only version/tag
metadata and upstream autoloads generated; actual upstream Lisp unmodified.
Static54 direct-call interfaces0 arity conflicts/4 generated unresolved. Actual
runtime resolves all54, checks41 function references and87 declared capabilities;
missing/conflicts nil. Definition paths belong to isolated9.8 for direct/reference
functions.13 production modules strict-compile with warnings-as-errors pass.
Final120s runtime98 build exits0/no warnings; no complete9.8 ERT/native validation.
Dynamic callback argument semantics are not proven by reporting signatures.
Representatives cache store/get/create, property-raw/properties-mapc, option helpers,
INCLUDE parser/reader/expansion, generated backend constructor/accessors all present.

Initial runtime Nix quote syntax failed evaluation; later generated-autoload loader
warned compressed-library recursive load. Bare pinned Emacs/preloaded cl-lib and
jka-compr/9.8 source priority correct harness; clean final run confirms actual
source paths. These failures do not establish Org incompatibilities. Source input
manifest13 modules SHA256cdc92d088bfc53f86b1772a9dd5ff9a0145edabd283a3d5712a931dacedf89a2;
static signatures SHA256322c56bdadf96dc551dc0b3337370bc70ef272df32dbe45e51b0942646120a7e;
runtime signatures SHA256e1feaf296cf6b691df1944f1e40eefe779ca9f9017efa8303dd135d9b3c4d68b.
Nine original-byte artifacts archived, reverified and archive-only checkpoint checked:
archive/2026-10-14T14-04-21Z--611cb70/MANIFEST.md. Probe files, flake/lock,
input manifest/comment patch, raw sexp reports and explanation retained. Duplicated
logs/upstream checkout/generated autoloads/bytecode/cache/products not selected.
Archived original patch contains four blank context lines with leading spaces;
diff --check warns but fidelity requires preserving bytes. Auto-review rejected
adding an explanatory note to captured manifest; safe alternative is this memory
note. Archive unmodified. No inferred project parent for uncommitted snapshot.

Conclusion supersedes earlier unsupported blanket retention/bump suggestions:
no API/signature necessity to raise minimum above9.8 demonstrated. Declared9.8
can remain for this boundary; full behavioral baseline9.8.10 is distinct. Values
and root lock/user mirror unchanged; prior doc/comment corrections still unstaged.
Prior doc-modification authorization used to refine README/main commentary after
results:9.8 API/signature/strict compilation passed, full ERT/native regressions
still9.8.10. Prose-only post-audit refinement, no executable/dependency value change;
archived input manifest/comment patch remains the exact earlier tested snapshot.

## Documentation staging and message preparation (2026-10-14)

User authorized staging and commit message. Exactly README.org/org-texmacs.el/
ox-texmacs.el staged, complete diff reviewed and diff --check clean. Staged blobs
match current worktree. Only prose/comment changes, no executable/dependency version
change; isolated signatures/compile evidence remains scoped as previously recorded.
tmp/commit.md replaces completed Phase6 draft: docs(package) subject, Chinese
ASCII-punctuation body, Refs: #1, #2 trailer. No new issue-closing or breaking
claim. Coherent single commit, split not necessary/difficulty low. User mirror
excluded and unstaged; no project commit or new builds performed.

## Documentation user commit verification (2026-10-14)

User reported committed. Read-only verification confirms parent is Phase6
611cb704567e677bc600c293c2d5a159e2e8f3fe, exact changed paths README.org/
org-texmacs.el/ox-texmacs.el. Complete committed binary diff SHA256
2db2062baf99f72e5f2f33ef25c5bc52ccaa8a69660d8d7d9c50ca246a2d5574
equals reviewed staged diff; all three committed blobs match worktree. Full message
equals tmp/commit.md, docs(package) subject and Refs: #1, #2 trailer. Index empty,
only user flake.nix mirror dirty. No new tests just for commit verification; no
executable/dependency version changes or external issue write. This checkpoint
associates the actual documentation commit inspected, not original provenance of
earlier signature runs. Raw signature archive remains immutable.

## Issue #3 export API and managed buffer acceptance (2026-10-15)

User selected implementation against memory/export-api-contract.md on inspected
baseline92476aa073238d1bc38809d4300985c5a444572c. Tested sources are the
uncommitted five-path candidate, not unchanged baseline commit. No candidate
project parent inferred; a later user commit can be verified by byte identity.
No ordinary staging/commit, version/INBOX/root-lock/external issue changes.
Existing user flake mirror retained.

Implemented three interactive frontend/five noninteractive explicit-source APIs,
exact rename map without aliases, PDF module separation, maintained special
preprocessing/bibliography/Document/Session/setup names. Conversion/provider
transactions, menu opt-in and naming/overwrite versus exclusive creation unchanged.
Managed result checks identity/token/name/tick/native-view attributes; rename/
edit/takeover creates a new result. Unique collision names stably reused. Source
death does not kill result; explicit views stay fresh/caller-owned/undisplayed.
Atomic change group protects content/point on commit failure, followed by undo
disable/tick refresh. Conversion failure preserves old result; display failure
keeps committed reused content, but removes only new allocations.

Ten new maintained tests cover lifecycle, actual partial-insertion rollback,
foreign/explicit results, takeover variants, cleanup/hooks/raw bytes/source state
and two independent compiled fresh-load processes. Existing native selection/
file/PDF/discovery/menu/HTML tests and real integration references synchronized.
Initial sandbox daemon socket denial handled by same authorized commands escalated.
Compiler caught renamed-reference docstring over80cols, fixed. First110focused
107pass/3fail: cancellation left undo enabled; compiled interactive-form omitted
mode metadata; legacy narrowing assertion called deleted prompt helper. Corrected
undo reset, assert command-modes, remove obsolete helper assertion while retaining
frontend restriction-change/pre-worker guard and explicit safety/command tests.
No pending failures. GNU Emacs supports command mode tagging:
https://www.gnu.org/software/emacs/manual/html_node/elisp/Command-Modes.html.
Actual compiled fresh processes verify signatures/ownership/commandp and
interactive nil with org-mode metadata; tagging does not replace runtime checks.
Remote issue3 and upstream Org fetches failed; no remote-state/Org comparison claim.

User authorized repeated exact120s focused/integration and240s full commands:

- timeout 120s nix build 'path:./tmp/issue-3-api#checks.x86_64-linux.focused' --no-link --no-update-lock-file --print-build-logs
- timeout 120s nix build 'path:./tmp/issue-3-api#checks.x86_64-linux.integration' --no-link --no-update-lock-file --print-build-logs
- timeout 240s nix flake check path:./tmp/issue-3-api --no-update-lock-file --print-build-logs

Final focused110/11083.751063s; real fixtures9/9 (first11.370098s,
final11.658110s); installed ERT396/396199.315532s. Complete gate exits0,
all6logged checks pass, including strict module compilation/package lint and
focused/integration derivations. Full gate reuses completed focused derivation
and reruns changed integration/core/lint inputs. Locked Emacs31.1/Org9.8.10/
TeXmacs2.1.5 with existing pinned Org-roam/include/organize/blog fixtures,
x86_64-linux only. No other-system/GUI/pagination or full Org9.8 behavior claim;
earlier minimum audit predates candidate. Whitespace check passes;25project+
11foreign inputs byte-match before/after gate. Five task paths plus untouched
user mirror dirty; ordinary index empty.

Exact final candidate SHA-256:

| Project path | Digest |
| --- | --- |
| README.org | b0f7c6b0bb588dfcdad16564c721c186b608b85437c4b9b7e79b2232c1bdb4fa |
| org-texmacs.el | ed98a6eefc3a53efef02326f041ea738bbf96572ad5d0fed97529943d7af708d |
| ox-texmacs.el | d3639caa37ff7e7b3a00055022278f7ae64893cd3eeee779f636b4da466e360d |
| tests/ert/ert.el | 72ece8c9482d7cab882633a04d64c155cb0fa2e05069985341ba60db3622d62b |
| tests/integration/phase4.el | 54d702d49752725cb7df7f3fe3b3b12c4d12625eb2a18eef5ceacb481d9c81f1 |

Project manifest SHA256b891870fbe55c8995e5d76f0d185215e7c094e2339ee89e2d59add753b121420;
foreign manifest f4ff7bb5ba39869e2e636b7233f1d129f858c09d01e1e70b42e395a2a9e1cb64;
isolated flake5127f7ca41e971305b0cd44c0f64226ec9f0809b9fa092f81205768373f2b825;
root/copied lock118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a.
Isolation derives from previous mirror-equipped Phase6 fixture with unchanged
lock/11extension modules, adds Org-roam only to test Emacs, replaces probe checks
with focused/real integration. Focused selector includes export-, serialization-export,
pdf-, preprocess, subtree, region, narrow, overrides, external names. Core/lint
and integration runner/phase4.el are maintained project tests. No ad hoc native
probe, business-logic mock or external-source patch.

Archive assessment under global/project archive skills: no raw capture selected.
Active plan/decisions extracted into durable contract; loading/lifecycle/rollback
reproduction is maintained in project tests. Transient logs/build products/duplicate
fixtures have no independent retention value here. Outcomes/commands/failure
causes/fixes/exact hashes/fixture context/limits extracted above. Incidental tmp
filenames/digests describe checks, not required semantic dependencies. Reassess
on INBOX retirement or independently valuable new evidence; no default whole
directory/conversation capture or tmp clearing.

User subsequently authorized exact-five-path staging and commit-message drafting.
Read complete staged implementation/doc/integration/ERT diffs and recent20subjects;
candidate is coherent, no split needed (medium splitting difficulty because API
definitions/callers/docs and lifecycle tests must remain coordinated). Each staged
blob matches accepted project manifest and worktree. Staged binary diff SHA256
756b192be25990ffdc68edcee2816cabe2fa47c3ff25dbbe0561ebbd653fe0b4;
whitespace passes, only user flake mirror unstaged, no new tests solely for staging.
The completed draft records the API/interactive/buffer migration summary.
Current committed message is authoritative as verified below; preserve the
preparation file without regeneration. No ordinary commit/external write by agent.

User committed the selected issue3 revision. Read-only verification of current
main confirms exactly five expected paths, parent equals investigation baseline,
five committed blobs match accepted input manifest/worktree and complete binary
diff SHA256756b192be25990ffdc68edcee2816cabe2fa47c3ff25dbbe0561ebbd653fe0b4
matches staged review. Complete message contains feat(export)! subject, four
Chinese bullets and adjacent BREAKING-CHANGE and Closes: #3 trailers; parsed
with git interpret-trailers. User explicitly judged selected scope complete and
intends issue3 closure. No remote push/status lookup or external write performed.
No tests rerun solely for commit verification; previous gates transfer by exact
byte identity. No ordinary commit performed by agent or new release/work selected.
This checkpoint associates the actual main commit inspected, without inventing
original test provenance. Ordinary index empty; only user flake.nix modification
present, untouched by memory maintenance. Completed tmp/commit.md is historical
preparation, not authoritative current message or an automatic rewrite target.

User also requested current document/comment synchronization audit. Against
current main, checked README API names/examples/migration and both buffer/file
policies, main/frontend export docstrings and related source old-name references.
No affected stale description found: three frontend/five explicit APIs, command
boundary, ownership/failure/display contracts and file policy agree. Old normal
names occur only in migration descriptions; retained special names intentional.
Scope is issue3-related documents/comments, not a new whole-project audit.
No raw archive selected: Git preserves commit evidence, substantive conclusions
are extracted here and in current memory; product source/docs unchanged.

## Issue #5: Org wrapper name case acceptance (2026-10-15)

User first requested diagnosis, then adopted case-insensitive Org block names
and authorized source/fragment/documentation/test edits plus GAW maintenance.
User supplied https://github.com/ren-lingyu/org-texmacs/issues/5 as association;
public page fetch failed, no remote content/state or closure claim/write.
The selected local request is implemented and validated in an uncommitted
four-path candidate on the committed issue3 baseline. No candidate project
parent inferred from unchanged HEAD; later commit can be verified by bytes.

Source predicate validates :type is a string before comparing downcase with
texmacs, without changing AST/source/body. Fragment ancestry exclusion now uses
the same predicate and explicitly requires the source module. Direct extraction,
document/island/scope validation, preprocessing STM shielding and bibliography
masking inherit consistent recognition. README distinguishes Org wrapper naming
from intentionally case-sensitive native STM and inline fragment tags. Worker,
native parsing, source ownership/cache, pure lowering and source output unchanged.

Five new maintained ERT verify162 combinations of BEGIN/END keyword casing,
opening/closing name casing and ambient case-fold-search (nil/t); raw body and
Org :type spelling remain unchanged. Nested block content excluded from inline
discovery while outer fragments remain discoverable and uppercase inline MATH
remains literal. Actual native conversion yields identical body/STM provenance/
serialized bytes for lower/upper/mixed wrapper types and preserves complete
source state. Root and actual included uppercase blocks shield INCLUDE/SETUPFILE
text without reading absent files; bibliography discovery ignores fake declarations
and citations in differently cased blocks. Existing invalid-node predicate test
now includes missing/nonstring :type, avoiding downcase type errors.

The initial diagnosis used exact local comparisons and published Emacs31.1 parser
source (special-block parser binds case-fold-search t and stores original type):
https://raw.githubusercontent.com/emacs-mirror/emacs/emacs-31.1/lisp/org/org-element.el.
Direct release_9.8 source lookup failed; actual locked Org9.8.10 maintained tests
now confirm the relevant parsing behavior, rather than relying on newer source.

User authorized repeated commands with necessary locked-dependency networking,
tmp snapshots/logs and Nix store/cache writes, no root lock changes:

- timeout 120s nix build 'path:./tmp/block-case#checks.x86_64-linux.focused' --no-link --no-update-lock-file --print-build-logs
- timeout 240s nix flake check path:./tmp/block-case --no-update-lock-file --print-build-logs

Focused114/11448.641846s passes; all five new cases pass, native2.147122s and
162case matrix0.032900s. Complete240s gate exits0:401core ERT204.454363s,
actual extension fixtures9/9 11.781628s and all6logged checks/strict module
compilation/package-lint pass. No corrective rerun or failure in this task.
Full gate reuses focused derivation and runs core/real integration/lint checks.
Pinned Emacs31.1/Org9.8.10/TeXmacs2.1.5 and same real include/organize/blog+
Org-roam fixtures as accepted issue3 isolation; x86_64-linux only. Other systems,
GUI/full minimum9.8 behavior unverified. No new runtime dependency or build wiring.

Before/after gate,25project inputs match root and isolated copied bytes;11foreign
Elisp modules match unchanged accepted fixture digests. Root lock unchanged,
user flake mirror untouched, ordinary index empty. Only four task paths changed:

| Path | Final SHA-256 |
| --- | --- |
| README.org | db7d41fee382bceb019e5b7115c6f2edc79b434a18966e9d3a8cc3b6dba31ce1 |
| org-texmacs-source.el | 18afa541de20383bf7df82ccb057d6bde63820ead9315319aa7bdd5d726dc1d9 |
| org-texmacs-fragment.el | eafb44d70a90d87ee7dc8f069c57e40aaafe7a2b8b7c5405a4faad48ffaad152 |
| tests/ert/ert.el | a610ff9505e31ad925b1e03f6e08de1803ab90299ee870688b841ecdf3c5fdb1 |

Project manifest SHA2569c5614d614d53a786fb4f18a2aa4f2fb641d272a49069088efedef45523076d0;
foreign manifest f4ff7bb5ba39869e2e636b7233f1d129f858c09d01e1e70b42e395a2a9e1cb64;
isolated flake07b58b8cff7ee8c4cae7ea1918ac76b2916284c4902058e85c92adaa9f5401f3;
root/copied lock118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a.
Isolation copies maintained test/package inputs and prior pinned fixture, retains
mirror-equipped flake/lock and optional test-only Org-roam, and changes focused
selector to block-case, test-block, test-tree, test-fragment, preprocess and
bibliography names. Actual integration uses unchanged maintained runner/fixtures.

Archive selection under global/project skills: no original-byte capture selected.
No ad hoc probe or retired document; maintained ERT preserves all new reproduction.
Build logs/copied dependencies/snapshots duplicate reproducible maintained checks;
results, semantic findings, exact inputs, commands and limits extracted above.
No whole-directory/conversation capture or tmp cleanup; external tracking separate.

User subsequently authorized staging and commit-message generation. Exactly four
paths above staged, complete diff reviewed:115 insertions/6 deletions; cached
whitespace check clean. Each staged blob equals the accepted manifest and worktree.
Complete binary staged diff SHA256:
21b8e79f0e73b61cddc3a641ab94bbdc93ec14ec482ffbf08315ac71dbfa0a13.
Only user flake.nix mirror remains unstaged. tmp/commit.md replaced the completed
Issue3 draft with fix(source): recognize TeXmacs block names without case,
four Chinese change bullets. User subsequently clarified that the accepted fix
should close Issue5; draft trailer changed to Closes: #5 and parser verified.
This records closure intent, not a remote issue state change.
One coherent predicate/consumer/docs/regression fix; split not necessary, low
difficulty. Existing acceptance transfers by exact byte identity; no new tests
solely for staging. No ordinary commit or external issue action performed.
No unique raw evidence selected for archive; staged findings extracted here.

User reported committing. Read-only verification confirms current main is a direct
child of the previous export API revision and changes exactly the four accepted
paths. Full committed binary diff SHA256 equals the reviewed staged digest above;
all four committed blobs match the accepted manifest and worktree. Full commit
message equals reviewed tmp/commit.md, including parsed Closes: #5. Index empty,
only existing user flake.nix mirror dirty. This checkpoint's project parent is the
actual inspected committed revision; acceptance transfers by exact byte identity,
no new tests solely for commit verification. No further implementation selected,
no remote publication/status verification or external issue write performed.

## Issue #6: owned temporary-buffer cleanup implementation (2026-10-15)

User adopted the reviewed plan and requested implementation plus continuous GAW
maintenance. Separate authorization permits repeated exact focused120s Nix build
and complete240s flake check under tmp/issue-6-cleanup, necessary locked-dependency
network/store/cache/logs, no root lock changes. User flake mirror is excluded.

Four new maintained ERT observe actual kill-buffer entry and invoke real destruction;
assertions occur afterward so observation cannot replace errors/cleanup. Private
objects registered through preprocessing context and actual Cite collector; a
separate modified user-owned buffer tests ownership after callback current-buffer
switch. Tests use real find-file-noselect source and test-owned files/directories.

First focused run with unchanged production intentionally fails4/4 in2.107358s:
all failures are the expected nonempty-file-name AND modified kill-entry assertion.
Independent root error, non-file-root INCLUDE capture and local bibliography paths
confirm all three affected lifetimes. This is runtime danger-state evidence, not
an observed interactive popup/stack trace. Before-production SHA256:
- preprocess:97f2899981f13f66176f43676172162df1145066cc66307a3772c73535ff63aa.
- bibliography:00ab1e3780fd8032e1f40f26a080a0e004053bc46f3032f1ffb603116e6fc132.
- new ERT:6d0ab8dfa181677393e5b20ac7eb06b363f80dfbdce0e694639d1d3c5035a684.
Red log focused-before.log SHA256
57bd3ed8fd802f2c8f4b197b0025717d96cd92218b4131b0c262b086adcead25.

Repair captures each owned object and uses unwind-protect to clear only that
buffer's file identity at final exit, including callback-switch/errors. Root and
INCLUDE in preprocess module; discovery callback in bibliography module. Lifetime
starts before context/file assignment. No global confirmation override, generic
buffer helper, source flag change or context loss during processing. Context/
snapshot/dependency guards, original errors, native and overwrite contracts retained.

Same focused command now passes4/4 in2.861718s. Actual native tm/PDF output with
source modified false/true x discovery false/true, non-file INCLUDE, local Cite/
direct preparation and12 error combinations (root/include/Cite x absent/existing
output x tm/PDF) pass. Original sentinel error, source text/point/mark/restriction/
modified/location, untouched user buffer, existing bytes and no new output on
preparation failure asserted. Strict byte/native production compilation passed.
Full240s gate is running; interactive Emacs no-popup verification requested from
user but not yet received. No full-acceptance or GUI result claimed at this point.

Isolated harness reuses prior proven mirror-backed flake, same root lock and11
unchanged pinned extension modules; focused selector is ^org-texmacs-cleanup-.
All25project inputs byte-match final snapshot; project-inputs.json SHA256
6ee3deb45b063a5e22c5a9072c1d8dab37f6bbd42525950a9b83356b45f222af.
Current changed production SHA256:
- preprocess:26b88e3a223e7797a389c15c63a34d47730f283b329c9f1129b983e8f0a10170.
- bibliography:a4fcc65c7f4a8b49c44b030595025024f802d57f332c32826de7e17fd1c80523.
ERT unchanged since red run. Commands:
`timeout 120s nix build 'path:./tmp/issue-6-cleanup#checks.x86_64-linux.focused' --no-link --no-update-lock-file --print-build-logs`
`timeout 240s nix flake check path:./tmp/issue-6-cleanup --no-update-lock-file --print-build-logs`

No raw archive selected so far: maintained tests plus project history reproduce
the before/after comparison; exact findings/digests/limits extracted here. No unique
standalone probe or retiring source. Reassess new evidence at final acceptance.
Ordinary index empty; only three task paths plus existing flake mirror dirty.
No ordinary staging/commit, INBOX/version/lock/external issue change performed.

Final exact240s gate exits0:405/405core ERT205.240427s, real pinned extensions
9/9 in11.484144s; all four check targets pass, strict byte/native production
compilation and package-lint accepted. Same focused4/4 result reused in full gate.
After gate all25project and11foreign inputs match isolated snapshot and unchanged
fixture sources; root lock matches copied lock, ordinary index empty. Only three
task paths plus pre-existing user flake mirror dirty. Task binary diff SHA256:
643872b4d9e92812a9b9204168d773a85625db1da477676b0d54a2814b4bf203.
Full check.log SHA256
58b5e4df75d8ed0c6a9d84fad71dd6d7508712454542d42e76d88b8fc0dd6ad6.
Extension-inputs.json SHA256
9438de1d9bc2b53a24eb465b20b268df2067ac4ff9027ac0e2364d35663de02f;
isolated flake f31552e14c7e7f69e7d8d24d652c5d9905d39b192d2be9d07189babae72d5e25;
root/copied lock118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a.
Environment locked Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux. Other systems,
full minimum Org9.8 behavior and actual interactive GUI popup elimination not
verified. User interactive check requested asynchronously and still unanswered;
implementation/automated acceptance complete, interactive acceptance pending.
No public API/support policy change requiring README migration; three private
cleanup comments document identity retirement. No ordinary commit/issue closure.
Final archive assessment: no unique transient probe or retired source, maintained
ERT + previous production history reproduce all new scenarios and expected-red
comparison; counts, hashes, commands, cause and limits extracted above. No raw
archive or tmp cleanup. GAW current/model/backlog synchronized to this state.

### Interactive feedback and INCLUDE configuration guard follow-up

User confirms no-INCLUDE interactive export no longer prompts, but INCLUDE fails
with "Bibliography transaction configuration changed". Supplied ignored fixtures:
tmp/realworld_test/test.org,6447bytes,SHA256
73e9e8da9310fa73561633efa410e9003883e8924db708b91cd2ca3e640985bb;
test_include.org,22bytes,SHA256
cf802a0cc4da13622c21546d9fbd4c847c8e1d020c5360024cda66c0f337dbc6,
contains #+INCLUDE: ./test.org. Included file has title, Chinese prose, native
snake-lemma graphics/math and equation STM. Original files left unchanged.

Isolated exact files pass preparation in clean Org context with discovery nil/t
(temporary fifth focused test,5/5 in5.052564s). Adding source-buffer-local
org-export-with-toc=nil to maintained full-native-file-exports reproduces exactly
the user's error (1/5 fails,2.483592s). Actual user's locals not inspected, so do
not assert their precise setting. Native INCLUDE calls guards in private buffers;
--bibliography-convert configuration-check previously read ambient options/style/
initial/globals instead of the captured source. This bug predates file-identity
cleanup and is exposed by this acceptance path, not caused by that cleanup.

Same authorized bibliography path now anchors configuration-check to source-buffer.
No condition removed or failure bypassed. Fifth maintained ERT changes true source
with-toc while current private buffer matches original snapshot; must still reject
with discovery nil/t. Source-local with-toc=nil added to actual native full export
regression, proving ordinary INCLUDE no longer produces a false configuration error.

Updated focused6/6 pass5.137303s with original preparation probe; upgraded exact
fixture probe performs actual frontend exports. Final focused6/6 pass8.088419s,
native fixture probe5.279271s: two user files x discovery nil/t x tm/PDF =8valid
native outputs with source state retained under with-toc=nil. Five tests maintained
in repo, one extra temporary probe loaded only by focused isolated harness.
No package mapping/rendering change. Revised complete240s check running; do not
transfer previous405core/9real acceptance to changed code without new result.
Current interactive acceptance remains pending reloaded-module retry by user.
