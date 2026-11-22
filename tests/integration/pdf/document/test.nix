{
  pkgs,
  pdfInspector,
  testSupport,
}:
let
  inherit (pkgs)
    coreutils
    emacsPackages
    lib
    runCommand
    texmacs
    poppler-utils
    python3
    ;
  emacs = emacsPackages.emacsWithPackages (_: [
    emacsPackages.org-texmacs
    emacsPackages.citeproc
  ]);
in
runCommand "org-texmacs-integration-pdf-document"
  {
    nativeBuildInputs = [
      coreutils
      texmacs
      poppler-utils
      (python3.withPackages (ps: [ ps.pypdf ]))
    ];
    ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
    ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [
      testSupport.csl
      testSupport.document
      testSupport.native
      testSupport.pdf
      ./support.el
    ];
    ORG_TEXMACS_TEST_FILES = builtins.toJSON [
      ./lisp/ert-cite-standard-cite.el
      ./lisp/ert-pdf-frontend.el
      ./lisp/ert-pdf-metadata.el
      ./lisp/ert-pdf-native-cite.el
      ./lisp/ert-pdf-preprocess.el
      ./lisp/ert-pdf-special-blocks.el
      ./lisp/ert-pdf-standard-frontend.el
      ./lisp/ert-pdf-standard-source.el
    ];
    ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [
      "texmacs"
      "pdftotext"
      "pdfinfo"
      "pdftoppm"
      "pdftohtml"
      "python3"
    ];
    ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
    ORG_TEXMACS_TEST_PDF_LINKS = pdfInspector;
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out"
    export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
    set -o pipefail
    timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch --load ${testSupport.runner} 2>&1 | tee "$out/ert.log"
  ''
