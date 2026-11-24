{
  description = "Org TeXmacs figure validation reachability through footnotes";
  inputs.project.url = "git+file:///home/lingyu/Projects/org-texmacs?ref=main&rev=5b396dcf7f7a5c9763829ab70fc0f3d535f3e266";
  outputs = { self, project }:
    let
      system = "x86_64-linux";
      pkgs = project.inputs.nixpkgs.legacyPackages.${system};
      packages = project.packages.${system};
      probe = name: package:
        let emacs = pkgs.emacsPackages.emacsWithPackages (_: [ package ]);
        in pkgs.runCommand "org-texmacs-footnote-reachability-${name}" {
          nativeBuildInputs = [ pkgs.coreutils ];
        } ''
          export HOME="$TMPDIR/home"
          mkdir -p "$HOME" "$out"
          set -o pipefail
          timeout --kill-after=5s 75s ${pkgs.lib.getExe' emacs "emacs"} -Q --batch \
            --load ${./probe.el} 2>&1 | tee "$out/report.txt"
        '';
    in {
      packages.${system} = {
        stock = probe "stock" packages.org-texmacs;
        pre = probe "pre" packages.org-10pre-texmacs;
      };
    };
}
