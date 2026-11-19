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
  # Pin the external extension used by this integration check.
  organize = builtins.fetchTree {
    type = "github";
    owner = "ren-lingyu";
    repo = "org-roam-organize";
    rev = "56fdaac6adab06deafc23357aec63ae2a497e09b";
    narHash = "sha256-rZBPdTRUmPKrk0JWkF5ukQs9qjPzo6600Vct2P3Ac9A=";
  };
  emacs = emacsPackages.emacsWithPackages (_: [
    emacsPackages.org-texmacs
    emacsPackages.org-roam
    emacsPackages.citeproc
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
    testSupport.csl
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
