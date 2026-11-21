{
  inputs.release.url = "github:ren-lingyu/org-texmacs/d0f521688dac15ca1cbdf64f54f114d7ca9fbca4";

  outputs = { release, ... }:
    let
      system = "x86_64-linux";
      pkgs = release.inputs.nixpkgs.legacyPackages.${system};
      mkProbe = name: emacs: native: pkgs.runCommand name {
        STM_NATIVE = if native then "1" else "0";
      } ''
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME" "$out"
        export STM_REPORT="$out/result.txt"
        ${pkgs.coreutils}/bin/timeout 90s ${emacs}/bin/emacs -Q --batch --load ${./probe.el}
        cat "$STM_REPORT"
      '';
    in {
      checks.${system} = {
        stm-pure = mkProbe "stm-pure" pkgs.emacs false;
        stm-native-diff = mkProbe "stm-native-diff" release.packages.${system}.emacs true;
      };
    };
}
