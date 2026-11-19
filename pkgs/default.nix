{ llib, source }: {
  overlays = llib.packages.mkOverlays {
    root = ./.;
    overlayFile = "overlay.nix";
    extraArgs = {
      inherit source;
      mkChecks = llib.tests.mkChecks;
    };
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
