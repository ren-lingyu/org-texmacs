{ llib, src }: {
  overlays = llib.packages.mkOverlays {
    root = ./.;
    overlayFile = "overlay.nix";
    extraArgs = { inherit src; };
    groups = {
      default = {
        exclude = [
          "emacs-with-org-texmacs"
          "org-texmacs-examples"
          "texmacs-fandol"
          "texmacs-fandol-with-gotor-support"
        ];
      };
      legacy = {
        export = true;
      };
    };
  };
}
