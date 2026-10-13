# Reproduce Phase 2a

Use archived flake/lock and research Lisp files. Materialize the ordinary package
files and test build definitions from main 049a5a00bdd52d83e1f03823accc9324f4bcee0c.
The archived flake preserves the user USTC transport overlay; SHA-256 source hashes
remain lock-governed. Run in an independent path:

```
timeout 120s nix build -L --no-link --no-write-lock-file path:<isolated-directory>#checks.x86_64-linux.phase2-probes
```

Output derivation ert.log contains 12/12 research results. The additional focused
check is reserved for subsequent implementation tests. Tests create/clean private
files and controlled callbacks; they do not use personal databases/native workers.
