{
  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    flake-parts.url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
  };
  outputs = { nixpkgs, ... }: {
    checks.x86_64-linux.probes = let pkgs = nixpkgs.legacyPackages.x86_64-linux; in
      pkgs.runCommand "org-texmacs-footnote-target-probes" {
        nativeBuildInputs = [ pkgs.texmacs pkgs.poppler-utils
          (pkgs.python3.withPackages (p: [ p.pypdf ])) ];
        TEXMACS_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
      } ''
        mkdir -p "$TMPDIR/home" "$out"
        export HOME="$TMPDIR/home"
        python ${./run.py} "$out" ${./generic-control.tm} ${./article-control.tm}
      '';
  };
}
