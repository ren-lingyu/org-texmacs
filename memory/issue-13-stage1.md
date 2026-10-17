# Issue13 stage 1: recursive blocks and formal statements

## Current state and authority

User selected the reviewed plan for implementation on2026-10-17. Ordinary
candidate modifies exactly document lowering, input ownership, source adapter,
ERT and README. HEAD remains82d7aa131043d2683c6e303413ee95ccf51da7de; candidate
is uncommitted/unstaged. Preserve user flake.nix ELPA mirror workaround, exclude
it from delivery; no lock/version/INBOX or external issue changes. Full Issue13
remains open work: equation/figure/table/NAME and weak anchors are later nodes;
Issue9 independently named composite constituents stays post0.5.0.

Foundation A/B is one reviewable node, with statement as the second logical
node; code is not staged or user-committed as either node. No stable public
handler API, defcustom, module, dependency or worker protocol added.

## Implemented contract

Native texmacs blocks remain opaque and take precedence. Other special blocks
recursively prepare existing paragraphs/fragments/children, including scoped
and recovered footnote dependencies. Pure lowering wraps child results in
document, then explicit statement tag or captured private handler. Existing
container context admission extended narrowly; naked tables and bare/mixed
display semantics preserved. Affiliated NAME/CAPTION/ATTR remains rejected on
ordinary special blocks; existing table semantics unchanged.

Private registry: alist, copied lowercase nonempty single-token keys, reject
duplicates/reserved texmacs/statement/statement_* and statement type aliases.
Resolve function symbols at option capture; input ownership copies registry
shell/strings, retains captured function definitions. Pure lower uses INFO only,
defaults to empty handlers. Mutable captured closure state is not frozen.
Handler(block, contents, info): read-only arguments, returns stree; no source
reads/native work. Arbitrary user callback effects are not sandboxed.

Contents mutation detection snapshots original cons edges and string values,
then checks those objects without recursively following a corrupted graph.
Before output copying, validate stree/cycles; locate contents root exactly once;
reject external sharing of every original descendant cons/string, including
list spines. Prefix both STM and file paths by the discovered identity path.
Root topology/value preservation plus prefix construction preserves path targets.
Deep-rebuilt source-semantic duplication is forbidden by callback contract, not
claimed mechanically detectable. Equal independent ordinary strings remain valid.

Preflight copies INFO and sets a private temporary marker for lower only;
unknown source/metadata/type/registry errors reject before BODY STM requests.
Bibliography requests may already have occurred. Walk custom contents but never
invoke custom handlers on placeholders. Marker does not enter final input.
Handlers execute when real input is consumed, including no-STM inputs; invalid
final output leaves parser worker usable, with source guards/cleanup unchanged.

Statement syntax: statement TYPE exactly one token; statement_TYPE/direct TYPE
no parameters. Case-insensitive explicit native-tag whitelist; example-block
retains Org literal interpretation. All16 candidates verified with native
generic style: theorem/proposition/lemma/corollary/axiom/definition/notation/
conjecture/remark/example/note/warning/convention/exercise/problem/proof.
No bespoke nesting/title/ATTR grammar. Native style owns numbering. Other styles,
GUI use and new object-level labels are not certified by these tests.

## Verification and diagnostic limits

User authorized repeated commands:

1. timeout300s nix develop --no-write-lock-file path:. --command emacs -Q
   --batch -L . --load tests/ert/ert.el --eval
   '(ert-run-tests-batch-and-exit "issue13")'
2. timeout600s nix flake check --no-write-lock-file path:.
3. timeout120s nix build --no-link --no-write-lock-file path:.#default
4. Replacement focused environment, timeout300s nix develop
   --no-write-lock-file path:.#checks.x86_64-linux.ert --command emacs -Q
   --batch -L . --load tests/ert/ert.el --eval
   '(ert-run-tests-batch-and-exit "issue13")'

All scope this task, may network/write store/cache/logs/native temporary files;
no lock updates/result links. Nix daemon requires sandbox escalation; first
sandbox attempt failed before tests, same authorized command then approved.
Default devShell lacks Poppler: first9/10 then13/14 pure-focused results did not
accept the native test. Existing ERT derivation environment supplies Poppler,
without changing flake. Subsequent failures were fixture-only: reused exclusive
reference.pdf target; Definition PDF fi ligature (normalize NFKC); missing
explicit ucs-normalize require. Native title test now requires real numbered
environment title (proof unnumbered), not arbitrary tag parser acceptance.

First full run488 tests:486passed,2failed in311.738724s. Native filename failure
already fixed; snapshot fixture incorrectly assumed custom output was first
top-level child, while full-suite options introduced doc-data. Corrected to
assert exact expected initial wrapper among top-level children, keeping function
capture check. No production change from these fixture diagnostics.

Final focused17/17pass19.993503s,2026-10-17T09:13:48Z. Includes real parser,
worker failure/recovery, all16native PDF comparisons against independent native
expected bodies, saved tm for each, theorem/proof reload geometry within existing
1pt tolerance. Source/island paths checked; PDFs require native titles/counters,
not just visible body text. Runtime artifacts isolated/cleaned by maintained
fixtures; no permanent PDF archive needed. Public package build exits0.
Final full495/495pass326.837943s,completed2026-10-17T09:18:57Z; full flake
exit0 (strict package compilation/lint included). Final no-link package build
exit0. Stage1 locally complete/accepted, still unstaged/uncommitted. Same locked
x86_64-linux inputs as preceding Emacs31.1/Org9.8.10/TeXmacs2.1.5 baseline;
other platforms not checked. Interim495run before metadata assertion repair:
494passed/1fixture failure327.522964s, not final acceptance. Final all7below
input hashes match after gates; no production changes since native acceptance.

Final candidate SHA256 (unchanged after final focused/build start):

| Input | SHA256 |
| --- | --- |
| org-texmacs-document.el | 8feb633a79df2fe1343f37b5aeccb9345a3edaa5aee92da5eaf07e41c97457eb |
| org-texmacs-input.el | 15dc9e9211697d66d69cd38413031f0c122cee4b6f19c329275fa6c838739575 |
| org-texmacs.el | 68324674339157807691726f363c22ae2141959e8f2603cd3b7a2b1384b08146 |
| tests/ert/ert.el | eaade2d3c6d419f4452f60890dc94218086c80959794368a5f68971e7d58a256 |
| README.org | f6d5dbb9a22785f0679b8d9a1c269c101a3692fa068875af731ac18de4f04d5c |
| flake.nix (user workaround) | a717dcfa245b1ccaee102ed8eef3a6ae229d0c86b60f674080bab5273d093a8a |
| flake.lock (unchanged) | 118fef565c931d48ea082daeea2b28e50aa0957035948d4adb3912b2e3c7505a |

Tests also cover scalar/body/list/table/center/quote content, literal example,
source aliases/errors/metadata, snapshot symbol rebinding/registry mutation/filter
owning, root/descendant/string/spine sharing, equal topology replacement/cycles,
pure interfaces/source preservation, scoped/narrowed requests/notes and source
mutation during wait. Preflight bibliography/no-bibliography cases are distinct.
No weakening of existing ERT assertions or business repair of unrelated gaps.

Current next action: user reviews five-path unstaged delivery; explicit ordinary
staging authorization still needed, ordinary commit remains user's action. No
stage1 code/check work remains. Memory coordinated across current/project/goals/
backlog/release/evidence. No project parent inferred for uncommitted provenance.
No automatic next Issue13 node or release action selected.
