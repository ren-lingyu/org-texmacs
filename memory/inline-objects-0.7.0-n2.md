# N2 entity lowering: accepted native behavior and verification

Baseline is verified N1 a34b574. N2 is implemented and locally accepted; human
delivery5ce20ef is verified against the exact parent, ten paths, message and
all159accepted hashes. Candidate/handoff statements below are historical.
INFO projects :with-entities. Pure lowering uses owned :utf-8 /
:latex-math-p values; math entities get local native math, text stays text. Missing
option defaults to enabled; explicit nil uses Org's source-independent interpreter
and preserves brackets/post-blank. Late filter/Cite nodes obey effective INFO.
Missing/invalid representation and malformed nodes fail at the consumer boundary.
No dynamic entity lookup, source read, native parse or worker in pure lowering.
No script/LaTeX/model/island-contract work is folded into N2.

## Isolated native experiment

Tracked-input snapshot: tmp/inline-objects-0.7.0/n2-probe-1, with inputs.json,
probe.nix/probe.el and the disclosed inline-entity-probe check. TeXmacs2.1.5,
Emacs31.1, Org9.8.10 on x86_64-linux. Corrected experiment exits0/2tests;
the native tree agreed across both runs.
Org attributes confirm alpha/cdot/rightarrow math=true and copy/nbsp text=false.
Unicode alpha/dot/arrow become native <alpha>/<cdot>/<rightarrow>, copyright
becomes <copyright>, while literal <alpha> becomes <less>alpha<gtr>.
Native session readback and serialized TM preserve these distinct paths.
Output: /nix/store/igkjrr7iyr27c7gv84hbjrwgh2sbpwlm-org-texmacs-inline-entity-probe.
Actual entity.png inspected: alpha, centered dot, right arrow, copyright and
literal spelling render as intended in mixed prose. PDF text extraction cannot
reliably identify these math-font glyphs; it is not used as a glyph oracle.
First probe used nonexistent org-element-properties and failed only attribute
logging. Corrected to individual public properties; the native part already
succeeded. No production implementation was based on that failed helper.

## Maintained tests and focused gate

Eight new cases: six core, one native and one PDF. Pure default/explicit-nil,
input ownership, repeat lowering, worker/source/dynamic-entity lookup forbidden,
malformed representations, heading/emphasis/footnote/caption/table contexts,
normal and synthetic AST nodes, metadata INFO changes and synthetic Cite output.
Native session compares exact Cork symbols versus escaped literal text. PDF ink
matches an independently authored native tree and saved-TM reloaded output.
Focused fixture intentionally selects entity/identity names and runs9cases (one
existing identity regression included), all pass in6.289508s. Output:
/nix/store/00hvxp1g4i03avp3qdx0qbkxvxmdaxcz-org-texmacs-inline-entity-focused.
Full acceptance follows below. Initial focused results precede final formatting;
maintained cases were rerun against formatted sources by the complete suite.

Initial focused harness had invalid relative paths after individual store import;
fixed to explicit Nix-supplied paths. First maintained fixture had one missing
closing parenthesis, then exposed a non-ASCII string mutation error and missing
existing affiliation marker on a raw caption AST. Corrected fixture ownership
mutation and prepared caption input; kept all semantic assertions. Native/PDF,
late Cite and option tests passed before these fixture repairs. No scope waiver.

## Retention

Reviewed native/focused experiments for archive value. Maintained tests now retain
the independent native reference, encoding/literal distinction, option and PDF
raster/reload proof. This note and input manifest can retain enough invocation/
source facts at final acceptance; raw failed harnesses and binary PNG/PDF have no
independent necessary archive value. Do not copy the whole snapshot or binaries
into GAW. Reassess if subsequent failures establish a distinct durable finding.

## Complete acceptance and human handoff

Final ten-path candidate adds two production-module changes, eight maintained
cases and README/root summary/detailed notes. No public API, model/island/worker
protocol, scripts or LaTeX conversion is added. Full diff reviewed, whitespace
clean and ordinary index left empty. One coupled feat(document) candidate; no
split needed. Expected parent/message/ten paths and all159final source hashes:
memory/inline-objects-0.7.0-n2-inputs.json. Human commit must match that record
before N3. Final version remains0.7.0/NEXT with no CLOSED/tag/publication.

Commands (from root; each snapshot is below tmp/inline-objects-0.7.0):
- timeout 120s nix fmt --no-write-lock-file -- [the ten changed paths]: exit0;
  seven Lisp paths formatted. Later README-only fmt exits0/no changes.
- timeout 600s nix flake check --no-write-lock-file --keep-going --print-build-logs
  --max-jobs 2 path:./tmp/inline-objects-0.7.0/n2-full-1: exit0/all12named checks.
- timeout 120s nix flake check with identical flags and n2-full-2: exit0; final
  README-only explanation change rebuilds treefmt alone, all other derivations
  identical/cached. No unchanged runtime rerun needed.

Locked x86_64-linux Emacs31.1/Org9.8.10/TeXmacs2.1.5. Complete runtime:
core281/281(1.542529s), native274/274(191.674625s), Cite9/9(11.405654s),
PDFdocument46/46(110.127931s), PDFrender29/29(159.086223s), patchedcaption6/6
(2.853773s) =645defaultERT. Real pinned Organize integration4/4(6.108290s).
Strict byte/native compilation, package-lint, treefmt and native gotor check pass;
ERT/PDF aggregates do not replay cases. Optional integration copied the previously
reviewed controlled drivers into isolated sources, not root flake/lockfiles.
Both full snapshots and logs remain under the task tmp path; final manifest proves
all159root/snapshot input bytes equal. Earlier probe/focused source states are
not silently attributed to final runtime. The inspected glyph PNG is prototype
native evidence, with maintained final raster/reference/reload proof succeeding.

No minimum-Org9.8 runtime, other-platform, arbitrary fonts/custom entities, GUI or
CSL math-title support claim. Missing/invalid entity representations reject; a
latex-fragment remains a different unsupported consumer input. N3 scripts and N4
CSL-triggered conditional work follow only after human N2 delivery.

Final retention review: maintained source tests, exact input manifest and these
facts/commands sufficiently preserve reproduction and meaning. No new raw archive
needed for the superseded probe/drivers/logs; no binary PNG/PDF retained in GAW.
