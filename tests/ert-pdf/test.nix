{
  runCommand,
  coreutils,
  lib,
  emacs,
  testSupport,
  texmacs,
  poppler-utils,
  python3,
}:
let
  testFiles = [
    ./lisp/document.el
    ./lisp/frontend.el
    ./lisp/pdf.el
    ./lisp/preprocess.el
    ./lisp/serialization.el
    ./lisp/special-blocks.el
    ./lisp/worker.el
  ];
in
runCommand "org-texmacs-ert-pdf"
  {
    nativeBuildInputs = [
      coreutils
      texmacs
      poppler-utils
      (python3.withPackages (ps: [ ps.pypdf ]))
    ];
    ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
    ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [
      testSupport.common
      testSupport.native
      testSupport.pdf
    ];
    ORG_TEXMACS_TEST_FILES = builtins.toJSON testFiles;
    ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [
      "texmacs"
      "pdftotext"
      "pdftohtml"
      "pdftoppm"
      "pdfinfo"
      "python3"
    ];
    ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
    ORG_TEXMACS_TEST_PDF_LINKS = ./python/pdf-links.py;
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out"
    export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
    set -o pipefail
    set +e
    timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch \
      --load ${testSupport.runner} 2>&1 | tee "$out/ert.log"
    status=$?
    set -e
    exit "$status"
  ''
