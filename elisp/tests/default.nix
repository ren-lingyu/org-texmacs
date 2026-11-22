{
  lib,
  mkChecks,
  emacsPackages,
  runCommand,
  coreutils,
  setupfileTest,
}:
let
  testSupport = import ./support;
  emacs = emacsPackages.emacsWithPackages (_: [ emacsPackages.org-texmacs ]);

in
mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";

  checks = lib.optionalAttrs (setupfileTest != null) {
    ert-setupfile = testSupport.mkErtCheck {
      inherit
        runCommand
        coreutils
        lib
        testSupport
        emacs
        ;
      name = "org-texmacs-org-10pre-ert-setupfile";
      testFiles = [ setupfileTest ];
      helpers = [ ];
      pure = true;
      environment = {
        ORG_TEXMACS_TEST_EXPECTED_ORG = emacsPackages.org;
        ORG_TEXMACS_TEST_EXPECTED_PACKAGE = emacsPackages.org-texmacs;
      };
    };
  };
  args = {
    inherit
      lib
      runCommand
      coreutils
      emacsPackages
      emacs
      testSupport
      ;
  };
}
