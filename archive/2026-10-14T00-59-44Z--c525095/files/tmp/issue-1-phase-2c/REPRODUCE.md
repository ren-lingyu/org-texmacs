# Reproduction and evidence limits

Native research: materialize project sources/tests from c52509573e5bccddeb661cf1dab1802733ac7dec
into an independent project tmp directory; copy archived flake.nix, flake.lock and
phase2c-probes.el there. Build checks.x86_64-linux.phase2c-probes with timeout120s,
--no-link and --no-write-lock-file. Probes call native Org helpers only, assert
Emacs31.1/Org9.8.10 and do not call the candidate preprocessing implementation.
The archived flake also declares a focused check; do not use baseline tests to
claim reproduction of the later candidate gate. Candidate full validation requires
23 exact final-inputs.json inputs from the implemented working tree/future user
commit, not merely the c525095 baseline. Archived manifest hashes identify candidate
bytes but are not copies of candidate source files. Maintained project ERT/history
preserve accepted implementation; no duplicate production source archive.

Actual successful commands used path:/home/lingyu/Projects/org-texmacs/tmp/issue-1-phase-2c:
120s nix build -L --no-link --no-write-lock-file ...#checks.x86_64-linux.phase2c-probes
120s nix build -L --no-link --no-write-lock-file ...#checks.x86_64-linux.phase2c-focused
240s nix flake check -L --no-write-lock-file ...

Reports/logs preserve native stage/STM hazards and line-preserving comparison,
which final protected maintained tests cannot alone reconstruct. Native source
excerpts inspected from locked Org ox.el3318-3840 and org.el4862-4912 (reader),
prior source digest in Phase2a source-evidence.txt. No unpinned latest/local Org used.
Full gate27focused/368ERT/all5checks x86_64-linux; no other-platform/GUI/real package
or atomic filesystem claims. User mirror transmission config remains separate.
