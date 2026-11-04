{ pkgs, suite }:
let support = import ./tests/support;
in support.mkErtCheck {
  inherit (pkgs) runCommand coreutils lib;
  emacs = pkgs.emacs-with-org-texmacs;
  testSupport = support;
  name = "org-texmacs-native-cite-${suite}";
  testFiles = [ (./. + "/${suite}.el") ];
  helpers = [ support.common support.native support.pdf ./probe-common.el ];
  nativeBuildInputs = [ pkgs.texmacs pkgs.poppler-utils ];
  tools = [ "texmacs" "pdftotext" "pdftoppm" ];
  environment = {
    ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
    NATIVE_ADAPTER = ./adapter.el;
    NATIVE_STYLE_SCHEME = ./styles.scm;
  };
}
