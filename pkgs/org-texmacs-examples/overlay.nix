{ }: final_: prev_: {
  org-texmacs-examples = final_.callPackage ./package.nix {
    emacs = (final_.emacsPackagesFor final_.emacs).withPackages (epkgs_: [
      (epkgs_.org-texmacs.override { texmacs = final_.texmacs-fandol-with-gotor-support; })
    ]);
  };
}
