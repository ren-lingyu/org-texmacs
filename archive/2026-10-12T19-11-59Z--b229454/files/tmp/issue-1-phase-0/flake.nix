{
  description = "Isolated issue #1 Org pipeline investigation";
  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    flake-parts.url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, ... }: let
    epkgs = pkgs.emacsPackagesFor pkgs.emacs31;
    # Same fixed-output Org bytes as the project; transport override only.
    orgMirror = epkgs.org.overrideAttrs (old: {
      src = old.src.overrideAttrs (_: {
        urls = [
          "https://mirrors.ustc.edu.cn/elpa/gnu/org-${epkgs.org.version}.tar"
          "https://mirrors.ustc.edu.cn/elpa/gnu/org-${epkgs.org.version}.tar.lz"
        ];
      });
    });
    emacs = epkgs.emacsWithPackages (_: [ orgMirror ]);
  in {
    packages.default = emacs;
    checks.environment = pkgs.runCommand "issue-1-org-environment" {
      nativeBuildInputs = [ emacs ];
    } ''
      mkdir -p "$out" work
      cd work
      emacs --batch --load ${./environment.el}
      cp environment.txt "$out/"
    '';
    checks.probes = pkgs.runCommand "issue-1-org-probes" {
      nativeBuildInputs = [ emacs ];
    } ''
      mkdir -p "$out" work
      cp -r ${./fixtures} work/fixtures
      cd work
      emacs --batch --load ${./environment.el} > "$out/environment.txt" 2>&1
      set +e
      emacs --batch -L ${./project} --load ${./probes.el} > "$out/ert.log" 2>&1
      status=$?
      set -e
      cat "$out/ert.log"
      cp observations.sexp summary.txt "$out/"
      test "$status" = 0
    '';
    };
  };
}
