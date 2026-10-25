# Issue14 document information implementation

## Selected contract and local candidate

User selected the reviewed plan after the isolated experiments documented in
issue14-metadata.md. No font work, release-policy change, ordinary staging,
agent project commit or remote issue mutation is selected. User subsequently
committed the exact accepted candidate; delivery and external closure are
independently verified below.

Nine Org fields are captured through the existing restricted context adapter,
external plist validation and EXPORT_* subtree properties. TITLE/SUBTITLE/
AUTHOR/DATE are owned parsed secondary strings; EMAIL/LANGUAGE/KEYWORDS/
DESCRIPTION/CREATOR are owned plain strings. No metadata STM discovery.
Rich fields retain Org parse/join behavior; EMAIL/LANGUAGE last, CREATOR first,
KEYWORDS plain space-join and DESCRIPTION ox-html-style newline-join. Empty
metadata declarations must reach Org conversion instead of the old collector's
blank filtering; explicit nil is distinct from absence.

TITLE/SUBTITLE become doc-title/doc-subtitle under leading doc-data; title flag
controls both. AUTHOR remains one author-name, without heuristic splitting.
EMAIL becomes author-email with independent email flag, including email-only.
DATE retains the existing literal timestamp policy. creator:t adds a doc-note
labelled "Created by:", using the plain Org generator default when necessary.
Hidden metadata alone does not introduce default authors/doc-data.

Each abstract is reserved built-in abstract-data(abstract(document ...)), not a
formal statement or custom handler. Empty abstracts remain independent native
blocks; parameters and NAME/CAPTION are explicitly unsupported. Existing body
lowering and STM/file provenance apply recursively.

Whole-document KEYWORDS stays in the AST and lowers into independent
abstract-keywords nodes in source order. No nearby abstract ownership or empty
wrapper. Subtree/region consumes body declarations and inserts one effective
value after title/TOC, before the selected body: EXPORT_KEYWORDS replaces file
values; otherwise file values are inherited/space-joined. Source declarations
override external fallback. Selection pruning all positions also uses one
effective prefix. Direct owned INFO without a source adapter is supported.

## Initial environment and native boundary

Org file/external/subtree values override the corresponding native initial
defaults; priority remains global < external < file < subtree. LANGUAGE maps to
initial.language; DESCRIPTION maps to hidden global-subject (PDF Subject), not
an abstract. Explicit nil/empty effective value removes its corresponding
initial default. Without explicit Org language, preserve configured native
language; otherwise map captured org-export-default-language. Other initial
entries retain native source semantics.

Language identifiers use the explicit table documented in README and source,
case-insensitive after trimming. Nonempty unmapped effective codes error.
Includes the native registry's 27 identifiers through base codes plus explicit
en-US/en-GB/zh-CN/zh-TW aliases. Registry membership is not font availability:
native supported-language? additionally checks fonts for four CJK identifiers;
the maintained test checks supported-languages membership, not that predicate.

Read-only result slot/accessor initial-literal-keys defaults nil. Pure lowering
copies generated initial entries and marks literal provenance without encoding.
Native wire retains two-item entries for explicit source-semantic values and
adds third symbol org-literal for marked entries. Both boundaries reject invalid
provenance; encode before session mutation. Ordinary <alpha> remains literal,
and .tm serialization escapes its encoded angle notation. PDF Creator remains
TeXmacs; keyword nodes do not automatically populate PDF Keywords.

## Validation state and authority

User authorizes repeated exact command this task:

timeout 600s nix flake check -L --no-write-lock-file --max-jobs 2
path:/home/lingyu/Projects/org-texmacs/tmp/issue14-implementation

Isolation may write Nix store/cache/logs/products and fetch locked dependencies;
no root lock/index/result changes. Early iterations corrected isolation flake
syntax, test delimiter/serialization expectations and strict docstring widths.
Focused13core/2native/1PDF passed; PDF case prints and reloads generic/article.
Full intermediate run found blank collection mismatch (fixed) and two legacy
assertions needing mapped default language. Legacy snapshot regression now also
mutates default language during worker wait, proving coherent snapshot capture.
Five focused native cases then passed, including all29mapped language codes.

Final full gate passes (exit0, "all checks passed!") on85byte-equal root/copy
inputs, manifest at
tmp/issue14-implementation/input-manifest.json; original flake and runner restored.
All85root and copy hashes rechecked unchanged after completion. Main ERT inventory
is192core/321native/33PDF-document/27PDF-render =573, plus6patched default cases,
579total. Strict compilation, lint and dependency aggregates pass. Native321 runs
194.629306s; PDF-document33 runs93.848228s, PDF-render27 runs139.780124s in this
gate. Two styles' exported .tm files reload independently to PDF with exact
Subject/title/author and ordered visible markers. No font acceptance claim.
New maintained cases are16core/3native/1PDF in existing suites, not extra checks;
no prior case deleted. Optional9extension cases were not rerun this task.
Root lock/flake/index unchanged, no result link or ordinary staging/commit.
At gate completion the candidate was uncommitted; later user delivery is
verified below. No agent external tracking action performed.
No raw archive needed: distilled contract/evidence and current source suffice.

## Staged delivery review and draft

User stages all15paths; all85accepted input blobs match index, no unstaged project
changes, cached diff whitespace clean. Fresh issue reread has unchanged scope
and acceptance. Candidate resolves14 including explicit tested native limits;
user requests Closes footer when resolved. git-maintenance drafts tmp/commit.md:
feat(document): map Org metadata and abstracts to TeXmacs, with Closes:#14.
Single coherent feature, no split needed. No runtime rerun for identical inputs.
Expected project parent:8a2cf380d9f496c592b312b863a70f45f4afbd7b.
Message SHA256:78eddf61c737213cd20d59e55a33ee2f71f718dba3f9e833e2e3736b8034c9b2.
Binary full-index staged patch SHA256:
560e8df5be8cf40e1bc34e73b0dfee32bb988afd973ae524b1bd1de11cdf0cb3.
These fingerprints support subsequent delivery verification, not GAW semantic IDs.

## Verified user delivery and issue closure

User commits the reviewed15path candidate. Read-only verification establishes
the expected single parent, exact full-index binary patch, exact approved
message with Closes:#14, and all85accepted committed input hashes. Delivered
snapshot is the Issue14 feature commit, associated as a project parent of the
delivery checkpoint. This association grounds delivery equivalence, not the
original uncommitted runtime test provenance. No runtime rerun for identical
bytes. The new commit's reviewed delta is within the established source-history
retention boundary; its predecessor was already associated by prior memory.

GitHub connector independently confirms Issue14 CLOSED/COMPLETED,
closed_at/updated_at2026-10-25T17:29:52Z. No agent remote write. Implementation,
validation, user delivery and external closure are complete.

At delivery review the project index contained15additional staged paths including
Lisp, tests and Nix composition. No unstaged project changes. These later changes
are unreviewed/unvalidated here and excluded from the delivered acceptance claim;
agent did not modify or unstage them. User subsequently commits the formatting,
enables the formatting flake check and updates inputs; that distinct review and
README-only synchronization are recorded in post-issue14-flake.md. Original
Issue14 runtime evidence remains bound to its actual fixed inputs.
