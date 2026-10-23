{
  lib,
  llib,
  src,
}:
{
  mkLegacyPackages =
    pkgs:
    llib.packages.mkLegacyPackages {
      root = ./.;
      overlayFile = "overlay.nix";
      inherit pkgs;
    };

  overlays = {
    default = lib.composeManyExtensions (
      builtins.attrValues (
        llib.packages.mkOverlays {
          root = ./.;
          overlayFile = "overlay.nix";
          extraArgs = { inherit src; };
        }
      )
    );
  };
}
