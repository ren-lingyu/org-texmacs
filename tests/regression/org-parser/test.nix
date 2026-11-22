{ pkgs, testSupport }:
let
  inherit (pkgs)
    coreutils
    emacsPackages
    lib
    runCommand
    ;
  emacs = emacsPackages.emacsWithPackages (_: [ emacsPackages.org-texmacs ]);
in
runCommand "org-texmacs-regression-org-parser"
  {
    nativeBuildInputs = [ coreutils ];
    ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
    ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [ testSupport.document ];
    ORG_TEXMACS_TEST_FILES = builtins.toJSON [ ./lisp/ert-native-document.el ];
    ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [ ];
    ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out"
    export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
    set -o pipefail
    timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch --load ${testSupport.runner} 2>&1 | tee "$out/ert.log"
  ''
