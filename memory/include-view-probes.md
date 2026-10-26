# Isolated INCLUDE semantics probes

## Scope, provenance and result

User selects isolated investigation of the snapshot/view proposal, then
authorizes repeated execution of the exact timeout120s run.sh command for this
round. Source is the clean gitignore-anchoring project snapshot previously
reviewed;16Lisp/Scheme inputs copied to ignored tmp/include-view-probe-20261026.
Final root hashes match inputs.sha256. Project index/worktree and both stashes
are unchanged. No production refactor or stash restore is authorized.

Installed Emacs31.1/Org9.8.7 runs -Q --batch with explicit empty-inherited
environment, isolated HOME/XDG/TMPDIR/cwd and fresh fixtures. No network,
Nix/store operation, TeXmacs worker or renderer. This is directory/environment
isolation, not a sandboxed Nix build. Initial --script option ordering prevented
loading; changed to --load before any probes ran. Authorized retry completes
38cases, then final49cases, with zero unexpected failures in under a second.
Groups: native15, current20, guard-only3, dispatch6, target5. Expected rejection
counts as success; wrapped INCLUDE remains unsupported in production.

## Measured semantic boundaries

- Native src/example/export treats STM-looking text, headings, footnotes,
  nested INCLUDE and end-block lines as literal text, escaping source delimiters.
  No Babel execution occurs. Literal :lines may cut an apparent STM fragment.
- Plain Org inclusion recurses and applies location/only-contents/minlevel.
  Generic block wrapping does not recurse. Literal/generic wrappers did not
  apply location/only-contents selection; generic minlevel likewise had no
  heading effect. Preserve these native branch differences.
- Removing only :env/:block rejection in an in-memory copy of compose yields
  three counterexamples. Text[fn::(math "unfinished]. in literal source fails
  as an invalid inline-footnote STM candidate. Source `(math\n  "x")\n`
  with :lines "2-3" falsely fails STM truncation. A native texmacs block whose
  multiline string contains a line #+end_src is shielded then restored without
  Org's comma escape, ending the containing source block early. Native Org
  instead emits ,#+end_src. Parameter widening alone is incorrect.
- Dynamic scope around org-export--blindly-expand-include reaches preparation
  and location readers. Literal-first and Org-first mixed reuse, nested mode
  success/error restoration, function restoration and independent cached-text
  copies pass. Native-body mode reaches readers. This is a small dispatch/raw
  cache spike, not protected views, receipts or the production transaction.
- Current compose creates one captured source for two uses but the fixture
  records12physical byte reads. org-texmacs--bibliography-check-receipts reads
  bytes again to verify hashes. Require one captured/decoded snapshot, not one
  total physical read while retaining receipts. The spike omits verification;
  its one acquisition is not evidence of a production performance improvement.
- Native expanded src org/emacs-lisp/bibtex already lowers to static code with
  worker startup mocked to fail. Export html and unsupported source headers
  fail in target lowering; :tangle never-created.el creates no file.

## Controls and limits

Baseline controls pass for true STM truncation, unknown/coding parameters,
per-file/aggregate source/working byte limits, occurrence/depth budgets,
symlink/physical-alias rejection, invalid UTF8, changed dependency and function
restoration. These do not establish preservation by a future refactor. The
component helper substitutes a no-op outer transaction check; it does not
replace public provider/configuration mutation regression coverage.

Not verified: full snapshot/view implementation, opaque native-body preservation
under every selection/transformation, locked Org environment, full ERT,
native serialization/.tm reload/PDF or restored bilingual documentation builds.
Next implementation specification must preserve receipts, cache/occurrence
budget distinctions, private helper compatibility and scoped restoration.

Temporary reproduction artifacts are run.sh, probe.el, REPORT.org, results.json,
probe.log and inputs.sha256 under the directory above. Distilled exact failure
patterns and limits here suffice for recovery; no independent raw archival need.
The round-specific execution authorization does not grant future test permission.
