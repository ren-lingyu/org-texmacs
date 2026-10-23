{
  runCommand,
  coreutils,
  lib,
  src,
  emacs,
  package-lint,
}:

runCommand "org-texmacs-package-lint"
  {
    nativeBuildInputs = [ coreutils ];
    ORG_TEXMACS_TEST_SOURCE = src;
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    timeout --kill-after=10s 120s ${lib.getExe' emacs "emacs"} -Q --batch \
      -L ${package-lint}/share/emacs/site-lisp/elpa/package-lint-${package-lint.version} \
      --load ${./lisp/package-lint.el}
    touch "$out"
  ''
