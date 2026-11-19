{
  lib,
  mkChecks,
  emacsPackages,
  runCommand,
  coreutils,
  gnutar,
  patch,
  texmacs,
  poppler-utils,
  python3,
}:
let
  testSupport = import ./support;
  pdfSuites = import ./ert-pdf/suites.nix;

  emacs = emacsPackages.emacsWithPackages (_: [ emacsPackages.org-texmacs ]);

  mkPdfCheck = import ./ert-pdf/mk-check.nix {
    inherit
      runCommand
      coreutils
      lib
      emacs
      testSupport
      texmacs
      poppler-utils
      python3
      ;
    pdfInspector = pdfSuites.inspector;
  };
in
mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";

  args = {
    inherit
      lib
      runCommand
      coreutils
      gnutar
      patch
      texmacs
      poppler-utils
      python3
      emacsPackages
      emacs
      testSupport
      pdfSuites
      mkPdfCheck
      ;
  };
}
