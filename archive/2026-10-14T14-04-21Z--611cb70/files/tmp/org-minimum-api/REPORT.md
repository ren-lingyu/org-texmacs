# Org 9.8 API/signature audit

Historical evidence, not instructions. Checked on current production snapshot with
uncommitted commentary corrections, defined by project-inputs.json and the
project-comments.patch against project commit611cb704567e677bc600c293c2d5a159e2e8f3fe.

Independent flake copies the project's pinned nixpkgs node, and adds non-flake Org
release_9.8 source locked to89df5bf46ba214db44eea898cc7cacc0b27fd760.
Baseline Emacs31.1/Org9.8.10. Actual runtime Emacs31.1/Org9.8 loads unmodified
upstream Lisp from the locked input; source preparation generates only org-version.el
(version/tag metadata) and org-loaddefs.el. No personal Emacs installation used.

Static comparison:54 actual direct-call interfaces,0 arity conflicts,4 generated
interfaces unresolved. Actual9.8 runtime resolves all54, checks41 function references
(including function-identity checks and callback lists),87 capability entries,
0 missing functions/variables and0 direct-call arity conflicts. Each interface and
function reference's defining path belongs to the isolated9.8 source. All13
production modules pass strict compilation against actual9.8. Representative
interfaces include cache store/get/create, property-raw/properties-mapc, global/
inbuffer/subtree options, INCLUDE parser/reader/expansion helpers and backend
constructor/accessors. Raw signatures in the two original-byte sexp reports.

First runtime flake evaluation failed due shell/Nix quote escaping, corrected.
A subsequent autoload-generation run warned about recursive loading of compressed
Emacs libraries; final recipe uses bare pinned Emacs, preloads cl-lib/jka-compr and
prioritizes the9.8 source. Final build exits0 without warnings. These are harness
issues, not Org incompatibility evidence. Final command:

    timeout 120s nix build -L --no-link --no-write-lock-file path:/home/lingyu/Projects/org-texmacs/tmp/org-minimum-api#checks.x86_64-linux.runtime98

Initial source lock command (writes only isolated lock):

    timeout 120s nix flake lock path:/home/lingyu/Projects/org-texmacs/tmp/org-minimum-api

To reproduce, reconstruct the13 module snapshot from the project commit plus the
archived comments patch and verify project-inputs.json. Place project/ beside both
probe files, flake.nix and flake.lock, then run the same runtime98 check with the
new isolated path. The signatures check is a dependency of runtime98. Fetching
locked inputs/building needs its own applicable authorization.

Conclusion: no demonstrated API existence/signature reason to raise minimum Org
above9.8. This is not a full9.8 behavioral compatibility claim. Callback signatures
are reported; strict compilation checks direct calls/macros, not arbitrary dynamic
argument contracts. No complete ERT, native TeXmacs, all-platform or GUI regression
at9.8. Full existing behavioral baseline remains project-locked9.8.10. Root project
lock, dependencies and user mirror untouched by checks; no project staging/commit.

Select original probe files, independent flake/lock, input manifest/comment patch,
raw signatures and this report for archive. Exclude duplicate builder/failure logs,
full upstream checkout/generated autoloads/bytecode/Nix products; relevant harness
failure facts distilled here. No inferred committed candidate test provenance.
