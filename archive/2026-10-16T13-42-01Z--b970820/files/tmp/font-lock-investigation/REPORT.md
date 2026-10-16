# STM font-lock investigation — 2026-10-16

Investigation complete; production feature not implemented or accepted. All new
scripts and result copies are in ignored `tmp/font-lock-investigation/`.
User flake overlay is preserved. No project index change, worker execution,
TeXmacs process, source edits or lock updates.

## Conclusion

Existing Org Scheme fontification supplies useful lexical colors for STM
paragraph fragments, inline footnotes and TeXmacs special blocks. It does not
validate STM tags or native semantics. Merely mapping texmacs to Scheme in
`org-src-lang-modes` colors source blocks, but not TeXmacs special blocks.

A small production integration is plausible, but neither direct use of the Org
helper nor the tested whole-buffer-cache wrapper is ready to ship. Recommend
context-bounded recognition and explicit property/invalidation ownership before
implementation. If v0.5.0 should avoid that additional work, an explicit deferral
is justified by this evidence. No implementation/deferral decision was adopted.

## Environment and reproducibility

Locked flake: x86_64-linux, Emacs 31.1, Org 9.8.10. `inputs.json` records 17
production/README/license/lock hashes; each matches task snapshot, current root
and committed HEAD b97082033663dd32a1f9960a3d54dd56a0d84800. The separate task
flake/prototype are synthetic investigation inputs, not committed project code;
`harness-identities.json` records their exact bytes.

User authorized repeats, necessary locked dependency access, source audit and
result copies of these two commands, run sequentially:

```
timeout 120s nix build 'path:./tmp/font-lock-investigation#checks.x86_64-linux.sources' --no-link --no-update-lock-file --print-build-logs --print-out-paths
timeout 240s nix build 'path:./tmp/font-lock-investigation#checks.x86_64-linux.probes' --no-link --no-update-lock-file --print-build-logs --print-out-paths
```

Final source output: `/nix/store/ibadhvi7jdfy2w2vc3152cw030j0wdl1-org-texmacs-font-lock-sources`.
Final probe output: `/nix/store/acz620w1wwaw4zmwhsgqq98wcgi3kih3-org-texmacs-font-lock-probes`.
Copies: `final-source-results/` and `final-probe-results/`.

The source check extracts selected function definitions and relevant local Org
settings, not full libraries. The probes use unchanged package discovery and a
private-buffer Scheme fontifier, transferring face runs to owned source spans.
They forbid make-process/start-process/call-process. Batch normally refuses to
enable font-lock; the harness binds noninteractive=nil during activation in
named buffers and asserts font-lock/JIT modes and after-change hook registration.
This exercises registered hooks and explicit ensure/flush, not GUI redisplay,
idle scheduling, folding, third-party mode coexistence or visual acceptance.

## Source audit and observed behavior

1. `org-src-font-lock-fontify-block` copies syntax-table and other fontification
   properties, adds org-block face and may manage display. Direct invocation
   preserves source characters/state in the probe but is not a face-only inline
   adapter. Org unfontification has its own syntax/link/display cleanup.
2. Native Org special-block fontification handles src/export/example, not
   texmacs. The config-only control confirms special block uncolored, source
   block texmacs colored after language mapping.
3. Face-only transfer avoids importing Scheme syntax properties, but existing
   Org interpretation remains inside STM strings: link keymap/mouse-face and
   hidden org-link delimiters survive; emphasis properties also survive.
   A correct opaque presentation needs scoped suppression/restoration of those
   properties without disrupting surrounding Org or source ownership.
4. Deleting a special-block terminator leaves stale old-body color under local
   ensure; full flush clears it. Old/new paragraph/block context must determine
   invalidation. Current properties alone are insufficient.
5. Catching a malformed inline-note discovery error around the whole scan avoids
   a hard editing error but loses coloring of unrelated valid fragments.
   Recovery should be local and soft; export errors/semantics stay unchanged.
6. Changing fragment tags without editing characters leaves old colors until
   explicit flush. Cache keys alone cannot trigger redisplay of already
   fontified text; configuration refresh needs an explicit policy.
7. Positive controls cover all 11 default roots, custom roots, inline notes,
   mixed-case special blocks, paragraph object exclusions, quote/parenthesis
   edits, multiline input, per-buffer config, narrowing, disable and major-mode
   cleanup. Tested text/modified/chars tick/point/mark/undo state is preserved.
   Ordinary surrounding Org properties remain unchanged in tested controls.

Final ERT: 12/12 expected, 0 unexpected, 9.531266 s. Several tests deliberately
record prototype shortcomings; green means the investigation observations are
reproduced, not that a complete editor feature passed acceptance.

Earlier harness read syntax failure was corrected before ERT. Two early 8/10
runs mislocated NOTE/CUSTOM markers because search inherited Org's case-folding:
NOTE matched prose Note, CUSTOM matched root custom. Case-sensitive lookup fixed
both; those failures were harness defects, not product bugs. Diagnostic logs
remain temporary; final source, probes and concise results preserve the evidence.

## Cost measurements

Synthetic ASCII fixtures have many distinct small STM paragraphs. One cold
whole-span scan and one cache lookup per size; fontification includes cache
rebuild. Paragraph-only measurement averages three scans of one narrowed plain
paragraph and verifies its absolute span against the full result.

| Bytes | Fragments | Full scan (s) | Cached geometry (µs) | Initial fontification (s) | One bounded paragraph (ms) |
|---:|---:|---:|---:|---:|---:|
| 4,114 | 132 | 0.0379 | 6.0 | 0.0818 | 0.268 |
| 16,402 | 516 | 0.5281 | 6.7 | 0.6789 | 0.260 |
| 65,550 | 2,020 | 8.0148 | 7.6 | skipped | 0.276 |

256 KiB skipped after the >4 s scan guard; 64 KiB full fontification skipped
because scan already exceeded 2 s. Two earlier scans measured 7.88/7.76 s at
64 KiB, supporting the same concern. Cache hits are cheap, but any character
edit invalidates the current whole-buffer cache. These dense-fixture timings
show strongly superlinear growth, not a universal complexity theorem or a
measurement of every document shape. Repeated per-edit full discovery is
unacceptable for responsive font-lock. Bounded paragraph timing illustrates a
promising direction, not a complete context-safe incremental algorithm.

## Proposed implementation boundary, pending user decision

Keep this in optional editor presentation; use existing Org parsing and fragment
boundary rules, not a worker/native parser or export pipeline change. Recognize
bounded owning contexts, retain old/new dirty intervals, recover locally from
incomplete input, and refresh on config/narrowing changes. Transfer only intended
properties with explicit Org-property suppression/restoration within opaque
islands. Preserve exclusions, default/custom roots, buffer-local state and full
cleanup. Separate Scheme lexical highlighting from semantic validation.

Before shipping: maintained lifecycle/boundary tests, bounded large-input cost
checks and real interactive typing/undo/folding/disable checks are needed. No
production full ERT/PDF regression suite was run for this presentation-only
investigation; there are no production changes to validate.
