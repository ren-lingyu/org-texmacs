{ pkgs }:
let support = import ./tests/support;
in support.mkErtCheck {
  inherit (pkgs) runCommand coreutils lib;
  emacs = pkgs.emacs-with-org-texmacs;
  testSupport = support;
  name = "org-texmacs-inline-script-probe";
  testFiles = [ ./probe.el ];
  helpers = [ support.common support.native support.pdf ];
  nativeBuildInputs = [ pkgs.texmacs pkgs.poppler-utils ];
  tools = [ "texmacs" "pdftotext" ];
  environment.ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
}
