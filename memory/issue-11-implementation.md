# Issue11 adopted implementation contract

User selected implementation of final revised plan. Motivation: package paragraph
concat changes native display layout while .tm load normalizes it away, as proven
in memory/release-0.5.0-investigation.md. No serialize/reparse production remedy.

Bare ordinary paragraph iff exactly one registered string island identity, all
other direct children unregistered ASCII space/tab/CR/LF-only strings (empty
allowed), no other Org objects. Registered atomic/whitespace island takes priority
over whitespace filtering. Promote complete copied lowering result; parent packs
provenance. All default11roots/custom supported roots/atomic islands structurally
covered, no assumption that arbitrary roots have identical layout. Do not alter
user STM internals, ordinary string encoding or source ownership.

Mixed paragraphs retain existing concat, but known direct display roots equation,
eqnarray,align,gather,eqsplit and each * explicitly fail document-error before
serialization/rendering/file write. No automatic splitting; user's temporary
mixed-split choice was explicitly withdrawn. Root inspection only; no new config,
recursive classification or discovery expansion. math/other ordinary mixtures
unchanged. This can occur after native STM parsing; no before-worker guarantee.

Context matrix: ordinary body, quote/center, separate-note definitions and later
list paragraphs use normal bare lowering. Leading list paragraph retains marker
and concat; known display roots reject there even for source-only fragment.
Inline-note STM remains Issue10. No new generic container machinery.

Structural coverage: all11default roots, custom and atomic islands, empty/ASCII/
NBSP distinctions, Org objects, multiple mappings, duplicate use, independent
copies, nested contexts and adjacent file-path provenance. Pure lowering does
not read buffer/start workers. Source mutation rejected/preserved as before.
Native coverage: valid inputs per tag, especially equation/equation*/align geometry,
numbering and multirow structure; same STM/style/initial/container/order/counter
context compared between bare and special block. No comparing different native
environments as if they must share layout. Direct PDF versus native .tm reload
comparison is a test only. All default roots' valid fixtures checked for route
consistency, not arbitrary tags/layout correctness. No PDF byte equality required.

## Completed implementation and committed delivery

Exactly document module/maintained ERT/README changed; user has committed the
approved single fix after separately authorized staging/message.
Identity-based paragraph helper promotes full copied island result; global pack,
source preparation/native consumers/protocol/config/API unchanged. Known direct
mixed display roots reject, list-marker route retained. README/docstring/table
and7affected old expectations synchronized. No new generic containers or root
layout interpretation. User flake mirror, INBOX, versions and lock untouched.

Seven new maintained ERT (423->430). Structural55same-root route pairs cover11
roots x5contexts. Native23route fixtures:11body roots plus equation/equation*/align
in4container contexts; direct bare/block/PDF and independent native .tm reload
compared for text/geometry<=1pt. Original issue formula under article/A4/12.7mm
checks both equation starts/numbers align and number lies near right margin.
Custom roots/atomic islands/ASCII/empty identities/NBSP/other objects/unused target/
multiple mappings/purity/copy/source/provenance/error boundaries covered.

Final focused14/14passes79.974344s (7new+7updated), real extension9/9passes12.125815s.
Final600s flake check exit0:430/430core296.145612s, strict compilation/lint/all
applicable checks pass. Locked Emacs31.1/Org9.8.10/TeXmacs2.1.5/x86_64-linux;
other incompatible systems omitted, not tested. All25baseline/25final/11foreign
input identities verified and source stable. Root lock matches isolated lock.
First/final candidate patches independently reconstruct three task files exactly.

User separately authorized repeated sequential baseline120/focused180/integration120/
full600 commands under tmp/issue-11-bare, locked dependency network/store/cache and
result access. Final full gate includes baseline target: final two regressions
run against committed old modules fail at intended extra concat and80.16pt layout
assertions2.374614s; successful baseline derivation means expected red, not old-code
acceptance. Earlier clean control2.487940s preceded legacy expectation migration.

Diagnostic extraction: missing native helper parenthesis blocked initial ERT load;
shared empty-string AST fixture hit ownership guard (Emacs canonical empty strings);
fixed before causal red/green. First full423/430passes297.201308s exposed7stale
concat/path assertions only; kept snapshots/encoding/source/session checks while
migrating output expectations. Added target test initially omitted existing empty
slot; corrected concat("",math),path(0,1), no production change. Final14/14/430core
validate these corrections. No unsupported-case test relaxed or mapping flattened.

## Retention and next action

14necessary original pure-text artifacts byte/digest/source-stability verified in
separate archive-only checkpoint:
archive/2026-10-16T07-46-35Z--8a90b4c/MANIFEST.md.
Harness/lock/manifests/first+final patches/paired gate logs/report/diagnostic limits
preserved; maintained ERT retains native fixtures/reload helper. No PDFs/binaries/
dependency tree/full tmp archived. Capture baseline is exact red source, not
accepted candidate provenance; no inferred additional project parent for this
uncommitted acceptance. Prior investigation archive remains immutable.

Selected local Issue11 implementation/automated acceptance and user delivery
complete. User authorized sequential staging/message with at most3minutes between
groups; one strongly coupled fix needed no split/inter-group polling. User then
committed the exact approved draft (fix(document): preserve native layout of
standalone STM fragments; Closes:#11). Parent verified as inspected Issue4 baseline,
exactly README.org,org-texmacs-document.el,tests/ert/ert.el changed. All25committed
input hashes match final accepted manifest; complete message equals draft.
Index empty; only existing user flake remains unstaged. Earlier acceptance
transfers by byte identity, no new build/test or business edits. Delivery checkpoint
association means exact committed snapshot verification, not original runtime
provenance. Remote Issue11 verified closed/completed on2026-10-16; timestamp/source
in memory/evidence.md. No external write/publication. #10 is also delivered and
remotely closed; subsequent PDF link repair is locally accepted in
memory/pdf-links-investigation.md. Fonts postponed;
font-lock later. v0.5.0 remains planned, not release-ready.
