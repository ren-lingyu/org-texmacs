{
  lib,
  mkChecks,
  melpaBuild,
  emacsWithPackages,
  citeproc,
  package-lint,
  org,
  org-roam,
  runCommand,
  coreutils,
  gnutar,
  patch,
  texmacs,
  poppler-utils,
  python3,
}:
melpaBuild (finalAttrs_: {
  src = lib.fileset.toSource {
    root = ./src;
    fileset = ./src;
  };

  pname = "org-texmacs";
  version = "0.8.0";
  melpaVersion = finalAttrs_.version;

  files = ''(:defaults "org-texmacs-worker.scm")'';
  packageRequires = [ org ];
  turnCompilationWarningToError = true;

  doCheck = true;
  checkInputs = [ package-lint ];
  checkPhase = ''
    runHook preCheck

    (
      export HOME="$TMPDIR/package-lint-home"
      export ORG_TEXMACS_TEST_SOURCE="${finalAttrs_.src}"
      mkdir -p "$HOME"

      ${lib.getExe' coreutils "timeout"} --kill-after=10s 120s emacs -Q --batch \
        --funcall package-activate-all \
        --load ${./package-lint.el}
    )

    runHook postCheck
  '';

  passthru.tests = import ./tests {
    inherit
      lib
      mkChecks
      runCommand
      coreutils
      gnutar
      patch
      texmacs
      poppler-utils
      python3
      ;
    emacsPackages = {
      inherit
        emacsWithPackages
        citeproc
        org
        org-roam
        ;
      org-texmacs = finalAttrs_.finalPackage;
    };
  };

  meta = {
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
})
