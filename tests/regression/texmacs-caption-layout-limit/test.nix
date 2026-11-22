{ pkgs, testSupport }:
let
  inherit (pkgs)
    coreutils
    emacsPackages
    lib
    runCommand
    texmacs
    poppler-utils
    ;
  emacs = emacsPackages.emacsWithPackages (_: [ emacsPackages.org-texmacs ]);
in
if lib.getVersion texmacs != "2.1.5" then
  { }
else
  runCommand "org-texmacs-regression-texmacs-caption-layout-limit"
    {
      nativeBuildInputs = [
        coreutils
        texmacs
        poppler-utils
      ];
      ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
      ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [
        testSupport.document
        testSupport.native
        testSupport.pdf
      ];
      ORG_TEXMACS_TEST_FILES = builtins.toJSON [ ./lisp/ert-pdf-document.el ];
      ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [
        "texmacs"
        "pdftotext"
      ];
      ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
      ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
    }
    ''
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME" "$out"
      export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
      set -o pipefail
      timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch --load ${testSupport.runner} 2>&1 | tee "$out/ert.log"
    ''
