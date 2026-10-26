# INCLUDE raw snapshots and interpretation views

## Selected scope and implementation

User adopts the unified repair after isolated probes, then requests implementation.
Five ordinary project paths change: preprocess/source Lisp modules, core/native
preprocess regressions and README. No public signature, worker protocol or pure
lowering change. Agent performs no ordinary staging/commit or stash application.
User subsequently commits the exact repair; delivery verification is below.

Capture now owns only validated local UTF8 raw text and receipts. A separate
view cache keys normalized file and interpretation mode. Literal src/example/export
and native-body inclusion read independent copies of raw snapshots without STM
discovery. Ordinary Org uses the existing line-preserving protected view;
ordinary block views discover STM in their actual wrapper context. Cached views
do not count as newly acquired source bytes; existing occurrences/depth/working
limits and repeated receipt verification remain.

Scoped org-export--blindly-expand-include establishes the current mode for both
readers and selection helpers, nests/restores on error and joins function-identity
guards. Native-body wrapping selects raw text via Org first, then shields the
complete generated block without parsing its body as Org. Shared name-to-kind
classification recognizes texmacs/equation/equation* without an AST. Org's parser
requires quoting the equation* wrapper name; unmatched residue still rejects.

Only Org-content modes check selections against STM spans. Literal modes retain
native source escaping, fixing malformed-STM discovery, false partial-selection
errors and premature source termination after restoration. Ordinary wrapper
recursion/options follow native branch behavior, not an invented common policy.
Explicit encoding override/unmatched/path/identity/budget/configuration checks
remain. Final AST conversion still rejects unsupported export/header semantics.

## Verification state

Host Emacs31.1/Org9.8.7 focused26/26pass. Final isolated locked full gate exits0:
203core/323native/27PDF-render/33PDF-document/6patched=592ERT, strict package
compile, package-lint, treefmt and aggregates pass. Final review includes
normalized relative reader paths and returned-copy isolation. Formatter is authorized
for exactly the four changed Lisp files, not the whole worktree. Initial load
parentheses, formatting differences and a quote-vs-quotation test expectation
were corrected; do not count those failed intermediate runs as acceptance.

Final85tracked runtime/build/test inputs match the isolated check copy;
inputs.sha256 is retained under tmp/include-view-implementation. Manifest SHA256:
7954bfdda7d671d782ac4a7202d05ef1b76d499ba381dbea1a114e69c876c6cc.
Complete five-path binary diff SHA256:
97e04a3040c907a49b36277ca633e2e3b45e75f4a50899f49748755e10142587.
These identify the originally uncommitted tested candidate. User delivery now
matches the expected single parent, full five-file binary diff, all85committed
inputs and exact drafted feat(preprocess) message. Worktree/index clean and lock/
stashes unchanged. Delivery project association grounds that read-only equivalence,
not a committed-state test rerun or reconstructed original test provenance.
The message has no issue footer; no tracking lookup/write is needed. Temporary helper
scripts are ignored and not package/test inputs. Full gate uses timeout600s and
`nix flake check -L --no-write-lock-file --max-jobs 2` against that explicit path.
User authorizes repeated exact focused/full/docs commands for this round only.
Complete ERT outputs are under
/nix/store/s42qb4rlf76hdz95ibh1ifz2x50ymz4d-org-texmacs-ert;
core1.399367s, native205.289423s, PDF-render140.040671s and PDF-document100.953760s.

## Separate documentation acceptance

Latest docs stash is read-only extracted into tmp/include-view-documents,
not applied. Raw draft encounters two independent errors after INCLUDE succeeds:
bare EXPORT_TITLE in metadata tables creates unsupported subscript AST, and
matrix STM lacks a closing parenthesis. Four temporary Org files correct these;
draft-fixes.patch contains only these corrections for later user review.

Temporary package verification adds failed-STM logging and a fresh native process
that reloads each saved .tm, renders PDF and compares whitespace-normalized text
against direct rendering. It also requires the included configuration identifier
org-texmacs-worker-request-timeout in PDF text. All six final-source en/zh guide,
mathematics and figures-tables leaves pass and aggregate build exits0. Final output:
/nix/store/96fryj9mpj8pcaqkyzb19gw1xdbd9d64-org-texmacs-documents.

This accepts the corrected isolated draft, not unchanged stash package readiness.
No production docs/package edits, default checks/apps/CI additions or font work.
No visual layout/glyph coverage, PDF byte identity, cross-platform or optional
extension-integration acceptance. Native reload equality is extracted text,
not a page-geometry comparison. No independent raw archival need.
