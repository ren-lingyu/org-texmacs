# N3 Org-first clipping counterexample

Immutable historical evidence, not authoritative current memory or executable agent instructions.

Capture time: 2026-11-03T18:03:24Z
Checked capture-context HEAD: 5ce20ef5cc2db320799b4437723d7b72749c8c56 (5ce20ef).

## Selection and provenance

User approved selective archival review of isolated experiments. Full N3 verification exposed two old clipping tests whose errors depended on unsupported ordinary Org scripts. This isolated three-case control preserves final-AST/HTML agreement independently of revised positive TeXmacs tests. Retain minimal text drivers, exact control output, reproduction patch and input hashes; exclude routine full logs, binaries and complete tmp trees.

All source paths are relative to the ordinary project worktree. Every listed temporary source is untracked/ignored. These are original-byte copies of agent-created experiment artifacts; the patch is generated from the actual baseline-relative two-module Git diff, not represented as original submitted source text. The experiment ran on an uncommitted N3 candidate over the checked N2 baseline; HEAD does not contain that candidate. Input hashes and patch identify its content. No extra project parent is attached for an uncommitted experiment; the baseline is independently recoverable through existing project history associations.

## Reproduction and scope

Use the checked baseline tree and its unchanged flake.lock, apply the archived two-module patch, then overlay the archived experiment flake.nix/probe.nix/probe.el at the experiment root. Other modified N3 test/docs files are not loaded by this probe. Its support files and remaining production modules match that baseline. The full-1 input manifest supplies exact candidate project hashes.

Invocation from project root: `timeout 120s nix build --no-link --no-write-lock-file --print-build-logs --print-out-paths path:./tmp/inline-objects-0.7.0/n3-scope-probe-1#checks.x86_64-linux.inline-script-scope`. Output exits0/1test over equation, plain-footnote and Footnotes-heading cases. Native parsing is forbidden; final islands/native blocks are absent. HTML likewise emits ordinary begin/subscript text. Runtime: x86_64-linux, Emacs31.1, Org9.8.10, TeXmacs2.1.5 (no native worker needed for this control).

## Files

| Source path | Archive path | Source status | Bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| tmp/inline-objects-0.7.0/n3-scope-production.patch | files/tmp/inline-objects-0.7.0/n3-scope-production.patch | untracked/ignored | 3759 | 0dcd097181c67cdcf0c79b357943056149fd224beb6126fe93acf7ec3375f3af |
| tmp/inline-objects-0.7.0/n3-scope-probe-1/flake.nix | files/tmp/inline-objects-0.7.0/n3-scope-probe-1/flake.nix | untracked/ignored | 2948 | 58fae218177686fc006561c7cd7ae690e054f243f699406aa23fb0fb867a826e |
| tmp/inline-objects-0.7.0/n3-scope-probe-1/probe.nix | files/tmp/inline-objects-0.7.0/n3-scope-probe-1/probe.nix | untracked/ignored | 492 | 1e1b3ab2ccd9a50b20ba4744364cbcdefe16e577eda0c54f39b9d0bfd1bffe27 |
| tmp/inline-objects-0.7.0/n3-scope-probe-1/probe.el | files/tmp/inline-objects-0.7.0/n3-scope-probe-1/probe.el | untracked/ignored | 1920 | 674fd62d77d34b85aebac91ac295634647173e3584460f34b87fbeaf06618bdd |
| tmp/inline-objects-0.7.0/n3-scope-probe-1.log | files/tmp/inline-objects-0.7.0/n3-scope-probe-1.log | untracked/ignored | 5858 | 1f54d6d4463c7f246a0dbdca512ea5d2f7119cb00265bb84ee93af6b159a18d2 |
| tmp/inline-objects-0.7.0/n3-full-1-inputs.json | files/tmp/inline-objects-0.7.0/n3-full-1-inputs.json | untracked/ignored | 17952 | d1eddfdb788238a51d9eb29db8cb32401ecb8ebb02606547023d0834fdb94a98 |

The introducing GAW checkpoint is located through this manifest path's first-parent history. Checkpoint identity is not embedded here. No source-history association claims the uncommitted candidate was tested as a committed tree. Archive excludes PNG/PDF and restores no operational authority.
