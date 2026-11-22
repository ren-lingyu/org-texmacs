{ pkgs, testSupport }:
let
  inherit (pkgs)
    coreutils
    emacsPackages
    lib
    runCommand
    texmacs
    ;
  emacs = emacsPackages.emacsWithPackages (_: [
    emacsPackages.org-texmacs
    emacsPackages.citeproc
  ]);
in
runCommand "org-texmacs-integration-native"
  {
    nativeBuildInputs = [
      coreutils
      texmacs
    ];
    ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
    ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [
      testSupport.csl
      testSupport.document
      testSupport.native
      ./support.el
    ];
    ORG_TEXMACS_TEST_FILES = builtins.toJSON [
      ./lisp/ert-cite-standard-cite.el
      ./lisp/ert-native-bibliography.el
      ./lisp/ert-native-document.el
      ./lisp/ert-native-frontend.el
      ./lisp/ert-native-metadata.el
      ./lisp/ert-native-model-parser.el
      ./lisp/ert-native-model-serialization.el
      ./lisp/ert-native-native-cite.el
      ./lisp/ert-native-preprocess.el
      ./lisp/ert-native-serialization.el
      ./lisp/ert-native-session.el
      ./lisp/ert-native-source.el
      ./lisp/ert-native-special-blocks.el
      ./lisp/ert-native-standard-context.el
      ./lisp/ert-native-standard-export.el
      ./lisp/ert-native-standard-source.el
      ./lisp/ert-native-worker.el
      ./lisp/ert-pdf-pdf.el
      ./lisp/ert-pdf-preprocess.el
      ./lisp/ert-pdf-standard-frontend.el
    ];
    ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [ "texmacs" ];
    ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
    ORG_TEXMACS_TEST_CITE_STYLE_SCHEME = ./native-cite-style.scm;
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out"
    export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
    set -o pipefail
    timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch --load ${testSupport.runner} 2>&1 | tee "$out/ert.log"
  ''
