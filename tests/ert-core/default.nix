{ runCommand, coreutils, lib, emacs, testSupport }:
let
  testFiles = [
    ./lisp/bibliography.el
    ./lisp/document.el
    ./lisp/editing.el
    ./lisp/frontend.el
    ./lisp/preprocess.el
    ./lisp/source.el
    ./lisp/special-blocks.el
    ./lisp/worker.el
  ];
in runCommand "org-texmacs-ert-core" {
  nativeBuildInputs = [ coreutils  ];
  ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
  ORG_TEXMACS_TEST_HELPERS = builtins.toJSON [ testSupport.common testSupport.native ];
  ORG_TEXMACS_TEST_FILES = builtins.toJSON testFiles;
  ORG_TEXMACS_TEST_TOOLS = builtins.toJSON [  ];
  ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
} ''
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME" "$out"
  export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
  set +e
  timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch \
    --load ${testSupport.runner} > "$out/ert.log" 2>&1
  status=$?
  set -e
  cat "$out/ert.log"
  exit "$status"
''
