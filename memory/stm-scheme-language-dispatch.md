# STM Scheme language dispatch

## Proposed migration and evidence gate

Before the migration, the block editor and Org-side indentation selected a
Scheme mode via `org-texmacs-edit-mode`. Embedded fontification already
requested the `"scheme"` language through Org Src. The migration gives Org Src
and Emacs ownership of mode selection. Org-TeXmacs continues to own STM
recognition, payload ranges and the block-editing lifecycle.

First prove that one Org Src mapping can drive editing, indentation and
fontification in the locked Emacs 31.1 and Org 9.8.10 environment. Use a
temporary configuration and a probe that exercises the existing editor
with only the mode-selection helper replaced in memory. Keep the Custom
option, production code, documentation and maintained tests in place
during this experiment.

Probe default resolution, Emacs remapping, explicit Org mapping, a missing
mode, an initializer that raises an error, and real Scheme Tree-sitter
when available. Check edit save, cancel and reuse, private indentation
and failure cleanup, both carrier syntaxes, payload property ownership,
source preservation and the Org native fontification toggle. Record real
Tree-sitter as unverified if the mode or grammar is missing.

If the probe establishes the necessary behavior, remove the old option
without an alias and use the Org Src resolver. Keep normal Org source
editing and the package's STM parsing and export paths independent of
this selection. Update maintained tests and documentation with the
implementation. This migration is separate from the completed core nodes
and from inline fragment editing, preview and any API freeze.

## Isolated findings

The locked package loaded Emacs 31.1 and Org 9.8.10. Eight probe tests
passed. The real Tree-sitter test was skipped because the environment did
not provide `scheme-ts-mode`. The repro is
`tmp/stm-scheme-org-src-probe.el` in the project worktree.

An in-memory resolver substitution drove native block editing, Org-side
line/region indentation and both inline carriers with the default Scheme
mode, controlled Emacs remapping, and explicit Org language mapping. An
explicit Org mapping changes the input to Emacs remapping. The probe
checked payload faces and syntax properties, carrier face ownership,
repeat fontification, the Org native fontification toggle, save/exit,
cancel, buffer reuse, multiline whitespace and source protection. The
baseline in this environment binds exit to `C-c '` and cancel/save to
`C-c C-k` / `C-x C-s`. It has no fixed `C-c C-c` binding.

Org's fontifier in the private staging buffer missed source-local language
mappings and remaps. Rebinding those settings at the Org Src call selected
the source buffer's mode for both cases without adding a selection rule.
A missing mode yielded nil from `org-src-get-lang-mode-if-bound`, skipped
fontification, and failed editing/indentation before touching the source.
An initializer exception left no live source-edit buffer or source
change. Org contained the exception during fontification and emitted one
diagnostic per attempt. Retain Org's diagnostic and retry behavior.

## Delivered implementation

The user committed the migration in the project snapshot associated with
this checkpoint. It removes the Custom option. Editing resolves Scheme
through Org Src, and the temporary fontification view receives the source
buffer's language mappings and remaps before invoking Org's fontifier.
The migration docs cover the shared Emacs configuration and the existing
Org Src keys. No Scheme mode or grammar-specific branch is needed.

Under the locked environment, the offline targeted Nix build passed byte
compilation, all 349 Core ERT tests, package-lint and treefmt. The Core suite
checks remapping, explicit language mappings, failure cleanup and fontifier
ownership. Agent-run validation was limited to these targeted checks.
The user subsequently reported that all manually run tests and the
`org-texmacs-examples` build passed. The exact commands and logs were not
provided. Real Scheme Tree-sitter remains unverified.

The delivered change is independent of inline fragment editing and preview.
