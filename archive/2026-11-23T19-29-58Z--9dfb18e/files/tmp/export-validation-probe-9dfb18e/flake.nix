{
  description = "Baseline probes for Org TeXmacs export validation";
  inputs.project.url = "git+file:///home/lingyu/Projects/org-texmacs?ref=main&rev=9dfb18ed41d3404279b203abddcb1f3e3e384453";
  outputs = { self, project }:
    let
      system = "x86_64-linux";
      pkgs = project.inputs.nixpkgs.legacyPackages.${system};
      ep = project.packages.${system};
      probe = name: package:
        let emacs = pkgs.emacsPackages.emacsWithPackages (_: [ package ]);
        in pkgs.runCommand "org-texmacs-export-validation-${name}" {
          nativeBuildInputs = [ pkgs.coreutils pkgs.texmacs ];
        } ''
          export HOME="$TMPDIR/home"
          mkdir -p "$HOME" "$out"
          set -o pipefail
          timeout --kill-after=5s 75s ${pkgs.lib.getExe' emacs "emacs"} -Q --batch \
            --load ${./probe.el} 2>&1 | tee "$out/report.txt"
        '';
    in {
      packages.${system} = {
        stock = probe "stock" ep.org-texmacs;
        pre = probe "pre" ep.org-10pre-texmacs;
      };
    };
}
