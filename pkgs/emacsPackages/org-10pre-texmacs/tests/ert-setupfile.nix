{
  coreutils,
  emacsWithPackages,
  lib,
  org,
  org-texmacs,
  runCommand,
}:
let
  testSupport = import ../../../../elisp/tests/support;
in
testSupport.mkErtCheck {
  inherit
    coreutils
    lib
    runCommand
    testSupport
    ;
  name = "org-texmacs-org-10pre-ert-setupfile";
  emacs = emacsWithPackages (_: [ org-texmacs ]);
  testFiles = [ ./setupfile.el ];
  helpers = [ ];
  environment = {
    ORG_TEXMACS_TEST_EXPECTED_ORG = org;
    ORG_TEXMACS_TEST_EXPECTED_PACKAGE = org-texmacs;
  };
}
