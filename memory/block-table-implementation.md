# Issue4 block repair and separate table alignment

User selected implementing reviewed INBOX plan A+B as separate deliveries.
Baseline main is the committed Issue6 repair; original source25input manifest
captured in isolated tmp/issue-4-block-table. Root user flake mirror remains
untouched and ordinary index empty. Public APIs, date/metadata, NAME redesign,
async, font/footnote/PDF-link/pagination policy excluded. Completing A+B does not
close allIssue4. B has separate created open Issue8:
https://github.com/ren-lingyu/org-texmacs/issues/8.

## Adopted contract and implementation

A uniformly lowers quote-block to quotation(document...), including one/multiple
paragraphs, nested lists/containers/STM. No shape-dependent quote-env choice.
Center/code/list mappings retained after bounded native comparison. Code retains
existing indentation/-i/tab-width expansion/literal semantics, no Babel/STM parsing.

B permits zero or ONE independent complete alignment row anywhere. Every field
is plain<l>/<c>/<r> after whitespace trim; number of fields matches data columns.
Duplicate/identical/conflicting format rows reject, no merge/priority/repair.
Partial or mixed cookie/data rows, width cookies, formula/group/special-column
semantics remain rejected. At least one rectangular data row. Remove format row
before border numbering; newly adjacent rules still reject. Generate one column
cwith(1,-1,c,c,cell-halign,l/c/r), then existing border directives/table. No format
row -> existing output/no numeric alignment inference. Captions/names/references,
typed file targets and STM provenance remain in shared structural packing.

Pure validated-row classifier detects known cookie fields even when Org doesn't
classify mixed rows as special. For format tables only, independent org-element-copy
view omits the format row before Org special-column check. Prepared AST/parents
never mutated; maintained owned-AST snapshot assertion passes. This avoids a valid
format row masking a formerly unsupported special column. Native table-facts
probe on pinned Org establishes both behavior boundaries. Literal<alpha> and
inline-verbatim<r> remain text, not format directives.

## Verification and evidence

Locked Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux independent flake,25project+
11fixed extension modules, no system Emacs. Exact authorized commands use
path:./tmp/issue-4-block-table with --no-update-lock-file:
120s nix build checks.x86_64-linux.probes;
180s nix build checks.x86_64-linux.focused;
120s nix build checks.x86_64-linux.integration;
600s nix flake check (complete checks). Builds add --no-link --print-build-logs
--print-out-paths; full check adds --print-build-logs. User explicitly authorizes
repeated sequential commands, necessary pinned dependency network/store/cache/tmp
writes and native JSON/text/PDF result reads/copies; no root lock or original
example writes, no ordinary staging/commit.

Baseline native10records: old quote yields visible hquotej... markers, native
quotation removes them and indents30pt. Center paragraph midpoints coincide;
code remains literal, lists have separate Org/native constructs. AST/tree/native
readback/PDF coordinate records retained as selected diagnostic evidence. First
probe write hit encoding selection due undeclared UTF-8 bbox subprocess output;
fixed diagnostics only. Baseline successful log prints1record because nreverse
mutated list before log count, actual JSON has10records; later script count fixed.

Valid baseline focused17tests:15pass/2new failures (uniformquotation/PDF layout),
then A focused17/17pass9.764553s. First invalid focused attempt was missing closing
parenthesis in newly added test; corrected before actual baseline, not product
failure. A native10records + Org helper facts pass; real extensions9/9pass
11.892089s. A patch/a-inputs manifest and reconstructed3source files byte-match.

B tests on A:17/21pass, exactly4new tests fail. After B implementation21/21pass;
one additional caption/reference/typed-file/STM combination regression justified
final focused22/22pass13.648062s. Includes counts1/2/4, format positions0/1/2,
border indices,12rejection inputs, source/AST preservation, native3column actual
PDF geometry, standard tm/PDF export, and retained existing width negative.

PDF regression uses Poppler -bbox parsed as UTF-8 XML, matches unique ASCII words
to explicit native references within1pt; positive indentation and column-edge/
midpoint checks. Existing normalized-text helper remains unchanged for content.
No pixel/font/page-count golden. Successful native/header/layout checks establish
bounded semantics, not arbitrary style/GUI/all-platform rendering.

First full gate:412/413core pass; one named-footnote test retained oldquote
expectation. Corrected that A expectation in root and reconstructed A candidate.
Expanded focused selector to include that existing case. Review also replaced
introduced filtered-row membership scans with format-row identity exclusion,
avoiding quadratic work for aligned large tables. Final25inputs refreshed;
final focused23/23pass13.694420s. Final complete flake check exits0:
413/413core212.650622s,9/9real11.469430s,native10records,strict compilation/lint.
Other systems omitted;25final source snapshots/11extensions/root lock unchanged.
A/B patches apply consecutively to baseline and reproduce all three final files.
A patch includes the later footnote assertion correction; A-focused log predates
that correction, final combined focused/full validate it. No separate final-A-only
fullgate claimed. Ordinary index empty; user flake mirror untouched.

Selected23necessary pure-text originals archived byte-exactly, verified with
source stability and digest checks, in separate archive-only checkpoint:
archive/2026-10-15T11-15-33Z--4839029/MANIFEST.md.
Includes before/after native reports and Org helper facts, valid red/green logs,
first failed/full successful gates, reproducible harness/lock/source identities and
independent A/B patches. No binaries/PDF/dependencies/full tmp capture. Remaining
useful findings and adopted contract extracted into memory; INBOX/current proposal
needs no raw archive. No inferred project-parent for uncommitted candidate.

Implementation/validation complete, README/comments/tests synchronized. Issue4
remaining audit stays open; Issue8 tracks implemented B independently. External
closure/release not performed. Next user review, then path-scoped authorization
before staging A patch only and preparing its commit message, preserving B for
separate delivery. Ordinary commits remain user's responsibility.
