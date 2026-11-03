# N3 native scripts: binding experiment and active candidate

Baseline is verified human N2 5ce20ef; all159accepted input hashes/message/paths
match and ordinary project/index was clean. N3 candidate is implemented, not yet
accepted or delivered. Adds only :with-sub-superscript projection and local pure
subscript/superscript lowering. Missing option defaults to t; nil retains marker/
braces and recursively lowers child objects, {} interprets bracketed nodes only.
This handles remaining late filter/Cite objects without repeating preparation.
Interpreted children use independent whitespace state inheriting metadata guards;
external whitespace resumes after the script. rsub/rsup remain outside opaque STM
roots. No parser/worker/source read in pure lowering; no model or worker protocol
extension, LaTeX/Citeproc field workaround or new public API.

## Native gate before production implementation

Isolated tracked-input snapshot: tmp/inline-objects-0.7.0/n3-probe-1.
Command: timeout 120s nix build --no-link --no-write-lock-file --print-build-logs
--print-out-paths path:./tmp/inline-objects-0.7.0/n3-probe-1#checks.x86_64-linux.inline-script-probe.
Native2/2 passes in2.641724s on x86_64-linux/Emacs31.1/Org9.8.10/TeXmacs2.1.5.
Output /nix/store/481azlpiwgwrgzb7z35acpll942g30nk-org-texmacs-inline-script-probe
contains native TM/PDF and script.png, explicitly viewed. Org properties show
separate consecutive objects, :use-brackets-p nil/t and recursive a_b content.
Native rsub/rsup in text mode bind to x after italic first, to bold x, to an
opaque math fraction, and within heading/table caption; text stays roman except
explicit emphasis. Nested subscript stays inside superscript body.

Coordinate evidence for prose x_i^2: base x box(161.52,84.220584,166.8,96.070584),
upper2(166.8,83.030584,170.783,91.682584), loweri(167.1,88.790584,169.361,97.442584).
Upper/lower attach at the same right edge with smaller font and proper vertical
placement. Similar coordinate relations hold for bold/heading/caption and fraction.
This and direct native readback, not mere tag existence, selects native right
scripts without switching entire paragraphs into math. The prototype does not
claim arbitrary font/style/platform or GUI behavior.

## Candidate verification and retention

Eight planned maintained cases: pure fixed options/ownership/nesting/whitespace/
opaque STM, disabled recursive child markup, metadata line-break/file-link guards,
normal versus positionless filter output across t/{}/nil, late INFO metadata,
Cite-generated scripts, exact native tree/provenance and actual PDF binding.
The PDF fixture checks base/right-edge alignment and relative height/size in
prose, styled bases, headings and captions; nested attachment and adjacent fraction
scripts, plus saved TM reload raster equality. No fixed image baseline.
README/root summary/detailed notes updated. Full checks and diff acceptance still
pending. Exact frozen focused snapshot is tmp/inline-objects-0.7.0/n3-focused-1.

Retention assessment at native experiment: maintained structural/reference/layout
cases and these code/version/coordinate facts will preserve meaningful proof if
they pass. Raw parent-heavy Org logging, entire tmp tree or binary PNG/PDF are not
selected for GAW archive. Final acceptance will revisit retention and keep exact
source inputs; no need to archive every successful temporary probe by default.

## Focused gate passed, full verification active

N3 focused8/8 passes in6.798610s. Output:
/nix/store/avi4pr4ry0aq9f3g5x56gc21z7jc9q2w-org-texmacs-inline-script-focused.
Initial6/8 failure concerned fixture representations, not native/option behavior:
Org consumes standard :post-blank from its supplied property plist, so a quoted
plist reused across iterations lost that property on the second construction.
Fresh list allocation preserves the original assertion. Native reference was
corrected to the existing separate emphasis post-blank string, without merging
adjacent text. Isolated diagnostics proved the root cause; production lowering
was unchanged. All eight original semantic targets then pass. No waived checks.

Formatting of ten changed paths exits0; after these fixture repairs two targeted
files formatted again, whitespace check clean. Full frozen159input snapshot and
controlled existing integration drivers: tmp/inline-objects-0.7.0/n3-full-1;
input manifest/log alongside it. Disclosed command is timeout 600s nix flake check
--no-write-lock-file --keep-going --print-build-logs --max-jobs 2 path:SNAPSHOT.
Full acceptance not yet claimed. Source and tests remain fixed during that gate.

## Full-1 counterexample and adopted regression correction

Full-1 exits1: native273/275 with two legacy should-error cases failing because
exports now succeed. Other groups pass, including new native script/PDF cases.
Failed legacy cases: issue13-stage2-scoped-selection-and-clipping and
issue13-stage3-region-restored-wrapper-completeness in native special-blocks.el.
Their region cuts leave unclosed #+begin_equation* or #+begin_table markers.
Final Org AST has no native special block/islands and instead contains subscript
objects in ordinary prose (including selected footnote bodies). Earlier failure
was incidental unsupported-script rejection, not an effective native-block guard.

Isolated standard-HTML counterfactual, n3-scope-probe-1, passes1/1 over equation,
plain footnote and Footnotes-heading variants. Both final texmacs AST and HTML
interpret the clipped markers as prose with equation/table subscripts; no worker
parse call is allowed. Output:
/nix/store/3cmvg2mzbb00jnli2b6m5v9raww3j8la-org-texmacs-inline-script-probe.
The initial user-facing full-check status missed earlier errors by reading only
the log tail; corrected immediately after complete failure search, no acceptance
claim or checkpoint made from that mistaken status.

Apply the already approved Org-structure-first decision: do not restore original
wrapper completeness or add source protection to reproduce incidental errors.
Revise these two regressions to require no effective native block/islands, no
native parser, correct prose subscript and expected footnote inclusion/exclusion.
Retain valid native-block selection and genuine malformed STM/error checks.
Document this observable selection behavior explicitly. This is a tested semantic
consequence of adding valid Org objects, not a waived native integrity contract.

The cross-backend experiment has independent causal audit value beyond a new
positive TeXmacs assertion: select minimal text drivers/control output plus a
baseline-relative two-module patch and input hashes for archive. Exclude routine
full logs and binary artifacts. Record immutable archive locator after capture.
