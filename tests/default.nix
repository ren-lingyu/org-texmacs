{
  src,
  emacs,
  pkgs,
  llib,
}:
let
  testSupport = import ./support;
  pdfSuites = import ./ert-pdf/suites.nix;
  mkPdfCheck = pkgs.callPackage ./ert-pdf/mk-check.nix {
    inherit emacs testSupport;
    pdfInspector = pdfSuites.inspector;
  };
in
llib.tests.mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";

  # Only directories with a test overlay enter the default checks. Integration
  # remains a separate entry requiring caller-supplied extension sources.
  args = {
    inherit (pkgs)
      lib
      runCommand
      coreutils
      gnutar
      patch
      texmacs
      poppler-utils
      python3
      gzip
      makeFontsConf
      emacsPackages
      ;
    texmacsWithGotorSupport = pkgs.texmacs-with-gotor-support;
    inherit
      emacs
      src
      testSupport
      pdfSuites
      mkPdfCheck
      ;
  };
}
