{
  runCommand,
  coreutils,
  lib,
  emacs,
  texmacs,
  poppler-utils,
  extensionSources,
  testSupport,
}:
# Caller supplies installed org-texmacs/Org-roam and pinned extension sources.
let
  testFiles = [ ./lisp/extensions.el ];
in
runCommand "org-texmacs-integration"
  {
    nativeBuildInputs = [
      coreutils
      texmacs
      poppler-utils
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
    ];
    ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
    ORG_TEXMACS_TEST_PROGRAM = lib.getExe' texmacs "texmacs";
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out"
    export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
    set +e
    timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch -L ${extensionSources.include} -L ${extensionSources.organize} -L ${extensionSources.blog} \
      --load ${testSupport.runner} > "$out/ert.log" 2>&1
    status=$?
    set -e
    cat "$out/ert.log"
    exit "$status"
  ''
