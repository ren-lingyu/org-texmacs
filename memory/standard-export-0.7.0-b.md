# Stage B: late prepared AST adapter

Stage A human delivery4f03ee4 is verified: expected parent/message/11paths and
all133accepted hashes, clean ordinary index/worktree. Stage B is now active.
Isolated143baseline inputs and source-manifest are in
 tmp/standard-export-0.7.0-b. Prototype uses the actual texmacs identity and
public org-export-as, overriding only final input construction for the probe.

Initial daemon access was sandbox-blocked; same authorized Nix command succeeds
outside sandbox. Early scripts had a corrected extra parenthesis and quoted
fixture typo. Strict compile caught missing worker dependency and unsupported
while-let* spelling; fixed explicitly. The predicted Org normalization loss did
NOT occur on the multiline fixture; reversed assertion is recorded as a rejected
hypothesis, not evidence for earlier protection. Heading-looking native string
lines cross Org structure boundaries (no native block remains), consistent with
existing supported syntax limits; indent such data. No new protection justified.

Attempt7: exit0,10/10 in1.965603sec with strict byte/native compilation. Tested
final AST object splitting and faithful interpretation for selected inline/native
fixtures, positionless synthesized nodes/explicit native source property, owned
ignore-list projection, boundary errors before worker and four actual native
islands through lowering. Runtime Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux.
This prototype result alone is focused feasibility; maintained acceptance follows below.

Adopt a thin source-coordinate-independent adapter. Copy final tree with existing
owner, map Org ignore identities into that copy, derive complete native input
from final structured contents or explicit :texmacs-source, and parse once.
Inline Org objects contribute syntax only wholly inside a quoted STM string;
actual object boundaries, incomplete STM and missing complete native input fail.
No whole-buffer reparse, source-position authority, earlier protection, INCLUDE
recursion or third AST. This selected architecture is now implemented and
verified through maintained tests and the complete gate described below.

Retention review: rejected normalization hypothesis is fully reproduced by the
fixture recorded above and the retained probe. The final selective retention
review and immutable capture are described below; no whole directory or binary
archive is needed. Uncaptured tmp files are not immutable evidence.


## Maintained candidate and focused validation

New org-texmacs-prepared.el owns final AST and remaps ignore identities, removes
consumed control directives without merging options, derives affiliation from
final properties (RESULTS already consumed), and discovers complete STM input.
It never uses begin/end/source buffers to identify islands. Adjacent plain text
can join a synthetic prefix. Interpreted Org objects are accepted only wholly
inside a complete STM string; target raw/opaque interpretations cannot be
absorbed. Native blocks support final structured contents or explicit complete
:texmacs-source. Known Org boundary failures remain explicit, no early protection.

Maintained native tests exposed code :value as a still-deferred vector after
org-element-map(identity), whose owned copy could not resolve it. A diagnostic
read printed RAW [org-element-deferred org-element--substring (1 8) t] then
RESOLVED "literal" and made the fixture pass. Public API documentation confirms
org-element-properties-resolve resolves all fields and FORCE overwrites values.
Production now calls it without FORCE on final nodes/secondary INFO while live,
preserving AST-filter writes. This replaces the insufficient A identity-map
assumption; no advice/copy of private Org preparation. Babel RESULTS previously
tripped source-position affiliation checks; structured affiliation fixes that
while unsupported attrs still fail, including positionless nodes.

Ownership review additionally moved input/context/function freezing before the
first worker wait. Like the independent parser, private placeholder islands are
owned first, filled exactly once from the native parser, then references are
allocated after actual static labels exist. Partial inputs never escape and
errors preserve native conditions. Source tag settings join mutation checks.
Regression mutating a formatter definition during a wait proves owned function
identity; no callback replay or restoration of arbitrary user code.

Focused attempts:1 core275pass/native4of6 (code/RESULTS defects);2/3diagnostics
confirmed deferred value;4strict compile stopped on81-character docstring;
5core278/native6pass;6final core280/native6pass after wait-ownership/raw guards.
Final focused6: core280/280 in1.662638s; native six cases in10.923344s, zero
unexpected, strict byte/native compilation passes. Native matrix includes Org
markup, inline notes, texmacs/equation/equation*, Unicode and rich title code;
generated macro/Babel/recursive INCLUDE, synthetic replacements and malformed
native inputs are exercised. The subsequent formal12check gate used
600s/max-jobs2/keep-going on the same144root inputs; final acceptance follows
below. The temporary native-only overlay was removed before that full gate.
No root lock/result/Git index changes. Exact active snapshot/logs are under
 tmp/standard-export-0.7.0-b-production; no other-platform/minimum9.8/real extension
acceptance claim. Stage C-E remain pending after the human B delivery gate.

## Selective retention review

Final10-test prototype and replay inputs/log/report were original-byte verified
and archived separately at
archive/2026-11-02T18-33-35Z--4f03ee4/MANIFEST.md (nine text files plusmanifest).
Its project association is the exact committed baseline4f03ee4, not current
uncommitted B production. The report distinguishes harness failures/rejected
normalization assumption from actual counterexamples. Later diagnostic script
was temporary and removed; focused3 log remains in tmp, while its relevant raw/
resolved values, API contract and maintained regressions above preserve the
necessary conclusion. No exact diagnostic-script capture is claimed or needed.
Routine production logs/caches/full copied trees do not need raw archiving.


## Final acceptance and delivery gate

Formal full-1 exits0/all12checks pass. Exact core280 result from focused6 is
reused; fresh native345/345 in238.502440s, PDF-document33/33 in93.905916s,
PDF-render29/29 in156.815891s and patched6/6 in2.943279s yield693ERT/zero
unexpected. Strict byte/native compile, lint and treefmt pass. Runtime/platform
limits above remain; no other-platform/minimum9.8/real extension claim.
Full log: tmp/standard-export-0.7.0-b-production/full-1.log.

Accepted exact snapshot: memory/standard-export-0.7.0-b-inputs.json. All144root
and isolated file hashes match; HEAD4f03ee4 and ordinary index unchanged. This
manifest contains all143tracked baseline files plus prepared.el. The A accepted
manifest covered133inputs, excluding LICENSE/.gitignore/eight historical release
manuscripts; blindly carrying its count into B was a prose error. The immutable
B archive manifest/report also say133baseline inputs; read that as143, confirmed
by its original JSON/hash list. Captured bytes and experiment results are exact;
do not edit immutable evidence to hide the count correction. Earlier assertions
that the B production copy had134inputs are corrected to144 here.

Six ordinary candidate paths: README, CHANGELOG, export.el, new prepared.el and
two maintained standard-export suites. README/CHANGELOG now describe the bridge
and adapter;3complete/1ongoing/10pending feature boxes, TODO unchanged. No version
bump/CLOSED/CUSTOM_ID. tmp/commit.md, using the approved worktree-diff workflow,
contains feat(export): adapt prepared ASTs and native STM islands, four Chinese
bullets, no breaking/issue footer. One coherent feature; no split needed.
No ordinary staging/commit. Await human B delivery, verify expected4f03ee4parent,
complete paths/message and all144accepted hashes before C. Do not rerun unchanged
passed gates merely for delivery. Keep source/native consumer/AST-first and early
unsupported node-filter boundaries. Standard references/footnotes/selection,
Cite/real-extension and public convenience migration remain C-E work.
