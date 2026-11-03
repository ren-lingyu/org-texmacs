{
  runCommand,
  coreutils,
  lib,
  emacsPackages,
  texmacs,
  poppler-utils,
  testSupport,
}:
let
  # Explicit optional replay; these extensions are not default runtime inputs.
  organize = builtins.fetchTree {
    type = "github";
    owner = "ren-lingyu";
    repo = "org-roam-organize";
    rev = "56fdaac6adab06deafc23357aec63ae2a497e09b";
    narHash = "sha256-rZBPdTRUmPKrk0JWkF5ukQs9qjPzo6600Vct2P3Ac9A=";
  };
  emacs = emacsPackages.emacsWithPackages (ep: [
    ep.org-texmacs
    ep.org-roam
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
  name = "org-texmacs-standard-cite-integration";
  testFiles = [ ./lisp/standard-cite.el ];
  helpers = [
    testSupport.common
    testSupport.native
    testSupport.pdf
    ../ert-cite/support.el
  ];
  emacsArgs = [
    "-L"
    "${organize}/lisp"
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
