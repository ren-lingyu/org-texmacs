{
  runCommand,
  coreutils,
  lib,
  name,
  emacs,
  testSupport,
  testFiles,
  helpers,
  tools ? [ ],
  nativeBuildInputs ? [ ],
  environment ? { },
  emacsArgs ? [ ],
  timeout ? 600,
}:
runCommand name
  (
    environment
    // {
      nativeBuildInputs = [ coreutils ] ++ nativeBuildInputs;
      ORG_TEXMACS_TEST_BOOTSTRAP = testSupport.bootstrap;
      ORG_TEXMACS_TEST_HELPERS = builtins.toJSON helpers;
      ORG_TEXMACS_TEST_FILES = builtins.toJSON testFiles;
      ORG_TEXMACS_TEST_TOOLS = builtins.toJSON tools;
      ORG_TEXMACS_TEST_STRICT_TOOLS = "1";
    }
  )
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out"
    export ORG_TEXMACS_TEST_NAMES_FILE="$out/test-names.txt"
    set -o pipefail
    set +e
    timeout --kill-after=10s ${toString timeout}s ${lib.getExe' emacs "emacs"} -Q --batch ${lib.escapeShellArgs (map toString emacsArgs)} \
      --load ${testSupport.runner} 2>&1 | tee "$out/ert.log"
    status=$?
    set -e
    exit "$status"
  ''
