{
  runCommand,
  coreutils,
  lib,
  source,
  emacs,
}:

runCommand "org-texmacs-package-lint"
  {
    nativeBuildInputs = [ coreutils ];
    ORG_TEXMACS_TEST_SOURCE = source;
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    timeout --kill-after=10s 120s ${lib.getExe' emacs "emacs"} -Q --batch \
      --load ${./lisp/package-lint.el}
    touch "$out"
  ''
