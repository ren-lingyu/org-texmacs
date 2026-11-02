# Stage A follow-up: early node-string-filter rejection

This follows archive/2026-11-02T16-54-11Z--440b331/MANIFEST.md. The user explicitly
chooses rejecting unsupported node-string filters before callback execution;
full node-string-filter support is not a v0.7.0 release requirement. Standard
options/AST semantics and final body/output text filters remain required.

The original isolated source snapshot is still130inputs from
440b33119e7878eba8a11b11e252ad711c3cae74, described by source-manifest.json and
the copied flake/lock. The prior archive retains those exact inputs/manifest and
common probe Nix files. Only probe.el gained the extra guarded experiments.
This is an isolated prototype, not the later modified production worktree.

Command, same declared120s timeout and110s internal ERT limit:

```
timeout 120s nix build --no-link --no-write-lock-file --max-jobs 2 --print-out-paths path:/home/lingyu/Projects/org-texmacs/tmp/standard-export-0.7.0-a/project#checks.x86_64-linux.standard-export-probe -L
```

Attempt6 exits0:18/18 in8.603494s, printing Emacs31.1/Org9.8.10. It repeats the
prior counterexamples and adds rejection of initially installed node callbacks,
options-installed callbacks and AST-installed callbacks before Cite (callback
side-effect count stays zero). Standard AST/options/final text behavior survives;
ASCII node filters remain active. The selected mechanism uses backend options/
tree callbacks for early detection, with texmacs-only checks at the public
org-export-data/org-cite-process-citations boundaries for later INFO mutations.
It does not advise or copy private Org preparation. No arbitrary user-code
sandbox or prediction of callback effects is claimed.

Artifact: /nix/store/rcr4mcpvjb8aw9mpy197k9x6rlmgqcpf-org-texmacs-standard-export-stage-a.
The first archive's final script/log refer to the earlier12-probe stage; this
follow-up preserves the exact18-probe script and its log rather than modifying
that immutable archive. Replay uses that earlier archive's flake/lock/test Nix
and source-manifest/reconstructed project inputs, replacing probe.el with this
follow-up version. No real org-roam-organize integration or complete stage A
production gate follows merely from these probes.

Retention: exact later-INFO-installation/Cite controls justify preserving this
small supplement, even though the production candidate now also has related
maintained regressions. Only this report, final prototype script and attempt6
log are selected. Do not duplicate all original inputs/closures/binaries/logs.
