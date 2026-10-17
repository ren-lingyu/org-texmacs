{ pkgs, source, emacs, emacsPackages, buildPackage } : {

  caption-inline-footnotes = import ./caption-inline-footnotes {
    inherit pkgs source emacsPackages buildPackage;
  };

  ert = import ./ert {
    inherit pkgs emacs;
  };

  package-lint = import ./package-lint {
    inherit pkgs source emacs;
  };

}
