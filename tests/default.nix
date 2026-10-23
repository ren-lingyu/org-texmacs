{ pkgs, source, emacs, emacsPackages, buildPackage }:
let
  testSupport = import ./support;
  ert-core = pkgs.callPackage ./ert-core { inherit emacs testSupport; };
  ert-native = pkgs.callPackage ./ert-native { inherit emacs testSupport; };
  ert-pdf = pkgs.callPackage ./ert-pdf { inherit emacs testSupport; };
in {
  inherit ert-core ert-native ert-pdf;

  ert = pkgs.callPackage ./ert { inherit ert-core ert-native ert-pdf; };

  caption-inline-footnotes = pkgs.callPackage ./caption-inline-footnotes {
    inherit emacsPackages buildPackage testSupport;
  };

  package-lint = pkgs.callPackage ./package-lint { inherit source emacs; };
}
