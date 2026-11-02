# Stage A standard export feasibility: observations and remaining gate

## Source and execution scope

Ordinary source snapshot: 440b33119e7878eba8a11b11e252ad711c3cae74,
the verified CHANGELOG-only first v0.7.0 delivery. source-manifest.json lists
130 copied tracked inputs and their SHA256 hashes. Production code, root lock,
ordinary index and result link were not changed. The only added copied inputs
are project/tests/standard-export-probe/{test.nix,test-overlay.nix,probe.el}.
The unchanged copied flake discovers this isolated check through normal overlays.
Nix selects the project-locked Emacs/Org/TeXmacs package closure. Native serializer
output reports TeXmacs2.1.5; runtime Emacs/Org version strings were not separately
printed, so do not claim independent version-range acceptance from this probe.

Each attempt used this exact command (shell tee saved the corresponding log):

```
timeout 120s nix build --no-link --no-write-lock-file --max-jobs 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs/tmp/standard-export-0.7.0-a/project#checks.x86_64-linux.standard-export-probe -L
```

The builder limits ERT to110s and uses existing testSupport.mkErtCheck with isolated
HOME and per-native-test worker configuration. Only the probe derivation was
built, not default/full ERT or optional real-extension integration. No formatter
or root source implementation ran. Original frontend checks were not modified,
but their success is not newly claimed.

## Results and counterexamples

| Attempt | Result | Interpretation |
| --- | --- | --- |
| 1 | Exit1,6/7pass,3.503310s | Standard file output adds a terminal newline; original exact-byte expectation is false. Early catch delivery needs advice-completion audit. |
| 2 | Exit1,9/10pass,3.444399s | Normal-return result container works; CITE_EXPORT remains a keyword rejected by the naive pure-lowering handoff. |
| 3 | Exit1,9/10pass,5.210878s | Selecting processor through normal configuration isolates structured-result success; original-native-file versus parsed-file equality is too strong for the diagnostic. |
| 4 | Exit0,10/10pass,5.138121s | Diagnostic instrumentation printed no tree contents; NOT proof of native tree equivalence. Superseded by an explicit parse-to-parse assertion in attempt5. |
| 5 | Exit0,12/12pass,6.667459s | Refined native parse comparison plus two expected counterexamples pass. This is feasibility evidence, not all-stage acceptance. |

Final output: /nix/store/srjhvq4nfhhc51d0baya8h1nk8d6l8w6-org-texmacs-standard-export-stage-a.
The successful script and attempt5 log are the primary evidence. Attempts1/2
preserve useful failed hypotheses. Intermediate3/4 diagnostics add no independent
accepted result; their scripts/logs remain temporary but are not selected for archive.

Confirmed under the actual texmacs backend identity:

1. Org runs before-processing, before-parsing and tree filters before its normal
   transcoders and inner-template. The final model can be owned using the existing
   constructor after ordinary Org mapping resolves deferred data on these fixtures.
2. Cite processors returning Org elements/secondary strings keep their structure.
   Strings and results of a processor calling org-export-data become raw nodes.
   Basic citation/bibliography also produce raw. The existing lowerer rejects
   target-code raw; it must not be reclassified as ordinary literal text.
3. A per-invocation result container can retain model/document while org-export-as
   returns normally. Nested exports use independent containers; normal-return
   advice, unwind cleanup, errors and subsequent requests behave correctly here.
   The alternative throw across org-export-as skips normal advice completion:
   expected counterexample a-12, so do not use that alternative as success delivery.
4. The structured consumer can render native PDF directly from its owned document,
   without native text serialization/reparsing. Known identity output filter is
   permitted; an unknown effective final filter is conservatively rejected. The
   fixture does not prove a general callback classification implementation.
5. Native .tm contains byteE9 for the accented fixture; permissive UTF8 decoding
   yields Emacs raw-octet characters rather than exclusively Unicode characters.
   ISO-Latin-1 transport has a reversible byte/character mapping. Standard file
   export with that explicitly bound coding system writes native bytes plus one
   terminal newline. Parsing native bytes and bytes-plus-newline yields equal
   native trees. This does NOT mean generic UTF8 file export preserves native bytes.
6. Ordinary structured processor output can reach the existing pure lowerer when
   processor selection uses normal Org configuration. CITE_EXPORT syntax in the
   final tree separately needs adapter/control-keyword handling, without repeating
   preparation. Existing ASCII exporter still runs in the isolated fixture.
7. Expected counterexample a-11 demonstrates that a final-AST handoff which ignores
   initial string transcoding loses a paragraph output filter's modification.
   Passing this test records the defect, not support for that filter. A production
   path must either preserve its semantics or explicitly reject the unsupported
   effective node-output callback. No silent loss is acceptable.

## Proposed refinement and remaining architecture gate

Prefer normal-return scoped result delivery over nonlocal success exits. Keep
preparation/AST filters/Cite standard and exactly once. Keep target raw distinct
from literal content; use the already permitted structured TeXmacs Cite processor
route if basic cannot satisfy AST-first. Use an explicit reversible native text
transport/file coding contract rather than assume UTF8 bytes; retain existing
native byte-consumer behavior independently.

The node-string-filter finding requires an explicit support decision before
dependent production implementation. A user question is pending: restrict and
reject unsupported node-string filters while retaining standard AST/options and
final body/output filters, or investigate an architecture preserving those node
filters. No production source has been changed and no complete A acceptance is
claimed. All later B-E requirements, actual extension integration, source-state
and broader syntax tests remain pending.

Replay: materialize the source-manifest paths from the recorded project commit
under project/, verify hashes, overlay the selected probe/Nix files at their
original paths and run the command with the reconstructed flake path. To replay
attempt1/2, replace only the probe/Nix files with the corresponding preserved
attempt inputs. The archive does not vendor dependency closures or guarantee
future network availability.

## Retention assessment

Select this report, source manifest, copied flake/lock, common probe Nix files,
attempt1/2 probe scripts and logs, and final probe script/attempt5 log. These
preserve architecture counterexamples and their exact experimental controls not
present in maintained tests or project history. Do not archive all130copied inputs,
Nix/store closures, native files/PDFs, databases, caches or intermediate diagnostic
attempt3/4. Original project sources are recoverable from the exact associated
project snapshot; dependency identities are in the copied lock. Capture selected
text bytes faithfully, with SHA256 and a separate immutable archive checkpoint.
