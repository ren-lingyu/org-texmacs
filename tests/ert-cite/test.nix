{
  runCommand,
  coreutils,
  lib,
  emacsPackages,
  testSupport,
  texmacs,
  poppler-utils,
}:
let
  emacs = emacsPackages.emacsWithPackages (ep: [
    ep.org-texmacs
    ep.citeproc
  ]);
in
testSupport.mkErtCheck {
  inherit
    runCommand
    coreutils
    lib
    emacs
    testSupport
    ;
  name = "org-texmacs-ert-cite";
  testFiles = [ ./lisp/standard-cite.el ];
  helpers = [
    testSupport.common
    testSupport.native
    testSupport.pdf
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
