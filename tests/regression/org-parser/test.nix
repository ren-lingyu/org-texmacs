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
runCommand "org-texmacs-regression-org-parser" { nativeBuildInputs = [ coreutils ]; } ''
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME" "$out"
  set -o pipefail
  timeout --kill-after=10s 600s ${lib.getExe' emacs "emacs"} -Q --batch \
    ${
      lib.escapeShellArgs (
        lib.concatMap
          (file: [
            "--load"
            "${file}"
          ])
          [
            testSupport.document
            ./lisp/ert-native-document.el
          ]
      )
    } \
    --funcall ert-run-tests-batch-and-exit 2>&1 | tee "$out/ert.log"
''
