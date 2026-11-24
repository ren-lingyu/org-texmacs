{
  description = "D2 title formatter provenance baseline";
  inputs.project.url = "git+file:///home/lingyu/Projects/org-texmacs?ref=main&rev=0aabcd64225dd921f9dda3ac4877abd91b5efccc";
  outputs = { self, project }:
    let
      system = "x86_64-linux";
      pkgs = project.inputs.nixpkgs.legacyPackages.${system};
      emacs = pkgs.emacsPackages.emacsWithPackages (_: [ project.packages.${system}.org-texmacs ]);
    in {
      packages.${system}.stock = pkgs.runCommand "org-texmacs-d2-headline-provenance" {
        nativeBuildInputs = [ pkgs.coreutils ];
      } ''
        export HOME="$TMPDIR/probe-home"
        mkdir -p "$HOME" "$out"
        set -o pipefail
        timeout --kill-after=5s 75s ${pkgs.lib.getExe' emacs "emacs"} -Q --batch \
          --load ${./probe.el} 2>&1 | tee "$out/report.txt"
      '';
    };
}
