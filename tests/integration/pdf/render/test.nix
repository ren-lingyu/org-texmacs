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
  emacs = emacsPackages.emacsWithPackages (_: [ emacsPackages.org-texmacs ]);
in
runCommand "org-texmacs-integration-pdf-render"
  {
    nativeBuildInputs = [
      coreutils
      texmacs
      poppler-utils
      (python3.withPackages (ps: [ ps.pypdf ]))
    ];
    ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
    ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [
      testSupport.document
      testSupport.native
      testSupport.pdf
      ./support.el
    ];
    ORG_TEXMACS_TEST_FILES = builtins.toJSON [ ./lisp/ert-pdf-pdf.el ];
    ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [
      "texmacs"
      "pdftotext"
      "pdfinfo"
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
