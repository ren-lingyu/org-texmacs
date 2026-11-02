# Stage B final-AST feasibility experiment

Historical evidence, not current instructions or full release acceptance.
Baseline is committed4f03ee4a5997e7f5d8e96b155954fdcb2b361aa4,133tracked
inputs copied byte-for-byte; source-manifest.json records their SHA256s.
The added prepared.el and test overlay are task-authored experimental changes,
not files from that baseline commit. The production adapter has subsequently
received additional ownership/deferred/affiliation fixes and maintained tests.

Reproduce by checking out that baseline into a separate ordinary directory,
verifying the133manifest hashes, then adding archived prototype/overlay/test
files at their paths relative to project/. Use copied flake/lock unchanged.
Command (replace the absolute source path for the restored directory):
 timeout 120s nix build --no-link --no-write-lock-file --max-jobs 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs/tmp/standard-export-0.7.0-b/project#checks.x86_64-linux.standard-export-probe -L
The public texmacs backend uses standard org-export-as; only final input
construction is overridden for the focused adapter experiment. No recursive
INCLUDE, private preparation advice/copy or complete frontend migration.

Final attempt7: exit0,10/10 in1.965603sec, strict byte/native compilation;
Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux. Tests establish object splitting
inside quoted STM, complete structured input for positionless nodes, selected
native-body interpretation equivalence, identity-keyed exclusion, invalid
boundaries before native calls, and four actual parsed/lowered native cases.
The ignore-list diagnostic prints nil and is NOT proof that the footnote fixture
uses logical exclusion; the separate explicit ignore-identity test supplies
that evidence. The headline-looking native string crosses an Org structure
boundary: the final AST has a headline and no native special block.

Rejected hypothesis: attempt3 expected `(document "a\n  b")` raw native text
(normal source newline) to change under Org interpretation. It did not; the
assertion failed and was reversed after inspection. This is no reason to add
earlier protection. Attempt4 extended the matrix but had an incorrectly escaped
quoted fixture, fixed before final validation. Attempt1 never ran because the
sandbox blocked Nix daemon access; identical command was allowed outside it.
Attempt2 had an extra closing parenthesis. Attempts5/6 were strict-compilation
failures from missing explicit worker dependency and unsupported while-let*
spelling. Final sources are retained; failed script versions were not separately
captured. These are harness errors, not successful architecture evidence.

Select this final fixture/prototype/replay input identity and necessary log
because it preserves the tested thin-adapter hypothesis and explicit structure
boundary controls. Do not retain entire worktrees, native caches or binaries.
Later production diagnostics are distilled in memory/standard-export-0.7.0-b.md
and maintained regression tests; this snapshot does not establish their result.
