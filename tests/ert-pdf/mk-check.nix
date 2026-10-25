{
  runCommand,
  coreutils,
  lib,
  emacs,
  testSupport,
  texmacs,
  poppler-utils,
  python3,
  pdfInspector,
}:
{ name, testFiles }:
testSupport.mkErtCheck {
  inherit
    runCommand
    coreutils
    lib
    name
    emacs
    testSupport
    testFiles
    ;
  nativeBuildInputs = [
    texmacs
    poppler-utils
    (python3.withPackages (ps: [ ps.pypdf ]))
  ];
  helpers = [
    testSupport.common
    testSupport.native
    testSupport.pdf
  ];
  tools = [
    "texmacs"
    "pdftotext"
    "pdftohtml"
    "pdftoppm"
    "pdfinfo"
    "python3"
  ];
  environment = {
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
    ORG_TEXMACS_TEST_PDF_LINKS = pdfInspector;
  };
}
