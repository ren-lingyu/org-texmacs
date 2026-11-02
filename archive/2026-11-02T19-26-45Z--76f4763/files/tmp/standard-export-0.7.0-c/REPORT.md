# Stage C: live Org queries before identity adaptation

Historical experiment evidence, not current instructions or complete acceptance.
Exact baseline76f4763807bb2d072cdfb5380ae6a08ab9f0130a (B human delivery),
144tracked files copied byte-for-byte; source-manifest.json records their hashes.
The task-authored prototype.patch modifies only private model/prepared ownership;
query.el and tests are new derivatives. They are not committed baseline content
or the later completed production implementation.

Restore that baseline into an isolated directory, verify its144hashes, apply
prototype.patch with -p1 there, and add the captured query.el/probe/Nix overlay
at their paths relative to project/. Copied flake/lock remain unchanged.
Command (substitute the restored project's absolute path):
 timeout 120s nix build --no-link --no-write-lock-file --max-jobs 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs/tmp/standard-export-0.7.0-c/project#checks.x86_64-linux.standard-query-probe -L
Original backend identity texmacs and real org-export-as are used; the final
inner-template is temporarily replaced to inspect final AST+INFO. No Org
preparation implementation is copied. Source snapshots may include files not
needed by a particular derivation; the144count is all tracked baseline files.

Final attempt5:8/8,0.121925s, exit0, strict byte/native compilation. Runtime
Emacs31.1/Org9.8.10/x86_64-linux. Public query docs are printed in the retained
log. Experiments verify selected external footnote definitions, named/anonymous
inline shape, original headline numbering after filter insertion, offset,
duplicate-target choice, STM opacity and finite fact ownership/remapping.

Key expected counterexample: copying INFO and changing parse-tree does not
remap its identity-keyed footnote cache. A cloned reference's public footnote
number query returns nil, even though target lookup can use a fresh tree cache.
The selected protocol therefore queries original nodes in actual INFO and then
remaps finite results. Do not create a parallel query transaction with guessed
copied caches. The private secondary-normalizer import handles Org's generated
scalar footnote title while standalone core constructor defaults remain strict.

Earlier attempt1:3/4; incorrectly expected the first duplicate headline, while
Org selects another (last in that fixture). Use the actual public query, never
hardcode this choice or restore a custom ambiguity rejection. Attempt2:5/5.
Attempt3:5/6 is the cache counterexample above, converted into an expected test.
Attempt4 failed strict compilation on an81character docstring; corrected.
Failed script versions are not separately captured; final scripts retain the
useful tested controls. This log/prototype alone does not prove production
lowering, native PDF, broader standard syntax or current extension integration.

Selection preserves the independently useful original-cache counterexample and
replay protocol with minimal text evidence. No entire source worktree, binary,
cache, database, PDF or native closure is archived. Later production findings
(actual selected footnote copies, deferred getter noncaching, output guards)
are distilled in memory/standard-export-0.7.0-c.md and maintained regressions;
no exact raw capture of all intermediate production revisions is claimed.
