{
  lib,
  runCommand,
  coreutils,
  emacsPackages,
}:
let
  emacs = emacsPackages.emacsWithPackages (_: [
    emacsPackages.org-texmacs
    emacsPackages.citeproc
  ]);
in
runCommand "org-texmacs-ert-csl" { nativeBuildInputs = [ coreutils ]; } ''
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
            ./lisp/standard-cite.el
          ]
      )
    } \
    --funcall ert-run-tests-batch-and-exit 2>&1 | tee "$out/ert.log"
''
