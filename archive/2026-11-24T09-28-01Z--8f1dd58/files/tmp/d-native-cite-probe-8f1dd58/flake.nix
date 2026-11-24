{
  description = "Node D Native Cite ownership and resolution probe";
  inputs.project.url = "git+file:///home/lingyu/Projects/org-texmacs?ref=main&rev=8f1dd58d52aad211345f57ec6c28110e30f6f7b2";
  outputs = { self, project }:
    let
      system = "x86_64-linux";
      pkgs = project.inputs.nixpkgs.legacyPackages.${system};
      emacs = pkgs.emacsPackages.emacsWithPackages (_: [ project.packages.${system}.org-texmacs ]);
    in {
      packages.${system}.stock = pkgs.runCommand "org-texmacs-d-native-cite-flow-stock" {
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
