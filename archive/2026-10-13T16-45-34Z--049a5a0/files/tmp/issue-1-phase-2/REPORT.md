# Phase 2a investigation

Baseline: main 049a5a00bdd52d83e1f03823accc9324f4bcee0c; copied current lock and
user mirror overlay. Emacs31.1 / Org9.8.10. Twelve isolated ERT probes pass, 0 unexpected, 0.144719s,
including locked environment and whole-file footnote behavior. No production edit or native TeXmacs/real DB operation.

## Locked lifecycle and side effects

The actual ox.el annotate-info order (3090–3155) is before-processing hooks →
INCLUDE → comment deletion → optional macros → parser/radio refresh → optional
Babel/results macro refresh → before-parsing hooks → conditional parser refresh →
effective environment → optional Cite discovery/processors → parsing/filters.
Earlier Phase 0 supplies the remainder and buffer-copy/alias/ID lookup evidence.
There is no after-includes hook in this version. Hook return values are ignored
in the observed native ASCII lifecycle; AST filter return rules are separate.
Native INCLUDE (3318+, blindly-expand/prepare-file-contents 3500+/3638+) performs
recursive reads, level/footnote transformations, link relocation and temporary
Org buffers. Its internal mode initialization may run mode hooks; bounded adapter
must suppress those hooks and BIND/Babel/Lisp macro execution. This is not a
complete exporter profile; do not substitute annotate-info or stop the exporter.

## New observations and runnable model

1. Ordinary file:image.png in a parts/a.org inclusion becomes parts/image.png,
   while an STM image argument remains image.png. Link relocation is insufficient
   for mixed-origin STM resources. Current input has one resource base, not a
   per-island resource policy. Either design such a policy or reject directory
   conflicts; first node chooses common-directory provenance.
2. Owned native mirror with unique occurrence boundaries/STM tokens distinguishes
   same file repeated and equal text from different files. Native helper performs
   the actual INCLUDE transformation over captured sanitized copies; canonical
   Org is untouched. Fake INCLUDE/SETUPFILE inside STM does not reach reads.
3. Original numeric selection positions shift after INCLUDE. No reliable original
   region/subtree map is established; first opt-in supports full unrestricted
   documents only. Existing APIs retain their selection semantics.
4. Marker damage fails instead of recovering identity from equal STM strings.
   Restoring STM before deriving final ranges avoids stale post-expansion offsets.
   Before-parsing hook insertion is explicit generated-origin text with no claimed
   original file/range; normal source context and original occurrence stay distinct.
5. Receipts reject dependency changes after acquisition. This model proves fixed
   text and observed checks, not native wait transaction coverage or atomicity.

Model/probes: prototype.el, phase2-probes.el. Source ranges for original STM are
retained explicitly; ordinary segment intervals describe the derived working
view, not an exact original character map. Production must own/remap node keys
rather than match repeated raw strings. It must validate occurrence boundaries,
source budgets, changes across callbacks/waits and cleanup independently.

## Strategy comparison and selection

- Full copy/annotate exporter: native lifecycle available, but unsupported
  preprocessing/ID lookup/config aliases and no demonstrated STM origins. Reject.
- Own raw recursive composition: can retain origins, but silently clones Org's
  INCLUDE level/footnote semantics. Reject as first native-reuse implementation.
- Owned protected mirror + native INCLUDE: finite first scope, explicit occurrence
  identity, fixed texts/receipts and no global collector/read monkey patches.
  Select, with declared differences: protected working view, generated-origin
  policy, projected filenames visible to INCLUDE advice, shared resource directory,
  bare whole-file includes, full source only; no full-native/real package claim.

## Selected Phase 2b minimum and acceptance

Node A: owned original/derived source and origin maps enter shared preparation,
annotated before the once-only Phase 1 filters; no new pure input slot/I/O.
Node B: protected source composition with standard hook utility and native INCLUDE,
bounded snapshots, cycle/physical alias checks, generated origins, dependency
receipts and original configuration guards; old APIs remain explicit/no preprocessing.
Node C: public opt-in prepare/document/bytes plus separately requested bibliography
integration over derived declarations and unchanged explicit-text priority/receipts.
Validate complete transaction with maintained ERT, actual files, native STM/bib/
readback/bytes, callback/acquisition/wait/final-output changes and HTML/ASCII guard.
A source snapshot is immutable derived input, not an atomic FS/DB transaction.

Initial include policy: local regular UTF-8 <=64 KiB/file, same captured resource
base, <=8 levels, <=32 occurrences, <=256 KiB aggregate working/source data; bare
quoted full-file includes, no lines/location/env/options/tilde/remote/symlink or
physical alias ambiguity. Whole-file footnotes use existing grammar after native renaming; partial-file
footnote extraction remains outside the selected parameter scope. No source-relative selection mapping, cross-directory STM
encoding or automatic general preprocessing of Phase 3b's existing APIs.
Private-stage callbacks may rewrite ordinary text and insert generated STM;
original STM markers cannot be lost/duplicated/changed. They may not change captured
parser/options/style/location/mode or reserved provenance. Arbitrary callback I/O
is not sandboxed. Named hooks run through owned copied hook lists; generic frontend
rejection stays installed and active for generic export, including nested calls.
