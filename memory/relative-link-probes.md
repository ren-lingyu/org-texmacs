# Relative file-link consumer investigation

## Subsequent user semantic decision

Final adopted scope is now implemented/accepted: PDF-only relative preservation
flag (default nil means do not absolutize), uniform optional .org->.pdf for all
native consumers (default t). Native .tm/session source-base resolution remains.
This supersedes the intermediate general local-preservation discussion below.
Production evidence: memory/file-link-implementation.md.

User explicitly requires local path-form preservation: source relative stays
relative, source absolute stays absolute in final output. Different bases,
group movement and target existence do not justify rewriting. Earlier suggestion
below to retain source-based session navigation is NOT an adopted requirement.
Native scratch base was observed, actual click resolution was not tested. It
does not establish that relative session links need mandatory absolutization.
Keep buffer identity/navigation concerns separate from target compilation.

## Authority and provenance

User requests isolated experiments and authorizes repeated exact command:
`timeout 600s nix build --no-link --no-write-lock-file --max-jobs 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs/tmp/relative-link-probe#checks.x86_64-linux.relative-links -L`.
tmp/relative-link-probe contains standalone flake, copied lock/16runtime inputs,
probe.nix/probe.py/export.el and REPORT.org. Current-lock Emacs31.1/Org9.8.10,
TeXmacs2.1.5, Python/pypdf. HOME/XDG/tmp isolated per process, empty fontconfig;
no GUI or followed network links. Runtime-only Scheme session-base observer and
dynamic Lisp target override, preserving production validation. No main edits.

Sandbox daemon denial occurred before evaluation. Same authorized command was
escalated; first builder failed appending observer to readonly source before link
tests. copyfile fixes runtime copy; final build exits0. Output:
/nix/store/gpgb6v6b0rrhwnmdwg7xi18l6vdgrb81-org-texmacs-relative-link-probe.
All16source hashes and lock equal root after run; exact hashes in inputs.json.

## Verified observations

Three modes: baseline absolute expansion, relative retention, relative retention
with terminal lowercase .org->.pdf. Nine links per document: sibling, ./, ../,
space, Unicode, .org, .tm, absolute and HTTPS. Direct PDF, fresh native saved-.tm
reload and fresh reload after artifact-tree relocation:9PDFs/81actual annotations,
9per output, arrays equal across three origins within each mode. All /URI actions,
not /GoToR. Relative/space/Unicode targets preserved verbatim, absolute/HTTPS
unchanged. Suffix spike changes article.org to article.pdf without display change.
Baseline links become source /build/probe/... paths. Wire, saved .tm and session
native hex readback agree. Original document body remains equal across consumers.

Unnamed sessions have actual buffer URL
/build/probe/homes/<mode>/texmacs/texts/scratch/no_name_2.tm, not captured source.
Native reloads use actual saved file URL and relocated URL. This proves a base
distinction, not successful relative navigation from an unnamed session.

## Implications and limits

Relative targets feasible for relocatable file exports. Do not simply replace
shared absolutization for all consumers: session source-base navigation needs
explicit handling. Keep optional suffix policy separate, capture settings in
prepared state and preserve typed provenance. No production feature implemented.
No GUI/viewer clicks/target-open or universal PDF-reader compatibility claim.
Relocation checked annotation strings after re-render; moved parent target fixture
does not exist for every moved parent. Include/subtree, uppercase/.org.gpg and
option defaults/freeze semantics are future implementation boundaries.
Source/lock equality and exact scripts/report suffice; no raw archive selected.
