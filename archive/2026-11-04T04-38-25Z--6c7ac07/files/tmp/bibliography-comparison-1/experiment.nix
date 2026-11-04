{ pkgs, suite }:
let support = import ./tests/support;
in support.mkErtCheck {
  inherit (pkgs) runCommand coreutils lib;
  emacs = pkgs.emacsPackages.emacsWithPackages (ep: [ ep.org-texmacs ep.citeproc ]);
  testSupport = support;
  name = "org-texmacs-bib-compare-${suite}";
  testFiles = [ (./. + "/${suite}.el") ];
  helpers = [ support.common support.native support.pdf ./probe-common.el ];
  nativeBuildInputs = [ pkgs.texmacs pkgs.poppler-utils ];
  tools = [ "texmacs" "pdftotext" "pdftoppm" ];
  environment = {
    ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
    BIB_COMPARE_FANDOL_PROGRAM = pkgs.lib.getExe' pkgs.texmacs-fandol "texmacs";
    BIB_COMPARE_FIXTURES = ./fixtures;
    BIB_COMPARE_CITEPROC_VERSION = pkgs.emacsPackages.citeproc.version;
  };
}
