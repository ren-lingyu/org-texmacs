{
  description = "Issue #1 Phase 3a bibliography discovery/acquisition research";
  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    flake-parts.url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, ... }: let
      epkgs = pkgs.emacsPackagesFor pkgs.emacs31;
      org = epkgs.org.overrideAttrs (old: {
        src = old.src.overrideAttrs (_: {
          urls = [
            "https://mirrors.ustc.edu.cn/elpa/gnu/org-${epkgs.org.version}.tar"
            "https://mirrors.ustc.edu.cn/elpa/gnu/org-${epkgs.org.version}.tar.lz"
          ];
        });
      });
      emacs = epkgs.emacsWithPackages (_: [ org ]);
    in {
      packages.default = emacs;
      checks.discovery = pkgs.runCommand "issue-1-phase-3a-discovery" {
        nativeBuildInputs = [ emacs ];
      } ''
        mkdir -p "$out" work
        cp -r ${./fixtures} work/fixtures
        cd work
        set +e
        emacs --batch -L ${./project} --load ${./probes.el} \
          > "$out/ert.log" 2>&1
        status=$?
        set -e
        cat "$out/ert.log"
        cp environment.txt observations.sexp summary.txt "$out/"
        exit "$status"
      '';
    };
  };
}
