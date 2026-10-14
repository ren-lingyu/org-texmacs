{
  description = "Isolated Org minimum API signature audit";
  inputs.nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
  inputs.org98 = { url = "github:bzg/org-mode/release_9.8"; flake = false; };
  outputs = { nixpkgs, org98, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    ep = pkgs.emacsPackagesFor pkgs.emacs31;
    runtime = ep.emacsWithPackages (ps: [ ps.org ]);
    source98 = pkgs.runCommand "org-9.8-probe-source" { nativeBuildInputs = [ pkgs.emacs31 ]; } ''
      mkdir -p "$out"
      cp ${org98}/lisp/*.el "$out/"
      cat > "$out/org-version.el" <<'EOF'
      ;;; -*- lexical-binding: t; -*-
      (defun org-release () "9.8")
      (defun org-git-version () "9.8-89df5bf")
      (provide 'org-version)
      EOF
      emacs -Q --batch -L "$out" --eval '(progn (require (quote cl-lib)) (require (quote jka-compr)) (require (quote loaddefs-gen)) (loaddefs-generate "'$out'" "'$out'/org-loaddefs.el"))'
    '';
    audit = pkgs.runCommand "org-minimum-api-signatures" { nativeBuildInputs = [ runtime ]; } ''
      mkdir -p "$out" "$TMPDIR/home"
      export HOME="$TMPDIR/home"
      set +e
      emacs -Q --batch --load ${./signatures.el} \
        --eval '(org-minimum-api-audit "${./project}" "${org98}/lisp" "'$out'")' \
        > "$out/audit.log" 2>&1
      status=$?
      set -e
      cat "$out/audit.log"
      exit "$status"
    '';
    runtimeAudit = pkgs.runCommand "org-minimum-api-runtime98" { nativeBuildInputs = [ runtime ]; } ''
      mkdir -p "$out" "$TMPDIR/home"
      export HOME="$TMPDIR/home"
      set +e
      emacs -Q --batch -L ${source98} -L ${./project} --load ${./runtime-signatures.el} \
        --eval '(org-minimum-api-runtime-audit "${./project}" "${source98}" "${audit}/signatures.sexp" "'$out'")' \
        > "$out/audit.log" 2>&1
      status=$?
      set -e
      cat "$out/audit.log"
      exit "$status"
    '';
  in { checks.${system} = { signatures = audit; runtime98 = runtimeAudit; }; };
}
