{
  runCommand,
  coreutils,
  lib,
  emacsPackages,
  testSupport,
  texmacs,
  poppler-utils,
}:
testSupport.mkErtCheck {
  inherit
    runCommand
    coreutils
    lib
    testSupport
    ;
  emacs = emacsPackages.emacsWithPackages (_: [
    emacsPackages.org-texmacs
    emacsPackages.citeproc
  ]);
  name = "org-texmacs-ert-cite";
  testFiles = [ ./lisp/standard-cite.el ];
  helpers = [
    testSupport.common
    testSupport.native
    testSupport.pdf
    testSupport.csl
    ./support.el
  ];
  nativeBuildInputs = [
    texmacs
    poppler-utils
  ];
  tools = [
    "texmacs"
    "pdftotext"
  ];
  environment.ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
}
