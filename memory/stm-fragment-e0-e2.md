# STM E0–E2 isolated findings

## Baseline, evidence and execution

Read-only v0.7.1 source; additional project parent of this checkpoint identifies
the exact snapshot tested. Emacs 31.1, loaded Org 9.8.10, TeXmacs 2.1.5.
Batch -Q, Org element cache disabled, isolated HOME/XDG/TMPDIR. No personal
Org files or ID databases were read. Package environment reused the flake cache.
load-prefer-newer was set after local stale .elc files were noticed; final probes
were rerun with that setting. Final native.el run exited 0. Socket bind initially
failed under sandboxing; the same isolated run succeeded with socket permission.
Final worker process was stopped and its temporary directory removal verified.
An earlier bare --version invocation aborted; the successful isolated worker
startup independently supplied the runtime version. No version-only result is
used as STM parsing evidence.

Probe scripts and full JSON AST/results: archive/2026-11-17T13-23-55Z--dd4deff/files/tmp/stm-e0-e2/.
Manifest explains replay, byte digests, source baseline and evidence limitations.
The temporary project location is tmp/stm-e0-e2/; recovery must use the archive
if those files disappear. No full handoff archive was needed.

## E0 — Confirmed native behavior in sampled contexts

60 matrix cases: five forms across eleven contexts plus five boundary cases.
$x$, backslash-parenthesized math and compound carriers become latex-fragment
in paragraphs, titles, table cells, inline footnotes and link descriptions.
Caption secondary strings also contain fragments when traversed with
org-element-map WITH-AFFILIATED enabled; ordinary traversal omits those objects.
Their parent property is nil in this sample, so do not infer ordinary child
parent semantics for secondary-string objects. Full outputs retain begin/end,
post-blank, parent observations and complete printed ASTs.

Code/verbatim remain opaque, as do src/example blocks. Native incomplete
backslash-open math yields ordinary content without a fragment, not a strict
error. A single newline can remain inside native math; a blank paragraph break
or heading boundary prevents joining the fragment across structures.
Ordinary punctuation adjacency and trailing spaces are represented natively.
These are sampled observations, not a complete object-restriction proof.

## E1 — Confirmed separation of lexical and native validation

probe-scan reuses the existing fragment syntax table and scan-sexps for one
balanced compound expression, then requires an immediate matching carrier close.
It receives a caller-supplied legal owner limit; it does not discover that limit.
Nested forms, multiline source, escaped quotes and delimiter-like characters
inside strings were recognized without a tag whitelist. Missing tree/close,
extra text between tree and close, and multiple datum inside one carrier fail.
Atomic source is not a carrier. Content after a closed carrier belongs to the
surrounding document; adjacent carriers are separate (the single-span probe
returns the first, not a whole-document scan). E1 has 18 lexical cases.

Seven native requests independently establish: (math "x"), (custom-tag "x")
and (x) parse; (math #bad) and two top-level datum fail. A string containing
backslash/closing-parenthesis text parses, and direct atomic "V" remains legal.
The lexical scanner accepts #bad structurally: this is intentionally not native
validation. Neither the lexical probe nor parser acceptance promises rendering
for unknown tags. Reader punctuation beyond the exercised cases is unverified.

## E2 — Refuted recognition-only sufficiency; protection Conditional

Seven comparisons use native parsing, a scoped recognition-only surrogate and
same-length masking. The surrogate temporarily uses latex-fragment solely as a
controlled experiment, not an adopted representation or production design.

Counterexample: *Consider \((math "a* b")\) here.*
Native emphasis closes at the star inside the STM string. Replacing only the
latex-fragment parser cannot fix it: by the time that parser runs the buffer is
narrowed to the truncated emphasis contents and the scanner reports an incomplete
tree. The handoff's concat-with-a-quoted-star case shows the same failure.
Source explanation: org-element--parse-generic-emphasis searches for its closing
marker before recursive object parsing (org-element.el around lines 3380–3420).

A native latex fragment also closes early on backslash-close text in an STM
string. Lexical recognition-only adaptation fixes that standalone case, but not
the outer emphasis issue. Equal-length masking of complete spans before parsing
preserves the full outer bold extent in both emphasis counterexamples. Neighboring
bold text remains a separate object; table/underscore and inner link-like syntax
are neutralized. Code/verbatim spans are skipped and remain opaque in these cases.

This mask prototype is deliberately incomplete: it uses a preliminary native
parse for opaque spans and point-max as candidate limit. It does not establish
correct context ownership when preliminary parsing was already distorted, nor
strict incomplete handling across every container, actual stm-fragment object
reconstruction, source positions after general transformations, AST roundtrip or
standard Export integration. Global pre-shielding or original-source restoration
is not adopted. No design conflict requiring a changed external contract has yet
been proven, but no complete viable E2 adapter is claimed.

## Next action and policy

Reassess E2 with the post-probe native-compatible contract below. Prefer a
local Org object-parser extension, adding prescanning or masking only for a
concrete remaining failure, then proceed to E3 object construction. Do not begin formal source implementation
or claim E3–E6 acceptance. No exact minimum-version conclusion follows from one
Org version. For later OLP experiments the user permits replacing emacsPackages.org
with emacsPackages.elpaDevelPackages.org; if its source is unreliable, consulting
~/emarccs only for building Org from upstream/mirror source and overlaying
emacsPackages.org is allowed; do not copy its directory/configuration structure.
No development Org fetch or OLP test was performed in E0–E2.

## Post-probe design decision

The user narrowed the contract after these probes: native latex-fragment allowed
positions and successful composition rules are the minimum target. Repairing
Org's own emphasis ambiguities is not required. Recognition-only failure on the
recorded native-conflicting emphasis examples therefore does not independently
show project-contract failure. Masking is a demonstrated candidate technique,
not a mandatory implementation. These examples remain exploratory evidence,
not unconditional must-pass regression cases. Original observations above are
unchanged. Once recognized, STM interiors retain lexical isolation, native
validation, strict errors, no whitelist and no silent fallback. Opaque Org
objects and structure boundaries retain priority, including for malformed
candidate-shaped text. E2-prime must establish context through actual Org parsing,
not unconditional full-source scanning.
