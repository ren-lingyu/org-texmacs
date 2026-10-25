{
  runCommand,
  coreutils,
  lib,
  emacs,
  texmacs,
  poppler-utils,
  extensionSources,
  testSupport,
}:
# Caller supplies installed org-texmacs/Org-roam and pinned extension sources.
let
  testFiles = [ ./lisp/extensions.el ];
in
testSupport.mkErtCheck {
  inherit runCommand coreutils lib emacs testSupport testFiles;
  name = "org-texmacs-integration";
  nativeBuildInputs = [ texmacs poppler-utils ];
  helpers = [
    testSupport.common
    testSupport.native
    testSupport.pdf
  ];
  tools = [ "texmacs" "pdftotext" ];
  emacsArgs = [
    "-L"
    extensionSources.include
    "-L"
    extensionSources.organize
    "-L"
    extensionSources.blog
  ];
  environment = {
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
  };
}
