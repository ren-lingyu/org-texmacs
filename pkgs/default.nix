{ llib, src }: {
  overlays = llib.packages.mkOverlays {
    root = ./.;
    overlayFile = "overlay.nix";
    extraArgs = { inherit src; };
    groups = {
      emacsPackages = {
        include = [ "emacsPackages" ];
      };
      texmacs = {
        include = [ "texmacs-with-gotor-support" ];
      };
      legacy = {
        export = true;
      };
    };
  };
}
