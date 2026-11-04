{ pkgs }:
let support = import ./tests/support;
in support.mkErtCheck {
  inherit (pkgs) runCommand coreutils lib;
  emacs = pkgs.emacsPackages.emacsWithPackages (ep: [ ep.org-texmacs ep.citeproc ]);
  testSupport = support;
  name = "org-texmacs-inline-csl-flow";
  testFiles = [ ./flow.el ];
  helpers = [ support.common support.native support.pdf ];
  nativeBuildInputs = [ pkgs.texmacs pkgs.poppler-utils ];
  tools = [ "texmacs" "pdftotext" "pdftoppm" ];
  environment = {
    ORG_TEXMACS_TEST_PROGRAM = pkgs.lib.getExe' pkgs.texmacs "texmacs";
    ORG_TEXMACS_PROBE_INIT_LATEX = "${pkgs.texmacs}/share/TeXmacs/progs/convert/latex/init-latex.scm";
    ORG_TEXMACS_PROBE_CITEPROC_SOURCE = pkgs.emacsPackages.citeproc.src;
    ORG_TEXMACS_PROBE_CITEPROC_VERSION = pkgs.emacsPackages.citeproc.version;
  };
}
